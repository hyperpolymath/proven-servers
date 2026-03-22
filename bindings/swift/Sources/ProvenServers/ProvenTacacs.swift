// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TACACS+ protocol types for proven-servers.

/// PacketType matching the Idris2 ABI tags.
public enum PacketType: UInt8, CaseIterable, Sendable {
    case authentication = 0
    case authorization = 1
    case accounting = 2
}

/// AuthenType matching the Idris2 ABI tags.
public enum AuthenType: UInt8, CaseIterable, Sendable {
    case ascii = 0
    case pap = 1
    case chap = 2
    case msChapV1 = 3
    case msChapV2 = 4
}

/// AuthenAction matching the Idris2 ABI tags.
public enum AuthenAction: UInt8, CaseIterable, Sendable {
    case login = 0
    case changePass = 1
    case sendAuth = 2
}

/// AuthenStatus matching the Idris2 ABI tags.
public enum AuthenStatus: UInt8, CaseIterable, Sendable {
    case pass = 0
    case authenStatus_Fail = 1
    case getData = 2
    case getUser = 3
    case getPass = 4
    case restart = 5
    case authenStatus_Error = 6
    case authenStatus_Follow = 7
}

/// AuthorStatus matching the Idris2 ABI tags.
public enum AuthorStatus: UInt8, CaseIterable, Sendable {
    case passAdd = 0
    case passRepl = 1
    case authorStatus_Fail = 2
    case authorStatus_Error = 3
    case authorStatus_Follow = 4
}

/// AcctStatus matching the Idris2 ABI tags.
public enum AcctStatus: UInt8, CaseIterable, Sendable {
    case success = 0
    case acctStatus_Error = 1
    case acctStatus_Follow = 2
}

/// AcctFlag matching the Idris2 ABI tags.
public enum AcctFlag: UInt8, CaseIterable, Sendable {
    case start = 0
    case stop = 1
    case watchdog = 2
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case authenticating = 1
    case authorizing = 2
    case active = 3
    case closing = 4
}
