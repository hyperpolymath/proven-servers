// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// SPARQL protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// SparqlQueryType represents the SparqlQueryType type (Idris2 ABI tags).
type SparqlQueryType uint8

const (
	SparqlQueryTypeSelect SparqlQueryType = iota
	SparqlQueryTypeConstruct
	SparqlQueryTypeAsk
	SparqlQueryTypeDescribe
)

// UpdateType represents the UpdateType type (Idris2 ABI tags).
type UpdateType uint8

const (
	UpdateTypeInsert UpdateType = iota
	UpdateTypeDelete
	UpdateTypeLoad
	UpdateTypeClear
	UpdateTypeCreate
	UpdateTypeDrop
)

// ResultFormat represents the ResultFormat type (Idris2 ABI tags).
type ResultFormat uint8

const (
	ResultFormatXml ResultFormat = iota
	ResultFormatJson
	ResultFormatCsv
	ResultFormatTsv
)

// SparqlErrorType represents the SparqlErrorType type (Idris2 ABI tags).
type SparqlErrorType uint8

const (
	SparqlErrorTypeParseError SparqlErrorType = iota
	SparqlErrorTypeQueryTimeout
	SparqlErrorTypeResultsTooLarge
	SparqlErrorTypeUnknownGraph
	SparqlErrorTypeAccessDenied
)
