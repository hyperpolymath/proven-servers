-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- NetconfABI.Types: C-ABI-compatible numeric representations of NETCONF types.
--
-- Maps every constructor of the core NETCONF sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/netconf.zig) exactly.
--
-- Types covered:
--   Operation      (12 constructors, tags 0-11)
--   Datastore      (3 constructors, tags 0-2)
--   EditOperation  (5 constructors, tags 0-4)
--   ErrorType      (4 constructors, tags 0-3)
--   ErrorSeverity  (2 constructors, tags 0-1)

module NetconfABI.Types

import NETCONF.Types

%default total

---------------------------------------------------------------------------
-- Operation (12 constructors, tags 0-11)
---------------------------------------------------------------------------

public export
operationToTag : Operation -> Bits8
operationToTag Get            = 0
operationToTag GetConfig      = 1
operationToTag EditConfig     = 2
operationToTag CopyConfig     = 3
operationToTag DeleteConfig   = 4
operationToTag Lock           = 5
operationToTag Unlock         = 6
operationToTag CloseSession   = 7
operationToTag KillSession    = 8
operationToTag Commit         = 9
operationToTag Validate       = 10
operationToTag DiscardChanges = 11

public export
tagToOperation : Bits8 -> Maybe Operation
tagToOperation 0  = Just Get
tagToOperation 1  = Just GetConfig
tagToOperation 2  = Just EditConfig
tagToOperation 3  = Just CopyConfig
tagToOperation 4  = Just DeleteConfig
tagToOperation 5  = Just Lock
tagToOperation 6  = Just Unlock
tagToOperation 7  = Just CloseSession
tagToOperation 8  = Just KillSession
tagToOperation 9  = Just Commit
tagToOperation 10 = Just Validate
tagToOperation 11 = Just DiscardChanges
tagToOperation _  = Nothing

public export
operationRoundtrip : (o : Operation) -> tagToOperation (operationToTag o) = Just o
operationRoundtrip Get            = Refl
operationRoundtrip GetConfig      = Refl
operationRoundtrip EditConfig     = Refl
operationRoundtrip CopyConfig     = Refl
operationRoundtrip DeleteConfig   = Refl
operationRoundtrip Lock           = Refl
operationRoundtrip Unlock         = Refl
operationRoundtrip CloseSession   = Refl
operationRoundtrip KillSession    = Refl
operationRoundtrip Commit         = Refl
operationRoundtrip Validate       = Refl
operationRoundtrip DiscardChanges = Refl

---------------------------------------------------------------------------
-- Datastore (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
datastoreToTag : Datastore -> Bits8
datastoreToTag Running   = 0
datastoreToTag Startup   = 1
datastoreToTag Candidate = 2

public export
tagToDatastore : Bits8 -> Maybe Datastore
tagToDatastore 0 = Just Running
tagToDatastore 1 = Just Startup
tagToDatastore 2 = Just Candidate
tagToDatastore _ = Nothing

public export
datastoreRoundtrip : (d : Datastore) -> tagToDatastore (datastoreToTag d) = Just d
datastoreRoundtrip Running   = Refl
datastoreRoundtrip Startup   = Refl
datastoreRoundtrip Candidate = Refl

---------------------------------------------------------------------------
-- EditOperation (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
editOperationToTag : EditOperation -> Bits8
editOperationToTag Merge   = 0
editOperationToTag Replace = 1
editOperationToTag Create  = 2
editOperationToTag Delete  = 3
editOperationToTag Remove  = 4

public export
tagToEditOperation : Bits8 -> Maybe EditOperation
tagToEditOperation 0 = Just Merge
tagToEditOperation 1 = Just Replace
tagToEditOperation 2 = Just Create
tagToEditOperation 3 = Just Delete
tagToEditOperation 4 = Just Remove
tagToEditOperation _ = Nothing

public export
editOperationRoundtrip : (e : EditOperation) -> tagToEditOperation (editOperationToTag e) = Just e
editOperationRoundtrip Merge   = Refl
editOperationRoundtrip Replace = Refl
editOperationRoundtrip Create  = Refl
editOperationRoundtrip Delete  = Refl
editOperationRoundtrip Remove  = Refl

---------------------------------------------------------------------------
-- ErrorType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
errorTypeToTag : ErrorType -> Bits8
errorTypeToTag Transport   = 0
errorTypeToTag RPC         = 1
errorTypeToTag Protocol    = 2
errorTypeToTag Application = 3

public export
tagToErrorType : Bits8 -> Maybe ErrorType
tagToErrorType 0 = Just Transport
tagToErrorType 1 = Just RPC
tagToErrorType 2 = Just Protocol
tagToErrorType 3 = Just Application
tagToErrorType _ = Nothing

public export
errorTypeRoundtrip : (e : ErrorType) -> tagToErrorType (errorTypeToTag e) = Just e
errorTypeRoundtrip Transport   = Refl
errorTypeRoundtrip RPC         = Refl
errorTypeRoundtrip Protocol    = Refl
errorTypeRoundtrip Application = Refl

---------------------------------------------------------------------------
-- ErrorSeverity (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
errorSeverityToTag : ErrorSeverity -> Bits8
errorSeverityToTag Error   = 0
errorSeverityToTag Warning = 1

public export
tagToErrorSeverity : Bits8 -> Maybe ErrorSeverity
tagToErrorSeverity 0 = Just Error
tagToErrorSeverity 1 = Just Warning
tagToErrorSeverity _ = Nothing

public export
errorSeverityRoundtrip : (s : ErrorSeverity) -> tagToErrorSeverity (errorSeverityToTag s) = Just s
errorSeverityRoundtrip Error   = Refl
errorSeverityRoundtrip Warning = Refl

---------------------------------------------------------------------------
-- NetconfState: Composite lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| NETCONF session lifecycle states used by the FFI layer.
public export
data NetconfState : Type where
  ||| No session. Initial state.
  NCIdle        : NetconfState
  ||| SSH/TLS transport established, NETCONF hello exchanged.
  NCConnected   : NetconfState
  ||| A datastore lock is held.
  NCLocked      : NetconfState
  ||| Edit-config in progress (candidate datastore modified).
  NCEditing     : NetconfState
  ||| Session closing (close-session sent).
  NCClosing     : NetconfState
  ||| Session terminated (kill-session or error).
  NCTerminated  : NetconfState

public export
Eq NetconfState where
  NCIdle       == NCIdle       = True
  NCConnected  == NCConnected  = True
  NCLocked     == NCLocked     = True
  NCEditing    == NCEditing    = True
  NCClosing    == NCClosing    = True
  NCTerminated == NCTerminated = True
  _            == _            = False

public export
Show NetconfState where
  show NCIdle       = "Idle"
  show NCConnected  = "Connected"
  show NCLocked     = "Locked"
  show NCEditing    = "Editing"
  show NCClosing    = "Closing"
  show NCTerminated = "Terminated"

public export
netconfStateToTag : NetconfState -> Bits8
netconfStateToTag NCIdle       = 0
netconfStateToTag NCConnected  = 1
netconfStateToTag NCLocked     = 2
netconfStateToTag NCEditing    = 3
netconfStateToTag NCClosing    = 4
netconfStateToTag NCTerminated = 5

public export
tagToNetconfState : Bits8 -> Maybe NetconfState
tagToNetconfState 0 = Just NCIdle
tagToNetconfState 1 = Just NCConnected
tagToNetconfState 2 = Just NCLocked
tagToNetconfState 3 = Just NCEditing
tagToNetconfState 4 = Just NCClosing
tagToNetconfState 5 = Just NCTerminated
tagToNetconfState _ = Nothing

public export
netconfStateRoundtrip : (s : NetconfState) -> tagToNetconfState (netconfStateToTag s) = Just s
netconfStateRoundtrip NCIdle       = Refl
netconfStateRoundtrip NCConnected  = Refl
netconfStateRoundtrip NCLocked     = Refl
netconfStateRoundtrip NCEditing    = Refl
netconfStateRoundtrip NCClosing    = Refl
netconfStateRoundtrip NCTerminated = Refl
