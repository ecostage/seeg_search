defmodule SeegSearchTest do
  use ExUnit.Case
  doctest SeegSearch

  test "load database" do
    assert length(SeegSearch.load_database("test/database.exs")) > 1
  end

  test "required types" do
    assert length(SeegSearch.required_types()) > 1
  end

  test "remove stop words" do
    phrase = "Emissões de co2 no brasil"
    assert SeegSearch.remove_stop_words(phrase) == "Emissões co2 brasil"
  end

  test "sanitize" do
    phrase = "Emissões co2e são paulo"
    assert SeegSearch.sanitize(phrase) == "emisses co2e so paulo"
  end

  test 'combine tokens' do
    tokens = ["emissoes", "mato", "grosso", "sul"]
    assert SeegSearch.combine_tokens(tokens) |> Enum.sort == Enum.sort([
      "emissoes",
      "emissoes mato",
      "emissoes mato grosso",
      "emissoes mato grosso sul",
      "mato",
      "mato grosso",
      "mato grosso sul",
      "grosso",
      "grosso sul",
      "sul"
    ])
  end

  test "tokenize" do
    phrase = "Emissões co2e são paulo"
    assert SeegSearch.tokenize(phrase) |> Enum.sort == Enum.sort([
      "emisses",
      "emisses co2e",
      "emisses co2e so",
      "emisses co2e so paulo",
      "co2e",
      "co2e so",
      "co2e so paulo",
      "so",
      "so paulo",
      "paulo",
    ])
  end

  test "concat defaults" do
    tree = [{{"Text", :sector, []}, 1}]
    result = SeegSearch.concat_defaults(tree)
    assert [
      {_, :type, _},
      {_, :territory, _},
      {_, :gas, _},
      {"Text", :sector, _},
    ] = result
  end

  test "search" do
    database = SeegSearch.load_database("test/database.exs")
    phrase = "Emissões de co2e gwp no brasil"
    result = SeegSearch.search(phrase, database)
    assert [
      {"Emissão", :type, _},
      {"Brasil", :territory, _},
      {"CO2e (t GWP)", :gas, _},
    ] = result
  end

  test "parse phrase" do
    database = SeegSearch.load_database("test/database.exs")
    phrase = "Emissões de co2 no brasil"
    result = SeegSearch.parse_phrase(phrase, database)
    |> Enum.map(fn({{ text, _, _}, _}) -> text end)
    |> Enum.sort

    assert ["Brasil", "CO2 (t)", "Emissão"] = result
  end
end
