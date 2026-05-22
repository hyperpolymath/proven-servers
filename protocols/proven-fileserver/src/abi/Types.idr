-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FileserverABI.Types: C-ABI-compatible numeric representations of
-- file server types.
--
-- Maps every constructor of the core Fileserver sum types to fixed Bits8
-- values for C interop. Each type gets a total encoder, partial decoder,
-- and roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/fileserver.zig)
-- exactly.
--
-- Types covered:
--   Operation    (10 constructors, tags 0-9)
--   FileType     (7 constructors,  tags 0-6)
--   Permission   (9 constructors,  tags 0-8)
--   LockType     (4 constructors,  tags 0-3)
--   ErrorCode    (10 constructors, tags 0-9)
--   SessionState (5 constructors,  tags 0-4)

module FileserverABI.Types

import Fileserver.Types

%default total

---------------------------------------------------------------------------
-- Operation (10 constructors, tags 0-9)
---------------------------------------------------------------------------

public export
operationToTag : Operation -> Bits8
operationToTag Read   = 0
operationToTag Write  = 1
operationToTag Create = 2
operationToTag Delete = 3
operationToTag Rename = 4
operationToTag List   = 5
operationToTag Stat   = 6
operationToTag Lock   = 7
operationToTag Unlock = 8
operationToTag Watch  = 9

public export
tagToOperation : Bits8 -> Maybe Operation
tagToOperation 0 = Just Read
tagToOperation 1 = Just Write
tagToOperation 2 = Just Create
tagToOperation 3 = Just Delete
tagToOperation 4 = Just Rename
tagToOperation 5 = Just List
tagToOperation 6 = Just Stat
tagToOperation 7 = Just Lock
tagToOperation 8 = Just Unlock
tagToOperation 9 = Just Watch
tagToOperation _ = Nothing

public export
operationRoundtrip : (o : Operation) -> tagToOperation (operationToTag o) = Just o
operationRoundtrip Read   = Refl
operationRoundtrip Write  = Refl
operationRoundtrip Create = Refl
operationRoundtrip Delete = Refl
operationRoundtrip Rename = Refl
operationRoundtrip List   = Refl
operationRoundtrip Stat   = Refl
operationRoundtrip Lock   = Refl
operationRoundtrip Unlock = Refl
operationRoundtrip Watch  = Refl

---------------------------------------------------------------------------
-- FileType (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
fileTypeToTag : FileType -> Bits8
fileTypeToTag Regular     = 0
fileTypeToTag Directory   = 1
fileTypeToTag Symlink     = 2
fileTypeToTag BlockDevice = 3
fileTypeToTag CharDevice  = 4
fileTypeToTag FIFO        = 5
fileTypeToTag Socket      = 6

public export
tagToFileType : Bits8 -> Maybe FileType
tagToFileType 0 = Just Regular
tagToFileType 1 = Just Directory
tagToFileType 2 = Just Symlink
tagToFileType 3 = Just BlockDevice
tagToFileType 4 = Just CharDevice
tagToFileType 5 = Just FIFO
tagToFileType 6 = Just Socket
tagToFileType _ = Nothing

public export
fileTypeRoundtrip : (f : FileType) -> tagToFileType (fileTypeToTag f) = Just f
fileTypeRoundtrip Regular     = Refl
fileTypeRoundtrip Directory   = Refl
fileTypeRoundtrip Symlink     = Refl
fileTypeRoundtrip BlockDevice = Refl
fileTypeRoundtrip CharDevice  = Refl
fileTypeRoundtrip FIFO        = Refl
fileTypeRoundtrip Socket      = Refl

---------------------------------------------------------------------------
-- Permission (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
permissionToTag : Permission -> Bits8
permissionToTag OwnerRead     = 0
permissionToTag OwnerWrite    = 1
permissionToTag OwnerExecute  = 2
permissionToTag GroupRead     = 3
permissionToTag GroupWrite    = 4
permissionToTag GroupExecute  = 5
permissionToTag OtherRead     = 6
permissionToTag OtherWrite    = 7
permissionToTag OtherExecute  = 8

public export
tagToPermission : Bits8 -> Maybe Permission
tagToPermission 0 = Just OwnerRead
tagToPermission 1 = Just OwnerWrite
tagToPermission 2 = Just OwnerExecute
tagToPermission 3 = Just GroupRead
tagToPermission 4 = Just GroupWrite
tagToPermission 5 = Just GroupExecute
tagToPermission 6 = Just OtherRead
tagToPermission 7 = Just OtherWrite
tagToPermission 8 = Just OtherExecute
tagToPermission _ = Nothing

public export
permissionRoundtrip : (p : Permission) -> tagToPermission (permissionToTag p) = Just p
permissionRoundtrip OwnerRead     = Refl
permissionRoundtrip OwnerWrite    = Refl
permissionRoundtrip OwnerExecute  = Refl
permissionRoundtrip GroupRead     = Refl
permissionRoundtrip GroupWrite    = Refl
permissionRoundtrip GroupExecute  = Refl
permissionRoundtrip OtherRead     = Refl
permissionRoundtrip OtherWrite    = Refl
permissionRoundtrip OtherExecute  = Refl

---------------------------------------------------------------------------
-- LockType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
lockTypeToTag : LockType -> Bits8
lockTypeToTag Shared    = 0
lockTypeToTag Exclusive = 1
lockTypeToTag Advisory  = 2
lockTypeToTag Mandatory = 3

public export
tagToLockType : Bits8 -> Maybe LockType
tagToLockType 0 = Just Shared
tagToLockType 1 = Just Exclusive
tagToLockType 2 = Just Advisory
tagToLockType 3 = Just Mandatory
tagToLockType _ = Nothing

public export
lockTypeRoundtrip : (l : LockType) -> tagToLockType (lockTypeToTag l) = Just l
lockTypeRoundtrip Shared    = Refl
lockTypeRoundtrip Exclusive = Refl
lockTypeRoundtrip Advisory  = Refl
lockTypeRoundtrip Mandatory = Refl

---------------------------------------------------------------------------
-- ErrorCode (10 constructors, tags 0-9)
---------------------------------------------------------------------------

public export
errorCodeToTag : ErrorCode -> Bits8
errorCodeToTag NotFound         = 0
errorCodeToTag PermissionDenied = 1
errorCodeToTag AlreadyExists    = 2
errorCodeToTag NotEmpty         = 3
errorCodeToTag IsDirectory      = 4
errorCodeToTag NotDirectory     = 5
errorCodeToTag NoSpace          = 6
errorCodeToTag ReadOnly         = 7
errorCodeToTag Locked           = 8
errorCodeToTag IOError          = 9

public export
tagToErrorCode : Bits8 -> Maybe ErrorCode
tagToErrorCode 0 = Just NotFound
tagToErrorCode 1 = Just PermissionDenied
tagToErrorCode 2 = Just AlreadyExists
tagToErrorCode 3 = Just NotEmpty
tagToErrorCode 4 = Just IsDirectory
tagToErrorCode 5 = Just NotDirectory
tagToErrorCode 6 = Just NoSpace
tagToErrorCode 7 = Just ReadOnly
tagToErrorCode 8 = Just Locked
tagToErrorCode 9 = Just IOError
tagToErrorCode _ = Nothing

public export
errorCodeRoundtrip : (e : ErrorCode) -> tagToErrorCode (errorCodeToTag e) = Just e
errorCodeRoundtrip NotFound         = Refl
errorCodeRoundtrip PermissionDenied = Refl
errorCodeRoundtrip AlreadyExists    = Refl
errorCodeRoundtrip NotEmpty         = Refl
errorCodeRoundtrip IsDirectory      = Refl
errorCodeRoundtrip NotDirectory     = Refl
errorCodeRoundtrip NoSpace          = Refl
errorCodeRoundtrip ReadOnly         = Refl
errorCodeRoundtrip Locked           = Refl
errorCodeRoundtrip IOError          = Refl

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| File server session lifecycle states.
public export
data SessionState : Type where
  ||| No connection. Initial and terminal state.
  FSSIdle          : SessionState
  ||| Connection established, ready for operations.
  FSSConnected     : SessionState
  ||| Performing a file operation.
  FSSOperating     : SessionState
  ||| A file lock is held.
  FSSLocked        : SessionState
  ||| Connection shutting down.
  FSSDisconnecting : SessionState

public export
Eq SessionState where
  FSSIdle          == FSSIdle          = True
  FSSConnected     == FSSConnected     = True
  FSSOperating     == FSSOperating     = True
  FSSLocked        == FSSLocked        = True
  FSSDisconnecting == FSSDisconnecting = True
  _                == _                = False

public export
Show SessionState where
  show FSSIdle          = "Idle"
  show FSSConnected     = "Connected"
  show FSSOperating     = "Operating"
  show FSSLocked        = "Locked"
  show FSSDisconnecting = "Disconnecting"

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag FSSIdle          = 0
sessionStateToTag FSSConnected     = 1
sessionStateToTag FSSOperating     = 2
sessionStateToTag FSSLocked        = 3
sessionStateToTag FSSDisconnecting = 4

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just FSSIdle
tagToSessionState 1 = Just FSSConnected
tagToSessionState 2 = Just FSSOperating
tagToSessionState 3 = Just FSSLocked
tagToSessionState 4 = Just FSSDisconnecting
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip FSSIdle          = Refl
sessionStateRoundtrip FSSConnected     = Refl
sessionStateRoundtrip FSSOperating     = Refl
sessionStateRoundtrip FSSLocked        = Refl
sessionStateRoundtrip FSSDisconnecting = Refl

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

public export
data ValidSessionTransition : SessionState -> SessionState -> Type where
  ClientConnected      : ValidSessionTransition FSSIdle FSSConnected
  BeginOperation       : ValidSessionTransition FSSConnected FSSOperating
  OperationDone        : ValidSessionTransition FSSOperating FSSConnected
  AcquireLock          : ValidSessionTransition FSSConnected FSSLocked
  OperateWhileLocked   : ValidSessionTransition FSSLocked FSSOperating
  OperationDoneLocked  : ValidSessionTransition FSSOperating FSSLocked
  ReleaseLock          : ValidSessionTransition FSSLocked FSSConnected
  DisconnectFromConn   : ValidSessionTransition FSSConnected FSSDisconnecting
  DisconnectFromLocked : ValidSessionTransition FSSLocked FSSDisconnecting
  DisconnectFromOp     : ValidSessionTransition FSSOperating FSSDisconnecting
  CleanupDone          : ValidSessionTransition FSSDisconnecting FSSIdle

public export
validateSessionTransition : (from : SessionState) -> (to : SessionState)
                          -> Maybe (ValidSessionTransition from to)
validateSessionTransition FSSIdle          FSSConnected     = Just ClientConnected
validateSessionTransition FSSConnected     FSSOperating     = Just BeginOperation
validateSessionTransition FSSOperating     FSSConnected     = Just OperationDone
validateSessionTransition FSSConnected     FSSLocked        = Just AcquireLock
validateSessionTransition FSSLocked        FSSOperating     = Just OperateWhileLocked
validateSessionTransition FSSOperating     FSSLocked        = Just OperationDoneLocked
validateSessionTransition FSSLocked        FSSConnected     = Just ReleaseLock
validateSessionTransition FSSConnected     FSSDisconnecting = Just DisconnectFromConn
validateSessionTransition FSSLocked        FSSDisconnecting = Just DisconnectFromLocked
validateSessionTransition FSSOperating     FSSDisconnecting = Just DisconnectFromOp
validateSessionTransition FSSDisconnecting FSSIdle          = Just CleanupDone
validateSessionTransition _                _                = Nothing

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

public export
idleCannotOperate : ValidSessionTransition FSSIdle FSSOperating -> Void
idleCannotOperate _ impossible

public export
cannotReconnectFromDisconnecting : ValidSessionTransition FSSDisconnecting FSSConnected -> Void
cannotReconnectFromDisconnecting _ impossible
