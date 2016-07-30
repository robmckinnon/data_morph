defmodule DataMorph.Struct do
  @moduledoc ~S"""
  Contains `from_maps/3` function that defines a struct and return structs
  created from maps, and `defmodulestruct/2` macro to define a struct.
  """

  @doc ~S"""
  Defines a struct from given `kind` alias and list of `fields`.

  When called a second time with additional new fields it redefines struct,
  setting fields to be the union of the old and new fields.

  ## Examples

      iex> DataMorph.Struct.defmodulestruct(Foo.Bar, [:baz, :boom])
      {:module, Foo.Bar, _, %Foo.Bar{baz: nil, boom: nil}}
      ...> %Foo.Bar{baz: "zy", boom: "boom"}
      %Foo.Bar{baz: "zy", boom: "boom"}
      ...> DataMorph.Struct.defmodulestruct(Foo.Bar, [:bish, :bash])
      {:module, Foo.Bar, _, %Foo.Bar{bash: nil, baz: nil, bish: nil, boom: nil}}
      ...> %Foo.Bar{bish: "zy", bash: "boom"}
      %Foo.Bar{bash: "boom", baz: nil, bish: "zy", boom: nil}

  """
  defmacro defmodulestruct kind, fields do
    quote do
      value = try do
        template = struct unquote(kind)
        existing_fields = template |> Map.to_list |> Keyword.keys |> MapSet.new
        new_fields = MapSet.new unquote(fields)

        if MapSet.equal? existing_fields, new_fields do
          {:module, unquote(kind), nil, template}
        else
          union = MapSet.union(existing_fields, new_fields)
          defmodule Module.concat([ unquote(kind) ]) do
            defstruct MapSet.to_list(union)
          end
        end
      rescue
        UndefinedFunctionError ->
          defmodule Module.concat([ unquote(kind) ]) do
            defstruct unquote(fields)
          end
      end
      value
    end
  end

  @doc ~S"""
  Defines a struct and returns structs created from `maps` list or stream, and
  a `namespace` and `name`.

  Redefines struct when called again with same namespace and name but different
  fields, sets struct fields to be the union of the old and new fields.

  ## Examples

  Defines a struct and returns stream of structs created from stream of `maps`.

      iex> [
      ...>   %{"name" => "New Zealand", "ISO code" => "nz"},
      ...>   %{"name" => "United Kingdom", "ISO code" => "gb"}
      ...> ] \
      ...> |> Stream.map(& &1) \
      ...> |> DataMorph.Struct.from_maps(OpenRegister, "country") \
      ...> |> Enum.to_list
      [%OpenRegister.Country{iso_code: "nz", name: "New Zealand"},
      %OpenRegister.Country{iso_code: "gb", name: "United Kingdom"}]

  Defines a struct and returns stream of structs created from list of `maps`.

      iex> [
      ...>   %{"name" => "New Zealand", "ISO code" => "nz"},
      ...>   %{"name" => "United Kingdom", "ISO code" => "gb"}
      ...> ] \
      ...> |> DataMorph.Struct.from_maps("open-register", Country) \
      ...> |> Enum.to_list
      [%OpenRegister.Country{iso_code: "nz", name: "New Zealand"},
      %OpenRegister.Country{iso_code: "gb", name: "United Kingdom"}]

  """
  def from_maps maps, namespace, name do
    kind = DataMorph.Module.camelize_concat(namespace, name)
    fields = maps |> extract_fields
    defmodulestruct kind, Map.values(fields)
    maps
    |> ParallelStream.map(& &1 |> convert_keys(fields))
    |> ParallelStream.map(& struct(kind, &1))
  end

  defp convert_keys map, fields do
    for {key, val} <- map, into: %{}, do: {fields[key], val}
  end

  defp normalize string do
    string
    |> String.downcase
    |> String.replace(~r"\W", " ")
    |> String.replace(~r"  +", " ")
    |> String.strip()
    |> String.replace(" ", "_")
    |> String.to_atom
  end

  defp extract_fields stream do
    stream
    |> Enum.at(0)
    |> Map.keys
    |> Map.new(fn x -> {x, normalize(x)} end)
  end

end
