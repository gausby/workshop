defmodule Workshop.Mixfile do
  use Mix.Project

  @version File.read!("VERSION") |> String.strip
  defp description do
    """
    Mix tasks for creating and running interactive workshops for teaching
    people how to program in Elixir, and other things.
    """
  end

  def project do
    [app: :workshop,
     version: @version,
     description: description,
     package: package,
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp package do
    %{
      licenses: ["Apache v2.0"],
      contributors: [
        "Martin Gausby"
      ],
      links: %{
        "GitHub" => "https://github.com/gausby/workshop",
        "Bugs" => "https://github.com/gausby/workshop/issues"
      },
      files: ~w(lib config mix.exs LICENSE VERSION README*)
    }
  end

  # This project should not have any third-party dependencies as it should
  # be able to build to, and be distributed as, a mix archive.
  defp deps, do: []
end
