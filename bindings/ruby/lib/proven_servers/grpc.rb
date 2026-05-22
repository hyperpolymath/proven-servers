# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Ruby bindings for the proven-grpc Zig FFI.
#
# Wraps the C-ABI functions for gRPC/HTTP2 stream lifecycle,
# compression, status codes, and flow control.

# frozen_string_literal: true

require "ffi"

module ProvenServers
  # gRPC protocol bindings matching the Idris2 ABI.
  #
  # @example
  #   ProvenServers::Grpc.with_context do |ctx|
  #     ctx.send_headers
  #     ctx.set_status(ProvenServers::Grpc::StatusCode::OK)
  #     ctx.local_end_stream
  #   end
  module Grpc
    extend FFI::Library

    FFILoader.load_protocol_library(self, "grpc")

    # HTTP/2 stream states matching Idris2 ABI tags.
    module StreamState
      IDLE               = 0
      RESERVED           = 1
      OPEN               = 2
      HALF_CLOSED_LOCAL  = 3
      HALF_CLOSED_REMOTE = 4
      CLOSED             = 5
    end

    # gRPC compression algorithms matching Idris2 ABI tags.
    module Compression
      NONE    = 0
      GZIP    = 1
      DEFLATE = 2
      SNAPPY  = 3
      ZSTD    = 4
    end

    # gRPC status codes matching Idris2 ABI tags.
    module StatusCode
      OK                  = 0
      CANCELLED           = 1
      UNKNOWN             = 2
      INVALID_ARGUMENT    = 3
      DEADLINE_EXCEEDED   = 4
      NOT_FOUND           = 5
      ALREADY_EXISTS      = 6
      PERMISSION_DENIED   = 7
      RESOURCE_EXHAUSTED  = 8
      FAILED_PRECONDITION = 9
      ABORTED             = 10
      OUT_OF_RANGE        = 11
      UNIMPLEMENTED       = 12
      INTERNAL            = 13
      UNAVAILABLE         = 14
      DATA_LOSS           = 15
      UNAUTHENTICATED     = 16
    end

    # FFI function declarations.
    attach_function :grpc_create,            [:uint8], :int
    attach_function :grpc_destroy,           [:int], :void
    attach_function :grpc_stream_state,      [:int], :uint8
    attach_function :grpc_compression,       [:int], :uint8
    attach_function :grpc_status_code,       [:int], :uint8
    attach_function :grpc_stream_id,         [:int], :uint32
    attach_function :grpc_can_send,          [:int], :uint8
    attach_function :grpc_can_receive,       [:int], :uint8
    attach_function :grpc_send_window,       [:int], :uint32
    attach_function :grpc_recv_window,       [:int], :uint32
    attach_function :grpc_set_status,        [:int, :uint8], :uint8
    attach_function :grpc_send_headers,      [:int], :uint8
    attach_function :grpc_local_end_stream,  [:int], :uint8
    attach_function :grpc_remote_end_stream, [:int], :uint8
    attach_function :grpc_reset_stream,      [:int, :uint8], :uint8
    attach_function :grpc_close_half_local,  [:int], :uint8
    attach_function :grpc_close_half_remote, [:int], :uint8
    attach_function :grpc_push_promise,      [:int], :uint8
    attach_function :grpc_reserved_to_half,  [:int], :uint8
    attach_function :grpc_update_send_window, [:int, :int32], :uint8
    attach_function :grpc_update_recv_window, [:int, :int32], :uint8
    attach_function :grpc_abi_version,       [], :uint32
    attach_function :grpc_can_transition,    [:uint8, :uint8], :uint8

    # gRPC stream context wrapping a Zig FFI slot.
    class Context
      attr_reader :slot

      def initialize(slot)
        @slot = slot
        @destroyed = false
      end

      # @param compression [Integer] Compression tag (default: NONE)
      # @return [Context]
      def self.create(compression: Compression::NONE)
        slot = ProvenServers.check_slot(Grpc.grpc_create(compression))
        new(slot)
      end

      # @return [void]
      def destroy
        return if @destroyed

        Grpc.grpc_destroy(@slot)
        @destroyed = true
      end

      # @return [Integer, nil] StreamState tag
      def stream_state
        tag = Grpc.grpc_stream_state(@slot)
        tag <= 5 ? tag : nil
      end

      # @return [Integer] Compression tag
      def compression   = Grpc.grpc_compression(@slot)
      # @return [Integer, nil] StatusCode tag
      def status_code
        tag = Grpc.grpc_status_code(@slot)
        tag <= 16 ? tag : nil
      end

      # @return [Integer]
      def stream_id     = Grpc.grpc_stream_id(@slot)
      # @return [Boolean]
      def can_send?     = Grpc.grpc_can_send(@slot) == 1
      # @return [Boolean]
      def can_receive?  = Grpc.grpc_can_receive(@slot) == 1
      # @return [Integer]
      def send_window   = Grpc.grpc_send_window(@slot)
      # @return [Integer]
      def recv_window   = Grpc.grpc_recv_window(@slot)

      # @param status [Integer] StatusCode tag
      # @return [void]
      def set_status(status)
        ProvenServers.check_status(Grpc.grpc_set_status(@slot, status))
      end

      # @return [void]
      def send_headers       = ProvenServers.check_status(Grpc.grpc_send_headers(@slot))
      # @return [void]
      def local_end_stream   = ProvenServers.check_status(Grpc.grpc_local_end_stream(@slot))
      # @return [void]
      def remote_end_stream  = ProvenServers.check_status(Grpc.grpc_remote_end_stream(@slot))

      # @param status [Integer] StatusCode tag
      # @return [void]
      def reset_stream(status)
        ProvenServers.check_status(Grpc.grpc_reset_stream(@slot, status))
      end

      # @return [void]
      def close_half_local   = ProvenServers.check_status(Grpc.grpc_close_half_local(@slot))
      # @return [void]
      def close_half_remote  = ProvenServers.check_status(Grpc.grpc_close_half_remote(@slot))
      # @return [void]
      def push_promise       = ProvenServers.check_status(Grpc.grpc_push_promise(@slot))
      # @return [void]
      def reserved_to_half   = ProvenServers.check_status(Grpc.grpc_reserved_to_half(@slot))

      # @param delta [Integer]
      # @return [void]
      def update_send_window(delta)
        ProvenServers.check_status(Grpc.grpc_update_send_window(@slot, delta))
      end

      # @param delta [Integer]
      # @return [void]
      def update_recv_window(delta)
        ProvenServers.check_status(Grpc.grpc_update_recv_window(@slot, delta))
      end
    end

    # @yield [Context]
    # @return [Object]
    def self.with_context(compression: Compression::NONE)
      ctx = Context.create(compression: compression)
      begin
        yield ctx
      ensure
        ctx.destroy
      end
    end

    # @return [Integer]
    def self.abi_version = grpc_abi_version
    # @param from [Integer] @param to [Integer] @return [Boolean]
    def self.can_transition?(from, to) = grpc_can_transition(from, to) == 1
  end
end
