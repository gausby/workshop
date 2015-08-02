defmodule Workshop.Exercise do
  @doc false
  defmacro __using__(_opts) do
    quote do
      Enum.each [:title, :description],
        &Module.register_attribute(__MODULE__, &1, persist: true)
    end
  end
end
