# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Shared FFI loading utilities for the proven-servers Ruby bindings.
#
# Uses the ffi gem to load Zig-compiled shared libraries (.so/.dylib/.dll).
# Each protocol module extends ProvenServers::FFILoader to gain access to
# the library search and loading logic.

# frozen_string_literal: true

require "ffi"

module ProvenServers
  # Shared FFI library loading utilities.
  #
  # Each protocol module extends this to load its corresponding Zig shared
  # library. The search order is:
  #   1. +PROVEN_LIB_DIR+ environment variable
  #   2. Relative to the gem (in-tree builds)
  #   3. System library paths (ld.so default)
  module FFILoader
    # Build the platform-specific shared library filename.
    #
    # @param protocol [String] protocol name without the "proven-" prefix
    # @return [String] the library filename, e.g. "libproven_httpd.so"
    def self.library_filename(protocol)
      base = "proven_#{protocol.tr('-', '_')}"
      case RbConfig::CONFIG["host_os"]
      when /darwin/i
        "lib#{base}.dylib"
      when /mswin|mingw|cygwin/i
        "#{base}.dll"
      else
        "lib#{base}.so"
      end
    end

    # Search directories for the library file, in priority order.
    #
    # @param protocol [String] protocol name
    # @return [String, nil] absolute path to the library, or nil if not found
    def self.find_library(protocol)
      filename = library_filename(protocol)

      # Priority 1: PROVEN_LIB_DIR environment variable
      if (env_dir = ENV["PROVEN_LIB_DIR"])
        candidate = File.join(env_dir, filename)
        return candidate if File.exist?(candidate)
      end

      # Priority 2: relative to gem root (in-tree builds)
      gem_root = File.expand_path("../../..", __dir__)
      pkg_root = File.expand_path("../..", gem_root)
      relative_paths = [
        "ffi/zig/zig-out/lib/#{filename}",
        "protocols/proven-#{protocol}/ffi/zig/zig-out/lib/#{filename}",
        "target/release/#{filename}",
        "build/#{filename}",
      ]
      relative_paths.each do |rel|
        candidate = File.join(pkg_root, rel)
        return candidate if File.exist?(candidate)
      end

      # Priority 3: rely on system library path (let FFI/dlopen find it)
      nil
    end

    # Load a Zig shared library for the given protocol into an FFI module.
    #
    # @param mod [Module] the FFI module to load the library into
    # @param protocol [String] protocol name without "proven-" prefix
    # @raise [LoadError] if the library cannot be found or loaded
    def self.load_protocol_library(mod, protocol)
      path = find_library(protocol)
      lib_name = path || "proven_#{protocol.tr('-', '_')}"
      mod.ffi_lib lib_name
    rescue LoadError => e
      raise LoadError,
        "Cannot load proven-#{protocol} shared library. " \
        "Set PROVEN_LIB_DIR or ensure #{library_filename(protocol)} " \
        "is on the library search path. Original error: #{e.message}"
    end
  end
end
