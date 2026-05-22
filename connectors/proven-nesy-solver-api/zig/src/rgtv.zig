// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// rgtv.zig — RGTV grant-broker client for proven-nesy-solver-api.
//
// Replaces: proven-servers/connectors/proven-nesy-solver-api/v/rgtv_client.v
//
// Two-step grant/redeem protocol:
//   1. POST {rgtv_url}/v1/grants  {"hint":"..."}   → 201 {grant_id, expires_in_secs}
//   2. POST {rgtv_url}/v1/grants/:id/redeem  {}    → 200 {hint, value}
//
// Both requests carry:  Authorization: Bearer <RGTV_AGENT_TOKEN>
//
// Fallback: if RGTV_URL is unset or the broker is unreachable, reads the
// credential directly from the NESY_INGEST_TOKEN environment variable.
//
// loadIngestToken() should be called once at startup.  Treat the returned
// string as a secret: do not log it, do not embed it in URLs or filenames.

const std = @import("std");

// =============================================================================
// Public API
// =============================================================================

/// Fetch a credential value from the RGTV grant broker.
/// Performs the two-step grant → redeem protocol.
/// Returns an allocated slice owned by the caller (free with `allocator.free`).
pub fn fetchFromRgtv(
    allocator: std.mem.Allocator,
    rgtv_url: []const u8,
    agent_token: []const u8,
    hint: []const u8,
) ![]u8 {
    var url_buf: [512]u8 = undefined;
    var req_body_buf: [256]u8 = undefined;
    var auth_buf: [312]u8 = undefined;
    var grant_resp_buf: [1024]u8 = undefined;
    var redeem_resp_buf: [1024]u8 = undefined;

    const bearer = std.fmt.bufPrint(&auth_buf, "Bearer {s}", .{agent_token}) catch
        return error.AuthTooLong;

    // -------------------------------------------------------------------------
    // Step 1: POST /v1/grants  → 201 {"grant_id":"..."}
    // -------------------------------------------------------------------------
    const grant_body = std.fmt.bufPrint(
        &req_body_buf, "{{\"hint\":\"{s}\"}}", .{hint},
    ) catch return error.HintTooLong;

    const grants_url = std.fmt.bufPrint(
        &url_buf, "{s}/v1/grants", .{rgtv_url},
    ) catch return error.UrlTooLong;

    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    var grant_writer = std.Io.Writer.fixed(grant_resp_buf[0..]);
    const grant_result = try client.fetch(.{
        .location        = .{ .url = grants_url },
        .method          = .POST,
        .payload         = grant_body,
        .response_writer = &grant_writer,
        .extra_headers   = &.{
            .{ .name = "Content-Type",  .value = "application/json" },
            .{ .name = "Authorization", .value = bearer },
        },
    });
    if (grant_result.status != .created) return error.GrantRequestFailed;

    const grant_n = grant_resp_buf.len - grant_writer.unusedCapacityLen();
    const grant_json = grant_resp_buf[0..grant_n];
    const grant_id = extractJsonString(grant_json, "grant_id") orelse
        return error.MissingGrantId;

    // -------------------------------------------------------------------------
    // Step 2: POST /v1/grants/:id/redeem  → 200 {"value":"..."}
    // -------------------------------------------------------------------------
    const redeem_url = std.fmt.bufPrint(
        &url_buf, "{s}/v1/grants/{s}/redeem", .{ rgtv_url, grant_id },
    ) catch return error.UrlTooLong;

    var redeem_writer = std.Io.Writer.fixed(redeem_resp_buf[0..]);
    const redeem_result = try client.fetch(.{
        .location        = .{ .url = redeem_url },
        .method          = .POST,
        .payload         = "{}",
        .response_writer = &redeem_writer,
        .extra_headers   = &.{
            .{ .name = "Content-Type",  .value = "application/json" },
            .{ .name = "Authorization", .value = bearer },
        },
    });
    if (redeem_result.status != .ok) return error.RedeemFailed;

    const redeem_n = redeem_resp_buf.len - redeem_writer.unusedCapacityLen();
    const redeem_json = redeem_resp_buf[0..redeem_n];
    const value = extractJsonString(redeem_json, "value") orelse
        return error.MissingValue;

    return try allocator.dupe(u8, value);
}

/// Load NESY_INGEST_TOKEN.  Tries RGTV grant broker first when RGTV_URL is
/// set; falls back to raw NESY_INGEST_TOKEN env var on any failure.
/// Returns a heap-allocated slice.  On allocation failure returns an empty slice.
pub fn loadIngestToken(allocator: std.mem.Allocator) []const u8 {
    const rgtv_url = std.posix.getenv("RGTV_URL") orelse "";
    if (rgtv_url.len > 0) {
        const agent_token = std.posix.getenv("RGTV_AGENT_TOKEN") orelse "";
        if (agent_token.len == 0) {
            std.debug.print(
                "warn: RGTV_URL is set but RGTV_AGENT_TOKEN is missing — falling back to env\n",
                .{},
            );
        } else {
            const val = fetchFromRgtv(allocator, rgtv_url, agent_token, "NESY_INGEST_TOKEN") catch |err| {
                std.debug.print(
                    "warn: rgtv fetch(NESY_INGEST_TOKEN) failed: {s} — falling back to env\n",
                    .{@errorName(err)},
                );
                return allocator.dupe(u8, std.posix.getenv("NESY_INGEST_TOKEN") orelse "") catch "";
            };
            std.debug.print("info: NESY_INGEST_TOKEN loaded via RGTV grant broker\n", .{});
            return val;
        }
    }
    return allocator.dupe(u8, std.posix.getenv("NESY_INGEST_TOKEN") orelse "") catch "";
}

// =============================================================================
// Internal helpers
// =============================================================================

/// Extract the string value for `key` from a flat JSON object.
/// Handles simple unescaped ASCII values only (grant_id and value are UUIDs/tokens).
fn extractJsonString(json: []const u8, key: []const u8) ?[]const u8 {
    var needle_buf: [128]u8 = undefined;
    const needle = std.fmt.bufPrint(&needle_buf, "\"{s}\":\"", .{key}) catch return null;
    const start = (std.mem.indexOf(u8, json, needle) orelse return null) + needle.len;
    if (start >= json.len) return null;
    const end = std.mem.indexOfScalarPos(u8, json, start, '"') orelse return null;
    return json[start..end];
}
