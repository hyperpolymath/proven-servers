// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Tests for the generic root-level FFI prototype. These call the Zig module
// directly; they do not test a compiled C consumer or establish a protocol ABI.

const std = @import("std");
const testing = std.testing;
const proven_servers = @import("proven_servers");

// Lifecycle -----------------------------------------------------------------

test "create and destroy handle" {
    const handle = proven_servers.proven_servers_init() orelse return error.InitFailed;
    defer proven_servers.proven_servers_free(handle);
    try testing.expectEqual(@as(u32, 1), proven_servers.proven_servers_is_initialized(handle));
}

test "null handle is not initialized" {
    try testing.expectEqual(@as(u32, 0), proven_servers.proven_servers_is_initialized(null));
}

test "free null is safe" {
    proven_servers.proven_servers_free(null);
}

// Example operations ---------------------------------------------------------

test "process accepts a live handle as a no-op example" {
    const handle = proven_servers.proven_servers_init() orelse return error.InitFailed;
    defer proven_servers.proven_servers_free(handle);
    try testing.expectEqual(proven_servers.Result.ok, proven_servers.proven_servers_process(handle, 42));
}

test "process rejects a null handle" {
    try testing.expectEqual(proven_servers.Result.null_pointer, proven_servers.proven_servers_process(null, 42));
    try testing.expect(proven_servers.proven_servers_last_error() != null);
}

test "process array bounds its declared length" {
    const handle = proven_servers.proven_servers_init() orelse return error.InitFailed;
    defer proven_servers.proven_servers_free(handle);

    try testing.expectEqual(
        proven_servers.Result.null_pointer,
        proven_servers.proven_servers_process_array(handle, null, 1),
    );
    try testing.expectEqual(
        proven_servers.Result.invalid_param,
        proven_servers.proven_servers_process_array(handle, null, 1_048_577),
    );
    try testing.expectEqual(
        proven_servers.Result.ok,
        proven_servers.proven_servers_process_array(handle, null, 0),
    );
}

test "get string returns a static example value" {
    const handle = proven_servers.proven_servers_init() orelse return error.InitFailed;
    defer proven_servers.proven_servers_free(handle);

    const result = proven_servers.proven_servers_get_string(handle) orelse return error.MissingResult;
    try testing.expectEqualStrings("Example result", std.mem.span(result));
    proven_servers.proven_servers_free_string(result);
}

test "get string rejects a null handle" {
    try testing.expect(proven_servers.proven_servers_get_string(null) == null);
}

// Error and version reporting -----------------------------------------------

test "successful operation clears the thread-local error" {
    _ = proven_servers.proven_servers_process(null, 0);
    try testing.expect(proven_servers.proven_servers_last_error() != null);

    const handle = proven_servers.proven_servers_init() orelse return error.InitFailed;
    defer proven_servers.proven_servers_free(handle);
    _ = proven_servers.proven_servers_process(handle, 0);
    try testing.expect(proven_servers.proven_servers_last_error() == null);
}

test "version string is non-empty" {
    try testing.expect(std.mem.span(proven_servers.proven_servers_version()).len > 0);
}

test "build information is non-empty" {
    try testing.expect(std.mem.span(proven_servers.proven_servers_build_info()).len > 0);
}

// Handle separation ----------------------------------------------------------

test "multiple handles have distinct addresses" {
    const first = proven_servers.proven_servers_init() orelse return error.InitFailed;
    defer proven_servers.proven_servers_free(first);
    const second = proven_servers.proven_servers_init() orelse return error.InitFailed;
    defer proven_servers.proven_servers_free(second);

    try testing.expect(first != second);
    try testing.expectEqual(proven_servers.Result.ok, proven_servers.proven_servers_process(first, 1));
    try testing.expectEqual(proven_servers.Result.ok, proven_servers.proven_servers_process(second, 2));
}
