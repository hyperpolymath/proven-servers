# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Ruby bindings for the proven-ssh-bastion Zig FFI.
#
# Wraps the C-ABI functions for SSH bastion session lifecycle,
# key exchange, authentication, channel management, and audit logging.

# frozen_string_literal: true

require "ffi"

module ProvenServers
  # SSH bastion protocol bindings matching the Idris2 ABI.
  #
  # @example
  #   ProvenServers::SshBastion.with_context do |ctx|
  #     ctx.complete_kex
  #     ctx.authenticate
  #     ch_id = ctx.open_channel(ProvenServers::SshBastion::ChannelType::SESSION)
  #     ctx.confirm_channel(ch_id)
  #     ctx.close_channel(ch_id)
  #     ctx.disconnect(ProvenServers::SshBastion::DisconnectReason::BY_APPLICATION)
  #   end
  module SshBastion
    extend FFI::Library

    FFILoader.load_protocol_library(self, "ssh_bastion")

    # SSH bastion session states matching Idris2 ABI tags.
    module BastionState
      CONNECTED     = 0
      KEY_EXCHANGED = 1
      AUTHENTICATED = 2
      CHANNEL_OPEN  = 3
      ACTIVE        = 4
      CLOSED        = 5
    end

    # SSH key exchange methods matching Idris2 ABI tags.
    module KexMethod
      CURVE25519_SHA256              = 0
      ECDH_SHA2_NISTP256             = 1
      ECDH_SHA2_NISTP384             = 2
      DIFFIE_HELLMAN_GROUP14_SHA256  = 3
      DIFFIE_HELLMAN_GROUP16_SHA512  = 4
    end

    # SSH authentication methods matching Idris2 ABI tags.
    module AuthMethod
      PUBLIC_KEY            = 0
      PASSWORD              = 1
      KEYBOARD_INTERACTIVE  = 2
      HOST_BASED            = 3
    end

    # SSH channel types matching Idris2 ABI tags.
    module ChannelType
      SESSION         = 0
      DIRECT_TCPIP    = 1
      FORWARDED_TCPIP = 2
      X11             = 3
    end

    # SSH channel states matching Idris2 ABI tags.
    module ChannelState
      OPENING = 0
      OPEN    = 1
      CLOSED  = 2
    end

    # SSH disconnect reasons matching Idris2 ABI tags.
    module DisconnectReason
      BY_APPLICATION         = 0
      PROTOCOL_ERROR         = 1
      KEY_EXCHANGE_FAILED    = 2
      AUTH_CANCELLED_BY_USER = 3
      TOO_MANY_CONNECTIONS   = 4
      HOST_NOT_ALLOWED       = 5
      ILLEGAL_USER_NAME      = 6
    end

    # FFI function declarations.
    attach_function :ssh_bastion_create,            [:uint8, :uint8], :int
    attach_function :ssh_bastion_destroy,           [:int], :void
    attach_function :ssh_bastion_state,             [:int], :uint8
    attach_function :ssh_bastion_kex_method,        [:int], :uint8
    attach_function :ssh_bastion_auth_method,       [:int], :uint8
    attach_function :ssh_bastion_can_transfer,      [:int], :uint8
    attach_function :ssh_bastion_disconnect_reason, [:int], :uint8
    attach_function :ssh_bastion_auth_failures,     [:int], :uint32
    attach_function :ssh_bastion_complete_kex,      [:int], :uint8
    attach_function :ssh_bastion_authenticate,      [:int, :uint8], :uint8
    attach_function :ssh_bastion_record_auth_failure, [:int], :uint8
    attach_function :ssh_bastion_open_channel,      [:int, :uint8], :int
    attach_function :ssh_bastion_confirm_channel,   [:int, :int], :uint8
    attach_function :ssh_bastion_close_channel,     [:int, :int], :uint8
    attach_function :ssh_bastion_channel_state,     [:int, :int], :uint8
    attach_function :ssh_bastion_channel_type,      [:int, :int], :uint8
    attach_function :ssh_bastion_channel_count,     [:int], :uint32
    attach_function :ssh_bastion_rekey,             [:int], :uint8
    attach_function :ssh_bastion_disconnect,        [:int, :uint8], :uint8
    attach_function :ssh_bastion_audit_count,       [:int], :uint32
    attach_function :ssh_bastion_audit_entry,       [:int, :uint32], :uint8
    attach_function :ssh_bastion_audit_entry_to,    [:int, :uint32], :uint8
    attach_function :ssh_bastion_set_recording,     [:int, :uint8], :uint8
    attach_function :ssh_bastion_is_recording,      [:int], :uint8
    attach_function :ssh_bastion_abi_version,       [], :uint32
    attach_function :ssh_bastion_can_transition,    [:uint8, :uint8], :uint8

    # SSH bastion session context wrapping a Zig FFI slot.
    class Context
      attr_reader :slot

      def initialize(slot)
        @slot = slot
        @destroyed = false
      end

      # @param kex [Integer] KexMethod tag (default: CURVE25519_SHA256)
      # @param auth [Integer] AuthMethod tag (default: PUBLIC_KEY)
      # @return [Context]
      def self.create(kex: KexMethod::CURVE25519_SHA256, auth: AuthMethod::PUBLIC_KEY)
        slot = ProvenServers.check_slot(SshBastion.ssh_bastion_create(kex, auth))
        new(slot)
      end

      # @return [void]
      def destroy
        return if @destroyed

        SshBastion.ssh_bastion_destroy(@slot)
        @destroyed = true
      end

      # @return [Integer, nil] BastionState tag
      def state
        tag = SshBastion.ssh_bastion_state(@slot)
        tag <= 5 ? tag : nil
      end

      # @return [Integer, nil] KexMethod tag
      def kex_method
        tag = SshBastion.ssh_bastion_kex_method(@slot)
        tag <= 4 ? tag : nil
      end

      # @return [Integer, nil] AuthMethod tag
      def auth_method
        tag = SshBastion.ssh_bastion_auth_method(@slot)
        tag <= 3 ? tag : nil
      end

      # @return [Boolean]
      def can_transfer_data? = SshBastion.ssh_bastion_can_transfer(@slot) == 1

      # @return [Integer, nil] DisconnectReason tag
      def disconnect_reason
        tag = SshBastion.ssh_bastion_disconnect_reason(@slot)
        tag <= 6 ? tag : nil
      end

      # @return [Integer]
      def auth_failures = SshBastion.ssh_bastion_auth_failures(@slot)

      # @return [void]
      def complete_kex = ProvenServers.check_status(SshBastion.ssh_bastion_complete_kex(@slot))

      # @return [void]
      def authenticate
        ProvenServers.check_status(SshBastion.ssh_bastion_authenticate(@slot, 0))
      end

      # Record an authentication failure.
      #
      # @return [Boolean] true if locked out
      def record_auth_failure
        SshBastion.ssh_bastion_record_auth_failure(@slot) == 1
      end

      # Open a channel.
      #
      # @param ch_type [Integer] ChannelType tag
      # @return [Integer] channel ID
      def open_channel(ch_type)
        ProvenServers.check_slot(SshBastion.ssh_bastion_open_channel(@slot, ch_type))
      end

      # @param ch_id [Integer]
      # @return [void]
      def confirm_channel(ch_id)
        ProvenServers.check_status(SshBastion.ssh_bastion_confirm_channel(@slot, ch_id))
      end

      # @param ch_id [Integer]
      # @return [void]
      def close_channel(ch_id)
        ProvenServers.check_status(SshBastion.ssh_bastion_close_channel(@slot, ch_id))
      end

      # @param ch_id [Integer]
      # @return [Integer, nil] ChannelState tag
      def channel_state(ch_id)
        tag = SshBastion.ssh_bastion_channel_state(@slot, ch_id)
        tag <= 2 ? tag : nil
      end

      # @param ch_id [Integer]
      # @return [Integer, nil] ChannelType tag
      def channel_type(ch_id)
        tag = SshBastion.ssh_bastion_channel_type(@slot, ch_id)
        tag <= 3 ? tag : nil
      end

      # @return [Integer]
      def channel_count = SshBastion.ssh_bastion_channel_count(@slot)

      # @return [void]
      def rekey = ProvenServers.check_status(SshBastion.ssh_bastion_rekey(@slot))

      # @param reason [Integer] DisconnectReason tag
      # @return [void]
      def disconnect(reason)
        ProvenServers.check_status(SshBastion.ssh_bastion_disconnect(@slot, reason))
      end

      # @return [Integer]
      def audit_count = SshBastion.ssh_bastion_audit_count(@slot)

      # @param index [Integer]
      # @return [Integer, nil] BastionState (from) tag
      def audit_entry_from(index)
        tag = SshBastion.ssh_bastion_audit_entry(@slot, index)
        tag <= 5 ? tag : nil
      end

      # @param index [Integer]
      # @return [Integer, nil] BastionState (to) tag
      def audit_entry_to(index)
        tag = SshBastion.ssh_bastion_audit_entry_to(@slot, index)
        tag <= 5 ? tag : nil
      end

      # @param enabled [Boolean]
      # @return [void]
      def set_recording(enabled)
        ProvenServers.check_status(SshBastion.ssh_bastion_set_recording(@slot, enabled ? 1 : 0))
      end

      # @return [Boolean]
      def recording? = SshBastion.ssh_bastion_is_recording(@slot) == 1
    end

    # @yield [Context]
    # @return [Object]
    def self.with_context(kex: KexMethod::CURVE25519_SHA256, auth: AuthMethod::PUBLIC_KEY)
      ctx = Context.create(kex: kex, auth: auth)
      begin
        yield ctx
      ensure
        ctx.destroy
      end
    end

    # @return [Integer]
    def self.abi_version = ssh_bastion_abi_version
    # @param from [Integer] @param to [Integer] @return [Boolean]
    def self.can_transition?(from, to) = ssh_bastion_can_transition(from, to) == 1
  end
end
