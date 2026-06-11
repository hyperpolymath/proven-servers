# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Federation do
  @moduledoc """
  Federation types for the proven-servers ABI.
  
  Formally verified ActivityPub/federation types.
  Mirrors the Idris2 module `FederationABI.Types`.
  
  - `ActivityType` -- ActivityPub activity types.
  - `ActorType` -- ActivityPub actor types.
  - `DeliveryStatus` -- Federation delivery statuses.
  - `TrustLevel` -- Federation trust levels.
  - `ObjectType` -- ActivityPub object types.
  - `ServerState` -- Federation server states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # ActivityType (tags 0-10)
  # ===========================================================================

  @typedoc """
  ActivityType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type activity_type ::
          :create
          | :update
          | :delete
          | :follow
          | :accept
          | :reject
          | :announce
          | :like
          | :undo
          | :block
          | :flag

  @activity_type_tags %{
    create: 0,
    update: 1,
    delete: 2,
    follow: 3,
    accept: 4,
    reject: 5,
    announce: 6,
    like: 7,
    undo: 8,
    block: 9,
    flag: 10,
  }

  @tag_to_activity_type Map.new(@activity_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ActivityType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..10, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Federation.activity_type_from_tag(0)
      {:ok, :create}
  """
  @spec activity_type_from_tag(non_neg_integer()) :: {:ok, activity_type()} | :error
  def activity_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 10 do
    {:ok, Map.fetch!(@tag_to_activity_type, tag)}
  end

  def activity_type_from_tag(_tag), do: :error

  @doc """
  Encode a `ActivityType` to the C-ABI tag value.
  """
  @spec activity_type_to_tag(activity_type()) :: non_neg_integer()
  def activity_type_to_tag(val) when is_map_key(@activity_type_tags, val) do
    Map.fetch!(@activity_type_tags, val)
  end

  @doc """
  All `ActivityType` variants in tag order.
  """
  @spec all_activity_types() :: [activity_type()]
  def all_activity_types do
    [
      :create, :update, :delete, :follow, :accept, :reject, :announce,
      :like, :undo, :block, :flag
    ]
  end

  # ===========================================================================
  # ActorType (tags 0-4)
  # ===========================================================================

  @typedoc """
  ActorType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type actor_type :: :person | :service | :application | :group | :organization

  @actor_type_tags %{
    person: 0,
    service: 1,
    application: 2,
    group: 3,
    organization: 4,
  }

  @tag_to_actor_type Map.new(@actor_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ActorType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Federation.actor_type_from_tag(0)
      {:ok, :person}
  """
  @spec actor_type_from_tag(non_neg_integer()) :: {:ok, actor_type()} | :error
  def actor_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_actor_type, tag)}
  end

  def actor_type_from_tag(_tag), do: :error

  @doc """
  Encode a `ActorType` to the C-ABI tag value.
  """
  @spec actor_type_to_tag(actor_type()) :: non_neg_integer()
  def actor_type_to_tag(val) when is_map_key(@actor_type_tags, val) do
    Map.fetch!(@actor_type_tags, val)
  end

  @doc """
  All `ActorType` variants in tag order.
  """
  @spec all_actor_types() :: [actor_type()]
  def all_actor_types, do: [:person, :service, :application, :group, :organization]

  # ===========================================================================
  # DeliveryStatus (tags 0-4)
  # ===========================================================================

  @typedoc """
  DeliveryStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type delivery_status :: :pending | :delivered | :failed | :rejected | :deferred

  @delivery_status_tags %{
    pending: 0,
    delivered: 1,
    failed: 2,
    rejected: 3,
    deferred: 4,
  }

  @tag_to_delivery_status Map.new(@delivery_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DeliveryStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Federation.delivery_status_from_tag(0)
      {:ok, :pending}
  """
  @spec delivery_status_from_tag(non_neg_integer()) :: {:ok, delivery_status()} | :error
  def delivery_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_delivery_status, tag)}
  end

  def delivery_status_from_tag(_tag), do: :error

  @doc """
  Encode a `DeliveryStatus` to the C-ABI tag value.
  """
  @spec delivery_status_to_tag(delivery_status()) :: non_neg_integer()
  def delivery_status_to_tag(val) when is_map_key(@delivery_status_tags, val) do
    Map.fetch!(@delivery_status_tags, val)
  end

  @doc """
  All `DeliveryStatus` variants in tag order.
  """
  @spec all_delivery_statuss() :: [delivery_status()]
  def all_delivery_statuss, do: [:pending, :delivered, :failed, :rejected, :deferred]

  # ===========================================================================
  # TrustLevel (tags 0-4)
  # ===========================================================================

  @typedoc """
  TrustLevel types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type trust_level ::
          :self_signed
          | :peer_verified
          | :federation_trusted
          | :revoked
          | :unknown

  @trust_level_tags %{
    self_signed: 0,
    peer_verified: 1,
    federation_trusted: 2,
    revoked: 3,
    unknown: 4,
  }

  @tag_to_trust_level Map.new(@trust_level_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TrustLevel` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Federation.trust_level_from_tag(0)
      {:ok, :self_signed}
  """
  @spec trust_level_from_tag(non_neg_integer()) :: {:ok, trust_level()} | :error
  def trust_level_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_trust_level, tag)}
  end

  def trust_level_from_tag(_tag), do: :error

  @doc """
  Encode a `TrustLevel` to the C-ABI tag value.
  """
  @spec trust_level_to_tag(trust_level()) :: non_neg_integer()
  def trust_level_to_tag(val) when is_map_key(@trust_level_tags, val) do
    Map.fetch!(@trust_level_tags, val)
  end

  @doc """
  All `TrustLevel` variants in tag order.
  """
  @spec all_trust_levels() :: [trust_level()]
  def all_trust_levels, do: [:self_signed, :peer_verified, :federation_trusted, :revoked, :unknown]

  # ===========================================================================
  # ObjectType (tags 0-8)
  # ===========================================================================

  @typedoc """
  ObjectType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type object_type ::
          :note
          | :article
          | :image
          | :video
          | :audio
          | :document
          | :event
          | :collection
          | :ordered_collection

  @object_type_tags %{
    note: 0,
    article: 1,
    image: 2,
    video: 3,
    audio: 4,
    document: 5,
    event: 6,
    collection: 7,
    ordered_collection: 8,
  }

  @tag_to_object_type Map.new(@object_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ObjectType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..8, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Federation.object_type_from_tag(0)
      {:ok, :note}
  """
  @spec object_type_from_tag(non_neg_integer()) :: {:ok, object_type()} | :error
  def object_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_object_type, tag)}
  end

  def object_type_from_tag(_tag), do: :error

  @doc """
  Encode a `ObjectType` to the C-ABI tag value.
  """
  @spec object_type_to_tag(object_type()) :: non_neg_integer()
  def object_type_to_tag(val) when is_map_key(@object_type_tags, val) do
    Map.fetch!(@object_type_tags, val)
  end

  @doc """
  All `ObjectType` variants in tag order.
  """
  @spec all_object_types() :: [object_type()]
  def all_object_types do
    [
      :note, :article, :image, :video, :audio, :document, :event, :collection,
      :ordered_collection
    ]
  end

  # ===========================================================================
  # ServerState (tags 0-4)
  # ===========================================================================

  @typedoc """
  ServerState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type server_state :: :idle | :active | :processing | :delivering | :shutdown

  @server_state_tags %{
    idle: 0,
    active: 1,
    processing: 2,
    delivering: 3,
    shutdown: 4,
  }

  @tag_to_server_state Map.new(@server_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ServerState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Federation.server_state_from_tag(0)
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
  def all_server_states, do: [:idle, :active, :processing, :delivering, :shutdown]

end
