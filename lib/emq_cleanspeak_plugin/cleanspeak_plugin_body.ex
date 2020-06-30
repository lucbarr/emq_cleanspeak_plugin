defmodule EmqCleanspeakPlugin.Body do

    alias EmqCleanspeakPlugin.{Filter}
    require Logger
    require Jason

    require Record
    import Record, only: [defrecord: 2, extract: 2]
    defrecord :mqtt_message, extract(:mqtt_message, from: "include/emqttd.hrl")

    def hook_add(a, b, c) do
        :emqttd_hooks.add(a, b, c)
    end
    
    def hook_del(a, b) do
        :emqttd_hooks.delete(a, b)
    end

    def load(env) do
        hook_add(:"message.publish",      &EmqCleanspeakPlugin.Body.on_message_publish/2,     [env])
    end

    def unload do
        hook_del(:"message.publish",      &EmqCleanspeakPlugin.Body.on_message_publish/2     )
    end
    
    def on_message_publish(msg, _env) do
        {payload, topic} = {mqtt_message(msg, :payload), mqtt_message(msg, :topic)}
        Logger.debug fn ->
          "on message publish called:" <> payload <> ";" <> topic
        end

        case topic do
          "$SYS/" <> _ ->  {:ok, msg}
          _ ->
            Logger.debug fn ->
              "filtering message"
            end

            msg =
            case build_filtered_payload(payload, topic) do
              {:ok, new_payload} ->
                mqtt_message(msg, payload: new_payload)
              {:notok, _payload} ->
                Logger.warn "failed to build filtered payload"
                msg
            end

            {:ok, msg}
        end
    end

    def build_filtered_payload(payload, topic) do
        case Jason.decode(payload) do
          {:error, _} -> {:notok, payload}
          {_, payload_json} ->
            payload_message = payload_json["message"]
            filtered_message = Filter.filter(payload_message,topic)

            payload_json = %{payload_json | "message" => filtered_message}
            new_payload = Jason.encode!(payload_json)

            {:ok, new_payload}
        end
    end

end


