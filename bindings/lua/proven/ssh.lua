-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
--- @module proven.ssh
--- SSH Bastion protocol bindings for proven-servers.
---
--- Mirrors the Idris2 module `SshBastionABI.Types`. Tag values match the
--- ABI definitions for `SshMessageType`, `AuthMethod`, `KexMethod`,
--- `ChannelType`, `BastionState`, `DisconnectReason`, `HostKeyAlgorithm`,
--- `CipherAlgorithm`, and `ChannelOpenFailure`.
---
--- @see protocols/proven-ssh-bastion/src/ for the Idris2 definitions.

local ffi_mod = require("proven.ffi")
local err_mod = require("proven.error")

local M = {}

---------------------------------------------------------------------------
-- SSH Constants
---------------------------------------------------------------------------

--- Standard SSH port (RFC 4253).
M.SSH_PORT = 22

---------------------------------------------------------------------------
-- SshMessageType (tags 0-7)
---------------------------------------------------------------------------

--- SSH message types.
--- @table SshMessageType
M.SshMessageType = {
  KEXINIT         = 0,
  NEWKEYS         = 1,
  SERVICE_REQUEST = 2,
  USERAUTH_REQUEST = 3,
  CHANNEL_OPEN    = 4,
  CHANNEL_DATA    = 5,
  CHANNEL_CLOSE   = 6,
  DISCONNECT      = 7,
}

--- Reverse lookup: tag -> name.
M.SshMessageTypeName = {
  [0] = "KEXINIT", [1] = "NEWKEYS", [2] = "SERVICE_REQUEST",
  [3] = "USERAUTH_REQUEST", [4] = "CHANNEL_OPEN", [5] = "CHANNEL_DATA",
  [6] = "CHANNEL_CLOSE", [7] = "DISCONNECT",
}

---------------------------------------------------------------------------
-- AuthMethod (tags 0-3)
---------------------------------------------------------------------------

--- SSH authentication methods.
--- @table AuthMethod
M.AuthMethod = {
  PASSWORD   = 0,
  PUBLIC_KEY = 1,
  KEYBOARD_INTERACTIVE = 2,
  NONE       = 3,
}

---------------------------------------------------------------------------
-- KexMethod (tags 0-5)
---------------------------------------------------------------------------

--- SSH key exchange methods.
--- @table KexMethod
M.KexMethod = {
  CURVE25519_SHA256          = 0,
  ECDH_SHA2_NISTP256         = 1,
  ECDH_SHA2_NISTP384         = 2,
  ECDH_SHA2_NISTP521         = 3,
  DIFFIE_HELLMAN_GROUP14_SHA256 = 4,
  DIFFIE_HELLMAN_GROUP16_SHA512 = 5,
}

---------------------------------------------------------------------------
-- ChannelType (tags 0-3)
---------------------------------------------------------------------------

--- SSH channel types.
--- @table ChannelType
M.ChannelType = {
  SESSION        = 0,
  DIRECT_TCPIP   = 1,
  FORWARDED_TCPIP = 2,
  X11            = 3,
}

---------------------------------------------------------------------------
-- BastionState (tags 0-5)
---------------------------------------------------------------------------

--- SSH bastion connection state machine.
--- @table BastionState
M.BastionState = {
  INITIAL          = 0,
  KEX_IN_PROGRESS  = 1,
  AUTHENTICATED    = 2,
  CHANNEL_OPEN     = 3,
  DATA_TRANSFER    = 4,
  DISCONNECTED     = 5,
}

---------------------------------------------------------------------------
-- HostKeyAlgorithm (tags 0-3)
---------------------------------------------------------------------------

--- SSH host key algorithms.
--- @table HostKeyAlgorithm
M.HostKeyAlgorithm = {
  SSH_ED25519         = 0,
  ECDSA_SHA2_NISTP256 = 1,
  RSA_SHA2_256        = 2,
  RSA_SHA2_512        = 3,
}

---------------------------------------------------------------------------
-- CipherAlgorithm (tags 0-5)
---------------------------------------------------------------------------

--- SSH symmetric cipher algorithms.
--- @table CipherAlgorithm
M.CipherAlgorithm = {
  CHACHA20_POLY1305        = 0,
  AES256_GCM               = 1,
  AES128_GCM               = 2,
  AES256_CTR               = 3,
  AES192_CTR               = 4,
  AES128_CTR               = 5,
}

---------------------------------------------------------------------------
-- DisconnectReason (tags 0-11)
---------------------------------------------------------------------------

--- SSH disconnect reason codes (RFC 4253 Section 11.1).
--- @table DisconnectReason
M.DisconnectReason = {
  HOST_NOT_ALLOWED       = 0,
  PROTOCOL_ERROR         = 1,
  KEY_EXCHANGE_FAILED    = 2,
  RESERVED               = 3,
  MAC_ERROR              = 4,
  COMPRESSION_ERROR      = 5,
  SERVICE_NOT_AVAILABLE  = 6,
  PROTOCOL_VERSION       = 7,
  HOST_KEY_NOT_VERIFIABLE = 8,
  CONNECTION_LOST        = 9,
  BY_APPLICATION         = 10,
  TOO_MANY_CONNECTIONS   = 11,
}

---------------------------------------------------------------------------
-- ChannelOpenFailure (tags 0-3)
---------------------------------------------------------------------------

--- SSH channel open failure reasons.
--- @table ChannelOpenFailure
M.ChannelOpenFailure = {
  ADMINISTRATIVELY_PROHIBITED = 0,
  CONNECT_FAILED              = 1,
  UNKNOWN_CHANNEL_TYPE        = 2,
  RESOURCE_SHORTAGE           = 3,
}

---------------------------------------------------------------------------
-- Context (OOP wrapper)
---------------------------------------------------------------------------

--- SSH context wrapping a slot in the Zig FFI pool.
--- @type Context
local Context = {}
Context.__index = Context

--- Create a new SSH context.
--- @return Context  A new context, or raises on pool exhaustion.
function Context.new()
  local lib = ffi_mod.get_lib()
  local slot = lib.ssh_create_context()
  local s, e = err_mod.from_slot(slot)
  if not s then err_mod.raise("ssh.Context.new", e) end
  return setmetatable({ _slot = s, _destroyed = false }, Context)
end

--- Destroy the context.
function Context:destroy()
  if not self._destroyed then
    local lib = ffi_mod.get_lib()
    lib.ssh_destroy_context(self._slot)
    self._destroyed = true
  end
end

--- Get the current bastion state tag.
--- @return number  State tag (0-5), see `M.BastionState`.
function Context:get_state()
  local lib = ffi_mod.get_lib()
  return lib.ssh_get_state(self._slot)
end

--- Set the authentication method.
--- @param method_tag number  Auth method tag (0-3), see `M.AuthMethod`.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:set_auth_method(method_tag)
  local lib = ffi_mod.get_lib()
  return err_mod.from_param_status(lib.ssh_set_auth_method(self._slot, method_tag))
end

--- Set the key exchange method.
--- @param kex_tag number  KEX method tag (0-5), see `M.KexMethod`.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:set_kex_method(kex_tag)
  local lib = ffi_mod.get_lib()
  return err_mod.from_param_status(lib.ssh_set_kex_method(self._slot, kex_tag))
end

--- Process an incoming SSH message.
--- @param data string  Raw SSH message bytes.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:process_message(data)
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local buf = ffi.cast("const uint8_t *", data)
  return err_mod.from_status(lib.ssh_process_message(self._slot, buf, #data))
end

--- Get the last processed message type tag.
--- @return number  Message type tag (0-7), see `M.SshMessageType`.
function Context:get_message_type()
  local lib = ffi_mod.get_lib()
  return lib.ssh_get_message_type(self._slot)
end

Context.__gc = Context.destroy

M.Context = Context

return M
