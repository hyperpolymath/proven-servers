// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SPARQL protocol types for proven-servers.

namespace Proven;

/// <summary>SparqlQueryType matching the Idris2 ABI tags (0-3).</summary>
public enum SparqlQueryType : byte
{
    Select = 0,
    Construct = 1,
    Ask = 2,
    Describe = 3
}

/// <summary>UpdateType matching the Idris2 ABI tags (0-5).</summary>
public enum UpdateType : byte
{
    Insert = 0,
    Delete = 1,
    Load = 2,
    Clear = 3,
    Create = 4,
    Drop = 5
}

/// <summary>ResultFormat matching the Idris2 ABI tags (0-3).</summary>
public enum ResultFormat : byte
{
    Xml = 0,
    Json = 1,
    Csv = 2,
    Tsv = 3
}

/// <summary>SparqlErrorType matching the Idris2 ABI tags (0-4).</summary>
public enum SparqlErrorType : byte
{
    ParseError = 0,
    QueryTimeout = 1,
    ResultsTooLarge = 2,
    UnknownGraph = 3,
    AccessDenied = 4
}
