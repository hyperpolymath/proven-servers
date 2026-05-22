# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Ruby bindings for the proven-tls Zig FFI.
#
# Wraps the C-ABI functions for TLS handshake lifecycle,
# cipher negotiation, certificate validation, and data transfer.

# frozen_string_literal: true

require "ffi"

module ProvenServers
  # TLS protocol bindings matching the Idris2 ABI.
  #
  # @example
  #   ProvenServers::Tls.with_context do |ctx|
  #     ctx.client_hello
  #     ctx.server_hello
  #     ctx.negotiate(ProvenServers::Tls::CipherSuite::AES_256_GCM_SHA384)
  #     ctx.validate_cert(ProvenServers::Tls::CertStatus::VALID)
  #     ctx.complete_handshake
  #     ctx.send_data(1024)
  #     ctx.shutdown
  #   end
  module Tls
    extend FFI::Library

    FFILoader.load_protocol_library(self, "tls")

    # TLS handshake lifecycle states matching Idris2 ABI tags.
    module TlsState
      IDLE               = 0
      CLIENT_HELLO       = 1
      SERVER_HELLO       = 2
      NEGOTIATED         = 3
      HANDSHAKE_COMPLETE = 4
      APPLICATION_DATA   = 5
      SHUTDOWN           = 6
      CLOSED             = 7
    end

    # TLS protocol versions matching Idris2 ABI tags.
    module TlsVersion
      TLS_1_2 = 0
      TLS_1_3 = 1
    end

    # TLS cipher suites matching Idris2 ABI tags.
    module CipherSuite
      AES_128_GCM_SHA256       = 0
      AES_256_GCM_SHA384       = 1
      CHACHA20_POLY1305_SHA256 = 2
      AES_128_CCM_SHA256       = 3
    end

    # Certificate validation status matching Idris2 ABI tags.
    module CertStatus
      UNCHECKED         = 0
      VALID             = 1
      EXPIRED           = 2
      REVOKED           = 3
      SELF_SIGNED       = 4
      UNKNOWN_CA        = 5
      HOSTNAME_MISMATCH = 6
    end

    # TLS alert levels matching Idris2 ABI tags.
    module AlertLevel
      WARNING = 0
      FATAL   = 1
    end

    # FFI function declarations.
    attach_function :tls_create,             [:uint8, :uint8], :int
    attach_function :tls_destroy,            [:int], :void
    attach_function :tls_state,              [:int], :uint8
    attach_function :tls_version,            [:int], :uint8
    attach_function :tls_cipher_suite,       [:int], :uint8
    attach_function :tls_cert_status,        [:int], :uint8
    attach_function :tls_is_resumed,         [:int], :uint8
    attach_function :tls_bytes_sent,         [:int], :uint64
    attach_function :tls_bytes_received,     [:int], :uint64
    attach_function :tls_client_hello,       [:int], :uint8
    attach_function :tls_server_hello,       [:int], :uint8
    attach_function :tls_negotiate,          [:int, :uint8], :uint8
    attach_function :tls_validate_cert,      [:int, :uint8], :uint8
    attach_function :tls_complete_handshake, [:int], :uint8
    attach_function :tls_send_data,          [:int, :uint64], :uint8
    attach_function :tls_receive_data,       [:int, :uint64], :uint8
    attach_function :tls_rekey,              [:int], :uint8
    attach_function :tls_shutdown,           [:int], :uint8
    attach_function :tls_send_alert,         [:int, :uint8], :uint8
    attach_function :tls_abi_version,        [], :uint32
    attach_function :tls_can_transition,     [:uint8, :uint8], :uint8

    # TLS session context wrapping a Zig FFI slot.
    class Context
      attr_reader :slot

      def initialize(slot)
        @slot = slot
        @destroyed = false
      end

      # @param version [Integer] TlsVersion tag (default: TLS_1_3)
      # @param cipher_suite [Integer] CipherSuite tag (default: AES_256_GCM_SHA384)
      # @return [Context]
      def self.create(version: TlsVersion::TLS_1_3, cipher_suite: CipherSuite::AES_256_GCM_SHA384)
        slot = ProvenServers.check_slot(Tls.tls_create(version, cipher_suite))
        new(slot)
      end

      # @return [void]
      def destroy
        return if @destroyed

        Tls.tls_destroy(@slot)
        @destroyed = true
      end

      # @return [Integer, nil] TlsState tag
      def state
        tag = Tls.tls_state(@slot)
        tag <= 7 ? tag : nil
      end

      # @return [Integer, nil] TlsVersion tag
      def version
        tag = Tls.tls_version(@slot)
        tag <= 1 ? tag : nil
      end

      # @return [Integer, nil] CipherSuite tag
      def cipher_suite
        tag = Tls.tls_cipher_suite(@slot)
        tag <= 3 ? tag : nil
      end

      # @return [Integer, nil] CertStatus tag
      def cert_status
        tag = Tls.tls_cert_status(@slot)
        tag <= 6 ? tag : nil
      end

      # @return [Boolean]
      def resumed?        = Tls.tls_is_resumed(@slot) == 1
      # @return [Integer]
      def bytes_sent      = Tls.tls_bytes_sent(@slot)
      # @return [Integer]
      def bytes_received  = Tls.tls_bytes_received(@slot)

      # @return [void]
      def client_hello      = ProvenServers.check_status(Tls.tls_client_hello(@slot))
      # @return [void]
      def server_hello      = ProvenServers.check_status(Tls.tls_server_hello(@slot))

      # Negotiate a cipher suite.
      #
      # @param cipher_suite [Integer] CipherSuite tag
      # @return [void]
      def negotiate(cipher_suite)
        ProvenServers.check_status(Tls.tls_negotiate(@slot, cipher_suite))
      end

      # Validate the peer certificate.
      #
      # @param status [Integer] CertStatus tag
      # @return [void]
      def validate_cert(status)
        ProvenServers.check_status(Tls.tls_validate_cert(@slot, status))
      end

      # @return [void]
      def complete_handshake = ProvenServers.check_status(Tls.tls_complete_handshake(@slot))

      # Record data sent.
      #
      # @param length [Integer]
      # @return [void]
      def send_data(length)
        ProvenServers.check_status(Tls.tls_send_data(@slot, length))
      end

      # Record data received.
      #
      # @param length [Integer]
      # @return [void]
      def receive_data(length)
        ProvenServers.check_status(Tls.tls_receive_data(@slot, length))
      end

      # @return [void]
      def rekey     = ProvenServers.check_status(Tls.tls_rekey(@slot))
      # @return [void]
      def shutdown  = ProvenServers.check_status(Tls.tls_shutdown(@slot))

      # Send a TLS alert.
      #
      # @param level [Integer] AlertLevel tag
      # @return [void]
      def send_alert(level)
        ProvenServers.check_status(Tls.tls_send_alert(@slot, level))
      end
    end

    # @yield [Context]
    # @return [Object]
    def self.with_context(version: TlsVersion::TLS_1_3, cipher_suite: CipherSuite::AES_256_GCM_SHA384)
      ctx = Context.create(version: version, cipher_suite: cipher_suite)
      begin
        yield ctx
      ensure
        ctx.destroy
      end
    end

    # @return [Integer]
    def self.abi_version = tls_abi_version
    # @param from [Integer] @param to [Integer] @return [Boolean]
    def self.can_transition?(from, to) = tls_can_transition(from, to) == 1
  end
end
