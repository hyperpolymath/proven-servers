-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DiodeABI.Types: C-ABI-compatible numeric representations of Diode types.
--
-- Maps every constructor of the core Diode sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/diode.zig) exactly.
--
-- Types covered:
--   Direction                 (2 constructors, tags 0-1)
--   Protocol                  (5 constructors, tags 0-4)
--   TransferState             (5 constructors, tags 0-4)
--   ValidationResult          (4 constructors, tags 0-3)
--   IntegrityCheck            (3 constructors, tags 0-2)
--   GatewayState              (5 constructors, tags 0-4)

module DiodeABI.Types

%default total

---------------------------------------------------------------------------
-- Direction (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
directionSize : Nat
directionSize = 1

||| Direction sum type for ABI encoding.
public export
data Direction : Type where
  HighToLow : Direction
  LowToHigh : Direction

||| Encode a Direction to its ABI tag value.
public export
directionToTag : Direction -> Bits8
directionToTag HighToLow = 0
directionToTag LowToHigh = 1

||| Decode an ABI tag to a Direction.
public export
tagToDirection : Bits8 -> Maybe Direction
tagToDirection 0 = Just HighToLow
tagToDirection 1 = Just LowToHigh
tagToDirection _ = Nothing

||| Roundtrip proof: decoding an encoded Direction yields the original.
public export
directionRoundtrip : (x : Direction) -> tagToDirection (directionToTag x) = Just x
directionRoundtrip HighToLow = Refl
directionRoundtrip LowToHigh = Refl

---------------------------------------------------------------------------
-- Protocol (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
protocolSize : Nat
protocolSize = 1

||| Protocol sum type for ABI encoding.
public export
data Protocol : Type where
  Udp : Protocol
  Tcp : Protocol
  FileTransfer : Protocol
  Syslog : Protocol
  Snmp : Protocol

||| Encode a Protocol to its ABI tag value.
public export
protocolToTag : Protocol -> Bits8
protocolToTag Udp = 0
protocolToTag Tcp = 1
protocolToTag FileTransfer = 2
protocolToTag Syslog = 3
protocolToTag Snmp = 4

||| Decode an ABI tag to a Protocol.
public export
tagToProtocol : Bits8 -> Maybe Protocol
tagToProtocol 0 = Just Udp
tagToProtocol 1 = Just Tcp
tagToProtocol 2 = Just FileTransfer
tagToProtocol 3 = Just Syslog
tagToProtocol 4 = Just Snmp
tagToProtocol _ = Nothing

||| Roundtrip proof: decoding an encoded Protocol yields the original.
public export
protocolRoundtrip : (x : Protocol) -> tagToProtocol (protocolToTag x) = Just x
protocolRoundtrip Udp = Refl
protocolRoundtrip Tcp = Refl
protocolRoundtrip FileTransfer = Refl
protocolRoundtrip Syslog = Refl
protocolRoundtrip Snmp = Refl

---------------------------------------------------------------------------
-- TransferState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
transfer_stateSize : Nat
transfer_stateSize = 1

||| TransferState sum type for ABI encoding.
public export
data TransferState : Type where
  Queued : TransferState
  Sending : TransferState
  Confirming : TransferState
  Complete : TransferState
  Failed : TransferState

||| Encode a TransferState to its ABI tag value.
public export
transfer_stateToTag : TransferState -> Bits8
transfer_stateToTag Queued = 0
transfer_stateToTag Sending = 1
transfer_stateToTag Confirming = 2
transfer_stateToTag Complete = 3
transfer_stateToTag Failed = 4

||| Decode an ABI tag to a TransferState.
public export
tagToTransferState : Bits8 -> Maybe TransferState
tagToTransferState 0 = Just Queued
tagToTransferState 1 = Just Sending
tagToTransferState 2 = Just Confirming
tagToTransferState 3 = Just Complete
tagToTransferState 4 = Just Failed
tagToTransferState _ = Nothing

||| Roundtrip proof: decoding an encoded TransferState yields the original.
public export
transfer_stateRoundtrip : (x : TransferState) -> tagToTransferState (transfer_stateToTag x) = Just x
transfer_stateRoundtrip Queued = Refl
transfer_stateRoundtrip Sending = Refl
transfer_stateRoundtrip Confirming = Refl
transfer_stateRoundtrip Complete = Refl
transfer_stateRoundtrip Failed = Refl

---------------------------------------------------------------------------
-- ValidationResult (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
validation_resultSize : Nat
validation_resultSize = 1

||| ValidationResult sum type for ABI encoding.
public export
data ValidationResult : Type where
  Passed : ValidationResult
  FormatError : ValidationResult
  SizeExceeded : ValidationResult
  PolicyBlocked : ValidationResult

||| Encode a ValidationResult to its ABI tag value.
public export
validation_resultToTag : ValidationResult -> Bits8
validation_resultToTag Passed = 0
validation_resultToTag FormatError = 1
validation_resultToTag SizeExceeded = 2
validation_resultToTag PolicyBlocked = 3

||| Decode an ABI tag to a ValidationResult.
public export
tagToValidationResult : Bits8 -> Maybe ValidationResult
tagToValidationResult 0 = Just Passed
tagToValidationResult 1 = Just FormatError
tagToValidationResult 2 = Just SizeExceeded
tagToValidationResult 3 = Just PolicyBlocked
tagToValidationResult _ = Nothing

||| Roundtrip proof: decoding an encoded ValidationResult yields the original.
public export
validation_resultRoundtrip : (x : ValidationResult) -> tagToValidationResult (validation_resultToTag x) = Just x
validation_resultRoundtrip Passed = Refl
validation_resultRoundtrip FormatError = Refl
validation_resultRoundtrip SizeExceeded = Refl
validation_resultRoundtrip PolicyBlocked = Refl

---------------------------------------------------------------------------
-- IntegrityCheck (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
integrity_checkSize : Nat
integrity_checkSize = 1

||| IntegrityCheck sum type for ABI encoding.
public export
data IntegrityCheck : Type where
  Crc32 : IntegrityCheck
  Sha256 : IntegrityCheck
  Hmac : IntegrityCheck

||| Encode a IntegrityCheck to its ABI tag value.
public export
integrity_checkToTag : IntegrityCheck -> Bits8
integrity_checkToTag Crc32 = 0
integrity_checkToTag Sha256 = 1
integrity_checkToTag Hmac = 2

||| Decode an ABI tag to a IntegrityCheck.
public export
tagToIntegrityCheck : Bits8 -> Maybe IntegrityCheck
tagToIntegrityCheck 0 = Just Crc32
tagToIntegrityCheck 1 = Just Sha256
tagToIntegrityCheck 2 = Just Hmac
tagToIntegrityCheck _ = Nothing

||| Roundtrip proof: decoding an encoded IntegrityCheck yields the original.
public export
integrity_checkRoundtrip : (x : IntegrityCheck) -> tagToIntegrityCheck (integrity_checkToTag x) = Just x
integrity_checkRoundtrip Crc32 = Refl
integrity_checkRoundtrip Sha256 = Refl
integrity_checkRoundtrip Hmac = Refl

---------------------------------------------------------------------------
-- GatewayState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
gateway_stateSize : Nat
gateway_stateSize = 1

||| GatewayState sum type for ABI encoding.
public export
data GatewayState : Type where
  Idle : GatewayState
  Configured : GatewayState
  Transferring : GatewayState
  Validating : GatewayState
  Shutdown : GatewayState

||| Encode a GatewayState to its ABI tag value.
public export
gateway_stateToTag : GatewayState -> Bits8
gateway_stateToTag Idle = 0
gateway_stateToTag Configured = 1
gateway_stateToTag Transferring = 2
gateway_stateToTag Validating = 3
gateway_stateToTag Shutdown = 4

||| Decode an ABI tag to a GatewayState.
public export
tagToGatewayState : Bits8 -> Maybe GatewayState
tagToGatewayState 0 = Just Idle
tagToGatewayState 1 = Just Configured
tagToGatewayState 2 = Just Transferring
tagToGatewayState 3 = Just Validating
tagToGatewayState 4 = Just Shutdown
tagToGatewayState _ = Nothing

||| Roundtrip proof: decoding an encoded GatewayState yields the original.
public export
gateway_stateRoundtrip : (x : GatewayState) -> tagToGatewayState (gateway_stateToTag x) = Just x
gateway_stateRoundtrip Idle = Refl
gateway_stateRoundtrip Configured = Refl
gateway_stateRoundtrip Transferring = Refl
gateway_stateRoundtrip Validating = Refl
gateway_stateRoundtrip Shutdown = Refl
