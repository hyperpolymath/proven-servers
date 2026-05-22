// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LDP protocol types for proven-servers.

namespace Proven;

/// <summary>ContainerType matching the Idris2 ABI tags (0-2).</summary>
public enum ContainerType : byte
{
    Basic = 0,
    Direct = 1,
    Indirect = 2
}

/// <summary>LdpResourceType matching the Idris2 ABI tags (0-2).</summary>
public enum LdpResourceType : byte
{
    RdfSource = 0,
    NonRdfSource = 1,
    Container = 2
}

/// <summary>Preference matching the Idris2 ABI tags (0-4).</summary>
public enum Preference : byte
{
    MinimalContainer = 0,
    IncludeContainment = 1,
    IncludeMembership = 2,
    OmitContainment = 3,
    OmitMembership = 4
}

/// <summary>InteractionModel matching the Idris2 ABI tags (0-4).</summary>
public enum InteractionModel : byte
{
    Ldpr = 0,
    Ldpc = 1,
    LdpBasicContainer = 2,
    LdpDirectContainer = 3,
    LdpIndirectContainer = 4
}

/// <summary>ConstraintViolation matching the Idris2 ABI tags (0-3).</summary>
public enum ConstraintViolation : byte
{
    MembershipConstant = 0,
    ContainsTriplesModified = 1,
    ServerManaged = 2,
    TypeConflict = 3
}
