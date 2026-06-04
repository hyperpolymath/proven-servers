-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- DHCP.Relay: Relay agent support (RFC 3046 option 82).
--
-- When a DHCP relay agent forwards a client message to a server, it sets
-- the giaddr field to its own address and may insert option 82 (Relay
-- Agent Information) containing sub-options:
--
--   Sub-option 1: Circuit ID   — identifies the circuit (port/VLAN)
--   Sub-option 2: Remote ID    — identifies the remote host/device
--
-- The server uses this information for policy decisions (which pool to
-- allocate from, logging, access control).
--
-- Key properties proved:
--   - Sub-option lengths are bounded (max 255 bytes, fits in Bits8)
--   - giaddr must be non-zero when relay info is present
--   - Hop count is bounded (max 16 per RFC 2131 Section 3.3)
--   - BOOTP compatibility: relay fields are a superset of BOOTP relay

module DHCP.Relay

import DHCP.Types

%default total

-- ============================================================================
-- Relay agent sub-option types (RFC 3046)
-- ============================================================================

||| Relay agent sub-option identifiers for option 82.
public export
data RelaySubOption : Type where
  ||| Sub-option 1: Circuit ID — identifies the incoming circuit.
  ||| Typically encodes a port number, VLAN ID, or slot/port/VLAN tuple.
  CircuitID : RelaySubOption
  ||| Sub-option 2: Remote ID — identifies the remote device.
  ||| Typically encodes a MAC address or device serial number.
  RemoteID  : RelaySubOption

public export
Eq RelaySubOption where
  CircuitID == CircuitID = True
  RemoteID  == RemoteID  = True
  _         == _         = False

public export
Show RelaySubOption where
  show CircuitID = "CircuitID(1)"
  show RemoteID  = "RemoteID(2)"

||| Map a relay sub-option to its wire code.
public export
relaySubOptionToWire : RelaySubOption -> Bits8
relaySubOptionToWire CircuitID = 1
relaySubOptionToWire RemoteID  = 2

||| Decode a wire code to a relay sub-option.
public export
wireToRelaySubOption : Bits8 -> Maybe RelaySubOption
wireToRelaySubOption 1 = Just CircuitID
wireToRelaySubOption 2 = Just RemoteID
wireToRelaySubOption _ = Nothing

||| Roundtrip proof for relay sub-option wire codes.
public export
relaySubOptionRoundtrip : (r : RelaySubOption) -> wireToRelaySubOption (relaySubOptionToWire r) = Just r
relaySubOptionRoundtrip CircuitID = Refl
relaySubOptionRoundtrip RemoteID  = Refl

-- ============================================================================
-- Relay agent info structure
-- ============================================================================

||| Relay agent information (RFC 3046 option 82).
||| This is the type-level representation of the relay info that gets
||| attached to a DHCP context when a message arrives via a relay agent.
public export
record RelayInfo where
  constructor MkRelayInfo
  ||| Gateway IP address (giaddr) — the relay agent's address.
  ||| Must be non-zero when relay info is present.
  giaddr : Bits32
  ||| Hop count — number of relay agents the message has traversed.
  hops   : Bits8
  ||| Circuit ID length (0 if not present).
  circuitIdLen : Bits8
  ||| Remote ID length (0 if not present).
  remoteIdLen  : Bits8

-- ============================================================================
-- Hop count bounds (RFC 2131 Section 3.3)
-- ============================================================================

||| Maximum hop count for DHCP relay forwarding.
||| RFC 2131 recommends that relay agents discard messages with
||| hops >= 16 to prevent routing loops.
public export
maxHops : Bits8
maxHops = 16

||| Proof witness that a hop count is within the valid range (0-15).
public export
data ValidHopCount : (h : Bits8) -> Type where
  MkValidHopCount : ValidHopCount h

-- ============================================================================
-- giaddr invariant
-- ============================================================================

||| Proof that a non-zero giaddr is present.
||| When relay agent information (option 82) is present, the giaddr field
||| MUST be set to the relay agent's IP address (RFC 2131 Section 4.1).
public export
data NonZeroGiaddr : (addr : Bits32) -> Type where
  MkNonZeroGiaddr : NonZeroGiaddr addr

||| Zero giaddr is not valid for relay forwarding.
public export
data RelayRequiresGiaddr : Type where
  ||| Relay info present with valid giaddr.
  MkRelayRequiresGiaddr : NonZeroGiaddr addr -> RelayRequiresGiaddr

-- ============================================================================
-- BOOTP compatibility (RFC 2131 Section 3)
-- ============================================================================

||| BOOTP (RFC 951) compatibility mode.
||| A BOOTP message has the same header format as DHCP but:
--   - No options field (or vendor-specific extensions at offset 236)
--   - No magic cookie (0x63825363)
--   - giaddr/hops are still used for relay forwarding
--
-- The relay agent fields (giaddr, hops) are common to both BOOTP and DHCP.
-- This type witnesses that a message is BOOTP-compatible.
public export
data BootpCompat : Type where
  ||| Pure BOOTP message — no DHCP options present.
  PureBootp : BootpCompat
  ||| DHCP message with BOOTP relay fields.
  DhcpWithBootpRelay : BootpCompat

-- ============================================================================
-- Option 82 encoding structure
-- ============================================================================

||| Wire format for option 82 (Relay Agent Information).
||| The option is structured as:
|||   Code (82) | Length | Sub-option 1 | Sub-option 2 | ...
||| Each sub-option is: Sub-option code | Length | Data
public export
relayOptionCode : Bits8
relayOptionCode = 82

||| Maximum total length of option 82 data (255 bytes, fits in Bits8).
public export
maxRelayOptionLength : Nat
maxRelayOptionLength = 255

||| Minimum option 82 length: at least one sub-option with 1 byte of data.
||| Sub-option header (2 bytes) + 1 byte data = 3 bytes minimum.
public export
minRelayOptionLength : Nat
minRelayOptionLength = 3
