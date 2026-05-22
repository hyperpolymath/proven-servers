// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// HTTP protocol bindings for proven-servers.
//
// Wraps the C-ABI functions from protocols/proven-httpd/ffi/zig/src/httpd.zig.
// Context lifecycle: create -> parse -> query/set -> send -> reset/destroy.
package proven

/*
#cgo LDFLAGS: -lproven_httpd
#include <stdint.h>

extern uint32_t http_abi_version();
extern int http_create_context();
extern void http_destroy_context(int slot);
extern uint8_t http_parse_request(int slot, const uint8_t *data, uint32_t len);
extern uint8_t http_get_method(int slot);
extern uint32_t http_get_path(int slot, uint8_t *buf, uint32_t len);
extern uint32_t http_get_header(int slot, const uint8_t *key, uint32_t klen, uint8_t *buf, uint32_t blen);
extern uint32_t http_get_body(int slot, uint8_t *buf, uint32_t len);
extern uint8_t http_set_status(int slot, uint8_t status_tag);
extern uint8_t http_set_header(int slot, const uint8_t *key, uint32_t klen, const uint8_t *val, uint32_t vlen);
extern uint8_t http_set_body(int slot, const uint8_t *data, uint32_t len);
extern uint8_t http_send_response(int slot);
extern uint8_t http_keep_alive_check(int slot);
extern uint8_t http_get_phase(int slot);
extern uint8_t http_get_version(int slot);
extern uint8_t http_reset_context(int slot);
extern uint8_t http_can_transition(uint8_t from, uint8_t to);
*/
import "C"
import "unsafe"

// HttpMethod represents an HTTP request method (RFC 7231).
// Tag values match httpMethodToTag in HTTPABI.Layout.
type HttpMethod uint8

const (
	HttpGet     HttpMethod = iota // GET
	HttpPost                      // POST
	HttpPut                       // PUT
	HttpDelete                    // DELETE
	HttpPatch                     // PATCH
	HttpHead                      // HEAD
	HttpOptions                   // OPTIONS
	HttpTrace                     // TRACE
	HttpConnect                   // CONNECT
)

// RequestPhase represents the HTTP request lifecycle state.
// Tag values match the Idris2 ABI transitions.
type RequestPhase uint8

const (
	PhaseIdle          RequestPhase = iota // Waiting for data
	PhaseReceiving                         // Data being received
	PhaseHeadersParsed                     // Headers fully parsed
	PhaseBodyReceiving                     // Body being received
	PhaseComplete                          // Request fully parsed
	PhaseResponding                        // Building response
	PhaseSent                              // Response sent
)

// HttpVersion represents the HTTP protocol version.
type HttpVersion uint8

const (
	Http10 HttpVersion = iota // HTTP/1.0
	Http11                    // HTTP/1.1
)

// HttpStatusCode represents an HTTP response status code tag.
type HttpStatusCode uint8

const (
	StatusOk                  HttpStatusCode = 0  // 200
	StatusCreated             HttpStatusCode = 1  // 201
	StatusNoContent           HttpStatusCode = 2  // 204
	StatusMovedPermanently    HttpStatusCode = 3  // 301
	StatusFound               HttpStatusCode = 4  // 302
	StatusNotModified         HttpStatusCode = 5  // 304
	StatusBadRequest          HttpStatusCode = 6  // 400
	StatusUnauthorized        HttpStatusCode = 7  // 401
	StatusForbidden           HttpStatusCode = 8  // 403
	StatusNotFound            HttpStatusCode = 9  // 404
	StatusMethodNotAllowed    HttpStatusCode = 10 // 405
	StatusInternalServerError HttpStatusCode = 11 // 500
	StatusNotImplemented      HttpStatusCode = 12 // 501
	StatusBadGateway          HttpStatusCode = 13 // 502
	StatusServiceUnavailable  HttpStatusCode = 14 // 503
)

// ParseResult indicates the outcome of feeding raw HTTP data into a context.
type ParseResult int

const (
	// ParseComplete means parsing is finished; the request is ready.
	ParseComplete ParseResult = iota
	// ParseRejected means the request was malformed.
	ParseRejected
	// ParseNeedMore means more data is needed to complete parsing.
	ParseNeedMore
)

// HttpContext wraps a slot in the proven-httpd context pool.
// Must be closed when no longer needed to release the slot.
type HttpContext struct {
	slot C.int
}

// HttpABIVersion returns the ABI version of the linked libproven_httpd.
func HttpABIVersion() uint32 {
	return uint32(C.http_abi_version())
}

// HttpCreateContext allocates a new HTTP context in the Idle phase.
// Returns an HttpContext that must be closed to release the slot.
func HttpCreateContext() (*HttpContext, error) {
	slot := C.http_create_context()
	s, err := slotError(slot)
	if err != nil {
		return nil, err
	}
	return &HttpContext{slot: C.int(s)}, nil
}

// Close releases the HTTP context slot back to the pool.
func (ctx *HttpContext) Close() {
	C.http_destroy_context(ctx.slot)
}

// ParseRequest feeds raw HTTP data into the context for parsing.
func (ctx *HttpContext) ParseRequest(data []byte) (ParseResult, error) {
	if len(data) == 0 {
		return ParseRejected, &ProvenError{Code: 0, Kind: ErrInvalidParameter}
	}
	result := C.http_parse_request(ctx.slot, (*C.uint8_t)(unsafe.Pointer(&data[0])), C.uint32_t(len(data)))
	switch result {
	case 0:
		return ParseComplete, nil
	case 1:
		return ParseRejected, nil
	case 2:
		return ParseNeedMore, nil
	default:
		return ParseRejected, &ProvenError{Code: int(result), Kind: ErrUnknown}
	}
}

// GetMethod returns the HTTP method of the parsed request, or -1 if unset.
func (ctx *HttpContext) GetMethod() (HttpMethod, bool) {
	tag := C.http_get_method(ctx.slot)
	if tag == 255 {
		return 0, false
	}
	return HttpMethod(tag), true
}

// GetPath copies the request path into the provided buffer and returns
// the number of bytes written.
func (ctx *HttpContext) GetPath(buf []byte) int {
	if len(buf) == 0 {
		return 0
	}
	written := C.http_get_path(ctx.slot, (*C.uint8_t)(unsafe.Pointer(&buf[0])), C.uint32_t(len(buf)))
	return int(written)
}

// GetHeader looks up a request header by key (case-insensitive) and copies
// the value into buf. Returns the number of bytes written.
func (ctx *HttpContext) GetHeader(key string, buf []byte) int {
	if len(buf) == 0 || len(key) == 0 {
		return 0
	}
	keyBytes := []byte(key)
	written := C.http_get_header(
		ctx.slot,
		(*C.uint8_t)(unsafe.Pointer(&keyBytes[0])), C.uint32_t(len(keyBytes)),
		(*C.uint8_t)(unsafe.Pointer(&buf[0])), C.uint32_t(len(buf)),
	)
	return int(written)
}

// GetBody copies the request body into buf and returns bytes written.
func (ctx *HttpContext) GetBody(buf []byte) int {
	if len(buf) == 0 {
		return 0
	}
	written := C.http_get_body(ctx.slot, (*C.uint8_t)(unsafe.Pointer(&buf[0])), C.uint32_t(len(buf)))
	return int(written)
}

// SetStatus sets the response status code. Requires Complete or Responding phase.
func (ctx *HttpContext) SetStatus(status HttpStatusCode) error {
	return statusError(C.http_set_status(ctx.slot, C.uint8_t(status)))
}

// SetHeader sets a response header key-value pair.
func (ctx *HttpContext) SetHeader(key, value string) error {
	keyBytes := []byte(key)
	valBytes := []byte(value)
	return statusError(C.http_set_header(
		ctx.slot,
		(*C.uint8_t)(unsafe.Pointer(&keyBytes[0])), C.uint32_t(len(keyBytes)),
		(*C.uint8_t)(unsafe.Pointer(&valBytes[0])), C.uint32_t(len(valBytes)),
	))
}

// SetBody sets the response body data.
func (ctx *HttpContext) SetBody(data []byte) error {
	if len(data) == 0 {
		return statusError(C.http_set_body(ctx.slot, nil, 0))
	}
	return statusError(C.http_set_body(ctx.slot, (*C.uint8_t)(unsafe.Pointer(&data[0])), C.uint32_t(len(data))))
}

// SendResponse sends the response. Transitions Responding -> Sent.
func (ctx *HttpContext) SendResponse() error {
	return statusError(C.http_send_response(ctx.slot))
}

// KeepAliveCheck returns true if the connection uses keep-alive.
func (ctx *HttpContext) KeepAliveCheck() bool {
	return C.http_keep_alive_check(ctx.slot) == 1
}

// GetPhase returns the current request processing phase.
func (ctx *HttpContext) GetPhase() (RequestPhase, bool) {
	tag := C.http_get_phase(ctx.slot)
	if tag > 6 {
		return 0, false
	}
	return RequestPhase(tag), true
}

// GetVersion returns the HTTP version of the parsed request.
func (ctx *HttpContext) GetVersion() (HttpVersion, bool) {
	tag := C.http_get_version(ctx.slot)
	if tag > 1 {
		return 0, false
	}
	return HttpVersion(tag), true
}

// ResetContext resets the context for keep-alive reuse (Sent -> Idle).
func (ctx *HttpContext) ResetContext() error {
	return statusError(C.http_reset_context(ctx.slot))
}

// HttpCanTransition checks whether a lifecycle transition is valid.
func HttpCanTransition(from, to RequestPhase) bool {
	return C.http_can_transition(C.uint8_t(from), C.uint8_t(to)) == 1
}
