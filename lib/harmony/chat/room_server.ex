defmodule Harmony.Chat.RoomServer do
  use GenServer

  alias Harmony.Chat.Room

  def init(%{name: _, key: _} = opts) do
    {:ok, Room.new(opts)}
  end

  def handle_cast({:post, msg}, room) do
    {:noreply, Room.post(room, msg)}
  end

  def handle_call({:fetch_data}, _from, room) do
    {:reply, room, room}
  end

  def post(pid, msg) do
    GenServer.cast(pid, {:post, msg})
  end

  def fetch_data(pid) do
    GenServer.call(pid, {:fetch_data})
  end
end
