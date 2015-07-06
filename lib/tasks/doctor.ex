defmodule Mix.Tasks.Workshop.Doctor do
  use Mix.Task

  @prerequisite_file_name "prerequisite.exs"

  defp prerequisite_file(folder),
    do: Path.join(folder, @prerequisite_file_name)

  defp execute_prerequisite_check(path) do
    if File.exists? path do
      # compile and execute the run function on the first found module
      prerequisite = Code.load_file(path) |> hd |> elem(0)
      prerequisite.run()
    else
      {:ok, "no prerequisites defined"}
    end
  end

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    {_, _, _} = OptionParser.parse(argv, switches: [system: :boolean])

    {_, failures} = prerequisite_file("./sample")
                    |> execute_prerequisite_check

    IO.inspect failures
    System.at_exit fn _ ->
      if failures > 0, do: exit({:shutdown, 1})
    end
  end
end
