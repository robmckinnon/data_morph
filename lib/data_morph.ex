defmodule DataMorph do
  @moduledoc false

  require DataMorph.Struct

  @doc ~S"""
  Defines a struct and returns stream of structs created from TSV.

  Redefines struct when called again with same namespace and name but different
  fields, sets struct fields to be the union of the old and new fields.

  ## Example

  Define a struct and return stream of structs created from a TSV string.

      iex> "name\tiso\nNew Zealand\tnz\nUnited Kingdom\tgb"
      iex> |> DataMorph.structs_from_tsv(OpenRegister, "country")
      [%OpenRegister.Country{iso: "nz", name: "New Zealand"},
      %OpenRegister.Country{iso: "gb", name: "United Kingdom"}]

  Define a struct and return stream of structs created from a TSV stream.

      iex> "name\tiso\nNew Zealand\tnz\nUnited Kingdom\tgb"
      iex> |> String.split("\n")
      iex> |> Stream.map(&(&1))
      iex> |> DataMorph.structs_from_tsv(OpenRegister, "country")
      [%OpenRegister.Country{iso: "nz", name: "New Zealand"},
      %OpenRegister.Country{iso: "gb", name: "United Kingdom"}]

  Add new fields to struct when called again with different TSV.

      iex> "name\tiso\nNew Zealand\tnz\nUnited Kingdom\tgb"
      iex> |> DataMorph.structs_from_tsv(OpenRegister, "country")
      iex> "name\tacronym\nNew Zealand\tNZ\nUnited Kingdom\tUK"
      iex> |> DataMorph.structs_from_tsv(OpenRegister, "country")
      [%OpenRegister.Country{acronym: "NZ", iso: nil, name: "New Zealand"},
      %OpenRegister.Country{acronym: "UK", iso: nil, name: "United Kingdom"}]

  """
  def structs_from_tsv tsv, namespace, name do
    DataMorph.Tsv.to_stream_of_maps(tsv)
    |> DataMorph.Struct.from_maps(namespace, name)
  end
end
