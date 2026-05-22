# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Objectstore do
  @moduledoc """
  Object Store types for the proven-servers ABI.
  
  Formally verified S3-compatible object store types.
  Mirrors the Idris2 module `ObjectstoreABI.Types`.
  
  - `Operation` -- Object store operations.
  - `StorageClass` -- Object storage classes.
  - `Acl` -- Object ACL policies.
  - `ErrorCode` -- Object store error codes.
  - `SessionState` -- Object store session states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard MinIO/S3 port."
  @spec objectstore_port() :: non_neg_integer()
  def objectstore_port, do: 9000

  # ===========================================================================
  # Operation (tags 0-11)
  # ===========================================================================

  @typedoc """
  Operation types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type operation ::
          :put_object
          | :get_object
          | :delete_object
          | :list_objects
          | :head_object
          | :copy_object
          | :create_bucket
          | :delete_bucket
          | :list_buckets
          | :init_multipart_upload
          | :upload_part
          | :complete_multipart_upload

  @operation_tags %{
    put_object: 0,
    get_object: 1,
    delete_object: 2,
    list_objects: 3,
    head_object: 4,
    copy_object: 5,
    create_bucket: 6,
    delete_bucket: 7,
    list_buckets: 8,
    init_multipart_upload: 9,
    upload_part: 10,
    complete_multipart_upload: 11,
  }

  @tag_to_operation Map.new(@operation_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Operation` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..11, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Objectstore.operation_from_tag(0)
      {:ok, :put_object}
  """
  @spec operation_from_tag(non_neg_integer()) :: {:ok, operation()} | :error
  def operation_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 11 do
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
      :put_object, :get_object, :delete_object, :list_objects, :head_object,
      :copy_object, :create_bucket, :delete_bucket, :list_buckets, :init_multipart_upload,
      :upload_part, :complete_multipart_upload
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this is a bucket-level operation.
  """
  @spec is_bucket_op?(operation()) :: boolean()
  def is_bucket_op?(val) when val in [:create_bucket, :delete_bucket, :list_buckets], do: true
  def is_bucket_op?(_val), do: false

  @doc """
  Whether this is a multipart upload operation.
  """
  @spec is_multipart?(operation()) :: boolean()
  def is_multipart?(val) when val in [:init_multipart_upload, :upload_part, :complete_multipart_upload], do: true
  def is_multipart?(_val), do: false

  # ===========================================================================
  # StorageClass (tags 0-4)
  # ===========================================================================

  @typedoc """
  StorageClass types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type storage_class :: :standard | :infrequent_access | :glacier | :deep_archive | :one_zone

  @storage_class_tags %{
    standard: 0,
    infrequent_access: 1,
    glacier: 2,
    deep_archive: 3,
    one_zone: 4,
  }

  @tag_to_storage_class Map.new(@storage_class_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `StorageClass` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Objectstore.storage_class_from_tag(0)
      {:ok, :standard}
  """
  @spec storage_class_from_tag(non_neg_integer()) :: {:ok, storage_class()} | :error
  def storage_class_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_storage_class, tag)}
  end

  def storage_class_from_tag(_tag), do: :error

  @doc """
  Encode a `StorageClass` to the C-ABI tag value.
  """
  @spec storage_class_to_tag(storage_class()) :: non_neg_integer()
  def storage_class_to_tag(val) when is_map_key(@storage_class_tags, val) do
    Map.fetch!(@storage_class_tags, val)
  end

  @doc """
  All `StorageClass` variants in tag order.
  """
  @spec all_storage_classs() :: [storage_class()]
  def all_storage_classs, do: [:standard, :infrequent_access, :glacier, :deep_archive, :one_zone]

  # ===========================================================================
  # Acl (tags 0-3)
  # ===========================================================================

  @typedoc """
  Acl types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type acl :: :private | :public_read | :public_read_write | :authenticated_read

  @acl_tags %{
    private: 0,
    public_read: 1,
    public_read_write: 2,
    authenticated_read: 3,
  }

  @tag_to_acl Map.new(@acl_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Acl` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Objectstore.acl_from_tag(0)
      {:ok, :private}
  """
  @spec acl_from_tag(non_neg_integer()) :: {:ok, acl()} | :error
  def acl_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_acl, tag)}
  end

  def acl_from_tag(_tag), do: :error

  @doc """
  Encode a `Acl` to the C-ABI tag value.
  """
  @spec acl_to_tag(acl()) :: non_neg_integer()
  def acl_to_tag(val) when is_map_key(@acl_tags, val) do
    Map.fetch!(@acl_tags, val)
  end

  @doc """
  All `Acl` variants in tag order.
  """
  @spec all_acls() :: [acl()]
  def all_acls, do: [:private, :public_read, :public_read_write, :authenticated_read]

  # ===========================================================================
  # ErrorCode (tags 0-7)
  # ===========================================================================

  @typedoc """
  ErrorCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type error_code ::
          :no_such_bucket
          | :no_such_key
          | :bucket_already_exists
          | :bucket_not_empty
          | :access_denied
          | :entity_too_large
          | :invalid_part
          | :incomplete_body

  @error_code_tags %{
    no_such_bucket: 0,
    no_such_key: 1,
    bucket_already_exists: 2,
    bucket_not_empty: 3,
    access_denied: 4,
    entity_too_large: 5,
    invalid_part: 6,
    incomplete_body: 7,
  }

  @tag_to_error_code Map.new(@error_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ErrorCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Objectstore.error_code_from_tag(0)
      {:ok, :no_such_bucket}
  """
  @spec error_code_from_tag(non_neg_integer()) :: {:ok, error_code()} | :error
  def error_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
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
      :no_such_bucket, :no_such_key, :bucket_already_exists, :bucket_not_empty,
      :access_denied, :entity_too_large, :invalid_part, :incomplete_body,
    ]
  end

  # ===========================================================================
  # SessionState (tags 0-4)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :idle | :ready | :bucket_active | :uploading | :closing

  @session_state_tags %{
    idle: 0,
    ready: 1,
    bucket_active: 2,
    uploading: 3,
    closing: 4,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Objectstore.session_state_from_tag(0)
      {:ok, :idle}
  """
  @spec session_state_from_tag(non_neg_integer()) :: {:ok, session_state()} | :error
  def session_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_session_state, tag)}
  end

  def session_state_from_tag(_tag), do: :error

  @doc """
  Encode a `SessionState` to the C-ABI tag value.
  """
  @spec session_state_to_tag(session_state()) :: non_neg_integer()
  def session_state_to_tag(val) when is_map_key(@session_state_tags, val) do
    Map.fetch!(@session_state_tags, val)
  end

  @doc """
  All `SessionState` variants in tag order.
  """
  @spec all_session_states() :: [session_state()]
  def all_session_states, do: [:idle, :ready, :bucket_active, :uploading, :closing]

end
