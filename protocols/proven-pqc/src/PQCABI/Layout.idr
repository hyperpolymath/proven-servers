-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- PQCABI.Layout: C-ABI-compatible numeric representations of PQC types.
--
-- Maps every constructor of the PQC sum types (PQCAlgorithm, NISTLevel,
-- Operation, HybridMode, AlgorithmCategory) to fixed Bits8 values for C
-- interop.  Each type gets a total encoder, partial decoder, and
-- roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/pqc.h) and the
-- Zig FFI enums (ffi/zig/src/pqc.zig) exactly.

module PQCABI.Layout

import PQC.Types

%default total

---------------------------------------------------------------------------
-- PQCAlgorithm (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
algorithmSize : Nat
algorithmSize = 1

public export
algorithmToTag : PQCAlgorithm -> Bits8
algorithmToTag CRYSTALS_Kyber     = 0
algorithmToTag CRYSTALS_Dilithium = 1
algorithmToTag FALCON             = 2
algorithmToTag SPHINCS_Plus       = 3
algorithmToTag Classic_McEliece   = 4
algorithmToTag BIKE               = 5
algorithmToTag HQC                = 6
algorithmToTag FrodoKEM           = 7

public export
tagToAlgorithm : Bits8 -> Maybe PQCAlgorithm
tagToAlgorithm 0 = Just CRYSTALS_Kyber
tagToAlgorithm 1 = Just CRYSTALS_Dilithium
tagToAlgorithm 2 = Just FALCON
tagToAlgorithm 3 = Just SPHINCS_Plus
tagToAlgorithm 4 = Just Classic_McEliece
tagToAlgorithm 5 = Just BIKE
tagToAlgorithm 6 = Just HQC
tagToAlgorithm 7 = Just FrodoKEM
tagToAlgorithm _ = Nothing

public export
algorithmRoundtrip : (a : PQCAlgorithm) -> tagToAlgorithm (algorithmToTag a) = Just a
algorithmRoundtrip CRYSTALS_Kyber     = Refl
algorithmRoundtrip CRYSTALS_Dilithium = Refl
algorithmRoundtrip FALCON             = Refl
algorithmRoundtrip SPHINCS_Plus       = Refl
algorithmRoundtrip Classic_McEliece   = Refl
algorithmRoundtrip BIKE               = Refl
algorithmRoundtrip HQC                = Refl
algorithmRoundtrip FrodoKEM           = Refl

---------------------------------------------------------------------------
-- NISTLevel (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
nistLevelSize : Nat
nistLevelSize = 1

public export
nistLevelToTag : NISTLevel -> Bits8
nistLevelToTag NIST_1 = 0
nistLevelToTag NIST_2 = 1
nistLevelToTag NIST_3 = 2
nistLevelToTag NIST_4 = 3
nistLevelToTag NIST_5 = 4

public export
tagToNISTLevel : Bits8 -> Maybe NISTLevel
tagToNISTLevel 0 = Just NIST_1
tagToNISTLevel 1 = Just NIST_2
tagToNISTLevel 2 = Just NIST_3
tagToNISTLevel 3 = Just NIST_4
tagToNISTLevel 4 = Just NIST_5
tagToNISTLevel _ = Nothing

public export
nistLevelRoundtrip : (l : NISTLevel) -> tagToNISTLevel (nistLevelToTag l) = Just l
nistLevelRoundtrip NIST_1 = Refl
nistLevelRoundtrip NIST_2 = Refl
nistLevelRoundtrip NIST_3 = Refl
nistLevelRoundtrip NIST_4 = Refl
nistLevelRoundtrip NIST_5 = Refl

---------------------------------------------------------------------------
-- Operation (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
operationSize : Nat
operationSize = 1

public export
operationToTag : Operation -> Bits8
operationToTag KeyGen      = 0
operationToTag Encapsulate = 1
operationToTag Decapsulate = 2
operationToTag Sign        = 3
operationToTag Verify      = 4

public export
tagToOperation : Bits8 -> Maybe Operation
tagToOperation 0 = Just KeyGen
tagToOperation 1 = Just Encapsulate
tagToOperation 2 = Just Decapsulate
tagToOperation 3 = Just Sign
tagToOperation 4 = Just Verify
tagToOperation _ = Nothing

public export
operationRoundtrip : (o : Operation) -> tagToOperation (operationToTag o) = Just o
operationRoundtrip KeyGen      = Refl
operationRoundtrip Encapsulate = Refl
operationRoundtrip Decapsulate = Refl
operationRoundtrip Sign        = Refl
operationRoundtrip Verify      = Refl

---------------------------------------------------------------------------
-- HybridMode (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
hybridModeSize : Nat
hybridModeSize = 1

public export
hybridModeToTag : HybridMode -> Bits8
hybridModeToTag ClassicalOnly = 0
hybridModeToTag PQCOnly       = 1
hybridModeToTag Hybrid        = 2

public export
tagToHybridMode : Bits8 -> Maybe HybridMode
tagToHybridMode 0 = Just ClassicalOnly
tagToHybridMode 1 = Just PQCOnly
tagToHybridMode 2 = Just Hybrid
tagToHybridMode _ = Nothing

public export
hybridModeRoundtrip : (m : HybridMode) -> tagToHybridMode (hybridModeToTag m) = Just m
hybridModeRoundtrip ClassicalOnly = Refl
hybridModeRoundtrip PQCOnly       = Refl
hybridModeRoundtrip Hybrid        = Refl

---------------------------------------------------------------------------
-- AlgorithmCategory (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
categorySize : Nat
categorySize = 1

public export
categoryToTag : AlgorithmCategory -> Bits8
categoryToTag KEMCategory       = 0
categoryToTag SignatureCategory = 1

public export
tagToCategory : Bits8 -> Maybe AlgorithmCategory
tagToCategory 0 = Just KEMCategory
tagToCategory 1 = Just SignatureCategory
tagToCategory _ = Nothing

public export
categoryRoundtrip : (c : AlgorithmCategory) -> tagToCategory (categoryToTag c) = Just c
categoryRoundtrip KEMCategory       = Refl
categoryRoundtrip SignatureCategory = Refl

---------------------------------------------------------------------------
-- Cross-type validation: algorithm -> valid NIST levels
--
-- Not all algorithms support all NIST levels.  This table captures the
-- valid combinations.
---------------------------------------------------------------------------

||| Whether an algorithm supports a given NIST security level.
||| Based on NIST FIPS 203/204/205 parameter sets and Round 4 specs.
public export
validAlgorithmLevel : PQCAlgorithm -> NISTLevel -> Bool
-- CRYSTALS-Kyber (ML-KEM): 512=Level 1, 768=Level 3, 1024=Level 5
validAlgorithmLevel CRYSTALS_Kyber     NIST_1 = True
validAlgorithmLevel CRYSTALS_Kyber     NIST_3 = True
validAlgorithmLevel CRYSTALS_Kyber     NIST_5 = True
-- CRYSTALS-Dilithium (ML-DSA): 44=Level 2, 65=Level 3, 87=Level 5
validAlgorithmLevel CRYSTALS_Dilithium NIST_2 = True
validAlgorithmLevel CRYSTALS_Dilithium NIST_3 = True
validAlgorithmLevel CRYSTALS_Dilithium NIST_5 = True
-- FALCON: 512=Level 1, 1024=Level 5
validAlgorithmLevel FALCON             NIST_1 = True
validAlgorithmLevel FALCON             NIST_5 = True
-- SPHINCS+ (SLH-DSA): 128f/128s=Level 1, 192f=Level 3, 256f=Level 5
validAlgorithmLevel SPHINCS_Plus       NIST_1 = True
validAlgorithmLevel SPHINCS_Plus       NIST_3 = True
validAlgorithmLevel SPHINCS_Plus       NIST_5 = True
-- Classic McEliece: 348864=Level 1, 460896=Level 3, 6688128=Level 5
validAlgorithmLevel Classic_McEliece   NIST_1 = True
validAlgorithmLevel Classic_McEliece   NIST_3 = True
validAlgorithmLevel Classic_McEliece   NIST_5 = True
-- BIKE: Level 1, Level 3, Level 5
validAlgorithmLevel BIKE               NIST_1 = True
validAlgorithmLevel BIKE               NIST_3 = True
validAlgorithmLevel BIKE               NIST_5 = True
-- HQC: Level 1, Level 3, Level 5
validAlgorithmLevel HQC                NIST_1 = True
validAlgorithmLevel HQC                NIST_3 = True
validAlgorithmLevel HQC                NIST_5 = True
-- FrodoKEM: 640=Level 1, 976=Level 3, 1344=Level 5
validAlgorithmLevel FrodoKEM           NIST_1 = True
validAlgorithmLevel FrodoKEM           NIST_3 = True
validAlgorithmLevel FrodoKEM           NIST_5 = True
-- All other combinations are invalid.
validAlgorithmLevel _                  _      = False
