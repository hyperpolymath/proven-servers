-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SOCKSABI.Types: C-ABI-compatible numeric representations of SOCKS5 types.
--
-- Maps every constructor of the core SOCKS5 sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/socks.h) and the
-- Zig FFI enums (ffi/zig/src/socks.zig) exactly.
--
-- Types covered:
--   AuthMethod  (4 constructors, tags 0-3)
--   Command     (3 constructors, tags 0-2)
--   AddressType (3 constructors, tags 0-2)
--   Reply       (9 constructors, tags 0-8)
--   State       (6 constructors, tags 0-5)

module SOCKSABI.Types

import SOCKS.Types

%default total

---------------------------------------------------------------------------
-- AuthMethod (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
authMethodSize : Nat
authMethodSize = 1

||| Encode an AuthMethod to its ABI tag value.
public export
authMethodToTag : AuthMethod -> Bits8
authMethodToTag NoAuth           = 0
authMethodToTag GSSAPI           = 1
authMethodToTag UsernamePassword = 2
authMethodToTag NoAcceptable     = 3

||| Decode an ABI tag to an AuthMethod.
public export
tagToAuthMethod : Bits8 -> Maybe AuthMethod
tagToAuthMethod 0 = Just NoAuth
tagToAuthMethod 1 = Just GSSAPI
tagToAuthMethod 2 = Just UsernamePassword
tagToAuthMethod 3 = Just NoAcceptable
tagToAuthMethod _ = Nothing

||| Roundtrip proof: decoding an encoded AuthMethod yields the original.
public export
authMethodRoundtrip : (a : AuthMethod) -> tagToAuthMethod (authMethodToTag a) = Just a
authMethodRoundtrip NoAuth           = Refl
authMethodRoundtrip GSSAPI           = Refl
authMethodRoundtrip UsernamePassword = Refl
authMethodRoundtrip NoAcceptable     = Refl

---------------------------------------------------------------------------
-- Command (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
commandSize : Nat
commandSize = 1

||| Encode a Command to its ABI tag value.
public export
commandToTag : Command -> Bits8
commandToTag Connect      = 0
commandToTag Bind         = 1
commandToTag UDPAssociate = 2

||| Decode an ABI tag to a Command.
public export
tagToCommand : Bits8 -> Maybe Command
tagToCommand 0 = Just Connect
tagToCommand 1 = Just Bind
tagToCommand 2 = Just UDPAssociate
tagToCommand _ = Nothing

||| Roundtrip proof: decoding an encoded Command yields the original.
public export
commandRoundtrip : (c : Command) -> tagToCommand (commandToTag c) = Just c
commandRoundtrip Connect      = Refl
commandRoundtrip Bind         = Refl
commandRoundtrip UDPAssociate = Refl

---------------------------------------------------------------------------
-- AddressType (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
addressTypeSize : Nat
addressTypeSize = 1

||| Encode an AddressType to its ABI tag value.
public export
addressTypeToTag : AddressType -> Bits8
addressTypeToTag IPv4       = 0
addressTypeToTag DomainName = 1
addressTypeToTag IPv6       = 2

||| Decode an ABI tag to an AddressType.
public export
tagToAddressType : Bits8 -> Maybe AddressType
tagToAddressType 0 = Just IPv4
tagToAddressType 1 = Just DomainName
tagToAddressType 2 = Just IPv6
tagToAddressType _ = Nothing

||| Roundtrip proof: decoding an encoded AddressType yields the original.
public export
addressTypeRoundtrip : (a : AddressType) -> tagToAddressType (addressTypeToTag a) = Just a
addressTypeRoundtrip IPv4       = Refl
addressTypeRoundtrip DomainName = Refl
addressTypeRoundtrip IPv6       = Refl

---------------------------------------------------------------------------
-- Reply (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
replySize : Nat
replySize = 1

||| Encode a Reply to its ABI tag value.
public export
replyToTag : Reply -> Bits8
replyToTag Succeeded               = 0
replyToTag GeneralFailure          = 1
replyToTag NotAllowed              = 2
replyToTag NetworkUnreachable      = 3
replyToTag HostUnreachable         = 4
replyToTag ConnectionRefused       = 5
replyToTag TTLExpired              = 6
replyToTag CommandNotSupported     = 7
replyToTag AddressTypeNotSupported = 8

||| Decode an ABI tag to a Reply.
public export
tagToReply : Bits8 -> Maybe Reply
tagToReply 0 = Just Succeeded
tagToReply 1 = Just GeneralFailure
tagToReply 2 = Just NotAllowed
tagToReply 3 = Just NetworkUnreachable
tagToReply 4 = Just HostUnreachable
tagToReply 5 = Just ConnectionRefused
tagToReply 6 = Just TTLExpired
tagToReply 7 = Just CommandNotSupported
tagToReply 8 = Just AddressTypeNotSupported
tagToReply _ = Nothing

||| Roundtrip proof: decoding an encoded Reply yields the original.
public export
replyRoundtrip : (r : Reply) -> tagToReply (replyToTag r) = Just r
replyRoundtrip Succeeded               = Refl
replyRoundtrip GeneralFailure          = Refl
replyRoundtrip NotAllowed              = Refl
replyRoundtrip NetworkUnreachable      = Refl
replyRoundtrip HostUnreachable         = Refl
replyRoundtrip ConnectionRefused       = Refl
replyRoundtrip TTLExpired              = Refl
replyRoundtrip CommandNotSupported     = Refl
replyRoundtrip AddressTypeNotSupported = Refl

---------------------------------------------------------------------------
-- State (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
stateSize : Nat
stateSize = 1

||| Encode a State to its ABI tag value.
public export
stateToTag : State -> Bits8
stateToTag Initial        = 0
stateToTag Authenticating = 1
stateToTag Authenticated  = 2
stateToTag Connecting     = 3
stateToTag Established    = 4
stateToTag Closed         = 5

||| Decode an ABI tag to a State.
public export
tagToState : Bits8 -> Maybe State
tagToState 0 = Just Initial
tagToState 1 = Just Authenticating
tagToState 2 = Just Authenticated
tagToState 3 = Just Connecting
tagToState 4 = Just Established
tagToState 5 = Just Closed
tagToState _ = Nothing

||| Roundtrip proof: decoding an encoded State yields the original.
public export
stateRoundtrip : (s : State) -> tagToState (stateToTag s) = Just s
stateRoundtrip Initial        = Refl
stateRoundtrip Authenticating = Refl
stateRoundtrip Authenticated  = Refl
stateRoundtrip Connecting     = Refl
stateRoundtrip Established    = Refl
stateRoundtrip Closed         = Refl
