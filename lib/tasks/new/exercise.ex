defmodule Mix.Tasks.Workshop.New.Exercise do
  use Mix.Task
  import Mix.Generator
  import Mix.Utils, only: [camelize: 1]

  alias Workshop.Exercises

  @shortdoc "Create a new exercise for a workshop"
  @moduledoc """
  Creates a new exercise for a workshop.

  It expects a name for the new exercise

      mix workshop.new NAME

  The path will be named after the given NAME. Given `my_exercise` it will
  result in a workshop named *My Exercise*. The generated files will be
  stored in folder prefixed with a number, like "010", incrementing by 10
  for every exercise that is created.
  """
  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {opts, argv, _} = OptionParser.parse(argv, switches: [])

    path = Workshop.Session.get(:exercises_folder)
    # update current working dir
    File.cd!(path)

    case argv do
      [] -> Mix.raise "Expected NAME to be given. Please use `mix workshop.new.exercise NAME`"
      [name|_] ->
        name = Path.basename(Path.expand(name))
        check_workshop_name!(name)
        mod = camelize(name)
        title = snake_case_to_headline(name)
        exercise_folder = Path.join(path, get_next_exercise_weight <> "_" <> name)

        case File.mkdir_p(exercise_folder) do
          :ok ->
            File.cd!(exercise_folder, fn ->
              do_generate_exercise(path, title, mod, opts)
              Mix.shell.info """
              The new exercise has been created in:

                  #{exercise_folder}

              If you want to change the precedence of this exercise you can simply
              move the folder and change the assigned number.
              """
            end)
        end
    end
  end

  # calculate the next weight value for the next exercise
  @weight_increment 10
  defp get_next_exercise_weight do
    current = case Enum.reverse(Exercises.list_by_weight!) do
      [{weight, _} | _] ->
        weight

      [] ->
        0
    end
    current + @weight_increment |> Integer.to_string |> String.rjust(3, ?0)
  end

  defp check_workshop_name!(name) do
    # taken from the `mix new` source code
    unless name =~ ~r/^[a-z][\w_]*$/ do
      Mix.raise "Exercise name must start with a letter and have only lowercase " <>
                "letters, numbers and underscore, got: #{inspect name}"
    end
  end

  defp snake_case_to_headline(name) do
    name
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp do_generate_exercise(name, title, mod, _opts) do
    assigns = [name: name, title: title, module: mod]

    create_file "README.md", readme_template(assigns)
    create_file "exercise.exs", exercise_template(assigns)
    create_directory "files"
    create_directory "test"
    create_file "test/test_helper.exs", ""
  end

  embed_template :readme, """
  <%= @title %>
  <%= String.replace(@title, ~r/./, "=") %>
  **TODO: add a short description of the exercise**

  What's next?
  ------------
  Type `mix workshop.check` to check your solution. If you pass you can proceed
  to the next exercise by typing `mix workshop.next`. This is all done in the
  terminal.

  If you are confused you could try `mix workshop.hint`. Otherwise ask your
  instructor or follow the directions on `mix workshop.help`.
  """

  embed_template :exercise, """
  defmodule Workshop.Exercise.<%= @module %> do
    use Workshop.Exercise

    @title "<%= @title %>"

    @description \"""
    @todo, write this exercise
    \"""

    @hint \"""
    @todo, write a hint for completing this exercise
    \"""
  end
  """
end
