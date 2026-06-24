# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Tls do
  @moduledoc """
  TLS protocol types for the proven-servers ABI.

  Models TLS 1.2 and 1.3 protocol types based on RFC 8446 (TLS 1.3)
  and RFC 5246 (TLS 1.2). Tag values are provisional pending Idris2
  ABI formalisation.

  ## Handshake State Machine (TLS 1.3)

      Start -> WaitServerHello -> WaitEncryptedExtensions ->
      WaitCertRequest -> WaitCert -> WaitFinished -> Connected
  """

  # ===========================================================================
  # TLS Constants
  # ===========================================================================

  @doc "Standard HTTPS port (443)."
  @spec https_port() :: non_neg_integer()
  def https_port, do: 443

  @doc "Maximum TLS record size in bytes (16384, RFC 8446 Section 5.1)."
  @spec max_record_size() :: non_neg_integer()
  def max_record_size, do: 16_384

  @doc "Maximum TLS record size with padding (16640, RFC 8446 Section 5.4)."
  @spec max_record_size_with_padding() :: non_neg_integer()
  def max_record_size_with_padding, do: 16_640

  # ===========================================================================
  # TlsVersion (provisional tags 0-3)
  # ===========================================================================

  @typedoc "TLS protocol versions."
  @type tls_version :: :tls10 | :tls11 | :tls12 | :tls13

  @version_tags %{tls10: 0, tls11: 1, tls12: 2, tls13: 3}
  @tag_to_version Map.new(@version_tags, fn {k, v} -> {v, k} end)

  @version_wires %{tls10: 0x0301, tls11: 0x0302, tls12: 0x0303, tls13: 0x0304}
  @version_strings %{tls10: "TLS 1.0", tls11: "TLS 1.1", tls12: "TLS 1.2", tls13: "TLS 1.3"}

  @doc "Decode from a C-ABI tag value."
  @spec version_from_tag(non_neg_integer()) :: {:ok, tls_version()} | :error
  def version_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_version, tag)}
  end
  def version_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec version_to_tag(tls_version()) :: non_neg_integer()
  def version_to_tag(v) when is_map_key(@version_tags, v), do: Map.fetch!(@version_tags, v)

  @doc "TLS wire protocol version bytes (major.minor as u16)."
  @spec version_wire_value(tls_version()) :: non_neg_integer()
  def version_wire_value(v) when is_map_key(@version_wires, v), do: Map.fetch!(@version_wires, v)

  @doc """
  Human-readable version string.

  ## Examples

      iex> ProvenServers.Tls.version_to_string(:tls13)
      "TLS 1.3"
  """
  @spec version_to_string(tls_version()) :: String.t()
  def version_to_string(v) when is_map_key(@version_strings, v), do: Map.fetch!(@version_strings, v)

  @doc "Whether this version is considered secure (TLS 1.2+ per RFC 8996)."
  @spec version_secure?(tls_version()) :: boolean()
  def version_secure?(v) when v in [:tls12, :tls13], do: true
  def version_secure?(_v), do: false

  # ===========================================================================
  # HandshakeType (RFC 8446 Section 4, provisional tags 0-10)
  # ===========================================================================

  @typedoc "TLS handshake message types (RFC 8446 Section 4)."
  @type handshake_type ::
          :client_hello | :server_hello | :new_session_ticket | :end_of_early_data
          | :encrypted_extensions | :certificate | :certificate_request
          | :certificate_verify | :finished | :key_update | :message_hash

  @handshake_type_tags %{
    client_hello: 0, server_hello: 1, new_session_ticket: 2,
    end_of_early_data: 3, encrypted_extensions: 4, certificate: 5,
    certificate_request: 6, certificate_verify: 7, finished: 8,
    key_update: 9, message_hash: 10
  }
  @tag_to_handshake_type Map.new(@handshake_type_tags, fn {k, v} -> {v, k} end)

  @handshake_type_wires %{
    client_hello: 1, server_hello: 2, new_session_ticket: 4,
    end_of_early_data: 5, encrypted_extensions: 8, certificate: 11,
    certificate_request: 13, certificate_verify: 15, finished: 20,
    key_update: 24, message_hash: 254
  }

  @doc "Decode from a C-ABI tag value."
  @spec handshake_type_from_tag(non_neg_integer()) :: {:ok, handshake_type()} | :error
  def handshake_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 10 do
    {:ok, Map.fetch!(@tag_to_handshake_type, tag)}
  end
  def handshake_type_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec handshake_type_to_tag(handshake_type()) :: non_neg_integer()
  def handshake_type_to_tag(ht) when is_map_key(@handshake_type_tags, ht) do
    Map.fetch!(@handshake_type_tags, ht)
  end

  @doc "RFC wire value for the handshake type."
  @spec handshake_type_wire_value(handshake_type()) :: non_neg_integer()
  def handshake_type_wire_value(ht) when is_map_key(@handshake_type_wires, ht) do
    Map.fetch!(@handshake_type_wires, ht)
  end

  # ===========================================================================
  # CipherSuite (TLS 1.3, provisional tags 0-4)
  # ===========================================================================

  @typedoc "TLS 1.3 cipher suites (RFC 8446 Section 9.1)."
  @type cipher_suite ::
          :aes_128_gcm_sha256 | :aes_256_gcm_sha384 | :chacha20_poly1305_sha256
          | :aes_128_ccm_sha256 | :aes_128_ccm_8_sha256

  @cipher_suite_tags %{
    aes_128_gcm_sha256: 0, aes_256_gcm_sha384: 1,
    chacha20_poly1305_sha256: 2, aes_128_ccm_sha256: 3, aes_128_ccm_8_sha256: 4
  }
  @tag_to_cipher_suite Map.new(@cipher_suite_tags, fn {k, v} -> {v, k} end)

  @cipher_suite_ianas %{
    aes_128_gcm_sha256: 0x1301, aes_256_gcm_sha384: 0x1302,
    chacha20_poly1305_sha256: 0x1303, aes_128_ccm_sha256: 0x1304, aes_128_ccm_8_sha256: 0x1305
  }

  @cipher_suite_names %{
    aes_128_gcm_sha256: "TLS_AES_128_GCM_SHA256",
    aes_256_gcm_sha384: "TLS_AES_256_GCM_SHA384",
    chacha20_poly1305_sha256: "TLS_CHACHA20_POLY1305_SHA256",
    aes_128_ccm_sha256: "TLS_AES_128_CCM_SHA256",
    aes_128_ccm_8_sha256: "TLS_AES_128_CCM_8_SHA256"
  }

  @doc "Decode from a C-ABI tag value."
  @spec cipher_suite_from_tag(non_neg_integer()) :: {:ok, cipher_suite()} | :error
  def cipher_suite_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_cipher_suite, tag)}
  end
  def cipher_suite_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec cipher_suite_to_tag(cipher_suite()) :: non_neg_integer()
  def cipher_suite_to_tag(cs) when is_map_key(@cipher_suite_tags, cs) do
    Map.fetch!(@cipher_suite_tags, cs)
  end

  @doc "IANA cipher suite value (RFC 8446 Appendix B.4)."
  @spec cipher_suite_iana_value(cipher_suite()) :: non_neg_integer()
  def cipher_suite_iana_value(cs) when is_map_key(@cipher_suite_ianas, cs) do
    Map.fetch!(@cipher_suite_ianas, cs)
  end

  @doc "OpenSSL-style cipher suite name."
  @spec cipher_suite_name(cipher_suite()) :: String.t()
  def cipher_suite_name(cs) when is_map_key(@cipher_suite_names, cs) do
    Map.fetch!(@cipher_suite_names, cs)
  end

  # ===========================================================================
  # AlertLevel (RFC 8446 Section 6, provisional tags 0-1)
  # ===========================================================================

  @typedoc "TLS alert levels (RFC 8446 Section 6.1)."
  @type alert_level :: :warning | :fatal

  @doc "Decode from a C-ABI tag value."
  @spec alert_level_from_tag(non_neg_integer()) :: {:ok, alert_level()} | :error
  def alert_level_from_tag(0), do: {:ok, :warning}
  def alert_level_from_tag(1), do: {:ok, :fatal}
  def alert_level_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec alert_level_to_tag(alert_level()) :: non_neg_integer()
  def alert_level_to_tag(:warning), do: 0
  def alert_level_to_tag(:fatal), do: 1

  @doc "TLS wire value."
  @spec alert_level_wire_value(alert_level()) :: non_neg_integer()
  def alert_level_wire_value(:warning), do: 1
  def alert_level_wire_value(:fatal), do: 2

  # ===========================================================================
  # AlertDescription (RFC 8446 Section 6.2, provisional tags 0-13)
  # ===========================================================================

  @typedoc "TLS alert descriptions (RFC 8446 Section 6.2, subset)."
  @type alert_description ::
          :close_notify | :unexpected_message | :bad_record_mac | :record_overflow
          | :handshake_failure | :bad_certificate | :unsupported_certificate
          | :certificate_revoked | :certificate_expired | :certificate_unknown
          | :illegal_parameter | :decode_error | :decrypt_error | :protocol_version

  @alert_desc_tags %{
    close_notify: 0, unexpected_message: 1, bad_record_mac: 2, record_overflow: 3,
    handshake_failure: 4, bad_certificate: 5, unsupported_certificate: 6,
    certificate_revoked: 7, certificate_expired: 8, certificate_unknown: 9,
    illegal_parameter: 10, decode_error: 11, decrypt_error: 12, protocol_version: 13
  }
  @tag_to_alert_desc Map.new(@alert_desc_tags, fn {k, v} -> {v, k} end)

  @alert_desc_strings %{
    close_notify: "close_notify", unexpected_message: "unexpected_message",
    bad_record_mac: "bad_record_mac", record_overflow: "record_overflow",
    handshake_failure: "handshake_failure", bad_certificate: "bad_certificate",
    unsupported_certificate: "unsupported_certificate",
    certificate_revoked: "certificate_revoked", certificate_expired: "certificate_expired",
    certificate_unknown: "certificate_unknown", illegal_parameter: "illegal_parameter",
    decode_error: "decode_error", decrypt_error: "decrypt_error",
    protocol_version: "protocol_version"
  }

  @doc "Decode from a C-ABI tag value."
  @spec alert_description_from_tag(non_neg_integer()) :: {:ok, alert_description()} | :error
  def alert_description_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 13 do
    {:ok, Map.fetch!(@tag_to_alert_desc, tag)}
  end
  def alert_description_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec alert_description_to_tag(alert_description()) :: non_neg_integer()
  def alert_description_to_tag(desc) when is_map_key(@alert_desc_tags, desc) do
    Map.fetch!(@alert_desc_tags, desc)
  end

  @doc "Human-readable alert description."
  @spec alert_description_to_string(alert_description()) :: String.t()
  def alert_description_to_string(desc) when is_map_key(@alert_desc_strings, desc) do
    Map.fetch!(@alert_desc_strings, desc)
  end

  @doc "Whether this alert is always fatal."
  @spec alert_description_fatal?(alert_description()) :: boolean()
  def alert_description_fatal?(:close_notify), do: false
  def alert_description_fatal?(_desc), do: true

  # ===========================================================================
  # HandshakeState (provisional tags 0-6)
  # ===========================================================================

  @typedoc "TLS handshake lifecycle states (TLS 1.3 full handshake)."
  @type handshake_state ::
          :start | :wait_server_hello | :wait_encrypted_extensions
          | :wait_cert_request | :wait_cert | :wait_finished | :connected

  @handshake_state_tags %{
    start: 0, wait_server_hello: 1, wait_encrypted_extensions: 2,
    wait_cert_request: 3, wait_cert: 4, wait_finished: 5, connected: 6
  }
  @tag_to_handshake_state Map.new(@handshake_state_tags, fn {k, v} -> {v, k} end)

  @doc "Decode from a C-ABI tag value."
  @spec handshake_state_from_tag(non_neg_integer()) :: {:ok, handshake_state()} | :error
  def handshake_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_handshake_state, tag)}
  end
  def handshake_state_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec handshake_state_to_tag(handshake_state()) :: non_neg_integer()
  def handshake_state_to_tag(state) when is_map_key(@handshake_state_tags, state) do
    Map.fetch!(@handshake_state_tags, state)
  end

  @doc "Whether application data can be sent in this state."
  @spec handshake_state_can_send_data?(handshake_state()) :: boolean()
  def handshake_state_can_send_data?(:connected), do: true
  def handshake_state_can_send_data?(_state), do: false

  @typedoc "Named TLS handshake transitions."
  @type handshake_transition ::
          :send_client_hello | :receive_server_hello | :receive_encrypted_extensions
          | :receive_cert_request | :receive_cert | :receive_finished
          | :skip_cert_request | :skip_cert

  # validate_handshake_transition removed: unproven reimplementation. The verified check lives in the
  # Idris2/Zig core; calling it needs FFI wiring not yet present in this binding.
  # Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md
end
