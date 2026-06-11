-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- FSM: Top-level module for proven-fsm.
-- Re-exports FSM.Types and provides state-machine-related constants.

module FSM

import public FSM.Types

%default total

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

||| Maximum number of states in a single state machine.
public export
maxStates : Nat
maxStates = 1024

||| Maximum number of transitions in a single state machine.
public export
maxTransitions : Nat
maxTransitions = 65536
