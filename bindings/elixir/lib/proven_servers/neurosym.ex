# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Neurosym do
  @moduledoc """
  Neurosymbolic Engine types for the proven-servers ABI.
  
  Formally verified neurosymbolic integration types.
  Mirrors the Idris2 module `NeurosymABI.Types`.
  
  - `InferenceMode` -- Neurosymbolic inference modes.
  - `SymbolicOp` -- Symbolic reasoning operations.
  - `NeuralOp` -- Neural inference operations.
  - `FusionStrategy` -- Neural-symbolic fusion strategies.
  - `ConfidenceLevel` -- Inference confidence levels.
  - `KnowledgeType` -- Knowledge entry types.
  - `NeurosymState` -- Neurosymbolic engine states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # InferenceMode (tags 0-3)
  # ===========================================================================

  @typedoc """
  InferenceMode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type inference_mode :: :neural | :symbolic | :hybrid | :cascade

  @inference_mode_tags %{
    neural: 0,
    symbolic: 1,
    hybrid: 2,
    cascade: 3,
  }

  @tag_to_inference_mode Map.new(@inference_mode_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `InferenceMode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Neurosym.inference_mode_from_tag(0)
      {:ok, :neural}
  """
  @spec inference_mode_from_tag(non_neg_integer()) :: {:ok, inference_mode()} | :error
  def inference_mode_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_inference_mode, tag)}
  end

  def inference_mode_from_tag(_tag), do: :error

  @doc """
  Encode a `InferenceMode` to the C-ABI tag value.
  """
  @spec inference_mode_to_tag(inference_mode()) :: non_neg_integer()
  def inference_mode_to_tag(val) when is_map_key(@inference_mode_tags, val) do
    Map.fetch!(@inference_mode_tags, val)
  end

  @doc """
  All `InferenceMode` variants in tag order.
  """
  @spec all_inference_modes() :: [inference_mode()]
  def all_inference_modes, do: [:neural, :symbolic, :hybrid, :cascade]

  # ===========================================================================
  # SymbolicOp (tags 0-5)
  # ===========================================================================

  @typedoc """
  SymbolicOp types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type symbolic_op :: :unify | :resolve | :rewrite | :prove | :search | :constrain

  @symbolic_op_tags %{
    unify: 0,
    resolve: 1,
    rewrite: 2,
    prove: 3,
    search: 4,
    constrain: 5,
  }

  @tag_to_symbolic_op Map.new(@symbolic_op_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SymbolicOp` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Neurosym.symbolic_op_from_tag(0)
      {:ok, :unify}
  """
  @spec symbolic_op_from_tag(non_neg_integer()) :: {:ok, symbolic_op()} | :error
  def symbolic_op_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_symbolic_op, tag)}
  end

  def symbolic_op_from_tag(_tag), do: :error

  @doc """
  Encode a `SymbolicOp` to the C-ABI tag value.
  """
  @spec symbolic_op_to_tag(symbolic_op()) :: non_neg_integer()
  def symbolic_op_to_tag(val) when is_map_key(@symbolic_op_tags, val) do
    Map.fetch!(@symbolic_op_tags, val)
  end

  @doc """
  All `SymbolicOp` variants in tag order.
  """
  @spec all_symbolic_ops() :: [symbolic_op()]
  def all_symbolic_ops, do: [:unify, :resolve, :rewrite, :prove, :search, :constrain]

  # ===========================================================================
  # NeuralOp (tags 0-5)
  # ===========================================================================

  @typedoc """
  NeuralOp types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type neural_op :: :embed | :classify | :generate | :attend | :retrieve | :finetune

  @neural_op_tags %{
    embed: 0,
    classify: 1,
    generate: 2,
    attend: 3,
    retrieve: 4,
    finetune: 5,
  }

  @tag_to_neural_op Map.new(@neural_op_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NeuralOp` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Neurosym.neural_op_from_tag(0)
      {:ok, :embed}
  """
  @spec neural_op_from_tag(non_neg_integer()) :: {:ok, neural_op()} | :error
  def neural_op_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_neural_op, tag)}
  end

  def neural_op_from_tag(_tag), do: :error

  @doc """
  Encode a `NeuralOp` to the C-ABI tag value.
  """
  @spec neural_op_to_tag(neural_op()) :: non_neg_integer()
  def neural_op_to_tag(val) when is_map_key(@neural_op_tags, val) do
    Map.fetch!(@neural_op_tags, val)
  end

  @doc """
  All `NeuralOp` variants in tag order.
  """
  @spec all_neural_ops() :: [neural_op()]
  def all_neural_ops, do: [:embed, :classify, :generate, :attend, :retrieve, :finetune]

  # ===========================================================================
  # FusionStrategy (tags 0-4)
  # ===========================================================================

  @typedoc """
  FusionStrategy types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type fusion_strategy ::
          :neural_then_symbolic
          | :symbolic_then_neural
          | :parallel
          | :iterative
          | :gated

  @fusion_strategy_tags %{
    neural_then_symbolic: 0,
    symbolic_then_neural: 1,
    parallel: 2,
    iterative: 3,
    gated: 4,
  }

  @tag_to_fusion_strategy Map.new(@fusion_strategy_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `FusionStrategy` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Neurosym.fusion_strategy_from_tag(0)
      {:ok, :neural_then_symbolic}
  """
  @spec fusion_strategy_from_tag(non_neg_integer()) :: {:ok, fusion_strategy()} | :error
  def fusion_strategy_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_fusion_strategy, tag)}
  end

  def fusion_strategy_from_tag(_tag), do: :error

  @doc """
  Encode a `FusionStrategy` to the C-ABI tag value.
  """
  @spec fusion_strategy_to_tag(fusion_strategy()) :: non_neg_integer()
  def fusion_strategy_to_tag(val) when is_map_key(@fusion_strategy_tags, val) do
    Map.fetch!(@fusion_strategy_tags, val)
  end

  @doc """
  All `FusionStrategy` variants in tag order.
  """
  @spec all_fusion_strategys() :: [fusion_strategy()]
  def all_fusion_strategys do
    [
      :neural_then_symbolic, :symbolic_then_neural, :parallel, :iterative,
      :gated
    ]
  end

  # ===========================================================================
  # ConfidenceLevel (tags 0-5)
  # ===========================================================================

  @typedoc """
  ConfidenceLevel types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type confidence_level ::
          :proven
          | :high_confidence
          | :moderate
          | :low_confidence
          | :uncertain
          | :contradicted

  @confidence_level_tags %{
    proven: 0,
    high_confidence: 1,
    moderate: 2,
    low_confidence: 3,
    uncertain: 4,
    contradicted: 5,
  }

  @tag_to_confidence_level Map.new(@confidence_level_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ConfidenceLevel` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Neurosym.confidence_level_from_tag(0)
      {:ok, :proven}
  """
  @spec confidence_level_from_tag(non_neg_integer()) :: {:ok, confidence_level()} | :error
  def confidence_level_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_confidence_level, tag)}
  end

  def confidence_level_from_tag(_tag), do: :error

  @doc """
  Encode a `ConfidenceLevel` to the C-ABI tag value.
  """
  @spec confidence_level_to_tag(confidence_level()) :: non_neg_integer()
  def confidence_level_to_tag(val) when is_map_key(@confidence_level_tags, val) do
    Map.fetch!(@confidence_level_tags, val)
  end

  @doc """
  All `ConfidenceLevel` variants in tag order.
  """
  @spec all_confidence_levels() :: [confidence_level()]
  def all_confidence_levels do
    [
      :proven, :high_confidence, :moderate, :low_confidence, :uncertain,
      :contradicted
    ]
  end

  # ===========================================================================
  # KnowledgeType (tags 0-5)
  # ===========================================================================

  @typedoc """
  KnowledgeType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type knowledge_type :: :axiom | :learned | :inferred | :grounded | :hypothetical | :retracted

  @knowledge_type_tags %{
    axiom: 0,
    learned: 1,
    inferred: 2,
    grounded: 3,
    hypothetical: 4,
    retracted: 5,
  }

  @tag_to_knowledge_type Map.new(@knowledge_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `KnowledgeType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Neurosym.knowledge_type_from_tag(0)
      {:ok, :axiom}
  """
  @spec knowledge_type_from_tag(non_neg_integer()) :: {:ok, knowledge_type()} | :error
  def knowledge_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_knowledge_type, tag)}
  end

  def knowledge_type_from_tag(_tag), do: :error

  @doc """
  Encode a `KnowledgeType` to the C-ABI tag value.
  """
  @spec knowledge_type_to_tag(knowledge_type()) :: non_neg_integer()
  def knowledge_type_to_tag(val) when is_map_key(@knowledge_type_tags, val) do
    Map.fetch!(@knowledge_type_tags, val)
  end

  @doc """
  All `KnowledgeType` variants in tag order.
  """
  @spec all_knowledge_types() :: [knowledge_type()]
  def all_knowledge_types, do: [:axiom, :learned, :inferred, :grounded, :hypothetical, :retracted]

  # ===========================================================================
  # NeurosymState (tags 0-5)
  # ===========================================================================

  @typedoc """
  NeurosymState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type neurosym_state :: :idle | :ready | :inferring | :reasoning | :fusing | :shutdown

  @neurosym_state_tags %{
    idle: 0,
    ready: 1,
    inferring: 2,
    reasoning: 3,
    fusing: 4,
    shutdown: 5,
  }

  @tag_to_neurosym_state Map.new(@neurosym_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NeurosymState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Neurosym.neurosym_state_from_tag(0)
      {:ok, :idle}
  """
  @spec neurosym_state_from_tag(non_neg_integer()) :: {:ok, neurosym_state()} | :error
  def neurosym_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_neurosym_state, tag)}
  end

  def neurosym_state_from_tag(_tag), do: :error

  @doc """
  Encode a `NeurosymState` to the C-ABI tag value.
  """
  @spec neurosym_state_to_tag(neurosym_state()) :: non_neg_integer()
  def neurosym_state_to_tag(val) when is_map_key(@neurosym_state_tags, val) do
    Map.fetch!(@neurosym_state_tags, val)
  end

  @doc """
  All `NeurosymState` variants in tag order.
  """
  @spec all_neurosym_states() :: [neurosym_state()]
  def all_neurosym_states, do: [:idle, :ready, :inferring, :reasoning, :fusing, :shutdown]

end
