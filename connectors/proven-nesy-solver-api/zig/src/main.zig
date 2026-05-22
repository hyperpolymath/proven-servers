// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// main.zig — proven-nesy-solver-api HTTP server.
//
// Replaces:
//   proven-servers/connectors/proven-nesy-solver-api/v/server.v
//   proven-servers/connectors/proven-nesy-solver-api/v/rgtv_client.v
//
// Routes:
//   GET  /health             — service health + upstream reachability
//   POST /prove              — forward to echidna, record in verisim-api
//   GET  /strategy/:class    — fetch prover strategy from verisim-api
//   POST /ingest             — authenticated passthrough to verisim-api
//   GET  /surfaces           — list of supported protocol surfaces
//   OPTIONS *                — CORS preflight
//
// Environment variables:
//   ECHIDNA_URL         (default: http://localhost:8090)
//   VERISIM_URL         (default: http://localhost:8080)
//   NESY_PORT           (default: 9000)
//   NESY_REPO_TAG       (default: hyperpolymath/nesy-solver)
//   NESY_FILE_TAG       (default: playground/submission.txt)
//   RGTV_URL            (optional: RGTV grant broker base URL)
//   RGTV_AGENT_TOKEN    (required when RGTV_URL is set)
//   NESY_INGEST_TOKEN   (fallback when RGTV_URL is unset)

const std = @import("std");
const rgtv = @import("rgtv.zig");

// =============================================================================
// Constants
// =============================================================================

const MAX_BODY_BYTES: usize  = 1024 * 1024; // 1 MiB request body cap
const VERSION: []const u8    = "0.1.0";

const SURFACES = [_][]const u8{
    "rest", "graphql", "websocket", "sse", "grpc", "jsonrpc",
    "msgpack-rpc", "cbor", "flatbuffers", "capnproto", "bebop",
    "trpc", "mqtt", "amqp", "soap", "verisimdb",
};

// =============================================================================
// Configuration
// =============================================================================

const Config = struct {
    echidna_url:  []const u8,
    verisim_url:  []const u8,
    port:         u16,
    repo:         []const u8,
    file_tag:     []const u8,
    /// Shared secret for POST /ingest (batch_driver, echidnabot).
    /// Loaded via RGTV grant broker if RGTV_URL is set; env fallback otherwise.
    ingest_token: []const u8,
};

fn loadConfig(allocator: std.mem.Allocator) !Config {
    const port_str = std.posix.getenv("NESY_PORT") orelse "9000";
    const port = std.fmt.parseInt(u16, port_str, 10) catch 9000;

    return .{
        .echidna_url  = std.posix.getenv("ECHIDNA_URL") orelse "http://localhost:8090",
        .verisim_url  = std.posix.getenv("VERISIM_URL") orelse "http://localhost:8080",
        .port         = port,
        .repo         = std.posix.getenv("NESY_REPO_TAG") orelse "hyperpolymath/nesy-solver",
        .file_tag     = std.posix.getenv("NESY_FILE_TAG") orelse "playground/submission.txt",
        .ingest_token = rgtv.loadIngestToken(allocator),
    };
}

// =============================================================================
// JSON wire types (input)
// =============================================================================

/// Prove request body.  obligationClass is camelCase in the JSON contract.
const ProveInput = struct {
    language:        []const u8 = "",
    obligationClass: []const u8 = "",
    prover:          []const u8 = "auto",
    content:         []const u8 = "",
};

/// echidna /api/verify response.
const EchidnaResult = struct {
    valid:           bool  = false,
    goals_remaining: i32   = 0,
    tactics_used:    i32   = 0,
};

// =============================================================================
// JSON wire types (output) — field names must match the client contract
// =============================================================================

const ProveOutput = struct {
    valid:            bool,
    outcome:          []const u8,
    prover:           []const u8,
    duration_ms:      u64,
    goals_remaining:  i32,
    tactics_used:     i32,
    obligation_id:    []const u8,
    obligation_class: []const u8,
    language:         []const u8,
    strategy_tag:     []const u8,
    prover_output:    []const u8,
    attempt_id:       []const u8,
    recorded:         bool,
    mock:             bool,
};

const HealthOutput = struct {
    service:           []const u8,
    version:           []const u8,
    abi_major:         u8,
    abi_minor:         u8,
    mode:              []const u8,
    echidna_reachable: bool,
    verisim_reachable: bool,
    surfaces:          []const []const u8,
};

const VerisimAttempt = struct {
    attempt_id:        []const u8,
    obligation_id:     []const u8,
    repo:              []const u8,
    file:              []const u8,
    claim:             []const u8,
    obligation_class:  []const u8,
    prover_used:       []const u8,
    outcome:           []const u8,
    duration_ms:       u64,
    confidence:        f32,
    parent_attempt_id: ?[]const u8,
    strategy_tag:      []const u8,
    started_at:        []const u8,
    completed_at:      []const u8,
    prover_output:     []const u8,
    error_message:     ?[]const u8,
};

// =============================================================================
// Helper functions
// =============================================================================

/// Map a user-supplied prover name + language to the canonical echidna name.
fn toEchidnaProverName(req_prover: []const u8, language: []const u8) []const u8 {
    var p_buf: [64]u8 = undefined;
    const p_len = @min(req_prover.len, 64);
    const p = std.ascii.lowerString(p_buf[0..p_len], req_prover[0..p_len]);

    const KnownProver = struct { from: []const u8, to: []const u8 };
    const known = [_]KnownProver{
        .{ .from = "z3",       .to = "Z3"       },
        .{ .from = "cvc5",     .to = "CVC5"     },
        .{ .from = "coq",      .to = "Coq"      },
        .{ .from = "lean",     .to = "Lean"     },
        .{ .from = "lean4",    .to = "Lean"     },
        .{ .from = "idris2",   .to = "Idris2"   },
        .{ .from = "agda",     .to = "Agda"     },
        .{ .from = "isabelle", .to = "Isabelle" },
        .{ .from = "dafny",    .to = "Dafny"    },
        .{ .from = "fstar",    .to = "FStar"    },
    };
    for (known) |kp| {
        if (std.mem.eql(u8, p, kp.from)) return kp.to;
    }

    // Derive from language for "auto" or unknown prover.
    var l_buf: [64]u8 = undefined;
    const l_len = @min(language.len, 64);
    const l = std.ascii.lowerString(l_buf[0..l_len], language[0..l_len]);
    if (std.mem.eql(u8, l, "lean") or std.mem.eql(u8, l, "lean4")) return "Lean";
    if (std.mem.eql(u8, l, "coq"))    return "Coq";
    if (std.mem.eql(u8, l, "idris2")) return "Idris2";
    if (std.mem.eql(u8, l, "agda"))   return "Agda";
    return "Z3";
}

const VALID_CLASSES = [_][]const u8{
    "safety", "linearity", "termination", "equiv", "correctness",
    "confluence", "totality", "invariant", "refinement", "model-check", "other",
};

/// Normalise an obligation class name to a known token.
fn normaliseClass(class: []const u8) []const u8 {
    const len = @min(class.len, 64);
    var c_buf: [64]u8 = undefined;
    _ = std.ascii.lowerString(c_buf[0..len], class[0..len]);
    // Replace underscores with hyphens in-place.
    for (c_buf[0..len]) |*ch| {
        if (ch.* == '_') ch.* = '-';
    }
    for (VALID_CLASSES) |v| {
        if (std.mem.eql(u8, c_buf[0..len], v)) return v;
    }
    return "other";
}

/// Format current UTC time as "YYYY-MM-DDTHH:MM:SS.mmm" (no trailing Z).
/// ClickHouse DateTime64(3) rejects trailing Z — format matches V behaviour.
fn isoTimestampMs(buf: *[32]u8) []u8 {
    const ms_i64: i64 = std.time.milliTimestamp();
    const secs_i64: i64 = @divTrunc(ms_i64, 1000);
    const millis: u64 = @intCast(@mod(ms_i64, 1000));
    const secs: u64 = if (secs_i64 >= 0) @intCast(secs_i64) else 0;

    const ep  = std.time.epoch.EpochSeconds{ .secs = secs };
    const yd  = ep.getEpochDay().calculateYearDay();
    const md  = yd.calculateMonthDay();
    const ds  = ep.getDaySeconds();

    return std.fmt.bufPrint(
        buf,
        "{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}.{d:0>3}",
        .{
            yd.year,
            @intFromEnum(md.month),
            md.day_index + 1,
            ds.getHoursIntoDay(),
            ds.getMinutesIntoHour(),
            ds.getSecondsIntoMinute(),
            millis,
        },
    ) catch buf[0..0];
}

/// SHA-256 of `input`, returned as 64 lowercase hex chars written into `out`.
fn sha256Hex(input: []const u8, out: *[64]u8) []u8 {
    var hash: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(input, &hash, .{});
    return std.fmt.bufPrint(out, "{}", .{std.fmt.fmtSliceHexLower(&hash)}) catch out[0..0];
}

/// Simple monotonic identifier: 12 hex time chars + "-nesy-" + 16 random hex.
fn uuidLike(buf: *[48]u8) []u8 {
    const now_ms: u64 = @intCast(@max(0, std.time.milliTimestamp()));
    var rand_bytes: [8]u8 = undefined;
    std.crypto.random.bytes(&rand_bytes);
    return std.fmt.bufPrint(
        buf,
        "{x:0>12}-nesy-{}",
        .{ now_ms, std.fmt.fmtSliceHexLower(&rand_bytes) },
    ) catch buf[0..0];
}

/// Return the first line of `s`, capped at `max_len` bytes.
fn firstLine(s: []const u8, max_len: usize) []const u8 {
    const nl = std.mem.indexOfScalar(u8, s, '\n') orelse s.len;
    return s[0..@min(nl, max_len)];
}

// =============================================================================
// HTTP helpers (low-level request/response)
// =============================================================================

/// Read one CRLF-terminated line from `stream` into `buf`.
/// Returns the line contents without the trailing \r\n.
fn readLine(stream: std.net.Stream, buf: []u8) ![]const u8 {
    var pos: usize = 0;
    while (pos < buf.len) {
        const n = try stream.read(buf[pos..][0..1]);
        if (n == 0) break;
        if (buf[pos] == '\n') {
            const end = if (pos > 0 and buf[pos - 1] == '\r') pos - 1 else pos;
            return buf[0..end];
        }
        pos += 1;
    }
    return buf[0..pos];
}

/// Read up to `MAX_BODY_BYTES` from `stream`.  Caller must free the returned slice.
fn readBody(
    allocator: std.mem.Allocator,
    stream: std.net.Stream,
    content_length: usize,
) ![]u8 {
    const to_read = @min(content_length, MAX_BODY_BYTES);
    const buf = try allocator.alloc(u8, to_read);
    var total: usize = 0;
    while (total < to_read) {
        const n = try stream.read(buf[total..]);
        if (n == 0) break;
        total += n;
    }
    return buf[0..total];
}

/// Write a complete HTTP/1.1 response.
fn writeResponse(
    conn: *std.net.Server.Connection,
    status: u16,
    content_type: []const u8,
    body: []const u8,
    extra_headers: []const [2][]const u8,
) void {
    var h_buf: [1024]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&h_buf);
    const w = fbs.writer();
    w.print(
        "HTTP/1.1 {d} \r\nContent-Type: {s}\r\nContent-Length: {d}\r\nConnection: close\r\n",
        .{ status, content_type, body.len },
    ) catch return;
    for (extra_headers) |h| {
        w.print("{s}: {s}\r\n", .{ h[0], h[1] }) catch return;
    }
    _ = w.write("\r\n") catch return;
    const headers_written = fbs.getWritten();

    const stream = conn.stream;
    stream.writeAll(headers_written) catch return;
    stream.writeAll(body) catch return;
}

const CORS_HEADERS = [_][2][]const u8{
    .{ "Access-Control-Allow-Origin",  "*"                         },
    .{ "Access-Control-Allow-Methods", "GET, POST, OPTIONS"        },
    .{ "Access-Control-Allow-Headers", "Content-Type, Authorization" },
};

fn writeJson(conn: *std.net.Server.Connection, status: u16, body: []const u8) void {
    writeResponse(conn, status, "application/json", body, &CORS_HEADERS);
}

fn writeJsonError(conn: *std.net.Server.Connection, status: u16, msg: []const u8) void {
    var buf: [512]u8 = undefined;
    const body = std.fmt.bufPrint(&buf, "{{\"error\":\"{s}\"}}", .{msg}) catch
        "{\"error\":\"error\"}";
    writeJson(conn, status, body);
}

// =============================================================================
// Upstream HTTP callers
// =============================================================================

/// Call echidna /api/verify.  Returns parsed EchidnaResult on success.
fn callEchidnaVerify(
    allocator: std.mem.Allocator,
    echidna_url: []const u8,
    prover: []const u8,
    content: []const u8,
) !EchidnaResult {
    // Build request JSON with std.json to handle special chars in content.
    var req_json_buf: [MAX_BODY_BYTES + 256]u8 = undefined;
    var req_fbs = std.io.fixedBufferStream(&req_json_buf);
    try std.json.stringify(.{ .prover = prover, .content = content }, .{}, req_fbs.writer());
    const req_json = req_fbs.getWritten();

    var url_buf: [512]u8 = undefined;
    const url = std.fmt.bufPrint(&url_buf, "{s}/api/verify", .{echidna_url}) catch
        return error.UrlTooLong;

    var resp_buf: [65536]u8 = undefined;
    var resp_writer = std.Io.Writer.fixed(resp_buf[0..]);

    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    const result = try client.fetch(.{
        .location        = .{ .url = url },
        .method          = .POST,
        .payload         = req_json,
        .response_writer = &resp_writer,
        .extra_headers   = &.{
            .{ .name = "Content-Type", .value = "application/json" },
        },
    });
    if (result.status != .ok) return error.EchidnaHttpError;

    const n = resp_buf.len - resp_writer.unusedCapacityLen();
    const parsed = try std.json.parseFromSlice(EchidnaResult, allocator, resp_buf[0..n], .{
        .ignore_unknown_fields = true,
    });
    defer parsed.deinit();
    return parsed.value;
}

/// POST a VerisimAttempt to verisim-api.  Returns the response body (allocated).
fn recordAttempt(
    allocator: std.mem.Allocator,
    verisim_url: []const u8,
    attempt: VerisimAttempt,
) ![]u8 {
    var req_json_buf: [8192]u8 = undefined;
    var req_fbs = std.io.fixedBufferStream(&req_json_buf);
    try std.json.stringify(attempt, .{}, req_fbs.writer());
    const req_json = req_fbs.getWritten();

    var url_buf: [512]u8 = undefined;
    const url = std.fmt.bufPrint(&url_buf, "{s}/api/v1/proof_attempts", .{verisim_url}) catch
        return error.UrlTooLong;

    var resp_buf: [4096]u8 = undefined;
    var resp_writer = std.Io.Writer.fixed(resp_buf[0..]);

    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    const result = try client.fetch(.{
        .location        = .{ .url = url },
        .method          = .POST,
        .payload         = req_json,
        .response_writer = &resp_writer,
        .extra_headers   = &.{
            .{ .name = "Content-Type", .value = "application/json" },
        },
    });
    if (@intFromEnum(result.status) >= 300) return error.VerisimHttpError;

    const n = resp_buf.len - resp_writer.unusedCapacityLen();
    return try allocator.dupe(u8, resp_buf[0..n]);
}

/// GET strategy recommendations from verisim-api.  Returns raw JSON (allocated).
fn fetchStrategyJson(
    allocator: std.mem.Allocator,
    verisim_url: []const u8,
    obligation_class: []const u8,
) ![]u8 {
    var url_buf: [512]u8 = undefined;
    const url = std.fmt.bufPrint(
        &url_buf,
        "{s}/api/v1/proof_attempts/strategy?class={s}",
        .{ verisim_url, obligation_class },
    ) catch return error.UrlTooLong;

    var resp_buf: [32768]u8 = undefined;
    var resp_writer = std.Io.Writer.fixed(resp_buf[0..]);

    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    const result = try client.fetch(.{
        .location        = .{ .url = url },
        .method          = .GET,
        .response_writer = &resp_writer,
    });
    if (result.status != .ok) return error.VerisimHttpError;

    const n = resp_buf.len - resp_writer.unusedCapacityLen();
    return try allocator.dupe(u8, resp_buf[0..n]);
}

/// Quick reachability probe: GET url and check for 200.
fn isReachable(allocator: std.mem.Allocator, url: []const u8) bool {
    var dummy_buf: [64]u8 = undefined;
    var dummy_writer = std.Io.Writer.fixed(dummy_buf[0..]);
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();
    const result = client.fetch(.{
        .location        = .{ .url = url },
        .method          = .GET,
        .response_writer = &dummy_writer,
    }) catch return false;
    return result.status == .ok;
}

// =============================================================================
// Route handlers
// =============================================================================

fn handleHealth(
    conn: *std.net.Server.Connection,
    cfg: *const Config,
    allocator: std.mem.Allocator,
) void {
    var echidna_url_buf: [256]u8 = undefined;
    const echidna_health_url = std.fmt.bufPrint(
        &echidna_url_buf, "{s}/api/health", .{cfg.echidna_url},
    ) catch cfg.echidna_url;

    var verisim_url_buf: [256]u8 = undefined;
    const verisim_health_url = std.fmt.bufPrint(
        &verisim_url_buf, "{s}/health", .{cfg.verisim_url},
    ) catch cfg.verisim_url;

    const echidna_ok = isReachable(allocator, echidna_health_url);
    const verisim_ok = isReachable(allocator, verisim_health_url);

    const resp = HealthOutput{
        .service           = "proven-nesy-solver-api",
        .version           = VERSION,
        .abi_major         = 0,
        .abi_minor         = 1,
        .mode              = "live",
        .echidna_reachable = echidna_ok,
        .verisim_reachable = verisim_ok,
        .surfaces          = &SURFACES,
    };

    var json_buf: [1024]u8 = undefined;
    var json_fbs = std.io.fixedBufferStream(&json_buf);
    std.json.stringify(resp, .{}, json_fbs.writer()) catch {
        writeJsonError(conn, 500, "json encode failed");
        return;
    };
    writeJson(conn, 200, json_fbs.getWritten());
}

fn handleProve(
    conn: *std.net.Server.Connection,
    body: []const u8,
    cfg: *const Config,
    allocator: std.mem.Allocator,
) void {
    // Parse JSON input.
    const parsed = std.json.parseFromSlice(ProveInput, allocator, body, .{
        .ignore_unknown_fields = true,
    }) catch {
        writeJsonError(conn, 400, "invalid JSON");
        return;
    };
    const input = parsed.value;

    if (input.content.len == 0) {
        writeJsonError(conn, 400, "content required");
        return;
    }

    const prover = toEchidnaProverName(input.prover, input.language);
    const class  = normaliseClass(input.obligationClass);

    var started_buf: [32]u8 = undefined;
    const started = isoTimestampMs(&started_buf);
    const start_us = std.time.microTimestamp();

    // Forward to echidna.
    const ec = callEchidnaVerify(allocator, cfg.echidna_url, prover, input.content) catch |err| {
        var msg_buf: [128]u8 = undefined;
        const msg = std.fmt.bufPrint(&msg_buf, "echidna: {s}", .{@errorName(err)}) catch "echidna error";
        writeJsonError(conn, 502, msg);
        return;
    };

    const elapsed_ms: u64 = @intCast(@max(0, @divTrunc(std.time.microTimestamp() - start_us, 1000)));
    var completed_buf: [32]u8 = undefined;
    const completed = isoTimestampMs(&completed_buf);

    // Compute IDs.
    var sha_buf: [64]u8 = undefined;
    const obligation_id = sha256Hex(input.content, &sha_buf);

    var uuid_buf: [48]u8 = undefined;
    const attempt_id = uuidLike(&uuid_buf);

    const outcome: []const u8       = if (ec.valid) "success" else "failure";
    const confidence: f32            = if (ec.valid) 0.85 else 0.20;
    const claim                      = firstLine(input.content, 200);

    var prover_lower_buf: [64]u8 = undefined;
    const prover_lower = std.ascii.lowerString(
        prover_lower_buf[0..@min(input.prover.len, 64)],
        input.prover,
    );
    const strategy_tag: []const u8  = if (std.mem.eql(u8, prover_lower, "auto"))
        "auto-language" else "manual";

    var po_buf: [128]u8 = undefined;
    const prover_output = std.fmt.bufPrint(
        &po_buf,
        "valid={} goals={d} tactics={d}",
        .{ ec.valid, ec.goals_remaining, ec.tactics_used },
    ) catch "prover output unavailable";

    // Record in verisim-api (non-fatal on failure).
    const attempt = VerisimAttempt{
        .attempt_id        = attempt_id,
        .obligation_id     = obligation_id,
        .repo              = cfg.repo,
        .file              = cfg.file_tag,
        .claim             = claim,
        .obligation_class  = class,
        .prover_used       = prover_lower,
        .outcome           = outcome,
        .duration_ms       = elapsed_ms,
        .confidence        = confidence,
        .parent_attempt_id = null,
        .strategy_tag      = strategy_tag,
        .started_at        = started,
        .completed_at      = completed,
        .prover_output     = prover_output,
        .error_message     = null,
    };
    const recorded = blk: {
        const r = recordAttempt(allocator, cfg.verisim_url, attempt);
        if (r) |body_bytes| {
            allocator.free(body_bytes);
            break :blk true;
        } else |err| {
            std.debug.print("warn: verisim-api record failed: {s}\n", .{@errorName(err)});
            break :blk false;
        }
    };

    // Build and send response.
    const resp = ProveOutput{
        .valid            = ec.valid,
        .outcome          = outcome,
        .prover           = prover,
        .duration_ms      = elapsed_ms,
        .goals_remaining  = ec.goals_remaining,
        .tactics_used     = ec.tactics_used,
        .obligation_id    = obligation_id,
        .obligation_class = class,
        .language         = input.language,
        .strategy_tag     = strategy_tag,
        .prover_output    = prover_output,
        .attempt_id       = attempt_id,
        .recorded         = recorded,
        .mock             = false,
    };

    var json_buf: [4096]u8 = undefined;
    var json_fbs = std.io.fixedBufferStream(&json_buf);
    std.json.stringify(resp, .{}, json_fbs.writer()) catch {
        writeJsonError(conn, 500, "json encode failed");
        return;
    };
    writeJson(conn, 200, json_fbs.getWritten());
}

fn handleStrategy(
    conn: *std.net.Server.Connection,
    raw_class: []const u8,
    cfg: *const Config,
    allocator: std.mem.Allocator,
) void {
    const class = normaliseClass(raw_class);
    const strategy_json = fetchStrategyJson(allocator, cfg.verisim_url, class) catch |err| {
        var msg_buf: [128]u8 = undefined;
        const msg = std.fmt.bufPrint(&msg_buf, "verisim-api: {s}", .{@errorName(err)}) catch "verisim error";
        writeJsonError(conn, 502, msg);
        return;
    };
    defer allocator.free(strategy_json);
    writeJson(conn, 200, strategy_json);
}

fn handleIngest(
    conn: *std.net.Server.Connection,
    body: []const u8,
    auth_header: []const u8,
    cfg: *const Config,
    allocator: std.mem.Allocator,
) void {
    if (cfg.ingest_token.len == 0) {
        writeJsonError(conn, 503, "ingest disabled: NESY_INGEST_TOKEN not set on server");
        return;
    }

    var expected_buf: [512]u8 = undefined;
    const expected = std.fmt.bufPrint(
        &expected_buf, "Bearer {s}", .{cfg.ingest_token},
    ) catch {
        writeJsonError(conn, 500, "token too long");
        return;
    };
    if (!std.mem.eql(u8, auth_header, expected)) {
        writeJsonError(conn, 401, "missing or invalid bearer token");
        return;
    }

    // Forward body verbatim to verisim-api.
    var url_buf: [512]u8 = undefined;
    const url = std.fmt.bufPrint(
        &url_buf, "{s}/api/v1/proof_attempts", .{cfg.verisim_url},
    ) catch {
        writeJsonError(conn, 500, "url too long");
        return;
    };

    var resp_buf: [32768]u8 = undefined;
    var resp_writer = std.Io.Writer.fixed(resp_buf[0..]);

    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    const result = client.fetch(.{
        .location        = .{ .url = url },
        .method          = .POST,
        .payload         = body,
        .response_writer = &resp_writer,
        .extra_headers   = &.{
            .{ .name = "Content-Type", .value = "application/json" },
        },
    }) catch |err| {
        var msg_buf: [128]u8 = undefined;
        const msg = std.fmt.bufPrint(&msg_buf, "verisim-api: {s}", .{@errorName(err)}) catch "proxy error";
        writeJsonError(conn, 502, msg);
        return;
    };

    const n = resp_buf.len - resp_writer.unusedCapacityLen();
    writeJson(conn, @intCast(@intFromEnum(result.status)), resp_buf[0..n]);
}

fn handleSurfaces(conn: *std.net.Server.Connection) void {
    var json_buf: [512]u8 = undefined;
    var json_fbs = std.io.fixedBufferStream(&json_buf);
    std.json.stringify(SURFACES, .{}, json_fbs.writer()) catch {
        writeJsonError(conn, 500, "json encode failed");
        return;
    };
    writeJson(conn, 200, json_fbs.getWritten());
}

// =============================================================================
// Request dispatcher
// =============================================================================

/// Headers we need from a single HTTP request.
const RequestMeta = struct {
    content_length: usize       = 0,
    authorization:  []const u8  = "",
};

fn serveRequest(
    conn: *std.net.Server.Connection,
    cfg: *const Config,
    allocator: std.mem.Allocator,
) void {
    // --- Request line ---
    var request_line_buf: [1024]u8 = undefined;
    const request_line = readLine(conn.stream, &request_line_buf) catch {
        writeJsonError(conn, 400, "malformed request line");
        return;
    };

    var parts = std.mem.splitScalar(u8, request_line, ' ');
    const method_str = parts.next() orelse {
        writeJsonError(conn, 400, "missing method");
        return;
    };
    const path_str = parts.next() orelse {
        writeJsonError(conn, 400, "missing path");
        return;
    };

    // --- Headers ---
    var meta = RequestMeta{};
    var h_buf: [512]u8 = undefined;
    var auth_copy_buf: [512]u8 = undefined;
    while (true) {
        const line = readLine(conn.stream, &h_buf) catch break;
        if (line.len == 0) break;
        if (std.ascii.startsWithIgnoreCase(line, "content-length:")) {
            const val = std.mem.trimLeft(u8, line["content-length:".len..], " \t");
            meta.content_length = std.fmt.parseInt(usize, val, 10) catch 0;
        } else if (std.ascii.startsWithIgnoreCase(line, "authorization:")) {
            const val = std.mem.trimLeft(u8, line["authorization:".len..], " \t");
            // Copy to a stable buffer since h_buf is reused each iteration.
            const auth_len = @min(val.len, auth_copy_buf.len);
            @memcpy(auth_copy_buf[0..auth_len], val[0..auth_len]);
            meta.authorization = auth_copy_buf[0..auth_len];
        }
    }

    // --- Body ---
    var body_slice: []const u8 = "";
    var body_owned: ?[]u8 = null;
    defer if (body_owned) |b| allocator.free(b);
    if (meta.content_length > 0) {
        body_owned = readBody(allocator, conn.stream, meta.content_length) catch {
            writeJsonError(conn, 500, "failed to read body");
            return;
        };
        body_slice = body_owned.?;
    }

    // --- Dispatch ---
    const is_get     = std.mem.eql(u8, method_str, "GET");
    const is_post    = std.mem.eql(u8, method_str, "POST");
    const is_options = std.mem.eql(u8, method_str, "OPTIONS");

    if (is_options) {
        writeResponse(conn, 204, "text/plain", "", &CORS_HEADERS);
    } else if (is_get and std.mem.eql(u8, path_str, "/health")) {
        handleHealth(conn, cfg, allocator);
    } else if (is_get and std.mem.eql(u8, path_str, "/surfaces")) {
        handleSurfaces(conn);
    } else if (is_get and std.mem.startsWith(u8, path_str, "/strategy/")) {
        const raw_class = path_str["/strategy/".len..];
        handleStrategy(conn, raw_class, cfg, allocator);
    } else if (is_post and std.mem.eql(u8, path_str, "/prove")) {
        handleProve(conn, body_slice, cfg, allocator);
    } else if (is_post and std.mem.eql(u8, path_str, "/ingest")) {
        handleIngest(conn, body_slice, meta.authorization, cfg, allocator);
    } else {
        writeJsonError(conn, 404, "not found");
    }
}

// =============================================================================
// Connection thread
// =============================================================================

const ConnArgs = struct {
    conn:  std.net.Server.Connection,
    cfg:   *const Config,
    alloc: std.mem.Allocator,
};

fn handleConnection(args: ConnArgs) void {
    var conn = args.conn;
    defer conn.stream.close();

    var arena = std.heap.ArenaAllocator.init(args.alloc);
    defer arena.deinit();

    serveRequest(&conn, args.cfg, arena.allocator());
}

// =============================================================================
// Entry point
// =============================================================================

pub fn main() !void {
    var gpa_inst = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_inst.deinit();
    const gpa = gpa_inst.allocator();

    const cfg = try loadConfig(gpa);

    const addr = try std.net.Address.parseIp4("0.0.0.0", cfg.port);
    var server = try addr.listen(.{ .reuse_address = true });
    defer server.deinit();

    std.debug.print(
        "proven-nesy-solver-api {s}  port={d}  echidna={s}  verisim={s}\n",
        .{ VERSION, cfg.port, cfg.echidna_url, cfg.verisim_url },
    );
    if (cfg.ingest_token.len > 0) {
        std.debug.print("info: POST /ingest is enabled\n", .{});
    }

    while (true) {
        const conn = try server.accept();
        const thread = try std.Thread.spawn(.{}, handleConnection, .{ConnArgs{
            .conn  = conn,
            .cfg   = &cfg,
            .alloc = gpa,
        }});
        thread.detach();
    }
}
