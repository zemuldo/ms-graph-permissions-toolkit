defmodule TractorTest do
  use ExUnit.Case
  doctest Tractor

  test "greets the world" do
    assert Tractor.hello() == :world
  end
end
