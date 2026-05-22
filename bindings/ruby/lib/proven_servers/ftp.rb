# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Ruby bindings for the proven-ftp Zig FFI.
#
# Wraps the C-ABI functions for FTP session lifecycle, authentication,
# directory navigation, and file transfer management.

# frozen_string_literal: true

require "ffi"

module ProvenServers
  # FTP server protocol bindings matching the Idris2 ABI.
  #
  # @example
  #   ProvenServers::Ftp.with_context do |ctx|
  #     ctx.user("anonymous")
  #     ctx.pass("guest@")
  #     ctx.set_passive
  #     ctx.begin_transfer
  #     ctx.add_bytes(4096)
  #     ctx.complete_transfer
  #     ctx.quit_session
  #   end
  module Ftp
    extend FFI::Library

    FFILoader.load_protocol_library(self, "ftp")

    # FTP session states matching Idris2 ABI tags.
    module SessionState
      CONNECTED     = 0
      USER_OK       = 1
      AUTHENTICATED = 2
      RENAMING      = 3
      QUIT          = 4
    end

    # FTP transfer states matching Idris2 ABI tags.
    module TransferState
      IDLE        = 0
      IN_PROGRESS = 1
      COMPLETED   = 2
      ABORTED     = 3
    end

    # FFI function declarations.
    attach_function :ftp_create,            [], :int
    attach_function :ftp_destroy,           [:int], :void
    attach_function :ftp_state,             [:int], :uint8
    attach_function :ftp_transfer_type,     [:int], :uint8
    attach_function :ftp_data_mode,         [:int], :uint8
    attach_function :ftp_transfer_state,    [:int], :uint8
    attach_function :ftp_bytes_transferred, [:int], :uint64
    attach_function :ftp_file_count,        [:int], :uint32
    attach_function :ftp_last_reply_code,   [:int], :uint16
    attach_function :ftp_cwd,               [:int, :pointer, :uint32], :uint32
    attach_function :ftp_user,              [:int, :pointer, :uint32], :uint8
    attach_function :ftp_pass,              [:int, :pointer, :uint32], :uint8
    attach_function :ftp_quit,              [:int], :uint8
    attach_function :ftp_cwd_cmd,           [:int, :pointer, :uint32], :uint8
    attach_function :ftp_cdup,              [:int], :uint8
    attach_function :ftp_set_type,          [:int, :uint8], :uint8
    attach_function :ftp_set_passive,       [:int], :uint8
    attach_function :ftp_set_active,        [:int, :uint16], :uint8
    attach_function :ftp_begin_transfer,    [:int], :uint8
    attach_function :ftp_add_bytes,         [:int, :uint64], :uint8
    attach_function :ftp_complete_transfer, [:int], :uint8
    attach_function :ftp_abort_transfer,    [:int], :uint8
    attach_function :ftp_begin_rename,      [:int], :uint8
    attach_function :ftp_complete_rename,   [:int], :uint8
    attach_function :ftp_abi_version,       [], :uint32
    attach_function :ftp_can_transfer,      [:uint8], :uint8
    attach_function :ftp_can_transition,    [:uint8, :uint8], :uint8

    # FTP session context wrapping a Zig FFI slot.
    class Context
      attr_reader :slot

      def initialize(slot)
        @slot = slot
        @destroyed = false
      end

      # @return [Context]
      def self.create
        slot = ProvenServers.check_slot(Ftp.ftp_create)
        new(slot)
      end

      # @return [void]
      def destroy
        return if @destroyed

        Ftp.ftp_destroy(@slot)
        @destroyed = true
      end

      # @return [Integer, nil] SessionState tag
      def state
        tag = Ftp.ftp_state(@slot)
        tag <= 4 ? tag : nil
      end

      # @return [Integer]
      def transfer_type     = Ftp.ftp_transfer_type(@slot)
      # @return [Integer]
      def data_mode         = Ftp.ftp_data_mode(@slot)
      # @return [Integer]
      def bytes_transferred = Ftp.ftp_bytes_transferred(@slot)
      # @return [Integer]
      def file_count        = Ftp.ftp_file_count(@slot)
      # @return [Integer]
      def last_reply_code   = Ftp.ftp_last_reply_code(@slot)

      # @return [Integer, nil] TransferState tag
      def transfer_state
        tag = Ftp.ftp_transfer_state(@slot)
        tag <= 3 ? tag : nil
      end

      # Get the current working directory.
      #
      # @param max_len [Integer]
      # @return [String]
      def cwd(max_len: 4096)
        buf = FFI::MemoryPointer.new(:uint8, max_len)
        written = Ftp.ftp_cwd(@slot, buf, max_len)
        buf.read_string(written)
      end

      # Send USER command.
      #
      # @param name [String] username
      # @return [void]
      def user(name)
        data = FFI::MemoryPointer.from_string(name)
        ProvenServers.check_status(Ftp.ftp_user(@slot, data, name.bytesize))
      end

      # Send PASS command.
      #
      # @param password [String]
      # @return [void]
      def pass(password)
        data = FFI::MemoryPointer.from_string(password)
        ProvenServers.check_status(Ftp.ftp_pass(@slot, data, password.bytesize))
      end

      # @return [void]
      def quit_session     = ProvenServers.check_status(Ftp.ftp_quit(@slot))

      # Change directory.
      #
      # @param path [String]
      # @return [void]
      def change_dir(path)
        data = FFI::MemoryPointer.from_string(path)
        ProvenServers.check_status(Ftp.ftp_cwd_cmd(@slot, data, path.bytesize))
      end

      # @return [void]
      def change_dir_up     = ProvenServers.check_status(Ftp.ftp_cdup(@slot))

      # Set transfer type.
      #
      # @param type_tag [Integer] 0=ASCII, 1=binary
      # @return [void]
      def set_type(type_tag)
        ProvenServers.check_status(Ftp.ftp_set_type(@slot, type_tag))
      end

      # @return [void]
      def set_passive       = ProvenServers.check_status(Ftp.ftp_set_passive(@slot))

      # Set active mode with port.
      #
      # @param port [Integer]
      # @return [void]
      def set_active(port)
        ProvenServers.check_status(Ftp.ftp_set_active(@slot, port))
      end

      # @return [void]
      def begin_transfer    = ProvenServers.check_status(Ftp.ftp_begin_transfer(@slot))

      # Record transferred bytes.
      #
      # @param count [Integer]
      # @return [void]
      def add_bytes(count)
        ProvenServers.check_status(Ftp.ftp_add_bytes(@slot, count))
      end

      # @return [void]
      def complete_transfer = ProvenServers.check_status(Ftp.ftp_complete_transfer(@slot))
      # @return [void]
      def abort_transfer    = ProvenServers.check_status(Ftp.ftp_abort_transfer(@slot))
      # @return [void]
      def begin_rename      = ProvenServers.check_status(Ftp.ftp_begin_rename(@slot))
      # @return [void]
      def complete_rename   = ProvenServers.check_status(Ftp.ftp_complete_rename(@slot))
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
    def self.abi_version = ftp_abi_version
    # @param state_tag [Integer] @return [Boolean]
    def self.can_transfer?(state_tag) = ftp_can_transfer(state_tag) == 1
    # @param from [Integer] @param to [Integer] @return [Boolean]
    def self.can_transition?(from, to) = ftp_can_transition(from, to) == 1
  end
end
