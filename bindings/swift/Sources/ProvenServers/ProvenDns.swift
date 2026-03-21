// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Swift bindings for the proven-dns protocol.
// Wraps the C-ABI functions from protocols/proven-dns/ffi/zig/src/dns.zig.
// Enums match Idris2 ABI tags exactly (DnsABI.Layout).

import Foundation

// MARK: - C interop declarations

@_silgen_name("dns_abi_version")   private func dns_abi_version() -> UInt32
@_silgen_name("dns_create_context") private func dns_create_context() -> Int32
@_silgen_name("dns_destroy_context") private func dns_destroy_context(_ slot: Int32)
@_silgen_name("dns_state")         private func dns_state(_ slot: Int32) -> UInt8
@_silgen_name("dns_dnssec_state")  private func dns_dnssec_state(_ slot: Int32) -> UInt8
@_silgen_name("dns_rcode")         private func dns_rcode(_ slot: Int32) -> UInt8
@_silgen_name("dns_answer_count")  private func dns_answer_count(_ slot: Int32) -> UInt16
@_silgen_name("dns_authority_count") private func dns_authority_count(_ slot: Int32) -> UInt16
@_silgen_name("dns_additional_count") private func dns_additional_count(_ slot: Int32) -> UInt16
@_silgen_name("dns_query_rtype")   private func dns_query_rtype(_ slot: Int32) -> UInt8
@_silgen_name("dns_query_class")   private func dns_query_class(_ slot: Int32) -> UInt8
@_silgen_name("dns_parse_query")   private func dns_parse_query(_ slot: Int32, _ buf: UnsafePointer<UInt8>, _ len: UInt16) -> UInt8
@_silgen_name("dns_begin_lookup")  private func dns_begin_lookup(_ slot: Int32) -> UInt8
@_silgen_name("dns_begin_response") private func dns_begin_response(_ slot: Int32) -> UInt8
@_silgen_name("dns_add_answer")    private func dns_add_answer(_ slot: Int32, _ rtype: UInt8, _ rclass: UInt8, _ ttl: UInt32, _ rdata: UnsafePointer<UInt8>, _ rdlen: UInt16) -> UInt8
@_silgen_name("dns_add_authority") private func dns_add_authority(_ slot: Int32, _ rtype: UInt8, _ rclass: UInt8, _ ttl: UInt32, _ rdata: UnsafePointer<UInt8>, _ rdlen: UInt16) -> UInt8
@_silgen_name("dns_add_additional") private func dns_add_additional(_ slot: Int32, _ rtype: UInt8, _ rclass: UInt8, _ ttl: UInt32, _ rdata: UnsafePointer<UInt8>, _ rdlen: UInt16) -> UInt8
@_silgen_name("dns_set_rcode")     private func dns_set_rcode(_ slot: Int32, _ rcodeTag: UInt8) -> UInt8
@_silgen_name("dns_build_response") private func dns_build_response(_ slot: Int32, _ out: UnsafeMutablePointer<UInt8>, _ outLen: UnsafeMutablePointer<UInt16>) -> UInt8
@_silgen_name("dns_enable_dnssec") private func dns_enable_dnssec(_ slot: Int32) -> UInt8
@_silgen_name("dns_load_dnssec_key") private func dns_load_dnssec_key(_ slot: Int32, _ algo: UInt8) -> UInt8
@_silgen_name("dns_sign_response") private func dns_sign_response(_ slot: Int32) -> UInt8
@_silgen_name("dns_validate_dnssec") private func dns_validate_dnssec(_ slot: Int32) -> UInt8
@_silgen_name("dns_can_transition") private func dns_can_transition(_ from: UInt8, _ to: UInt8) -> UInt8
@_silgen_name("dns_can_dnssec_transition") private func dns_can_dnssec_transition(_ from: UInt8, _ to: UInt8) -> UInt8

// MARK: - Enums matching Idris2 ABI tags

/// DNS query lifecycle states (tags 0-4).
public enum DnsState: Int, CaseIterable, Sendable {
    /// Waiting for a query.
    case idle = 0
    /// Query received and parsed.
    case queryReceived = 1
    /// Performing DNS lookup.
    case lookup = 2
    /// Building response message.
    case responseBuilding = 3
    /// Response sent (terminal).
    case sent = 4

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

/// DNSSEC states (tags 0-3).
public enum DnssecState: Int, CaseIterable, Sendable {
    /// DNSSEC disabled.
    case disabled = 0
    /// DNSSEC enabled, no key loaded.
    case enabled = 1
    /// DNSSEC key loaded.
    case keyLoaded = 2
    /// Response validated/signed.
    case validated = 3

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

/// DNSSEC signing algorithms (tags 0-4).
public enum DnssecAlgorithm: Int, CaseIterable, Sendable {
    /// RSA/SHA-256.
    case rsaSha256 = 0
    /// RSA/SHA-512.
    case rsaSha512 = 1
    /// ECDSA P-256/SHA-256.
    case ecdsaP256Sha256 = 2
    /// ECDSA P-384/SHA-384.
    case ecdsaP384Sha384 = 3
    /// Ed25519.
    case ed25519 = 4

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

// MARK: - Swift-idiomatic wrapper

/// Swift wrapper for the proven DNS server protocol FFI.
///
/// Manages an opaque context slot in the Zig FFI pool. The context is
/// automatically destroyed when this object is deallocated.
///
/// Lifecycle: Idle -> QueryReceived -> Lookup -> ResponseBuilding -> Sent.
public final class ProvenDns: @unchecked Sendable {

    private let slot: Int32

    /// Create a new DNS context in the Idle state.
    ///
    /// - Throws: ``ProvenError/poolExhausted`` if all 64 slots are in use.
    public init() throws {
        self.slot = try ProvenError.checkSlot(dns_create_context())
    }

    deinit { dns_destroy_context(slot) }

    /// The ABI version of the linked DNS library.
    public static var abiVersion: UInt32 { dns_abi_version() }

    /// The current lifecycle state.
    public var state: DnsState? { DnsState(tag: dns_state(slot)) }

    /// The current DNSSEC state.
    public var dnssecState: DnssecState? { DnssecState(tag: dns_dnssec_state(slot)) }

    /// The response code tag.
    public var rcode: UInt8 { dns_rcode(slot) }

    /// The number of answer records.
    public var answerCount: UInt16 { dns_answer_count(slot) }

    /// The number of authority records.
    public var authorityCount: UInt16 { dns_authority_count(slot) }

    /// The number of additional records.
    public var additionalCount: UInt16 { dns_additional_count(slot) }

    /// The query record type (ABI tag, 255 = unset).
    public var queryRtype: UInt8 { dns_query_rtype(slot) }

    /// The query class (ABI tag, 255 = unset).
    public var queryClass: UInt8 { dns_query_class(slot) }

    /// Parse a DNS query from raw bytes. Transitions Idle -> QueryReceived.
    ///
    /// - Parameter data: Raw DNS query bytes.
    /// - Throws: ``ProvenError/invalidState`` if not in Idle state.
    public func parseQuery(_ data: Data) throws {
        let result = data.withUnsafeBytes { buf -> UInt8 in
            let ptr = buf.baseAddress!.assumingMemoryBound(to: UInt8.self)
            return dns_parse_query(slot, ptr, UInt16(buf.count))
        }
        try ProvenError.checkStatus(result)
    }

    /// Begin DNS lookup. Transitions QueryReceived -> Lookup.
    ///
    /// - Throws: ``ProvenError/invalidState`` if not in QueryReceived state.
    public func beginLookup() throws {
        try ProvenError.checkStatus(dns_begin_lookup(slot))
    }

    /// Begin building the response. Transitions Lookup -> ResponseBuilding.
    ///
    /// - Throws: ``ProvenError/invalidState`` if not in Lookup state.
    public func beginResponse() throws {
        try ProvenError.checkStatus(dns_begin_response(slot))
    }

    /// Add a resource record to the answer section.
    ///
    /// - Parameters:
    ///   - rtype: Record type ABI tag.
    ///   - rclass: Record class ABI tag.
    ///   - ttl: Time-to-live in seconds.
    ///   - rdata: Record data bytes.
    /// - Throws: ``ProvenError/invalidState`` if not in ResponseBuilding state.
    public func addAnswer(rtype: UInt8, rclass: UInt8, ttl: UInt32, rdata: Data) throws {
        let result = rdata.withUnsafeBytes { buf -> UInt8 in
            let ptr = buf.baseAddress!.assumingMemoryBound(to: UInt8.self)
            return dns_add_answer(slot, rtype, rclass, ttl, ptr, UInt16(buf.count))
        }
        try ProvenError.checkStatus(result)
    }

    /// Add a resource record to the authority section.
    public func addAuthority(rtype: UInt8, rclass: UInt8, ttl: UInt32, rdata: Data) throws {
        let result = rdata.withUnsafeBytes { buf -> UInt8 in
            let ptr = buf.baseAddress!.assumingMemoryBound(to: UInt8.self)
            return dns_add_authority(slot, rtype, rclass, ttl, ptr, UInt16(buf.count))
        }
        try ProvenError.checkStatus(result)
    }

    /// Add a resource record to the additional section.
    public func addAdditional(rtype: UInt8, rclass: UInt8, ttl: UInt32, rdata: Data) throws {
        let result = rdata.withUnsafeBytes { buf -> UInt8 in
            let ptr = buf.baseAddress!.assumingMemoryBound(to: UInt8.self)
            return dns_add_additional(slot, rtype, rclass, ttl, ptr, UInt16(buf.count))
        }
        try ProvenError.checkStatus(result)
    }

    /// Set the response code (RCODE).
    ///
    /// - Parameter rcodeTag: The RCODE ABI tag.
    /// - Throws: ``ProvenError/invalidState`` if not in ResponseBuilding state.
    public func setRcode(_ rcodeTag: UInt8) throws {
        try ProvenError.checkStatus(dns_set_rcode(slot, rcodeTag))
    }

    /// Build the DNS response message. Transitions ResponseBuilding -> Sent.
    ///
    /// - Returns: The serialised DNS response as `Data`.
    /// - Throws: ``ProvenError/invalidState`` if not in ResponseBuilding state.
    public func buildResponse() throws -> Data {
        var buf = [UInt8](repeating: 0, count: 65536)
        var outLen: UInt16 = 0
        try ProvenError.checkStatus(dns_build_response(slot, &buf, &outLen))
        return Data(buf.prefix(Int(outLen)))
    }

    /// Enable DNSSEC. Transitions Disabled -> Enabled.
    public func enableDnssec() throws {
        try ProvenError.checkStatus(dns_enable_dnssec(slot))
    }

    /// Load a DNSSEC signing key. Transitions Enabled -> KeyLoaded.
    ///
    /// - Parameter algorithm: The DNSSEC algorithm to use.
    public func loadDnssecKey(algorithm: DnssecAlgorithm) throws {
        try ProvenError.checkStatus(dns_load_dnssec_key(slot, algorithm.tag))
    }

    /// Sign the response (DNSSEC). Transitions KeyLoaded -> Validated.
    public func signResponse() throws {
        try ProvenError.checkStatus(dns_sign_response(slot))
    }

    /// Check DNSSEC validation result.
    public var isDnssecValid: Bool {
        dns_validate_dnssec(slot) == 0
    }

    /// Stateless query: check whether a DNS lifecycle transition is valid.
    public static func canTransition(from: DnsState, to: DnsState) -> Bool {
        dns_can_transition(from.tag, to.tag) == 1
    }

    /// Stateless query: check whether a DNSSEC state transition is valid.
    public static func canDnssecTransition(from: DnssecState, to: DnssecState) -> Bool {
        dns_can_dnssec_transition(from.tag, to.tag) == 1
    }
}
