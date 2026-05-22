# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Ruby bindings for the proven-smtp Zig FFI.
#
# Wraps the C-ABI functions for SMTP session lifecycle,
# authentication, and message relay.

# frozen_string_literal: true

require "ffi"

module ProvenServers
  # SMTP server protocol bindings matching the Idris2 ABI.
  #
  # @example
  #   ProvenServers::Smtp.with_context do |ctx|
  #     ctx.greet(ehlo: true)
  #     ctx.authenticate(ProvenServers::Smtp::AuthMechanism::PLAIN)
  #     ctx.auth_complete(true)
  #     ctx.set_sender
  #     ctx.add_recipient
  #     ctx.start_data
  #     ctx.append_data(1024)
  #     ctx.finish_data
  #     ctx.quit
  #   end
  module Smtp
    extend FFI::Library

    FFILoader.load_protocol_library(self, "smtp")

    # SMTP session states matching Idris2 ABI tags.
    module SessionState
      CONNECTED       = 0
      GREETED         = 1
      AUTH_STARTED    = 2
      AUTHENTICATED   = 3
      MAIL_FROM       = 4
      RCPT_TO         = 5
      DATA            = 6
      MESSAGE_RECEIVED = 7
      QUIT            = 8
    end

    # SMTP AUTH mechanisms matching Idris2 ABI tags.
    module AuthMechanism
      PLAIN     = 0
      LOGIN     = 1
      CRAM_MD5  = 2
      XOAUTH2   = 3
    end

    # FFI function declarations.
    attach_function :smtp_create_context,      [], :int
    attach_function :smtp_destroy_context,     [:int], :void
    attach_function :smtp_get_state,           [:int], :uint8
    attach_function :smtp_get_reply_code,      [:int], :uint16
    attach_function :smtp_get_recipient_count, [:int], :uint32
    attach_function :smtp_get_data_size,       [:int], :uint32
    attach_function :smtp_get_auth_mechanism,  [:int], :uint8
    attach_function :smtp_is_authenticated,    [:int], :uint8
    attach_function :smtp_is_tls_active,       [:int], :uint8
    attach_function :smtp_greet,               [:int, :uint8], :uint8
    attach_function :smtp_authenticate,        [:int, :uint8], :uint8
    attach_function :smtp_auth_complete,       [:int, :uint8], :uint8
    attach_function :smtp_set_sender,          [:int], :uint8
    attach_function :smtp_add_recipient,       [:int], :uint8
    attach_function :smtp_start_data,          [:int], :uint8
    attach_function :smtp_append_data,         [:int, :uint32], :uint8
    attach_function :smtp_finish_data,         [:int], :uint8
    attach_function :smtp_reset,               [:int], :uint8
    attach_function :smtp_quit,                [:int], :uint8
    attach_function :smtp_enable_tls,          [:int], :uint8
    attach_function :smtp_abi_version,         [], :uint32
    attach_function :smtp_can_transition,      [:uint8, :uint8], :uint8

    # SMTP session context wrapping a Zig FFI slot.
    class Context
      attr_reader :slot

      def initialize(slot)
        @slot = slot
        @destroyed = false
      end

      # @return [Context]
      def self.create
        slot = ProvenServers.check_slot(Smtp.smtp_create_context)
        new(slot)
      end

      # @return [void]
      def destroy
        return if @destroyed

        Smtp.smtp_destroy_context(@slot)
        @destroyed = true
      end

      # @return [Integer, nil] SessionState tag
      def state
        tag = Smtp.smtp_get_state(@slot)
        tag <= 8 ? tag : nil
      end

      # @return [Integer] SMTP reply code
      def reply_code       = Smtp.smtp_get_reply_code(@slot)
      # @return [Integer]
      def recipient_count  = Smtp.smtp_get_recipient_count(@slot)
      # @return [Integer]
      def data_size        = Smtp.smtp_get_data_size(@slot)

      # @return [Integer, nil] AuthMechanism tag
      def auth_mechanism
        tag = Smtp.smtp_get_auth_mechanism(@slot)
        tag <= 3 ? tag : nil
      end

      # @return [Boolean]
      def authenticated?  = Smtp.smtp_is_authenticated(@slot) == 1
      # @return [Boolean]
      def tls_active?     = Smtp.smtp_is_tls_active(@slot) == 1

      # Send EHLO/HELO greeting.
      #
      # @param ehlo [Boolean] true for EHLO, false for HELO
      # @return [void]
      def greet(ehlo: true)
        ProvenServers.check_status(Smtp.smtp_greet(@slot, ehlo ? 1 : 0))
      end

      # Start authentication with the given mechanism.
      #
      # @param mechanism [Integer] AuthMechanism tag
      # @return [void]
      def authenticate(mechanism)
        ProvenServers.check_status(Smtp.smtp_authenticate(@slot, mechanism))
      end

      # Complete authentication.
      #
      # @param success [Boolean] whether authentication succeeded
      # @return [void]
      def auth_complete(success)
        ProvenServers.check_status(Smtp.smtp_auth_complete(@slot, success ? 1 : 0))
      end

      # @return [void]
      def set_sender     = ProvenServers.check_status(Smtp.smtp_set_sender(@slot))
      # @return [void]
      def add_recipient   = ProvenServers.check_status(Smtp.smtp_add_recipient(@slot))
      # @return [void]
      def start_data     = ProvenServers.check_status(Smtp.smtp_start_data(@slot))

      # Append data to the message body.
      #
      # @param length [Integer] number of bytes appended
      # @return [void]
      def append_data(length)
        ProvenServers.check_status(Smtp.smtp_append_data(@slot, length))
      end

      # @return [void]
      def finish_data = ProvenServers.check_status(Smtp.smtp_finish_data(@slot))
      # @return [void]
      def reset       = ProvenServers.check_status(Smtp.smtp_reset(@slot))
      # @return [void]
      def quit        = ProvenServers.check_status(Smtp.smtp_quit(@slot))
      # @return [void]
      def enable_tls  = ProvenServers.check_status(Smtp.smtp_enable_tls(@slot))
    end

    # @yield [Context]
    # @return [Object]
    def self.with_context
      ctx = Context.create
      begin
        yield ctx
      ensure
        ctx.destroy
      end
    end

    # @return [Integer]
    def self.abi_version = smtp_abi_version
    # @param from [Integer] @param to [Integer] @return [Boolean]
    def self.can_transition?(from, to) = smtp_can_transition(from, to) == 1
  end
end
