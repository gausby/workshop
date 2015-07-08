defmodule Binary do
  @spec to_decimal(String.t) :: Integer
  def to_decimal(word) do
    word
    |> String.split("", trim: true)
    |> Enum.reduce(0, fn
         "1", acc -> acc * 2 + 1
         "0", acc -> acc * 2
       end)
  end
end
