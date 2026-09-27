// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// dns.zig -- Zig FFI implementation of proven-dns.
//
// Implements a bounded DNS state-machine/message-builder model with:
//   - 64-slot mutex-protected context pool
//   - A deliberately narrow root-question query subset
//   - Responses capped at 512 bytes and non-authoritative/non-recursive flags
//   - DNSSEC configuration state; key loading/signing/validation fail closed
//   - Thread-safe via per-slot mutex pool
// This is not a general resolver or a production DNSSEC implementation.

const std = @import("std");

// -- Enums (matching DNSABI.Layout.idr tag assignments) -----------------------

/// DNS record types (ABI tags 0-14, matching Layout.idr).
pub const RecordType = enum(u8) {
    a = 0,
    aaaa = 1,
    cname = 2,
    mx = 3,
    ns = 4,
    ptr = 5,
    soa = 6,
    srv = 7,
    txt = 8,
    caa = 9,
    dnskey = 10,
    ds = 11,
    rrsig = 12,
    nsec = 13,
    nsec3 = 14,
};

/// DNS query classes (ABI tags 0-3, matching Layout.idr).
pub const QueryClass = enum(u8) {
    in_ = 0,
    ch = 1,
    hs = 2,
    any = 3,
};

/// DNS opcodes (ABI tags 0-4, matching Layout.idr).
pub const Opcode = enum(u8) {
    query = 0,
    iquery = 1,
    status = 2,
    notify = 3,
    update = 4,
};

/// DNS response codes (ABI tags 0-10, matching Layout.idr).
pub const ResponseCode = enum(u8) {
    no_error = 0,
    form_err = 1,
    serv_fail = 2,
    nx_domain = 3,
    not_imp = 4,
    refused = 5,
    yx_domain = 6,
    yx_rrset = 7,
    nx_rrset = 8,
    not_auth = 9,
    not_zone = 10,
};

/// DNS lifecycle states (matching DNSABI.Transitions.idr).
pub const DnsState = enum(u8) {
    idle = 0,
    query_received = 1,
    lookup = 2,
    response_building = 3,
    sent = 4,
};

/// DNSSEC ABI/model tags; key loading, signing, and validation are unavailable.
pub const DnssecState = enum(u8) {
    disabled = 0,
    enabled = 1,
    key_loaded = 2,
    validated = 3,
};

/// DNSSEC signing algorithms (ABI tags 0-4, matching Layout.idr).
pub const DnssecAlgorithm = enum(u8) {
    rsa_sha256 = 0,
    rsa_sha512 = 1,
    ecdsa_p256_sha256 = 2,
    ecdsa_p384_sha384 = 3,
    ed25519 = 4,
};

// -- IANA wire code mapping ---------------------------------------------------

/// Map ABI record type tag to IANA wire type code.
pub fn recordTypeToWire(rtype: u8) u16 {
    return switch (rtype) {
        0 => 1, // A
        1 => 28, // AAAA
        2 => 5, // CNAME
        3 => 15, // MX
        4 => 2, // NS
        5 => 12, // PTR
        6 => 6, // SOA
        7 => 33, // SRV
        8 => 16, // TXT
        9 => 257, // CAA
        10 => 48, // DNSKEY
        11 => 43, // DS
        12 => 46, // RRSIG
        13 => 47, // NSEC
        14 => 50, // NSEC3
        else => 0, // invalid
    };
}

/// Map ABI query class tag to IANA wire class code.
pub fn queryClassToWire(qclass: u8) u16 {
    return switch (qclass) {
        0 => 1, // IN
        1 => 3, // CH
        2 => 4, // HS
        3 => 255, // ANY
        else => 0, // invalid
    };
}

// -- Resource record storage --------------------------------------------------

/// A single resource record stored in a context.
const ResourceRecord = struct {
    rtype: u8,
    rclass: u8,
    ttl: u32,
    rdlen: u16,
    rdata: [256]u8,
};

/// Maximum number of resource records per section (16).
/// Kept small to limit static memory footprint (64 contexts x 3 sections).
const MAX_RR_PER_SECTION: u16 = 16;

// -- DNS context --------------------------------------------------------------

/// A DNS query processing context.
const Context = struct {
    /// Current lifecycle state.
    state: DnsState,
    /// Current DNSSEC state.
    dnssec_state: DnssecState,
    /// Reserved ABI/model tag; this FFI never selects a cryptographic algorithm.
    dnssec_algo: u8,
    /// Response code.
    rcode: u8,
    /// Parsed query record type (ABI tag).
    query_rtype: u8,
    /// Parsed query class (ABI tag).
    query_class: u8,
    /// Recursion Desired bit copied from a supported query.
    recursion_desired: bool,
    /// Parsed query transaction ID.
    transaction_id: u16,
    /// Whether this slot is in use.
    active: bool,
    /// Answer section records.
    answers: [16]ResourceRecord,
    answer_count: u16,
    /// Authority section records.
    authorities: [16]ResourceRecord,
    authority_count: u16,
    /// Additional section records.
    additionals: [16]ResourceRecord,
    additional_count: u16,
};

const MAX_CONTEXTS: usize = 64;

/// The default (empty) resource record used for array initialisation.
const empty_rr: ResourceRecord = .{
    .rtype = 0,
    .rclass = 0,
    .ttl = 0,
    .rdlen = 0,
    .rdata = [_]u8{0} ** 256,
};

/// The default (empty) context used for array initialisation.
const empty_context: Context = .{
    .state = .idle,
    .dnssec_state = .disabled,
    .dnssec_algo = 255,
    .rcode = 0,
    .query_rtype = 255,
    .query_class = 255,
    .recursion_desired = false,
    .transaction_id = 0,
    .active = false,
    .answers = [_]ResourceRecord{empty_rr} ** 16,
    .answer_count = 0,
    .authorities = [_]ResourceRecord{empty_rr} ** 16,
    .authority_count = 0,
    .additionals = [_]ResourceRecord{empty_rr} ** 16,
    .additional_count = 0,
};

var contexts: [MAX_CONTEXTS]Context = [_]Context{empty_context} ** MAX_CONTEXTS;

/// Per-slot mutex pool for thread safety.
var mutexes: [MAX_CONTEXTS]std.Thread.Mutex = [_]std.Thread.Mutex{.{}} ** MAX_CONTEXTS;

/// Global mutex for slot allocation/deallocation.
var global_mutex: std.Thread.Mutex = .{};

/// Validate and return the slot index, or null if invalid/inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return idx;
}

// -- ABI version --------------------------------------------------------------

pub export fn dns_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

pub export fn dns_create_context() callconv(.c) c_int {
    global_mutex.lock();
    defer global_mutex.unlock();
    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_context;
            ctx.active = true;
            return @intCast(i);
        }
    }
    return -1; // no free slots
}

pub export fn dns_destroy_context(slot: c_int) callconv(.c) void {
    global_mutex.lock();
    defer global_mutex.unlock();
    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// -- State queries ------------------------------------------------------------

pub export fn dns_state(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 4; // sent as fallback
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return @intFromEnum(contexts[idx].state);
}

pub export fn dns_dnssec_state(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 0; // disabled fallback
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return @intFromEnum(contexts[idx].dnssec_state);
}

pub export fn dns_rcode(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 2; // servfail fallback
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].rcode;
}

pub export fn dns_answer_count(slot: c_int) callconv(.c) u16 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].answer_count;
}

pub export fn dns_authority_count(slot: c_int) callconv(.c) u16 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].authority_count;
}

pub export fn dns_additional_count(slot: c_int) callconv(.c) u16 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].additional_count;
}

pub export fn dns_query_rtype(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 255;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].query_rtype;
}

pub export fn dns_query_class(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 255;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].query_class;
}

// -- Lifecycle transitions ----------------------------------------------------

/// Parse only an exact 17-byte standard request (QR=0, OPCODE=QUERY) with
/// one root-name question, a recognized type/class, no other sections, and RD
/// as its only set flag.
/// Other packets are rejected because this context does not retain arbitrary
/// QNAMEs or EDNS data. Transitions: Idle -> QueryReceived on valid input.
pub export fn dns_parse_query(slot: c_int, buf: ?[*]const u8, len: u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].state != .idle) return 1;
    if (len != 17) return 1;
    const data = buf orelse return 1;

    // Accept only a standard query (QR=0, opcode=QUERY), optionally RD=1.
    if ((data[2] & 0xFE) != 0 or data[3] != 0) return 1;
    if (data[4] != 0 or data[5] != 1) return 1; // exactly one question
    for (data[6..12]) |section_count| {
        if (section_count != 0) return 1; // unsupported response/additional sections
    }
    if (data[12] != 0) return 1; // only the root QNAME is retained/encoded

    const wire_type: u16 = (@as(u16, data[13]) << 8) | @as(u16, data[14]);
    const wire_class: u16 = (@as(u16, data[15]) << 8) | @as(u16, data[16]);
    const query_type = wireTypeToAbiTag(wire_type);
    const query_class = wireClassToAbiTag(wire_class);
    if (query_type == 255 or query_class == 255) return 1;

    // Commit parsed data only after the entire minimal packet is validated.
    contexts[idx].transaction_id = (@as(u16, data[0]) << 8) | @as(u16, data[1]);
    contexts[idx].recursion_desired = (data[2] & 1) != 0;
    contexts[idx].query_rtype = query_type;
    contexts[idx].query_class = query_class;
    contexts[idx].state = .query_received;
    return 0;
}

/// Transition from QueryReceived to Lookup.
pub export fn dns_begin_lookup(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].state != .query_received) return 1;
    contexts[idx].state = .lookup;
    return 0;
}

/// Transition from Lookup to ResponseBuilding.
pub export fn dns_begin_response(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].state != .lookup) return 1;
    contexts[idx].state = .response_building;
    return 0;
}

// -- Record addition ----------------------------------------------------------

/// Add a resource record to the answer section.
/// Only valid in ResponseBuilding state.
pub export fn dns_add_answer(slot: c_int, rtype: u8, rclass: u8, ttl: u32, rdata: ?[*]const u8, rdlen: u16) callconv(.c) u8 {
    return addRecord(slot, .answer, rtype, rclass, ttl, rdata, rdlen);
}

/// Add a resource record to the authority section.
pub export fn dns_add_authority(slot: c_int, rtype: u8, rclass: u8, ttl: u32, rdata: ?[*]const u8, rdlen: u16) callconv(.c) u8 {
    return addRecord(slot, .authority, rtype, rclass, ttl, rdata, rdlen);
}

/// Add a resource record to the additional section.
pub export fn dns_add_additional(slot: c_int, rtype: u8, rclass: u8, ttl: u32, rdata: ?[*]const u8, rdlen: u16) callconv(.c) u8 {
    return addRecord(slot, .additional, rtype, rclass, ttl, rdata, rdlen);
}

const Section = enum { answer, authority, additional };

fn addRecord(slot: c_int, section: Section, rtype: u8, rclass: u8, ttl: u32, rdata: ?[*]const u8, rdlen: u16) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();

    if (contexts[idx].state != .response_building) return 1;
    if (rtype > 14) return 1; // invalid ABI record type tag
    if (rclass > 3) return 1; // invalid ABI query class tag
    if (rdlen > 256) return 1; // rdata too large
    if (rdlen > 0 and rdata == null) return 1; // non-empty rdata requires a pointer

    var rr: ResourceRecord = empty_rr;
    rr.rtype = rtype;
    rr.rclass = rclass;
    rr.ttl = ttl;
    rr.rdlen = rdlen;

    if (rdata) |d| {
        @memcpy(rr.rdata[0..rdlen], d[0..rdlen]);
    }

    switch (section) {
        .answer => {
            if (contexts[idx].answer_count >= 16) return 1;
            contexts[idx].answers[contexts[idx].answer_count] = rr;
            contexts[idx].answer_count += 1;
        },
        .authority => {
            if (contexts[idx].authority_count >= 16) return 1;
            contexts[idx].authorities[contexts[idx].authority_count] = rr;
            contexts[idx].authority_count += 1;
        },
        .additional => {
            if (contexts[idx].additional_count >= 16) return 1;
            contexts[idx].additionals[contexts[idx].additional_count] = rr;
            contexts[idx].additional_count += 1;
        },
    }
    return 0;
}

/// Set the response code (only valid in ResponseBuilding state).
pub export fn dns_set_rcode(slot: c_int, rcode_tag: u8) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].state != .response_building) return 1;
    if (rcode_tag > 10) return 1; // invalid ABI response code tag
    contexts[idx].rcode = rcode_tag;
    return 0;
}

// -- Response building --------------------------------------------------------

/// Build a DNS response message into the provided buffer.
/// Transitions: ResponseBuilding -> Sent.
/// The output buffer must be at least 512 bytes. Responses exceeding that
/// limit are rejected before writing any bytes. DNSSEC-enabled contexts are
/// rejected because no signer is available; unsigned operation remains usable.
/// On success, out_len is set to the actual message length.
pub export fn dns_build_response(slot: c_int, out: ?[*]u8, out_len: ?*u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].state != .response_building) return 1;

    const buf = out orelse return 1;
    const len_ptr = out_len orelse return 1;
    len_ptr.* = 0;

    // DNSSEC was requested, but this implementation cannot produce or verify
    // signatures. Never send an unsigned response under an enabled DNSSEC state.
    if (contexts[idx].dnssec_state != .disabled) return 1;
    if (responseLength(&contexts[idx]) > 512) return 1;

    var offset: usize = 0;

    // -- DNS Header (12 bytes) --
    // Transaction ID
    buf[0] = @truncate(contexts[idx].transaction_id >> 8);
    buf[1] = @truncate(contexts[idx].transaction_id);
    // QR=1, standard opcode, AA=0, TC=0, echo RD; RA=0 because recursion
    // is not implemented. Do not claim authority or recursive service.
    buf[2] = 0x80 | @as(u8, if (contexts[idx].recursion_desired) 1 else 0);
    buf[3] = contexts[idx].rcode & 0x0F; // RA=0, Z=0, RCODE
    // QDCOUNT = 1 (echo back the question)
    buf[4] = 0;
    buf[5] = 1;
    // ANCOUNT
    buf[6] = @truncate(contexts[idx].answer_count >> 8);
    buf[7] = @truncate(contexts[idx].answer_count);
    // NSCOUNT
    buf[8] = @truncate(contexts[idx].authority_count >> 8);
    buf[9] = @truncate(contexts[idx].authority_count);
    // ARCOUNT
    buf[10] = @truncate(contexts[idx].additional_count >> 8);
    buf[11] = @truncate(contexts[idx].additional_count);
    offset = 12;

    // -- Question section (minimal: root name + qtype + qclass) --
    buf[offset] = 0; // root name (single zero byte)
    offset += 1;
    const wire_type = recordTypeToWire(contexts[idx].query_rtype);
    buf[offset] = @truncate(wire_type >> 8);
    buf[offset + 1] = @truncate(wire_type);
    offset += 2;
    const wire_class = queryClassToWire(contexts[idx].query_class);
    buf[offset] = @truncate(wire_class >> 8);
    buf[offset + 1] = @truncate(wire_class);
    offset += 2;

    // -- Answer section --
    offset = writeSection(buf, offset, &contexts[idx].answers, contexts[idx].answer_count);
    // -- Authority section --
    offset = writeSection(buf, offset, &contexts[idx].authorities, contexts[idx].authority_count);
    // -- Additional section --
    offset = writeSection(buf, offset, &contexts[idx].additionals, contexts[idx].additional_count);

    len_ptr.* = @intCast(offset);
    contexts[idx].state = .sent;
    return 0;
}

/// Calculate the uncompressed wire length before writing to the caller's
/// fixed-minimum (512-byte) output buffer.
fn responseLength(ctx: *const Context) usize {
    return 17 + sectionWireLength(&ctx.answers, ctx.answer_count) +
        sectionWireLength(&ctx.authorities, ctx.authority_count) +
        sectionWireLength(&ctx.additionals, ctx.additional_count);
}

fn sectionWireLength(records: *const [16]ResourceRecord, count: u16) usize {
    var length: usize = 0;
    var i: usize = 0;
    while (i < count) : (i += 1) {
        // Root owner name (1), TYPE (2), CLASS (2), TTL (4), RDLENGTH (2), RDATA.
        length += 11 + @as(usize, records[i].rdlen);
    }
    return length;
}

/// Write a section of resource records into the output buffer.
fn writeSection(buf: [*]u8, start_offset: usize, records: *const [16]ResourceRecord, count: u16) usize {
    var offset = start_offset;
    var i: usize = 0;
    while (i < count) : (i += 1) {
        const rr = records[i];
        // Name: root (single zero byte) — simplified encoding
        buf[offset] = 0;
        offset += 1;
        // TYPE (2 bytes)
        const wt = recordTypeToWire(rr.rtype);
        buf[offset] = @truncate(wt >> 8);
        buf[offset + 1] = @truncate(wt);
        offset += 2;
        // CLASS (2 bytes)
        const wc = queryClassToWire(rr.rclass);
        buf[offset] = @truncate(wc >> 8);
        buf[offset + 1] = @truncate(wc);
        offset += 2;
        // TTL (4 bytes, big-endian)
        buf[offset] = @truncate(rr.ttl >> 24);
        buf[offset + 1] = @truncate(rr.ttl >> 16);
        buf[offset + 2] = @truncate(rr.ttl >> 8);
        buf[offset + 3] = @truncate(rr.ttl);
        offset += 4;
        // RDLENGTH (2 bytes)
        buf[offset] = @truncate(rr.rdlen >> 8);
        buf[offset + 1] = @truncate(rr.rdlen);
        offset += 2;
        // RDATA
        @memcpy(buf[offset .. offset + rr.rdlen], rr.rdata[0..rr.rdlen]);
        offset += rr.rdlen;
    }
    return offset;
}

// -- DNSSEC operations --------------------------------------------------------

/// Mark DNSSEC mode requested. No crypto backend exists; response building fails closed.
/// Transitions: DnssecDisabled -> DnssecEnabled.
pub export fn dns_enable_dnssec(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].dnssec_state != .disabled) return 1;
    contexts[idx].dnssec_state = .enabled;
    return 0;
}

/// Load a DNSSEC signing key. This ABI accepts only an algorithm tag, not
/// private-key material, so it cannot load a key and always rejects.
pub export fn dns_load_dnssec_key(slot: c_int, algo: u8) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].dnssec_state != .enabled or algo > 4) return 1;
    return 1; // No private key bytes or key-management backend are provided.
}

/// Sign the response (DNSSEC). No signing backend is present, so a key tag or
/// state transition is never treated as evidence of a generated signature.
pub export fn dns_sign_response(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].dnssec_state != .key_loaded) return 1;
    if (contexts[idx].state != .response_building) return 1;
    return 1;
}

/// Check DNSSEC validation result. No DNSSEC validator is available.
pub export fn dns_validate_dnssec(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return 1;
}

// -- Stateless transition checks ----------------------------------------------

/// Check whether a DNS lifecycle state transition is valid.
/// Matches DNSABI.Transitions.validateDnsTransition exactly.
pub export fn dns_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> QueryReceived
    if (from == 1 and to == 2) return 1; // QueryReceived -> Lookup
    if (from == 2 and to == 3) return 1; // Lookup -> ResponseBuilding
    if (from == 3 and to == 4) return 1; // ResponseBuilding -> Sent
    // Abort edges
    if (from == 0 and to == 4) return 1; // Idle -> Sent
    if (from == 1 and to == 4) return 1; // QueryReceived -> Sent
    if (from == 2 and to == 4) return 1; // Lookup -> Sent
    return 0;
}

/// Check the abstract DNSSEC state model only; this does not imply that crypto is available.
/// Matches DNSABI.Transitions.validateDnssecTransition exactly.
pub export fn dns_can_dnssec_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Disabled -> Enabled
    if (from == 1 and to == 2) return 1; // Enabled -> KeyLoaded
    if (from == 2 and to == 3) return 1; // KeyLoaded -> Validated
    return 0;
}

// -- Wire code to ABI tag helpers (internal) ----------------------------------

fn wireTypeToAbiTag(wire: u16) u8 {
    return switch (wire) {
        1 => 0, // A
        28 => 1, // AAAA
        5 => 2, // CNAME
        15 => 3, // MX
        2 => 4, // NS
        12 => 5, // PTR
        6 => 6, // SOA
        33 => 7, // SRV
        16 => 8, // TXT
        257 => 9, // CAA
        48 => 10, // DNSKEY
        43 => 11, // DS
        46 => 12, // RRSIG
        47 => 13, // NSEC
        50 => 14, // NSEC3
        else => 255, // unknown
    };
}

fn wireClassToAbiTag(wire: u16) u8 {
    return switch (wire) {
        1 => 0, // IN
        3 => 1, // CH
        4 => 2, // HS
        255 => 3, // ANY
        else => 255, // unknown
    };
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(contexts)) > 16 * 1024 * 1024)
        @compileError("pool 'contexts' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
comptime {
    if (@sizeOf(@TypeOf(mutexes)) > 16 * 1024 * 1024)
        @compileError("pool 'mutexes' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
