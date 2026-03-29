-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SSHABI.Layout: C-ABI-compatible numeric representations of SSH types.
--
-- Maps every constructor of the core SSH sum types to fixed Bits8 values
-- for C interop.  Each type gets a total encoder, partial decoder, and
-- roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/ssh_bastion.h)
-- and the Zig FFI enums (ffi/zig/src/ssh_bastion.zig) exactly.

module SSHABI.Layout

import SSH.Transport
import SSH.Auth
import SSH.Channel
import SSH.Session

%default total

---------------------------------------------------------------------------
-- SshMessageType (8 constructors, tags 0-7)
---------------------------------------------------------------------------

||| SSH message types relevant to bastion operation.
public export
data SshMessageType : Type where
  KEXINIT              : SshMessageType
  NEWKEYS              : SshMessageType
  SERVICE_REQUEST      : SshMessageType
  USERAUTH_REQUEST     : SshMessageType
  CHANNEL_OPEN         : SshMessageType
  CHANNEL_DATA         : SshMessageType
  CHANNEL_CLOSE        : SshMessageType
  DISCONNECT           : SshMessageType

public export
Eq SshMessageType where
  KEXINIT          == KEXINIT          = True
  NEWKEYS          == NEWKEYS          = True
  SERVICE_REQUEST  == SERVICE_REQUEST  = True
  USERAUTH_REQUEST == USERAUTH_REQUEST = True
  CHANNEL_OPEN     == CHANNEL_OPEN     = True
  CHANNEL_DATA     == CHANNEL_DATA     = True
  CHANNEL_CLOSE    == CHANNEL_CLOSE    = True
  DISCONNECT       == DISCONNECT       = True
  _                == _                = False

public export
messageTypeSize : Nat
messageTypeSize = 1

public export
messageTypeToTag : SshMessageType -> Bits8
messageTypeToTag KEXINIT          = 0
messageTypeToTag NEWKEYS          = 1
messageTypeToTag SERVICE_REQUEST  = 2
messageTypeToTag USERAUTH_REQUEST = 3
messageTypeToTag CHANNEL_OPEN     = 4
messageTypeToTag CHANNEL_DATA     = 5
messageTypeToTag CHANNEL_CLOSE    = 6
messageTypeToTag DISCONNECT       = 7

public export
tagToMessageType : Bits8 -> Maybe SshMessageType
tagToMessageType 0 = Just KEXINIT
tagToMessageType 1 = Just NEWKEYS
tagToMessageType 2 = Just SERVICE_REQUEST
tagToMessageType 3 = Just USERAUTH_REQUEST
tagToMessageType 4 = Just CHANNEL_OPEN
tagToMessageType 5 = Just CHANNEL_DATA
tagToMessageType 6 = Just CHANNEL_CLOSE
tagToMessageType 7 = Just DISCONNECT
tagToMessageType _ = Nothing

public export
messageTypeRoundtrip : (m : SshMessageType) -> tagToMessageType (messageTypeToTag m) = Just m
messageTypeRoundtrip KEXINIT          = Refl
messageTypeRoundtrip NEWKEYS          = Refl
messageTypeRoundtrip SERVICE_REQUEST  = Refl
messageTypeRoundtrip USERAUTH_REQUEST = Refl
messageTypeRoundtrip CHANNEL_OPEN     = Refl
messageTypeRoundtrip CHANNEL_DATA     = Refl
messageTypeRoundtrip CHANNEL_CLOSE    = Refl
messageTypeRoundtrip DISCONNECT       = Refl

---------------------------------------------------------------------------
-- AuthMethodTag (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
authMethodSize : Nat
authMethodSize = 1

public export
authMethodToTag : AuthMethod -> Bits8
authMethodToTag PublicKey           = 0
authMethodToTag Password            = 1
authMethodToTag KeyboardInteractive = 2
authMethodToTag AuthNone            = 3

public export
tagToAuthMethod : Bits8 -> Maybe AuthMethod
tagToAuthMethod 0 = Just PublicKey
tagToAuthMethod 1 = Just Password
tagToAuthMethod 2 = Just KeyboardInteractive
tagToAuthMethod 3 = Just AuthNone
tagToAuthMethod _ = Nothing

public export
authMethodRoundtrip : (a : AuthMethod) -> tagToAuthMethod (authMethodToTag a) = Just a
authMethodRoundtrip PublicKey           = Refl
authMethodRoundtrip Password            = Refl
authMethodRoundtrip KeyboardInteractive = Refl
authMethodRoundtrip AuthNone            = Refl

---------------------------------------------------------------------------
-- KexMethodTag (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
kexMethodSize : Nat
kexMethodSize = 1

public export
kexMethodToTag : KexMethod -> Bits8
kexMethodToTag DiffieHellmanGroup14SHA256 = 0
kexMethodToTag Curve25519SHA256           = 1
kexMethodToTag DiffieHellmanGroup16SHA512 = 2
kexMethodToTag DiffieHellmanGroup18SHA512 = 3
kexMethodToTag EcdhSHA2NistP256           = 4
kexMethodToTag EcdhSHA2NistP384           = 5

public export
tagToKexMethod : Bits8 -> Maybe KexMethod
tagToKexMethod 0 = Just DiffieHellmanGroup14SHA256
tagToKexMethod 1 = Just Curve25519SHA256
tagToKexMethod 2 = Just DiffieHellmanGroup16SHA512
tagToKexMethod 3 = Just DiffieHellmanGroup18SHA512
tagToKexMethod 4 = Just EcdhSHA2NistP256
tagToKexMethod 5 = Just EcdhSHA2NistP384
tagToKexMethod _ = Nothing

public export
kexMethodRoundtrip : (k : KexMethod) -> tagToKexMethod (kexMethodToTag k) = Just k
kexMethodRoundtrip DiffieHellmanGroup14SHA256 = Refl
kexMethodRoundtrip Curve25519SHA256           = Refl
kexMethodRoundtrip DiffieHellmanGroup16SHA512 = Refl
kexMethodRoundtrip DiffieHellmanGroup18SHA512 = Refl
kexMethodRoundtrip EcdhSHA2NistP256           = Refl
kexMethodRoundtrip EcdhSHA2NistP384           = Refl

---------------------------------------------------------------------------
-- ChannelTypeTag (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
channelTypeSize : Nat
channelTypeSize = 1

public export
channelTypeToTag : ChannelType -> Bits8
channelTypeToTag Session        = 0
channelTypeToTag DirectTcpIp    = 1
channelTypeToTag ForwardedTcpIp = 2
channelTypeToTag X11            = 3

public export
tagToChannelType : Bits8 -> Maybe ChannelType
tagToChannelType 0 = Just Session
tagToChannelType 1 = Just DirectTcpIp
tagToChannelType 2 = Just ForwardedTcpIp
tagToChannelType 3 = Just X11
tagToChannelType _ = Nothing

public export
channelTypeRoundtrip : (c : ChannelType) -> tagToChannelType (channelTypeToTag c) = Just c
channelTypeRoundtrip Session        = Refl
channelTypeRoundtrip DirectTcpIp    = Refl
channelTypeRoundtrip ForwardedTcpIp = Refl
channelTypeRoundtrip X11            = Refl

---------------------------------------------------------------------------
-- SessionStateTag (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
sessionStateSize : Nat
sessionStateSize = 1

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag VersionExchange = 0
sessionStateToTag KeyExchange     = 1
sessionStateToTag UserAuth        = 2
sessionStateToTag Authenticated   = 3
sessionStateToTag Disconnected    = 4

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just VersionExchange
tagToSessionState 1 = Just KeyExchange
tagToSessionState 2 = Just UserAuth
tagToSessionState 3 = Just Authenticated
tagToSessionState 4 = Just Disconnected
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip VersionExchange = Refl
sessionStateRoundtrip KeyExchange     = Refl
sessionStateRoundtrip UserAuth        = Refl
sessionStateRoundtrip Authenticated   = Refl
sessionStateRoundtrip Disconnected    = Refl

---------------------------------------------------------------------------
-- ChannelStateTag (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
channelStateSize : Nat
channelStateSize = 1

public export
channelStateToTag : ChannelState -> Bits8
channelStateToTag Opening = 0
channelStateToTag Open    = 1
channelStateToTag Closing = 2
channelStateToTag Closed  = 3

public export
tagToChannelState : Bits8 -> Maybe ChannelState
tagToChannelState 0 = Just Opening
tagToChannelState 1 = Just Open
tagToChannelState 2 = Just Closing
tagToChannelState 3 = Just Closed
tagToChannelState _ = Nothing

public export
channelStateRoundtrip : (s : ChannelState) -> tagToChannelState (channelStateToTag s) = Just s
channelStateRoundtrip Opening = Refl
channelStateRoundtrip Open    = Refl
channelStateRoundtrip Closing = Refl
channelStateRoundtrip Closed  = Refl

---------------------------------------------------------------------------
-- DisconnectReasonTag (12 constructors, tags 0-11)
---------------------------------------------------------------------------

public export
disconnectReasonSize : Nat
disconnectReasonSize = 1

public export
disconnectReasonToTag : DisconnectReason -> Bits8
disconnectReasonToTag HostNotAllowed       = 0
disconnectReasonToTag ProtocolError        = 1
disconnectReasonToTag KeyExchangeFailed    = 2
disconnectReasonToTag HostAuthFailed       = 3
disconnectReasonToTag MACError             = 4
disconnectReasonToTag ServiceNotAvailable  = 5
disconnectReasonToTag VersionNotSupported  = 6
disconnectReasonToTag HostKeyNotVerifiable = 7
disconnectReasonToTag ConnectionLost       = 8
disconnectReasonToTag ByApplication        = 9
disconnectReasonToTag TooManyConnections   = 10
disconnectReasonToTag AuthCancelled        = 11

public export
tagToDisconnectReason : Bits8 -> Maybe DisconnectReason
tagToDisconnectReason 0  = Just HostNotAllowed
tagToDisconnectReason 1  = Just ProtocolError
tagToDisconnectReason 2  = Just KeyExchangeFailed
tagToDisconnectReason 3  = Just HostAuthFailed
tagToDisconnectReason 4  = Just MACError
tagToDisconnectReason 5  = Just ServiceNotAvailable
tagToDisconnectReason 6  = Just VersionNotSupported
tagToDisconnectReason 7  = Just HostKeyNotVerifiable
tagToDisconnectReason 8  = Just ConnectionLost
tagToDisconnectReason 9  = Just ByApplication
tagToDisconnectReason 10 = Just TooManyConnections
tagToDisconnectReason 11 = Just AuthCancelled
tagToDisconnectReason _  = Nothing

public export
disconnectReasonRoundtrip : (d : DisconnectReason) -> tagToDisconnectReason (disconnectReasonToTag d) = Just d
disconnectReasonRoundtrip HostNotAllowed       = Refl
disconnectReasonRoundtrip ProtocolError        = Refl
disconnectReasonRoundtrip KeyExchangeFailed    = Refl
disconnectReasonRoundtrip HostAuthFailed       = Refl
disconnectReasonRoundtrip MACError             = Refl
disconnectReasonRoundtrip ServiceNotAvailable  = Refl
disconnectReasonRoundtrip VersionNotSupported  = Refl
disconnectReasonRoundtrip HostKeyNotVerifiable = Refl
disconnectReasonRoundtrip ConnectionLost       = Refl
disconnectReasonRoundtrip ByApplication        = Refl
disconnectReasonRoundtrip TooManyConnections   = Refl
disconnectReasonRoundtrip AuthCancelled        = Refl

---------------------------------------------------------------------------
-- HostKeyAlgorithmTag (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
hostKeyAlgorithmSize : Nat
hostKeyAlgorithmSize = 1

public export
hostKeyAlgorithmToTag : HostKeyAlgorithm -> Bits8
hostKeyAlgorithmToTag SshEd25519    = 0
hostKeyAlgorithmToTag RsaSHA2_256   = 1
hostKeyAlgorithmToTag RsaSHA2_512   = 2
hostKeyAlgorithmToTag EcdsaNistP256 = 3

public export
tagToHostKeyAlgorithm : Bits8 -> Maybe HostKeyAlgorithm
tagToHostKeyAlgorithm 0 = Just SshEd25519
tagToHostKeyAlgorithm 1 = Just RsaSHA2_256
tagToHostKeyAlgorithm 2 = Just RsaSHA2_512
tagToHostKeyAlgorithm 3 = Just EcdsaNistP256
tagToHostKeyAlgorithm _ = Nothing

public export
hostKeyAlgorithmRoundtrip : (h : HostKeyAlgorithm) -> tagToHostKeyAlgorithm (hostKeyAlgorithmToTag h) = Just h
hostKeyAlgorithmRoundtrip SshEd25519    = Refl
hostKeyAlgorithmRoundtrip RsaSHA2_256   = Refl
hostKeyAlgorithmRoundtrip RsaSHA2_512   = Refl
hostKeyAlgorithmRoundtrip EcdsaNistP256 = Refl

---------------------------------------------------------------------------
-- CipherAlgorithmTag (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
cipherAlgorithmSize : Nat
cipherAlgorithmSize = 1

public export
cipherAlgorithmToTag : CipherAlgorithm -> Bits8
cipherAlgorithmToTag ChaCha20Poly1305 = 0
cipherAlgorithmToTag Aes256GCM        = 1
cipherAlgorithmToTag Aes128GCM        = 2
cipherAlgorithmToTag Aes256CTR        = 3
cipherAlgorithmToTag Aes192CTR        = 4
cipherAlgorithmToTag Aes128CTR        = 5

public export
tagToCipherAlgorithm : Bits8 -> Maybe CipherAlgorithm
tagToCipherAlgorithm 0 = Just ChaCha20Poly1305
tagToCipherAlgorithm 1 = Just Aes256GCM
tagToCipherAlgorithm 2 = Just Aes128GCM
tagToCipherAlgorithm 3 = Just Aes256CTR
tagToCipherAlgorithm 4 = Just Aes192CTR
tagToCipherAlgorithm 5 = Just Aes128CTR
tagToCipherAlgorithm _ = Nothing

public export
cipherAlgorithmRoundtrip : (c : CipherAlgorithm) -> tagToCipherAlgorithm (cipherAlgorithmToTag c) = Just c
cipherAlgorithmRoundtrip ChaCha20Poly1305 = Refl
cipherAlgorithmRoundtrip Aes256GCM        = Refl
cipherAlgorithmRoundtrip Aes128GCM        = Refl
cipherAlgorithmRoundtrip Aes256CTR        = Refl
cipherAlgorithmRoundtrip Aes192CTR        = Refl
cipherAlgorithmRoundtrip Aes128CTR        = Refl

---------------------------------------------------------------------------
-- ChannelOpenFailureTag (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
channelOpenFailureSize : Nat
channelOpenFailureSize = 1

public export
channelOpenFailureToTag : ChannelOpenFailure -> Bits8
channelOpenFailureToTag AdminProhibited    = 0
channelOpenFailureToTag ConnectFailed      = 1
channelOpenFailureToTag UnknownChannelType = 2
channelOpenFailureToTag ResourceShortage   = 3

public export
tagToChannelOpenFailure : Bits8 -> Maybe ChannelOpenFailure
tagToChannelOpenFailure 0 = Just AdminProhibited
tagToChannelOpenFailure 1 = Just ConnectFailed
tagToChannelOpenFailure 2 = Just UnknownChannelType
tagToChannelOpenFailure 3 = Just ResourceShortage
tagToChannelOpenFailure _ = Nothing

public export
channelOpenFailureRoundtrip : (f : ChannelOpenFailure) -> tagToChannelOpenFailure (channelOpenFailureToTag f) = Just f
channelOpenFailureRoundtrip AdminProhibited    = Refl
channelOpenFailureRoundtrip ConnectFailed      = Refl
channelOpenFailureRoundtrip UnknownChannelType = Refl
channelOpenFailureRoundtrip ResourceShortage   = Refl
