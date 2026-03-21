// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file grpc.hpp
/// @brief C++ bindings for proven-grpc.
///
/// RAII wrapper modelling the HTTP/2 stream state machine with flow control.
/// Stream lifecycle: Idle -> Open -> HalfClosed* -> Closed.

#ifndef PROVEN_GRPC_HPP
#define PROVEN_GRPC_HPP

#include "error.hpp"
#include <cstdint>
#include <optional>

extern "C" {
    uint32_t grpc_abi_version();
    int grpc_create(uint8_t compression);
    void grpc_destroy(int slot);
    uint8_t grpc_stream_state(int slot);
    uint8_t grpc_compression(int slot);
    uint8_t grpc_status_code(int slot);
    uint8_t grpc_set_status(int slot, uint8_t status);
    uint32_t grpc_stream_id(int slot);
    uint8_t grpc_send_headers(int slot);
    uint8_t grpc_local_end_stream(int slot);
    uint8_t grpc_remote_end_stream(int slot);
    uint8_t grpc_reset_stream(int slot, uint8_t status);
    uint8_t grpc_close_half_local(int slot);
    uint8_t grpc_close_half_remote(int slot);
    uint8_t grpc_push_promise(int slot);
    uint8_t grpc_reserved_to_half(int slot);
    uint8_t grpc_can_send(int slot);
    uint8_t grpc_can_receive(int slot);
    int32_t grpc_send_window(int slot);
    int32_t grpc_recv_window(int slot);
    uint8_t grpc_update_send_window(int slot, int32_t delta);
    uint8_t grpc_update_recv_window(int slot, int32_t delta);
    uint8_t grpc_can_transition(uint8_t from, uint8_t to);
}

namespace proven {

/// @brief HTTP/2 stream state. Tags match the Idris2 ABI.
enum class GrpcStreamState : uint8_t {
    Idle = 0, Reserved = 1, Open = 2,
    HalfClosedLocal = 3, HalfClosedRemote = 4, Closed = 5
};

/// @brief gRPC compression algorithm.
enum class GrpcCompression : uint8_t {
    None = 0, Gzip = 1, Deflate = 2
};

/// @brief gRPC status code.
enum class GrpcStatusCode : uint8_t {
    Ok = 0, Cancelled = 1, Unknown = 2, InvalidArgument = 3,
    DeadlineExceeded = 4, NotFound = 5, AlreadyExists = 6,
    PermissionDenied = 7, ResourceExhausted = 8, FailedPrecondition = 9,
    Aborted = 10, OutOfRange = 11, Unimplemented = 12,
    Internal = 13, Unavailable = 14, DataLoss = 15, Unauthenticated = 16
};

/// @brief RAII wrapper for a gRPC stream context slot.
class GrpcContext {
public:
    explicit GrpcContext(GrpcCompression compression = GrpcCompression::None)
        : slot_(ProvenError::check_slot(grpc_create(static_cast<uint8_t>(compression)))) {}

    ~GrpcContext() { if (slot_ >= 0) grpc_destroy(slot_); }

    GrpcContext(const GrpcContext&) = delete;
    GrpcContext& operator=(const GrpcContext&) = delete;
    GrpcContext(GrpcContext&& o) noexcept : slot_(o.slot_) { o.slot_ = -1; }
    GrpcContext& operator=(GrpcContext&& o) noexcept {
        if (this != &o) { if (slot_ >= 0) grpc_destroy(slot_); slot_ = o.slot_; o.slot_ = -1; }
        return *this;
    }

    [[nodiscard]] std::optional<GrpcStreamState> stream_state() const {
        uint8_t t = grpc_stream_state(slot_); return t <= 5 ? std::optional{static_cast<GrpcStreamState>(t)} : std::nullopt;
    }

    [[nodiscard]] uint8_t compression() const { return grpc_compression(slot_); }

    [[nodiscard]] std::optional<GrpcStatusCode> status_code() const {
        uint8_t t = grpc_status_code(slot_); return t <= 16 ? std::optional{static_cast<GrpcStatusCode>(t)} : std::nullopt;
    }

    void set_status(GrpcStatusCode status) {
        ProvenError::check_status(grpc_set_status(slot_, static_cast<uint8_t>(status)));
    }

    [[nodiscard]] uint32_t stream_id() const { return grpc_stream_id(slot_); }

    void send_headers() { ProvenError::check_status(grpc_send_headers(slot_)); }
    void local_end_stream() { ProvenError::check_status(grpc_local_end_stream(slot_)); }
    void remote_end_stream() { ProvenError::check_status(grpc_remote_end_stream(slot_)); }

    void reset_stream(GrpcStatusCode status) {
        ProvenError::check_status(grpc_reset_stream(slot_, static_cast<uint8_t>(status)));
    }

    void close_half_local() { ProvenError::check_status(grpc_close_half_local(slot_)); }
    void close_half_remote() { ProvenError::check_status(grpc_close_half_remote(slot_)); }
    void push_promise() { ProvenError::check_status(grpc_push_promise(slot_)); }
    void reserved_to_half() { ProvenError::check_status(grpc_reserved_to_half(slot_)); }

    [[nodiscard]] bool can_send() const { return grpc_can_send(slot_) == 1; }
    [[nodiscard]] bool can_receive() const { return grpc_can_receive(slot_) == 1; }
    [[nodiscard]] int32_t send_window() const { return grpc_send_window(slot_); }
    [[nodiscard]] int32_t recv_window() const { return grpc_recv_window(slot_); }

    void update_send_window(int32_t delta) { ProvenError::check_status(grpc_update_send_window(slot_, delta)); }
    void update_recv_window(int32_t delta) { ProvenError::check_status(grpc_update_recv_window(slot_, delta)); }

    static bool can_transition(GrpcStreamState from, GrpcStreamState to) {
        return grpc_can_transition(static_cast<uint8_t>(from), static_cast<uint8_t>(to)) == 1;
    }

    static uint32_t abi_version() { return grpc_abi_version(); }

private:
    int slot_;
};

} // namespace proven

#endif // PROVEN_GRPC_HPP
