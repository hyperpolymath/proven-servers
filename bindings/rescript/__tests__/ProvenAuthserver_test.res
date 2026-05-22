// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenAuthserver protocol bindings.

open ProvenAuthserver

let test_authMethod_roundtrip = () => {
  assert(authMethodFromTag(0) == Some(Password))
  assert(authMethodFromTag(1) == Some(Certificate))
  assert(authMethodFromTag(2) == Some(OAuth2))
  assert(authMethodFromTag(3) == Some(Saml))
  assert(authMethodFromTag(4) == Some(Fido2))
  assert(authMethodFromTag(5) == Some(Kerberos))
  assert(authMethodFromTag(6) == Some(Ldap))
  assert(authMethodFromTag(7) == Some(Radius))
  assert(authMethodFromTag(8) == None)
}

let test_authMethod_toTag = () => {
  assert(authMethodToTag(Password) == 0)
  assert(authMethodToTag(Certificate) == 1)
  assert(authMethodToTag(OAuth2) == 2)
  assert(authMethodToTag(Saml) == 3)
  assert(authMethodToTag(Fido2) == 4)
  assert(authMethodToTag(Kerberos) == 5)
  assert(authMethodToTag(Ldap) == 6)
  assert(authMethodToTag(Radius) == 7)
}

let test_tokenType_roundtrip = () => {
  assert(tokenTypeFromTag(0) == Some(Access))
  assert(tokenTypeFromTag(1) == Some(Refresh))
  assert(tokenTypeFromTag(2) == Some(Id))
  assert(tokenTypeFromTag(3) == Some(Api))
  assert(tokenTypeFromTag(4) == None)
}

let test_tokenType_toTag = () => {
  assert(tokenTypeToTag(Access) == 0)
  assert(tokenTypeToTag(Refresh) == 1)
  assert(tokenTypeToTag(Id) == 2)
  assert(tokenTypeToTag(Api) == 3)
}

let test_authResult_roundtrip = () => {
  assert(authResultFromTag(0) == Some(Success))
  assert(authResultFromTag(1) == Some(InvalidCredentials))
  assert(authResultFromTag(2) == Some(AccountLocked))
  assert(authResultFromTag(3) == Some(AccountExpired))
  assert(authResultFromTag(4) == Some(MfaRequired))
  assert(authResultFromTag(5) == Some(IpBlocked))
  assert(authResultFromTag(6) == None)
}

let test_authResult_toTag = () => {
  assert(authResultToTag(Success) == 0)
  assert(authResultToTag(InvalidCredentials) == 1)
  assert(authResultToTag(AccountLocked) == 2)
  assert(authResultToTag(AccountExpired) == 3)
  assert(authResultToTag(MfaRequired) == 4)
  assert(authResultToTag(IpBlocked) == 5)
}

let test_mfaMethod_roundtrip = () => {
  assert(mfaMethodFromTag(0) == Some(Totp))
  assert(mfaMethodFromTag(1) == Some(Sms))
  assert(mfaMethodFromTag(2) == Some(Push))
  assert(mfaMethodFromTag(3) == Some(Fido2Mfa))
  assert(mfaMethodFromTag(4) == Some(Email))
  assert(mfaMethodFromTag(5) == None)
}

let test_mfaMethod_toTag = () => {
  assert(mfaMethodToTag(Totp) == 0)
  assert(mfaMethodToTag(Sms) == 1)
  assert(mfaMethodToTag(Push) == 2)
  assert(mfaMethodToTag(Fido2Mfa) == 3)
  assert(mfaMethodToTag(Email) == 4)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Active))
  assert(sessionStateFromTag(1) == Some(Expired))
  assert(sessionStateFromTag(2) == Some(Revoked))
  assert(sessionStateFromTag(3) == Some(Locked))
  assert(sessionStateFromTag(4) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Active) == 0)
  assert(sessionStateToTag(Expired) == 1)
  assert(sessionStateToTag(Revoked) == 2)
  assert(sessionStateToTag(Locked) == 3)
}

// Run all tests
test_authMethod_roundtrip()
test_authMethod_toTag()
test_tokenType_roundtrip()
test_tokenType_toTag()
test_authResult_roundtrip()
test_authResult_toTag()
test_mfaMethod_roundtrip()
test_mfaMethod_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
