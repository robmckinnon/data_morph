defmodule DataMorphTest do
  use ExUnit.Case, async: false
  doctest DataMorph.Csv
  doctest DataMorph.Module
  doctest DataMorph.Stream

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
    list = stream |> Enum.to_list
    assert Enum.count(list) == 2
    List.first(list) |> assert_struct(kind, "nz", "New Zealand")
    List.last(list)  |> assert_struct(kind, "gb", "United Kingdom")
  end

  def assert_maps stream do
    list = stream |> Enum.to_list
    assert Enum.count(list) == 2
    assert List.first(list) == %{iso_code: "nz", name: "New Zealand"}
    assert List.last(list) == %{iso_code: "gb", name: "United Kingdom"}
  end

  test "creates maps with atom keys from TSV", context do
    maps = DataMorph.maps_from_tsv(context[:tsv])
    assert_maps maps
  end

  def assert_keyword_lists stream do
    list = stream |> Enum.to_list
    assert Enum.count(list) == 2
    assert (list |> List.first) == [{:"name", "New Zealand"}, {:"ISO code", "nz"}]
    assert (list |> List.last) == [{:"name", "United Kingdom"}, {:"ISO code", "gb"}]
  end

  test "creates structs from TSV", context do
    structs = DataMorph.structs_from_tsv(context[:tsv], OpenRegister, :iso_country)
    assert_structs "OpenRegister.IsoCountry", structs
  end

  test "creates keyword lists from TSV", context do
    lists = DataMorph.keyword_lists_from_tsv(context[:tsv])
    assert_keyword_lists lists
  end

  test "from_rows/3 defines struct and returns stream of rows converted to structs" do
    structs = [
                ["New Zealand","nz"],
                ["United Kingdom","gb"]
              ]
              |> DataMorph.Struct.from_rows(OpenRegister, "country", ["name","ISO code"])

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

  test "structs_from_csv/2 returns correct result from blank string" do
    result = DataMorph.structs_from_csv("", Nothing, :doing)
    assert (result |> Enum.to_list) == []
  end

  test "filter_and_take/3 returns stream after filter and take applied", context do
    result = context[:tsv]
    |> DataMorph.filter_and_take(~r{King|Zeal}, 1)
    |> Enum.to_list

    assert result == [ "New Zealand\tnz" ]
  end

  import ExUnit.CaptureIO

  test "puts_tsv/1 writes string lists as TSV to standard out", context do
    fun = fn ->
      DataMorph.structs_from_tsv(context[:tsv], :ex, :country)
      |> Stream.map(& [&1.iso_code, &1.name])
      |> DataMorph.puts_tsv
    end
    assert capture_io(fun) == "nz\tNew Zealand\ngb\tUnited Kingdom\n"
  end

  test "puts_tsv/2 writes string lists as TSV with headers to standard out", context do
    fun = fn ->
      DataMorph.structs_from_tsv(context[:tsv], :ex, :country)
      |> Stream.map(& [&1.iso_code, &1.name])
      |> DataMorph.puts_tsv(["iso","name"])
    end
    assert capture_io(fun) == "iso\tname\nnz\tNew Zealand\ngb\tUnited Kingdom\n"
  end
end
