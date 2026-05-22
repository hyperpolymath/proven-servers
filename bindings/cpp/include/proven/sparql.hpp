// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file sparql.hpp
/// @brief SPARQL protocol types for proven-servers.

#ifndef PROVEN_SPARQL_HPP
#define PROVEN_SPARQL_HPP

#include <cstdint>

namespace proven {

/// @brief SparqlQueryType matching the Idris2 ABI tags.
enum class SparqlQueryType : uint8_t {
    Select = 0,
    Construct = 1,
    Ask = 2,
    Describe = 3
};

/// @brief UpdateType matching the Idris2 ABI tags.
enum class UpdateType : uint8_t {
    Insert = 0,
    Delete = 1,
    Load = 2,
    Clear = 3,
    Create = 4,
    Drop = 5
};

/// @brief ResultFormat matching the Idris2 ABI tags.
enum class ResultFormat : uint8_t {
    Xml = 0,
    Json = 1,
    Csv = 2,
    Tsv = 3
};

/// @brief SparqlErrorType matching the Idris2 ABI tags.
enum class SparqlErrorType : uint8_t {
    ParseError = 0,
    QueryTimeout = 1,
    ResultsTooLarge = 2,
    UnknownGraph = 3,
    AccessDenied = 4
};

} // namespace proven

#endif // PROVEN_SPARQL_HPP
