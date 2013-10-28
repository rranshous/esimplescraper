defmodule Esimplescraper.Utils do
  def pmap(collection, fun) do
    me = self
    collection
      |> Enum.map(fn(elem) -> 
                    spawn_link fn -> 
                      (me <- { self, fun.(elem) })
                    end
                  end)
      |> Enum.map(
           fn(pid) ->
             receive do
               { ^pid, result } ->
                 result
             end
           end)
  end

  def pfilter(collection, fun) do
    pmap(collection, fun)
      |> Enum.zip(collection)
      |> Enum.filter(fn({ b, _c }) -> b end)
      |> Enum.map(fn({ _b, c }) -> c end)
  end

  def repeat_str(str, times) do
    Enum.reduce(1..times, "", fn(_i,acc) -> str <> acc end)
  end
end
