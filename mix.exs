defmodule Esimplescraper.Mixfile do
  use Mix.Project

  def project do
    [ app: :esimplescraper,
      version: "0.0.1",
      elixir: "~> 0.10.3",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:hackney]]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [{ :hackney, "> 0.0", git: "git://github.com/benoitc/hackney.git" },
     { :mochiweb, "> 0.0", git: "git://github.com/mochi/mochiweb.git" }]
  end
end
