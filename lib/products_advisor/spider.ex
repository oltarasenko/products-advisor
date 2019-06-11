defmodule ProductsAdvisor.Spider do
  @moduledoc false

  require Logger

  def save_image("", _), do: :ignored
  def save_image(category, url) do
    category = String.downcase(category) |> String.replace(" ", "_")
    base_dir = "/tmp/products_advisor/#{category}"
    File.mkdir_p(base_dir)

    case HTTPoison.get(url) do
      {:ok, response} ->
        save_jpeg(base_dir, response.body)
      _ ->
        Logger.error("Unable to fetch image..")
    end
  end

  def save_jpeg(dir, buffer) do
    case ExMagic.from_buffer!(buffer) do
      "image/jpeg" ->
        filename = "#{UUID.uuid4()}.jpeg"
        full_path = Path.join(dir, filename)
        File.write(full_path, buffer)
      _ ->
        Logger.info("File is not a jpeg") 
    end
  end
end
