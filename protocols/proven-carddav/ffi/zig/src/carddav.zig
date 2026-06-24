// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// carddav.zig -- Zig FFI implementation of proven-carddav.
//
// Implements the CardDAV (RFC 6352) server state machine with:
//   - 64-slot mutex-protected server pool
//   - Address book collection management (max 16 per server)
//   - vCard resource storage per address book (max 128 per book)
//   - UID uniqueness enforcement per address book
//   - ETag tracking for conditional requests
//   - vCard version validation (3.0 or 4.0)
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching CardDAVABI.Types.idr exactly.

const std = @import("std");

// Generated from the proven Idris ABI encoders by tools/gen-abi.sh; the
// comptime guard below pins every enum tag to these, so drift is a build error.
const gen = @import("carddav_abi_gen.zig");

/// ABI version (guarded against gen.ABI_VERSION below).
const ABI_VERSION: u32 = 1;

// =========================================================================
// Enums (matching CardDAVABI.Types.idr tag assignments)
// =========================================================================

/// vCard property types (ABI tags 0-8).
pub const PropertyType = enum(u8) {
    fn_name = 0,
    n = 1,
    email = 2,
    tel = 3,
    adr = 4,
    org = 5,
    photo = 6,
    url = 7,
    note = 8,
};

/// CardDAV request methods (ABI tags 0-6).
pub const CardMethod = enum(u8) {
    get = 0,
    put = 1,
    delete = 2,
    propfind = 3,
    proppatch = 4,
    report = 5,
    mkcol = 6,
};

/// vCard versions (ABI tags 0-1).
pub const VCardVersion = enum(u8) {
    vcard3 = 0,
    vcard4 = 1,
};

/// CardDAV error conditions (ABI tags 0-5).
pub const CardError = enum(u8) {
    valid_address_data = 0,
    no_resource_type = 1,
    max_resource_size = 2,
    uid_conflict = 3,
    supported_address_data = 4,
    precondition_failed = 5,
};

/// CardDAV server lifecycle states (ABI tags 0-3).
pub const ServerState = enum(u8) {
    idle = 0,
    bound = 1,
    serving = 2,
    shutdown = 3,
};

// ── ABI conformance guard ────────────────────────────────────────────────
// Every enum tag MUST equal the generated (= proven Idris) value; a mismatch
// fails `zig build` with the named symbol. Regenerate: bash tools/gen-abi.sh.
comptime {
    if (ABI_VERSION != gen.ABI_VERSION) @compileError("ABI drift: abi_version");

    if (@intFromEnum(PropertyType.fn_name) != gen.PROP_FN) @compileError("ABI drift: PropertyType.fn_name");
    if (@intFromEnum(PropertyType.n) != gen.PROP_N) @compileError("ABI drift: PropertyType.n");
    if (@intFromEnum(PropertyType.email) != gen.PROP_EMAIL) @compileError("ABI drift: PropertyType.email");
    if (@intFromEnum(PropertyType.tel) != gen.PROP_TEL) @compileError("ABI drift: PropertyType.tel");
    if (@intFromEnum(PropertyType.adr) != gen.PROP_ADR) @compileError("ABI drift: PropertyType.adr");
    if (@intFromEnum(PropertyType.org) != gen.PROP_ORG) @compileError("ABI drift: PropertyType.org");
    if (@intFromEnum(PropertyType.photo) != gen.PROP_PHOTO) @compileError("ABI drift: PropertyType.photo");
    if (@intFromEnum(PropertyType.url) != gen.PROP_URL) @compileError("ABI drift: PropertyType.url");
    if (@intFromEnum(PropertyType.note) != gen.PROP_NOTE) @compileError("ABI drift: PropertyType.note");

    if (@intFromEnum(CardMethod.get) != gen.METHOD_GET) @compileError("ABI drift: CardMethod.get");
    if (@intFromEnum(CardMethod.put) != gen.METHOD_PUT) @compileError("ABI drift: CardMethod.put");
    if (@intFromEnum(CardMethod.delete) != gen.METHOD_DELETE) @compileError("ABI drift: CardMethod.delete");
    if (@intFromEnum(CardMethod.propfind) != gen.METHOD_PROPFIND) @compileError("ABI drift: CardMethod.propfind");
    if (@intFromEnum(CardMethod.proppatch) != gen.METHOD_PROPPATCH) @compileError("ABI drift: CardMethod.proppatch");
    if (@intFromEnum(CardMethod.report) != gen.METHOD_REPORT) @compileError("ABI drift: CardMethod.report");
    if (@intFromEnum(CardMethod.mkcol) != gen.METHOD_MKCOL) @compileError("ABI drift: CardMethod.mkcol");

    if (@intFromEnum(VCardVersion.vcard3) != gen.VER_VCARD3) @compileError("ABI drift: VCardVersion.vcard3");
    if (@intFromEnum(VCardVersion.vcard4) != gen.VER_VCARD4) @compileError("ABI drift: VCardVersion.vcard4");

    if (@intFromEnum(CardError.valid_address_data) != gen.ERR_VALID_ADDRESS_DATA) @compileError("ABI drift: CardError.valid_address_data");
    if (@intFromEnum(CardError.no_resource_type) != gen.ERR_NO_RESOURCE_TYPE) @compileError("ABI drift: CardError.no_resource_type");
    if (@intFromEnum(CardError.max_resource_size) != gen.ERR_MAX_RESOURCE_SIZE) @compileError("ABI drift: CardError.max_resource_size");
    if (@intFromEnum(CardError.uid_conflict) != gen.ERR_UID_CONFLICT) @compileError("ABI drift: CardError.uid_conflict");
    if (@intFromEnum(CardError.supported_address_data) != gen.ERR_SUPPORTED_ADDRESS_DATA) @compileError("ABI drift: CardError.supported_address_data");
    if (@intFromEnum(CardError.precondition_failed) != gen.ERR_PRECONDITION_FAILED) @compileError("ABI drift: CardError.precondition_failed");

    if (@intFromEnum(ServerState.idle) != gen.STATE_IDLE) @compileError("ABI drift: ServerState.idle");
    if (@intFromEnum(ServerState.bound) != gen.STATE_BOUND) @compileError("ABI drift: ServerState.bound");
    if (@intFromEnum(ServerState.serving) != gen.STATE_SERVING) @compileError("ABI drift: ServerState.serving");
    if (@intFromEnum(ServerState.shutdown) != gen.STATE_SHUTDOWN) @compileError("ABI drift: ServerState.shutdown");
}

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent servers.
const MAX_SERVERS: usize = 64;

/// Maximum address books per server.
const MAX_ADDRESSBOOKS: usize = 16;

/// Maximum vCards per address book.
const MAX_VCARDS: usize = 32;

/// Maximum path/UID length in bytes.
const MAX_NAME_LEN: usize = 128;

/// A vCard resource.
const VCard = struct {
    /// Unique identifier (UID property from vCard).
    uid: [MAX_NAME_LEN]u8,
    uid_len: u32,
    /// vCard version tag.
    version: u8,
    /// ETag for conditional requests.
    etag: u32,
    /// Whether this vCard slot is active.
    active: bool,
};

/// An address book collection.
const AddressBook = struct {
    /// Collection path (e.g., "/addressbooks/contacts").
    path: [MAX_NAME_LEN]u8,
    path_len: u32,
    /// vCard resources.
    vcards: [MAX_VCARDS]VCard,
    /// Number of active vCards.
    vcard_count: u32,
    /// Whether this address book slot is active.
    active: bool,
};

/// A CardDAV server instance.
const Server = struct {
    /// Current server lifecycle state.
    state: ServerState,
    /// Bound HTTP port.
    port: u16,
    /// Address book collections.
    addressbooks: [MAX_ADDRESSBOOKS]AddressBook,
    /// Number of active address books.
    addressbook_count: u32,
    /// Whether this server slot is in use.
    active: bool,
};

/// Default (empty) vCard.
const empty_vcard: VCard = .{
    .uid = [_]u8{0} ** MAX_NAME_LEN,
    .uid_len = 0,
    .version = 1, // vCard 4.0 by default
    .etag = 0,
    .active = false,
};

/// Default (empty) address book.
const empty_addressbook: AddressBook = .{
    .path = [_]u8{0} ** MAX_NAME_LEN,
    .path_len = 0,
    .vcards = [_]VCard{empty_vcard} ** MAX_VCARDS,
    .vcard_count = 0,
    .active = false,
};

/// Default (empty) server.
const empty_server: Server = .{
    .state = .idle,
    .port = 0,
    .addressbooks = [_]AddressBook{empty_addressbook} ** MAX_ADDRESSBOOKS,
    .addressbook_count = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var servers: [MAX_SERVERS]Server = [_]Server{empty_server} ** MAX_SERVERS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SERVERS) return null;
    const idx: usize = @intCast(slot);
    if (!servers[idx].active) return null;
    return idx;
}

/// Find an address book by path within a server.
fn findAddressBook(idx: usize, path: []const u8) ?usize {
    for (&servers[idx].addressbooks, 0..) |*ab, i| {
        if (ab.active and ab.path_len == path.len and
            std.mem.eql(u8, ab.path[0..ab.path_len], path))
        {
            return i;
        }
    }
    return null;
}

/// Find a vCard by UID within an address book.
fn findVCard(idx: usize, abi: usize, uid: []const u8) ?usize {
    for (&servers[idx].addressbooks[abi].vcards, 0..) |*v, i| {
        if (v.active and v.uid_len == uid.len and
            std.mem.eql(u8, v.uid[0..v.uid_len], uid))
        {
            return i;
        }
    }
    return null;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

/// Returns the ABI version number.
pub export fn carddav_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
}

/// Create a new CardDAV server. Returns slot index (>=0) or -1 on failure.
pub export fn carddav_create(port: u16) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (port == 0) return -1;

    for (&servers, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_server;
            s.port = port;
            s.state = .bound;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a server, releasing its slot.
pub export fn carddav_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SERVERS) return;
    servers[@intCast(slot)] = empty_server;
}

/// Returns the current ServerState tag.
pub export fn carddav_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(servers[idx].state);
}

/// Create an address book collection. Returns 0 on success, 1 on rejection.
pub export fn carddav_create_addressbook(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = servers[idx].state;
    if (state != .bound and state != .serving) return 1;
    if (path_len == 0 or path_len > MAX_NAME_LEN) return 1;

    const path = path_ptr[0..path_len];
    if (findAddressBook(idx, path) != null) return 1;

    for (&servers[idx].addressbooks) |*ab| {
        if (!ab.active) {
            ab.* = empty_addressbook;
            @memcpy(ab.path[0..path_len], path);
            ab.path_len = path_len;
            ab.active = true;
            servers[idx].addressbook_count += 1;
            if (servers[idx].state == .bound) {
                servers[idx].state = .serving;
            }
            return 0;
        }
    }
    return 1;
}

/// Delete an address book. Returns 0 on success, 1 on rejection.
pub export fn carddav_delete_addressbook(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (path_len == 0 or path_len > MAX_NAME_LEN) return 1;

    const path = path_ptr[0..path_len];
    const abi = findAddressBook(idx, path) orelse return 1;

    servers[idx].addressbooks[abi] = empty_addressbook;
    servers[idx].addressbook_count -= 1;

    if (servers[idx].addressbook_count == 0 and servers[idx].state == .serving) {
        servers[idx].state = .bound;
    }

    return 0;
}

/// Returns the number of address book collections.
pub export fn carddav_addressbook_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return servers[idx].addressbook_count;
}

/// Put (create/update) a vCard resource. Returns 0 on success, 1 on rejection.
pub export fn carddav_put_vcard(
    slot: c_int,
    ab_path_ptr: [*]const u8,
    ab_path_len: u32,
    uid_ptr: [*]const u8,
    uid_len: u32,
    version: u8,
    etag: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (servers[idx].state != .serving) return 1;
    if (ab_path_len == 0 or ab_path_len > MAX_NAME_LEN) return 1;
    if (uid_len == 0 or uid_len > MAX_NAME_LEN) return 1;
    if (version > 1) return 1; // Only vCard 3.0 (0) and 4.0 (1) supported

    const ab_path = ab_path_ptr[0..ab_path_len];
    const abi = findAddressBook(idx, ab_path) orelse return 1;

    const uid = uid_ptr[0..uid_len];

    // Check for existing vCard with same UID (update case)
    if (findVCard(idx, abi, uid)) |vi| {
        servers[idx].addressbooks[abi].vcards[vi].version = version;
        servers[idx].addressbooks[abi].vcards[vi].etag = etag;
        return 0;
    }

    // Find a free vCard slot (create case)
    for (&servers[idx].addressbooks[abi].vcards) |*v| {
        if (!v.active) {
            @memcpy(v.uid[0..uid_len], uid);
            v.uid_len = uid_len;
            v.version = version;
            v.etag = etag;
            v.active = true;
            servers[idx].addressbooks[abi].vcard_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Delete a vCard resource. Returns 0 on success, 1 on rejection.
pub export fn carddav_delete_vcard(
    slot: c_int,
    ab_path_ptr: [*]const u8,
    ab_path_len: u32,
    uid_ptr: [*]const u8,
    uid_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (ab_path_len == 0 or ab_path_len > MAX_NAME_LEN) return 1;
    if (uid_len == 0 or uid_len > MAX_NAME_LEN) return 1;

    const ab_path = ab_path_ptr[0..ab_path_len];
    const abi = findAddressBook(idx, ab_path) orelse return 1;

    const uid = uid_ptr[0..uid_len];
    const vi = findVCard(idx, abi, uid) orelse return 1;

    servers[idx].addressbooks[abi].vcards[vi] = empty_vcard;
    servers[idx].addressbooks[abi].vcard_count -= 1;

    return 0;
}

/// Returns the number of vCards in an address book.
pub export fn carddav_vcard_count(
    slot: c_int,
    ab_path_ptr: [*]const u8,
    ab_path_len: u32,
) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;
    if (ab_path_len == 0 or ab_path_len > MAX_NAME_LEN) return 0;

    const ab_path = ab_path_ptr[0..ab_path_len];
    const abi = findAddressBook(idx, ab_path) orelse return 0;

    return servers[idx].addressbooks[abi].vcard_count;
}

/// Returns total vCards across all address books.
pub export fn carddav_total_vcards(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;
    var total: u32 = 0;
    for (&servers[idx].addressbooks) |*ab| {
        if (ab.active) {
            total += ab.vcard_count;
        }
    }
    return total;
}

/// Shutdown the server. Returns 0 on success, 1 on rejection.
pub export fn carddav_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = servers[idx].state;
    if (state == .bound or state == .serving) {
        servers[idx].state = .shutdown;
        return 0;
    }
    return 1;
}

/// Complete cleanup after shutdown. Returns 0 on success, 1 on rejection.
pub export fn carddav_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (servers[idx].state != .shutdown) return 1;

    servers[idx].state = .idle;
    servers[idx].addressbooks = [_]AddressBook{empty_addressbook} ** MAX_ADDRESSBOOKS;
    servers[idx].addressbook_count = 0;

    return 0;
}

/// Check if a server state transition is valid.
pub export fn carddav_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Bound
    if (from == 1 and to == 2) return 1; // Bound -> Serving
    if (from == 2 and to == 2) return 1; // Serving -> Serving
    if (from == 2 and to == 1) return 1; // Serving -> Bound
    if (from == 1 and to == 3) return 1; // Bound -> Shutdown
    if (from == 2 and to == 3) return 1; // Serving -> Shutdown
    if (from == 3 and to == 0) return 1; // Shutdown -> Idle
    return 0;
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(servers)) > 16 * 1024 * 1024)
        @compileError("pool 'servers' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
