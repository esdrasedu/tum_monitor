defmodule TumMonitor.Scoreboard do
  use GenServer

  import Phoenix.PubSub

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    true = connect_tum()
    chain = blocks()
    rank = chain
    |> update_rank(%{})
    interval()
    {:ok, %{blocks: chain, rank: rank}}
  end

  def connect_tum() do
    {:ok, nodes} = :net_adm.names()
    [name, _] = nodes
    |> Enum.map(fn({name, _port}) -> name end)

    {:ok, [{ip_t, _mask, _submask} | _tail]} = :inet.getif()
    ip = ip_t
    |> Tuple.to_list()
    |> Enum.join(".")

    "#{name}@#{ip}"
    |> String.to_atom()
    |> Node.connect()
  end

  def blocks() do
    Node.list()
    |> Kernel.hd()
    |> :rpc.call(Tum, :blocks, [])
  end

  def update_rank([%{message: "My name is " <> name, public_key: public_key} | blocks], rank) do
    line = rank
    |> Map.get(public_key, %{name: public_key, point: 0})

    rank = rank
    |> Map.put(public_key, %{line | point: line.point + 1, name: name })
    update_rank(blocks, rank)
  end
  def update_rank([%{public_key: public_key} | blocks], rank) do
    line = rank
    |> Map.get(public_key, %{name: public_key, point: 0})

    rank = rank
    |> Map.put(public_key, %{line | point: line.point + 1})
    update_rank(blocks, rank)
  end
  def update_rank([], rank) do
    rank
    |> Enum.map(fn({_att, value}) -> value end)
    |> Enum.sort(&(&1.point >= &2.point))
  end

  def handle_info(:update, _state) do
    chain = blocks()
    rank = chain
    |> update_rank(%{})

    interval()

    broadcast(TumMonitor.PubSub, "monitor", {:update, %{blocks: chain, rank: rank}})

    {:noreply, %{blocks: chain, rank: rank}}
  end

  def interval() do
    Process.send_after(self(), :update, 1_000)
  end

  def state() do
    GenServer.whereis(__MODULE__)
    |> :sys.get_state()
  end
end
