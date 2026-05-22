// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-httpd FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const httpd = @import("httpd");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), httpd.http_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "HttpMethod encoding matches Types.idr (9 tags)" {
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

test "HttpVersion encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(httpd.HttpVersion.http10));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(httpd.HttpVersion.http11));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(httpd.HttpVersion.http20));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(httpd.HttpVersion.http30));
}

test "RequestPhase encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(httpd.RequestPhase.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(httpd.RequestPhase.receiving));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(httpd.RequestPhase.headers_parsed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(httpd.RequestPhase.body_receiving));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(httpd.RequestPhase.complete));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(httpd.RequestPhase.responding));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(httpd.RequestPhase.sent));
}

test "StatusCategory encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(httpd.StatusCategory.informational));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(httpd.StatusCategory.success));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(httpd.StatusCategory.redirect));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(httpd.StatusCategory.client_error));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(httpd.StatusCategory.server_error));
}

test "AbiStatusCode encoding matches Types.idr (29 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(httpd.AbiStatusCode.sc_continue));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(httpd.AbiStatusCode.sc_switching_protocols));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(httpd.AbiStatusCode.sc_ok));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(httpd.AbiStatusCode.sc_created));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(httpd.AbiStatusCode.sc_accepted));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(httpd.AbiStatusCode.sc_no_content));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(httpd.AbiStatusCode.sc_moved_permanently));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(httpd.AbiStatusCode.sc_found));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(httpd.AbiStatusCode.sc_not_modified));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(httpd.AbiStatusCode.sc_temporary_redirect));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(httpd.AbiStatusCode.sc_permanent_redirect));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(httpd.AbiStatusCode.sc_bad_request));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(httpd.AbiStatusCode.sc_unauthorized));
    try std.testing.expectEqual(@as(u8, 13), @intFromEnum(httpd.AbiStatusCode.sc_forbidden));
    try std.testing.expectEqual(@as(u8, 14), @intFromEnum(httpd.AbiStatusCode.sc_not_found));
    try std.testing.expectEqual(@as(u8, 15), @intFromEnum(httpd.AbiStatusCode.sc_method_not_allowed));
    try std.testing.expectEqual(@as(u8, 16), @intFromEnum(httpd.AbiStatusCode.sc_request_timeout));
    try std.testing.expectEqual(@as(u8, 17), @intFromEnum(httpd.AbiStatusCode.sc_conflict));
    try std.testing.expectEqual(@as(u8, 18), @intFromEnum(httpd.AbiStatusCode.sc_gone));
    try std.testing.expectEqual(@as(u8, 19), @intFromEnum(httpd.AbiStatusCode.sc_length_required));
    try std.testing.expectEqual(@as(u8, 20), @intFromEnum(httpd.AbiStatusCode.sc_payload_too_large));
    try std.testing.expectEqual(@as(u8, 21), @intFromEnum(httpd.AbiStatusCode.sc_uri_too_long));
    try std.testing.expectEqual(@as(u8, 22), @intFromEnum(httpd.AbiStatusCode.sc_unsupported_media));
    try std.testing.expectEqual(@as(u8, 23), @intFromEnum(httpd.AbiStatusCode.sc_too_many_requests));
    try std.testing.expectEqual(@as(u8, 24), @intFromEnum(httpd.AbiStatusCode.sc_internal_error));
    try std.testing.expectEqual(@as(u8, 25), @intFromEnum(httpd.AbiStatusCode.sc_not_implemented));
    try std.testing.expectEqual(@as(u8, 26), @intFromEnum(httpd.AbiStatusCode.sc_bad_gateway));
    try std.testing.expectEqual(@as(u8, 27), @intFromEnum(httpd.AbiStatusCode.sc_service_unavailable));
    try std.testing.expectEqual(@as(u8, 28), @intFromEnum(httpd.AbiStatusCode.sc_gateway_timeout));
}

test "ContentType encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(httpd.ContentType.text_plain));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(httpd.ContentType.text_html));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(httpd.ContentType.application_json));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(httpd.ContentType.application_xml));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(httpd.ContentType.application_form));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(httpd.ContentType.multipart_form));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(httpd.ContentType.octet_stream));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(httpd.ContentType.text_css));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = httpd.http_create_context();
    try std.testing.expect(slot >= 0);
    defer httpd.http_destroy_context(slot);
}

test "destroy is safe with invalid slot" {
    httpd.http_destroy_context(-1);
    httpd.http_destroy_context(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), httpd.http_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), httpd.http_can_transition(0, 0)); // self-loop
}

