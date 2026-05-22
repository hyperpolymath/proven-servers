<?php

// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PHP bindings for the proven-graphql Zig FFI.

declare(strict_types=1);

namespace ProvenServers;

/** GraphQL request lifecycle phases matching Idris2 ABI tags. */
enum GraphqlPhase: int
{
    case Received  = 0;
    case Parsed    = 1;
    case Executing = 2;
    case Complete  = 3;
    case Error     = 4;
}

/** GraphQL operation types matching Idris2 ABI tags. */
enum GraphqlOperationType: int
{
    case Query        = 0;
    case Mutation     = 1;
    case Subscription = 2;
}

/** GraphQL error categories matching Idris2 ABI tags. */
enum GraphqlErrorCategory: int
{
    case Syntax        = 0;
    case Validation    = 1;
    case Authorization = 2;
    case Execution     = 3;
    case RateLimit     = 4;
    case Internal      = 5;
}

/**
 * GraphQL request context wrapping a Zig FFI slot.
 */
final class ProvenGraphql
{
    private const CDEF = <<<'CDEF'
    int graphql_create(uint8_t op_type);
    void graphql_destroy(int slot);
    uint8_t graphql_phase(int slot);
    uint8_t graphql_operation_type(int slot);
    uint8_t graphql_error_category(int slot);
    uint32_t graphql_query_depth(int slot);
    uint32_t graphql_complexity(int slot);
    uint32_t graphql_fields_resolved(int slot);
    uint8_t graphql_advance(int slot);
    uint8_t graphql_abort(int slot, uint8_t err_category);
    uint8_t graphql_set_query_depth(int slot, uint32_t depth);
    uint8_t graphql_set_complexity(int slot, uint32_t score);
    uint8_t graphql_resolve_field(int slot, uint8_t type_kind, uint8_t scalar_kind);
    uint8_t graphql_introspection_query(int slot, uint8_t intro_field);
    int graphql_sub_create(int slot);
    uint8_t graphql_sub_phase(int slot);
    uint8_t graphql_sub_advance(int slot);
    uint8_t graphql_sub_emit_event(int slot);
    uint8_t graphql_sub_abort(int slot);
    uint32_t graphql_sub_event_count(int slot);
    uint32_t graphql_abi_version(void);
    uint8_t graphql_can_transition(uint8_t from, uint8_t to);
    uint8_t graphql_sub_can_transition(uint8_t from, uint8_t to);
    uint8_t graphql_check_depth(uint32_t depth, uint32_t max_depth);
    uint8_t graphql_check_complexity(uint32_t score, uint32_t max_complexity);
    CDEF;

    private static ?\FFI $ffi = null;
    private int $slot;
    private bool $destroyed = false;

    private function __construct(int $slot) { $this->slot = $slot; }

    private static function ffi(): \FFI
    {
        if (self::$ffi === null) {
            self::$ffi = ProvenServers::loadLibrary('graphql', self::CDEF);
        }
        return self::$ffi;
    }

    /** @throws ProvenError */
    public static function create(GraphqlOperationType $opType = GraphqlOperationType::Query): self
    {
        return new self(ProvenError::checkSlot(self::ffi()->graphql_create($opType->value)));
    }

    public function destroy(): void
    {
        if (!$this->destroyed) {
            self::ffi()->graphql_destroy($this->slot);
            $this->destroyed = true;
        }
    }

    public function phase(): ?GraphqlPhase
    {
        $tag = self::ffi()->graphql_phase($this->slot);
        return $tag <= 4 ? GraphqlPhase::from($tag) : null;
    }

    public function operationType(): int { return self::ffi()->graphql_operation_type($this->slot); }
    public function errorCategory(): int { return self::ffi()->graphql_error_category($this->slot); }
    public function queryDepth(): int { return self::ffi()->graphql_query_depth($this->slot); }
    public function complexity(): int { return self::ffi()->graphql_complexity($this->slot); }
    public function fieldsResolved(): int { return self::ffi()->graphql_fields_resolved($this->slot); }

    /** @throws ProvenError */
    public function advance(): void { ProvenError::checkStatus(self::ffi()->graphql_advance($this->slot)); }

    /** @throws ProvenError */
    public function abort(GraphqlErrorCategory $errCategory): void
    {
        ProvenError::checkStatus(self::ffi()->graphql_abort($this->slot, $errCategory->value));
    }

    /** @throws ProvenError */
    public function setQueryDepth(int $depth): void
    {
        ProvenError::checkStatus(self::ffi()->graphql_set_query_depth($this->slot, $depth));
    }

    /** @throws ProvenError */
    public function setComplexity(int $score): void
    {
        ProvenError::checkStatus(self::ffi()->graphql_set_complexity($this->slot, $score));
    }

    /** @throws ProvenError */
    public function resolveField(int $typeKind, int $scalarKind): void
    {
        ProvenError::checkStatus(self::ffi()->graphql_resolve_field($this->slot, $typeKind, $scalarKind));
    }

    /** @throws ProvenError */
    public function introspectionQuery(int $introField): void
    {
        ProvenError::checkStatus(self::ffi()->graphql_introspection_query($this->slot, $introField));
    }

    /** @return int Subscription slot ID. @throws ProvenError */
    public function subCreate(): int
    {
        return ProvenError::checkSlot(self::ffi()->graphql_sub_create($this->slot));
    }

    public function subPhase(): int { return self::ffi()->graphql_sub_phase($this->slot); }
    /** @throws ProvenError */
    public function subAdvance(): void { ProvenError::checkStatus(self::ffi()->graphql_sub_advance($this->slot)); }
    /** @throws ProvenError */
    public function subEmitEvent(): void { ProvenError::checkStatus(self::ffi()->graphql_sub_emit_event($this->slot)); }
    /** @throws ProvenError */
    public function subAbort(): void { ProvenError::checkStatus(self::ffi()->graphql_sub_abort($this->slot)); }
    public function subEventCount(): int { return self::ffi()->graphql_sub_event_count($this->slot); }

    public static function abiVersion(): int { return self::ffi()->graphql_abi_version(); }
    public static function canTransition(GraphqlPhase $from, GraphqlPhase $to): bool
    {
        return self::ffi()->graphql_can_transition($from->value, $to->value) === 1;
    }
    public static function subCanTransition(int $from, int $to): bool
    {
        return self::ffi()->graphql_sub_can_transition($from, $to) === 1;
    }
    public static function checkDepth(int $depth, int $maxDepth): bool
    {
        return self::ffi()->graphql_check_depth($depth, $maxDepth) === 1;
    }
    public static function checkComplexity(int $score, int $maxComplexity): bool
    {
        return self::ffi()->graphql_check_complexity($score, $maxComplexity) === 1;
    }
}
