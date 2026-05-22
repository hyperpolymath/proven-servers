// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-wasm FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Module lifecycle (create/destroy)
//   - State transitions (Unloaded -> Loaded -> Instantiated -> Running -> Trapped)
//   - Function registration (import/export)
//   - Linear memory management (grow/size)
//   - Global variable registration (with mutability)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const wasm = @import("wasm");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), wasm.wasm_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "ValType encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(wasm.ValType.i32_val));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(wasm.ValType.i64_val));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(wasm.ValType.f32_val));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(wasm.ValType.f64_val));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(wasm.ValType.v128));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(wasm.ValType.funcref));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(wasm.ValType.externref));
}

test "ExternKind encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(wasm.ExternKind.func));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(wasm.ExternKind.table));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(wasm.ExternKind.memory));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(wasm.ExternKind.global));
}

test "Mutability encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(wasm.Mutability.immutable));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(wasm.Mutability.mutable_val));
}

test "ModuleState encoding matches lifecycle (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(wasm.ModuleState.unloaded));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(wasm.ModuleState.loaded));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(wasm.ModuleState.instantiated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(wasm.ModuleState.running));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(wasm.ModuleState.trapped));
}

// =========================================================================
// Module lifecycle
// =========================================================================

test "create returns valid slot in Unloaded state" {
    const slot = wasm.wasm_create();
    try std.testing.expect(slot >= 0);
    defer wasm.wasm_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), wasm.wasm_state(slot)); // Unloaded
}

test "destroy is safe with invalid slot" {
    wasm.wasm_destroy(-1);
    wasm.wasm_destroy(999);
}

// =========================================================================
// State transitions
// =========================================================================

test "load transitions Unloaded -> Loaded" {
    const slot = wasm.wasm_create();
    defer wasm.wasm_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), wasm.wasm_load(slot));
    try std.testing.expectEqual(@as(u8, 1), wasm.wasm_state(slot));
}

test "instantiate transitions Loaded -> Instantiated" {
    const slot = wasm.wasm_create();
    defer wasm.wasm_destroy(slot);

    _ = wasm.wasm_load(slot);
    try std.testing.expectEqual(@as(u8, 0), wasm.wasm_instantiate(slot));
    try std.testing.expectEqual(@as(u8, 2), wasm.wasm_state(slot));
}

test "start transitions Instantiated -> Running" {
    const slot = wasm.wasm_create();
    defer wasm.wasm_destroy(slot);

    _ = wasm.wasm_load(slot);
    _ = wasm.wasm_instantiate(slot);
    try std.testing.expectEqual(@as(u8, 0), wasm.wasm_start(slot));
    try std.testing.expectEqual(@as(u8, 3), wasm.wasm_state(slot));
}

test "trap transitions Running -> Trapped" {
    const slot = wasm.wasm_create();
    defer wasm.wasm_destroy(slot);

    _ = wasm.wasm_load(slot);
    _ = wasm.wasm_instantiate(slot);
    _ = wasm.wasm_start(slot);
    try std.testing.expectEqual(@as(u8, 0), wasm.wasm_trap(slot));
    try std.testing.expectEqual(@as(u8, 4), wasm.wasm_state(slot));
}

test "load rejected from Loaded" {
    const slot = wasm.wasm_create();
    defer wasm.wasm_destroy(slot);

    _ = wasm.wasm_load(slot);
    try std.testing.expectEqual(@as(u8, 1), wasm.wasm_load(slot));
}

test "trap rejected from Instantiated" {
    const slot = wasm.wasm_create();
    defer wasm.wasm_destroy(slot);

    _ = wasm.wasm_load(slot);
    _ = wasm.wasm_instantiate(slot);
    try std.testing.expectEqual(@as(u8, 1), wasm.wasm_trap(slot));
}

// =========================================================================
// Function registration
// =========================================================================

test "add_func registers function" {
    const slot = wasm.wasm_create();
    defer wasm.wasm_destroy(slot);

    const name = "add";
    try std.testing.expectEqual(@as(u8, 0), wasm.wasm_add_func(
        slot, name.ptr, name.len, 0, 2, 1,
    ));
    try std.testing.expectEqual(@as(u32, 1), wasm.wasm_func_count(slot));
}

test "add_func rejects invalid kind" {
    const slot = wasm.wasm_create();
    defer wasm.wasm_destroy(slot);

    const name = "bad";
    try std.testing.expectEqual(@as(u8, 1), wasm.wasm_add_func(
        slot, name.ptr, name.len, 99, 0, 0,
    ));
}

test "add_func rejects empty name" {
    const slot = wasm.wasm_create();
    defer wasm.wasm_destroy(slot);

    const name = "x";
    try std.testing.expectEqual(@as(u8, 1), wasm.wasm_add_func(
        slot, name.ptr, 0, 0, 0, 0,
    ));
}

// =========================================================================
// Memory management
// =========================================================================

test "memory_grow increases page count" {
    const slot = wasm.wasm_create();
    defer wasm.wasm_destroy(slot);

    try std.testing.expectEqual(@as(u32, 0), wasm.wasm_memory_size(slot));
    const prev = wasm.wasm_memory_grow(slot, 10);
    try std.testing.expectEqual(@as(i32, 0), prev);
    try std.testing.expectEqual(@as(u32, 10), wasm.wasm_memory_size(slot));
}

test "memory_grow returns -1 on overflow" {
    const slot = wasm.wasm_create();
    defer wasm.wasm_destroy(slot);

    _ = wasm.wasm_memory_grow(slot, 65536);
    try std.testing.expectEqual(@as(i32, -1), wasm.wasm_memory_grow(slot, 1));
}

// =========================================================================
// Global registration
// =========================================================================

test "add_global registers immutable global" {
    const slot = wasm.wasm_create();
    defer wasm.wasm_destroy(slot);

    const name = "counter";
    try std.testing.expectEqual(@as(u8, 0), wasm.wasm_add_global(
        slot, name.ptr, name.len, 0, 0, // i32, immutable
    ));
    try std.testing.expectEqual(@as(u32, 1), wasm.wasm_global_count(slot));
}

test "add_global rejects invalid val_type" {
    const slot = wasm.wasm_create();
    defer wasm.wasm_destroy(slot);

    const name = "bad";
    try std.testing.expectEqual(@as(u8, 1), wasm.wasm_add_global(
        slot, name.ptr, name.len, 99, 0,
    ));
}

test "add_global rejects invalid mutability" {
    const slot = wasm.wasm_create();
    defer wasm.wasm_destroy(slot);

    const name = "bad";
    try std.testing.expectEqual(@as(u8, 1), wasm.wasm_add_global(
        slot, name.ptr, name.len, 0, 2,
    ));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "wasm_can_transition matches module lifecycle" {
    // Valid
    try std.testing.expectEqual(@as(u8, 1), wasm.wasm_can_transition(0, 1)); // Unloaded -> Loaded
    try std.testing.expectEqual(@as(u8, 1), wasm.wasm_can_transition(1, 2)); // Loaded -> Instantiated
    try std.testing.expectEqual(@as(u8, 1), wasm.wasm_can_transition(2, 3)); // Instantiated -> Running
    try std.testing.expectEqual(@as(u8, 1), wasm.wasm_can_transition(3, 4)); // Running -> Trapped
    try std.testing.expectEqual(@as(u8, 1), wasm.wasm_can_transition(3, 2)); // Running -> Instantiated
    try std.testing.expectEqual(@as(u8, 1), wasm.wasm_can_transition(4, 0)); // Trapped -> Unloaded

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), wasm.wasm_can_transition(0, 2)); // Unloaded -/-> Instantiated
    try std.testing.expectEqual(@as(u8, 0), wasm.wasm_can_transition(4, 3)); // Trapped -/-> Running
    try std.testing.expectEqual(@as(u8, 0), wasm.wasm_can_transition(1, 3)); // Loaded -/-> Running
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), wasm.wasm_state(-1));
    try std.testing.expectEqual(@as(u32, 0), wasm.wasm_func_count(-1));
    try std.testing.expectEqual(@as(u32, 0), wasm.wasm_global_count(-1));
    try std.testing.expectEqual(@as(u32, 0), wasm.wasm_memory_size(-1));
    try std.testing.expectEqual(@as(u32, 0), wasm.wasm_export_count(-1));
    try std.testing.expectEqual(@as(u8, 1), wasm.wasm_load(-1));
    try std.testing.expectEqual(@as(i32, -1), wasm.wasm_memory_grow(-1, 1));
}
