defmodule MyWorkshop.Manifest do
  def workshop do
    [title: "A sample workshop!",
     version: "0.0.1",
     description: description,
     deps: deps]
  end

  defp description, do: """
  This workshop is a sample workshop used for developing the workshop.
  """

  defp deps do
    [elixir: "~> 1.0"]
  end
end
