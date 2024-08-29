defmodule ReqMulti.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/tubedude/req_multipart"

  def project do
    [
      app: :req_multi,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      source_url: @source_url
    ]
  end

  defp package do
    [
      name: "req_multi",
      description: "A Req plugin for handling multipart requests",
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/tubedude/req_multipart"},
      maintainers: ["Roberto Trevisan"]
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.6"},
      {:plug, "~> 1.0"},
      {:multipart, "~> 0.4.0"},

      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
