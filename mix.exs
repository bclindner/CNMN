defmodule CNMN.MixProject do
  use Mix.Project

  def project do
    [
      app: :cnmn,
      version: "1.0.1",
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

  def deps do
    [
      {:nostrum, "~> 0.7.0-rc2"},
      {:mogrify, "~> 0.9.2"},
      {:temp, "~> 0.4"},
      {:jason, "~> 1.3"}
    ]
  end
end
