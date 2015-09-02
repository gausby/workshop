defmodule Mix.Tasks.New.Exercise do
  use Mix.Task
  import Mix.Generator
  import Mix.Utils, only: [camelize: 1]

  alias Workshop.Exercise
  alias Workshop.Exercises

  @shortdoc "Create a new exercise for a workshop"
  @moduledoc """
  Creates a new exercise for a workshop.

  It expects a name for the new exercise

      mix new.workshop NAME

  The path will be named after the given NAME. Given `my_exercise` it will
  result in a workshop named *My Exercise*.

  The exercises will be ordered by a weight set as a module attribute in the
  generated *name/exercise.exs* file. It will increment by 1000 for every new
  exercise, which should give ample slots to move exercises around after
  they have been created, if the exercise order should change.
  """
  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {opts, argv, _} = OptionParser.parse(argv, switches: [])

    path = Workshop.Session.get(:exercises_folder)
    # update current working dir
    File.cd!(path)

    case argv do
      [] -> Mix.raise "Expected NAME to be given. Please use `mix new.exercise NAME`"
      [name|_] ->
        name = Path.basename(Path.expand(name))
        unless Exercise.valid_name?(name) do
          Mix.raise "Exercise name must start with a letter and have only lowercase " <>
                    "letters, numbers and underscore, got: #{inspect name}"
        end
        if Exercise.name_taken?(name) do
          Mix.raise "The name #{inspect name} has already been taken. Please use " <>
                    "another name for this exercise."
        end
        mod = camelize(name)
        title = snake_case_to_headline(name)
        weight = get_next_exercise_weight
        exercise_folder = Path.expand("#{name}", path)

        case File.mkdir_p(exercise_folder) do
          :ok ->
            File.cd!(exercise_folder, fn ->
              do_generate_exercise(path, title, mod, weight, opts)
              Mix.shell.info """
              The new exercise has been created in:

                  #{exercise_folder}

              If you want to change the precedence of this exercise you can simply
              change the assigned @weight in the created exercise.exs-file.
              """
            end)
        end
    end
  end

  # calculate the next weight value for the next exercise
  @weight_increment 1000
  defp get_next_exercise_weight do
    case Enum.reverse(Exercises.list_by_weight!) do
      [{weight, _} | _] ->
        weight + @weight_increment

      [] ->
        @weight_increment
    end
  end

  defp snake_case_to_headline(name) do
    name
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp do_generate_exercise(name, title, mod, weight, _opts) do
    assigns = [name: name, title: title, module: mod, weight: weight]

    create_file "exercise.exs", exercise_template(assigns)
    create_directory "files"
    create_directory "solution"
    create_directory "test"
    create_file "test/test_helper.exs", test_helper_template(assigns)
    create_file "test/check.exs", check_template(assigns)
  end

  embed_template :exercise, """
  defmodule Workshop.Exercise.<%= @module %> do
    use Workshop.Exercise

    @title "<%= @title %>"
    @weight <%= @weight %>

    @description \"""
    @todo, write this exercise

    # What's next?
    Type `mix workshop.check` to check your solution. If you pass you can proceed
    to the next exercise by typing `mix workshop.next`. This is all done in the
    terminal.

    If you are confused you could try `mix workshop.hint`. Otherwise ask your
    instructor or follow the directions on `mix workshop.help`.
    \"""

    @hint [
      \"""
      @todo, write a couple of hints for the solving this exercise
      \"""
    ]
  end
  """

  embed_template :test_helper, """
  defmodule Workshop.Exercise.<%= @module %>Check.Helper do
    def exec(solution) do
      # this file should know how to load the given exercise solution
      solution_dir =
        solution
        |> Workshop.Exercise.exercise_sandbox_name
        |> Path.expand(Workshop.Session.get(:folder))

      # locate and load the users solution
      script = "exercise.exs" |> Path.expand(solution_dir)
      Code.require_file(script)

      # load and run the solution checker
      Code.require_file("check.exs", __DIR__)

      Workshop.Exercise.<%= @module %>Check.run()
    end
  end
  """

  embed_template :check, """
  defmodule Workshop.Exercise.<%= @module %>Check do
    use Workshop.SolutionCheck

    verify "verify something" do
      # return value can be :ok, {:warning, message}, or {:error, message}
      :ok
    end

    verify "verify something else" do
      :ok
    end
  end
  """
end
