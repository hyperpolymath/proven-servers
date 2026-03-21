# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Top-level module for proven-servers Julia bindings.
#
# Provides type-safe Julia wrappers around the Zig FFI shared libraries
# for the 10 core proven-servers protocols. Each protocol is exposed as
# a submodule with @enum types matching the Idris2 ABI and ccall
# declarations for the C-ABI functions.
#
# Usage:
#   using ProvenServers
#   ctx = Httpd.create_context()
#   Httpd.destroy_context(ctx)

module ProvenServers

include("error.jl")
include("Httpd.jl")
include("Dns.jl")
include("Smtp.jl")
include("Ssh.jl")
include("Mqtt.jl")
include("Ftp.jl")
include("Firewall.jl")
include("Graphql.jl")
include("Grpc.jl")
include("Websocket.jl")

end # module ProvenServers
