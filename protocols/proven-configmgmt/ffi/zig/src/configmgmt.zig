// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// configmgmt.zig -- Zig FFI implementation of proven-configmgmt.
//
// Implements a configuration management resource session manager with:
//   - 64-slot resource session pool
//   - Per-session resource type, desired/observed state tracking
//   - Drift detection by comparing desired vs observed state
//   - Convergence action computation
//   - Apply mode enforcement (enforce/dry-run/audit)
//   - Thread-safe via mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching ConfigmgmtABI.Types.idr exactly.

const std = @import("std");

// Generated from the proven Idris ABI encoders by tools/gen-abi.sh; the
// comptime guard below pins every enum tag to these, so drift is a build error.
const gen = @import("configmgmt_abi_gen.zig");

/// ABI version (guarded against gen.ABI_VERSION below).
const ABI_VERSION: u32 = 1;

// =========================================================================
// Enums (matching ConfigmgmtABI.Types.idr tag assignments)
// =========================================================================

/// Resource types (tags 0-8).
pub const ResourceType = enum(u8) {
    file = 0,
    package = 1,
    service = 2,
    user = 3,
    group = 4,
    cron = 5,
    mount = 6,
    firewall = 7,
    registry = 8,
};

/// Resource states (tags 0-5).
pub const ResourceState = enum(u8) {
    present = 0,
    absent = 1,
    running = 2,
    stopped = 3,
    enabled = 4,
    disabled = 5,
};

/// Change actions (tags 0-5).
pub const ChangeAction = enum(u8) {
    create = 0,
    modify = 1,
    delete = 2,
    restart = 3,
    reload = 4,
    skip = 5,
};

/// Drift statuses (tags 0-3).
pub const DriftStatus = enum(u8) {
    in_sync = 0,
    drifted = 1,
    unknown = 2,
    unmanaged = 3,
};

/// Apply modes (tags 0-2).
pub const ApplyMode = enum(u8) {
    enforce = 0,
    dry_run = 1,
    audit = 2,
};

// ABI conformance: pin every enum tag to the proof-generated constant so any
// drift from the proven ConfigmgmtABI encoders is a compile error (not a comment).
comptime {
    if (ABI_VERSION != gen.ABI_VERSION) @compileError("ABI drift: abi_version");

    if (@intFromEnum(ResourceType.file) != gen.RT_FILE) @compileError("ABI drift: ResourceType.file");
    if (@intFromEnum(ResourceType.package) != gen.RT_PACKAGE) @compileError("ABI drift: ResourceType.package");
    if (@intFromEnum(ResourceType.service) != gen.RT_SERVICE) @compileError("ABI drift: ResourceType.service");
    if (@intFromEnum(ResourceType.user) != gen.RT_USER) @compileError("ABI drift: ResourceType.user");
    if (@intFromEnum(ResourceType.group) != gen.RT_GROUP) @compileError("ABI drift: ResourceType.group");
    if (@intFromEnum(ResourceType.cron) != gen.RT_CRON) @compileError("ABI drift: ResourceType.cron");
    if (@intFromEnum(ResourceType.mount) != gen.RT_MOUNT) @compileError("ABI drift: ResourceType.mount");
    if (@intFromEnum(ResourceType.firewall) != gen.RT_FIREWALL) @compileError("ABI drift: ResourceType.firewall");
    if (@intFromEnum(ResourceType.registry) != gen.RT_REGISTRY) @compileError("ABI drift: ResourceType.registry");

    if (@intFromEnum(ResourceState.present) != gen.RS_PRESENT) @compileError("ABI drift: ResourceState.present");
    if (@intFromEnum(ResourceState.absent) != gen.RS_ABSENT) @compileError("ABI drift: ResourceState.absent");
    if (@intFromEnum(ResourceState.running) != gen.RS_RUNNING) @compileError("ABI drift: ResourceState.running");
    if (@intFromEnum(ResourceState.stopped) != gen.RS_STOPPED) @compileError("ABI drift: ResourceState.stopped");
    if (@intFromEnum(ResourceState.enabled) != gen.RS_ENABLED) @compileError("ABI drift: ResourceState.enabled");
    if (@intFromEnum(ResourceState.disabled) != gen.RS_DISABLED) @compileError("ABI drift: ResourceState.disabled");

    if (@intFromEnum(ChangeAction.create) != gen.ACT_CREATE) @compileError("ABI drift: ChangeAction.create");
    if (@intFromEnum(ChangeAction.modify) != gen.ACT_MODIFY) @compileError("ABI drift: ChangeAction.modify");
    if (@intFromEnum(ChangeAction.delete) != gen.ACT_DELETE) @compileError("ABI drift: ChangeAction.delete");
    if (@intFromEnum(ChangeAction.restart) != gen.ACT_RESTART) @compileError("ABI drift: ChangeAction.restart");
    if (@intFromEnum(ChangeAction.reload) != gen.ACT_RELOAD) @compileError("ABI drift: ChangeAction.reload");
    if (@intFromEnum(ChangeAction.skip) != gen.ACT_SKIP) @compileError("ABI drift: ChangeAction.skip");

    if (@intFromEnum(DriftStatus.in_sync) != gen.DS_IN_SYNC) @compileError("ABI drift: DriftStatus.in_sync");
    if (@intFromEnum(DriftStatus.drifted) != gen.DS_DRIFTED) @compileError("ABI drift: DriftStatus.drifted");
    if (@intFromEnum(DriftStatus.unknown) != gen.DS_UNKNOWN) @compileError("ABI drift: DriftStatus.unknown");
    if (@intFromEnum(DriftStatus.unmanaged) != gen.DS_UNMANAGED) @compileError("ABI drift: DriftStatus.unmanaged");

    if (@intFromEnum(ApplyMode.enforce) != gen.AM_ENFORCE) @compileError("ABI drift: ApplyMode.enforce");
    if (@intFromEnum(ApplyMode.dry_run) != gen.AM_DRY_RUN) @compileError("ABI drift: ApplyMode.dry_run");
    if (@intFromEnum(ApplyMode.audit) != gen.AM_AUDIT) @compileError("ABI drift: ApplyMode.audit");
}

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent resource sessions.
const MAX_SESSIONS: usize = 64;

/// A configuration management resource session.
const Session = struct {
    /// Type of the managed resource.
    resource_type: ResourceType,
    /// Desired state.
    desired_state: ResourceState,
    /// Observed state (set after inspection).
    observed_state: ResourceState,
    /// Whether observed state has been set.
    observed_set: bool,
    /// Apply mode for this session.
    apply_mode: ApplyMode,
    /// Number of convergence operations performed.
    converge_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .resource_type = .file,
    .desired_state = .present,
    .observed_state = .present,
    .observed_set = false,
    .apply_mode = .enforce,
    .converge_count = 0,
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

/// Compute the convergence action based on desired and observed state.
fn computeAction(desired: ResourceState, observed: ResourceState) ChangeAction {
    if (@intFromEnum(desired) == @intFromEnum(observed)) return .skip; // Already converged

    // Absent -> Present = Create
    if (desired == .present and observed == .absent) return .create;
    // Present -> Absent = Delete
    if (desired == .absent and observed == .present) return .delete;
    // Stopped -> Running = Restart
    if (desired == .running and observed == .stopped) return .restart;
    // Running -> Stopped = Modify (stop service)
    if (desired == .stopped and observed == .running) return .modify;
    // Disabled -> Enabled = Modify
    if (desired == .enabled and observed == .disabled) return .modify;
    // Enabled -> Disabled = Modify
    if (desired == .disabled and observed == .enabled) return .modify;
    // Running -> Running but needs reload = Reload (handled externally)
    // Default: Modify
    return .modify;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

/// Returns the ABI version number.
pub export fn configmgmt_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
}

/// Create a new resource session. Returns slot index (>=0) or -1.
pub export fn configmgmt_create(res_type: u8, desired: u8, mode: u8) callconv(.c) c_int {
    if (res_type > 8 or desired > 5 or mode > 2) return -1;

    mutex.lock();
    defer mutex.unlock();

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.resource_type = @enumFromInt(res_type);
            s.desired_state = @enumFromInt(desired);
            s.apply_mode = @enumFromInt(mode);
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn configmgmt_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the resource type tag.
pub export fn configmgmt_resource_type(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].resource_type);
}

/// Returns the desired state tag.
pub export fn configmgmt_desired_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].desired_state);
}

/// Returns the observed state tag.
pub export fn configmgmt_observed_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].observed_state);
}

/// Set observed state. Returns 0 on success, 1 on invalid tag/slot.
pub export fn configmgmt_set_observed(slot: c_int, state: u8) callconv(.c) u8 {
    if (state > 5) return 1;

    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    sessions[idx].observed_state = @enumFromInt(state);
    sessions[idx].observed_set = true;
    return 0;
}

/// Compute drift status by comparing desired vs observed state.
pub export fn configmgmt_drift_status(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(DriftStatus.unknown);
    if (!sessions[idx].observed_set) return @intFromEnum(DriftStatus.unknown);
    if (@intFromEnum(sessions[idx].desired_state) == @intFromEnum(sessions[idx].observed_state)) {
        return @intFromEnum(DriftStatus.in_sync);
    }
    return @intFromEnum(DriftStatus.drifted);
}

/// Compute the convergence action needed.
pub export fn configmgmt_action(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(ChangeAction.skip);
    return @intFromEnum(computeAction(sessions[idx].desired_state, sessions[idx].observed_state));
}

/// Returns the apply mode tag.
pub export fn configmgmt_apply_mode(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].apply_mode);
}

/// Execute convergence. Returns 0 on success, 1 if mode is DryRun/Audit,
/// 2 if invalid slot.
pub export fn configmgmt_converge(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 2;
    if (sessions[idx].apply_mode != .enforce) return 1;

    // Simulate convergence: set observed = desired
    sessions[idx].observed_state = sessions[idx].desired_state;
    sessions[idx].observed_set = true;
    sessions[idx].converge_count += 1;
    return 0;
}

/// Returns the number of convergence operations performed.
pub export fn configmgmt_converge_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].converge_count;
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
