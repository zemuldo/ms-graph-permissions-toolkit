defmodule Scrapper.Scheduler do
  use Quantum, otp_app: :scrapper

  def to_db() do
    Scrapper.run("v1.0") |> Scrapper.to_db
  end

end
