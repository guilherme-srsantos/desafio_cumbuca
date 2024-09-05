defmodule DesafioCumbuca do
  @moduledoc """
  Documentation for `DesafioCumbuca`.
  """

  @doc """
  ## Examples

      iex> DesafioCumbuca.main(1)

  """

  def main(args) do
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
      ["GET", key] -> handle_get(key)
      ["BEGIN"] -> handle_begin_transaction()
      ["ROLLBACK"] -> handle_transaction_rollback()
      ["COMMIT"] -> handle_transaction_commit()
      _ -> IO.puts("ERR \"Comando #{command} invalido\"")
    end
  end

  defp handle_set(key, value) do
    KvsServer.set(key, value)
  end

  defp handle_get(key) do
    KvsServer.get(key)
  end

  defp handle_begin_transaction() do
    IO.puts("BEGIN TRANSACTION")
    KvsServer.begin_transaction()
  end

  defp handle_transaction_rollback() do
    IO.puts("TRANSACTION ROLLBACK")
    KvsServer.rollback_transaction()
  end

  defp handle_transaction_commit() do
    IO.puts("TRANSACTION COMMIT")
    KvsServer.commit_transaction()
  end

end
