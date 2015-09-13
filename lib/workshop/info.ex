defmodule Workshop.Info do
  @doc false
  defmacro __using__(_opts) do
    quote do
      Enum.each [:title, :version, :home, :description, :shortdesc, :introduction, :debriefing],
        &Module.register_attribute(__MODULE__, &1, persist: true)
    end
  end

  @spec get(atom, atom) :: String.t | nil
  def get(module, subject) when is_atom(module) and is_atom(subject) do
    case List.keyfind module.__info__(:attributes), subject, 0 do
      {:shortdesc, [false]} ->
        false
      {^subject, [content|_]} ->
        content
      _ ->
        nil
    end
  end
end
