-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
--- @module proven.firewall
--- Firewall (netfilter) bindings for proven-servers.
---
--- Mirrors the Idris2 module `FirewallABI.Types`. Tag values match the
--- ABI definitions for `Action`, `Protocol`, `ChainType`,
--- `RuleMatchType`, and `ConnState`.
---
--- @see protocols/proven-firewall/src/ for the Idris2 definitions.

local ffi_mod = require("proven.ffi")
local err_mod = require("proven.error")

local M = {}

---------------------------------------------------------------------------
-- Action (tags 0-7)
---------------------------------------------------------------------------

--- Firewall rule actions.
--- @table Action
M.Action = {
  ACCEPT     = 0,
  DROP       = 1,
  REJECT     = 2,
  LOG        = 3,
  REDIRECT   = 4,
  DNAT       = 5,
  SNAT       = 6,
  MASQUERADE = 7,
}

--- Reverse lookup: tag -> name.
M.ActionName = {
  [0] = "ACCEPT", [1] = "DROP", [2] = "REJECT", [3] = "LOG",
  [4] = "REDIRECT", [5] = "DNAT", [6] = "SNAT", [7] = "MASQUERADE",
}

---------------------------------------------------------------------------
-- Protocol (tags 0-5)
---------------------------------------------------------------------------

--- Network protocols for firewall rules.
--- @table Protocol
M.Protocol = {
  TCP  = 0,
  UDP  = 1,
  ICMP = 2,
  SCTP = 3,
  GRE  = 4,
  ANY  = 5,
}

--- Reverse lookup: tag -> name.
M.ProtocolName = {
  [0] = "TCP", [1] = "UDP", [2] = "ICMP", [3] = "SCTP",
  [4] = "GRE", [5] = "ANY",
}

---------------------------------------------------------------------------
-- ChainType (tags 0-4)
---------------------------------------------------------------------------

--- Firewall chain types (netfilter).
--- @table ChainType
M.ChainType = {
  INPUT       = 0,
  OUTPUT      = 1,
  FORWARD     = 2,
  PREROUTING  = 3,
  POSTROUTING = 4,
}

---------------------------------------------------------------------------
-- RuleMatchType (tags 0-5)
---------------------------------------------------------------------------

--- Firewall rule match criteria types.
--- @table RuleMatchType
M.RuleMatchType = {
  SOURCE_IP   = 0,
  DEST_IP     = 1,
  SOURCE_PORT = 2,
  DEST_PORT   = 3,
  PROTOCOL    = 4,
  CONN_STATE  = 5,
}

---------------------------------------------------------------------------
-- ConnState (tags 0-3)
---------------------------------------------------------------------------

--- Connection tracking states.
--- @table ConnState
M.ConnState = {
  NEW         = 0,
  ESTABLISHED = 1,
  RELATED     = 2,
  INVALID     = 3,
}

--- Reverse lookup: tag -> name.
M.ConnStateName = {
  [0] = "NEW", [1] = "ESTABLISHED", [2] = "RELATED", [3] = "INVALID",
}

---------------------------------------------------------------------------
-- Context (OOP wrapper)
---------------------------------------------------------------------------

--- Firewall context wrapping a slot in the Zig FFI pool.
--- @type Context
local Context = {}
Context.__index = Context

--- Create a new Firewall context.
--- @return Context  A new context, or raises on pool exhaustion.
function Context.new()
  local lib = ffi_mod.get_lib()
  local slot = lib.firewall_create_context()
  local s, e = err_mod.from_slot(slot)
  if not s then err_mod.raise("firewall.Context.new", e) end
  return setmetatable({ _slot = s, _destroyed = false }, Context)
end

--- Destroy the context.
function Context:destroy()
  if not self._destroyed then
    local lib = ffi_mod.get_lib()
    lib.firewall_destroy_context(self._slot)
    self._destroyed = true
  end
end

--- Add a firewall rule.
--- @param action_tag number  Action tag (0-7), see `M.Action`.
--- @param protocol_tag number  Protocol tag (0-5), see `M.Protocol`.
--- @param src_ip number  Source IP as uint32 (network byte order).
--- @param dst_ip number  Destination IP as uint32 (network byte order).
--- @param src_port number  Source port.
--- @param dst_port number  Destination port.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:add_rule(action_tag, protocol_tag, src_ip, dst_ip, src_port, dst_port)
  local lib = ffi_mod.get_lib()
  return err_mod.from_status(lib.firewall_add_rule(
    self._slot, action_tag, protocol_tag,
    src_ip, dst_ip, src_port, dst_port
  ))
end

--- Evaluate a packet against the loaded rules.
--- @param protocol_tag number  Protocol tag (0-5).
--- @param src_ip number  Source IP as uint32.
--- @param dst_ip number  Destination IP as uint32.
--- @param src_port number  Source port.
--- @param dst_port number  Destination port.
--- @return number  Action tag resulting from evaluation.
function Context:evaluate(protocol_tag, src_ip, dst_ip, src_port, dst_port)
  local lib = ffi_mod.get_lib()
  lib.firewall_evaluate(
    self._slot, protocol_tag,
    src_ip, dst_ip, src_port, dst_port
  )
  return lib.firewall_get_action(self._slot)
end

Context.__gc = Context.destroy

M.Context = Context

return M
