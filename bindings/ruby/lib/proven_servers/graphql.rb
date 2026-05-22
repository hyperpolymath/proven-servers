# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Ruby bindings for the proven-graphql Zig FFI.
#
# Wraps the C-ABI functions for GraphQL request lifecycle, query
# depth/complexity limits, field resolution, and subscriptions.

# frozen_string_literal: true

require "ffi"

module ProvenServers
  # GraphQL server protocol bindings matching the Idris2 ABI.
  #
  # @example
  #   ProvenServers::Graphql.with_context do |ctx|
  #     ctx.set_query_depth(3)
  #     ctx.set_complexity(50)
  #     ctx.advance  # RECEIVED -> PARSED
  #     ctx.advance  # PARSED -> EXECUTING
  #     ctx.resolve_field(0, 0)
  #     ctx.advance  # EXECUTING -> COMPLETE
  #   end
  module Graphql
    extend FFI::Library

    FFILoader.load_protocol_library(self, "graphql")

    # GraphQL request lifecycle phases matching Idris2 ABI tags.
    module Phase
      RECEIVED  = 0
      PARSED    = 1
      EXECUTING = 2
      COMPLETE  = 3
      ERROR     = 4
    end

    # GraphQL operation types matching Idris2 ABI tags.
    module OperationType
      QUERY        = 0
      MUTATION     = 1
      SUBSCRIPTION = 2
    end

    # GraphQL error categories matching Idris2 ABI tags.
    module ErrorCategory
      SYNTAX        = 0
      VALIDATION    = 1
      AUTHORIZATION = 2
      EXECUTION     = 3
      RATE_LIMIT    = 4
      INTERNAL      = 5
    end

    # FFI function declarations.
    attach_function :graphql_create,             [:uint8], :int
    attach_function :graphql_destroy,            [:int], :void
    attach_function :graphql_phase,              [:int], :uint8
    attach_function :graphql_operation_type,     [:int], :uint8
    attach_function :graphql_error_category,     [:int], :uint8
    attach_function :graphql_query_depth,        [:int], :uint32
    attach_function :graphql_complexity,         [:int], :uint32
    attach_function :graphql_fields_resolved,    [:int], :uint32
    attach_function :graphql_advance,            [:int], :uint8
    attach_function :graphql_abort,              [:int, :uint8], :uint8
    attach_function :graphql_set_query_depth,    [:int, :uint32], :uint8
    attach_function :graphql_set_complexity,     [:int, :uint32], :uint8
    attach_function :graphql_resolve_field,      [:int, :uint8, :uint8], :uint8
    attach_function :graphql_introspection_query, [:int, :uint8], :uint8
    attach_function :graphql_sub_create,         [:int], :int
    attach_function :graphql_sub_phase,          [:int], :uint8
    attach_function :graphql_sub_advance,        [:int], :uint8
    attach_function :graphql_sub_emit_event,     [:int], :uint8
    attach_function :graphql_sub_abort,          [:int], :uint8
    attach_function :graphql_sub_event_count,    [:int], :uint32
    attach_function :graphql_abi_version,        [], :uint32
    attach_function :graphql_can_transition,     [:uint8, :uint8], :uint8
    attach_function :graphql_sub_can_transition, [:uint8, :uint8], :uint8
    attach_function :graphql_check_depth,        [:uint32, :uint32], :uint8
    attach_function :graphql_check_complexity,   [:uint32, :uint32], :uint8

    # GraphQL request context wrapping a Zig FFI slot.
    class Context
      attr_reader :slot

      def initialize(slot)
        @slot = slot
        @destroyed = false
      end

      # @param op_type [Integer] OperationType tag (default: QUERY)
      # @return [Context]
      def self.create(op_type: OperationType::QUERY)
        slot = ProvenServers.check_slot(Graphql.graphql_create(op_type))
        new(slot)
      end

      # @return [void]
      def destroy
        return if @destroyed

        Graphql.graphql_destroy(@slot)
        @destroyed = true
      end

      # @return [Integer, nil] Phase tag
      def phase
        tag = Graphql.graphql_phase(@slot)
        tag <= 4 ? tag : nil
      end

      # @return [Integer] OperationType tag
      def operation_type  = Graphql.graphql_operation_type(@slot)
      # @return [Integer] ErrorCategory tag
      def error_category  = Graphql.graphql_error_category(@slot)
      # @return [Integer]
      def query_depth     = Graphql.graphql_query_depth(@slot)
      # @return [Integer]
      def complexity      = Graphql.graphql_complexity(@slot)
      # @return [Integer]
      def fields_resolved = Graphql.graphql_fields_resolved(@slot)

      # Advance the request to the next phase.
      #
      # @return [void]
      def advance = ProvenServers.check_status(Graphql.graphql_advance(@slot))

      # Abort the request with an error category.
      #
      # @param err_category [Integer] ErrorCategory tag
      # @return [void]
      def abort(err_category)
        ProvenServers.check_status(Graphql.graphql_abort(@slot, err_category))
      end

      # @param depth [Integer]
      # @return [void]
      def set_query_depth(depth)
        ProvenServers.check_status(Graphql.graphql_set_query_depth(@slot, depth))
      end

      # @param score [Integer]
      # @return [void]
      def set_complexity(score)
        ProvenServers.check_status(Graphql.graphql_set_complexity(@slot, score))
      end

      # Resolve a field.
      #
      # @param type_kind [Integer]
      # @param scalar_kind [Integer]
      # @return [void]
      def resolve_field(type_kind, scalar_kind)
        ProvenServers.check_status(Graphql.graphql_resolve_field(@slot, type_kind, scalar_kind))
      end

      # Execute an introspection query.
      #
      # @param intro_field [Integer]
      # @return [void]
      def introspection_query(intro_field)
        ProvenServers.check_status(Graphql.graphql_introspection_query(@slot, intro_field))
      end

      # Create a subscription.
      #
      # @return [Integer] subscription slot ID
      def sub_create
        ProvenServers.check_slot(Graphql.graphql_sub_create(@slot))
      end

      # @return [Integer] subscription phase
      def sub_phase       = Graphql.graphql_sub_phase(@slot)
      # @return [void]
      def sub_advance     = ProvenServers.check_status(Graphql.graphql_sub_advance(@slot))
      # @return [void]
      def sub_emit_event  = ProvenServers.check_status(Graphql.graphql_sub_emit_event(@slot))
      # @return [void]
      def sub_abort       = ProvenServers.check_status(Graphql.graphql_sub_abort(@slot))
      # @return [Integer]
      def sub_event_count = Graphql.graphql_sub_event_count(@slot)
    end

    # @yield [Context]
    # @return [Object]
    def self.with_context(op_type: OperationType::QUERY)
      ctx = Context.create(op_type: op_type)
      begin
        yield ctx
      ensure
        ctx.destroy
      end
    end

    # @return [Integer]
    def self.abi_version = graphql_abi_version
    # @param from [Integer] @param to [Integer] @return [Boolean]
    def self.can_transition?(from, to) = graphql_can_transition(from, to) == 1
    # @param from [Integer] @param to [Integer] @return [Boolean]
    def self.sub_can_transition?(from, to) = graphql_sub_can_transition(from, to) == 1
    # @param depth [Integer] @param max_depth [Integer] @return [Boolean]
    def self.check_depth?(depth, max_depth) = graphql_check_depth(depth, max_depth) == 1
    # @param score [Integer] @param max_complexity [Integer] @return [Boolean]
    def self.check_complexity?(score, max_complexity) = graphql_check_complexity(score, max_complexity) == 1
  end
end
