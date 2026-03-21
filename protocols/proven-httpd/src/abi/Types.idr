-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- HttpdABI.Types: C-ABI-compatible numeric representations of Httpd types.
--
-- Maps every constructor of the core Httpd sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/httpd.zig) exactly.
--
-- Types covered:
--   HttpMethod                (9 constructors, tags 0-8)
--   HttpVersion               (4 constructors, tags 0-3)
--   RequestPhase              (7 constructors, tags 0-6)
--   StatusCategory            (5 constructors, tags 0-4)
--   AbiStatusCode             (29 constructors, tags 0-28)
--   ContentType               (8 constructors, tags 0-7)

module HttpdABI.Types

%default total

---------------------------------------------------------------------------
-- HttpMethod (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
http_methodSize : Nat
http_methodSize = 1

||| HttpMethod sum type for ABI encoding.
public export
data HttpMethod : Type where
  Get : HttpMethod
  Post : HttpMethod
  Put : HttpMethod
  Delete : HttpMethod
  Patch : HttpMethod
  Head : HttpMethod
  Options : HttpMethod
  Trace : HttpMethod
  Connect : HttpMethod

||| Encode a HttpMethod to its ABI tag value.
public export
http_methodToTag : HttpMethod -> Bits8
http_methodToTag Get = 0
http_methodToTag Post = 1
http_methodToTag Put = 2
http_methodToTag Delete = 3
http_methodToTag Patch = 4
http_methodToTag Head = 5
http_methodToTag Options = 6
http_methodToTag Trace = 7
http_methodToTag Connect = 8

||| Decode an ABI tag to a HttpMethod.
public export
tagToHttpMethod : Bits8 -> Maybe HttpMethod
tagToHttpMethod 0 = Just Get
tagToHttpMethod 1 = Just Post
tagToHttpMethod 2 = Just Put
tagToHttpMethod 3 = Just Delete
tagToHttpMethod 4 = Just Patch
tagToHttpMethod 5 = Just Head
tagToHttpMethod 6 = Just Options
tagToHttpMethod 7 = Just Trace
tagToHttpMethod 8 = Just Connect
tagToHttpMethod _ = Nothing

||| Roundtrip proof: decoding an encoded HttpMethod yields the original.
public export
http_methodRoundtrip : (x : HttpMethod) -> tagToHttpMethod (http_methodToTag x) = Just x
http_methodRoundtrip Get = Refl
http_methodRoundtrip Post = Refl
http_methodRoundtrip Put = Refl
http_methodRoundtrip Delete = Refl
http_methodRoundtrip Patch = Refl
http_methodRoundtrip Head = Refl
http_methodRoundtrip Options = Refl
http_methodRoundtrip Trace = Refl
http_methodRoundtrip Connect = Refl

---------------------------------------------------------------------------
-- HttpVersion (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
http_versionSize : Nat
http_versionSize = 1

||| HttpVersion sum type for ABI encoding.
public export
data HttpVersion : Type where
  Http10 : HttpVersion
  Http11 : HttpVersion
  Http20 : HttpVersion
  Http30 : HttpVersion

||| Encode a HttpVersion to its ABI tag value.
public export
http_versionToTag : HttpVersion -> Bits8
http_versionToTag Http10 = 0
http_versionToTag Http11 = 1
http_versionToTag Http20 = 2
http_versionToTag Http30 = 3

||| Decode an ABI tag to a HttpVersion.
public export
tagToHttpVersion : Bits8 -> Maybe HttpVersion
tagToHttpVersion 0 = Just Http10
tagToHttpVersion 1 = Just Http11
tagToHttpVersion 2 = Just Http20
tagToHttpVersion 3 = Just Http30
tagToHttpVersion _ = Nothing

||| Roundtrip proof: decoding an encoded HttpVersion yields the original.
public export
http_versionRoundtrip : (x : HttpVersion) -> tagToHttpVersion (http_versionToTag x) = Just x
http_versionRoundtrip Http10 = Refl
http_versionRoundtrip Http11 = Refl
http_versionRoundtrip Http20 = Refl
http_versionRoundtrip Http30 = Refl

---------------------------------------------------------------------------
-- RequestPhase (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
request_phaseSize : Nat
request_phaseSize = 1

||| RequestPhase sum type for ABI encoding.
public export
data RequestPhase : Type where
  Idle : RequestPhase
  Receiving : RequestPhase
  HeadersParsed : RequestPhase
  BodyReceiving : RequestPhase
  Complete : RequestPhase
  Responding : RequestPhase
  Sent : RequestPhase

||| Encode a RequestPhase to its ABI tag value.
public export
request_phaseToTag : RequestPhase -> Bits8
request_phaseToTag Idle = 0
request_phaseToTag Receiving = 1
request_phaseToTag HeadersParsed = 2
request_phaseToTag BodyReceiving = 3
request_phaseToTag Complete = 4
request_phaseToTag Responding = 5
request_phaseToTag Sent = 6

||| Decode an ABI tag to a RequestPhase.
public export
tagToRequestPhase : Bits8 -> Maybe RequestPhase
tagToRequestPhase 0 = Just Idle
tagToRequestPhase 1 = Just Receiving
tagToRequestPhase 2 = Just HeadersParsed
tagToRequestPhase 3 = Just BodyReceiving
tagToRequestPhase 4 = Just Complete
tagToRequestPhase 5 = Just Responding
tagToRequestPhase 6 = Just Sent
tagToRequestPhase _ = Nothing

||| Roundtrip proof: decoding an encoded RequestPhase yields the original.
public export
request_phaseRoundtrip : (x : RequestPhase) -> tagToRequestPhase (request_phaseToTag x) = Just x
request_phaseRoundtrip Idle = Refl
request_phaseRoundtrip Receiving = Refl
request_phaseRoundtrip HeadersParsed = Refl
request_phaseRoundtrip BodyReceiving = Refl
request_phaseRoundtrip Complete = Refl
request_phaseRoundtrip Responding = Refl
request_phaseRoundtrip Sent = Refl

---------------------------------------------------------------------------
-- StatusCategory (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
status_categorySize : Nat
status_categorySize = 1

||| StatusCategory sum type for ABI encoding.
public export
data StatusCategory : Type where
  Informational : StatusCategory
  Success : StatusCategory
  Redirect : StatusCategory
  ClientError : StatusCategory
  ServerError : StatusCategory

||| Encode a StatusCategory to its ABI tag value.
public export
status_categoryToTag : StatusCategory -> Bits8
status_categoryToTag Informational = 0
status_categoryToTag Success = 1
status_categoryToTag Redirect = 2
status_categoryToTag ClientError = 3
status_categoryToTag ServerError = 4

||| Decode an ABI tag to a StatusCategory.
public export
tagToStatusCategory : Bits8 -> Maybe StatusCategory
tagToStatusCategory 0 = Just Informational
tagToStatusCategory 1 = Just Success
tagToStatusCategory 2 = Just Redirect
tagToStatusCategory 3 = Just ClientError
tagToStatusCategory 4 = Just ServerError
tagToStatusCategory _ = Nothing

||| Roundtrip proof: decoding an encoded StatusCategory yields the original.
public export
status_categoryRoundtrip : (x : StatusCategory) -> tagToStatusCategory (status_categoryToTag x) = Just x
status_categoryRoundtrip Informational = Refl
status_categoryRoundtrip Success = Refl
status_categoryRoundtrip Redirect = Refl
status_categoryRoundtrip ClientError = Refl
status_categoryRoundtrip ServerError = Refl

---------------------------------------------------------------------------
-- AbiStatusCode (29 constructors, tags 0-28)
---------------------------------------------------------------------------

public export
abi_status_codeSize : Nat
abi_status_codeSize = 1

||| AbiStatusCode sum type for ABI encoding.
public export
data AbiStatusCode : Type where
  ScContinue : AbiStatusCode
  ScSwitchingProtocols : AbiStatusCode
  ScOk : AbiStatusCode
  ScCreated : AbiStatusCode
  ScAccepted : AbiStatusCode
  ScNoContent : AbiStatusCode
  ScMovedPermanently : AbiStatusCode
  ScFound : AbiStatusCode
  ScNotModified : AbiStatusCode
  ScTemporaryRedirect : AbiStatusCode
  ScPermanentRedirect : AbiStatusCode
  ScBadRequest : AbiStatusCode
  ScUnauthorized : AbiStatusCode
  ScForbidden : AbiStatusCode
  ScNotFound : AbiStatusCode
  ScMethodNotAllowed : AbiStatusCode
  ScRequestTimeout : AbiStatusCode
  ScConflict : AbiStatusCode
  ScGone : AbiStatusCode
  ScLengthRequired : AbiStatusCode
  ScPayloadTooLarge : AbiStatusCode
  ScUriTooLong : AbiStatusCode
  ScUnsupportedMedia : AbiStatusCode
  ScTooManyRequests : AbiStatusCode
  ScInternalError : AbiStatusCode
  ScNotImplemented : AbiStatusCode
  ScBadGateway : AbiStatusCode
  ScServiceUnavailable : AbiStatusCode
  ScGatewayTimeout : AbiStatusCode

||| Encode a AbiStatusCode to its ABI tag value.
public export
abi_status_codeToTag : AbiStatusCode -> Bits8
abi_status_codeToTag ScContinue = 0
abi_status_codeToTag ScSwitchingProtocols = 1
abi_status_codeToTag ScOk = 2
abi_status_codeToTag ScCreated = 3
abi_status_codeToTag ScAccepted = 4
abi_status_codeToTag ScNoContent = 5
abi_status_codeToTag ScMovedPermanently = 6
abi_status_codeToTag ScFound = 7
abi_status_codeToTag ScNotModified = 8
abi_status_codeToTag ScTemporaryRedirect = 9
abi_status_codeToTag ScPermanentRedirect = 10
abi_status_codeToTag ScBadRequest = 11
abi_status_codeToTag ScUnauthorized = 12
abi_status_codeToTag ScForbidden = 13
abi_status_codeToTag ScNotFound = 14
abi_status_codeToTag ScMethodNotAllowed = 15
abi_status_codeToTag ScRequestTimeout = 16
abi_status_codeToTag ScConflict = 17
abi_status_codeToTag ScGone = 18
abi_status_codeToTag ScLengthRequired = 19
abi_status_codeToTag ScPayloadTooLarge = 20
abi_status_codeToTag ScUriTooLong = 21
abi_status_codeToTag ScUnsupportedMedia = 22
abi_status_codeToTag ScTooManyRequests = 23
abi_status_codeToTag ScInternalError = 24
abi_status_codeToTag ScNotImplemented = 25
abi_status_codeToTag ScBadGateway = 26
abi_status_codeToTag ScServiceUnavailable = 27
abi_status_codeToTag ScGatewayTimeout = 28

||| Decode an ABI tag to a AbiStatusCode.
public export
tagToAbiStatusCode : Bits8 -> Maybe AbiStatusCode
tagToAbiStatusCode 0 = Just ScContinue
tagToAbiStatusCode 1 = Just ScSwitchingProtocols
tagToAbiStatusCode 2 = Just ScOk
tagToAbiStatusCode 3 = Just ScCreated
tagToAbiStatusCode 4 = Just ScAccepted
tagToAbiStatusCode 5 = Just ScNoContent
tagToAbiStatusCode 6 = Just ScMovedPermanently
tagToAbiStatusCode 7 = Just ScFound
tagToAbiStatusCode 8 = Just ScNotModified
tagToAbiStatusCode 9 = Just ScTemporaryRedirect
tagToAbiStatusCode 10 = Just ScPermanentRedirect
tagToAbiStatusCode 11 = Just ScBadRequest
tagToAbiStatusCode 12 = Just ScUnauthorized
tagToAbiStatusCode 13 = Just ScForbidden
tagToAbiStatusCode 14 = Just ScNotFound
tagToAbiStatusCode 15 = Just ScMethodNotAllowed
tagToAbiStatusCode 16 = Just ScRequestTimeout
tagToAbiStatusCode 17 = Just ScConflict
tagToAbiStatusCode 18 = Just ScGone
tagToAbiStatusCode 19 = Just ScLengthRequired
tagToAbiStatusCode 20 = Just ScPayloadTooLarge
tagToAbiStatusCode 21 = Just ScUriTooLong
tagToAbiStatusCode 22 = Just ScUnsupportedMedia
tagToAbiStatusCode 23 = Just ScTooManyRequests
tagToAbiStatusCode 24 = Just ScInternalError
tagToAbiStatusCode 25 = Just ScNotImplemented
tagToAbiStatusCode 26 = Just ScBadGateway
tagToAbiStatusCode 27 = Just ScServiceUnavailable
tagToAbiStatusCode 28 = Just ScGatewayTimeout
tagToAbiStatusCode _ = Nothing

||| Roundtrip proof: decoding an encoded AbiStatusCode yields the original.
public export
abi_status_codeRoundtrip : (x : AbiStatusCode) -> tagToAbiStatusCode (abi_status_codeToTag x) = Just x
abi_status_codeRoundtrip ScContinue = Refl
abi_status_codeRoundtrip ScSwitchingProtocols = Refl
abi_status_codeRoundtrip ScOk = Refl
abi_status_codeRoundtrip ScCreated = Refl
abi_status_codeRoundtrip ScAccepted = Refl
abi_status_codeRoundtrip ScNoContent = Refl
abi_status_codeRoundtrip ScMovedPermanently = Refl
abi_status_codeRoundtrip ScFound = Refl
abi_status_codeRoundtrip ScNotModified = Refl
abi_status_codeRoundtrip ScTemporaryRedirect = Refl
abi_status_codeRoundtrip ScPermanentRedirect = Refl
abi_status_codeRoundtrip ScBadRequest = Refl
abi_status_codeRoundtrip ScUnauthorized = Refl
abi_status_codeRoundtrip ScForbidden = Refl
abi_status_codeRoundtrip ScNotFound = Refl
abi_status_codeRoundtrip ScMethodNotAllowed = Refl
abi_status_codeRoundtrip ScRequestTimeout = Refl
abi_status_codeRoundtrip ScConflict = Refl
abi_status_codeRoundtrip ScGone = Refl
abi_status_codeRoundtrip ScLengthRequired = Refl
abi_status_codeRoundtrip ScPayloadTooLarge = Refl
abi_status_codeRoundtrip ScUriTooLong = Refl
abi_status_codeRoundtrip ScUnsupportedMedia = Refl
abi_status_codeRoundtrip ScTooManyRequests = Refl
abi_status_codeRoundtrip ScInternalError = Refl
abi_status_codeRoundtrip ScNotImplemented = Refl
abi_status_codeRoundtrip ScBadGateway = Refl
abi_status_codeRoundtrip ScServiceUnavailable = Refl
abi_status_codeRoundtrip ScGatewayTimeout = Refl

---------------------------------------------------------------------------
-- ContentType (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
content_typeSize : Nat
content_typeSize = 1

||| ContentType sum type for ABI encoding.
public export
data ContentType : Type where
  TextPlain : ContentType
  TextHtml : ContentType
  ApplicationJson : ContentType
  ApplicationXml : ContentType
  ApplicationForm : ContentType
  MultipartForm : ContentType
  OctetStream : ContentType
  TextCss : ContentType

||| Encode a ContentType to its ABI tag value.
public export
content_typeToTag : ContentType -> Bits8
content_typeToTag TextPlain = 0
content_typeToTag TextHtml = 1
content_typeToTag ApplicationJson = 2
content_typeToTag ApplicationXml = 3
content_typeToTag ApplicationForm = 4
content_typeToTag MultipartForm = 5
content_typeToTag OctetStream = 6
content_typeToTag TextCss = 7

||| Decode an ABI tag to a ContentType.
public export
tagToContentType : Bits8 -> Maybe ContentType
tagToContentType 0 = Just TextPlain
tagToContentType 1 = Just TextHtml
tagToContentType 2 = Just ApplicationJson
tagToContentType 3 = Just ApplicationXml
tagToContentType 4 = Just ApplicationForm
tagToContentType 5 = Just MultipartForm
tagToContentType 6 = Just OctetStream
tagToContentType 7 = Just TextCss
tagToContentType _ = Nothing

||| Roundtrip proof: decoding an encoded ContentType yields the original.
public export
content_typeRoundtrip : (x : ContentType) -> tagToContentType (content_typeToTag x) = Just x
content_typeRoundtrip TextPlain = Refl
content_typeRoundtrip TextHtml = Refl
content_typeRoundtrip ApplicationJson = Refl
content_typeRoundtrip ApplicationXml = Refl
content_typeRoundtrip ApplicationForm = Refl
content_typeRoundtrip MultipartForm = Refl
content_typeRoundtrip OctetStream = Refl
content_typeRoundtrip TextCss = Refl
