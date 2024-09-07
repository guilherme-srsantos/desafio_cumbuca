defmodule Utils do

  def parse_value("TRUE"), do: true
  def parse_value("FALSE"), do: false
  def parse_value(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> value
    end
  end

  def format_value(true), do: "TRUE"
  def format_value(false), do: "FALSE"
  def format_value(value) when is_binary(value), do: value
  def format_value(value) when is_integer(value), do: Integer.to_string(value, 10)

end
