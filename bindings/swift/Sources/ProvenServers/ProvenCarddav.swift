// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CardDAV protocol types for proven-servers.

/// PropertyType matching the Idris2 ABI tags.
public enum PropertyType: UInt8, CaseIterable, Sendable {
    case fnName = 0
    case n = 1
    case email = 2
    case tel = 3
    case adr = 4
    case org = 5
    case photo = 6
    case url = 7
    case note = 8
}

/// CardMethod matching the Idris2 ABI tags.
public enum CardMethod: UInt8, CaseIterable, Sendable {
    case get = 0
    case put = 1
    case delete = 2
    case propfind = 3
    case proppatch = 4
    case report = 5
    case mkcol = 6
}

/// VCardVersion matching the Idris2 ABI tags.
public enum VCardVersion: UInt8, CaseIterable, Sendable {
    case vcard3 = 0
    case vcard4 = 1
}

/// CardError matching the Idris2 ABI tags.
public enum CardError: UInt8, CaseIterable, Sendable {
    case validAddressData = 0
    case noResourceType = 1
    case maxResourceSize = 2
    case uidConflict = 3
    case supportedAddressData = 4
    case preconditionFailed = 5
}

/// ServerState matching the Idris2 ABI tags.
public enum ServerState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case bound = 1
    case serving = 2
    case shutdown = 3
}
