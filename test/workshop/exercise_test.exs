defmodule Workshop.ExerciseTest do
  use ExUnit.Case

  alias Workshop.Exercise

  # check validity
  test "valid exercise names" do
    assert Exercise.valid_name?("hello") == true
    assert Exercise.valid_name?("hello_world") == true
  end

  test "invalid exercise names" do
    assert Exercise.valid_name?("010_hello") == false
    assert Exercise.valid_name?("HelloWorld") == false
    assert Exercise.valid_name?("hello_World") == false
  end
end
