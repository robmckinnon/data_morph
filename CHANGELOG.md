# Changelog

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
