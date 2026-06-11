-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- proven-epistemic: Main entry point.
--
-- Minimal main that prints the server name, demonstrates the core type
-- constructors, the meet table, and the decidable disclosure gate.
--
-- Usage:
--   idris2 --build proven-epistemic.ipkg
--   ./build/exec/proven-epistemic

module Main

import Epistemic

%default total

||| Render a disclosure decision.
showDecision : Dec (Disclosable g eff) -> String
showDecision (Yes _) = "disclose"
showDecision (No _)  = "REFUSE"

||| Render one row of the meet table.
meetRow : Tier -> Tier -> String
meetRow a b = "  meet " ++ show a ++ " " ++ show b ++ " = " ++ show (meet a b)

covering
main : IO ()
main = do
  putStrLn "proven-epistemic v0.1.0 -- epistemic disclosure server core"
  putStrLn ""
  putStrLn $ "Default tier (deny-by-default): " ++ show Epistemic.defaultTier

  putStrLn "\n--- Tier ---"
  putStrLn $ "  " ++ show Band
  putStrLn $ "  " ++ show Relational
  putStrLn $ "  " ++ show Full

  putStrLn "\n--- Revealingness ---"
  putStrLn $ "  " ++ show Innocuous
  putStrLn $ "  " ++ show Contextual
  putStrLn $ "  " ++ show Sensitive

  putStrLn "\n--- Purpose ---"
  putStrLn $ "  " ++ show Identification
  putStrLn $ "  " ++ show Eligibility
  putStrLn $ "  " ++ show Compatibility
  putStrLn $ "  " ++ show Contractual
  putStrLn $ "  " ++ show Audit

  putStrLn "\n--- SessionPhase ---"
  putStrLn $ "  " ++ show Initiated
  putStrLn $ "  " ++ show TiersAgreed
  putStrLn $ "  " ++ show Disclosing
  putStrLn $ "  " ++ show Closed

  putStrLn "\n--- DisclosureError ---"
  putStrLn $ "  " ++ show TierExceeded
  putStrLn $ "  " ++ show UnknownField
  putStrLn $ "  " ++ show NoActiveSession
  putStrLn $ "  " ++ show SessionAlreadyClosed
  putStrLn $ "  " ++ show IllGoverned

  putStrLn "\n--- Meet table (reciprocity: proven symmetric) ---"
  putStrLn $ meetRow Full Band
  putStrLn $ meetRow Full Relational
  putStrLn $ meetRow Relational Band
  putStrLn $ meetRow Full Full

  putStrLn "\n--- Disclosure gate (proven non-amplifying) ---"
  let sensitive = MkFieldGovernance "substance_tolerance" Compatibility Sensitive Full
  let lifestyle = MkFieldGovernance "guest_frequency" Compatibility Contextual Relational
  putStrLn $ "  substance_tolerance at Band:       " ++ showDecision (decideDisclosable sensitive Band)
  putStrLn $ "  substance_tolerance at Relational: " ++ showDecision (decideDisclosable sensitive Relational)
  putStrLn $ "  substance_tolerance at Full:       " ++ showDecision (decideDisclosable sensitive Full)
  putStrLn $ "  guest_frequency at Band:           " ++ showDecision (decideDisclosable lifestyle Band)
  putStrLn $ "  guest_frequency at Relational:     " ++ showDecision (decideDisclosable lifestyle Relational)
