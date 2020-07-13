defmodule EmqCleanspeakPlugin.Filter do
  require Logger
  require Jason
  require HTTPoison

  def init do
    Application.put_env(:emq_cleanspeak_plugin, :filter_url, (System.get_env("CLEANSPEAK_URL") || "" ) <> "/content/item/filter")
    Application.put_env(:emq_cleanspeak_plugin, :cleanspeak_token, System.get_env("CLEANSPEAK_TOKEN") || "")
    Application.put_env(:emq_cleanspeak_plugin, :minimum_severity, System.get_env("CLEANSPEAK_FILTER_MINIMUMSEVERITY") || "high")
    Application.put_env(:emq_cleanspeak_plugin, :filter_enabled, String.equivalent?(System.get_env("FILTER_ENABLED") || "", "true") || false)
    Application.put_env(:emq_cleanspeak_plugin, :filtered_topics, String.split(System.get_env("FILTER_ENABLED_TOPICS_CONTAINS") || "", ","))
  end

  def filter_url do Application.get_env(:emq_cleanspeak_plugin, :filter_url) end
  def cleanspeak_token do Application.get_env(:emq_cleanspeak_plugin, :cleanspeak_token) end
  def minimum_severity do Application.get_env(:emq_cleanspeak_plugin, :minimum_severity) end
  def filter_enabled do Application.get_env(:emq_cleanspeak_plugin, :filter_enabled) end
  def filtered_topics do Application.get_env(:emq_cleanspeak_plugin, :filtered_topics) end
  # TODO(luciano): handle no topics case as none rather than all - contains ""

  def default_headers do [{"Content-Type", "application/json"}, {"Authorization", cleanspeak_token()}] end

  def filter(message, topic, config \\ %{enabled: filter_enabled(), filtered_topics: filtered_topics()}) do
    Logger.debug "filtering message;topic: #{message};#{topic}"

    case config.enabled && is_filtered_topic?(topic, config.filtered_topics) do
      true -> 
        Logger.debug "filtering enabled for topic #{topic}"
        case request_filter(message) do
          {:ok, filtered_message} -> filtered_message
          {_, _filtered_message} -> message
        end
      false ->
        Logger.debug "filtering disabled for topic #{topic}"
        Logger.debug "filter enabled: #{config.enabled}; filtered topics: #{config.filtered_topics}"
        message
    end

  end

  def is_filtered_topic?(topic, filtered_topics) do
    Enum.any?(filtered_topics, fn filtered_topic -> String.contains?(topic, filtered_topic) end )
  end

  defp request_filter(message) do
    Logger.debug "requesting for filter"
    body = Jason.encode!(%{"blacklist" => %{"minimumSeverity" => minimum_severity()}, "content" => message})

    case HTTPoison.post(filter_url(), body, default_headers()) do
      {:ok, response} -> 
        filtered_message = Jason.decode!(response.body)["replacement"]
        Logger.debug "filtered message #{filtered_message}"
        {:ok, filtered_message}
      _ ->
        Logger.error fn ->
          "error trying to filter message: #{message}"
        end
        {:notok, message}
    end
  end
end

