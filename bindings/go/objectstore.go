// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Object Store protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Operation represents the Operation type (Idris2 ABI tags).
type Operation uint8

const (
	OperationPutObject Operation = iota
	OperationGetObject
	OperationDeleteObject
	OperationListObjects
	OperationHeadObject
	OperationCopyObject
	OperationCreateBucket
	OperationDeleteBucket
	OperationListBuckets
	OperationInitMultipartUpload
	OperationUploadPart
	OperationCompleteMultipartUpload
)

// StorageClass represents the StorageClass type (Idris2 ABI tags).
type StorageClass uint8

const (
	StorageClassStandard StorageClass = iota
	StorageClassInfrequentAccess
	StorageClassGlacier
	StorageClassDeepArchive
	StorageClassOneZone
)

// Acl represents the Acl type (Idris2 ABI tags).
type Acl uint8

const (
	AclPrivate Acl = iota
	AclPublicRead
	AclPublicReadWrite
	AclAuthenticatedRead
)

// ErrorCode represents the ErrorCode type (Idris2 ABI tags).
type ErrorCode uint8

const (
	ErrorCodeNoSuchBucket ErrorCode = iota
	ErrorCodeNoSuchKey
	ErrorCodeBucketAlreadyExists
	ErrorCodeBucketNotEmpty
	ErrorCodeAccessDenied
	ErrorCodeEntityTooLarge
	ErrorCodeInvalidPart
	ErrorCodeIncompleteBody
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateIdle SessionState = iota
	SessionStateReady
	SessionStateBucketActive
	SessionStateUploading
	SessionStateClosing
)
