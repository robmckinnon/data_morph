# DataMorph

Create Elixir structs, maps with atom keys, and keyword lists from CSV/TSV data.

[![Build Status](https://api.travis-ci.org/robmckinnon/data_morph.svg)](https://travis-ci.org/robmckinnon/data_morph)
[![Inline docs](http://inch-ci.org/github/robmckinnon/data_morph.svg)](http://inch-ci.org/github/robmckinnon/data_morph)
[![Hex.pm](https://img.shields.io/hexpm/v/data_morph.svg)](https://hex.pm/packages/data_morph)

## Documentation

You can view [full DataMorph API documentation on hexdocs](https://hexdocs.pm/data_morph/DataMorph.html).

Note, we should never convert user input to atoms. This is because atoms are not
garbage collected. Once an atom is created, it is never reclaimed.

Generating atoms from user input would mean the user can inject enough
different names to exhaust our system memory, or we reach the Erlang VM limit
for the maximum number of atoms which will bring our system down regardless.

## Installation

Add
```elixir
{:data_morph, "~> 0.1.0"}
```
to your deps in `mix.exs` like so:

```elixir
defp deps do
  [
    {:data_morph, "~> 0.1.0"}
  ]
end
```

## Usage examples

Given a CSV file of data like this:

```sh
(echo "name,iso-code" && echo New Zealand,nz && echo United Kingdom,gb) > tmp.csv
```

Define a struct and return stream of structs created from a `csv` stream,
a `namespace` string or atom, and a `name` string or atom.

```elixir
File.stream!('./tmp.csv') \
|> DataMorph.structs_from_csv("my-module", :iso_country) \
|> Enum.to_list
# [
#   %MyModule.IsoCountry{iso_code: "nz", name: "New Zealand"},
#   %MyModule.IsoCountry{iso_code: "gb", name: "United Kingdom"}
# ]
```

Return stream of maps created from a `csv` stream.

```elixir
File.stream!('./tmp.csv') \
|> DataMorph.maps_from_csv() \
|> Enum.to_list
# [
#   %{iso_code: "nz", name: "New Zealand"},
#   %{iso_code: "gb", name: "United Kingdom"}
# ]
```

Return a stream of keyword lists created from a stream of `csv`.

```sh
(echo name,iso && echo New Zealand,NZ) | \
    mix run -e 'IO.stream(:stdio, :line) \
    |> DataMorph.keyword_lists_from_csv() \
    |> IO.inspect'
# [[name: "New Zealand", iso: "NZ"]]
```

Add new fields to struct when called twice with different fields in `tsv`.

```elixir
"name\tiso\n" <>
"New Zealand\tnz\n" <>
"United Kingdom\tgb" \
|> DataMorph.structs_from_tsv(MyModule, "country") \
|> Enum.to_list
# [
#   %MyModule.Country{iso: "nz", name: "New Zealand"},
#   %MyModule.Country{iso: "gb", name: "United Kingdom"}
# ]

"name\tacronym\n" <>
"New Zealand\tNZ\n" <>
"United Kingdom\tUK" \
|> DataMorph.structs_from_tsv("MyModule", :country) \
|> Enum.to_list
# warning: redefining module MyModule.Country
#          (current version defined in memory)
# [
#   %MyModule.Country{acronym: "NZ", iso: nil, name: "New Zealand"},
#   %MyModule.Country{acronym: "UK", iso: nil, name: "United Kingdom"}
# ]
```

You can view [full DataMorph API documentation on hexdocs](https://hexdocs.pm/data_morph/DataMorph.html).
