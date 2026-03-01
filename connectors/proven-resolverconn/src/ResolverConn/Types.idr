-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ResolverConn.Types: Core type definitions for DNS resolver connector
-- interfaces.  Closed sum types representing DNS record types, resolver
-- states, DNSSEC validation statuses, error categories, and cache
-- policies.  These types enforce that any DNS resolver backend connector
-- is type-safe at the boundary.

module ResolverConn.Types

%default total

---------------------------------------------------------------------------
-- RecordType — DNS resource record types.
---------------------------------------------------------------------------

||| DNS resource record types supported by the resolver connector.
public export
data RecordType : Type where
  ||| IPv4 address record (RFC 1035).
  A     : RecordType
  ||| IPv6 address record (RFC 3596).
  AAAA  : RecordType
  ||| Canonical name alias (RFC 1035).
  CNAME : RecordType
  ||| Mail exchange record (RFC 1035).
  MX    : RecordType
  ||| Text record (RFC 1035).
  TXT   : RecordType
  ||| Service locator record (RFC 2782).
  SRV   : RecordType
  ||| Authoritative name server record (RFC 1035).
  NS    : RecordType
  ||| Start of authority record (RFC 1035).
  SOA   : RecordType
  ||| Pointer record for reverse lookups (RFC 1035).
  PTR   : RecordType
  ||| Certificate Authority Authorization (RFC 8659).
  CAA   : RecordType
  ||| TLSA certificate association for DANE (RFC 6698).
  TLSA  : RecordType
  ||| Service Binding record (RFC 9460).
  SVCB  : RecordType
  ||| HTTPS-specific Service Binding record (RFC 9460).
  HTTPS : RecordType

public export
Show RecordType where
  show A     = "A"
  show AAAA  = "AAAA"
  show CNAME = "CNAME"
  show MX    = "MX"
  show TXT   = "TXT"
  show SRV   = "SRV"
  show NS    = "NS"
  show SOA   = "SOA"
  show PTR   = "PTR"
  show CAA   = "CAA"
  show TLSA  = "TLSA"
  show SVCB  = "SVCB"
  show HTTPS = "HTTPS"

---------------------------------------------------------------------------
-- ResolverState — the state of the DNS resolver.
---------------------------------------------------------------------------

||| The lifecycle state of a DNS resolver connection.
public export
data ResolverState : Type where
  ||| Resolver is initialised and ready to accept queries.
  Ready    : ResolverState
  ||| A DNS query is in flight.
  Querying : ResolverState
  ||| The result was served from the local cache.
  Cached   : ResolverState
  ||| The resolver has entered a failed state.
  Failed   : ResolverState

public export
Show ResolverState where
  show Ready    = "Ready"
  show Querying = "Querying"
  show Cached   = "Cached"
  show Failed   = "Failed"

---------------------------------------------------------------------------
-- DNSSECStatus — the DNSSEC validation result.
---------------------------------------------------------------------------

||| DNSSEC validation status per RFC 4035.
public export
data DNSSECStatus : Type where
  ||| The response has a valid DNSSEC chain of trust.
  Secure        : DNSSECStatus
  ||| The zone is not signed; no DNSSEC data is present.
  Insecure      : DNSSECStatus
  ||| The DNSSEC signatures are present but invalid.
  Bogus         : DNSSECStatus
  ||| The DNSSEC status could not be determined.
  Indeterminate : DNSSECStatus

public export
Show DNSSECStatus where
  show Secure        = "Secure"
  show Insecure      = "Insecure"
  show Bogus         = "Bogus"
  show Indeterminate = "Indeterminate"

---------------------------------------------------------------------------
-- ResolverError — DNS resolver error categories.
---------------------------------------------------------------------------

||| Error categories that a DNS resolver connector can report.
public export
data ResolverError : Type where
  ||| The queried domain name does not exist (RCODE 3).
  NXDOMAIN                : ResolverError
  ||| The upstream server encountered an internal failure (RCODE 2).
  ServerFailure           : ResolverError
  ||| The upstream server refused the query (RCODE 5).
  Refused                 : ResolverError
  ||| The query exceeded the configured timeout.
  Timeout                 : ResolverError
  ||| The DNSSEC validation chain is broken or forged.
  DNSSECValidationFailed  : ResolverError
  ||| The network path to the upstream resolver is unreachable.
  NetworkUnreachable      : ResolverError
  ||| The response was truncated and TCP fallback also failed.
  TruncatedResponse       : ResolverError

public export
Show ResolverError where
  show NXDOMAIN                = "NXDOMAIN"
  show ServerFailure           = "ServerFailure"
  show Refused                 = "Refused"
  show Timeout                 = "Timeout"
  show DNSSECValidationFailed  = "DNSSECValidationFailed"
  show NetworkUnreachable      = "NetworkUnreachable"
  show TruncatedResponse       = "TruncatedResponse"

---------------------------------------------------------------------------
-- CachePolicy — how the resolver uses its local cache.
---------------------------------------------------------------------------

||| Cache behaviour for a DNS query.
public export
data CachePolicy : Type where
  ||| Use the cache if a valid entry exists; query upstream on miss.
  UseCache     : CachePolicy
  ||| Ignore any cached entry and always query upstream.
  BypassCache  : CachePolicy
  ||| Return only cached entries; never query upstream.
  CacheOnly    : CachePolicy
  ||| Force a refresh by querying upstream and updating the cache.
  RefreshCache : CachePolicy

public export
Show CachePolicy where
  show UseCache     = "UseCache"
  show BypassCache  = "BypassCache"
  show CacheOnly    = "CacheOnly"
  show RefreshCache = "RefreshCache"
