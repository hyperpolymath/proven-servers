// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// LPD protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// CommandCode represents the CommandCode type (Idris2 ABI tags).
type CommandCode uint8

const (
	CommandCodePrintJob CommandCode = iota
	CommandCodeReceiveJob
	CommandCodeShortQueue
	CommandCodeLongQueue
	CommandCodeRemoveJobs
)

// SubCommandCode represents the SubCommandCode type (Idris2 ABI tags).
type SubCommandCode uint8

const (
	SubCommandCodeAbortJob SubCommandCode = iota
	SubCommandCodeControlFile
	SubCommandCodeDataFile
)

// JobStatus represents the JobStatus type (Idris2 ABI tags).
type JobStatus uint8

const (
	JobStatusPending JobStatus = iota
	JobStatusPrinting
	JobStatusComplete
	JobStatusFailed
)
