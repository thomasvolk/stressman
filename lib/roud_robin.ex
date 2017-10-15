defmodule StressMan.RoundRobin do
  def next([first_item|rest]), do: {first_item, rest ++ [first_item]}
end
