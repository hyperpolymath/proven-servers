// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-cli FFI.
//
// Verifies that the Zig implementation matches the Idris2 formal
// specification in CLIABI.Types.

const std = @import("std");
const cli = @import("cli");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), cli.cli_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "ArgTypeTag encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(cli.ArgTypeTag.string));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(cli.ArgTypeTag.int));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(cli.ArgTypeTag.bool));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(cli.ArgTypeTag.float));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(cli.ArgTypeTag.path));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(cli.ArgTypeTag.enum_type));
}

test "ParseResult encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(cli.ParseResult.ok));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(cli.ParseResult.err));
}

test "ParseErrorTag encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(cli.ParseErrorTag.not_an_integer));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(cli.ParseErrorTag.not_a_boolean));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(cli.ParseErrorTag.not_a_float));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(cli.ParseErrorTag.empty_path));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(cli.ParseErrorTag.path_contains_null));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(cli.ParseErrorTag.invalid_enum));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(cli.ParseErrorTag.arg_too_long));
}

test "OptionDefErrTag encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(cli.OptionDefErrTag.dup_short));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(cli.OptionDefErrTag.dup_long));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(cli.OptionDefErrTag.empty_long));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(cli.OptionDefErrTag.req_with_def));
}

test "CmdDefErrTag encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(cli.CmdDefErrTag.empty_cmd_name));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(cli.CmdDefErrTag.cmd_name_spaces));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(cli.CmdDefErrTag.subcmd_too_deep));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(cli.CmdDefErrTag.dup_subcmd));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(cli.CmdDefErrTag.opt_errors));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create returns valid slot with correct config" {
    const slot = cli.cli_create(128, 3);
    try std.testing.expect(slot >= 0);
    defer cli.cli_destroy(slot);
    try std.testing.expectEqual(@as(u8, 3), cli.cli_max_depth(slot));
    try std.testing.expectEqual(@as(u8, 0), cli.cli_current_depth(slot));
    try std.testing.expectEqual(@as(u16, 0), cli.cli_option_count(slot));
}

test "destroy is safe with invalid slot" {
    cli.cli_destroy(-1);
    cli.cli_destroy(999);
}

// =========================================================================
// Option registration
// =========================================================================

test "register options" {
    const slot = cli.cli_create(256, 5);
    defer cli.cli_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), cli.cli_register_option(slot, 0, 1)); // String, required
    try std.testing.expectEqual(@as(u8, 0), cli.cli_register_option(slot, 1, 0)); // Int, optional
    try std.testing.expectEqual(@as(u8, 0), cli.cli_register_option(slot, 2, 0)); // Bool, optional
    try std.testing.expectEqual(@as(u16, 3), cli.cli_option_count(slot));
}

test "register option rejects invalid type" {
    const slot = cli.cli_create(256, 5);
    defer cli.cli_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), cli.cli_register_option(slot, 99, 0));
}

test "register option rejects invalid slot" {
    try std.testing.expectEqual(@as(u8, 1), cli.cli_register_option(-1, 0, 0));
}

// =========================================================================
// Argument parsing
// =========================================================================

test "parse arg succeeds for valid type" {
    const slot = cli.cli_create(256, 5);
    defer cli.cli_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), cli.cli_parse_arg(slot, 0)); // String
    try std.testing.expectEqual(@as(u8, 0), cli.cli_parse_arg(slot, 4)); // Path
}

test "parse arg rejects invalid type" {
    const slot = cli.cli_create(256, 5);
    defer cli.cli_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), cli.cli_parse_arg(slot, 99));
}

test "parse arg rejects when max args exceeded" {
    const slot = cli.cli_create(2, 5); // Only 2 args allowed
    defer cli.cli_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), cli.cli_parse_arg(slot, 0));
    try std.testing.expectEqual(@as(u8, 0), cli.cli_parse_arg(slot, 0));
    try std.testing.expectEqual(@as(u8, 1), cli.cli_parse_arg(slot, 0)); // Exceeds max
}

// =========================================================================
// Subcommand depth
// =========================================================================

test "push and pop subcommands" {
    const slot = cli.cli_create(256, 3);
    defer cli.cli_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), cli.cli_current_depth(slot));
    try std.testing.expectEqual(@as(u8, 0), cli.cli_push_subcommand(slot));
    try std.testing.expectEqual(@as(u8, 1), cli.cli_current_depth(slot));
    try std.testing.expectEqual(@as(u8, 0), cli.cli_push_subcommand(slot));
    try std.testing.expectEqual(@as(u8, 2), cli.cli_current_depth(slot));
    try std.testing.expectEqual(@as(u8, 0), cli.cli_pop_subcommand(slot));
    try std.testing.expectEqual(@as(u8, 1), cli.cli_current_depth(slot));
}

test "push subcommand rejects at max depth" {
    const slot = cli.cli_create(256, 2);
    defer cli.cli_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), cli.cli_push_subcommand(slot));
    try std.testing.expectEqual(@as(u8, 0), cli.cli_push_subcommand(slot));
    try std.testing.expectEqual(@as(u8, 1), cli.cli_push_subcommand(slot)); // Exceeds max
}

test "pop subcommand rejects at root" {
    const slot = cli.cli_create(256, 5);
    defer cli.cli_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), cli.cli_pop_subcommand(slot));
}

// =========================================================================
// Reset
// =========================================================================

test "reset clears state but preserves config" {
    const slot = cli.cli_create(128, 4);
    defer cli.cli_destroy(slot);

    _ = cli.cli_register_option(slot, 0, 1);
    _ = cli.cli_push_subcommand(slot);
    _ = cli.cli_parse_arg(slot, 0);

    cli.cli_reset(slot);

    try std.testing.expectEqual(@as(u16, 0), cli.cli_option_count(slot));
    try std.testing.expectEqual(@as(u8, 0), cli.cli_current_depth(slot));
    try std.testing.expectEqual(@as(u8, 4), cli.cli_max_depth(slot)); // Preserved
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u16, 0), cli.cli_option_count(-1));
    try std.testing.expectEqual(@as(u8, 0), cli.cli_current_depth(-1));
    try std.testing.expectEqual(@as(u8, 0), cli.cli_max_depth(-1));
    try std.testing.expectEqual(@as(u8, 0), cli.cli_last_error(-1));
}
