# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Nesy do
  @moduledoc """
  NeSy types for the proven-servers ABI.
  
  Formally verified neurosymbolic AI types.
  Mirrors the Idris2 module `NesyABI.Types`.
  
  - `ReasoningMode` -- Neurosymbolic reasoning modes.
  - `ProofStatus` -- Proof verification status.
  - `ConstraintKind` -- Type constraint kinds.
  - `NeuralBackend` -- Neural inference backend providers.
  - `Confidence` -- Inference confidence levels.
  - `DriftKind` -- Knowledge drift types.
  - `NeSyState` -- NeSy engine states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # ReasoningMode (tags 0-5)
  # ===========================================================================

  @typedoc """
  ReasoningMode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type reasoning_mode ::
          :symbolic
          | :neural
          | :sym_to_neural
          | :neural_to_sym
          | :ensemble
          | :cascade

  @reasoning_mode_tags %{
    symbolic: 0,
    neural: 1,
    sym_to_neural: 2,
    neural_to_sym: 3,
    ensemble: 4,
    cascade: 5,
  }

  @tag_to_reasoning_mode Map.new(@reasoning_mode_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ReasoningMode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Nesy.reasoning_mode_from_tag(0)
      {:ok, :symbolic}
  """
  @spec reasoning_mode_from_tag(non_neg_integer()) :: {:ok, reasoning_mode()} | :error
  def reasoning_mode_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_reasoning_mode, tag)}
  end

  def reasoning_mode_from_tag(_tag), do: :error

  @doc """
  Encode a `ReasoningMode` to the C-ABI tag value.
  """
  @spec reasoning_mode_to_tag(reasoning_mode()) :: non_neg_integer()
  def reasoning_mode_to_tag(val) when is_map_key(@reasoning_mode_tags, val) do
    Map.fetch!(@reasoning_mode_tags, val)
  end

  @doc """
  All `ReasoningMode` variants in tag order.
  """
  @spec all_reasoning_modes() :: [reasoning_mode()]
  def all_reasoning_modes do
    [
      :symbolic, :neural, :sym_to_neural, :neural_to_sym, :ensemble,
      :cascade
    ]
  end

  # ===========================================================================
  # ProofStatus (tags 0-5)
  # ===========================================================================

  @typedoc """
  ProofStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type proof_status :: :pending | :attempting | :proved | :failed | :assumed | :vacuous

  @proof_status_tags %{
    pending: 0,
    attempting: 1,
    proved: 2,
    failed: 3,
    assumed: 4,
    vacuous: 5,
  }

  @tag_to_proof_status Map.new(@proof_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ProofStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Nesy.proof_status_from_tag(0)
      {:ok, :pending}
  """
  @spec proof_status_from_tag(non_neg_integer()) :: {:ok, proof_status()} | :error
  def proof_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_proof_status, tag)}
  end

  def proof_status_from_tag(_tag), do: :error

  @doc """
  Encode a `ProofStatus` to the C-ABI tag value.
  """
  @spec proof_status_to_tag(proof_status()) :: non_neg_integer()
  def proof_status_to_tag(val) when is_map_key(@proof_status_tags, val) do
    Map.fetch!(@proof_status_tags, val)
  end

  @doc """
  All `ProofStatus` variants in tag order.
  """
  @spec all_proof_statuss() :: [proof_status()]
  def all_proof_statuss, do: [:pending, :attempting, :proved, :failed, :assumed, :vacuous]

  # ===========================================================================
  # ConstraintKind (tags 0-7)
  # ===========================================================================

  @typedoc """
  ConstraintKind types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type constraint_kind ::
          :type_equality
          | :subtype
          | :linearity
          | :termination
          | :totality
          | :invariant
          | :refinement
          | :dependent_index

  @constraint_kind_tags %{
    type_equality: 0,
    subtype: 1,
    linearity: 2,
    termination: 3,
    totality: 4,
    invariant: 5,
    refinement: 6,
    dependent_index: 7,
  }

  @tag_to_constraint_kind Map.new(@constraint_kind_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ConstraintKind` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Nesy.constraint_kind_from_tag(0)
      {:ok, :type_equality}
  """
  @spec constraint_kind_from_tag(non_neg_integer()) :: {:ok, constraint_kind()} | :error
  def constraint_kind_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_constraint_kind, tag)}
  end

  def constraint_kind_from_tag(_tag), do: :error

  @doc """
  Encode a `ConstraintKind` to the C-ABI tag value.
  """
  @spec constraint_kind_to_tag(constraint_kind()) :: non_neg_integer()
  def constraint_kind_to_tag(val) when is_map_key(@constraint_kind_tags, val) do
    Map.fetch!(@constraint_kind_tags, val)
  end

  @doc """
  All `ConstraintKind` variants in tag order.
  """
  @spec all_constraint_kinds() :: [constraint_kind()]
  def all_constraint_kinds do
    [
      :type_equality, :subtype, :linearity, :termination, :totality,
      :invariant, :refinement, :dependent_index
    ]
  end

  # ===========================================================================
  # NeuralBackend (tags 0-5)
  # ===========================================================================

  @typedoc """
  NeuralBackend types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type neural_backend :: :local_model | :claude | :gemini | :mistral | :gpt | :custom_neural

  @neural_backend_tags %{
    local_model: 0,
    claude: 1,
    gemini: 2,
    mistral: 3,
    gpt: 4,
    custom_neural: 5,
  }

  @tag_to_neural_backend Map.new(@neural_backend_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NeuralBackend` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Nesy.neural_backend_from_tag(0)
      {:ok, :local_model}
  """
  @spec neural_backend_from_tag(non_neg_integer()) :: {:ok, neural_backend()} | :error
  def neural_backend_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_neural_backend, tag)}
  end

  def neural_backend_from_tag(_tag), do: :error

  @doc """
  Encode a `NeuralBackend` to the C-ABI tag value.
  """
  @spec neural_backend_to_tag(neural_backend()) :: non_neg_integer()
  def neural_backend_to_tag(val) when is_map_key(@neural_backend_tags, val) do
    Map.fetch!(@neural_backend_tags, val)
  end

  @doc """
  All `NeuralBackend` variants in tag order.
  """
  @spec all_neural_backends() :: [neural_backend()]
  def all_neural_backends, do: [:local_model, :claude, :gemini, :mistral, :gpt, :custom_neural]

  # ===========================================================================
  # Confidence (tags 0-5)
  # ===========================================================================

  @typedoc """
  Confidence types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type confidence ::
          :verified
          | :high_neural
          | :medium_neural
          | :low_neural
          | :unknown
          | :contradicted

  @confidence_tags %{
    verified: 0,
    high_neural: 1,
    medium_neural: 2,
    low_neural: 3,
    unknown: 4,
    contradicted: 5,
  }

  @tag_to_confidence Map.new(@confidence_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Confidence` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Nesy.confidence_from_tag(0)
      {:ok, :verified}
  """
  @spec confidence_from_tag(non_neg_integer()) :: {:ok, confidence()} | :error
  def confidence_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_confidence, tag)}
  end

  def confidence_from_tag(_tag), do: :error

  @doc """
  Encode a `Confidence` to the C-ABI tag value.
  """
  @spec confidence_to_tag(confidence()) :: non_neg_integer()
  def confidence_to_tag(val) when is_map_key(@confidence_tags, val) do
    Map.fetch!(@confidence_tags, val)
  end

  @doc """
  All `Confidence` variants in tag order.
  """
  @spec all_confidences() :: [confidence()]
  def all_confidences do
    [
      :verified, :high_neural, :medium_neural, :low_neural, :unknown,
      :contradicted
    ]
  end

  # ===========================================================================
  # DriftKind (tags 0-5)
  # ===========================================================================

  @typedoc """
  DriftKind types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type drift_kind ::
          :no_drift
          | :semantic_drift
          | :confidence_drift
          | :factual_drift
          | :temporal_drift
          | :catastrophic_drift

  @drift_kind_tags %{
    no_drift: 0,
    semantic_drift: 1,
    confidence_drift: 2,
    factual_drift: 3,
    temporal_drift: 4,
    catastrophic_drift: 5,
  }

  @tag_to_drift_kind Map.new(@drift_kind_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DriftKind` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Nesy.drift_kind_from_tag(0)
      {:ok, :no_drift}
  """
  @spec drift_kind_from_tag(non_neg_integer()) :: {:ok, drift_kind()} | :error
  def drift_kind_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_drift_kind, tag)}
  end

  def drift_kind_from_tag(_tag), do: :error

  @doc """
  Encode a `DriftKind` to the C-ABI tag value.
  """
  @spec drift_kind_to_tag(drift_kind()) :: non_neg_integer()
  def drift_kind_to_tag(val) when is_map_key(@drift_kind_tags, val) do
    Map.fetch!(@drift_kind_tags, val)
  end

  @doc """
  All `DriftKind` variants in tag order.
  """
  @spec all_drift_kinds() :: [drift_kind()]
  def all_drift_kinds do
    [
      :no_drift, :semantic_drift, :confidence_drift, :factual_drift,
      :temporal_drift, :catastrophic_drift
    ]
  end

  # ===========================================================================
  # NeSyState (tags 0-5)
  # ===========================================================================

  @typedoc """
  NeSyState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type ne_sy_state :: :idle | :ready | :reasoning | :verifying | :drift | :shutdown

  @ne_sy_state_tags %{
    idle: 0,
    ready: 1,
    reasoning: 2,
    verifying: 3,
    drift: 4,
    shutdown: 5,
  }

  @tag_to_ne_sy_state Map.new(@ne_sy_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NeSyState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Nesy.ne_sy_state_from_tag(0)
      {:ok, :idle}
  """
  @spec ne_sy_state_from_tag(non_neg_integer()) :: {:ok, ne_sy_state()} | :error
  def ne_sy_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_ne_sy_state, tag)}
  end

  def ne_sy_state_from_tag(_tag), do: :error

  @doc """
  Encode a `NeSyState` to the C-ABI tag value.
  """
  @spec ne_sy_state_to_tag(ne_sy_state()) :: non_neg_integer()
  def ne_sy_state_to_tag(val) when is_map_key(@ne_sy_state_tags, val) do
    Map.fetch!(@ne_sy_state_tags, val)
  end

  @doc """
  All `NeSyState` variants in tag order.
  """
  @spec all_ne_sy_states() :: [ne_sy_state()]
  def all_ne_sy_states, do: [:idle, :ready, :reasoning, :verifying, :drift, :shutdown]

end
