// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig — Integration tests for the proven-pop3 FFI.
//
// Tests cover:
//   - ABI version check
//   - Session lifecycle (create, destroy, state queries)
//   - Authentication (Authorization -> Transaction)
//   - Command execution and state validation
//   - Message and deletion tracking
//   - QUIT transition to Update state
//   - Edge cases (invalid slots, double destroy, etc.)

const std = @import("std");
const pop3 = @import("pop3");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ── ABI Version ─────────────────────────────────────────────────────────

test "abi version returns 1" {
    try expectEqual(@as(u32, 1), pop3.pop3_abi_version());
}

// ── Create and Destroy ──────────────────────────────────────────────────

test "create returns valid slot" {
    const slot = pop3.pop3_create();
    try expect(slot >= 0);
    pop3.pop3_destroy(slot);
}

test "destroy invalid slot is safe" {
    pop3.pop3_destroy(-1);
    pop3.pop3_destroy(999);
}

test "double destroy is safe" {
    const slot = pop3.pop3_create();
    pop3.pop3_destroy(slot);
    pop3.pop3_destroy(slot);
}

// ── State Queries on Fresh Session ──────────────────────────────────────

test "fresh session is in Authorization state" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    try expectEqual(@as(u8, 0), pop3.pop3_get_state(slot)); // Authorization
}

test "fresh session has zero message count" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    try expectEqual(@as(u32, 0), pop3.pop3_get_message_count(slot));
}

test "fresh session has zero deleted count" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    try expectEqual(@as(u32, 0), pop3.pop3_get_deleted_count(slot));
}

test "fresh session has zero command count" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    try expectEqual(@as(u32, 0), pop3.pop3_get_command_count(slot));
}

test "fresh session has Ok response" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    try expectEqual(@as(u8, 0), pop3.pop3_get_last_response(slot)); // Ok
}

test "fresh session has no error (255)" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    try expectEqual(@as(u8, 255), pop3.pop3_get_last_error(slot));
}

// ── Queries on Invalid Slot ─────────────────────────────────────────────

test "get_state on invalid slot returns Authorization" {
    try expectEqual(@as(u8, 0), pop3.pop3_get_state(-1));
}

test "get_last_error on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), pop3.pop3_get_last_error(-1));
}

// ── Authentication ──────────────────────────────────────────────────────

test "authenticate transitions to Transaction" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    try expectEqual(@as(u8, 0), pop3.pop3_authenticate(slot)); // Ok
    try expectEqual(@as(u8, 1), pop3.pop3_get_state(slot)); // Transaction
}

test "authenticate in Transaction state fails" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    _ = pop3.pop3_authenticate(slot); // -> Transaction
    try expectEqual(@as(u8, 3), pop3.pop3_authenticate(slot)); // InvalidTransition
}

test "authenticate on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), pop3.pop3_authenticate(-1)); // InvalidSlot
}

// ── Command Execution: Authorization State ──────────────────────────────

test "USER command valid in Authorization" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    try expectEqual(@as(u8, 0), pop3.pop3_execute_command(slot, 0)); // USER -> Ok
    try expectEqual(@as(u32, 1), pop3.pop3_get_command_count(slot));
}

test "PASS command valid in Authorization" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    try expectEqual(@as(u8, 0), pop3.pop3_execute_command(slot, 1)); // PASS -> Ok
}

test "STAT command invalid in Authorization" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    try expectEqual(@as(u8, 4), pop3.pop3_execute_command(slot, 2)); // InvalidCommand
}

test "RETR command invalid in Authorization" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    try expectEqual(@as(u8, 4), pop3.pop3_execute_command(slot, 4)); // InvalidCommand
}

// ── Command Execution: Transaction State ────────────────────────────────

test "STAT command valid in Transaction" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    _ = pop3.pop3_authenticate(slot); // -> Transaction
    try expectEqual(@as(u8, 0), pop3.pop3_execute_command(slot, 2)); // STAT -> Ok
}

test "LIST command valid in Transaction" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    _ = pop3.pop3_authenticate(slot);
    try expectEqual(@as(u8, 0), pop3.pop3_execute_command(slot, 3)); // LIST -> Ok
}

test "DELE increments deleted count" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    _ = pop3.pop3_authenticate(slot);
    try expectEqual(@as(u8, 0), pop3.pop3_execute_command(slot, 5)); // DELE
    try expectEqual(@as(u32, 1), pop3.pop3_get_deleted_count(slot));
    try expectEqual(@as(u8, 0), pop3.pop3_execute_command(slot, 5)); // DELE
    try expectEqual(@as(u32, 2), pop3.pop3_get_deleted_count(slot));
}

test "RSET resets deleted count" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    _ = pop3.pop3_authenticate(slot);
    _ = pop3.pop3_execute_command(slot, 5); // DELE
    _ = pop3.pop3_execute_command(slot, 5); // DELE
    try expectEqual(@as(u32, 2), pop3.pop3_get_deleted_count(slot));
    try expectEqual(@as(u8, 0), pop3.pop3_execute_command(slot, 7)); // RSET
    try expectEqual(@as(u32, 0), pop3.pop3_get_deleted_count(slot));
}

test "RETR increments message count" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    _ = pop3.pop3_authenticate(slot);
    try expectEqual(@as(u8, 0), pop3.pop3_execute_command(slot, 4)); // RETR
    try expectEqual(@as(u32, 1), pop3.pop3_get_message_count(slot));
}

test "USER command invalid in Transaction" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    _ = pop3.pop3_authenticate(slot);
    try expectEqual(@as(u8, 4), pop3.pop3_execute_command(slot, 0)); // InvalidCommand
}

// ── QUIT and Update State ───────────────────────────────────────────────

test "QUIT in Authorization transitions to Update" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    try expectEqual(@as(u8, 0), pop3.pop3_execute_command(slot, 8)); // QUIT
    try expectEqual(@as(u8, 2), pop3.pop3_get_state(slot)); // Update
}

test "QUIT in Transaction transitions to Update" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    _ = pop3.pop3_authenticate(slot);
    try expectEqual(@as(u8, 0), pop3.pop3_execute_command(slot, 8)); // QUIT
    try expectEqual(@as(u8, 2), pop3.pop3_get_state(slot)); // Update
}

test "no commands valid in Update state" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    _ = pop3.pop3_execute_command(slot, 8); // QUIT -> Update
    try expectEqual(@as(u8, 4), pop3.pop3_execute_command(slot, 2)); // STAT -> InvalidCommand
    try expectEqual(@as(u8, 4), pop3.pop3_execute_command(slot, 0)); // USER -> InvalidCommand
}

// ── Invalid Command ─────────────────────────────────────────────────────

test "invalid command tag returns InvalidCommand" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);
    try expectEqual(@as(u8, 4), pop3.pop3_execute_command(slot, 99));
}

test "execute command on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), pop3.pop3_execute_command(-1, 0));
}

// ── Full Session Lifecycle ──────────────────────────────────────────────

test "full lifecycle: auth, commands, quit" {
    const slot = pop3.pop3_create();
    defer pop3.pop3_destroy(slot);

    // Authenticate
    try expectEqual(@as(u8, 0), pop3.pop3_authenticate(slot));

    // Read messages
    _ = pop3.pop3_execute_command(slot, 2); // STAT
    _ = pop3.pop3_execute_command(slot, 3); // LIST
    _ = pop3.pop3_execute_command(slot, 4); // RETR
    _ = pop3.pop3_execute_command(slot, 5); // DELE

    try expectEqual(@as(u32, 4), pop3.pop3_get_command_count(slot));
    try expectEqual(@as(u32, 1), pop3.pop3_get_message_count(slot));
    try expectEqual(@as(u32, 1), pop3.pop3_get_deleted_count(slot));

    // Quit
    _ = pop3.pop3_execute_command(slot, 8); // QUIT
    try expectEqual(@as(u8, 2), pop3.pop3_get_state(slot)); // Update
}
