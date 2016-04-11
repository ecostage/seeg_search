defmodule Index do
  import DefMemo

  defmemo load_db(file) do
    Code.eval_file(file) |> elem(0)
  end

  defmemo create(db, tokenizer) do
    Parallel.map(db, fn(record) ->
      {word, _} = record
      token = tokenizer.sanitize(word)
      {record, token}
    end)
  end

  def find(token_a, index, min_score \\ 0.7)
  defmemo find(token_a, index, min_score) do
    docs = Enum.reduce(index, [], fn({record, token_b}, tokens) ->
      distance = TheFuzz.Similarity.Levenshtein
        .compare(token_a, token_b)
      score = calc_score(distance, token_a, token_b)
      if score > min_score do
        [{record, score} | tokens]
      else
        tokens
      end
    end)

    case docs do
      [] -> nil
      _ -> Enum.max_by(docs, fn({_, score}) -> score end)
    end
  end

  defp calc_score(distance, token_a, token_b) do
    1-(distance / Enum.max([String.length(token_a), String.length(token_b)]))
  end
end
