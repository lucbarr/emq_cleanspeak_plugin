defmodule EmqCleanspeakPlugin.Filter do
  require Logger
  require Jason
  require HTTPoison

  @filter_url (System.get_env("CLEANSPEAK_URL") || "" ) <> "/content/item/filter"
  @cleanspeak_token System.get_env("CLEANSPEAK_TOKEN") || ""
  @minimum_severity System.get_env("CLEANSPEAK_FILTER_MINIMUMSEVERITY") || "high"
  @filter_enabled String.equivalent?(System.get_env("FILTER_ENABLED") || "", "true") || false
  @filtered_topics String.split(System.get_env("FILTER_ENABLED_TOPICS_CONTAINS") || "", ",")
  # TODO(luciano): handle no topics case as none rather than all - contains ""

  @default_headers [{"Content-Type", "application/json"}, {"Authorization", @cleanspeak_token}]

  def filter(message, topic, config \\ %{enabled: @filter_enabled, filtered_topics: @filtered_topics}) do
    case config.enabled && is_filtered_topic?(topic, config.filtered_topics) do
      true -> 
        case request_filter(message) do
          {:ok, filtered_message} -> filtered_message
          {_, _filtered_message} -> message
        end
      false ->  message
    end

  end

  def is_filtered_topic?(topic, filtered_topics) do
    Enum.any?(filtered_topics, fn filtered_topic -> String.contains?(topic, filtered_topic) end )
  end

  defp request_filter(message) do
    body = Jason.encode!(%{"blacklist" => %{"minimumSeverity" => @minimum_severity}, "content" => message})

    case HTTPoison.post(@filter_url, body, @default_headers) do
      {:ok, response} -> 
        filtered_message = Jason.decode!(response.body)["replacement"]
        {:ok, filtered_message}
      _ ->
        Logger.error fn ->
          "error trying to filter message: #{message}"
        end
        {:notok, message}
    end
  end
end

