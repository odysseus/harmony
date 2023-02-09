defmodule HarmonyWeb.Chat.RoomLive do
  use HarmonyWeb, :live_view
  alias HarmonyWeb.Chat.{MessageComponent, MessageFormComponent}
  alias Harmony.Chat.{Room, RoomServer}
  alias Phoenix.PubSub

  @default_room %{name: "General Chat", key: "general-chat"}
  @chat_server_registry ChatServerCache
  @chat_room_host ChatRoomHost

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_room(@default_room)
     |> subscribe_to_room()}
  end

  defp assign_room(socket, room) do
    case Registry.lookup(@chat_server_registry, room.key) do
      [{pid, _}] ->
        room = RoomServer.fetch_data(pid)

        socket
        |> assign(room_pid: pid)
        |> assign(room: room)

      [] ->
        name = {:via, Registry, {@chat_server_registry, room.key}}
        {:ok, pid} = GenServer.call(ChatRoomHost, {:create, room, name})
        room = RoomServer.fetch_data(pid)

        # The easy way to get persistence without supervision

        # {:ok, pid} = GenServer.start(RoomServer, room, name: name)
        # room = RoomServer.fetch_data(pid)

        socket
        |> assign(room_pid: pid)
        |> assign(room: room)
    end
  end

  defp subscribe_to_room(socket) do
    if connected?(socket) do
      PubSub.subscribe(
        Harmony.PubSub,
        socket.assigns.room.posts_channel_key
      )
    end

    socket
  end

  def render(assigns) do
    ~H"""
    <section class="container" id="#{@room.key}">
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

  def handle_info({:new_post, msg}, %{assigns: %{room: room}} = socket) do
    {:noreply,
     socket
     |> assign(room: Room.post(room, msg))}
  end
end
