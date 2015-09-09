defmodule Workshop.Doctor do
  use Workshop.Validator

  verify "System should have the same major minor version as the creation script" do
    # todo, the workshop should save the workshop version number it was created with
    :ok
  end

  # This will fetch the result of the prerequisite tests defined for the workshop in *prerequisite.exs*
  verify "Should pass all workshop prerequisite tests" do
    path =
      "prerequisite.exs"
      |> Path.expand(Workshop.Session.get(:data_folder))

    if File.exists? path do
      Code.require_file(path)
      apply(Workshop.Prerequisite, :run, [])
    else
      {:warning, "Could not find a prerequisite file for this workshop"}
    end
  end
end
