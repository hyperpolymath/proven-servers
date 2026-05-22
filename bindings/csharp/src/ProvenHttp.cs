// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// C# P/Invoke bindings for the proven-httpd protocol.
// Wraps the C-ABI functions from protocols/proven-httpd/ffi/zig/src/httpd.zig.
// Enums match Idris2 ABI tags exactly (HTTPABI.Layout).

using System;
using System.Runtime.InteropServices;

namespace ProvenServers
{
    /// <summary>HTTP request methods (HTTPABI.Layout.HttpMethod, tags 0-8).</summary>
    public enum HttpMethod : byte
    {
        Get = 0, Post = 1, Put = 2, Delete = 3, Patch = 4,
        Head = 5, Options = 6, Trace = 7, Connect = 8
    }

    /// <summary>HTTP version (tags 0-3).</summary>
    public enum HttpVersion : byte
    {
        Http10 = 0, Http11 = 1, Http20 = 2, Http30 = 3
    }

    /// <summary>HTTP request lifecycle phases (tags 0-6).</summary>
    public enum RequestPhase : byte
    {
        Idle = 0, Receiving = 1, HeadersParsed = 2, BodyReceiving = 3,
        Complete = 4, Responding = 5, Sent = 6
    }

    /// <summary>HTTP status codes (ABI tags 0-28).</summary>
    public enum HttpStatusCode : byte
    {
        Continue = 0, SwitchingProtocols = 1,
        Ok = 2, Created = 3, Accepted = 4, NoContent = 5,
        MovedPermanently = 6, Found = 7, NotModified = 8,
        TemporaryRedirect = 9, PermanentRedirect = 10,
        BadRequest = 11, Unauthorized = 12, Forbidden = 13,
        NotFound = 14, MethodNotAllowed = 15, RequestTimeout = 16,
        Conflict = 17, Gone = 18, LengthRequired = 19,
        PayloadTooLarge = 20, UriTooLong = 21,
        UnsupportedMediaType = 22, TooManyRequests = 23,
        InternalServerError = 24, NotImplemented = 25,
        BadGateway = 26, ServiceUnavailable = 27, GatewayTimeout = 28
    }

    /// <summary>Parse result from feeding raw HTTP data.</summary>
    public enum ParseResult : byte
    {
        Complete = 0, Rejected = 1, NeedMore = 2
    }

    /// <summary>
    /// C# bindings for the proven HTTP server protocol.
    /// Lifecycle: Idle -> Receiving -> HeadersParsed -> Complete -> Responding -> Sent.
    /// </summary>
    public static class ProvenHttp
    {
        private const string Lib = "proven_httpd";

        // -------------------------------------------------------------------
        // P/Invoke declarations
        // -------------------------------------------------------------------

        [DllImport(Lib)] private static extern uint http_abi_version();
        [DllImport(Lib)] private static extern int http_create_context();
        [DllImport(Lib)] private static extern void http_destroy_context(int slot);
        [DllImport(Lib)] private static extern byte http_parse_request(int slot, byte[] data, uint len);
        [DllImport(Lib)] private static extern byte http_get_method(int slot);
        [DllImport(Lib)] private static extern uint http_get_path(int slot, byte[] buf, uint len);
        [DllImport(Lib)] private static extern uint http_get_header(int slot, byte[] key, uint klen, byte[] buf, uint blen);
        [DllImport(Lib)] private static extern uint http_get_body(int slot, byte[] buf, uint len);
        [DllImport(Lib)] private static extern byte http_set_status(int slot, byte statusTag);
        [DllImport(Lib)] private static extern byte http_set_header(int slot, byte[] key, uint klen, byte[] val, uint vlen);
        [DllImport(Lib)] private static extern byte http_set_body(int slot, byte[] data, uint len);
        [DllImport(Lib)] private static extern byte http_send_response(int slot);
        [DllImport(Lib)] private static extern byte http_keep_alive_check(int slot);
        [DllImport(Lib)] private static extern byte http_get_phase(int slot);
        [DllImport(Lib)] private static extern byte http_get_version(int slot);
        [DllImport(Lib)] private static extern byte http_reset_context(int slot);
        [DllImport(Lib)] private static extern byte http_can_transition(byte from, byte to);

        // -------------------------------------------------------------------
        // Safe wrappers
        // -------------------------------------------------------------------

        /// <summary>Get the ABI version of the linked HTTP library.</summary>
        public static uint AbiVersion() => http_abi_version();

        /// <summary>Create a new HTTP context in the Idle phase.</summary>
        /// <exception cref="ProvenError">If the pool is exhausted.</exception>
        public static int CreateContext() => ProvenError.CheckSlot(http_create_context());

        /// <summary>Release an HTTP context slot.</summary>
        public static void DestroyContext(int slot) => http_destroy_context(slot);

        /// <summary>Feed raw HTTP data into a context for parsing.</summary>
        /// <exception cref="ProvenError">If the slot is invalid.</exception>
        public static ParseResult ParseRequest(int slot, byte[] data)
        {
            byte result = http_parse_request(slot, data, (uint)data.Length);
            if (result > 2)
                throw new ProvenError($"Unknown parse result: {result}", result);
            return (ParseResult)result;
        }

        /// <summary>Get the HTTP method of the parsed request.</summary>
        public static HttpMethod? GetMethod(int slot)
        {
            byte tag = http_get_method(slot);
            return tag <= 8 ? (HttpMethod)tag : null;
        }

        /// <summary>Copy the request path into a buffer. Returns bytes written.</summary>
        public static uint GetPath(int slot, byte[] buf) =>
            http_get_path(slot, buf, (uint)buf.Length);

        /// <summary>Look up a request header by key. Returns bytes written or 0.</summary>
        public static uint GetHeader(int slot, byte[] key, byte[] buf) =>
            http_get_header(slot, key, (uint)key.Length, buf, (uint)buf.Length);

        /// <summary>Copy the request body into a buffer. Returns bytes written.</summary>
        public static uint GetBody(int slot, byte[] buf) =>
            http_get_body(slot, buf, (uint)buf.Length);

        /// <summary>Set the response status code.</summary>
        /// <exception cref="ProvenError">If in the wrong phase.</exception>
        public static void SetStatus(int slot, HttpStatusCode status) =>
            ProvenError.CheckStatus(http_set_status(slot, (byte)status));

        /// <summary>Set a response header.</summary>
        /// <exception cref="ProvenError">If in wrong phase or capacity exceeded.</exception>
        public static void SetHeader(int slot, byte[] key, byte[] value) =>
            ProvenError.CheckStatus(http_set_header(slot, key, (uint)key.Length, value, (uint)value.Length));

        /// <summary>Set the response body.</summary>
        /// <exception cref="ProvenError">If in wrong phase or body exceeds limit.</exception>
        public static void SetBody(int slot, byte[] data) =>
            ProvenError.CheckStatus(http_set_body(slot, data, (uint)data.Length));

        /// <summary>Send the response (Responding -> Sent).</summary>
        /// <exception cref="ProvenError">If not in Responding phase.</exception>
        public static void SendResponse(int slot) =>
            ProvenError.CheckStatus(http_send_response(slot));

        /// <summary>Check whether the connection uses keep-alive.</summary>
        public static bool KeepAliveCheck(int slot) => http_keep_alive_check(slot) == 1;

        /// <summary>Get the current request processing phase.</summary>
        public static RequestPhase? GetPhase(int slot)
        {
            byte tag = http_get_phase(slot);
            return tag <= 6 ? (RequestPhase)tag : null;
        }

        /// <summary>Get the HTTP version of the parsed request.</summary>
        public static HttpVersion? GetVersion(int slot)
        {
            byte tag = http_get_version(slot);
            return tag <= 3 ? (HttpVersion)tag : null;
        }

        /// <summary>Reset the context for keep-alive reuse (Sent -> Idle).</summary>
        /// <exception cref="ProvenError">If not in Sent phase.</exception>
        public static void ResetContext(int slot) =>
            ProvenError.CheckStatus(http_reset_context(slot));

        /// <summary>Stateless: check whether a lifecycle transition is valid.</summary>
        public static bool CanTransition(RequestPhase from, RequestPhase to) =>
            http_can_transition((byte)from, (byte)to) == 1;
    }
}
