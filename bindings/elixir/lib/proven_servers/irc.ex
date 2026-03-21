# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Irc do
  @moduledoc """
  IRC protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `IrcABI.Types` and its type definitions:
  - `Command`      — IRC commands (17 constructors, tags 0-16)
  - `NumericReply`  — Selected numeric replies (11 constructors, tags 0-10)
  - `ChannelMode`   — Channel mode flags (10 constructors, tags 0-9)
  - `State`         — IRC connection lifecycle (5 constructors, tags 0-4)
  - `IrcError`      — IRC error categories (6 constructors, tags 0-5)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard IRC port (RFC 2812)."
  @spec irc_port() :: non_neg_integer()
  def irc_port, do: 6667

  @doc "Standard IRC over TLS port."
  @spec ircs_port() :: non_neg_integer()
  def ircs_port, do: 6697

  # ===========================================================================
  # Command (tags 0-16)
  # ===========================================================================

  @typedoc """
  Command types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type command ::
          :nick
          | :user
          | :join
          | :part
          | :privmsg
          | :notice
          | :quit
          | :ping
          | :pong
          | :mode
          | :kick
          | :topic
          | :invite
          | :names
          | :list
          | :who
          | :whois

  @command_tags %{
    nick: 0,
    user: 1,
    join: 2,
    part: 3,
    privmsg: 4,
    notice: 5,
    quit: 6,
    ping: 7,
    pong: 8,
    mode: 9,
    kick: 10,
    topic: 11,
    invite: 12,
    names: 13,
    list: 14,
    who: 15,
    whois: 16,
  }

  @tag_to_command Map.new(@command_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Command` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..16, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Irc.command_from_tag(0)
      {:ok, :nick}
  """
  @spec command_from_tag(non_neg_integer()) :: {:ok, command()} | :error
  def command_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 16 do
    {:ok, Map.fetch!(@tag_to_command, tag)}
  end

  def command_from_tag(_tag), do: :error

  @doc """
  Encode a `Command` to the C-ABI tag value.
  """
  @spec command_to_tag(command()) :: non_neg_integer()
  def command_to_tag(val) when is_map_key(@command_tags, val) do
    Map.fetch!(@command_tags, val)
  end

  @doc """
  All `Command` variants in tag order.
  """
  @spec all_commands() :: [command()]
  def all_commands do
    [
      :nick, :user, :join, :part, :privmsg, :notice, :quit, :ping, :pong,
      :mode, :kick, :topic, :invite, :names, :list, :who, :whois
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  The IRC command name string.
        match self {

  Whether this command requires channel operator privileges.
  """
  @spec requires_op?(command()) :: boolean()
  def requires_op?(val) when val in [:kick, :mode], do: true
  def requires_op?(_val), do: false

  @doc """
  Whether this command requires registered status.
  """
  @spec requires_registration?(command()) :: boolean()
  def requires_registration?(val) when val in [:nick, :user, :ping, :pong, :quit], do: false
  def requires_registration?(_val), do: true

  # ===========================================================================
  # NumericReply (tags 0-10)
  # ===========================================================================

  @typedoc """
  NumericReply types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type numeric_reply ::
          :welcome
          | :your_host
          | :created
          | :my_info
          | :bounce
          | :nick_in_use
          | :no_such_nick
          | :no_such_channel
          | :channel_is_full
          | :invite_only_chan
          | :banned_from_chan

  @numeric_reply_tags %{
    welcome: 0,
    your_host: 1,
    created: 2,
    my_info: 3,
    bounce: 4,
    nick_in_use: 5,
    no_such_nick: 6,
    no_such_channel: 7,
    channel_is_full: 8,
    invite_only_chan: 9,
    banned_from_chan: 10,
  }

  @tag_to_numeric_reply Map.new(@numeric_reply_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NumericReply` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..10, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Irc.numeric_reply_from_tag(0)
      {:ok, :welcome}
  """
  @spec numeric_reply_from_tag(non_neg_integer()) :: {:ok, numeric_reply()} | :error
  def numeric_reply_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 10 do
    {:ok, Map.fetch!(@tag_to_numeric_reply, tag)}
  end

  def numeric_reply_from_tag(_tag), do: :error

  @doc """
  Encode a `NumericReply` to the C-ABI tag value.
  """
  @spec numeric_reply_to_tag(numeric_reply()) :: non_neg_integer()
  def numeric_reply_to_tag(val) when is_map_key(@numeric_reply_tags, val) do
    Map.fetch!(@numeric_reply_tags, val)
  end

  @doc """
  All `NumericReply` variants in tag order.
  """
  @spec all_numeric_replys() :: [numeric_reply()]
  def all_numeric_replys do
    [
      :welcome, :your_host, :created, :my_info, :bounce, :nick_in_use,
      :no_such_nick, :no_such_channel, :channel_is_full, :invite_only_chan,
      :banned_from_chan
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this reply indicates an error.
  """
  @spec is_error?(numeric_reply()) :: boolean()
  def is_error?(val) when val in [:nick_in_use, :no_such_nick, :no_such_channel, :channel_is_full, :invite_only_chan, :banned_from_chan], do: true
  def is_error?(_val), do: false

  # ===========================================================================
  # ChannelMode (tags 0-9)
  # ===========================================================================

  @typedoc """
  ChannelMode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type channel_mode ::
          :op
          | :voice
          | :ban
          | :limit
          | :invite_only
          | :moderated
          | :no_external_msgs
          | :topic_lock
          | :secret
          | :private

  @channel_mode_tags %{
    op: 0,
    voice: 1,
    ban: 2,
    limit: 3,
    invite_only: 4,
    moderated: 5,
    no_external_msgs: 6,
    topic_lock: 7,
    secret: 8,
    private: 9,
  }

  @tag_to_channel_mode Map.new(@channel_mode_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ChannelMode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..9, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Irc.channel_mode_from_tag(0)
      {:ok, :op}
  """
  @spec channel_mode_from_tag(non_neg_integer()) :: {:ok, channel_mode()} | :error
  def channel_mode_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 9 do
    {:ok, Map.fetch!(@tag_to_channel_mode, tag)}
  end

  def channel_mode_from_tag(_tag), do: :error

  @doc """
  Encode a `ChannelMode` to the C-ABI tag value.
  """
  @spec channel_mode_to_tag(channel_mode()) :: non_neg_integer()
  def channel_mode_to_tag(val) when is_map_key(@channel_mode_tags, val) do
    Map.fetch!(@channel_mode_tags, val)
  end

  @doc """
  All `ChannelMode` variants in tag order.
  """
  @spec all_channel_modes() :: [channel_mode()]
  def all_channel_modes do
    [
      :op, :voice, :ban, :limit, :invite_only, :moderated, :no_external_msgs,
      :topic_lock, :secret, :private
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  The single-character mode flag.
        match self {

  Whether this mode requires a parameter when set.
  """
  @spec requires_parameter?(channel_mode()) :: boolean()
  def requires_parameter?(val) when val in [:op, :voice, :ban, :limit], do: true
  def requires_parameter?(_val), do: false

  # ===========================================================================
  # State (tags 0-4)
  # ===========================================================================

  @typedoc """
  State types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type state :: :disconnected | :connecting | :registered | :in_channel | :quitting

  @state_tags %{
    disconnected: 0,
    connecting: 1,
    registered: 2,
    in_channel: 3,
    quitting: 4,
  }

  @tag_to_state Map.new(@state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `State` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Irc.state_from_tag(0)
      {:ok, :disconnected}
  """
  @spec state_from_tag(non_neg_integer()) :: {:ok, state()} | :error
  def state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_state, tag)}
  end

  def state_from_tag(_tag), do: :error

  @doc """
  Encode a `State` to the C-ABI tag value.
  """
  @spec state_to_tag(state()) :: non_neg_integer()
  def state_to_tag(val) when is_map_key(@state_tags, val) do
    Map.fetch!(@state_tags, val)
  end

  @doc """
  All `State` variants in tag order.
  """
  @spec all_states() :: [state()]
  def all_states, do: [:disconnected, :connecting, :registered, :in_channel, :quitting]

  @doc """
  Validate whether a `State` state transition is allowed.

  Mirrors the formally verified transitions from the Idris2 source.
  """
  @spec validate_state_transition(state(), state()) :: boolean()
  def validate_state_transition(:disconnected, :connecting), do: true
  def validate_state_transition(:connecting, :registered), do: true
  def validate_state_transition(:registered, :in_channel), do: true
  def validate_state_transition(:in_channel, :registered), do: true
  def validate_state_transition(:registered, :quitting), do: true
  def validate_state_transition(:in_channel, :quitting), do: true
  def validate_state_transition(:quitting, :disconnected), do: true
  def validate_state_transition(_from, _to), do: false

  # ===========================================================================
  # IrcError (tags 0-5)
  # ===========================================================================

  @typedoc """
  IrcError types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type irc_error ::
          :none
          | :nick_in_use
          | :channel_full
          | :invite_only
          | :banned
          | :not_registered

  @irc_error_tags %{
    none: 0,
    nick_in_use: 1,
    channel_full: 2,
    invite_only: 3,
    banned: 4,
    not_registered: 5,
  }

  @tag_to_irc_error Map.new(@irc_error_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `IrcError` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Irc.irc_error_from_tag(0)
      {:ok, :none}
  """
  @spec irc_error_from_tag(non_neg_integer()) :: {:ok, irc_error()} | :error
  def irc_error_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_irc_error, tag)}
  end

  def irc_error_from_tag(_tag), do: :error

  @doc """
  Encode a `IrcError` to the C-ABI tag value.
  """
  @spec irc_error_to_tag(irc_error()) :: non_neg_integer()
  def irc_error_to_tag(val) when is_map_key(@irc_error_tags, val) do
    Map.fetch!(@irc_error_tags, val)
  end

  @doc """
  All `IrcError` variants in tag order.
  """
  @spec all_irc_errors() :: [irc_error()]
  def all_irc_errors do
    [
      :none, :nick_in_use, :channel_full, :invite_only, :banned, :not_registered,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this error code indicates success.
  """
  @spec is_success?(irc_error()) :: boolean()
  def is_success?(val) when val in [:none], do: true
  def is_success?(_val), do: false

  @doc """
  Whether this error relates to channel access.
  """
  @spec is_channel_error?(irc_error()) :: boolean()
  def is_channel_error?(val) when val in [:channel_full, :invite_only, :banned], do: true
  def is_channel_error?(_val), do: false

end
