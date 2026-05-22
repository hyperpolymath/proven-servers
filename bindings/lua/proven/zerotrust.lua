-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Zero Trust protocol types for proven-servers.

local M = {}

--- PolicyType matching the Idris2 ABI tags.
M.PolicyType = {
    ALWAYS_VERIFY = 0,
    NEVER_TRUST = 1,
    LEAST_PRIVILEGE = 2,
    MICRO_SEGMENTATION = 3,
}

--- IdentityConfidence matching the Idris2 ABI tags.
M.IdentityConfidence = {
    UNVERIFIED = 0,
    BASIC_AUTH = 1,
    MFA_VERIFIED = 2,
    STRONG_AUTH = 3,
    CONTINUOUS_AUTH = 4,
}

--- DeviceTrustScore matching the Idris2 ABI tags.
M.DeviceTrustScore = {
    DEVICE_UNKNOWN = 0,
    DEVICE_PARTIAL = 1,
    DEVICE_COMPLIANT = 2,
    DEVICE_MANAGED = 3,
    DEVICE_HARDENED = 4,
}

--- AccessDecision matching the Idris2 ABI tags.
M.AccessDecision = {
    ALLOW = 0,
    DENY = 1,
    CHALLENGE = 2,
    STEP_UP = 3,
}

--- ContextSignalKind matching the Idris2 ABI tags.
M.ContextSignalKind = {
    LOCATION = 0,
    TIME = 1,
    DEVICE = 2,
    BEHAVIOR = 3,
    NETWORK = 4,
}

--- AuthFactor matching the Idris2 ABI tags.
M.AuthFactor = {
    CERTIFICATE = 0,
    TOKEN = 1,
    BIOMETRIC = 2,
    FIDO2 = 3,
    TOTP = 4,
    PUSH = 5,
}

return M
