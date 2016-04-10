defmodule SeegSearch do
  def load_database(filename) do
    elem(Code.eval_file(filename), 0)
  end

  def search(phrase, database) do
    parse_phrase(phrase, database)
    |> concat_defaults
  end

  def parse_phrase(phrase, database) do
    tokenize(phrase)
    |> Enum.map(fn (token) ->
      Enum.map(database, fn (record) ->
        {word, _, _} = record
        distance = TheFuzz.Similarity.Levenshtein
          .compare(sanitize(word), token)
        score = 1-(distance / Enum.max([String.length(sanitize(word)), String.length(token)]))
        {record, score}
      end)
      |> Enum.max_by(fn({_, score}) -> score end)
    end)
    |> Enum.filter(fn({_, score}) -> score > 0.7 end)
    |> Enum.sort_by(fn({_, score}) -> score end)
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

  def remove_invalid_words(phrase) do
    Enum.reduce(invalid_words, phrase, fn(word, acc) ->
      String.replace(acc, " #{word} ", " ", global: true)
    end)
  end

  def remove_invalid_chars(phrase) do
    Enum.reduce(invalid_chars, phrase, fn(char, acc) ->
      String.replace(acc, char, " ", global: true)
    end)
  end

  def sanitize(phrase) do
    String.downcase(phrase)
    |> String.codepoints
    |> Enum.filter(fn(char) -> byte_size(char) == 1 end)
    |> Enum.join("")
    |> apply_transforms
    |> remove_invalid_words
    |> remove_invalid_chars
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

  def combine_tokens(list, tokens \\ [])

  def combine_tokens([], tokens), do: tokens

  def combine_tokens([ head | [] ], tokens) do
    combine_tokens([], [ head | tokens ])
  end

  def combine_tokens([ head | tail ], tokens) do
    [ next | _ ] = tail
    tokens = [ head | [ Enum.join([head, next], " ") | tokens ]]
    combine_tokens(tail, tokens)
  end

  def required_types do
    [
      {:type, [default: {"Emissão", :type, [id: 1]}]},
      {:territory, [default: {"Brasil", :territory, [id: 1]}]},
      {:gas, [default: {"CO2e", :gas, [id: 1]}]},
    ]
  end

  def invalid_words do
    ["o", "a", "os", "as", "no", "na", "com", "em", "nos", "nas", "do", "da", "dos", "das", "de"]
  end

  def invalid_chars do
    ["(", ")"]
  end
end
