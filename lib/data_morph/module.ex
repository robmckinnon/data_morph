defmodule DataMorph.Module do
  @moduledoc ~S"""
  Contains `camelize_concat/1` and `camelize_concat/2` functions that camelize
  and concatenate aliases and return a new alias.
  """

  @doc ~S"""
  Camelizes and concatenates `namespace` and `name` aliases and
  returns new alias.

  Both string and atom aliases are camelized.

  ## Examples

      iex> DataMorph.Module.camelize_concat(OpenRegister, "iso-country")
      OpenRegister.IsoCountry

      iex> DataMorph.Module.camelize_concat("open_register", "iso_country")
      OpenRegister.IsoCountry

      iex> DataMorph.Module.camelize_concat("open_register", :iso_country)
      OpenRegister.IsoCountry

      iex> DataMorph.Module.camelize_concat("", "country")
      Country

      iex> DataMorph.Module.camelize_concat(nil, Country)
      Country

      iex> DataMorph.Module.camelize_concat(nil, "iso-country")
      IsoCountry

      iex> DataMorph.Module.camelize_concat("", "iso_country")
      IsoCountry

      iex> DataMorph.Module.camelize_concat("", "isoCountry")
      IsoCountry

  """
  def camelize_concat(namespace, name) do
    [namespace, name] |> camelize_concat
  end

  @doc ~S"""
  Camelizes and concatenates a list of `aliases` and returns new
  alias.

  Both string and atom `aliases` are camelized.

  ## Examples

      iex> DataMorph.Module.camelize_concat(["open_register", "political", "iso-country"])
      OpenRegister.Political.IsoCountry
      iex> DataMorph.Module.camelize_concat(["", "political", nil])
      Political

  """
  def camelize_concat(aliases) do
    aliases
    |> camelize
    |> Module.concat
  end

  defp camelize([]), do: []
  defp camelize([head | tail]), do: [camelize(head) | camelize(tail)]
  defp camelize(nil), do: nil
  defp camelize(""), do: nil
  defp camelize(atom) when is_atom(atom), do: atom |> Atom.to_string |> camelize
  defp camelize(string) do
    string
    |> String.replace("-", "_")
    |> Macro.camelize
  end
end
