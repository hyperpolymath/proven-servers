<?php

// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PHP bindings for the proven-dns Zig FFI.
//
// Wraps the C-ABI functions for DNS query/response lifecycle,
// DNSSEC signing and validation, and record management.

declare(strict_types=1);

namespace ProvenServers;

/** DNS query lifecycle states matching Idris2 ABI tags. */
enum DnsState: int
{
    case Idle             = 0;
    case QueryReceived    = 1;
    case Lookup           = 2;
    case ResponseBuilding = 3;
    case Sent             = 4;
}

/** DNSSEC states matching Idris2 ABI tags. */
enum DnssecState: int
{
    case Disabled  = 0;
    case Enabled   = 1;
    case KeyLoaded = 2;
    case Validated = 3;
}

/** DNSSEC signing algorithms matching Idris2 ABI tags. */
enum DnssecAlgorithm: int
{
    case RsaSha256        = 0;
    case RsaSha512        = 1;
    case EcdsaP256Sha256  = 2;
    case EcdsaP384Sha384  = 3;
    case Ed25519          = 4;
}

/**
 * DNS query/response context wrapping a Zig FFI slot.
 */
final class ProvenDns
{
    private const CDEF = <<<'CDEF'
    int dns_create_context(void);
    void dns_destroy_context(int slot);
    uint8_t dns_state(int slot);
    uint8_t dns_dnssec_state(int slot);
    uint8_t dns_rcode(int slot);
    uint32_t dns_answer_count(int slot);
    uint32_t dns_authority_count(int slot);
    uint32_t dns_additional_count(int slot);
    uint16_t dns_query_rtype(int slot);
    uint16_t dns_query_class(int slot);
    uint8_t dns_parse_query(int slot, const uint8_t *data, uint32_t len);
    uint8_t dns_begin_lookup(int slot);
    uint8_t dns_begin_response(int slot);
    uint8_t dns_add_answer(int slot, uint16_t rtype, uint16_t rclass, uint32_t ttl, const uint8_t *rdata, uint32_t rdata_len);
    uint8_t dns_add_authority(int slot, uint16_t rtype, uint16_t rclass, uint32_t ttl, const uint8_t *rdata, uint32_t rdata_len);
    uint8_t dns_add_additional(int slot, uint16_t rtype, uint16_t rclass, uint32_t ttl, const uint8_t *rdata, uint32_t rdata_len);
    uint8_t dns_set_rcode(int slot, uint8_t rcode);
    uint8_t dns_build_response(int slot, uint8_t *buf, uint16_t *out_len);
    uint8_t dns_enable_dnssec(int slot);
    uint8_t dns_load_dnssec_key(int slot, uint8_t algo);
    uint8_t dns_sign_response(int slot);
    uint8_t dns_validate_dnssec(int slot);
    uint32_t dns_abi_version(void);
    uint8_t dns_can_transition(uint8_t from, uint8_t to);
    uint8_t dns_can_dnssec_transition(uint8_t from, uint8_t to);
    CDEF;

    private static ?\FFI $ffi = null;
    private int $slot;
    private bool $destroyed = false;

    private function __construct(int $slot)
    {
        $this->slot = $slot;
    }

    private static function ffi(): \FFI
    {
        if (self::$ffi === null) {
            self::$ffi = ProvenServers::loadLibrary('dns', self::CDEF);
        }
        return self::$ffi;
    }

    /** @throws ProvenError */
    public static function create(): self
    {
        return new self(ProvenError::checkSlot(self::ffi()->dns_create_context()));
    }

    public function destroy(): void
    {
        if (!$this->destroyed) {
            self::ffi()->dns_destroy_context($this->slot);
            $this->destroyed = true;
        }
    }

    public function state(): ?DnsState
    {
        $tag = self::ffi()->dns_state($this->slot);
        return $tag <= 4 ? DnsState::from($tag) : null;
    }

    public function dnssecState(): ?DnssecState
    {
        $tag = self::ffi()->dns_dnssec_state($this->slot);
        return $tag <= 3 ? DnssecState::from($tag) : null;
    }

    public function rcode(): int { return self::ffi()->dns_rcode($this->slot); }
    public function answerCount(): int { return self::ffi()->dns_answer_count($this->slot); }
    public function authorityCount(): int { return self::ffi()->dns_authority_count($this->slot); }
    public function additionalCount(): int { return self::ffi()->dns_additional_count($this->slot); }
    public function queryRtype(): int { return self::ffi()->dns_query_rtype($this->slot); }
    public function queryClass(): int { return self::ffi()->dns_query_class($this->slot); }

    /** @throws ProvenError */
    public function parseQuery(string $data): void
    {
        ProvenError::checkStatus(self::ffi()->dns_parse_query($this->slot, $data, strlen($data)));
    }

    /** @throws ProvenError */
    public function beginLookup(): void { ProvenError::checkStatus(self::ffi()->dns_begin_lookup($this->slot)); }
    /** @throws ProvenError */
    public function beginResponse(): void { ProvenError::checkStatus(self::ffi()->dns_begin_response($this->slot)); }

    /** @throws ProvenError */
    public function addAnswer(int $rtype, int $rclass, int $ttl, string $rdata): void
    {
        ProvenError::checkStatus(self::ffi()->dns_add_answer($this->slot, $rtype, $rclass, $ttl, $rdata, strlen($rdata)));
    }

    /** @throws ProvenError */
    public function addAuthority(int $rtype, int $rclass, int $ttl, string $rdata): void
    {
        ProvenError::checkStatus(self::ffi()->dns_add_authority($this->slot, $rtype, $rclass, $ttl, $rdata, strlen($rdata)));
    }

    /** @throws ProvenError */
    public function addAdditional(int $rtype, int $rclass, int $ttl, string $rdata): void
    {
        ProvenError::checkStatus(self::ffi()->dns_add_additional($this->slot, $rtype, $rclass, $ttl, $rdata, strlen($rdata)));
    }

    /** @throws ProvenError */
    public function setRcode(int $rcodeTag): void
    {
        ProvenError::checkStatus(self::ffi()->dns_set_rcode($this->slot, $rcodeTag));
    }

    /**
     * Build the DNS response wire format.
     *
     * @param int $maxLen Maximum response length.
     * @return string Serialized DNS response bytes.
     * @throws ProvenError
     */
    public function buildResponse(int $maxLen = 512): string
    {
        $buf = \FFI::new("uint8_t[{$maxLen}]");
        $outLen = \FFI::new('uint16_t');
        ProvenError::checkStatus(self::ffi()->dns_build_response($this->slot, $buf, \FFI::addr($outLen)));
        return \FFI::string($buf, $outLen->cdata);
    }

    /** @throws ProvenError */
    public function enableDnssec(): void { ProvenError::checkStatus(self::ffi()->dns_enable_dnssec($this->slot)); }

    /** @throws ProvenError */
    public function loadDnssecKey(DnssecAlgorithm $algo): void
    {
        ProvenError::checkStatus(self::ffi()->dns_load_dnssec_key($this->slot, $algo->value));
    }

    /** @throws ProvenError */
    public function signResponse(): void { ProvenError::checkStatus(self::ffi()->dns_sign_response($this->slot)); }

    public function validateDnssec(): bool { return self::ffi()->dns_validate_dnssec($this->slot) === 0; }

    public static function abiVersion(): int { return self::ffi()->dns_abi_version(); }
    public static function canTransition(DnsState $from, DnsState $to): bool
    {
        return self::ffi()->dns_can_transition($from->value, $to->value) === 1;
    }
    public static function canDnssecTransition(DnssecState $from, DnssecState $to): bool
    {
        return self::ffi()->dns_can_dnssec_transition($from->value, $to->value) === 1;
    }
}
