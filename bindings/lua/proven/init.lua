-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
--- @module proven
--- Top-level module for the proven-servers Lua bindings.
---
--- Re-exports all 10 core protocol modules plus shared error handling and
--- the FFI loader. Each sub-module provides Lua tables mirroring the Idris2
--- ABI enums and metatabled wrappers around the Zig FFI C functions.
---
--- @usage
---   local proven = require("proven")
---   local ctx = proven.httpd.Context.new()
---   ctx:parse_request(data)
---   local method = ctx:get_method()
---   ctx:destroy()

local proven = {}

--- Library version string, kept in sync with the Zig FFI and Cargo workspace.
proven.VERSION = "0.1.0"

--- Shared error handling utilities.
proven.error = require("proven.error")

--- Low-level FFI declarations and library loader.
proven.ffi = require("proven.ffi")

--- HTTP/1.1+ protocol bindings (proven-httpd).
proven.httpd = require("proven.httpd")

--- DNS protocol bindings (proven-dns).
proven.dns = require("proven.dns")

--- SMTP protocol bindings (proven-smtp).
proven.smtp = require("proven.smtp")

--- FTP protocol bindings (proven-ftp).
proven.ftp = require("proven.ftp")

--- SSH Bastion protocol bindings (proven-ssh-bastion).
proven.ssh = require("proven.ssh")

--- MQTT 3.1.1+ protocol bindings (proven-mqtt).
proven.mqtt = require("proven.mqtt")

--- gRPC/HTTP2 protocol bindings (proven-grpc).
proven.grpc = require("proven.grpc")

--- GraphQL protocol bindings (proven-graphql).
proven.graphql = require("proven.graphql")

--- Firewall (netfilter) bindings (proven-firewall).
proven.firewall = require("proven.firewall")

--- WebSocket protocol bindings (proven-ws).
proven.websocket = require("proven.websocket")

return proven
