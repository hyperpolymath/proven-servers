-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NFSABI.Types: C-ABI-compatible numeric representations of NFS types.
--
-- Maps every constructor of the core NFS sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/nfs.zig) exactly.
--
-- Types covered:
--   Operation  (15 constructors, tags 0-14)
--   FileType   (7 constructors, tags 0-6)
--   Status     (14 constructors, tags 0-13)

module NFSABI.Types

import NFS.Types

%default total

---------------------------------------------------------------------------
-- Operation (15 constructors, tags 0-14)
---------------------------------------------------------------------------

public export
operationToTag : Operation -> Bits8
operationToTag Access  = 0
operationToTag Close   = 1
operationToTag Commit  = 2
operationToTag Create  = 3
operationToTag GetAttr = 4
operationToTag Link    = 5
operationToTag Lock    = 6
operationToTag Lookup  = 7
operationToTag Open    = 8
operationToTag Read    = 9
operationToTag ReadDir = 10
operationToTag Remove  = 11
operationToTag Rename  = 12
operationToTag SetAttr = 13
operationToTag Write   = 14

public export
tagToOperation : Bits8 -> Maybe Operation
tagToOperation 0  = Just Access
tagToOperation 1  = Just Close
tagToOperation 2  = Just Commit
tagToOperation 3  = Just Create
tagToOperation 4  = Just GetAttr
tagToOperation 5  = Just Link
tagToOperation 6  = Just Lock
tagToOperation 7  = Just Lookup
tagToOperation 8  = Just Open
tagToOperation 9  = Just Read
tagToOperation 10 = Just ReadDir
tagToOperation 11 = Just Remove
tagToOperation 12 = Just Rename
tagToOperation 13 = Just SetAttr
tagToOperation 14 = Just Write
tagToOperation _  = Nothing

public export
operationRoundtrip : (o : Operation) -> tagToOperation (operationToTag o) = Just o
operationRoundtrip Access  = Refl
operationRoundtrip Close   = Refl
operationRoundtrip Commit  = Refl
operationRoundtrip Create  = Refl
operationRoundtrip GetAttr = Refl
operationRoundtrip Link    = Refl
operationRoundtrip Lock    = Refl
operationRoundtrip Lookup  = Refl
operationRoundtrip Open    = Refl
operationRoundtrip Read    = Refl
operationRoundtrip ReadDir = Refl
operationRoundtrip Remove  = Refl
operationRoundtrip Rename  = Refl
operationRoundtrip SetAttr = Refl
operationRoundtrip Write   = Refl

---------------------------------------------------------------------------
-- FileType (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
fileTypeToTag : FileType -> Bits8
fileTypeToTag Regular     = 0
fileTypeToTag Directory   = 1
fileTypeToTag BlockDevice = 2
fileTypeToTag CharDevice  = 3
fileTypeToTag Link        = 4
fileTypeToTag Socket      = 5
fileTypeToTag FIFO        = 6

public export
tagToFileType : Bits8 -> Maybe FileType
tagToFileType 0 = Just Regular
tagToFileType 1 = Just Directory
tagToFileType 2 = Just BlockDevice
tagToFileType 3 = Just CharDevice
tagToFileType 4 = Just Link
tagToFileType 5 = Just Socket
tagToFileType 6 = Just FIFO
tagToFileType _ = Nothing

public export
fileTypeRoundtrip : (f : FileType) -> tagToFileType (fileTypeToTag f) = Just f
fileTypeRoundtrip Regular     = Refl
fileTypeRoundtrip Directory   = Refl
fileTypeRoundtrip BlockDevice = Refl
fileTypeRoundtrip CharDevice  = Refl
fileTypeRoundtrip Link        = Refl
fileTypeRoundtrip Socket      = Refl
fileTypeRoundtrip FIFO        = Refl

---------------------------------------------------------------------------
-- Status (14 constructors, tags 0-13)
---------------------------------------------------------------------------

public export
statusToTag : Status -> Bits8
statusToTag Ok       = 0
statusToTag Perm     = 1
statusToTag NoEnt    = 2
statusToTag IO       = 3
statusToTag NxIO     = 4
statusToTag Access   = 5
statusToTag Exist    = 6
statusToTag NotDir   = 7
statusToTag IsDir    = 8
statusToTag FBig     = 9
statusToTag NoSpc    = 10
statusToTag ROfs     = 11
statusToTag NotEmpty = 12
statusToTag Stale    = 13

public export
tagToStatus : Bits8 -> Maybe Status
tagToStatus 0  = Just Ok
tagToStatus 1  = Just Perm
tagToStatus 2  = Just NoEnt
tagToStatus 3  = Just IO
tagToStatus 4  = Just NxIO
tagToStatus 5  = Just Access
tagToStatus 6  = Just Exist
tagToStatus 7  = Just NotDir
tagToStatus 8  = Just IsDir
tagToStatus 9  = Just FBig
tagToStatus 10 = Just NoSpc
tagToStatus 11 = Just ROfs
tagToStatus 12 = Just NotEmpty
tagToStatus 13 = Just Stale
tagToStatus _  = Nothing

public export
statusRoundtrip : (s : Status) -> tagToStatus (statusToTag s) = Just s
statusRoundtrip Ok       = Refl
statusRoundtrip Perm     = Refl
statusRoundtrip NoEnt    = Refl
statusRoundtrip IO       = Refl
statusRoundtrip NxIO     = Refl
statusRoundtrip Access   = Refl
statusRoundtrip Exist    = Refl
statusRoundtrip NotDir   = Refl
statusRoundtrip IsDir    = Refl
statusRoundtrip FBig     = Refl
statusRoundtrip NoSpc    = Refl
statusRoundtrip ROfs     = Refl
statusRoundtrip NotEmpty = Refl
statusRoundtrip Stale    = Refl

---------------------------------------------------------------------------
-- NFSState: Composite lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| NFS server lifecycle states used by the FFI layer.
public export
data NFSState : Type where
  ||| Not mounted. Initial state.
  NFSIdle      : NFSState
  ||| Connected to server, mount established.
  NFSMounted   : NFSState
  ||| File handle is open (read/write possible).
  NFSFileOpen  : NFSState
  ||| Lock held on a file region.
  NFSLocked    : NFSState
  ||| I/O in progress (read or write).
  NFSBusy      : NFSState
  ||| Unmounting (cleanup in progress).
  NFSUnmounting : NFSState

public export
Eq NFSState where
  NFSIdle       == NFSIdle       = True
  NFSMounted    == NFSMounted    = True
  NFSFileOpen   == NFSFileOpen   = True
  NFSLocked     == NFSLocked     = True
  NFSBusy       == NFSBusy       = True
  NFSUnmounting == NFSUnmounting = True
  _             == _             = False

public export
Show NFSState where
  show NFSIdle       = "Idle"
  show NFSMounted    = "Mounted"
  show NFSFileOpen   = "FileOpen"
  show NFSLocked     = "Locked"
  show NFSBusy       = "Busy"
  show NFSUnmounting = "Unmounting"

public export
nfsStateToTag : NFSState -> Bits8
nfsStateToTag NFSIdle       = 0
nfsStateToTag NFSMounted    = 1
nfsStateToTag NFSFileOpen   = 2
nfsStateToTag NFSLocked     = 3
nfsStateToTag NFSBusy       = 4
nfsStateToTag NFSUnmounting = 5

public export
tagToNFSState : Bits8 -> Maybe NFSState
tagToNFSState 0 = Just NFSIdle
tagToNFSState 1 = Just NFSMounted
tagToNFSState 2 = Just NFSFileOpen
tagToNFSState 3 = Just NFSLocked
tagToNFSState 4 = Just NFSBusy
tagToNFSState 5 = Just NFSUnmounting
tagToNFSState _ = Nothing

public export
nfsStateRoundtrip : (s : NFSState) -> tagToNFSState (nfsStateToTag s) = Just s
nfsStateRoundtrip NFSIdle       = Refl
nfsStateRoundtrip NFSMounted    = Refl
nfsStateRoundtrip NFSFileOpen   = Refl
nfsStateRoundtrip NFSLocked     = Refl
nfsStateRoundtrip NFSBusy       = Refl
nfsStateRoundtrip NFSUnmounting = Refl
