-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ApiserverABI.Types: C-ABI-compatible numeric representations of API server types.
--
-- Maps every constructor of the core Apiserver sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/apiserver.h) and the
-- Zig FFI enums (ffi/zig/src/apiserver.zig) exactly.
--
-- Types covered:
--   AuthScheme        (6 constructors, tags 0-5)
--   RateLimitStrategy (4 constructors, tags 0-3)
--   APIVersion        (5 constructors, tags 0-4)
--   ResponseFormat    (4 constructors, tags 0-3)
--   GatewayError      (6 constructors, tags 0-5)

module ApiserverABI.Types

import Apiserver.Types

%default total

---------------------------------------------------------------------------
-- AuthScheme (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
authSchemeSize : Nat
authSchemeSize = 1

||| Encode an AuthScheme to its ABI tag value.
public export
authSchemeToTag : AuthScheme -> Bits8
authSchemeToTag APIKey = 0
authSchemeToTag Bearer = 1
authSchemeToTag Basic  = 2
authSchemeToTag OAuth2 = 3
authSchemeToTag HMAC   = 4
authSchemeToTag MTLS   = 5

||| Decode an ABI tag to an AuthScheme.
public export
tagToAuthScheme : Bits8 -> Maybe AuthScheme
tagToAuthScheme 0 = Just APIKey
tagToAuthScheme 1 = Just Bearer
tagToAuthScheme 2 = Just Basic
tagToAuthScheme 3 = Just OAuth2
tagToAuthScheme 4 = Just HMAC
tagToAuthScheme 5 = Just MTLS
tagToAuthScheme _ = Nothing

||| Roundtrip proof: decoding an encoded AuthScheme yields the original.
public export
authSchemeRoundtrip : (a : AuthScheme) -> tagToAuthScheme (authSchemeToTag a) = Just a
authSchemeRoundtrip APIKey = Refl
authSchemeRoundtrip Bearer = Refl
authSchemeRoundtrip Basic  = Refl
authSchemeRoundtrip OAuth2 = Refl
authSchemeRoundtrip HMAC   = Refl
authSchemeRoundtrip MTLS   = Refl

---------------------------------------------------------------------------
-- RateLimitStrategy (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
rateLimitStrategySize : Nat
rateLimitStrategySize = 1

||| Encode a RateLimitStrategy to its ABI tag value.
public export
rateLimitStrategyToTag : RateLimitStrategy -> Bits8
rateLimitStrategyToTag FixedWindow   = 0
rateLimitStrategyToTag SlidingWindow = 1
rateLimitStrategyToTag TokenBucket   = 2
rateLimitStrategyToTag LeakyBucket   = 3

||| Decode an ABI tag to a RateLimitStrategy.
public export
tagToRateLimitStrategy : Bits8 -> Maybe RateLimitStrategy
tagToRateLimitStrategy 0 = Just FixedWindow
tagToRateLimitStrategy 1 = Just SlidingWindow
tagToRateLimitStrategy 2 = Just TokenBucket
tagToRateLimitStrategy 3 = Just LeakyBucket
tagToRateLimitStrategy _ = Nothing

||| Roundtrip proof: decoding an encoded RateLimitStrategy yields the original.
public export
rateLimitStrategyRoundtrip : (r : RateLimitStrategy) -> tagToRateLimitStrategy (rateLimitStrategyToTag r) = Just r
rateLimitStrategyRoundtrip FixedWindow   = Refl
rateLimitStrategyRoundtrip SlidingWindow = Refl
rateLimitStrategyRoundtrip TokenBucket   = Refl
rateLimitStrategyRoundtrip LeakyBucket   = Refl

---------------------------------------------------------------------------
-- APIVersion (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
apiVersionSize : Nat
apiVersionSize = 1

||| Encode an APIVersion to its ABI tag value.
public export
apiVersionToTag : APIVersion -> Bits8
apiVersionToTag V1         = 0
apiVersionToTag V2         = 1
apiVersionToTag V3         = 2
apiVersionToTag Latest     = 3
apiVersionToTag Deprecated = 4

||| Decode an ABI tag to an APIVersion.
public export
tagToAPIVersion : Bits8 -> Maybe APIVersion
tagToAPIVersion 0 = Just V1
tagToAPIVersion 1 = Just V2
tagToAPIVersion 2 = Just V3
tagToAPIVersion 3 = Just Latest
tagToAPIVersion 4 = Just Deprecated
tagToAPIVersion _ = Nothing

||| Roundtrip proof: decoding an encoded APIVersion yields the original.
public export
apiVersionRoundtrip : (v : APIVersion) -> tagToAPIVersion (apiVersionToTag v) = Just v
apiVersionRoundtrip V1         = Refl
apiVersionRoundtrip V2         = Refl
apiVersionRoundtrip V3         = Refl
apiVersionRoundtrip Latest     = Refl
apiVersionRoundtrip Deprecated = Refl

---------------------------------------------------------------------------
-- ResponseFormat (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
responseFormatSize : Nat
responseFormatSize = 1

||| Encode a ResponseFormat to its ABI tag value.
public export
responseFormatToTag : ResponseFormat -> Bits8
responseFormatToTag JSON        = 0
responseFormatToTag XML         = 1
responseFormatToTag Protobuf    = 2
responseFormatToTag MessagePack = 3

||| Decode an ABI tag to a ResponseFormat.
public export
tagToResponseFormat : Bits8 -> Maybe ResponseFormat
tagToResponseFormat 0 = Just JSON
tagToResponseFormat 1 = Just XML
tagToResponseFormat 2 = Just Protobuf
tagToResponseFormat 3 = Just MessagePack
tagToResponseFormat _ = Nothing

||| Roundtrip proof: decoding an encoded ResponseFormat yields the original.
public export
responseFormatRoundtrip : (f : ResponseFormat) -> tagToResponseFormat (responseFormatToTag f) = Just f
responseFormatRoundtrip JSON        = Refl
responseFormatRoundtrip XML         = Refl
responseFormatRoundtrip Protobuf    = Refl
responseFormatRoundtrip MessagePack = Refl

---------------------------------------------------------------------------
-- GatewayError (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
gatewayErrorSize : Nat
gatewayErrorSize = 1

||| Encode a GatewayError to its ABI tag value.
public export
gatewayErrorToTag : GatewayError -> Bits8
gatewayErrorToTag Unauthorized       = 0
gatewayErrorToTag RateLimited        = 1
gatewayErrorToTag NotFound           = 2
gatewayErrorToTag BadRequest         = 3
gatewayErrorToTag ServiceUnavailable = 4
gatewayErrorToTag CircuitOpen        = 5

||| Decode an ABI tag to a GatewayError.
public export
tagToGatewayError : Bits8 -> Maybe GatewayError
tagToGatewayError 0 = Just Unauthorized
tagToGatewayError 1 = Just RateLimited
tagToGatewayError 2 = Just NotFound
tagToGatewayError 3 = Just BadRequest
tagToGatewayError 4 = Just ServiceUnavailable
tagToGatewayError 5 = Just CircuitOpen
tagToGatewayError _ = Nothing

||| Roundtrip proof: decoding an encoded GatewayError yields the original.
public export
gatewayErrorRoundtrip : (e : GatewayError) -> tagToGatewayError (gatewayErrorToTag e) = Just e
gatewayErrorRoundtrip Unauthorized       = Refl
gatewayErrorRoundtrip RateLimited        = Refl
gatewayErrorRoundtrip NotFound           = Refl
gatewayErrorRoundtrip BadRequest         = Refl
gatewayErrorRoundtrip ServiceUnavailable = Refl
gatewayErrorRoundtrip CircuitOpen        = Refl
