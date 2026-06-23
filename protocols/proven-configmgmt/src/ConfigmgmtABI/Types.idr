-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- ConfigmgmtABI.Types: C-ABI-compatible numeric representations of
-- proven-configmgmt types.
--
-- Maps every constructor of the core configuration management sum types
-- to fixed Bits8 values for C interop.  Each type gets a total encoder,
-- partial decoder, and roundtrip proof guaranteeing encoding/decoding
-- never loses information.
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/configmgmt.zig)
-- exactly.
--
-- Types covered:
--   ResourceType   (9 constructors, tags 0-8)
--   ResourceState  (6 constructors, tags 0-5)
--   ChangeAction   (6 constructors, tags 0-5)
--   DriftStatus    (4 constructors, tags 0-3)
--   ApplyMode      (3 constructors, tags 0-2)

module ConfigmgmtABI.Types

import Configmgmt.Types

%default total

---------------------------------------------------------------------------
-- ResourceType (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
resourceTypeSize : Nat
resourceTypeSize = 1

||| Encode ResourceType to its ABI tag value.
public export
resourceTypeToTag : ResourceType -> Bits8
resourceTypeToTag File     = 0
resourceTypeToTag Package  = 1
resourceTypeToTag Service  = 2
resourceTypeToTag User     = 3
resourceTypeToTag Group    = 4
resourceTypeToTag Cron     = 5
resourceTypeToTag Mount    = 6
resourceTypeToTag Firewall = 7
resourceTypeToTag Registry = 8

public export
tagToResourceType : Bits8 -> Maybe ResourceType
tagToResourceType 0 = Just File
tagToResourceType 1 = Just Package
tagToResourceType 2 = Just Service
tagToResourceType 3 = Just User
tagToResourceType 4 = Just Group
tagToResourceType 5 = Just Cron
tagToResourceType 6 = Just Mount
tagToResourceType 7 = Just Firewall
tagToResourceType 8 = Just Registry
tagToResourceType _ = Nothing

public export
resourceTypeRoundtrip : (t : ResourceType) -> tagToResourceType (resourceTypeToTag t) = Just t
resourceTypeRoundtrip File     = Refl
resourceTypeRoundtrip Package  = Refl
resourceTypeRoundtrip Service  = Refl
resourceTypeRoundtrip User     = Refl
resourceTypeRoundtrip Group    = Refl
resourceTypeRoundtrip Cron     = Refl
resourceTypeRoundtrip Mount    = Refl
resourceTypeRoundtrip Firewall = Refl
resourceTypeRoundtrip Registry = Refl

---------------------------------------------------------------------------
-- ResourceState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
resourceStateSize : Nat
resourceStateSize = 1

||| Encode ResourceState to its ABI tag value.
public export
resourceStateToTag : ResourceState -> Bits8
resourceStateToTag Present  = 0
resourceStateToTag Absent   = 1
resourceStateToTag Running  = 2
resourceStateToTag Stopped  = 3
resourceStateToTag Enabled  = 4
resourceStateToTag Disabled = 5

public export
tagToResourceState : Bits8 -> Maybe ResourceState
tagToResourceState 0 = Just Present
tagToResourceState 1 = Just Absent
tagToResourceState 2 = Just Running
tagToResourceState 3 = Just Stopped
tagToResourceState 4 = Just Enabled
tagToResourceState 5 = Just Disabled
tagToResourceState _ = Nothing

public export
resourceStateRoundtrip : (s : ResourceState) -> tagToResourceState (resourceStateToTag s) = Just s
resourceStateRoundtrip Present  = Refl
resourceStateRoundtrip Absent   = Refl
resourceStateRoundtrip Running  = Refl
resourceStateRoundtrip Stopped  = Refl
resourceStateRoundtrip Enabled  = Refl
resourceStateRoundtrip Disabled = Refl

---------------------------------------------------------------------------
-- ChangeAction (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
changeActionSize : Nat
changeActionSize = 1

||| Encode ChangeAction to its ABI tag value.
public export
changeActionToTag : ChangeAction -> Bits8
changeActionToTag Create  = 0
changeActionToTag Modify  = 1
changeActionToTag Delete  = 2
changeActionToTag Restart = 3
changeActionToTag Reload  = 4
changeActionToTag Skip    = 5

public export
tagToChangeAction : Bits8 -> Maybe ChangeAction
tagToChangeAction 0 = Just Create
tagToChangeAction 1 = Just Modify
tagToChangeAction 2 = Just Delete
tagToChangeAction 3 = Just Restart
tagToChangeAction 4 = Just Reload
tagToChangeAction 5 = Just Skip
tagToChangeAction _ = Nothing

public export
changeActionRoundtrip : (a : ChangeAction) -> tagToChangeAction (changeActionToTag a) = Just a
changeActionRoundtrip Create  = Refl
changeActionRoundtrip Modify  = Refl
changeActionRoundtrip Delete  = Refl
changeActionRoundtrip Restart = Refl
changeActionRoundtrip Reload  = Refl
changeActionRoundtrip Skip    = Refl

---------------------------------------------------------------------------
-- DriftStatus (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
driftStatusSize : Nat
driftStatusSize = 1

||| Encode DriftStatus to its ABI tag value.
public export
driftStatusToTag : DriftStatus -> Bits8
driftStatusToTag InSync    = 0
driftStatusToTag Drifted   = 1
driftStatusToTag DUnknown  = 2
driftStatusToTag Unmanaged = 3

public export
tagToDriftStatus : Bits8 -> Maybe DriftStatus
tagToDriftStatus 0 = Just InSync
tagToDriftStatus 1 = Just Drifted
tagToDriftStatus 2 = Just DUnknown
tagToDriftStatus 3 = Just Unmanaged
tagToDriftStatus _ = Nothing

public export
driftStatusRoundtrip : (d : DriftStatus) -> tagToDriftStatus (driftStatusToTag d) = Just d
driftStatusRoundtrip InSync    = Refl
driftStatusRoundtrip Drifted   = Refl
driftStatusRoundtrip DUnknown  = Refl
driftStatusRoundtrip Unmanaged = Refl

---------------------------------------------------------------------------
-- ApplyMode (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
applyModeSize : Nat
applyModeSize = 1

||| Encode ApplyMode to its ABI tag value.
public export
applyModeToTag : ApplyMode -> Bits8
applyModeToTag Enforce = 0
applyModeToTag DryRun  = 1
applyModeToTag Audit   = 2

public export
tagToApplyMode : Bits8 -> Maybe ApplyMode
tagToApplyMode 0 = Just Enforce
tagToApplyMode 1 = Just DryRun
tagToApplyMode 2 = Just Audit
tagToApplyMode _ = Nothing

public export
applyModeRoundtrip : (m : ApplyMode) -> tagToApplyMode (applyModeToTag m) = Just m
applyModeRoundtrip Enforce = Refl
applyModeRoundtrip DryRun  = Refl
applyModeRoundtrip Audit   = Refl
