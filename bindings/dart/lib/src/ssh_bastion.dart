// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SSH Bastion protocol types for proven-servers.

/// BastionState matching the Idris2 ABI tags.
enum BastionState {
  bastionConnected(0),
  bastionKeyExchanged(1),
  bastionAuthenticated(2),
  bastionChannelOpen(3),
  bastionActive(4),
  bastionClosed(5);

  const BastionState(this.tag);
  final int tag;

  static BastionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// KexMethod matching the Idris2 ABI tags.
enum KexMethod {
  kexCurve25519(0),
  kexDhGroup14(1),
  kexDhGroup16(2),
  kexEcdhP256(3),
  kexEcdhP384(4);

  const KexMethod(this.tag);
  final int tag;

  static KexMethod? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// BastionAuthMethod matching the Idris2 ABI tags.
enum BastionAuthMethod {
  publicKey(0),
  password(1),
  keyboard(2),
  certificate(3);

  const BastionAuthMethod(this.tag);
  final int tag;

  static BastionAuthMethod? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// BastionChannelType matching the Idris2 ABI tags.
enum BastionChannelType {
  session(0),
  directTcpIp(1),
  forwardedTcpIp(2),
  subsystem(3);

  const BastionChannelType(this.tag);
  final int tag;

  static BastionChannelType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// BastionChannelState matching the Idris2 ABI tags.
enum BastionChannelState {
  opening(0),
  channelOpen(1),
  closing(2),
  channelClosed(3);

  const BastionChannelState(this.tag);
  final int tag;

  static BastionChannelState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DisconnectReason matching the Idris2 ABI tags.
enum DisconnectReason {
  hostNotAllowed(0),
  protocolError(1),
  keyExchangeFailed(2),
  authFailed(3),
  serviceNotAvailable(4),
  byApplication(5),
  tooManyConnections(6);

  const DisconnectReason(this.tag);
  final int tag;

  static DisconnectReason? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
