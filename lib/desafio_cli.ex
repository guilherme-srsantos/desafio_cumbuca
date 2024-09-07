defmodule DesafioCli do
  @moduledoc """
  Documentation for `DesafioCli`.
  """

  @doc """
  ## Examples

      iex> DesafioCli.main(1)

  """

  def main(_args) do
    try do
      KvsServer.start_link()
      start_server()
    catch
      :exit, reason ->
        IO.puts("Aplicacao finalizada #{inspect(reason)}")
      error ->
        IO.puts("Erro de execucao #{inspect(error)}")
    end
  end

  defp start_server do
    IO.gets("> ")
    |> String.trim()
    |> process_command()
    start_server()
  end

  defp process_command(""), do: :ok
  defp process_command(command), do: handle_command(command)

  defp handle_command(command) do
    case String.split(command) do
      ["SET", key, value] -> handle_set(key, value)
      ["SET", _] -> IO.puts("ERR \" Invalid syntax\"")
      ["GET", key] -> handle_get(key)
      ["BEGIN"] -> handle_begin_transaction()
      ["ROLLBACK"] -> handle_transaction_rollback()
      ["COMMIT"] -> handle_transaction_commit()
      _ -> IO.puts("ERR \"No command #{command}\"")
    end
  end

  defp handle_set(key, value) do
    KvsServer.set(key, Utils.format_value(value))
  end

  defp handle_get(key) do
    case KvsServer.get(key) do
      nil -> IO.puts("NIL")
      value -> IO.puts(Utils.format_value(value))
    end
  end

  defp handle_begin_transaction() do
    transaction_level = KvsServer.begin_transaction()
    IO.puts(transaction_level)
  end

  defp handle_transaction_rollback() do
    case KvsServer.rollback_transaction() do
      {:error, message} -> IO.puts("ERR \"#{message}\"")
      transaction_level -> IO.puts(transaction_level)
    end
  end

  defp handle_transaction_commit() do
    transaction_level = KvsServer.commit_transaction()
    IO.puts(transaction_level)
  end

end
