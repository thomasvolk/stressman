defmodule StressMan.Duration do
  def measure(func) do
     start_time = StressMan.Time.now()
     result = func.()
     end_time = StressMan.Time.now()
     { end_time - start_time, result }
  end
end

defmodule StressMan.Time do
   def now(), do: :os.system_time(:millisecond)
end
