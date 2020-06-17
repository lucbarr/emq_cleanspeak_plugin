defmodule EmqCleanspeakPlugin.Body do

    alias EmqCleanspeakPlugin.{Filter}
    require Logger

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
        Logger.debug fn -> "on_message_publish: #{msg}" end

        {payload, topic} = {mqtt_message(msg, :payload), mqtt_message(msg, :topic)}
        filtered_message = Filter.filter(payload,topic)
        msg = mqtt_message(msg, payload: filtered_message)
        
        {:ok, msg}
    end
    
end


