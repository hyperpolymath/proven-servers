// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// nesy_solver_api_adapter.v: zig hexadeca wrapper for proven-nesy-solver-api.
// Wraps the Zig FFI (libproven_nesy_solver_api.so) and exposes a single
// request model across 16 protocol surfaces from v_api_interfaces:
//   REST, GraphQL, WebSocket, SSE, gRPC, JSON-RPC, MsgPack-RPC, CBOR,
//   Flatbuffers, Cap'n Proto, Bebop, tRPC, MQTT, AMQP, SOAP, VerisimDB.
//
// Routes (uniform across surfaces):
//   POST /prove                  -> dispatch obligation to echidna
//   GET  /strategy/:class        -> top prover for an ObligationClass
//   GET  /certificates           -> PROVEN/SANCTIFY badges (V4)
//   GET  /history                -> per-session recent attempts
//   GET  /health                 -> liveness + ABI version
//
// This is the E2 skeleton. E3 wires the FFI calls to a real echidna HTTP
// client + verisim-api persistence.

module nesy_solver_api_adapter

import json

// -----------------------------------------------------------------------
// Domain enums (V mirror of C ABI + Idris2 Layout.idr tags)
// -----------------------------------------------------------------------

pub enum ProverKind as u8 {
	z3       = 0
	cvc5     = 1
	coq      = 2
	lean     = 3
	idris2   = 4
	agda     = 5
	isabelle = 6
	dafny    = 7
	fstar    = 8
}

pub fn (p ProverKind) str() string {
	return match p {
		.z3 { 'Z3' }
		.cvc5 { 'CVC5' }
		.coq { 'Coq' }
		.lean { 'Lean' }
		.idris2 { 'Idris2' }
		.agda { 'Agda' }
		.isabelle { 'Isabelle' }
		.dafny { 'Dafny' }
		.fstar { 'FStar' }
	}
}

pub enum InputLanguage as u8 {
	smtlib  = 0
	lean    = 1
	coq     = 2
	idris2  = 3
	agda    = 4
}

pub fn (l InputLanguage) str() string {
	return match l {
		.smtlib { 'smtlib' }
		.lean { 'lean' }
		.coq { 'coq' }
		.idris2 { 'idris2' }
		.agda { 'agda' }
	}
}

pub enum ObligationClass as u8 {
	safety       = 0
	linearity    = 1
	termination  = 2
	equiv        = 3
	correctness  = 4
	confluence   = 5
	totality     = 6
	invariant    = 7
	refinement   = 8
	model_check  = 9
	other        = 10
}

pub fn (c ObligationClass) str() string {
	return match c {
		.safety { 'safety' }
		.linearity { 'linearity' }
		.termination { 'termination' }
		.equiv { 'equiv' }
		.correctness { 'correctness' }
		.confluence { 'confluence' }
		.totality { 'totality' }
		.invariant { 'invariant' }
		.refinement { 'refinement' }
		.model_check { 'model-check' }
		.other { 'other' }
	}
}

pub enum ProveOutcome as u8 {
	success = 0
	failure = 1
	timeout = 2
	unknown = 3
}

pub fn (o ProveOutcome) str() string {
	return match o {
		.success { 'success' }
		.failure { 'failure' }
		.timeout { 'timeout' }
		.unknown { 'unknown' }
	}
}

pub enum SurfaceKind as u8 {
	rest         = 0
	graphql      = 1
	websocket    = 2
	sse          = 3
	grpc         = 4
	jsonrpc      = 5
	msgpack_rpc  = 6
	cbor         = 7
	flatbuffers  = 8
	capnproto    = 9
	bebop        = 10
	trpc         = 11
	mqtt         = 12
	amqp         = 13
	soap         = 14
	verisimdb    = 15
}

pub fn (s SurfaceKind) str() string {
	return match s {
		.rest { 'rest' }
		.graphql { 'graphql' }
		.websocket { 'websocket' }
		.sse { 'sse' }
		.grpc { 'grpc' }
		.jsonrpc { 'jsonrpc' }
		.msgpack_rpc { 'msgpack-rpc' }
		.cbor { 'cbor' }
		.flatbuffers { 'flatbuffers' }
		.capnproto { 'capnproto' }
		.bebop { 'bebop' }
		.trpc { 'trpc' }
		.mqtt { 'mqtt' }
		.amqp { 'amqp' }
		.soap { 'soap' }
		.verisimdb { 'verisimdb' }
	}
}

// -----------------------------------------------------------------------
// Request/response types (uniform across all 16 surfaces)
// -----------------------------------------------------------------------

pub struct ProveRequest {
pub:
	language          InputLanguage
	obligation_class  ObligationClass
	prover            ProverKind  // if not set, strategy_lookup picks one
	content           string
	strategy_tag      string      // how the prover was chosen
}

pub struct ProveResponse {
pub:
	valid            bool
	outcome          ProveOutcome
	prover_used      ProverKind
	duration_ms      u64
	goals_remaining  int
	tactics_used     int
	strategy_tag     string
	prover_output    string
	obligation_id    string  // SHA-256 hex of content
	surface          SurfaceKind
}

pub struct StrategyEntry {
pub:
	obligation_class  ObligationClass
	top_prover        ProverKind
	success_rate      f32
	n_attempts        int
}

pub struct CertificateEntry {
pub:
	obligation_class  ObligationClass
	prover            ProverKind
	cert_type         string  // "PROVEN" | "SANCTIFY" | "PENDING"
	issued_at         string  // ISO-8601 without trailing Z
}

pub struct HealthResponse {
pub:
	service           string
	version           string
	abi_major         u8
	abi_minor         u8
	surfaces_enabled  []string
	mode              string  // "mock" | "live"
}

// -----------------------------------------------------------------------
// FFI bindings to libproven_nesy_solver_api.so (Zig-built)
// -----------------------------------------------------------------------

#flag -L../ffi/zig/zig-out/lib -lproven_nesy_solver_api
#include "../generated/abi/nesy_solver_api.h"

struct C.nesy_session_t {}
struct C.nesy_dispatch_t {}

fn C.nesy_session_open() &C.nesy_session_t
fn C.nesy_session_close(s &C.nesy_session_t)
fn C.nesy_session_state(s &C.nesy_session_t) u8

fn C.nesy_dispatch_begin(s &C.nesy_session_t, prover u8, lang u8, class u8,
	content &u8, len usize) &C.nesy_dispatch_t
fn C.nesy_dispatch_poll(d &C.nesy_dispatch_t) u8
fn C.nesy_dispatch_duration_ms(d &C.nesy_dispatch_t) u64
fn C.nesy_dispatch_end(d &C.nesy_dispatch_t)

fn C.nesy_obligation_hash(content &u8, len usize, out &u8, out_len usize) int
fn C.nesy_strategy_lookup(class u8) u8

// -----------------------------------------------------------------------
// High-level wrapper (what each of the 16 surfaces calls into)
// -----------------------------------------------------------------------

pub struct SolverAPI {
pub mut:
	session  &C.nesy_session_t = unsafe { nil }
	surface  SurfaceKind       = .rest
}

pub fn new_solver_api(surface SurfaceKind) SolverAPI {
	s := C.nesy_session_open()
	return SolverAPI{
		session: s
		surface: surface
	}
}

pub fn (mut api SolverAPI) close() {
	if unsafe { api.session != nil } {
		C.nesy_session_close(api.session)
		api.session = unsafe { nil }
	}
}

pub fn (mut api SolverAPI) prove(req ProveRequest) ProveResponse {
	mut prover := req.prover
	mut strategy_tag := req.strategy_tag
	if strategy_tag == '' {
		strategy_tag = 'manual'
	}
	// If caller did not pre-select a prover, consult the strategy table.
	// (V enums default to their zeroth constructor, so we re-run lookup
	//  whenever strategy_tag says 'auto'.)
	if strategy_tag == 'auto' {
		prover = unsafe { ProverKind(C.nesy_strategy_lookup(u8(req.obligation_class))) }
	}

	content_bytes := req.content.bytes()
	d := C.nesy_dispatch_begin(api.session, u8(prover), u8(req.language),
		u8(req.obligation_class), content_bytes.data, usize(content_bytes.len))

	outcome := unsafe { ProveOutcome(C.nesy_dispatch_poll(d)) }
	duration := C.nesy_dispatch_duration_ms(d)
	C.nesy_dispatch_end(d)

	mut hash_buf := []u8{len: 65, init: 0}
	_ := C.nesy_obligation_hash(content_bytes.data, usize(content_bytes.len),
		hash_buf.data, usize(65))
	obligation_id := unsafe { cstring_to_vstring(&char(hash_buf.data)) }

	valid := outcome == .success
	return ProveResponse{
		valid: valid
		outcome: outcome
		prover_used: prover
		duration_ms: duration
		goals_remaining: if valid { 0 } else { 1 }
		tactics_used: 0
		strategy_tag: strategy_tag
		prover_output: '' // E3: populated from echidna response
		obligation_id: obligation_id
		surface: api.surface
	}
}

pub fn (api SolverAPI) strategy_for(class ObligationClass) StrategyEntry {
	top := unsafe { ProverKind(C.nesy_strategy_lookup(u8(class))) }
	// Static rates for E2 — E3 fetches from verisim-api.
	return StrategyEntry{
		obligation_class: class
		top_prover: top
		success_rate: 0.0
		n_attempts: 0
	}
}

pub fn (api SolverAPI) health() HealthResponse {
	return HealthResponse{
		service: 'proven-nesy-solver-api'
		version: '0.1.0'
		abi_major: 0
		abi_minor: 1
		surfaces_enabled: [
			'rest', 'graphql', 'websocket', 'sse', 'grpc', 'jsonrpc',
			'msgpack-rpc', 'cbor', 'flatbuffers', 'capnproto', 'bebop',
			'trpc', 'mqtt', 'amqp', 'soap', 'verisimdb',
		]
		mode: 'mock'
	}
}

// -----------------------------------------------------------------------
// Surface demo — prints what each of the 16 adapters would expose.
// Real surface adapters live in sibling files (rest_surface.v, etc.)
// and will be added in E3.
// -----------------------------------------------------------------------

pub fn enumerate_surfaces() []SurfaceKind {
	return [
		SurfaceKind.rest, .graphql, .websocket, .sse, .grpc, .jsonrpc,
		.msgpack_rpc, .cbor, .flatbuffers, .capnproto, .bebop, .trpc,
		.mqtt, .amqp, .soap, .verisimdb,
	]
}

// json roundtrip helpers (for REST / JSON-RPC / WebSocket / SSE surfaces)
pub fn prove_request_from_json(data string) !ProveRequest {
	return json.decode(ProveRequest, data)!
}

pub fn prove_response_to_json(resp ProveResponse) string {
	return json.encode(resp)
}
