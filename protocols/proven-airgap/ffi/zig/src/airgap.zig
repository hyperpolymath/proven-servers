// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// airgap.zig -- Zig FFI implementation of proven-airgap.
//
// Implements the airgapped data transfer gateway state machine with:
//   - 64-slot mutex-protected transfer pool
//   - Content scanning pipeline per transfer
//   - Validation check tracking (max 16 checks per transfer)
//   - Transfer lifecycle: Pending -> Scanning -> Approved/Rejected -> InProgress -> Complete/Failed
//   - Media type and direction immutable once set
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching AirgapABI.Types.idr exactly.

const std = @import("std");

// Generated from the proven Idris ABI encoders by tools/gen-abi.sh; the
// comptime guard below pins every enum tag to these, so drift is a build error.
const gen = @import("airgap_abi_gen.zig");

/// ABI version (guarded against gen.ABI_VERSION below).
const ABI_VERSION: u32 = 1;

// =========================================================================
// Enums (matching AirgapABI.Types.idr tag assignments)
// =========================================================================

/// Transfer direction across the air gap (ABI tags 0-1).
pub const TransferDirection = enum(u8) {
    import_ = 0,
    export_ = 1,
};

/// Physical media types for cross-boundary transfer (ABI tags 0-3).
pub const MediaType = enum(u8) {
    usb = 0,
    optical_disc = 1,
    tape_cartridge = 2,
    diode_link = 3,
};

/// Content scanning outcome (ABI tags 0-3).
pub const ScanResult = enum(u8) {
    clean = 0,
    suspicious = 1,
    malicious = 2,
    unscannable = 3,
};

/// Transfer lifecycle state (ABI tags 0-6).
pub const TransferState = enum(u8) {
    pending = 0,
    scanning = 1,
    approved = 2,
    rejected = 3,
    in_progress = 4,
    complete = 5,
    failed = 6,
};

/// Validation check types (ABI tags 0-4).
pub const ValidationCheck = enum(u8) {
    hash_verify = 0,
    signature_verify = 1,
    format_check = 2,
    content_inspection = 3,
    malware_scan = 4,
};

// ── ABI conformance guard ────────────────────────────────────────────────
// Every enum tag MUST equal the generated (= proven Idris) value; a mismatch
// fails `zig build` with the named symbol. Regenerate: bash tools/gen-abi.sh.
comptime {
    if (ABI_VERSION != gen.ABI_VERSION) @compileError("ABI drift: abi_version");

    if (@intFromEnum(TransferDirection.import_) != gen.DIR_IMPORT) @compileError("ABI drift: TransferDirection.import_");
    if (@intFromEnum(TransferDirection.export_) != gen.DIR_EXPORT) @compileError("ABI drift: TransferDirection.export_");

    if (@intFromEnum(MediaType.usb) != gen.MEDIA_USB) @compileError("ABI drift: MediaType.usb");
    if (@intFromEnum(MediaType.optical_disc) != gen.MEDIA_OPTICAL_DISC) @compileError("ABI drift: MediaType.optical_disc");
    if (@intFromEnum(MediaType.tape_cartridge) != gen.MEDIA_TAPE_CARTRIDGE) @compileError("ABI drift: MediaType.tape_cartridge");
    if (@intFromEnum(MediaType.diode_link) != gen.MEDIA_DIODE_LINK) @compileError("ABI drift: MediaType.diode_link");

    if (@intFromEnum(ScanResult.clean) != gen.SCAN_CLEAN) @compileError("ABI drift: ScanResult.clean");
    if (@intFromEnum(ScanResult.suspicious) != gen.SCAN_SUSPICIOUS) @compileError("ABI drift: ScanResult.suspicious");
    if (@intFromEnum(ScanResult.malicious) != gen.SCAN_MALICIOUS) @compileError("ABI drift: ScanResult.malicious");
    if (@intFromEnum(ScanResult.unscannable) != gen.SCAN_UNSCANNABLE) @compileError("ABI drift: ScanResult.unscannable");

    if (@intFromEnum(TransferState.pending) != gen.STATE_PENDING) @compileError("ABI drift: TransferState.pending");
    if (@intFromEnum(TransferState.scanning) != gen.STATE_SCANNING) @compileError("ABI drift: TransferState.scanning");
    if (@intFromEnum(TransferState.approved) != gen.STATE_APPROVED) @compileError("ABI drift: TransferState.approved");
    if (@intFromEnum(TransferState.rejected) != gen.STATE_REJECTED) @compileError("ABI drift: TransferState.rejected");
    if (@intFromEnum(TransferState.in_progress) != gen.STATE_IN_PROGRESS) @compileError("ABI drift: TransferState.in_progress");
    if (@intFromEnum(TransferState.complete) != gen.STATE_COMPLETE) @compileError("ABI drift: TransferState.complete");
    if (@intFromEnum(TransferState.failed) != gen.STATE_FAILED) @compileError("ABI drift: TransferState.failed");

    if (@intFromEnum(ValidationCheck.hash_verify) != gen.CHECK_HASH_VERIFY) @compileError("ABI drift: ValidationCheck.hash_verify");
    if (@intFromEnum(ValidationCheck.signature_verify) != gen.CHECK_SIGNATURE_VERIFY) @compileError("ABI drift: ValidationCheck.signature_verify");
    if (@intFromEnum(ValidationCheck.format_check) != gen.CHECK_FORMAT_CHECK) @compileError("ABI drift: ValidationCheck.format_check");
    if (@intFromEnum(ValidationCheck.content_inspection) != gen.CHECK_CONTENT_INSPECTION) @compileError("ABI drift: ValidationCheck.content_inspection");
    if (@intFromEnum(ValidationCheck.malware_scan) != gen.CHECK_MALWARE_SCAN) @compileError("ABI drift: ValidationCheck.malware_scan");
}

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent transfers.
const MAX_TRANSFERS: usize = 64;

/// Maximum validation checks per transfer.
const MAX_VALIDATIONS: usize = 16;

/// A validation check record.
const Validation = struct {
    /// Type of validation check.
    check: ValidationCheck,
    /// Whether this slot is active.
    active: bool,
};

/// Default (empty) validation.
const empty_validation: Validation = .{
    .check = .hash_verify,
    .active = false,
};

/// An airgap data transfer.
const Transfer = struct {
    /// Current transfer lifecycle state.
    state: TransferState,
    /// Direction of data movement across the air gap.
    direction: TransferDirection,
    /// Physical media used for transfer.
    media: MediaType,
    /// Result of content scanning (valid after scan completes).
    scan_result: ScanResult,
    /// Validation checks applied to this transfer.
    validations: [MAX_VALIDATIONS]Validation,
    /// Number of active validation checks.
    validation_count: u32,
    /// Total bytes transferred (monotonic counter).
    bytes_transferred: u64,
    /// Whether this transfer slot is in use.
    active: bool,
};

/// Default (empty) transfer.
const empty_transfer: Transfer = .{
    .state = .pending,
    .direction = .import_,
    .media = .usb,
    .scan_result = .clean,
    .validations = [_]Validation{empty_validation} ** MAX_VALIDATIONS,
    .validation_count = 0,
    .bytes_transferred = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var transfers: [MAX_TRANSFERS]Transfer = [_]Transfer{empty_transfer} ** MAX_TRANSFERS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_TRANSFERS) return null;
    const idx: usize = @intCast(slot);
    if (!transfers[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

// -- ABI version --------------------------------------------------------------

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn airgap_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new airgap transfer. Returns slot index (>=0) or -1 on failure.
/// The transfer starts in Pending state.
pub export fn airgap_create(direction: u8, media: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (direction > 1) return -1;
    if (media > 3) return -1;

    for (&transfers, 0..) |*t, i| {
        if (!t.active) {
            t.* = empty_transfer;
            t.direction = @enumFromInt(direction);
            t.media = @enumFromInt(media);
            t.state = .pending;
            t.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a transfer, releasing its slot.
pub export fn airgap_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_TRANSFERS) return;
    transfers[@intCast(slot)] = empty_transfer;
}

// -- State queries ------------------------------------------------------------

/// Returns the current TransferState tag for a transfer.
pub export fn airgap_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // pending fallback
    return @intFromEnum(transfers[idx].state);
}

/// Returns the TransferDirection tag for a transfer.
pub export fn airgap_direction(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(transfers[idx].direction);
}

/// Returns the MediaType tag for a transfer.
pub export fn airgap_media(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(transfers[idx].media);
}

// -- Scanning pipeline --------------------------------------------------------

/// Start content scanning. Returns 0 on success, 1 on rejection.
/// Transitions: Pending -> Scanning.
pub export fn airgap_start_scan(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (transfers[idx].state != .pending) return 1;

    transfers[idx].state = .scanning;
    return 0;
}

/// Submit scan result. Returns 0 on success, 1 on rejection.
/// Transitions: Scanning -> Approved (if Clean) or Rejected (otherwise).
pub export fn airgap_submit_scan_result(slot: c_int, result: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (transfers[idx].state != .scanning) return 1;
    if (result > 3) return 1;

    const scan_result: ScanResult = @enumFromInt(result);
    transfers[idx].scan_result = scan_result;

    if (scan_result == .clean) {
        transfers[idx].state = .approved;
    } else {
        transfers[idx].state = .rejected;
    }
    return 0;
}

// -- Transfer execution -------------------------------------------------------

/// Begin data transfer. Returns 0 on success, 1 on rejection.
/// Transitions: Approved -> InProgress.
pub export fn airgap_begin_transfer(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (transfers[idx].state != .approved) return 1;

    transfers[idx].state = .in_progress;
    return 0;
}

/// Complete data transfer. Returns 0 on success, 1 on rejection.
/// Transitions: InProgress -> Complete.
pub export fn airgap_complete_transfer(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (transfers[idx].state != .in_progress) return 1;

    transfers[idx].state = .complete;
    return 0;
}

/// Fail data transfer. Returns 0 on success, 1 on rejection.
/// Transitions: InProgress -> Failed.
pub export fn airgap_fail_transfer(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (transfers[idx].state != .in_progress) return 1;

    transfers[idx].state = .failed;
    return 0;
}

// -- Validation checks --------------------------------------------------------

/// Add a validation check to the transfer. Returns 0 on success, 1 on rejection.
pub export fn airgap_add_validation(slot: c_int, check: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (check > 4) return 1;

    // Find a free validation slot
    for (&transfers[idx].validations) |*v| {
        if (!v.active) {
            v.check = @enumFromInt(check);
            v.active = true;
            transfers[idx].validation_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Returns the number of validation checks for a transfer.
pub export fn airgap_validation_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return transfers[idx].validation_count;
}

// -- Stateless transition table -----------------------------------------------

/// Check if a transfer state transition is valid.
pub export fn airgap_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Pending -> Scanning
    if (from == 1 and to == 2) return 1; // Scanning -> Approved
    if (from == 1 and to == 3) return 1; // Scanning -> Rejected
    if (from == 2 and to == 4) return 1; // Approved -> InProgress
    if (from == 4 and to == 5) return 1; // InProgress -> Complete
    if (from == 4 and to == 6) return 1; // InProgress -> Failed
    return 0;
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(transfers)) > 16 * 1024 * 1024)
        @compileError("pool 'transfers' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
