# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Ca do
  @moduledoc """
  Certificate Authority types for the proven-servers ABI.
  
  Formally verified PKI/CA types.
  Mirrors the Idris2 module `CaABI.Types`.
  
  - `CertType` -- X.509 certificate types.
  - `KeyAlgorithm` -- Cryptographic key algorithms.
  - `SignatureAlgorithm` -- Cryptographic signature algorithms.
  - `CertState` -- Certificate lifecycle states.
  - `RevocationReason` -- Certificate revocation reasons (RFC 5280).
  - `CrlStatus` -- CRL status.
  - `OcspStatus` -- OCSP response status.
  - `Extension` -- X.509 extension types.
  - `KeyUsageBit` -- Key usage bit flags (RFC 5280).
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard CA API port."
  @spec ca_port() :: non_neg_integer()
  def ca_port, do: 8443

  # ===========================================================================
  # CertType (tags 0-6)
  # ===========================================================================

  @typedoc """
  CertType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type cert_type ::
          :root
          | :intermediate
          | :end_entity
          | :cross_signed
          | :code_signing
          | :email_protection
          | :ocsp_signing

  @cert_type_tags %{
    root: 0,
    intermediate: 1,
    end_entity: 2,
    cross_signed: 3,
    code_signing: 4,
    email_protection: 5,
    ocsp_signing: 6,
  }

  @tag_to_cert_type Map.new(@cert_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `CertType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ca.cert_type_from_tag(0)
      {:ok, :root}
  """
  @spec cert_type_from_tag(non_neg_integer()) :: {:ok, cert_type()} | :error
  def cert_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_cert_type, tag)}
  end

  def cert_type_from_tag(_tag), do: :error

  @doc """
  Encode a `CertType` to the C-ABI tag value.
  """
  @spec cert_type_to_tag(cert_type()) :: non_neg_integer()
  def cert_type_to_tag(val) when is_map_key(@cert_type_tags, val) do
    Map.fetch!(@cert_type_tags, val)
  end

  @doc """
  All `CertType` variants in tag order.
  """
  @spec all_cert_types() :: [cert_type()]
  def all_cert_types do
    [
      :root, :intermediate, :end_entity, :cross_signed, :code_signing,
      :email_protection, :ocsp_signing
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this certificate type is a CA certificate.
  """
  @spec is_ca?(cert_type()) :: boolean()
  def is_ca?(val) when val in [:root, :intermediate, :cross_signed], do: true
  def is_ca?(_val), do: false

  # ===========================================================================
  # KeyAlgorithm (tags 0-5)
  # ===========================================================================

  @typedoc """
  KeyAlgorithm types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type key_algorithm :: :rsa2048 | :rsa4096 | :ecdsa_p256 | :ecdsa_p384 | :ed25519 | :ed448

  @key_algorithm_tags %{
    rsa2048: 0,
    rsa4096: 1,
    ecdsa_p256: 2,
    ecdsa_p384: 3,
    ed25519: 4,
    ed448: 5,
  }

  @tag_to_key_algorithm Map.new(@key_algorithm_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `KeyAlgorithm` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ca.key_algorithm_from_tag(0)
      {:ok, :rsa2048}
  """
  @spec key_algorithm_from_tag(non_neg_integer()) :: {:ok, key_algorithm()} | :error
  def key_algorithm_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_key_algorithm, tag)}
  end

  def key_algorithm_from_tag(_tag), do: :error

  @doc """
  Encode a `KeyAlgorithm` to the C-ABI tag value.
  """
  @spec key_algorithm_to_tag(key_algorithm()) :: non_neg_integer()
  def key_algorithm_to_tag(val) when is_map_key(@key_algorithm_tags, val) do
    Map.fetch!(@key_algorithm_tags, val)
  end

  @doc """
  All `KeyAlgorithm` variants in tag order.
  """
  @spec all_key_algorithms() :: [key_algorithm()]
  def all_key_algorithms, do: [:rsa2048, :rsa4096, :ecdsa_p256, :ecdsa_p384, :ed25519, :ed448]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this is an RSA algorithm.
  """
  @spec is_rsa?(key_algorithm()) :: boolean()
  def is_rsa?(val) when val in [:rsa2048, :rsa4096], do: true
  def is_rsa?(_val), do: false

  @doc """
  Whether this is an elliptic curve algorithm.
  """
  @spec is_elliptic_curve?(key_algorithm()) :: boolean()
  def is_elliptic_curve?(val) when val in [:ecdsa_p256, :ecdsa_p384, :ed25519, :ed448], do: true
  def is_elliptic_curve?(_val), do: false

  # ===========================================================================
  # SignatureAlgorithm (tags 0-6)
  # ===========================================================================

  @typedoc """
  SignatureAlgorithm types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type signature_algorithm ::
          :sha256_with_rsa
          | :sha384_with_rsa
          | :sha512_with_rsa
          | :sha256_with_ecdsa
          | :sha384_with_ecdsa
          | :pure_ed25519
          | :pure_ed448

  @signature_algorithm_tags %{
    sha256_with_rsa: 0,
    sha384_with_rsa: 1,
    sha512_with_rsa: 2,
    sha256_with_ecdsa: 3,
    sha384_with_ecdsa: 4,
    pure_ed25519: 5,
    pure_ed448: 6,
  }

  @tag_to_signature_algorithm Map.new(@signature_algorithm_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SignatureAlgorithm` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ca.signature_algorithm_from_tag(0)
      {:ok, :sha256_with_rsa}
  """
  @spec signature_algorithm_from_tag(non_neg_integer()) :: {:ok, signature_algorithm()} | :error
  def signature_algorithm_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_signature_algorithm, tag)}
  end

  def signature_algorithm_from_tag(_tag), do: :error

  @doc """
  Encode a `SignatureAlgorithm` to the C-ABI tag value.
  """
  @spec signature_algorithm_to_tag(signature_algorithm()) :: non_neg_integer()
  def signature_algorithm_to_tag(val) when is_map_key(@signature_algorithm_tags, val) do
    Map.fetch!(@signature_algorithm_tags, val)
  end

  @doc """
  All `SignatureAlgorithm` variants in tag order.
  """
  @spec all_signature_algorithms() :: [signature_algorithm()]
  def all_signature_algorithms do
    [
      :sha256_with_rsa, :sha384_with_rsa, :sha512_with_rsa, :sha256_with_ecdsa,
      :sha384_with_ecdsa, :pure_ed25519, :pure_ed448
    ]
  end

  # ===========================================================================
  # CertState (tags 0-4)
  # ===========================================================================

  @typedoc """
  CertState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type cert_state :: :pending | :active | :revoked | :expired | :suspended

  @cert_state_tags %{
    pending: 0,
    active: 1,
    revoked: 2,
    expired: 3,
    suspended: 4,
  }

  @tag_to_cert_state Map.new(@cert_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `CertState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ca.cert_state_from_tag(0)
      {:ok, :pending}
  """
  @spec cert_state_from_tag(non_neg_integer()) :: {:ok, cert_state()} | :error
  def cert_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_cert_state, tag)}
  end

  def cert_state_from_tag(_tag), do: :error

  @doc """
  Encode a `CertState` to the C-ABI tag value.
  """
  @spec cert_state_to_tag(cert_state()) :: non_neg_integer()
  def cert_state_to_tag(val) when is_map_key(@cert_state_tags, val) do
    Map.fetch!(@cert_state_tags, val)
  end

  @doc """
  All `CertState` variants in tag order.
  """
  @spec all_cert_states() :: [cert_state()]
  def all_cert_states, do: [:pending, :active, :revoked, :expired, :suspended]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the certificate can be used.
  """
  @spec is_usable?(cert_state()) :: boolean()
  def is_usable?(val) when val in [:active], do: true
  def is_usable?(_val), do: false

  # ===========================================================================
  # RevocationReason (tags 0-6)
  # ===========================================================================

  @typedoc """
  RevocationReason types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type revocation_reason ::
          :unspecified
          | :key_compromise
          | :ca_compromise
          | :affiliation_changed
          | :superseded
          | :cessation_of_operation
          | :certificate_hold

  @revocation_reason_tags %{
    unspecified: 0,
    key_compromise: 1,
    ca_compromise: 2,
    affiliation_changed: 3,
    superseded: 4,
    cessation_of_operation: 5,
    certificate_hold: 6,
  }

  @tag_to_revocation_reason Map.new(@revocation_reason_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `RevocationReason` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ca.revocation_reason_from_tag(0)
      {:ok, :unspecified}
  """
  @spec revocation_reason_from_tag(non_neg_integer()) :: {:ok, revocation_reason()} | :error
  def revocation_reason_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_revocation_reason, tag)}
  end

  def revocation_reason_from_tag(_tag), do: :error

  @doc """
  Encode a `RevocationReason` to the C-ABI tag value.
  """
  @spec revocation_reason_to_tag(revocation_reason()) :: non_neg_integer()
  def revocation_reason_to_tag(val) when is_map_key(@revocation_reason_tags, val) do
    Map.fetch!(@revocation_reason_tags, val)
  end

  @doc """
  All `RevocationReason` variants in tag order.
  """
  @spec all_revocation_reasons() :: [revocation_reason()]
  def all_revocation_reasons do
    [
      :unspecified, :key_compromise, :ca_compromise, :affiliation_changed,
      :superseded, :cessation_of_operation, :certificate_hold
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this revocation indicates a security incident.
  """
  @spec is_security_incident?(revocation_reason()) :: boolean()
  def is_security_incident?(val) when val in [:key_compromise, :ca_compromise], do: true
  def is_security_incident?(_val), do: false

  # ===========================================================================
  # CrlStatus (tags 0-3)
  # ===========================================================================

  @typedoc """
  CrlStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type crl_status :: :current | :crl_expired | :crl_pending | :crl_error

  @crl_status_tags %{
    current: 0,
    crl_expired: 1,
    crl_pending: 2,
    crl_error: 3,
  }

  @tag_to_crl_status Map.new(@crl_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `CrlStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ca.crl_status_from_tag(0)
      {:ok, :current}
  """
  @spec crl_status_from_tag(non_neg_integer()) :: {:ok, crl_status()} | :error
  def crl_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_crl_status, tag)}
  end

  def crl_status_from_tag(_tag), do: :error

  @doc """
  Encode a `CrlStatus` to the C-ABI tag value.
  """
  @spec crl_status_to_tag(crl_status()) :: non_neg_integer()
  def crl_status_to_tag(val) when is_map_key(@crl_status_tags, val) do
    Map.fetch!(@crl_status_tags, val)
  end

  @doc """
  All `CrlStatus` variants in tag order.
  """
  @spec all_crl_statuss() :: [crl_status()]
  def all_crl_statuss, do: [:current, :crl_expired, :crl_pending, :crl_error]

  # ===========================================================================
  # OcspStatus (tags 0-3)
  # ===========================================================================

  @typedoc """
  OcspStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type ocsp_status :: :good | :ocsp_revoked | :unknown | :unavailable

  @ocsp_status_tags %{
    good: 0,
    ocsp_revoked: 1,
    unknown: 2,
    unavailable: 3,
  }

  @tag_to_ocsp_status Map.new(@ocsp_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `OcspStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ca.ocsp_status_from_tag(0)
      {:ok, :good}
  """
  @spec ocsp_status_from_tag(non_neg_integer()) :: {:ok, ocsp_status()} | :error
  def ocsp_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_ocsp_status, tag)}
  end

  def ocsp_status_from_tag(_tag), do: :error

  @doc """
  Encode a `OcspStatus` to the C-ABI tag value.
  """
  @spec ocsp_status_to_tag(ocsp_status()) :: non_neg_integer()
  def ocsp_status_to_tag(val) when is_map_key(@ocsp_status_tags, val) do
    Map.fetch!(@ocsp_status_tags, val)
  end

  @doc """
  All `OcspStatus` variants in tag order.
  """
  @spec all_ocsp_statuss() :: [ocsp_status()]
  def all_ocsp_statuss, do: [:good, :ocsp_revoked, :unknown, :unavailable]

  # ===========================================================================
  # Extension (tags 0-5)
  # ===========================================================================

  @typedoc """
  Extension types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type extension ::
          :basic_constraints
          | :key_usage
          | :ext_key_usage
          | :subject_alt_name
          | :authority_info_access
          | :crl_distribution_points

  @extension_tags %{
    basic_constraints: 0,
    key_usage: 1,
    ext_key_usage: 2,
    subject_alt_name: 3,
    authority_info_access: 4,
    crl_distribution_points: 5,
  }

  @tag_to_extension Map.new(@extension_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Extension` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ca.extension_from_tag(0)
      {:ok, :basic_constraints}
  """
  @spec extension_from_tag(non_neg_integer()) :: {:ok, extension()} | :error
  def extension_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_extension, tag)}
  end

  def extension_from_tag(_tag), do: :error

  @doc """
  Encode a `Extension` to the C-ABI tag value.
  """
  @spec extension_to_tag(extension()) :: non_neg_integer()
  def extension_to_tag(val) when is_map_key(@extension_tags, val) do
    Map.fetch!(@extension_tags, val)
  end

  @doc """
  All `Extension` variants in tag order.
  """
  @spec all_extensions() :: [extension()]
  def all_extensions do
    [
      :basic_constraints, :key_usage, :ext_key_usage, :subject_alt_name,
      :authority_info_access, :crl_distribution_points
    ]
  end

  # ===========================================================================
  # KeyUsageBit (tags 0-8)
  # ===========================================================================

  @typedoc """
  KeyUsageBit types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type key_usage_bit ::
          :digital_signature
          | :non_repudiation
          | :key_encipherment
          | :data_encipherment
          | :key_agreement
          | :key_cert_sign
          | :crl_sign
          | :encipher_only
          | :decipher_only

  @key_usage_bit_tags %{
    digital_signature: 0,
    non_repudiation: 1,
    key_encipherment: 2,
    data_encipherment: 3,
    key_agreement: 4,
    key_cert_sign: 5,
    crl_sign: 6,
    encipher_only: 7,
    decipher_only: 8,
  }

  @tag_to_key_usage_bit Map.new(@key_usage_bit_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `KeyUsageBit` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..8, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ca.key_usage_bit_from_tag(0)
      {:ok, :digital_signature}
  """
  @spec key_usage_bit_from_tag(non_neg_integer()) :: {:ok, key_usage_bit()} | :error
  def key_usage_bit_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_key_usage_bit, tag)}
  end

  def key_usage_bit_from_tag(_tag), do: :error

  @doc """
  Encode a `KeyUsageBit` to the C-ABI tag value.
  """
  @spec key_usage_bit_to_tag(key_usage_bit()) :: non_neg_integer()
  def key_usage_bit_to_tag(val) when is_map_key(@key_usage_bit_tags, val) do
    Map.fetch!(@key_usage_bit_tags, val)
  end

  @doc """
  All `KeyUsageBit` variants in tag order.
  """
  @spec all_key_usage_bits() :: [key_usage_bit()]
  def all_key_usage_bits do
    [
      :digital_signature, :non_repudiation, :key_encipherment, :data_encipherment,
      :key_agreement, :key_cert_sign, :crl_sign, :encipher_only, :decipher_only,
    ]
  end

end
