# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Ctlog do
  @moduledoc """
  CT Log types for the proven-servers ABI.
  
  Formally verified Certificate Transparency log types (RFC 6962).
  Mirrors the Idris2 module `CtlogABI.Types`.
  
  - `LogEntryType` -- CT log entry types.
  - `SignatureType` -- CT signature types.
  - `MerkleLeafType` -- Merkle tree leaf types.
  - `SubmissionStatus` -- Certificate submission status.
  - `VerificationResult` -- Proof verification results.
  - `ServerState` -- CT log server states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # LogEntryType (tags 0-1)
  # ===========================================================================

  @typedoc """
  LogEntryType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type log_entry_type :: :x509_entry | :precert_entry

  @log_entry_type_tags %{
    x509_entry: 0,
    precert_entry: 1,
  }

  @tag_to_log_entry_type Map.new(@log_entry_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `LogEntryType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ctlog.log_entry_type_from_tag(0)
      {:ok, :x509_entry}
  """
  @spec log_entry_type_from_tag(non_neg_integer()) :: {:ok, log_entry_type()} | :error
  def log_entry_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_log_entry_type, tag)}
  end

  def log_entry_type_from_tag(_tag), do: :error

  @doc """
  Encode a `LogEntryType` to the C-ABI tag value.
  """
  @spec log_entry_type_to_tag(log_entry_type()) :: non_neg_integer()
  def log_entry_type_to_tag(val) when is_map_key(@log_entry_type_tags, val) do
    Map.fetch!(@log_entry_type_tags, val)
  end

  @doc """
  All `LogEntryType` variants in tag order.
  """
  @spec all_log_entry_types() :: [log_entry_type()]
  def all_log_entry_types, do: [:x509_entry, :precert_entry]

  # ===========================================================================
  # SignatureType (tags 0-1)
  # ===========================================================================

  @typedoc """
  SignatureType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type signature_type :: :certificate_timestamp | :tree_hash

  @signature_type_tags %{
    certificate_timestamp: 0,
    tree_hash: 1,
  }

  @tag_to_signature_type Map.new(@signature_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SignatureType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ctlog.signature_type_from_tag(0)
      {:ok, :certificate_timestamp}
  """
  @spec signature_type_from_tag(non_neg_integer()) :: {:ok, signature_type()} | :error
  def signature_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_signature_type, tag)}
  end

  def signature_type_from_tag(_tag), do: :error

  @doc """
  Encode a `SignatureType` to the C-ABI tag value.
  """
  @spec signature_type_to_tag(signature_type()) :: non_neg_integer()
  def signature_type_to_tag(val) when is_map_key(@signature_type_tags, val) do
    Map.fetch!(@signature_type_tags, val)
  end

  @doc """
  All `SignatureType` variants in tag order.
  """
  @spec all_signature_types() :: [signature_type()]
  def all_signature_types, do: [:certificate_timestamp, :tree_hash]

  # ===========================================================================
  # MerkleLeafType (tags 0-0)
  # ===========================================================================

  @typedoc """
  MerkleLeafType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type merkle_leaf_type :: :timestamped_entry

  @merkle_leaf_type_tags %{
    timestamped_entry: 0,
  }

  @tag_to_merkle_leaf_type Map.new(@merkle_leaf_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MerkleLeafType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..0, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ctlog.merkle_leaf_type_from_tag(0)
      {:ok, :timestamped_entry}
  """
  @spec merkle_leaf_type_from_tag(non_neg_integer()) :: {:ok, merkle_leaf_type()} | :error
  def merkle_leaf_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 0 do
    {:ok, Map.fetch!(@tag_to_merkle_leaf_type, tag)}
  end

  def merkle_leaf_type_from_tag(_tag), do: :error

  @doc """
  Encode a `MerkleLeafType` to the C-ABI tag value.
  """
  @spec merkle_leaf_type_to_tag(merkle_leaf_type()) :: non_neg_integer()
  def merkle_leaf_type_to_tag(val) when is_map_key(@merkle_leaf_type_tags, val) do
    Map.fetch!(@merkle_leaf_type_tags, val)
  end

  @doc """
  All `MerkleLeafType` variants in tag order.
  """
  @spec all_merkle_leaf_types() :: [merkle_leaf_type()]
  def all_merkle_leaf_types, do: [:timestamped_entry]

  # ===========================================================================
  # SubmissionStatus (tags 0-5)
  # ===========================================================================

  @typedoc """
  SubmissionStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type submission_status ::
          :accepted
          | :duplicate
          | :rate_limited
          | :rejected
          | :invalid_chain
          | :unknown_anchor

  @submission_status_tags %{
    accepted: 0,
    duplicate: 1,
    rate_limited: 2,
    rejected: 3,
    invalid_chain: 4,
    unknown_anchor: 5,
  }

  @tag_to_submission_status Map.new(@submission_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SubmissionStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ctlog.submission_status_from_tag(0)
      {:ok, :accepted}
  """
  @spec submission_status_from_tag(non_neg_integer()) :: {:ok, submission_status()} | :error
  def submission_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_submission_status, tag)}
  end

  def submission_status_from_tag(_tag), do: :error

  @doc """
  Encode a `SubmissionStatus` to the C-ABI tag value.
  """
  @spec submission_status_to_tag(submission_status()) :: non_neg_integer()
  def submission_status_to_tag(val) when is_map_key(@submission_status_tags, val) do
    Map.fetch!(@submission_status_tags, val)
  end

  @doc """
  All `SubmissionStatus` variants in tag order.
  """
  @spec all_submission_statuss() :: [submission_status()]
  def all_submission_statuss do
    [
      :accepted, :duplicate, :rate_limited, :rejected, :invalid_chain,
      :unknown_anchor
    ]
  end

  # ===========================================================================
  # VerificationResult (tags 0-3)
  # ===========================================================================

  @typedoc """
  VerificationResult types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type verification_result :: :valid_proof | :invalid_proof | :inconsistent_tree | :stale_sth

  @verification_result_tags %{
    valid_proof: 0,
    invalid_proof: 1,
    inconsistent_tree: 2,
    stale_sth: 3,
  }

  @tag_to_verification_result Map.new(@verification_result_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `VerificationResult` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ctlog.verification_result_from_tag(0)
      {:ok, :valid_proof}
  """
  @spec verification_result_from_tag(non_neg_integer()) :: {:ok, verification_result()} | :error
  def verification_result_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_verification_result, tag)}
  end

  def verification_result_from_tag(_tag), do: :error

  @doc """
  Encode a `VerificationResult` to the C-ABI tag value.
  """
  @spec verification_result_to_tag(verification_result()) :: non_neg_integer()
  def verification_result_to_tag(val) when is_map_key(@verification_result_tags, val) do
    Map.fetch!(@verification_result_tags, val)
  end

  @doc """
  All `VerificationResult` variants in tag order.
  """
  @spec all_verification_results() :: [verification_result()]
  def all_verification_results, do: [:valid_proof, :invalid_proof, :inconsistent_tree, :stale_sth]

  # ===========================================================================
  # ServerState (tags 0-4)
  # ===========================================================================

  @typedoc """
  ServerState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type server_state :: :idle | :active | :merging | :signing | :shutdown

  @server_state_tags %{
    idle: 0,
    active: 1,
    merging: 2,
    signing: 3,
    shutdown: 4,
  }

  @tag_to_server_state Map.new(@server_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ServerState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ctlog.server_state_from_tag(0)
      {:ok, :idle}
  """
  @spec server_state_from_tag(non_neg_integer()) :: {:ok, server_state()} | :error
  def server_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_server_state, tag)}
  end

  def server_state_from_tag(_tag), do: :error

  @doc """
  Encode a `ServerState` to the C-ABI tag value.
  """
  @spec server_state_to_tag(server_state()) :: non_neg_integer()
  def server_state_to_tag(val) when is_map_key(@server_state_tags, val) do
    Map.fetch!(@server_state_tags, val)
  end

  @doc """
  All `ServerState` variants in tag order.
  """
  @spec all_server_states() :: [server_state()]
  def all_server_states, do: [:idle, :active, :merging, :signing, :shutdown]

end
