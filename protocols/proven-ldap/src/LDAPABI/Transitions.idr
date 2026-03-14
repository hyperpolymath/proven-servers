-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- LDAPABI.Transitions: Valid LDAP session state transitions.
--
-- Models the LDAP session lifecycle (RFC 4511):
--
--   Anonymous --Bind--> Binding --BindSuccess--> Bound
--   Anonymous --Bind--> Binding --BindFail--> Anonymous
--   Bound --Bind--> Binding (re-bind)
--   Bound --Search/Modify/Add/Delete/ModDN/Compare/Extended--> Bound
--   Anonymous --Search (anonymous)--> Anonymous
--   Any non-Closed --Unbind--> Closed
--
-- Key invariants:
--   - Modify/Add/Delete/ModDN require Bound (CanModify)
--   - Search can work from Anonymous (anonymous read) or Bound
--   - Closed is terminal (no outbound edges)
--   - Abandon has no state transition (it cancels an in-flight operation)

module LDAPABI.Transitions

import LDAPABI.Layout

%default total

---------------------------------------------------------------------------
-- ValidSessionTransition: exhaustive enumeration of legal transitions.
---------------------------------------------------------------------------

||| Proof witness that an LDAP session state transition is valid.
public export
data ValidSessionTransition : SessionState -> SessionState -> Type where
  ||| Anonymous -> Binding (Bind request sent).
  BeginBind          : ValidSessionTransition Anonymous Binding
  ||| Binding -> Bound (Bind succeeded).
  BindSuccess        : ValidSessionTransition Binding Bound
  ||| Binding -> Anonymous (Bind failed, back to anonymous).
  BindFail           : ValidSessionTransition Binding Anonymous
  ||| Bound -> Binding (re-Bind to change identity).
  ReBind             : ValidSessionTransition Bound Binding
  ||| Bound -> Bound (directory operation: Search, Modify, etc.).
  DirectoryOp        : ValidSessionTransition Bound Bound
  ||| Anonymous -> Anonymous (anonymous Search or Abandon).
  AnonymousOp        : ValidSessionTransition Anonymous Anonymous
  ||| Anonymous -> Closed (Unbind before binding).
  UnbindAnonymous    : ValidSessionTransition Anonymous Closed
  ||| Bound -> Closed (Unbind after binding).
  UnbindBound        : ValidSessionTransition Bound Closed
  ||| Binding -> Closed (Unbind while bind in progress).
  UnbindBinding      : ValidSessionTransition Binding Closed

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a session can perform write operations (Modify, Add, Delete, ModDN).
public export
data CanModify : SessionState -> Type where
  BoundCanModify : CanModify Bound

||| Proof that a session can perform search operations.
public export
data CanSearch : SessionState -> Type where
  AnonymousCanSearch : CanSearch Anonymous
  BoundCanSearch     : CanSearch Bound

||| Proof that a session can perform Compare operations.
public export
data CanCompare : SessionState -> Type where
  BoundCanCompare : CanCompare Bound

||| Proof that a session can initiate a Bind.
public export
data CanBind : SessionState -> Type where
  AnonymousCanBind : CanBind Anonymous
  BoundCanBind     : CanBind Bound

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot leave the Closed state -- it is terminal.
public export
closedIsTerminal : ValidSessionTransition Closed s -> Void
closedIsTerminal _ impossible

||| Cannot modify from Anonymous state.
public export
cannotModifyFromAnonymous : CanModify Anonymous -> Void
cannotModifyFromAnonymous _ impossible

||| Cannot modify from Closed state.
public export
cannotModifyFromClosed : CanModify Closed -> Void
cannotModifyFromClosed _ impossible

||| Cannot modify from Binding state.
public export
cannotModifyFromBinding : CanModify Binding -> Void
cannotModifyFromBinding _ impossible

||| Cannot search from Closed state.
public export
cannotSearchFromClosed : CanSearch Closed -> Void
cannotSearchFromClosed _ impossible

||| Cannot search from Binding state.
public export
cannotSearchFromBinding : CanSearch Binding -> Void
cannotSearchFromBinding _ impossible

||| Cannot bind from Closed state.
public export
cannotBindFromClosed : CanBind Closed -> Void
cannotBindFromClosed _ impossible

||| Cannot skip Binding and go directly Anonymous -> Bound.
public export
cannotSkipBinding : ValidSessionTransition Anonymous Bound -> Void
cannotSkipBinding _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether an LDAP session state transition is valid.
public export
validateSessionTransition : (from : SessionState) -> (to : SessionState)
                         -> Maybe (ValidSessionTransition from to)
validateSessionTransition Anonymous Binding   = Just BeginBind
validateSessionTransition Anonymous Anonymous = Just AnonymousOp
validateSessionTransition Anonymous Closed    = Just UnbindAnonymous
validateSessionTransition Binding   Bound     = Just BindSuccess
validateSessionTransition Binding   Anonymous = Just BindFail
validateSessionTransition Binding   Closed    = Just UnbindBinding
validateSessionTransition Bound     Binding   = Just ReBind
validateSessionTransition Bound     Bound     = Just DirectoryOp
validateSessionTransition Bound     Closed    = Just UnbindBound
validateSessionTransition _         _         = Nothing
