# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Modbus protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Modbus protocol types for proven-servers.
  module Modbus
    # FunctionCode matching the Idris2 ABI tags.
    module FunctionCode
      READ_COILS = 0
      READ_DISCRETE_INPUTS = 1
      READ_HOLDING_REGISTERS = 2
      READ_INPUT_REGISTERS = 3
      WRITE_SINGLE_COIL = 4
      WRITE_SINGLE_REGISTER = 5
      WRITE_MULTIPLE_COILS = 6
      WRITE_MULTIPLE_REGISTERS = 7
      READ_WRITE_MULTIPLE_REGISTERS = 8
      MASK_WRITE_REGISTER = 9
    end

    # ExceptionCode matching the Idris2 ABI tags.
    module ExceptionCode
      ILLEGAL_FUNCTION = 0
      ILLEGAL_DATA_ADDRESS = 1
      ILLEGAL_DATA_VALUE = 2
      SLAVE_DEVICE_FAILURE = 3
      ACKNOWLEDGE = 4
      SLAVE_DEVICE_BUSY = 5
      MEMORY_PARITY_ERROR = 6
      GATEWAY_PATH_UNAVAILABLE = 7
      GATEWAY_TARGET_DEVICE_FAILED = 8
    end

    # DeviceRole matching the Idris2 ABI tags.
    module DeviceRole
      MASTER = 0
      SLAVE = 1
    end

    # GatewayState matching the Idris2 ABI tags.
    module GatewayState
      IDLE = 0
      LISTENING = 1
      PROCESSING = 2
      ERROR = 3
      STOPPING = 4
    end

  end
end
