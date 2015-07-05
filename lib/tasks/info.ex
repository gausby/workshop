defmodule Mix.Tasks.Workshop.Info do
  use Mix.Task

  def run(_) do
    Mix.shell.info Workshop.get_description("./sample")
  end
end
