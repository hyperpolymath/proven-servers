// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenSocks protocol bindings.

open ProvenSocks

let test_authMethod_roundtrip = () => {
  assert(authMethodFromTag(0) == Some(NoAuth))
  assert(authMethodFromTag(1) == Some(Gssapi))
  assert(authMethodFromTag(2) == Some(UsernamePassword))
  assert(authMethodFromTag(3) == Some(NoAcceptable))
  assert(authMethodFromTag(4) == None)
}

let test_authMethod_toTag = () => {
  assert(authMethodToTag(NoAuth) == 0)
  assert(authMethodToTag(Gssapi) == 1)
  assert(authMethodToTag(UsernamePassword) == 2)
  assert(authMethodToTag(NoAcceptable) == 3)
}

let test_command_roundtrip = () => {
  assert(commandFromTag(0) == Some(Connect))
  assert(commandFromTag(1) == Some(Bind))
  assert(commandFromTag(2) == Some(UdpAssociate))
  assert(commandFromTag(3) == None)
}

let test_command_toTag = () => {
  assert(commandToTag(Connect) == 0)
  assert(commandToTag(Bind) == 1)
  assert(commandToTag(UdpAssociate) == 2)
}

let test_addressType_roundtrip = () => {
  assert(addressTypeFromTag(0) == Some(IPv4))
  assert(addressTypeFromTag(1) == Some(DomainName))
  assert(addressTypeFromTag(2) == Some(IPv6))
  assert(addressTypeFromTag(3) == None)
}

let test_addressType_toTag = () => {
  assert(addressTypeToTag(IPv4) == 0)
  assert(addressTypeToTag(DomainName) == 1)
  assert(addressTypeToTag(IPv6) == 2)
}

let test_reply_roundtrip = () => {
  assert(replyFromTag(0) == Some(Succeeded))
  assert(replyFromTag(1) == Some(GeneralFailure))
  assert(replyFromTag(2) == Some(NotAllowed))
  assert(replyFromTag(3) == Some(NetworkUnreachable))
  assert(replyFromTag(4) == Some(HostUnreachable))
  assert(replyFromTag(5) == Some(ConnectionRefused))
  assert(replyFromTag(6) == Some(TtlExpired))
  assert(replyFromTag(7) == Some(CommandNotSupported))
  assert(replyFromTag(8) == Some(AddressTypeNotSupported))
  assert(replyFromTag(9) == None)
}

let test_reply_toTag = () => {
  assert(replyToTag(Succeeded) == 0)
  assert(replyToTag(GeneralFailure) == 1)
  assert(replyToTag(NotAllowed) == 2)
  assert(replyToTag(NetworkUnreachable) == 3)
  assert(replyToTag(HostUnreachable) == 4)
  assert(replyToTag(ConnectionRefused) == 5)
  assert(replyToTag(TtlExpired) == 6)
  assert(replyToTag(CommandNotSupported) == 7)
  assert(replyToTag(AddressTypeNotSupported) == 8)
}

let test_state_roundtrip = () => {
  assert(stateFromTag(0) == Some(Initial))
  assert(stateFromTag(1) == Some(Authenticating))
  assert(stateFromTag(2) == Some(Authenticated))
  assert(stateFromTag(3) == Some(Connecting))
  assert(stateFromTag(4) == Some(Established))
  assert(stateFromTag(5) == Some(Closed))
  assert(stateFromTag(6) == None)
}

let test_state_toTag = () => {
  assert(stateToTag(Initial) == 0)
  assert(stateToTag(Authenticating) == 1)
  assert(stateToTag(Authenticated) == 2)
  assert(stateToTag(Connecting) == 3)
  assert(stateToTag(Established) == 4)
  assert(stateToTag(Closed) == 5)
}

// Run all tests
test_authMethod_roundtrip()
test_authMethod_toTag()
test_command_roundtrip()
test_command_toTag()
test_addressType_roundtrip()
test_addressType_toTag()
test_reply_roundtrip()
test_reply_toTag()
test_state_roundtrip()
test_state_toTag()
