<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LDP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** ContainerType matching the Idris2 ABI tags. */
enum ContainerType: int
{
    case Basic = 0;
    case Direct = 1;
    case Indirect = 2;
}

/** LdpResourceType matching the Idris2 ABI tags. */
enum LdpResourceType: int
{
    case RdfSource = 0;
    case NonRdfSource = 1;
    case Container = 2;
}

/** Preference matching the Idris2 ABI tags. */
enum Preference: int
{
    case MinimalContainer = 0;
    case IncludeContainment = 1;
    case IncludeMembership = 2;
    case OmitContainment = 3;
    case OmitMembership = 4;
}

/** InteractionModel matching the Idris2 ABI tags. */
enum InteractionModel: int
{
    case Ldpr = 0;
    case Ldpc = 1;
    case LdpBasicContainer = 2;
    case LdpDirectContainer = 3;
    case LdpIndirectContainer = 4;
}

/** ConstraintViolation matching the Idris2 ABI tags. */
enum ConstraintViolation: int
{
    case MembershipConstant = 0;
    case ContainsTriplesModified = 1;
    case ServerManaged = 2;
    case TypeConflict = 3;
}
