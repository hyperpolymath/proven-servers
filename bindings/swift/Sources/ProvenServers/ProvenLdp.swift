// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LDP protocol types for proven-servers.

/// ContainerType matching the Idris2 ABI tags.
public enum ContainerType: UInt8, CaseIterable, Sendable {
    case basic = 0
    case direct = 1
    case indirect = 2
}

/// LdpResourceType matching the Idris2 ABI tags.
public enum LdpResourceType: UInt8, CaseIterable, Sendable {
    case rdfSource = 0
    case nonRdfSource = 1
    case container = 2
}

/// Preference matching the Idris2 ABI tags.
public enum Preference: UInt8, CaseIterable, Sendable {
    case minimalContainer = 0
    case includeContainment = 1
    case includeMembership = 2
    case omitContainment = 3
    case omitMembership = 4
}

/// InteractionModel matching the Idris2 ABI tags.
public enum InteractionModel: UInt8, CaseIterable, Sendable {
    case ldpr = 0
    case ldpc = 1
    case ldpBasicContainer = 2
    case ldpDirectContainer = 3
    case ldpIndirectContainer = 4
}

/// ConstraintViolation matching the Idris2 ABI tags.
public enum ConstraintViolation: UInt8, CaseIterable, Sendable {
    case membershipConstant = 0
    case containsTriplesModified = 1
    case serverManaged = 2
    case typeConflict = 3
}
