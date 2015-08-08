defmodule Workshop.Exercises do
  def list! do
    exercises_folder = Workshop.Session.get(:exercises_folder)

    exercises_folder
    |> File.ls!
    |> Enum.filter(&(String.match?(&1, ~r/^\d/)))
    |> Enum.filter(&(File.dir?(Path.join(exercises_folder, &1))))
  end

  def list_by_weight! do
    list!
    |> Enum.map(fn item ->
                  [number, name] = String.split(item, "_", parts: 2)
                  {String.to_integer(number), name}
               end)
    |> Enum.sort
  end

  @spec find_next! :: {:next, String.t} | :workshop_over
  def find_next! do
    exercises = list!
    case Workshop.State.get(:progress)[:cursor] do
      nil ->
        {:next, List.first(exercises)}
      cursor ->
        {_, remaining} = Enum.split_while(exercises, &(cursor != &1))
        case remaining do
          [_current | []] ->
            :workshop_over
          [_current, next|_] ->
            {:next, next}
        end
    end
  end
end
