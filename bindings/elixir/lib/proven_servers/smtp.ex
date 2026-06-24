# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Smtp do
  @moduledoc """
  SMTP protocol types for the proven-servers ABI.

  Mirrors the Idris2 modules:

    * `SMTP.Command` -- SMTP commands (RFC 5321 Section 4.1)
    * `SMTP.Reply` -- reply codes and categories (RFC 5321 Section 4.2)
    * `SMTPABI.Layout` -- C-ABI tag values for all types
    * `SMTPABI.Transitions` -- session state machine

  ## Session State Machine

  The SMTP session follows this progression:

      Connected -> Greeted -> AuthStarted -> Authenticated -> MailFrom
              -> RcptTo -> Data -> MessageReceived [-> MailFrom (pipeline)]
              [-> Quit (from any state)]
  """

  # ===========================================================================
  # SMTP Constants
  # ===========================================================================

  @doc "Standard SMTP port (25)."
  @spec smtp_port() :: non_neg_integer()
  def smtp_port, do: 25

  @doc "SMTP submission port (587, RFC 6409)."
  @spec submission_port() :: non_neg_integer()
  def submission_port, do: 587

  @doc "SMTPS (implicit TLS) port (465)."
  @spec smtps_port() :: non_neg_integer()
  def smtps_port, do: 465

  # ===========================================================================
  # SmtpCommand (tags 0-11)
  # ===========================================================================

  @typedoc """
  SMTP protocol commands (RFC 5321).

  Tag values match `SmtpCommandTag` in `SmtpABI.Layout`.
  """
  @type command ::
          :helo | :ehlo | :mail_from | :rcpt_to | :data | :quit | :rset
          | :noop | :vrfy | :expn | :starttls | :auth

  @command_tags %{
    helo: 0, ehlo: 1, mail_from: 2, rcpt_to: 3, data: 4, quit: 5,
    rset: 6, noop: 7, vrfy: 8, expn: 9, starttls: 10, auth: 11
  }

  @tag_to_command Map.new(@command_tags, fn {k, v} -> {v, k} end)

  @command_verbs %{
    helo: "HELO", ehlo: "EHLO", mail_from: "MAIL FROM", rcpt_to: "RCPT TO",
    data: "DATA", quit: "QUIT", rset: "RSET", noop: "NOOP",
    vrfy: "VRFY", expn: "EXPN", starttls: "STARTTLS", auth: "AUTH"
  }

  @doc """
  Decode from a C-ABI tag value.

  ## Examples

      iex> ProvenServers.Smtp.command_from_tag(0)
      {:ok, :helo}
  """
  @spec command_from_tag(non_neg_integer()) :: {:ok, command()} | :error
  def command_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 11 do
    {:ok, Map.fetch!(@tag_to_command, tag)}
  end
  def command_from_tag(_tag), do: :error

  @doc "Encode a command to the C-ABI tag value."
  @spec command_to_tag(command()) :: non_neg_integer()
  def command_to_tag(cmd) when is_map_key(@command_tags, cmd) do
    Map.fetch!(@command_tags, cmd)
  end

  @doc """
  The SMTP command verb as a string.

  ## Examples

      iex> ProvenServers.Smtp.command_verb(:ehlo)
      "EHLO"
  """
  @spec command_verb(command()) :: String.t()
  def command_verb(cmd) when is_map_key(@command_verbs, cmd) do
    Map.fetch!(@command_verbs, cmd)
  end

  @doc "Whether this command is part of the mail transaction envelope."
  @spec command_envelope?(command()) :: boolean()
  def command_envelope?(cmd) when cmd in [:mail_from, :rcpt_to, :data], do: true
  def command_envelope?(_cmd), do: false

  # ===========================================================================
  # ReplyCategory (tags 0-3)
  # ===========================================================================

  @typedoc "SMTP reply severity categories (RFC 5321 Section 4.2)."
  @type reply_category :: :positive | :intermediate | :transient_negative | :permanent_negative

  @reply_category_tags %{positive: 0, intermediate: 1, transient_negative: 2, permanent_negative: 3}
  @tag_to_reply_category Map.new(@reply_category_tags, fn {k, v} -> {v, k} end)

  @doc "Decode from a C-ABI tag value."
  @spec reply_category_from_tag(non_neg_integer()) :: {:ok, reply_category()} | :error
  def reply_category_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_reply_category, tag)}
  end
  def reply_category_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec reply_category_to_tag(reply_category()) :: non_neg_integer()
  def reply_category_to_tag(cat) when is_map_key(@reply_category_tags, cat) do
    Map.fetch!(@reply_category_tags, cat)
  end

  @doc "Whether this category indicates success."
  @spec reply_category_success?(reply_category()) :: boolean()
  def reply_category_success?(:positive), do: true
  def reply_category_success?(_cat), do: false

  @doc "Whether this category indicates an error."
  @spec reply_category_error?(reply_category()) :: boolean()
  def reply_category_error?(cat) when cat in [:transient_negative, :permanent_negative], do: true
  def reply_category_error?(_cat), do: false

  # ===========================================================================
  # ReplyCode (tags 0-16)
  # ===========================================================================

  @typedoc "SMTP reply codes (RFC 5321)."
  @type reply_code ::
          :service_ready | :service_closing | :action_ok | :will_forward
          | :start_mail_input | :service_unavailable | :mailbox_busy
          | :local_error | :insufficient_storage | :syntax_error
          | :param_syntax_error | :not_implemented | :bad_sequence
          | :param_not_implemented | :mailbox_unavailable
          | :mailbox_name_invalid | :transaction_failed

  @reply_code_tags %{
    service_ready: 0, service_closing: 1, action_ok: 2, will_forward: 3,
    start_mail_input: 4, service_unavailable: 5, mailbox_busy: 6,
    local_error: 7, insufficient_storage: 8, syntax_error: 9,
    param_syntax_error: 10, not_implemented: 11, bad_sequence: 12,
    param_not_implemented: 13, mailbox_unavailable: 14,
    mailbox_name_invalid: 15, transaction_failed: 16
  }

  @tag_to_reply_code Map.new(@reply_code_tags, fn {k, v} -> {v, k} end)

  @reply_code_numerics %{
    service_ready: 220, service_closing: 221, action_ok: 250, will_forward: 251,
    start_mail_input: 354, service_unavailable: 421, mailbox_busy: 450,
    local_error: 451, insufficient_storage: 452, syntax_error: 500,
    param_syntax_error: 501, not_implemented: 502, bad_sequence: 503,
    param_not_implemented: 504, mailbox_unavailable: 550,
    mailbox_name_invalid: 553, transaction_failed: 554
  }

  @doc "Decode from a C-ABI tag value."
  @spec reply_code_from_tag(non_neg_integer()) :: {:ok, reply_code()} | :error
  def reply_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 16 do
    {:ok, Map.fetch!(@tag_to_reply_code, tag)}
  end
  def reply_code_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec reply_code_to_tag(reply_code()) :: non_neg_integer()
  def reply_code_to_tag(code) when is_map_key(@reply_code_tags, code) do
    Map.fetch!(@reply_code_tags, code)
  end

  @doc """
  The numeric SMTP reply code (e.g. 220, 250).

  ## Examples

      iex> ProvenServers.Smtp.reply_code_numeric(:action_ok)
      250
  """
  @spec reply_code_numeric(reply_code()) :: non_neg_integer()
  def reply_code_numeric(code) when is_map_key(@reply_code_numerics, code) do
    Map.fetch!(@reply_code_numerics, code)
  end

  @doc "The reply category for a given reply code."
  @spec reply_code_category(reply_code()) :: reply_category()
  def reply_code_category(code) when is_map_key(@reply_code_numerics, code) do
    case div(reply_code_numeric(code), 100) do
      2 -> :positive
      3 -> :intermediate
      4 -> :transient_negative
      _ -> :permanent_negative
    end
  end

  # ===========================================================================
  # AuthMechanism (tags 0-3)
  # ===========================================================================

  @typedoc "SMTP SASL authentication mechanisms (RFC 4954)."
  @type auth_mechanism :: :plain | :login | :cram_md5 | :xoauth2

  @auth_mechanism_tags %{plain: 0, login: 1, cram_md5: 2, xoauth2: 3}
  @tag_to_auth_mechanism Map.new(@auth_mechanism_tags, fn {k, v} -> {v, k} end)

  @auth_mechanism_names %{plain: "PLAIN", login: "LOGIN", cram_md5: "CRAM-MD5", xoauth2: "XOAUTH2"}

  @doc "Decode from a C-ABI tag value."
  @spec auth_mechanism_from_tag(non_neg_integer()) :: {:ok, auth_mechanism()} | :error
  def auth_mechanism_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_auth_mechanism, tag)}
  end
  def auth_mechanism_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec auth_mechanism_to_tag(auth_mechanism()) :: non_neg_integer()
  def auth_mechanism_to_tag(mech) when is_map_key(@auth_mechanism_tags, mech) do
    Map.fetch!(@auth_mechanism_tags, mech)
  end

  @doc "The SASL mechanism name string."
  @spec auth_mechanism_name(auth_mechanism()) :: String.t()
  def auth_mechanism_name(mech) when is_map_key(@auth_mechanism_names, mech) do
    Map.fetch!(@auth_mechanism_names, mech)
  end

  @doc "Whether this mechanism sends credentials in cleartext (requires TLS)."
  @spec auth_mechanism_requires_tls?(auth_mechanism()) :: boolean()
  def auth_mechanism_requires_tls?(mech) when mech in [:plain, :login], do: true
  def auth_mechanism_requires_tls?(_mech), do: false

  # ===========================================================================
  # SmtpExtension (tags 0-6)
  # ===========================================================================

  @typedoc "SMTP ESMTP extensions (RFC 5321 Section 2.2)."
  @type smtp_extension ::
          :size | :pipelining | :eight_bit_mime | :starttls
          | :auth_ext | :dsn | :chunking

  @smtp_extension_tags %{
    size: 0, pipelining: 1, eight_bit_mime: 2, starttls: 3,
    auth_ext: 4, dsn: 5, chunking: 6
  }

  @tag_to_smtp_extension Map.new(@smtp_extension_tags, fn {k, v} -> {v, k} end)

  @smtp_extension_keywords %{
    size: "SIZE", pipelining: "PIPELINING", eight_bit_mime: "8BITMIME",
    starttls: "STARTTLS", auth_ext: "AUTH", dsn: "DSN", chunking: "CHUNKING"
  }

  @doc """
  Decode from a C-ABI tag value.

  ## Examples

      iex> ProvenServers.Smtp.smtp_extension_from_tag(0)
      {:ok, :size}
  """
  @spec smtp_extension_from_tag(non_neg_integer()) :: {:ok, smtp_extension()} | :error
  def smtp_extension_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_smtp_extension, tag)}
  end
  def smtp_extension_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec smtp_extension_to_tag(smtp_extension()) :: non_neg_integer()
  def smtp_extension_to_tag(ext) when is_map_key(@smtp_extension_tags, ext) do
    Map.fetch!(@smtp_extension_tags, ext)
  end

  @doc """
  The ESMTP keyword string for this extension.

  ## Examples

      iex> ProvenServers.Smtp.smtp_extension_keyword(:pipelining)
      "PIPELINING"
  """
  @spec smtp_extension_keyword(smtp_extension()) :: String.t()
  def smtp_extension_keyword(ext) when is_map_key(@smtp_extension_keywords, ext) do
    Map.fetch!(@smtp_extension_keywords, ext)
  end

  # ===========================================================================
  # SmtpSessionState (tags 0-8)
  # ===========================================================================

  @typedoc "SMTP session state machine (RFC 5321)."
  @type session_state ::
          :connected | :greeted | :auth_started | :authenticated
          | :mail_from | :rcpt_to | :data | :message_received | :session_quit

  @session_state_tags %{
    connected: 0, greeted: 1, auth_started: 2, authenticated: 3,
    mail_from: 4, rcpt_to: 5, data: 6, message_received: 7, session_quit: 8
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc "Decode from a C-ABI tag value."
  @spec session_state_from_tag(non_neg_integer()) :: {:ok, session_state()} | :error
  def session_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_session_state, tag)}
  end
  def session_state_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec session_state_to_tag(session_state()) :: non_neg_integer()
  def session_state_to_tag(state) when is_map_key(@session_state_tags, state) do
    Map.fetch!(@session_state_tags, state)
  end

  # can_transition? removed: unproven reimplementation. The verified check lives in the
  # Idris2/Zig core; calling it needs FFI wiring not yet present in this binding.
  # Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md
end
