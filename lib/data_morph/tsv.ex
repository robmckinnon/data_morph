defmodule DataMorph.Tsv do
  @moduledoc false

  @doc ~S"""
  Parse tsv to list of maps.

  ## Examples

  Convert blank string to empty stream.
      iex> DataMorph.Tsv.to_stream_of_maps("")
      iex> |> Enum.to_list
      []

  Map a string of lines separated by \n to a stream of maps with
  header row as keys:
      iex> string = "name\tiso\nNew Zealand\tnz\nUnited Kingdom\tgb"
      iex> DataMorph.Tsv.to_stream_of_maps(string)
      iex> |> Enum.to_list
      [
        %{"name" => "New Zealand", "iso" => "nz"},
        %{"name" => "United Kingdom", "iso" => "gb"}
      ]

  Map a stream of lines separated by \n to a stream of maps with
  header row as keys:
      iex> tsv = "name\tiso\nNew Zealand\tnz\nUnited Kingdom\tgb"
      iex> stream = tsv |> String.split("\n") |> Stream.map(&(&1))
      iex> DataMorph.Tsv.to_stream_of_maps(stream)
      iex> |> Enum.to_list
      [
        %{"name" => "New Zealand", "iso" => "nz"},
        %{"name" => "United Kingdom", "iso" => "gb"}
      ]

  """
  def to_stream_of_maps(tsv) when is_binary(tsv) do
    tsv
      |> String.split("\n")
      |> ParallelStream.map(&(&1))
      |> to_stream_of_maps
  end
  def to_stream_of_maps(tsv) do
    tsv
      |> CSV.decode(separator: ?\t, headers: true)
  end
end
