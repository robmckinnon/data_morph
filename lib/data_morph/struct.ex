defmodule DataMorph.Struct do
  @moduledoc ~S"""
  Contains `from_rows/3` function that defines a struct and return structs
  created from rows, and `defmodulestruct/2` macro to define a struct.
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
      module = unquote(kind)
      fields = unquote(fields)
      fields_changeset = try do
                           existing_fields = (struct(module) |> Map.keys) -- [:__struct__]
                           existing_fieldset = MapSet.new(existing_fields)
                           new_fieldset = MapSet.new(fields)
                           unless existing_fieldset === new_fieldset do
                             existing_fieldset
                             |> MapSet.union(new_fieldset)
                             |> MapSet.to_list
                           end
                         rescue
                           UndefinedFunctionError -> fields
                         end
      if fields_changeset do
        defmodule Module.concat([module]), do: defstruct fields_changeset
      else
        {:module, module, nil, struct(module)}
      end
    end
  end

  @doc ~S"""
  Defines a struct and returns structs created from `rows` list or stream, and
  a `namespace`, a `name`, and a list of `headers`.

  Redefines struct when called again with same namespace and name but different
  headers, sets struct fields to be the union of the old and new headers.

  ## Examples

  Defines a struct and returns stream of structs created from stream of `rows`.

      iex> headers = ["name","ISO code"]
      ...> [
      ...>   ["New Zealand","nz"],
      ...>   ["United Kingdom","gb"]
      ...> ] \
      ...> |> Stream.map(& &1) \
      ...> |> DataMorph.Struct.from_rows(OpenRegister, "country", headers) \
      ...> |> Enum.to_list
      [%OpenRegister.Country{iso_code: "nz", name: "New Zealand"},
      %OpenRegister.Country{iso_code: "gb", name: "United Kingdom"}]

  Defines a struct and returns stream of structs created from list of `rows`.

      iex> headers = ["name","ISO code"]
      ...> [
      ...>   ["New Zealand","nz"],
      ...>   ["United Kingdom","gb"]
      ...> ] \
      ...> |> DataMorph.Struct.from_rows("open-register", Country, headers) \
      ...> |> Enum.to_list
      [%OpenRegister.Country{iso_code: "nz", name: "New Zealand"},
      %OpenRegister.Country{iso_code: "gb", name: "United Kingdom"}]

  """
  def from_rows rows, namespace, name, headers do
    kind = DataMorph.Module.camelize_concat(namespace, name)
    fields = headers |> Enum.map(&normalize/1)

    defmodulestruct kind, fields

    rows |> Stream.map(&convert_row(&1, kind, fields))
  end

  defp convert_row(row, kind, fields) do
    tuples = fields |> Enum.zip(row)
    struct(kind, tuples)
  end

  def normalize string do
    string
    |> String.downcase
    |> String.replace(~r"\W", " ")
    |> String.replace(~r"  +", " ")
    |> String.strip()
    |> String.replace(" ", "_")
    |> String.to_atom
  end

end
