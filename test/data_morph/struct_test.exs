defmodule DataMorphStructTest do
  use ExUnit.Case, async: true

  require DataMorph.Struct

  test "defmodulestruct/2 macro defines struct with correct name" do
    {:module, name, _, _} = DataMorph.Struct.defmodulestruct(Foo.Bar, [:baz, :boom])
    assert name == Foo.Bar
  end

  test "defmodulestruct/2 macro defines struct with correct template" do
    {:module, _, _, template} = DataMorph.Struct.defmodulestruct(Bar.Foo, [:baz, :boom])
    assert Map.to_list(template) == [__struct__: Bar.Foo, baz: nil, boom: nil]
  end

  test "defmodulestruct/2 macro called second time with different fields does not redefine struct" do
    DataMorph.Struct.defmodulestruct(Baz.Foo, [:baz, :boom])
    {:module, _, _, template} = DataMorph.Struct.defmodulestruct(Baz.Foo, [:baz, :boom, :bish])
    assert Map.to_list(template) == [__struct__: Baz.Foo, baz: nil, boom: nil]
  end

end
