defmodule EmqCleanspeakPlugin do
  use Application

  def start(_type, _args) do
    {:ok, supervisor} = EmqCleanspeakPlugin.Supervisor.start_link()
    :ok = EmqCleanspeakPlugin.Body.load([])
    {:ok, supervisor}
  end

  def stop(_app) do
    EmqCleanspeakPlugin.Body.unload()
  end
end
