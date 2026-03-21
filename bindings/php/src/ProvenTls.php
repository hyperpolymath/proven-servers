<?php

// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PHP bindings for the proven-tls Zig FFI.

declare(strict_types=1);

namespace ProvenServers;

/** TLS handshake lifecycle states matching Idris2 ABI tags. */
enum TlsState: int
{
    case Idle              = 0;
    case ClientHello       = 1;
    case ServerHello       = 2;
    case Negotiated        = 3;
    case HandshakeComplete = 4;
    case ApplicationData   = 5;
    case Shutdown          = 6;
    case Closed            = 7;
}

/** TLS protocol versions matching Idris2 ABI tags. */
enum TlsVersion: int
{
    case Tls1_2 = 0;
    case Tls1_3 = 1;
}

/** TLS cipher suites matching Idris2 ABI tags. */
enum TlsCipherSuite: int
{
    case Aes128GcmSha256      = 0;
    case Aes256GcmSha384      = 1;
    case Chacha20Poly1305Sha256 = 2;
    case Aes128CcmSha256      = 3;
}

/** Certificate validation status matching Idris2 ABI tags. */
enum TlsCertStatus: int
{
    case Unchecked        = 0;
    case Valid            = 1;
    case Expired          = 2;
    case Revoked          = 3;
    case SelfSigned       = 4;
    case UnknownCA        = 5;
    case HostnameMismatch = 6;
}

/** TLS alert levels matching Idris2 ABI tags. */
enum TlsAlertLevel: int
{
    case Warning = 0;
    case Fatal   = 1;
}

/**
 * TLS session context wrapping a Zig FFI slot.
 */
final class ProvenTls
{
    private const CDEF = <<<'CDEF'
    int tls_create(uint8_t version, uint8_t cipher_suite);
    void tls_destroy(int slot);
    uint8_t tls_state(int slot);
    uint8_t tls_version(int slot);
    uint8_t tls_cipher_suite(int slot);
    uint8_t tls_cert_status(int slot);
    uint8_t tls_is_resumed(int slot);
    uint64_t tls_bytes_sent(int slot);
    uint64_t tls_bytes_received(int slot);
    uint8_t tls_client_hello(int slot);
    uint8_t tls_server_hello(int slot);
    uint8_t tls_negotiate(int slot, uint8_t cipher_suite);
    uint8_t tls_validate_cert(int slot, uint8_t status);
    uint8_t tls_complete_handshake(int slot);
    uint8_t tls_send_data(int slot, uint64_t length);
    uint8_t tls_receive_data(int slot, uint64_t length);
    uint8_t tls_rekey(int slot);
    uint8_t tls_shutdown(int slot);
    uint8_t tls_send_alert(int slot, uint8_t level);
    uint32_t tls_abi_version(void);
    uint8_t tls_can_transition(uint8_t from, uint8_t to);
    CDEF;

    private static ?\FFI $ffi = null;
    private int $slot;
    private bool $destroyed = false;

    private function __construct(int $slot) { $this->slot = $slot; }

    private static function ffi(): \FFI
    {
        if (self::$ffi === null) {
            self::$ffi = ProvenServers::loadLibrary('tls', self::CDEF);
        }
        return self::$ffi;
    }

    /** @throws ProvenError */
    public static function create(
        TlsVersion $version = TlsVersion::Tls1_3,
        TlsCipherSuite $cipherSuite = TlsCipherSuite::Aes256GcmSha384,
    ): self {
        return new self(ProvenError::checkSlot(self::ffi()->tls_create($version->value, $cipherSuite->value)));
    }

    public function destroy(): void
    {
        if (!$this->destroyed) {
            self::ffi()->tls_destroy($this->slot);
            $this->destroyed = true;
        }
    }

    public function state(): ?TlsState
    {
        $tag = self::ffi()->tls_state($this->slot);
        return $tag <= 7 ? TlsState::from($tag) : null;
    }

    public function version(): ?TlsVersion
    {
        $tag = self::ffi()->tls_version($this->slot);
        return $tag <= 1 ? TlsVersion::from($tag) : null;
    }

    public function cipherSuite(): ?TlsCipherSuite
    {
        $tag = self::ffi()->tls_cipher_suite($this->slot);
        return $tag <= 3 ? TlsCipherSuite::from($tag) : null;
    }

    public function certStatus(): ?TlsCertStatus
    {
        $tag = self::ffi()->tls_cert_status($this->slot);
        return $tag <= 6 ? TlsCertStatus::from($tag) : null;
    }

    public function isResumed(): bool { return self::ffi()->tls_is_resumed($this->slot) === 1; }
    public function bytesSent(): int { return self::ffi()->tls_bytes_sent($this->slot); }
    public function bytesReceived(): int { return self::ffi()->tls_bytes_received($this->slot); }

    /** @throws ProvenError */
    public function clientHello(): void { ProvenError::checkStatus(self::ffi()->tls_client_hello($this->slot)); }
    /** @throws ProvenError */
    public function serverHello(): void { ProvenError::checkStatus(self::ffi()->tls_server_hello($this->slot)); }

    /** @throws ProvenError */
    public function negotiate(TlsCipherSuite $cipherSuite): void
    {
        ProvenError::checkStatus(self::ffi()->tls_negotiate($this->slot, $cipherSuite->value));
    }

    /** @throws ProvenError */
    public function validateCert(TlsCertStatus $status): void
    {
        ProvenError::checkStatus(self::ffi()->tls_validate_cert($this->slot, $status->value));
    }

    /** @throws ProvenError */
    public function completeHandshake(): void { ProvenError::checkStatus(self::ffi()->tls_complete_handshake($this->slot)); }

    /** @throws ProvenError */
    public function sendData(int $length): void { ProvenError::checkStatus(self::ffi()->tls_send_data($this->slot, $length)); }
    /** @throws ProvenError */
    public function receiveData(int $length): void { ProvenError::checkStatus(self::ffi()->tls_receive_data($this->slot, $length)); }
    /** @throws ProvenError */
    public function rekey(): void { ProvenError::checkStatus(self::ffi()->tls_rekey($this->slot)); }
    /** @throws ProvenError */
    public function shutdown(): void { ProvenError::checkStatus(self::ffi()->tls_shutdown($this->slot)); }

    /** @throws ProvenError */
    public function sendAlert(TlsAlertLevel $level): void
    {
        ProvenError::checkStatus(self::ffi()->tls_send_alert($this->slot, $level->value));
    }

    public static function abiVersion(): int { return self::ffi()->tls_abi_version(); }
    public static function canTransition(TlsState $from, TlsState $to): bool
    {
        return self::ffi()->tls_can_transition($from->value, $to->value) === 1;
    }
}
