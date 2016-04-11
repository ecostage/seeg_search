defmodule IndexTest do
  use ExUnit.Case
  doctest Index

  test "load db" do
    assert Index.load_db("test/database.exs")
  end

  test "create" do
    db = [
      {"Emissões", []},
      {"São Paulo", []}
    ]
    assert Index.create(db, DefaultTokenizer) |> Enum.sort == Enum.sort([
      {{"Emissões", []}, "emisses"},
      {{"São Paulo", []}, "so paulo"},
    ])
  end

  test "find" do
    index = [
      {{"a", []}, "emisso"},
      {{"b", []}, "so paulo"},
      {{"c", []}, "emisses hfc"}
    ]

    token = "emisses"
    assert {{"a", _}, _} = Index.find(token, index)
  end
end
