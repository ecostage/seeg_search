defmodule SeegSearchTest do
  use ExUnit.Case
  doctest SeegSearch

  test "load database" do
    assert length(SeegSearch.load_database("test/database.exs")) > 1
  end

  test "required types" do
    assert length(SeegSearch.required_types()) > 1
  end

  test "remove invalid words" do
    phrase = "Emissões de co2 no brasil"
    assert SeegSearch.remove_invalid_words(phrase) == "Emissões co2 brasil"
  end

  test "sanitize" do
    phrase = "Emissões co2e são paulo"
    assert SeegSearch.sanitize(phrase) == "emisses co2e so paulo"
  end

  test "tokenize" do
    phrase = "Emissões co2e são paulo"
    assert SeegSearch.tokenize(phrase) == [
      "paulo",
      "so",
      "so paulo",
      "co2e",
      "co2e so",
      "emisses",
      "emisses co2e"
    ]
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
    phrase = "Emissões de co2 no brasil"
    result = SeegSearch.search(phrase, database)
    assert [
      {"CO2 (t)", :gas, _},
      {"Brasil", :territory, _},
      {"Emissão", :type, _},
    ] = result
  end

  test "parse phrase" do
    database = SeegSearch.load_database("test/database.exs")
    phrase = "Emissões de co2 no brasil"
    result = SeegSearch.parse_phrase(phrase, database)
    |> Enum.map(fn({{ text, _, _}, _}) -> text end)

    assert ["CO2 (t)", "Brasil", "Emissão"] = result
  end
end
