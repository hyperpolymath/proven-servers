# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Ocsp do
  @moduledoc """
  OCSP types for the proven-servers ABI.
  
  Formally verified OCSP (Online Certificate Status Protocol, RFC 6960) types.
  Mirrors the Idris2 module `OcspABI.Types`.
  
  - `CertStatus` -- Certificate status in OCSP response.
  - `ResponseStatus` -- OCSP response status.
  - `HashAlgorithm` -- OCSP hash algorithms.
  - `ResponderState` -- OCSP responder states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard OCSP HTTP port."
  @spec ocsp_port() :: non_neg_integer()
  def ocsp_port, do: 80

  # ===========================================================================
  # CertStatus (tags 0-2)
  # ===========================================================================

  @typedoc """
  CertStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type cert_status :: :good | :revoked | :unknown

  @cert_status_tags %{
    good: 0,
    revoked: 1,
    unknown: 2,
  }

  @tag_to_cert_status Map.new(@cert_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `CertStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ocsp.cert_status_from_tag(0)
      {:ok, :good}
  """
  @spec cert_status_from_tag(non_neg_integer()) :: {:ok, cert_status()} | :error
  def cert_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_cert_status, tag)}
  end

  def cert_status_from_tag(_tag), do: :error

  @doc """
  Encode a `CertStatus` to the C-ABI tag value.
  """
  @spec cert_status_to_tag(cert_status()) :: non_neg_integer()
  def cert_status_to_tag(val) when is_map_key(@cert_status_tags, val) do
    Map.fetch!(@cert_status_tags, val)
  end

  @doc """
  All `CertStatus` variants in tag order.
  """
  @spec all_cert_statuss() :: [cert_status()]
  def all_cert_statuss, do: [:good, :revoked, :unknown]

  # ===========================================================================
  # ResponseStatus (tags 0-5)
  # ===========================================================================

  @typedoc """
  ResponseStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type response_status ::
          :successful
          | :malformed_request
          | :internal_error
          | :try_later
          | :sig_required
          | :unauthorized

  @response_status_tags %{
    successful: 0,
    malformed_request: 1,
    internal_error: 2,
    try_later: 3,
    sig_required: 4,
    unauthorized: 5,
  }

  @tag_to_response_status Map.new(@response_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ResponseStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ocsp.response_status_from_tag(0)
      {:ok, :successful}
  """
  @spec response_status_from_tag(non_neg_integer()) :: {:ok, response_status()} | :error
  def response_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_response_status, tag)}
  end

  def response_status_from_tag(_tag), do: :error

  @doc """
  Encode a `ResponseStatus` to the C-ABI tag value.
  """
  @spec response_status_to_tag(response_status()) :: non_neg_integer()
  def response_status_to_tag(val) when is_map_key(@response_status_tags, val) do
    Map.fetch!(@response_status_tags, val)
  end

  @doc """
  All `ResponseStatus` variants in tag order.
  """
  @spec all_response_statuss() :: [response_status()]
  def all_response_statuss do
    [
      :successful, :malformed_request, :internal_error, :try_later, :sig_required,
      :unauthorized
    ]
  end

  # ===========================================================================
  # HashAlgorithm (tags 0-3)
  # ===========================================================================

  @typedoc """
  HashAlgorithm types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type hash_algorithm :: :sha1 | :sha256 | :sha384 | :sha512

  @hash_algorithm_tags %{
    sha1: 0,
    sha256: 1,
    sha384: 2,
    sha512: 3,
  }

  @tag_to_hash_algorithm Map.new(@hash_algorithm_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `HashAlgorithm` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ocsp.hash_algorithm_from_tag(0)
      {:ok, :sha1}
  """
  @spec hash_algorithm_from_tag(non_neg_integer()) :: {:ok, hash_algorithm()} | :error
  def hash_algorithm_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_hash_algorithm, tag)}
  end

  def hash_algorithm_from_tag(_tag), do: :error

  @doc """
  Encode a `HashAlgorithm` to the C-ABI tag value.
  """
  @spec hash_algorithm_to_tag(hash_algorithm()) :: non_neg_integer()
  def hash_algorithm_to_tag(val) when is_map_key(@hash_algorithm_tags, val) do
    Map.fetch!(@hash_algorithm_tags, val)
  end

  @doc """
  All `HashAlgorithm` variants in tag order.
  """
  @spec all_hash_algorithms() :: [hash_algorithm()]
  def all_hash_algorithms, do: [:sha1, :sha256, :sha384, :sha512]

  # ===========================================================================
  # ResponderState (tags 0-4)
  # ===========================================================================

  @typedoc """
  ResponderState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type responder_state :: :idle | :ready | :processing | :signing | :closing

  @responder_state_tags %{
    idle: 0,
    ready: 1,
    processing: 2,
    signing: 3,
    closing: 4,
  }

  @tag_to_responder_state Map.new(@responder_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ResponderState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ocsp.responder_state_from_tag(0)
      {:ok, :idle}
  """
  @spec responder_state_from_tag(non_neg_integer()) :: {:ok, responder_state()} | :error
  def responder_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_responder_state, tag)}
  end

  def responder_state_from_tag(_tag), do: :error

  @doc """
  Encode a `ResponderState` to the C-ABI tag value.
  """
  @spec responder_state_to_tag(responder_state()) :: non_neg_integer()
  def responder_state_to_tag(val) when is_map_key(@responder_state_tags, val) do
    Map.fetch!(@responder_state_tags, val)
  end

  @doc """
  All `ResponderState` variants in tag order.
  """
  @spec all_responder_states() :: [responder_state()]
  def all_responder_states, do: [:idle, :ready, :processing, :signing, :closing]

end
