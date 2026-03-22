// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LDP protocol types for proven-servers.

/// ContainerType matching the Idris2 ABI tags.
enum ContainerType {
  basic(0),
  direct(1),
  indirect(2);

  const ContainerType(this.tag);
  final int tag;

  static ContainerType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// LdpResourceType matching the Idris2 ABI tags.
enum LdpResourceType {
  rdfSource(0),
  nonRdfSource(1),
  container(2);

  const LdpResourceType(this.tag);
  final int tag;

  static LdpResourceType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Preference matching the Idris2 ABI tags.
enum Preference {
  minimalContainer(0),
  includeContainment(1),
  includeMembership(2),
  omitContainment(3),
  omitMembership(4);

  const Preference(this.tag);
  final int tag;

  static Preference? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// InteractionModel matching the Idris2 ABI tags.
enum InteractionModel {
  ldpr(0),
  ldpc(1),
  ldpBasicContainer(2),
  ldpDirectContainer(3),
  ldpIndirectContainer(4);

  const InteractionModel(this.tag);
  final int tag;

  static InteractionModel? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ConstraintViolation matching the Idris2 ABI tags.
enum ConstraintViolation {
  membershipConstant(0),
  containsTriplesModified(1),
  serverManaged(2),
  typeConflict(3);

  const ConstraintViolation(this.tag);
  final int tag;

  static ConstraintViolation? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
