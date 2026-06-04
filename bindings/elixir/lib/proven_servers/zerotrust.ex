# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Zerotrust do
  @moduledoc """
  Zero Trust types for the proven-servers ABI.
  
  Formally verified Zero Trust architecture types.
  Mirrors the Idris2 module `ZerotrustABI.Types`.
  
  - `PolicyType` -- Zero Trust policy types.
  - `IdentityConfidence` -- Identity verification confidence.
  - `DeviceTrustScore` -- Device trust assessment.
  - `AccessDecision` -- Zero Trust access decisions.
  - `ContextSignalKind` -- Context signals for trust evaluation.
  - `AuthFactor` -- Authentication factor types.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # PolicyType (tags 0-3)
  # ===========================================================================

  @typedoc """
  PolicyType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type policy_type :: :always_verify | :never_trust | :least_privilege | :micro_segmentation

  @policy_type_tags %{
    always_verify: 0,
    never_trust: 1,
    least_privilege: 2,
    micro_segmentation: 3,
  }

  @tag_to_policy_type Map.new(@policy_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PolicyType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Zerotrust.policy_type_from_tag(0)
      {:ok, :always_verify}
  """
  @spec policy_type_from_tag(non_neg_integer()) :: {:ok, policy_type()} | :error
  def policy_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_policy_type, tag)}
  end

  def policy_type_from_tag(_tag), do: :error

  @doc """
  Encode a `PolicyType` to the C-ABI tag value.
  """
  @spec policy_type_to_tag(policy_type()) :: non_neg_integer()
  def policy_type_to_tag(val) when is_map_key(@policy_type_tags, val) do
    Map.fetch!(@policy_type_tags, val)
  end

  @doc """
  All `PolicyType` variants in tag order.
  """
  @spec all_policy_types() :: [policy_type()]
  def all_policy_types, do: [:always_verify, :never_trust, :least_privilege, :micro_segmentation]

  # ===========================================================================
  # IdentityConfidence (tags 0-4)
  # ===========================================================================

  @typedoc """
  IdentityConfidence types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type identity_confidence ::
          :unverified
          | :basic_auth
          | :mfa_verified
          | :strong_auth
          | :continuous_auth

  @identity_confidence_tags %{
    unverified: 0,
    basic_auth: 1,
    mfa_verified: 2,
    strong_auth: 3,
    continuous_auth: 4,
  }

  @tag_to_identity_confidence Map.new(@identity_confidence_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `IdentityConfidence` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Zerotrust.identity_confidence_from_tag(0)
      {:ok, :unverified}
  """
  @spec identity_confidence_from_tag(non_neg_integer()) :: {:ok, identity_confidence()} | :error
  def identity_confidence_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_identity_confidence, tag)}
  end

  def identity_confidence_from_tag(_tag), do: :error

  @doc """
  Encode a `IdentityConfidence` to the C-ABI tag value.
  """
  @spec identity_confidence_to_tag(identity_confidence()) :: non_neg_integer()
  def identity_confidence_to_tag(val) when is_map_key(@identity_confidence_tags, val) do
    Map.fetch!(@identity_confidence_tags, val)
  end

  @doc """
  All `IdentityConfidence` variants in tag order.
  """
  @spec all_identity_confidences() :: [identity_confidence()]
  def all_identity_confidences do
    [
      :unverified, :basic_auth, :mfa_verified, :strong_auth, :continuous_auth,
    ]
  end

  # ===========================================================================
  # DeviceTrustScore (tags 0-4)
  # ===========================================================================

  @typedoc """
  DeviceTrustScore types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type device_trust_score ::
          :device_unknown
          | :device_partial
          | :device_compliant
          | :device_managed
          | :device_hardened

  @device_trust_score_tags %{
    device_unknown: 0,
    device_partial: 1,
    device_compliant: 2,
    device_managed: 3,
    device_hardened: 4,
  }

  @tag_to_device_trust_score Map.new(@device_trust_score_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DeviceTrustScore` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Zerotrust.device_trust_score_from_tag(0)
      {:ok, :device_unknown}
  """
  @spec device_trust_score_from_tag(non_neg_integer()) :: {:ok, device_trust_score()} | :error
  def device_trust_score_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_device_trust_score, tag)}
  end

  def device_trust_score_from_tag(_tag), do: :error

  @doc """
  Encode a `DeviceTrustScore` to the C-ABI tag value.
  """
  @spec device_trust_score_to_tag(device_trust_score()) :: non_neg_integer()
  def device_trust_score_to_tag(val) when is_map_key(@device_trust_score_tags, val) do
    Map.fetch!(@device_trust_score_tags, val)
  end

  @doc """
  All `DeviceTrustScore` variants in tag order.
  """
  @spec all_device_trust_scores() :: [device_trust_score()]
  def all_device_trust_scores do
    [
      :device_unknown, :device_partial, :device_compliant, :device_managed,
      :device_hardened
    ]
  end

  # ===========================================================================
  # AccessDecision (tags 0-3)
  # ===========================================================================

  @typedoc """
  AccessDecision types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type access_decision :: :allow | :deny | :challenge | :step_up

  @access_decision_tags %{
    allow: 0,
    deny: 1,
    challenge: 2,
    step_up: 3,
  }

  @tag_to_access_decision Map.new(@access_decision_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AccessDecision` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Zerotrust.access_decision_from_tag(0)
      {:ok, :allow}
  """
  @spec access_decision_from_tag(non_neg_integer()) :: {:ok, access_decision()} | :error
  def access_decision_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_access_decision, tag)}
  end

  def access_decision_from_tag(_tag), do: :error

  @doc """
  Encode a `AccessDecision` to the C-ABI tag value.
  """
  @spec access_decision_to_tag(access_decision()) :: non_neg_integer()
  def access_decision_to_tag(val) when is_map_key(@access_decision_tags, val) do
    Map.fetch!(@access_decision_tags, val)
  end

  @doc """
  All `AccessDecision` variants in tag order.
  """
  @spec all_access_decisions() :: [access_decision()]
  def all_access_decisions, do: [:allow, :deny, :challenge, :step_up]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether access is granted.
  """
  @spec is_granted?(access_decision()) :: boolean()
  def is_granted?(val) when val in [:allow], do: true
  def is_granted?(_val), do: false

  # ===========================================================================
  # ContextSignalKind (tags 0-4)
  # ===========================================================================

  @typedoc """
  ContextSignalKind types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type context_signal_kind :: :location | :time | :device | :behavior | :network

  @context_signal_kind_tags %{
    location: 0,
    time: 1,
    device: 2,
    behavior: 3,
    network: 4,
  }

  @tag_to_context_signal_kind Map.new(@context_signal_kind_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ContextSignalKind` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Zerotrust.context_signal_kind_from_tag(0)
      {:ok, :location}
  """
  @spec context_signal_kind_from_tag(non_neg_integer()) :: {:ok, context_signal_kind()} | :error
  def context_signal_kind_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_context_signal_kind, tag)}
  end

  def context_signal_kind_from_tag(_tag), do: :error

  @doc """
  Encode a `ContextSignalKind` to the C-ABI tag value.
  """
  @spec context_signal_kind_to_tag(context_signal_kind()) :: non_neg_integer()
  def context_signal_kind_to_tag(val) when is_map_key(@context_signal_kind_tags, val) do
    Map.fetch!(@context_signal_kind_tags, val)
  end

  @doc """
  All `ContextSignalKind` variants in tag order.
  """
  @spec all_context_signal_kinds() :: [context_signal_kind()]
  def all_context_signal_kinds, do: [:location, :time, :device, :behavior, :network]

  # ===========================================================================
  # AuthFactor (tags 0-5)
  # ===========================================================================

  @typedoc """
  AuthFactor types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type auth_factor :: :certificate | :token | :biometric | :fido2 | :totp | :push

  @auth_factor_tags %{
    certificate: 0,
    token: 1,
    biometric: 2,
    fido2: 3,
    totp: 4,
    push: 5,
  }

  @tag_to_auth_factor Map.new(@auth_factor_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AuthFactor` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Zerotrust.auth_factor_from_tag(0)
      {:ok, :certificate}
  """
  @spec auth_factor_from_tag(non_neg_integer()) :: {:ok, auth_factor()} | :error
  def auth_factor_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_auth_factor, tag)}
  end

  def auth_factor_from_tag(_tag), do: :error

  @doc """
  Encode a `AuthFactor` to the C-ABI tag value.
  """
  @spec auth_factor_to_tag(auth_factor()) :: non_neg_integer()
  def auth_factor_to_tag(val) when is_map_key(@auth_factor_tags, val) do
    Map.fetch!(@auth_factor_tags, val)
  end

  @doc """
  All `AuthFactor` variants in tag order.
  """
  @spec all_auth_factors() :: [auth_factor()]
  def all_auth_factors, do: [:certificate, :token, :biometric, :fido2, :totp, :push]

end
