defmodule HarmonyWeb.Chat.MessageFormComponent do
  use HarmonyWeb, :live_component
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <div>
    <.form
    let={f}
    for={:message}
    id="chat-entry"
    phx-submit="post">

    <%= label f, :name %>
    <%= text_input f, :name %>

    <%= label f, :text %>
    <%= text_input f, :text %>

    <%= submit "Send" %>

    </.form>
    </div>
    """
  end
end
