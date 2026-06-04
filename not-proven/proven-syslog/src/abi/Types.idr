-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- SyslogABI.Types: C-ABI-compatible numeric representations of Syslog types.
--
-- Maps every constructor of the core Syslog sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/syslog.h) and the
-- Zig FFI enums (ffi/zig/src/syslog.zig) exactly.
--
-- Types covered:
--   Severity  (8 constructors, tags 0-7)
--   Facility  (24 constructors, tags 0-23)
--   Transport (3 constructors, tags 0-2)

module SyslogABI.Types

import Syslog.Severity
import Syslog.Facility
import Syslog.Transport

%default total

---------------------------------------------------------------------------
-- Severity (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
severitySize : Nat
severitySize = 1

||| Encode a Severity to its ABI tag value (matching RFC 5424 numeric codes).
public export
severityToTag : Severity -> Bits8
severityToTag Emergency     = 0
severityToTag Alert         = 1
severityToTag Critical      = 2
severityToTag Error         = 3
severityToTag Warning       = 4
severityToTag Notice        = 5
severityToTag Informational = 6
severityToTag Debug         = 7

||| Decode an ABI tag to a Severity.
public export
tagToSeverity : Bits8 -> Maybe Severity
tagToSeverity 0 = Just Emergency
tagToSeverity 1 = Just Alert
tagToSeverity 2 = Just Critical
tagToSeverity 3 = Just Error
tagToSeverity 4 = Just Warning
tagToSeverity 5 = Just Notice
tagToSeverity 6 = Just Informational
tagToSeverity 7 = Just Debug
tagToSeverity _ = Nothing

||| Roundtrip proof: decoding an encoded Severity yields the original.
public export
severityRoundtrip : (s : Severity) -> tagToSeverity (severityToTag s) = Just s
severityRoundtrip Emergency     = Refl
severityRoundtrip Alert         = Refl
severityRoundtrip Critical      = Refl
severityRoundtrip Error         = Refl
severityRoundtrip Warning       = Refl
severityRoundtrip Notice        = Refl
severityRoundtrip Informational = Refl
severityRoundtrip Debug         = Refl

---------------------------------------------------------------------------
-- Facility (24 constructors, tags 0-23)
---------------------------------------------------------------------------

public export
facilitySize : Nat
facilitySize = 1

||| Encode a Facility to its ABI tag value (matching RFC 5424 numeric codes).
public export
facilityToTag : Facility -> Bits8
facilityToTag Kern     = 0
facilityToTag User     = 1
facilityToTag Mail     = 2
facilityToTag Daemon   = 3
facilityToTag Auth     = 4
facilityToTag SyslogF  = 5
facilityToTag LPR      = 6
facilityToTag News     = 7
facilityToTag UUCP     = 8
facilityToTag Cron     = 9
facilityToTag AuthPriv = 10
facilityToTag FTP      = 11
facilityToTag NTPFac   = 12
facilityToTag Audit    = 13
facilityToTag Alert    = 14
facilityToTag Clock    = 15
facilityToTag Local0   = 16
facilityToTag Local1   = 17
facilityToTag Local2   = 18
facilityToTag Local3   = 19
facilityToTag Local4   = 20
facilityToTag Local5   = 21
facilityToTag Local6   = 22
facilityToTag Local7   = 23

||| Decode an ABI tag to a Facility.
public export
tagToFacility : Bits8 -> Maybe Facility
tagToFacility 0  = Just Kern
tagToFacility 1  = Just User
tagToFacility 2  = Just Mail
tagToFacility 3  = Just Daemon
tagToFacility 4  = Just Auth
tagToFacility 5  = Just SyslogF
tagToFacility 6  = Just LPR
tagToFacility 7  = Just News
tagToFacility 8  = Just UUCP
tagToFacility 9  = Just Cron
tagToFacility 10 = Just AuthPriv
tagToFacility 11 = Just FTP
tagToFacility 12 = Just NTPFac
tagToFacility 13 = Just Audit
tagToFacility 14 = Just Alert
tagToFacility 15 = Just Clock
tagToFacility 16 = Just Local0
tagToFacility 17 = Just Local1
tagToFacility 18 = Just Local2
tagToFacility 19 = Just Local3
tagToFacility 20 = Just Local4
tagToFacility 21 = Just Local5
tagToFacility 22 = Just Local6
tagToFacility 23 = Just Local7
tagToFacility _  = Nothing

||| Roundtrip proof: decoding an encoded Facility yields the original.
public export
facilityRoundtrip : (f : Facility) -> tagToFacility (facilityToTag f) = Just f
facilityRoundtrip Kern     = Refl
facilityRoundtrip User     = Refl
facilityRoundtrip Mail     = Refl
facilityRoundtrip Daemon   = Refl
facilityRoundtrip Auth     = Refl
facilityRoundtrip SyslogF  = Refl
facilityRoundtrip LPR      = Refl
facilityRoundtrip News     = Refl
facilityRoundtrip UUCP     = Refl
facilityRoundtrip Cron     = Refl
facilityRoundtrip AuthPriv = Refl
facilityRoundtrip FTP      = Refl
facilityRoundtrip NTPFac   = Refl
facilityRoundtrip Audit    = Refl
facilityRoundtrip Alert    = Refl
facilityRoundtrip Clock    = Refl
facilityRoundtrip Local0   = Refl
facilityRoundtrip Local1   = Refl
facilityRoundtrip Local2   = Refl
facilityRoundtrip Local3   = Refl
facilityRoundtrip Local4   = Refl
facilityRoundtrip Local5   = Refl
facilityRoundtrip Local6   = Refl
facilityRoundtrip Local7   = Refl

---------------------------------------------------------------------------
-- Transport (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
transportSize : Nat
transportSize = 1

||| Encode a Transport to its ABI tag value.
public export
transportToTag : Transport -> Bits8
transportToTag UDP514  = 0
transportToTag TCP514  = 1
transportToTag TLS6514 = 2

||| Decode an ABI tag to a Transport.
public export
tagToTransport : Bits8 -> Maybe Transport
tagToTransport 0 = Just UDP514
tagToTransport 1 = Just TCP514
tagToTransport 2 = Just TLS6514
tagToTransport _ = Nothing

||| Roundtrip proof: decoding an encoded Transport yields the original.
public export
transportRoundtrip : (t : Transport) -> tagToTransport (transportToTag t) = Just t
transportRoundtrip UDP514  = Refl
transportRoundtrip TCP514  = Refl
transportRoundtrip TLS6514 = Refl
