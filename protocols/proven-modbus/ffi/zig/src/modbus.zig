// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// modbus.zig -- Zig FFI implementation of proven-modbus.
//
// Implements the Modbus TCP gateway state machine with:
//   - 64-slot mutex-protected gateway session pool
//   - Per-session register file (256 coils + 256 holding registers)
//   - Per-session pending transaction tracking (max 32)
//   - Modbus TCP gateway lifecycle
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching abi.Types.idr exactly.

const std = @import("std");

// Generated from the proven Idris ABI encoders by tools/gen-abi.sh; the
// comptime guard below pins every enum tag to these, so drift is a build error.
const gen = @import("modbus_abi_gen.zig");

/// ABI version (guarded against gen.ABI_VERSION below).
const ABI_VERSION: u32 = 1;

// =========================================================================
// Enums (matching abi.Types.idr tag assignments)
// =========================================================================

/// Modbus function codes (ABI tags 0-9).
pub const FunctionCode = enum(u8) {
    read_coils = 0,
    read_discrete_inputs = 1,
    read_holding_registers = 2,
    read_input_registers = 3,
    write_single_coil = 4,
    write_single_register = 5,
    write_multiple_coils = 6,
    write_multiple_registers = 7,
    read_write_multiple_registers = 8,
    mask_write_register = 9,
};

/// Modbus exception codes (ABI tags 0-8).
pub const ExceptionCode = enum(u8) {
    illegal_function = 0,
    illegal_data_address = 1,
    illegal_data_value = 2,
    slave_device_failure = 3,
    acknowledge = 4,
    slave_device_busy = 5,
    memory_parity_error = 6,
    gateway_path_unavailable = 7,
    gateway_target_device_failed = 8,
};

/// Device roles (ABI tags 0-1).
pub const DeviceRole = enum(u8) {
    master = 0,
    slave = 1,
};

/// Gateway lifecycle states (ABI tags 0-4).
pub const GatewayState = enum(u8) {
    idle = 0,
    listening = 1,
    processing = 2,
    err = 3,
    stopping = 4,
};

// ── ABI conformance guard ────────────────────────────────────────────────
// Every enum tag MUST equal the generated (= proven Idris) value; a mismatch
// fails `zig build` with the named symbol. Regenerate: bash tools/gen-abi.sh.
comptime {
    if (ABI_VERSION != gen.ABI_VERSION) @compileError("ABI drift: abi_version");

    if (@intFromEnum(FunctionCode.read_coils) != gen.FUNC_READ_COILS) @compileError("ABI drift: FunctionCode.read_coils");
    if (@intFromEnum(FunctionCode.read_discrete_inputs) != gen.FUNC_READ_DISCRETE_INPUTS) @compileError("ABI drift: FunctionCode.read_discrete_inputs");
    if (@intFromEnum(FunctionCode.read_holding_registers) != gen.FUNC_READ_HOLDING_REGISTERS) @compileError("ABI drift: FunctionCode.read_holding_registers");
    if (@intFromEnum(FunctionCode.read_input_registers) != gen.FUNC_READ_INPUT_REGISTERS) @compileError("ABI drift: FunctionCode.read_input_registers");
    if (@intFromEnum(FunctionCode.write_single_coil) != gen.FUNC_WRITE_SINGLE_COIL) @compileError("ABI drift: FunctionCode.write_single_coil");
    if (@intFromEnum(FunctionCode.write_single_register) != gen.FUNC_WRITE_SINGLE_REGISTER) @compileError("ABI drift: FunctionCode.write_single_register");
    if (@intFromEnum(FunctionCode.write_multiple_coils) != gen.FUNC_WRITE_MULTIPLE_COILS) @compileError("ABI drift: FunctionCode.write_multiple_coils");
    if (@intFromEnum(FunctionCode.write_multiple_registers) != gen.FUNC_WRITE_MULTIPLE_REGISTERS) @compileError("ABI drift: FunctionCode.write_multiple_registers");
    if (@intFromEnum(FunctionCode.read_write_multiple_registers) != gen.FUNC_READ_WRITE_MULTIPLE_REGISTERS) @compileError("ABI drift: FunctionCode.read_write_multiple_registers");
    if (@intFromEnum(FunctionCode.mask_write_register) != gen.FUNC_MASK_WRITE_REGISTER) @compileError("ABI drift: FunctionCode.mask_write_register");

    if (@intFromEnum(ExceptionCode.illegal_function) != gen.EXC_ILLEGAL_FUNCTION) @compileError("ABI drift: ExceptionCode.illegal_function");
    if (@intFromEnum(ExceptionCode.illegal_data_address) != gen.EXC_ILLEGAL_DATA_ADDRESS) @compileError("ABI drift: ExceptionCode.illegal_data_address");
    if (@intFromEnum(ExceptionCode.illegal_data_value) != gen.EXC_ILLEGAL_DATA_VALUE) @compileError("ABI drift: ExceptionCode.illegal_data_value");
    if (@intFromEnum(ExceptionCode.slave_device_failure) != gen.EXC_SLAVE_DEVICE_FAILURE) @compileError("ABI drift: ExceptionCode.slave_device_failure");
    if (@intFromEnum(ExceptionCode.acknowledge) != gen.EXC_ACKNOWLEDGE) @compileError("ABI drift: ExceptionCode.acknowledge");
    if (@intFromEnum(ExceptionCode.slave_device_busy) != gen.EXC_SLAVE_DEVICE_BUSY) @compileError("ABI drift: ExceptionCode.slave_device_busy");
    if (@intFromEnum(ExceptionCode.memory_parity_error) != gen.EXC_MEMORY_PARITY_ERROR) @compileError("ABI drift: ExceptionCode.memory_parity_error");
    if (@intFromEnum(ExceptionCode.gateway_path_unavailable) != gen.EXC_GATEWAY_PATH_UNAVAILABLE) @compileError("ABI drift: ExceptionCode.gateway_path_unavailable");
    if (@intFromEnum(ExceptionCode.gateway_target_device_failed) != gen.EXC_GATEWAY_TARGET_DEVICE_FAILED) @compileError("ABI drift: ExceptionCode.gateway_target_device_failed");

    if (@intFromEnum(DeviceRole.master) != gen.ROLE_MASTER) @compileError("ABI drift: DeviceRole.master");
    if (@intFromEnum(DeviceRole.slave) != gen.ROLE_SLAVE) @compileError("ABI drift: DeviceRole.slave");

    if (@intFromEnum(GatewayState.idle) != gen.GW_IDLE) @compileError("ABI drift: GatewayState.idle");
    if (@intFromEnum(GatewayState.listening) != gen.GW_LISTENING) @compileError("ABI drift: GatewayState.listening");
    if (@intFromEnum(GatewayState.processing) != gen.GW_PROCESSING) @compileError("ABI drift: GatewayState.processing");
    if (@intFromEnum(GatewayState.err) != gen.GW_ERR) @compileError("ABI drift: GatewayState.err");
    if (@intFromEnum(GatewayState.stopping) != gen.GW_STOPPING) @compileError("ABI drift: GatewayState.stopping");
}

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum pending transactions per session.
const MAX_PENDING: usize = 32;

/// Number of coils in the register file.
const NUM_COILS: usize = 256;

/// Number of holding registers in the register file.
const NUM_REGISTERS: usize = 256;

/// A pending Modbus transaction.
const Transaction = struct {
    txn_id: u32,
    func_code: FunctionCode,
    active: bool,
};

/// Default (empty) transaction.
const empty_txn: Transaction = .{
    .txn_id = 0,
    .func_code = .read_coils,
    .active = false,
};

/// A Modbus gateway session.
const Session = struct {
    /// Current gateway lifecycle state.
    state: GatewayState,
    /// Modbus unit ID.
    unit_id: u8,
    /// Device role (master/slave).
    role: DeviceRole,
    /// Listening port.
    port: u16,
    /// Coil register file (bit-packed as bytes for simplicity).
    coils: [NUM_COILS]u8,
    /// Holding register file.
    holding_registers: [NUM_REGISTERS]u16,
    /// Pending transactions.
    pending: [MAX_PENDING]Transaction,
    /// Number of active pending transactions.
    pending_count: u32,
    /// Last exception code (for error state).
    last_exception: ExceptionCode,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .unit_id = 1,
    .role = .slave,
    .port = 0,
    .coils = [_]u8{0} ** NUM_COILS,
    .holding_registers = [_]u16{0} ** NUM_REGISTERS,
    .pending = [_]Transaction{empty_txn} ** MAX_PENDING,
    .pending_count = 0,
    .last_exception = .illegal_function,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

/// Add a pending transaction and transition to Processing if not already.
fn addTransaction(idx: usize, func_code: FunctionCode) u8 {
    if (sessions[idx].pending_count >= MAX_PENDING) return 1;

    for (&sessions[idx].pending) |*p| {
        if (!p.active) {
            p.txn_id = sessions[idx].pending_count + 1;
            p.func_code = func_code;
            p.active = true;
            sessions[idx].pending_count += 1;
            if (sessions[idx].state == .listening) {
                sessions[idx].state = .processing;
            }
            return 0;
        }
    }
    return 1;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

/// Returns the ABI version number.
pub export fn modbus_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
}

/// Create a new Modbus gateway session. Returns slot (>=0) or -1 on failure.
pub export fn modbus_create(unit_id: u8, role: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (role > 1) return -1;
    if (unit_id == 0) return -1; // unit ID 0 is broadcast, not valid for a session

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.unit_id = unit_id;
            s.role = @enumFromInt(role);
            s.state = .idle;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn modbus_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current GatewayState tag.
pub export fn modbus_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Start listening on a port. Transitions Idle -> Listening.
pub export fn modbus_listen(slot: c_int, port: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .idle) return 1;
    if (port == 0) return 1;

    sessions[idx].port = port;
    sessions[idx].state = .listening;
    return 0;
}

/// Read coils request. Transitions Listening -> Processing.
pub export fn modbus_read_coils(slot: c_int, addr: u16, count: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .listening and state != .processing) return 1;
    if (count == 0) return 1;
    if (@as(u32, addr) + @as(u32, count) > NUM_COILS) return 1;

    return addTransaction(idx, .read_coils);
}

/// Read holding registers request. Transitions Listening -> Processing.
pub export fn modbus_read_holding(slot: c_int, addr: u16, count: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .listening and state != .processing) return 1;
    if (count == 0) return 1;
    if (@as(u32, addr) + @as(u32, count) > NUM_REGISTERS) return 1;

    return addTransaction(idx, .read_holding_registers);
}

/// Write a single coil.
pub export fn modbus_write_coil(slot: c_int, addr: u16, value: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .listening and state != .processing) return 1;
    if (addr >= NUM_COILS) return 1;

    sessions[idx].coils[addr] = if (value != 0) 1 else 0;
    return addTransaction(idx, .write_single_coil);
}

/// Write a single holding register.
pub export fn modbus_write_register(slot: c_int, addr: u16, value: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .listening and state != .processing) return 1;
    if (addr >= NUM_REGISTERS) return 1;

    sessions[idx].holding_registers[addr] = value;
    return addTransaction(idx, .write_single_register);
}

/// Complete a pending transaction. May transition Processing -> Listening.
pub export fn modbus_complete_transaction(slot: c_int, txn_id: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;

    for (&sessions[idx].pending) |*p| {
        if (p.active and p.txn_id == txn_id) {
            p.active = false;
            sessions[idx].pending_count -= 1;

            if (sessions[idx].pending_count == 0 and
                sessions[idx].state == .processing)
            {
                sessions[idx].state = .listening;
            }
            return 0;
        }
    }
    return 1;
}

/// Report an error. Transitions to Error state.
pub export fn modbus_report_error(slot: c_int, exc_code: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (exc_code > 8) return 1;
    const state = sessions[idx].state;
    if (state != .listening and state != .processing) return 1;

    sessions[idx].last_exception = @enumFromInt(exc_code);
    sessions[idx].state = .err;
    return 0;
}

/// Recover from error. Transitions Error -> Listening.
pub export fn modbus_recover(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .err) return 1;

    // Clear pending transactions
    sessions[idx].pending = [_]Transaction{empty_txn} ** MAX_PENDING;
    sessions[idx].pending_count = 0;
    sessions[idx].state = .listening;
    return 0;
}

/// Returns the number of pending transactions.
pub export fn modbus_pending_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].pending_count;
}

/// Get the value of a coil.
pub export fn modbus_get_coil(slot: c_int, addr: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;
    if (addr >= NUM_COILS) return 0;
    return sessions[idx].coils[addr];
}

/// Get the value of a holding register.
pub export fn modbus_get_register(slot: c_int, addr: u16) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;
    if (addr >= NUM_REGISTERS) return 0;
    return sessions[idx].holding_registers[addr];
}

/// Stop the gateway. Transitions to Stopping.
pub export fn modbus_stop(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .listening or state == .processing or state == .err) {
        sessions[idx].state = .stopping;
        return 0;
    }
    return 1;
}

/// Complete cleanup. Transitions Stopping -> Idle.
pub export fn modbus_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .stopping) return 1;

    sessions[idx].state = .idle;
    sessions[idx].port = 0;
    sessions[idx].coils = [_]u8{0} ** NUM_COILS;
    sessions[idx].holding_registers = [_]u16{0} ** NUM_REGISTERS;
    sessions[idx].pending = [_]Transaction{empty_txn} ** MAX_PENDING;
    sessions[idx].pending_count = 0;

    return 0;
}

/// Check if a gateway state transition is valid.
pub export fn modbus_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Listening
    if (from == 1 and to == 2) return 1; // Listening -> Processing
    if (from == 2 and to == 2) return 1; // Processing -> Processing
    if (from == 2 and to == 1) return 1; // Processing -> Listening
    if (from == 1 and to == 3) return 1; // Listening -> Error
    if (from == 2 and to == 3) return 1; // Processing -> Error
    if (from == 3 and to == 1) return 1; // Error -> Listening (recover)
    if (from == 1 and to == 4) return 1; // Listening -> Stopping
    if (from == 2 and to == 4) return 1; // Processing -> Stopping
    if (from == 3 and to == 4) return 1; // Error -> Stopping
    if (from == 4 and to == 0) return 1; // Stopping -> Idle
    return 0;
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
