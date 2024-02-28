defmodule CNMN.MixProject do
  use Mix.Project

  def project do
    [
      app: :cnmn,
      version: "1.3.1",
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
      {
        :nostrum,
        "~> 0.7.0-rc2",
        # nostrum should not run during tests
        # (see https://github.com/Kraigie/nostrum/issues/230#issuecomment-789498187)
        runtime: Mix.env() != :test
      },
      {:mogrify, "~> 0.9.2"},
      {:temp, "~> 0.4"},
      {:jason, "~> 1.3"},
      {:image, "~> 0.42.0"},
      {:ffmpex, "~> 0.10.0"}
    ]
  end
end
