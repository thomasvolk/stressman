defmodule StressMan.Mixfile do
  use Mix.Project

  def project do
    [
      app: :stressman,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      escript: [main_module: StressMan.CLI],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [ mod: {StressMan, []},
      applications: [:logger, :httpoison, :gproc]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 0.13"},
      {:gproc, "~> 0.6"}
    ]
  end
end
