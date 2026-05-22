// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Modbus protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Modbus protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenModbus {
    private ProvenModbus() {}

    /** FunctionCode (tags 0-9). */
    public enum FunctionCode {
        READ_COILS(0),
        READ_DISCRETE_INPUTS(1),
        READ_HOLDING_REGISTERS(2),
        READ_INPUT_REGISTERS(3),
        WRITE_SINGLE_COIL(4),
        WRITE_SINGLE_REGISTER(5),
        WRITE_MULTIPLE_COILS(6),
        WRITE_MULTIPLE_REGISTERS(7),
        READ_WRITE_MULTIPLE_REGISTERS(8),
        MASK_WRITE_REGISTER(9);

        private final int tag;
        FunctionCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static FunctionCode fromTag(int tag) {
            for (FunctionCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ExceptionCode (tags 0-8). */
    public enum ExceptionCode {
        ILLEGAL_FUNCTION(0),
        ILLEGAL_DATA_ADDRESS(1),
        ILLEGAL_DATA_VALUE(2),
        SLAVE_DEVICE_FAILURE(3),
        ACKNOWLEDGE(4),
        SLAVE_DEVICE_BUSY(5),
        MEMORY_PARITY_ERROR(6),
        GATEWAY_PATH_UNAVAILABLE(7),
        GATEWAY_TARGET_DEVICE_FAILED(8);

        private final int tag;
        ExceptionCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ExceptionCode fromTag(int tag) {
            for (ExceptionCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DeviceRole (tags 0-1). */
    public enum DeviceRole {
        MASTER(0),
        SLAVE(1);

        private final int tag;
        DeviceRole(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DeviceRole fromTag(int tag) {
            for (DeviceRole v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** GatewayState (tags 0-4). */
    public enum GatewayState {
        IDLE(0),
        LISTENING(1),
        PROCESSING(2),
        ERROR(3),
        STOPPING(4);

        private final int tag;
        GatewayState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static GatewayState fromTag(int tag) {
            for (GatewayState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
