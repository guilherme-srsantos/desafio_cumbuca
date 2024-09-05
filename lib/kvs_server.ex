defmodule KvsServer do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end


  def set(key, value) do
    GenServer.call(__MODULE__, {:set, key, value})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def begin_transaction() do
    GenServer.call(__MODULE__, :begin)
  end

  def rollback_transaction() do
    GenServer.call(__MODULE__, :rollback)
  end

  def commit_transaction() do
    GenServer.call(__MODULE__, :commit)
  end



  @impl true
  def init(state) do
    {:ok, %{store: %{}, transactions: []}}
  end

  @impl true
  def handle_call({:set, key, value}, _from, state) do
    IO.puts("set on server #{key}, #{value}")
    {:reply, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    IO.puts("get on server #{key}")
    {:noreply, state}
  end

  @impl true
  def handle_call(:begin, _from, state) do
    IO.puts("begin transaction on server")
    {:noreply, state}
  end

  @impl true
  def handle_call(:commit, _from, state) do
    IO.puts("commit transaction")
    {:noreply, state}
  end

  @impl true
  def handle_call(:rollback, _from, state) do
    IO.puts("rollback transaction")
    {:noreply, state}
  end
end
