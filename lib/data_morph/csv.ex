defmodule DataMorph.Csv do
  @moduledoc false

  @doc ~S"""
  Parse Csv to list of maps.

  ## Examples

  Convert blank string to empty stream.
      iex> DataMorph.Csv.to_stream_of_maps("")
      iex> |> Enum.to_list
      []

  Map a string of lines separated by \n to a stream of maps with
  header row as keys:
      iex> string = "name,iso\nNew Zealand,nz\nUnited Kingdom,gb"
      iex> DataMorph.Csv.to_stream_of_maps(string)
      iex> |> Enum.to_list
      [
        %{"name" => "New Zealand", "iso" => "nz"},
        %{"name" => "United Kingdom", "iso" => "gb"}
      ]

  Map a stream of lines separated by \n to a stream of maps with
  header row as keys:
      iex> csv = "name,iso\nNew Zealand,nz\nUnited Kingdom,gb"
      iex> stream = csv |> String.split("\n") |> Stream.map(&(&1))
      iex> DataMorph.Csv.to_stream_of_maps(stream)
      iex> |> Enum.to_list
      [
        %{"name" => "New Zealand", "iso" => "nz"},
        %{"name" => "United Kingdom", "iso" => "gb"}
      ]

  """
  def to_stream_of_maps(csv) when is_binary(csv) do
    csv
      |> String.split("\n")
      |> ParallelStream.map(&(&1))
      |> to_stream_of_maps
  end
  def to_stream_of_maps(csv) do
    csv
      |> CSV.decode(headers: true)
  end
end
