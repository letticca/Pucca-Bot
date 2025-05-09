defmodule PuccaBotTest do
  use ExUnit.Case
  doctest PuccaBot

  test "greets the world" do
    assert PuccaBot.hello() == :world
  end
end
