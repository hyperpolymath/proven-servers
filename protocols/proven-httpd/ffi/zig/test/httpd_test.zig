// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// httpd_test.zig -- Integration tests for proven-httpd FFI.
//
// Covers: ABI version, enum encoding, lifecycle, all HTTP methods, status codes,
// header management, body handling, keep-alive, phase transitions, impossibility
// proofs (cannot respond before parsing), and stateless transition table.

const std = @import("std");
const httpd = @import("httpd");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), httpd.http_abi_version());
}

// =========================================================================
// Enum encoding seams — HttpMethod
// =========================================================================

test "HttpMethod encoding matches Layout.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(httpd.HttpMethod.get));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(httpd.HttpMethod.post));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(httpd.HttpMethod.put));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(httpd.HttpMethod.delete));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(httpd.HttpMethod.patch));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(httpd.HttpMethod.head));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(httpd.HttpMethod.options));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(httpd.HttpMethod.trace));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(httpd.HttpMethod.connect));
}

// =========================================================================
// Enum encoding seams — HttpVersion
// =========================================================================

test "HttpVersion encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(httpd.HttpVersion.http10));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(httpd.HttpVersion.http11));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(httpd.HttpVersion.http20));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(httpd.HttpVersion.http30));
}

// =========================================================================
// Enum encoding seams — RequestPhase
// =========================================================================

test "RequestPhase encoding matches Layout.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(httpd.RequestPhase.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(httpd.RequestPhase.receiving));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(httpd.RequestPhase.headers_parsed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(httpd.RequestPhase.body_receiving));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(httpd.RequestPhase.complete));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(httpd.RequestPhase.responding));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(httpd.RequestPhase.sent));
}

// =========================================================================
// Enum encoding seams — AbiStatusCode
// =========================================================================

test "AbiStatusCode encoding matches Layout.idr (29 tags)" {
    // Spot-check category boundaries
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(httpd.AbiStatusCode.sc_continue));       // 1xx start
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(httpd.AbiStatusCode.sc_ok));              // 2xx start
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(httpd.AbiStatusCode.sc_moved_permanently)); // 3xx start
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(httpd.AbiStatusCode.sc_bad_request));    // 4xx start
    try std.testing.expectEqual(@as(u8, 24), @intFromEnum(httpd.AbiStatusCode.sc_internal_error)); // 5xx start
    try std.testing.expectEqual(@as(u8, 28), @intFromEnum(httpd.AbiStatusCode.sc_gateway_timeout)); // last
}

// =========================================================================
// Enum encoding seams — ContentType
// =========================================================================

test "ContentType encoding matches Layout.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(httpd.ContentType.text_plain));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(httpd.ContentType.application_json));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(httpd.ContentType.text_css));
}

// =========================================================================
// Lifecycle — create and destroy
// =========================================================================

test "create returns valid slot in Idle phase" {
    const slot = httpd.http_create_context();
    try std.testing.expect(slot >= 0);
    defer httpd.http_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 0), httpd.http_get_phase(slot)); // idle
}

test "destroy is safe with invalid slot" {
    httpd.http_destroy_context(-1);
    httpd.http_destroy_context(999);
}

// =========================================================================
// Full lifecycle: GET request (no body)
// =========================================================================

test "full lifecycle: GET / HTTP/1.1 -> Complete (no body)" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const request = "GET / HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n";
    const result = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));
    try std.testing.expectEqual(@as(u8, 0), result); // complete
    try std.testing.expectEqual(@as(u8, 4), httpd.http_get_phase(slot)); // complete

    // Verify method
    try std.testing.expectEqual(@as(u8, 0), httpd.http_get_method(slot)); // GET

    // Verify path
    var path_buf: [256]u8 = undefined;
    const path_len = httpd.http_get_path(slot, &path_buf, 256);
    try std.testing.expectEqual(@as(u32, 1), path_len);
    try std.testing.expectEqualStrings("/", path_buf[0..path_len]);

    // Verify version
    try std.testing.expectEqual(@as(u8, 1), httpd.http_get_version(slot)); // HTTP/1.1
}

// =========================================================================
// All HTTP methods parse correctly
// =========================================================================

test "all 9 HTTP methods parse correctly" {
    const methods = [_]struct { name: []const u8, tag: u8 }{
        .{ .name = "GET", .tag = 0 },
        .{ .name = "POST", .tag = 1 },
        .{ .name = "PUT", .tag = 2 },
        .{ .name = "DELETE", .tag = 3 },
        .{ .name = "PATCH", .tag = 4 },
        .{ .name = "HEAD", .tag = 5 },
        .{ .name = "OPTIONS", .tag = 6 },
        .{ .name = "TRACE", .tag = 7 },
        .{ .name = "CONNECT", .tag = 8 },
    };

    for (methods) |m| {
        const slot = httpd.http_create_context();
        defer httpd.http_destroy_context(slot);

        // Build request string
        var req_buf: [256]u8 = undefined;
        const req_len = std.fmt.bufPrint(&req_buf, "{s} / HTTP/1.1\r\nHost: test\r\n\r\n", .{m.name}) catch unreachable;
        const result = httpd.http_parse_request(slot, req_buf[0..req_len.len].ptr, @intCast(req_len.len));

        // POST/PUT/PATCH with no body after headers still complete
        try std.testing.expect(result == 0 or result == 2);
        try std.testing.expectEqual(m.tag, httpd.http_get_method(slot));
    }
}

// =========================================================================
// POST request with body
// =========================================================================

test "POST request with body parses correctly" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const request = "POST /api/data HTTP/1.1\r\nHost: localhost\r\nContent-Type: application/json\r\n\r\n{\"key\":\"value\"}";
    const result = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));
    try std.testing.expectEqual(@as(u8, 0), result); // complete

    // Verify method
    try std.testing.expectEqual(@as(u8, 1), httpd.http_get_method(slot)); // POST

    // Verify path
    var path_buf: [256]u8 = undefined;
    const path_len = httpd.http_get_path(slot, &path_buf, 256);
    try std.testing.expectEqualStrings("/api/data", path_buf[0..path_len]);

    // Verify body
    var body_buf: [256]u8 = undefined;
    const body_len = httpd.http_get_body(slot, &body_buf, 256);
    try std.testing.expectEqualStrings("{\"key\":\"value\"}", body_buf[0..body_len]);
}

// =========================================================================
// Header management
// =========================================================================

test "header lookup is case-insensitive" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const request = "GET / HTTP/1.1\r\nHost: example.com\r\nContent-Type: text/html\r\nX-Custom: foobar\r\n\r\n";
    _ = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));

    // Look up Host (different case)
    var val_buf: [256]u8 = undefined;
    const host_key = "host";
    const val_len = httpd.http_get_header(slot, host_key.ptr, @intCast(host_key.len), &val_buf, 256);
    try std.testing.expectEqualStrings("example.com", val_buf[0..val_len]);

    // Look up Content-Type (exact case)
    const ct_key = "Content-Type";
    const ct_len = httpd.http_get_header(slot, ct_key.ptr, @intCast(ct_key.len), &val_buf, 256);
    try std.testing.expectEqualStrings("text/html", val_buf[0..ct_len]);

    // Look up custom header
    const custom_key = "X-CUSTOM";
    const custom_len = httpd.http_get_header(slot, custom_key.ptr, @intCast(custom_key.len), &val_buf, 256);
    try std.testing.expectEqualStrings("foobar", val_buf[0..custom_len]);
}

test "missing header returns 0" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const request = "GET / HTTP/1.1\r\nHost: test\r\n\r\n";
    _ = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));

    var val_buf: [256]u8 = undefined;
    const key = "x-nonexistent";
    const len = httpd.http_get_header(slot, key.ptr, @intCast(key.len), &val_buf, 256);
    try std.testing.expectEqual(@as(u32, 0), len);
}

// =========================================================================
// Response construction
// =========================================================================

test "set status transitions Complete -> Responding" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const request = "GET / HTTP/1.1\r\nHost: test\r\n\r\n";
    _ = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));
    try std.testing.expectEqual(@as(u8, 4), httpd.http_get_phase(slot)); // complete

    // Set status
    try std.testing.expectEqual(@as(u8, 0), httpd.http_set_status(slot, 2)); // SC_OK
    try std.testing.expectEqual(@as(u8, 5), httpd.http_get_phase(slot)); // responding
}

test "set response header" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const request = "GET / HTTP/1.1\r\nHost: test\r\n\r\n";
    _ = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));

    const key = "Content-Type";
    const val = "text/plain";
    try std.testing.expectEqual(@as(u8, 0), httpd.http_set_header(slot, key.ptr, @intCast(key.len), val.ptr, @intCast(val.len)));
    try std.testing.expectEqual(@as(u8, 5), httpd.http_get_phase(slot)); // responding
}

test "set response body" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const request = "GET / HTTP/1.1\r\nHost: test\r\n\r\n";
    _ = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));

    const body = "Hello, World!";
    try std.testing.expectEqual(@as(u8, 0), httpd.http_set_body(slot, body.ptr, @intCast(body.len)));
}

// =========================================================================
// Send response — Responding -> Sent
// =========================================================================

test "send_response transitions Responding -> Sent" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const request = "GET / HTTP/1.1\r\nHost: test\r\n\r\n";
    _ = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));

    _ = httpd.http_set_status(slot, 2); // OK
    try std.testing.expectEqual(@as(u8, 0), httpd.http_send_response(slot));
    try std.testing.expectEqual(@as(u8, 6), httpd.http_get_phase(slot)); // sent
}

// =========================================================================
// Keep-alive
// =========================================================================

test "keep-alive detected from Connection header" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const request = "GET / HTTP/1.1\r\nHost: test\r\nConnection: keep-alive\r\n\r\n";
    _ = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));

    try std.testing.expectEqual(@as(u8, 1), httpd.http_keep_alive_check(slot));
}

test "no keep-alive when Connection: close" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const request = "GET / HTTP/1.1\r\nHost: test\r\nConnection: close\r\n\r\n";
    _ = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));

    try std.testing.expectEqual(@as(u8, 0), httpd.http_keep_alive_check(slot));
}

test "keep-alive recycle: Sent -> Idle" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    // Complete a full request-response cycle
    const request = "GET / HTTP/1.1\r\nHost: test\r\nConnection: keep-alive\r\n\r\n";
    _ = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));
    _ = httpd.http_set_status(slot, 2);
    _ = httpd.http_send_response(slot);
    try std.testing.expectEqual(@as(u8, 6), httpd.http_get_phase(slot)); // sent

    // Recycle for keep-alive
    try std.testing.expectEqual(@as(u8, 0), httpd.http_reset_context(slot));
    try std.testing.expectEqual(@as(u8, 0), httpd.http_get_phase(slot)); // idle
}

test "reset rejected from non-Sent phase" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), httpd.http_reset_context(slot)); // idle, not sent
}

// =========================================================================
// Status code tag validation
// =========================================================================

test "set_status rejects invalid status tag" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const request = "GET / HTTP/1.1\r\nHost: test\r\n\r\n";
    _ = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));

    try std.testing.expectEqual(@as(u8, 1), httpd.http_set_status(slot, 99)); // invalid
}

// =========================================================================
// Impossibility: cannot respond before parsing
// =========================================================================

test "cannot set status from Idle (no request parsed)" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    // Attempt to set status without parsing a request
    try std.testing.expectEqual(@as(u8, 1), httpd.http_set_status(slot, 2)); // rejected
}

test "cannot set header from Idle" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const key = "Content-Type";
    const val = "text/plain";
    try std.testing.expectEqual(@as(u8, 1), httpd.http_set_header(slot, key.ptr, @intCast(key.len), val.ptr, @intCast(val.len)));
}

test "cannot send_response from Complete (must set status first)" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const request = "GET / HTTP/1.1\r\nHost: test\r\n\r\n";
    _ = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));

    // Phase is Complete, not Responding
    try std.testing.expectEqual(@as(u8, 1), httpd.http_send_response(slot)); // rejected
}

test "cannot send_response from Idle" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), httpd.http_send_response(slot));
}

// =========================================================================
// Malformed request handling
// =========================================================================

test "malformed request line rejected" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const request = "GARBAGE\r\n\r\n";
    const result = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));
    try std.testing.expectEqual(@as(u8, 1), result); // rejected
    try std.testing.expectEqual(@as(u8, 6), httpd.http_get_phase(slot)); // sent (abort)
}

test "unknown method rejected" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const request = "FOOBAR / HTTP/1.1\r\nHost: test\r\n\r\n";
    const result = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));
    try std.testing.expectEqual(@as(u8, 1), result); // rejected
}

// =========================================================================
// HTTP version parsing
// =========================================================================

test "HTTP/1.0 version parsed correctly" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const request = "GET / HTTP/1.0\r\nHost: test\r\n\r\n";
    _ = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));
    try std.testing.expectEqual(@as(u8, 0), httpd.http_get_version(slot)); // http10
}

// =========================================================================
// Phase queries on invalid slots
// =========================================================================

test "phase queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 6), httpd.http_get_phase(-1));    // sent fallback
    try std.testing.expectEqual(@as(u8, 255), httpd.http_get_method(-1));
    try std.testing.expectEqual(@as(u8, 255), httpd.http_get_version(-1));
    try std.testing.expectEqual(@as(u8, 0), httpd.http_keep_alive_check(-1));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "http_can_transition matches Transitions.idr" {
    // Forward lifecycle sequence
    try std.testing.expectEqual(@as(u8, 1), httpd.http_can_transition(0, 1)); // Idle -> Receiving
    try std.testing.expectEqual(@as(u8, 1), httpd.http_can_transition(1, 2)); // Receiving -> HeadersParsed
    try std.testing.expectEqual(@as(u8, 1), httpd.http_can_transition(2, 3)); // HeadersParsed -> BodyReceiving
    try std.testing.expectEqual(@as(u8, 1), httpd.http_can_transition(2, 4)); // HeadersParsed -> Complete (no body)
    try std.testing.expectEqual(@as(u8, 1), httpd.http_can_transition(3, 4)); // BodyReceiving -> Complete
    try std.testing.expectEqual(@as(u8, 1), httpd.http_can_transition(4, 5)); // Complete -> Responding
    try std.testing.expectEqual(@as(u8, 1), httpd.http_can_transition(5, 6)); // Responding -> Sent
    try std.testing.expectEqual(@as(u8, 1), httpd.http_can_transition(6, 0)); // Sent -> Idle (keep-alive)

    // Abort edges
    try std.testing.expectEqual(@as(u8, 1), httpd.http_can_transition(1, 6)); // Receiving -> Sent
    try std.testing.expectEqual(@as(u8, 1), httpd.http_can_transition(2, 6)); // HeadersParsed -> Sent
    try std.testing.expectEqual(@as(u8, 1), httpd.http_can_transition(3, 6)); // BodyReceiving -> Sent
    try std.testing.expectEqual(@as(u8, 1), httpd.http_can_transition(4, 6)); // Complete -> Sent

    // Invalid transitions (impossibility proofs)
    try std.testing.expectEqual(@as(u8, 0), httpd.http_can_transition(0, 4)); // Idle -> Complete (skip!)
    try std.testing.expectEqual(@as(u8, 0), httpd.http_can_transition(0, 5)); // Idle -> Responding (skip!)
    try std.testing.expectEqual(@as(u8, 0), httpd.http_can_transition(4, 1)); // Complete -> Receiving (backwards!)
    try std.testing.expectEqual(@as(u8, 0), httpd.http_can_transition(5, 2)); // Responding -> HeadersParsed (backwards!)
    try std.testing.expectEqual(@as(u8, 0), httpd.http_can_transition(0, 0)); // Idle -> Idle (no self-loop)
    try std.testing.expectEqual(@as(u8, 0), httpd.http_can_transition(6, 6)); // Sent -> Sent (no self-loop)
}

// =========================================================================
// Body queries on GET (no body)
// =========================================================================

test "GET request has empty body" {
    const slot = httpd.http_create_context();
    defer httpd.http_destroy_context(slot);

    const request = "GET / HTTP/1.1\r\nHost: test\r\n\r\n";
    _ = httpd.http_parse_request(slot, request.ptr, @intCast(request.len));

    var body_buf: [256]u8 = undefined;
    const body_len = httpd.http_get_body(slot, &body_buf, 256);
    try std.testing.expectEqual(@as(u32, 0), body_len);
}
