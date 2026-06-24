// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// amqp.zig -- Zig FFI implementation of proven-amqp.
//
// Implements the AMQP 0-9-1 broker state machine with:
//   - 64-slot mutex-protected session pool
//   - Channel tracking per session (max 16 channels)
//   - Exchange/queue/binding declarations
//   - Consumer tracking per channel
//   - Delivery tag management
//   - Topic exchange routing key matching (*, #)
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching AMQPABI.Layout.idr exactly.

const std = @import("std");

// Generated from the proven Idris ABI encoders by tools/gen-abi.sh; the
// comptime guard below pins every enum tag to these, so drift is a build error.
const gen = @import("amqp_abi_gen.zig");

/// ABI version (guarded against gen.ABI_VERSION below).
const ABI_VERSION: u32 = 1;

// =========================================================================
// Enums (matching AMQPABI.Layout.idr tag assignments)
// =========================================================================

/// AMQP frame types (ABI tags 0-3).
pub const FrameType = enum(u8) {
    method = 0,
    header = 1,
    body = 2,
    heartbeat = 3,
};

/// AMQP method classes (ABI tags 0-6).
pub const MethodClass = enum(u8) {
    connection = 0,
    channel = 1,
    exchange = 2,
    queue = 3,
    basic = 4,
    tx = 5,
    confirm = 6,
};

/// AMQP exchange types (ABI tags 0-3).
pub const ExchangeType = enum(u8) {
    direct = 0,
    fanout = 1,
    topic = 2,
    headers = 3,
};

/// AMQP delivery modes (ABI tags 0-1).
pub const DeliveryMode = enum(u8) {
    non_persistent = 0,
    persistent = 1,
};

/// Error severity (ABI tags 0-1).
pub const ErrorSeverity = enum(u8) {
    channel_level = 0,
    connection_level = 1,
};

/// Connection lifecycle states (ABI tags 0-4).
pub const ConnectionState = enum(u8) {
    idle = 0,
    negotiating = 1,
    tuning_ok = 2,
    open = 3,
    closing = 4,
};

/// Channel lifecycle states (ABI tags 0-3).
pub const ChannelState = enum(u8) {
    closed = 0,
    opening = 1,
    ch_open = 2,
    ch_closing = 3,
};

/// Broker session lifecycle states (ABI tags 0-5).
pub const BrokerState = enum(u8) {
    idle = 0,
    connected = 1,
    channel_open = 2,
    consuming = 3,
    publishing = 4,
    disconnecting = 5,
};

// ── ABI conformance guard ────────────────────────────────────────────────
// Every enum tag MUST equal the generated (= proven Idris) value; a mismatch
// fails `zig build` with the named symbol. Regenerate: bash tools/gen-abi.sh.
comptime {
    if (ABI_VERSION != gen.ABI_VERSION) @compileError("ABI drift: abi_version");

    if (@intFromEnum(FrameType.method) != gen.FRAME_METHOD) @compileError("ABI drift: FrameType.method");
    if (@intFromEnum(FrameType.header) != gen.FRAME_HEADER) @compileError("ABI drift: FrameType.header");
    if (@intFromEnum(FrameType.body) != gen.FRAME_BODY) @compileError("ABI drift: FrameType.body");
    if (@intFromEnum(FrameType.heartbeat) != gen.FRAME_HEARTBEAT) @compileError("ABI drift: FrameType.heartbeat");

    if (@intFromEnum(MethodClass.connection) != gen.CLASS_CONNECTION) @compileError("ABI drift: MethodClass.connection");
    if (@intFromEnum(MethodClass.channel) != gen.CLASS_CHANNEL) @compileError("ABI drift: MethodClass.channel");
    if (@intFromEnum(MethodClass.exchange) != gen.CLASS_EXCHANGE) @compileError("ABI drift: MethodClass.exchange");
    if (@intFromEnum(MethodClass.queue) != gen.CLASS_QUEUE) @compileError("ABI drift: MethodClass.queue");
    if (@intFromEnum(MethodClass.basic) != gen.CLASS_BASIC) @compileError("ABI drift: MethodClass.basic");
    if (@intFromEnum(MethodClass.tx) != gen.CLASS_TX) @compileError("ABI drift: MethodClass.tx");
    if (@intFromEnum(MethodClass.confirm) != gen.CLASS_CONFIRM) @compileError("ABI drift: MethodClass.confirm");

    if (@intFromEnum(ExchangeType.direct) != gen.EXCH_DIRECT) @compileError("ABI drift: ExchangeType.direct");
    if (@intFromEnum(ExchangeType.fanout) != gen.EXCH_FANOUT) @compileError("ABI drift: ExchangeType.fanout");
    if (@intFromEnum(ExchangeType.topic) != gen.EXCH_TOPIC) @compileError("ABI drift: ExchangeType.topic");
    if (@intFromEnum(ExchangeType.headers) != gen.EXCH_HEADERS) @compileError("ABI drift: ExchangeType.headers");

    if (@intFromEnum(DeliveryMode.non_persistent) != gen.DMODE_NON_PERSISTENT) @compileError("ABI drift: DeliveryMode.non_persistent");
    if (@intFromEnum(DeliveryMode.persistent) != gen.DMODE_PERSISTENT) @compileError("ABI drift: DeliveryMode.persistent");

    if (@intFromEnum(ErrorSeverity.channel_level) != gen.SEV_CHANNEL_LEVEL) @compileError("ABI drift: ErrorSeverity.channel_level");
    if (@intFromEnum(ErrorSeverity.connection_level) != gen.SEV_CONNECTION_LEVEL) @compileError("ABI drift: ErrorSeverity.connection_level");

    if (@intFromEnum(ConnectionState.idle) != gen.CONN_IDLE) @compileError("ABI drift: ConnectionState.idle");
    if (@intFromEnum(ConnectionState.negotiating) != gen.CONN_NEGOTIATING) @compileError("ABI drift: ConnectionState.negotiating");
    if (@intFromEnum(ConnectionState.tuning_ok) != gen.CONN_TUNING_OK) @compileError("ABI drift: ConnectionState.tuning_ok");
    if (@intFromEnum(ConnectionState.open) != gen.CONN_OPEN) @compileError("ABI drift: ConnectionState.open");
    if (@intFromEnum(ConnectionState.closing) != gen.CONN_CLOSING) @compileError("ABI drift: ConnectionState.closing");

    if (@intFromEnum(ChannelState.closed) != gen.CHAN_CLOSED) @compileError("ABI drift: ChannelState.closed");
    if (@intFromEnum(ChannelState.opening) != gen.CHAN_OPENING) @compileError("ABI drift: ChannelState.opening");
    if (@intFromEnum(ChannelState.ch_open) != gen.CHAN_CH_OPEN) @compileError("ABI drift: ChannelState.ch_open");
    if (@intFromEnum(ChannelState.ch_closing) != gen.CHAN_CH_CLOSING) @compileError("ABI drift: ChannelState.ch_closing");

    if (@intFromEnum(BrokerState.idle) != gen.BROKER_IDLE) @compileError("ABI drift: BrokerState.idle");
    if (@intFromEnum(BrokerState.connected) != gen.BROKER_CONNECTED) @compileError("ABI drift: BrokerState.connected");
    if (@intFromEnum(BrokerState.channel_open) != gen.BROKER_CHANNEL_OPEN) @compileError("ABI drift: BrokerState.channel_open");
    if (@intFromEnum(BrokerState.consuming) != gen.BROKER_CONSUMING) @compileError("ABI drift: BrokerState.consuming");
    if (@intFromEnum(BrokerState.publishing) != gen.BROKER_PUBLISHING) @compileError("ABI drift: BrokerState.publishing");
    if (@intFromEnum(BrokerState.disconnecting) != gen.BROKER_DISCONNECTING) @compileError("ABI drift: BrokerState.disconnecting");
}

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 16;

/// Maximum channels per session.
const MAX_CHANNELS: usize = 16;

/// Maximum exchanges per session.
const MAX_EXCHANGES: usize = 32;

/// Maximum queues per session.
const MAX_QUEUES: usize = 64;

/// Maximum bindings per session.
const MAX_BINDINGS: usize = 128;

/// Maximum consumers per session (across all channels).
const MAX_CONSUMERS: usize = 64;

/// Maximum name length in bytes (exchange/queue/routing key/consumer tag).
const MAX_NAME_LEN: usize = 256;

/// Maximum vhost path length.
const MAX_VHOST_LEN: usize = 128;

/// A channel within a session.
const Channel = struct {
    /// Channel number (1-based per AMQP spec; 0 is reserved for connection).
    number: u16,
    /// Whether this channel slot is active.
    active: bool,
    /// Next delivery tag to assign (monotonically increasing per channel).
    next_delivery_tag: u64,
    /// Number of unacknowledged deliveries.
    unacked: u32,
    /// Prefetch count (0 = unlimited).
    prefetch_count: u16,
    /// Prefetch size (0 = unlimited).
    prefetch_size: u32,
    /// Whether QoS is global (connection-level).
    qos_global: bool,
};

/// An exchange declaration.
const ExchangeEntry = struct {
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    exch_type: ExchangeType,
    durable: bool,
    auto_delete: bool,
    internal: bool,
    active: bool,
};

/// A queue declaration.
const QueueEntry = struct {
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    durable: bool,
    exclusive: bool,
    auto_delete: bool,
    active: bool,
};

/// A binding between a queue and an exchange.
const BindingEntry = struct {
    queue_name: [MAX_NAME_LEN]u8,
    queue_len: u32,
    exchange_name: [MAX_NAME_LEN]u8,
    exchange_len: u32,
    routing_key: [MAX_NAME_LEN]u8,
    rk_len: u32,
    active: bool,
};

/// A consumer entry.
const ConsumerEntry = struct {
    consumer_tag: [MAX_NAME_LEN]u8,
    tag_len: u32,
    queue_name: [MAX_NAME_LEN]u8,
    queue_len: u32,
    channel: u16,
    no_ack: bool,
    exclusive: bool,
    active: bool,
};

/// A broker session.
const Session = struct {
    /// Current broker lifecycle state.
    state: BrokerState,
    /// Virtual host path.
    vhost: [MAX_VHOST_LEN]u8,
    vhost_len: u32,
    /// Negotiated maximum frame size.
    frame_max: u32,
    /// Negotiated maximum channel count.
    channel_max: u16,
    /// Negotiated heartbeat interval.
    heartbeat: u16,
    /// Channels (fixed array).
    channels: [MAX_CHANNELS]Channel,
    /// Number of active channels.
    channel_count: u16,
    /// Exchange declarations.
    exchanges: [MAX_EXCHANGES]ExchangeEntry,
    /// Queue declarations.
    queues: [MAX_QUEUES]QueueEntry,
    /// Bindings.
    bindings: [MAX_BINDINGS]BindingEntry,
    /// Consumers.
    consumers: [MAX_CONSUMERS]ConsumerEntry,
    /// Total active consumer count.
    consumer_count: u32,
    /// Whether consumers existed before entering Publishing state.
    had_consumers_before_publish: bool,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) channel.
const empty_channel: Channel = .{
    .number = 0,
    .active = false,
    .next_delivery_tag = 1,
    .unacked = 0,
    .prefetch_count = 0,
    .prefetch_size = 0,
    .qos_global = false,
};

/// Default (empty) exchange entry.
const empty_exchange: ExchangeEntry = .{
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .exch_type = .direct,
    .durable = false,
    .auto_delete = false,
    .internal = false,
    .active = false,
};

/// Default (empty) queue entry.
const empty_queue: QueueEntry = .{
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .durable = false,
    .exclusive = false,
    .auto_delete = false,
    .active = false,
};

/// Default (empty) binding entry.
const empty_binding: BindingEntry = .{
    .queue_name = [_]u8{0} ** MAX_NAME_LEN,
    .queue_len = 0,
    .exchange_name = [_]u8{0} ** MAX_NAME_LEN,
    .exchange_len = 0,
    .routing_key = [_]u8{0} ** MAX_NAME_LEN,
    .rk_len = 0,
    .active = false,
};

/// Default (empty) consumer entry.
const empty_consumer: ConsumerEntry = .{
    .consumer_tag = [_]u8{0} ** MAX_NAME_LEN,
    .tag_len = 0,
    .queue_name = [_]u8{0} ** MAX_NAME_LEN,
    .queue_len = 0,
    .channel = 0,
    .no_ack = false,
    .exclusive = false,
    .active = false,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .vhost = [_]u8{0} ** MAX_VHOST_LEN,
    .vhost_len = 0,
    .frame_max = 131072,
    .channel_max = 16,
    .heartbeat = 60,
    .channels = [_]Channel{empty_channel} ** MAX_CHANNELS,
    .channel_count = 0,
    .exchanges = [_]ExchangeEntry{empty_exchange} ** MAX_EXCHANGES,
    .queues = [_]QueueEntry{empty_queue} ** MAX_QUEUES,
    .bindings = [_]BindingEntry{empty_binding} ** MAX_BINDINGS,
    .consumers = [_]ConsumerEntry{empty_consumer} ** MAX_CONSUMERS,
    .consumer_count = 0,
    .had_consumers_before_publish = false,
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

/// Find a channel by number within a session.
fn findChannel(idx: usize, channel: u16) ?usize {
    for (&sessions[idx].channels, 0..) |*ch, i| {
        if (ch.active and ch.number == channel) return i;
    }
    return null;
}

/// Check if a broker state allows publishing.
fn canPublishState(state: BrokerState) bool {
    return state == .channel_open or state == .consuming;
}

/// Check if a broker state allows consuming.
fn canConsumeState(state: BrokerState) bool {
    return state == .channel_open or state == .consuming;
}

/// Match a routing key against a binding pattern for topic exchanges.
/// Supports '*' (single word) and '#' (zero or more words).
/// Words are delimited by '.'.
pub fn topicMatch(routing_key: []const u8, pattern: []const u8) bool {
    var ri: usize = 0;
    var pi: usize = 0;

    // Split into words and match iteratively
    while (pi < pattern.len) {
        if (pattern[pi] == '#') {
            // '#' matches zero or more words (rest of routing key)
            return true;
        } else if (pattern[pi] == '*') {
            // '*' matches exactly one word
            if (ri >= routing_key.len) return false;
            // Consume one word in routing key
            while (ri < routing_key.len and routing_key[ri] != '.') : (ri += 1) {}
            pi += 1;
            // Both should advance past '.' or end
            if (pi < pattern.len and pattern[pi] == '.') pi += 1;
            if (ri < routing_key.len and routing_key[ri] == '.') ri += 1;
        } else {
            // Literal match
            if (ri >= routing_key.len) return false;
            if (routing_key[ri] != pattern[pi]) return false;
            ri += 1;
            pi += 1;
        }
    }

    return ri == routing_key.len;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

// -- ABI version --------------------------------------------------------------

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn amqp_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new AMQP session. Returns slot index (>=0) or -1 on failure.
/// The session starts in Connected state (Idle -> Connected transition applied).
pub export fn amqp_create(
    vhost_ptr: [*]const u8,
    vhost_len: u32,
    frame_max: u32,
    channel_max: u16,
    heartbeat: u16,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (vhost_len == 0 or vhost_len > MAX_VHOST_LEN) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.vhost[0..vhost_len], vhost_ptr[0..vhost_len]);
            s.vhost_len = vhost_len;
            s.frame_max = if (frame_max == 0) 131072 else frame_max;
            s.channel_max = if (channel_max == 0) 16 else channel_max;
            s.heartbeat = heartbeat;
            s.state = .connected; // Idle -> Connected
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn amqp_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

// -- State queries ------------------------------------------------------------

/// Returns the current BrokerState tag for a session.
pub export fn amqp_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // idle fallback
    return @intFromEnum(sessions[idx].state);
}

/// Returns 1 if the session can publish, 0 otherwise.
pub export fn amqp_can_publish(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (canPublishState(sessions[idx].state)) 1 else 0;
}

/// Returns 1 if the session can consume, 0 otherwise.
pub export fn amqp_can_consume(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (canConsumeState(sessions[idx].state)) 1 else 0;
}

// -- Channel management -------------------------------------------------------

/// Open a channel. Returns 0 on success, 1 on rejection.
/// Transitions: Connected -> ChannelOpen, or stays ChannelOpen.
pub export fn amqp_channel_open(slot: c_int, channel: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .connected and state != .channel_open and
        state != .consuming) return 1;
    if (channel == 0) return 1; // channel 0 reserved for connection
    if (sessions[idx].channel_count >= sessions[idx].channel_max) return 1;

    // Check for duplicate channel number
    if (findChannel(idx, channel) != null) return 1;

    // Find a free channel slot
    for (&sessions[idx].channels) |*ch| {
        if (!ch.active) {
            ch.* = empty_channel;
            ch.number = channel;
            ch.active = true;
            sessions[idx].channel_count += 1;
            if (sessions[idx].state == .connected) {
                sessions[idx].state = .channel_open;
            }
            return 0;
        }
    }
    return 1;
}

/// Close a channel. Returns 0 on success, 1 on rejection.
/// May transition ChannelOpen -> Connected if last channel.
pub export fn amqp_channel_close(slot: c_int, channel: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const ci = findChannel(idx, channel) orelse return 1;

    // Cancel all consumers on this channel
    for (&sessions[idx].consumers) |*cons| {
        if (cons.active and cons.channel == channel) {
            cons.active = false;
            cons.tag_len = 0;
            sessions[idx].consumer_count -= 1;
        }
    }

    sessions[idx].channels[ci].active = false;
    sessions[idx].channel_count -= 1;

    // If no channels remain and we're in ChannelOpen/Consuming,
    // transition to Connected
    if (sessions[idx].channel_count == 0) {
        if (sessions[idx].state == .channel_open or
            sessions[idx].state == .consuming)
        {
            sessions[idx].state = .connected;
        }
    } else if (sessions[idx].consumer_count == 0 and
        sessions[idx].state == .consuming)
    {
        sessions[idx].state = .channel_open;
    }

    return 0;
}

/// Returns the number of open channels for a session.
pub export fn amqp_channel_count(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].channel_count;
}

// -- Exchange / Queue / Binding -----------------------------------------------

/// Declare an exchange. Returns 0 on success, 1 on rejection.
pub export fn amqp_exchange_declare(
    slot: c_int,
    channel: u16,
    name_ptr: [*]const u8,
    name_len: u32,
    exch_type: u8,
    durable: u8,
    auto_delete: u8,
    internal: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (findChannel(idx, channel) == null) return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (exch_type > 3) return 1;

    // Check for duplicate exchange name
    const name = name_ptr[0..name_len];
    for (&sessions[idx].exchanges) |*ex| {
        if (ex.active and ex.name_len == name_len and
            std.mem.eql(u8, ex.name[0..ex.name_len], name))
        {
            return 1; // already exists (precondition failed in real AMQP)
        }
    }

    // Find a free exchange slot
    for (&sessions[idx].exchanges) |*ex| {
        if (!ex.active) {
            @memcpy(ex.name[0..name_len], name);
            ex.name_len = name_len;
            ex.exch_type = @enumFromInt(exch_type);
            ex.durable = (durable != 0);
            ex.auto_delete = (auto_delete != 0);
            ex.internal = (internal != 0);
            ex.active = true;
            return 0;
        }
    }
    return 1;
}

/// Declare a queue. Returns 0 on success, 1 on rejection.
/// Validates exclusive+durable constraint: exclusive queues cannot be durable.
pub export fn amqp_queue_declare(
    slot: c_int,
    channel: u16,
    name_ptr: [*]const u8,
    name_len: u32,
    durable: u8,
    exclusive: u8,
    auto_delete: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (findChannel(idx, channel) == null) return 1;
    if (name_len > MAX_NAME_LEN) return 1;

    // Enforce: exclusive queues cannot be durable (matches Idris2 proof)
    if (exclusive != 0 and durable != 0) return 1;

    // Check for duplicate queue name (if name is non-empty)
    if (name_len > 0) {
        const name = name_ptr[0..name_len];
        for (&sessions[idx].queues) |*q| {
            if (q.active and q.name_len == name_len and
                std.mem.eql(u8, q.name[0..q.name_len], name))
            {
                return 1;
            }
        }
    }

    // Find a free queue slot
    for (&sessions[idx].queues) |*q| {
        if (!q.active) {
            if (name_len > 0) {
                @memcpy(q.name[0..name_len], name_ptr[0..name_len]);
            }
            q.name_len = name_len;
            q.durable = (durable != 0);
            q.exclusive = (exclusive != 0);
            q.auto_delete = (auto_delete != 0);
            q.active = true;
            return 0;
        }
    }
    return 1;
}

/// Bind a queue to an exchange with a routing key. Returns 0 on success, 1 on rejection.
pub export fn amqp_queue_bind(
    slot: c_int,
    channel: u16,
    queue_ptr: [*]const u8,
    queue_len: u32,
    exchange_ptr: [*]const u8,
    exchange_len: u32,
    routing_key_ptr: [*]const u8,
    rk_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (findChannel(idx, channel) == null) return 1;
    if (queue_len == 0 or queue_len > MAX_NAME_LEN) return 1;
    if (exchange_len > MAX_NAME_LEN) return 1;
    if (rk_len > MAX_NAME_LEN) return 1;

    // Find a free binding slot
    for (&sessions[idx].bindings) |*b| {
        if (!b.active) {
            @memcpy(b.queue_name[0..queue_len], queue_ptr[0..queue_len]);
            b.queue_len = queue_len;
            if (exchange_len > 0) {
                @memcpy(b.exchange_name[0..exchange_len], exchange_ptr[0..exchange_len]);
            }
            b.exchange_len = exchange_len;
            if (rk_len > 0) {
                @memcpy(b.routing_key[0..rk_len], routing_key_ptr[0..rk_len]);
            }
            b.rk_len = rk_len;
            b.active = true;
            return 0;
        }
    }
    return 1;
}

// -- Basic operations ---------------------------------------------------------

/// Publish a message. Returns 0 on success, 1 on rejection.
pub export fn amqp_basic_publish(
    slot: c_int,
    channel: u16,
    exchange_ptr: [*]const u8,
    exchange_len: u32,
    routing_key_ptr: [*]const u8,
    rk_len: u32,
    body_ptr: [*]const u8,
    body_len: u32,
    delivery_mode: u8,
    priority: u8,
    mandatory: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = body_ptr;
    _ = body_len;
    _ = mandatory;

    const idx = validSlot(slot) orelse return 1;
    if (!canPublishState(sessions[idx].state)) return 1;
    if (findChannel(idx, channel) == null) return 1;
    if (exchange_len > MAX_NAME_LEN) return 1;
    if (rk_len > MAX_NAME_LEN) return 1;
    _ = exchange_ptr;
    _ = routing_key_ptr;
    if (delivery_mode > 1) return 1;
    if (priority > 9) return 1;

    // Track that we had consumers before entering publishing
    sessions[idx].had_consumers_before_publish = (sessions[idx].state == .consuming);
    sessions[idx].state = .publishing;

    return 0;
}

/// Start consuming from a queue. Returns 0 on success, 1 on rejection.
/// Transitions ChannelOpen -> Consuming, or stays Consuming.
pub export fn amqp_basic_consume(
    slot: c_int,
    channel: u16,
    queue_ptr: [*]const u8,
    queue_len: u32,
    consumer_tag_ptr: [*]const u8,
    ct_len: u32,
    no_ack: u8,
    exclusive: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (!canConsumeState(sessions[idx].state)) return 1;
    if (findChannel(idx, channel) == null) return 1;
    if (queue_len == 0 or queue_len > MAX_NAME_LEN) return 1;
    if (ct_len == 0 or ct_len > MAX_NAME_LEN) return 1;

    // Find a free consumer slot
    for (&sessions[idx].consumers) |*cons| {
        if (!cons.active) {
            @memcpy(cons.consumer_tag[0..ct_len], consumer_tag_ptr[0..ct_len]);
            cons.tag_len = ct_len;
            @memcpy(cons.queue_name[0..queue_len], queue_ptr[0..queue_len]);
            cons.queue_len = queue_len;
            cons.channel = channel;
            cons.no_ack = (no_ack != 0);
            cons.exclusive = (exclusive != 0);
            cons.active = true;
            sessions[idx].consumer_count += 1;
            sessions[idx].state = .consuming;
            return 0;
        }
    }
    return 1;
}

/// Cancel a consumer. Returns 0 on success, 1 on rejection.
/// May transition Consuming -> ChannelOpen if last consumer.
pub export fn amqp_basic_cancel(
    slot: c_int,
    channel: u16,
    consumer_tag_ptr: [*]const u8,
    ct_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (findChannel(idx, channel) == null) return 1;
    if (ct_len == 0 or ct_len > MAX_NAME_LEN) return 1;

    const tag = consumer_tag_ptr[0..ct_len];

    for (&sessions[idx].consumers) |*cons| {
        if (cons.active and cons.channel == channel and
            cons.tag_len == ct_len and
            std.mem.eql(u8, cons.consumer_tag[0..cons.tag_len], tag))
        {
            cons.active = false;
            cons.tag_len = 0;
            sessions[idx].consumer_count -= 1;

            if (sessions[idx].consumer_count == 0 and
                sessions[idx].state == .consuming)
            {
                sessions[idx].state = .channel_open;
            }
            return 0;
        }
    }
    return 1;
}

/// Acknowledge a delivery. Returns 0 on success, 1 on rejection.
pub export fn amqp_basic_ack(
    slot: c_int,
    channel: u16,
    delivery_tag: u64,
    multiple: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = delivery_tag;
    _ = multiple;

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .channel_open and state != .consuming and state != .publishing) return 1;
    const ci = findChannel(idx, channel) orelse return 1;

    if (sessions[idx].channels[ci].unacked > 0) {
        sessions[idx].channels[ci].unacked -= 1;
    }

    // If we were publishing and this was the last unacked, maybe exit
    maybeExitPublishing(idx);
    return 0;
}

/// Negative acknowledge (RabbitMQ extension). Returns 0 on success, 1 on rejection.
pub export fn amqp_basic_nack(
    slot: c_int,
    channel: u16,
    delivery_tag: u64,
    multiple: u8,
    requeue: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = delivery_tag;
    _ = multiple;
    _ = requeue;

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .channel_open and state != .consuming and state != .publishing) return 1;
    if (findChannel(idx, channel) == null) return 1;

    return 0;
}

/// Reject a single delivery. Returns 0 on success, 1 on rejection.
pub export fn amqp_basic_reject(
    slot: c_int,
    channel: u16,
    delivery_tag: u64,
    requeue: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = delivery_tag;
    _ = requeue;

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .channel_open and state != .consuming and state != .publishing) return 1;
    if (findChannel(idx, channel) == null) return 1;

    return 0;
}

/// Set QoS (prefetch) for a channel. Returns 0 on success, 1 on rejection.
pub export fn amqp_basic_qos(
    slot: c_int,
    channel: u16,
    prefetch_count: u16,
    prefetch_size: u32,
    global: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const ci = findChannel(idx, channel) orelse return 1;

    sessions[idx].channels[ci].prefetch_count = prefetch_count;
    sessions[idx].channels[ci].prefetch_size = prefetch_size;
    sessions[idx].channels[ci].qos_global = (global != 0);

    return 0;
}

// -- Consumer queries ---------------------------------------------------------

/// Returns the total number of active consumers across all channels.
pub export fn amqp_consumer_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].consumer_count;
}

// -- Disconnect / Cleanup -----------------------------------------------------

/// Disconnect the session. Returns 0 on success, 1 on rejection.
pub export fn amqp_disconnect(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .connected or state == .channel_open or
        state == .consuming or state == .publishing)
    {
        sessions[idx].state = .disconnecting;
        return 0;
    }
    return 1;
}

/// Complete cleanup after disconnect. Returns 0 on success, 1 on rejection.
pub export fn amqp_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .disconnecting) return 1;

    // Clear all session state
    sessions[idx].state = .idle;
    sessions[idx].channels = [_]Channel{empty_channel} ** MAX_CHANNELS;
    sessions[idx].channel_count = 0;
    sessions[idx].exchanges = [_]ExchangeEntry{empty_exchange} ** MAX_EXCHANGES;
    sessions[idx].queues = [_]QueueEntry{empty_queue} ** MAX_QUEUES;
    sessions[idx].bindings = [_]BindingEntry{empty_binding} ** MAX_BINDINGS;
    sessions[idx].consumers = [_]ConsumerEntry{empty_consumer} ** MAX_CONSUMERS;
    sessions[idx].consumer_count = 0;

    return 0;
}

/// If all in-flight work is done, exit Publishing state.
fn maybeExitPublishing(idx: usize) void {
    if (sessions[idx].state != .publishing) return;
    // Simple heuristic: check if any channels have unacked deliveries
    var any_unacked = false;
    for (&sessions[idx].channels) |*ch| {
        if (ch.active and ch.unacked > 0) {
            any_unacked = true;
            break;
        }
    }
    if (!any_unacked) {
        if (sessions[idx].had_consumers_before_publish) {
            sessions[idx].state = .consuming;
        } else {
            sessions[idx].state = .channel_open;
        }
    }
}

// -- Stateless transition tables ----------------------------------------------

/// Check if a broker state transition is valid (matches Transitions.idr).
pub export fn amqp_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Connected
    if (from == 1 and to == 2) return 1; // Connected -> ChannelOpen
    if (from == 2 and to == 2) return 1; // ChannelOpen -> ChannelOpen
    if (from == 2 and to == 1) return 1; // ChannelOpen -> Connected (all closed)
    if (from == 2 and to == 3) return 1; // ChannelOpen -> Consuming
    if (from == 3 and to == 3) return 1; // Consuming -> Consuming
    if (from == 3 and to == 2) return 1; // Consuming -> ChannelOpen (all cancelled)
    if (from == 2 and to == 4) return 1; // ChannelOpen -> Publishing
    if (from == 3 and to == 4) return 1; // Consuming -> Publishing
    if (from == 4 and to == 2) return 1; // Publishing -> ChannelOpen (done, no cons)
    if (from == 4 and to == 3) return 1; // Publishing -> Consuming (done, has cons)
    if (from == 1 and to == 5) return 1; // Connected -> Disconnecting
    if (from == 2 and to == 5) return 1; // ChannelOpen -> Disconnecting
    if (from == 3 and to == 5) return 1; // Consuming -> Disconnecting
    if (from == 4 and to == 5) return 1; // Publishing -> Disconnecting
    if (from == 5 and to == 0) return 1; // Disconnecting -> Idle
    return 0;
}

/// Match a routing key against a pattern, given exchange type.
/// Exchange type: 0=direct, 1=fanout, 2=topic, 3=headers.
/// Returns 1 on match, 0 on no match.
pub export fn amqp_routing_match(
    routing_key_ptr: [*]const u8,
    rk_len: u32,
    pattern_ptr: [*]const u8,
    pat_len: u32,
    exch_type: u8,
) callconv(.c) u8 {
    if (exch_type == 1) return 1; // fanout: always match

    if (rk_len > MAX_NAME_LEN or pat_len > MAX_NAME_LEN) return 0;

    const rk = routing_key_ptr[0..rk_len];
    const pat = pattern_ptr[0..pat_len];

    if (exch_type == 0) {
        // direct: exact match
        if (rk_len != pat_len) return 0;
        return if (std.mem.eql(u8, rk, pat)) 1 else 0;
    }

    if (exch_type == 2) {
        // topic: wildcard matching
        return if (topicMatch(rk, pat)) 1 else 0;
    }

    // headers (3) and unknown: no routing key matching (headers use header table)
    return 0;
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
