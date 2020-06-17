defmodule EmqCleanspeakPlugin.Supervisor do
  # Automatically imports Supervisor.Spec
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = []

    HTTPoison.start()

    # supervise/2 is imported from Supervisor.Spec
    supervise(children, strategy: :one_for_one)
  end
end

