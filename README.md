# DataMorph

Create Elixir structs from data.

[![Build Status](https://api.travis-ci.org/robmckinnon/data_morph.svg)](https://travis-ci.org/robmckinnon/data_morph)
[![Inline docs](http://inch-ci.org/github/robmckinnon/data_morph.svg)](http://inch-ci.org/github/robmckinnon/data_morph)

## Documentation

You can view [full DataMorph API documentation on hexdocs](https://hexdocs.pm/data_morph/DataMorph.html).

## Installation

Add
```elixir
{:data_morph, "~> 0.0.2"}
```
to your deps in `mix.exs` like so:

```elixir
defp deps do
  [
    {:data_morph, "~> 0.0.2"}
  ]
end
```

## Usage examples

Define a struct and return stream of structs created from a `tsv` string, a `namespace` atom and `name` string.

```elixir
iex> "name\tiso\n" <>
...> "New Zealand\tnz\n" <>
...> "United Kingdom\tgb" \
...> |> DataMorph.structs_from_tsv(OpenRegister, "country") \
...> |> Enum.to_list
[
  %OpenRegister.Country{iso: "nz", name: "New Zealand"},
  %OpenRegister.Country{iso: "gb", name: "United Kingdom"}
]
```

Define a struct and return stream of structs created from a `tsv` stream, and a `namespace` string and `name` atom.

```elixir
iex> "name\tiso\n" <>
...> "New Zealand\tnz\n" <>
...> "United Kingdom\tgb" \
...> |> String.split("\n") \
...> |> Stream.map(& &1) \
...> |> DataMorph.structs_from_tsv("open-register", :iso_country) \
...> |> Enum.to_list
[
  %OpenRegister.IsoCountry{iso: "nz", name: "New Zealand"},
  %OpenRegister.IsoCountry{iso: "gb", name: "United Kingdom"}
]
```

Add additional new fields to struct when called again with different `tsv`.

```elixir
iex> "name\tiso\n" <>
...> "New Zealand\tnz\n" <>
...> "United Kingdom\tgb" \
...> |> DataMorph.structs_from_tsv(OpenRegister, "country") \
...> |> Enum.to_list
...>
...> "name\tacronym\n" <>
...> "New Zealand\tNZ\n" <>
...> "United Kingdom\tUK" \
...> |> DataMorph.structs_from_tsv(OpenRegister, "country") \
...> |> Enum.to_list
[
  %OpenRegister.Country{acronym: "NZ", iso: nil, name: "New Zealand"},
  %OpenRegister.Country{acronym: "UK", iso: nil, name: "United Kingdom"}
]
```
