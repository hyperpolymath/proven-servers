// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// rgtv_client.v: RGTV grant-broker client for proven-nesy-solver-api.
//
// Credentials the nesy-solver-api needs (NESY_INGEST_TOKEN) are brokered
// through the RGTV vault-broker so that LLM agents never see raw values.
//
// Protocol (two-step):
//   1. POST /v1/grants  { "hint": "NESY_INGEST_TOKEN" }
//      → 201 { "grant_id": "...", "expires_in_secs": 30 }
//   2. POST /v1/grants/:grant_id/redeem
//      → 200 { "hint": "...", "value": "<credential>" }
//
// Both requests carry:
//   Authorization: Bearer <RGTV_AGENT_TOKEN>
//
// If RGTV_URL is not set, falls back to the raw NESY_INGEST_TOKEN env var
// so local development without a running broker still works.
//
// Each load_* function should be called once at startup.  Treat the returned
// string as a secret: do not log it, do not embed it in URLs or filenames.

module main

import net.http
import json
import os
import time

// ---------------------------------------------------------------------------
// Wire types
// ---------------------------------------------------------------------------

struct RgtvGrantRequest {
	hint string @[json: 'hint']
}

struct RgtvGrantResponse {
	grant_id       string @[json: 'grant_id']
	hint           string @[json: 'hint']
	expires_in_secs int   @[json: 'expires_in_secs']
}

struct RgtvRedeemResponse {
	hint  string @[json: 'hint']
	value string @[json: 'value']
}

struct RgtvErrorResponse {
	error string @[json: 'error']
}

// ---------------------------------------------------------------------------
// Core grant / redeem cycle
// ---------------------------------------------------------------------------

// fetch_from_rgtv requests a one-use grant for `hint` from the RGTV broker
// at `rgtv_url`, authenticating with `agent_token`, then immediately redeems
// it and returns the credential value.
//
// The grant is single-use and expires in ~30 s.  Errors from either step
// are returned as V errors; the caller should fall back to env-var loading.
fn fetch_from_rgtv(rgtv_url string, agent_token string, hint string) !string {
	bearer := 'Bearer ${agent_token}'

	// -- Step 1: request grant --
	grant_body := json.encode(RgtvGrantRequest{ hint: hint })
	mut grant_req := http.new_request(.post, '${rgtv_url}/v1/grants', grant_body)
	grant_req.add_header(http.CommonHeader.content_type, 'application/json')
	grant_req.add_header(http.CommonHeader.authorization, bearer)
	grant_req.read_timeout = 10 * time.second

	grant_resp := grant_req.do() or {
		return error('rgtv: grant request failed: ${err}')
	}
	if grant_resp.status_code != 201 {
		rgtv_err := json.decode(RgtvErrorResponse, grant_resp.body) or {
			RgtvErrorResponse{ error: grant_resp.body }
		}
		return error('rgtv: grant HTTP ${grant_resp.status_code}: ${rgtv_err.error}')
	}
	grant := json.decode(RgtvGrantResponse, grant_resp.body) or {
		return error('rgtv: invalid grant response: ${err}')
	}

	// -- Step 2: redeem grant --
	mut redeem_req := http.new_request(.post,
		'${rgtv_url}/v1/grants/${grant.grant_id}/redeem', '{}')
	redeem_req.add_header(http.CommonHeader.content_type, 'application/json')
	redeem_req.add_header(http.CommonHeader.authorization, bearer)
	redeem_req.read_timeout = 10 * time.second

	redeem_resp := redeem_req.do() or {
		return error('rgtv: redeem request failed: ${err}')
	}
	if redeem_resp.status_code != 200 {
		rgtv_err := json.decode(RgtvErrorResponse, redeem_resp.body) or {
			RgtvErrorResponse{ error: redeem_resp.body }
		}
		return error('rgtv: redeem HTTP ${redeem_resp.status_code}: ${rgtv_err.error}')
	}
	redeem := json.decode(RgtvRedeemResponse, redeem_resp.body) or {
		return error('rgtv: invalid redeem response: ${err}')
	}

	return redeem.value
}

// ---------------------------------------------------------------------------
// Per-credential loaders
// ---------------------------------------------------------------------------

// load_ingest_token returns the NESY_INGEST_TOKEN value.
// Tries RGTV first; falls back to the raw env var if RGTV_URL is unset or
// the broker is unreachable.  Logs a warning (never the value) on fallback.
fn load_ingest_token() string {
	rgtv_url := os.getenv('RGTV_URL')
	if rgtv_url != '' {
		agent_token := os.getenv('RGTV_AGENT_TOKEN')
		if agent_token == '' {
			eprintln('warn: RGTV_URL is set but RGTV_AGENT_TOKEN is missing — falling back to env')
		} else {
			val := fetch_from_rgtv(rgtv_url, agent_token, 'NESY_INGEST_TOKEN') or {
				eprintln('warn: rgtv fetch(NESY_INGEST_TOKEN) failed: ${err} — falling back to env')
				return os.getenv_opt('NESY_INGEST_TOKEN') or { '' }
			}
			eprintln('info: NESY_INGEST_TOKEN loaded via RGTV grant broker')
			return val
		}
	}
	// Direct env fallback (local dev / RGTV not deployed yet).
	return os.getenv_opt('NESY_INGEST_TOKEN') or { '' }
}
