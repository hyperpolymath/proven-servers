// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenSsh protocol bindings.

open ProvenSsh

let test_sshMessageType_roundtrip = () => {
  assert(sshMessageTypeFromTag(0) == Some(Kexinit))
  assert(sshMessageTypeFromTag(1) == Some(Newkeys))
  assert(sshMessageTypeFromTag(2) == Some(ServiceRequest))
  assert(sshMessageTypeFromTag(3) == Some(UserauthRequest))
  assert(sshMessageTypeFromTag(4) == Some(ChannelOpen))
  assert(sshMessageTypeFromTag(5) == Some(ChannelData))
  assert(sshMessageTypeFromTag(6) == Some(ChannelClose))
  assert(sshMessageTypeFromTag(7) == Some(Disconnect))
  assert(sshMessageTypeFromTag(8) == None)
}

let test_sshMessageType_toTag = () => {
  assert(sshMessageTypeToTag(Kexinit) == 0)
  assert(sshMessageTypeToTag(Newkeys) == 1)
  assert(sshMessageTypeToTag(ServiceRequest) == 2)
  assert(sshMessageTypeToTag(UserauthRequest) == 3)
  assert(sshMessageTypeToTag(ChannelOpen) == 4)
  assert(sshMessageTypeToTag(ChannelData) == 5)
  assert(sshMessageTypeToTag(ChannelClose) == 6)
  assert(sshMessageTypeToTag(Disconnect) == 7)
}

let test_authMethod_roundtrip = () => {
  assert(authMethodFromTag(0) == Some(Publickey))
  assert(authMethodFromTag(1) == Some(Password))
  assert(authMethodFromTag(2) == Some(KeyboardInteractive))
  assert(authMethodFromTag(3) == Some(AuthNone))
  assert(authMethodFromTag(4) == None)
}

let test_authMethod_toTag = () => {
  assert(authMethodToTag(Publickey) == 0)
  assert(authMethodToTag(Password) == 1)
  assert(authMethodToTag(KeyboardInteractive) == 2)
  assert(authMethodToTag(AuthNone) == 3)
}

let test_kexMethod_roundtrip = () => {
  assert(kexMethodFromTag(0) == Some(DiffieHellmanGroup14Sha256))
  assert(kexMethodFromTag(1) == Some(Curve25519Sha256))
  assert(kexMethodFromTag(2) == Some(DiffieHellmanGroup16Sha512))
  assert(kexMethodFromTag(3) == Some(DiffieHellmanGroup18Sha512))
  assert(kexMethodFromTag(4) == Some(EcdhSha2Nistp256))
  assert(kexMethodFromTag(5) == Some(EcdhSha2Nistp384))
  assert(kexMethodFromTag(6) == None)
}

let test_kexMethod_toTag = () => {
  assert(kexMethodToTag(DiffieHellmanGroup14Sha256) == 0)
  assert(kexMethodToTag(Curve25519Sha256) == 1)
  assert(kexMethodToTag(DiffieHellmanGroup16Sha512) == 2)
  assert(kexMethodToTag(DiffieHellmanGroup18Sha512) == 3)
  assert(kexMethodToTag(EcdhSha2Nistp256) == 4)
  assert(kexMethodToTag(EcdhSha2Nistp384) == 5)
}

let test_channelType_roundtrip = () => {
  assert(channelTypeFromTag(0) == Some(Session))
  assert(channelTypeFromTag(1) == Some(DirectTcpip))
  assert(channelTypeFromTag(2) == Some(ForwardedTcpip))
  assert(channelTypeFromTag(3) == Some(X11))
  assert(channelTypeFromTag(4) == None)
}

let test_channelType_toTag = () => {
  assert(channelTypeToTag(Session) == 0)
  assert(channelTypeToTag(DirectTcpip) == 1)
  assert(channelTypeToTag(ForwardedTcpip) == 2)
  assert(channelTypeToTag(X11) == 3)
}

let test_bastionState_roundtrip = () => {
  assert(bastionStateFromTag(0) == Some(Connected))
  assert(bastionStateFromTag(1) == Some(KeyExchanged))
  assert(bastionStateFromTag(2) == Some(Authenticated))
  assert(bastionStateFromTag(3) == Some(ChannelOpen))
  assert(bastionStateFromTag(4) == Some(Active))
  assert(bastionStateFromTag(5) == Some(Closed))
  assert(bastionStateFromTag(6) == None)
}

let test_bastionState_toTag = () => {
  assert(bastionStateToTag(Connected) == 0)
  assert(bastionStateToTag(KeyExchanged) == 1)
  assert(bastionStateToTag(Authenticated) == 2)
  assert(bastionStateToTag(ChannelOpen) == 3)
  assert(bastionStateToTag(Active) == 4)
  assert(bastionStateToTag(Closed) == 5)
}

let test_channelState_roundtrip = () => {
  assert(channelStateFromTag(0) == Some(Opening))
  assert(channelStateFromTag(1) == Some(Open))
  assert(channelStateFromTag(2) == Some(Closing))
  assert(channelStateFromTag(3) == Some(Closed))
  assert(channelStateFromTag(4) == None)
}

let test_channelState_toTag = () => {
  assert(channelStateToTag(Opening) == 0)
  assert(channelStateToTag(Open) == 1)
  assert(channelStateToTag(Closing) == 2)
  assert(channelStateToTag(Closed) == 3)
}

let test_disconnectReason_roundtrip = () => {
  assert(disconnectReasonFromTag(0) == Some(HostNotAllowed))
  assert(disconnectReasonFromTag(1) == Some(ProtocolError))
  assert(disconnectReasonFromTag(2) == Some(KeyExchangeFailed))
  assert(disconnectReasonFromTag(3) == Some(HostAuthFailed))
  assert(disconnectReasonFromTag(4) == Some(MacError))
  assert(disconnectReasonFromTag(5) == Some(ServiceNotAvailable))
  assert(disconnectReasonFromTag(6) == Some(VersionNotSupported))
  assert(disconnectReasonFromTag(7) == Some(HostKeyNotVerifiable))
  assert(disconnectReasonFromTag(8) == Some(ConnectionLost))
  assert(disconnectReasonFromTag(9) == Some(ByApplication))
  assert(disconnectReasonFromTag(10) == Some(TooManyConnections))
  assert(disconnectReasonFromTag(11) == Some(AuthCancelled))
  assert(disconnectReasonFromTag(12) == None)
}

let test_disconnectReason_toTag = () => {
  assert(disconnectReasonToTag(HostNotAllowed) == 0)
  assert(disconnectReasonToTag(ProtocolError) == 1)
  assert(disconnectReasonToTag(KeyExchangeFailed) == 2)
  assert(disconnectReasonToTag(HostAuthFailed) == 3)
  assert(disconnectReasonToTag(MacError) == 4)
  assert(disconnectReasonToTag(ServiceNotAvailable) == 5)
  assert(disconnectReasonToTag(VersionNotSupported) == 6)
  assert(disconnectReasonToTag(HostKeyNotVerifiable) == 7)
  assert(disconnectReasonToTag(ConnectionLost) == 8)
  assert(disconnectReasonToTag(ByApplication) == 9)
  assert(disconnectReasonToTag(TooManyConnections) == 10)
  assert(disconnectReasonToTag(AuthCancelled) == 11)
}

let test_hostKeyAlgorithm_roundtrip = () => {
  assert(hostKeyAlgorithmFromTag(0) == Some(SshEd25519))
  assert(hostKeyAlgorithmFromTag(1) == Some(RsaSha2256))
  assert(hostKeyAlgorithmFromTag(2) == Some(RsaSha2512))
  assert(hostKeyAlgorithmFromTag(3) == Some(EcdsaNistp256))
  assert(hostKeyAlgorithmFromTag(4) == None)
}

let test_hostKeyAlgorithm_toTag = () => {
  assert(hostKeyAlgorithmToTag(SshEd25519) == 0)
  assert(hostKeyAlgorithmToTag(RsaSha2256) == 1)
  assert(hostKeyAlgorithmToTag(RsaSha2512) == 2)
  assert(hostKeyAlgorithmToTag(EcdsaNistp256) == 3)
}

let test_cipherAlgorithm_roundtrip = () => {
  assert(cipherAlgorithmFromTag(0) == Some(Chacha20Poly1305))
  assert(cipherAlgorithmFromTag(1) == Some(Aes256Gcm))
  assert(cipherAlgorithmFromTag(2) == Some(Aes128Gcm))
  assert(cipherAlgorithmFromTag(3) == Some(Aes256Ctr))
  assert(cipherAlgorithmFromTag(4) == Some(Aes192Ctr))
  assert(cipherAlgorithmFromTag(5) == Some(Aes128Ctr))
  assert(cipherAlgorithmFromTag(6) == None)
}

let test_cipherAlgorithm_toTag = () => {
  assert(cipherAlgorithmToTag(Chacha20Poly1305) == 0)
  assert(cipherAlgorithmToTag(Aes256Gcm) == 1)
  assert(cipherAlgorithmToTag(Aes128Gcm) == 2)
  assert(cipherAlgorithmToTag(Aes256Ctr) == 3)
  assert(cipherAlgorithmToTag(Aes192Ctr) == 4)
  assert(cipherAlgorithmToTag(Aes128Ctr) == 5)
}

let test_channelOpenFailure_roundtrip = () => {
  assert(channelOpenFailureFromTag(0) == Some(AdminProhibited))
  assert(channelOpenFailureFromTag(1) == Some(ConnectFailed))
  assert(channelOpenFailureFromTag(2) == Some(UnknownChannelType))
  assert(channelOpenFailureFromTag(3) == Some(ResourceShortage))
  assert(channelOpenFailureFromTag(4) == None)
}

let test_channelOpenFailure_toTag = () => {
  assert(channelOpenFailureToTag(AdminProhibited) == 0)
  assert(channelOpenFailureToTag(ConnectFailed) == 1)
  assert(channelOpenFailureToTag(UnknownChannelType) == 2)
  assert(channelOpenFailureToTag(ResourceShortage) == 3)
}

// Run all tests
test_sshMessageType_roundtrip()
test_sshMessageType_toTag()
test_authMethod_roundtrip()
test_authMethod_toTag()
test_kexMethod_roundtrip()
test_kexMethod_toTag()
test_channelType_roundtrip()
test_channelType_toTag()
test_bastionState_roundtrip()
test_bastionState_toTag()
test_channelState_roundtrip()
test_channelState_toTag()
test_disconnectReason_roundtrip()
test_disconnectReason_toTag()
test_hostKeyAlgorithm_roundtrip()
test_hostKeyAlgorithm_toTag()
test_cipherAlgorithm_roundtrip()
test_cipherAlgorithm_toTag()
test_channelOpenFailure_roundtrip()
test_channelOpenFailure_toTag()
