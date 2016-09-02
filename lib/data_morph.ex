defmodule DataMorph do
  @moduledoc ~S"""
  Create Elixir structs from data.

  ## Example

  Define a struct and return stream of structs created from a `tsv` string, a
  `namespace` atom and `name` string.

      iex> "name\tiso\n" <>
      ...> "New Zealand\tnz\n" <>
      ...> "United Kingdom\tgb" \
      ...> |> DataMorph.structs_from_tsv(OpenRegister, "country") \
      ...> |> Enum.to_list
      [
        %OpenRegister.Country{iso: "nz", name: "New Zealand"},
        %OpenRegister.Country{iso: "gb", name: "United Kingdom"}
      ]

  """

  require DataMorph.Struct

  @doc ~S"""
  Defines a struct and returns stream of structs created from `tsv` string or
  stream, and a `namespace` and `name`.

  Redefines struct when called again with same `namespace` and `name` but
  different fields. It sets struct fields to be the union of the old and new
  fields.

  ## Example

  Define a struct and return stream of structs created from a `tsv` stream, and
  a `namespace` string and `name` atom.

      iex> "name\tiso\n" <>
      ...> "New Zealand\tnz\n" <>
      ...> "United Kingdom\tgb" \
      ...> |> String.split("\n") \
      ...> |> Stream.map(& &1) \
      ...> |> DataMorph.structs_from_tsv("open-register", :iso_country) \
      ...> |> Enum.to_list
      [
        %OpenRegister.IsoCountry{iso: "nz", name: "New Zealand"},
        %OpenRegister.IsoCountry{iso: "gb", name: "United Kingdom"}
      ]

  ## Example

  Add additional new fields to struct when called again with different `tsv`.

      iex> "name\tiso\n" <>
      ...> "New Zealand\tnz\n" <>
      ...> "United Kingdom\tgb" \
      ...> |> DataMorph.structs_from_tsv(OpenRegister, "country") \
      ...> |> Enum.to_list
      ...>
      ...> "name\tacronym\n" <>
      ...> "New Zealand\tNZ\n" <>
      ...> "United Kingdom\tUK" \
      ...> |> DataMorph.structs_from_tsv(OpenRegister, "country") \
      ...> |> Enum.to_list
      [
        %OpenRegister.Country{acronym: "NZ", iso: nil, name: "New Zealand"},
        %OpenRegister.Country{acronym: "UK", iso: nil, name: "United Kingdom"}
      ]

  ## Parmeters

   - `tsv`: TSV stream or string
   - `namespace`: string or atom to form first part of struct alias
   - `name`: string or atom to form last part of struct alias
  """
  def structs_from_tsv tsv, namespace, name do
    {headers, rows} = tsv
      |> DataMorph.Csv.to_headers_and_rows_stream(separator: ?\t)

    rows
    |> DataMorph.Struct.from_rows(namespace, name, headers)
  end

  @doc ~S"""
  Defines a struct and returns stream of structs created from `csv` string or
  stream, and a `namespace` and `name`.

  See `structs_from_tsv/3` for examples.

  ## Parmeters

   - `csv`: CSV stream or string
   - `namespace`: string or atom to form first part of struct alias
   - `name`: string or atom to form last part of struct alias
  """
  def structs_from_csv csv, namespace, name do
    {headers, rows} = csv
      |> DataMorph.Csv.to_headers_and_rows_stream

    rows
    |> DataMorph.Struct.from_rows(namespace, name, headers)
  end

  @doc ~S"""
  Takes stream and applies filter `regexp` when not nil, and takes `count` when
  not nil.

  ## Parmeters
   - `stream`: stream of string lines
   - `regex`: nil or regexp to match lines via Stream.filter/2 and String.match?/2
   - `count`: optional take count to apply via Stream.take/2
  """
  def filter_and_take(stream, regex, count \\ nil) do
    DataMorph.Stream.filter_and_take stream, regex, count
  end

  @doc ~S"""
  Encode stream of to TSV and write to standard out.

  ## Example

  Write to standard out stream of string lists as TSV lines.

      iex> "name\tiso\n" <>
      ...> "New Zealand\tnz\n" <>
      ...> "United Kingdom\tgb" \
      ...> |> String.split("\n") \
      ...> |> DataMorph.structs_from_tsv("open-register", :iso_country) \
      ...> |> Stream.map(& [&1.iso, &1.name]) \
      ...> DataMorph.puts_tsv
      nz\tNew Zealand
      gb\tUnited Kingdom
  """
  def puts_tsv(stream) do
    stream
    |> CSV.encode(separator: ?\t, delimiter: "\n")
    |> Enum.each(& IO.write/1)
  end

  @doc ~S"""
  Concat headers to stream, encode to TSV and write to standard out.

  ## Example

  Write to standard out stream of string lists as TSV lines with headers.

      iex> "name\tiso\n" <>
      ...> "New Zealand\tnz\n" <>
      ...> "United Kingdom\tgb" \
      ...> |> String.split("\n") \
      ...> |> DataMorph.structs_from_tsv("open-register", :iso_country) \
      ...> |> Stream.map(& [&1.iso, &1.name]) \
      ...> DataMorph.puts_tsv("iso-code","name")
      iso-code\tname
      nz\tNew Zealand
      gb\tUnited Kingdom
  """
  def puts_tsv(stream, headers) do
    Stream.concat([headers], stream)
    |> puts_tsv
  end
end
