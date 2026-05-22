// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// HTTP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Method represents the Method type (Idris2 ABI tags).
type Method uint8

const (
	MethodGet Method = iota
	MethodPost
	MethodPut
	MethodDelete
	MethodPatch
	MethodHead
	MethodOptions
	MethodTrace
	MethodConnect
)

// Version represents the Version type (Idris2 ABI tags).
type Version uint8

const (
	VersionHttp10 Version = iota
	VersionHttp11
	VersionHttp20
	VersionHttp30
)

// StatusCategory represents the StatusCategory type (Idris2 ABI tags).
type StatusCategory uint8

const (
	StatusCategoryInformational StatusCategory = iota
	StatusCategorySuccess
	StatusCategoryRedirect
	StatusCategoryClientError
	StatusCategoryServerError
)

// StatusCode represents the StatusCode type (Idris2 ABI tags).
type StatusCode uint8

const (
	StatusCodeContinue StatusCode = iota
	StatusCodeSwitchingProtocols
	StatusCodeOk
	StatusCodeCreated
	StatusCodeAccepted
	StatusCodeNoContent
	StatusCodeMovedPermanently
	StatusCodeFound
	StatusCodeNotModified
	StatusCodeTemporaryRedirect
	StatusCodePermanentRedirect
	StatusCodeBadRequest
	StatusCodeUnauthorized
	StatusCodeForbidden
	StatusCodeNotFound
	StatusCodeMethodNotAllowed
	StatusCodeRequestTimeout
	StatusCodeConflict
	StatusCodeGone
	StatusCodeLengthRequired
	StatusCodePayloadTooLarge
	StatusCodeUriTooLong
	StatusCodeUnsupportedMedia
	StatusCodeTooManyRequests
	StatusCodeInternalError
	StatusCodeNotImplemented
	StatusCodeBadGateway
	StatusCodeServiceUnavailable
	StatusCodeGatewayTimeout
)

// ContentType represents the ContentType type (Idris2 ABI tags).
type ContentType uint8

const (
	ContentTypeTextPlain ContentType = iota
	ContentTypeTextHtml
	ContentTypeApplicationJson
	ContentTypeApplicationXml
	ContentTypeApplicationForm
	ContentTypeMultipartForm
	ContentTypeOctetStream
	ContentTypeTextCss
)

// HeaderType represents the HeaderType type (Idris2 ABI tags).
type HeaderType uint8

const (
	HeaderTypeContentType HeaderType = iota
	HeaderTypeContentLength
	HeaderTypeHost
	HeaderTypeConnection
	HeaderTypeAccept
	HeaderTypeUserAgent
	HeaderTypeServer
	HeaderTypeLocation
	HeaderTypeCacheControl
	HeaderTypeCustom
)

// RequestPhase represents the RequestPhase type (Idris2 ABI tags).
type RequestPhase uint8

const (
	RequestPhaseIdle RequestPhase = iota
	RequestPhaseReceiving
	RequestPhaseHeadersParsed
	RequestPhaseBodyReceiving
	RequestPhaseComplete
	RequestPhaseResponding
	RequestPhaseSent
)
