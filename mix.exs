defmodule CNMN.MixProject do
  use Mix.Project

  def project do
    [
      app: :cnmn,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {CNMN.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [{:nostrum, "~> 0.7.0-rc2"}]
  end
end
