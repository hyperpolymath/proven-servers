<?php

// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PHP bindings for the proven-grpc Zig FFI.

declare(strict_types=1);

namespace ProvenServers;

/** HTTP/2 stream states matching Idris2 ABI tags. */
enum GrpcStreamState: int
{
    case Idle             = 0;
    case Reserved         = 1;
    case Open             = 2;
    case HalfClosedLocal  = 3;
    case HalfClosedRemote = 4;
    case Closed           = 5;
}

/** gRPC compression algorithms matching Idris2 ABI tags. */
enum GrpcCompression: int
{
    case None    = 0;
    case Gzip    = 1;
    case Deflate = 2;
    case Snappy  = 3;
    case Zstd    = 4;
}

/** gRPC status codes matching Idris2 ABI tags. */
enum GrpcStatusCode: int
{
    case OK                 = 0;
    case Cancelled          = 1;
    case Unknown            = 2;
    case InvalidArgument    = 3;
    case DeadlineExceeded   = 4;
    case NotFound           = 5;
    case AlreadyExists      = 6;
    case PermissionDenied   = 7;
    case ResourceExhausted  = 8;
    case FailedPrecondition = 9;
    case Aborted            = 10;
    case OutOfRange         = 11;
    case Unimplemented      = 12;
    case Internal           = 13;
    case Unavailable        = 14;
    case DataLoss           = 15;
    case Unauthenticated    = 16;
}

/**
 * gRPC stream context wrapping a Zig FFI slot.
 */
final class ProvenGrpc
{
    private const CDEF = <<<'CDEF'
    int grpc_create(uint8_t compression);
    void grpc_destroy(int slot);
    uint8_t grpc_stream_state(int slot);
    uint8_t grpc_compression(int slot);
    uint8_t grpc_status_code(int slot);
    uint32_t grpc_stream_id(int slot);
    uint8_t grpc_can_send(int slot);
    uint8_t grpc_can_receive(int slot);
    uint32_t grpc_send_window(int slot);
    uint32_t grpc_recv_window(int slot);
    uint8_t grpc_set_status(int slot, uint8_t status);
    uint8_t grpc_send_headers(int slot);
    uint8_t grpc_local_end_stream(int slot);
    uint8_t grpc_remote_end_stream(int slot);
    uint8_t grpc_reset_stream(int slot, uint8_t status);
    uint8_t grpc_close_half_local(int slot);
    uint8_t grpc_close_half_remote(int slot);
    uint8_t grpc_push_promise(int slot);
    uint8_t grpc_reserved_to_half(int slot);
    uint8_t grpc_update_send_window(int slot, int32_t delta);
    uint8_t grpc_update_recv_window(int slot, int32_t delta);
    uint32_t grpc_abi_version(void);
    uint8_t grpc_can_transition(uint8_t from, uint8_t to);
    CDEF;

    private static ?\FFI $ffi = null;
    private int $slot;
    private bool $destroyed = false;

    private function __construct(int $slot) { $this->slot = $slot; }

    private static function ffi(): \FFI
    {
        if (self::$ffi === null) {
            self::$ffi = ProvenServers::loadLibrary('grpc', self::CDEF);
        }
        return self::$ffi;
    }

    /** @throws ProvenError */
    public static function create(GrpcCompression $compression = GrpcCompression::None): self
    {
        return new self(ProvenError::checkSlot(self::ffi()->grpc_create($compression->value)));
    }

    public function destroy(): void
    {
        if (!$this->destroyed) {
            self::ffi()->grpc_destroy($this->slot);
            $this->destroyed = true;
        }
    }

    public function streamState(): ?GrpcStreamState
    {
        $tag = self::ffi()->grpc_stream_state($this->slot);
        return $tag <= 5 ? GrpcStreamState::from($tag) : null;
    }

    public function compression(): int { return self::ffi()->grpc_compression($this->slot); }

    public function statusCode(): ?GrpcStatusCode
    {
        $tag = self::ffi()->grpc_status_code($this->slot);
        return $tag <= 16 ? GrpcStatusCode::from($tag) : null;
    }

    public function streamId(): int { return self::ffi()->grpc_stream_id($this->slot); }
    public function canSend(): bool { return self::ffi()->grpc_can_send($this->slot) === 1; }
    public function canReceive(): bool { return self::ffi()->grpc_can_receive($this->slot) === 1; }
    public function sendWindow(): int { return self::ffi()->grpc_send_window($this->slot); }
    public function recvWindow(): int { return self::ffi()->grpc_recv_window($this->slot); }

    /** @throws ProvenError */
    public function setStatus(GrpcStatusCode $status): void
    {
        ProvenError::checkStatus(self::ffi()->grpc_set_status($this->slot, $status->value));
    }

    /** @throws ProvenError */
    public function sendHeaders(): void { ProvenError::checkStatus(self::ffi()->grpc_send_headers($this->slot)); }
    /** @throws ProvenError */
    public function localEndStream(): void { ProvenError::checkStatus(self::ffi()->grpc_local_end_stream($this->slot)); }
    /** @throws ProvenError */
    public function remoteEndStream(): void { ProvenError::checkStatus(self::ffi()->grpc_remote_end_stream($this->slot)); }

    /** @throws ProvenError */
    public function resetStream(GrpcStatusCode $status): void
    {
        ProvenError::checkStatus(self::ffi()->grpc_reset_stream($this->slot, $status->value));
    }

    /** @throws ProvenError */
    public function closeHalfLocal(): void { ProvenError::checkStatus(self::ffi()->grpc_close_half_local($this->slot)); }
    /** @throws ProvenError */
    public function closeHalfRemote(): void { ProvenError::checkStatus(self::ffi()->grpc_close_half_remote($this->slot)); }
    /** @throws ProvenError */
    public function pushPromise(): void { ProvenError::checkStatus(self::ffi()->grpc_push_promise($this->slot)); }
    /** @throws ProvenError */
    public function reservedToHalf(): void { ProvenError::checkStatus(self::ffi()->grpc_reserved_to_half($this->slot)); }

    /** @throws ProvenError */
    public function updateSendWindow(int $delta): void
    {
        ProvenError::checkStatus(self::ffi()->grpc_update_send_window($this->slot, $delta));
    }

    /** @throws ProvenError */
    public function updateRecvWindow(int $delta): void
    {
        ProvenError::checkStatus(self::ffi()->grpc_update_recv_window($this->slot, $delta));
    }

    public static function abiVersion(): int { return self::ffi()->grpc_abi_version(); }
    public static function canTransition(GrpcStreamState $from, GrpcStreamState $to): bool
    {
        return self::ffi()->grpc_can_transition($from->value, $to->value) === 1;
    }
}
