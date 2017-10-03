defmodule Stress do
  use Application

  def start(_type, _args) do
    Stress.Supervisor.start_link(:ok)
  end

end
