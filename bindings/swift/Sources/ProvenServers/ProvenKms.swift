// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// KMS protocol types for proven-servers.

/// ObjectType matching the Idris2 ABI tags.
public enum ObjectType: UInt8, CaseIterable, Sendable {
    case symmetricKey = 0
    case publicKey = 1
    case privateKey = 2
    case secretData = 3
    case certificate = 4
    case opaqueData = 5
}

/// Operation matching the Idris2 ABI tags.
public enum Operation: UInt8, CaseIterable, Sendable {
    case create = 0
    case get = 1
    case activate = 2
    case revoke = 3
    case destroy = 4
    case locate = 5
    case register = 6
    case rekey = 7
    case encrypt = 8
    case decrypt = 9
    case sign = 10
    case verify = 11
    case wrap = 12
    case unwrap = 13
    case mac = 14
}

/// KeyState matching the Idris2 ABI tags.
public enum KeyState: UInt8, CaseIterable, Sendable {
    case preActive = 0
    case active = 1
    case deactivated = 2
    case compromised = 3
    case destroyed = 4
    case destroyedCompromised = 5
}

/// KmsAlgorithm matching the Idris2 ABI tags.
public enum KmsAlgorithm: UInt8, CaseIterable, Sendable {
    case aes128 = 0
    case aes256 = 1
    case rsa2048 = 2
    case rsa4096 = 3
    case ecdsaP256 = 4
    case ecdsaP384 = 5
    case ed25519 = 6
    case chacha20Poly1305 = 7
    case hmacSha256 = 8
}
