-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
--- LuaRocks package specification for proven-servers Lua bindings.
---
--- Provides Lua (LuaJIT FFI) bindings to the proven-servers formally verified
--- protocol ABI. All type definitions mirror the Idris2 ABI layer; FFI calls
--- go through the Zig-compiled shared library.

package = "proven-servers"
version = "0.1.0-1"
source = {
  url = "https://github.com/hyperpolymath/proven-servers/archive/refs/tags/v0.1.0.tar.gz",
  dir = "proven-servers-0.1.0/bindings/lua",
}

description = {
  summary = "Lua bindings for the proven-servers formally verified protocol ABI",
  detailed = [[
    Type-safe Lua wrappers for the proven-servers library. Covers 10 core
    protocols (HTTP, DNS, SMTP, FTP, SSH, MQTT, gRPC, GraphQL, Firewall,
    WebSocket) with enum tables matching the Idris2 ABI and LuaJIT FFI
    declarations for the Zig FFI layer.
  ]],
  homepage = "https://github.com/hyperpolymath/proven-servers",
  license = "MPL-2.0",
  maintainer = "Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>",
}

dependencies = {
  "lua >= 5.1",
}

build = {
  type = "builtin",
  modules = {
    ["proven"]           = "proven/init.lua",
    ["proven.error"]     = "proven/error.lua",
    ["proven.ffi"]       = "proven/ffi.lua",
    ["proven.httpd"]     = "proven/httpd.lua",
    ["proven.dns"]       = "proven/dns.lua",
    ["proven.smtp"]      = "proven/smtp.lua",
    ["proven.ftp"]       = "proven/ftp.lua",
    ["proven.ssh"]       = "proven/ssh.lua",
    ["proven.mqtt"]      = "proven/mqtt.lua",
    ["proven.grpc"]      = "proven/grpc.lua",
    ["proven.graphql"]   = "proven/graphql.lua",
    ["proven.firewall"]  = "proven/firewall.lua",
    ["proven.websocket"] = "proven/websocket.lua",
  },
}
