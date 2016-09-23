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
end
