defmodule PorkbunTest do
  use ExUnit.Case
  doctest Porkbun

  test "greets the world" do
    assert Porkbun.hello() == :world
  end
end
