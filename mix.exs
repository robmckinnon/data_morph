defmodule DataMorph.Mixfile do
  use Mix.Project

  @version "0.0.9"

  def project do
    [
      app: :data_morph,
      version: @version,
      elixir: "~> 1.3 or ~> 1.4 or ~> 1.5 or ~> 1.6 or ~> 1.7 or ~> 1.8",
      description: description(),
      deps: deps(),
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      name: "DataMorph",
      docs: [source_ref: "v#{@version}", main: "DataMorph"],
      source_url: "https://github.com/robmckinnon/data_morph"
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:csv, "~> 2.3.1"},
      # Docs dependencies
      {:ex_doc, "~> 0.21.1", only: :docs, runtime: false},
      {:inch_ex, "~> 2.0", only: :docs, runtime: false},
      # Test dependencies
      {:mix_test_watch, "~> 0.9", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    Create Elixir structs, maps with atom keys, and keyword lists from CSV/TSV data.
    """
  end

  defp package do
    [
      maintainers: ["Rob McKinnon"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/robmckinnon/data_morph"},
      files: ~w(lib) ++ ~w(LICENSE mix.exs README.md CHANGELOG.md)
    ]
  end
end
