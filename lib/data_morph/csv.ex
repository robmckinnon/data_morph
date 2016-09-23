defmodule DataMorph.Csv do
  @moduledoc ~S"""
  Functions for converting CSV stream or string, to stream of rows.
  """

  @doc ~S"""
  Parse `csv` string or stream to stream of rows.

  ## Examples

  Convert blank string to empty stream.
      iex> DataMorph.Csv.to_stream_of_rows("")
      iex> |> Enum.to_list
      [[""]]

  Map a string of lines separated by \n to a stream of rows with
  header row as keys:
      iex> "name,iso\n" <>
      ...> "New Zealand,nz\n" <>
      ...> "United Kingdom,gb"
      ...> |> DataMorph.Csv.to_stream_of_rows
      ...> |> Enum.to_list
      [
        ["name","iso"],
        ["New Zealand","nz"],
        ["United Kingdom","gb"]
      ]

  Map a stream of lines separated by \n to a stream of rows with
  header row as keys:
      iex> "name,iso\n" <>
      ...> "New Zealand,nz\n" <>
      ...> "United Kingdom,gb"
      ...> |> String.split("\n")
      ...> |> Stream.map(& &1)
      ...> |> DataMorph.Csv.to_stream_of_rows
      ...> |> Enum.to_list
      [
        ["name","iso"],
        ["New Zealand","nz"],
        ["United Kingdom","gb"]
      ]

    Map a string of tab-separated lines separated by \n to a stream of rows with
    header row as keys:
        iex> "name\tiso\n" <>
        ...> "New Zealand\tnz\n" <>
        ...> "United Kingdom\tgb"
        ...> |> DataMorph.Csv.to_stream_of_rows(separator: ?\t)
        ...> |> Enum.to_list
        [
          ["name","iso"],
          ["New Zealand","nz"],
          ["United Kingdom","gb"]
        ]
  """
  def to_stream_of_rows(csv) do
    to_stream_of_rows(csv, [separator: ","])
  end
  def to_stream_of_rows(csv, options) when is_binary(csv) do
    csv
      |> String.split("\n")
      |> ParallelStream.map(&(&1))
      |> to_stream_of_rows(options)
  end
  def to_stream_of_rows(csv, options) do
    separator = options |> Keyword.get(:separator)
    case separator do
      "," -> csv |> CSV.decode()
      _ -> csv |> CSV.decode(separator: separator)
    end
  end
end
