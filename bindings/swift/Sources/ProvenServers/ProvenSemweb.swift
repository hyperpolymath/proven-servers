// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Semantic Web protocol types for proven-servers.

/// RdfFormat matching the Idris2 ABI tags.
public enum RdfFormat: UInt8, CaseIterable, Sendable {
    case rdfXml = 0
    case turtle = 1
    case nTriples = 2
    case nQuads = 3
    case jsonLd = 4
    case trig = 5
}

/// SemwebResourceType matching the Idris2 ABI tags.
public enum SemwebResourceType: UInt8, CaseIterable, Sendable {
    case `class` = 0
    case property = 1
    case individual = 2
    case ontology = 3
    case namedGraph = 4
}

/// HttpMethod matching the Idris2 ABI tags.
public enum HttpMethod: UInt8, CaseIterable, Sendable {
    case get = 0
    case post = 1
    case put = 2
    case patch = 3
    case delete = 4
}

/// ContentNegotiation matching the Idris2 ABI tags.
public enum ContentNegotiation: UInt8, CaseIterable, Sendable {
    case negRdfXml = 0
    case negTurtle = 1
    case negJsonLd = 2
    case negHtml = 3
}

/// SemwebErrorCode matching the Idris2 ABI tags.
public enum SemwebErrorCode: UInt8, CaseIterable, Sendable {
    case notFound = 0
    case invalidUri = 1
    case malformedRdf = 2
    case unsupportedFormat = 3
    case conflictingTriples = 4
}
