defmodule Harmony.Chat.RoomHost do
  alias Harmony.Chat.RoomServer

  use GenServer

  def init(_) do
    {:ok, nil}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def child_spec() do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

  def handle_call({:create, room, name}, _from, _) do
    children = [
      {RoomServer, room: room, name: name}
    ]

    opts = [strategy: :one_for_one]
    {:ok, sup} = Supervisor.start_link(children, opts)
    [{_, pid, _, _}] = Supervisor.which_children(sup)

    {:reply, {:ok, pid}, nil}
  end
end
