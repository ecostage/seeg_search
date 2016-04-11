defmodule TokenizerTest do
  use ExUnit.Case
  doctest Tokenizer

  test "sanitize" do
    phrase = "Emissões co2e são paulo!"
    assert Tokenizer.sanitize(phrase) == "emisses co2e so paulo"
  end

  test "tokenize" do
    phrase = "Emissões co2e são paulo!"
    assert Tokenizer.tokenize(phrase) |> Enum.sort == Enum.sort([
      "emisses",
      "co2e",
      "so",
      "paulo",
    ])
  end

  test "ngrams" do
    tokens = ["mato", "grosso", "sul"]
    assert Tokenizer.ngrams(tokens, 3) |> Enum.sort == Enum.sort([
      "mato",
      "mato grosso",
      "mato grosso sul",
      "grosso",
      "grosso sul",
      "sul"
    ])
  end
end
