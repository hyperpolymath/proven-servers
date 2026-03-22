// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file semweb.hpp
/// @brief Semantic Web protocol types for proven-servers.

#ifndef PROVEN_SEMWEB_HPP
#define PROVEN_SEMWEB_HPP

#include <cstdint>

namespace proven {

/// @brief RdfFormat matching the Idris2 ABI tags.
enum class RdfFormat : uint8_t {
    RdfXml = 0,
    Turtle = 1,
    NTriples = 2,
    NQuads = 3,
    JsonLd = 4,
    Trig = 5
};

/// @brief SemwebResourceType matching the Idris2 ABI tags.
enum class SemwebResourceType : uint8_t {
    Class = 0,
    Property = 1,
    Individual = 2,
    Ontology = 3,
    NamedGraph = 4
};

/// @brief HttpMethod matching the Idris2 ABI tags.
enum class HttpMethod : uint8_t {
    Get = 0,
    Post = 1,
    Put = 2,
    Patch = 3,
    Delete = 4
};

/// @brief ContentNegotiation matching the Idris2 ABI tags.
enum class ContentNegotiation : uint8_t {
    NegRdfXml = 0,
    NegTurtle = 1,
    NegJsonLd = 2,
    NegHtml = 3
};

/// @brief SemwebErrorCode matching the Idris2 ABI tags.
enum class SemwebErrorCode : uint8_t {
    NotFound = 0,
    InvalidUri = 1,
    MalformedRdf = 2,
    UnsupportedFormat = 3,
    ConflictingTriples = 4
};

} // namespace proven

#endif // PROVEN_SEMWEB_HPP
