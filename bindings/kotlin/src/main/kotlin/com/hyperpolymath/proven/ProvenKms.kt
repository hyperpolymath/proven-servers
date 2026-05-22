// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// KMS protocol types for proven-servers.

package com.hyperpolymath.proven

/** ObjectType matching the Idris2 ABI tags. */
enum class ObjectType(val tag: Int) {
    SYMMETRIC_KEY(0),
    PUBLIC_KEY(1),
    PRIVATE_KEY(2),
    SECRET_DATA(3),
    CERTIFICATE(4),
    OPAQUE_DATA(5);

    companion object {
        fun fromTag(tag: Int): ObjectType? = entries.find { it.tag == tag }
    }
}

/** Operation matching the Idris2 ABI tags. */
enum class Operation(val tag: Int) {
    CREATE(0),
    GET(1),
    ACTIVATE(2),
    REVOKE(3),
    DESTROY(4),
    LOCATE(5),
    REGISTER(6),
    REKEY(7),
    ENCRYPT(8),
    DECRYPT(9),
    SIGN(10),
    VERIFY(11),
    WRAP(12),
    UNWRAP(13),
    MAC(14);

    companion object {
        fun fromTag(tag: Int): Operation? = entries.find { it.tag == tag }
    }
}

/** KeyState matching the Idris2 ABI tags. */
enum class KeyState(val tag: Int) {
    PRE_ACTIVE(0),
    ACTIVE(1),
    DEACTIVATED(2),
    COMPROMISED(3),
    DESTROYED(4),
    DESTROYED_COMPROMISED(5);

    companion object {
        fun fromTag(tag: Int): KeyState? = entries.find { it.tag == tag }
    }
}

/** KmsAlgorithm matching the Idris2 ABI tags. */
enum class KmsAlgorithm(val tag: Int) {
    AES128(0),
    AES256(1),
    RSA2048(2),
    RSA4096(3),
    ECDSA_P256(4),
    ECDSA_P384(5),
    ED25519(6),
    CHACHA20_POLY1305(7),
    HMAC_SHA256(8);

    companion object {
        fun fromTag(tag: Int): KmsAlgorithm? = entries.find { it.tag == tag }
    }
}
