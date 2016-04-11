defmodule SpellChecker do
  import DefMemo

  defmemo correct(phrase, db) do
    phrase
    |> String.split(" ")
    |> Parallel.map(&correct_token(&1, db))
  end

  defmemo correct_token(token, db) do
    Enum.find(db, token, fn(word) ->
      String.jaro_distance(word, token) > 0.8
    end)
  end
end
