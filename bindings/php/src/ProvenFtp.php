<?php

// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PHP bindings for the proven-ftp Zig FFI.

declare(strict_types=1);

namespace ProvenServers;

/** FTP session states matching Idris2 ABI tags. */
enum FtpSessionState: int
{
    case Connected     = 0;
    case UserOk        = 1;
    case Authenticated = 2;
    case Renaming      = 3;
    case Quit          = 4;
}

/** FTP transfer states matching Idris2 ABI tags. */
enum FtpTransferState: int
{
    case Idle       = 0;
    case InProgress = 1;
    case Completed  = 2;
    case Aborted    = 3;
}

/**
 * FTP session context wrapping a Zig FFI slot.
 */
final class ProvenFtp
{
    private const CDEF = <<<'CDEF'
    int ftp_create(void);
    void ftp_destroy(int slot);
    uint8_t ftp_state(int slot);
    uint8_t ftp_transfer_type(int slot);
    uint8_t ftp_data_mode(int slot);
    uint8_t ftp_transfer_state(int slot);
    uint64_t ftp_bytes_transferred(int slot);
    uint32_t ftp_file_count(int slot);
    uint16_t ftp_last_reply_code(int slot);
    uint32_t ftp_cwd(int slot, uint8_t *buf, uint32_t max_len);
    uint8_t ftp_user(int slot, const uint8_t *name, uint32_t len);
    uint8_t ftp_pass(int slot, const uint8_t *pass, uint32_t len);
    uint8_t ftp_quit(int slot);
    uint8_t ftp_cwd_cmd(int slot, const uint8_t *path, uint32_t len);
    uint8_t ftp_cdup(int slot);
    uint8_t ftp_set_type(int slot, uint8_t type_tag);
    uint8_t ftp_set_passive(int slot);
    uint8_t ftp_set_active(int slot, uint16_t port);
    uint8_t ftp_begin_transfer(int slot);
    uint8_t ftp_add_bytes(int slot, uint64_t count);
    uint8_t ftp_complete_transfer(int slot);
    uint8_t ftp_abort_transfer(int slot);
    uint8_t ftp_begin_rename(int slot);
    uint8_t ftp_complete_rename(int slot);
    uint32_t ftp_abi_version(void);
    uint8_t ftp_can_transfer(uint8_t state_tag);
    uint8_t ftp_can_transition(uint8_t from, uint8_t to);
    CDEF;

    private static ?\FFI $ffi = null;
    private int $slot;
    private bool $destroyed = false;

    private function __construct(int $slot) { $this->slot = $slot; }

    private static function ffi(): \FFI
    {
        if (self::$ffi === null) {
            self::$ffi = ProvenServers::loadLibrary('ftp', self::CDEF);
        }
        return self::$ffi;
    }

    /** @throws ProvenError */
    public static function create(): self
    {
        return new self(ProvenError::checkSlot(self::ffi()->ftp_create()));
    }

    public function destroy(): void
    {
        if (!$this->destroyed) {
            self::ffi()->ftp_destroy($this->slot);
            $this->destroyed = true;
        }
    }

    public function state(): ?FtpSessionState
    {
        $tag = self::ffi()->ftp_state($this->slot);
        return $tag <= 4 ? FtpSessionState::from($tag) : null;
    }

    public function transferType(): int { return self::ffi()->ftp_transfer_type($this->slot); }
    public function dataMode(): int { return self::ffi()->ftp_data_mode($this->slot); }
    public function bytesTransferred(): int { return self::ffi()->ftp_bytes_transferred($this->slot); }
    public function fileCount(): int { return self::ffi()->ftp_file_count($this->slot); }
    public function lastReplyCode(): int { return self::ffi()->ftp_last_reply_code($this->slot); }

    public function transferState(): ?FtpTransferState
    {
        $tag = self::ffi()->ftp_transfer_state($this->slot);
        return $tag <= 3 ? FtpTransferState::from($tag) : null;
    }

    /** @param int $maxLen @return string */
    public function cwd(int $maxLen = 4096): string
    {
        $buf = \FFI::new("uint8_t[{$maxLen}]");
        $written = self::ffi()->ftp_cwd($this->slot, $buf, $maxLen);
        return \FFI::string($buf, $written);
    }

    /** @throws ProvenError */
    public function user(string $name): void
    {
        ProvenError::checkStatus(self::ffi()->ftp_user($this->slot, $name, strlen($name)));
    }

    /** @throws ProvenError */
    public function pass(string $password): void
    {
        ProvenError::checkStatus(self::ffi()->ftp_pass($this->slot, $password, strlen($password)));
    }

    /** @throws ProvenError */
    public function quitSession(): void { ProvenError::checkStatus(self::ffi()->ftp_quit($this->slot)); }

    /** @throws ProvenError */
    public function changeDir(string $path): void
    {
        ProvenError::checkStatus(self::ffi()->ftp_cwd_cmd($this->slot, $path, strlen($path)));
    }

    /** @throws ProvenError */
    public function changeDirUp(): void { ProvenError::checkStatus(self::ffi()->ftp_cdup($this->slot)); }

    /** @param int $typeTag 0=ASCII, 1=binary @throws ProvenError */
    public function setType(int $typeTag): void
    {
        ProvenError::checkStatus(self::ffi()->ftp_set_type($this->slot, $typeTag));
    }

    /** @throws ProvenError */
    public function setPassive(): void { ProvenError::checkStatus(self::ffi()->ftp_set_passive($this->slot)); }

    /** @throws ProvenError */
    public function setActive(int $port): void
    {
        ProvenError::checkStatus(self::ffi()->ftp_set_active($this->slot, $port));
    }

    /** @throws ProvenError */
    public function beginTransfer(): void { ProvenError::checkStatus(self::ffi()->ftp_begin_transfer($this->slot)); }
    /** @throws ProvenError */
    public function addBytes(int $count): void { ProvenError::checkStatus(self::ffi()->ftp_add_bytes($this->slot, $count)); }
    /** @throws ProvenError */
    public function completeTransfer(): void { ProvenError::checkStatus(self::ffi()->ftp_complete_transfer($this->slot)); }
    /** @throws ProvenError */
    public function abortTransfer(): void { ProvenError::checkStatus(self::ffi()->ftp_abort_transfer($this->slot)); }
    /** @throws ProvenError */
    public function beginRename(): void { ProvenError::checkStatus(self::ffi()->ftp_begin_rename($this->slot)); }
    /** @throws ProvenError */
    public function completeRename(): void { ProvenError::checkStatus(self::ffi()->ftp_complete_rename($this->slot)); }

    public static function abiVersion(): int { return self::ffi()->ftp_abi_version(); }
    public static function canTransfer(FtpSessionState $state): bool
    {
        return self::ffi()->ftp_can_transfer($state->value) === 1;
    }
    public static function canTransition(FtpSessionState $from, FtpSessionState $to): bool
    {
        return self::ffi()->ftp_can_transition($from->value, $to->value) === 1;
    }
}
