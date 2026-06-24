# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Kerberos do
  @moduledoc """
  Kerberos protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `KerberosABI.Types` and its type definitions:
  - `MessageType`       — Kerberos message types (10 constructors, tags 0-9)
  - `EncryptionType`    — Encryption algorithms (5 constructors, tags 0-4)
  - `PrincipalType`     — Principal name types (7 constructors, tags 0-6)
  - `TicketFlag`        — Ticket flags (7 constructors, tags 0-6)
  - `ErrorCode`         — KDC error codes (10 constructors, tags 0-9)
  - `AuthState`         — Authentication state machine (5 constructors, tags 0-4)
  - `EncStrength`       — Encryption strength levels (3 constructors, tags 0-2)
  - `PreAuthType`       — Pre-authentication types (4 constructors, tags 0-3)
  - `NegotiationState`  — Negotiation state machine (4 constructors, tags 0-3)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard Kerberos KDC port (RFC 4120)."
  @spec kerberos_port() :: non_neg_integer()
  def kerberos_port, do: 88

  # ===========================================================================
  # MessageType (tags 0-9)
  # ===========================================================================

  @typedoc """
  MessageType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type message_type ::
          :as_req
          | :as_rep
          | :tgs_req
          | :tgs_rep
          | :ap_req
          | :ap_rep
          | :krb_error
          | :krb_safe
          | :krb_priv
          | :krb_cred

  @message_type_tags %{
    as_req: 0,
    as_rep: 1,
    tgs_req: 2,
    tgs_rep: 3,
    ap_req: 4,
    ap_rep: 5,
    krb_error: 6,
    krb_safe: 7,
    krb_priv: 8,
    krb_cred: 9,
  }

  @tag_to_message_type Map.new(@message_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MessageType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..9, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Kerberos.message_type_from_tag(0)
      {:ok, :as_req}
  """
  @spec message_type_from_tag(non_neg_integer()) :: {:ok, message_type()} | :error
  def message_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 9 do
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
      :as_req, :as_rep, :tgs_req, :tgs_rep, :ap_req, :ap_rep, :krb_error,
      :krb_safe, :krb_priv, :krb_cred
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this message is a request.
  """
  @spec is_request?(message_type()) :: boolean()
  def is_request?(val) when val in [:as_req, :tgs_req, :ap_req], do: true
  def is_request?(_val), do: false

  @doc """
  Whether this message is a reply.
  """
  @spec is_reply?(message_type()) :: boolean()
  def is_reply?(val) when val in [:as_rep, :tgs_rep, :ap_rep], do: true
  def is_reply?(_val), do: false

  # ===========================================================================
  # EncryptionType (tags 0-4)
  # ===========================================================================

  @typedoc """
  EncryptionType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type encryption_type ::
          :aes256_cts_hmac_sha1
          | :aes128_cts_hmac_sha1
          | :aes256_cts_hmac_sha384
          | :rc4_hmac
          | :des3_cbc_sha1

  @encryption_type_tags %{
    aes256_cts_hmac_sha1: 0,
    aes128_cts_hmac_sha1: 1,
    aes256_cts_hmac_sha384: 2,
    rc4_hmac: 3,
    des3_cbc_sha1: 4,
  }

  @tag_to_encryption_type Map.new(@encryption_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `EncryptionType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Kerberos.encryption_type_from_tag(0)
      {:ok, :aes256_cts_hmac_sha1}
  """
  @spec encryption_type_from_tag(non_neg_integer()) :: {:ok, encryption_type()} | :error
  def encryption_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_encryption_type, tag)}
  end

  def encryption_type_from_tag(_tag), do: :error

  @doc """
  Encode a `EncryptionType` to the C-ABI tag value.
  """
  @spec encryption_type_to_tag(encryption_type()) :: non_neg_integer()
  def encryption_type_to_tag(val) when is_map_key(@encryption_type_tags, val) do
    Map.fetch!(@encryption_type_tags, val)
  end

  @doc """
  All `EncryptionType` variants in tag order.
  """
  @spec all_encryption_types() :: [encryption_type()]
  def all_encryption_types do
    [
      :aes256_cts_hmac_sha1, :aes128_cts_hmac_sha1, :aes256_cts_hmac_sha384,
      :rc4_hmac, :des3_cbc_sha1
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  The encryption strength classification.
        match self {

  Whether this encryption type is considered legacy/deprecated.
  """
  @spec is_legacy?(encryption_type()) :: boolean()
  def is_legacy?(val) when val in [:rc4_hmac, :des3_cbc_sha1], do: true
  def is_legacy?(_val), do: false

  # ===========================================================================
  # PrincipalType (tags 0-6)
  # ===========================================================================

  @typedoc """
  PrincipalType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type principal_type ::
          :nt_unknown
          | :nt_principal
          | :nt_srv_inst
          | :nt_srv_hst
          | :nt_uid
          | :nt_x500
          | :nt_enterprise

  @principal_type_tags %{
    nt_unknown: 0,
    nt_principal: 1,
    nt_srv_inst: 2,
    nt_srv_hst: 3,
    nt_uid: 4,
    nt_x500: 5,
    nt_enterprise: 6,
  }

  @tag_to_principal_type Map.new(@principal_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PrincipalType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Kerberos.principal_type_from_tag(0)
      {:ok, :nt_unknown}
  """
  @spec principal_type_from_tag(non_neg_integer()) :: {:ok, principal_type()} | :error
  def principal_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_principal_type, tag)}
  end

  def principal_type_from_tag(_tag), do: :error

  @doc """
  Encode a `PrincipalType` to the C-ABI tag value.
  """
  @spec principal_type_to_tag(principal_type()) :: non_neg_integer()
  def principal_type_to_tag(val) when is_map_key(@principal_type_tags, val) do
    Map.fetch!(@principal_type_tags, val)
  end

  @doc """
  All `PrincipalType` variants in tag order.
  """
  @spec all_principal_types() :: [principal_type()]
  def all_principal_types do
    [
      :nt_unknown, :nt_principal, :nt_srv_inst, :nt_srv_hst, :nt_uid,
      :nt_x500, :nt_enterprise
    ]
  end

  # ===========================================================================
  # TicketFlag (tags 0-6)
  # ===========================================================================

  @typedoc """
  TicketFlag types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type ticket_flag ::
          :forwardable
          | :forwarded
          | :proxiable
          | :proxy
          | :renewable
          | :pre_authent
          | :hw_authent

  @ticket_flag_tags %{
    forwardable: 0,
    forwarded: 1,
    proxiable: 2,
    proxy: 3,
    renewable: 4,
    pre_authent: 5,
    hw_authent: 6,
  }

  @tag_to_ticket_flag Map.new(@ticket_flag_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TicketFlag` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Kerberos.ticket_flag_from_tag(0)
      {:ok, :forwardable}
  """
  @spec ticket_flag_from_tag(non_neg_integer()) :: {:ok, ticket_flag()} | :error
  def ticket_flag_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_ticket_flag, tag)}
  end

  def ticket_flag_from_tag(_tag), do: :error

  @doc """
  Encode a `TicketFlag` to the C-ABI tag value.
  """
  @spec ticket_flag_to_tag(ticket_flag()) :: non_neg_integer()
  def ticket_flag_to_tag(val) when is_map_key(@ticket_flag_tags, val) do
    Map.fetch!(@ticket_flag_tags, val)
  end

  @doc """
  All `TicketFlag` variants in tag order.
  """
  @spec all_ticket_flags() :: [ticket_flag()]
  def all_ticket_flags do
    [
      :forwardable, :forwarded, :proxiable, :proxy, :renewable, :pre_authent,
      :hw_authent
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this flag relates to delegation.
  """
  @spec is_delegation?(ticket_flag()) :: boolean()
  def is_delegation?(val) when val in [:forwardable, :forwarded, :proxiable, :proxy], do: true
  def is_delegation?(_val), do: false

  # ===========================================================================
  # ErrorCode (tags 0-9)
  # ===========================================================================

  @typedoc """
  ErrorCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type error_code ::
          :kdc_err_none
          | :kdc_err_name_exp
          | :kdc_err_service_exp
          | :kdc_err_bad_pvno
          | :kdc_err_c_old_mast_kvno
          | :kdc_err_s_old_mast_kvno
          | :kdc_err_c_principal_unknown
          | :kdc_err_s_principal_unknown
          | :kdc_err_preauth_failed
          | :kdc_err_preauth_required

  @error_code_tags %{
    kdc_err_none: 0,
    kdc_err_name_exp: 1,
    kdc_err_service_exp: 2,
    kdc_err_bad_pvno: 3,
    kdc_err_c_old_mast_kvno: 4,
    kdc_err_s_old_mast_kvno: 5,
    kdc_err_c_principal_unknown: 6,
    kdc_err_s_principal_unknown: 7,
    kdc_err_preauth_failed: 8,
    kdc_err_preauth_required: 9,
  }

  @tag_to_error_code Map.new(@error_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ErrorCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..9, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Kerberos.error_code_from_tag(0)
      {:ok, :kdc_err_none}
  """
  @spec error_code_from_tag(non_neg_integer()) :: {:ok, error_code()} | :error
  def error_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 9 do
    {:ok, Map.fetch!(@tag_to_error_code, tag)}
  end

  def error_code_from_tag(_tag), do: :error

  @doc """
  Encode a `ErrorCode` to the C-ABI tag value.
  """
  @spec error_code_to_tag(error_code()) :: non_neg_integer()
  def error_code_to_tag(val) when is_map_key(@error_code_tags, val) do
    Map.fetch!(@error_code_tags, val)
  end

  @doc """
  All `ErrorCode` variants in tag order.
  """
  @spec all_error_codes() :: [error_code()]
  def all_error_codes do
    [
      :kdc_err_none, :kdc_err_name_exp, :kdc_err_service_exp, :kdc_err_bad_pvno,
      :kdc_err_c_old_mast_kvno, :kdc_err_s_old_mast_kvno, :kdc_err_c_principal_unknown,
      :kdc_err_s_principal_unknown, :kdc_err_preauth_failed, :kdc_err_preauth_required,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this code indicates success.
  """
  @spec is_success?(error_code()) :: boolean()
  def is_success?(val) when val in [:kdc_err_none], do: true
  def is_success?(_val), do: false

  # ===========================================================================
  # AuthState (tags 0-4)
  # ===========================================================================

  @typedoc """
  AuthState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type auth_state ::
          :initial
          | :tgt_obtained
          | :service_ticket_obtained
          | :authenticated
          | :auth_failed

  @auth_state_tags %{
    initial: 0,
    tgt_obtained: 1,
    service_ticket_obtained: 2,
    authenticated: 3,
    auth_failed: 4,
  }

  @tag_to_auth_state Map.new(@auth_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AuthState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Kerberos.auth_state_from_tag(0)
      {:ok, :initial}
  """
  @spec auth_state_from_tag(non_neg_integer()) :: {:ok, auth_state()} | :error
  def auth_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_auth_state, tag)}
  end

  def auth_state_from_tag(_tag), do: :error

  @doc """
  Encode a `AuthState` to the C-ABI tag value.
  """
  @spec auth_state_to_tag(auth_state()) :: non_neg_integer()
  def auth_state_to_tag(val) when is_map_key(@auth_state_tags, val) do
    Map.fetch!(@auth_state_tags, val)
  end

  @doc """
  All `AuthState` variants in tag order.
  """
  @spec all_auth_states() :: [auth_state()]
  def all_auth_states do
    [
      :initial, :tgt_obtained, :service_ticket_obtained, :authenticated,
      :auth_failed
    ]
  end

  # validate_auth_state_transition removed: unproven reimplementation. The verified check lives in the
  # Idris2/Zig core; calling it needs FFI wiring not yet present in this binding.
  # Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

  # ===========================================================================
  # EncStrength (tags 0-2)
  # ===========================================================================

  @typedoc """
  EncStrength types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type enc_strength :: :strong | :medium | :weak

  @enc_strength_tags %{
    strong: 0,
    medium: 1,
    weak: 2,
  }

  @tag_to_enc_strength Map.new(@enc_strength_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `EncStrength` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Kerberos.enc_strength_from_tag(0)
      {:ok, :strong}
  """
  @spec enc_strength_from_tag(non_neg_integer()) :: {:ok, enc_strength()} | :error
  def enc_strength_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_enc_strength, tag)}
  end

  def enc_strength_from_tag(_tag), do: :error

  @doc """
  Encode a `EncStrength` to the C-ABI tag value.
  """
  @spec enc_strength_to_tag(enc_strength()) :: non_neg_integer()
  def enc_strength_to_tag(val) when is_map_key(@enc_strength_tags, val) do
    Map.fetch!(@enc_strength_tags, val)
  end

  @doc """
  All `EncStrength` variants in tag order.
  """
  @spec all_enc_strengths() :: [enc_strength()]
  def all_enc_strengths, do: [:strong, :medium, :weak]

  # ===========================================================================
  # PreAuthType (tags 0-3)
  # ===========================================================================

  @typedoc """
  PreAuthType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type pre_auth_type :: :pa_enc_timestamp | :pa_etype_info2 | :pa_fx_fast | :pa_fx_cookie

  @pre_auth_type_tags %{
    pa_enc_timestamp: 0,
    pa_etype_info2: 1,
    pa_fx_fast: 2,
    pa_fx_cookie: 3,
  }

  @tag_to_pre_auth_type Map.new(@pre_auth_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PreAuthType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Kerberos.pre_auth_type_from_tag(0)
      {:ok, :pa_enc_timestamp}
  """
  @spec pre_auth_type_from_tag(non_neg_integer()) :: {:ok, pre_auth_type()} | :error
  def pre_auth_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_pre_auth_type, tag)}
  end

  def pre_auth_type_from_tag(_tag), do: :error

  @doc """
  Encode a `PreAuthType` to the C-ABI tag value.
  """
  @spec pre_auth_type_to_tag(pre_auth_type()) :: non_neg_integer()
  def pre_auth_type_to_tag(val) when is_map_key(@pre_auth_type_tags, val) do
    Map.fetch!(@pre_auth_type_tags, val)
  end

  @doc """
  All `PreAuthType` variants in tag order.
  """
  @spec all_pre_auth_types() :: [pre_auth_type()]
  def all_pre_auth_types, do: [:pa_enc_timestamp, :pa_etype_info2, :pa_fx_fast, :pa_fx_cookie]

  # ===========================================================================
  # NegotiationState (tags 0-3)
  # ===========================================================================

  @typedoc """
  NegotiationState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type negotiation_state :: :neg_idle | :proposed | :selected | :neg_failed

  @negotiation_state_tags %{
    neg_idle: 0,
    proposed: 1,
    selected: 2,
    neg_failed: 3,
  }

  @tag_to_negotiation_state Map.new(@negotiation_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NegotiationState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Kerberos.negotiation_state_from_tag(0)
      {:ok, :neg_idle}
  """
  @spec negotiation_state_from_tag(non_neg_integer()) :: {:ok, negotiation_state()} | :error
  def negotiation_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_negotiation_state, tag)}
  end

  def negotiation_state_from_tag(_tag), do: :error

  @doc """
  Encode a `NegotiationState` to the C-ABI tag value.
  """
  @spec negotiation_state_to_tag(negotiation_state()) :: non_neg_integer()
  def negotiation_state_to_tag(val) when is_map_key(@negotiation_state_tags, val) do
    Map.fetch!(@negotiation_state_tags, val)
  end

  @doc """
  All `NegotiationState` variants in tag order.
  """
  @spec all_negotiation_states() :: [negotiation_state()]
  def all_negotiation_states, do: [:neg_idle, :proposed, :selected, :neg_failed]

end
