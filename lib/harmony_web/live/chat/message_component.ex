defmodule HarmonyWeb.Chat.MessageComponent do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <div class="message">
    <p><b><%= @message.name %>:</b> <%= @message.text %></p>
    </div>
    """
  end
end
