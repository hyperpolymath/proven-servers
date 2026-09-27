// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
// Generic root-level C-ABI example scaffold.
//
// It does not implement a protocol or establish conformance to the separate
// Idris2 model. It exists only as a small buildable FFI prototype.
//

const std = @import("std");

// Version information (keep in sync with project)
const VERSION = "0.1.0";
const BUILD_INFO = "proven-servers FFI prototype built with Zig " ++ @import("builtin").zig_version_string;
const EXAMPLE_RESULT: [:0]const u8 = "Example result";
const MAX_PROCESS_ARRAY_LEN: u32 = 1_048_576;

/// Thread-local pointer to a static, sentinel-terminated error message.
threadlocal var last_error: ?[*:0]const u8 = null;

/// Set the last error message without allocating or transferring ownership.
fn setError(msg: [:0]const u8) void {
    last_error = msg.ptr;
}

/// Clear the last error
fn clearError() void {
    last_error = null;
}

//==============================================================================
// Core Types (must match src/abi/Types.idr)
//==============================================================================

/// Result codes for this prototype; no Idris2 ABI conformance is asserted.
pub const Result = enum(c_int) {
    ok = 0,
    @"error" = 1,
    invalid_param = 2,
    out_of_memory = 3,
    null_pointer = 4,
};

/// Opaque handle type exposed across the C ABI.
pub const Handle = opaque {};

/// Private state behind the opaque ABI handle.
const HandleState = struct {
    allocator: std.mem.Allocator,
    initialized: bool,
};

fn stateOf(handle: *Handle) *HandleState {
    return @ptrCast(@alignCast(handle));
}

//==============================================================================
// Library Lifecycle
//==============================================================================

/// Initialize the library
/// Returns a handle, or null on failure
export fn proven_servers_init() ?*Handle {
    const allocator = std.heap.page_allocator;

    const state = allocator.create(HandleState) catch {
        setError("Failed to allocate handle");
        return null;
    };
    state.* = .{ .allocator = allocator, .initialized = true };

    clearError();
    return @ptrCast(state);
}

/// Free a handle exactly once. Passing null is a no-op; reusing a freed handle
/// is invalid and cannot be made safe by this raw-pointer ABI.
export fn proven_servers_free(handle: ?*Handle) void {
    const h = handle orelse return;
    const state = stateOf(h);
    const allocator = state.allocator;
    state.initialized = false;
    allocator.destroy(state);
    clearError();
}

//==============================================================================
// Core Operations
//==============================================================================

/// Process data (example operation)
export fn proven_servers_process(handle: ?*Handle, input: u32) Result {
    const h = handle orelse {
        setError("Null handle");
        return .null_pointer;
    };
    const state = stateOf(h);

    if (!state.initialized) {
        setError("Handle not initialized");
        return .@"error";
    }

    // This prototype intentionally does not implement protocol processing.
    _ = input;

    clearError();
    return .ok;
}

//==============================================================================
// String Operations
//==============================================================================

/// Return a static example string. This prototype does not return protocol data.
export fn proven_servers_get_string(handle: ?*Handle) ?[*:0]const u8 {
    const h = handle orelse {
        setError("Null handle");
        return null;
    };
    if (!stateOf(h).initialized) {
        setError("Handle not initialized");
        return null;
    }

    clearError();
    return EXAMPLE_RESULT.ptr;
}

/// Compatibility no-op for the static string returned above.
export fn proven_servers_free_string(str: ?[*:0]const u8) void {
    _ = str;
}

//==============================================================================
// Array/Buffer Operations
//==============================================================================

/// Process an array of data
export fn proven_servers_process_array(
    handle: ?*Handle,
    buffer: ?[*]const u8,
    len: u32,
) Result {
    const h = handle orelse {
        setError("Null handle");
        return .null_pointer;
    };
    if (!stateOf(h).initialized) {
        setError("Handle not initialized");
        return .@"error";
    }
    if (len > MAX_PROCESS_ARRAY_LEN) {
        setError("Input length exceeds prototype limit");
        return .invalid_param;
    }
    if (len > 0 and buffer == null) {
        setError("Null buffer");
        return .null_pointer;
    }

    // This example validates the declared length but intentionally does not
    // read caller-owned memory or implement protocol processing.
    clearError();
    return .ok;
}

//==============================================================================
// Error Handling
//==============================================================================

/// Get the last error message
/// Returns null if no error
export fn proven_servers_last_error() ?[*:0]const u8 {
    return last_error;
}

//==============================================================================
// Version Information
//==============================================================================

/// Get the library version
export fn proven_servers_version() [*:0]const u8 {
    return VERSION.ptr;
}

/// Get build information
export fn proven_servers_build_info() [*:0]const u8 {
    return BUILD_INFO.ptr;
}

//==============================================================================
// Callback Support
//==============================================================================

/// Callback function type (C ABI)
pub const Callback = *const fn (u64, u32) callconv(.c) u32;

/// Register a callback
export fn proven_servers_register_callback(
    handle: ?*Handle,
    callback: ?Callback,
) Result {
    const h = handle orelse {
        setError("Null handle");
        return .null_pointer;
    };

    const cb = callback orelse {
        setError("Null callback");
        return .null_pointer;
    };

    if (!stateOf(h).initialized) {
        setError("Handle not initialized");
        return .@"error";
    }

    // This prototype validates the callback argument but does not retain it.
    _ = cb;

    clearError();
    return .ok;
}

//==============================================================================
// Utility Functions
//==============================================================================

/// Check if handle is initialized
export fn proven_servers_is_initialized(handle: ?*Handle) u32 {
    const h = handle orelse return 0;
    return if (stateOf(h).initialized) 1 else 0;
}

//==============================================================================
// Tests
//==============================================================================

test "lifecycle" {
    const handle = proven_servers_init() orelse return error.InitFailed;
    defer proven_servers_free(handle);

    try std.testing.expect(proven_servers_is_initialized(handle) == 1);
}

test "error handling" {
    const result = proven_servers_process(null, 0);
    try std.testing.expectEqual(Result.null_pointer, result);

    const err = proven_servers_last_error();
    try std.testing.expect(err != null);
}

test "version" {
    const ver = proven_servers_version();
    const ver_str = std.mem.span(ver);
    try std.testing.expectEqualStrings(VERSION, ver_str);
}
