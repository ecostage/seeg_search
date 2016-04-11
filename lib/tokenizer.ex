defmodule Tokenizer do
  import DefMemo

  def tokenize(phrase, stop_words \\ [], transforms \\ [])
  defmemo tokenize(phrase, stop_words, transforms) do
    phrase
    |> sanitize(stop_words, transforms)
    |> String.split(" ")
  end

  def sanitize(phrase, stop_words \\ [], transforms \\ [])
  defmemo sanitize(phrase, stop_words, transforms) do
    phrase
    |> String.downcase
    |> String.split(" ")
    |> remove_stop_words(stop_words)
    |> remove_diacritcs
    |> remove_punctuation
    |> apply_transforms(transforms)
    |> Enum.reject(&(String.length(&1) == 0))
    |> strip
    |> Enum.join(" ")
  end

  def ngrams(tokens, n \\ 3)
  def ngrams(_, 0), do: []
  def ngrams([], _), do: []
  defmemo ngrams(tokens, n) do
    ngram = Enum.slice(tokens, (0..(n-1))) |> Enum.join(" ")
    [_ | tail] = tokens
    [ngram | ngrams(tokens, n-1)] ++ ngrams(tail, n)
    |> Enum.uniq
  end

  defp strip(tokens) do
    Enum.map(tokens, &String.strip(&1))
  end

  defp remove_diacritcs(tokens) do
    Enum.map(tokens, fn(token) ->
      token
      |> String.codepoints
      |> Enum.filter(&(byte_size(&1) == 1))
      |> Enum.join
    end)
  end

  defp remove_punctuation(tokens) do
    Enum.map(tokens, fn(token) ->
      String.replace(token, ~r/[\p{P}\p{S}]/, "")
    end)
  end

  defp remove_stop_words(tokens, stop_words) do
    Enum.filter(tokens, fn(token) ->
      !Enum.member?(stop_words, token)
    end)
  end

  defp apply_transforms(tokens, transforms) do
    Enum.map(tokens, fn(token) ->
      Enum.reduce(transforms, token, fn(transform, acc) ->
        transform.(acc)
      end)
    end)
  end
end
