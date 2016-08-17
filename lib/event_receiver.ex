require IEx
defmodule Aprb.EventReceiver do
  require Logger

  def start_link(channel) do
    KafkaEx.create_worker(String.to_atom(channel))
    for message <- KafkaEx.stream(channel, 0, worker_name: String.to_atom(channel), offset: latest_offset(channel)), acceptable_message?(message.value) do
      proccessed_message = process_message message
      # broadcast a message to a channel
      IO.inspect proccessed_message
      t = Slack.Web.Chat.post_message("#apr-machines", proccessed_message["verb"])
      IO.inspect t
    end
  end

  def latest_offset(channel) do
    KafkaEx.latest_offset(channel, 0)
        |> List.first
        |> Map.get(:partition_offsets)
        |> List.first
        |> Map.get(:offset)
        |> List.first
  end

  def acceptable_message?(message) do
    try do
      Poison.decode!(message)
        |> is_map
    rescue
      Poison.SyntaxError -> false
    end
  end

  def process_message(message) do
    Poison.decode!(message.value)
      |> Map.take(["verb", "subject", "object", "properties"])
  end
end