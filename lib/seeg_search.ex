defmodule SeegSearch do
  import DefMemo

  defmemo load_database(filename) do
    elem(Code.eval_file(filename), 0)
  end

  defmemo search(phrase, database) do
    parse_phrase(phrase, database)
    |> concat_defaults
  end

  defmemo find_token(token, database) do
    Enum.map(database, fn (record) ->
      {word, _, _} = record
      distance = TheFuzz.Similarity.Levenshtein
        .compare(sanitize(word), token)
      score = 1-(distance / Enum.max([String.length(sanitize(word)), String.length(token)]))
      {record, score}
    end)
    |> Enum.max_by(fn({_, score}) -> score end)
  end

  def parse_phrase(phrase, database) do
    tokenize(phrase)
    |> Parallel.map(&find_token(&1, database))
    |> Enum.filter(fn({_, score}) -> score > 0.7 end)
    |> Enum.sort_by(fn({{word, _, _}, score}) -> [score, String.length(word)] end)
    |> Enum.reverse
    |> Enum.reduce([], fn(match, acc) ->
      {{_, match_type, _}, _} = match
      exists? = Enum.any?(acc, fn({{_, type, _}, _}) -> type == match_type end)
      if exists? do
        acc
      else
        [ match | acc ]
      end
    end)
  end

  def concat_defaults(tree) do
    records = Enum.map(tree, fn({record, _}) -> record end)
    Enum.map(required_types, fn({required_type, opts}) ->
      Enum.find(records, fn({_, type, _}) -> type == required_type end)
      |> concat_default({required_type, opts})
    end)
    |> Enum.reject(&(is_nil(&1)))
    |> Enum.concat(records)
  end

  def concat_default(nil, {_, [default: default]}) do
    default
  end

  def concat_default(_, _) do
    nil
  end

  def remove_stop_words(phrase) do
    phrase
    |> String.split(" ")
    |> Enum.filter(fn(word) -> !Enum.member?(stop_words, word) end)
    |> Enum.join(" ")
  end

  def remove_punctuation(phrase) do
    String.replace(phrase, ~r/[\p{P}\p{S}]/, "")
  end

  def sanitize(phrase) do
    String.downcase(phrase)
    |> String.codepoints
    |> Enum.filter(fn(char) -> byte_size(char) == 1 end)
    |> Enum.join("")
    |> apply_transforms
    |> remove_stop_words
    |> remove_punctuation
    |> String.strip
  end

  def apply_transforms(phrase) do
    String.replace(phrase, "(t)", "", global: true)
    |> String.replace("(t ", "", global: true)
  end

  def tokenize(phrase) do
    sanitize(phrase)
    |> String.split(" ")
    |> combine_tokens
  end

  def combine_tokens(list, acc \\ "", tokens \\ [], depth \\ 0)

  def combine_tokens(_, _, tokens, 3), do: tokens
  def combine_tokens([], _, tokens, _), do: tokens

  defmemo combine_tokens([head | tail], "", tokens, depth) do
    combine_tokens(tail, head, [head | tokens], depth)
    |> Enum.uniq
  end

  def combine_tokens([head | tail], acc, tokens, depth) do
    token = Enum.join([acc, head], " ")
    combine_tokens(tail, token, [ token | tokens], depth+1)
    |> Enum.concat(combine_tokens([head | tail], "", [], 0))
  end

  def required_types do
    [
      {:type, [default: {"Emissão", :type, [id: "Emissão"]}]},
      {:territory, [default: {"Brasil", :territory, [id: 28]}]},
      {:gas, [default: {"CO2e (t GWP)", :gas, [id: 89]}]},
    ]
  end

  def stop_words do
    ["o", "a", "os", "as", "no", "na", "com", "em", "nos", "nas", "do", "da",
    "dos", "das", "de", "a", "o", "e"]
  end
end
