// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// C# P/Invoke bindings for the proven-dns protocol.
// Wraps the C-ABI functions from protocols/proven-dns/ffi/zig/src/dns.zig.

using System;
using System.Runtime.InteropServices;

namespace ProvenServers
{
    /// <summary>DNS query lifecycle states (tags 0-4).</summary>
    public enum DnsState : byte
    {
        Idle = 0, QueryReceived = 1, Lookup = 2, ResponseBuilding = 3, Sent = 4
    }

    /// <summary>DNSSEC states (tags 0-3).</summary>
    public enum DnssecState : byte
    {
        Disabled = 0, Enabled = 1, KeyLoaded = 2, Validated = 3
    }

    /// <summary>DNSSEC signing algorithms (tags 0-4).</summary>
    public enum DnssecAlgorithm : byte
    {
        RsaSha256 = 0, RsaSha512 = 1, EcdsaP256Sha256 = 2,
        EcdsaP384Sha384 = 3, Ed25519 = 4
    }

    /// <summary>
    /// C# bindings for the proven DNS server protocol.
    /// Lifecycle: Idle -> QueryReceived -> Lookup -> ResponseBuilding -> Sent.
    /// </summary>
    public static class ProvenDns
    {
        private const string Lib = "proven_dns";

        [DllImport(Lib)] private static extern uint dns_abi_version();
        [DllImport(Lib)] private static extern int dns_create_context();
        [DllImport(Lib)] private static extern void dns_destroy_context(int slot);
        [DllImport(Lib)] private static extern byte dns_state(int slot);
        [DllImport(Lib)] private static extern byte dns_dnssec_state(int slot);
        [DllImport(Lib)] private static extern byte dns_rcode(int slot);
        [DllImport(Lib)] private static extern ushort dns_answer_count(int slot);
        [DllImport(Lib)] private static extern ushort dns_authority_count(int slot);
        [DllImport(Lib)] private static extern ushort dns_additional_count(int slot);
        [DllImport(Lib)] private static extern byte dns_query_rtype(int slot);
        [DllImport(Lib)] private static extern byte dns_query_class(int slot);
        [DllImport(Lib)] private static extern byte dns_parse_query(int slot, byte[] buf, ushort len);
        [DllImport(Lib)] private static extern byte dns_begin_lookup(int slot);
        [DllImport(Lib)] private static extern byte dns_begin_response(int slot);
        [DllImport(Lib)] private static extern byte dns_add_answer(int slot, byte rtype, byte rclass, uint ttl, byte[] rdata, ushort rdlen);
        [DllImport(Lib)] private static extern byte dns_add_authority(int slot, byte rtype, byte rclass, uint ttl, byte[] rdata, ushort rdlen);
        [DllImport(Lib)] private static extern byte dns_add_additional(int slot, byte rtype, byte rclass, uint ttl, byte[] rdata, ushort rdlen);
        [DllImport(Lib)] private static extern byte dns_set_rcode(int slot, byte rcodeTag);
        [DllImport(Lib)] private static extern byte dns_build_response(int slot, byte[] outBuf, ref ushort outLen);
        [DllImport(Lib)] private static extern byte dns_enable_dnssec(int slot);
        [DllImport(Lib)] private static extern byte dns_load_dnssec_key(int slot, byte algo);
        [DllImport(Lib)] private static extern byte dns_sign_response(int slot);
        [DllImport(Lib)] private static extern byte dns_validate_dnssec(int slot);
        [DllImport(Lib)] private static extern byte dns_can_transition(byte from, byte to);
        [DllImport(Lib)] private static extern byte dns_can_dnssec_transition(byte from, byte to);

        public static uint AbiVersion() => dns_abi_version();

        /// <exception cref="ProvenError">If the pool is exhausted.</exception>
        public static int CreateContext() => ProvenError.CheckSlot(dns_create_context());

        public static void DestroyContext(int slot) => dns_destroy_context(slot);

        public static DnsState? State(int slot)
        {
            byte tag = dns_state(slot);
            return tag <= 4 ? (DnsState)tag : null;
        }

        public static DnssecState? GetDnssecState(int slot)
        {
            byte tag = dns_dnssec_state(slot);
            return tag <= 3 ? (DnssecState)tag : null;
        }

        public static byte Rcode(int slot) => dns_rcode(slot);
        public static ushort AnswerCount(int slot) => dns_answer_count(slot);
        public static ushort AuthorityCount(int slot) => dns_authority_count(slot);
        public static ushort AdditionalCount(int slot) => dns_additional_count(slot);
        public static byte QueryRtype(int slot) => dns_query_rtype(slot);
        public static byte QueryClass(int slot) => dns_query_class(slot);

        /// <summary>Parse a DNS query. Transitions Idle -> QueryReceived.</summary>
        public static void ParseQuery(int slot, byte[] data) =>
            ProvenError.CheckStatus(dns_parse_query(slot, data, (ushort)data.Length));

        /// <summary>Begin lookup. Transitions QueryReceived -> Lookup.</summary>
        public static void BeginLookup(int slot) =>
            ProvenError.CheckStatus(dns_begin_lookup(slot));

        /// <summary>Begin response building. Transitions Lookup -> ResponseBuilding.</summary>
        public static void BeginResponse(int slot) =>
            ProvenError.CheckStatus(dns_begin_response(slot));

        /// <summary>Add a resource record to the answer section.</summary>
        public static void AddAnswer(int slot, byte rtype, byte rclass, uint ttl, byte[] rdata) =>
            ProvenError.CheckStatus(dns_add_answer(slot, rtype, rclass, ttl, rdata, (ushort)rdata.Length));

        /// <summary>Add a resource record to the authority section.</summary>
        public static void AddAuthority(int slot, byte rtype, byte rclass, uint ttl, byte[] rdata) =>
            ProvenError.CheckStatus(dns_add_authority(slot, rtype, rclass, ttl, rdata, (ushort)rdata.Length));

        /// <summary>Add a resource record to the additional section.</summary>
        public static void AddAdditional(int slot, byte rtype, byte rclass, uint ttl, byte[] rdata) =>
            ProvenError.CheckStatus(dns_add_additional(slot, rtype, rclass, ttl, rdata, (ushort)rdata.Length));

        /// <summary>Set the response code.</summary>
        public static void SetRcode(int slot, byte rcodeTag) =>
            ProvenError.CheckStatus(dns_set_rcode(slot, rcodeTag));

        /// <summary>Build the DNS response. Returns bytes written to outBuf.</summary>
        public static ushort BuildResponse(int slot, byte[] outBuf)
        {
            ushort outLen = 0;
            ProvenError.CheckStatus(dns_build_response(slot, outBuf, ref outLen));
            return outLen;
        }

        /// <summary>Enable DNSSEC. Transitions Disabled -> Enabled.</summary>
        public static void EnableDnssec(int slot) =>
            ProvenError.CheckStatus(dns_enable_dnssec(slot));

        /// <summary>Load DNSSEC signing key. Transitions Enabled -> KeyLoaded.</summary>
        public static void LoadDnssecKey(int slot, DnssecAlgorithm algo) =>
            ProvenError.CheckStatus(dns_load_dnssec_key(slot, (byte)algo));

        /// <summary>Sign the response. Transitions KeyLoaded -> Validated.</summary>
        public static void SignResponse(int slot) =>
            ProvenError.CheckStatus(dns_sign_response(slot));

        /// <summary>Check DNSSEC validation result.</summary>
        public static bool ValidateDnssec(int slot) => dns_validate_dnssec(slot) == 0;

        public static bool CanTransition(DnsState from, DnsState to) =>
            dns_can_transition((byte)from, (byte)to) == 1;

        public static bool CanDnssecTransition(DnssecState from, DnssecState to) =>
            dns_can_dnssec_transition((byte)from, (byte)to) == 1;
    }
}
