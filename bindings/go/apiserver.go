// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// API Server protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// AuthScheme represents the AuthScheme type (Idris2 ABI tags).
type AuthScheme uint8

const (
	AuthSchemeApiKey AuthScheme = iota
	AuthSchemeBearer
	AuthSchemeBasic
	AuthSchemeOAuth2
	AuthSchemeHmac
	AuthSchemeMtls
)

// RateLimitStrategy represents the RateLimitStrategy type (Idris2 ABI tags).
type RateLimitStrategy uint8

const (
	RateLimitStrategyFixedWindow RateLimitStrategy = iota
	RateLimitStrategySlidingWindow
	RateLimitStrategyTokenBucket
	RateLimitStrategyLeakyBucket
)

// ApiVersion represents the ApiVersion type (Idris2 ABI tags).
type ApiVersion uint8

const (
	ApiVersionV1 ApiVersion = iota
	ApiVersionV2
	ApiVersionV3
	ApiVersionLatest
	ApiVersionDeprecated
)

// ResponseFormat represents the ResponseFormat type (Idris2 ABI tags).
type ResponseFormat uint8

const (
	ResponseFormatJson ResponseFormat = iota
	ResponseFormatXml
	ResponseFormatProtobuf
	ResponseFormatMessagePack
)

// GatewayError represents the GatewayError type (Idris2 ABI tags).
type GatewayError uint8

const (
	GatewayErrorUnauthorized GatewayError = iota
	GatewayErrorRateLimited
	GatewayErrorNotFound
	GatewayErrorBadRequest
	GatewayErrorServiceUnavailable
	GatewayErrorCircuitOpen
)
