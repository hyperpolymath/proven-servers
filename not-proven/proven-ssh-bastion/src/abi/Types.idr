-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- SshBastionABI.Types: C-ABI-compatible numeric representations of SshBastion types.
--
-- Maps every constructor of the core SshBastion sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/ssh_bastion.zig) exactly.
--
-- Types covered:
--   SshMessageType            (8 constructors, tags 0-7)
--   AuthMethod                (4 constructors, tags 0-3)
--   KexMethod                 (6 constructors, tags 0-5)
--   ChannelType               (4 constructors, tags 0-3)
--   BastionState              (6 constructors, tags 0-5)
--   ChannelState              (4 constructors, tags 0-3)
--   DisconnectReason          (12 constructors, tags 0-11)
--   HostKeyAlgorithm          (4 constructors, tags 0-3)
--   CipherAlgorithm           (6 constructors, tags 0-5)
--   ChannelOpenFailure        (4 constructors, tags 0-3)

module SshBastionABI.Types

%default total

---------------------------------------------------------------------------
-- SshMessageType (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
ssh_message_typeSize : Nat
ssh_message_typeSize = 1

||| SshMessageType sum type for ABI encoding.
public export
data SshMessageType : Type where
  Kexinit : SshMessageType
  Newkeys : SshMessageType
  ServiceRequest : SshMessageType
  UserauthRequest : SshMessageType
  ChannelOpen : SshMessageType
  ChannelData : SshMessageType
  ChannelClose : SshMessageType
  Disconnect : SshMessageType

||| Encode a SshMessageType to its ABI tag value.
public export
ssh_message_typeToTag : SshMessageType -> Bits8
ssh_message_typeToTag Kexinit = 0
ssh_message_typeToTag Newkeys = 1
ssh_message_typeToTag ServiceRequest = 2
ssh_message_typeToTag UserauthRequest = 3
ssh_message_typeToTag ChannelOpen = 4
ssh_message_typeToTag ChannelData = 5
ssh_message_typeToTag ChannelClose = 6
ssh_message_typeToTag Disconnect = 7

||| Decode an ABI tag to a SshMessageType.
public export
tagToSshMessageType : Bits8 -> Maybe SshMessageType
tagToSshMessageType 0 = Just Kexinit
tagToSshMessageType 1 = Just Newkeys
tagToSshMessageType 2 = Just ServiceRequest
tagToSshMessageType 3 = Just UserauthRequest
tagToSshMessageType 4 = Just ChannelOpen
tagToSshMessageType 5 = Just ChannelData
tagToSshMessageType 6 = Just ChannelClose
tagToSshMessageType 7 = Just Disconnect
tagToSshMessageType _ = Nothing

||| Roundtrip proof: decoding an encoded SshMessageType yields the original.
public export
ssh_message_typeRoundtrip : (x : SshMessageType) -> tagToSshMessageType (ssh_message_typeToTag x) = Just x
ssh_message_typeRoundtrip Kexinit = Refl
ssh_message_typeRoundtrip Newkeys = Refl
ssh_message_typeRoundtrip ServiceRequest = Refl
ssh_message_typeRoundtrip UserauthRequest = Refl
ssh_message_typeRoundtrip ChannelOpen = Refl
ssh_message_typeRoundtrip ChannelData = Refl
ssh_message_typeRoundtrip ChannelClose = Refl
ssh_message_typeRoundtrip Disconnect = Refl

---------------------------------------------------------------------------
-- AuthMethod (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
auth_methodSize : Nat
auth_methodSize = 1

||| AuthMethod sum type for ABI encoding.
public export
data AuthMethod : Type where
  Publickey : AuthMethod
  Password : AuthMethod
  KeyboardInteractive : AuthMethod
  AuthNone : AuthMethod

||| Encode a AuthMethod to its ABI tag value.
public export
auth_methodToTag : AuthMethod -> Bits8
auth_methodToTag Publickey = 0
auth_methodToTag Password = 1
auth_methodToTag KeyboardInteractive = 2
auth_methodToTag AuthNone = 3

||| Decode an ABI tag to a AuthMethod.
public export
tagToAuthMethod : Bits8 -> Maybe AuthMethod
tagToAuthMethod 0 = Just Publickey
tagToAuthMethod 1 = Just Password
tagToAuthMethod 2 = Just KeyboardInteractive
tagToAuthMethod 3 = Just AuthNone
tagToAuthMethod _ = Nothing

||| Roundtrip proof: decoding an encoded AuthMethod yields the original.
public export
auth_methodRoundtrip : (x : AuthMethod) -> tagToAuthMethod (auth_methodToTag x) = Just x
auth_methodRoundtrip Publickey = Refl
auth_methodRoundtrip Password = Refl
auth_methodRoundtrip KeyboardInteractive = Refl
auth_methodRoundtrip AuthNone = Refl

---------------------------------------------------------------------------
-- KexMethod (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
kex_methodSize : Nat
kex_methodSize = 1

||| KexMethod sum type for ABI encoding.
public export
data KexMethod : Type where
  DiffieHellmanGroup14Sha256 : KexMethod
  Curve25519Sha256 : KexMethod
  DiffieHellmanGroup16Sha512 : KexMethod
  DiffieHellmanGroup18Sha512 : KexMethod
  EcdhSha2Nistp256 : KexMethod
  EcdhSha2Nistp384 : KexMethod

||| Encode a KexMethod to its ABI tag value.
public export
kex_methodToTag : KexMethod -> Bits8
kex_methodToTag DiffieHellmanGroup14Sha256 = 0
kex_methodToTag Curve25519Sha256 = 1
kex_methodToTag DiffieHellmanGroup16Sha512 = 2
kex_methodToTag DiffieHellmanGroup18Sha512 = 3
kex_methodToTag EcdhSha2Nistp256 = 4
kex_methodToTag EcdhSha2Nistp384 = 5

||| Decode an ABI tag to a KexMethod.
public export
tagToKexMethod : Bits8 -> Maybe KexMethod
tagToKexMethod 0 = Just DiffieHellmanGroup14Sha256
tagToKexMethod 1 = Just Curve25519Sha256
tagToKexMethod 2 = Just DiffieHellmanGroup16Sha512
tagToKexMethod 3 = Just DiffieHellmanGroup18Sha512
tagToKexMethod 4 = Just EcdhSha2Nistp256
tagToKexMethod 5 = Just EcdhSha2Nistp384
tagToKexMethod _ = Nothing

||| Roundtrip proof: decoding an encoded KexMethod yields the original.
public export
kex_methodRoundtrip : (x : KexMethod) -> tagToKexMethod (kex_methodToTag x) = Just x
kex_methodRoundtrip DiffieHellmanGroup14Sha256 = Refl
kex_methodRoundtrip Curve25519Sha256 = Refl
kex_methodRoundtrip DiffieHellmanGroup16Sha512 = Refl
kex_methodRoundtrip DiffieHellmanGroup18Sha512 = Refl
kex_methodRoundtrip EcdhSha2Nistp256 = Refl
kex_methodRoundtrip EcdhSha2Nistp384 = Refl

---------------------------------------------------------------------------
-- ChannelType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
channel_typeSize : Nat
channel_typeSize = 1

||| ChannelType sum type for ABI encoding.
public export
data ChannelType : Type where
  Session : ChannelType
  DirectTcpip : ChannelType
  ForwardedTcpip : ChannelType
  X11 : ChannelType

||| Encode a ChannelType to its ABI tag value.
public export
channel_typeToTag : ChannelType -> Bits8
channel_typeToTag Session = 0
channel_typeToTag DirectTcpip = 1
channel_typeToTag ForwardedTcpip = 2
channel_typeToTag X11 = 3

||| Decode an ABI tag to a ChannelType.
public export
tagToChannelType : Bits8 -> Maybe ChannelType
tagToChannelType 0 = Just Session
tagToChannelType 1 = Just DirectTcpip
tagToChannelType 2 = Just ForwardedTcpip
tagToChannelType 3 = Just X11
tagToChannelType _ = Nothing

||| Roundtrip proof: decoding an encoded ChannelType yields the original.
public export
channel_typeRoundtrip : (x : ChannelType) -> tagToChannelType (channel_typeToTag x) = Just x
channel_typeRoundtrip Session = Refl
channel_typeRoundtrip DirectTcpip = Refl
channel_typeRoundtrip ForwardedTcpip = Refl
channel_typeRoundtrip X11 = Refl

---------------------------------------------------------------------------
-- BastionState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
bastion_stateSize : Nat
bastion_stateSize = 1

||| BastionState sum type for ABI encoding.
public export
data BastionState : Type where
  Connected : BastionState
  KeyExchanged : BastionState
  Authenticated : BastionState
  ChannelOpen : BastionState
  Active : BastionState
  Closed : BastionState

||| Encode a BastionState to its ABI tag value.
public export
bastion_stateToTag : BastionState -> Bits8
bastion_stateToTag Connected = 0
bastion_stateToTag KeyExchanged = 1
bastion_stateToTag Authenticated = 2
bastion_stateToTag ChannelOpen = 3
bastion_stateToTag Active = 4
bastion_stateToTag Closed = 5

||| Decode an ABI tag to a BastionState.
public export
tagToBastionState : Bits8 -> Maybe BastionState
tagToBastionState 0 = Just Connected
tagToBastionState 1 = Just KeyExchanged
tagToBastionState 2 = Just Authenticated
tagToBastionState 3 = Just ChannelOpen
tagToBastionState 4 = Just Active
tagToBastionState 5 = Just Closed
tagToBastionState _ = Nothing

||| Roundtrip proof: decoding an encoded BastionState yields the original.
public export
bastion_stateRoundtrip : (x : BastionState) -> tagToBastionState (bastion_stateToTag x) = Just x
bastion_stateRoundtrip Connected = Refl
bastion_stateRoundtrip KeyExchanged = Refl
bastion_stateRoundtrip Authenticated = Refl
bastion_stateRoundtrip ChannelOpen = Refl
bastion_stateRoundtrip Active = Refl
bastion_stateRoundtrip Closed = Refl

---------------------------------------------------------------------------
-- ChannelState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
channel_stateSize : Nat
channel_stateSize = 1

||| ChannelState sum type for ABI encoding.
public export
data ChannelState : Type where
  Opening : ChannelState
  Open : ChannelState
  Closing : ChannelState
  Closed : ChannelState

||| Encode a ChannelState to its ABI tag value.
public export
channel_stateToTag : ChannelState -> Bits8
channel_stateToTag Opening = 0
channel_stateToTag Open = 1
channel_stateToTag Closing = 2
channel_stateToTag Closed = 3

||| Decode an ABI tag to a ChannelState.
public export
tagToChannelState : Bits8 -> Maybe ChannelState
tagToChannelState 0 = Just Opening
tagToChannelState 1 = Just Open
tagToChannelState 2 = Just Closing
tagToChannelState 3 = Just Closed
tagToChannelState _ = Nothing

||| Roundtrip proof: decoding an encoded ChannelState yields the original.
public export
channel_stateRoundtrip : (x : ChannelState) -> tagToChannelState (channel_stateToTag x) = Just x
channel_stateRoundtrip Opening = Refl
channel_stateRoundtrip Open = Refl
channel_stateRoundtrip Closing = Refl
channel_stateRoundtrip Closed = Refl

---------------------------------------------------------------------------
-- DisconnectReason (12 constructors, tags 0-11)
---------------------------------------------------------------------------

public export
disconnect_reasonSize : Nat
disconnect_reasonSize = 1

||| DisconnectReason sum type for ABI encoding.
public export
data DisconnectReason : Type where
  HostNotAllowed : DisconnectReason
  ProtocolError : DisconnectReason
  KeyExchangeFailed : DisconnectReason
  HostAuthFailed : DisconnectReason
  MacError : DisconnectReason
  ServiceNotAvailable : DisconnectReason
  VersionNotSupported : DisconnectReason
  HostKeyNotVerifiable : DisconnectReason
  ConnectionLost : DisconnectReason
  ByApplication : DisconnectReason
  TooManyConnections : DisconnectReason
  AuthCancelled : DisconnectReason

||| Encode a DisconnectReason to its ABI tag value.
public export
disconnect_reasonToTag : DisconnectReason -> Bits8
disconnect_reasonToTag HostNotAllowed = 0
disconnect_reasonToTag ProtocolError = 1
disconnect_reasonToTag KeyExchangeFailed = 2
disconnect_reasonToTag HostAuthFailed = 3
disconnect_reasonToTag MacError = 4
disconnect_reasonToTag ServiceNotAvailable = 5
disconnect_reasonToTag VersionNotSupported = 6
disconnect_reasonToTag HostKeyNotVerifiable = 7
disconnect_reasonToTag ConnectionLost = 8
disconnect_reasonToTag ByApplication = 9
disconnect_reasonToTag TooManyConnections = 10
disconnect_reasonToTag AuthCancelled = 11

||| Decode an ABI tag to a DisconnectReason.
public export
tagToDisconnectReason : Bits8 -> Maybe DisconnectReason
tagToDisconnectReason 0 = Just HostNotAllowed
tagToDisconnectReason 1 = Just ProtocolError
tagToDisconnectReason 2 = Just KeyExchangeFailed
tagToDisconnectReason 3 = Just HostAuthFailed
tagToDisconnectReason 4 = Just MacError
tagToDisconnectReason 5 = Just ServiceNotAvailable
tagToDisconnectReason 6 = Just VersionNotSupported
tagToDisconnectReason 7 = Just HostKeyNotVerifiable
tagToDisconnectReason 8 = Just ConnectionLost
tagToDisconnectReason 9 = Just ByApplication
tagToDisconnectReason 10 = Just TooManyConnections
tagToDisconnectReason 11 = Just AuthCancelled
tagToDisconnectReason _ = Nothing

||| Roundtrip proof: decoding an encoded DisconnectReason yields the original.
public export
disconnect_reasonRoundtrip : (x : DisconnectReason) -> tagToDisconnectReason (disconnect_reasonToTag x) = Just x
disconnect_reasonRoundtrip HostNotAllowed = Refl
disconnect_reasonRoundtrip ProtocolError = Refl
disconnect_reasonRoundtrip KeyExchangeFailed = Refl
disconnect_reasonRoundtrip HostAuthFailed = Refl
disconnect_reasonRoundtrip MacError = Refl
disconnect_reasonRoundtrip ServiceNotAvailable = Refl
disconnect_reasonRoundtrip VersionNotSupported = Refl
disconnect_reasonRoundtrip HostKeyNotVerifiable = Refl
disconnect_reasonRoundtrip ConnectionLost = Refl
disconnect_reasonRoundtrip ByApplication = Refl
disconnect_reasonRoundtrip TooManyConnections = Refl
disconnect_reasonRoundtrip AuthCancelled = Refl

---------------------------------------------------------------------------
-- HostKeyAlgorithm (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
host_key_algorithmSize : Nat
host_key_algorithmSize = 1

||| HostKeyAlgorithm sum type for ABI encoding.
public export
data HostKeyAlgorithm : Type where
  SshEd25519 : HostKeyAlgorithm
  RsaSha2256 : HostKeyAlgorithm
  RsaSha2512 : HostKeyAlgorithm
  EcdsaNistp256 : HostKeyAlgorithm

||| Encode a HostKeyAlgorithm to its ABI tag value.
public export
host_key_algorithmToTag : HostKeyAlgorithm -> Bits8
host_key_algorithmToTag SshEd25519 = 0
host_key_algorithmToTag RsaSha2256 = 1
host_key_algorithmToTag RsaSha2512 = 2
host_key_algorithmToTag EcdsaNistp256 = 3

||| Decode an ABI tag to a HostKeyAlgorithm.
public export
tagToHostKeyAlgorithm : Bits8 -> Maybe HostKeyAlgorithm
tagToHostKeyAlgorithm 0 = Just SshEd25519
tagToHostKeyAlgorithm 1 = Just RsaSha2256
tagToHostKeyAlgorithm 2 = Just RsaSha2512
tagToHostKeyAlgorithm 3 = Just EcdsaNistp256
tagToHostKeyAlgorithm _ = Nothing

||| Roundtrip proof: decoding an encoded HostKeyAlgorithm yields the original.
public export
host_key_algorithmRoundtrip : (x : HostKeyAlgorithm) -> tagToHostKeyAlgorithm (host_key_algorithmToTag x) = Just x
host_key_algorithmRoundtrip SshEd25519 = Refl
host_key_algorithmRoundtrip RsaSha2256 = Refl
host_key_algorithmRoundtrip RsaSha2512 = Refl
host_key_algorithmRoundtrip EcdsaNistp256 = Refl

---------------------------------------------------------------------------
-- CipherAlgorithm (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
cipher_algorithmSize : Nat
cipher_algorithmSize = 1

||| CipherAlgorithm sum type for ABI encoding.
public export
data CipherAlgorithm : Type where
  Chacha20Poly1305 : CipherAlgorithm
  Aes256Gcm : CipherAlgorithm
  Aes128Gcm : CipherAlgorithm
  Aes256Ctr : CipherAlgorithm
  Aes192Ctr : CipherAlgorithm
  Aes128Ctr : CipherAlgorithm

||| Encode a CipherAlgorithm to its ABI tag value.
public export
cipher_algorithmToTag : CipherAlgorithm -> Bits8
cipher_algorithmToTag Chacha20Poly1305 = 0
cipher_algorithmToTag Aes256Gcm = 1
cipher_algorithmToTag Aes128Gcm = 2
cipher_algorithmToTag Aes256Ctr = 3
cipher_algorithmToTag Aes192Ctr = 4
cipher_algorithmToTag Aes128Ctr = 5

||| Decode an ABI tag to a CipherAlgorithm.
public export
tagToCipherAlgorithm : Bits8 -> Maybe CipherAlgorithm
tagToCipherAlgorithm 0 = Just Chacha20Poly1305
tagToCipherAlgorithm 1 = Just Aes256Gcm
tagToCipherAlgorithm 2 = Just Aes128Gcm
tagToCipherAlgorithm 3 = Just Aes256Ctr
tagToCipherAlgorithm 4 = Just Aes192Ctr
tagToCipherAlgorithm 5 = Just Aes128Ctr
tagToCipherAlgorithm _ = Nothing

||| Roundtrip proof: decoding an encoded CipherAlgorithm yields the original.
public export
cipher_algorithmRoundtrip : (x : CipherAlgorithm) -> tagToCipherAlgorithm (cipher_algorithmToTag x) = Just x
cipher_algorithmRoundtrip Chacha20Poly1305 = Refl
cipher_algorithmRoundtrip Aes256Gcm = Refl
cipher_algorithmRoundtrip Aes128Gcm = Refl
cipher_algorithmRoundtrip Aes256Ctr = Refl
cipher_algorithmRoundtrip Aes192Ctr = Refl
cipher_algorithmRoundtrip Aes128Ctr = Refl

---------------------------------------------------------------------------
-- ChannelOpenFailure (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
channel_open_failureSize : Nat
channel_open_failureSize = 1

||| ChannelOpenFailure sum type for ABI encoding.
public export
data ChannelOpenFailure : Type where
  AdminProhibited : ChannelOpenFailure
  ConnectFailed : ChannelOpenFailure
  UnknownChannelType : ChannelOpenFailure
  ResourceShortage : ChannelOpenFailure

||| Encode a ChannelOpenFailure to its ABI tag value.
public export
channel_open_failureToTag : ChannelOpenFailure -> Bits8
channel_open_failureToTag AdminProhibited = 0
channel_open_failureToTag ConnectFailed = 1
channel_open_failureToTag UnknownChannelType = 2
channel_open_failureToTag ResourceShortage = 3

||| Decode an ABI tag to a ChannelOpenFailure.
public export
tagToChannelOpenFailure : Bits8 -> Maybe ChannelOpenFailure
tagToChannelOpenFailure 0 = Just AdminProhibited
tagToChannelOpenFailure 1 = Just ConnectFailed
tagToChannelOpenFailure 2 = Just UnknownChannelType
tagToChannelOpenFailure 3 = Just ResourceShortage
tagToChannelOpenFailure _ = Nothing

||| Roundtrip proof: decoding an encoded ChannelOpenFailure yields the original.
public export
channel_open_failureRoundtrip : (x : ChannelOpenFailure) -> tagToChannelOpenFailure (channel_open_failureToTag x) = Just x
channel_open_failureRoundtrip AdminProhibited = Refl
channel_open_failureRoundtrip ConnectFailed = Refl
channel_open_failureRoundtrip UnknownChannelType = Refl
channel_open_failureRoundtrip ResourceShortage = Refl
