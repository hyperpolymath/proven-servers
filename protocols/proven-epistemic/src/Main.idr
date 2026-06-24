-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- proven-epistemic :: conformance scenario runner.
--
-- Drives the proven Layer-0 engine (Epistemic.Engine) through the SAME
-- scenarios as the Zig integration suite (ffi/zig/test/integration_test.zig),
-- printing PASS/FAIL per scenario and exiting nonzero on any failure. This is
-- the Idris-side behavioural check (CI builds no Idris today) and the
-- executable proof that the engine actually runs.
--
-- Usage:
--   idris2 --build proven-epistemic.ipkg
--   ./build/exec/proven-epistemic

module Main

import Epistemic
import Epistemic.Engine
import EpistemicABI.Types
import EpistemicABI.Foreign
import Data.List
import System

%default total

-- ----------------------------------------------------------------------------
-- Tiny pure assertion helpers
-- ----------------------------------------------------------------------------

isYes : Dec a -> Bool
isYes (Yes _) = True
isYes (No _)  = False

||| Equality via Show (the enums' Show is injective); avoids needing Eq
||| instances on the core types.
sameStr : Show a => a -> a -> Bool
sameStr x y = show x == show y

discloseOK : Either DisclosureError (Session, DisclosureEvent) -> Bool
discloseOK (Right _) = True
discloseOK (Left _)  = False

discloseErr : DisclosureError -> Either DisclosureError (Session, DisclosureEvent) -> Bool
discloseErr e (Left e') = sameStr e e'
discloseErr _ (Right _) = False

sessionErr : DisclosureError -> Either DisclosureError Session -> Bool
sessionErr e (Left e') = sameStr e e'
sessionErr _ (Right _) = False

-- ----------------------------------------------------------------------------
-- Demo governance policy and helpers
-- ----------------------------------------------------------------------------

demoPolicy : List FieldGovernance
demoPolicy =
  [ MkFieldGovernance "band_field" Compatibility Innocuous  Band
  , MkFieldGovernance "rel_field"  Compatibility Contextual Relational
  , MkFieldGovernance "full_field" Compatibility Innocuous  Full
  , MkFieldGovernance "sens_rel"   Compatibility Sensitive  Relational  -- ill-governed
  , MkFieldGovernance "sens_full"  Compatibility Sensitive  Full
  ]

||| A session walked to Disclosing with effective tier = meet ours theirs.
mkDisclosing : (ours, theirs : Tier) -> Either DisclosureError Session
mkDisclosing ours theirs = do
  s1 <- agreeTiers ours theirs (initiate demoPolicy)
  beginDisclosure s1

||| Disclose one field in a fresh Disclosing session.
discloseIn : (ours, theirs : Tier) -> String
          -> Either DisclosureError (Session, DisclosureEvent)
discloseIn ours theirs name = do
  s <- mkDisclosing ours theirs
  disclose name s

||| Disclose after the session has been closed.
afterClose : Either DisclosureError (Session, DisclosureEvent)
afterClose = do
  s  <- mkDisclosing Full Full
  s2 <- close s
  disclose "band_field" s2

-- ----------------------------------------------------------------------------
-- Stateless transition table (mirrors ValidSessionTransition / can_transition)
-- ----------------------------------------------------------------------------

legalTransition : SessionPhase -> SessionPhase -> Bool
legalTransition Initiated   TiersAgreed = True
legalTransition TiersAgreed Disclosing  = True
legalTransition Initiated   Closed      = True
legalTransition TiersAgreed Closed      = True
legalTransition Disclosing  Closed      = True
legalTransition _           _           = False

allTiers : List Tier
allTiers = [Band, Relational, Full]

meetSymmetric : Bool
meetSymmetric = all (\a => all (\b => sameStr (meet a b) (meet b a)) allTiers) allTiers

lifecycleWalk : Bool
lifecycleWalk =
  case agreeTiers Full Relational (initiate demoPolicy) of
    Left _   => False
    Right s1 =>
      sameStr s1.phase TiersAgreed &&
      sameStr (sessionEffective s1) Relational &&
      (case beginDisclosure s1 of
        Left _   => False
        Right s2 => sameStr s2.phase Disclosing &&
          (case close s2 of
            Left _   => False
            Right s3 => sameStr s3.phase Closed))

doubleClose : Bool
doubleClose =
  case close (initiate demoPolicy) of
    Left _   => False
    Right s1 => sessionErr SessionAlreadyClosed (close s1)

wg : Revealingness -> Tier -> Bool
wg r t = isYes (decideWellGoverned (MkFieldGovernance "x" Compatibility r t))

-- ----------------------------------------------------------------------------
-- The scenario table (1:1 with integration_test.zig groups)
-- ----------------------------------------------------------------------------

scenarios : List (String, Bool)
scenarios =
  [ ("abiVersion = 1",                              abiVersion == 1)
  , ("tag Tier.Full = 2",                           tierToTag Full == 2)
  , ("tag Revealingness.Sensitive = 2",             revealingnessToTag Sensitive == 2)
  , ("tag Purpose.Audit = 4",                       purposeToTag Audit == 4)
  , ("tag SessionPhase.Closed = 3",                 phaseToTag Closed == 3)
  , ("meet Band Full = Band (absorbing)",           sameStr (meet Band Full) Band)
  , ("meet Full Band = Band",                       sameStr (meet Full Band) Band)
  , ("meet Full Relational = Relational",           sameStr (meet Full Relational) Relational)
  , ("meet Full Full = Full",                       sameStr (meet Full Full) Full)
  , ("meet Relational Relational = Relational",     sameStr (meet Relational Relational) Relational)
  , ("meet symmetric over all 9 pairs",             meetSymmetric)
  , ("well-governed Sensitive@Band rejected",       not (wg Sensitive Band))
  , ("well-governed Sensitive@Relational rejected", not (wg Sensitive Relational))
  , ("well-governed Sensitive@Full accepted",       wg Sensitive Full)
  , ("well-governed Innocuous@Band accepted",       wg Innocuous Band)
  , ("lifecycle Initiated->...->Closed",            lifecycleWalk)
  , ("cannot skip agreement",                       sessionErr NoActiveSession (beginDisclosure (initiate demoPolicy)))
  , ("closed is terminal (double close)",           doubleClose)
  , ("transition Initiated->TiersAgreed legal",     legalTransition Initiated TiersAgreed)
  , ("transition TiersAgreed->Disclosing legal",    legalTransition TiersAgreed Disclosing)
  , ("transition Disclosing->Closed legal",         legalTransition Disclosing Closed)
  , ("transition Initiated->Disclosing illegal",    not (legalTransition Initiated Disclosing))
  , ("transition Closed->Disclosing illegal",       not (legalTransition Closed Disclosing))
  , ("gate Band field discloses at eff=Relational", discloseOK (discloseIn Full Relational "band_field"))
  , ("gate Relational field discloses at eff=Rel",  discloseOK (discloseIn Full Relational "rel_field"))
  , ("gate Full field refused at eff=Relational",   discloseErr TierExceeded (discloseIn Full Relational "full_field"))
  , ("disclose refused when Initiated",             discloseErr NoActiveSession (disclose "band_field" (initiate demoPolicy)))
  , ("disclose refused after close",                discloseErr SessionAlreadyClosed afterClose)
  , ("unknown field rejected",                      discloseErr UnknownField (discloseIn Full Full "nope"))
  , ("Sensitive@Relational ill-governed at eff=Full", discloseErr IllGoverned (discloseIn Full Full "sens_rel"))
  , ("Sensitive@Full discloses at eff=Full",        discloseOK (discloseIn Full Full "sens_full"))
  ]

printResult : (String, Bool) -> IO ()
printResult (label, ok) = putStrLn $ (if ok then "  PASS  " else "  FAIL  ") ++ label

covering
main : IO ()
main = do
  putStrLn "proven-epistemic :: Layer-0 engine conformance scenarios"
  putStrLn ""
  traverse_ printResult scenarios
  let failed = length (filter (not . snd) scenarios)
  let count  = length scenarios
  putStrLn ""
  if failed == 0
    then putStrLn $ "All " ++ show count ++ " scenarios PASS"
    else do
      putStrLn $ show failed ++ " of " ++ show count ++ " scenarios FAILED"
      exitFailure
