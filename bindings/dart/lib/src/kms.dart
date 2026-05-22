// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// KMS protocol types for proven-servers.

/// ObjectType matching the Idris2 ABI tags.
enum ObjectType {
  symmetricKey(0),
  publicKey(1),
  privateKey(2),
  secretData(3),
  certificate(4),
  opaqueData(5);

  const ObjectType(this.tag);
  final int tag;

  static ObjectType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Operation matching the Idris2 ABI tags.
enum Operation {
  create(0),
  get_(1),
  activate(2),
  revoke(3),
  destroy(4),
  locate(5),
  register(6),
  rekey(7),
  encrypt(8),
  decrypt(9),
  sign(10),
  verify(11),
  wrap(12),
  unwrap(13),
  mac(14);

  const Operation(this.tag);
  final int tag;

  static Operation? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// KeyState matching the Idris2 ABI tags.
enum KeyState {
  preActive(0),
  active(1),
  deactivated(2),
  compromised(3),
  destroyed(4),
  destroyedCompromised(5);

  const KeyState(this.tag);
  final int tag;

  static KeyState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// KmsAlgorithm matching the Idris2 ABI tags.
enum KmsAlgorithm {
  aes128(0),
  aes256(1),
  rsa2048(2),
  rsa4096(3),
  ecdsaP256(4),
  ecdsaP384(5),
  ed25519(6),
  chacha20Poly1305(7),
  hmacSha256(8);

  const KmsAlgorithm(this.tag);
  final int tag;

  static KmsAlgorithm? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
