-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Main: Entry point for proven-fsm.
-- Prints the primitive name and shows all type constructors.

module Main

import FSM

%default total

||| Print a labelled list of constructors for a sum type.
covering
showConstructors : String -> List String -> IO ()
showConstructors label cs = do
  putStrLn $ "  " ++ label ++ ":"
  traverse_ (\c => putStrLn $ "    - " ++ c) cs

||| Entry point — display proven-fsm type constructors and constants.
covering
main : IO ()
main = do
  putStrLn "proven-fsm — Linear finite state machine"
  putStrLn ""
  showConstructors "TransitionResult"
    [ show Accepted, show Rejected, show Deferred ]
  showConstructors "ValidationError"
    [ show InvalidTransition, show PreconditionFailed
    , show PostconditionFailed, show GuardFailed ]
  showConstructors "MachineState"
    [ show Initial, show Running, show Terminal, show Faulted ]
  showConstructors "EventDisposition"
    [ show Consumed, show Ignored, show Queued, show Dropped ]
  putStrLn ""
  putStrLn $ "  maxStates      = " ++ show maxStates
  putStrLn $ "  maxTransitions = " ++ show maxTransitions
