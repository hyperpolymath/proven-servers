// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Semantic Web protocol types for proven-servers.

namespace Proven;

/// <summary>RdfFormat matching the Idris2 ABI tags (0-5).</summary>
public enum RdfFormat : byte
{
    RdfXml = 0,
    Turtle = 1,
    NTriples = 2,
    NQuads = 3,
    JsonLd = 4,
    Trig = 5
}

/// <summary>SemwebResourceType matching the Idris2 ABI tags (0-4).</summary>
public enum SemwebResourceType : byte
{
    Class = 0,
    Property = 1,
    Individual = 2,
    Ontology = 3,
    NamedGraph = 4
}

/// <summary>HttpMethod matching the Idris2 ABI tags (0-4).</summary>
public enum HttpMethod : byte
{
    Get = 0,
    Post = 1,
    Put = 2,
    Patch = 3,
    Delete = 4
}

/// <summary>ContentNegotiation matching the Idris2 ABI tags (0-3).</summary>
public enum ContentNegotiation : byte
{
    NegRdfXml = 0,
    NegTurtle = 1,
    NegJsonLd = 2,
    NegHtml = 3
}

/// <summary>SemwebErrorCode matching the Idris2 ABI tags (0-4).</summary>
public enum SemwebErrorCode : byte
{
    NotFound = 0,
    InvalidUri = 1,
    MalformedRdf = 2,
    UnsupportedFormat = 3,
    ConflictingTriples = 4
}
