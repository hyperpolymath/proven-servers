<?php

// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Shared exception class for the proven-servers PHP bindings.
//
// Maps the slot-based context pool error pattern used by every Zig FFI
// implementation to PHP exceptions.

declare(strict_types=1);

namespace ProvenServers;

/**
 * Error codes matching the proven-servers Zig FFI status conventions.
 *
 * Every Zig FFI function returns a u8 status:
 *   0 = success
 *   1 = invalid state (wrong lifecycle phase)
 *   2 = validation failed (bad input)
 * Slot-creating functions return c_int: -1 = pool exhausted.
 */
enum ErrorCode: int
{
    /** Context pool exhausted (64-slot limit). */
    case PoolExhausted = -1;
    /** Invalid or inactive context slot. */
    case InvalidSlot = -2;
    /** Operation rejected: wrong lifecycle state. */
    case InvalidState = 1;
    /** Input validation failed. */
    case ValidationFailed = 2;
    /** Parameter value outside valid ABI tag range. */
    case InvalidParameter = 3;
    /** Fixed-size buffer or array capacity exceeded. */
    case CapacityExceeded = 4;
    /** Unknown FFI error. */
    case Unknown = 255;

    /**
     * Get the default human-readable message for this error code.
     */
    public function defaultMessage(): string
    {
        return match ($this) {
            self::PoolExhausted   => 'context pool exhausted (64-slot limit)',
            self::InvalidSlot     => 'invalid or inactive context slot',
            self::InvalidState    => 'operation rejected: wrong lifecycle state',
            self::ValidationFailed => 'input validation failed',
            self::InvalidParameter => 'parameter value outside valid ABI tag range',
            self::CapacityExceeded => 'fixed-size buffer or array capacity exceeded',
            self::Unknown          => 'unknown FFI error',
        };
    }
}

/**
 * Exception thrown by proven-servers FFI wrapper methods.
 */
class ProvenError extends \RuntimeException
{
    /**
     * @param ErrorCode $errorCode The categorised error code.
     * @param int       $rawCode   The raw integer returned by the FFI function.
     * @param string    $message   Optional human-readable message override.
     */
    public function __construct(
        public readonly ErrorCode $errorCode,
        public readonly int $rawCode = 0,
        string $message = '',
    ) {
        $msg = $message !== '' ? $message : $errorCode->defaultMessage();
        parent::__construct($msg, $errorCode->value);
    }

    /**
     * Interpret a slot-returning FFI call (c_int).
     * Returns the slot index for non-negative values.
     *
     * @param int $raw The raw c_int returned by the FFI create function.
     * @return int The valid slot index.
     * @throws self If no free slot is available.
     */
    public static function checkSlot(int $raw): int
    {
        if ($raw >= 0) {
            return $raw;
        }
        throw new self(ErrorCode::PoolExhausted, $raw);
    }

    /**
     * Interpret a status-returning FFI call (u8).
     * 0 = success, 1 = invalid state, 2 = validation failed.
     *
     * @param int $raw The raw u8 status returned by the FFI function.
     * @throws self If the status indicates failure.
     */
    public static function checkStatus(int $raw): void
    {
        if ($raw === 0) {
            return;
        }

        $code = match ($raw) {
            1 => ErrorCode::InvalidState,
            2 => ErrorCode::ValidationFailed,
            3 => ErrorCode::InvalidParameter,
            4 => ErrorCode::CapacityExceeded,
            default => ErrorCode::Unknown,
        };

        throw new self($code, $raw);
    }
}
