// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file graphql.hpp
/// @brief C++ bindings for proven-graphql.
///
/// RAII wrapper. Request lifecycle:
/// Received -> Parsed -> Executing -> Complete (or Error at any point).

#ifndef PROVEN_GRAPHQL_HPP
#define PROVEN_GRAPHQL_HPP

#include "error.hpp"
#include <cstdint>
#include <optional>

extern "C" {
    uint32_t graphql_abi_version();
    int graphql_create(uint8_t op_type);
    void graphql_destroy(int slot);
    uint8_t graphql_phase(int slot);
    uint8_t graphql_operation_type(int slot);
    uint8_t graphql_error_category(int slot);
    uint8_t graphql_advance(int slot);
    uint8_t graphql_abort(int slot, uint8_t err_cat);
    uint8_t graphql_set_query_depth(int slot, uint16_t depth);
    uint16_t graphql_query_depth(int slot);
    uint8_t graphql_set_complexity(int slot, uint16_t score);
    uint16_t graphql_complexity(int slot);
    uint8_t graphql_resolve_field(int slot, uint8_t type_kind, uint8_t scalar_kind);
    uint16_t graphql_fields_resolved(int slot);
    uint8_t graphql_can_transition(uint8_t from, uint8_t to);
    int graphql_sub_create(int slot);
    uint8_t graphql_sub_phase(int slot);
    uint8_t graphql_sub_advance(int slot);
    uint8_t graphql_sub_emit_event(int slot);
    uint8_t graphql_sub_abort(int slot);
    uint32_t graphql_sub_event_count(int slot);
    uint8_t graphql_introspection_query(int slot, uint8_t intro_field);
    uint8_t graphql_check_depth(uint16_t depth, uint16_t max_depth);
    uint8_t graphql_check_complexity(uint16_t score, uint16_t max_complexity);
}

namespace proven {

/// @brief GraphQL request lifecycle phase.
enum class GraphqlPhase : uint8_t {
    Received = 0, Parsed = 1, Executing = 2, Complete = 3, Error = 4
};

/// @brief GraphQL operation type.
enum class GraphqlOperationType : uint8_t {
    Query = 0, Mutation = 1, Subscription = 2
};

/// @brief RAII wrapper for a GraphQL context slot.
class GraphqlContext {
public:
    /// @param op_type The operation type (Query/Mutation/Subscription).
    explicit GraphqlContext(GraphqlOperationType op_type)
        : slot_(ProvenError::check_slot(graphql_create(static_cast<uint8_t>(op_type)))) {}

    ~GraphqlContext() { if (slot_ >= 0) graphql_destroy(slot_); }

    GraphqlContext(const GraphqlContext&) = delete;
    GraphqlContext& operator=(const GraphqlContext&) = delete;
    GraphqlContext(GraphqlContext&& o) noexcept : slot_(o.slot_) { o.slot_ = -1; }
    GraphqlContext& operator=(GraphqlContext&& o) noexcept {
        if (this != &o) { if (slot_ >= 0) graphql_destroy(slot_); slot_ = o.slot_; o.slot_ = -1; }
        return *this;
    }

    [[nodiscard]] std::optional<GraphqlPhase> phase() const {
        uint8_t t = graphql_phase(slot_); return t <= 4 ? std::optional{static_cast<GraphqlPhase>(t)} : std::nullopt;
    }

    [[nodiscard]] GraphqlOperationType operation_type() const {
        return static_cast<GraphqlOperationType>(graphql_operation_type(slot_));
    }

    [[nodiscard]] uint8_t error_category() const { return graphql_error_category(slot_); }

    void advance() { ProvenError::check_status(graphql_advance(slot_)); }
    void abort(uint8_t err_category) { ProvenError::check_status(graphql_abort(slot_, err_category)); }

    void set_query_depth(uint16_t depth) { ProvenError::check_status(graphql_set_query_depth(slot_, depth)); }
    [[nodiscard]] uint16_t query_depth() const { return graphql_query_depth(slot_); }

    void set_complexity(uint16_t score) { ProvenError::check_status(graphql_set_complexity(slot_, score)); }
    [[nodiscard]] uint16_t complexity() const { return graphql_complexity(slot_); }

    void resolve_field(uint8_t type_kind, uint8_t scalar_kind) {
        ProvenError::check_status(graphql_resolve_field(slot_, type_kind, scalar_kind));
    }

    [[nodiscard]] uint16_t fields_resolved() const { return graphql_fields_resolved(slot_); }

    /// @brief Create a subscription (only for Subscription operation type).
    int sub_create() { return ProvenError::check_slot(graphql_sub_create(slot_)); }
    [[nodiscard]] uint8_t sub_phase() const { return graphql_sub_phase(slot_); }
    void sub_advance() { ProvenError::check_status(graphql_sub_advance(slot_)); }
    void sub_emit_event() { ProvenError::check_status(graphql_sub_emit_event(slot_)); }
    void sub_abort() { ProvenError::check_status(graphql_sub_abort(slot_)); }
    [[nodiscard]] uint32_t sub_event_count() const { return graphql_sub_event_count(slot_); }

    void introspection_query(uint8_t intro_field) {
        ProvenError::check_status(graphql_introspection_query(slot_, intro_field));
    }

    static bool can_transition(GraphqlPhase from, GraphqlPhase to) {
        return graphql_can_transition(static_cast<uint8_t>(from), static_cast<uint8_t>(to)) == 1;
    }

    /// @brief Stateless depth limit check.
    static bool check_depth(uint16_t depth, uint16_t max_depth) {
        return graphql_check_depth(depth, max_depth) == 1;
    }

    /// @brief Stateless complexity limit check.
    static bool check_complexity(uint16_t score, uint16_t max_complexity) {
        return graphql_check_complexity(score, max_complexity) == 1;
    }

    static uint32_t abi_version() { return graphql_abi_version(); }

private:
    int slot_;
};

} // namespace proven

#endif // PROVEN_GRAPHQL_HPP
