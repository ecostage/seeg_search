defmodule DefaultTokenizer do
  @stop_words ["o", "a", "os", "as", "no", "na", "com", "em", "nos",
               "nas", "do", "da", "dos", "das", "de", "a", "o", "e"]

  def tokenize(phrase) do
    Tokenizer.tokenize(phrase, @stop_words, [&remove_t_from_gases/1])
  end

  def sanitize(phrase) do
    Tokenizer.sanitize(phrase, @stop_words, [&remove_t_from_gases/1])
  end

  defp remove_t_from_gases(token) do
    String.replace(token, ~r/t$|\ t /, "", global: true)
  end
end
