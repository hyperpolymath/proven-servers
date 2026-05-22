-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
--- @module proven.mqtt
--- MQTT 3.1.1+ protocol bindings for proven-servers.
---
--- Mirrors the Idris2 modules `MQTT.QoS` and `MQTT.PacketType`. Discriminant
--- values are the MQTT 3.1.1 wire values.
---
--- @see protocols/proven-mqtt/src/ for the Idris2 definitions.

local ffi_mod = require("proven.ffi")
local err_mod = require("proven.error")

local M = {}

---------------------------------------------------------------------------
-- MQTT Constants
---------------------------------------------------------------------------

--- Standard MQTT port.
M.MQTT_PORT = 1883

--- MQTT over TLS port.
M.MQTTS_PORT = 8883

---------------------------------------------------------------------------
-- QoS (MQTT 3.1.1 Section 4.3, 2-bit wire codes)
---------------------------------------------------------------------------

--- MQTT Quality of Service levels.
--- @table QoS
M.QoS = {
  AT_MOST_ONCE  = 0,
  AT_LEAST_ONCE = 1,
  EXACTLY_ONCE  = 2,
}

--- Reverse lookup: code -> name.
M.QoSName = {
  [0] = "AT_MOST_ONCE", [1] = "AT_LEAST_ONCE", [2] = "EXACTLY_ONCE",
}

--- Whether a QoS level requires acknowledgement.
--- @param qos number  QoS code (0-2).
--- @return boolean  true if QoS 1 or 2.
function M.requires_ack(qos)
  return qos > 0
end

--- Number of ack packets needed for a QoS flow.
--- @param qos number  QoS code (0-2).
--- @return number  0 for QoS 0, 1 for QoS 1, 3 for QoS 2.
function M.ack_packet_count(qos)
  if qos == 0 then return 0
  elseif qos == 1 then return 1
  else return 3
  end
end

---------------------------------------------------------------------------
-- PacketType (MQTT 3.1.1 Section 2.2)
---------------------------------------------------------------------------

--- MQTT control packet types. Values are the 4-bit wire codes.
--- @table PacketType
M.PacketType = {
  CONNECT     = 1,
  CONNACK     = 2,
  PUBLISH     = 3,
  PUBACK      = 4,
  PUBREC      = 5,
  PUBREL      = 6,
  PUBCOMP     = 7,
  SUBSCRIBE   = 8,
  SUBACK      = 9,
  UNSUBSCRIBE = 10,
  UNSUBACK    = 11,
  PINGREQ     = 12,
  PINGRESP    = 13,
  DISCONNECT  = 14,
}

--- Reverse lookup: wire code -> name.
M.PacketTypeName = {
  [1]  = "CONNECT",  [2]  = "CONNACK",    [3]  = "PUBLISH",
  [4]  = "PUBACK",   [5]  = "PUBREC",     [6]  = "PUBREL",
  [7]  = "PUBCOMP",  [8]  = "SUBSCRIBE",  [9]  = "SUBACK",
  [10] = "UNSUBSCRIBE", [11] = "UNSUBACK", [12] = "PINGREQ",
  [13] = "PINGRESP", [14] = "DISCONNECT",
}

---------------------------------------------------------------------------
-- ConnectReturnCode (MQTT 3.1.1 Section 3.2.2.3)
---------------------------------------------------------------------------

--- CONNACK return codes.
--- @table ConnectReturnCode
M.ConnectReturnCode = {
  ACCEPTED              = 0,
  UNACCEPTABLE_VERSION  = 1,
  IDENTIFIER_REJECTED   = 2,
  SERVER_UNAVAILABLE    = 3,
  BAD_CREDENTIALS       = 4,
  NOT_AUTHORIZED        = 5,
}

---------------------------------------------------------------------------
-- Context (OOP wrapper)
---------------------------------------------------------------------------

--- MQTT context wrapping a slot in the Zig FFI pool.
--- @type Context
local Context = {}
Context.__index = Context

--- Create a new MQTT context.
--- @return Context  A new context, or raises on pool exhaustion.
function Context.new()
  local lib = ffi_mod.get_lib()
  local slot = lib.mqtt_create_context()
  local s, e = err_mod.from_slot(slot)
  if not s then err_mod.raise("mqtt.Context.new", e) end
  return setmetatable({ _slot = s, _destroyed = false }, Context)
end

--- Destroy the context.
function Context:destroy()
  if not self._destroyed then
    local lib = ffi_mod.get_lib()
    lib.mqtt_destroy_context(self._slot)
    self._destroyed = true
  end
end

--- Parse an MQTT packet from raw bytes.
--- @param data string  Raw MQTT packet bytes.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:parse_packet(data)
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local buf = ffi.cast("const uint8_t *", data)
  return err_mod.from_status(lib.mqtt_parse_packet(self._slot, buf, #data))
end

--- Get the parsed packet type.
--- @return number  Packet type wire code, see `M.PacketType`.
function Context:get_packet_type()
  local lib = ffi_mod.get_lib()
  return lib.mqtt_get_packet_type(self._slot)
end

--- Set the QoS level for subsequent operations.
--- @param qos_tag number  QoS code (0-2), see `M.QoS`.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:set_qos(qos_tag)
  local lib = ffi_mod.get_lib()
  return err_mod.from_param_status(lib.mqtt_set_qos(self._slot, qos_tag))
end

--- Publish a message to a topic.
--- @param topic string  Topic string.
--- @param payload string  Message payload bytes.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:publish(topic, payload)
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local t = ffi.cast("const uint8_t *", topic)
  local p = ffi.cast("const uint8_t *", payload)
  return err_mod.from_status(lib.mqtt_publish(self._slot, t, #topic, p, #payload))
end

--- Subscribe to a topic with a given QoS level.
--- @param topic string  Topic filter string.
--- @param qos_tag number  QoS code (0-2), see `M.QoS`.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:subscribe(topic, qos_tag)
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local t = ffi.cast("const uint8_t *", topic)
  return err_mod.from_status(lib.mqtt_subscribe(self._slot, t, #topic, qos_tag))
end

Context.__gc = Context.destroy

M.Context = Context

return M
