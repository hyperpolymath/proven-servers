# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Ldp do
  @moduledoc """
  LDP types for the proven-servers ABI.
  
  Formally verified Linked Data Platform types (W3C LDP).
  Mirrors the Idris2 module `LdpABI.Types`.
  
  - `ContainerType` -- LDP container types.
  - `LdpResourceType` -- LDP resource types.
  - `Preference` -- LDP prefer header values.
  - `InteractionModel` -- LDP interaction models.
  - `ConstraintViolation` -- LDP constraint violations.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # ContainerType (tags 0-2)
  # ===========================================================================

  @typedoc """
  ContainerType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type container_type :: :basic | :direct | :indirect

  @container_type_tags %{
    basic: 0,
    direct: 1,
    indirect: 2,
  }

  @tag_to_container_type Map.new(@container_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ContainerType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ldp.container_type_from_tag(0)
      {:ok, :basic}
  """
  @spec container_type_from_tag(non_neg_integer()) :: {:ok, container_type()} | :error
  def container_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_container_type, tag)}
  end

  def container_type_from_tag(_tag), do: :error

  @doc """
  Encode a `ContainerType` to the C-ABI tag value.
  """
  @spec container_type_to_tag(container_type()) :: non_neg_integer()
  def container_type_to_tag(val) when is_map_key(@container_type_tags, val) do
    Map.fetch!(@container_type_tags, val)
  end

  @doc """
  All `ContainerType` variants in tag order.
  """
  @spec all_container_types() :: [container_type()]
  def all_container_types, do: [:basic, :direct, :indirect]

  # ===========================================================================
  # LdpResourceType (tags 0-2)
  # ===========================================================================

  @typedoc """
  LdpResourceType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type ldp_resource_type :: :rdf_source | :non_rdf_source | :container

  @ldp_resource_type_tags %{
    rdf_source: 0,
    non_rdf_source: 1,
    container: 2,
  }

  @tag_to_ldp_resource_type Map.new(@ldp_resource_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `LdpResourceType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ldp.ldp_resource_type_from_tag(0)
      {:ok, :rdf_source}
  """
  @spec ldp_resource_type_from_tag(non_neg_integer()) :: {:ok, ldp_resource_type()} | :error
  def ldp_resource_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_ldp_resource_type, tag)}
  end

  def ldp_resource_type_from_tag(_tag), do: :error

  @doc """
  Encode a `LdpResourceType` to the C-ABI tag value.
  """
  @spec ldp_resource_type_to_tag(ldp_resource_type()) :: non_neg_integer()
  def ldp_resource_type_to_tag(val) when is_map_key(@ldp_resource_type_tags, val) do
    Map.fetch!(@ldp_resource_type_tags, val)
  end

  @doc """
  All `LdpResourceType` variants in tag order.
  """
  @spec all_ldp_resource_types() :: [ldp_resource_type()]
  def all_ldp_resource_types, do: [:rdf_source, :non_rdf_source, :container]

  # ===========================================================================
  # Preference (tags 0-4)
  # ===========================================================================

  @typedoc """
  Preference types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type preference ::
          :minimal_container
          | :include_containment
          | :include_membership
          | :omit_containment
          | :omit_membership

  @preference_tags %{
    minimal_container: 0,
    include_containment: 1,
    include_membership: 2,
    omit_containment: 3,
    omit_membership: 4,
  }

  @tag_to_preference Map.new(@preference_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Preference` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ldp.preference_from_tag(0)
      {:ok, :minimal_container}
  """
  @spec preference_from_tag(non_neg_integer()) :: {:ok, preference()} | :error
  def preference_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_preference, tag)}
  end

  def preference_from_tag(_tag), do: :error

  @doc """
  Encode a `Preference` to the C-ABI tag value.
  """
  @spec preference_to_tag(preference()) :: non_neg_integer()
  def preference_to_tag(val) when is_map_key(@preference_tags, val) do
    Map.fetch!(@preference_tags, val)
  end

  @doc """
  All `Preference` variants in tag order.
  """
  @spec all_preferences() :: [preference()]
  def all_preferences do
    [
      :minimal_container, :include_containment, :include_membership,
      :omit_containment, :omit_membership
    ]
  end

  # ===========================================================================
  # InteractionModel (tags 0-4)
  # ===========================================================================

  @typedoc """
  InteractionModel types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type interaction_model ::
          :ldpr
          | :ldpc
          | :ldp_basic_container
          | :ldp_direct_container
          | :ldp_indirect_container

  @interaction_model_tags %{
    ldpr: 0,
    ldpc: 1,
    ldp_basic_container: 2,
    ldp_direct_container: 3,
    ldp_indirect_container: 4,
  }

  @tag_to_interaction_model Map.new(@interaction_model_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `InteractionModel` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ldp.interaction_model_from_tag(0)
      {:ok, :ldpr}
  """
  @spec interaction_model_from_tag(non_neg_integer()) :: {:ok, interaction_model()} | :error
  def interaction_model_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_interaction_model, tag)}
  end

  def interaction_model_from_tag(_tag), do: :error

  @doc """
  Encode a `InteractionModel` to the C-ABI tag value.
  """
  @spec interaction_model_to_tag(interaction_model()) :: non_neg_integer()
  def interaction_model_to_tag(val) when is_map_key(@interaction_model_tags, val) do
    Map.fetch!(@interaction_model_tags, val)
  end

  @doc """
  All `InteractionModel` variants in tag order.
  """
  @spec all_interaction_models() :: [interaction_model()]
  def all_interaction_models do
    [
      :ldpr, :ldpc, :ldp_basic_container, :ldp_direct_container, :ldp_indirect_container,
    ]
  end

  # ===========================================================================
  # ConstraintViolation (tags 0-3)
  # ===========================================================================

  @typedoc """
  ConstraintViolation types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type constraint_violation ::
          :membership_constant
          | :contains_triples_modified
          | :server_managed
          | :type_conflict

  @constraint_violation_tags %{
    membership_constant: 0,
    contains_triples_modified: 1,
    server_managed: 2,
    type_conflict: 3,
  }

  @tag_to_constraint_violation Map.new(@constraint_violation_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ConstraintViolation` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ldp.constraint_violation_from_tag(0)
      {:ok, :membership_constant}
  """
  @spec constraint_violation_from_tag(non_neg_integer()) :: {:ok, constraint_violation()} | :error
  def constraint_violation_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_constraint_violation, tag)}
  end

  def constraint_violation_from_tag(_tag), do: :error

  @doc """
  Encode a `ConstraintViolation` to the C-ABI tag value.
  """
  @spec constraint_violation_to_tag(constraint_violation()) :: non_neg_integer()
  def constraint_violation_to_tag(val) when is_map_key(@constraint_violation_tags, val) do
    Map.fetch!(@constraint_violation_tags, val)
  end

  @doc """
  All `ConstraintViolation` variants in tag order.
  """
  @spec all_constraint_violations() :: [constraint_violation()]
  def all_constraint_violations do
    [
      :membership_constant, :contains_triples_modified, :server_managed,
      :type_conflict
    ]
  end

end
