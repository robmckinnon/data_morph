defmodule DataMorph.Stream do

  @doc ~S"""
  Filter via `regexp` and take `count`.

  ## Examples

  Filter lines by regexp:
      iex> "name,iso\n" <>
      ...> "New Zealand,nz\n" <>
      ...> "United Kingdom,gb"
      ...> |> String.split("\n")
      ...> |> Stream.map(& &1)
      ...> |> DataMorph.Stream.filter_and_take(~r{King})
      ...> |> Enum.to_list
      [
        "United Kingdom,gb"
      ]

  Take count lines:
      iex> "name,iso\n" <>
      ...> "New Zealand,nz\n" <>
      ...> "United Kingdom,gb"
      ...> |> String.split("\n")
      ...> |> Stream.map(& &1)
      ...> |> DataMorph.Stream.filter_and_take(nil, 2)
      ...> |> Enum.to_list
      [
        "name,iso",
        "New Zealand,nz"
      ]

  Filter by regexp and take count lines:
      iex> "name,iso\n" <>
      ...> "New Zealand,nz\n" <>
      ...> "United Kingdom,gb"
      ...> |> String.split("\n")
      ...> |> Stream.map(& &1)
      ...> |> DataMorph.Stream.filter_and_take(~r{d}, 1)
      ...> |> Enum.to_list
      [
        "New Zealand,nz"
      ]
  """
  def filter_and_take(stream, regexp, count \\ nil) do
    stream
    |> apply_filter(regexp)
    |> apply_take(count)
  end

  defp apply_filter(stream, nil), do: stream
  defp apply_filter(stream, regexp), do: stream |> Stream.filter(& &1 |> String.match?(regexp))

  defp apply_take(stream, nil), do: stream
  defp apply_take(stream, count), do: stream |> Stream.take(count)

end
