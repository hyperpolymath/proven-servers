-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
--- @module proven.ffi
--- LuaJIT FFI declarations and shared library loader for proven-servers.
---
--- Loads `libproven_servers` (and per-protocol libraries) via LuaJIT's FFI
--- or cffi-lua. All `ffi.cdef` blocks mirror the C headers generated from
--- the Idris2 ABI definitions in `src/abi/` and the per-protocol Zig FFI
--- implementations.
---
--- If LuaJIT is not available, falls back to cffi-lua. If neither is present,
--- returns a stub that raises helpful errors on use.

local M = {}

--- Detect FFI implementation: LuaJIT ffi or cffi-lua.
local ffi_ok, ffi = pcall(require, "ffi")
if not ffi_ok then
  ffi_ok, ffi = pcall(require, "cffi")
end

if not ffi_ok then
  --- Stub module returned when no FFI is available.
  M.available = false
  M.ffi = nil
  M.lib = nil

  --- Placeholder that raises a clear error if FFI calls are attempted.
  --- @param name string  The function that was called.
  function M.require_ffi(name)
    error(string.format(
      "proven-servers: FFI not available (need LuaJIT or cffi-lua) — cannot call %s",
      name
    ), 2)
  end

  return M
end

M.available = true
M.ffi = ffi

---------------------------------------------------------------------------
-- Core library C declarations (src/abi/Foreign.idr → ffi/zig/src/main.zig)
---------------------------------------------------------------------------

ffi.cdef[[
  /* ---- Library lifecycle ---- */
  void *proven_servers_init(void);
  void  proven_servers_free(void *handle);

  /* ---- Core operations ---- */
  int   proven_servers_process(void *handle, uint32_t input);

  /* ---- String operations ---- */
  const char *proven_servers_get_string(void *handle);
  void        proven_servers_free_string(const char *str);

  /* ---- Array/buffer operations ---- */
  int   proven_servers_process_array(void *handle, const uint8_t *buf, uint32_t len);

  /* ---- Error handling ---- */
  const char *proven_servers_last_error(void);

  /* ---- Version information ---- */
  const char *proven_servers_version(void);
  const char *proven_servers_build_info(void);

  /* ---- Callback support ---- */
  int   proven_servers_register_callback(void *handle, void *callback);

  /* ---- Utility ---- */
  uint32_t proven_servers_is_initialized(void *handle);
]]

---------------------------------------------------------------------------
-- Per-protocol C declarations
---------------------------------------------------------------------------

ffi.cdef[[
  /* ---- HTTP (proven-httpd) ---- */
  uint32_t http_abi_version(void);
  int      http_create_context(void);
  void     http_destroy_context(int slot);
  uint8_t  http_parse_request(int slot, const uint8_t *data, uint32_t len);
  uint8_t  http_get_method(int slot);
  uint32_t http_get_path(int slot, uint8_t *buf, uint32_t len);
  uint32_t http_get_header(int slot, const uint8_t *key, uint32_t klen,
                           uint8_t *buf, uint32_t blen);
  uint32_t http_get_body(int slot, uint8_t *buf, uint32_t len);
  uint8_t  http_set_status(int slot, uint8_t status_tag);
  uint8_t  http_set_header(int slot, const uint8_t *key, uint32_t klen,
                           const uint8_t *val, uint32_t vlen);
  uint8_t  http_set_body(int slot, const uint8_t *data, uint32_t len);
  uint8_t  http_send_response(int slot);
  uint8_t  http_keep_alive_check(int slot);
  uint8_t  http_get_phase(int slot);
  uint8_t  http_get_version(int slot);
  uint8_t  http_reset_context(int slot);
  uint8_t  http_can_transition(uint8_t from_phase, uint8_t to_phase);

  /* ---- DNS (proven-dns) ---- */
  int      dns_create_context(void);
  void     dns_destroy_context(int slot);
  uint8_t  dns_parse_query(int slot, const uint8_t *data, uint32_t len);
  uint8_t  dns_get_query_type(int slot);
  uint32_t dns_get_query_name(int slot, uint8_t *buf, uint32_t len);
  uint8_t  dns_set_response_code(int slot, uint8_t rcode);
  uint8_t  dns_add_record(int slot, uint8_t rtype, const uint8_t *rdata, uint32_t rlen);
  uint8_t  dns_send_response(int slot);

  /* ---- SMTP (proven-smtp) ---- */
  int      smtp_create_context(void);
  void     smtp_destroy_context(int slot);
  uint8_t  smtp_parse_command(int slot, const uint8_t *data, uint32_t len);
  uint8_t  smtp_get_command(int slot);
  uint8_t  smtp_get_state(int slot);
  uint8_t  smtp_set_reply(int slot, uint16_t code, const uint8_t *msg, uint32_t mlen);
  uint8_t  smtp_send_reply(int slot);

  /* ---- FTP (proven-ftp) ---- */
  int      ftp_create_context(void);
  void     ftp_destroy_context(int slot);
  uint8_t  ftp_parse_command(int slot, const uint8_t *data, uint32_t len);
  uint8_t  ftp_get_command(int slot);
  uint8_t  ftp_get_session_state(int slot);
  uint8_t  ftp_set_reply(int slot, uint16_t code, const uint8_t *msg, uint32_t mlen);
  uint8_t  ftp_send_reply(int slot);

  /* ---- SSH (proven-ssh-bastion) ---- */
  int      ssh_create_context(void);
  void     ssh_destroy_context(int slot);
  uint8_t  ssh_get_state(int slot);
  uint8_t  ssh_set_auth_method(int slot, uint8_t method_tag);
  uint8_t  ssh_set_kex_method(int slot, uint8_t kex_tag);
  uint8_t  ssh_process_message(int slot, const uint8_t *data, uint32_t len);
  uint8_t  ssh_get_message_type(int slot);

  /* ---- MQTT (proven-mqtt) ---- */
  int      mqtt_create_context(void);
  void     mqtt_destroy_context(int slot);
  uint8_t  mqtt_parse_packet(int slot, const uint8_t *data, uint32_t len);
  uint8_t  mqtt_get_packet_type(int slot);
  uint8_t  mqtt_set_qos(int slot, uint8_t qos_tag);
  uint8_t  mqtt_publish(int slot, const uint8_t *topic, uint32_t tlen,
                        const uint8_t *payload, uint32_t plen);
  uint8_t  mqtt_subscribe(int slot, const uint8_t *topic, uint32_t tlen, uint8_t qos_tag);

  /* ---- gRPC (proven-grpc) ---- */
  int      grpc_create_context(void);
  void     grpc_destroy_context(int slot);
  uint8_t  grpc_get_stream_state(int slot);
  uint8_t  grpc_set_status(int slot, uint8_t status_tag);
  uint8_t  grpc_send_message(int slot, const uint8_t *data, uint32_t len);
  uint8_t  grpc_receive_message(int slot, uint8_t *buf, uint32_t len);

  /* ---- GraphQL (proven-graphql) ---- */
  int      graphql_create_context(void);
  void     graphql_destroy_context(int slot);
  uint8_t  graphql_parse_query(int slot, const uint8_t *data, uint32_t len);
  uint8_t  graphql_get_operation_type(int slot);
  uint8_t  graphql_validate(int slot);
  uint8_t  graphql_execute(int slot, uint8_t *buf, uint32_t len);

  /* ---- Firewall (proven-firewall) ---- */
  int      firewall_create_context(void);
  void     firewall_destroy_context(int slot);
  uint8_t  firewall_add_rule(int slot, uint8_t action_tag, uint8_t protocol_tag,
                             uint32_t src_ip, uint32_t dst_ip,
                             uint16_t src_port, uint16_t dst_port);
  uint8_t  firewall_evaluate(int slot, uint8_t protocol_tag,
                             uint32_t src_ip, uint32_t dst_ip,
                             uint16_t src_port, uint16_t dst_port);
  uint8_t  firewall_get_action(int slot);

  /* ---- WebSocket (proven-ws) ---- */
  int      ws_create_context(void);
  void     ws_destroy_context(int slot);
  uint8_t  ws_parse_frame(int slot, const uint8_t *data, uint32_t len);
  uint8_t  ws_get_opcode(int slot);
  uint32_t ws_get_payload(int slot, uint8_t *buf, uint32_t len);
  uint8_t  ws_send_frame(int slot, uint8_t opcode, const uint8_t *data, uint32_t len);
  uint8_t  ws_send_close(int slot, uint16_t code);
]]

---------------------------------------------------------------------------
-- Library loading
---------------------------------------------------------------------------

--- Loaded shared library handle, or nil if loading failed.
--- @type userdata|nil
M.lib = nil

--- Error message from the last failed load attempt.
--- @type string|nil
M.load_error = nil

--- Attempt to load the proven-servers shared library.
---
--- Searches for `libproven_servers` in the standard library paths. On
--- success, sets `M.lib`; on failure, sets `M.load_error`.
---
--- @param path string|nil  Optional explicit path to the shared library.
--- @return boolean  true if the library was loaded successfully.
function M.load(path)
  local lib_name = path or "proven_servers"
  local ok, lib = pcall(ffi.load, lib_name)
  if ok then
    M.lib = lib
    M.load_error = nil
    return true
  end
  M.lib = nil
  M.load_error = tostring(lib)
  return false
end

--- Get the loaded library, raising an error if not loaded.
--- @return userdata  The FFI library handle.
function M.get_lib()
  if M.lib then
    return M.lib
  end
  error("proven-servers: shared library not loaded — call proven.ffi.load() first", 2)
end

-- Attempt auto-load on require (non-fatal).
M.load()

return M
