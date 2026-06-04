# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Mix project definition for proven_servers Elixir bindings.
#
# Provides idiomatic Elixir types mirroring the Idris2 ABI definitions
# and Rust bindings for the proven-servers protocol suite.

defmodule ProvenServers.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/hyperpolymath/proven-servers"

  def project do
    [
      app: :proven_servers,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ProvenServers",
      description: "Elixir bindings for proven-servers protocol ABI types",
      source_url: @source_url,
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "ProvenServers",
      extras: ["../../README.adoc"]
    ]
  end

  defp package do
    [
      licenses: ["MPL-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
