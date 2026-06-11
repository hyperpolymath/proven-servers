-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- OSPFABI.Types: C-ABI-compatible numeric representations of OSPF types.
--
-- Maps every constructor of the OSPF domain types (PacketType, NeighborState,
-- LSAType, AreaType) to fixed Bits8 values for C interop.  Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/ospf.zig) exactly.

module OSPFABI.Types

import OSPF.Types

%default total

---------------------------------------------------------------------------
-- PacketType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| C-ABI representation size for PacketType (1 byte).
public export
packetTypeSize : Nat
packetTypeSize = 1

||| Map PacketType to its C-ABI byte value.
|||
||| Tag assignments:
|||   Hello               = 0
|||   DatabaseDescription = 1
|||   LinkStateRequest    = 2
|||   LinkStateUpdate     = 3
|||   LinkStateAck        = 4
public export
packetTypeToTag : PacketType -> Bits8
packetTypeToTag Hello               = 0
packetTypeToTag DatabaseDescription = 1
packetTypeToTag LinkStateRequest    = 2
packetTypeToTag LinkStateUpdate     = 3
packetTypeToTag LinkStateAck        = 4

||| Recover PacketType from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-4.
public export
tagToPacketType : Bits8 -> Maybe PacketType
tagToPacketType 0 = Just Hello
tagToPacketType 1 = Just DatabaseDescription
tagToPacketType 2 = Just LinkStateRequest
tagToPacketType 3 = Just LinkStateUpdate
tagToPacketType 4 = Just LinkStateAck
tagToPacketType _ = Nothing

||| Proof: encoding then decoding PacketType is the identity.
public export
packetTypeRoundtrip : (p : PacketType) -> tagToPacketType (packetTypeToTag p) = Just p
packetTypeRoundtrip Hello               = Refl
packetTypeRoundtrip DatabaseDescription = Refl
packetTypeRoundtrip LinkStateRequest    = Refl
packetTypeRoundtrip LinkStateUpdate     = Refl
packetTypeRoundtrip LinkStateAck        = Refl

---------------------------------------------------------------------------
-- NeighborState (8 constructors, tags 0-7)
---------------------------------------------------------------------------

||| C-ABI representation size for NeighborState (1 byte).
public export
neighborStateSize : Nat
neighborStateSize = 1

||| Map NeighborState to its C-ABI byte value.
|||
||| Tag assignments:
|||   Down     = 0
|||   Attempt  = 1
|||   Init     = 2
|||   TwoWay   = 3
|||   ExStart  = 4
|||   Exchange = 5
|||   Loading  = 6
|||   Full     = 7
public export
neighborStateToTag : NeighborState -> Bits8
neighborStateToTag Down     = 0
neighborStateToTag Attempt  = 1
neighborStateToTag Init     = 2
neighborStateToTag TwoWay   = 3
neighborStateToTag ExStart  = 4
neighborStateToTag Exchange = 5
neighborStateToTag Loading  = 6
neighborStateToTag Full     = 7

||| Recover NeighborState from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-7.
public export
tagToNeighborState : Bits8 -> Maybe NeighborState
tagToNeighborState 0 = Just Down
tagToNeighborState 1 = Just Attempt
tagToNeighborState 2 = Just Init
tagToNeighborState 3 = Just TwoWay
tagToNeighborState 4 = Just ExStart
tagToNeighborState 5 = Just Exchange
tagToNeighborState 6 = Just Loading
tagToNeighborState 7 = Just Full
tagToNeighborState _ = Nothing

||| Proof: encoding then decoding NeighborState is the identity.
public export
neighborStateRoundtrip : (n : NeighborState) -> tagToNeighborState (neighborStateToTag n) = Just n
neighborStateRoundtrip Down     = Refl
neighborStateRoundtrip Attempt  = Refl
neighborStateRoundtrip Init     = Refl
neighborStateRoundtrip TwoWay   = Refl
neighborStateRoundtrip ExStart  = Refl
neighborStateRoundtrip Exchange = Refl
neighborStateRoundtrip Loading  = Refl
neighborStateRoundtrip Full     = Refl

---------------------------------------------------------------------------
-- LSAType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| C-ABI representation size for LSAType (1 byte).
public export
lsaTypeSize : Nat
lsaTypeSize = 1

||| Map LSAType to its C-ABI byte value.
|||
||| Tag assignments:
|||   RouterLSA      = 0
|||   NetworkLSA     = 1
|||   SummaryLSA     = 2
|||   ASBRSummaryLSA = 3
|||   ASExternalLSA  = 4
public export
lsaTypeToTag : LSAType -> Bits8
lsaTypeToTag RouterLSA      = 0
lsaTypeToTag NetworkLSA     = 1
lsaTypeToTag SummaryLSA     = 2
lsaTypeToTag ASBRSummaryLSA = 3
lsaTypeToTag ASExternalLSA  = 4

||| Recover LSAType from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-4.
public export
tagToLSAType : Bits8 -> Maybe LSAType
tagToLSAType 0 = Just RouterLSA
tagToLSAType 1 = Just NetworkLSA
tagToLSAType 2 = Just SummaryLSA
tagToLSAType 3 = Just ASBRSummaryLSA
tagToLSAType 4 = Just ASExternalLSA
tagToLSAType _ = Nothing

||| Proof: encoding then decoding LSAType is the identity.
public export
lsaTypeRoundtrip : (l : LSAType) -> tagToLSAType (lsaTypeToTag l) = Just l
lsaTypeRoundtrip RouterLSA      = Refl
lsaTypeRoundtrip NetworkLSA     = Refl
lsaTypeRoundtrip SummaryLSA     = Refl
lsaTypeRoundtrip ASBRSummaryLSA = Refl
lsaTypeRoundtrip ASExternalLSA  = Refl

---------------------------------------------------------------------------
-- AreaType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for AreaType (1 byte).
public export
areaTypeSize : Nat
areaTypeSize = 1

||| Map AreaType to its C-ABI byte value.
|||
||| Tag assignments:
|||   Normal      = 0
|||   Stub        = 1
|||   TotallyStub = 2
|||   NSSA        = 3
public export
areaTypeToTag : AreaType -> Bits8
areaTypeToTag Normal      = 0
areaTypeToTag Stub        = 1
areaTypeToTag TotallyStub = 2
areaTypeToTag NSSA        = 3

||| Recover AreaType from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-3.
public export
tagToAreaType : Bits8 -> Maybe AreaType
tagToAreaType 0 = Just Normal
tagToAreaType 1 = Just Stub
tagToAreaType 2 = Just TotallyStub
tagToAreaType 3 = Just NSSA
tagToAreaType _ = Nothing

||| Proof: encoding then decoding AreaType is the identity.
public export
areaTypeRoundtrip : (a : AreaType) -> tagToAreaType (areaTypeToTag a) = Just a
areaTypeRoundtrip Normal      = Refl
areaTypeRoundtrip Stub        = Refl
areaTypeRoundtrip TotallyStub = Refl
areaTypeRoundtrip NSSA        = Refl

---------------------------------------------------------------------------
-- OSPFError (7 constructors, tags 0-6)
---------------------------------------------------------------------------

||| Error codes for OSPF FFI operations.
public export
data OSPFError : Type where
  ||| No error.
  OspfOk               : OSPFError
  ||| Invalid slot index.
  OspfInvalidSlot      : OSPFError
  ||| Neighbor not active.
  OspfNotActive        : OSPFError
  ||| Invalid state transition.
  OspfInvalidTransition : OSPFError
  ||| Invalid packet type for current state.
  OspfInvalidPacket    : OSPFError
  ||| Area configuration error.
  OspfAreaError        : OSPFError
  ||| LSA flooding limit exceeded.
  OspfFloodLimit       : OSPFError

public export
Show OSPFError where
  show OspfOk                = "Ok"
  show OspfInvalidSlot       = "InvalidSlot"
  show OspfNotActive         = "NotActive"
  show OspfInvalidTransition = "InvalidTransition"
  show OspfInvalidPacket     = "InvalidPacket"
  show OspfAreaError         = "AreaError"
  show OspfFloodLimit        = "FloodLimit"

||| C-ABI representation size for OSPFError (1 byte).
public export
ospfErrorSize : Nat
ospfErrorSize = 1

||| Map OSPFError to its C-ABI byte value.
public export
ospfErrorToTag : OSPFError -> Bits8
ospfErrorToTag OspfOk                = 0
ospfErrorToTag OspfInvalidSlot       = 1
ospfErrorToTag OspfNotActive         = 2
ospfErrorToTag OspfInvalidTransition = 3
ospfErrorToTag OspfInvalidPacket     = 4
ospfErrorToTag OspfAreaError         = 5
ospfErrorToTag OspfFloodLimit        = 6

||| Recover OSPFError from its C-ABI byte value.
public export
tagToOSPFError : Bits8 -> Maybe OSPFError
tagToOSPFError 0 = Just OspfOk
tagToOSPFError 1 = Just OspfInvalidSlot
tagToOSPFError 2 = Just OspfNotActive
tagToOSPFError 3 = Just OspfInvalidTransition
tagToOSPFError 4 = Just OspfInvalidPacket
tagToOSPFError 5 = Just OspfAreaError
tagToOSPFError 6 = Just OspfFloodLimit
tagToOSPFError _ = Nothing

||| Proof: encoding then decoding OSPFError is the identity.
public export
ospfErrorRoundtrip : (e : OSPFError) -> tagToOSPFError (ospfErrorToTag e) = Just e
ospfErrorRoundtrip OspfOk                = Refl
ospfErrorRoundtrip OspfInvalidSlot       = Refl
ospfErrorRoundtrip OspfNotActive         = Refl
ospfErrorRoundtrip OspfInvalidTransition = Refl
ospfErrorRoundtrip OspfInvalidPacket     = Refl
ospfErrorRoundtrip OspfAreaError         = Refl
ospfErrorRoundtrip OspfFloodLimit        = Refl
