defmodule CNMN.Image do
  @moduledoc """
  Image transformation functions.
  """

  alias Mogrify, as: Mog

  defp pctstring(percentage) do
    to_string(percentage) <> "%"
  end

  def factorstring(percentage) do
    pctstring(percentage) <> "x" <> pctstring(percentage)
  end

  def crunch(image, factor) do
    image |> Mog.custom("liquid-rescale", factorstring(factor))
  end

  def save(image, path) do
    Mog.save(image, path: path)
    path
  end
end
