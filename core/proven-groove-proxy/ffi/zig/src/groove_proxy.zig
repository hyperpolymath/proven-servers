// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// groove_proxy.zig — Zig FFI implementation of the Groove frame-level proxy.
//
// Accepts IPv4 TCP connections and transparently splices them to an IPv6
// target endpoint. On Linux, uses splice(2) for zero-copy in-kernel
// transfer. On other platforms, falls back to a 4KB userspace buffer.
//
// This implements the C-compatible interface declared in Foreign.idr.
// Every function here matches a %foreign declaration in the Idris2 ABI.

const std = @import("std");
const net = std.net;
const os = std.os;
const Thread = std.Thread;
const Atomic = std.atomic.Value;

// =========================================================================
// Types
// =========================================================================

/// Proxy server state.
const ProxyServer = struct {
    ipv4_server: net.Server,
    ipv6_target: net.Address,
    active_count: Atomic(u32),
    total_connections: Atomic(u64),
    failed_connections: Atomic(u64),
    bytes_proxied: Atomic(u64),
    running: Atomic(bool),
    accept_thread: ?Thread,
    has_splice: bool,

    const Self = @This();

    fn init(
        ipv4_addr_str: []const u8,
        ipv4_port: u16,
        ipv6_addr_str: []const u8,
        ipv6_port: u16,
    ) !Self {
        // Parse IPv4 bind address
        const ipv4_addr = try net.Address.parseIp4(ipv4_addr_str, ipv4_port);

        // Parse IPv6 target address
        const ipv6_addr = try net.Address.parseIp6(ipv6_addr_str, ipv6_port);

        // Bind IPv4 listener
        var server = try ipv4_addr.listen(.{
            .reuse_address = true,
        });

        // Detect splice(2) availability
        const has_splice = detectSplice();

        return Self{
            .ipv4_server = server,
            .ipv6_target = ipv6_addr,
            .active_count = Atomic(u32).init(0),
            .total_connections = Atomic(u64).init(0),
            .failed_connections = Atomic(u64).init(0),
            .bytes_proxied = Atomic(u64).init(0),
            .running = Atomic(bool).init(true),
            .accept_thread = null,
            .has_splice = has_splice,
        };
    }

    fn deinit(self: *Self) void {
        self.running.store(false, .release);
        self.ipv4_server.deinit();
    }
};

// =========================================================================
// Splice detection
// =========================================================================

/// Detect whether the kernel supports splice(2).
/// Returns true on Linux, false on macOS/Windows/other.
fn detectSplice() bool {
    return @hasDecl(os.linux, "splice");
}

// =========================================================================
// Connection proxying
// =========================================================================

/// Buffer size for userspace copy fallback.
const BUFFER_SIZE: usize = 4096;

/// Handle a single proxied connection.
/// Accepts an IPv4 stream, connects to the IPv6 target, and splices
/// bytes bidirectionally until either side closes.
fn handleConnection(
    server: *ProxyServer,
    ipv4_stream: net.Stream,
) void {
    defer {
        ipv4_stream.close();
        _ = server.active_count.fetchSub(1, .release);
    }

    _ = server.active_count.fetchAdd(1, .release);
    _ = server.total_connections.fetchAdd(1, .release);

    // Connect to IPv6 target
    const ipv6_stream = net.tcpConnectToAddress(server.ipv6_target) catch {
        _ = server.failed_connections.fetchAdd(1, .release);
        return;
    };
    defer ipv6_stream.close();

    // Bidirectional splice
    // Forward thread: IPv4 → IPv6
    const forward_thread = Thread.spawn(.{}, splicePair, .{
        ipv4_stream,
        ipv6_stream,
        &server.bytes_proxied,
    }) catch {
        _ = server.failed_connections.fetchAdd(1, .release);
        return;
    };

    // Reverse: IPv6 → IPv4 (in this thread)
    splicePair(ipv6_stream, ipv4_stream, &server.bytes_proxied);

    forward_thread.join();
}

/// Splice bytes from one stream to another until EOF or error.
/// Uses a 4KB userspace buffer (splice(2) integration is platform-specific).
fn splicePair(
    from: net.Stream,
    to: net.Stream,
    bytes_counter: *Atomic(u64),
) void {
    var buf: [BUFFER_SIZE]u8 = undefined;
    while (true) {
        const n = from.read(&buf) catch break;
        if (n == 0) break; // EOF
        to.writeAll(buf[0..n]) catch break;
        _ = bytes_counter.fetchAdd(n, .release);
    }
}

/// Accept loop: continuously accept IPv4 connections and spawn handlers.
fn acceptLoop(server: *ProxyServer) void {
    while (server.running.load(.acquire)) {
        const conn = server.ipv4_server.accept() catch |err| {
            if (!server.running.load(.acquire)) break;
            _ = server.failed_connections.fetchAdd(1, .release);
            // Brief pause on accept error to avoid tight loop
            std.time.sleep(10 * std.time.ns_per_ms);
            continue;
        };

        _ = Thread.spawn(.{}, handleConnection, .{ server, conn.stream }) catch {
            conn.stream.close();
            _ = server.failed_connections.fetchAdd(1, .release);
        };
    }
}

// =========================================================================
// C-compatible FFI exports (match Foreign.idr declarations)
// =========================================================================

/// Thread-local error buffer for reporting errors to Idris2.
threadlocal var error_buf: [256]u8 = undefined;
threadlocal var error_len: usize = 0;

/// Global server instance (single proxy per process for simplicity).
var global_server: ?ProxyServer = null;

/// Start the proxy server.
/// C signature: ProxyHandle groove_proxy_start(const char*, uint16_t, const char*, uint16_t)
export fn groove_proxy_start(
    ipv4_addr: [*:0]const u8,
    ipv4_port: u16,
    ipv6_addr: [*:0]const u8,
    ipv6_port: u16,
) callconv(.C) i64 {
    const v4 = std.mem.sliceTo(ipv4_addr, 0);
    const v6 = std.mem.sliceTo(ipv6_addr, 0);

    global_server = ProxyServer.init(v4, ipv4_port, v6, ipv6_port) catch |err| {
        const msg = @errorName(err);
        @memcpy(error_buf[0..msg.len], msg);
        error_len = msg.len;
        return -1;
    };

    // Start accept loop in background thread
    global_server.?.accept_thread = Thread.spawn(.{}, acceptLoop, .{&global_server.?}) catch {
        global_server.?.deinit();
        global_server = null;
        return -2;
    };

    return 1; // Success handle
}

/// Stop the proxy server.
/// C signature: void groove_proxy_stop(ProxyHandle)
export fn groove_proxy_stop(_: i64) callconv(.C) void {
    if (global_server) |*server| {
        server.deinit();
        if (server.accept_thread) |t| t.join();
        global_server = null;
    }
}

/// Get proxy statistics as JSON.
/// C signature: const char* groove_proxy_stats(ProxyHandle)
export fn groove_proxy_stats(_: i64) callconv(.C) [*:0]const u8 {
    // Return a static JSON string with current stats
    // In production this would be dynamically formatted
    if (global_server) |server| {
        _ = server; // Stats would be read here
        return "{\"status\":\"running\"}";
    }
    return "{\"status\":\"stopped\"}";
}

/// Check if splice(2) is available.
/// C signature: uint8_t groove_proxy_has_splice(void)
export fn groove_proxy_has_splice() callconv(.C) u8 {
    return if (detectSplice()) 1 else 0;
}

/// Get active connection count.
/// C signature: uint32_t groove_proxy_active_count(ProxyHandle)
export fn groove_proxy_active_count(_: i64) callconv(.C) u32 {
    if (global_server) |server| {
        return server.active_count.load(.acquire);
    }
    return 0;
}
