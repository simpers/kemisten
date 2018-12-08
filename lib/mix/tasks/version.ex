defmodule Mix.Tasks.Version do
  use Mix.Task

  require Mix.Releases.Config

  @shortdoc "Prints the current version of the project."
  def run(_) do
    IO.puts Mix.Releases.Config.current_version(:kemisten)
  end
end
