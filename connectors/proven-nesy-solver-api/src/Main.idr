-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Main: Demo entry point for proven-nesy-solver-api.  Prints the tag
-- table and confirms the ABI version.  Real binding consumers import
-- NesySolverAPIABI directly.

module Main

import NesySolverAPI
import NesySolverAPIABI

%default total

showProverTable : String
showProverTable =
  concat
    [ "ProverKind tags:\n"
    , "  Z3=0  CVC5=1  Coq=2  Lean=3  Idris2=4\n"
    , "  Agda=5  Isabelle=6  Dafny=7  FStar=8\n"
    ]

showClassTable : String
showClassTable =
  concat
    [ "ObligationClass tags (mirrors verisimdb Enum8):\n"
    , "  Safety=0  Linearity=1  Termination=2  Equiv=3  Correctness=4\n"
    , "  Confluence=5  Totality=6  Invariant=7  Refinement=8\n"
    , "  ModelCheck=9  OtherClass=10\n"
    ]

main : IO ()
main = do
  putStrLn "proven-nesy-solver-api 0.1.0"
  putStrLn (concat ["ABI version: ", show abiVersionMajor, ".", show abiVersionMinor])
  putStrLn ""
  putStrLn showProverTable
  putStrLn showClassTable
  putStrLn "FFI surface:"
  traverse_ (\f => putStrLn ("  " ++ f)) ffiFunctionNames
