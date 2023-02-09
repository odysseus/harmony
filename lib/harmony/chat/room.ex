defmodule Harmony.Chat.Room do
  alias Harmony.Chat.Message

  defstruct name: nil,
            key: nil,
            posts_channel_key: nil,
            messages: []

  def new(%{name: name, key: key} = _opts) do
    %__MODULE__{
      name: name,
      key: key,
      posts_channel_key: posts_channel_keyval(key),
      messages: []
    }
  end

  defp posts_channel_keyval(key) do
    "#{key}-posts"
  end

  def post(room, %{name: name, text: text})
      when is_binary(name) and is_binary(text) do
    msg = %Message{name: name, text: text}
    %{room | messages: [msg | room.messages]}
  end

  def post(room, %{"name" => name, "text" => text})
      when is_binary(name) and is_binary(text) do
    msg = %Message{name: name, text: text}
    %{room | messages: [msg | room.messages]}
  end
end
