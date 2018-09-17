# Changelog

## 0.0.8 (2018-09-17)

* Elixir update
  * Support latest version of Elixir.
* Dependencies update
  * Update to latest version of dependencies.

## 0.0.7 (2018-06-26)

* Dependencies update
  * Update to latest version of dependencies.
  * Format code with Elixir formatter.

## 0.0.6 (2017-03-19)

* Features
  * Add `keyword_lists_from_tsv/1` and `keyword_lists_from_csv/2` that returns keyword lists stream for given TSV/CSV
  * Add `maps_from_tsv/1` and `maps_from_csv/2` that returns maps with atom keys stream for given TSV/CSV
  * Add `filter_and_take/3` that returns stream with filter regexp and take count applied
  * Add `puts_tsv/1` and `puts_tsv/2` functions to write streams of string lists as TSV to stdout

## 0.0.5 (2016-09-23)

* Refactoring
  * Create structs from stream of lists, rather than stream of maps.
  * Return headers separately from CSV/TSV parsing.
  * Pass headers separately to struct creation function.
  * Remove redundant `DataMorph.Tsv` module.
  * Pass separator token to `DataMorph.Csv` module instead.

## 0.0.4 (2016-09-09)

* Bug Fixes
  * Change code to only process line at first position of stream once, to fix bug processing from IO.stream :stdio

## 0.0.3 (2016-08-14)

* Bug Fixes
  * When `defmodulestruct/2` macro called a second time with the same fields in different order don't redefine struct

## 0.0.2 (2016-08-07)

* Bug Fixes
  * When `defmodulestruct/2` macro called a second time with the same fields don't redefine struct

## 0.0.1 (2016-08-01)

* Initial release
