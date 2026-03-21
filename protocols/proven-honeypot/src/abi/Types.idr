-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
module HoneypotABI.Types
import Honeypot.Types
%default total

public export
serviceEmulationToTag : ServiceEmulation -> Bits8
serviceEmulationToTag SSH = 0; serviceEmulationToTag HTTP = 1; serviceEmulationToTag FTP = 2
serviceEmulationToTag SMTP = 3; serviceEmulationToTag Telnet = 4; serviceEmulationToTag MySQL = 5
serviceEmulationToTag RDP = 6

public export
tagToServiceEmulation : Bits8 -> Maybe ServiceEmulation
tagToServiceEmulation 0 = Just SSH; tagToServiceEmulation 1 = Just HTTP; tagToServiceEmulation 2 = Just FTP
tagToServiceEmulation 3 = Just SMTP; tagToServiceEmulation 4 = Just Telnet; tagToServiceEmulation 5 = Just MySQL
tagToServiceEmulation 6 = Just RDP; tagToServiceEmulation _ = Nothing

public export
serviceEmulationRoundtrip : (s : ServiceEmulation) -> tagToServiceEmulation (serviceEmulationToTag s) = Just s
serviceEmulationRoundtrip SSH = Refl; serviceEmulationRoundtrip HTTP = Refl; serviceEmulationRoundtrip FTP = Refl
serviceEmulationRoundtrip SMTP = Refl; serviceEmulationRoundtrip Telnet = Refl; serviceEmulationRoundtrip MySQL = Refl
serviceEmulationRoundtrip RDP = Refl

public export
interactionLevelToTag : InteractionLevel -> Bits8
interactionLevelToTag Low = 0; interactionLevelToTag Medium = 1; interactionLevelToTag High = 2

public export
tagToInteractionLevel : Bits8 -> Maybe InteractionLevel
tagToInteractionLevel 0 = Just Low; tagToInteractionLevel 1 = Just Medium
tagToInteractionLevel 2 = Just High; tagToInteractionLevel _ = Nothing

public export
interactionLevelRoundtrip : (i : InteractionLevel) -> tagToInteractionLevel (interactionLevelToTag i) = Just i
interactionLevelRoundtrip Low = Refl; interactionLevelRoundtrip Medium = Refl; interactionLevelRoundtrip High = Refl

public export
alertSeverityToTag : AlertSeverity -> Bits8
alertSeverityToTag Info = 0; alertSeverityToTag ASLow = 1; alertSeverityToTag ASMedium = 2
alertSeverityToTag ASHigh = 3; alertSeverityToTag Critical = 4

public export
tagToAlertSeverity : Bits8 -> Maybe AlertSeverity
tagToAlertSeverity 0 = Just Info; tagToAlertSeverity 1 = Just ASLow; tagToAlertSeverity 2 = Just ASMedium
tagToAlertSeverity 3 = Just ASHigh; tagToAlertSeverity 4 = Just Critical; tagToAlertSeverity _ = Nothing

public export
alertSeverityRoundtrip : (a : AlertSeverity) -> tagToAlertSeverity (alertSeverityToTag a) = Just a
alertSeverityRoundtrip Info = Refl; alertSeverityRoundtrip ASLow = Refl; alertSeverityRoundtrip ASMedium = Refl
alertSeverityRoundtrip ASHigh = Refl; alertSeverityRoundtrip Critical = Refl

public export
attackerActionToTag : AttackerAction -> Bits8
attackerActionToTag Scan = 0; attackerActionToTag BruteForce = 1; attackerActionToTag Exploit = 2
attackerActionToTag Payload = 3; attackerActionToTag Lateral = 4; attackerActionToTag Exfiltration = 5

public export
tagToAttackerAction : Bits8 -> Maybe AttackerAction
tagToAttackerAction 0 = Just Scan; tagToAttackerAction 1 = Just BruteForce; tagToAttackerAction 2 = Just Exploit
tagToAttackerAction 3 = Just Payload; tagToAttackerAction 4 = Just Lateral; tagToAttackerAction 5 = Just Exfiltration
tagToAttackerAction _ = Nothing

public export
attackerActionRoundtrip : (a : AttackerAction) -> tagToAttackerAction (attackerActionToTag a) = Just a
attackerActionRoundtrip Scan = Refl; attackerActionRoundtrip BruteForce = Refl; attackerActionRoundtrip Exploit = Refl
attackerActionRoundtrip Payload = Refl; attackerActionRoundtrip Lateral = Refl; attackerActionRoundtrip Exfiltration = Refl

public export
data ServerState : Type where
  HPIdle : ServerState; HPDeployed : ServerState; HPEngaged : ServerState; HPShutdown : ServerState

public export
Eq ServerState where
  HPIdle == HPIdle = True; HPDeployed == HPDeployed = True; HPEngaged == HPEngaged = True
  HPShutdown == HPShutdown = True; _ == _ = False

public export
Show ServerState where
  show HPIdle = "Idle"; show HPDeployed = "Deployed"; show HPEngaged = "Engaged"; show HPShutdown = "Shutdown"

public export
serverStateToTag : ServerState -> Bits8
serverStateToTag HPIdle = 0; serverStateToTag HPDeployed = 1; serverStateToTag HPEngaged = 2; serverStateToTag HPShutdown = 3

public export
tagToServerState : Bits8 -> Maybe ServerState
tagToServerState 0 = Just HPIdle; tagToServerState 1 = Just HPDeployed; tagToServerState 2 = Just HPEngaged
tagToServerState 3 = Just HPShutdown; tagToServerState _ = Nothing

public export
serverStateRoundtrip : (s : ServerState) -> tagToServerState (serverStateToTag s) = Just s
serverStateRoundtrip HPIdle = Refl; serverStateRoundtrip HPDeployed = Refl
serverStateRoundtrip HPEngaged = Refl; serverStateRoundtrip HPShutdown = Refl
