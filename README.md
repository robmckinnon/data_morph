# DataMorph

Create Elixir structs, maps with atom keys, and keyword lists from CSV/TSV data.

[![Build Status](https://api.travis-ci.org/robmckinnon/data_morph.svg)](https://travis-ci.org/robmckinnon/data_morph)
[![Inline docs](http://inch-ci.org/github/robmckinnon/data_morph.svg)](http://inch-ci.org/github/robmckinnon/data_morph)
[![Hex.pm](https://img.shields.io/hexpm/v/data_morph.svg)](https://hex.pm/packages/data_morph)

## Documentation

You can view [full DataMorph API documentation on hexdocs](https://hexdocs.pm/data_morph/DataMorph.html).

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

Define a struct and return stream of structs created from a `tsv` string, a `namespace` atom and `name` string.

```elixir
"name\tiso\n" <>
"New Zealand\tnz\n" <>
"United Kingdom\tgb" \
|> DataMorph.structs_from_tsv(OpenRegister, "country") \
|> Enum.to_list
# [
#   %OpenRegister.Country{iso: "nz", name: "New Zealand"},
#   %OpenRegister.Country{iso: "gb", name: "United Kingdom"}
# ]
```

Define a struct and return stream of structs created from a `csv` file stream,
and a `namespace` string and `name` atom.

```sh
(echo name,iso && echo New Zealand,nz && echo United Kingdom,gb) > tmp.csv
```

```elixir
File.stream!('./tmp.csv') \
|> DataMorph.structs_from_csv("open-register", :iso_country) \
|> Enum.to_list
# [
#   %OpenRegister.IsoCountry{iso: "nz", name: "New Zealand"},
#   %OpenRegister.IsoCountry{iso: "gb", name: "United Kingdom"}
# ]
```

Define a struct and puts stream of structs created from a stream of `csv`
on standard input, and a `namespace` atom, and `name` string.
```sh
(echo name,iso && echo New Zealand,NZ) | \
    mix run -e 'IO.puts inspect \
    IO.stream(:stdio, :line) \
    |> DataMorph.structs_from_csv(:ex, "ample") \
    |> Enum.at(0)'
# %Ex.Ample{iso: "NZ", name: "New Zealand"}
```

Add additional new fields to struct when called again with different `tsv`.

```elixir
"name\tiso\n" <>
"New Zealand\tnz\n" <>
"United Kingdom\tgb" \
|> DataMorph.structs_from_tsv(OpenRegister, "country") \
|> Enum.to_list

"name\tacronym\n" <>
"New Zealand\tNZ\n" <>
"United Kingdom\tUK" \
|> DataMorph.structs_from_tsv(OpenRegister, "country") \
|> Enum.to_list
# [
#   %OpenRegister.Country{acronym: "NZ", iso: nil, name: "New Zealand"},
#   %OpenRegister.Country{acronym: "UK", iso: nil, name: "United Kingdom"}
# ]
```

You can view [full DataMorph API documentation on hexdocs](https://hexdocs.pm/data_morph/DataMorph.html).
