// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// wasm.zig -- Zig FFI implementation of proven-wasm.
//
// Implements the WASM module instance state machine with:
//   - 64-slot mutex-protected module instance pool
//   - Module lifecycle (Unloaded/Loaded/Instantiated/Running/Trapped)
//   - Function registration (import/export, max 256 per instance)
//   - Linear memory management (grow/size in pages)
//   - Global variable tracking (with mutability)
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching WASMABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching WASMABI.Types.idr tag assignments)
// =========================================================================

/// WASM value types (ABI tags 0-6).
pub const ValType = enum(u8) {
    i32_val = 0,
    i64_val = 1,
    f32_val = 2,
    f64_val = 3,
    v128 = 4,
    funcref = 5,
    externref = 6,
};

/// WASM extern kinds (ABI tags 0-3).
pub const ExternKind = enum(u8) {
    func = 0,
    table = 1,
    memory = 2,
    global = 3,
};

/// Mutability (ABI tags 0-1).
pub const Mutability = enum(u8) {
    immutable = 0,
    mutable_val = 1,
};

/// Module instance lifecycle states (ABI tags 0-4).
pub const ModuleState = enum(u8) {
    unloaded = 0,
    loaded = 1,
    instantiated = 2,
    running = 3,
    trapped = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent module instances.
const MAX_SESSIONS: usize = 64;

/// Maximum functions per instance.
const MAX_FUNCS: usize = 256;

/// Maximum globals per instance.
const MAX_GLOBALS: usize = 64;

/// Maximum name length.
const MAX_NAME_LEN: usize = 256;

/// Maximum memory size in pages (64KiB each, capped at 65536 = 4GiB).
const MAX_MEMORY_PAGES: u32 = 65536;

/// A registered function entry.
const FuncEntry = struct {
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    kind: ExternKind,
    param_count: u32,
    result_count: u32,
    active: bool,
};

/// A registered global entry.
const GlobalEntry = struct {
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    val_type: ValType,
    mutability: Mutability,
    active: bool,
};

/// Default (empty) function entry.
const empty_func: FuncEntry = .{
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .kind = .func,
    .param_count = 0,
    .result_count = 0,
    .active = false,
};

/// Default (empty) global entry.
const empty_global: GlobalEntry = .{
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .val_type = .i32_val,
    .mutability = .immutable,
    .active = false,
};

/// A WASM module instance.
const Instance = struct {
    /// Current module state.
    state: ModuleState,
    /// Registered functions.
    funcs: [MAX_FUNCS]FuncEntry,
    /// Number of active functions.
    func_count: u32,
    /// Registered globals.
    globals: [MAX_GLOBALS]GlobalEntry,
    /// Number of active globals.
    global_count: u32,
    /// Linear memory size in pages (64KiB per page).
    memory_pages: u32,
    /// Number of exports.
    export_count: u32,
    /// Whether this slot is in use.
    active: bool,
};

/// Default (empty) instance.
const empty_instance: Instance = .{
    .state = .unloaded,
    .funcs = [_]FuncEntry{empty_func} ** MAX_FUNCS,
    .func_count = 0,
    .globals = [_]GlobalEntry{empty_global} ** MAX_GLOBALS,
    .global_count = 0,
    .memory_pages = 0,
    .export_count = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var instances: [MAX_SESSIONS]Instance = [_]Instance{empty_instance} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!instances[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

pub export fn wasm_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new WASM module instance. Returns slot (>=0) or -1 on failure.
pub export fn wasm_create() callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    for (&instances, 0..) |*inst, i| {
        if (!inst.active) {
            inst.* = empty_instance;
            inst.state = .unloaded;
            inst.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn wasm_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    instances[@intCast(slot)] = empty_instance;
}

pub export fn wasm_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(instances[idx].state);
}

/// Transition Unloaded -> Loaded. Returns 0 on success.
pub export fn wasm_load(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (instances[idx].state != .unloaded) return 1;
    instances[idx].state = .loaded;
    return 0;
}

/// Transition Loaded -> Instantiated. Returns 0 on success.
pub export fn wasm_instantiate(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (instances[idx].state != .loaded) return 1;
    instances[idx].state = .instantiated;
    return 0;
}

/// Transition Instantiated -> Running. Returns 0 on success.
pub export fn wasm_start(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (instances[idx].state != .instantiated) return 1;
    instances[idx].state = .running;
    return 0;
}

/// Transition Running -> Trapped. Returns 0 on success.
pub export fn wasm_trap(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (instances[idx].state != .running) return 1;
    instances[idx].state = .trapped;
    return 0;
}

/// Register a function. Returns 0 on success.
pub export fn wasm_add_func(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
    kind: u8,
    param_count: u32,
    result_count: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (kind > 3) return 1;

    for (&instances[idx].funcs) |*f| {
        if (!f.active) {
            @memcpy(f.name[0..name_len], name_ptr[0..name_len]);
            f.name_len = name_len;
            f.kind = @enumFromInt(kind);
            f.param_count = param_count;
            f.result_count = result_count;
            f.active = true;
            instances[idx].func_count += 1;
            if (kind == 0) {
                // Function exports count as exports
                instances[idx].export_count += 1;
            }
            return 0;
        }
    }
    return 1;
}

pub export fn wasm_func_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return instances[idx].func_count;
}

/// Grow linear memory. Returns previous page count or -1 on failure.
pub export fn wasm_memory_grow(slot: c_int, pages: u32) callconv(.c) i32 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return -1;
    const current = instances[idx].memory_pages;
    if (current + pages > MAX_MEMORY_PAGES) return -1;

    instances[idx].memory_pages = current + pages;
    return @intCast(current);
}

pub export fn wasm_memory_size(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return instances[idx].memory_pages;
}

/// Register a global variable. Returns 0 on success.
pub export fn wasm_add_global(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
    val_type: u8,
    mut: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (val_type > 6) return 1;
    if (mut > 1) return 1;

    for (&instances[idx].globals) |*g| {
        if (!g.active) {
            @memcpy(g.name[0..name_len], name_ptr[0..name_len]);
            g.name_len = name_len;
            g.val_type = @enumFromInt(val_type);
            g.mutability = @enumFromInt(mut);
            g.active = true;
            instances[idx].global_count += 1;
            return 0;
        }
    }
    return 1;
}

pub export fn wasm_global_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return instances[idx].global_count;
}

pub export fn wasm_export_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return instances[idx].export_count;
}

/// Check if a module state transition is valid.
pub export fn wasm_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Unloaded -> Loaded
    if (from == 1 and to == 2) return 1; // Loaded -> Instantiated
    if (from == 2 and to == 3) return 1; // Instantiated -> Running
    if (from == 3 and to == 4) return 1; // Running -> Trapped
    if (from == 3 and to == 2) return 1; // Running -> Instantiated (re-instantiate)
    if (from == 4 and to == 0) return 1; // Trapped -> Unloaded (cleanup)
    return 0;
}
