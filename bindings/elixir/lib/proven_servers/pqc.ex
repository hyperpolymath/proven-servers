# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Pqc do
  @moduledoc """
  Post-Quantum Cryptography types for the proven-servers ABI.
  
  Formally verified PQC types.
  Mirrors the Idris2 module `PqcABI.Types`.
  
  - `PqcAlgorithm` -- Post-quantum cryptographic algorithms.
  - `NistLevel` -- NIST security levels (1-5).
  - `Operation` -- PQC cryptographic operations.
  - `HybridMode` -- Classical/PQC hybrid modes.
  - `AlgorithmCategory` -- PQC algorithm categories.
  - `KeyState` -- PQC key lifecycle states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # PqcAlgorithm (tags 0-7)
  # ===========================================================================

  @typedoc """
  PqcAlgorithm types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type pqc_algorithm ::
          :crystals_kyber
          | :crystals_dilithium
          | :falcon
          | :sphincs_plus
          | :classic_mceliece
          | :bike
          | :hqc
          | :frodokem

  @pqc_algorithm_tags %{
    crystals_kyber: 0,
    crystals_dilithium: 1,
    falcon: 2,
    sphincs_plus: 3,
    classic_mceliece: 4,
    bike: 5,
    hqc: 6,
    frodokem: 7,
  }

  @tag_to_pqc_algorithm Map.new(@pqc_algorithm_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PqcAlgorithm` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Pqc.pqc_algorithm_from_tag(0)
      {:ok, :crystals_kyber}
  """
  @spec pqc_algorithm_from_tag(non_neg_integer()) :: {:ok, pqc_algorithm()} | :error
  def pqc_algorithm_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_pqc_algorithm, tag)}
  end

  def pqc_algorithm_from_tag(_tag), do: :error

  @doc """
  Encode a `PqcAlgorithm` to the C-ABI tag value.
  """
  @spec pqc_algorithm_to_tag(pqc_algorithm()) :: non_neg_integer()
  def pqc_algorithm_to_tag(val) when is_map_key(@pqc_algorithm_tags, val) do
    Map.fetch!(@pqc_algorithm_tags, val)
  end

  @doc """
  All `PqcAlgorithm` variants in tag order.
  """
  @spec all_pqc_algorithms() :: [pqc_algorithm()]
  def all_pqc_algorithms do
    [
      :crystals_kyber, :crystals_dilithium, :falcon, :sphincs_plus, :classic_mceliece,
      :bike, :hqc, :frodokem
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this is a KEM (key encapsulation) algorithm.
  """
  @spec is_kem?(pqc_algorithm()) :: boolean()
  def is_kem?(val) when val in [:crystals_kyber, :classic_mceliece, :bike, :hqc, :frodokem], do: true
  def is_kem?(_val), do: false

  @doc """
  Whether this is a signature algorithm.
  """
  @spec is_signature?(pqc_algorithm()) :: boolean()
  def is_signature?(val) when val in [:crystals_dilithium, :falcon, :sphincs_plus], do: true
  def is_signature?(_val), do: false

  # ===========================================================================
  # NistLevel (tags 0-4)
  # ===========================================================================

  @typedoc """
  NistLevel types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type nist_level :: :nist1 | :nist2 | :nist3 | :nist4 | :nist5

  @nist_level_tags %{
    nist1: 0,
    nist2: 1,
    nist3: 2,
    nist4: 3,
    nist5: 4,
  }

  @tag_to_nist_level Map.new(@nist_level_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NistLevel` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Pqc.nist_level_from_tag(0)
      {:ok, :nist1}
  """
  @spec nist_level_from_tag(non_neg_integer()) :: {:ok, nist_level()} | :error
  def nist_level_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_nist_level, tag)}
  end

  def nist_level_from_tag(_tag), do: :error

  @doc """
  Encode a `NistLevel` to the C-ABI tag value.
  """
  @spec nist_level_to_tag(nist_level()) :: non_neg_integer()
  def nist_level_to_tag(val) when is_map_key(@nist_level_tags, val) do
    Map.fetch!(@nist_level_tags, val)
  end

  @doc """
  All `NistLevel` variants in tag order.
  """
  @spec all_nist_levels() :: [nist_level()]
  def all_nist_levels, do: [:nist1, :nist2, :nist3, :nist4, :nist5]

  # ===========================================================================
  # Operation (tags 0-4)
  # ===========================================================================

  @typedoc """
  Operation types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type operation :: :keygen | :encapsulate | :decapsulate | :sign | :verify

  @operation_tags %{
    keygen: 0,
    encapsulate: 1,
    decapsulate: 2,
    sign: 3,
    verify: 4,
  }

  @tag_to_operation Map.new(@operation_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Operation` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Pqc.operation_from_tag(0)
      {:ok, :keygen}
  """
  @spec operation_from_tag(non_neg_integer()) :: {:ok, operation()} | :error
  def operation_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_operation, tag)}
  end

  def operation_from_tag(_tag), do: :error

  @doc """
  Encode a `Operation` to the C-ABI tag value.
  """
  @spec operation_to_tag(operation()) :: non_neg_integer()
  def operation_to_tag(val) when is_map_key(@operation_tags, val) do
    Map.fetch!(@operation_tags, val)
  end

  @doc """
  All `Operation` variants in tag order.
  """
  @spec all_operations() :: [operation()]
  def all_operations, do: [:keygen, :encapsulate, :decapsulate, :sign, :verify]

  # ===========================================================================
  # HybridMode (tags 0-2)
  # ===========================================================================

  @typedoc """
  HybridMode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type hybrid_mode :: :classical_only | :pqc_only | :hybrid

  @hybrid_mode_tags %{
    classical_only: 0,
    pqc_only: 1,
    hybrid: 2,
  }

  @tag_to_hybrid_mode Map.new(@hybrid_mode_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `HybridMode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Pqc.hybrid_mode_from_tag(0)
      {:ok, :classical_only}
  """
  @spec hybrid_mode_from_tag(non_neg_integer()) :: {:ok, hybrid_mode()} | :error
  def hybrid_mode_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_hybrid_mode, tag)}
  end

  def hybrid_mode_from_tag(_tag), do: :error

  @doc """
  Encode a `HybridMode` to the C-ABI tag value.
  """
  @spec hybrid_mode_to_tag(hybrid_mode()) :: non_neg_integer()
  def hybrid_mode_to_tag(val) when is_map_key(@hybrid_mode_tags, val) do
    Map.fetch!(@hybrid_mode_tags, val)
  end

  @doc """
  All `HybridMode` variants in tag order.
  """
  @spec all_hybrid_modes() :: [hybrid_mode()]
  def all_hybrid_modes, do: [:classical_only, :pqc_only, :hybrid]

  # ===========================================================================
  # AlgorithmCategory (tags 0-1)
  # ===========================================================================

  @typedoc """
  AlgorithmCategory types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type algorithm_category :: :kem | :signature

  @algorithm_category_tags %{
    kem: 0,
    signature: 1,
  }

  @tag_to_algorithm_category Map.new(@algorithm_category_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AlgorithmCategory` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Pqc.algorithm_category_from_tag(0)
      {:ok, :kem}
  """
  @spec algorithm_category_from_tag(non_neg_integer()) :: {:ok, algorithm_category()} | :error
  def algorithm_category_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_algorithm_category, tag)}
  end

  def algorithm_category_from_tag(_tag), do: :error

  @doc """
  Encode a `AlgorithmCategory` to the C-ABI tag value.
  """
  @spec algorithm_category_to_tag(algorithm_category()) :: non_neg_integer()
  def algorithm_category_to_tag(val) when is_map_key(@algorithm_category_tags, val) do
    Map.fetch!(@algorithm_category_tags, val)
  end

  @doc """
  All `AlgorithmCategory` variants in tag order.
  """
  @spec all_algorithm_categorys() :: [algorithm_category()]
  def all_algorithm_categorys, do: [:kem, :signature]

  # ===========================================================================
  # KeyState (tags 0-5)
  # ===========================================================================

  @typedoc """
  KeyState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type key_state :: :empty | :generating | :generated | :active | :expired | :compromised

  @key_state_tags %{
    empty: 0,
    generating: 1,
    generated: 2,
    active: 3,
    expired: 4,
    compromised: 5,
  }

  @tag_to_key_state Map.new(@key_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `KeyState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Pqc.key_state_from_tag(0)
      {:ok, :empty}
  """
  @spec key_state_from_tag(non_neg_integer()) :: {:ok, key_state()} | :error
  def key_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_key_state, tag)}
  end

  def key_state_from_tag(_tag), do: :error

  @doc """
  Encode a `KeyState` to the C-ABI tag value.
  """
  @spec key_state_to_tag(key_state()) :: non_neg_integer()
  def key_state_to_tag(val) when is_map_key(@key_state_tags, val) do
    Map.fetch!(@key_state_tags, val)
  end

  @doc """
  All `KeyState` variants in tag order.
  """
  @spec all_key_states() :: [key_state()]
  def all_key_states, do: [:empty, :generating, :generated, :active, :expired, :compromised]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the key can be used.
  """
  @spec is_usable?(key_state()) :: boolean()
  def is_usable?(val) when val in [:active], do: true
  def is_usable?(_val), do: false

end
