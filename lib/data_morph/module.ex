defmodule DataMorph.Module do
  @moduledoc false

  @doc ~S"""
  Camelizes and concatenates two aliases and returns a new alias.

  String aliases are camelized. Atom aliases are left unchanged.

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
  Camelizes and concatenates a list of aliases and returns a new alias.

  String aliases are camelized. Atom aliases are left unchanged.

  ## Examples

      iex> DataMorph.Module.camelize_concat(["open_register", "political", "iso-country"])
      OpenRegister.Political.IsoCountry
      iex> DataMorph.Module.camelize_concat(["", "political", nil])
      Political

  """
  def camelize_concat(list) do
    list
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
