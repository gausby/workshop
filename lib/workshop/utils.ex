defmodule Workshop.Utils do

  @doc """
  Find the workshop data folder for the current workshop
  """
  def find_workshop_data_folder, do: find_workshop_data_folder(File.cwd!)

  @doc """
  Find the data folder of the workshop starting from *folder*
  """
  def find_workshop_data_folder(folder) do
    candidate = Path.join(folder, ".workshop")
    if File.exists?(candidate) and File.exists?(Path.join(candidate, "exercises")) do
      {:ok, candidate}
    else
      parent = Path.dirname(folder)
      unless folder == parent do
        find_workshop_data_folder parent
      else
        {:error, "Folder is not within a workshop"}
      end
    end
  end

  @doc """
  find the root of the workshop
  """
  def find_workshop_folder, do: find_workshop_folder(File.cwd!)

  @doc """
  Find the root folder of the workshop starting from *folder*
  """
  def find_workshop_folder(folder) do
    case find_workshop_data_folder(folder) do
      {:ok, data_folder} -> {:ok, Path.dirname data_folder}
      error -> error
    end
  end

  def find_exercise_folders!(folder) do
    folder
    |> File.ls!
    |> Enum.filter(&(String.match?(&1, ~r/^\d/)))
    |> Enum.filter(&(File.dir?(Path.join(folder, &1))))
  end

  @headline_char ?#
  def get_exercise_title!(exercise_folder) do
    Path.join(exercise_folder, "README.md")
    |> File.stream!
    |> Enum.take(1)
    |> hd
    |> String.lstrip(@headline_char)
    |> String.strip
  end

  # workshops should get prefixed with a weight
  def get_exercises_by_weight! do
    File.ls!(File.cwd!)
    |> Enum.reject(&(String.starts_with?(&1, ".")))
    |> Enum.map(fn item ->
                  [number, name] = String.split(item, "_", parts: 2)
                  {String.to_integer(number), name}
               end)
    |> Enum.sort
  end
end
