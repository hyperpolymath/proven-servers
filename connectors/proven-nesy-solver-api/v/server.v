// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// server.v: proven-nesy-solver-api HTTP service — forwards prove requests
// to echidna and records attempts in verisim-api.  This is the backend
// that nesy-solver.dev calls to get real verification results.
//
// Runs on port 9000 by default.  Configurable via env vars:
//   ECHIDNA_URL    (default: http://localhost:8090)
//   VERISIM_URL    (default: http://localhost:8080)
//   NESY_PORT      (default: 9000)
//
// E3 milestone: local E2E with echidna + verisim-api running on dev host.
// E3 deploy:    fly.io with same env vars.

module main

import vweb
import net.http
import json
import os
import rand
import time
import crypto.sha256

// -----------------------------------------------------------------------
// Configuration
// -----------------------------------------------------------------------

struct Config {
	echidna_url  string
	verisim_url  string
	port         int
	repo         string
	file_tag     string
	ingest_token string // shared secret for POST /ingest (batch_driver, echidnabot)
}

fn load_config() Config {
	return Config{
		echidna_url:  os.getenv_opt('ECHIDNA_URL') or { 'http://localhost:8090' }
		verisim_url:  os.getenv_opt('VERISIM_URL') or { 'http://localhost:8080' }
		port:         (os.getenv_opt('NESY_PORT') or { '9000' }).int()
		repo:         os.getenv_opt('NESY_REPO_TAG') or { 'hyperpolymath/nesy-solver' }
		file_tag:     os.getenv_opt('NESY_FILE_TAG') or { 'playground/submission.txt' }
		ingest_token: os.getenv_opt('NESY_INGEST_TOKEN') or { '' }
	}
}

// -----------------------------------------------------------------------
// Request / response types (JSON boundary)
// -----------------------------------------------------------------------

struct ProveRequestBody {
	language          string @[json: 'language']
	obligation_class  string @[json: 'obligationClass']
	prover            string @[json: 'prover']
	content           string @[json: 'content']
}

struct ProveResponseBody {
	valid            bool   @[json: 'valid']
	outcome          string @[json: 'outcome']
	prover           string @[json: 'prover']
	duration_ms      u64    @[json: 'duration_ms']
	goals_remaining  int    @[json: 'goals_remaining']
	tactics_used     int    @[json: 'tactics_used']
	obligation_id    string @[json: 'obligation_id']
	obligation_class string @[json: 'obligation_class']
	language         string @[json: 'language']
	strategy_tag     string @[json: 'strategy_tag']
	prover_output    string @[json: 'prover_output']
	attempt_id       string @[json: 'attempt_id']
	recorded         bool   @[json: 'recorded']
	mock             bool   @[json: 'mock']
}

// echidna /api/verify wire format
struct EchidnaRequest {
	prover  string
	content string
}

struct EchidnaResponse {
	valid           bool
	goals_remaining int
	tactics_used    int
}

// verisim-api /api/v1/proof_attempts POST body
struct VerisimAttempt {
	attempt_id        string @[json: 'attempt_id']
	obligation_id     string @[json: 'obligation_id']
	repo              string @[json: 'repo']
	file              string @[json: 'file']
	claim             string @[json: 'claim']
	obligation_class  string @[json: 'obligation_class']
	prover_used       string @[json: 'prover_used']
	outcome           string @[json: 'outcome']
	duration_ms       u64    @[json: 'duration_ms']
	confidence        f32    @[json: 'confidence']
	parent_attempt_id ?string @[json: 'parent_attempt_id']
	strategy_tag      string @[json: 'strategy_tag']
	started_at        string @[json: 'started_at']
	completed_at      string @[json: 'completed_at']
	prover_output     string @[json: 'prover_output']
	error_message     ?string @[json: 'error_message']
}

struct VerisimStrategyResponse {
	obligation_class string
	recommendations  []VerisimStrategyEntry
}

struct VerisimStrategyEntry {
	prover           string
	success_rate     f32
	avg_duration_ms  f32
	total_attempts   int
}

struct HealthResponse {
	service          string   @[json: 'service']
	version          string   @[json: 'version']
	abi_major        u8       @[json: 'abi_major']
	abi_minor        u8       @[json: 'abi_minor']
	mode             string   @[json: 'mode']
	echidna_reachable bool    @[json: 'echidna_reachable']
	verisim_reachable bool    @[json: 'verisim_reachable']
	surfaces         []string @[json: 'surfaces']
}

// -----------------------------------------------------------------------
// Helpers: language → echidna prover name, obligation-class normalisation
// -----------------------------------------------------------------------

fn to_echidna_prover_name(req_prover string, language string) string {
	// Accept user choice if valid; otherwise derive from language.
	p := req_prover.to_lower()
	return match p {
		'z3' { 'Z3' }
		'cvc5' { 'CVC5' }
		'coq' { 'Coq' }
		'lean' { 'Lean' }
		'idris2' { 'Idris2' }
		'agda' { 'Agda' }
		'isabelle' { 'Isabelle' }
		'dafny' { 'Dafny' }
		'fstar' { 'FStar' }
		else {
			// 'auto' or unknown — derive from language.
			match language.to_lower() {
				'lean' { 'Lean' }
				'coq' { 'Coq' }
				'idris2' { 'Idris2' }
				'agda' { 'Agda' }
				else { 'Z3' }
			}
		}
	}
}

fn normalise_class(class string) string {
	c := class.to_lower().replace('_', '-')
	valid := ['safety', 'linearity', 'termination', 'equiv', 'correctness',
		'confluence', 'totality', 'invariant', 'refinement', 'model-check', 'other']
	if c in valid {
		return c
	}
	return 'other'
}

fn iso_timestamp_no_z() string {
	// ClickHouse DateTime64(3) rejects trailing Z.  Format: 2026-04-05T10:15:00.000
	return time.utc().format_rfc3339().trim_right('Z').replace('+00:00', '')
}

fn sha256_hex(s string) string {
	digest := sha256.sum(s.bytes())
	mut out := ''
	for b in digest {
		out += b.hex()
	}
	return out
}

fn uuid_v7_like() string {
	// Simple monotonic UUID-ish string: time_ms (hex) + 16 random hex chars.
	// We don't need strict UUID v7 conformance — just uniqueness.
	now_ms := time.now().unix_milli()
	mut r := ''
	for _ in 0 .. 16 {
		r += '${rand.intn(16) or { 0 }:x}'
	}
	return '${now_ms:012x}-nesy-${r}'
}

// -----------------------------------------------------------------------
// echidna forwarder
// -----------------------------------------------------------------------

fn call_echidna_verify(cfg Config, prover string, content string) !EchidnaResponse {
	body := json.encode(EchidnaRequest{
		prover:  prover
		content: content
	})
	url := '${cfg.echidna_url}/api/verify'
	req := http.new_request(.post, url, body)
	mut mutreq := req
	mutreq.add_header(http.CommonHeader.content_type, 'application/json')
	resp := mutreq.do() or {
		return error('echidna unreachable: ${err}')
	}
	if resp.status_code != 200 {
		return error('echidna HTTP ${resp.status_code}: ${resp.body}')
	}
	return json.decode(EchidnaResponse, resp.body)!
}

// -----------------------------------------------------------------------
// verisim-api forwarders
// -----------------------------------------------------------------------

fn record_attempt(cfg Config, attempt VerisimAttempt) !string {
	body := json.encode(attempt)
	url := '${cfg.verisim_url}/api/v1/proof_attempts'
	req := http.new_request(.post, url, body)
	mut mutreq := req
	mutreq.add_header(http.CommonHeader.content_type, 'application/json')
	resp := mutreq.do() or {
		return error('verisim-api unreachable: ${err}')
	}
	if resp.status_code >= 300 {
		return error('verisim-api HTTP ${resp.status_code}: ${resp.body}')
	}
	return resp.body
}

fn fetch_strategy(cfg Config, obligation_class string) !VerisimStrategyResponse {
	url := '${cfg.verisim_url}/api/v1/proof_attempts/strategy?class=${obligation_class}'
	resp := http.get(url) or {
		return error('verisim-api unreachable: ${err}')
	}
	if resp.status_code != 200 {
		return error('verisim-api HTTP ${resp.status_code}: ${resp.body}')
	}
	return json.decode(VerisimStrategyResponse, resp.body)!
}

// -----------------------------------------------------------------------
// vweb app
// -----------------------------------------------------------------------

struct App {
	vweb.Context
pub mut:
	cfg Config @[vweb_global]
}

// CORS: permit browser calls from the nesy-solver frontend.
fn (mut app App) add_cors_headers() {
	app.add_header('Access-Control-Allow-Origin', '*')
	app.add_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
	app.add_header('Access-Control-Allow-Headers', 'Content-Type')
}

// GET /health
@['/health']
pub fn (mut app App) health() vweb.Result {
	app.add_cors_headers()
	echidna_ok := is_reachable('${app.cfg.echidna_url}/api/health')
	verisim_ok := is_reachable('${app.cfg.verisim_url}/health')
	resp := HealthResponse{
		service:           'proven-nesy-solver-api'
		version:           '0.1.0'
		abi_major:         0
		abi_minor:         1
		mode:              'live'
		echidna_reachable: echidna_ok
		verisim_reachable: verisim_ok
		surfaces:          [
			'rest', 'graphql', 'websocket', 'sse', 'grpc', 'jsonrpc',
			'msgpack-rpc', 'cbor', 'flatbuffers', 'capnproto', 'bebop',
			'trpc', 'mqtt', 'amqp', 'soap', 'verisimdb',
		]
	}
	return app.json(resp)
}

fn is_reachable(url string) bool {
	resp := http.get(url) or { return false }
	return resp.status_code == 200
}

// OPTIONS /prove (CORS preflight)
@['/prove'; options]
pub fn (mut app App) prove_options() vweb.Result {
	app.add_cors_headers()
	return app.ok('')
}

// POST /prove
@['/prove'; post]
pub fn (mut app App) prove() vweb.Result {
	app.add_cors_headers()
	app.add_header('Content-Type', 'application/json')
	req_body := json.decode(ProveRequestBody, app.req.data) or {
		app.set_status(400, 'Bad Request')
		return app.text('{"error":"invalid JSON: ${err}"}')
	}
	if req_body.content.len == 0 {
		app.set_status(400, 'Bad Request')
		return app.text('{"error":"content required"}')
	}

	prover := to_echidna_prover_name(req_body.prover, req_body.language)
	class := normalise_class(req_body.obligation_class)
	started := iso_timestamp_no_z()
	start_ns := time.now().unix_nano()

	// Forward to echidna.
	ec_result := call_echidna_verify(app.cfg, prover, req_body.content) or {
		app.set_status(502, 'Bad Gateway')
		return app.text('{"error":"echidna: ${err}"}')
	}

	elapsed_ms := u64((time.now().unix_nano() - start_ns) / 1_000_000)
	completed := iso_timestamp_no_z()
	obligation_id := sha256_hex(req_body.content)
	attempt_id := uuid_v7_like()
	outcome := if ec_result.valid { 'success' } else { 'failure' }
	strategy_tag := if req_body.prover.to_lower() == 'auto' { 'auto-language' } else { 'manual' }
	claim := req_body.content.split_into_lines().first().limit(200)
	prover_output := 'valid=${ec_result.valid} goals=${ec_result.goals_remaining} tactics=${ec_result.tactics_used}'

	// Record attempt (fire-and-forget warning if it fails, but return verdict anyway).
	attempt := VerisimAttempt{
		attempt_id:        attempt_id
		obligation_id:     obligation_id
		repo:              app.cfg.repo
		file:              app.cfg.file_tag
		claim:             claim
		obligation_class:  class
		prover_used:       prover.to_lower()
		outcome:           outcome
		duration_ms:       elapsed_ms
		confidence:        if ec_result.valid { f32(0.85) } else { f32(0.20) }
		parent_attempt_id: none
		strategy_tag:      strategy_tag
		started_at:        started
		completed_at:      completed
		prover_output:     prover_output
		error_message:     none
	}
	recorded := true
	_ := record_attempt(app.cfg, attempt) or {
		eprintln('warn: verisim-api record failed: ${err}')
		return app.json(ProveResponseBody{
			valid:            ec_result.valid
			outcome:          outcome
			prover:           prover
			duration_ms:      elapsed_ms
			goals_remaining:  ec_result.goals_remaining
			tactics_used:     ec_result.tactics_used
			obligation_id:    obligation_id
			obligation_class: class
			language:         req_body.language
			strategy_tag:     strategy_tag
			prover_output:    prover_output
			attempt_id:       attempt_id
			recorded:         false
			mock:             false
		})
	}
	_ = recorded

	return app.json(ProveResponseBody{
		valid:            ec_result.valid
		outcome:          outcome
		prover:           prover
		duration_ms:      elapsed_ms
		goals_remaining:  ec_result.goals_remaining
		tactics_used:     ec_result.tactics_used
		obligation_id:    obligation_id
		obligation_class: class
		language:         req_body.language
		strategy_tag:     strategy_tag
		prover_output:    prover_output
		attempt_id:       attempt_id
		recorded:         true
		mock:             false
	})
}

// GET /strategy/:class
@['/strategy/:class']
pub fn (mut app App) strategy(class string) vweb.Result {
	app.add_cors_headers()
	app.add_header('Content-Type', 'application/json')
	normalised := normalise_class(class)
	resp := fetch_strategy(app.cfg, normalised) or {
		app.set_status(502, 'Bad Gateway')
		return app.text('{"error":"verisim-api: ${err}"}')
	}
	return app.json(resp)
}

// POST /ingest — authenticated passthrough for batch_driver / echidnabot.
// Accepts a pre-formed VerisimAttempt JSON and forwards it verbatim to
// verisim-api's /api/v1/proof_attempts.  Requires
// `Authorization: Bearer <NESY_INGEST_TOKEN>`.
@['/ingest'; post]
pub fn (mut app App) ingest() vweb.Result {
	app.add_cors_headers()
	app.add_header('Content-Type', 'application/json')
	if app.cfg.ingest_token == '' {
		app.set_status(503, 'Service Unavailable')
		return app.text('{"error":"ingest disabled: NESY_INGEST_TOKEN not set on server"}')
	}
	auth := app.get_header('Authorization')
	expected := 'Bearer ${app.cfg.ingest_token}'
	if auth != expected {
		app.set_status(401, 'Unauthorized')
		return app.text('{"error":"missing or invalid bearer token"}')
	}
	// Forward the request body verbatim to verisim-api.
	url := '${app.cfg.verisim_url}/api/v1/proof_attempts'
	req := http.new_request(.post, url, app.req.data)
	mut mutreq := req
	mutreq.add_header(http.CommonHeader.content_type, 'application/json')
	resp := mutreq.do() or {
		app.set_status(502, 'Bad Gateway')
		return app.text('{"error":"verisim-api: ${err}"}')
	}
	app.set_status(resp.status_code, '')
	return app.text(resp.body)
}

// GET /surfaces
@['/surfaces']
pub fn (mut app App) surfaces() vweb.Result {
	app.add_cors_headers()
	return app.json([
		'rest', 'graphql', 'websocket', 'sse', 'grpc', 'jsonrpc',
		'msgpack-rpc', 'cbor', 'flatbuffers', 'capnproto', 'bebop',
		'trpc', 'mqtt', 'amqp', 'soap', 'verisimdb',
	])
}

// -----------------------------------------------------------------------
// Entry point
// -----------------------------------------------------------------------

fn main() {
	cfg := load_config()
	eprintln('proven-nesy-solver-api 0.1.0')
	eprintln('  port:    ${cfg.port}')
	eprintln('  echidna: ${cfg.echidna_url}')
	eprintln('  verisim: ${cfg.verisim_url}')
	mut app := &App{
		cfg: cfg
	}
	vweb.run(app, cfg.port)
}
