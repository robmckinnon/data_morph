defmodule DataMorph.Struct do
  @moduledoc false

  @doc ~S"""
  Defines a struct from given alias and list of fields.

  When called a second time with additional new fields it redefines struct,
  setting fields to be the union of the old and new fields.

  ## Example

      iex> DataMorph.Struct.defmodulestruct(Foo.Bar, [:baz, :boom])
      {:module, Foo.Bar, _, %Foo.Bar{baz: nil, boom: nil}}
      iex> %Foo.Bar{baz: "zy", boom: "boom"}
      %Foo.Bar{baz: "zy", boom: "boom"}
      iex> DataMorph.Struct.defmodulestruct(Foo.Bar, [:bish, :bash])
      {:module, Foo.Bar, _, %Foo.Bar{bash: nil, baz: nil, bish: nil, boom: nil}}
      iex> %Foo.Bar{bish: "zy", bash: "boom"}
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
  Defines a struct and returns structs created from maps.

  Redefines struct when called again with same namespace and name but different
  fields, sets struct fields to be the union of the old and new fields.

  ## Examples

  Defines a struct and returns stream of structs created from stream of maps.

      iex> [
      iex>   %{"name" => "New Zealand", "ISO code" => "nz"},
      iex>   %{"name" => "United Kingdom", "ISO code" => "gb"}
      iex> ]
      iex> |> Stream.map &(&1)
      iex> |> DataMorph.Struct.from_maps(OpenRegister, "country")
      [%OpenRegister.Country{iso_code: "nz", name: "New Zealand"},
      %OpenRegister.Country{iso_code: "gb", name: "United Kingdom"}]

  Defines a struct and returns stream of structs created from list of maps.

      iex> DataMorph.Struct.from_maps OpenRegister, "country", [
      iex>   %{"name" => "New Zealand", "ISO code" => "nz"},
      iex>   %{"name" => "United Kingdom", "ISO code" => "gb"}
      iex> ]
      [%OpenRegister.Country{iso_code: "nz", name: "New Zealand"},
      %OpenRegister.Country{iso_code: "gb", name: "United Kingdom"}]

  """
  def from_maps stream, namespace, name do
    kind = DataMorph.Module.camelize_concat(namespace, name)
    fields = stream |> extract_fields
    defmodulestruct kind, Map.values(fields)
    stream
    |> ParallelStream.map(&(&1 |> convert_keys(fields)))
    |> ParallelStream.map(&(struct(kind, &1)))
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
