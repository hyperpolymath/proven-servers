# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Chat do
  @moduledoc """
  Chat Server types for the proven-servers ABI.
  
  Formally verified real-time chat types.
  Mirrors the Idris2 module `ChatABI.Types`.
  
  - `MessageType` -- Chat message types.
  - `PresenceStatus` -- User presence statuses.
  - `RoomType` -- Chat room types.
  - `Permission` -- Chat permissions.
  - `Event` -- Chat events.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # MessageType (tags 0-8)
  # ===========================================================================

  @typedoc """
  MessageType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type message_type ::
          :text
          | :image
          | :file
          | :system
          | :reaction
          | :edit
          | :delete
          | :reply
          | :thread

  @message_type_tags %{
    text: 0,
    image: 1,
    file: 2,
    system: 3,
    reaction: 4,
    edit: 5,
    delete: 6,
    reply: 7,
    thread: 8,
  }

  @tag_to_message_type Map.new(@message_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MessageType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..8, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Chat.message_type_from_tag(0)
      {:ok, :text}
  """
  @spec message_type_from_tag(non_neg_integer()) :: {:ok, message_type()} | :error
  def message_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_message_type, tag)}
  end

  def message_type_from_tag(_tag), do: :error

  @doc """
  Encode a `MessageType` to the C-ABI tag value.
  """
  @spec message_type_to_tag(message_type()) :: non_neg_integer()
  def message_type_to_tag(val) when is_map_key(@message_type_tags, val) do
    Map.fetch!(@message_type_tags, val)
  end

  @doc """
  All `MessageType` variants in tag order.
  """
  @spec all_message_types() :: [message_type()]
  def all_message_types do
    [
      :text, :image, :file, :system, :reaction, :edit, :delete, :reply,
      :thread
    ]
  end

  # ===========================================================================
  # PresenceStatus (tags 0-4)
  # ===========================================================================

  @typedoc """
  PresenceStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type presence_status :: :online | :away | :dnd | :invisible | :offline

  @presence_status_tags %{
    online: 0,
    away: 1,
    dnd: 2,
    invisible: 3,
    offline: 4,
  }

  @tag_to_presence_status Map.new(@presence_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PresenceStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Chat.presence_status_from_tag(0)
      {:ok, :online}
  """
  @spec presence_status_from_tag(non_neg_integer()) :: {:ok, presence_status()} | :error
  def presence_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_presence_status, tag)}
  end

  def presence_status_from_tag(_tag), do: :error

  @doc """
  Encode a `PresenceStatus` to the C-ABI tag value.
  """
  @spec presence_status_to_tag(presence_status()) :: non_neg_integer()
  def presence_status_to_tag(val) when is_map_key(@presence_status_tags, val) do
    Map.fetch!(@presence_status_tags, val)
  end

  @doc """
  All `PresenceStatus` variants in tag order.
  """
  @spec all_presence_statuss() :: [presence_status()]
  def all_presence_statuss, do: [:online, :away, :dnd, :invisible, :offline]

  # ===========================================================================
  # RoomType (tags 0-3)
  # ===========================================================================

  @typedoc """
  RoomType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type room_type :: :direct | :group | :channel | :broadcast

  @room_type_tags %{
    direct: 0,
    group: 1,
    channel: 2,
    broadcast: 3,
  }

  @tag_to_room_type Map.new(@room_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `RoomType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Chat.room_type_from_tag(0)
      {:ok, :direct}
  """
  @spec room_type_from_tag(non_neg_integer()) :: {:ok, room_type()} | :error
  def room_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_room_type, tag)}
  end

  def room_type_from_tag(_tag), do: :error

  @doc """
  Encode a `RoomType` to the C-ABI tag value.
  """
  @spec room_type_to_tag(room_type()) :: non_neg_integer()
  def room_type_to_tag(val) when is_map_key(@room_type_tags, val) do
    Map.fetch!(@room_type_tags, val)
  end

  @doc """
  All `RoomType` variants in tag order.
  """
  @spec all_room_types() :: [room_type()]
  def all_room_types, do: [:direct, :group, :channel, :broadcast]

  # ===========================================================================
  # Permission (tags 0-7)
  # ===========================================================================

  @typedoc """
  Permission types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type permission ::
          :read
          | :write
          | :admin
          | :invite
          | :kick
          | :ban
          | :pin
          | :delete_others

  @permission_tags %{
    read: 0,
    write: 1,
    admin: 2,
    invite: 3,
    kick: 4,
    ban: 5,
    pin: 6,
    delete_others: 7,
  }

  @tag_to_permission Map.new(@permission_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Permission` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Chat.permission_from_tag(0)
      {:ok, :read}
  """
  @spec permission_from_tag(non_neg_integer()) :: {:ok, permission()} | :error
  def permission_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_permission, tag)}
  end

  def permission_from_tag(_tag), do: :error

  @doc """
  Encode a `Permission` to the C-ABI tag value.
  """
  @spec permission_to_tag(permission()) :: non_neg_integer()
  def permission_to_tag(val) when is_map_key(@permission_tags, val) do
    Map.fetch!(@permission_tags, val)
  end

  @doc """
  All `Permission` variants in tag order.
  """
  @spec all_permissions() :: [permission()]
  def all_permissions, do: [:read, :write, :admin, :invite, :kick, :ban, :pin, :delete_others]

  # ===========================================================================
  # Event (tags 0-6)
  # ===========================================================================

  @typedoc """
  Event types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type event ::
          :message_sent
          | :message_delivered
          | :message_read
          | :user_joined
          | :user_left
          | :typing
          | :room_created

  @event_tags %{
    message_sent: 0,
    message_delivered: 1,
    message_read: 2,
    user_joined: 3,
    user_left: 4,
    typing: 5,
    room_created: 6,
  }

  @tag_to_event Map.new(@event_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Event` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Chat.event_from_tag(0)
      {:ok, :message_sent}
  """
  @spec event_from_tag(non_neg_integer()) :: {:ok, event()} | :error
  def event_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_event, tag)}
  end

  def event_from_tag(_tag), do: :error

  @doc """
  Encode a `Event` to the C-ABI tag value.
  """
  @spec event_to_tag(event()) :: non_neg_integer()
  def event_to_tag(val) when is_map_key(@event_tags, val) do
    Map.fetch!(@event_tags, val)
  end

  @doc """
  All `Event` variants in tag order.
  """
  @spec all_events() :: [event()]
  def all_events do
    [
      :message_sent, :message_delivered, :message_read, :user_joined,
      :user_left, :typing, :room_created
    ]
  end

end
