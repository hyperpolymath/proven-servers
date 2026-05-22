-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- LoadbalancerABI.Types: C-ABI-compatible numeric representations of Loadbalancer types.
--
-- Maps every constructor of the core Loadbalancer sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/loadbalancer.zig) exactly.
--
-- Types covered:
--   Algorithm                 (6 constructors, tags 0-5)
--   HealthCheckType           (4 constructors, tags 0-3)
--   BackendState              (4 constructors, tags 0-3)
--   SessionPersistence        (4 constructors, tags 0-3)
--   Protocol                  (5 constructors, tags 0-4)
--   LBError                   (7 constructors, tags 0-6)

module LoadbalancerABI.Types

%default total

---------------------------------------------------------------------------
-- Algorithm (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
algorithmSize : Nat
algorithmSize = 1

||| Algorithm sum type for ABI encoding.
public export
data Algorithm : Type where
  RoundRobin : Algorithm
  LeastConnections : Algorithm
  IpHash : Algorithm
  Random : Algorithm
  WeightedRoundRobin : Algorithm
  LeastResponseTime : Algorithm

||| Encode a Algorithm to its ABI tag value.
public export
algorithmToTag : Algorithm -> Bits8
algorithmToTag RoundRobin = 0
algorithmToTag LeastConnections = 1
algorithmToTag IpHash = 2
algorithmToTag Random = 3
algorithmToTag WeightedRoundRobin = 4
algorithmToTag LeastResponseTime = 5

||| Decode an ABI tag to a Algorithm.
public export
tagToAlgorithm : Bits8 -> Maybe Algorithm
tagToAlgorithm 0 = Just RoundRobin
tagToAlgorithm 1 = Just LeastConnections
tagToAlgorithm 2 = Just IpHash
tagToAlgorithm 3 = Just Random
tagToAlgorithm 4 = Just WeightedRoundRobin
tagToAlgorithm 5 = Just LeastResponseTime
tagToAlgorithm _ = Nothing

||| Roundtrip proof: decoding an encoded Algorithm yields the original.
public export
algorithmRoundtrip : (x : Algorithm) -> tagToAlgorithm (algorithmToTag x) = Just x
algorithmRoundtrip RoundRobin = Refl
algorithmRoundtrip LeastConnections = Refl
algorithmRoundtrip IpHash = Refl
algorithmRoundtrip Random = Refl
algorithmRoundtrip WeightedRoundRobin = Refl
algorithmRoundtrip LeastResponseTime = Refl

---------------------------------------------------------------------------
-- HealthCheckType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
health_check_typeSize : Nat
health_check_typeSize = 1

||| HealthCheckType sum type for ABI encoding.
public export
data HealthCheckType : Type where
  Http : HealthCheckType
  Tcp : HealthCheckType
  Grpc : HealthCheckType
  Script : HealthCheckType

||| Encode a HealthCheckType to its ABI tag value.
public export
health_check_typeToTag : HealthCheckType -> Bits8
health_check_typeToTag Http = 0
health_check_typeToTag Tcp = 1
health_check_typeToTag Grpc = 2
health_check_typeToTag Script = 3

||| Decode an ABI tag to a HealthCheckType.
public export
tagToHealthCheckType : Bits8 -> Maybe HealthCheckType
tagToHealthCheckType 0 = Just Http
tagToHealthCheckType 1 = Just Tcp
tagToHealthCheckType 2 = Just Grpc
tagToHealthCheckType 3 = Just Script
tagToHealthCheckType _ = Nothing

||| Roundtrip proof: decoding an encoded HealthCheckType yields the original.
public export
health_check_typeRoundtrip : (x : HealthCheckType) -> tagToHealthCheckType (health_check_typeToTag x) = Just x
health_check_typeRoundtrip Http = Refl
health_check_typeRoundtrip Tcp = Refl
health_check_typeRoundtrip Grpc = Refl
health_check_typeRoundtrip Script = Refl

---------------------------------------------------------------------------
-- BackendState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
backend_stateSize : Nat
backend_stateSize = 1

||| BackendState sum type for ABI encoding.
public export
data BackendState : Type where
  Healthy : BackendState
  Unhealthy : BackendState
  Draining : BackendState
  Disabled : BackendState

||| Encode a BackendState to its ABI tag value.
public export
backend_stateToTag : BackendState -> Bits8
backend_stateToTag Healthy = 0
backend_stateToTag Unhealthy = 1
backend_stateToTag Draining = 2
backend_stateToTag Disabled = 3

||| Decode an ABI tag to a BackendState.
public export
tagToBackendState : Bits8 -> Maybe BackendState
tagToBackendState 0 = Just Healthy
tagToBackendState 1 = Just Unhealthy
tagToBackendState 2 = Just Draining
tagToBackendState 3 = Just Disabled
tagToBackendState _ = Nothing

||| Roundtrip proof: decoding an encoded BackendState yields the original.
public export
backend_stateRoundtrip : (x : BackendState) -> tagToBackendState (backend_stateToTag x) = Just x
backend_stateRoundtrip Healthy = Refl
backend_stateRoundtrip Unhealthy = Refl
backend_stateRoundtrip Draining = Refl
backend_stateRoundtrip Disabled = Refl

---------------------------------------------------------------------------
-- SessionPersistence (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
session_persistenceSize : Nat
session_persistenceSize = 1

||| SessionPersistence sum type for ABI encoding.
public export
data SessionPersistence : Type where
  None : SessionPersistence
  Cookie : SessionPersistence
  SourceIp : SessionPersistence
  Header : SessionPersistence

||| Encode a SessionPersistence to its ABI tag value.
public export
session_persistenceToTag : SessionPersistence -> Bits8
session_persistenceToTag None = 0
session_persistenceToTag Cookie = 1
session_persistenceToTag SourceIp = 2
session_persistenceToTag Header = 3

||| Decode an ABI tag to a SessionPersistence.
public export
tagToSessionPersistence : Bits8 -> Maybe SessionPersistence
tagToSessionPersistence 0 = Just None
tagToSessionPersistence 1 = Just Cookie
tagToSessionPersistence 2 = Just SourceIp
tagToSessionPersistence 3 = Just Header
tagToSessionPersistence _ = Nothing

||| Roundtrip proof: decoding an encoded SessionPersistence yields the original.
public export
session_persistenceRoundtrip : (x : SessionPersistence) -> tagToSessionPersistence (session_persistenceToTag x) = Just x
session_persistenceRoundtrip None = Refl
session_persistenceRoundtrip Cookie = Refl
session_persistenceRoundtrip SourceIp = Refl
session_persistenceRoundtrip Header = Refl

---------------------------------------------------------------------------
-- Protocol (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
protocolSize : Nat
protocolSize = 1

||| Protocol sum type for ABI encoding.
public export
data Protocol : Type where
  Http : Protocol
  Https : Protocol
  Tcp : Protocol
  Udp : Protocol
  Grpc : Protocol

||| Encode a Protocol to its ABI tag value.
public export
protocolToTag : Protocol -> Bits8
protocolToTag Http = 0
protocolToTag Https = 1
protocolToTag Tcp = 2
protocolToTag Udp = 3
protocolToTag Grpc = 4

||| Decode an ABI tag to a Protocol.
public export
tagToProtocol : Bits8 -> Maybe Protocol
tagToProtocol 0 = Just Http
tagToProtocol 1 = Just Https
tagToProtocol 2 = Just Tcp
tagToProtocol 3 = Just Udp
tagToProtocol 4 = Just Grpc
tagToProtocol _ = Nothing

||| Roundtrip proof: decoding an encoded Protocol yields the original.
public export
protocolRoundtrip : (x : Protocol) -> tagToProtocol (protocolToTag x) = Just x
protocolRoundtrip Http = Refl
protocolRoundtrip Https = Refl
protocolRoundtrip Tcp = Refl
protocolRoundtrip Udp = Refl
protocolRoundtrip Grpc = Refl

---------------------------------------------------------------------------
-- LBError (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
l_b_errorSize : Nat
l_b_errorSize = 1

||| LBError sum type for ABI encoding.
public export
data LBError : Type where
  Ok : LBError
  InvalidSlot : LBError
  NotActive : LBError
  InvalidTransition : LBError
  NoHealthyBackends : LBError
  CapacityExhausted : LBError
  InvalidParam : LBError

||| Encode a LBError to its ABI tag value.
public export
l_b_errorToTag : LBError -> Bits8
l_b_errorToTag Ok = 0
l_b_errorToTag InvalidSlot = 1
l_b_errorToTag NotActive = 2
l_b_errorToTag InvalidTransition = 3
l_b_errorToTag NoHealthyBackends = 4
l_b_errorToTag CapacityExhausted = 5
l_b_errorToTag InvalidParam = 6

||| Decode an ABI tag to a LBError.
public export
tagToLBError : Bits8 -> Maybe LBError
tagToLBError 0 = Just Ok
tagToLBError 1 = Just InvalidSlot
tagToLBError 2 = Just NotActive
tagToLBError 3 = Just InvalidTransition
tagToLBError 4 = Just NoHealthyBackends
tagToLBError 5 = Just CapacityExhausted
tagToLBError 6 = Just InvalidParam
tagToLBError _ = Nothing

||| Roundtrip proof: decoding an encoded LBError yields the original.
public export
l_b_errorRoundtrip : (x : LBError) -> tagToLBError (l_b_errorToTag x) = Just x
l_b_errorRoundtrip Ok = Refl
l_b_errorRoundtrip InvalidSlot = Refl
l_b_errorRoundtrip NotActive = Refl
l_b_errorRoundtrip InvalidTransition = Refl
l_b_errorRoundtrip NoHealthyBackends = Refl
l_b_errorRoundtrip CapacityExhausted = Refl
l_b_errorRoundtrip InvalidParam = Refl
