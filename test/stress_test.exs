defmodule StressTest do
  use ExUnit.Case
  doctest Stress

  test "greets the world" do
    assert Stress.hello() == :world
  end
end
