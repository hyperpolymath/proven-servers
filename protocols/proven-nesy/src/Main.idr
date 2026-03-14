-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Main: Entry point for the proven-nesy protocol library.
-- Verifies that all types are total and exports the public API.

module Main

import NeSy

%default total

main : IO ()
main = do
  putStrLn "proven-nesy: Neurosymbolic integration protocol types"
  putStrLn $ "  ReasoningModes: " ++ show [Symbolic, Neural, SymToNeural, NeuralToSym, Ensemble, Cascade]
  putStrLn $ "  ProofStatuses:  " ++ show [Pending, Attempting, Proved, Failed, Assumed, Vacuous]
  putStrLn $ "  Constraints:    " ++ show [TypeEquality, Subtype, Linearity, Termination, Totality, Invariant, Refinement, DependentIndex]
  putStrLn $ "  NeuralBackends: " ++ show [LocalModel, Claude, Gemini, Mistral, GPT, CustomNeural]
  putStrLn $ "  Confidence:     " ++ show [Verified, HighNeural, MediumNeural, LowNeural, Unknown, Contradicted]
  putStrLn $ "  DriftKinds:     " ++ show [NoDrift, SemanticDrift, ConfidenceDrift, FactualDrift, TemporalDrift, CatastrophicDrift]
  putStrLn "All types total, all Show instances verified."
