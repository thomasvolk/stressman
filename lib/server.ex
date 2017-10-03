defmodule Stress.Server do
  def start(name) do
    Node.start(name)
    receive do
       { :halt_server } -> 0
    end
  end

end
