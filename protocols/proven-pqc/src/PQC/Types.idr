-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- PQC.Types : Core types for the Post-Quantum Cryptography server.
--
-- Defines KEM algorithms (FIPS 203 ML-KEM, plus Round 4 candidates),
-- signature algorithms (FIPS 204/205 ML-DSA/SLH-DSA, plus FALCON),
-- NIST security levels (1-5), hybrid operation modes, and
-- cryptographic operations.
--
-- Algorithm families covered:
--   KEM:       CRYSTALS-Kyber (ML-KEM), Classic McEliece, BIKE, HQC, FrodoKEM
--   Signature: CRYSTALS-Dilithium (ML-DSA), FALCON, SPHINCS+ (SLH-DSA)

module PQC.Types

%default total

---------------------------------------------------------------------------
-- PQCAlgorithm : Unified algorithm identifier covering all PQC families.
---------------------------------------------------------------------------

||| Post-quantum cryptographic algorithm families.
||| Covers NIST FIPS 203/204/205 winners and Round 4 candidates.
public export
data PQCAlgorithm : Type where
  ||| CRYSTALS-Kyber / ML-KEM (FIPS 203) — lattice-based KEM.
  CRYSTALS_Kyber      : PQCAlgorithm
  ||| CRYSTALS-Dilithium / ML-DSA (FIPS 204) — lattice-based signature.
  CRYSTALS_Dilithium  : PQCAlgorithm
  ||| FALCON — NTRU-lattice-based compact signature.
  FALCON              : PQCAlgorithm
  ||| SPHINCS+ / SLH-DSA (FIPS 205) — stateless hash-based signature.
  SPHINCS_Plus        : PQCAlgorithm
  ||| Classic McEliece — code-based KEM (Round 4 candidate).
  Classic_McEliece    : PQCAlgorithm
  ||| BIKE — code-based KEM (Round 4 candidate).
  BIKE                : PQCAlgorithm
  ||| HQC — code-based KEM (Round 4 candidate).
  HQC                 : PQCAlgorithm
  ||| FrodoKEM — lattice-based KEM (conservative, learning with errors).
  FrodoKEM            : PQCAlgorithm

public export
Eq PQCAlgorithm where
  CRYSTALS_Kyber     == CRYSTALS_Kyber     = True
  CRYSTALS_Dilithium == CRYSTALS_Dilithium = True
  FALCON             == FALCON             = True
  SPHINCS_Plus       == SPHINCS_Plus       = True
  Classic_McEliece   == Classic_McEliece   = True
  BIKE               == BIKE               = True
  HQC                == HQC                = True
  FrodoKEM           == FrodoKEM           = True
  _                  == _                  = False

export
Show PQCAlgorithm where
  show CRYSTALS_Kyber     = "CRYSTALS-Kyber"
  show CRYSTALS_Dilithium = "CRYSTALS-Dilithium"
  show FALCON             = "FALCON"
  show SPHINCS_Plus       = "SPHINCS+"
  show Classic_McEliece   = "Classic-McEliece"
  show BIKE               = "BIKE"
  show HQC                = "HQC"
  show FrodoKEM           = "FrodoKEM"

---------------------------------------------------------------------------
-- NISTLevel : NIST post-quantum security levels (1-5).
---------------------------------------------------------------------------

||| NIST post-quantum security levels.
||| Level 1 = AES-128 equivalent, Level 5 = AES-256 equivalent.
public export
data NISTLevel : Type where
  ||| Security Level 1 — at least as hard to break as AES-128.
  NIST_1 : NISTLevel
  ||| Security Level 2 — at least as hard to break as SHA-256.
  NIST_2 : NISTLevel
  ||| Security Level 3 — at least as hard to break as AES-192.
  NIST_3 : NISTLevel
  ||| Security Level 4 — at least as hard to break as SHA-384.
  NIST_4 : NISTLevel
  ||| Security Level 5 — at least as hard to break as AES-256.
  NIST_5 : NISTLevel

public export
Eq NISTLevel where
  NIST_1 == NIST_1 = True
  NIST_2 == NIST_2 = True
  NIST_3 == NIST_3 = True
  NIST_4 == NIST_4 = True
  NIST_5 == NIST_5 = True
  _      == _      = False

export
Show NISTLevel where
  show NIST_1 = "NIST-1"
  show NIST_2 = "NIST-2"
  show NIST_3 = "NIST-3"
  show NIST_4 = "NIST-4"
  show NIST_5 = "NIST-5"

---------------------------------------------------------------------------
-- KEMAlgorithm : NIST FIPS 203 ML-KEM parameter sets.
---------------------------------------------------------------------------

||| Module-Lattice Key Encapsulation Mechanism parameter sets (FIPS 203).
public export
data KEMAlgorithm : Type where
  ML_KEM_512  : KEMAlgorithm
  ML_KEM_768  : KEMAlgorithm
  ML_KEM_1024 : KEMAlgorithm

export
Show KEMAlgorithm where
  show ML_KEM_512  = "ML-KEM-512"
  show ML_KEM_768  = "ML-KEM-768"
  show ML_KEM_1024 = "ML-KEM-1024"

---------------------------------------------------------------------------
-- SignatureAlgorithm : NIST FIPS 204/205 signature schemes.
---------------------------------------------------------------------------

||| Post-quantum digital signature algorithms (FIPS 204 ML-DSA, FIPS 205 SLH-DSA).
public export
data SignatureAlgorithm : Type where
  ML_DSA_44   : SignatureAlgorithm
  ML_DSA_65   : SignatureAlgorithm
  ML_DSA_87   : SignatureAlgorithm
  SLH_DSA_128f : SignatureAlgorithm
  SLH_DSA_128s : SignatureAlgorithm
  SLH_DSA_192f : SignatureAlgorithm
  SLH_DSA_256f : SignatureAlgorithm

export
Show SignatureAlgorithm where
  show ML_DSA_44    = "ML-DSA-44"
  show ML_DSA_65    = "ML-DSA-65"
  show ML_DSA_87    = "ML-DSA-87"
  show SLH_DSA_128f = "SLH-DSA-128f"
  show SLH_DSA_128s = "SLH-DSA-128s"
  show SLH_DSA_192f = "SLH-DSA-192f"
  show SLH_DSA_256f = "SLH-DSA-256f"

---------------------------------------------------------------------------
-- HybridMode : Classical/PQC hybrid operation modes.
---------------------------------------------------------------------------

||| Whether to use classical, post-quantum, or hybrid cryptography.
public export
data HybridMode : Type where
  ClassicalOnly : HybridMode
  PQCOnly       : HybridMode
  Hybrid        : HybridMode

public export
Eq HybridMode where
  ClassicalOnly == ClassicalOnly = True
  PQCOnly       == PQCOnly       = True
  Hybrid        == Hybrid        = True
  _             == _             = False

export
Show HybridMode where
  show ClassicalOnly = "ClassicalOnly"
  show PQCOnly       = "PQCOnly"
  show Hybrid        = "Hybrid"

---------------------------------------------------------------------------
-- Operation : Cryptographic operations the PQC server can perform.
---------------------------------------------------------------------------

||| Operations supported by the post-quantum cryptography server.
public export
data Operation : Type where
  KeyGen       : Operation
  Encapsulate  : Operation
  Decapsulate  : Operation
  Sign         : Operation
  Verify       : Operation

public export
Eq Operation where
  KeyGen      == KeyGen      = True
  Encapsulate == Encapsulate = True
  Decapsulate == Decapsulate = True
  Sign        == Sign        = True
  Verify      == Verify      = True
  _           == _           = False

export
Show Operation where
  show KeyGen      = "KeyGen"
  show Encapsulate = "Encapsulate"
  show Decapsulate = "Decapsulate"
  show Sign        = "Sign"
  show Verify      = "Verify"

---------------------------------------------------------------------------
-- AlgorithmCategory : Whether an algorithm is a KEM or a signature scheme.
---------------------------------------------------------------------------

||| Classifies a PQC algorithm as either a KEM or a signature scheme.
public export
data AlgorithmCategory : Type where
  KEMCategory       : AlgorithmCategory
  SignatureCategory : AlgorithmCategory

public export
Eq AlgorithmCategory where
  KEMCategory       == KEMCategory       = True
  SignatureCategory == SignatureCategory = True
  _                 == _                 = False

export
Show AlgorithmCategory where
  show KEMCategory       = "KEM"
  show SignatureCategory = "Signature"

||| Determine the category of a PQC algorithm.
public export
algorithmCategory : PQCAlgorithm -> AlgorithmCategory
algorithmCategory CRYSTALS_Kyber     = KEMCategory
algorithmCategory CRYSTALS_Dilithium = SignatureCategory
algorithmCategory FALCON             = SignatureCategory
algorithmCategory SPHINCS_Plus       = SignatureCategory
algorithmCategory Classic_McEliece   = KEMCategory
algorithmCategory BIKE               = KEMCategory
algorithmCategory HQC                = KEMCategory
algorithmCategory FrodoKEM           = KEMCategory

||| Check whether an operation is valid for a given algorithm category.
||| KEM algorithms support KeyGen, Encapsulate, Decapsulate.
||| Signature algorithms support KeyGen, Sign, Verify.
public export
validOperation : AlgorithmCategory -> Operation -> Bool
validOperation KEMCategory       KeyGen      = True
validOperation KEMCategory       Encapsulate = True
validOperation KEMCategory       Decapsulate = True
validOperation SignatureCategory KeyGen      = True
validOperation SignatureCategory Sign        = True
validOperation SignatureCategory Verify      = True
validOperation _                 _           = False
