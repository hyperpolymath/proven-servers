# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Vpn do
  @moduledoc """
  VPN (Virtual Private Network) types for the proven-servers ABI.
  
  Mirrors the Idris2 module `VpnABI.Types` and its type definitions:
  - `TunnelType`           — VPN tunnel technologies (4 constructors, tags 0-3)
  - `TunnelPhase`          — IKE/tunnel negotiation phases (7 constructors, tags 0-6)
  - `EncryptionAlgorithm`  — Encryption algorithms (6 constructors, tags 0-5)
  - `IntegrityAlgorithm`   — Integrity/MAC algorithms (5 constructors, tags 0-4)
  - `DhGroup`              — Diffie-Hellman groups (4 constructors, tags 0-3)
  - `SaLifecycle`          — Security Association lifecycle (5 constructors, tags 0-4)
  - `IkeVersion`           — IKE protocol versions (2 constructors, tags 0-1)
  - `VpnError`             — VPN error codes (6 constructors, tags 0-5)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard IKE (Internet Key Exchange) port."
  @spec ike_port() :: non_neg_integer()
  def ike_port, do: 500

  @doc "IKE NAT-Traversal port (RFC 3947)."
  @spec ike_natt_port() :: non_neg_integer()
  def ike_natt_port, do: 4500

  @doc "WireGuard default listening port."
  @spec wireguard_port() :: non_neg_integer()
  def wireguard_port, do: 51820

  @doc "OpenVPN default port."
  @spec openvpn_port() :: non_neg_integer()
  def openvpn_port, do: 1194

  # ===========================================================================
  # TunnelType (tags 0-3)
  # ===========================================================================

  @typedoc """
  TunnelType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type tunnel_type :: :ipsec | :wireguard | :openvpn | :l2tp

  @tunnel_type_tags %{
    ipsec: 0,
    wireguard: 1,
    openvpn: 2,
    l2tp: 3,
  }

  @tag_to_tunnel_type Map.new(@tunnel_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TunnelType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Vpn.tunnel_type_from_tag(0)
      {:ok, :ipsec}
  """
  @spec tunnel_type_from_tag(non_neg_integer()) :: {:ok, tunnel_type()} | :error
  def tunnel_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_tunnel_type, tag)}
  end

  def tunnel_type_from_tag(_tag), do: :error

  @doc """
  Encode a `TunnelType` to the C-ABI tag value.
  """
  @spec tunnel_type_to_tag(tunnel_type()) :: non_neg_integer()
  def tunnel_type_to_tag(val) when is_map_key(@tunnel_type_tags, val) do
    Map.fetch!(@tunnel_type_tags, val)
  end

  @doc """
  All `TunnelType` variants in tag order.
  """
  @spec all_tunnel_types() :: [tunnel_type()]
  def all_tunnel_types, do: [:ipsec, :wireguard, :openvpn, :l2tp]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this tunnel type uses IKE for key exchange.
  """
  @spec uses_ike?(tunnel_type()) :: boolean()
  def uses_ike?(val) when val in [:ipsec, :l2tp], do: true
  def uses_ike?(_val), do: false

  @doc """
  Whether this tunnel type operates at the kernel level.
  """
  @spec is_kernel_level?(tunnel_type()) :: boolean()
  def is_kernel_level?(val) when val in [:ipsec, :wireguard], do: true
  def is_kernel_level?(_val), do: false

  # ===========================================================================
  # TunnelPhase (tags 0-6)
  # ===========================================================================

  @typedoc """
  TunnelPhase types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type tunnel_phase ::
          :idle
          | :phase1_init
          | :phase1_auth
          | :phase1_done
          | :phase2_negotiating
          | :established
          | :expired

  @tunnel_phase_tags %{
    idle: 0,
    phase1_init: 1,
    phase1_auth: 2,
    phase1_done: 3,
    phase2_negotiating: 4,
    established: 5,
    expired: 6,
  }

  @tag_to_tunnel_phase Map.new(@tunnel_phase_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TunnelPhase` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Vpn.tunnel_phase_from_tag(0)
      {:ok, :idle}
  """
  @spec tunnel_phase_from_tag(non_neg_integer()) :: {:ok, tunnel_phase()} | :error
  def tunnel_phase_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_tunnel_phase, tag)}
  end

  def tunnel_phase_from_tag(_tag), do: :error

  @doc """
  Encode a `TunnelPhase` to the C-ABI tag value.
  """
  @spec tunnel_phase_to_tag(tunnel_phase()) :: non_neg_integer()
  def tunnel_phase_to_tag(val) when is_map_key(@tunnel_phase_tags, val) do
    Map.fetch!(@tunnel_phase_tags, val)
  end

  @doc """
  All `TunnelPhase` variants in tag order.
  """
  @spec all_tunnel_phases() :: [tunnel_phase()]
  def all_tunnel_phases do
    [
      :idle, :phase1_init, :phase1_auth, :phase1_done, :phase2_negotiating,
      :established, :expired
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the tunnel is carrying traffic.
  """
  @spec is_established?(tunnel_phase()) :: boolean()
  def is_established?(val) when val in [:established], do: true
  def is_established?(_val), do: false

  @doc """
  Whether negotiation is in progress.
  """
  @spec is_negotiating?(tunnel_phase()) :: boolean()
  def is_negotiating?(val) when val in [:phase1_init, :phase1_auth, :phase2_negotiating], do: true
  def is_negotiating?(_val), do: false

  @doc """
  Whether Phase 1 (IKE SA) is complete.
  """
  @spec phase1_complete?(tunnel_phase()) :: boolean()
  def phase1_complete?(val) when val in [:phase1_done, :phase2_negotiating, :established], do: true
  def phase1_complete?(_val), do: false

  # ===========================================================================
  # EncryptionAlgorithm (tags 0-5)
  # ===========================================================================

  @typedoc """
  EncryptionAlgorithm types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type encryption_algorithm ::
          :aes128_cbc
          | :aes256_cbc
          | :aes128_gcm
          | :aes256_gcm
          | :chacha20_poly1305
          | :null_cipher

  @encryption_algorithm_tags %{
    aes128_cbc: 0,
    aes256_cbc: 1,
    aes128_gcm: 2,
    aes256_gcm: 3,
    chacha20_poly1305: 4,
    null_cipher: 5,
  }

  @tag_to_encryption_algorithm Map.new(@encryption_algorithm_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `EncryptionAlgorithm` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Vpn.encryption_algorithm_from_tag(0)
      {:ok, :aes128_cbc}
  """
  @spec encryption_algorithm_from_tag(non_neg_integer()) :: {:ok, encryption_algorithm()} | :error
  def encryption_algorithm_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_encryption_algorithm, tag)}
  end

  def encryption_algorithm_from_tag(_tag), do: :error

  @doc """
  Encode a `EncryptionAlgorithm` to the C-ABI tag value.
  """
  @spec encryption_algorithm_to_tag(encryption_algorithm()) :: non_neg_integer()
  def encryption_algorithm_to_tag(val) when is_map_key(@encryption_algorithm_tags, val) do
    Map.fetch!(@encryption_algorithm_tags, val)
  end

  @doc """
  All `EncryptionAlgorithm` variants in tag order.
  """
  @spec all_encryption_algorithms() :: [encryption_algorithm()]
  def all_encryption_algorithms do
    [
      :aes128_cbc, :aes256_cbc, :aes128_gcm, :aes256_gcm, :chacha20_poly1305,
      :null_cipher
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this algorithm provides authenticated encryption (AEAD).
  """
  @spec is_aead?(encryption_algorithm()) :: boolean()
  def is_aead?(val) when val in [:aes128_gcm, :aes256_gcm, :chacha20_poly1305], do: true
  def is_aead?(_val), do: false

  @doc """
  Whether this algorithm actually encrypts data.
  """
  @spec provides_confidentiality?(encryption_algorithm()) :: boolean()
  def provides_confidentiality?(val) when val in [:null_cipher], do: false
  def provides_confidentiality?(_val), do: true

  # ===========================================================================
  # IntegrityAlgorithm (tags 0-4)
  # ===========================================================================

  @typedoc """
  IntegrityAlgorithm types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type integrity_algorithm ::
          :hmac_sha1
          | :hmac_sha256
          | :hmac_sha384
          | :hmac_sha512
          | :no_integrity

  @integrity_algorithm_tags %{
    hmac_sha1: 0,
    hmac_sha256: 1,
    hmac_sha384: 2,
    hmac_sha512: 3,
    no_integrity: 4,
  }

  @tag_to_integrity_algorithm Map.new(@integrity_algorithm_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `IntegrityAlgorithm` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Vpn.integrity_algorithm_from_tag(0)
      {:ok, :hmac_sha1}
  """
  @spec integrity_algorithm_from_tag(non_neg_integer()) :: {:ok, integrity_algorithm()} | :error
  def integrity_algorithm_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_integrity_algorithm, tag)}
  end

  def integrity_algorithm_from_tag(_tag), do: :error

  @doc """
  Encode a `IntegrityAlgorithm` to the C-ABI tag value.
  """
  @spec integrity_algorithm_to_tag(integrity_algorithm()) :: non_neg_integer()
  def integrity_algorithm_to_tag(val) when is_map_key(@integrity_algorithm_tags, val) do
    Map.fetch!(@integrity_algorithm_tags, val)
  end

  @doc """
  All `IntegrityAlgorithm` variants in tag order.
  """
  @spec all_integrity_algorithms() :: [integrity_algorithm()]
  def all_integrity_algorithms, do: [:hmac_sha1, :hmac_sha256, :hmac_sha384, :hmac_sha512, :no_integrity]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this algorithm provides integrity protection.
  """
  @spec provides_integrity?(integrity_algorithm()) :: boolean()
  def provides_integrity?(val) when val in [:no_integrity], do: false
  def provides_integrity?(_val), do: true

  # ===========================================================================
  # DhGroup (tags 0-3)
  # ===========================================================================

  @typedoc """
  DhGroup types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type dh_group :: :dh14 | :ecp256 | :ecp384 | :curve25519

  @dh_group_tags %{
    dh14: 0,
    ecp256: 1,
    ecp384: 2,
    curve25519: 3,
  }

  @tag_to_dh_group Map.new(@dh_group_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DhGroup` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Vpn.dh_group_from_tag(0)
      {:ok, :dh14}
  """
  @spec dh_group_from_tag(non_neg_integer()) :: {:ok, dh_group()} | :error
  def dh_group_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_dh_group, tag)}
  end

  def dh_group_from_tag(_tag), do: :error

  @doc """
  Encode a `DhGroup` to the C-ABI tag value.
  """
  @spec dh_group_to_tag(dh_group()) :: non_neg_integer()
  def dh_group_to_tag(val) when is_map_key(@dh_group_tags, val) do
    Map.fetch!(@dh_group_tags, val)
  end

  @doc """
  All `DhGroup` variants in tag order.
  """
  @spec all_dh_groups() :: [dh_group()]
  def all_dh_groups, do: [:dh14, :ecp256, :ecp384, :curve25519]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this group uses elliptic curve cryptography.
  """
  @spec is_ecc?(dh_group()) :: boolean()
  def is_ecc?(val) when val in [:ecp256, :ecp384, :curve25519], do: true
  def is_ecc?(_val), do: false

  # ===========================================================================
  # SaLifecycle (tags 0-4)
  # ===========================================================================

  @typedoc """
  SaLifecycle types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type sa_lifecycle :: :none | :active | :rekeying | :expired | :deleted

  @sa_lifecycle_tags %{
    none: 0,
    active: 1,
    rekeying: 2,
    expired: 3,
    deleted: 4,
  }

  @tag_to_sa_lifecycle Map.new(@sa_lifecycle_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SaLifecycle` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Vpn.sa_lifecycle_from_tag(0)
      {:ok, :none}
  """
  @spec sa_lifecycle_from_tag(non_neg_integer()) :: {:ok, sa_lifecycle()} | :error
  def sa_lifecycle_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_sa_lifecycle, tag)}
  end

  def sa_lifecycle_from_tag(_tag), do: :error

  @doc """
  Encode a `SaLifecycle` to the C-ABI tag value.
  """
  @spec sa_lifecycle_to_tag(sa_lifecycle()) :: non_neg_integer()
  def sa_lifecycle_to_tag(val) when is_map_key(@sa_lifecycle_tags, val) do
    Map.fetch!(@sa_lifecycle_tags, val)
  end

  @doc """
  All `SaLifecycle` variants in tag order.
  """
  @spec all_sa_lifecycles() :: [sa_lifecycle()]
  def all_sa_lifecycles, do: [:none, :active, :rekeying, :expired, :deleted]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the SA is usable for traffic.
  """
  @spec is_usable?(sa_lifecycle()) :: boolean()
  def is_usable?(val) when val in [:active, :rekeying], do: true
  def is_usable?(_val), do: false

  @doc """
  Whether the SA has been terminated.
  """
  @spec is_terminated?(sa_lifecycle()) :: boolean()
  def is_terminated?(val) when val in [:expired, :deleted], do: true
  def is_terminated?(_val), do: false

  # ===========================================================================
  # IkeVersion (tags 0-1)
  # ===========================================================================

  @typedoc """
  IkeVersion types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type ike_version :: :v1 | :v2

  @ike_version_tags %{
    v1: 0,
    v2: 1,
  }

  @tag_to_ike_version Map.new(@ike_version_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `IkeVersion` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Vpn.ike_version_from_tag(0)
      {:ok, :v1}
  """
  @spec ike_version_from_tag(non_neg_integer()) :: {:ok, ike_version()} | :error
  def ike_version_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_ike_version, tag)}
  end

  def ike_version_from_tag(_tag), do: :error

  @doc """
  Encode a `IkeVersion` to the C-ABI tag value.
  """
  @spec ike_version_to_tag(ike_version()) :: non_neg_integer()
  def ike_version_to_tag(val) when is_map_key(@ike_version_tags, val) do
    Map.fetch!(@ike_version_tags, val)
  end

  @doc """
  All `IkeVersion` variants in tag order.
  """
  @spec all_ike_versions() :: [ike_version()]
  def all_ike_versions, do: [:v1, :v2]

  # ===========================================================================
  # VpnError (tags 0-5)
  # ===========================================================================

  @typedoc """
  VpnError types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type vpn_error ::
          :authentication_failed
          | :no_proposal_chosen
          | :lifetime_expired
          | :invalid_spi
          | :replay_detected
          | :negotiation_timeout

  @vpn_error_tags %{
    authentication_failed: 0,
    no_proposal_chosen: 1,
    lifetime_expired: 2,
    invalid_spi: 3,
    replay_detected: 4,
    negotiation_timeout: 5,
  }

  @tag_to_vpn_error Map.new(@vpn_error_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `VpnError` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Vpn.vpn_error_from_tag(0)
      {:ok, :authentication_failed}
  """
  @spec vpn_error_from_tag(non_neg_integer()) :: {:ok, vpn_error()} | :error
  def vpn_error_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_vpn_error, tag)}
  end

  def vpn_error_from_tag(_tag), do: :error

  @doc """
  Encode a `VpnError` to the C-ABI tag value.
  """
  @spec vpn_error_to_tag(vpn_error()) :: non_neg_integer()
  def vpn_error_to_tag(val) when is_map_key(@vpn_error_tags, val) do
    Map.fetch!(@vpn_error_tags, val)
  end

  @doc """
  All `VpnError` variants in tag order.
  """
  @spec all_vpn_errors() :: [vpn_error()]
  def all_vpn_errors do
    [
      :authentication_failed, :no_proposal_chosen, :lifetime_expired,
      :invalid_spi, :replay_detected, :negotiation_timeout
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this error indicates a security concern.
  """
  @spec is_security_concern?(vpn_error()) :: boolean()
  def is_security_concern?(val) when val in [:authentication_failed, :invalid_spi, :replay_detected], do: true
  def is_security_concern?(_val), do: false

  @doc """
  Whether this error is likely transient and retryable.
  """
  @spec is_retryable?(vpn_error()) :: boolean()
  def is_retryable?(val) when val in [:negotiation_timeout, :lifetime_expired], do: true
  def is_retryable?(_val), do: false

end
