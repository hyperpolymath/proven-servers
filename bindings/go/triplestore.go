// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Triplestore protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Statement represents the Statement type (Idris2 ABI tags).
type Statement uint8

const (
	StatementTriple Statement = iota
	StatementQuad
)

// IndexOrder represents the IndexOrder type (Idris2 ABI tags).
type IndexOrder uint8

const (
	IndexOrderSpo IndexOrder = iota
	IndexOrderPos
	IndexOrderOsp
	IndexOrderGspo
	IndexOrderGpos
	IndexOrderGosp
)

// StorageBackend represents the StorageBackend type (Idris2 ABI tags).
type StorageBackend uint8

const (
	StorageBackendInMemory StorageBackend = iota
	StorageBackendBTree
	StorageBackendLsm
	StorageBackendPersistent
)

// ImportFormat represents the ImportFormat type (Idris2 ABI tags).
type ImportFormat uint8

const (
	ImportFormatNTriples ImportFormat = iota
	ImportFormatTurtle
	ImportFormatRdfXml
	ImportFormatJsonLd
	ImportFormatNQuads
	ImportFormatTrig
)

// TransactionIsolation represents the TransactionIsolation type (Idris2 ABI tags).
type TransactionIsolation uint8

const (
	TransactionIsolationReadCommitted TransactionIsolation = iota
	TransactionIsolationSerializable
	TransactionIsolationSnapshot
)

// StoreState represents the StoreState type (Idris2 ABI tags).
type StoreState uint8

const (
	StoreStateIdle StoreState = iota
	StoreStateReady
	StoreStateInTransaction
	StoreStateImporting
	StoreStateClosing
)
