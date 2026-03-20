-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AirgapABI.Types: C-ABI-compatible numeric representations of Airgap types.
--
-- Maps every constructor of the core Airgap sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/airgap.h) and the
-- Zig FFI enums (ffi/zig/src/airgap.zig) exactly.
--
-- Types covered:
--   TransferDirection (2 constructors, tags 0-1)
--   MediaType         (4 constructors, tags 0-3)
--   ScanResult        (4 constructors, tags 0-3)
--   TransferState     (7 constructors, tags 0-6)
--   ValidationCheck   (5 constructors, tags 0-4)

module AirgapABI.Types

import Airgap.Types

%default total

---------------------------------------------------------------------------
-- TransferDirection (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
transferDirectionSize : Nat
transferDirectionSize = 1

||| Encode a TransferDirection to its ABI tag value.
public export
transferDirectionToTag : TransferDirection -> Bits8
transferDirectionToTag Import = 0
transferDirectionToTag Export = 1

||| Decode an ABI tag to a TransferDirection.
public export
tagToTransferDirection : Bits8 -> Maybe TransferDirection
tagToTransferDirection 0 = Just Import
tagToTransferDirection 1 = Just Export
tagToTransferDirection _ = Nothing

||| Roundtrip proof: decoding an encoded TransferDirection yields the original.
public export
transferDirectionRoundtrip : (d : TransferDirection) -> tagToTransferDirection (transferDirectionToTag d) = Just d
transferDirectionRoundtrip Import = Refl
transferDirectionRoundtrip Export = Refl

---------------------------------------------------------------------------
-- MediaType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
mediaTypeSize : Nat
mediaTypeSize = 1

||| Encode a MediaType to its ABI tag value.
public export
mediaTypeToTag : MediaType -> Bits8
mediaTypeToTag USB          = 0
mediaTypeToTag OpticalDisc  = 1
mediaTypeToTag TapeCartridge = 2
mediaTypeToTag DiodeLink    = 3

||| Decode an ABI tag to a MediaType.
public export
tagToMediaType : Bits8 -> Maybe MediaType
tagToMediaType 0 = Just USB
tagToMediaType 1 = Just OpticalDisc
tagToMediaType 2 = Just TapeCartridge
tagToMediaType 3 = Just DiodeLink
tagToMediaType _ = Nothing

||| Roundtrip proof: decoding an encoded MediaType yields the original.
public export
mediaTypeRoundtrip : (m : MediaType) -> tagToMediaType (mediaTypeToTag m) = Just m
mediaTypeRoundtrip USB          = Refl
mediaTypeRoundtrip OpticalDisc  = Refl
mediaTypeRoundtrip TapeCartridge = Refl
mediaTypeRoundtrip DiodeLink    = Refl

---------------------------------------------------------------------------
-- ScanResult (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
scanResultSize : Nat
scanResultSize = 1

||| Encode a ScanResult to its ABI tag value.
public export
scanResultToTag : ScanResult -> Bits8
scanResultToTag Clean       = 0
scanResultToTag Suspicious  = 1
scanResultToTag Malicious   = 2
scanResultToTag Unscannable = 3

||| Decode an ABI tag to a ScanResult.
public export
tagToScanResult : Bits8 -> Maybe ScanResult
tagToScanResult 0 = Just Clean
tagToScanResult 1 = Just Suspicious
tagToScanResult 2 = Just Malicious
tagToScanResult 3 = Just Unscannable
tagToScanResult _ = Nothing

||| Roundtrip proof: decoding an encoded ScanResult yields the original.
public export
scanResultRoundtrip : (r : ScanResult) -> tagToScanResult (scanResultToTag r) = Just r
scanResultRoundtrip Clean       = Refl
scanResultRoundtrip Suspicious  = Refl
scanResultRoundtrip Malicious   = Refl
scanResultRoundtrip Unscannable = Refl

---------------------------------------------------------------------------
-- TransferState (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
transferStateSize : Nat
transferStateSize = 1

||| Encode a TransferState to its ABI tag value.
public export
transferStateToTag : TransferState -> Bits8
transferStateToTag Pending    = 0
transferStateToTag Scanning   = 1
transferStateToTag Approved   = 2
transferStateToTag Rejected   = 3
transferStateToTag InProgress = 4
transferStateToTag Complete   = 5
transferStateToTag Failed     = 6

||| Decode an ABI tag to a TransferState.
public export
tagToTransferState : Bits8 -> Maybe TransferState
tagToTransferState 0 = Just Pending
tagToTransferState 1 = Just Scanning
tagToTransferState 2 = Just Approved
tagToTransferState 3 = Just Rejected
tagToTransferState 4 = Just InProgress
tagToTransferState 5 = Just Complete
tagToTransferState 6 = Just Failed
tagToTransferState _ = Nothing

||| Roundtrip proof: decoding an encoded TransferState yields the original.
public export
transferStateRoundtrip : (s : TransferState) -> tagToTransferState (transferStateToTag s) = Just s
transferStateRoundtrip Pending    = Refl
transferStateRoundtrip Scanning   = Refl
transferStateRoundtrip Approved   = Refl
transferStateRoundtrip Rejected   = Refl
transferStateRoundtrip InProgress = Refl
transferStateRoundtrip Complete   = Refl
transferStateRoundtrip Failed     = Refl

---------------------------------------------------------------------------
-- ValidationCheck (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
validationCheckSize : Nat
validationCheckSize = 1

||| Encode a ValidationCheck to its ABI tag value.
public export
validationCheckToTag : ValidationCheck -> Bits8
validationCheckToTag HashVerify        = 0
validationCheckToTag SignatureVerify   = 1
validationCheckToTag FormatCheck       = 2
validationCheckToTag ContentInspection = 3
validationCheckToTag MalwareScan       = 4

||| Decode an ABI tag to a ValidationCheck.
public export
tagToValidationCheck : Bits8 -> Maybe ValidationCheck
tagToValidationCheck 0 = Just HashVerify
tagToValidationCheck 1 = Just SignatureVerify
tagToValidationCheck 2 = Just FormatCheck
tagToValidationCheck 3 = Just ContentInspection
tagToValidationCheck 4 = Just MalwareScan
tagToValidationCheck _ = Nothing

||| Roundtrip proof: decoding an encoded ValidationCheck yields the original.
public export
validationCheckRoundtrip : (v : ValidationCheck) -> tagToValidationCheck (validationCheckToTag v) = Just v
validationCheckRoundtrip HashVerify        = Refl
validationCheckRoundtrip SignatureVerify   = Refl
validationCheckRoundtrip FormatCheck       = Refl
validationCheckRoundtrip ContentInspection = Refl
validationCheckRoundtrip MalwareScan       = Refl
