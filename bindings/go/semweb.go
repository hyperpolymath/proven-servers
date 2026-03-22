// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Semantic Web protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// RdfFormat represents the RdfFormat type (Idris2 ABI tags).
type RdfFormat uint8

const (
	RdfFormatRdfXml RdfFormat = iota
	RdfFormatTurtle
	RdfFormatNTriples
	RdfFormatNQuads
	RdfFormatJsonLd
	RdfFormatTrig
)

// SemwebResourceType represents the SemwebResourceType type (Idris2 ABI tags).
type SemwebResourceType uint8

const (
	SemwebResourceTypeClass SemwebResourceType = iota
	SemwebResourceTypeProperty
	SemwebResourceTypeIndividual
	SemwebResourceTypeOntology
	SemwebResourceTypeNamedGraph
)

// HttpMethod represents the HttpMethod type (Idris2 ABI tags).
type HttpMethod uint8

const (
	HttpMethodGet HttpMethod = iota
	HttpMethodPost
	HttpMethodPut
	HttpMethodPatch
	HttpMethodDelete
)

// ContentNegotiation represents the ContentNegotiation type (Idris2 ABI tags).
type ContentNegotiation uint8

const (
	ContentNegotiationNegRdfXml ContentNegotiation = iota
	ContentNegotiationNegTurtle
	ContentNegotiationNegJsonLd
	ContentNegotiationNegHtml
)

// SemwebErrorCode represents the SemwebErrorCode type (Idris2 ABI tags).
type SemwebErrorCode uint8

const (
	SemwebErrorCodeNotFound SemwebErrorCode = iota
	SemwebErrorCodeInvalidUri
	SemwebErrorCodeMalformedRdf
	SemwebErrorCodeUnsupportedFormat
	SemwebErrorCodeConflictingTriples
)
