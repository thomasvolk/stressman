defmodule StressMan do
  use Application

  def start(_type, _args) do
    StressMan.Supervisor.start_link(:ok)
  end

end
