// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// main.zig — proven-nesy REST adapter server.
//
// Replaces: proven-servers/protocols/proven-nesy/adapter/nesy_adapter.v
//
// Routes:
//   GET  /health                   — protocol + domain type inventory
//   GET  /types                    — list type family names
//   POST /sessions                 — create new NeSy session
//   GET  /sessions/:id             — get session state
//   GET  /drift/analyze/:kind      — drift analysis + recommended action
//   GET  /confidence/:level        — confidence level metadata
//   GET  /reasoning-modes/:mode    — reasoning mode metadata
//   GET  /graphql/schema           — GraphQL SDL
//
// Environment:
//   NESY_PORT   (default 8401)

const std = @import("std");

// =============================================================================
// Domain types  (mirrors nesy_adapter.v enums)
// =============================================================================

pub const ReasoningMode = enum(u8) {
    symbolic      = 0,
    neural        = 1,
    sym_to_neural = 2,
    neural_to_sym = 3,
    ensemble      = 4,
    cascade       = 5,

    pub fn str(self: ReasoningMode) []const u8 {
        return switch (self) {
            .symbolic      => "Symbolic",
            .neural        => "Neural",
            .sym_to_neural => "SymToNeural",
            .neural_to_sym => "NeuralToSym",
            .ensemble      => "Ensemble",
            .cascade       => "Cascade",
        };
    }

    pub fn usesSymbolic(self: ReasoningMode) bool { return self != .neural; }
    pub fn usesNeural(self: ReasoningMode) bool   { return self != .symbolic; }
    pub fn isHybrid(self: ReasoningMode) bool     { return self.usesSymbolic() and self.usesNeural(); }

    pub fn parse(s: []const u8) ?ReasoningMode {
        if (std.mem.eql(u8, s, "symbolic"))                             return .symbolic;
        if (std.mem.eql(u8, s, "neural"))                               return .neural;
        if (std.mem.eql(u8, s, "symtoneural") or
            std.mem.eql(u8, s, "sym_to_neural"))                        return .sym_to_neural;
        if (std.mem.eql(u8, s, "neuraltosym") or
            std.mem.eql(u8, s, "neural_to_sym"))                        return .neural_to_sym;
        if (std.mem.eql(u8, s, "ensemble"))                             return .ensemble;
        if (std.mem.eql(u8, s, "cascade"))                              return .cascade;
        return null;
    }
};

pub const Confidence = enum(u8) {
    verified       = 0,
    high_neural    = 1,
    medium_neural  = 2,
    low_neural     = 3,
    unknown        = 4,
    contradicted   = 5,

    pub fn str(self: Confidence) []const u8 {
        return switch (self) {
            .verified      => "Verified",
            .high_neural   => "HighNeural",
            .medium_neural => "MediumNeural",
            .low_neural    => "LowNeural",
            .unknown       => "Unknown",
            .contradicted  => "Contradicted",
        };
    }

    pub fn score(self: Confidence) f32 {
        return switch (self) {
            .verified      => 1.0,
            .high_neural   => 0.95,
            .medium_neural => 0.80,
            .low_neural    => 0.50,
            .unknown       => 0.0,
            .contradicted  => 0.0,
        };
    }

    pub fn isActionable(self: Confidence) bool {
        return switch (self) {
            .verified, .high_neural, .medium_neural => true,
            .low_neural, .unknown, .contradicted    => false,
        };
    }

    pub fn parse(s: []const u8) ?Confidence {
        if (std.mem.eql(u8, s, "verified"))                                  return .verified;
        if (std.mem.eql(u8, s, "highneural") or
            std.mem.eql(u8, s, "high_neural"))                               return .high_neural;
        if (std.mem.eql(u8, s, "mediumneural") or
            std.mem.eql(u8, s, "medium_neural"))                             return .medium_neural;
        if (std.mem.eql(u8, s, "lowneural") or
            std.mem.eql(u8, s, "low_neural"))                                return .low_neural;
        if (std.mem.eql(u8, s, "unknown"))                                   return .unknown;
        if (std.mem.eql(u8, s, "contradicted"))                              return .contradicted;
        return null;
    }
};

pub const DriftKind = enum(u8) {
    no_drift         = 0,
    semantic_drift   = 1,
    confidence_drift = 2,
    factual_drift    = 3,
    temporal_drift   = 4,
    catastrophic_drift = 5,

    pub fn str(self: DriftKind) []const u8 {
        return switch (self) {
            .no_drift          => "NoDrift",
            .semantic_drift    => "SemanticDrift",
            .confidence_drift  => "ConfidenceDrift",
            .factual_drift     => "FactualDrift",
            .temporal_drift    => "TemporalDrift",
            .catastrophic_drift => "CatastrophicDrift",
        };
    }

    pub fn isUrgent(self: DriftKind) bool {
        return self == .factual_drift or self == .catastrophic_drift;
    }

    pub fn parse(s: []const u8) ?DriftKind {
        if (std.mem.eql(u8, s, "nodrift") or
            std.mem.eql(u8, s, "no_drift") or
            std.mem.eql(u8, s, "none"))                                   return .no_drift;
        if (std.mem.eql(u8, s, "semanticdrift") or
            std.mem.eql(u8, s, "semantic_drift") or
            std.mem.eql(u8, s, "semantic"))                               return .semantic_drift;
        if (std.mem.eql(u8, s, "confidencedrift") or
            std.mem.eql(u8, s, "confidence_drift") or
            std.mem.eql(u8, s, "confidence"))                             return .confidence_drift;
        if (std.mem.eql(u8, s, "factualdrift") or
            std.mem.eql(u8, s, "factual_drift") or
            std.mem.eql(u8, s, "factual"))                                return .factual_drift;
        if (std.mem.eql(u8, s, "temporaldrift") or
            std.mem.eql(u8, s, "temporal_drift") or
            std.mem.eql(u8, s, "temporal"))                               return .temporal_drift;
        if (std.mem.eql(u8, s, "catastrophicdrift") or
            std.mem.eql(u8, s, "catastrophic_drift") or
            std.mem.eql(u8, s, "catastrophic"))                           return .catastrophic_drift;
        return null;
    }
};

/// Pure function: map drift kind to recommended action (mirrors recommend_drift_action).
pub fn recommendDriftAction(drift: DriftKind) []const u8 {
    return switch (drift) {
        .no_drift          => "LogAndAccept",
        .semantic_drift    => "LogAndAccept",
        .confidence_drift  => "FlagForReview",
        .factual_drift     => "RejectNeural",
        .temporal_drift    => "RetryNeural",
        .catastrophic_drift => "Halt",
    };
}

// =============================================================================
// In-memory session store
// =============================================================================

const MAX_SESSIONS: usize = 1024;

const NeSySession = struct {
    session_id:      u32,
    mode:            []const u8,
    confidence:      []const u8,
    drift:           []const u8,
    merge_strategy:  []const u8,
    proof_status:    []const u8,
    grounding:       []const u8,
};

var sessions_mutex: std.Thread.Mutex       = .{};
var sessions: [MAX_SESSIONS]?NeSySession   = [_]?NeSySession{null} ** MAX_SESSIONS;
var session_count: u32                     = 0;

fn createSession() NeSySession {
    const id = @atomicRmw(u32, &session_count, .Add, 1, .monotonic);
    return .{
        .session_id     = id,
        .mode           = "Symbolic",
        .confidence     = "Unknown",
        .drift          = "NoDrift",
        .merge_strategy = "SymbolicPrimacy",
        .proof_status   = "Pending",
        .grounding      = "Ungrounded",
    };
}

// =============================================================================
// HTTP helpers
// =============================================================================

fn readLine(stream: std.net.Stream, buf: []u8) ![]const u8 {
    var pos: usize = 0;
    while (pos < buf.len) {
        const n = try stream.read(buf[pos..][0..1]);
        if (n == 0) break;
        if (buf[pos] == '\n') {
            const end = if (pos > 0 and buf[pos - 1] == '\r') pos - 1 else pos;
            return buf[0..end];
        }
        pos += 1;
    }
    return buf[0..pos];
}

fn writeResponse(conn: *std.net.Server.Connection, status: u16, body: []const u8) void {
    var h: [256]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&h);
    fbs.writer().print(
        "HTTP/1.1 {d} \r\nContent-Type: application/json\r\nContent-Length: {d}\r\n" ++
        "Access-Control-Allow-Origin: *\r\nConnection: close\r\n\r\n",
        .{ status, body.len },
    ) catch return;
    conn.stream.writeAll(fbs.getWritten()) catch return;
    conn.stream.writeAll(body) catch return;
}

fn writeError(conn: *std.net.Server.Connection, status: u16, msg: []const u8) void {
    var buf: [256]u8 = undefined;
    const body = std.fmt.bufPrint(&buf, "{{\"error\":\"{s}\"}}", .{msg}) catch
        "{\"error\":\"error\"}";
    writeResponse(conn, status, body);
}

// =============================================================================
// Route handlers
// =============================================================================

fn handleHealth(conn: *std.net.Server.Connection) void {
    writeResponse(conn, 200,
        \\{"protocol":"proven-nesy","version":"0.1.0","status":"ok","types":[
        ++ \\{"name":"ReasoningMode","variants":["Symbolic","Neural","SymToNeural","NeuralToSym","Ensemble","Cascade"]},
        ++ \\{"name":"ProofStatus","variants":["Pending","Attempting","Proved","Failed","Assumed","Vacuous"]},
        ++ \\{"name":"ConstraintKind","variants":["TypeEquality","Subtype","Linearity","Termination","Totality","Invariant","Refinement","DependentIndex"]},
        ++ \\{"name":"NeuralBackend","variants":["LocalModel","Claude","Gemini","Mistral","GPT","CustomNeural"]},
        ++ \\{"name":"Confidence","variants":["Verified","HighNeural","MediumNeural","LowNeural","Unknown","Contradicted"]},
        ++ \\{"name":"DriftKind","variants":["NoDrift","SemanticDrift","ConfidenceDrift","FactualDrift","TemporalDrift","CatastrophicDrift"]},
        ++ \\{"name":"MergeStrategy","variants":["SymbolicPrimacy","NeuralPrimacy","ConfidenceWeighted","Consensus","DualReturn","ConstrainedGeneration"]},
        ++ \\{"name":"DriftAction","variants":["LogAndAccept","FlagForReview","RejectNeural","RetryNeural","Escalate","Halt"]},
        ++ \\{"name":"GroundingStatus","variants":["FullyGrounded","PartiallyGrounded","Ungrounded","GroundingPending","GroundingFailed"]}
        ++ \\]}
    );
}

fn handleTypes(conn: *std.net.Server.Connection) void {
    writeResponse(conn, 200,
        \\["ReasoningMode","ProofStatus","ConstraintKind","NeuralBackend","Confidence","DriftKind","MergeStrategy","DriftAction","GroundingStatus"]
    );
}

fn sessionJson(s: NeSySession, buf: []u8) ![]const u8 {
    return std.fmt.bufPrint(
        buf,
        \\{{"session_id":{d},"mode":"{s}","confidence":"{s}","drift":"{s}","merge_strategy":"{s}","proof_status":"{s}","grounding":"{s}"}}
        ,
        .{ s.session_id, s.mode, s.confidence, s.drift, s.merge_strategy, s.proof_status, s.grounding },
    );
}

fn handleCreateSession(conn: *std.net.Server.Connection) void {
    const session = createSession();
    sessions_mutex.lock();
    sessions[session.session_id % MAX_SESSIONS] = session;
    sessions_mutex.unlock();

    var buf: [512]u8 = undefined;
    const body = sessionJson(session, &buf) catch return writeError(conn, 500, "json encode failed");
    writeResponse(conn, 201, body);
}

fn handleGetSession(conn: *std.net.Server.Connection, id_str: []const u8) void {
    const id = std.fmt.parseInt(u32, id_str, 10) catch
        return writeError(conn, 400, "invalid session id");

    sessions_mutex.lock();
    const maybe = sessions[id % MAX_SESSIONS];
    sessions_mutex.unlock();

    const s = maybe orelse return writeError(conn, 404, "session not found");
    if (s.session_id != id) return writeError(conn, 404, "session not found");

    var buf: [512]u8 = undefined;
    const body = sessionJson(s, &buf) catch return writeError(conn, 500, "json encode failed");
    writeResponse(conn, 200, body);
}

fn handleAnalyzeDrift(conn: *std.net.Server.Connection, kind_str: []const u8) void {
    var lbuf: [32]u8 = undefined;
    const llen = @min(kind_str.len, 32);
    const lower = std.ascii.lowerString(lbuf[0..llen], kind_str[0..llen]);
    const dk = DriftKind.parse(lower) orelse
        return writeError(conn, 400, "unknown drift kind");

    const action = recommendDriftAction(dk);
    const severity: u8 = @intFromEnum(dk);

    var buf: [512]u8 = undefined;
    const body = std.fmt.bufPrint(
        &buf,
        \\{{"drift":"{s}","severity":{d},"urgent":{s},"recommended_action":"{s}"}}
        ,
        .{ dk.str(), severity, if (dk.isUrgent()) "true" else "false", action },
    ) catch return writeError(conn, 500, "json encode failed");
    writeResponse(conn, 200, body);
}

fn handleConfidenceInfo(conn: *std.net.Server.Connection, level_str: []const u8) void {
    var lbuf: [32]u8 = undefined;
    const llen = @min(level_str.len, 32);
    const lower = std.ascii.lowerString(lbuf[0..llen], level_str[0..llen]);
    const conf = Confidence.parse(lower) orelse
        return writeError(conn, 400, "unknown confidence level");

    var buf: [256]u8 = undefined;
    const body = std.fmt.bufPrint(
        &buf,
        \\{{"level":"{s}","score":{d:.2},"actionable":{s}}}
        ,
        .{ conf.str(), conf.score(), if (conf.isActionable()) "true" else "false" },
    ) catch return writeError(conn, 500, "json encode failed");
    writeResponse(conn, 200, body);
}

fn handleReasoningMode(conn: *std.net.Server.Connection, mode_str: []const u8) void {
    var lbuf: [32]u8 = undefined;
    const llen = @min(mode_str.len, 32);
    const lower = std.ascii.lowerString(lbuf[0..llen], mode_str[0..llen]);
    const rm = ReasoningMode.parse(lower) orelse
        return writeError(conn, 400, "unknown reasoning mode");

    var buf: [256]u8 = undefined;
    const body = std.fmt.bufPrint(
        &buf,
        \\{{"mode":"{s}","uses_symbolic":{s},"uses_neural":{s},"is_hybrid":{s}}}
        ,
        .{
            rm.str(),
            if (rm.usesSymbolic()) "true" else "false",
            if (rm.usesNeural()) "true" else "false",
            if (rm.isHybrid()) "true" else "false",
        },
    ) catch return writeError(conn, 500, "json encode failed");
    writeResponse(conn, 200, body);
}

// =============================================================================
// Dispatcher
// =============================================================================

fn serveRequest(conn: *std.net.Server.Connection, allocator: std.mem.Allocator) void {
    var req_line_buf: [1024]u8 = undefined;
    const req_line = readLine(conn.stream, &req_line_buf) catch return;

    var parts = std.mem.splitScalar(u8, req_line, ' ');
    const method = parts.next() orelse return;
    const path   = parts.next() orelse return;

    // Drain headers.
    var h_buf: [512]u8 = undefined;
    while (true) {
        const line = readLine(conn.stream, &h_buf) catch break;
        if (line.len == 0) break;
    }
    _ = allocator;

    const is_get  = std.mem.eql(u8, method, "GET");
    const is_post = std.mem.eql(u8, method, "POST");
    const is_opts = std.mem.eql(u8, method, "OPTIONS");

    if (is_opts) {
        writeResponse(conn, 204, "");
    } else if (is_get and std.mem.eql(u8, path, "/health")) {
        handleHealth(conn);
    } else if (is_get and std.mem.eql(u8, path, "/types")) {
        handleTypes(conn);
    } else if (is_post and std.mem.eql(u8, path, "/sessions")) {
        handleCreateSession(conn);
    } else if (is_get and std.mem.startsWith(u8, path, "/sessions/")) {
        handleGetSession(conn, path["/sessions/".len..]);
    } else if (is_get and std.mem.startsWith(u8, path, "/drift/analyze/")) {
        handleAnalyzeDrift(conn, path["/drift/analyze/".len..]);
    } else if (is_get and std.mem.startsWith(u8, path, "/confidence/")) {
        handleConfidenceInfo(conn, path["/confidence/".len..]);
    } else if (is_get and std.mem.startsWith(u8, path, "/reasoning-modes/")) {
        handleReasoningMode(conn, path["/reasoning-modes/".len..]);
    } else if (is_get and std.mem.eql(u8, path, "/graphql/schema")) {
        const SCHEMA =
            \\type Query {
            \\  health: Health!
            \\  types: [TypeInfo!]!
            \\  session(id: Int!): NeSySession
            \\  analyzeDrift(kind: String!): DriftReport!
            \\  confidenceInfo(level: String!): ConfidenceReport!
            \\  reasoningMode(mode: String!): ReasoningModeReport!
            \\}
        ;
        var h: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&h);
        fbs.writer().print(
            "HTTP/1.1 200 \r\nContent-Type: text/plain\r\nContent-Length: {d}\r\nConnection: close\r\n\r\n",
            .{SCHEMA.len},
        ) catch return;
        conn.stream.writeAll(fbs.getWritten()) catch return;
        conn.stream.writeAll(SCHEMA) catch return;
    } else {
        writeError(conn, 404, "not found");
    }
}

// =============================================================================
// Entry point
// =============================================================================

const ConnArgs = struct {
    conn:  std.net.Server.Connection,
    alloc: std.mem.Allocator,
};

fn handleConnection(args: ConnArgs) void {
    var conn = args.conn;
    defer conn.stream.close();
    var arena = std.heap.ArenaAllocator.init(args.alloc);
    defer arena.deinit();
    serveRequest(&conn, arena.allocator());
}

pub fn main() !void {
    var gpa_inst = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_inst.deinit();
    const gpa = gpa_inst.allocator();

    const port_str = std.posix.getenv("NESY_PORT") orelse "8401";
    const port = std.fmt.parseInt(u16, port_str, 10) catch 8401;

    const addr = try std.net.Address.parseIp4("0.0.0.0", port);
    var server = try addr.listen(.{ .reuse_address = true });
    defer server.deinit();

    std.debug.print("proven-nesy adapter 0.1.0  port={d}\n", .{port});

    while (true) {
        const conn = try server.accept();
        const thread = try std.Thread.spawn(.{}, handleConnection, .{ConnArgs{
            .conn  = conn,
            .alloc = gpa,
        }});
        thread.detach();
    }
}
