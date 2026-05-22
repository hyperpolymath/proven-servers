-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
--- @module proven.dns
--- DNS protocol bindings for proven-servers.
---
--- Mirrors the Idris2 `DNS` module and `DNS.RecordType`. Constants are
--- derived from RFC 1035 and RFC 6891. Record type discriminants match
--- the standard IANA DNS type codes.
---
--- @see protocols/proven-dns/src/ for the Idris2 definitions.

local ffi_mod = require("proven.ffi")
local err_mod = require("proven.error")

local M = {}

---------------------------------------------------------------------------
-- DNS Constants (DNS module)
---------------------------------------------------------------------------

--- Standard DNS port (RFC 1035).
M.DNS_PORT = 53

--- Maximum UDP message size without EDNS (RFC 1035 Section 4.2.1).
M.MAX_UDP_SIZE = 512

--- Maximum TCP message size (RFC 1035 Section 4.2.2).
M.MAX_TCP_SIZE = 65535

--- Maximum label length in bytes (RFC 1035 Section 2.3.4).
M.MAX_LABEL_LENGTH = 63

--- Maximum total domain name length including dots (RFC 1035).
M.MAX_NAME_LENGTH = 253

--- EDNS(0) default UDP payload size (RFC 6891).
M.EDNS_UDP_SIZE = 4096

---------------------------------------------------------------------------
-- Record Type (DNS.RecordType, IANA type codes)
---------------------------------------------------------------------------

--- DNS resource record types.
--- Discriminant values are IANA DNS type codes.
--- @table RecordType
M.RecordType = {
  A     = 1,    -- IPv4 address (RFC 1035)
  AAAA  = 28,   -- IPv6 address (RFC 3596)
  CNAME = 5,    -- Canonical name (RFC 1035)
  MX    = 15,   -- Mail exchange (RFC 1035)
  NS    = 2,    -- Name server (RFC 1035)
  TXT   = 16,   -- Text record (RFC 1035)
  SOA   = 6,    -- Start of authority (RFC 1035)
  SRV   = 33,   -- Service locator (RFC 2782)
  PTR   = 12,   -- Pointer record (RFC 1035)
}

--- Reverse lookup: type code -> name string.
M.RecordTypeName = {
  [1]  = "A",   [28] = "AAAA", [5]  = "CNAME", [15] = "MX",
  [2]  = "NS",  [16] = "TXT",  [6]  = "SOA",   [33] = "SRV",
  [12] = "PTR",
}

---------------------------------------------------------------------------
-- Response Code (DNS RCODE, RFC 1035 Section 4.1.1)
---------------------------------------------------------------------------

--- DNS response codes.
--- @table ResponseCode
M.ResponseCode = {
  NOERROR  = 0,
  FORMERR  = 1,
  SERVFAIL = 2,
  NXDOMAIN = 3,
  NOTIMP   = 4,
  REFUSED  = 5,
}

---------------------------------------------------------------------------
-- Context (OOP wrapper)
---------------------------------------------------------------------------

--- DNS context wrapping a slot in the Zig FFI pool.
--- @type Context
local Context = {}
Context.__index = Context

--- Create a new DNS context.
--- @return Context  A new context, or raises on pool exhaustion.
function Context.new()
  local lib = ffi_mod.get_lib()
  local slot = lib.dns_create_context()
  local s, e = err_mod.from_slot(slot)
  if not s then err_mod.raise("dns.Context.new", e) end
  return setmetatable({ _slot = s, _destroyed = false }, Context)
end

--- Destroy the context, releasing the slot.
function Context:destroy()
  if not self._destroyed then
    local lib = ffi_mod.get_lib()
    lib.dns_destroy_context(self._slot)
    self._destroyed = true
  end
end

--- Parse a DNS query from raw bytes.
--- @param data string  Raw DNS query packet.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:parse_query(data)
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local buf = ffi.cast("const uint8_t *", data)
  return err_mod.from_status(lib.dns_parse_query(self._slot, buf, #data))
end

--- Get the parsed query record type tag.
--- @return number  Record type code, see `M.RecordType`.
function Context:get_query_type()
  local lib = ffi_mod.get_lib()
  return lib.dns_get_query_type(self._slot)
end

--- Set the response code.
--- @param rcode number  Response code, see `M.ResponseCode`.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:set_response_code(rcode)
  local lib = ffi_mod.get_lib()
  return err_mod.from_status(lib.dns_set_response_code(self._slot, rcode))
end

--- Add a resource record to the response.
--- @param rtype number  Record type code.
--- @param rdata string  Record data bytes.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:add_record(rtype, rdata)
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local buf = ffi.cast("const uint8_t *", rdata)
  return err_mod.from_status(lib.dns_add_record(self._slot, rtype, buf, #rdata))
end

--- Send the constructed DNS response.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:send_response()
  local lib = ffi_mod.get_lib()
  return err_mod.from_status(lib.dns_send_response(self._slot))
end

Context.__gc = Context.destroy

M.Context = Context

return M
