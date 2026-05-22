// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file ldp.hpp
/// @brief LDP protocol types for proven-servers.

#ifndef PROVEN_LDP_HPP
#define PROVEN_LDP_HPP

#include <cstdint>

namespace proven {

/// @brief ContainerType matching the Idris2 ABI tags.
enum class ContainerType : uint8_t {
    Basic = 0,
    Direct = 1,
    Indirect = 2
};

/// @brief LdpResourceType matching the Idris2 ABI tags.
enum class LdpResourceType : uint8_t {
    RdfSource = 0,
    NonRdfSource = 1,
    Container = 2
};

/// @brief Preference matching the Idris2 ABI tags.
enum class Preference : uint8_t {
    MinimalContainer = 0,
    IncludeContainment = 1,
    IncludeMembership = 2,
    OmitContainment = 3,
    OmitMembership = 4
};

/// @brief InteractionModel matching the Idris2 ABI tags.
enum class InteractionModel : uint8_t {
    Ldpr = 0,
    Ldpc = 1,
    LdpBasicContainer = 2,
    LdpDirectContainer = 3,
    LdpIndirectContainer = 4
};

/// @brief ConstraintViolation matching the Idris2 ABI tags.
enum class ConstraintViolation : uint8_t {
    MembershipConstant = 0,
    ContainsTriplesModified = 1,
    ServerManaged = 2,
    TypeConflict = 3
};

} // namespace proven

#endif // PROVEN_LDP_HPP
