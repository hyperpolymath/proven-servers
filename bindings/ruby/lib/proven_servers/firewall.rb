# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Ruby bindings for the proven-firewall Zig FFI.
#
# Wraps the C-ABI functions for firewall packet evaluation,
# rule management, connection tracking, and NAT actions.

# frozen_string_literal: true

require "ffi"

module ProvenServers
  # Firewall protocol bindings matching the Idris2 ABI.
  #
  # @example
  #   ProvenServers::Firewall.with_context do |ctx|
  #     ctx.classify_packet(6, 0, src_ip, dst_ip, src_port, dst_port)
  #     ctx.begin_chain
  #     ctx.add_rule(0, 80, ProvenServers::Firewall::Action::ACCEPT, 100)
  #     ctx.set_default_action(ProvenServers::Firewall::Action::DROP)
  #     ctx.evaluate_rules
  #     ctx.commit
  #   end
  module Firewall
    extend FFI::Library

    FFILoader.load_protocol_library(self, "firewall")

    # Firewall rule actions matching Idris2 ABI tags.
    module Action
      ACCEPT     = 0
      DROP       = 1
      REJECT     = 2
      LOG        = 3
      REDIRECT   = 4
      DNAT       = 5
      SNAT       = 6
      MASQUERADE = 7
    end

    # Firewall packet lifecycle states matching Idris2 ABI tags.
    module PacketState
      IDLE       = 0
      CLASSIFIED = 1
      EVALUATING = 2
      DECIDED    = 3
      COMMITTED  = 4
    end

    # Connection tracking states matching Idris2 ABI tags.
    module ConntrackState
      NONE        = 0
      TRACKING    = 1
      ESTABLISHED = 2
      RELATED     = 3
      EXPIRED     = 4
    end

    # FFI function declarations.
    attach_function :fw_create_context,         [], :int
    attach_function :fw_destroy_context,        [:int], :void
    attach_function :fw_packet_state,           [:int], :uint8
    attach_function :fw_conntrack_state,        [:int], :uint8
    attach_function :fw_get_decision,           [:int], :uint8
    attach_function :fw_rule_count,             [:int], :uint32
    attach_function :fw_packet_proto,           [:int], :uint8
    attach_function :fw_packet_chain,           [:int], :uint8
    attach_function :fw_packet_src_ip,          [:int], :uint32
    attach_function :fw_packet_dst_ip,          [:int], :uint32
    attach_function :fw_packet_src_port,        [:int], :uint16
    attach_function :fw_packet_dst_port,        [:int], :uint16
    attach_function :fw_classify_packet,        [:int, :uint8, :uint8, :uint32, :uint32, :uint16, :uint16], :uint8
    attach_function :fw_begin_chain,            [:int], :uint8
    attach_function :fw_add_rule,               [:int, :uint8, :uint32, :uint8, :uint32], :uint8
    attach_function :fw_set_default_action,     [:int, :uint8], :uint8
    attach_function :fw_evaluate_rules,         [:int], :uint8
    attach_function :fw_commit,                 [:int], :uint8
    attach_function :fw_begin_tracking,         [:int], :uint8
    attach_function :fw_complete_tracking,      [:int, :uint8], :uint8
    attach_function :fw_expire_conn,            [:int], :uint8
    attach_function :fw_abi_version,            [], :uint32
    attach_function :fw_can_transition,         [:uint8, :uint8], :uint8
    attach_function :fw_can_conntrack_transition, [:uint8, :uint8], :uint8

    # Firewall packet evaluation context wrapping a Zig FFI slot.
    class Context
      attr_reader :slot

      def initialize(slot)
        @slot = slot
        @destroyed = false
      end

      # @return [Context]
      def self.create
        slot = ProvenServers.check_slot(Firewall.fw_create_context)
        new(slot)
      end

      # @return [void]
      def destroy
        return if @destroyed

        Firewall.fw_destroy_context(@slot)
        @destroyed = true
      end

      # @return [Integer, nil] PacketState tag
      def packet_state
        tag = Firewall.fw_packet_state(@slot)
        tag <= 4 ? tag : nil
      end

      # @return [Integer, nil] ConntrackState tag
      def conntrack_state
        tag = Firewall.fw_conntrack_state(@slot)
        tag <= 4 ? tag : nil
      end

      # @return [Integer, nil] Action tag
      def decision
        tag = Firewall.fw_get_decision(@slot)
        tag <= 7 ? tag : nil
      end

      # @return [Integer]
      def rule_count     = Firewall.fw_rule_count(@slot)
      # @return [Integer]
      def packet_proto   = Firewall.fw_packet_proto(@slot)
      # @return [Integer]
      def packet_chain   = Firewall.fw_packet_chain(@slot)
      # @return [Integer]
      def packet_src_ip  = Firewall.fw_packet_src_ip(@slot)
      # @return [Integer]
      def packet_dst_ip  = Firewall.fw_packet_dst_ip(@slot)
      # @return [Integer]
      def packet_src_port = Firewall.fw_packet_src_port(@slot)
      # @return [Integer]
      def packet_dst_port = Firewall.fw_packet_dst_port(@slot)

      # Classify a packet. Transitions Idle -> Classified.
      #
      # @param proto [Integer] protocol number
      # @param chain [Integer] chain identifier
      # @param src_ip [Integer] source IP (as u32)
      # @param dst_ip [Integer] destination IP (as u32)
      # @param src_port [Integer] source port
      # @param dst_port [Integer] destination port
      # @return [void]
      def classify_packet(proto, chain, src_ip, dst_ip, src_port, dst_port)
        ProvenServers.check_status(
          Firewall.fw_classify_packet(@slot, proto, chain, src_ip, dst_ip, src_port, dst_port)
        )
      end

      # @return [void]
      def begin_chain = ProvenServers.check_status(Firewall.fw_begin_chain(@slot))

      # Add a firewall rule.
      #
      # @param match_type [Integer]
      # @param match_value [Integer]
      # @param action [Integer] Action tag
      # @param priority [Integer]
      # @return [void]
      def add_rule(match_type, match_value, action, priority)
        ProvenServers.check_status(
          Firewall.fw_add_rule(@slot, match_type, match_value, action, priority)
        )
      end

      # Set the default action for unmatched packets.
      #
      # @param action [Integer] Action tag
      # @return [void]
      def set_default_action(action)
        ProvenServers.check_status(Firewall.fw_set_default_action(@slot, action))
      end

      # @return [void]
      def evaluate_rules = ProvenServers.check_status(Firewall.fw_evaluate_rules(@slot))
      # @return [void]
      def commit         = ProvenServers.check_status(Firewall.fw_commit(@slot))
      # @return [void]
      def begin_tracking = ProvenServers.check_status(Firewall.fw_begin_tracking(@slot))

      # Complete connection tracking with a state.
      #
      # @param conn_state [Integer] ConntrackState tag
      # @return [void]
      def complete_tracking(conn_state)
        ProvenServers.check_status(Firewall.fw_complete_tracking(@slot, conn_state))
      end

      # @return [void]
      def expire_conn = ProvenServers.check_status(Firewall.fw_expire_conn(@slot))
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
    def self.abi_version = fw_abi_version
    # @param from [Integer] @param to [Integer] @return [Boolean]
    def self.can_transition?(from, to) = fw_can_transition(from, to) == 1
    # @param from [Integer] @param to [Integer] @return [Boolean]
    def self.can_conntrack_transition?(from, to) = fw_can_conntrack_transition(from, to) == 1
  end
end
