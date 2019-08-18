defmodule RTL.TimeParser do
  def string_to_float(nil), do: nil
  def string_to_float(""), do: nil
  def string_to_float(string) do
    string = String.trim(string)
    # Verify that the string is in a valid format
    if Regex.run(~r/\A(\d\d?:)?\d\d?(\.\d+)?\z/, string) do
      tokens = string |> String.split(":") |> Enum.reverse()
      sec = Enum.at(tokens, 0) |> parse_float!()
      min = (Enum.at(tokens, 1) || "0") |> String.to_integer()
      min * 60 + sec
    else
      raise "Don't know how to parse time string: #{inspect(string)}"
    end
  end

  def float_to_string(nil), do: nil
  def float_to_string(float) when is_float(float) do
    floor = trunc(float)
    min = trunc(floor / 60)
    sec = (float - min * 60) |> Float.round(2)
    pad = if sec < 10, do: "0", else: ""

    "#{min}:#{pad}#{int_or_float(sec)}"
  end

  defp parse_float!(string) do
    {float, ""} = Float.parse(string)
    float
  end

  def int_or_float(num) do
    if num == trunc(num), do: trunc(num), else: num
  end
end
