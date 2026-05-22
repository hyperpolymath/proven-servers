# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Gemspec for the proven-servers Ruby bindings.
#
# These bindings load the Zig-compiled shared library (libproven_*.so)
# via the ffi gem and expose idiomatic Ruby wrappers for all 10 core
# protocols: httpd, dns, smtp, ftp, ssh_bastion, mqtt, grpc, graphql,
# tls, and firewall.

Gem::Specification.new do |s|
  s.name        = "proven_servers"
  s.version     = "0.1.0"
  s.summary     = "Ruby bindings for proven-servers formally verified protocol libraries"
  s.description = <<~DESC
    Type-safe Ruby bindings for the proven-servers project. Each protocol
    module wraps the Zig FFI shared library, matching the Idris2 ABI
    definitions with dependent-type-proven correctness.

    Supported protocols: httpd, dns, smtp, ftp, ssh_bastion, mqtt, grpc,
    graphql, tls, firewall.
  DESC
  s.authors     = ["Jonathan D.A. Jewell"]
  s.email       = ["j.d.a.jewell@open.ac.uk"]
  s.homepage    = "https://github.com/hyperpolymath/proven-servers"
  s.license     = "MPL-2.0"
  s.files       = Dir["lib/**/*.rb"]
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 3.1.0"

  s.add_dependency "ffi", "~> 1.15"

  s.metadata = {
    "homepage_uri"    => s.homepage,
    "source_code_uri" => "https://github.com/hyperpolymath/proven-servers",
    "bug_tracker_uri" => "https://github.com/hyperpolymath/proven-servers/issues",
  }
end
