// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// queueconn.zig — Zig FFI implementation for proven-queueconn.
//
// Skeleton implementation enforcing the queue connection state machine.

const std = @import("std");

pub const ABI_VERSION: u32 = 1;
pub const MAX_MESSAGE_SIZE: u32 = 1048576;
pub const DEFAULT_PREFETCH: u16 = 10;
pub const ACK_TIMEOUT: u32 = 30;

pub const QueueOp = enum(u8) {
    publish = 0,
    subscribe = 1,
    acknowledge = 2,
    reject = 3,
    peek = 4,
    purge = 5,
};

pub const DeliveryGuarantee = enum(u8) {
    at_most_once = 0,
    at_least_once = 1,
    exactly_once = 2,
};

pub const QueueState = enum(u8) {
    disconnected = 0,
    connected = 1,
    consuming = 2,
    producing = 3,
    failed = 4,
};

pub const MessageState = enum(u8) {
    pending = 0,
    delivered = 1,
    acknowledged = 2,
    rejected = 3,
    dead_lettered = 4,
    expired = 5,
};

pub const QueueError = enum(u8) {
    none = 0,
    connection_lost = 1,
    queue_not_found = 2,
    message_too_large = 3,
    quota_exceeded = 4,
    ack_timeout = 5,
    unauthorized = 6,
    serialization_error = 7,
};

pub const QueueHandle = struct {
    state: QueueState,
    guarantee: DeliveryGuarantee,
    port: u16,
};

pub const MessageHandle = struct {
    conn: *QueueHandle,
    state: MessageState,
};

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub export fn queueconn_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
}

pub export fn queueconn_connect(
    host: ?[*:0]const u8,
    port: u16,
    guarantee: DeliveryGuarantee,
    err: *QueueError,
) callconv(.c) ?*QueueHandle {
    _ = host;
    const handle = allocator.create(QueueHandle) catch {
        err.* = QueueError.connection_lost;
        return null;
    };
    handle.* = QueueHandle{
        .state = QueueState.connected,
        .guarantee = guarantee,
        .port = port,
    };
    err.* = QueueError.none;
    return handle;
}

pub export fn queueconn_disconnect(h: ?*QueueHandle) callconv(.c) QueueError {
    const handle = h orelse return QueueError.connection_lost;
    switch (handle.state) {
        .connected, .consuming, .producing => {
            handle.state = QueueState.disconnected;
            allocator.destroy(handle);
            return QueueError.none;
        },
        .disconnected, .failed => return QueueError.connection_lost,
    }
}

pub export fn queueconn_state(h: ?*const QueueHandle) callconv(.c) QueueState {
    const handle = h orelse return QueueState.disconnected;
    return handle.state;
}

pub export fn queueconn_subscribe(
    h: ?*QueueHandle,
    queue: ?[*]const u8,
    queue_len: u32,
) callconv(.c) QueueError {
    const handle = h orelse return QueueError.connection_lost;
    _ = queue;
    _ = queue_len;
    switch (handle.state) {
        .connected => {
            handle.state = QueueState.consuming;
            return QueueError.none;
        },
        .consuming => return QueueError.connection_lost, // already consuming
        .producing => return QueueError.connection_lost, // must stop producing first
        .disconnected, .failed => return QueueError.connection_lost,
    }
}

pub export fn queueconn_unsubscribe(h: ?*QueueHandle) callconv(.c) QueueError {
    const handle = h orelse return QueueError.connection_lost;
    switch (handle.state) {
        .consuming => {
            handle.state = QueueState.connected;
            return QueueError.none;
        },
        .connected, .producing => return QueueError.connection_lost,
        .disconnected, .failed => return QueueError.connection_lost,
    }
}

pub export fn queueconn_publish(
    h: ?*QueueHandle,
    queue: ?[*]const u8,
    queue_len: u32,
    body: ?*const anyopaque,
    body_len: u32,
) callconv(.c) QueueError {
    const handle = h orelse return QueueError.connection_lost;
    _ = queue;
    _ = queue_len;
    _ = body;
    switch (handle.state) {
        .connected => {
            if (body_len > MAX_MESSAGE_SIZE) return QueueError.message_too_large;
            // Skeleton: briefly enter producing, then back to connected
            handle.state = QueueState.producing;
            handle.state = QueueState.connected;
            return QueueError.none;
        },
        .consuming, .producing => return QueueError.connection_lost,
        .disconnected, .failed => return QueueError.connection_lost,
    }
}

pub export fn queueconn_receive(
    h: ?*QueueHandle,
    err: *QueueError,
) callconv(.c) ?*MessageHandle {
    const handle = h orelse {
        err.* = QueueError.connection_lost;
        return null;
    };
    switch (handle.state) {
        .consuming => {
            const msg = allocator.create(MessageHandle) catch {
                err.* = QueueError.connection_lost;
                return null;
            };
            msg.* = MessageHandle{
                .conn = handle,
                .state = MessageState.delivered,
            };
            err.* = QueueError.none;
            return msg;
        },
        else => {
            err.* = QueueError.connection_lost;
            return null;
        },
    }
}

pub export fn queueconn_acknowledge(m: ?*MessageHandle) callconv(.c) QueueError {
    const msg = m orelse return QueueError.connection_lost;
    switch (msg.state) {
        .delivered => {
            msg.state = MessageState.acknowledged;
            return QueueError.none;
        },
        else => return QueueError.connection_lost,
    }
}

pub export fn queueconn_reject(m: ?*MessageHandle, requeue: u8) callconv(.c) QueueError {
    const msg = m orelse return QueueError.connection_lost;
    _ = requeue;
    switch (msg.state) {
        .delivered => {
            msg.state = MessageState.rejected;
            return QueueError.none;
        },
        else => return QueueError.connection_lost,
    }
}

pub export fn queueconn_message_state(m: ?*const MessageHandle) callconv(.c) MessageState {
    const msg = m orelse return MessageState.expired;
    return msg.state;
}

pub export fn queueconn_message_free(m: ?*MessageHandle) callconv(.c) void {
    const msg = m orelse return;
    allocator.destroy(msg);
}
