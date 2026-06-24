# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Http do
  @moduledoc """
  HTTP protocol types for the proven-servers ABI.

  Mirrors the Idris2 modules:

    * `HTTP.Method` — request methods (RFC 7231)
    * `HTTP.Status` — status codes and categories (RFC 7231)
    * `HTTPABI.Layout` — C-ABI tag values for methods, versions, content types
    * `HTTPABI.Transitions` — request lifecycle state machine

  All tag values match the `*ToTag` functions in `HTTPABI.Layout` exactly.
  The request lifecycle is modelled via `request_phase` and
  `validate_http_transition/2`, matching the formal proofs in
  `HTTPABI.Transitions`.

  ## State Machine

  The HTTP request lifecycle follows this state machine:

      Idle -> Receiving -> HeadersParsed -> BodyReceiving -> Complete
           -> Responding -> Sent [-> Idle (keep-alive)]

  Abort transitions allow jumping from any in-progress phase to `:sent`.
  """

  # ===========================================================================
  # HTTP Method (HTTPABI.Layout.HttpMethod, tags 0-8)
  # ===========================================================================

  @typedoc """
  Standard HTTP request methods (RFC 7231 Section 4, RFC 5789).

  Tag values match `httpMethodToTag` in `HTTPABI.Layout`.
  """
  @type method ::
          :get | :post | :put | :delete | :patch | :head | :options | :trace | :connect

  @method_tags %{
    get: 0,
    post: 1,
    put: 2,
    delete: 3,
    patch: 4,
    head: 5,
    options: 6,
    trace: 7,
    connect: 8
  }

  @tag_to_method Map.new(@method_tags, fn {k, v} -> {v, k} end)

  @method_strings %{
    get: "GET",
    post: "POST",
    put: "PUT",
    delete: "DELETE",
    patch: "PATCH",
    head: "HEAD",
    options: "OPTIONS",
    trace: "TRACE",
    connect: "CONNECT"
  }

  @string_to_method Map.new(@method_strings, fn {k, v} -> {v, k} end)

  @doc """
  Parse a method string (case-sensitive) to a method atom.

  Returns `{:ok, method}` for recognised methods, `:error` for unknown.
  Matches `parseMethod` in `HTTP.Method`.

  ## Examples

      iex> ProvenServers.Http.parse_method("GET")
      {:ok, :get}

      iex> ProvenServers.Http.parse_method("UNKNOWN")
      :error
  """
  @spec parse_method(String.t()) :: {:ok, method()} | :error
  def parse_method(string) when is_binary(string) do
    case Map.fetch(@string_to_method, string) do
      {:ok, _method} = result -> result
      :error -> :error
    end
  end

  @doc """
  Decode from the C-ABI tag value.

  Matches `tagToHttpMethod` in `HTTPABI.Layout`.

  ## Examples

      iex> ProvenServers.Http.method_from_tag(0)
      {:ok, :get}

      iex> ProvenServers.Http.method_from_tag(99)
      :error
  """
  @spec method_from_tag(non_neg_integer()) :: {:ok, method()} | :error
  def method_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_method, tag)}
  end

  def method_from_tag(_tag), do: :error

  @doc """
  Encode a method to the C-ABI tag value.

  ## Examples

      iex> ProvenServers.Http.method_to_tag(:get)
      0
  """
  @spec method_to_tag(method()) :: non_neg_integer()
  def method_to_tag(method) when is_map_key(@method_tags, method) do
    Map.fetch!(@method_tags, method)
  end

  @doc """
  Canonical string representation (e.g. `"GET"`).

  ## Examples

      iex> ProvenServers.Http.method_to_string(:post)
      "POST"
  """
  @spec method_to_string(method()) :: String.t()
  def method_to_string(method) when is_map_key(@method_strings, method) do
    Map.fetch!(@method_strings, method)
  end

  @doc """
  Whether the method is "safe" (RFC 7231 Section 4.2.1).

  Safe methods are read-only and should not cause side effects.
  Matches `isSafe` in `HTTP.Method`.

  ## Examples

      iex> ProvenServers.Http.method_safe?(:get)
      true

      iex> ProvenServers.Http.method_safe?(:post)
      false
  """
  @spec method_safe?(method()) :: boolean()
  def method_safe?(method) when method in [:get, :head, :options, :trace], do: true
  def method_safe?(_method), do: false

  @doc """
  Whether the method is idempotent (RFC 7231 Section 4.2.2).

  Matches `isIdempotent` in `HTTP.Method`.

  ## Examples

      iex> ProvenServers.Http.method_idempotent?(:put)
      true

      iex> ProvenServers.Http.method_idempotent?(:post)
      false
  """
  @spec method_idempotent?(method()) :: boolean()
  def method_idempotent?(method)
      when method in [:get, :head, :put, :delete, :options, :trace],
      do: true

  def method_idempotent?(_method), do: false

  @doc """
  Whether the method typically carries a request body.

  Matches `hasRequestBody` in `HTTP.Method`.

  ## Examples

      iex> ProvenServers.Http.method_has_body?(:post)
      true

      iex> ProvenServers.Http.method_has_body?(:get)
      false
  """
  @spec method_has_body?(method()) :: boolean()
  def method_has_body?(method) when method in [:post, :put, :patch], do: true
  def method_has_body?(_method), do: false

  @doc """
  All standard HTTP methods in tag order.
  """
  @spec all_methods() :: [method()]
  def all_methods, do: [:get, :post, :put, :delete, :patch, :head, :options, :trace, :connect]

  # ===========================================================================
  # HTTP Version (HTTPABI.Layout.HttpVersion, tags 0-3)
  # ===========================================================================

  @typedoc """
  HTTP protocol versions.

  Tag values match `httpVersionToTag` in `HTTPABI.Layout`.
  """
  @type version :: :http10 | :http11 | :http20 | :http30

  @version_tags %{http10: 0, http11: 1, http20: 2, http30: 3}
  @tag_to_version Map.new(@version_tags, fn {k, v} -> {v, k} end)

  @version_strings %{
    http10: "HTTP/1.0",
    http11: "HTTP/1.1",
    http20: "HTTP/2",
    http30: "HTTP/3"
  }

  @doc """
  Decode from the C-ABI tag value.

  ## Examples

      iex> ProvenServers.Http.version_from_tag(1)
      {:ok, :http11}
  """
  @spec version_from_tag(non_neg_integer()) :: {:ok, version()} | :error
  def version_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_version, tag)}
  end

  def version_from_tag(_tag), do: :error

  @doc """
  Encode a version to the C-ABI tag value.
  """
  @spec version_to_tag(version()) :: non_neg_integer()
  def version_to_tag(version) when is_map_key(@version_tags, version) do
    Map.fetch!(@version_tags, version)
  end

  @doc """
  Human-readable version string.

  ## Examples

      iex> ProvenServers.Http.version_to_string(:http20)
      "HTTP/2"
  """
  @spec version_to_string(version()) :: String.t()
  def version_to_string(version) when is_map_key(@version_strings, version) do
    Map.fetch!(@version_strings, version)
  end

  # ===========================================================================
  # Status Category (HTTPABI.Layout.StatusCat, tags 0-4)
  # ===========================================================================

  @typedoc """
  HTTP response status code categories (RFC 7231 Section 6).
  """
  @type status_category :: :informational | :success | :redirect | :client_error | :server_error

  # ===========================================================================
  # Status Code (HTTPABI.Layout.AbiStatusCode, tags 0-28)
  # ===========================================================================

  @typedoc """
  Common HTTP status codes (RFC 7231 and related RFCs).

  Tag values match `abiStatusCodeToTag` in `HTTPABI.Layout`.
  """
  @type status_code ::
          :continue
          | :switching_protocols
          | :ok
          | :created
          | :accepted
          | :no_content
          | :moved_permanently
          | :found
          | :not_modified
          | :temporary_redirect
          | :permanent_redirect
          | :bad_request
          | :unauthorized
          | :forbidden
          | :not_found
          | :method_not_allowed
          | :request_timeout
          | :conflict
          | :gone
          | :length_required
          | :payload_too_large
          | :uri_too_long
          | :unsupported_media
          | :too_many_requests
          | :internal_error
          | :not_implemented
          | :bad_gateway
          | :service_unavailable
          | :gateway_timeout

  @status_code_tags %{
    continue: 0,
    switching_protocols: 1,
    ok: 2,
    created: 3,
    accepted: 4,
    no_content: 5,
    moved_permanently: 6,
    found: 7,
    not_modified: 8,
    temporary_redirect: 9,
    permanent_redirect: 10,
    bad_request: 11,
    unauthorized: 12,
    forbidden: 13,
    not_found: 14,
    method_not_allowed: 15,
    request_timeout: 16,
    conflict: 17,
    gone: 18,
    length_required: 19,
    payload_too_large: 20,
    uri_too_long: 21,
    unsupported_media: 22,
    too_many_requests: 23,
    internal_error: 24,
    not_implemented: 25,
    bad_gateway: 26,
    service_unavailable: 27,
    gateway_timeout: 28
  }

  @tag_to_status_code Map.new(@status_code_tags, fn {k, v} -> {v, k} end)

  @status_numeric_codes %{
    continue: 100,
    switching_protocols: 101,
    ok: 200,
    created: 201,
    accepted: 202,
    no_content: 204,
    moved_permanently: 301,
    found: 302,
    not_modified: 304,
    temporary_redirect: 307,
    permanent_redirect: 308,
    bad_request: 400,
    unauthorized: 401,
    forbidden: 403,
    not_found: 404,
    method_not_allowed: 405,
    request_timeout: 408,
    conflict: 409,
    gone: 410,
    length_required: 411,
    payload_too_large: 413,
    uri_too_long: 414,
    unsupported_media: 415,
    too_many_requests: 429,
    internal_error: 500,
    not_implemented: 501,
    bad_gateway: 502,
    service_unavailable: 503,
    gateway_timeout: 504
  }

  @numeric_to_status_code Map.new(@status_numeric_codes, fn {k, v} -> {v, k} end)

  @status_reason_phrases %{
    continue: "Continue",
    switching_protocols: "Switching Protocols",
    ok: "OK",
    created: "Created",
    accepted: "Accepted",
    no_content: "No Content",
    moved_permanently: "Moved Permanently",
    found: "Found",
    not_modified: "Not Modified",
    temporary_redirect: "Temporary Redirect",
    permanent_redirect: "Permanent Redirect",
    bad_request: "Bad Request",
    unauthorized: "Unauthorized",
    forbidden: "Forbidden",
    not_found: "Not Found",
    method_not_allowed: "Method Not Allowed",
    request_timeout: "Request Timeout",
    conflict: "Conflict",
    gone: "Gone",
    length_required: "Length Required",
    payload_too_large: "Payload Too Large",
    uri_too_long: "URI Too Long",
    unsupported_media: "Unsupported Media Type",
    too_many_requests: "Too Many Requests",
    internal_error: "Internal Server Error",
    not_implemented: "Not Implemented",
    bad_gateway: "Bad Gateway",
    service_unavailable: "Service Unavailable",
    gateway_timeout: "Gateway Timeout"
  }

  @doc """
  Decode from the C-ABI tag value.

  ## Examples

      iex> ProvenServers.Http.status_code_from_tag(2)
      {:ok, :ok}

      iex> ProvenServers.Http.status_code_from_tag(14)
      {:ok, :not_found}
  """
  @spec status_code_from_tag(non_neg_integer()) :: {:ok, status_code()} | :error
  def status_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 28 do
    {:ok, Map.fetch!(@tag_to_status_code, tag)}
  end

  def status_code_from_tag(_tag), do: :error

  @doc """
  Encode a status code to the C-ABI tag value.
  """
  @spec status_code_to_tag(status_code()) :: non_neg_integer()
  def status_code_to_tag(code) when is_map_key(@status_code_tags, code) do
    Map.fetch!(@status_code_tags, code)
  end

  @doc """
  The numeric HTTP status code (e.g. 200, 404).

  Matches `statusToCode` in `HTTP.Status`.

  ## Examples

      iex> ProvenServers.Http.numeric_code(:ok)
      200

      iex> ProvenServers.Http.numeric_code(:not_found)
      404
  """
  @spec numeric_code(status_code()) :: pos_integer()
  def numeric_code(code) when is_map_key(@status_numeric_codes, code) do
    Map.fetch!(@status_numeric_codes, code)
  end

  @doc """
  Parse from a numeric HTTP status code (e.g. `200`).

  Matches `fromCode` in `HTTP.Status`.

  ## Examples

      iex> ProvenServers.Http.status_from_numeric(200)
      {:ok, :ok}

      iex> ProvenServers.Http.status_from_numeric(999)
      :error
  """
  @spec status_from_numeric(pos_integer()) :: {:ok, status_code()} | :error
  def status_from_numeric(code) when is_integer(code) do
    case Map.fetch(@numeric_to_status_code, code) do
      {:ok, _status} = result -> result
      :error -> :error
    end
  end

  @doc """
  Standard reason phrase (RFC 7231).

  Matches `reasonPhrase` in `HTTP.Status`.

  ## Examples

      iex> ProvenServers.Http.reason_phrase(:ok)
      "OK"

      iex> ProvenServers.Http.reason_phrase(:not_found)
      "Not Found"
  """
  @spec reason_phrase(status_code()) :: String.t()
  def reason_phrase(code) when is_map_key(@status_reason_phrases, code) do
    Map.fetch!(@status_reason_phrases, code)
  end

  @doc """
  Categorise a status code.

  Matches `categorise` in `HTTP.Status`.

  ## Examples

      iex> ProvenServers.Http.status_category(:ok)
      :success

      iex> ProvenServers.Http.status_category(:not_found)
      :client_error
  """
  @spec status_category(status_code()) :: status_category()
  def status_category(code) when is_map_key(@status_code_tags, code) do
    tag = Map.fetch!(@status_code_tags, code)

    cond do
      tag <= 1 -> :informational
      tag <= 5 -> :success
      tag <= 10 -> :redirect
      tag <= 23 -> :client_error
      true -> :server_error
    end
  end

  @doc """
  Whether a status code represents success (2xx).
  """
  @spec status_success?(status_code()) :: boolean()
  def status_success?(code), do: status_category(code) == :success

  @doc """
  Whether a status code represents an error (4xx or 5xx).
  """
  @spec status_error?(status_code()) :: boolean()
  def status_error?(code), do: status_category(code) in [:client_error, :server_error]

  @doc """
  Whether a status code represents a redirect (3xx).
  """
  @spec status_redirect?(status_code()) :: boolean()
  def status_redirect?(code), do: status_category(code) == :redirect

  # ===========================================================================
  # Content Type (HTTPABI.Layout.ContentType, tags 0-7)
  # ===========================================================================

  @typedoc """
  Common HTTP content types for ABI interchange.

  Tag values match `contentTypeToTag` in `HTTPABI.Layout`.
  """
  @type content_type ::
          :text_plain
          | :text_html
          | :application_json
          | :application_xml
          | :application_form
          | :multipart_form
          | :octet_stream
          | :text_css

  @content_type_tags %{
    text_plain: 0,
    text_html: 1,
    application_json: 2,
    application_xml: 3,
    application_form: 4,
    multipart_form: 5,
    octet_stream: 6,
    text_css: 7
  }

  @tag_to_content_type Map.new(@content_type_tags, fn {k, v} -> {v, k} end)

  @content_type_mimes %{
    text_plain: "text/plain",
    text_html: "text/html",
    application_json: "application/json",
    application_xml: "application/xml",
    application_form: "application/x-www-form-urlencoded",
    multipart_form: "multipart/form-data",
    octet_stream: "application/octet-stream",
    text_css: "text/css"
  }

  @doc """
  Decode from the C-ABI tag value.

  ## Examples

      iex> ProvenServers.Http.content_type_from_tag(2)
      {:ok, :application_json}
  """
  @spec content_type_from_tag(non_neg_integer()) :: {:ok, content_type()} | :error
  def content_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_content_type, tag)}
  end

  def content_type_from_tag(_tag), do: :error

  @doc """
  Encode a content type to the C-ABI tag value.
  """
  @spec content_type_to_tag(content_type()) :: non_neg_integer()
  def content_type_to_tag(ct) when is_map_key(@content_type_tags, ct) do
    Map.fetch!(@content_type_tags, ct)
  end

  @doc """
  MIME type string.

  ## Examples

      iex> ProvenServers.Http.content_type_mime(:application_json)
      "application/json"
  """
  @spec content_type_mime(content_type()) :: String.t()
  def content_type_mime(ct) when is_map_key(@content_type_mimes, ct) do
    Map.fetch!(@content_type_mimes, ct)
  end

  # ===========================================================================
  # Header Type (HTTPABI.Layout.HeaderType, tags 0-9)
  # ===========================================================================

  @typedoc """
  Common HTTP header types for ABI interchange.

  Tag values match `headerTypeToTag` in `HTTPABI.Layout`.
  """
  @type header_type ::
          :content_type_header | :content_length | :host | :connection
          | :accept | :user_agent | :server | :location
          | :cache_control | :custom

  @header_type_tags %{
    content_type_header: 0, content_length: 1, host: 2, connection: 3,
    accept: 4, user_agent: 5, server: 6, location: 7,
    cache_control: 8, custom: 9
  }

  @tag_to_header_type Map.new(@header_type_tags, fn {k, v} -> {v, k} end)

  @header_type_names %{
    content_type_header: "Content-Type", content_length: "Content-Length",
    host: "Host", connection: "Connection", accept: "Accept",
    user_agent: "User-Agent", server: "Server", location: "Location",
    cache_control: "Cache-Control", custom: "X-Custom"
  }

  @doc """
  Decode from a C-ABI tag value.

  ## Examples

      iex> ProvenServers.Http.header_type_from_tag(0)
      {:ok, :content_type_header}
  """
  @spec header_type_from_tag(non_neg_integer()) :: {:ok, header_type()} | :error
  def header_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 9 do
    {:ok, Map.fetch!(@tag_to_header_type, tag)}
  end
  def header_type_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec header_type_to_tag(header_type()) :: non_neg_integer()
  def header_type_to_tag(ht) when is_map_key(@header_type_tags, ht) do
    Map.fetch!(@header_type_tags, ht)
  end

  @doc """
  Canonical header name string.

  ## Examples

      iex> ProvenServers.Http.header_type_name(:user_agent)
      "User-Agent"
  """
  @spec header_type_name(header_type()) :: String.t()
  def header_type_name(ht) when is_map_key(@header_type_names, ht) do
    Map.fetch!(@header_type_names, ht)
  end

  # ===========================================================================
  # Request Phase / Lifecycle (HTTPABI.Layout.RequestPhase, tags 0-6)
  # ===========================================================================

  @typedoc """
  Phases of the HTTP request processing lifecycle.

  Models the state machine from `HTTPABI.Transitions`.
  """
  @type request_phase ::
          :idle | :receiving | :headers_parsed | :body_receiving | :complete | :responding | :sent

  @phase_tags %{
    idle: 0,
    receiving: 1,
    headers_parsed: 2,
    body_receiving: 3,
    complete: 4,
    responding: 5,
    sent: 6
  }

  @tag_to_phase Map.new(@phase_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode from the C-ABI tag value.
  """
  @spec phase_from_tag(non_neg_integer()) :: {:ok, request_phase()} | :error
  def phase_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_phase, tag)}
  end

  def phase_from_tag(_tag), do: :error

  @doc """
  Encode a request phase to the C-ABI tag value.
  """
  @spec phase_to_tag(request_phase()) :: non_neg_integer()
  def phase_to_tag(phase) when is_map_key(@phase_tags, phase) do
    Map.fetch!(@phase_tags, phase)
  end

  @typedoc """
  Named HTTP request lifecycle transition.

  Each value corresponds to a constructor of `ValidHttpTransition`
  in `HTTPABI.Transitions`.
  """
  @type http_transition ::
          :start_receiving
          | :parse_headers
          | :start_body
          | :no_body_complete
          | :body_done
          | :begin_response
          | :finish_send
          | :keep_alive_recycle
          | :abort_receiving
          | :abort_headers_parsed
          | :abort_body_receiving
          | :abort_complete

  # validate_http_transition removed: unproven reimplementation. The verified check lives in the
  # Idris2/Zig core; calling it needs FFI wiring not yet present in this binding.
  # Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

  @doc """
  The source phase of a named transition.
  """
  @spec transition_from_phase(http_transition()) :: request_phase()
  def transition_from_phase(:start_receiving), do: :idle
  def transition_from_phase(:parse_headers), do: :receiving
  def transition_from_phase(:abort_receiving), do: :receiving
  def transition_from_phase(:start_body), do: :headers_parsed
  def transition_from_phase(:no_body_complete), do: :headers_parsed
  def transition_from_phase(:abort_headers_parsed), do: :headers_parsed
  def transition_from_phase(:body_done), do: :body_receiving
  def transition_from_phase(:abort_body_receiving), do: :body_receiving
  def transition_from_phase(:begin_response), do: :complete
  def transition_from_phase(:abort_complete), do: :complete
  def transition_from_phase(:finish_send), do: :responding
  def transition_from_phase(:keep_alive_recycle), do: :sent

  @doc """
  The target phase of a named transition.
  """
  @spec transition_to_phase(http_transition()) :: request_phase()
  def transition_to_phase(:start_receiving), do: :receiving
  def transition_to_phase(:parse_headers), do: :headers_parsed
  def transition_to_phase(:start_body), do: :body_receiving
  def transition_to_phase(:no_body_complete), do: :complete
  def transition_to_phase(:body_done), do: :complete
  def transition_to_phase(:begin_response), do: :responding
  def transition_to_phase(:finish_send), do: :sent
  def transition_to_phase(:abort_receiving), do: :sent
  def transition_to_phase(:abort_headers_parsed), do: :sent
  def transition_to_phase(:abort_body_receiving), do: :sent
  def transition_to_phase(:abort_complete), do: :sent
  def transition_to_phase(:keep_alive_recycle), do: :idle
end
