defmodule DataMorph.Struct do
  @moduledoc false

  @doc ~S"""
  Defines a struct from given alias and list of fields.

  When called a second time with different fields it does not redefine struct.

  ## Example

      iex> DataMorph.Struct.defmodulestruct(Foo.Bar, [:baz, :boom])
      {:module, Foo.Bar, _, %Foo.Bar{baz: nil, boom: nil}}
      iex> %Foo.Bar{baz: "zy", boom: "boom"}
      %Foo.Bar{baz: "zy", boom: "boom"}
      iex> DataMorph.Struct.defmodulestruct(Foo.Bar, [:bish, :bash])
      {:module, Foo.Bar, _, %Foo.Bar{baz: nil, boom: nil}}
      iex> %Foo.Bar{bish: "zy", bash: "boom"}
      ** (CompileError) iex:93: unknown key :bish for struct Foo.Bar

  """
  defmacro defmodulestruct kind, fields do
    quote do
      value = try do
        template = struct(unquote(kind))
        {:module, unquote(kind), nil, template}
      rescue
        UndefinedFunctionError ->
          defmodule Module.concat([ unquote(kind) ]) do
            defstruct unquote(fields)
          end
      end
      value
    end
  end

end
