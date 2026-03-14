// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// nesy_adapter.v: V-lang triple adapter for the proven-nesy protocol.
// Exposes the Zig FFI as REST + gRPC + GraphQL endpoints.
// This is the API surface that BoJ cartridges and external consumers use.

module nesy_adapter

import vweb
import json

// -----------------------------------------------------------------------
// Domain types (V-native mirrors of the Zig FFI enums)
// -----------------------------------------------------------------------

pub enum ReasoningMode {
	symbolic
	neural
	sym_to_neural
	neural_to_sym
	ensemble
	cascade
}

pub fn (m ReasoningMode) str() string {
	return match m {
		.symbolic { 'Symbolic' }
		.neural { 'Neural' }
		.sym_to_neural { 'SymToNeural' }
		.neural_to_sym { 'NeuralToSym' }
		.ensemble { 'Ensemble' }
		.cascade { 'Cascade' }
	}
}

pub fn (m ReasoningMode) uses_symbolic() bool {
	return m != .neural
}

pub fn (m ReasoningMode) uses_neural() bool {
	return m != .symbolic
}

pub fn (m ReasoningMode) is_hybrid() bool {
	return m.uses_symbolic() && m.uses_neural()
}

pub enum ProofStatus {
	pending
	attempting
	proved
	failed
	assumed
	vacuous
}

pub fn (p ProofStatus) str() string {
	return match p {
		.pending { 'Pending' }
		.attempting { 'Attempting' }
		.proved { 'Proved' }
		.failed { 'Failed' }
		.assumed { 'Assumed' }
		.vacuous { 'Vacuous' }
	}
}

pub fn (p ProofStatus) is_terminal() bool {
	return p in [.proved, .failed, .assumed, .vacuous]
}

pub fn (p ProofStatus) is_trusted() bool {
	return p in [.proved, .assumed, .vacuous]
}

pub enum ConstraintKind {
	type_equality
	subtype
	linearity
	termination
	totality
	invariant
	refinement
	dependent_index
}

pub fn (c ConstraintKind) str() string {
	return match c {
		.type_equality { 'TypeEquality' }
		.subtype { 'Subtype' }
		.linearity { 'Linearity' }
		.termination { 'Termination' }
		.totality { 'Totality' }
		.invariant { 'Invariant' }
		.refinement { 'Refinement' }
		.dependent_index { 'DependentIndex' }
	}
}

pub enum NeuralBackend {
	local_model
	claude
	gemini
	mistral
	gpt
	custom_neural
}

pub fn (b NeuralBackend) str() string {
	return match b {
		.local_model { 'LocalModel' }
		.claude { 'Claude' }
		.gemini { 'Gemini' }
		.mistral { 'Mistral' }
		.gpt { 'GPT' }
		.custom_neural { 'CustomNeural' }
	}
}

pub fn (b NeuralBackend) is_local() bool {
	return b == .local_model
}

pub fn (b NeuralBackend) is_cloud_api() bool {
	return b in [.claude, .gemini, .mistral, .gpt]
}

pub enum Confidence {
	verified
	high_neural
	medium_neural
	low_neural
	unknown
	contradicted
}

pub fn (c Confidence) str() string {
	return match c {
		.verified { 'Verified' }
		.high_neural { 'HighNeural' }
		.medium_neural { 'MediumNeural' }
		.low_neural { 'LowNeural' }
		.unknown { 'Unknown' }
		.contradicted { 'Contradicted' }
	}
}

pub fn (c Confidence) score() f32 {
	return match c {
		.verified { 1.0 }
		.high_neural { 0.95 }
		.medium_neural { 0.80 }
		.low_neural { 0.50 }
		.unknown { 0.0 }
		.contradicted { 0.0 }
	}
}

pub fn (c Confidence) is_actionable() bool {
	return c in [.verified, .high_neural, .medium_neural]
}

pub enum DriftKind {
	no_drift
	semantic_drift
	confidence_drift
	factual_drift
	temporal_drift
	catastrophic_drift
}

pub fn (d DriftKind) str() string {
	return match d {
		.no_drift { 'NoDrift' }
		.semantic_drift { 'SemanticDrift' }
		.confidence_drift { 'ConfidenceDrift' }
		.factual_drift { 'FactualDrift' }
		.temporal_drift { 'TemporalDrift' }
		.catastrophic_drift { 'CatastrophicDrift' }
	}
}

pub fn (d DriftKind) is_urgent() bool {
	return d in [.factual_drift, .catastrophic_drift]
}

pub enum MergeStrategy {
	symbolic_primacy
	neural_primacy
	confidence_weighted
	consensus
	dual_return
	constrained_generation
}

pub fn (m MergeStrategy) str() string {
	return match m {
		.symbolic_primacy { 'SymbolicPrimacy' }
		.neural_primacy { 'NeuralPrimacy' }
		.confidence_weighted { 'ConfidenceWeighted' }
		.consensus { 'Consensus' }
		.dual_return { 'DualReturn' }
		.constrained_generation { 'ConstrainedGeneration' }
	}
}

pub enum DriftAction {
	log_and_accept
	flag_for_review
	reject_neural
	retry_neural
	escalate
	halt
}

pub fn (a DriftAction) str() string {
	return match a {
		.log_and_accept { 'LogAndAccept' }
		.flag_for_review { 'FlagForReview' }
		.reject_neural { 'RejectNeural' }
		.retry_neural { 'RetryNeural' }
		.escalate { 'Escalate' }
		.halt { 'Halt' }
	}
}

pub enum GroundingStatus {
	fully_grounded
	partially_grounded
	ungrounded
	grounding_pending
	grounding_failed
}

pub fn (g GroundingStatus) str() string {
	return match g {
		.fully_grounded { 'FullyGrounded' }
		.partially_grounded { 'PartiallyGrounded' }
		.ungrounded { 'Ungrounded' }
		.grounding_pending { 'GroundingPending' }
		.grounding_failed { 'GroundingFailed' }
	}
}

pub fn (g GroundingStatus) is_trusted() bool {
	return g == .fully_grounded
}

// -----------------------------------------------------------------------
// Drift recommendation — pure function mapping drift to action
// -----------------------------------------------------------------------

pub fn recommend_drift_action(drift DriftKind) DriftAction {
	return match drift {
		.no_drift { .log_and_accept }
		.semantic_drift { .log_and_accept }
		.confidence_drift { .flag_for_review }
		.factual_drift { .reject_neural }
		.temporal_drift { .retry_neural }
		.catastrophic_drift { .halt }
	}
}

// -----------------------------------------------------------------------
// NeSy session context
// -----------------------------------------------------------------------

pub struct NeSySession {
pub mut:
	session_id     u32
	mode           ReasoningMode
	confidence     Confidence
	drift          DriftKind
	merge_strategy MergeStrategy
	proof_status   ProofStatus
	grounding      GroundingStatus
}

pub fn new_session(id u32) NeSySession {
	return NeSySession{
		session_id: id
		mode: .symbolic
		confidence: .unknown
		drift: .no_drift
		merge_strategy: .symbolic_primacy
		proof_status: .pending
		grounding: .ungrounded
	}
}

// -----------------------------------------------------------------------
// JSON response types
// -----------------------------------------------------------------------

struct TypeInfo {
	name     string
	variants []string
}

struct HealthResponse {
	protocol string
	version  string
	status   string
	types    []TypeInfo
}

struct DriftReport {
	drift            string
	severity         int
	urgent           bool
	recommended_action string
}

struct ConfidenceReport {
	level      string
	score      f32
	actionable bool
}

struct ReasoningModeReport {
	mode           string
	uses_symbolic  bool
	uses_neural    bool
	is_hybrid      bool
}

// -----------------------------------------------------------------------
// REST adapter — vweb-based HTTP server
// -----------------------------------------------------------------------

pub struct RestAdapter {
	vweb.Context
pub mut:
	sessions map[u32]NeSySession
}

// GET /health
['/health']
pub fn (mut app RestAdapter) health() vweb.Result {
	resp := HealthResponse{
		protocol: 'proven-nesy'
		version: '0.1.0'
		status: 'ok'
		types: [
			TypeInfo{ name: 'ReasoningMode', variants: ['Symbolic', 'Neural', 'SymToNeural', 'NeuralToSym', 'Ensemble', 'Cascade'] },
			TypeInfo{ name: 'ProofStatus', variants: ['Pending', 'Attempting', 'Proved', 'Failed', 'Assumed', 'Vacuous'] },
			TypeInfo{ name: 'ConstraintKind', variants: ['TypeEquality', 'Subtype', 'Linearity', 'Termination', 'Totality', 'Invariant', 'Refinement', 'DependentIndex'] },
			TypeInfo{ name: 'NeuralBackend', variants: ['LocalModel', 'Claude', 'Gemini', 'Mistral', 'GPT', 'CustomNeural'] },
			TypeInfo{ name: 'Confidence', variants: ['Verified', 'HighNeural', 'MediumNeural', 'LowNeural', 'Unknown', 'Contradicted'] },
			TypeInfo{ name: 'DriftKind', variants: ['NoDrift', 'SemanticDrift', 'ConfidenceDrift', 'FactualDrift', 'TemporalDrift', 'CatastrophicDrift'] },
			TypeInfo{ name: 'MergeStrategy', variants: ['SymbolicPrimacy', 'NeuralPrimacy', 'ConfidenceWeighted', 'Consensus', 'DualReturn', 'ConstrainedGeneration'] },
			TypeInfo{ name: 'DriftAction', variants: ['LogAndAccept', 'FlagForReview', 'RejectNeural', 'RetryNeural', 'Escalate', 'Halt'] },
			TypeInfo{ name: 'GroundingStatus', variants: ['FullyGrounded', 'PartiallyGrounded', 'Ungrounded', 'GroundingPending', 'GroundingFailed'] },
		]
	}
	return app.json(resp)
}

// GET /types — list all type families
['/types']
pub fn (mut app RestAdapter) types_list() vweb.Result {
	return app.json([
		'ReasoningMode', 'ProofStatus', 'ConstraintKind', 'NeuralBackend',
		'Confidence', 'DriftKind', 'MergeStrategy', 'DriftAction',
		'GroundingStatus',
	])
}

// POST /sessions — create a new reasoning session
['/sessions'; post]
pub fn (mut app RestAdapter) create_session() vweb.Result {
	id := u32(app.sessions.len)
	session := new_session(id)
	app.sessions[id] = session
	return app.json(session)
}

// GET /sessions/:id — get session state
['/sessions/:id']
pub fn (mut app RestAdapter) get_session(id u32) vweb.Result {
	if s := app.sessions[id] {
		return app.json(s)
	}
	app.set_status(404, 'Not Found')
	return app.text('Session not found')
}

// GET /drift/analyze/:kind — analyze drift and recommend action
['/drift/analyze/:kind']
pub fn (mut app RestAdapter) analyze_drift(kind string) vweb.Result {
	dk := parse_drift_kind(kind) or {
		app.set_status(400, 'Bad Request')
		return app.text('Unknown drift kind: ${kind}')
	}
	action := recommend_drift_action(dk)
	report := DriftReport{
		drift: dk.str()
		severity: int(dk)
		urgent: dk.is_urgent()
		recommended_action: action.str()
	}
	return app.json(report)
}

// GET /confidence/:level — get confidence info
['/confidence/:level']
pub fn (mut app RestAdapter) confidence_info(level string) vweb.Result {
	conf := parse_confidence(level) or {
		app.set_status(400, 'Bad Request')
		return app.text('Unknown confidence level: ${level}')
	}
	report := ConfidenceReport{
		level: conf.str()
		score: conf.score()
		actionable: conf.is_actionable()
	}
	return app.json(report)
}

// GET /reasoning-modes/:mode — get reasoning mode info
['/reasoning-modes/:mode']
pub fn (mut app RestAdapter) reasoning_mode_info(mode string) vweb.Result {
	rm := parse_reasoning_mode(mode) or {
		app.set_status(400, 'Bad Request')
		return app.text('Unknown reasoning mode: ${mode}')
	}
	report := ReasoningModeReport{
		mode: rm.str()
		uses_symbolic: rm.uses_symbolic()
		uses_neural: rm.uses_neural()
		is_hybrid: rm.is_hybrid()
	}
	return app.json(report)
}

// -----------------------------------------------------------------------
// GraphQL schema (string-based, served at /graphql)
// -----------------------------------------------------------------------

const graphql_schema = '
type Query {
  health: Health!
  types: [TypeInfo!]!
  session(id: Int!): NeSySession
  analyzeDrift(kind: String!): DriftReport!
  confidenceInfo(level: String!): ConfidenceReport!
  reasoningMode(mode: String!): ReasoningModeReport!
  backends: [BackendInfo!]!
}

type Mutation {
  createSession: NeSySession!
  setMode(sessionId: Int!, mode: String!): NeSySession!
  setMergeStrategy(sessionId: Int!, strategy: String!): NeSySession!
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

type NeSySession {
  sessionId: Int!
  mode: String!
  confidence: String!
  drift: String!
  mergeStrategy: String!
  proofStatus: String!
  grounding: String!
}

type DriftReport {
  drift: String!
  severity: Int!
  urgent: Boolean!
  recommendedAction: String!
}

type ConfidenceReport {
  level: String!
  score: Float!
  actionable: Boolean!
}

type ReasoningModeReport {
  mode: String!
  usesSymbolic: Boolean!
  usesNeural: Boolean!
  isHybrid: Boolean!
}

type BackendInfo {
  name: String!
  isLocal: Boolean!
  isCloudApi: Boolean!
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

package proven.nesy.v1;

service NeSyService {
  rpc Health (Empty) returns (HealthResponse);
  rpc ListTypes (Empty) returns (TypeListResponse);
  rpc CreateSession (Empty) returns (SessionResponse);
  rpc GetSession (SessionIdRequest) returns (SessionResponse);
  rpc AnalyzeDrift (DriftKindRequest) returns (DriftReport);
  rpc GetConfidenceInfo (ConfidenceRequest) returns (ConfidenceReport);
  rpc GetReasoningModeInfo (ReasoningModeRequest) returns (ReasoningModeReport);
  rpc RecommendDriftAction (DriftKindRequest) returns (DriftActionResponse);
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

message SessionIdRequest {
  uint32 session_id = 1;
}

message SessionResponse {
  uint32 session_id = 1;
  string mode = 2;
  string confidence = 3;
  string drift = 4;
  string merge_strategy = 5;
  string proof_status = 6;
  string grounding = 7;
}

message DriftKindRequest {
  string kind = 1;
}

message DriftReport {
  string drift = 1;
  int32 severity = 2;
  bool urgent = 3;
  string recommended_action = 4;
}

message ConfidenceRequest {
  string level = 1;
}

message ConfidenceReport {
  string level = 1;
  float score = 2;
  bool actionable = 3;
}

message ReasoningModeRequest {
  string mode = 1;
}

message ReasoningModeReport {
  string mode = 1;
  bool uses_symbolic = 2;
  bool uses_neural = 3;
  bool is_hybrid = 4;
}

message DriftActionResponse {
  string action = 1;
}
'

// -----------------------------------------------------------------------
// Parsing helpers
// -----------------------------------------------------------------------

fn parse_reasoning_mode(s string) ?ReasoningMode {
	return match s.to_lower() {
		'symbolic' { .symbolic }
		'neural' { .neural }
		'symtoneural', 'sym_to_neural' { .sym_to_neural }
		'neuraltosym', 'neural_to_sym' { .neural_to_sym }
		'ensemble' { .ensemble }
		'cascade' { .cascade }
		else { none }
	}
}

fn parse_confidence(s string) ?Confidence {
	return match s.to_lower() {
		'verified' { .verified }
		'highneural', 'high_neural' { .high_neural }
		'mediumneural', 'medium_neural' { .medium_neural }
		'lowneural', 'low_neural' { .low_neural }
		'unknown' { .unknown }
		'contradicted' { .contradicted }
		else { none }
	}
}

fn parse_drift_kind(s string) ?DriftKind {
	return match s.to_lower() {
		'nodrift', 'no_drift', 'none' { .no_drift }
		'semanticdrift', 'semantic_drift', 'semantic' { .semantic_drift }
		'confidencedrift', 'confidence_drift', 'confidence' { .confidence_drift }
		'factualdrift', 'factual_drift', 'factual' { .factual_drift }
		'temporaldrift', 'temporal_drift', 'temporal' { .temporal_drift }
		'catastrophicdrift', 'catastrophic_drift', 'catastrophic' { .catastrophic_drift }
		else { none }
	}
}
