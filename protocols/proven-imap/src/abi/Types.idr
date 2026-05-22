-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
module IMAPABI.Types
import IMAP.Types
%default total

public export
commandToTag : Command -> Bits8
commandToTag Login = 0; commandToTag Logout = 1; commandToTag Select = 2; commandToTag Examine = 3
commandToTag Create = 4; commandToTag Delete = 5; commandToTag Rename = 6; commandToTag List = 7
commandToTag Fetch = 8; commandToTag Store = 9; commandToTag Search = 10; commandToTag Copy = 11
commandToTag Noop = 12; commandToTag Capability = 13

public export
tagToCommand : Bits8 -> Maybe Command
tagToCommand 0 = Just Login; tagToCommand 1 = Just Logout; tagToCommand 2 = Just Select
tagToCommand 3 = Just Examine; tagToCommand 4 = Just Create; tagToCommand 5 = Just Delete
tagToCommand 6 = Just Rename; tagToCommand 7 = Just List; tagToCommand 8 = Just Fetch
tagToCommand 9 = Just Store; tagToCommand 10 = Just Search; tagToCommand 11 = Just Copy
tagToCommand 12 = Just Noop; tagToCommand 13 = Just Capability; tagToCommand _ = Nothing

public export
commandRoundtrip : (c : Command) -> tagToCommand (commandToTag c) = Just c
commandRoundtrip Login = Refl; commandRoundtrip Logout = Refl; commandRoundtrip Select = Refl
commandRoundtrip Examine = Refl; commandRoundtrip Create = Refl; commandRoundtrip Delete = Refl
commandRoundtrip Rename = Refl; commandRoundtrip List = Refl; commandRoundtrip Fetch = Refl
commandRoundtrip Store = Refl; commandRoundtrip Search = Refl; commandRoundtrip Copy = Refl
commandRoundtrip Noop = Refl; commandRoundtrip Capability = Refl

public export
stateToTag : State -> Bits8
stateToTag NotAuthenticated = 0; stateToTag Authenticated = 1
stateToTag Selected = 2; stateToTag LogoutState = 3

public export
tagToState : Bits8 -> Maybe State
tagToState 0 = Just NotAuthenticated; tagToState 1 = Just Authenticated
tagToState 2 = Just Selected; tagToState 3 = Just LogoutState; tagToState _ = Nothing

public export
stateRoundtrip : (s : State) -> tagToState (stateToTag s) = Just s
stateRoundtrip NotAuthenticated = Refl; stateRoundtrip Authenticated = Refl
stateRoundtrip Selected = Refl; stateRoundtrip LogoutState = Refl

public export
flagToTag : Flag -> Bits8
flagToTag Seen = 0; flagToTag Answered = 1; flagToTag Flagged = 2
flagToTag Deleted = 3; flagToTag Draft = 4; flagToTag Recent = 5

public export
tagToFlag : Bits8 -> Maybe Flag
tagToFlag 0 = Just Seen; tagToFlag 1 = Just Answered; tagToFlag 2 = Just Flagged
tagToFlag 3 = Just Deleted; tagToFlag 4 = Just Draft; tagToFlag 5 = Just Recent; tagToFlag _ = Nothing

public export
flagRoundtrip : (f : Flag) -> tagToFlag (flagToTag f) = Just f
flagRoundtrip Seen = Refl; flagRoundtrip Answered = Refl; flagRoundtrip Flagged = Refl
flagRoundtrip Deleted = Refl; flagRoundtrip Draft = Refl; flagRoundtrip Recent = Refl

public export
data ValidStateTransition : State -> State -> Type where
  AuthLogin : ValidStateTransition NotAuthenticated Authenticated
  SelectMailbox : ValidStateTransition Authenticated Selected
  CloseMailbox : ValidStateTransition Selected Authenticated
  LogoutFromUnauth : ValidStateTransition NotAuthenticated LogoutState
  LogoutFromAuth : ValidStateTransition Authenticated LogoutState
  LogoutFromSelected : ValidStateTransition Selected LogoutState

public export
validateStateTransition : (from : State) -> (to : State) -> Maybe (ValidStateTransition from to)
validateStateTransition NotAuthenticated Authenticated = Just AuthLogin
validateStateTransition Authenticated Selected = Just SelectMailbox
validateStateTransition Selected Authenticated = Just CloseMailbox
validateStateTransition NotAuthenticated LogoutState = Just LogoutFromUnauth
validateStateTransition Authenticated LogoutState = Just LogoutFromAuth
validateStateTransition Selected LogoutState = Just LogoutFromSelected
validateStateTransition _ _ = Nothing

public export
cannotSelectWithoutAuth : ValidStateTransition NotAuthenticated Selected -> Void
cannotSelectWithoutAuth _ impossible
