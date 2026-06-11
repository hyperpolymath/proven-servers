# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Kms do
  @moduledoc """
  Key Management Service types for the proven-servers ABI.
  
  Formally verified KMS types (KMIP-compatible).
  Mirrors the Idris2 module `KmsABI.Types`.
  
  - `ObjectType` -- Managed cryptographic object types.
  - `Operation` -- KMS operations.
  - `KeyState` -- Key lifecycle states (KMIP).
  - `KmsAlgorithm` -- Cryptographic algorithms.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard KMIP port."
  @spec kms_port() :: non_neg_integer()
  def kms_port, do: 5696

  # ===========================================================================
  # ObjectType (tags 0-5)
  # ===========================================================================

  @typedoc """
  ObjectType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type object_type ::
          :symmetric_key
          | :public_key
          | :private_key
          | :secret_data
          | :certificate
          | :opaque_data

  @object_type_tags %{
    symmetric_key: 0,
    public_key: 1,
    private_key: 2,
    secret_data: 3,
    certificate: 4,
    opaque_data: 5,
  }

  @tag_to_object_type Map.new(@object_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ObjectType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Kms.object_type_from_tag(0)
      {:ok, :symmetric_key}
  """
  @spec object_type_from_tag(non_neg_integer()) :: {:ok, object_type()} | :error
  def object_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
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
      :symmetric_key, :public_key, :private_key, :secret_data, :certificate,
      :opaque_data
    ]
  end

  # ===========================================================================
  # Operation (tags 0-14)
  # ===========================================================================

  @typedoc """
  Operation types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type operation ::
          :create
          | :get
          | :activate
          | :revoke
          | :destroy
          | :locate
          | :register
          | :rekey
          | :encrypt
          | :decrypt
          | :sign
          | :verify
          | :wrap
          | :unwrap
          | :mac

  @operation_tags %{
    create: 0,
    get: 1,
    activate: 2,
    revoke: 3,
    destroy: 4,
    locate: 5,
    register: 6,
    rekey: 7,
    encrypt: 8,
    decrypt: 9,
    sign: 10,
    verify: 11,
    wrap: 12,
    unwrap: 13,
    mac: 14,
  }

  @tag_to_operation Map.new(@operation_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Operation` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..14, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Kms.operation_from_tag(0)
      {:ok, :create}
  """
  @spec operation_from_tag(non_neg_integer()) :: {:ok, operation()} | :error
  def operation_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 14 do
    {:ok, Map.fetch!(@tag_to_operation, tag)}
  end

  def operation_from_tag(_tag), do: :error

  @doc """
  Encode a `Operation` to the C-ABI tag value.
  """
  @spec operation_to_tag(operation()) :: non_neg_integer()
  def operation_to_tag(val) when is_map_key(@operation_tags, val) do
    Map.fetch!(@operation_tags, val)
  end

  @doc """
  All `Operation` variants in tag order.
  """
  @spec all_operations() :: [operation()]
  def all_operations do
    [
      :create, :get, :activate, :revoke, :destroy, :locate, :register,
      :rekey, :encrypt, :decrypt, :sign, :verify, :wrap, :unwrap, :mac,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this is a cryptographic operation.
  """
  @spec is_crypto_op?(operation()) :: boolean()
  def is_crypto_op?(val) when val in [:encrypt, :decrypt, :sign, :verify, :wrap, :unwrap, :mac], do: true
  def is_crypto_op?(_val), do: false

  @doc """
  Whether this is a key lifecycle operation.
  """
  @spec is_lifecycle_op?(operation()) :: boolean()
  def is_lifecycle_op?(val) when val in [:create, :activate, :revoke, :destroy, :rekey], do: true
  def is_lifecycle_op?(_val), do: false

  # ===========================================================================
  # KeyState (tags 0-5)
  # ===========================================================================

  @typedoc """
  KeyState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type key_state ::
          :pre_active
          | :active
          | :deactivated
          | :compromised
          | :destroyed
          | :destroyed_compromised

  @key_state_tags %{
    pre_active: 0,
    active: 1,
    deactivated: 2,
    compromised: 3,
    destroyed: 4,
    destroyed_compromised: 5,
  }

  @tag_to_key_state Map.new(@key_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `KeyState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Kms.key_state_from_tag(0)
      {:ok, :pre_active}
  """
  @spec key_state_from_tag(non_neg_integer()) :: {:ok, key_state()} | :error
  def key_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_key_state, tag)}
  end

  def key_state_from_tag(_tag), do: :error

  @doc """
  Encode a `KeyState` to the C-ABI tag value.
  """
  @spec key_state_to_tag(key_state()) :: non_neg_integer()
  def key_state_to_tag(val) when is_map_key(@key_state_tags, val) do
    Map.fetch!(@key_state_tags, val)
  end

  @doc """
  All `KeyState` variants in tag order.
  """
  @spec all_key_states() :: [key_state()]
  def all_key_states do
    [
      :pre_active, :active, :deactivated, :compromised, :destroyed, :destroyed_compromised,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the key can be used for cryptographic operations.
  """
  @spec is_usable?(key_state()) :: boolean()
  def is_usable?(val) when val in [:active], do: true
  def is_usable?(_val), do: false

  # ===========================================================================
  # KmsAlgorithm (tags 0-8)
  # ===========================================================================

  @typedoc """
  KmsAlgorithm types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type kms_algorithm ::
          :aes128
          | :aes256
          | :rsa2048
          | :rsa4096
          | :ecdsa_p256
          | :ecdsa_p384
          | :ed25519
          | :chacha20_poly1305
          | :hmac_sha256

  @kms_algorithm_tags %{
    aes128: 0,
    aes256: 1,
    rsa2048: 2,
    rsa4096: 3,
    ecdsa_p256: 4,
    ecdsa_p384: 5,
    ed25519: 6,
    chacha20_poly1305: 7,
    hmac_sha256: 8,
  }

  @tag_to_kms_algorithm Map.new(@kms_algorithm_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `KmsAlgorithm` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..8, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Kms.kms_algorithm_from_tag(0)
      {:ok, :aes128}
  """
  @spec kms_algorithm_from_tag(non_neg_integer()) :: {:ok, kms_algorithm()} | :error
  def kms_algorithm_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_kms_algorithm, tag)}
  end

  def kms_algorithm_from_tag(_tag), do: :error

  @doc """
  Encode a `KmsAlgorithm` to the C-ABI tag value.
  """
  @spec kms_algorithm_to_tag(kms_algorithm()) :: non_neg_integer()
  def kms_algorithm_to_tag(val) when is_map_key(@kms_algorithm_tags, val) do
    Map.fetch!(@kms_algorithm_tags, val)
  end

  @doc """
  All `KmsAlgorithm` variants in tag order.
  """
  @spec all_kms_algorithms() :: [kms_algorithm()]
  def all_kms_algorithms do
    [
      :aes128, :aes256, :rsa2048, :rsa4096, :ecdsa_p256, :ecdsa_p384,
      :ed25519, :chacha20_poly1305, :hmac_sha256
    ]
  end

end
