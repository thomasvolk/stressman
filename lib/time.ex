defmodule StressMan.Duration do
  def measure(func) do
     start_time = :os.system_time(:millisecond)
     result = func.()
     end_time = :os.system_time(:millisecond)
     { end_time - start_time, result }
  end
end
