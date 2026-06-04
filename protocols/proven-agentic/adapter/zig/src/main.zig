// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// main.zig — proven-agentic REST adapter server.
//
// Replaces: proven-servers/protocols/proven-agentic/adapter/agentic_adapter.v
//
// Routes (all under configurable base port, default 8400):
//   GET  /health                        — protocol + domain type inventory
//   GET  /types                         — list type family names
//   POST /agents                        — create new agent context
//   GET  /agents/:id                    — get agent state
//   POST /agents/:id/transition         — attempt OODA state transition
//   GET  /tool-calls/:kind              — tool call metadata
//   GET  /safety-checks/:outcome        — safety check metadata
//   GET  /graphql/schema                — GraphQL SDL
//   GET  /proto                         — proto3 service definition
//
// Environment:
//   AGENTIC_PORT   (default 8400)

const std = @import("std");

// =============================================================================
// Domain types  (mirrors agentic_adapter.v enums)
// =============================================================================

pub const AgentState = enum(u8) {
    idle       = 0,
    planning   = 1,
    acting     = 2,
    observing  = 3,
    reflecting = 4,
    blocked    = 5,
    terminated = 6,

    pub fn str(self: AgentState) []const u8 {
        return switch (self) {
            .idle       => "Idle",
            .planning   => "Planning",
            .acting     => "Acting",
            .observing  => "Observing",
            .reflecting => "Reflecting",
            .blocked    => "Blocked",
            .terminated => "Terminated",
        };
    }

    /// OODA-loop valid transitions.
    pub fn canTransition(self: AgentState, to: AgentState) bool {
        return switch (self) {
            .idle       => to == .planning  or to == .terminated,
            .planning   => to == .acting    or to == .blocked    or to == .terminated,
            .acting     => to == .observing or to == .blocked    or to == .terminated,
            .observing  => to == .reflecting or to == .blocked   or to == .terminated,
            .reflecting => to == .planning  or to == .acting     or to == .idle or to == .terminated,
            .blocked    => to == .planning  or to == .acting     or to == .idle or to == .terminated,
            .terminated => false,
        };
    }

    pub fn parse(s: []const u8) ?AgentState {
        if (std.mem.eql(u8, s, "idle"))       return .idle;
        if (std.mem.eql(u8, s, "planning"))   return .planning;
        if (std.mem.eql(u8, s, "acting"))     return .acting;
        if (std.mem.eql(u8, s, "observing"))  return .observing;
        if (std.mem.eql(u8, s, "reflecting")) return .reflecting;
        if (std.mem.eql(u8, s, "blocked"))    return .blocked;
        if (std.mem.eql(u8, s, "terminated")) return .terminated;
        return null;
    }
};

pub const ToolCallKind = enum(u8) {
    execute     = 0,
    query       = 1,
    transform   = 2,
    communicate = 3,
    delegate    = 4,
    escalate    = 5,

    pub fn str(self: ToolCallKind) []const u8 {
        return switch (self) {
            .execute     => "Execute",
            .query       => "Query",
            .transform   => "Transform",
            .communicate => "Communicate",
            .delegate    => "Delegate",
            .escalate    => "Escalate",
        };
    }

    pub fn hasSideEffects(self: ToolCallKind) bool {
        return switch (self) {
            .execute, .communicate, .delegate, .escalate => true,
            .query, .transform => false,
        };
    }

    pub fn requiresSafetyCheck(self: ToolCallKind) bool {
        return switch (self) {
            .execute, .delegate, .escalate => true,
            .query, .transform, .communicate => false,
        };
    }

    pub fn parse(s: []const u8) ?ToolCallKind {
        if (std.mem.eql(u8, s, "execute"))     return .execute;
        if (std.mem.eql(u8, s, "query"))       return .query;
        if (std.mem.eql(u8, s, "transform"))   return .transform;
        if (std.mem.eql(u8, s, "communicate")) return .communicate;
        if (std.mem.eql(u8, s, "delegate"))    return .delegate;
        if (std.mem.eql(u8, s, "escalate"))    return .escalate;
        return null;
    }
};

pub const SafetyCheck = enum(u8) {
    approved       = 0,
    denied         = 1,
    escalated      = 2,
    timeout        = 3,
    sandboxed      = 4,
    human_required = 5,

    pub fn str(self: SafetyCheck) []const u8 {
        return switch (self) {
            .approved       => "Approved",
            .denied         => "Denied",
            .escalated      => "Escalated",
            .timeout        => "Timeout",
            .sandboxed      => "Sandboxed",
            .human_required => "HumanRequired",
        };
    }

    pub fn allowsExecution(self: SafetyCheck) bool {
        return self == .approved or self == .sandboxed;
    }

    pub fn needsHuman(self: SafetyCheck) bool {
        return self == .escalated or self == .human_required;
    }

    pub fn parse(s: []const u8) ?SafetyCheck {
        if (std.mem.eql(u8, s, "approved"))        return .approved;
        if (std.mem.eql(u8, s, "denied"))          return .denied;
        if (std.mem.eql(u8, s, "escalated"))       return .escalated;
        if (std.mem.eql(u8, s, "timeout"))         return .timeout;
        if (std.mem.eql(u8, s, "sandboxed"))       return .sandboxed;
        if (std.mem.eql(u8, s, "human_required") or
            std.mem.eql(u8, s, "humanrequired"))   return .human_required;
        return null;
    }
};

// =============================================================================
// In-memory agent store (simple array + atomic counter)
// =============================================================================

const MAX_AGENTS: usize = 1024;

const AgentContext = struct {
    agent_id:     u32,
    state:        AgentState,
    coordination: []const u8,   // "Solo" | "Collaborative" | etc.
    last_safety:  []const u8,
    memory:       []const u8,
};

var agents_mutex: std.Thread.Mutex    = .{};
var agents: [MAX_AGENTS]?AgentContext = [_]?AgentContext{null} ** MAX_AGENTS;
var agent_count: u32                  = 0;

fn createAgent() AgentContext {
    const id = @atomicRmw(u32, &agent_count, .Add, 1, .monotonic);
    return .{
        .agent_id     = id,
        .state        = .idle,
        .coordination = "Solo",
        .last_safety  = "Approved",
        .memory       = "Working",
    };
}

// =============================================================================
// HTTP helpers  (minimal HTTP/1.1, same pattern as gnosis.zig)
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

fn readBody(allocator: std.mem.Allocator, stream: std.net.Stream, content_length: usize) ![]u8 {
    const cap = @min(content_length, 65536);
    const buf = try allocator.alloc(u8, cap);
    var total: usize = 0;
    while (total < cap) {
        const n = try stream.read(buf[total..]);
        if (n == 0) break;
        total += n;
    }
    return buf[0..total];
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

fn extractJsonString(json: []const u8, key: []const u8) ?[]const u8 {
    var needle_buf: [64]u8 = undefined;
    const needle = std.fmt.bufPrint(&needle_buf, "\"{s}\":\"", .{key}) catch return null;
    const start = (std.mem.indexOf(u8, json, needle) orelse return null) + needle.len;
    if (start >= json.len) return null;
    const end = std.mem.indexOfScalarPos(u8, json, start, '"') orelse return null;
    return json[start..end];
}

// =============================================================================
// Static response payloads
// =============================================================================

const GRAPHQL_SCHEMA =
    \\type Query {
    \\  health: Health!
    \\  types: [TypeInfo!]!
    \\  agent(id: Int!): AgentContext
    \\  toolCall(kind: String!): ToolCallInfo
    \\  safetyCheck(outcome: String!): SafetyCheckInfo
    \\  canTransition(from: String!, to: String!): Boolean!
    \\}
    \\
    \\type Mutation {
    \\  createAgent: AgentContext!
    \\  transitionAgent(id: Int!, newState: String!): TransitionResult!
    \\}
    \\
    \\type AgentContext {
    \\  agentId: Int!
    \\  state: String!
    \\  coordination: String!
    \\  lastSafety: String!
    \\  memory: String!
    \\}
    \\
    \\type ToolCallInfo {
    \\  kind: String!
    \\  hasSideEffects: Boolean!
    \\  requiresSafetyCheck: Boolean!
    \\}
    \\
    \\type SafetyCheckInfo {
    \\  outcome: String!
    \\  allowsExecution: Boolean!
    \\  needsHuman: Boolean!
    \\}
    \\
    \\type TransitionResult {
    \\  from: String!
    \\  to: String!
    \\  allowed: Boolean!
    \\}
;

// =============================================================================
// Route handlers
// =============================================================================

fn handleHealth(conn: *std.net.Server.Connection, alloc: std.mem.Allocator) void {
    const body =
        \\{"protocol":"proven-agentic","version":"0.1.0","status":"ok","types":[
        ++ \\{"name":"AgentState","variants":["Idle","Planning","Acting","Observing","Reflecting","Blocked","Terminated"]},
        ++ \\{"name":"ToolCall","variants":["Execute","Query","Transform","Communicate","Delegate","Escalate"]},
        ++ \\{"name":"PlanStep","variants":["Action","Condition","Loop","Branch","Parallel","Checkpoint","Rollback"]},
        ++ \\{"name":"Coordination","variants":["Solo","Collaborative","Competitive","Hierarchical","Swarm","Consensus"]},
        ++ \\{"name":"SafetyCheck","variants":["Approved","Denied","Escalated","Timeout","Sandboxed","HumanRequired"]},
        ++ \\{"name":"MemoryType","variants":["Working","Episodic","Semantic","Procedural","Shared"]}
        ++ \\]}
    ;
    _ = alloc;
    writeResponse(conn, 200, body);
}

fn handleTypes(conn: *std.net.Server.Connection) void {
    writeResponse(conn, 200,
        \\["AgentState","ToolCall","PlanStep","Coordination","SafetyCheck","MemoryType"]
    );
}

fn handleCreateAgent(conn: *std.net.Server.Connection) void {
    const agent = createAgent();
    agents_mutex.lock();
    const idx = agent.agent_id % MAX_AGENTS;
    agents[idx] = agent;
    agents_mutex.unlock();

    var buf: [256]u8 = undefined;
    const body = std.fmt.bufPrint(
        &buf,
        \\{{"agent_id":{d},"state":"{s}","coordination":"{s}","last_safety":"{s}","memory":"{s}"}}
        ,
        .{ agent.agent_id, agent.state.str(), agent.coordination, agent.last_safety, agent.memory },
    ) catch return writeError(conn, 500, "json encode failed");
    writeResponse(conn, 201, body);
}

fn handleGetAgent(conn: *std.net.Server.Connection, id_str: []const u8) void {
    const id = std.fmt.parseInt(u32, id_str, 10) catch {
        return writeError(conn, 400, "invalid agent id");
    };
    agents_mutex.lock();
    const agent = agents[id % MAX_AGENTS];
    agents_mutex.unlock();

    const a = agent orelse return writeError(conn, 404, "agent not found");
    if (a.agent_id != id) return writeError(conn, 404, "agent not found");

    var buf: [256]u8 = undefined;
    const body = std.fmt.bufPrint(
        &buf,
        \\{{"agent_id":{d},"state":"{s}","coordination":"{s}","last_safety":"{s}","memory":"{s}"}}
        ,
        .{ a.agent_id, a.state.str(), a.coordination, a.last_safety, a.memory },
    ) catch return writeError(conn, 500, "json encode failed");
    writeResponse(conn, 200, body);
}

fn handleTransition(
    conn: *std.net.Server.Connection,
    id_str: []const u8,
    body: []const u8,
) void {
    const id = std.fmt.parseInt(u32, id_str, 10) catch
        return writeError(conn, 400, "invalid agent id");

    const to_str = extractJsonString(body, "to") orelse
        return writeError(conn, 400, "missing 'to' field");
    const from_str = extractJsonString(body, "from") orelse "";

    var to_lower_buf: [32]u8 = undefined;
    const to_len = @min(to_str.len, 32);
    const to_lower = std.ascii.lowerString(to_lower_buf[0..to_len], to_str[0..to_len]);

    const new_state = AgentState.parse(to_lower) orelse
        return writeError(conn, 400, "unknown agent state");

    agents_mutex.lock();
    const idx = id % MAX_AGENTS;
    const maybe_agent = agents[idx];
    var allowed = false;
    if (maybe_agent) |a| {
        if (a.agent_id == id and a.state.canTransition(new_state)) {
            agents[idx] = .{
                .agent_id     = a.agent_id,
                .state        = new_state,
                .coordination = a.coordination,
                .last_safety  = a.last_safety,
                .memory       = a.memory,
            };
            allowed = true;
        }
    }
    agents_mutex.unlock();

    if (maybe_agent == null or maybe_agent.?.agent_id != id) {
        return writeError(conn, 404, "agent not found");
    }

    var resp_buf: [256]u8 = undefined;
    const resp = std.fmt.bufPrint(
        &resp_buf,
        \\{{"from":"{s}","to":"{s}","allowed":{s}}}
        ,
        .{ from_str, to_str, if (allowed) "true" else "false" },
    ) catch return writeError(conn, 500, "json encode failed");
    writeResponse(conn, 200, resp);
}

fn handleToolCallInfo(conn: *std.net.Server.Connection, kind_str: []const u8) void {
    var lbuf: [32]u8 = undefined;
    const llen = @min(kind_str.len, 32);
    const kind_lower = std.ascii.lowerString(lbuf[0..llen], kind_str[0..llen]);
    const kind = ToolCallKind.parse(kind_lower) orelse
        return writeError(conn, 400, "unknown tool call kind");

    var buf: [256]u8 = undefined;
    const body = std.fmt.bufPrint(
        &buf,
        \\{{"kind":"{s}","has_side_effects":{s},"requires_safety_check":{s}}}
        ,
        .{
            kind.str(),
            if (kind.hasSideEffects()) "true" else "false",
            if (kind.requiresSafetyCheck()) "true" else "false",
        },
    ) catch return writeError(conn, 500, "json encode failed");
    writeResponse(conn, 200, body);
}

fn handleSafetyCheckInfo(conn: *std.net.Server.Connection, outcome_str: []const u8) void {
    var lbuf: [32]u8 = undefined;
    const llen = @min(outcome_str.len, 32);
    const outcome_lower = std.ascii.lowerString(lbuf[0..llen], outcome_str[0..llen]);
    const sc = SafetyCheck.parse(outcome_lower) orelse
        return writeError(conn, 400, "unknown safety check outcome");

    var buf: [256]u8 = undefined;
    const body = std.fmt.bufPrint(
        &buf,
        \\{{"outcome":"{s}","allows_execution":{s},"needs_human":{s}}}
        ,
        .{
            sc.str(),
            if (sc.allowsExecution()) "true" else "false",
            if (sc.needsHuman()) "true" else "false",
        },
    ) catch return writeError(conn, 500, "json encode failed");
    writeResponse(conn, 200, body);
}

// =============================================================================
// Request dispatcher
// =============================================================================

fn serveRequest(
    conn: *std.net.Server.Connection,
    allocator: std.mem.Allocator,
) void {
    var req_line_buf: [1024]u8 = undefined;
    const req_line = readLine(conn.stream, &req_line_buf) catch return;

    var parts = std.mem.splitScalar(u8, req_line, ' ');
    const method = parts.next() orelse return;
    const path   = parts.next() orelse return;

    // Drain headers, collect Content-Length.
    var content_length: usize = 0;
    var h_buf: [512]u8 = undefined;
    while (true) {
        const line = readLine(conn.stream, &h_buf) catch break;
        if (line.len == 0) break;
        if (std.ascii.startsWithIgnoreCase(line, "content-length:")) {
            const val = std.mem.trimLeft(u8, line["content-length:".len..], " \t");
            content_length = std.fmt.parseInt(usize, val, 10) catch 0;
        }
    }

    var body_buf: ?[]u8 = null;
    defer if (body_buf) |b| allocator.free(b);
    if (content_length > 0) {
        body_buf = readBody(allocator, conn.stream, content_length) catch return;
    }
    const body: []const u8 = if (body_buf) |b| b else "";

    const is_get    = std.mem.eql(u8, method, "GET");
    const is_post   = std.mem.eql(u8, method, "POST");
    const is_opts   = std.mem.eql(u8, method, "OPTIONS");

    if (is_opts) {
        writeResponse(conn, 204, "");
    } else if (is_get and std.mem.eql(u8, path, "/health")) {
        handleHealth(conn, allocator);
    } else if (is_get and std.mem.eql(u8, path, "/types")) {
        handleTypes(conn);
    } else if (is_post and std.mem.eql(u8, path, "/agents")) {
        handleCreateAgent(conn);
    } else if (is_get and std.mem.startsWith(u8, path, "/agents/") and
               !std.mem.endsWith(u8, path, "/transition"))
    {
        handleGetAgent(conn, path["/agents/".len..]);
    } else if (is_post and std.mem.startsWith(u8, path, "/agents/") and
               std.mem.endsWith(u8, path, "/transition"))
    {
        // Extract agent id between /agents/ and /transition
        const after_agents = path["/agents/".len..];
        const end_pos = std.mem.lastIndexOf(u8, after_agents, "/transition") orelse
            return writeError(conn, 400, "bad path");
        handleTransition(conn, after_agents[0..end_pos], body);
    } else if (is_get and std.mem.startsWith(u8, path, "/tool-calls/")) {
        handleToolCallInfo(conn, path["/tool-calls/".len..]);
    } else if (is_get and std.mem.startsWith(u8, path, "/safety-checks/")) {
        handleSafetyCheckInfo(conn, path["/safety-checks/".len..]);
    } else if (is_get and std.mem.eql(u8, path, "/graphql/schema")) {
        // Return as plain text to match V behaviour.
        var h: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&h);
        fbs.writer().print(
            "HTTP/1.1 200 \r\nContent-Type: text/plain\r\nContent-Length: {d}\r\nConnection: close\r\n\r\n",
            .{GRAPHQL_SCHEMA.len},
        ) catch return;
        conn.stream.writeAll(fbs.getWritten()) catch return;
        conn.stream.writeAll(GRAPHQL_SCHEMA) catch return;
    } else {
        writeError(conn, 404, "not found");
    }
}

// =============================================================================
// Connection thread + main
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

    const port_str = std.posix.getenv("AGENTIC_PORT") orelse "8400";
    const port = std.fmt.parseInt(u16, port_str, 10) catch 8400;

    const addr = try std.net.Address.parseIp4("0.0.0.0", port);
    var server = try addr.listen(.{ .reuse_address = true });
    defer server.deinit();

    std.debug.print("proven-agentic adapter 0.1.0  port={d}\n", .{port});

    while (true) {
        const conn = try server.accept();
        const thread = try std.Thread.spawn(.{}, handleConnection, .{ConnArgs{
            .conn  = conn,
            .alloc = gpa,
        }});
        thread.detach();
    }
}
