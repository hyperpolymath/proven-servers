-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- TFTPABI Types: C-ABI-compatible numeric representations of TFTP types.
--
-- Maps every constructor of the core TFTP sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/tftp.zig) exactly.
--
-- Types covered:
--   Opcode        (5 constructors, tags 0-4)
--   TransferMode  (3 constructors, tags 0-2)
--   TFTPError     (8 constructors, tags 0-7)
--   TransferState (5 constructors, tags 0-4)

module TFTPABI.Types

import TFTP.Opcode
import TFTP.Mode
import TFTP.Error
import TFTP.Transfer

%default total

---------------------------------------------------------------------------
-- Opcode (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
opcodeABISize : Nat
opcodeABISize = 1

||| Encode an Opcode to its ABI tag value.
public export
opcodeToTag : Opcode -> Bits8
opcodeToTag RRQ   = 0
opcodeToTag WRQ   = 1
opcodeToTag DATA  = 2
opcodeToTag ACK   = 3
opcodeToTag ERROR = 4

||| Decode an ABI tag to an Opcode.
public export
tagToOpcode : Bits8 -> Maybe Opcode
tagToOpcode 0 = Just RRQ
tagToOpcode 1 = Just WRQ
tagToOpcode 2 = Just DATA
tagToOpcode 3 = Just ACK
tagToOpcode 4 = Just ERROR
tagToOpcode _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all Opcode values.
public export
opcodeRoundtrip : (o : Opcode) -> tagToOpcode (opcodeToTag o) = Just o
opcodeRoundtrip RRQ   = Refl
opcodeRoundtrip WRQ   = Refl
opcodeRoundtrip DATA  = Refl
opcodeRoundtrip ACK   = Refl
opcodeRoundtrip ERROR = Refl

---------------------------------------------------------------------------
-- TransferMode (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
transferModeSize : Nat
transferModeSize = 1

||| Encode a TransferMode to its ABI tag value.
public export
transferModeToTag : TransferMode -> Bits8
transferModeToTag NetASCII = 0
transferModeToTag Octet    = 1
transferModeToTag Mail     = 2

||| Decode an ABI tag to a TransferMode.
public export
tagToTransferMode : Bits8 -> Maybe TransferMode
tagToTransferMode 0 = Just NetASCII
tagToTransferMode 1 = Just Octet
tagToTransferMode 2 = Just Mail
tagToTransferMode _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all TransferMode values.
public export
transferModeRoundtrip : (m : TransferMode) -> tagToTransferMode (transferModeToTag m) = Just m
transferModeRoundtrip NetASCII = Refl
transferModeRoundtrip Octet    = Refl
transferModeRoundtrip Mail     = Refl

---------------------------------------------------------------------------
-- TFTPError (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
tftpErrorSize : Nat
tftpErrorSize = 1

||| Encode a TFTPError to its ABI tag value.
public export
tftpErrorToTag : TFTPError -> Bits8
tftpErrorToTag NotDefined       = 0
tftpErrorToTag FileNotFound     = 1
tftpErrorToTag AccessViolation  = 2
tftpErrorToTag DiskFull         = 3
tftpErrorToTag IllegalOperation = 4
tftpErrorToTag UnknownTID       = 5
tftpErrorToTag FileExists       = 6
tftpErrorToTag NoSuchUser       = 7

||| Decode an ABI tag to a TFTPError.
public export
tagToTFTPError : Bits8 -> Maybe TFTPError
tagToTFTPError 0 = Just NotDefined
tagToTFTPError 1 = Just FileNotFound
tagToTFTPError 2 = Just AccessViolation
tagToTFTPError 3 = Just DiskFull
tagToTFTPError 4 = Just IllegalOperation
tagToTFTPError 5 = Just UnknownTID
tagToTFTPError 6 = Just FileExists
tagToTFTPError 7 = Just NoSuchUser
tagToTFTPError _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all TFTPError values.
public export
tftpErrorRoundtrip : (e : TFTPError) -> tagToTFTPError (tftpErrorToTag e) = Just e
tftpErrorRoundtrip NotDefined       = Refl
tftpErrorRoundtrip FileNotFound     = Refl
tftpErrorRoundtrip AccessViolation  = Refl
tftpErrorRoundtrip DiskFull         = Refl
tftpErrorRoundtrip IllegalOperation = Refl
tftpErrorRoundtrip UnknownTID       = Refl
tftpErrorRoundtrip FileExists       = Refl
tftpErrorRoundtrip NoSuchUser       = Refl

---------------------------------------------------------------------------
-- TransferState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
transferStateSize : Nat
transferStateSize = 1

||| Encode a TransferState to its ABI tag value.
public export
transferStateToTag : TransferState -> Bits8
transferStateToTag Idle     = 0
transferStateToTag Reading  = 1
transferStateToTag Writing  = 2
transferStateToTag InError  = 3
transferStateToTag Complete = 4

||| Decode an ABI tag to a TransferState.
public export
tagToTransferState : Bits8 -> Maybe TransferState
tagToTransferState 0 = Just Idle
tagToTransferState 1 = Just Reading
tagToTransferState 2 = Just Writing
tagToTransferState 3 = Just InError
tagToTransferState 4 = Just Complete
tagToTransferState _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all TransferState values.
public export
transferStateRoundtrip : (s : TransferState) -> tagToTransferState (transferStateToTag s) = Just s
transferStateRoundtrip Idle     = Refl
transferStateRoundtrip Reading  = Refl
transferStateRoundtrip Writing  = Refl
transferStateRoundtrip InError  = Refl
transferStateRoundtrip Complete = Refl
