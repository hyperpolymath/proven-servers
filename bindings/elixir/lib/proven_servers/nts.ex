# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Nts do
  @moduledoc """
  Network Time Security types for the proven-servers ABI.
  
  Formally verified NTS types (RFC 8915).
  Mirrors the Idris2 module `NtsABI.Types`.
  
  - `RecordType` -- NTS-KE record types.
  - `ErrorCode` -- NTS error codes.
  - `AeadAlgorithm` -- AEAD algorithms for NTS.
  - `HandshakeState` -- NTS handshake states.
  - `SessionState` -- NTS session lifecycle states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard NTS-KE port."
  @spec nts_ke_port() :: non_neg_integer()
  def nts_ke_port, do: 4460

  # ===========================================================================
  # RecordType (tags 0-8)
  # ===========================================================================

  @typedoc """
  RecordType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type record_type ::
          :end_of_message
          | :next_protocol
          | :error
          | :warning
          | :aead_algorithm
          | :cookie
          | :cookie_placeholder
          | :ntske_server
          | :ntske_port

  @record_type_tags %{
    end_of_message: 0,
    next_protocol: 1,
    error: 2,
    warning: 3,
    aead_algorithm: 4,
    cookie: 5,
    cookie_placeholder: 6,
    ntske_server: 7,
    ntske_port: 8,
  }

  @tag_to_record_type Map.new(@record_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `RecordType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..8, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Nts.record_type_from_tag(0)
      {:ok, :end_of_message}
  """
  @spec record_type_from_tag(non_neg_integer()) :: {:ok, record_type()} | :error
  def record_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_record_type, tag)}
  end

  def record_type_from_tag(_tag), do: :error

  @doc """
  Encode a `RecordType` to the C-ABI tag value.
  """
  @spec record_type_to_tag(record_type()) :: non_neg_integer()
  def record_type_to_tag(val) when is_map_key(@record_type_tags, val) do
    Map.fetch!(@record_type_tags, val)
  end

  @doc """
  All `RecordType` variants in tag order.
  """
  @spec all_record_types() :: [record_type()]
  def all_record_types do
    [
      :end_of_message, :next_protocol, :error, :warning, :aead_algorithm,
      :cookie, :cookie_placeholder, :ntske_server, :ntske_port
    ]
  end

  # ===========================================================================
  # ErrorCode (tags 0-2)
  # ===========================================================================

  @typedoc """
  ErrorCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type error_code :: :unrecognized_critical | :bad_request | :internal_error

  @error_code_tags %{
    unrecognized_critical: 0,
    bad_request: 1,
    internal_error: 2,
  }

  @tag_to_error_code Map.new(@error_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ErrorCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Nts.error_code_from_tag(0)
      {:ok, :unrecognized_critical}
  """
  @spec error_code_from_tag(non_neg_integer()) :: {:ok, error_code()} | :error
  def error_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_error_code, tag)}
  end

  def error_code_from_tag(_tag), do: :error

  @doc """
  Encode a `ErrorCode` to the C-ABI tag value.
  """
  @spec error_code_to_tag(error_code()) :: non_neg_integer()
  def error_code_to_tag(val) when is_map_key(@error_code_tags, val) do
    Map.fetch!(@error_code_tags, val)
  end

  @doc """
  All `ErrorCode` variants in tag order.
  """
  @spec all_error_codes() :: [error_code()]
  def all_error_codes, do: [:unrecognized_critical, :bad_request, :internal_error]

  # ===========================================================================
  # AeadAlgorithm (tags 0-2)
  # ===========================================================================

  @typedoc """
  AeadAlgorithm types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type aead_algorithm :: :aead_aes128_gcm | :aead_aes256_gcm | :aead_aes_siv_cmac256

  @aead_algorithm_tags %{
    aead_aes128_gcm: 0,
    aead_aes256_gcm: 1,
    aead_aes_siv_cmac256: 2,
  }

  @tag_to_aead_algorithm Map.new(@aead_algorithm_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AeadAlgorithm` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Nts.aead_algorithm_from_tag(0)
      {:ok, :aead_aes128_gcm}
  """
  @spec aead_algorithm_from_tag(non_neg_integer()) :: {:ok, aead_algorithm()} | :error
  def aead_algorithm_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_aead_algorithm, tag)}
  end

  def aead_algorithm_from_tag(_tag), do: :error

  @doc """
  Encode a `AeadAlgorithm` to the C-ABI tag value.
  """
  @spec aead_algorithm_to_tag(aead_algorithm()) :: non_neg_integer()
  def aead_algorithm_to_tag(val) when is_map_key(@aead_algorithm_tags, val) do
    Map.fetch!(@aead_algorithm_tags, val)
  end

  @doc """
  All `AeadAlgorithm` variants in tag order.
  """
  @spec all_aead_algorithms() :: [aead_algorithm()]
  def all_aead_algorithms, do: [:aead_aes128_gcm, :aead_aes256_gcm, :aead_aes_siv_cmac256]

  # ===========================================================================
  # HandshakeState (tags 0-3)
  # ===========================================================================

  @typedoc """
  HandshakeState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type handshake_state :: :initial | :negotiating | :established | :failed

  @handshake_state_tags %{
    initial: 0,
    negotiating: 1,
    established: 2,
    failed: 3,
  }

  @tag_to_handshake_state Map.new(@handshake_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `HandshakeState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Nts.handshake_state_from_tag(0)
      {:ok, :initial}
  """
  @spec handshake_state_from_tag(non_neg_integer()) :: {:ok, handshake_state()} | :error
  def handshake_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_handshake_state, tag)}
  end

  def handshake_state_from_tag(_tag), do: :error

  @doc """
  Encode a `HandshakeState` to the C-ABI tag value.
  """
  @spec handshake_state_to_tag(handshake_state()) :: non_neg_integer()
  def handshake_state_to_tag(val) when is_map_key(@handshake_state_tags, val) do
    Map.fetch!(@handshake_state_tags, val)
  end

  @doc """
  All `HandshakeState` variants in tag order.
  """
  @spec all_handshake_states() :: [handshake_state()]
  def all_handshake_states, do: [:initial, :negotiating, :established, :failed]

  # ===========================================================================
  # SessionState (tags 0-4)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :idle | :handshaking | :negotiating | :established | :closing

  @session_state_tags %{
    idle: 0,
    handshaking: 1,
    negotiating: 2,
    established: 3,
    closing: 4,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Nts.session_state_from_tag(0)
      {:ok, :idle}
  """
  @spec session_state_from_tag(non_neg_integer()) :: {:ok, session_state()} | :error
  def session_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_session_state, tag)}
  end

  def session_state_from_tag(_tag), do: :error

  @doc """
  Encode a `SessionState` to the C-ABI tag value.
  """
  @spec session_state_to_tag(session_state()) :: non_neg_integer()
  def session_state_to_tag(val) when is_map_key(@session_state_tags, val) do
    Map.fetch!(@session_state_tags, val)
  end

  @doc """
  All `SessionState` variants in tag order.
  """
  @spec all_session_states() :: [session_state()]
  def all_session_states, do: [:idle, :handshaking, :negotiating, :established, :closing]

end
