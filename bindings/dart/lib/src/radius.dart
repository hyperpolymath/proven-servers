// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// RADIUS protocol types for proven-servers.

/// PacketType matching the Idris2 ABI tags.
enum PacketType {
  accessRequest(1),
  accessAccept(2),
  accessReject(3),
  accountingRequest(4),
  accountingResponse(5),
  accessChallenge(11);

  const PacketType(this.tag);
  final int tag;

  static PacketType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AttributeType matching the Idris2 ABI tags.
enum AttributeType {
  userName(1),
  userPassword(2),
  nasIpAddress(4),
  nasPort(5),
  serviceType(6),
  framedProtocol(7),
  framedIpAddress(8),
  replyMessage(18),
  sessionTimeout(27);

  const AttributeType(this.tag);
  final int tag;

  static AttributeType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ServiceType matching the Idris2 ABI tags.
enum ServiceType {
  login(1),
  framed(2),
  callbackLogin(3),
  callbackFramed(4),
  outbound(5),
  administrative(6);

  const ServiceType(this.tag);
  final int tag;

  static ServiceType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AuthMethod matching the Idris2 ABI tags.
enum AuthMethod {
  pap(0),
  chap(1),
  mschap(2),
  mschapv2(3),
  eap(4);

  const AuthMethod(this.tag);
  final int tag;

  static AuthMethod? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SessionState matching the Idris2 ABI tags.
enum SessionState {
  idle(0),
  authenticating(1),
  authorized(2),
  rejected(3),
  challenged(4),
  accounting(5),
  complete(6);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// RadiusResult matching the Idris2 ABI tags.
enum RadiusResult {
  ok(0),
  err(1),
  invalidParam(2),
  poolExhausted(3),
  badSecret(4);

  const RadiusResult(this.tag);
  final int tag;

  static RadiusResult? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
