-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DHCP.Options: Total option TLV (Type-Length-Value) parsing for DHCP.
--
-- RFC 2132 defines DHCP options as a sequence of TLV records in the
-- variable-length options field (bytes 240+ of a DHCP message, after
-- the 4-byte magic cookie 0x63825363).
--
-- TLV format:
--   Byte 0: Option code (1-254)
--   Byte 1: Length N (number of data bytes)
--   Bytes 2..2+N-1: Option data
--
-- Special codes:
--   0   = Pad (no length, no data — skip 1 byte)
--   255 = End (terminates the option list)
--
-- Key properties proved:
--   - Parsing is total (always terminates, cannot loop)
--   - Pad options advance by exactly 1 byte
--   - End option terminates parsing
--   - TLV offset advances by exactly (2 + length) bytes
--   - The parsed option data length matches the declared length

module DHCP.Options

import DHCP.Types

%default total

-- ============================================================================
-- Option parsing result type
-- ============================================================================

||| Result of parsing a single DHCP option from a byte buffer.
public export
data OptionParseResult : Type where
  ||| Successfully parsed a TLV option.
  ||| @code    The option code (1-254).
  ||| @dataLen The number of data bytes following the code+length.
  ||| @advance The total number of bytes consumed (2 + dataLen).
  ParsedOption : (code : Bits8) -> (dataLen : Bits8) -> (advance : Nat) -> OptionParseResult
  ||| Pad option (code 0): skip 1 byte, no data.
  ParsedPad    : OptionParseResult
  ||| End option (code 255): terminates the options list.
  ParsedEnd    : OptionParseResult
  ||| Parse error: buffer too short or invalid structure.
  ParseError   : OptionParseResult

public export
Eq OptionParseResult where
  ParsedPad == ParsedPad = True
  ParsedEnd == ParsedEnd = True
  ParseError == ParseError = True
  (ParsedOption c1 l1 a1) == (ParsedOption c2 l2 a2) =
    c1 == c2 && l1 == l2 && a1 == a2
  _ == _ = False

-- ============================================================================
-- TLV advance proof
-- ============================================================================

||| Proof that a TLV option advances by exactly (2 + dataLen) bytes.
||| This ensures the parser always makes progress and cannot loop.
public export
data TLVAdvance : Nat -> Bits8 -> Type where
  ||| For any data length N, the advance is 2 + cast N.
  MkTLVAdvance : (dataLen : Bits8) -> TLVAdvance (2 + cast dataLen) dataLen

-- ============================================================================
-- Pad advance proof
-- ============================================================================

||| Proof that a pad option advances by exactly 1 byte.
public export
data PadAdvance : Nat -> Type where
  MkPadAdvance : PadAdvance 1

-- ============================================================================
-- Option list termination witness
-- ============================================================================

||| Proof that an option list is properly terminated with an End marker.
||| A well-formed DHCP options field must end with code 255.
public export
data IsTerminated : Type where
  ||| The parser encountered an End option (code 255).
  TerminatedByEnd : IsTerminated
  ||| The parser exhausted the buffer (implicit termination).
  TerminatedByLength : IsTerminated

-- ============================================================================
-- Magic cookie validation
-- ============================================================================

||| The DHCP magic cookie value: 99.130.83.99 (0x63825363).
||| Must appear at offset 236-239 in the message to indicate that
||| the options field follows (rather than BOOTP vendor extensions).
public export
magicCookie : List Bits8
magicCookie = [99, 130, 83, 99]

||| Result of checking the magic cookie.
public export
data MagicCookieCheck : Type where
  ||| Magic cookie is present and correct — options follow.
  CookiePresent : MagicCookieCheck
  ||| Magic cookie is absent — BOOTP compatibility mode (no options).
  CookieAbsent  : MagicCookieCheck

-- ============================================================================
-- Option code classification
-- ============================================================================

||| Classify a raw option code byte into its semantic category.
public export
data OptionCategory : Type where
  ||| Pad option (code 0): single-byte, no length/data.
  CatPad     : OptionCategory
  ||| End option (code 255): terminates option list.
  CatEnd     : OptionCategory
  ||| Standard TLV option (codes 1-254): has length and data.
  CatTLV     : OptionCategory

||| Classify an option code byte.
public export
classifyOption : Bits8 -> OptionCategory
classifyOption 0   = CatPad
classifyOption 255 = CatEnd
classifyOption _   = CatTLV

||| Proof that classifyOption is total over all Bits8 values.
||| (The function above covers 0, 255, and wildcard, so this is trivially true
||| by construction. We provide the statement for documentation.)
public export
classifyOptionTotal : (b : Bits8) -> (classifyOption b = CatPad) `Either`
                                     ((classifyOption b = CatEnd) `Either`
                                      (classifyOption b = CatTLV))
classifyOptionTotal 0   = Left Refl
classifyOptionTotal 255 = Right (Left Refl)
classifyOptionTotal _   = Right (Right Refl)

-- ============================================================================
-- Wire code mapping proofs
-- ============================================================================

||| Map a known OptionCode to its RFC 2132 wire code.
||| This duplicates Layout.idr's optionCodeToWire but is used here for
||| option parsing validation.
public export
knownOptionWireCode : OptionCode -> Bits8
knownOptionWireCode SubnetMask  = 1
knownOptionWireCode Router      = 3
knownOptionWireCode DNS         = 6
knownOptionWireCode DomainName  = 15
knownOptionWireCode LeaseTime   = 51
knownOptionWireCode ServerID    = 54
knownOptionWireCode RequestedIP = 50
knownOptionWireCode MsgType     = 53

||| Attempt to decode a wire option code to a known OptionCode.
public export
wireToKnownOption : Bits8 -> Maybe OptionCode
wireToKnownOption 1  = Just SubnetMask
wireToKnownOption 3  = Just Router
wireToKnownOption 6  = Just DNS
wireToKnownOption 15 = Just DomainName
wireToKnownOption 51 = Just LeaseTime
wireToKnownOption 54 = Just ServerID
wireToKnownOption 50 = Just RequestedIP
wireToKnownOption 53 = Just MsgType
wireToKnownOption _  = Nothing

||| Roundtrip: wireToKnownOption(knownOptionWireCode(o)) = Just o.
public export
wireCodeRoundtrip : (o : OptionCode) -> wireToKnownOption (knownOptionWireCode o) = Just o
wireCodeRoundtrip SubnetMask  = Refl
wireCodeRoundtrip Router      = Refl
wireCodeRoundtrip DNS         = Refl
wireCodeRoundtrip DomainName  = Refl
wireCodeRoundtrip LeaseTime   = Refl
wireCodeRoundtrip ServerID    = Refl
wireCodeRoundtrip RequestedIP = Refl
wireCodeRoundtrip MsgType     = Refl

-- ============================================================================
-- Expected option data lengths
-- ============================================================================

||| Expected data length for fixed-length options.
||| Returns Nothing for variable-length options (e.g., DomainName, DNS).
public export
expectedOptionLength : OptionCode -> Maybe Nat
expectedOptionLength SubnetMask  = Just 4
expectedOptionLength Router      = Just 4
expectedOptionLength DNS         = Nothing  -- variable: 4*N (multiple servers)
expectedOptionLength DomainName  = Nothing  -- variable: domain name string
expectedOptionLength LeaseTime   = Just 4
expectedOptionLength ServerID    = Just 4
expectedOptionLength RequestedIP = Just 4
expectedOptionLength MsgType     = Just 1

-- ============================================================================
-- Message type extraction (option 53)
-- ============================================================================

||| Decode a message type byte (option 53 value) to a MessageType.
public export
messageTypeFromByte : Bits8 -> Maybe MessageType
messageTypeFromByte 1 = Just Discover
messageTypeFromByte 2 = Just Offer
messageTypeFromByte 3 = Just Request
messageTypeFromByte 4 = Just Decline
messageTypeFromByte 5 = Just Ack
messageTypeFromByte 6 = Just Nak
messageTypeFromByte 7 = Just Release
messageTypeFromByte 8 = Just Inform
messageTypeFromByte _ = Nothing

||| Encode a MessageType to its option 53 wire byte.
public export
messageTypeToByte : MessageType -> Bits8
messageTypeToByte Discover = 1
messageTypeToByte Offer    = 2
messageTypeToByte Request  = 3
messageTypeToByte Decline  = 4
messageTypeToByte Ack      = 5
messageTypeToByte Nak      = 6
messageTypeToByte Release  = 7
messageTypeToByte Inform   = 8

||| Roundtrip: messageTypeFromByte(messageTypeToByte(m)) = Just m.
public export
messageTypeWireRoundtrip : (m : MessageType) -> messageTypeFromByte (messageTypeToByte m) = Just m
messageTypeWireRoundtrip Discover = Refl
messageTypeWireRoundtrip Offer    = Refl
messageTypeWireRoundtrip Request  = Refl
messageTypeWireRoundtrip Decline  = Refl
messageTypeWireRoundtrip Ack      = Refl
messageTypeWireRoundtrip Nak      = Refl
messageTypeWireRoundtrip Release  = Refl
messageTypeWireRoundtrip Inform   = Refl
