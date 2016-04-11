defmodule SeegSearch do
  import DefMemo

  @required [
    {:type, {"Emissão", [type: :type, id: "Emissão"]}},
    {:territory, {"Brasil", [type: :territory, id: 28]}},
    {:gas, {"CO2e (t GWP)", [type: :gas, id: 89]}},
  ]

  defmemo search(phrase, index) do
    tokenize(phrase)
    |> Parallel.map(&Index.find(&1, index))
    |> Enum.reject(&(is_nil(&1)))
    |> Enum.sort_by(fn({{word, _}, score}) -> [score, String.length(word)] end)
    |> Enum.reverse
    |> Enum.map(fn({doc, _}) -> doc end)
    |> Enum.uniq_by(fn({_, opts}) -> Keyword.fetch!(opts, :type) end)
    |> concat_defaults(@required)
  end

  def concat_defaults(docs, required) do
    Enum.map(required, fn({type, doc}) ->
      ret = Enum.find(docs, fn({_, opts}) -> Keyword.fetch!(opts, :type) == type end)
      case ret do
        nil -> doc
        _ -> nil
      end
    end)
    |> Enum.reject(&(is_nil(&1)))
    |> Enum.concat(docs)
  end

  defmemo tokenize(phrase) do
    phrase
    |> DefaultTokenizer.tokenize
    |> Tokenizer.ngrams
  end
end
