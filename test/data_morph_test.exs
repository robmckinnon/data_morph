defmodule DataMorphTest do
  use ExUnit.Case, async: false
  doctest DataMorph.Tsv
  doctest DataMorph.Module

  setup do
    {:ok, [tsv: "name\tiso\nNew Zealand\tnz\nUnited Kingdom\tgb"]}
  end

  def assert_struct item, expected_kind, expected_iso, expected_name do
    [__struct__: kind, iso: iso, name: name] = Map.to_list item
    assert Atom.to_string(kind) == "Elixir.#{expected_kind}"
    assert iso == expected_iso
    assert name == expected_name
  end

  def assert_structs kind, list do
    assert Enum.count(list) == 2
    List.first(list) |> assert_struct(kind, "nz", "New Zealand")
    List.last(list)  |> assert_struct(kind, "gb", "United Kingdom")
  end

  test "creates structs from TSV", context do
    structs = DataMorph.structs_from_tsv(OpenRegister, "country", context[:tsv])
    assert_structs "OpenRegister.Country", structs
  end

  test "from_list_of_maps/3 defines struct and returns list of maps converted to structs" do
    structs = DataMorph.Struct.from_list_of_maps OpenRegister, "country", [
      %{"name" => "New Zealand", "iso" => "nz"},
      %{"name" => "United Kingdom", "iso" => "gb"}
    ]

    assert_structs "OpenRegister.Country", structs
  end

end
