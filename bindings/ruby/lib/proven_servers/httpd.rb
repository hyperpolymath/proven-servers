# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Ruby bindings for the proven-httpd Zig FFI.
#
# Wraps the C-ABI functions from protocols/proven-httpd/ffi/zig/src/httpd.zig:
#   - Context lifecycle: http_create_context, http_destroy_context
#   - Request parsing: http_parse_request
#   - Request queries: http_get_method, http_get_path, http_get_header, http_get_body
#   - Response construction: http_set_status, http_set_header, http_set_body,
#     http_send_response
#   - Phase & transition: http_get_phase, http_get_version, http_keep_alive_check,
#     http_reset_context, http_can_transition

# frozen_string_literal: true

require "ffi"

module ProvenServers
  # HTTP server protocol bindings matching the Idris2 ABI.
  #
  # @example
  #   ProvenServers::Httpd.with_context do |ctx|
  #     result = ctx.parse_request(raw_data)
  #     if result == ProvenServers::Httpd::ParseResult::COMPLETE
  #       ctx.set_status(ProvenServers::Httpd::StatusCode::OK)
  #       ctx.set_body("Hello, world!")
  #       ctx.send_response
  #     end
  #   end
  module Httpd
    extend FFI::Library

    FFILoader.load_protocol_library(self, "httpd")

    # HTTP request methods matching Idris2 ABI tags.
    module Method
      GET     = 0
      POST    = 1
      PUT     = 2
      DELETE  = 3
      PATCH   = 4
      HEAD    = 5
      OPTIONS = 6
      TRACE   = 7
      CONNECT = 8
    end

    # HTTP request lifecycle phases matching Idris2 ABI tags.
    module RequestPhase
      IDLE            = 0
      RECEIVING       = 1
      HEADERS_PARSED  = 2
      BODY_RECEIVING  = 3
      COMPLETE        = 4
      RESPONDING      = 5
      SENT            = 6
    end

    # HTTP response status code tags matching Idris2 ABI.
    module StatusCode
      OK                     = 0
      CREATED                = 1
      NO_CONTENT             = 2
      MOVED_PERMANENTLY      = 3
      FOUND                  = 4
      NOT_MODIFIED           = 5
      BAD_REQUEST            = 6
      UNAUTHORIZED           = 7
      FORBIDDEN              = 8
      NOT_FOUND              = 9
      METHOD_NOT_ALLOWED     = 10
      CONFLICT               = 11
      GONE                   = 12
      UNPROCESSABLE_ENTITY   = 13
      TOO_MANY_REQUESTS      = 14
      INTERNAL_SERVER_ERROR  = 15
      NOT_IMPLEMENTED        = 16
      BAD_GATEWAY            = 17
      SERVICE_UNAVAILABLE    = 18
      GATEWAY_TIMEOUT        = 19
    end

    # HTTP version tags matching Idris2 ABI.
    module Version
      HTTP_1_0 = 0
      HTTP_1_1 = 1
      HTTP_2   = 2
    end

    # Parse result values matching Idris2 ABI.
    module ParseResult
      COMPLETE  = 0
      REJECTED  = 1
      NEED_MORE = 2
    end

    # FFI function declarations for the proven-httpd Zig shared library.
    attach_function :http_create_context,  [], :int
    attach_function :http_destroy_context, [:int], :void
    attach_function :http_parse_request,   [:int, :pointer, :uint32], :uint8
    attach_function :http_get_method,      [:int], :uint8
    attach_function :http_get_path,        [:int, :pointer, :uint32], :uint32
    attach_function :http_get_header,      [:int, :pointer, :uint32, :pointer, :uint32], :uint32
    attach_function :http_get_body,        [:int, :pointer, :uint32], :uint32
    attach_function :http_set_status,      [:int, :uint8], :uint8
    attach_function :http_set_header,      [:int, :pointer, :uint32, :pointer, :uint32], :uint8
    attach_function :http_set_body,        [:int, :pointer, :uint32], :uint8
    attach_function :http_send_response,   [:int], :uint8
    attach_function :http_keep_alive_check, [:int], :uint8
    attach_function :http_get_phase,       [:int], :uint8
    attach_function :http_get_version,     [:int], :uint8
    attach_function :http_reset_context,   [:int], :uint8
    attach_function :http_can_transition,  [:uint8, :uint8], :uint8
    attach_function :http_abi_version,     [], :uint32

    # HTTP request/response context wrapping a Zig FFI slot.
    #
    # Prefer using {Httpd.with_context} for automatic cleanup.
    class Context
      # @return [Integer] the FFI slot index
      attr_reader :slot

      # @param slot [Integer] the FFI slot index
      def initialize(slot)
        @slot = slot
        @destroyed = false
      end

      # Create a new HTTP context.
      #
      # @return [Context]
      # @raise [ProvenError] if the context pool is exhausted
      def self.create
        slot = ProvenServers.check_slot(Httpd.http_create_context)
        new(slot)
      end

      # Release the context slot back to the pool.
      #
      # @return [void]
      def destroy
        return if @destroyed

        Httpd.http_destroy_context(@slot)
        @destroyed = true
      end

      # Feed raw HTTP data into the context for parsing.
      #
      # @param data [String] raw HTTP request bytes
      # @return [Integer] ParseResult value
      def parse_request(data)
        buf = FFI::MemoryPointer.from_string(data)
        Httpd.http_parse_request(@slot, buf, data.bytesize)
      end

      # Get the HTTP method of the parsed request.
      #
      # @return [Integer, nil] Method tag, or nil if not yet parsed
      def method
        tag = Httpd.http_get_method(@slot)
        tag == 255 ? nil : tag
      end

      # Get the request path.
      #
      # @param max_len [Integer] maximum path length
      # @return [String] the request path
      def path(max_len: 4096)
        buf = FFI::MemoryPointer.new(:uint8, max_len)
        written = Httpd.http_get_path(@slot, buf, max_len)
        buf.read_string(written)
      end

      # Look up a request header by key (case-insensitive).
      #
      # @param key [String] header name
      # @param max_len [Integer] maximum value length
      # @return [String] header value, or empty string if not found
      def header(key, max_len: 4096)
        key_buf = FFI::MemoryPointer.from_string(key)
        val_buf = FFI::MemoryPointer.new(:uint8, max_len)
        written = Httpd.http_get_header(@slot, key_buf, key.bytesize, val_buf, max_len)
        val_buf.read_string(written)
      end

      # Get the request body.
      #
      # @param max_len [Integer] maximum body length
      # @return [String] the request body bytes
      def body(max_len: 65_536)
        buf = FFI::MemoryPointer.new(:uint8, max_len)
        written = Httpd.http_get_body(@slot, buf, max_len)
        buf.read_string(written)
      end

      # Set the response status code.
      #
      # @param status [Integer] StatusCode tag
      # @return [void]
      # @raise [ProvenError] on invalid state transition
      def set_status(status)
        ProvenServers.check_status(Httpd.http_set_status(@slot, status))
      end

      # Set a response header.
      #
      # @param key [String] header name
      # @param value [String] header value
      # @return [void]
      # @raise [ProvenError] on invalid state transition
      def set_header(key, value)
        k = FFI::MemoryPointer.from_string(key)
        v = FFI::MemoryPointer.from_string(value)
        ProvenServers.check_status(
          Httpd.http_set_header(@slot, k, key.bytesize, v, value.bytesize)
        )
      end

      # Set the response body.
      #
      # @param data [String] response body bytes
      # @return [void]
      # @raise [ProvenError] on invalid state transition
      def set_body(data)
        buf = FFI::MemoryPointer.from_string(data)
        ProvenServers.check_status(Httpd.http_set_body(@slot, buf, data.bytesize))
      end

      # Send the response. Transitions Responding -> Sent.
      #
      # @return [void]
      # @raise [ProvenError] on invalid state transition
      def send_response
        ProvenServers.check_status(Httpd.http_send_response(@slot))
      end

      # Check if the connection uses keep-alive.
      #
      # @return [Boolean]
      def keep_alive?
        Httpd.http_keep_alive_check(@slot) == 1
      end

      # Get the current request processing phase.
      #
      # @return [Integer, nil] RequestPhase tag, or nil if unknown
      def phase
        tag = Httpd.http_get_phase(@slot)
        tag <= 6 ? tag : nil
      end

      # Get the HTTP version.
      #
      # @return [Integer, nil] Version tag, or nil if unknown
      def version
        tag = Httpd.http_get_version(@slot)
        tag <= 2 ? tag : nil
      end

      # Reset context for keep-alive reuse (Sent -> Idle).
      #
      # @return [void]
      # @raise [ProvenError] on invalid state transition
      def reset
        ProvenServers.check_status(Httpd.http_reset_context(@slot))
      end
    end

    # Create a context, yield it, and ensure cleanup.
    #
    # @yield [Context] the HTTP context
    # @return [Object] the block's return value
    # @raise [ProvenError] if the context pool is exhausted
    def self.with_context
      ctx = Context.create
      begin
        yield ctx
      ensure
        ctx.destroy
      end
    end

    # Return the ABI version of the linked library.
    #
    # @return [Integer]
    def self.abi_version
      http_abi_version
    end

    # Stateless query: check whether a lifecycle transition is valid.
    #
    # @param from [Integer] source RequestPhase tag
    # @param to [Integer] target RequestPhase tag
    # @return [Boolean]
    def self.can_transition?(from, to)
      http_can_transition(from, to) == 1
    end
  end
end
