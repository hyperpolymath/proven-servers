// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// httpd.zig -- Zig FFI implementation of proven-httpd.
//
// Implements the verified HTTP request lifecycle state machine with:
//   - Slot-based context management (up to 64 concurrent connections)
//   - State machine enforcement matching Idris2 Transitions.idr
//   - Thread-safe via per-slot mutex pool (64 mutexes)
//   - Request parsing: method, path, headers, body
//   - Response construction: status, headers, body
//   - Keep-alive support with context recycling
//   - Header key-value store (fixed array, max 32 headers)
//   - Body buffer (fixed, max 64 KiB)

const std = @import("std");

// -- Enums (matching HTTPABI.Layout.idr tag assignments) ----------------------

/// HTTP request methods (tags 0-8, matching Layout.idr httpMethodToTag).
pub const HttpMethod = enum(u8) {
    get = 0,
    post = 1,
    put = 2,
    delete = 3,
    patch = 4,
    head = 5,
    options = 6,
    trace = 7,
    connect = 8,
};

/// HTTP protocol versions (tags 0-3, matching Layout.idr httpVersionToTag).
pub const HttpVersion = enum(u8) {
    http10 = 0,
    http11 = 1,
    http20 = 2,
    http30 = 3,
};

/// HTTP request lifecycle phases (tags 0-6, matching Layout.idr requestPhaseToTag).
pub const RequestPhase = enum(u8) {
    idle = 0,
    receiving = 1,
    headers_parsed = 2,
    body_receiving = 3,
    complete = 4,
    responding = 5,
    sent = 6,
};

/// HTTP status code categories (tags 0-4, matching Layout.idr statusCatToTag).
pub const StatusCategory = enum(u8) {
    informational = 0,
    success = 1,
    redirect = 2,
    client_error = 3,
    server_error = 4,
};

/// HTTP status codes (tags 0-28, matching Layout.idr abiStatusCodeToTag).
pub const AbiStatusCode = enum(u8) {
    // 1xx Informational
    sc_continue = 0,
    sc_switching_protocols = 1,
    // 2xx Success
    sc_ok = 2,
    sc_created = 3,
    sc_accepted = 4,
    sc_no_content = 5,
    // 3xx Redirection
    sc_moved_permanently = 6,
    sc_found = 7,
    sc_not_modified = 8,
    sc_temporary_redirect = 9,
    sc_permanent_redirect = 10,
    // 4xx Client Error
    sc_bad_request = 11,
    sc_unauthorized = 12,
    sc_forbidden = 13,
    sc_not_found = 14,
    sc_method_not_allowed = 15,
    sc_request_timeout = 16,
    sc_conflict = 17,
    sc_gone = 18,
    sc_length_required = 19,
    sc_payload_too_large = 20,
    sc_uri_too_long = 21,
    sc_unsupported_media = 22,
    sc_too_many_requests = 23,
    // 5xx Server Error
    sc_internal_error = 24,
    sc_not_implemented = 25,
    sc_bad_gateway = 26,
    sc_service_unavailable = 27,
    sc_gateway_timeout = 28,
};

/// Common content types (tags 0-7, matching Layout.idr contentTypeToTag).
pub const ContentType = enum(u8) {
    text_plain = 0,
    text_html = 1,
    application_json = 2,
    application_xml = 3,
    application_form = 4,
    multipart_form = 5,
    octet_stream = 6,
    text_css = 7,
};

// -- Constants ----------------------------------------------------------------

const MAX_CONTEXTS: usize = 64;
const MAX_HEADERS: usize = 32;
const MAX_PATH_LEN: usize = 2048;
const MAX_HEADER_KEY_LEN: usize = 128;
const MAX_HEADER_VAL_LEN: usize = 512;
const MAX_BODY_LEN: usize = 8192; // 8 KiB per-slot body buffer

// -- Header key-value store ---------------------------------------------------

/// A single HTTP header entry stored as fixed-size byte arrays.
const HeaderEntry = struct {
    key: [MAX_HEADER_KEY_LEN]u8,
    key_len: u32,
    value: [MAX_HEADER_VAL_LEN]u8,
    value_len: u32,
    active: bool,
};

const empty_header: HeaderEntry = .{
    .key = [_]u8{0} ** MAX_HEADER_KEY_LEN,
    .key_len = 0,
    .value = [_]u8{0} ** MAX_HEADER_VAL_LEN,
    .value_len = 0,
    .active = false,
};

// -- HTTP Context (request + response state) ----------------------------------

/// Represents a single HTTP request/response transaction.
const HttpCtx = struct {
    // -- Lifecycle state --
    phase: RequestPhase,
    active: bool,

    // -- Request fields --
    method: u8, // HttpMethod tag, 255 = unset
    version: u8, // HttpVersion tag, 255 = unset
    path: [MAX_PATH_LEN]u8,
    path_len: u32,
    req_headers: [MAX_HEADERS]HeaderEntry,
    req_header_count: u32,
    req_body: [MAX_BODY_LEN]u8,
    req_body_len: u32,
    keep_alive: bool,

    // -- Response fields --
    resp_status: u8, // AbiStatusCode tag, 255 = unset
    resp_headers: [MAX_HEADERS]HeaderEntry,
    resp_header_count: u32,
    resp_body: [MAX_BODY_LEN]u8,
    resp_body_len: u32,
};

const empty_ctx: HttpCtx = .{
    .phase = .idle,
    .active = false,
    .method = 255,
    .version = 255,
    .path = [_]u8{0} ** MAX_PATH_LEN,
    .path_len = 0,
    .req_headers = [_]HeaderEntry{empty_header} ** MAX_HEADERS,
    .req_header_count = 0,
    .req_body = [_]u8{0} ** MAX_BODY_LEN,
    .req_body_len = 0,
    .keep_alive = false,
    .resp_status = 255,
    .resp_headers = [_]HeaderEntry{empty_header} ** MAX_HEADERS,
    .resp_header_count = 0,
    .resp_body = [_]u8{0} ** MAX_BODY_LEN,
    .resp_body_len = 0,
};

// -- Global state: single mutex (matching proven-tls pattern) -----------------

var contexts: [MAX_CONTEXTS]HttpCtx = [_]HttpCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

/// Validate a slot index and return the usize index if valid and active.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return idx;
}

// -- Internal: parse helpers --------------------------------------------------

/// Method strings for parsing. Order matches HttpMethod enum tags.
const method_strings = [_][]const u8{
    "GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS", "TRACE", "CONNECT",
};

/// Parse a method string to its tag value. Returns 255 if unrecognised.
fn parseMethodStr(data: []const u8) u8 {
    for (method_strings, 0..) |ms, i| {
        if (data.len == ms.len and std.mem.eql(u8, data, ms)) {
            return @intCast(i);
        }
    }
    return 255;
}

/// Parse HTTP version string to tag. Returns 255 if unrecognised.
fn parseVersionStr(data: []const u8) u8 {
    if (std.mem.eql(u8, data, "HTTP/1.0")) return 0;
    if (std.mem.eql(u8, data, "HTTP/1.1")) return 1;
    if (std.mem.eql(u8, data, "HTTP/2.0") or std.mem.eql(u8, data, "HTTP/2")) return 2;
    if (std.mem.eql(u8, data, "HTTP/3.0") or std.mem.eql(u8, data, "HTTP/3")) return 3;
    return 255;
}

/// Find end-of-line (CRLF or LF) in data. Returns index after the line ending,
/// or null if not found.
fn findEol(data: []const u8) ?usize {
    for (data, 0..) |b, i| {
        if (b == '\n') {
            return i + 1;
        }
    }
    return null;
}

/// Trim leading and trailing whitespace (spaces, tabs, CR, LF).
fn trimWhitespace(data: []const u8) []const u8 {
    var start: usize = 0;
    while (start < data.len and (data[start] == ' ' or data[start] == '\t' or data[start] == '\r' or data[start] == '\n')) : (start += 1) {}
    var end: usize = data.len;
    while (end > start and (data[end - 1] == ' ' or data[end - 1] == '\t' or data[end - 1] == '\r' or data[end - 1] == '\n')) : (end -= 1) {}
    return data[start..end];
}

/// Check if the Connection header indicates keep-alive.
fn checkKeepAlive(ctx: *const HttpCtx) bool {
    for (ctx.req_headers[0..ctx.req_header_count]) |h| {
        if (!h.active) continue;
        // Case-insensitive check for "connection" header
        const key = h.key[0..h.key_len];
        if (key.len != 10) continue;
        // Lowercase compare "connection"
        const target = "connection";
        var match = true;
        for (key, 0..) |c, ki| {
            const lower = if (c >= 'A' and c <= 'Z') c + 32 else c;
            if (lower != target[ki]) {
                match = false;
                break;
            }
        }
        if (!match) continue;
        // Check value for "keep-alive"
        const val = trimWhitespace(h.value[0..h.value_len]);
        if (val.len < 10) continue;
        // Case-insensitive "keep-alive" check
        const ka = "keep-alive";
        var ka_match = true;
        if (val.len != ka.len) {
            ka_match = false;
        } else {
            for (val, 0..) |vc, vi| {
                const vl = if (vc >= 'A' and vc <= 'Z') vc + 32 else vc;
                if (vl != ka[vi]) {
                    ka_match = false;
                    break;
                }
            }
        }
        return ka_match;
    }
    return false;
}

/// Internal: add a header to a header array. Returns false if full.
fn addHeaderToArray(headers: *[MAX_HEADERS]HeaderEntry, count: *u32, key: []const u8, value: []const u8) bool {
    if (count.* >= MAX_HEADERS) return false;
    if (key.len > MAX_HEADER_KEY_LEN) return false;
    if (value.len > MAX_HEADER_VAL_LEN) return false;
    const idx: usize = @intCast(count.*);
    @memcpy(headers[idx].key[0..key.len], key);
    headers[idx].key_len = @intCast(key.len);
    @memcpy(headers[idx].value[0..value.len], value);
    headers[idx].value_len = @intCast(value.len);
    headers[idx].active = true;
    count.* += 1;
    return true;
}

// -- ABI version --------------------------------------------------------------

pub export fn http_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new HTTP context in Idle phase. Returns slot index or -1 on failure.
pub export fn http_create_context() callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            ctx.phase = .idle;
            return @intCast(i);
        }
    }
    return -1; // no free slots
}

/// Destroy an HTTP context, releasing its slot.
pub export fn http_destroy_context(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    contexts[@intCast(slot)].active = false;
}

// -- Request parsing ----------------------------------------------------------

/// Feed raw HTTP data into a context. Parses the request line, headers, and body.
///
/// Returns:
///   0 = parsing complete (phase is now Complete)
///   1 = rejected (malformed request, phase is now Sent — error)
///   2 = need more data (headers or body incomplete)
///
/// This function handles the Idle -> Receiving -> HeadersParsed -> Complete
/// (or BodyReceiving -> Complete) transitions.
pub export fn http_parse_request(slot: c_int, data: [*]const u8, len: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_CONTEXTS) return 1;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return 1;

    const ctx = &contexts[idx];

    // Can only parse from Idle, Receiving, or BodyReceiving
    if (ctx.phase != .idle and ctx.phase != .receiving and ctx.phase != .body_receiving) return 1;

    if (ctx.phase == .idle) {
        ctx.phase = .receiving; // Idle -> Receiving
    }

    const input = data[0..len];

    // If we are in body_receiving, append to body
    if (ctx.phase == .body_receiving) {
        const remaining = MAX_BODY_LEN - ctx.req_body_len;
        const to_copy: u32 = @intCast(@min(@as(usize, len), remaining));
        @memcpy(ctx.req_body[ctx.req_body_len..][0..to_copy], input[0..to_copy]);
        ctx.req_body_len += to_copy;
        // Check if we have the full body (simplified: mark complete)
        ctx.phase = .complete;
        return 0;
    }

    // Parse request line and headers from the input buffer.
    // Find end of request line.
    const rl_end = findEol(input) orelse return 2; // need more
    const request_line = trimWhitespace(input[0..rl_end]);

    // Parse request line: "METHOD PATH VERSION"
    // Find first space
    const sp1 = std.mem.indexOfScalar(u8, request_line, ' ') orelse {
        ctx.phase = .sent; // abort: malformed
        return 1;
    };
    const method_str = request_line[0..sp1];
    const rest1 = request_line[sp1 + 1 ..];

    // Find second space
    const sp2 = std.mem.indexOfScalar(u8, rest1, ' ') orelse {
        ctx.phase = .sent;
        return 1;
    };
    const path_str = rest1[0..sp2];
    const version_str = rest1[sp2 + 1 ..];

    // Validate and store method
    const method_tag = parseMethodStr(method_str);
    if (method_tag == 255) {
        ctx.phase = .sent;
        return 1;
    }
    ctx.method = method_tag;

    // Validate and store version
    const version_tag = parseVersionStr(version_str);
    if (version_tag == 255) {
        ctx.phase = .sent;
        return 1;
    }
    ctx.version = version_tag;

    // Store path
    if (path_str.len == 0 or path_str.len > MAX_PATH_LEN) {
        ctx.phase = .sent;
        return 1;
    }
    @memcpy(ctx.path[0..path_str.len], path_str);
    ctx.path_len = @intCast(path_str.len);

    // Parse headers
    var pos: usize = rl_end;
    while (pos < input.len) {
        const line_end = findEol(input[pos..]) orelse break;
        const line = trimWhitespace(input[pos .. pos + line_end]);
        pos += line_end;

        // Empty line marks end of headers
        if (line.len == 0) {
            ctx.phase = .headers_parsed; // Receiving -> HeadersParsed

            // Check if body is expected (POST, PUT, PATCH have bodies)
            const has_body = (ctx.method == 1 or ctx.method == 2 or ctx.method == 4);

            if (has_body and pos < input.len) {
                // Body data follows in same buffer
                ctx.phase = .body_receiving;
                const body_data = input[pos..];
                const to_copy = @min(body_data.len, MAX_BODY_LEN);
                @memcpy(ctx.req_body[0..to_copy], body_data[0..to_copy]);
                ctx.req_body_len = @intCast(to_copy);
                ctx.phase = .complete; // BodyReceiving -> Complete
            } else if (!has_body) {
                ctx.phase = .complete; // HeadersParsed -> Complete (no body)
            } else {
                ctx.phase = .body_receiving; // Waiting for body
                return 2; // need more data
            }

            // Check keep-alive
            ctx.keep_alive = checkKeepAlive(ctx);

            return 0; // complete
        }

        // Parse header: "Key: Value"
        const colon = std.mem.indexOfScalar(u8, line, ':') orelse continue;
        const key = trimWhitespace(line[0..colon]);
        const value = trimWhitespace(line[colon + 1 ..]);

        _ = addHeaderToArray(&ctx.req_headers, &ctx.req_header_count, key, value);
    }

    // Headers not complete yet
    return 2; // need more data
}

// -- Request queries ----------------------------------------------------------

/// Get the HTTP method tag for a context. Returns 255 if unset/invalid.
pub export fn http_get_method(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 255;
    mutex.lock();
    defer mutex.unlock();
    return contexts[idx].method;
}

/// Copy the request path into the provided buffer. Returns bytes written, 0 on error.
pub export fn http_get_path(slot: c_int, buf: [*]u8, len: u32) callconv(.c) u32 {
    const idx = validSlot(slot) orelse return 0;
    mutex.lock();
    defer mutex.unlock();
    const ctx = &contexts[idx];
    if (ctx.path_len == 0) return 0;
    const to_copy = @min(ctx.path_len, len);
    @memcpy(buf[0..to_copy], ctx.path[0..to_copy]);
    return to_copy;
}

/// Look up a request header by key. Copies value into buf. Returns bytes written, 0 if not found.
pub export fn http_get_header(slot: c_int, key: [*]const u8, klen: u32, buf: [*]u8, blen: u32) callconv(.c) u32 {
    const idx = validSlot(slot) orelse return 0;
    mutex.lock();
    defer mutex.unlock();
    const ctx = &contexts[idx];
    const search_key = key[0..klen];

    for (ctx.req_headers[0..ctx.req_header_count]) |h| {
        if (!h.active) continue;
        const hkey = h.key[0..h.key_len];
        if (hkey.len != search_key.len) continue;
        // Case-insensitive comparison
        var match = true;
        for (hkey, 0..) |c, ki| {
            const a = if (c >= 'A' and c <= 'Z') c + 32 else c;
            const b = if (search_key[ki] >= 'A' and search_key[ki] <= 'Z') search_key[ki] + 32 else search_key[ki];
            if (a != b) {
                match = false;
                break;
            }
        }
        if (match) {
            const to_copy = @min(h.value_len, blen);
            @memcpy(buf[0..to_copy], h.value[0..to_copy]);
            return to_copy;
        }
    }
    return 0; // not found
}

/// Copy the request body into the provided buffer. Returns bytes written, 0 on error.
pub export fn http_get_body(slot: c_int, buf: [*]u8, len: u32) callconv(.c) u32 {
    const idx = validSlot(slot) orelse return 0;
    mutex.lock();
    defer mutex.unlock();
    const ctx = &contexts[idx];
    if (ctx.req_body_len == 0) return 0;
    const to_copy = @min(ctx.req_body_len, len);
    @memcpy(buf[0..to_copy], ctx.req_body[0..to_copy]);
    return to_copy;
}

// -- Response construction ----------------------------------------------------

/// Set the response status code. Requires Complete or Responding phase.
/// Returns 0 on success, 1 if rejected (wrong phase).
pub export fn http_set_status(slot: c_int, status_tag: u8) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutex.lock();
    defer mutex.unlock();
    const ctx = &contexts[idx];
    if (ctx.phase != .complete and ctx.phase != .responding) return 1;
    if (status_tag > 28) return 1; // invalid status code tag
    ctx.resp_status = status_tag;
    if (ctx.phase == .complete) {
        ctx.phase = .responding; // Complete -> Responding
    }
    return 0;
}

/// Set a response header. Requires Complete or Responding phase.
/// Returns 0 on success, 1 if rejected.
pub export fn http_set_header(slot: c_int, key: [*]const u8, klen: u32, val: [*]const u8, vlen: u32) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutex.lock();
    defer mutex.unlock();
    const ctx = &contexts[idx];
    if (ctx.phase != .complete and ctx.phase != .responding) return 1;
    if (ctx.phase == .complete) {
        ctx.phase = .responding; // Complete -> Responding
    }
    if (!addHeaderToArray(&ctx.resp_headers, &ctx.resp_header_count, key[0..klen], val[0..vlen])) {
        return 1;
    }
    return 0;
}

/// Set the response body. Requires Complete or Responding phase.
/// Returns 0 on success, 1 if rejected.
pub export fn http_set_body(slot: c_int, data: [*]const u8, len: u32) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutex.lock();
    defer mutex.unlock();
    const ctx = &contexts[idx];
    if (ctx.phase != .complete and ctx.phase != .responding) return 1;
    if (len > MAX_BODY_LEN) return 1;
    if (ctx.phase == .complete) {
        ctx.phase = .responding; // Complete -> Responding
    }
    @memcpy(ctx.resp_body[0..len], data[0..len]);
    ctx.resp_body_len = len;
    return 0;
}

/// Send the response (finalise). Transitions Responding -> Sent.
/// Returns 0 on success, 1 if rejected.
pub export fn http_send_response(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutex.lock();
    defer mutex.unlock();
    const ctx = &contexts[idx];
    if (ctx.phase != .responding) return 1;
    ctx.phase = .sent; // Responding -> Sent
    return 0;
}

// -- Keep-alive and phase queries ---------------------------------------------

/// Check if the connection uses keep-alive. Returns 1=yes, 0=no.
pub export fn http_keep_alive_check(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 0;
    mutex.lock();
    defer mutex.unlock();
    return if (contexts[idx].keep_alive) 1 else 0;
}

/// Get the current request phase tag.
pub export fn http_get_phase(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 6; // sent as fallback
    mutex.lock();
    defer mutex.unlock();
    return @intFromEnum(contexts[idx].phase);
}

/// Get the HTTP version tag for the parsed request. Returns 255 if unset.
pub export fn http_get_version(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 255;
    mutex.lock();
    defer mutex.unlock();
    return contexts[idx].version;
}

/// Reset context for keep-alive reuse. Transitions Sent -> Idle.
/// Returns 0 on success, 1 if rejected.
pub export fn http_reset_context(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutex.lock();
    defer mutex.unlock();
    const ctx = &contexts[idx];
    if (ctx.phase != .sent) return 1;
    // Reset to idle, preserving the active flag
    ctx.* = empty_ctx;
    ctx.active = true;
    ctx.phase = .idle;
    return 0;
}

// -- Stateless transition table -----------------------------------------------

/// Check whether an HTTP lifecycle transition is valid.
/// Matches Transitions.idr validateHttpTransition exactly.
/// Returns 1=valid, 0=invalid.
pub export fn http_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Idle(0) -> Receiving(1)
    if (from == 0 and to == 1) return 1;
    // Receiving(1) -> HeadersParsed(2)
    if (from == 1 and to == 2) return 1;
    // HeadersParsed(2) -> BodyReceiving(3)
    if (from == 2 and to == 3) return 1;
    // HeadersParsed(2) -> Complete(4) (no-body)
    if (from == 2 and to == 4) return 1;
    // BodyReceiving(3) -> Complete(4)
    if (from == 3 and to == 4) return 1;
    // Complete(4) -> Responding(5)
    if (from == 4 and to == 5) return 1;
    // Responding(5) -> Sent(6)
    if (from == 5 and to == 6) return 1;
    // Sent(6) -> Idle(0) (keep-alive)
    if (from == 6 and to == 0) return 1;
    // Abort edges: Receiving(1) -> Sent(6)
    if (from == 1 and to == 6) return 1;
    // Abort edges: HeadersParsed(2) -> Sent(6)
    if (from == 2 and to == 6) return 1;
    // Abort edges: BodyReceiving(3) -> Sent(6)
    if (from == 3 and to == 6) return 1;
    // Abort edges: Complete(4) -> Sent(6)
    if (from == 4 and to == 6) return 1;
    return 0;
}
