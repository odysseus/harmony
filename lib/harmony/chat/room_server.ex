defmodule Harmony.Chat.RoomServer do
  use GenServer

  alias Phoenix.PubSub
  alias Harmony.Chat.Room

  def init(%{name: _, key: _} = opts) do
    {:ok, Room.new(opts)}
  end

  def handle_cast({:post, msg}, room) do
    room = Room.post(room, msg)
    msg = List.first(room.messages)

    PubSub.broadcast(
      Harmony.PubSub,
      room.posts_channel_key,
      {:new_post, msg}
    )

    {:noreply, room}
  end

  def handle_call({:fetch_data}, _from, room) do
    {:reply, room, room}
  end

  def start_link(room: room, name: name) do
    GenServer.start_link(__MODULE__, room, name: name)
  end

  def child_spec(room: room, name: name) do
    %{
      id: room.key,
      start: {__MODULE__, :start_link, [[room: room, name: name]]}
    }
  end

  def post(pid, msg) do
    GenServer.cast(pid, {:post, msg})
  end

  def fetch_data(pid) do
    GenServer.call(pid, {:fetch_data})
  end
end
