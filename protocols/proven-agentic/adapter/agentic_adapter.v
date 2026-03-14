// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// agentic_adapter.v: V-lang triple adapter for the proven-agentic protocol.
// Exposes the Zig FFI as REST + gRPC + GraphQL endpoints.
// This is the API surface that BoJ cartridges and external consumers use.

module agentic_adapter

import vweb
import json
import net.http

// -----------------------------------------------------------------------
// Domain types (V-native mirrors of the Zig FFI enums)
// -----------------------------------------------------------------------

pub enum AgentState {
	idle
	planning
	acting
	observing
	reflecting
	blocked
	terminated
}

pub fn (s AgentState) str() string {
	return match s {
		.idle { 'Idle' }
		.planning { 'Planning' }
		.acting { 'Acting' }
		.observing { 'Observing' }
		.reflecting { 'Reflecting' }
		.blocked { 'Blocked' }
		.terminated { 'Terminated' }
	}
}

pub enum ToolCallKind {
	execute
	query
	transform
	communicate
	delegate
	escalate
}

pub fn (t ToolCallKind) str() string {
	return match t {
		.execute { 'Execute' }
		.query { 'Query' }
		.transform { 'Transform' }
		.communicate { 'Communicate' }
		.delegate { 'Delegate' }
		.escalate { 'Escalate' }
	}
}

pub fn (t ToolCallKind) has_side_effects() bool {
	return t in [.execute, .communicate, .delegate, .escalate]
}

pub fn (t ToolCallKind) requires_safety_check() bool {
	return t in [.execute, .delegate, .escalate]
}

pub enum PlanStep {
	action
	condition
	loop_step
	branch
	parallel
	checkpoint
	rollback
}

pub fn (p PlanStep) str() string {
	return match p {
		.action { 'Action' }
		.condition { 'Condition' }
		.loop_step { 'Loop' }
		.branch { 'Branch' }
		.parallel { 'Parallel' }
		.checkpoint { 'Checkpoint' }
		.rollback { 'Rollback' }
	}
}

pub enum Coordination {
	solo
	collaborative
	competitive
	hierarchical
	swarm
	consensus
}

pub fn (c Coordination) str() string {
	return match c {
		.solo { 'Solo' }
		.collaborative { 'Collaborative' }
		.competitive { 'Competitive' }
		.hierarchical { 'Hierarchical' }
		.swarm { 'Swarm' }
		.consensus { 'Consensus' }
	}
}

pub fn (c Coordination) is_multi_agent() bool {
	return c != .solo
}

pub enum SafetyCheck {
	approved
	denied
	escalated
	timeout
	sandboxed
	human_required
}

pub fn (s SafetyCheck) str() string {
	return match s {
		.approved { 'Approved' }
		.denied { 'Denied' }
		.escalated { 'Escalated' }
		.timeout { 'Timeout' }
		.sandboxed { 'Sandboxed' }
		.human_required { 'HumanRequired' }
	}
}

pub fn (s SafetyCheck) allows_execution() bool {
	return s in [.approved, .sandboxed]
}

pub enum MemoryKind {
	working
	episodic
	semantic
	procedural
	shared
}

pub fn (m MemoryKind) str() string {
	return match m {
		.working { 'Working' }
		.episodic { 'Episodic' }
		.semantic { 'Semantic' }
		.procedural { 'Procedural' }
		.shared { 'Shared' }
	}
}

pub fn (m MemoryKind) is_persistent() bool {
	return m != .working
}

// -----------------------------------------------------------------------
// Agent context — runtime state for a single agent
// -----------------------------------------------------------------------

pub struct AgentContext {
pub mut:
	agent_id         u32
	state            AgentState
	coordination     Coordination
	last_safety      SafetyCheck
	memory           MemoryKind
}

pub fn new_agent_context(id u32) AgentContext {
	return AgentContext{
		agent_id: id
		state: .idle
		coordination: .solo
		last_safety: .approved
		memory: .working
	}
}

// Valid OODA-loop transitions
pub fn (s AgentState) can_transition(to AgentState) bool {
	return match s {
		.idle { to == .planning || to == .terminated }
		.planning { to == .acting || to == .blocked || to == .terminated }
		.acting { to == .observing || to == .blocked || to == .terminated }
		.observing { to == .reflecting || to == .blocked || to == .terminated }
		.reflecting { to in [.planning, .acting, .idle, .terminated] }
		.blocked { to in [.planning, .acting, .idle, .terminated] }
		.terminated { false }
	}
}

pub fn (mut ctx AgentContext) transition(new_state AgentState) bool {
	if ctx.state.can_transition(new_state) {
		ctx.state = new_state
		return true
	}
	return false
}

// -----------------------------------------------------------------------
// JSON response types (shared across REST and GraphQL)
// -----------------------------------------------------------------------

struct TypeInfo {
	name     string
	variants []string
}

struct TransitionRequest {
	from string
	to   string
}

struct TransitionResult {
	from    string
	to      string
	allowed bool
}

struct ToolCallInfo {
	kind                  string
	has_side_effects      bool
	requires_safety_check bool
}

struct SafetyCheckInfo {
	outcome          string
	allows_execution bool
	needs_human      bool
}

struct HealthResponse {
	protocol string
	version  string
	status   string
	types    []TypeInfo
}

// -----------------------------------------------------------------------
// REST adapter — vweb-based HTTP server
// -----------------------------------------------------------------------

pub struct RestAdapter {
	vweb.Context
pub mut:
	agents map[u32]AgentContext
}

// GET /health
['/health']
pub fn (mut app RestAdapter) health() vweb.Result {
	resp := HealthResponse{
		protocol: 'proven-agentic'
		version: '0.1.0'
		status: 'ok'
		types: [
			TypeInfo{ name: 'AgentState', variants: ['Idle', 'Planning', 'Acting', 'Observing', 'Reflecting', 'Blocked', 'Terminated'] },
			TypeInfo{ name: 'ToolCall', variants: ['Execute', 'Query', 'Transform', 'Communicate', 'Delegate', 'Escalate'] },
			TypeInfo{ name: 'PlanStep', variants: ['Action', 'Condition', 'Loop', 'Branch', 'Parallel', 'Checkpoint', 'Rollback'] },
			TypeInfo{ name: 'Coordination', variants: ['Solo', 'Collaborative', 'Competitive', 'Hierarchical', 'Swarm', 'Consensus'] },
			TypeInfo{ name: 'SafetyCheck', variants: ['Approved', 'Denied', 'Escalated', 'Timeout', 'Sandboxed', 'HumanRequired'] },
			TypeInfo{ name: 'MemoryType', variants: ['Working', 'Episodic', 'Semantic', 'Procedural', 'Shared'] },
		]
	}
	return app.json(resp)
}

// GET /types — list all type families
['/types']
pub fn (mut app RestAdapter) types_list() vweb.Result {
	return app.json([
		'AgentState', 'ToolCall', 'PlanStep',
		'Coordination', 'SafetyCheck', 'MemoryType',
	])
}

// POST /agents — create a new agent context
['/agents'; post]
pub fn (mut app RestAdapter) create_agent() vweb.Result {
	id := u32(app.agents.len)
	ctx := new_agent_context(id)
	app.agents[id] = ctx
	return app.json(ctx)
}

// GET /agents/:id — get agent state
['/agents/:id']
pub fn (mut app RestAdapter) get_agent(id u32) vweb.Result {
	if ctx := app.agents[id] {
		return app.json(ctx)
	}
	app.set_status(404, 'Not Found')
	return app.text('Agent not found')
}

// POST /agents/:id/transition — attempt state transition
['/agents/:id/transition'; post]
pub fn (mut app RestAdapter) agent_transition(id u32) vweb.Result {
	if _ := app.agents[id] {
		body := app.req.data
		req := json.decode(TransitionRequest, body) or {
			app.set_status(400, 'Bad Request')
			return app.text('Invalid request body')
		}
		new_state := parse_agent_state(req.to) or {
			app.set_status(400, 'Bad Request')
			return app.text('Unknown state: ${req.to}')
		}
		mut ctx := app.agents[id]
		ok := ctx.transition(new_state)
		if ok {
			app.agents[id] = ctx
		}
		result := TransitionResult{
			from: req.from
			to: req.to
			allowed: ok
		}
		return app.json(result)
	}
	app.set_status(404, 'Not Found')
	return app.text('Agent not found')
}

// GET /tool-calls/:kind — get tool call info
['/tool-calls/:kind']
pub fn (mut app RestAdapter) tool_call_info(kind string) vweb.Result {
	tc := parse_tool_call(kind) or {
		app.set_status(400, 'Bad Request')
		return app.text('Unknown tool call: ${kind}')
	}
	info := ToolCallInfo{
		kind: tc.str()
		has_side_effects: tc.has_side_effects()
		requires_safety_check: tc.requires_safety_check()
	}
	return app.json(info)
}

// GET /safety-checks/:outcome — get safety check info
['/safety-checks/:outcome']
pub fn (mut app RestAdapter) safety_check_info(outcome string) vweb.Result {
	sc := parse_safety_check(outcome) or {
		app.set_status(400, 'Bad Request')
		return app.text('Unknown safety check: ${outcome}')
	}
	info := SafetyCheckInfo{
		outcome: sc.str()
		allows_execution: sc.allows_execution()
		needs_human: sc == .escalated || sc == .human_required
	}
	return app.json(info)
}

// -----------------------------------------------------------------------
// GraphQL schema (string-based, served at /graphql)
// -----------------------------------------------------------------------

const graphql_schema = '
type Query {
  health: Health!
  types: [TypeInfo!]!
  agent(id: Int!): AgentContext
  toolCall(kind: String!): ToolCallInfo
  safetyCheck(outcome: String!): SafetyCheckInfo
  canTransition(from: String!, to: String!): Boolean!
}

type Mutation {
  createAgent: AgentContext!
  transitionAgent(id: Int!, newState: String!): TransitionResult!
}

type Health {
  protocol: String!
  version: String!
  status: String!
}

type TypeInfo {
  name: String!
  variants: [String!]!
}

type AgentContext {
  agentId: Int!
  state: String!
  coordination: String!
  lastSafety: String!
  memory: String!
}

type ToolCallInfo {
  kind: String!
  hasSideEffects: Boolean!
  requiresSafetyCheck: Boolean!
}

type SafetyCheckInfo {
  outcome: String!
  allowsExecution: Boolean!
  needsHuman: Boolean!
}

type TransitionResult {
  from: String!
  to: String!
  allowed: Boolean!
}
'

// GET /graphql/schema — return the GraphQL schema
['/graphql/schema']
pub fn (mut app RestAdapter) graphql_schema_endpoint() vweb.Result {
	return app.text(graphql_schema)
}

// -----------------------------------------------------------------------
// gRPC service definition (proto3, for codegen)
// -----------------------------------------------------------------------

pub const grpc_proto = '
syntax = "proto3";

package proven.agentic.v1;

service AgenticService {
  rpc Health (Empty) returns (HealthResponse);
  rpc ListTypes (Empty) returns (TypeListResponse);
  rpc CreateAgent (Empty) returns (AgentContextResponse);
  rpc GetAgent (AgentIdRequest) returns (AgentContextResponse);
  rpc TransitionAgent (TransitionRequest) returns (TransitionResponse);
  rpc GetToolCallInfo (ToolCallRequest) returns (ToolCallInfoResponse);
  rpc GetSafetyCheckInfo (SafetyCheckRequest) returns (SafetyCheckInfoResponse);
}

message Empty {}

message HealthResponse {
  string protocol = 1;
  string version = 2;
  string status = 3;
}

message TypeListResponse {
  repeated TypeInfo types = 1;
}

message TypeInfo {
  string name = 1;
  repeated string variants = 2;
}

message AgentIdRequest {
  uint32 agent_id = 1;
}

message AgentContextResponse {
  uint32 agent_id = 1;
  string state = 2;
  string coordination = 3;
  string last_safety = 4;
  string memory = 5;
}

message TransitionRequest {
  uint32 agent_id = 1;
  string new_state = 2;
}

message TransitionResponse {
  string from_state = 1;
  string to_state = 2;
  bool allowed = 3;
}

message ToolCallRequest {
  string kind = 1;
}

message ToolCallInfoResponse {
  string kind = 1;
  bool has_side_effects = 2;
  bool requires_safety_check = 3;
}

message SafetyCheckRequest {
  string outcome = 1;
}

message SafetyCheckInfoResponse {
  string outcome = 1;
  bool allows_execution = 2;
  bool needs_human = 3;
}
'

// -----------------------------------------------------------------------
// Parsing helpers
// -----------------------------------------------------------------------

fn parse_agent_state(s string) ?AgentState {
	return match s.to_lower() {
		'idle' { .idle }
		'planning' { .planning }
		'acting' { .acting }
		'observing' { .observing }
		'reflecting' { .reflecting }
		'blocked' { .blocked }
		'terminated' { .terminated }
		else { none }
	}
}

fn parse_tool_call(s string) ?ToolCallKind {
	return match s.to_lower() {
		'execute' { .execute }
		'query' { .query }
		'transform' { .transform }
		'communicate' { .communicate }
		'delegate' { .delegate }
		'escalate' { .escalate }
		else { none }
	}
}

fn parse_safety_check(s string) ?SafetyCheck {
	return match s.to_lower() {
		'approved' { .approved }
		'denied' { .denied }
		'escalated' { .escalated }
		'timeout' { .timeout }
		'sandboxed' { .sandboxed }
		'human_required', 'humanrequired' { .human_required }
		else { none }
	}
}
