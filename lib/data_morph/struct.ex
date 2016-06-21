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
      iex>   %{"name" => "New Zealand", "iso" => "nz"},
      iex>   %{"name" => "United Kingdom", "iso" => "gb"}
      iex> ]
      iex> |> Stream.map &(&1)
      iex> |> DataMorph.Struct.from_maps(OpenRegister, "country")
      [%OpenRegister.Country{iso: "nz", name: "New Zealand"},
      %OpenRegister.Country{iso: "gb", name: "United Kingdom"}]

  Defines a struct and returns stream of structs created from list of maps.

      iex> DataMorph.Struct.from_maps OpenRegister, "country", [
      iex>   %{"name" => "New Zealand", "iso" => "nz"},
      iex>   %{"name" => "United Kingdom", "iso" => "gb"}
      iex> ]
      [%OpenRegister.Country{iso: "nz", name: "New Zealand"},
      %OpenRegister.Country{iso: "gb", name: "United Kingdom"}]

  """
  def from_maps stream, namespace, name do
    kind = DataMorph.Module.camelize_concat(namespace, name)
    fields = extract_fields(stream)
    defmodulestruct kind, fields
    ParallelStream.map stream, &(Maptu.struct!(kind, &1))
  end

  defp extract_fields stream do
    stream
    |> Enum.at(0)
    |> Map.keys
    |> Enum.map(&String.to_atom/1)
  end

end
