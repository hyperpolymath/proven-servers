// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// dns.zig -- Zig FFI implementation of proven-dns.
//
// Implements the verified DNS query lifecycle state machine with:
//   - 64-slot mutex-protected context pool
//   - State machine enforcement matching Idris2 DNSABI.Transitions.idr
//   - DNS message builder (header + question + answer + authority + additional)
//   - Record type encoding (ABI tags <-> IANA wire codes)
//   - DNSSEC state machine (enable, key load, sign/validate)
//   - Thread-safe via per-slot mutex pool

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

/// DNSSEC states (matching DNSABI.Transitions.idr).
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
    /// DNSSEC algorithm (valid when key_loaded or validated).
    dnssec_algo: u8,
    /// Response code.
    rcode: u8,
    /// Parsed query record type (ABI tag).
    query_rtype: u8,
    /// Parsed query class (ABI tag).
    query_class: u8,
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

/// Parse a DNS query from a raw buffer.
/// Transitions: Idle -> QueryReceived.
/// The buffer must contain at least a 12-byte DNS header.
pub export fn dns_parse_query(slot: c_int, buf: ?[*]const u8, len: u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].state != .idle) return 1;

    // Minimum DNS header is 12 bytes
    if (len < 12) return 1;
    const data = buf orelse return 1;

    // Parse transaction ID (bytes 0-1, big-endian)
    contexts[idx].transaction_id = (@as(u16, data[0]) << 8) | @as(u16, data[1]);

    // Parse opcode from flags byte (byte 2, bits 1-4)
    // We store but don't validate opcode here — the ABI tag check is in Layout.idr

    // If we have a question section (bytes 4-5 > 0), try to extract qtype and qclass
    const qdcount: u16 = (@as(u16, data[4]) << 8) | @as(u16, data[5]);
    if (qdcount > 0 and len > 12) {
        // Skip the QNAME (series of length-prefixed labels ending with 0)
        var offset: usize = 12;
        while (offset < len) {
            const label_len = data[offset];
            offset += 1;
            if (label_len == 0) break;
            offset += label_len;
        }
        // Read QTYPE (2 bytes) and QCLASS (2 bytes) if available
        if (offset + 4 <= len) {
            const wire_type: u16 = (@as(u16, data[offset]) << 8) | @as(u16, data[offset + 1]);
            const wire_class: u16 = (@as(u16, data[offset + 2]) << 8) | @as(u16, data[offset + 3]);
            contexts[idx].query_rtype = wireTypeToAbiTag(wire_type);
            contexts[idx].query_class = wireClassToAbiTag(wire_class);
        }
    }

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
/// The output buffer must be at least 512 bytes.
/// On success, out_len is set to the actual message length.
pub export fn dns_build_response(slot: c_int, out: ?[*]u8, out_len: ?*u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].state != .response_building) return 1;

    const buf = out orelse return 1;
    const len_ptr = out_len orelse return 1;

    var offset: usize = 0;

    // -- DNS Header (12 bytes) --
    // Transaction ID
    buf[0] = @truncate(contexts[idx].transaction_id >> 8);
    buf[1] = @truncate(contexts[idx].transaction_id);
    // Flags: QR=1, Opcode=0, AA=1, TC=0, RD=1, RA=1, Z=0, RCODE
    buf[2] = 0x85; // 1_0000_1_0_1 = QR=1, Opcode=0, AA=1, TC=0, RD=1
    buf[3] = 0x80 | (contexts[idx].rcode & 0x0F); // RA=1, Z=0, RCODE
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

/// Enable DNSSEC on a context.
/// Transitions: DnssecDisabled -> DnssecEnabled.
pub export fn dns_enable_dnssec(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].dnssec_state != .disabled) return 1;
    contexts[idx].dnssec_state = .enabled;
    return 0;
}

/// Load a DNSSEC signing key.
/// Transitions: DnssecEnabled -> DnssecKeyLoaded.
pub export fn dns_load_dnssec_key(slot: c_int, algo: u8) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].dnssec_state != .enabled) return 1;
    if (algo > 4) return 1; // invalid DNSSEC algorithm tag
    contexts[idx].dnssec_algo = algo;
    contexts[idx].dnssec_state = .key_loaded;
    return 0;
}

/// Sign the response (DNSSEC).
/// Transitions: DnssecKeyLoaded -> DnssecValidated.
/// Only valid when lifecycle state is ResponseBuilding.
pub export fn dns_sign_response(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].dnssec_state != .key_loaded) return 1;
    if (contexts[idx].state != .response_building) return 1;
    contexts[idx].dnssec_state = .validated;
    return 0;
}

/// Check DNSSEC validation result.
pub export fn dns_validate_dnssec(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return if (contexts[idx].dnssec_state == .validated) 0 else 1;
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

/// Check whether a DNSSEC state transition is valid.
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
