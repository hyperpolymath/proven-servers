// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Swift bindings for the proven-httpd protocol.
// Wraps the C-ABI functions from protocols/proven-httpd/ffi/zig/src/httpd.zig.
// Enums match Idris2 ABI tags exactly (HTTPABI.Layout).

import Foundation

// MARK: - C interop declarations

@_silgen_name("http_abi_version")
private func http_abi_version() -> UInt32

@_silgen_name("http_create_context")
private func http_create_context() -> Int32

@_silgen_name("http_destroy_context")
private func http_destroy_context(_ slot: Int32)

@_silgen_name("http_parse_request")
private func http_parse_request(_ slot: Int32, _ data: UnsafePointer<UInt8>, _ len: UInt32) -> UInt8

@_silgen_name("http_get_method")
private func http_get_method(_ slot: Int32) -> UInt8

@_silgen_name("http_get_path")
private func http_get_path(_ slot: Int32, _ buf: UnsafeMutablePointer<UInt8>, _ len: UInt32) -> UInt32

@_silgen_name("http_get_header")
private func http_get_header(_ slot: Int32, _ key: UnsafePointer<UInt8>, _ klen: UInt32, _ buf: UnsafeMutablePointer<UInt8>, _ blen: UInt32) -> UInt32

@_silgen_name("http_get_body")
private func http_get_body(_ slot: Int32, _ buf: UnsafeMutablePointer<UInt8>, _ len: UInt32) -> UInt32

@_silgen_name("http_set_status")
private func http_set_status(_ slot: Int32, _ statusTag: UInt8) -> UInt8

@_silgen_name("http_set_header")
private func http_set_header(_ slot: Int32, _ key: UnsafePointer<UInt8>, _ klen: UInt32, _ val: UnsafePointer<UInt8>, _ vlen: UInt32) -> UInt8

@_silgen_name("http_set_body")
private func http_set_body(_ slot: Int32, _ data: UnsafePointer<UInt8>, _ len: UInt32) -> UInt8

@_silgen_name("http_send_response")
private func http_send_response(_ slot: Int32) -> UInt8

@_silgen_name("http_keep_alive_check")
private func http_keep_alive_check(_ slot: Int32) -> UInt8

@_silgen_name("http_get_phase")
private func http_get_phase(_ slot: Int32) -> UInt8

@_silgen_name("http_get_version")
private func http_get_version(_ slot: Int32) -> UInt8

@_silgen_name("http_reset_context")
private func http_reset_context(_ slot: Int32) -> UInt8

@_silgen_name("http_can_transition")
private func http_can_transition(_ from: UInt8, _ to: UInt8) -> UInt8

// MARK: - Enums matching Idris2 ABI tags

/// HTTP request methods (HTTPABI.Layout.HttpMethod, tags 0-8).
public enum HttpMethod: Int, CaseIterable, Sendable {
    /// Retrieve a representation of the target resource.
    case get = 0
    /// Perform resource-specific processing on the request payload.
    case post = 1
    /// Replace all current representations of the target resource.
    case put = 2
    /// Remove all current representations of the target resource.
    case delete = 3
    /// Apply partial modifications to a resource (RFC 5789).
    case patch = 4
    /// Same as GET but only transfer status line and headers.
    case head = 5
    /// Describe the communication options for the target resource.
    case options = 6
    /// Perform a message loop-back test.
    case trace = 7
    /// Establish a tunnel to the server.
    case connect = 8

    /// Decode from an ABI tag value, or `nil` if unknown.
    public init?(tag: UInt8) {
        self.init(rawValue: Int(tag))
    }

    /// The ABI tag value.
    public var tag: UInt8 { UInt8(rawValue) }
}

/// HTTP protocol versions (HTTPABI.Layout, tags 0-3).
public enum HttpVersion: Int, CaseIterable, Sendable {
    /// HTTP/1.0 (RFC 1945).
    case http10 = 0
    /// HTTP/1.1 (RFC 7230).
    case http11 = 1
    /// HTTP/2 (RFC 7540).
    case http20 = 2
    /// HTTP/3 (RFC 9114).
    case http30 = 3

    /// Decode from an ABI tag value.
    public init?(tag: UInt8) {
        self.init(rawValue: Int(tag))
    }

    /// The ABI tag value.
    public var tag: UInt8 { UInt8(rawValue) }
}

/// HTTP request lifecycle phases (HTTPABI.Transitions, tags 0-6).
public enum HttpRequestPhase: Int, CaseIterable, Sendable {
    /// Waiting for a new request.
    case idle = 0
    /// Receiving request data.
    case receiving = 1
    /// Request headers fully parsed.
    case headersParsed = 2
    /// Receiving request body.
    case bodyReceiving = 3
    /// Full request received.
    case complete = 4
    /// Constructing response.
    case responding = 5
    /// Response fully sent.
    case sent = 6

    /// Decode from an ABI tag value.
    public init?(tag: UInt8) {
        self.init(rawValue: Int(tag))
    }

    /// The ABI tag value.
    public var tag: UInt8 { UInt8(rawValue) }
}

/// HTTP status codes (HTTPABI.Layout.AbiStatusCode, tags 0-28).
public enum HttpStatusCode: Int, CaseIterable, Sendable {
    // 1xx Informational
    case `continue` = 0
    case switchingProtocols = 1
    // 2xx Success
    case ok = 2
    case created = 3
    case accepted = 4
    case noContent = 5
    // 3xx Redirection
    case movedPermanently = 6
    case found = 7
    case notModified = 8
    case temporaryRedirect = 9
    case permanentRedirect = 10
    // 4xx Client Error
    case badRequest = 11
    case unauthorized = 12
    case forbidden = 13
    case notFound = 14
    case methodNotAllowed = 15
    case requestTimeout = 16
    case conflict = 17
    case gone = 18
    case lengthRequired = 19
    case payloadTooLarge = 20
    case uriTooLong = 21
    case unsupportedMedia = 22
    case tooManyRequests = 23
    // 5xx Server Error
    case internalError = 24
    case notImplemented = 25
    case badGateway = 26
    case serviceUnavailable = 27
    case gatewayTimeout = 28

    /// Decode from an ABI tag value.
    public init?(tag: UInt8) {
        self.init(rawValue: Int(tag))
    }

    /// The ABI tag value.
    public var tag: UInt8 { UInt8(rawValue) }
}

/// Result of parsing raw HTTP data into a context.
public enum HttpParseResult: Int, Sendable {
    /// Parsing complete, request is ready for processing.
    case complete = 0
    /// Request was malformed and rejected.
    case rejected = 1
    /// Need more data (headers or body incomplete).
    case needMore = 2
}

// MARK: - Swift-idiomatic wrapper

/// Swift wrapper for the proven HTTP server protocol FFI.
///
/// Manages an opaque context slot in the Zig FFI pool. The context is
/// automatically destroyed when this object is deallocated.
///
/// Lifecycle: Idle -> Receiving -> HeadersParsed -> Complete -> Responding -> Sent.
public final class ProvenHttp: @unchecked Sendable {

    /// The raw context slot index in the FFI pool.
    private let slot: Int32

    /// Create a new HTTP context in the Idle phase.
    ///
    /// - Throws: ``ProvenError/poolExhausted`` if all 64 slots are in use.
    public init() throws {
        self.slot = try ProvenError.checkSlot(http_create_context())
    }

    deinit {
        http_destroy_context(slot)
    }

    /// The ABI version of the linked `libproven_httpd`.
    public static var abiVersion: UInt32 {
        http_abi_version()
    }

    /// Feed raw HTTP data into this context for parsing.
    ///
    /// - Parameter data: Raw HTTP bytes to parse.
    /// - Returns: The parse result indicating completion, rejection, or need for more data.
    /// - Throws: ``ProvenError`` if the slot is invalid.
    public func parseRequest(_ data: Data) throws -> HttpParseResult {
        let result = data.withUnsafeBytes { buf -> UInt8 in
            let ptr = buf.baseAddress!.assumingMemoryBound(to: UInt8.self)
            return http_parse_request(slot, ptr, UInt32(buf.count))
        }
        guard let parsed = HttpParseResult(rawValue: Int(result)) else {
            throw ProvenError.unknown(code: Int32(result))
        }
        return parsed
    }

    /// The HTTP method of the parsed request, or `nil` if not yet parsed.
    public var method: HttpMethod? {
        HttpMethod(tag: http_get_method(slot))
    }

    /// Copy the request path into a `String`.
    ///
    /// - Returns: The request path, or an empty string if none is set.
    public func getPath() -> String {
        var buf = [UInt8](repeating: 0, count: 4096)
        let written = http_get_path(slot, &buf, UInt32(buf.count))
        return String(bytes: buf.prefix(Int(written)), encoding: .utf8) ?? ""
    }

    /// Look up a request header by key (case-insensitive).
    ///
    /// - Parameter key: The header name to look up.
    /// - Returns: The header value, or `nil` if the header was not found.
    public func getHeader(_ key: String) -> String? {
        var buf = [UInt8](repeating: 0, count: 8192)
        let written = key.withCString { cKey in
            http_get_header(slot, UnsafePointer<UInt8>(OpaquePointer(cKey)), UInt32(key.utf8.count), &buf, UInt32(buf.count))
        }
        guard written > 0 else { return nil }
        return String(bytes: buf.prefix(Int(written)), encoding: .utf8)
    }

    /// Copy the request body into `Data`.
    ///
    /// - Returns: The request body, or empty `Data` if none is present.
    public func getBody() -> Data {
        var buf = [UInt8](repeating: 0, count: 65536)
        let written = http_get_body(slot, &buf, UInt32(buf.count))
        return Data(buf.prefix(Int(written)))
    }

    /// Set the response status code.
    ///
    /// Requires the context to be in Complete or Responding phase.
    ///
    /// - Parameter status: The HTTP status code to set.
    /// - Throws: ``ProvenError/invalidState`` if in the wrong phase.
    public func setStatus(_ status: HttpStatusCode) throws {
        try ProvenError.checkStatus(http_set_status(slot, status.tag))
    }

    /// Set a response header.
    ///
    /// - Parameters:
    ///   - key: The header name.
    ///   - value: The header value.
    /// - Throws: ``ProvenError/invalidState`` if in the wrong phase.
    public func setHeader(_ key: String, value: String) throws {
        let result = key.withCString { cKey in
            value.withCString { cVal in
                http_set_header(
                    slot,
                    UnsafePointer<UInt8>(OpaquePointer(cKey)), UInt32(key.utf8.count),
                    UnsafePointer<UInt8>(OpaquePointer(cVal)), UInt32(value.utf8.count)
                )
            }
        }
        try ProvenError.checkStatus(result)
    }

    /// Set the response body.
    ///
    /// - Parameter data: The response body bytes.
    /// - Throws: ``ProvenError/invalidState`` if in the wrong phase.
    public func setBody(_ data: Data) throws {
        let result = data.withUnsafeBytes { buf -> UInt8 in
            let ptr = buf.baseAddress!.assumingMemoryBound(to: UInt8.self)
            return http_set_body(slot, ptr, UInt32(buf.count))
        }
        try ProvenError.checkStatus(result)
    }

    /// Send the response, transitioning Responding -> Sent.
    ///
    /// - Throws: ``ProvenError/invalidState`` if not in Responding phase.
    public func sendResponse() throws {
        try ProvenError.checkStatus(http_send_response(slot))
    }

    /// Check if the connection uses keep-alive.
    public var isKeepAlive: Bool {
        http_keep_alive_check(slot) == 1
    }

    /// The current request processing phase.
    public var phase: HttpRequestPhase? {
        HttpRequestPhase(tag: http_get_phase(slot))
    }

    /// The HTTP version of the parsed request.
    public var version: HttpVersion? {
        HttpVersion(tag: http_get_version(slot))
    }

    /// Reset the context for keep-alive reuse (Sent -> Idle).
    ///
    /// - Throws: ``ProvenError/invalidState`` if not in Sent phase.
    public func reset() throws {
        try ProvenError.checkStatus(http_reset_context(slot))
    }

    /// Stateless query: check whether a lifecycle transition is valid.
    ///
    /// - Parameters:
    ///   - from: The source phase.
    ///   - to: The destination phase.
    /// - Returns: `true` if the transition is allowed.
    public static func canTransition(from: HttpRequestPhase, to: HttpRequestPhase) -> Bool {
        http_can_transition(from.tag, to.tag) == 1
    }
}
