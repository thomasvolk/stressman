defmodule DurationTest do
  use ExUnit.Case
  doctest StressMan.Duration

  test "time should mesure time" do
    assert StressMan.Duration.measure( fn -> nil end)
  end
end
