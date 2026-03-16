-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- IDS.Types : Core types for an Intrusion Detection/Prevention System.
--
-- Defines alert severity levels, detection methods, response actions,
-- network protocol identifiers, traffic directions, threat levels,
-- rule match criteria, and rule match status.

module IDS.Types

%default total

---------------------------------------------------------------------------
-- AlertSeverity : Severity level assigned to an IDS alert.
---------------------------------------------------------------------------

||| Severity level assigned to a generated IDS alert.
public export
data AlertSeverity : Type where
  Low      : AlertSeverity
  Medium   : AlertSeverity
  High     : AlertSeverity
  Critical : AlertSeverity

export
Show AlertSeverity where
  show Low      = "Low"
  show Medium   = "Medium"
  show High     = "High"
  show Critical = "Critical"

export
Eq AlertSeverity where
  Low      == Low      = True
  Medium   == Medium   = True
  High     == High     = True
  Critical == Critical = True
  _        == _        = False

---------------------------------------------------------------------------
-- DetectionMethod : Engine detection strategy.
---------------------------------------------------------------------------

||| Strategy the IDS engine uses to identify threats.
public export
data DetectionMethod : Type where
  Signature : DetectionMethod
  Anomaly   : DetectionMethod
  Stateful  : DetectionMethod
  Heuristic : DetectionMethod

export
Show DetectionMethod where
  show Signature = "Signature"
  show Anomaly   = "Anomaly"
  show Stateful  = "Stateful"
  show Heuristic = "Heuristic"

export
Eq DetectionMethod where
  Signature == Signature = True
  Anomaly   == Anomaly   = True
  Stateful  == Stateful  = True
  Heuristic == Heuristic = True
  _         == _         = False

---------------------------------------------------------------------------
-- Protocol : Network protocol identifiers for rule matching.
---------------------------------------------------------------------------

||| Network protocols the IDS can inspect.
public export
data Protocol : Type where
  TCP  : Protocol
  UDP  : Protocol
  ICMP : Protocol
  DNS  : Protocol
  HTTP : Protocol
  TLS  : Protocol
  SSH  : Protocol

export
Show Protocol where
  show TCP  = "TCP"
  show UDP  = "UDP"
  show ICMP = "ICMP"
  show DNS  = "DNS"
  show HTTP = "HTTP"
  show TLS  = "TLS"
  show SSH  = "SSH"

export
Eq Protocol where
  TCP  == TCP  = True
  UDP  == UDP  = True
  ICMP == ICMP = True
  DNS  == DNS  = True
  HTTP == HTTP = True
  TLS  == TLS  = True
  SSH  == SSH  = True
  _    == _    = False

---------------------------------------------------------------------------
-- Action : Response action when a rule fires.
---------------------------------------------------------------------------

||| Action taken by the IDS/IPS when a detection rule matches.
public export
data Action : Type where
  Alert : Action
  Drop  : Action
  Log   : Action
  Block : Action
  Pass  : Action

export
Show Action where
  show Alert = "Alert"
  show Drop  = "Drop"
  show Log   = "Log"
  show Block = "Block"
  show Pass  = "Pass"

export
Eq Action where
  Alert == Alert = True
  Drop  == Drop  = True
  Log   == Log   = True
  Block == Block = True
  Pass  == Pass  = True
  _     == _     = False

---------------------------------------------------------------------------
-- Direction : Traffic direction for rule scope.
---------------------------------------------------------------------------

||| Direction of network traffic a rule applies to.
public export
data Direction : Type where
  Inbound  : Direction
  Outbound : Direction
  Both     : Direction

export
Show Direction where
  show Inbound  = "Inbound"
  show Outbound = "Outbound"
  show Both     = "Both"

export
Eq Direction where
  Inbound  == Inbound  = True
  Outbound == Outbound = True
  Both     == Both     = True
  _        == _        = False

---------------------------------------------------------------------------
-- ThreatLevel : Severity of a detected threat.
---------------------------------------------------------------------------

||| Assessed severity of a detected threat.
public export
data ThreatLevel : Type where
  TLInfo     : ThreatLevel
  TLLow      : ThreatLevel
  TLMedium   : ThreatLevel
  TLHigh     : ThreatLevel
  TLCritical : ThreatLevel

export
Show ThreatLevel where
  show TLInfo     = "Info"
  show TLLow      = "Low"
  show TLMedium   = "Medium"
  show TLHigh     = "High"
  show TLCritical = "Critical"

export
Eq ThreatLevel where
  TLInfo     == TLInfo     = True
  TLLow      == TLLow      = True
  TLMedium   == TLMedium   = True
  TLHigh     == TLHigh     = True
  TLCritical == TLCritical = True
  _          == _          = False

---------------------------------------------------------------------------
-- RuleMatch : Criteria for matching packets against rules.
---------------------------------------------------------------------------

||| Packet inspection criteria for rule matching.
public export
data RuleMatch : Type where
  SrcAddr   : RuleMatch
  DstAddr   : RuleMatch
  SrcPort   : RuleMatch
  DstPort   : RuleMatch
  Content   : RuleMatch
  Regex     : RuleMatch
  Threshold : RuleMatch
  FlowBits  : RuleMatch

export
Show RuleMatch where
  show SrcAddr   = "SrcAddr"
  show DstAddr   = "DstAddr"
  show SrcPort   = "SrcPort"
  show DstPort   = "DstPort"
  show Content   = "Content"
  show Regex     = "Regex"
  show Threshold = "Threshold"
  show FlowBits  = "FlowBits"

export
Eq RuleMatch where
  SrcAddr   == SrcAddr   = True
  DstAddr   == DstAddr   = True
  SrcPort   == SrcPort   = True
  DstPort   == DstPort   = True
  Content   == Content   = True
  Regex     == Regex     = True
  Threshold == Threshold = True
  FlowBits  == FlowBits  = True
  _         == _         = False

---------------------------------------------------------------------------
-- MatchStatus : Whether a rule matched or not.
---------------------------------------------------------------------------

||| Result of evaluating a detection rule against a packet.
public export
data MatchStatus : Type where
  NoMatch    : MatchStatus
  Matched    : MatchStatus
  Suppressed : MatchStatus

export
Show MatchStatus where
  show NoMatch    = "NoMatch"
  show Matched    = "Matched"
  show Suppressed = "Suppressed"

export
Eq MatchStatus where
  NoMatch    == NoMatch    = True
  Matched    == Matched    = True
  Suppressed == Suppressed = True
  _          == _          = False
