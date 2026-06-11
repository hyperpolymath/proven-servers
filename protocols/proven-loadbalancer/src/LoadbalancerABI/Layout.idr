-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- LoadbalancerABI.Layout: C-ABI-compatible numeric representations of
-- load balancer types.
--
-- Maps every constructor of the load balancer domain types (Algorithm,
-- HealthCheckType, BackendState, SessionPersistence, Protocol) to fixed
-- Bits8 values for C interop.  Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- Tag values here MUST match the C header (generated/abi/loadbalancer.h)
-- and the Zig FFI enums (ffi/zig/src/loadbalancer.zig) exactly.

module LoadbalancerABI.Layout

import Loadbalancer.Types

%default total

---------------------------------------------------------------------------
-- Algorithm (6 constructors, tags 0-5)
---------------------------------------------------------------------------

||| C-ABI representation size for Algorithm (1 byte).
public export
algorithmSize : Nat
algorithmSize = 1

||| Map Algorithm to its C-ABI byte value.
public export
algorithmToTag : Algorithm -> Bits8
algorithmToTag RoundRobin         = 0
algorithmToTag LeastConnections   = 1
algorithmToTag IPHash             = 2
algorithmToTag Random             = 3
algorithmToTag WeightedRoundRobin = 4
algorithmToTag LeastResponseTime  = 5

||| Recover Algorithm from its C-ABI byte value.
public export
tagToAlgorithm : Bits8 -> Maybe Algorithm
tagToAlgorithm 0 = Just RoundRobin
tagToAlgorithm 1 = Just LeastConnections
tagToAlgorithm 2 = Just IPHash
tagToAlgorithm 3 = Just Random
tagToAlgorithm 4 = Just WeightedRoundRobin
tagToAlgorithm 5 = Just LeastResponseTime
tagToAlgorithm _ = Nothing

||| Proof: encoding then decoding Algorithm is the identity.
public export
algorithmRoundtrip : (a : Algorithm) -> tagToAlgorithm (algorithmToTag a) = Just a
algorithmRoundtrip RoundRobin         = Refl
algorithmRoundtrip LeastConnections   = Refl
algorithmRoundtrip IPHash             = Refl
algorithmRoundtrip Random             = Refl
algorithmRoundtrip WeightedRoundRobin = Refl
algorithmRoundtrip LeastResponseTime  = Refl

---------------------------------------------------------------------------
-- HealthCheckType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for HealthCheckType (1 byte).
public export
healthCheckTypeSize : Nat
healthCheckTypeSize = 1

||| Map HealthCheckType to its C-ABI byte value.
public export
healthCheckTypeToTag : HealthCheckType -> Bits8
healthCheckTypeToTag HcHTTP   = 0
healthCheckTypeToTag HcTCP    = 1
healthCheckTypeToTag HcGRPC   = 2
healthCheckTypeToTag HcScript = 3

||| Recover HealthCheckType from its C-ABI byte value.
public export
tagToHealthCheckType : Bits8 -> Maybe HealthCheckType
tagToHealthCheckType 0 = Just HcHTTP
tagToHealthCheckType 1 = Just HcTCP
tagToHealthCheckType 2 = Just HcGRPC
tagToHealthCheckType 3 = Just HcScript
tagToHealthCheckType _ = Nothing

||| Proof: encoding then decoding HealthCheckType is the identity.
public export
healthCheckTypeRoundtrip : (h : HealthCheckType) -> tagToHealthCheckType (healthCheckTypeToTag h) = Just h
healthCheckTypeRoundtrip HcHTTP   = Refl
healthCheckTypeRoundtrip HcTCP    = Refl
healthCheckTypeRoundtrip HcGRPC   = Refl
healthCheckTypeRoundtrip HcScript = Refl

---------------------------------------------------------------------------
-- BackendState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for BackendState (1 byte).
public export
backendStateSize : Nat
backendStateSize = 1

||| Map BackendState to its C-ABI byte value.
public export
backendStateToTag : BackendState -> Bits8
backendStateToTag Healthy   = 0
backendStateToTag Unhealthy = 1
backendStateToTag Draining  = 2
backendStateToTag BDisabled = 3

||| Recover BackendState from its C-ABI byte value.
public export
tagToBackendState : Bits8 -> Maybe BackendState
tagToBackendState 0 = Just Healthy
tagToBackendState 1 = Just Unhealthy
tagToBackendState 2 = Just Draining
tagToBackendState 3 = Just BDisabled
tagToBackendState _ = Nothing

||| Proof: encoding then decoding BackendState is the identity.
public export
backendStateRoundtrip : (b : BackendState) -> tagToBackendState (backendStateToTag b) = Just b
backendStateRoundtrip Healthy   = Refl
backendStateRoundtrip Unhealthy = Refl
backendStateRoundtrip Draining  = Refl
backendStateRoundtrip BDisabled = Refl

---------------------------------------------------------------------------
-- SessionPersistence (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for SessionPersistence (1 byte).
public export
sessionPersistenceSize : Nat
sessionPersistenceSize = 1

||| Map SessionPersistence to its C-ABI byte value.
public export
sessionPersistenceToTag : SessionPersistence -> Bits8
sessionPersistenceToTag None     = 0
sessionPersistenceToTag Cookie   = 1
sessionPersistenceToTag SourceIP = 2
sessionPersistenceToTag Header   = 3

||| Recover SessionPersistence from its C-ABI byte value.
public export
tagToSessionPersistence : Bits8 -> Maybe SessionPersistence
tagToSessionPersistence 0 = Just None
tagToSessionPersistence 1 = Just Cookie
tagToSessionPersistence 2 = Just SourceIP
tagToSessionPersistence 3 = Just Header
tagToSessionPersistence _ = Nothing

||| Proof: encoding then decoding SessionPersistence is the identity.
public export
sessionPersistenceRoundtrip : (s : SessionPersistence) -> tagToSessionPersistence (sessionPersistenceToTag s) = Just s
sessionPersistenceRoundtrip None     = Refl
sessionPersistenceRoundtrip Cookie   = Refl
sessionPersistenceRoundtrip SourceIP = Refl
sessionPersistenceRoundtrip Header   = Refl

---------------------------------------------------------------------------
-- Protocol (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| C-ABI representation size for Protocol (1 byte).
public export
protocolSize : Nat
protocolSize = 1

||| Map Protocol to its C-ABI byte value.
public export
protocolToTag : Protocol -> Bits8
protocolToTag HTTP  = 0
protocolToTag HTTPS = 1
protocolToTag TCP   = 2
protocolToTag UDP   = 3
protocolToTag GRPC  = 4

||| Recover Protocol from its C-ABI byte value.
public export
tagToProtocol : Bits8 -> Maybe Protocol
tagToProtocol 0 = Just HTTP
tagToProtocol 1 = Just HTTPS
tagToProtocol 2 = Just TCP
tagToProtocol 3 = Just UDP
tagToProtocol 4 = Just GRPC
tagToProtocol _ = Nothing

||| Proof: encoding then decoding Protocol is the identity.
public export
protocolRoundtrip : (p : Protocol) -> tagToProtocol (protocolToTag p) = Just p
protocolRoundtrip HTTP  = Refl
protocolRoundtrip HTTPS = Refl
protocolRoundtrip TCP   = Refl
protocolRoundtrip UDP   = Refl
protocolRoundtrip GRPC  = Refl

---------------------------------------------------------------------------
-- LBError (7 constructors, tags 0-6)
-- Error codes returned by load balancer FFI operations.
---------------------------------------------------------------------------

||| Error codes for load balancer FFI operations.
public export
data LBError : Type where
  ||| No error.
  LbOk                : LBError
  ||| Invalid slot index.
  LbInvalidSlot       : LBError
  ||| Backend not active.
  LbNotActive         : LBError
  ||| Invalid state transition.
  LbInvalidTransition : LBError
  ||| No healthy backends available.
  LbNoHealthyBackends : LBError
  ||| Backend pool capacity exhausted.
  LbCapacityExhausted : LBError
  ||| Invalid parameter value.
  LbInvalidParam      : LBError

public export
Eq LBError where
  LbOk                == LbOk                = True
  LbInvalidSlot       == LbInvalidSlot       = True
  LbNotActive         == LbNotActive         = True
  LbInvalidTransition == LbInvalidTransition = True
  LbNoHealthyBackends == LbNoHealthyBackends = True
  LbCapacityExhausted == LbCapacityExhausted = True
  LbInvalidParam      == LbInvalidParam      = True
  _                   == _                   = False

public export
Show LBError where
  show LbOk                = "Ok"
  show LbInvalidSlot       = "InvalidSlot"
  show LbNotActive         = "NotActive"
  show LbInvalidTransition = "InvalidTransition"
  show LbNoHealthyBackends = "NoHealthyBackends"
  show LbCapacityExhausted = "CapacityExhausted"
  show LbInvalidParam      = "InvalidParam"

||| C-ABI representation size for LBError (1 byte).
public export
lbErrorSize : Nat
lbErrorSize = 1

||| Map LBError to its C-ABI byte value.
public export
lbErrorToTag : LBError -> Bits8
lbErrorToTag LbOk                = 0
lbErrorToTag LbInvalidSlot       = 1
lbErrorToTag LbNotActive         = 2
lbErrorToTag LbInvalidTransition = 3
lbErrorToTag LbNoHealthyBackends = 4
lbErrorToTag LbCapacityExhausted = 5
lbErrorToTag LbInvalidParam      = 6

||| Recover LBError from its C-ABI byte value.
public export
tagToLBError : Bits8 -> Maybe LBError
tagToLBError 0 = Just LbOk
tagToLBError 1 = Just LbInvalidSlot
tagToLBError 2 = Just LbNotActive
tagToLBError 3 = Just LbInvalidTransition
tagToLBError 4 = Just LbNoHealthyBackends
tagToLBError 5 = Just LbCapacityExhausted
tagToLBError 6 = Just LbInvalidParam
tagToLBError _ = Nothing

||| Proof: encoding then decoding LBError is the identity.
public export
lbErrorRoundtrip : (e : LBError) -> tagToLBError (lbErrorToTag e) = Just e
lbErrorRoundtrip LbOk                = Refl
lbErrorRoundtrip LbInvalidSlot       = Refl
lbErrorRoundtrip LbNotActive         = Refl
lbErrorRoundtrip LbInvalidTransition = Refl
lbErrorRoundtrip LbNoHealthyBackends = Refl
lbErrorRoundtrip LbCapacityExhausted = Refl
lbErrorRoundtrip LbInvalidParam      = Refl
