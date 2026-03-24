# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Ftp do
  @moduledoc """
  FTP protocol types for the proven-servers ABI.

  Mirrors the Idris2 modules:

    * `FTP.Session` -- session states (RFC 959 Section 4.1)
    * `FTP.Command` -- FTP commands
    * `FTP.Transfer` -- transfer types and modes
    * `FTP.Reply` -- reply categories
    * `FTPABI.Layout` -- C-ABI tag values
    * `FTPABI.Transitions` -- session state machine
  """

  # ===========================================================================
  # FTP Constants
  # ===========================================================================

  @doc "Standard FTP control port (21, RFC 959)."
  @spec ftp_control_port() :: non_neg_integer()
  def ftp_control_port, do: 21

  @doc "Standard FTP data port (20, RFC 959)."
  @spec ftp_data_port() :: non_neg_integer()
  def ftp_data_port, do: 20

  @doc "FTPS (implicit TLS) control port (990)."
  @spec ftps_port() :: non_neg_integer()
  def ftps_port, do: 990

  # ===========================================================================
  # SessionState (tags 0-4)
  # ===========================================================================

  @typedoc "FTP session state machine."
  @type session_state :: :connected | :user_ok | :authenticated | :renaming | :quit

  @session_state_tags %{connected: 0, user_ok: 1, authenticated: 2, renaming: 3, quit: 4}
  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc "Decode from a C-ABI tag value."
  @spec session_state_from_tag(non_neg_integer()) :: {:ok, session_state()} | :error
  def session_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_session_state, tag)}
  end
  def session_state_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec session_state_to_tag(session_state()) :: non_neg_integer()
  def session_state_to_tag(state) when is_map_key(@session_state_tags, state) do
    Map.fetch!(@session_state_tags, state)
  end

  @doc """
  Validate whether an FTP session state transition is allowed.

  ## Examples

      iex> ProvenServers.Ftp.session_can_transition?(:connected, :user_ok)
      true

      iex> ProvenServers.Ftp.session_can_transition?(:connected, :authenticated)
      false
  """
  @spec session_can_transition?(session_state(), session_state()) :: boolean()
  def session_can_transition?(:connected, :user_ok), do: true
  def session_can_transition?(:user_ok, :authenticated), do: true
  def session_can_transition?(:user_ok, :connected), do: true
  def session_can_transition?(:authenticated, :renaming), do: true
  def session_can_transition?(:renaming, :authenticated), do: true
  def session_can_transition?(_, :quit), do: true
  def session_can_transition?(_, _), do: false

  # ===========================================================================
  # TransferType (tags 0-1)
  # ===========================================================================

  @typedoc "FTP data transfer type (RFC 959 Section 3.1.1)."
  @type transfer_type :: :ascii | :binary

  @transfer_type_tags %{ascii: 0, binary: 1}
  @tag_to_transfer_type Map.new(@transfer_type_tags, fn {k, v} -> {v, k} end)

  @doc "Decode from a C-ABI tag value."
  @spec transfer_type_from_tag(non_neg_integer()) :: {:ok, transfer_type()} | :error
  def transfer_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_transfer_type, tag)}
  end
  def transfer_type_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec transfer_type_to_tag(transfer_type()) :: non_neg_integer()
  def transfer_type_to_tag(tt) when is_map_key(@transfer_type_tags, tt) do
    Map.fetch!(@transfer_type_tags, tt)
  end

  @doc """
  The FTP TYPE parameter character.

  ## Examples

      iex> ProvenServers.Ftp.transfer_type_char(:ascii)
      "A"

      iex> ProvenServers.Ftp.transfer_type_char(:binary)
      "I"
  """
  @spec transfer_type_char(transfer_type()) :: String.t()
  def transfer_type_char(:ascii), do: "A"
  def transfer_type_char(:binary), do: "I"

  # ===========================================================================
  # DataMode (tags 0-1)
  # ===========================================================================

  @typedoc "FTP data connection mode (RFC 959)."
  @type data_mode :: :active | :passive

  @data_mode_tags %{active: 0, passive: 1}
  @tag_to_data_mode Map.new(@data_mode_tags, fn {k, v} -> {v, k} end)

  @doc "Decode from a C-ABI tag value."
  @spec data_mode_from_tag(non_neg_integer()) :: {:ok, data_mode()} | :error
  def data_mode_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_data_mode, tag)}
  end
  def data_mode_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec data_mode_to_tag(data_mode()) :: non_neg_integer()
  def data_mode_to_tag(mode) when is_map_key(@data_mode_tags, mode) do
    Map.fetch!(@data_mode_tags, mode)
  end

  @doc "Whether this mode is firewall-friendly (passive allows NAT traversal)."
  @spec data_mode_firewall_friendly?(data_mode()) :: boolean()
  def data_mode_firewall_friendly?(:passive), do: true
  def data_mode_firewall_friendly?(_mode), do: false

  # ===========================================================================
  # TransferState (tags 0-3)
  # ===========================================================================

  @typedoc "FTP file transfer state machine."
  @type transfer_state :: :idle | :in_progress | :completed | :aborted

  @transfer_state_tags %{idle: 0, in_progress: 1, completed: 2, aborted: 3}
  @tag_to_transfer_state Map.new(@transfer_state_tags, fn {k, v} -> {v, k} end)

  @doc "Decode from a C-ABI tag value."
  @spec transfer_state_from_tag(non_neg_integer()) :: {:ok, transfer_state()} | :error
  def transfer_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_transfer_state, tag)}
  end
  def transfer_state_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec transfer_state_to_tag(transfer_state()) :: non_neg_integer()
  def transfer_state_to_tag(state) when is_map_key(@transfer_state_tags, state) do
    Map.fetch!(@transfer_state_tags, state)
  end

  @doc "Whether the transfer has finished (completed or aborted)."
  @spec transfer_state_terminal?(transfer_state()) :: boolean()
  def transfer_state_terminal?(state) when state in [:completed, :aborted], do: true
  def transfer_state_terminal?(_state), do: false

  # ===========================================================================
  # ReplyCategory (tags 0-4)
  # ===========================================================================

  @typedoc "FTP reply categories (RFC 959 Section 4.2)."
  @type reply_category :: :preliminary | :completion | :intermediate | :transient_neg | :permanent_neg

  @reply_category_tags %{preliminary: 0, completion: 1, intermediate: 2, transient_neg: 3, permanent_neg: 4}
  @tag_to_reply_category Map.new(@reply_category_tags, fn {k, v} -> {v, k} end)

  @doc "Decode from a C-ABI tag value."
  @spec reply_category_from_tag(non_neg_integer()) :: {:ok, reply_category()} | :error
  def reply_category_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_reply_category, tag)}
  end
  def reply_category_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec reply_category_to_tag(reply_category()) :: non_neg_integer()
  def reply_category_to_tag(cat) when is_map_key(@reply_category_tags, cat) do
    Map.fetch!(@reply_category_tags, cat)
  end

  @doc "Whether this category indicates a positive outcome."
  @spec reply_category_positive?(reply_category()) :: boolean()
  def reply_category_positive?(cat) when cat in [:preliminary, :completion, :intermediate], do: true
  def reply_category_positive?(_cat), do: false

  @doc "Whether this category indicates an error."
  @spec reply_category_error?(reply_category()) :: boolean()
  def reply_category_error?(cat) when cat in [:transient_neg, :permanent_neg], do: true
  def reply_category_error?(_cat), do: false

  # ===========================================================================
  # Command (tags 0-22)
  # ===========================================================================

  @typedoc "FTP protocol commands (RFC 959)."
  @type command ::
          :user | :pass | :acct | :cwd | :cdup | :quit | :pasv | :port
          | :type_cmd | :retr | :stor | :dele | :rmd | :mkd | :pwd
          | :list | :nlst | :syst | :stat | :noop | :rnfr | :rnto | :size

  @command_tags %{
    user: 0, pass: 1, acct: 2, cwd: 3, cdup: 4, quit: 5, pasv: 6, port: 7,
    type_cmd: 8, retr: 9, stor: 10, dele: 11, rmd: 12, mkd: 13, pwd: 14,
    list: 15, nlst: 16, syst: 17, stat: 18, noop: 19, rnfr: 20, rnto: 21,
    size: 22
  }

  @tag_to_command Map.new(@command_tags, fn {k, v} -> {v, k} end)

  @command_verbs %{
    user: "USER", pass: "PASS", acct: "ACCT", cwd: "CWD", cdup: "CDUP",
    quit: "QUIT", pasv: "PASV", port: "PORT", type_cmd: "TYPE",
    retr: "RETR", stor: "STOR", dele: "DELE", rmd: "RMD", mkd: "MKD",
    pwd: "PWD", list: "LIST", nlst: "NLST", syst: "SYST", stat: "STAT",
    noop: "NOOP", rnfr: "RNFR", rnto: "RNTO", size: "SIZE"
  }

  @doc """
  Decode from a C-ABI tag value.

  ## Examples

      iex> ProvenServers.Ftp.command_from_tag(0)
      {:ok, :user}
  """
  @spec command_from_tag(non_neg_integer()) :: {:ok, command()} | :error
  def command_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 22 do
    {:ok, Map.fetch!(@tag_to_command, tag)}
  end
  def command_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec command_to_tag(command()) :: non_neg_integer()
  def command_to_tag(cmd) when is_map_key(@command_tags, cmd) do
    Map.fetch!(@command_tags, cmd)
  end

  @doc """
  The FTP command verb as a string.

  ## Examples

      iex> ProvenServers.Ftp.command_verb(:retr)
      "RETR"
  """
  @spec command_verb(command()) :: String.t()
  def command_verb(cmd) when is_map_key(@command_verbs, cmd) do
    Map.fetch!(@command_verbs, cmd)
  end

  @doc "Whether this command initiates a data transfer."
  @spec command_requires_data_connection?(command()) :: boolean()
  def command_requires_data_connection?(cmd) when cmd in [:retr, :stor, :list, :nlst], do: true
  def command_requires_data_connection?(_cmd), do: false

  @doc "Whether this command requires authentication."
  @spec command_requires_auth?(command()) :: boolean()
  def command_requires_auth?(cmd) when cmd in [:user, :pass, :acct, :quit], do: false
  def command_requires_auth?(_cmd), do: true

  @doc "All supported FTP commands in tag order."
  @spec all_commands() :: [command()]
  def all_commands do
    [
      :user, :pass, :acct, :cwd, :cdup, :quit, :pasv, :port, :type_cmd,
      :retr, :stor, :dele, :rmd, :mkd, :pwd, :list, :nlst, :syst,
      :stat, :noop, :rnfr, :rnto, :size
    ]
  end
end
