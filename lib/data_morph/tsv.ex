defmodule DataMorph.Tsv do
  @moduledoc ~S"""
  Functions for converting TSV stream or string, to stream of rows.
  """

  @doc ~S"""
  Parse `tsv` string or stream to stream of rows.

  ## Examples

  Convert blank string to empty stream.
      iex> DataMorph.Tsv.to_stream_of_rows("")
      iex> |> Enum.to_list
      [[""]]

  Map a string of lines separated by \n to a stream of rows with
  header row as keys:
      iex> "name\tiso\n" <>
      ...> "New Zealand\tnz\n" <>
      ...> "United Kingdom\tgb"
      ...> |> DataMorph.Tsv.to_stream_of_rows
      ...> |> Enum.to_list
      [
        ["name","iso"],
        ["New Zealand","nz"],
        ["United Kingdom","gb"]
      ]

  Map a stream of lines separated by \n to a stream of rows with
  header row as keys:
      iex> "name\tiso\n" <>
      ...> "New Zealand\tnz\n" <>
      ...> "United Kingdom\tgb"
      ...> |> String.split("\n")
      ...> |> Stream.map(& &1)
      ...> |> DataMorph.Tsv.to_stream_of_rows
      ...> |> Enum.to_list
      [
        ["name","iso"],
        ["New Zealand","nz"],
        ["United Kingdom","gb"]
      ]

  """
  def to_stream_of_rows(tsv) when is_binary(tsv) do
    tsv
      |> String.split("\n")
      |> ParallelStream.map(&(&1))
      |> to_stream_of_rows
  end
  def to_stream_of_rows(tsv) do
    tsv
      |> CSV.decode(separator: ?\t)
  end
end
