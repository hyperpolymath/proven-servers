<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Semantic Web protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** RdfFormat matching the Idris2 ABI tags. */
enum RdfFormat: int
{
    case RdfXml = 0;
    case Turtle = 1;
    case NTriples = 2;
    case NQuads = 3;
    case JsonLd = 4;
    case Trig = 5;
}

/** SemwebResourceType matching the Idris2 ABI tags. */
enum SemwebResourceType: int
{
    case Class = 0;
    case Property = 1;
    case Individual = 2;
    case Ontology = 3;
    case NamedGraph = 4;
}

/** HttpMethod matching the Idris2 ABI tags. */
enum HttpMethod: int
{
    case Get = 0;
    case Post = 1;
    case Put = 2;
    case Patch = 3;
    case Delete = 4;
}

/** ContentNegotiation matching the Idris2 ABI tags. */
enum ContentNegotiation: int
{
    case NegRdfXml = 0;
    case NegTurtle = 1;
    case NegJsonLd = 2;
    case NegHtml = 3;
}

/** SemwebErrorCode matching the Idris2 ABI tags. */
enum SemwebErrorCode: int
{
    case NotFound = 0;
    case InvalidUri = 1;
    case MalformedRdf = 2;
    case UnsupportedFormat = 3;
    case ConflictingTriples = 4;
}
