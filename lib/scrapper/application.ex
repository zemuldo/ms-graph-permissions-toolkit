defmodule Scrapper.Application do
  use Application

  @impl true
  def start(_type, _args) do

    opts = [strategy: :one_for_one, name: Scrapper.Supervisor]

     Supervisor.start_link([Scrapper.Repo] , opts)
  end
end
