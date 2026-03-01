-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Main: Entry point for proven-compose.
-- Prints the primitive name and shows all type constructors.

module Main

import Compose

%default total

||| Print a labelled list of constructors for a sum type.
covering
showConstructors : String -> List String -> IO ()
showConstructors label cs = do
  putStrLn $ "  " ++ label ++ ":"
  traverse_ (\c => putStrLn $ "    - " ++ c) cs

||| Entry point — display proven-compose type constructors and constants.
covering
main : IO ()
main = do
  putStrLn "proven-compose — Composition combinators"
  putStrLn ""
  showConstructors "Combinator"
    [ show Chain, show Parallel, show Proxy, show Relay
    , show Mux, show Demux, show Filter, show Transform, show Tap ]
  showConstructors "Compatibility"
    [ show Compatible, show IncompatibleTypes
    , show IncompatibleFraming, show IncompatibleSecurity
    , show IncompatibleDirection ]
  showConstructors "Direction"
    [ show Upstream, show Downstream, show Bidirectional ]
  showConstructors "CompositionError"
    [ show TypeMismatch, show SecurityDowngrade, show CycleDetected
    , show MissingDependency, show AmbiguousRoute ]
  showConstructors "PipelineStage"
    [ show Ingress, show Process, show Egress
    , show ErrorHandler, show Audit ]
  putStrLn ""
  putStrLn $ "  maxChainDepth       = " ++ show maxChainDepth
  putStrLn $ "  maxParallelBranches = " ++ show maxParallelBranches
