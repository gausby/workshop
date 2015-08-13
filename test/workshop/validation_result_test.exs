defmodule Workshop.ValidationResultTest do
  use ExUnit.Case

  alias Workshop.ValidationResult, as: Result

  test "validation results should start out with blank values" do
    assert %Result{}.runs == 0
    assert %Result{}.passed == 0
    assert %Result{}.errors == []
    assert %Result{}.warnings == []
  end

  test "should collect errors" do
    result = [{:error, "reason"}] |> Enum.into(%Result{})
    assert result.errors == ["reason"]
    assert result.warnings == []
    assert result.passed == 0
    assert result.runs == 1
  end

  test "should collect warnings" do
    result = [{:warning, "reason"}] |> Enum.into(%Result{})
    assert result.warnings == ["reason"]
    assert result.errors == []
    assert result.passed == 1
    assert result.runs == 1
  end

  test "should collect successes" do
    result = [:ok] |> Enum.into(%Result{})
    assert result.warnings == []
    assert result.errors == []
    assert result.passed == 1
    assert result.runs == 1
  end

  test "should collect mixed results" do
    input = [:ok, {:error, "foo"}, {:warning, "bar"}, {:error, "baz"}]
    result = Enum.into(input, %Result{})
    assert length(result.warnings) == 1
    assert length(result.errors) == 2
    assert result.passed == 2
    assert result.runs == length(input)
  end
end
