defmodule Stress.Server do
  require Logger
  def start(name) do
    Logger.info("start server: #{name}")
    Node.start(name)
    receive do
       { :halt_server } -> 0
    end
  end

end
