-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- PqcABI.Types: C-ABI-compatible numeric representations of Pqc types.
--
-- Maps every constructor of the core Pqc sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/pqc.zig) exactly.
--
-- Types covered:
--   PQCAlgorithm              (8 constructors, tags 0-7)
--   NISTLevel                 (5 constructors, tags 0-4)
--   Operation                 (5 constructors, tags 0-4)
--   HybridMode                (3 constructors, tags 0-2)
--   AlgorithmCategory         (2 constructors, tags 0-1)
--   KeyState                  (6 constructors, tags 0-5)
--   HybridState               (5 constructors, tags 0-4)

module PqcABI.Types

%default total

---------------------------------------------------------------------------
-- PQCAlgorithm (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
p_q_c_algorithmSize : Nat
p_q_c_algorithmSize = 1

||| PQCAlgorithm sum type for ABI encoding.
public export
data PQCAlgorithm : Type where
  CrystalsKyber : PQCAlgorithm
  CrystalsDilithium : PQCAlgorithm
  Falcon : PQCAlgorithm
  SphincsPlus : PQCAlgorithm
  ClassicMceliece : PQCAlgorithm
  Bike : PQCAlgorithm
  Hqc : PQCAlgorithm
  Frodokem : PQCAlgorithm

||| Encode a PQCAlgorithm to its ABI tag value.
public export
p_q_c_algorithmToTag : PQCAlgorithm -> Bits8
p_q_c_algorithmToTag CrystalsKyber = 0
p_q_c_algorithmToTag CrystalsDilithium = 1
p_q_c_algorithmToTag Falcon = 2
p_q_c_algorithmToTag SphincsPlus = 3
p_q_c_algorithmToTag ClassicMceliece = 4
p_q_c_algorithmToTag Bike = 5
p_q_c_algorithmToTag Hqc = 6
p_q_c_algorithmToTag Frodokem = 7

||| Decode an ABI tag to a PQCAlgorithm.
public export
tagToPQCAlgorithm : Bits8 -> Maybe PQCAlgorithm
tagToPQCAlgorithm 0 = Just CrystalsKyber
tagToPQCAlgorithm 1 = Just CrystalsDilithium
tagToPQCAlgorithm 2 = Just Falcon
tagToPQCAlgorithm 3 = Just SphincsPlus
tagToPQCAlgorithm 4 = Just ClassicMceliece
tagToPQCAlgorithm 5 = Just Bike
tagToPQCAlgorithm 6 = Just Hqc
tagToPQCAlgorithm 7 = Just Frodokem
tagToPQCAlgorithm _ = Nothing

||| Roundtrip proof: decoding an encoded PQCAlgorithm yields the original.
public export
p_q_c_algorithmRoundtrip : (x : PQCAlgorithm) -> tagToPQCAlgorithm (p_q_c_algorithmToTag x) = Just x
p_q_c_algorithmRoundtrip CrystalsKyber = Refl
p_q_c_algorithmRoundtrip CrystalsDilithium = Refl
p_q_c_algorithmRoundtrip Falcon = Refl
p_q_c_algorithmRoundtrip SphincsPlus = Refl
p_q_c_algorithmRoundtrip ClassicMceliece = Refl
p_q_c_algorithmRoundtrip Bike = Refl
p_q_c_algorithmRoundtrip Hqc = Refl
p_q_c_algorithmRoundtrip Frodokem = Refl

---------------------------------------------------------------------------
-- NISTLevel (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
n_i_s_t_levelSize : Nat
n_i_s_t_levelSize = 1

||| NISTLevel sum type for ABI encoding.
public export
data NISTLevel : Type where
  Nist1 : NISTLevel
  Nist2 : NISTLevel
  Nist3 : NISTLevel
  Nist4 : NISTLevel
  Nist5 : NISTLevel

||| Encode a NISTLevel to its ABI tag value.
public export
n_i_s_t_levelToTag : NISTLevel -> Bits8
n_i_s_t_levelToTag Nist1 = 0
n_i_s_t_levelToTag Nist2 = 1
n_i_s_t_levelToTag Nist3 = 2
n_i_s_t_levelToTag Nist4 = 3
n_i_s_t_levelToTag Nist5 = 4

||| Decode an ABI tag to a NISTLevel.
public export
tagToNISTLevel : Bits8 -> Maybe NISTLevel
tagToNISTLevel 0 = Just Nist1
tagToNISTLevel 1 = Just Nist2
tagToNISTLevel 2 = Just Nist3
tagToNISTLevel 3 = Just Nist4
tagToNISTLevel 4 = Just Nist5
tagToNISTLevel _ = Nothing

||| Roundtrip proof: decoding an encoded NISTLevel yields the original.
public export
n_i_s_t_levelRoundtrip : (x : NISTLevel) -> tagToNISTLevel (n_i_s_t_levelToTag x) = Just x
n_i_s_t_levelRoundtrip Nist1 = Refl
n_i_s_t_levelRoundtrip Nist2 = Refl
n_i_s_t_levelRoundtrip Nist3 = Refl
n_i_s_t_levelRoundtrip Nist4 = Refl
n_i_s_t_levelRoundtrip Nist5 = Refl

---------------------------------------------------------------------------
-- Operation (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
operationSize : Nat
operationSize = 1

||| Operation sum type for ABI encoding.
public export
data Operation : Type where
  Keygen : Operation
  Encapsulate : Operation
  Decapsulate : Operation
  Sign : Operation
  Verify : Operation

||| Encode a Operation to its ABI tag value.
public export
operationToTag : Operation -> Bits8
operationToTag Keygen = 0
operationToTag Encapsulate = 1
operationToTag Decapsulate = 2
operationToTag Sign = 3
operationToTag Verify = 4

||| Decode an ABI tag to a Operation.
public export
tagToOperation : Bits8 -> Maybe Operation
tagToOperation 0 = Just Keygen
tagToOperation 1 = Just Encapsulate
tagToOperation 2 = Just Decapsulate
tagToOperation 3 = Just Sign
tagToOperation 4 = Just Verify
tagToOperation _ = Nothing

||| Roundtrip proof: decoding an encoded Operation yields the original.
public export
operationRoundtrip : (x : Operation) -> tagToOperation (operationToTag x) = Just x
operationRoundtrip Keygen = Refl
operationRoundtrip Encapsulate = Refl
operationRoundtrip Decapsulate = Refl
operationRoundtrip Sign = Refl
operationRoundtrip Verify = Refl

---------------------------------------------------------------------------
-- HybridMode (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
hybrid_modeSize : Nat
hybrid_modeSize = 1

||| HybridMode sum type for ABI encoding.
public export
data HybridMode : Type where
  ClassicalOnly : HybridMode
  PqcOnly : HybridMode
  Hybrid : HybridMode

||| Encode a HybridMode to its ABI tag value.
public export
hybrid_modeToTag : HybridMode -> Bits8
hybrid_modeToTag ClassicalOnly = 0
hybrid_modeToTag PqcOnly = 1
hybrid_modeToTag Hybrid = 2

||| Decode an ABI tag to a HybridMode.
public export
tagToHybridMode : Bits8 -> Maybe HybridMode
tagToHybridMode 0 = Just ClassicalOnly
tagToHybridMode 1 = Just PqcOnly
tagToHybridMode 2 = Just Hybrid
tagToHybridMode _ = Nothing

||| Roundtrip proof: decoding an encoded HybridMode yields the original.
public export
hybrid_modeRoundtrip : (x : HybridMode) -> tagToHybridMode (hybrid_modeToTag x) = Just x
hybrid_modeRoundtrip ClassicalOnly = Refl
hybrid_modeRoundtrip PqcOnly = Refl
hybrid_modeRoundtrip Hybrid = Refl

---------------------------------------------------------------------------
-- AlgorithmCategory (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
algorithm_categorySize : Nat
algorithm_categorySize = 1

||| AlgorithmCategory sum type for ABI encoding.
public export
data AlgorithmCategory : Type where
  Kem : AlgorithmCategory
  Signature : AlgorithmCategory

||| Encode a AlgorithmCategory to its ABI tag value.
public export
algorithm_categoryToTag : AlgorithmCategory -> Bits8
algorithm_categoryToTag Kem = 0
algorithm_categoryToTag Signature = 1

||| Decode an ABI tag to a AlgorithmCategory.
public export
tagToAlgorithmCategory : Bits8 -> Maybe AlgorithmCategory
tagToAlgorithmCategory 0 = Just Kem
tagToAlgorithmCategory 1 = Just Signature
tagToAlgorithmCategory _ = Nothing

||| Roundtrip proof: decoding an encoded AlgorithmCategory yields the original.
public export
algorithm_categoryRoundtrip : (x : AlgorithmCategory) -> tagToAlgorithmCategory (algorithm_categoryToTag x) = Just x
algorithm_categoryRoundtrip Kem = Refl
algorithm_categoryRoundtrip Signature = Refl

---------------------------------------------------------------------------
-- KeyState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
key_stateSize : Nat
key_stateSize = 1

||| KeyState sum type for ABI encoding.
public export
data KeyState : Type where
  Empty : KeyState
  Generating : KeyState
  Generated : KeyState
  Active : KeyState
  Expired : KeyState
  Compromised : KeyState

||| Encode a KeyState to its ABI tag value.
public export
key_stateToTag : KeyState -> Bits8
key_stateToTag Empty = 0
key_stateToTag Generating = 1
key_stateToTag Generated = 2
key_stateToTag Active = 3
key_stateToTag Expired = 4
key_stateToTag Compromised = 5

||| Decode an ABI tag to a KeyState.
public export
tagToKeyState : Bits8 -> Maybe KeyState
tagToKeyState 0 = Just Empty
tagToKeyState 1 = Just Generating
tagToKeyState 2 = Just Generated
tagToKeyState 3 = Just Active
tagToKeyState 4 = Just Expired
tagToKeyState 5 = Just Compromised
tagToKeyState _ = Nothing

||| Roundtrip proof: decoding an encoded KeyState yields the original.
public export
key_stateRoundtrip : (x : KeyState) -> tagToKeyState (key_stateToTag x) = Just x
key_stateRoundtrip Empty = Refl
key_stateRoundtrip Generating = Refl
key_stateRoundtrip Generated = Refl
key_stateRoundtrip Active = Refl
key_stateRoundtrip Expired = Refl
key_stateRoundtrip Compromised = Refl

---------------------------------------------------------------------------
-- HybridState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
hybrid_stateSize : Nat
hybrid_stateSize = 1

||| HybridState sum type for ABI encoding.
public export
data HybridState : Type where
  Idle : HybridState
  ClassicalSelected : HybridState
  PqcSelected : HybridState
  Negotiated : HybridState
  Complete : HybridState

||| Encode a HybridState to its ABI tag value.
public export
hybrid_stateToTag : HybridState -> Bits8
hybrid_stateToTag Idle = 0
hybrid_stateToTag ClassicalSelected = 1
hybrid_stateToTag PqcSelected = 2
hybrid_stateToTag Negotiated = 3
hybrid_stateToTag Complete = 4

||| Decode an ABI tag to a HybridState.
public export
tagToHybridState : Bits8 -> Maybe HybridState
tagToHybridState 0 = Just Idle
tagToHybridState 1 = Just ClassicalSelected
tagToHybridState 2 = Just PqcSelected
tagToHybridState 3 = Just Negotiated
tagToHybridState 4 = Just Complete
tagToHybridState _ = Nothing

||| Roundtrip proof: decoding an encoded HybridState yields the original.
public export
hybrid_stateRoundtrip : (x : HybridState) -> tagToHybridState (hybrid_stateToTag x) = Just x
hybrid_stateRoundtrip Idle = Refl
hybrid_stateRoundtrip ClassicalSelected = Refl
hybrid_stateRoundtrip PqcSelected = Refl
hybrid_stateRoundtrip Negotiated = Refl
hybrid_stateRoundtrip Complete = Refl
