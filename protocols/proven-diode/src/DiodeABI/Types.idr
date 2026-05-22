-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DiodeABI.Types: C-ABI-compatible numeric representations of Diode types.
--
-- Maps every constructor of the core Diode sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/diode.h) and the
-- Zig FFI enums (ffi/zig/src/diode.zig) exactly.
--
-- Types covered:
--   Direction        (2 constructors, tags 0-1)
--   Protocol         (5 constructors, tags 0-4)
--   TransferState    (5 constructors, tags 0-4)
--   ValidationResult (4 constructors, tags 0-3)
--   IntegrityCheck   (3 constructors, tags 0-2)
--   GatewayState     (5 constructors, tags 0-4)

module DiodeABI.Types

import Diode.Types

%default total

---------------------------------------------------------------------------
-- Direction (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
directionToTag : Direction -> Bits8
directionToTag HighToLow = 0
directionToTag LowToHigh = 1

public export
tagToDirection : Bits8 -> Maybe Direction
tagToDirection 0 = Just HighToLow
tagToDirection 1 = Just LowToHigh
tagToDirection _ = Nothing

public export
directionRoundtrip : (d : Direction) -> tagToDirection (directionToTag d) = Just d
directionRoundtrip HighToLow = Refl
directionRoundtrip LowToHigh = Refl

---------------------------------------------------------------------------
-- Protocol (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
protocolToTag : Protocol -> Bits8
protocolToTag UDP          = 0
protocolToTag TCP          = 1
protocolToTag FileTransfer = 2
protocolToTag Syslog       = 3
protocolToTag SNMP         = 4

public export
tagToProtocol : Bits8 -> Maybe Protocol
tagToProtocol 0 = Just UDP
tagToProtocol 1 = Just TCP
tagToProtocol 2 = Just FileTransfer
tagToProtocol 3 = Just Syslog
tagToProtocol 4 = Just SNMP
tagToProtocol _ = Nothing

public export
protocolRoundtrip : (p : Protocol) -> tagToProtocol (protocolToTag p) = Just p
protocolRoundtrip UDP          = Refl
protocolRoundtrip TCP          = Refl
protocolRoundtrip FileTransfer = Refl
protocolRoundtrip Syslog       = Refl
protocolRoundtrip SNMP         = Refl

---------------------------------------------------------------------------
-- TransferState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
transferStateToTag : TransferState -> Bits8
transferStateToTag Queued     = 0
transferStateToTag Sending    = 1
transferStateToTag Confirming = 2
transferStateToTag Complete   = 3
transferStateToTag Failed     = 4

public export
tagToTransferState : Bits8 -> Maybe TransferState
tagToTransferState 0 = Just Queued
tagToTransferState 1 = Just Sending
tagToTransferState 2 = Just Confirming
tagToTransferState 3 = Just Complete
tagToTransferState 4 = Just Failed
tagToTransferState _ = Nothing

public export
transferStateRoundtrip : (t : TransferState) -> tagToTransferState (transferStateToTag t) = Just t
transferStateRoundtrip Queued     = Refl
transferStateRoundtrip Sending    = Refl
transferStateRoundtrip Confirming = Refl
transferStateRoundtrip Complete   = Refl
transferStateRoundtrip Failed     = Refl

---------------------------------------------------------------------------
-- ValidationResult (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
validationResultToTag : ValidationResult -> Bits8
validationResultToTag Passed        = 0
validationResultToTag FormatError   = 1
validationResultToTag SizeExceeded  = 2
validationResultToTag PolicyBlocked = 3

public export
tagToValidationResult : Bits8 -> Maybe ValidationResult
tagToValidationResult 0 = Just Passed
tagToValidationResult 1 = Just FormatError
tagToValidationResult 2 = Just SizeExceeded
tagToValidationResult 3 = Just PolicyBlocked
tagToValidationResult _ = Nothing

public export
validationResultRoundtrip : (v : ValidationResult) -> tagToValidationResult (validationResultToTag v) = Just v
validationResultRoundtrip Passed        = Refl
validationResultRoundtrip FormatError   = Refl
validationResultRoundtrip SizeExceeded  = Refl
validationResultRoundtrip PolicyBlocked = Refl

---------------------------------------------------------------------------
-- IntegrityCheck (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
integrityCheckToTag : IntegrityCheck -> Bits8
integrityCheckToTag CRC32  = 0
integrityCheckToTag SHA256 = 1
integrityCheckToTag HMAC   = 2

public export
tagToIntegrityCheck : Bits8 -> Maybe IntegrityCheck
tagToIntegrityCheck 0 = Just CRC32
tagToIntegrityCheck 1 = Just SHA256
tagToIntegrityCheck 2 = Just HMAC
tagToIntegrityCheck _ = Nothing

public export
integrityCheckRoundtrip : (i : IntegrityCheck) -> tagToIntegrityCheck (integrityCheckToTag i) = Just i
integrityCheckRoundtrip CRC32  = Refl
integrityCheckRoundtrip SHA256 = Refl
integrityCheckRoundtrip HMAC   = Refl

---------------------------------------------------------------------------
-- GatewayState (5 constructors, tags 0-4)
-- Data diode gateway lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| Data diode gateway lifecycle states.
public export
data GatewayState : Type where
  ||| No gateway active. Initial and terminal state.
  GSIdle        : GatewayState
  ||| Gateway configured with direction and protocol.
  GSConfigured  : GatewayState
  ||| Actively transferring data through the diode.
  GSTransferring : GatewayState
  ||| Validating queued segments before transfer.
  GSValidating  : GatewayState
  ||| Shutting down, draining queues.
  GSShutdown    : GatewayState

public export
Eq GatewayState where
  GSIdle         == GSIdle         = True
  GSConfigured   == GSConfigured   = True
  GSTransferring == GSTransferring = True
  GSValidating   == GSValidating   = True
  GSShutdown     == GSShutdown     = True
  _              == _              = False

public export
Show GatewayState where
  show GSIdle         = "Idle"
  show GSConfigured   = "Configured"
  show GSTransferring = "Transferring"
  show GSValidating   = "Validating"
  show GSShutdown     = "Shutdown"

public export
gatewayStateToTag : GatewayState -> Bits8
gatewayStateToTag GSIdle         = 0
gatewayStateToTag GSConfigured   = 1
gatewayStateToTag GSTransferring = 2
gatewayStateToTag GSValidating   = 3
gatewayStateToTag GSShutdown     = 4

public export
tagToGatewayState : Bits8 -> Maybe GatewayState
tagToGatewayState 0 = Just GSIdle
tagToGatewayState 1 = Just GSConfigured
tagToGatewayState 2 = Just GSTransferring
tagToGatewayState 3 = Just GSValidating
tagToGatewayState 4 = Just GSShutdown
tagToGatewayState _ = Nothing

public export
gatewayStateRoundtrip : (g : GatewayState) -> tagToGatewayState (gatewayStateToTag g) = Just g
gatewayStateRoundtrip GSIdle         = Refl
gatewayStateRoundtrip GSConfigured   = Refl
gatewayStateRoundtrip GSTransferring = Refl
gatewayStateRoundtrip GSValidating   = Refl
gatewayStateRoundtrip GSShutdown     = Refl
