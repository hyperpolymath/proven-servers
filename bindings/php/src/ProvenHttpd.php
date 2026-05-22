<?php

// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PHP bindings for the proven-httpd Zig FFI.
//
// Wraps the C-ABI functions for HTTP request/response lifecycle,
// request parsing, response construction, and keep-alive management.

declare(strict_types=1);

namespace ProvenServers;

/** HTTP request methods matching Idris2 ABI tags. */
enum HttpMethod: int
{
    case GET     = 0;
    case POST    = 1;
    case PUT     = 2;
    case DELETE  = 3;
    case PATCH   = 4;
    case HEAD    = 5;
    case OPTIONS = 6;
    case TRACE   = 7;
    case CONNECT = 8;
}

/** HTTP request lifecycle phases matching Idris2 ABI tags. */
enum HttpRequestPhase: int
{
    case Idle           = 0;
    case Receiving      = 1;
    case HeadersParsed  = 2;
    case BodyReceiving  = 3;
    case Complete       = 4;
    case Responding     = 5;
    case Sent           = 6;
}

/** HTTP response status code tags matching Idris2 ABI. */
enum HttpStatusCode: int
{
    case OK                    = 0;
    case Created               = 1;
    case NoContent             = 2;
    case MovedPermanently      = 3;
    case Found                 = 4;
    case NotModified           = 5;
    case BadRequest            = 6;
    case Unauthorized          = 7;
    case Forbidden             = 8;
    case NotFound              = 9;
    case MethodNotAllowed      = 10;
    case Conflict              = 11;
    case Gone                  = 12;
    case UnprocessableEntity   = 13;
    case TooManyRequests       = 14;
    case InternalServerError   = 15;
    case NotImplemented        = 16;
    case BadGateway            = 17;
    case ServiceUnavailable    = 18;
    case GatewayTimeout        = 19;
}

/** HTTP version tags matching Idris2 ABI. */
enum HttpVersion: int
{
    case HTTP_1_0 = 0;
    case HTTP_1_1 = 1;
    case HTTP_2   = 2;
}

/** Parse result values matching Idris2 ABI. */
enum HttpParseResult: int
{
    case Complete = 0;
    case Rejected = 1;
    case NeedMore = 2;
}

/**
 * HTTP request/response context wrapping a Zig FFI slot.
 *
 * @example
 *   $ctx = ProvenHttpd::create();
 *   try {
 *       $result = $ctx->parseRequest($rawData);
 *       if ($result === HttpParseResult::Complete) {
 *           $ctx->setStatus(HttpStatusCode::OK);
 *           $ctx->setBody("Hello, world!");
 *           $ctx->sendResponse();
 *       }
 *   } finally {
 *       $ctx->destroy();
 *   }
 */
final class ProvenHttpd
{
    /** C header declarations for the FFI. */
    private const CDEF = <<<'CDEF'
    int http_create_context(void);
    void http_destroy_context(int slot);
    uint8_t http_parse_request(int slot, const uint8_t *data, uint32_t len);
    uint8_t http_get_method(int slot);
    uint32_t http_get_path(int slot, uint8_t *buf, uint32_t max_len);
    uint32_t http_get_header(int slot, const uint8_t *key, uint32_t key_len, uint8_t *val, uint32_t val_max);
    uint32_t http_get_body(int slot, uint8_t *buf, uint32_t max_len);
    uint8_t http_set_status(int slot, uint8_t status);
    uint8_t http_set_header(int slot, const uint8_t *key, uint32_t key_len, const uint8_t *val, uint32_t val_len);
    uint8_t http_set_body(int slot, const uint8_t *data, uint32_t len);
    uint8_t http_send_response(int slot);
    uint8_t http_keep_alive_check(int slot);
    uint8_t http_get_phase(int slot);
    uint8_t http_get_version(int slot);
    uint8_t http_reset_context(int slot);
    uint8_t http_can_transition(uint8_t from, uint8_t to);
    uint32_t http_abi_version(void);
    CDEF;

    private static ?\FFI $ffi = null;
    private int $slot;
    private bool $destroyed = false;

    private function __construct(int $slot)
    {
        $this->slot = $slot;
    }

    /** Get or initialize the FFI handle. */
    private static function ffi(): \FFI
    {
        if (self::$ffi === null) {
            self::$ffi = ProvenServers::loadLibrary('httpd', self::CDEF);
        }
        return self::$ffi;
    }

    /**
     * Create a new HTTP context.
     *
     * @throws ProvenError If the context pool is exhausted.
     */
    public static function create(): self
    {
        $slot = ProvenError::checkSlot(self::ffi()->http_create_context());
        return new self($slot);
    }

    /** Release the context slot back to the pool. */
    public function destroy(): void
    {
        if (!$this->destroyed) {
            self::ffi()->http_destroy_context($this->slot);
            $this->destroyed = true;
        }
    }

    /**
     * Feed raw HTTP data into the context for parsing.
     *
     * @param string $data Raw HTTP request bytes.
     * @return HttpParseResult The parse result.
     */
    public function parseRequest(string $data): HttpParseResult
    {
        $len = strlen($data);
        $tag = self::ffi()->http_parse_request($this->slot, $data, $len);
        return HttpParseResult::from($tag);
    }

    /**
     * Get the HTTP method of the parsed request.
     *
     * @return HttpMethod|null Method, or null if not yet parsed.
     */
    public function getMethod(): ?HttpMethod
    {
        $tag = self::ffi()->http_get_method($this->slot);
        return $tag === 255 ? null : HttpMethod::from($tag);
    }

    /**
     * Get the request path.
     *
     * @param int $maxLen Maximum path length.
     * @return string The request path.
     */
    public function getPath(int $maxLen = 4096): string
    {
        $buf = \FFI::new("uint8_t[{$maxLen}]");
        $written = self::ffi()->http_get_path($this->slot, $buf, $maxLen);
        return \FFI::string($buf, $written);
    }

    /**
     * Look up a request header by key.
     *
     * @param string $key    Header name.
     * @param int    $maxLen Maximum value length.
     * @return string Header value, or empty string if not found.
     */
    public function getHeader(string $key, int $maxLen = 4096): string
    {
        $keyLen = strlen($key);
        $valBuf = \FFI::new("uint8_t[{$maxLen}]");
        $written = self::ffi()->http_get_header($this->slot, $key, $keyLen, $valBuf, $maxLen);
        return \FFI::string($valBuf, $written);
    }

    /**
     * Get the request body.
     *
     * @param int $maxLen Maximum body length.
     * @return string The request body bytes.
     */
    public function getBody(int $maxLen = 65536): string
    {
        $buf = \FFI::new("uint8_t[{$maxLen}]");
        $written = self::ffi()->http_get_body($this->slot, $buf, $maxLen);
        return \FFI::string($buf, $written);
    }

    /**
     * Set the response status code.
     *
     * @param HttpStatusCode $status Status code.
     * @throws ProvenError On invalid state transition.
     */
    public function setStatus(HttpStatusCode $status): void
    {
        ProvenError::checkStatus(self::ffi()->http_set_status($this->slot, $status->value));
    }

    /**
     * Set a response header.
     *
     * @throws ProvenError On invalid state transition.
     */
    public function setHeader(string $key, string $value): void
    {
        ProvenError::checkStatus(
            self::ffi()->http_set_header($this->slot, $key, strlen($key), $value, strlen($value))
        );
    }

    /**
     * Set the response body.
     *
     * @throws ProvenError On invalid state transition.
     */
    public function setBody(string $data): void
    {
        ProvenError::checkStatus(self::ffi()->http_set_body($this->slot, $data, strlen($data)));
    }

    /**
     * Send the response. Transitions Responding -> Sent.
     *
     * @throws ProvenError On invalid state transition.
     */
    public function sendResponse(): void
    {
        ProvenError::checkStatus(self::ffi()->http_send_response($this->slot));
    }

    /** Check if the connection uses keep-alive. */
    public function keepAlive(): bool
    {
        return self::ffi()->http_keep_alive_check($this->slot) === 1;
    }

    /** Get the current request processing phase. */
    public function getPhase(): ?HttpRequestPhase
    {
        $tag = self::ffi()->http_get_phase($this->slot);
        return $tag <= 6 ? HttpRequestPhase::from($tag) : null;
    }

    /** Get the HTTP version. */
    public function getVersion(): ?HttpVersion
    {
        $tag = self::ffi()->http_get_version($this->slot);
        return $tag <= 2 ? HttpVersion::from($tag) : null;
    }

    /** Reset context for keep-alive reuse (Sent -> Idle). */
    public function reset(): void
    {
        ProvenError::checkStatus(self::ffi()->http_reset_context($this->slot));
    }

    /** Return the ABI version of the linked library. */
    public static function abiVersion(): int
    {
        return self::ffi()->http_abi_version();
    }

    /** Check whether a lifecycle transition is valid. */
    public static function canTransition(HttpRequestPhase $from, HttpRequestPhase $to): bool
    {
        return self::ffi()->http_can_transition($from->value, $to->value) === 1;
    }
}
