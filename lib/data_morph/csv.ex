defmodule DataMorph.Csv do
  @moduledoc ~S"""
  Functions for converting CSV stream or string, to stream of maps.
  """

  @doc ~S"""
  Parse `csv` string or stream to stream of maps.

  ## Examples

  Convert blank string to empty stream.
      iex> DataMorph.Csv.to_stream_of_maps("") \
      iex> |> Enum.to_list
      []

  Map a string of lines separated by \n to a stream of maps with
  header row as keys:
      iex> "name,iso\n" <>
      ...> "New Zealand,nz\n" <>
      ...> "United Kingdom,gb" \
      ...> |> DataMorph.Csv.to_stream_of_maps \
      ...> |> Enum.to_list
      [
        %{"name" => "New Zealand", "iso" => "nz"},
        %{"name" => "United Kingdom", "iso" => "gb"}
      ]

  Map a stream of lines separated by \n to a stream of maps with
  header row as keys:
      iex> "name,iso\n" <>
      ...> "New Zealand,nz\n" <>
      ...> "United Kingdom,gb" \
      ...> |> String.split("\n") \
      ...> |> Stream.map(& &1) \
      ...> |> DataMorph.Csv.to_stream_of_maps \
      ...> |> Enum.to_list
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
