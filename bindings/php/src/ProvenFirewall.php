<?php

// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PHP bindings for the proven-firewall Zig FFI.

declare(strict_types=1);

namespace ProvenServers;

/** Firewall rule actions matching Idris2 ABI tags. */
enum FirewallAction: int
{
    case Accept     = 0;
    case Drop       = 1;
    case Reject     = 2;
    case Log        = 3;
    case Redirect   = 4;
    case Dnat       = 5;
    case Snat       = 6;
    case Masquerade = 7;
}

/** Firewall packet lifecycle states matching Idris2 ABI tags. */
enum FirewallPacketState: int
{
    case Idle       = 0;
    case Classified = 1;
    case Evaluating = 2;
    case Decided    = 3;
    case Committed  = 4;
}

/** Connection tracking states matching Idris2 ABI tags. */
enum FirewallConntrackState: int
{
    case None        = 0;
    case Tracking    = 1;
    case Established = 2;
    case Related     = 3;
    case Expired     = 4;
}

/**
 * Firewall packet evaluation context wrapping a Zig FFI slot.
 */
final class ProvenFirewall
{
    private const CDEF = <<<'CDEF'
    int fw_create_context(void);
    void fw_destroy_context(int slot);
    uint8_t fw_packet_state(int slot);
    uint8_t fw_conntrack_state(int slot);
    uint8_t fw_get_decision(int slot);
    uint32_t fw_rule_count(int slot);
    uint8_t fw_packet_proto(int slot);
    uint8_t fw_packet_chain(int slot);
    uint32_t fw_packet_src_ip(int slot);
    uint32_t fw_packet_dst_ip(int slot);
    uint16_t fw_packet_src_port(int slot);
    uint16_t fw_packet_dst_port(int slot);
    uint8_t fw_classify_packet(int slot, uint8_t proto, uint8_t chain, uint32_t src_ip, uint32_t dst_ip, uint16_t src_port, uint16_t dst_port);
    uint8_t fw_begin_chain(int slot);
    uint8_t fw_add_rule(int slot, uint8_t match_type, uint32_t match_value, uint8_t action, uint32_t priority);
    uint8_t fw_set_default_action(int slot, uint8_t action);
    uint8_t fw_evaluate_rules(int slot);
    uint8_t fw_commit(int slot);
    uint8_t fw_begin_tracking(int slot);
    uint8_t fw_complete_tracking(int slot, uint8_t conn_state);
    uint8_t fw_expire_conn(int slot);
    uint32_t fw_abi_version(void);
    uint8_t fw_can_transition(uint8_t from, uint8_t to);
    uint8_t fw_can_conntrack_transition(uint8_t from, uint8_t to);
    CDEF;

    private static ?\FFI $ffi = null;
    private int $slot;
    private bool $destroyed = false;

    private function __construct(int $slot) { $this->slot = $slot; }

    private static function ffi(): \FFI
    {
        if (self::$ffi === null) {
            self::$ffi = ProvenServers::loadLibrary('firewall', self::CDEF);
        }
        return self::$ffi;
    }

    /** @throws ProvenError */
    public static function create(): self
    {
        return new self(ProvenError::checkSlot(self::ffi()->fw_create_context()));
    }

    public function destroy(): void
    {
        if (!$this->destroyed) {
            self::ffi()->fw_destroy_context($this->slot);
            $this->destroyed = true;
        }
    }

    public function packetState(): ?FirewallPacketState
    {
        $tag = self::ffi()->fw_packet_state($this->slot);
        return $tag <= 4 ? FirewallPacketState::from($tag) : null;
    }

    public function conntrackState(): ?FirewallConntrackState
    {
        $tag = self::ffi()->fw_conntrack_state($this->slot);
        return $tag <= 4 ? FirewallConntrackState::from($tag) : null;
    }

    public function getDecision(): ?FirewallAction
    {
        $tag = self::ffi()->fw_get_decision($this->slot);
        return $tag <= 7 ? FirewallAction::from($tag) : null;
    }

    public function ruleCount(): int { return self::ffi()->fw_rule_count($this->slot); }
    public function packetProto(): int { return self::ffi()->fw_packet_proto($this->slot); }
    public function packetChain(): int { return self::ffi()->fw_packet_chain($this->slot); }
    public function packetSrcIp(): int { return self::ffi()->fw_packet_src_ip($this->slot); }
    public function packetDstIp(): int { return self::ffi()->fw_packet_dst_ip($this->slot); }
    public function packetSrcPort(): int { return self::ffi()->fw_packet_src_port($this->slot); }
    public function packetDstPort(): int { return self::ffi()->fw_packet_dst_port($this->slot); }

    /**
     * Classify a packet. Transitions Idle -> Classified.
     *
     * @throws ProvenError
     */
    public function classifyPacket(
        int $proto,
        int $chain,
        int $srcIp,
        int $dstIp,
        int $srcPort,
        int $dstPort,
    ): void {
        ProvenError::checkStatus(
            self::ffi()->fw_classify_packet($this->slot, $proto, $chain, $srcIp, $dstIp, $srcPort, $dstPort)
        );
    }

    /** @throws ProvenError */
    public function beginChain(): void { ProvenError::checkStatus(self::ffi()->fw_begin_chain($this->slot)); }

    /**
     * Add a firewall rule.
     *
     * @throws ProvenError
     */
    public function addRule(int $matchType, int $matchValue, FirewallAction $action, int $priority): void
    {
        ProvenError::checkStatus(
            self::ffi()->fw_add_rule($this->slot, $matchType, $matchValue, $action->value, $priority)
        );
    }

    /** @throws ProvenError */
    public function setDefaultAction(FirewallAction $action): void
    {
        ProvenError::checkStatus(self::ffi()->fw_set_default_action($this->slot, $action->value));
    }

    /** @throws ProvenError */
    public function evaluateRules(): void { ProvenError::checkStatus(self::ffi()->fw_evaluate_rules($this->slot)); }
    /** @throws ProvenError */
    public function commit(): void { ProvenError::checkStatus(self::ffi()->fw_commit($this->slot)); }
    /** @throws ProvenError */
    public function beginTracking(): void { ProvenError::checkStatus(self::ffi()->fw_begin_tracking($this->slot)); }

    /** @throws ProvenError */
    public function completeTracking(FirewallConntrackState $connState): void
    {
        ProvenError::checkStatus(self::ffi()->fw_complete_tracking($this->slot, $connState->value));
    }

    /** @throws ProvenError */
    public function expireConn(): void { ProvenError::checkStatus(self::ffi()->fw_expire_conn($this->slot)); }

    public static function abiVersion(): int { return self::ffi()->fw_abi_version(); }
    public static function canTransition(FirewallPacketState $from, FirewallPacketState $to): bool
    {
        return self::ffi()->fw_can_transition($from->value, $to->value) === 1;
    }
    public static function canConntrackTransition(FirewallConntrackState $from, FirewallConntrackState $to): bool
    {
        return self::ffi()->fw_can_conntrack_transition($from->value, $to->value) === 1;
    }
}
