defmodule ProductsAdvisorTest do
  use ExUnit.Case
  doctest ProductsAdvisor

  test "greets the world" do
    assert ProductsAdvisor.hello() == :world
  end
end
