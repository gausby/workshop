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

  test "find exercise files folder" do
    assert Exercise.files_folder("foo", "bar") == "bar/foo/files"
  end

  test "find sandbox name" do
    source = [{1, "foo"}, {2, "bar"}, {3, "baz"}]
    assert Exercise.exercise_sandbox_name("foo", source) == "01_foo"
    assert Exercise.exercise_sandbox_name("baz", source) == "03_baz"
  end

  test "find sandbox name should pad correctly when source dir has more than 100 exercises" do
    source = for x <- 1..100, do: {x, "foo_#{x}"}
    assert Exercise.exercise_sandbox_name("foo_50", source) == "050_foo_50"
    assert Exercise.exercise_sandbox_name("foo_75", source) == "075_foo_75"
    assert Exercise.exercise_sandbox_name("foo_100", source) == "100_foo_100"
    refute Exercise.exercise_sandbox_name("foo_32", source) == "031_foo_31"
  end
end
