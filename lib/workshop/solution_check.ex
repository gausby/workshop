defmodule Workshop.SolutionCheck do
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute __MODULE__, :checks, accumulate: true
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def run, do: Workshop.SolutionCheck.Test.run(@checks, __MODULE__)
    end
  end

  defmacro verify(description, do: verify_block) do
    verify_func = String.to_atom(description)
    quote do
      @checks {unquote(verify_func), unquote(description)}
      def unquote(verify_func)(), do: unquote(verify_block)
    end
  end
end

defmodule Workshop.SolutionCheck.Test do
  alias Workshop.ValidationResult, as: Result

  def run(checks, module) do
    for {func, _description} <- checks, into: %Result{} do
      apply(module, func, [])
    end
  end
end
