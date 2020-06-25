defmodule EmqCleanspeakPlugin do
  use Application
  require Logger

  def start(_type, _args) do
    Logger.debug fn ->
      "starting cleanspeak plugin"
    end

    {:ok, supervisor} = EmqCleanspeakPlugin.Supervisor.start_link()
    :ok = EmqCleanspeakPlugin.Body.load([])
    {:ok, supervisor}
  end

  def stop(_app) do
    EmqCleanspeakPlugin.Body.unload()
  end
end
