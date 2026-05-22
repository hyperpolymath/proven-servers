-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ContainerABI.Types: C-ABI-compatible numeric representations of
-- proven-container types.
--
-- Maps every constructor of the core container sum types to fixed Bits8
-- values for C interop.  Each type gets a total encoder, partial decoder,
-- and roundtrip proof guaranteeing encoding/decoding never loses information.
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/container.zig)
-- exactly.
--
-- Types covered:
--   ContainerState (7 constructors, tags 0-6)
--   Operation      (11 constructors, tags 0-10)
--   NetworkMode    (5 constructors, tags 0-4)
--   VolumeType     (3 constructors, tags 0-2)
--   RestartPolicy  (4 constructors, tags 0-3)
--   HealthStatus   (4 constructors, tags 0-3)

module ContainerABI.Types

import Container.Types

%default total

---------------------------------------------------------------------------
-- ContainerState (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
containerStateSize : Nat
containerStateSize = 1

||| Encode ContainerState to its ABI tag value.
public export
containerStateToTag : ContainerState -> Bits8
containerStateToTag Creating   = 0
containerStateToTag Running    = 1
containerStateToTag Paused     = 2
containerStateToTag Restarting = 3
containerStateToTag Stopped    = 4
containerStateToTag Removing   = 5
containerStateToTag Dead       = 6

public export
tagToContainerState : Bits8 -> Maybe ContainerState
tagToContainerState 0 = Just Creating
tagToContainerState 1 = Just Running
tagToContainerState 2 = Just Paused
tagToContainerState 3 = Just Restarting
tagToContainerState 4 = Just Stopped
tagToContainerState 5 = Just Removing
tagToContainerState 6 = Just Dead
tagToContainerState _ = Nothing

public export
containerStateRoundtrip : (s : ContainerState) -> tagToContainerState (containerStateToTag s) = Just s
containerStateRoundtrip Creating   = Refl
containerStateRoundtrip Running    = Refl
containerStateRoundtrip Paused     = Refl
containerStateRoundtrip Restarting = Refl
containerStateRoundtrip Stopped    = Refl
containerStateRoundtrip Removing   = Refl
containerStateRoundtrip Dead       = Refl

---------------------------------------------------------------------------
-- Operation (11 constructors, tags 0-10)
---------------------------------------------------------------------------

public export
operationSize : Nat
operationSize = 1

||| Encode Operation to its ABI tag value.
public export
operationToTag : Operation -> Bits8
operationToTag Create  = 0
operationToTag Start   = 1
operationToTag Stop    = 2
operationToTag Restart = 3
operationToTag Pause   = 4
operationToTag Unpause = 5
operationToTag Kill    = 6
operationToTag Remove  = 7
operationToTag Exec    = 8
operationToTag Logs    = 9
operationToTag Inspect = 10

public export
tagToOperation : Bits8 -> Maybe Operation
tagToOperation 0  = Just Create
tagToOperation 1  = Just Start
tagToOperation 2  = Just Stop
tagToOperation 3  = Just Restart
tagToOperation 4  = Just Pause
tagToOperation 5  = Just Unpause
tagToOperation 6  = Just Kill
tagToOperation 7  = Just Remove
tagToOperation 8  = Just Exec
tagToOperation 9  = Just Logs
tagToOperation 10 = Just Inspect
tagToOperation _  = Nothing

public export
operationRoundtrip : (o : Operation) -> tagToOperation (operationToTag o) = Just o
operationRoundtrip Create  = Refl
operationRoundtrip Start   = Refl
operationRoundtrip Stop    = Refl
operationRoundtrip Restart = Refl
operationRoundtrip Pause   = Refl
operationRoundtrip Unpause = Refl
operationRoundtrip Kill    = Refl
operationRoundtrip Remove  = Refl
operationRoundtrip Exec    = Refl
operationRoundtrip Logs    = Refl
operationRoundtrip Inspect = Refl

---------------------------------------------------------------------------
-- NetworkMode (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
networkModeSize : Nat
networkModeSize = 1

||| Encode NetworkMode to its ABI tag value.
public export
networkModeToTag : NetworkMode -> Bits8
networkModeToTag Bridge  = 0
networkModeToTag Host    = 1
networkModeToTag None    = 2
networkModeToTag Overlay = 3
networkModeToTag Macvlan = 4

public export
tagToNetworkMode : Bits8 -> Maybe NetworkMode
tagToNetworkMode 0 = Just Bridge
tagToNetworkMode 1 = Just Host
tagToNetworkMode 2 = Just None
tagToNetworkMode 3 = Just Overlay
tagToNetworkMode 4 = Just Macvlan
tagToNetworkMode _ = Nothing

public export
networkModeRoundtrip : (m : NetworkMode) -> tagToNetworkMode (networkModeToTag m) = Just m
networkModeRoundtrip Bridge  = Refl
networkModeRoundtrip Host    = Refl
networkModeRoundtrip None    = Refl
networkModeRoundtrip Overlay = Refl
networkModeRoundtrip Macvlan = Refl

---------------------------------------------------------------------------
-- VolumeType (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
volumeTypeSize : Nat
volumeTypeSize = 1

||| Encode VolumeType to its ABI tag value.
public export
volumeTypeToTag : VolumeType -> Bits8
volumeTypeToTag Bind  = 0
volumeTypeToTag Named = 1
volumeTypeToTag Tmpfs = 2

public export
tagToVolumeType : Bits8 -> Maybe VolumeType
tagToVolumeType 0 = Just Bind
tagToVolumeType 1 = Just Named
tagToVolumeType 2 = Just Tmpfs
tagToVolumeType _ = Nothing

public export
volumeTypeRoundtrip : (v : VolumeType) -> tagToVolumeType (volumeTypeToTag v) = Just v
volumeTypeRoundtrip Bind  = Refl
volumeTypeRoundtrip Named = Refl
volumeTypeRoundtrip Tmpfs = Refl

---------------------------------------------------------------------------
-- RestartPolicy (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
restartPolicySize : Nat
restartPolicySize = 1

||| Encode RestartPolicy to its ABI tag value.
public export
restartPolicyToTag : RestartPolicy -> Bits8
restartPolicyToTag No            = 0
restartPolicyToTag Always        = 1
restartPolicyToTag OnFailure     = 2
restartPolicyToTag UnlessStopped = 3

public export
tagToRestartPolicy : Bits8 -> Maybe RestartPolicy
tagToRestartPolicy 0 = Just No
tagToRestartPolicy 1 = Just Always
tagToRestartPolicy 2 = Just OnFailure
tagToRestartPolicy 3 = Just UnlessStopped
tagToRestartPolicy _ = Nothing

public export
restartPolicyRoundtrip : (p : RestartPolicy) -> tagToRestartPolicy (restartPolicyToTag p) = Just p
restartPolicyRoundtrip No            = Refl
restartPolicyRoundtrip Always        = Refl
restartPolicyRoundtrip OnFailure     = Refl
restartPolicyRoundtrip UnlessStopped = Refl

---------------------------------------------------------------------------
-- HealthStatus (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
healthStatusSize : Nat
healthStatusSize = 1

||| Encode HealthStatus to its ABI tag value.
public export
healthStatusToTag : HealthStatus -> Bits8
healthStatusToTag Starting  = 0
healthStatusToTag Healthy   = 1
healthStatusToTag Unhealthy = 2
healthStatusToTag NoCheck   = 3

public export
tagToHealthStatus : Bits8 -> Maybe HealthStatus
tagToHealthStatus 0 = Just Starting
tagToHealthStatus 1 = Just Healthy
tagToHealthStatus 2 = Just Unhealthy
tagToHealthStatus 3 = Just NoCheck
tagToHealthStatus _ = Nothing

public export
healthStatusRoundtrip : (h : HealthStatus) -> tagToHealthStatus (healthStatusToTag h) = Just h
healthStatusRoundtrip Starting  = Refl
healthStatusRoundtrip Healthy   = Refl
healthStatusRoundtrip Unhealthy = Refl
healthStatusRoundtrip NoCheck   = Refl
