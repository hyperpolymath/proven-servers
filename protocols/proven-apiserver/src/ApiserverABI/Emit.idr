-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- ApiserverABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into apiserver_abi_gen.zig for the comptime guard.

module ApiserverABI.Emit

import Apiserver.Types
import ApiserverABI.Types
import ApiserverABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "AUTH" "API_KEY" (authSchemeToTag APIKey)
  , line "AUTH" "BEARER"  (authSchemeToTag Bearer)
  , line "AUTH" "BASIC"   (authSchemeToTag Basic)
  , line "AUTH" "OAUTH2"  (authSchemeToTag OAuth2)
  , line "AUTH" "HMAC"    (authSchemeToTag HMAC)
  , line "AUTH" "MTLS"    (authSchemeToTag MTLS)
  , line "RATE" "FIXED_WINDOW"   (rateLimitStrategyToTag FixedWindow)
  , line "RATE" "SLIDING_WINDOW" (rateLimitStrategyToTag SlidingWindow)
  , line "RATE" "TOKEN_BUCKET"   (rateLimitStrategyToTag TokenBucket)
  , line "RATE" "LEAKY_BUCKET"   (rateLimitStrategyToTag LeakyBucket)
  , line "VER" "V1"         (apiVersionToTag V1)
  , line "VER" "V2"         (apiVersionToTag V2)
  , line "VER" "V3"         (apiVersionToTag V3)
  , line "VER" "LATEST"     (apiVersionToTag Latest)
  , line "VER" "DEPRECATED" (apiVersionToTag Deprecated)
  , line "FMT" "JSON"        (responseFormatToTag JSON)
  , line "FMT" "XML"         (responseFormatToTag XML)
  , line "FMT" "PROTOBUF"    (responseFormatToTag Protobuf)
  , line "FMT" "MESSAGEPACK" (responseFormatToTag MessagePack)
  , line "ERR" "UNAUTHORIZED"        (gatewayErrorToTag Unauthorized)
  , line "ERR" "RATE_LIMITED"        (gatewayErrorToTag RateLimited)
  , line "ERR" "NOT_FOUND"           (gatewayErrorToTag NotFound)
  , line "ERR" "BAD_REQUEST"         (gatewayErrorToTag BadRequest)
  , line "ERR" "SERVICE_UNAVAILABLE" (gatewayErrorToTag ServiceUnavailable)
  , line "ERR" "CIRCUIT_OPEN"        (gatewayErrorToTag CircuitOpen)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
