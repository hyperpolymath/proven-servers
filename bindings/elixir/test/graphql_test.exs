# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.GraphqlTest do
  use ExUnit.Case, async: true
  doctest ProvenServers.Graphql

  alias ProvenServers.Graphql

  describe "operation type roundtrip" do
    test "all tags 0..2 roundtrip" do
      for tag <- 0..2 do
        {:ok, op} = Graphql.operation_from_tag(tag)
        assert Graphql.operation_to_tag(op) == tag
      end
    end

    test "invalid tag returns error" do
      assert Graphql.operation_from_tag(3) == :error
    end
  end

  describe "type kind roundtrip" do
    test "all tags 0..7 roundtrip" do
      for tag <- 0..7 do
        {:ok, tk} = Graphql.type_kind_from_tag(tag)
        assert Graphql.type_kind_to_tag(tk) == tag
      end
    end

    test "invalid tag returns error" do
      assert Graphql.type_kind_from_tag(8) == :error
    end
  end

  describe "type kind classification" do
    test "wrapper types" do
      assert Graphql.type_kind_wrapper?(:list)
      assert Graphql.type_kind_wrapper?(:non_null)
      refute Graphql.type_kind_wrapper?(:scalar)
    end

    test "composite types" do
      assert Graphql.type_kind_composite?(:object)
      assert Graphql.type_kind_composite?(:interface)
      assert Graphql.type_kind_composite?(:union)
      refute Graphql.type_kind_composite?(:scalar)
      refute Graphql.type_kind_composite?(:enum)
    end
  end

  describe "directive location roundtrip" do
    test "all tags 0..17 roundtrip" do
      for tag <- 0..17 do
        {:ok, loc} = Graphql.directive_location_from_tag(tag)
        assert Graphql.directive_location_to_tag(loc) == tag
      end
    end

    test "invalid tag returns error" do
      assert Graphql.directive_location_from_tag(18) == :error
    end
  end

  describe "directive location classification" do
    test "executable locations" do
      assert Graphql.directive_location_executable?(:query)
      assert Graphql.directive_location_executable?(:field)
      assert Graphql.directive_location_executable?(:inline_fragment)
      refute Graphql.directive_location_executable?(:schema)
    end

    test "type system locations" do
      assert Graphql.directive_location_type_system?(:schema)
      assert Graphql.directive_location_type_system?(:field_definition)
      refute Graphql.directive_location_type_system?(:query)
    end
  end

  describe "error category roundtrip" do
    test "all tags 0..4 roundtrip" do
      for tag <- 0..4 do
        {:ok, ec} = Graphql.error_category_from_tag(tag)
        assert Graphql.error_category_to_tag(ec) == tag
      end
    end

    test "invalid tag returns error" do
      assert Graphql.error_category_from_tag(5) == :error
    end
  end
end
