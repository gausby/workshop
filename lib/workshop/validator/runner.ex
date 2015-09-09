defmodule Workshop.Validator.Runner do
  alias Workshop.Validator.Result

  def run(checks, module, context \\ nil) do
    for func <- Enum.reverse(checks), into: %Result{} do
      apply(module, func, [context])
    end
  end
end
