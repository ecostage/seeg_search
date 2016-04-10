#from: http://www.selectedintelligence.com/post/117286711659/elixir-easy-parallelism-doesnt-mean-i-can-stop

defmodule Parallel do
  def map(collection, timeout \\ 1000, function) do
    me = self
    collection
    |> Enum.map(fn(elem) ->
      spawn fn -> (
        send me, {self, function.(elem)})
      end
    end)
    |> Enum.map(fn(pid) ->
      receive do {^pid, result} ->
        result
      end
    end)
  end
end
