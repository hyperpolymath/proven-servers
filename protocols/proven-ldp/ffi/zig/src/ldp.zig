// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ldp.zig — Zig FFI implementation of proven-ldp.
//
// Implements the W3C Linked Data Platform resource primitive with:
//   - Slot-based resource context management (up to 64 concurrent resources)
//   - Container hierarchy (Basic, Direct, Indirect)
//   - Resource type tracking (RDFSource, NonRDFSource, Container)
//   - Preference management (RFC 7240 Prefer header)
//   - Constraint violation checking
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/LdpABI/Layout.idr)
//   - C header   (generated/abi/ldp.h)

const std = @import("std");

// ── Enums (matching Idris2 Layout.idr tag assignments exactly) ──────────

/// ContainerType — matches containerTypeToTag
pub const ContainerType = enum(u8) {
    basic = 0,
    direct = 1,
    indirect = 2,
};

/// ResourceType — matches resourceTypeToTag
pub const ResourceType = enum(u8) {
    rdf_source = 0,
    non_rdf_source = 1,
    container = 2,
};

/// Preference — matches preferenceToTag
pub const Preference = enum(u8) {
    minimal_container = 0,
    include_containment = 1,
    include_membership = 2,
    omit_containment = 3,
    omit_membership = 4,
};

/// InteractionModel — matches interactionModelToTag
pub const InteractionModel = enum(u8) {
    ldpr = 0,
    ldpc = 1,
    ldp_basic_container = 2,
    ldp_direct_container = 3,
    ldp_indirect_container = 4,
};

/// ConstraintViolation — matches constraintViolationToTag
pub const ConstraintViolation = enum(u8) {
    membership_constant = 0,
    contains_triples_modified = 1,
    server_managed = 2,
    type_conflict = 3,
};

/// LdpError — matches ldpErrorToTag
pub const LdpError = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    constraint_violation = 3,
    type_conflict = 4,
    capacity_exhausted = 5,
    invalid_preference = 6,
};

// ── Resource Context instance ───────────────────────────────────────────

/// Maximum number of children a container can hold.
const MAX_CHILDREN: u32 = 1024;

const LdpCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// Type of LDP resource.
    resource_type: ResourceType,
    /// Container type (meaningful only if resource_type is container).
    container_type: ContainerType,
    /// Interaction model for this resource.
    interaction: InteractionModel,
    /// Active client preference.
    preference: Preference,
    /// Last error code (255 = no error).
    last_error: u8,
    /// Number of child resources (for containers).
    child_count: u32,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: LdpCtx = .{
    .active = false,
    .resource_type = .rdf_source,
    .container_type = .basic,
    .interaction = .ldpr,
    .preference = .minimal_container,
    .last_error = 255,
    .child_count = 0,
};

var contexts: [MAX_CONTEXTS]LdpCtx = [_]LdpCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// ── Helpers ─────────────────────────────────────────────────────────────

/// Validate and return a pointer to an active context, or null.
fn getActive(slot: c_int) ?*LdpCtx {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return &contexts[idx];
}

// ── ABI version ─────────────────────────────────────────────────────────

/// ABI version — must match LdpABI.Foreign.abiVersion (currently 1).
pub export fn ldp_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new LDP resource context.
/// Returns slot index (0-63) or -1 if no slots available or invalid params.
pub export fn ldp_create(res_type: u8, container_type: u8, interaction: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    // Validate resource type (0-2)
    if (res_type > 2) return -1;
    // Validate container type (0-2)
    if (container_type > 2) return -1;
    // Validate interaction model (0-4)
    if (interaction > 4) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            ctx.resource_type = @enumFromInt(res_type);
            ctx.container_type = @enumFromInt(container_type);
            ctx.interaction = @enumFromInt(interaction);
            return @intCast(i);
        }
    }
    return -1; // all slots occupied
}

/// Destroy an LDP resource context, freeing its slot.
pub export fn ldp_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the ResourceType tag for a slot.
pub export fn ldp_get_resource_type(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.resource_type);
}

/// Get the ContainerType tag for a slot.
pub export fn ldp_get_container_type(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.container_type);
}

/// Get the InteractionModel tag for a slot.
pub export fn ldp_get_interaction_model(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.interaction);
}

/// Get the Preference tag for a slot.
pub export fn ldp_get_preference(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.preference);
}

/// Get the number of child resources.
pub export fn ldp_get_child_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.child_count;
}

/// Get the last LdpError tag, or 255 if no error.
pub export fn ldp_get_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 255;
    return ctx.last_error;
}

// ── Configuration setters ───────────────────────────────────────────────

/// Set the client preference for a resource.
pub export fn ldp_set_preference(slot: c_int, pref: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(LdpError.invalid_slot);

    if (pref > 4) {
        ctx.last_error = @intFromEnum(LdpError.invalid_preference);
        return @intFromEnum(LdpError.invalid_preference);
    }

    ctx.preference = @enumFromInt(pref);
    ctx.last_error = 255;
    return @intFromEnum(LdpError.ok);
}

/// Add a child resource to a container.
/// Resource must be of type Container (2). Returns LdpError tag.
pub export fn ldp_add_child(slot: c_int, child_type: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(LdpError.invalid_slot);

    // Only containers can have children
    if (ctx.resource_type != .container) {
        ctx.last_error = @intFromEnum(LdpError.type_conflict);
        return @intFromEnum(LdpError.type_conflict);
    }

    // Validate child type (0-2)
    if (child_type > 2) {
        ctx.last_error = @intFromEnum(LdpError.type_conflict);
        return @intFromEnum(LdpError.type_conflict);
    }

    if (ctx.child_count >= MAX_CHILDREN) {
        ctx.last_error = @intFromEnum(LdpError.capacity_exhausted);
        return @intFromEnum(LdpError.capacity_exhausted);
    }

    ctx.child_count += 1;
    ctx.last_error = 255;
    return @intFromEnum(LdpError.ok);
}

/// Check a constraint for a given operation type.
/// Returns ConstraintViolation tag if violated, or 255 if no violation.
pub export fn ldp_check_constraint(slot: c_int, op: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;

    // Operation 0 = modify membership: only Direct/Indirect containers allow
    if (op == 0 and ctx.container_type == .basic) {
        ctx.last_error = @intFromEnum(LdpError.constraint_violation);
        return @intFromEnum(ConstraintViolation.membership_constant);
    }

    // Operation 1 = modify containment triples: always server-managed
    if (op == 1) {
        ctx.last_error = @intFromEnum(LdpError.constraint_violation);
        return @intFromEnum(ConstraintViolation.contains_triples_modified);
    }

    // Operation 2 = modify server-managed props
    if (op == 2) {
        ctx.last_error = @intFromEnum(LdpError.constraint_violation);
        return @intFromEnum(ConstraintViolation.server_managed);
    }

    ctx.last_error = 255;
    return 255; // no violation
}
