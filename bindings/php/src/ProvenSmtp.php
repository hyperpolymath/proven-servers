<?php

// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PHP bindings for the proven-smtp Zig FFI.

declare(strict_types=1);

namespace ProvenServers;

/** SMTP session states matching Idris2 ABI tags. */
enum SmtpSessionState: int
{
    case Connected       = 0;
    case Greeted         = 1;
    case AuthStarted     = 2;
    case Authenticated   = 3;
    case MailFrom        = 4;
    case RcptTo          = 5;
    case Data            = 6;
    case MessageReceived = 7;
    case Quit            = 8;
}

/** SMTP AUTH mechanisms matching Idris2 ABI tags. */
enum SmtpAuthMechanism: int
{
    case Plain   = 0;
    case Login   = 1;
    case CramMd5 = 2;
    case Xoauth2 = 3;
}

/**
 * SMTP session context wrapping a Zig FFI slot.
 */
final class ProvenSmtp
{
    private const CDEF = <<<'CDEF'
    int smtp_create_context(void);
    void smtp_destroy_context(int slot);
    uint8_t smtp_get_state(int slot);
    uint16_t smtp_get_reply_code(int slot);
    uint32_t smtp_get_recipient_count(int slot);
    uint32_t smtp_get_data_size(int slot);
    uint8_t smtp_get_auth_mechanism(int slot);
    uint8_t smtp_is_authenticated(int slot);
    uint8_t smtp_is_tls_active(int slot);
    uint8_t smtp_greet(int slot, uint8_t ehlo);
    uint8_t smtp_authenticate(int slot, uint8_t mechanism);
    uint8_t smtp_auth_complete(int slot, uint8_t success);
    uint8_t smtp_set_sender(int slot);
    uint8_t smtp_add_recipient(int slot);
    uint8_t smtp_start_data(int slot);
    uint8_t smtp_append_data(int slot, uint32_t length);
    uint8_t smtp_finish_data(int slot);
    uint8_t smtp_reset(int slot);
    uint8_t smtp_quit(int slot);
    uint8_t smtp_enable_tls(int slot);
    uint32_t smtp_abi_version(void);
    uint8_t smtp_can_transition(uint8_t from, uint8_t to);
    CDEF;

    private static ?\FFI $ffi = null;
    private int $slot;
    private bool $destroyed = false;

    private function __construct(int $slot) { $this->slot = $slot; }

    private static function ffi(): \FFI
    {
        if (self::$ffi === null) {
            self::$ffi = ProvenServers::loadLibrary('smtp', self::CDEF);
        }
        return self::$ffi;
    }

    /** @throws ProvenError */
    public static function create(): self
    {
        return new self(ProvenError::checkSlot(self::ffi()->smtp_create_context()));
    }

    public function destroy(): void
    {
        if (!$this->destroyed) {
            self::ffi()->smtp_destroy_context($this->slot);
            $this->destroyed = true;
        }
    }

    public function getState(): ?SmtpSessionState
    {
        $tag = self::ffi()->smtp_get_state($this->slot);
        return $tag <= 8 ? SmtpSessionState::from($tag) : null;
    }

    public function getReplyCode(): int { return self::ffi()->smtp_get_reply_code($this->slot); }
    public function getRecipientCount(): int { return self::ffi()->smtp_get_recipient_count($this->slot); }
    public function getDataSize(): int { return self::ffi()->smtp_get_data_size($this->slot); }

    public function getAuthMechanism(): ?SmtpAuthMechanism
    {
        $tag = self::ffi()->smtp_get_auth_mechanism($this->slot);
        return $tag <= 3 ? SmtpAuthMechanism::from($tag) : null;
    }

    public function isAuthenticated(): bool { return self::ffi()->smtp_is_authenticated($this->slot) === 1; }
    public function isTlsActive(): bool { return self::ffi()->smtp_is_tls_active($this->slot) === 1; }

    /** @throws ProvenError */
    public function greet(bool $ehlo = true): void
    {
        ProvenError::checkStatus(self::ffi()->smtp_greet($this->slot, $ehlo ? 1 : 0));
    }

    /** @throws ProvenError */
    public function authenticate(SmtpAuthMechanism $mechanism): void
    {
        ProvenError::checkStatus(self::ffi()->smtp_authenticate($this->slot, $mechanism->value));
    }

    /** @throws ProvenError */
    public function authComplete(bool $success): void
    {
        ProvenError::checkStatus(self::ffi()->smtp_auth_complete($this->slot, $success ? 1 : 0));
    }

    /** @throws ProvenError */
    public function setSender(): void { ProvenError::checkStatus(self::ffi()->smtp_set_sender($this->slot)); }
    /** @throws ProvenError */
    public function addRecipient(): void { ProvenError::checkStatus(self::ffi()->smtp_add_recipient($this->slot)); }
    /** @throws ProvenError */
    public function startData(): void { ProvenError::checkStatus(self::ffi()->smtp_start_data($this->slot)); }

    /** @throws ProvenError */
    public function appendData(int $length): void
    {
        ProvenError::checkStatus(self::ffi()->smtp_append_data($this->slot, $length));
    }

    /** @throws ProvenError */
    public function finishData(): void { ProvenError::checkStatus(self::ffi()->smtp_finish_data($this->slot)); }
    /** @throws ProvenError */
    public function reset(): void { ProvenError::checkStatus(self::ffi()->smtp_reset($this->slot)); }
    /** @throws ProvenError */
    public function quit(): void { ProvenError::checkStatus(self::ffi()->smtp_quit($this->slot)); }
    /** @throws ProvenError */
    public function enableTls(): void { ProvenError::checkStatus(self::ffi()->smtp_enable_tls($this->slot)); }

    public static function abiVersion(): int { return self::ffi()->smtp_abi_version(); }
    public static function canTransition(SmtpSessionState $from, SmtpSessionState $to): bool
    {
        return self::ffi()->smtp_can_transition($from->value, $to->value) === 1;
    }
}
