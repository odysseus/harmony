defmodule HarmonyWeb.Chat.RoomLive do
  use HarmonyWeb, :live_view
  alias HarmonyWeb.Chat.{MessageComponent, MessageFormComponent}
  alias Harmony.Chat.{RoomServer}

  @default_room %{name: "General Chat", key: "general-chat"}
  @chat_server_registry ChatServerCache

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_room(@default_room)}
  end

  defp assign_room(socket, opts) do
    case Registry.lookup(@chat_server_registry, opts.key) do
      [{pid, _}] ->
        room = RoomServer.fetch_data(pid)
        socket
        |> assign(room_pid: pid)
        |> assign(room: room)

      [] ->
        name = {:via, Registry, {@chat_server_registry, opts.key}}
        {:ok, pid} = GenServer.start_link(RoomServer, opts, name: name)
        room = RoomServer.fetch_data(pid)
        socket
        |> assign(room_pid: pid)
        |> assign(room: room)
    end
  end

  def render(assigns) do
    ~H"""
    <section class="container">
    <h1><%= @room.name %></h1>
    <%= for msg <- @room.messages do %>
      <MessageComponent.render message={ msg } />
    <% end %>

    <MessageFormComponent.render />
    </section>
    """
  end

  def handle_event(
        "post",
        %{"message" => message},
        %{assigns: %{room_pid: pid}} = socket
      ) do

    RoomServer.post(pid, message)
    {:noreply, socket}
  end
end
