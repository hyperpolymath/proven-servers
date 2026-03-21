# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Shared error class for the proven-servers Ruby bindings.
#
# Maps the slot-based context pool error pattern used by every Zig FFI
# implementation to Ruby exceptions. All protocol modules raise
# ProvenError with an appropriate error code.

# frozen_string_literal: true

module ProvenServers
  # Error codes matching the proven-servers Zig FFI status conventions.
  #
  # Every Zig FFI function returns a u8 status:
  #   0 = success
  #   1 = invalid state (wrong lifecycle phase)
  #   2 = validation failed (bad input)
  # Slot-creating functions return c_int: -1 = pool exhausted.
  module ErrorCode
    # Context pool exhausted (64-slot limit).
    POOL_EXHAUSTED = -1
    # Invalid or inactive context slot.
    INVALID_SLOT = -2
    # Operation rejected: wrong lifecycle state.
    INVALID_STATE = 1
    # Input validation failed.
    VALIDATION_FAILED = 2
    # Parameter value outside valid ABI tag range.
    INVALID_PARAMETER = 3
    # Fixed-size buffer or array capacity exceeded.
    CAPACITY_EXCEEDED = 4
    # Unknown FFI error.
    UNKNOWN = 255
  end

  # Default human-readable messages for each error code.
  ERROR_MESSAGES = {
    ErrorCode::POOL_EXHAUSTED   => "context pool exhausted (64-slot limit)",
    ErrorCode::INVALID_SLOT     => "invalid or inactive context slot",
    ErrorCode::INVALID_STATE    => "operation rejected: wrong lifecycle state",
    ErrorCode::VALIDATION_FAILED => "input validation failed",
    ErrorCode::INVALID_PARAMETER => "parameter value outside valid ABI tag range",
    ErrorCode::CAPACITY_EXCEEDED => "fixed-size buffer or array capacity exceeded",
    ErrorCode::UNKNOWN           => "unknown FFI error",
  }.freeze

  # Exception thrown by proven-servers FFI wrapper methods.
  #
  # @example
  #   begin
  #     ctx.send_response
  #   rescue ProvenServers::ProvenError => e
  #     puts "FFI error #{e.code}: #{e.message}"
  #   end
  class ProvenError < StandardError
    # @return [Integer] the ErrorCode describing the failure category
    attr_reader :code

    # @return [Integer] the raw integer returned by the FFI function
    attr_reader :raw_code

    # @param code [Integer] the ErrorCode describing the failure category
    # @param raw_code [Integer] the raw integer returned by the FFI function
    # @param message [String, nil] optional human-readable message override
    def initialize(code, raw_code = 0, message = nil)
      @code = code
      @raw_code = raw_code
      msg = message || ERROR_MESSAGES[code] || "unknown FFI error (code #{raw_code})"
      super(msg)
    end
  end

  # Interpret a slot-returning FFI call (c_int).
  # Returns the slot index for non-negative values.
  #
  # @param raw [Integer] the raw c_int returned by the FFI create function
  # @return [Integer] the valid slot index
  # @raise [ProvenError] if no free slot is available
  def self.check_slot(raw)
    return raw if raw >= 0

    raise ProvenError.new(ErrorCode::POOL_EXHAUSTED, raw)
  end

  # Interpret a status-returning FFI call (u8).
  # 0 = success, 1 = invalid state, 2 = validation failed.
  #
  # @param raw [Integer] the raw u8 status returned by the FFI function
  # @raise [ProvenError] if the status indicates failure
  def self.check_status(raw)
    return if raw == 0

    status_map = {
      1 => ErrorCode::INVALID_STATE,
      2 => ErrorCode::VALIDATION_FAILED,
      3 => ErrorCode::INVALID_PARAMETER,
      4 => ErrorCode::CAPACITY_EXCEEDED,
    }
    code = status_map.fetch(raw, ErrorCode::UNKNOWN)
    raise ProvenError.new(code, raw)
  end
end
