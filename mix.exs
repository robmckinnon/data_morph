defmodule DataMorph.Mixfile do
  use Mix.Project

  def project do
    [app: :data_morph,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:csv, "~> 1.4.0"},
      {:maptu, ">= 0.0.0"},
      {:mix_test_watch, "~> 0.2", only: :dev},
    ]
  end
end
