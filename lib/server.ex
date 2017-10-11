defmodule StressMan.Server do
  require Logger
  def start(name, cookie) do
    Logger.info("start server: #{name}")
    Node.start(name)
    Node.set_cookie(:"#{cookie}")
    receive do
       { :halt_server } -> 0
    end
  end

end
