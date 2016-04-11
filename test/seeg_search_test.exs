defmodule SeegSearchTest do
  use ExUnit.Case
  doctest SeegSearch

  test "concat defaults" do
    docs = [{"Energia", [type: :sector]}]
    required = [{:territory, {"Brasil", [type: :territory]}}]
    ret = SeegSearch.concat_defaults(docs, required)
    assert [
      {_, [type: :territory]},
      {"Energia", [type: :sector]},
    ] = ret
  end

  @tag timeout: 10000
  test "search" do
    db = Index.load_db("test/database.exs")
    index = Index.create(db, DefaultTokenizer)
    phrase = "Emissões de co2e gwp no brasil"
    ret = SeegSearch.search(phrase, index)
    |> Enum.map(fn({w, _}) -> w end)
    assert Enum.sort([
      "Brasil",
      "CO2e (t GWP)",
      "Emissão",
    ]) == Enum.sort(ret)
  end
end
