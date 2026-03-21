# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Ruby bindings for the proven-dns Zig FFI.
#
# Wraps the C-ABI functions for DNS query/response lifecycle,
# DNSSEC signing and validation, and record management.

# frozen_string_literal: true

require "ffi"

module ProvenServers
  # DNS server protocol bindings matching the Idris2 ABI.
  #
  # @example
  #   ProvenServers::Dns.with_context do |ctx|
  #     ctx.parse_query(raw_data)
  #     ctx.begin_lookup
  #     ctx.begin_response
  #     ctx.add_answer(1, 1, 300, rdata)
  #     wire = ctx.build_response
  #   end
  module Dns
    extend FFI::Library

    FFILoader.load_protocol_library(self, "dns")

    # DNS query lifecycle states matching Idris2 ABI tags.
    module DnsState
      IDLE              = 0
      QUERY_RECEIVED    = 1
      LOOKUP            = 2
      RESPONSE_BUILDING = 3
      SENT              = 4
    end

    # DNSSEC states matching Idris2 ABI tags.
    module DnssecState
      DISABLED  = 0
      ENABLED   = 1
      KEY_LOADED = 2
      VALIDATED = 3
    end

    # DNSSEC signing algorithms matching Idris2 ABI tags.
    module DnssecAlgorithm
      RSA_SHA256         = 0
      RSA_SHA512         = 1
      ECDSA_P256_SHA256  = 2
      ECDSA_P384_SHA384  = 3
      ED25519            = 4
    end

    # FFI function declarations for the proven-dns Zig shared library.
    attach_function :dns_create_context,  [], :int
    attach_function :dns_destroy_context, [:int], :void
    attach_function :dns_state,           [:int], :uint8
    attach_function :dns_dnssec_state,    [:int], :uint8
    attach_function :dns_rcode,           [:int], :uint8
    attach_function :dns_answer_count,    [:int], :uint32
    attach_function :dns_authority_count, [:int], :uint32
    attach_function :dns_additional_count, [:int], :uint32
    attach_function :dns_query_rtype,     [:int], :uint16
    attach_function :dns_query_class,     [:int], :uint16
    attach_function :dns_parse_query,     [:int, :pointer, :uint32], :uint8
    attach_function :dns_begin_lookup,    [:int], :uint8
    attach_function :dns_begin_response,  [:int], :uint8
    attach_function :dns_add_answer,      [:int, :uint16, :uint16, :uint32, :pointer, :uint32], :uint8
    attach_function :dns_add_authority,   [:int, :uint16, :uint16, :uint32, :pointer, :uint32], :uint8
    attach_function :dns_add_additional,  [:int, :uint16, :uint16, :uint32, :pointer, :uint32], :uint8
    attach_function :dns_set_rcode,       [:int, :uint8], :uint8
    attach_function :dns_build_response,  [:int, :pointer, :pointer], :uint8
    attach_function :dns_enable_dnssec,   [:int], :uint8
    attach_function :dns_load_dnssec_key, [:int, :uint8], :uint8
    attach_function :dns_sign_response,   [:int], :uint8
    attach_function :dns_validate_dnssec, [:int], :uint8
    attach_function :dns_abi_version,     [], :uint32
    attach_function :dns_can_transition,  [:uint8, :uint8], :uint8
    attach_function :dns_can_dnssec_transition, [:uint8, :uint8], :uint8

    # DNS query/response context wrapping a Zig FFI slot.
    class Context
      # @return [Integer] the FFI slot index
      attr_reader :slot

      def initialize(slot)
        @slot = slot
        @destroyed = false
      end

      # @return [Context]
      # @raise [ProvenError] if the context pool is exhausted
      def self.create
        slot = ProvenServers.check_slot(Dns.dns_create_context)
        new(slot)
      end

      # @return [void]
      def destroy
        return if @destroyed

        Dns.dns_destroy_context(@slot)
        @destroyed = true
      end

      # @return [Integer, nil] DnsState tag
      def state
        tag = Dns.dns_state(@slot)
        tag <= 4 ? tag : nil
      end

      # @return [Integer, nil] DnssecState tag
      def dnssec_state
        tag = Dns.dns_dnssec_state(@slot)
        tag <= 3 ? tag : nil
      end

      # @return [Integer] response code tag
      def rcode
        Dns.dns_rcode(@slot)
      end

      # @return [Integer]
      def answer_count    = Dns.dns_answer_count(@slot)
      # @return [Integer]
      def authority_count = Dns.dns_authority_count(@slot)
      # @return [Integer]
      def additional_count = Dns.dns_additional_count(@slot)
      # @return [Integer]
      def query_rtype     = Dns.dns_query_rtype(@slot)
      # @return [Integer]
      def query_class     = Dns.dns_query_class(@slot)

      # Parse a raw DNS query.
      #
      # @param data [String] raw DNS query bytes
      # @return [void]
      # @raise [ProvenError] on failure
      def parse_query(data)
        buf = FFI::MemoryPointer.from_string(data)
        ProvenServers.check_status(Dns.dns_parse_query(@slot, buf, data.bytesize))
      end

      # @return [void]
      # @raise [ProvenError] on invalid state transition
      def begin_lookup  = ProvenServers.check_status(Dns.dns_begin_lookup(@slot))
      # @return [void]
      # @raise [ProvenError] on invalid state transition
      def begin_response = ProvenServers.check_status(Dns.dns_begin_response(@slot))

      # Add an answer record to the response.
      #
      # @param rtype [Integer] record type
      # @param rclass [Integer] record class
      # @param ttl [Integer] time to live
      # @param rdata [String] record data bytes
      # @return [void]
      # @raise [ProvenError] on failure
      def add_answer(rtype, rclass, ttl, rdata)
        buf = FFI::MemoryPointer.from_string(rdata)
        ProvenServers.check_status(
          Dns.dns_add_answer(@slot, rtype, rclass, ttl, buf, rdata.bytesize)
        )
      end

      # Add an authority record to the response.
      #
      # @param rtype [Integer] record type
      # @param rclass [Integer] record class
      # @param ttl [Integer] time to live
      # @param rdata [String] record data bytes
      # @return [void]
      def add_authority(rtype, rclass, ttl, rdata)
        buf = FFI::MemoryPointer.from_string(rdata)
        ProvenServers.check_status(
          Dns.dns_add_authority(@slot, rtype, rclass, ttl, buf, rdata.bytesize)
        )
      end

      # Add an additional record to the response.
      #
      # @param rtype [Integer] record type
      # @param rclass [Integer] record class
      # @param ttl [Integer] time to live
      # @param rdata [String] record data bytes
      # @return [void]
      def add_additional(rtype, rclass, ttl, rdata)
        buf = FFI::MemoryPointer.from_string(rdata)
        ProvenServers.check_status(
          Dns.dns_add_additional(@slot, rtype, rclass, ttl, buf, rdata.bytesize)
        )
      end

      # Set the DNS response code.
      #
      # @param rcode_tag [Integer] response code tag
      # @return [void]
      def set_rcode(rcode_tag)
        ProvenServers.check_status(Dns.dns_set_rcode(@slot, rcode_tag))
      end

      # Build the DNS response wire format.
      #
      # @param max_len [Integer] maximum response length
      # @return [String] serialized DNS response bytes
      def build_response(max_len: 512)
        buf = FFI::MemoryPointer.new(:uint8, max_len)
        out_len = FFI::MemoryPointer.new(:uint16)
        ProvenServers.check_status(Dns.dns_build_response(@slot, buf, out_len))
        buf.read_string(out_len.read_uint16)
      end

      # @return [void]
      def enable_dnssec = ProvenServers.check_status(Dns.dns_enable_dnssec(@slot))

      # Load a DNSSEC signing key.
      #
      # @param algo [Integer] DnssecAlgorithm tag
      # @return [void]
      def load_dnssec_key(algo)
        ProvenServers.check_status(Dns.dns_load_dnssec_key(@slot, algo))
      end

      # @return [void]
      def sign_response = ProvenServers.check_status(Dns.dns_sign_response(@slot))

      # @return [Boolean]
      def validate_dnssec? = Dns.dns_validate_dnssec(@slot) == 0
    end

    # Create a context, yield it, and ensure cleanup.
    #
    # @yield [Context] the DNS context
    # @return [Object] the block's return value
    def self.with_context
      ctx = Context.create
      begin
        yield ctx
      ensure
        ctx.destroy
      end
    end

    # @return [Integer]
    def self.abi_version = dns_abi_version

    # @param from [Integer] @param to [Integer] @return [Boolean]
    def self.can_transition?(from, to) = dns_can_transition(from, to) == 1

    # @param from [Integer] @param to [Integer] @return [Boolean]
    def self.can_dnssec_transition?(from, to) = dns_can_dnssec_transition(from, to) == 1
  end
end
