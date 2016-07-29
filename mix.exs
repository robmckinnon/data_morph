defmodule DataMorph.Mixfile do
  use Mix.Project

  def project do
    [app: :data_morph,
     version: "0.0.1",
     elixir: "~> 1.3",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:csv, "~> 1.4.2"},
      {:mix_test_watch, "~> 0.2", only: :dev},
      {:parallel_stream, "~> 1.0.5"},
    ]
  end

  defp description do
    """
    Create Elixir structs from data
    """
  end

  defp package do
    [
      maintainers: ["Rob McKinnon"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/robmckinnon/data_morph" },
    ]
  end
end
