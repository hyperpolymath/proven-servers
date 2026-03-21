<?php

// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PHP bindings for the proven-ssh-bastion Zig FFI.

declare(strict_types=1);

namespace ProvenServers;

/** SSH bastion session states matching Idris2 ABI tags. */
enum SshBastionState: int
{
    case Connected    = 0;
    case KeyExchanged = 1;
    case Authenticated = 2;
    case ChannelOpen  = 3;
    case Active       = 4;
    case Closed       = 5;
}

/** SSH key exchange methods matching Idris2 ABI tags. */
enum SshKexMethod: int
{
    case Curve25519Sha256            = 0;
    case EcdhSha2Nistp256            = 1;
    case EcdhSha2Nistp384            = 2;
    case DiffieHellmanGroup14Sha256  = 3;
    case DiffieHellmanGroup16Sha512  = 4;
}

/** SSH authentication methods matching Idris2 ABI tags. */
enum SshAuthMethod: int
{
    case PublicKey            = 0;
    case Password             = 1;
    case KeyboardInteractive  = 2;
    case HostBased            = 3;
}

/** SSH channel types matching Idris2 ABI tags. */
enum SshChannelType: int
{
    case Session        = 0;
    case DirectTcpip    = 1;
    case ForwardedTcpip = 2;
    case X11            = 3;
}

/** SSH channel states matching Idris2 ABI tags. */
enum SshChannelState: int
{
    case Opening = 0;
    case Open    = 1;
    case Closed  = 2;
}

/** SSH disconnect reasons matching Idris2 ABI tags. */
enum SshDisconnectReason: int
{
    case ByApplication        = 0;
    case ProtocolError        = 1;
    case KeyExchangeFailed    = 2;
    case AuthCancelledByUser  = 3;
    case TooManyConnections   = 4;
    case HostNotAllowed       = 5;
    case IllegalUserName      = 6;
}

/**
 * SSH bastion session context wrapping a Zig FFI slot.
 */
final class ProvenSshBastion
{
    private const CDEF = <<<'CDEF'
    int ssh_bastion_create(uint8_t kex, uint8_t auth);
    void ssh_bastion_destroy(int slot);
    uint8_t ssh_bastion_state(int slot);
    uint8_t ssh_bastion_kex_method(int slot);
    uint8_t ssh_bastion_auth_method(int slot);
    uint8_t ssh_bastion_can_transfer(int slot);
    uint8_t ssh_bastion_disconnect_reason(int slot);
    uint32_t ssh_bastion_auth_failures(int slot);
    uint8_t ssh_bastion_complete_kex(int slot);
    uint8_t ssh_bastion_authenticate(int slot, uint8_t dummy);
    uint8_t ssh_bastion_record_auth_failure(int slot);
    int ssh_bastion_open_channel(int slot, uint8_t ch_type);
    uint8_t ssh_bastion_confirm_channel(int slot, int ch_id);
    uint8_t ssh_bastion_close_channel(int slot, int ch_id);
    uint8_t ssh_bastion_channel_state(int slot, int ch_id);
    uint8_t ssh_bastion_channel_type(int slot, int ch_id);
    uint32_t ssh_bastion_channel_count(int slot);
    uint8_t ssh_bastion_rekey(int slot);
    uint8_t ssh_bastion_disconnect(int slot, uint8_t reason);
    uint32_t ssh_bastion_audit_count(int slot);
    uint8_t ssh_bastion_audit_entry(int slot, uint32_t index);
    uint8_t ssh_bastion_audit_entry_to(int slot, uint32_t index);
    uint8_t ssh_bastion_set_recording(int slot, uint8_t enabled);
    uint8_t ssh_bastion_is_recording(int slot);
    uint32_t ssh_bastion_abi_version(void);
    uint8_t ssh_bastion_can_transition(uint8_t from, uint8_t to);
    CDEF;

    private static ?\FFI $ffi = null;
    private int $slot;
    private bool $destroyed = false;

    private function __construct(int $slot) { $this->slot = $slot; }

    private static function ffi(): \FFI
    {
        if (self::$ffi === null) {
            self::$ffi = ProvenServers::loadLibrary('ssh_bastion', self::CDEF);
        }
        return self::$ffi;
    }

    /** @throws ProvenError */
    public static function create(
        SshKexMethod $kex = SshKexMethod::Curve25519Sha256,
        SshAuthMethod $auth = SshAuthMethod::PublicKey,
    ): self {
        return new self(ProvenError::checkSlot(self::ffi()->ssh_bastion_create($kex->value, $auth->value)));
    }

    public function destroy(): void
    {
        if (!$this->destroyed) {
            self::ffi()->ssh_bastion_destroy($this->slot);
            $this->destroyed = true;
        }
    }

    public function state(): ?SshBastionState
    {
        $tag = self::ffi()->ssh_bastion_state($this->slot);
        return $tag <= 5 ? SshBastionState::from($tag) : null;
    }

    public function kexMethod(): ?SshKexMethod
    {
        $tag = self::ffi()->ssh_bastion_kex_method($this->slot);
        return $tag <= 4 ? SshKexMethod::from($tag) : null;
    }

    public function authMethod(): ?SshAuthMethod
    {
        $tag = self::ffi()->ssh_bastion_auth_method($this->slot);
        return $tag <= 3 ? SshAuthMethod::from($tag) : null;
    }

    public function canTransferData(): bool { return self::ffi()->ssh_bastion_can_transfer($this->slot) === 1; }

    public function disconnectReason(): ?SshDisconnectReason
    {
        $tag = self::ffi()->ssh_bastion_disconnect_reason($this->slot);
        return $tag <= 6 ? SshDisconnectReason::from($tag) : null;
    }

    public function authFailures(): int { return self::ffi()->ssh_bastion_auth_failures($this->slot); }

    /** @throws ProvenError */
    public function completeKex(): void { ProvenError::checkStatus(self::ffi()->ssh_bastion_complete_kex($this->slot)); }
    /** @throws ProvenError */
    public function authenticate(): void { ProvenError::checkStatus(self::ffi()->ssh_bastion_authenticate($this->slot, 0)); }

    /** @return bool True if locked out. */
    public function recordAuthFailure(): bool { return self::ffi()->ssh_bastion_record_auth_failure($this->slot) === 1; }

    /** @throws ProvenError @return int Channel ID. */
    public function openChannel(SshChannelType $chType): int
    {
        return ProvenError::checkSlot(self::ffi()->ssh_bastion_open_channel($this->slot, $chType->value));
    }

    /** @throws ProvenError */
    public function confirmChannel(int $chId): void
    {
        ProvenError::checkStatus(self::ffi()->ssh_bastion_confirm_channel($this->slot, $chId));
    }

    /** @throws ProvenError */
    public function closeChannel(int $chId): void
    {
        ProvenError::checkStatus(self::ffi()->ssh_bastion_close_channel($this->slot, $chId));
    }

    public function channelState(int $chId): ?SshChannelState
    {
        $tag = self::ffi()->ssh_bastion_channel_state($this->slot, $chId);
        return $tag <= 2 ? SshChannelState::from($tag) : null;
    }

    public function channelType(int $chId): ?SshChannelType
    {
        $tag = self::ffi()->ssh_bastion_channel_type($this->slot, $chId);
        return $tag <= 3 ? SshChannelType::from($tag) : null;
    }

    public function channelCount(): int { return self::ffi()->ssh_bastion_channel_count($this->slot); }

    /** @throws ProvenError */
    public function rekey(): void { ProvenError::checkStatus(self::ffi()->ssh_bastion_rekey($this->slot)); }

    /** @throws ProvenError */
    public function disconnect(SshDisconnectReason $reason): void
    {
        ProvenError::checkStatus(self::ffi()->ssh_bastion_disconnect($this->slot, $reason->value));
    }

    public function auditCount(): int { return self::ffi()->ssh_bastion_audit_count($this->slot); }

    public function auditEntryFrom(int $index): ?SshBastionState
    {
        $tag = self::ffi()->ssh_bastion_audit_entry($this->slot, $index);
        return $tag <= 5 ? SshBastionState::from($tag) : null;
    }

    public function auditEntryTo(int $index): ?SshBastionState
    {
        $tag = self::ffi()->ssh_bastion_audit_entry_to($this->slot, $index);
        return $tag <= 5 ? SshBastionState::from($tag) : null;
    }

    /** @throws ProvenError */
    public function setRecording(bool $enabled): void
    {
        ProvenError::checkStatus(self::ffi()->ssh_bastion_set_recording($this->slot, $enabled ? 1 : 0));
    }

    public function isRecording(): bool { return self::ffi()->ssh_bastion_is_recording($this->slot) === 1; }

    public static function abiVersion(): int { return self::ffi()->ssh_bastion_abi_version(); }
    public static function canTransition(SshBastionState $from, SshBastionState $to): bool
    {
        return self::ffi()->ssh_bastion_can_transition($from->value, $to->value) === 1;
    }
}
