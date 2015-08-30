defmodule Workshop.Doctor do
  @type result :: :ok | {:error, String.t} | {:warning, String.t}
  @type test_function :: (() -> result)

  alias Workshop.ValidationResult, as: Result

  @spec run :: Result.t
  def run do
    tests = [
      &system_should_have_the_same_major_minor_version_as_the_creation_script/0
    ]

    all_tests = get_workshop_prerequisite_tests ++ tests

    for test <- all_tests, into: %Result{}, do: apply(test, [])
  end

  @spec system_should_have_the_same_major_minor_version_as_the_creation_script :: result
  defp system_should_have_the_same_major_minor_version_as_the_creation_script do
    # todo, the workshop should save the workshop version number it was created with
    :ok
  end

  # This will fetch the prerequisite tests defined in the workshop in *prerequisite.exs*
  @spec get_workshop_prerequisite_tests :: [test_function]
  defp get_workshop_prerequisite_tests do
    path =
      "prerequisite.exs"
      |> Path.expand(Workshop.Session.get(:data_folder))

    if File.exists? path do
      Code.require_file(path)
      apply(Workshop.Prerequisite, :run, [])
    else
      []
    end
  end
end
