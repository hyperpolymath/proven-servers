// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file error.hpp
/// @brief Unified error type for proven-servers C++ bindings.
///
/// Maps the C-ABI return codes (slot=-1 for pool exhaustion, status!=0 for
/// state/validation errors) to a C++ exception hierarchy.

#ifndef PROVEN_ERROR_HPP
#define PROVEN_ERROR_HPP

#include <cstdint>
#include <stdexcept>
#include <string>

namespace proven {

/// @brief Error category codes matching the Rust ProvenError variants.
enum class ErrorKind : uint8_t {
    PoolExhausted = 0,    ///< All 64 context slots are in use.
    InvalidSlot = 1,      ///< Slot index is invalid or inactive.
    InvalidState = 2,     ///< Wrong lifecycle state for the operation.
    InvalidParameter = 3, ///< Parameter outside valid ABI tag range.
    CapacityExceeded = 4, ///< Fixed-size buffer/array limit exceeded.
    ValidationFailed = 5, ///< Input validation failed.
    Unknown = 6,          ///< Undocumented FFI return code.
};

/// @brief Exception class for all proven-servers FFI errors.
///
/// Inherits from std::runtime_error and carries an ErrorKind plus the
/// raw FFI return code for diagnostic purposes.
class ProvenError : public std::runtime_error {
public:
    /// @brief Construct a ProvenError with a kind and raw code.
    explicit ProvenError(ErrorKind kind, int code = 0)
        : std::runtime_error(make_message(kind, code))
        , kind_(kind)
        , code_(code) {}

    /// @brief Get the error category.
    [[nodiscard]] ErrorKind kind() const noexcept { return kind_; }

    /// @brief Get the raw FFI return code.
    [[nodiscard]] int code() const noexcept { return code_; }

    /// @brief Interpret a slot-returning FFI call.
    /// @param raw The raw return value from a slot-creating FFI function.
    /// @return The slot index (non-negative).
    /// @throws ProvenError if raw < 0 (pool exhausted).
    static int check_slot(int raw) {
        if (raw >= 0) return raw;
        throw ProvenError(ErrorKind::PoolExhausted, raw);
    }

    /// @brief Interpret a status-returning FFI call (0=success).
    /// @param raw The raw return value from a status-returning FFI function.
    /// @throws ProvenError if raw != 0.
    static void check_status(uint8_t raw) {
        if (raw == 0) return;
        switch (raw) {
            case 1: throw ProvenError(ErrorKind::InvalidState, 1);
            case 2: throw ProvenError(ErrorKind::ValidationFailed, 2);
            default: throw ProvenError(ErrorKind::Unknown, static_cast<int>(raw));
        }
    }

private:
    ErrorKind kind_;
    int code_;

    static std::string make_message(ErrorKind kind, int code) {
        switch (kind) {
            case ErrorKind::PoolExhausted:
                return "proven: context pool exhausted (64-slot limit)";
            case ErrorKind::InvalidSlot:
                return "proven: invalid or inactive context slot";
            case ErrorKind::InvalidState:
                return "proven: operation rejected: wrong lifecycle state";
            case ErrorKind::InvalidParameter:
                return "proven: parameter value outside valid ABI tag range";
            case ErrorKind::CapacityExceeded:
                return "proven: fixed-size buffer or array capacity exceeded";
            case ErrorKind::ValidationFailed:
                return "proven: input validation failed";
            case ErrorKind::Unknown:
                return "proven: unknown FFI error (code " + std::to_string(code) + ")";
        }
        return "proven: error (code " + std::to_string(code) + ")";
    }
};

} // namespace proven

#endif // PROVEN_ERROR_HPP
