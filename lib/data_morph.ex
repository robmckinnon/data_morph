defmodule DataMorph do
  @moduledoc false

  require DataMorph.Struct

  @doc ~S"""
  Defines a struct and returns list of structs created from TSV string.

  When called a second time with different fields it does not redefine struct.

  ## Example

      iex> structs = DataMorph.Struct.structs_from_tsv(OpenRegister, "country",
      iex> "name\tiso\nNew Zealand\tnz\nUnited Kingdom\tgb")
      [%OpenRegister.Country{iso: "nz", name: "New Zealand"},
      %OpenRegister.Country{iso: "gb", name: "United Kingdom"}]
  """
  def structs_from_tsv namespace, name, tsv do
    list = DataMorph.Tsv.to_list_of_maps(tsv)

    DataMorph.Struct.from_list_of_maps namespace, name, list
  end
end
