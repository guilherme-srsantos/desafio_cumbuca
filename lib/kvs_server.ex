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
  def init(_) do
    state = load_state()
    {:ok, state}
  end

  @impl true
  def handle_call({:set, key, value}, _from, state) do
    {existed, new_state} = case state.transactions do
      [] ->
        existed = Map.has_key?(state.store, key)
        new_store = Map.put(state.store, key, value)
        new_state = %{state | store: new_store}
        {existed, save_state(new_state)}
      [current | _] ->
        existed = Map.has_key?(current, key)
        new_current = Map.put(current, key, value)
        new_state = %{state | transactions: [new_current | tl(state.transactions)]}
        {existed, new_state}
  end

    {:reply, {existed, value}, new_state}
  end


  def handle_call({:get, key}, _from, state) do
    value = case state.transactions do
      [] -> Map.get(state.store, key)
      [current | _] -> Map.get(current, key, Map.get(state.store, key))
    end

    {:reply, value, state}
  end

  def handle_call(:begin, _from, state) do
    new_transactions = [Map.new() | state.transactions]
    new_state = %{state | transactions: new_transactions}
    {:reply, length(new_transactions), new_state}
  end

  def handle_call(:rollback, _from, state) do
    case state.transactions do
      [] ->
        {:reply, {:error, "Cannot rollback at transaction level 0"}, state}
      [_ | rest] ->
        new_state = %{state | transactions: rest}
        {:reply, length(rest), new_state}
    end
  end

  def handle_call(:commit, _from, state) do
    case state.transactions do
      [] ->
        {:reply, 0, state}
      [current | rest] ->
        new_store = case rest do
          [] ->
            merged_store = Map.merge(state.store, current)
            save_state(%{state | store: merged_store, transactions: []})
            merged_store
          [parent | _] -> Map.merge(parent, current)
        end
        new_state = %{state |
          store: (if rest == [], do: new_store, else: state.store),
          transactions: (if rest == [], do: [], else: [new_store | tl(rest)])
        }
        {:reply, length(rest), new_state}
    end
  end
  end
end
