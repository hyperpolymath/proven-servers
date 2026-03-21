# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Top-level require for the proven-servers Ruby bindings.
#
# Usage:
#   require "proven_servers"
#
# Then use individual protocol modules:
#   ProvenServers::Httpd.with_context { |ctx| ... }
#   ProvenServers::Dns.with_context { |ctx| ... }

# frozen_string_literal: true

require_relative "proven_servers/error"
require_relative "proven_servers/ffi"
require_relative "proven_servers/httpd"
require_relative "proven_servers/dns"
require_relative "proven_servers/smtp"
require_relative "proven_servers/ftp"
require_relative "proven_servers/ssh_bastion"
require_relative "proven_servers/mqtt"
require_relative "proven_servers/grpc"
require_relative "proven_servers/graphql"
require_relative "proven_servers/tls"
require_relative "proven_servers/firewall"

# Top-level namespace for the proven-servers Ruby bindings.
#
# Each protocol is exposed as a sub-module (e.g. +ProvenServers::Httpd+)
# with FFI function declarations, enum constants matching the Idris2 ABI,
# and idiomatic Ruby wrapper classes with block-based lifecycle management.
module ProvenServers
  # Gem version, tracking the proven-servers ABI version.
  VERSION = "0.1.0"
end
