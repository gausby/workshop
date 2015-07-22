defmodule Mix.Tasks.Workshop.New.Workshop do
  use Mix.Task
  import Mix.Generator
  import Mix.Utils, only: [camelize: 1]

  @shortdoc "Create a new workshop"
  @moduledoc """
  Creates a new workshop.

  It expects a path for the workshop

      mix workshop.new.workshop PATH

  The path will be named after the given PATH. Given `my_workshop` will
  result in a workshop named *My Workshop*.
  """

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    {opts, argv, _} = OptionParser.parse(argv, switches: [])

    case argv do
      [] -> Mix.raise "Expected PATH to be given. Please use `mix workshop.new.workshop PATH`"
      [path|_] ->
        name = Path.basename(Path.expand(path))
        check_workshop_name!(name)
        mod = camelize(name)
        title = snake_case_to_headline(name)
        case File.mkdir_p(path) do
          :ok ->
            File.cd!(path, fn ->
              do_generate_workshop(path, title, mod, opts)
            end)
        end
    end
  end

  defp check_workshop_name!(name) do
    # taken from the `mix new` source code
    unless name =~ ~r/^[a-z][\w_]*$/ do
      Mix.raise "Workshop name must start with a letter and have only lowercase " <>
                "letters, numbers and underscore, got: #{inspect name}"
    end
  end

  defp do_generate_workshop(name, title, mod, opts \\ []) do
    assigns = [name: name, title: title, module: mod]

    create_file "README.md", readme_template(assigns)
    create_directory ".workshop"
    create_file ".workshop/prerequisite.exs", prerequisite_template(assigns)
    create_file ".workshop/workshop.exs", workshop_template(assigns)
    create_directory ".workshop/exercises"
    create_file ".workshop/exercises/.gitkeep", ""
  end

  defp snake_case_to_headline(name) do
    name
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  embed_template :readme, """
  <%= @title %>
  <%= String.replace(@title, ~r/./, "=") %>
  **TODO: add a short description of the workshop**

  What's next?
  ------------
  Type `mix workshop.start` in the terminal to start the workshop, and
  have fun!
  """

  embed_template :workshop, """
  defmodule <%= @module %> do
    def info do
      [title: "<%= @title %>",
      version: "0.0.1",
      description: description]
    end

    defp description, do: \"""
    **TODO: write a short description of the workshop**
    \"""
  end
  """

  embed_template :prerequisite, """
  defmodule <%= @module %>.Prerequisite do
    def run() do
      :ok
    end
  end
  """
end
