# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.HttpTest do
  use ExUnit.Case, async: true
  doctest ProvenServers.Http

  alias ProvenServers.Http

  describe "method tag roundtrip" do
    test "all methods roundtrip through tags" do
      for method <- Http.all_methods() do
        tag = Http.method_to_tag(method)
        assert {:ok, ^method} = Http.method_from_tag(tag)
      end
    end

    test "invalid tag returns error" do
      assert Http.method_from_tag(99) == :error
    end
  end

  describe "method parse roundtrip" do
    test "all methods roundtrip through strings" do
      for method <- Http.all_methods() do
        string = Http.method_to_string(method)
        assert {:ok, ^method} = Http.parse_method(string)
      end
    end

    test "unknown method returns error" do
      assert Http.parse_method("UNKNOWN") == :error
    end
  end

  describe "method safety classification" do
    test "safe methods" do
      assert Http.method_safe?(:get)
      assert Http.method_safe?(:head)
      refute Http.method_safe?(:post)
      refute Http.method_safe?(:delete)
    end

    test "idempotent methods" do
      assert Http.method_idempotent?(:get)
      assert Http.method_idempotent?(:put)
      assert Http.method_idempotent?(:delete)
      refute Http.method_idempotent?(:post)
      refute Http.method_idempotent?(:patch)
    end

    test "methods with body" do
      assert Http.method_has_body?(:post)
      assert Http.method_has_body?(:put)
      assert Http.method_has_body?(:patch)
      refute Http.method_has_body?(:get)
    end
  end

  describe "status code roundtrip" do
    test "all tags 0..28 roundtrip" do
      for tag <- 0..28 do
        {:ok, code} = Http.status_code_from_tag(tag)
        assert Http.status_code_to_tag(code) == tag
      end
    end
  end

  describe "status code numeric" do
    test "known numeric codes" do
      assert Http.numeric_code(:ok) == 200
      assert Http.numeric_code(:not_found) == 404
      assert Http.numeric_code(:internal_error) == 500
    end

    test "from_numeric roundtrip" do
      assert Http.status_from_numeric(200) == {:ok, :ok}
      assert Http.status_from_numeric(404) == {:ok, :not_found}
      assert Http.status_from_numeric(999) == :error
    end
  end

  describe "status category classification" do
    test "success codes" do
      assert Http.status_success?(:ok)
      assert Http.status_success?(:created)
      refute Http.status_success?(:not_found)
    end

    test "error codes" do
      assert Http.status_error?(:not_found)
      assert Http.status_error?(:internal_error)
      refute Http.status_error?(:ok)
    end

    test "redirect codes" do
      assert Http.status_redirect?(:moved_permanently)
      refute Http.status_redirect?(:ok)
    end
  end

  describe "content type roundtrip" do
    test "all tags 0..7 roundtrip" do
      for tag <- 0..7 do
        {:ok, ct} = Http.content_type_from_tag(tag)
        assert Http.content_type_to_tag(ct) == tag
      end
    end

    test "mime strings" do
      assert Http.content_type_mime(:application_json) == "application/json"
      assert Http.content_type_mime(:text_html) == "text/html"
    end
  end

  describe "version ordering" do
    test "version tags are ordered" do
      assert Http.version_to_tag(:http10) < Http.version_to_tag(:http11)
      assert Http.version_to_tag(:http11) < Http.version_to_tag(:http20)
      assert Http.version_to_tag(:http20) < Http.version_to_tag(:http30)
    end
  end
end
