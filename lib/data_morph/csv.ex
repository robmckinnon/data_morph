defmodule DataMorph.Csv do
  @moduledoc ~S"""
  Functions for converting CSV stream or string, to stream of rows.
  """

  @doc ~S"""
  Parse `csv` string or stream to stream of rows.

  ## Examples

  Convert blank string to empty stream.
      iex> {headers, rows} = DataMorph.Csv.to_headers_and_rows_stream("")
      ...> rows
      ...> |> Enum.to_list
      []
      ...> headers
      [""]

  Map a string of lines separated by \n to a stream of rows with
  header row as keys:
      iex> {headers, rows} = "name,iso\n" <>
      ...> "New Zealand,nz\n" <>
      ...> "United Kingdom,gb"
      ...> |> DataMorph.Csv.to_headers_and_rows_stream
      ...> rows
      ...> |> Enum.to_list
      [
        ["New Zealand","nz"],
        ["United Kingdom","gb"]
      ]
      ...> headers
      ["name","iso"]

  Map a stream of lines separated by \n to a stream of rows with
  header row as keys:
      iex> {headers, rows} = "name,iso\n" <>
      ...> "New Zealand,nz\n" <>
      ...> "United Kingdom,gb"
      ...> |> String.split("\n")
      ...> |> Stream.map(& &1)
      ...> |> DataMorph.Csv.to_headers_and_rows_stream
      ...> rows
      ...> |> Enum.to_list
      [
        ["New Zealand","nz"],
        ["United Kingdom","gb"]
      ]
      ...> headers
      ["name","iso"]

    Map a string of tab-separated lines separated by \n to a stream of rows with
    header row as keys:
        iex> {headers, rows} = "name\tiso\n" <>
        ...> "New Zealand\tnz\n" <>
        ...> "United Kingdom\tgb"
        ...> |> DataMorph.Csv.to_headers_and_rows_stream(separator: ?\t)
        ...> rows
        ...> |> Enum.to_list
        [
          ["New Zealand","nz"],
          ["United Kingdom","gb"]
        ]
        ...> headers
        ["name","iso"]
  """
  def to_headers_and_rows_stream(csv) do
    to_headers_and_rows_stream(csv, separator: ",")
  end
  def to_headers_and_rows_stream(csv, options) when is_binary(csv) do
    csv
    |> String.split("\n")
    |> to_headers_and_rows_stream(options)
  end
  def to_headers_and_rows_stream(stream, options) do
    separator = options |> Keyword.get(:separator)
    first_line = stream |> Enum.at(0)
    headers = [first_line]
      |> decode(separator)
      |> Enum.at(0)
    rows = stream |> to_rows(separator, first_line)
    {headers, rows}
  end

  defp to_rows(stream, separator, first_line) do
    stream
    |> Stream.drop_while(& &1 == first_line)
    |> decode(separator)
  end

  defp decode(stream, ","),       do: stream |> CSV.decode()
  defp decode(stream, separator), do: stream |> CSV.decode(separator: separator)
end
