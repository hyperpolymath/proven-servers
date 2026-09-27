-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
--- @module proven.dns
--- Bindings for the bounded proven-dns message-builder FFI.
---
--- The FFI accepts only exact 17-byte standard queries with one root-name
--- question, recognized QTYPE/QCLASS, no other sections, and RD as its only
--- supported flag. Responses are capped at 512 bytes. This is not a general
--- resolver; DNSSEC key loading, signing, and validation fail closed.
---
--- The RFC constants below describe DNS generally; they do not imply that
--- EDNS, arbitrary QNAMEs, TCP transport, or a network server are implemented.

local ffi_mod = require("proven.ffi")
local err_mod = require("proven.error")

local M = {}

---------------------------------------------------------------------------
-- DNS constants and ABI tags
---------------------------------------------------------------------------

--- Standard DNS port (RFC 1035); the FFI does not open sockets.
M.DNS_PORT = 53

--- Standard protocol size constants (RFC 1035/RFC 6891); not FFI capabilities.
M.MAX_UDP_SIZE = 512
M.MAX_TCP_SIZE = 65535
M.MAX_LABEL_LENGTH = 63
M.MAX_NAME_LENGTH = 253
M.EDNS_UDP_SIZE = 4096

--- Current FFI parser contract.
M.FFI_QUERY_LENGTH = 17
M.FFI_MAX_RESPONSE_SIZE = 512

--- IANA DNS wire type codes for the model's supported record-type subset.
M.RecordType = {
  A = 1, AAAA = 28, CNAME = 5, MX = 15, NS = 2,
  TXT = 16, SOA = 6, SRV = 33, PTR = 12,
}

--- Record-type ABI tags accepted by dns_add_* (not IANA wire codes).
M.RecordTypeTag = {
  A = 0, AAAA = 1, CNAME = 2, MX = 3, NS = 4,
  PTR = 5, SOA = 6, SRV = 7, TXT = 8,
}

--- Query-class ABI tags accepted by dns_add_*.
M.RecordClassTag = { IN = 0, CH = 1, HS = 2, ANY = 3 }

--- Corresponding IANA wire class codes.
M.RecordClass = { IN = 1, CH = 3, HS = 4, ANY = 255 }

--- DNS response-code ABI tags.
M.ResponseCode = {
  NOERROR = 0, FORMERR = 1, SERVFAIL = 2,
  NXDOMAIN = 3, NOTIMP = 4, REFUSED = 5,
}

M.DnsState = {
  IDLE = 0, QUERY_RECEIVED = 1, LOOKUP = 2,
  RESPONSE_BUILDING = 3, SENT = 4,
}

--- DNSSEC states are ABI/model tags only; crypto operations are unavailable.
M.DnssecState = { DISABLED = 0, ENABLED = 1, KEY_LOADED = 2, VALIDATED = 3 }

local TAG_TO_WIRE = { [0] = 1, [1] = 28, [2] = 5, [3] = 15, [4] = 2,
                      [5] = 12, [6] = 6, [7] = 33, [8] = 16 }

---------------------------------------------------------------------------
-- Context
---------------------------------------------------------------------------

--- Context wrapping a slot in the bounded Zig FFI pool.
--- @type Context
local Context = {}
Context.__index = Context

local function status_result(raw, context)
  local ok, err = err_mod.from_status(raw)
  if not ok then return nil, err end
  return true, nil
end

--- Create a new DNS message-builder context.
--- @return Context|nil context, or nil and an error key.
function Context.new()
  local lib = ffi_mod.get_lib()
  local slot, err = err_mod.from_slot(lib.dns_create_context())
  if not slot then err_mod.raise("dns.Context.new", err) end
  return setmetatable({ _slot = slot, _destroyed = false }, Context)
end

--- Destroy the context, releasing its slot.
function Context:destroy()
  if not self._destroyed then
    ffi_mod.get_lib().dns_destroy_context(self._slot)
    self._destroyed = true
  end
end

--- Get the current lifecycle-state ABI tag.
function Context:get_state()
  return ffi_mod.get_lib().dns_state(self._slot)
end

--- Get the current DNSSEC ABI/model-state tag.
function Context:get_dnssec_state()
  return ffi_mod.get_lib().dns_dnssec_state(self._slot)
end

--- Get the response-code ABI tag.
function Context:get_response_code()
  return ffi_mod.get_lib().dns_rcode(self._slot)
end

--- Get the parsed query's record-type ABI tag (255 means unset).
function Context:get_query_type()
  return ffi_mod.get_lib().dns_query_rtype(self._slot)
end

--- Get the parsed query's record-class ABI tag (255 means unset).
function Context:get_query_class()
  return ffi_mod.get_lib().dns_query_class(self._slot)
end

--- Convert a query-type ABI tag to its IANA wire type, or nil if unsupported.
function Context:get_query_type_wire()
  return TAG_TO_WIRE[self:get_query_type()]
end

--- Get section record counts as an answer/authority/additional triple.
function Context:get_record_counts()
  local lib = ffi_mod.get_lib()
  return lib.dns_answer_count(self._slot),
         lib.dns_authority_count(self._slot),
         lib.dns_additional_count(self._slot)
end

--- Parse only an exact 17-byte standard root-question query.
--- @param data string raw DNS query bytes
--- @return boolean|nil true on success, nil plus an error key on failure
function Context:parse_query(data)
  if type(data) ~= "string" or #data ~= M.FFI_QUERY_LENGTH then
    return nil, err_mod.ProvenError.INVALID_PARAMETER
  end
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local buf = ffi.cast("const uint8_t *", data)
  return status_result(lib.dns_parse_query(self._slot, buf, #data), "dns.parse_query")
end

--- Transition QueryReceived -> Lookup.
function Context:begin_lookup()
  return status_result(ffi_mod.get_lib().dns_begin_lookup(self._slot), "dns.begin_lookup")
end

--- Transition Lookup -> ResponseBuilding.
function Context:begin_response()
  return status_result(ffi_mod.get_lib().dns_begin_response(self._slot), "dns.begin_response")
end

--- Set the response-code ABI tag.
function Context:set_response_code(rcode_tag)
  if type(rcode_tag) ~= "number" or rcode_tag < 0 or rcode_tag > 10 or rcode_tag % 1 ~= 0 then
    return nil, err_mod.ProvenError.INVALID_PARAMETER
  end
  return status_result(ffi_mod.get_lib().dns_set_rcode(self._slot, rcode_tag), "dns.set_response_code")
end

local function add_record(ctx, function_name, rtype_tag, rclass_tag, ttl, rdata)
  if type(rdata) ~= "string" or #rdata > 256 then
    return nil, err_mod.ProvenError.CAPACITY_EXCEEDED
  end
  if type(rtype_tag) ~= "number" or rtype_tag < 0 or rtype_tag > 14 or rtype_tag % 1 ~= 0 or
     type(rclass_tag) ~= "number" or rclass_tag < 0 or rclass_tag > 3 or rclass_tag % 1 ~= 0 or
     type(ttl) ~= "number" or ttl < 0 or ttl > 4294967295 or ttl % 1 ~= 0 then
    return nil, err_mod.ProvenError.INVALID_PARAMETER
  end
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local buf = ffi.cast("const uint8_t *", rdata)
  return status_result(lib[function_name](ctx._slot, rtype_tag, rclass_tag, ttl, buf, #rdata),
                       "dns." .. function_name)
end

--- Add an answer RR. Type/class arguments are ABI tags; RDATA is at most 256 bytes.
function Context:add_answer(rtype_tag, rclass_tag, ttl, rdata)
  return add_record(self, "dns_add_answer", rtype_tag, rclass_tag, ttl, rdata)
end

--- Add an authority RR. Type/class arguments are ABI tags; RDATA is at most 256 bytes.
function Context:add_authority(rtype_tag, rclass_tag, ttl, rdata)
  return add_record(self, "dns_add_authority", rtype_tag, rclass_tag, ttl, rdata)
end

--- Add an additional RR. Type/class arguments are ABI tags; RDATA is at most 256 bytes.
function Context:add_additional(rtype_tag, rclass_tag, ttl, rdata)
  return add_record(self, "dns_add_additional", rtype_tag, rclass_tag, ttl, rdata)
end

--- Build the bounded DNS response bytes (at most 512); no network I/O occurs.
--- @return string|nil response or nil plus an error key
function Context:build_response()
  local ffi = ffi_mod.ffi
  local lib = ffi_mod.get_lib()
  local out = ffi.new("uint8_t[512]")
  local out_len = ffi.new("uint16_t[1]")
  local ok, err = status_result(lib.dns_build_response(self._slot, out, out_len), "dns.build_response")
  if not ok then return nil, err end
  return ffi.string(out, tonumber(out_len[0]))
end

--- Deprecated alias for build_response; this binding does not send packets.
function Context:send_response()
  return self:build_response()
end

--- Enable DNSSEC mode only; subsequent response construction rejects without a signer.
function Context:enable_dnssec()
  return status_result(ffi_mod.get_lib().dns_enable_dnssec(self._slot), "dns.enable_dnssec")
end

--- DNSSEC key loading always fails closed because the ABI has no key bytes.
function Context:load_dnssec_key(algo_tag)
  if type(algo_tag) ~= "number" or algo_tag < 0 or algo_tag > 4 or algo_tag % 1 ~= 0 then
    return nil, err_mod.ProvenError.INVALID_PARAMETER
  end
  return status_result(ffi_mod.get_lib().dns_load_dnssec_key(self._slot, algo_tag), "dns.load_dnssec_key")
end

--- DNSSEC signing always fails closed because no signing backend exists.
function Context:sign_response()
  return status_result(ffi_mod.get_lib().dns_sign_response(self._slot), "dns.sign_response")
end

--- DNSSEC validation always fails closed because no validator exists.
function Context:validate_dnssec()
  return ffi_mod.get_lib().dns_validate_dnssec(self._slot) == 0
end

Context.__gc = Context.destroy
M.Context = Context

--- Check a query lifecycle transition. This is a model check, not an operation.
function M.can_transition(from_tag, to_tag)
  return ffi_mod.get_lib().dns_can_transition(from_tag, to_tag) == 1
end

--- Check an abstract DNSSEC transition; this does not imply crypto availability.
function M.can_dnssec_transition(from_tag, to_tag)
  return ffi_mod.get_lib().dns_can_dnssec_transition(from_tag, to_tag) == 1
end

function M.abi_version()
  return ffi_mod.get_lib().dns_abi_version()
end

return M
