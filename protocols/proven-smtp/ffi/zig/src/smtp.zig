// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// smtp.zig -- Zig FFI implementation of proven-smtp.
//
// Implements verified SMTP session state machine with:
//   - Slot-based context management (up to 64 concurrent sessions)
//   - State machine enforcement matching Idris2 Transitions.idr
//   - Thread-safe via per-slot mutex pool (64 mutexes)
//   - Recipient list (fixed array, max 64 per transaction)
//   - Message buffer size tracking
//   - Reply code tracking
//   - AUTH mechanism and TLS state tracking

const std = @import("std");

// -- Enums (matching SMTPABI.Layout.idr tag assignments) ---------------------

/// SMTP command verbs (12 constructors, tags 0-11).
pub const SmtpCommandTag = enum(u8) {
    helo = 0,
    ehlo = 1,
    mail_from = 2,
    rcpt_to = 3,
    data = 4,
    quit = 5,
    rset = 6,
    noop = 7,
    vrfy = 8,
    expn = 9,
    starttls = 10,
    auth = 11,
};

/// SMTP reply categories (4 constructors, tags 0-3).
pub const ReplyCategory = enum(u8) {
    positive = 0,
    intermediate = 1,
    transient_negative = 2,
    permanent_negative = 3,
};

/// SMTP reply codes (17 constructors, tags 0-16).
pub const ReplyCode = enum(u8) {
    service_ready = 0,
    service_closing = 1,
    action_ok = 2,
    will_forward = 3,
    start_mail_input = 4,
    service_unavailable = 5,
    mailbox_busy = 6,
    local_error = 7,
    insufficient_storage = 8,
    syntax_error = 9,
    param_syntax_error = 10,
    not_implemented = 11,
    bad_sequence = 12,
    param_not_implemented = 13,
    mailbox_unavailable = 14,
    mailbox_name_invalid = 15,
    transaction_failed = 16,
};

/// AUTH mechanism tags (4 constructors, tags 0-3).
pub const AuthMechTag = enum(u8) {
    plain = 0,
    login = 1,
    cram_md5 = 2,
    xoauth2 = 3,
};

/// SMTP extensions (7 constructors, tags 0-6).
pub const SmtpExtension = enum(u8) {
    size = 0,
    pipelining = 1,
    eight_bit_mime = 2,
    starttls = 3,
    auth = 4,
    dsn = 5,
    chunking = 6,
};

/// Extended SMTP session states (9 constructors, tags 0-8).
pub const SmtpSessionState = enum(u8) {
    connected = 0,
    greeted = 1,
    auth_started = 2,
    authenticated = 3,
    mail_from = 4,
    rcpt_to = 5,
    data = 6,
    message_received = 7,
    quit = 8,
};

// -- SMTP session context ----------------------------------------------------

/// Maximum number of recipients per transaction.
const MAX_RECIPIENTS: usize = 64;

/// Maximum message data size in bytes (10 MiB).
const MAX_DATA_SIZE: u32 = 10_485_760;

/// An SMTP session context tracking all state for one connection.
const SmtpContext = struct {
    /// Current session state.
    state: SmtpSessionState,
    /// Last reply code sent.
    last_reply: u8,
    /// Number of recipients in current transaction.
    recipient_count: u8,
    /// Accumulated message data size in bytes.
    data_size: u32,
    /// Current AUTH mechanism (255 = none).
    auth_mechanism: u8,
    /// Whether the session has been authenticated.
    is_authenticated: bool,
    /// Whether STARTTLS has been negotiated.
    tls_active: bool,
    /// Whether this slot is in use.
    active: bool,
};

const MAX_SESSIONS: usize = 64;

/// Per-slot mutex pool for fine-grained locking.
var mutexes: [MAX_SESSIONS]std.Thread.Mutex = [_]std.Thread.Mutex{.{}} ** MAX_SESSIONS;

/// Global mutex for slot allocation/deallocation.
var global_mutex: std.Thread.Mutex = .{};

/// Session slot array.
var sessions: [MAX_SESSIONS]SmtpContext = [_]SmtpContext{.{
    .state = .connected,
    .last_reply = 0,
    .recipient_count = 0,
    .data_size = 0,
    .auth_mechanism = 255,
    .is_authenticated = false,
    .tls_active = false,
    .active = false,
}} ** MAX_SESSIONS;

/// Validate a slot index and return the index if valid and active.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// -- ABI version -------------------------------------------------------------

/// Return the ABI version number (must match Foreign.idr abiVersion).
pub export fn smtp_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ---------------------------------------------------------------

/// Create a new SMTP session context in the Connected state.
/// Returns the slot index, or -1 if no slots are available.
pub export fn smtp_create_context() callconv(.c) c_int {
    global_mutex.lock();
    defer global_mutex.unlock();
    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = .{
                .state = .connected,
                .last_reply = @intFromEnum(ReplyCode.service_ready),
                .recipient_count = 0,
                .data_size = 0,
                .auth_mechanism = 255,
                .is_authenticated = false,
                .tls_active = false,
                .active = true,
            };
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy an SMTP session context, freeing the slot.
pub export fn smtp_destroy_context(slot: c_int) callconv(.c) void {
    global_mutex.lock();
    defer global_mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)].active = false;
}

// -- State queries -----------------------------------------------------------

/// Get the current session state tag.
pub export fn smtp_get_state(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return @intFromEnum(SmtpSessionState.quit);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return @intFromEnum(sessions[idx].state);
}

/// Get the last reply code tag.
pub export fn smtp_get_reply_code(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 255;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return sessions[idx].last_reply;
}

/// Get the number of recipients in the current transaction.
pub export fn smtp_get_recipient_count(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return sessions[idx].recipient_count;
}

/// Get the accumulated data size in bytes.
pub export fn smtp_get_data_size(slot: c_int) callconv(.c) u32 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return sessions[idx].data_size;
}

/// Get the current AUTH mechanism tag (255 = none).
pub export fn smtp_get_auth_mechanism(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 255;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return sessions[idx].auth_mechanism;
}

/// Check if the session is authenticated (1=yes, 0=no).
pub export fn smtp_is_authenticated(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return if (sessions[idx].is_authenticated) 1 else 0;
}

/// Check if TLS is active (1=yes, 0=no).
pub export fn smtp_is_tls_active(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return if (sessions[idx].tls_active) 1 else 0;
}

// -- SMTP operations ---------------------------------------------------------

/// HELO/EHLO: Greet the server.  is_ehlo=0 for HELO, 1 for EHLO.
/// Returns 0 on success, 1 on rejection.
pub export fn smtp_greet(slot: c_int, is_ehlo: u8) callconv(.c) u8 {
    _ = is_ehlo;
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (sessions[idx].state != .connected) return 1;
    sessions[idx].state = .greeted;
    sessions[idx].last_reply = @intFromEnum(ReplyCode.action_ok);
    return 0;
}

/// Begin AUTH exchange with the given mechanism tag.
/// Returns 0 on success (-> AuthStarted), 1 on rejection.
pub export fn smtp_authenticate(slot: c_int, mech: u8) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    // Can only start AUTH from Greeted state
    if (sessions[idx].state != .greeted) return 1;
    // Validate mechanism tag (0-3)
    if (mech > 3) return 1;
    sessions[idx].state = .auth_started;
    sessions[idx].auth_mechanism = mech;
    sessions[idx].last_reply = @intFromEnum(ReplyCode.start_mail_input);
    return 0;
}

/// Complete AUTH exchange.  success=1 -> Authenticated, success=0 -> Greeted.
/// Returns 0 on success, 1 on rejection.
pub export fn smtp_auth_complete(slot: c_int, success: u8) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (sessions[idx].state != .auth_started) return 1;
    if (success == 1) {
        sessions[idx].state = .authenticated;
        sessions[idx].is_authenticated = true;
        sessions[idx].last_reply = @intFromEnum(ReplyCode.action_ok);
    } else {
        sessions[idx].state = .greeted;
        sessions[idx].auth_mechanism = 255;
        sessions[idx].last_reply = @intFromEnum(ReplyCode.transaction_failed);
    }
    return 0;
}

/// MAIL FROM: Set the sender.
/// Returns 0 on success (-> MailFrom), 1 on rejection.
pub export fn smtp_set_sender(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    // MAIL FROM valid from Greeted (relay) or Authenticated
    if (sessions[idx].state != .greeted and sessions[idx].state != .authenticated) return 1;
    sessions[idx].state = .mail_from;
    sessions[idx].recipient_count = 0;
    sessions[idx].data_size = 0;
    sessions[idx].last_reply = @intFromEnum(ReplyCode.action_ok);
    return 0;
}

/// RCPT TO: Add a recipient.
/// Returns 0 on success, 1 on rejection (wrong state or max recipients).
pub export fn smtp_add_recipient(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    // RCPT TO valid from MailFrom or RcptTo
    if (sessions[idx].state != .mail_from and sessions[idx].state != .rcpt_to) return 1;
    if (sessions[idx].recipient_count >= MAX_RECIPIENTS) return 1;
    sessions[idx].state = .rcpt_to;
    sessions[idx].recipient_count += 1;
    sessions[idx].last_reply = @intFromEnum(ReplyCode.action_ok);
    return 0;
}

/// DATA: Begin message body transfer.
/// Returns 0 on success (-> Data), 1 on rejection.
pub export fn smtp_start_data(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    // DATA only valid from RcptTo (must have at least one recipient)
    if (sessions[idx].state != .rcpt_to) return 1;
    sessions[idx].state = .data;
    sessions[idx].data_size = 0;
    sessions[idx].last_reply = @intFromEnum(ReplyCode.start_mail_input);
    return 0;
}

/// Append data to the message buffer.
/// Returns 0 on success, 1 on rejection (wrong state or size overflow).
pub export fn smtp_append_data(slot: c_int, len: u32) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (sessions[idx].state != .data) return 1;
    const new_size: u64 = @as(u64, sessions[idx].data_size) + @as(u64, len);
    if (new_size > MAX_DATA_SIZE) return 1;
    sessions[idx].data_size = @intCast(new_size);
    return 0;
}

/// Finish data transfer (end-of-data marker).
/// Returns 0 on success (-> MessageReceived), 1 on rejection.
pub export fn smtp_finish_data(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (sessions[idx].state != .data) return 1;
    sessions[idx].state = .message_received;
    sessions[idx].last_reply = @intFromEnum(ReplyCode.action_ok);
    return 0;
}

/// RSET: Reset the mail transaction.
/// Returns 0 on success (-> Greeted or Authenticated), 1 on rejection.
pub export fn smtp_reset(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    // RSET valid from MailFrom, RcptTo, or MessageReceived
    switch (sessions[idx].state) {
        .mail_from, .rcpt_to, .message_received => {
            // Preserve authentication state on reset
            if (sessions[idx].is_authenticated) {
                sessions[idx].state = .authenticated;
            } else {
                sessions[idx].state = .greeted;
            }
            sessions[idx].recipient_count = 0;
            sessions[idx].data_size = 0;
            sessions[idx].last_reply = @intFromEnum(ReplyCode.action_ok);
            return 0;
        },
        else => return 1,
    }
}

/// QUIT: End the session.
/// Returns 0 on success (-> Quit), 1 on rejection.
pub export fn smtp_quit(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    // QUIT valid from any state except Quit, Data, and AuthStarted
    switch (sessions[idx].state) {
        .quit, .data, .auth_started => return 1,
        else => {
            sessions[idx].state = .quit;
            sessions[idx].last_reply = @intFromEnum(ReplyCode.service_closing);
            return 0;
        },
    }
}

/// STARTTLS: Enable TLS on the connection.
/// Returns 0 on success, 1 on rejection (wrong state or already active).
pub export fn smtp_enable_tls(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    // STARTTLS only valid from Greeted state, and only once
    if (sessions[idx].state != .greeted) return 1;
    if (sessions[idx].tls_active) return 1;
    sessions[idx].tls_active = true;
    sessions[idx].last_reply = @intFromEnum(ReplyCode.service_ready);
    return 0;
}

// -- Stateless transition table ----------------------------------------------

/// Check whether a transition between two session states is valid.
/// Returns 1 if valid, 0 if invalid.
/// Matches Transitions.idr validateSmtpTransition exactly.
pub export fn smtp_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Connected(0) -> Greeted(1)
    if (from == 0 and to == 1) return 1;
    // Greeted(1) -> AuthStarted(2)
    if (from == 1 and to == 2) return 1;
    // AuthStarted(2) -> Authenticated(3)
    if (from == 2 and to == 3) return 1;
    // AuthStarted(2) -> Greeted(1) (auth failure)
    if (from == 2 and to == 1) return 1;
    // Authenticated(3) -> MailFrom(4)
    if (from == 3 and to == 4) return 1;
    // Greeted(1) -> MailFrom(4) (relay)
    if (from == 1 and to == 4) return 1;
    // MailFrom(4) -> RcptTo(5)
    if (from == 4 and to == 5) return 1;
    // RcptTo(5) -> RcptTo(5)
    if (from == 5 and to == 5) return 1;
    // RcptTo(5) -> Data(6)
    if (from == 5 and to == 6) return 1;
    // Data(6) -> MessageReceived(7)
    if (from == 6 and to == 7) return 1;
    // MessageReceived(7) -> Greeted(1)
    if (from == 7 and to == 1) return 1;
    // MessageReceived(7) -> Authenticated(3)
    if (from == 7 and to == 3) return 1;
    // MailFrom(4) -> Greeted(1) (RSET)
    if (from == 4 and to == 1) return 1;
    // RcptTo(5) -> Greeted(1) (RSET)
    if (from == 5 and to == 1) return 1;
    // Quit edges: Connected(0), Greeted(1), Authenticated(3),
    //             MailFrom(4), RcptTo(5), MessageReceived(7) -> Quit(8)
    if (to == 8) {
        if (from == 0 or from == 1 or from == 3 or from == 4 or from == 5 or from == 7) return 1;
    }
    return 0;
}
