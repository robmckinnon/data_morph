defmodule DataMorphTest do
  use ExUnit.Case, async: false
  doctest DataMorph.Tsv
  doctest DataMorph.Csv
  doctest DataMorph.Module

  setup do
    stream = "name\tISO code\n" <>
             "New Zealand\tnz\n" <>
             "United Kingdom\tgb"
             |> String.split("\n")
             |> Stream.map(&(&1))
    {:ok, [tsv: stream]}
  end

  def assert_struct item, expected_kind, expected_iso, expected_name do
    [__struct__: kind, iso_code: iso, name: name] = Map.to_list item
    assert Atom.to_string(kind) == "Elixir.#{expected_kind}"
    assert iso == expected_iso
    assert name == expected_name
  end

  def assert_structs kind, stream do
    list = Enum.to_list stream
    assert Enum.count(list) == 2
    List.first(list) |> assert_struct(kind, "nz", "New Zealand")
    List.last(list)  |> assert_struct(kind, "gb", "United Kingdom")
  end

  test "creates structs from TSV", context do
    structs = DataMorph.structs_from_tsv(context[:tsv], OpenRegister, :iso_country)
    assert_structs "OpenRegister.IsoCountry", structs
  end

  test "from_maps/3 defines struct and returns stream of maps converted to structs" do
    structs = [
                %{"name" => "New Zealand", "ISO code" => "nz"},
                %{"name" => "United Kingdom", "ISO code" => "gb"}
              ]
              |> DataMorph.Struct.from_maps(OpenRegister, "country")

    assert_structs "OpenRegister.Country", structs
  end

  test "structs_from_csv/2 returns correct result from IO.stream of :stdio" do
    result = "
    (echo name,iso && echo New Zealand,NZ) | \
    mix run -e 'IO.write inspect \
    IO.stream(:stdio, :line) \
    |> DataMorph.structs_from_csv(:ex, :ample) \
    |> Enum.at(0)'"
    |> String.to_char_list
    |> :os.cmd

    assert String.contains? "#{result}", "#{'%Ex.Ample{iso: "NZ", name: "New Zealand"}'}"
  end

end
