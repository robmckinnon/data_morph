defmodule DataMorphStructTest do
  use ExUnit.Case, async: true

  require DataMorph.Struct

  test "defmodulestruct/2 macro defines struct with correct name" do
    {:module, name, _, _} = DataMorph.Struct.defmodulestruct(Foo.Bar, [:baz, :boom])
    assert name == Foo.Bar
  end

  test "defmodulestruct/2 macro defines struct with correct template" do
    {:module, _, binary, template} = DataMorph.Struct.defmodulestruct(Bar.Foo, [:baz, :boom])
    assert Map.to_list(template) == [__struct__: Bar.Foo, baz: nil, boom: nil]
    assert is_binary(binary)
  end

  test "defmodulestruct/2 macro called second time with same field keys doesn't redefine struct" do
    DataMorph.Struct.defmodulestruct(Foo.Bar.Foo, [:baz, :boom])

    {:module, _, binary, template} = DataMorph.Struct.defmodulestruct(Foo.Bar.Foo, [:baz, :boom])
    assert Map.to_list(template) == [__struct__: Foo.Bar.Foo, baz: nil, boom: nil]
    assert binary == nil
  end

  test "defmodulestruct/2 macro called second time with same field keys in different order doesn't redefine struct" do
    DataMorph.Struct.defmodulestruct(Foo.Bar.Foo.Bar, [:baz, :boom])

    {:module, _, binary, template} = DataMorph.Struct.defmodulestruct(Foo.Bar.Foo.Bar, [:boom, :baz])
    assert Map.to_list(template) == [__struct__: Foo.Bar.Foo.Bar, baz: nil, boom: nil]
    assert binary == nil
  end

  test "defmodulestruct/2 macro called second time with additional new field redefines struct" do
    DataMorph.Struct.defmodulestruct(Baz.Foo, [:baz, :boom])
    {:module, _, _, template} = DataMorph.Struct.defmodulestruct(Baz.Foo, [:baz, :boom, :bish])
    assert Map.to_list(template) == [__struct__: Baz.Foo, baz: nil, bish: nil, boom: nil]
  end

  test "defmodulestruct/2 macro called second time without original fields redefines struct leaving original keys in struct" do
    DataMorph.Struct.defmodulestruct(Foo.Baz.Foo, [:baz, :boom])
    {:module, _, _, template} = DataMorph.Struct.defmodulestruct(Foo.Baz.Foo, [:bish])
    assert Map.to_list(template) == [__struct__: Foo.Baz.Foo, baz: nil, bish: nil, boom: nil]
  end

  test "redefining struct definition only adds keys to new structs" do
    Code.eval_string("defmodule Example, do: defstruct [:original_attribute]")
    { original, _ } = Code.eval_string("%Example{ original_attribute: 'hi' }")
    assert Map.has_key? original, :original_attribute
    assert !Map.has_key? original, :new_attribute

    Code.eval_string("defmodule Example, do: defstruct [:original_attribute, :new_attribute]")
    { updated, _ } = Code.eval_string("%Example{ new_attribute: 'bye' }")
    assert Map.has_key? updated, :original_attribute
    assert Map.has_key? updated, :new_attribute
    assert !Map.has_key? original, :new_attribute
  end

end
