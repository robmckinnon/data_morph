defmodule DataMorph.Tsv do
  @moduledoc false

  @doc ~S"""
  Parse tsv string to list of maps.

  ## Examples

      iex> DataMorph.Tsv.to_list_of_maps("")
      []

      iex> DataMorph.Tsv.to_list_of_maps("name\tiso\nNew Zealand\tnz\nUnited Kingdom\tgb")
      [
        %{"name" => "New Zealand", "iso" => "nz"},
        %{"name" => "United Kingdom", "iso" => "gb"}
      ]

  """
  def to_list_of_maps(""), do: []
  def to_list_of_maps tsv do
    tsv
      |> String.split("\n")
      |> Stream.map(&(&1))
      |> CSV.decode(separator: ?\t, headers: true)
      |> Enum.to_list
  end
end
