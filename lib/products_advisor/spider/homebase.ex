defmodule Homebase do
  @behaviour Crawly.Spider

  require Logger

  @impl Crawly.Spider
  def base_url(), do: "https://www.homebase.co.uk"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://www.homebase.co.uk/our-range/tools",
        "https://www.homebase.co.uk/our-range/lighting-and-electrical/torches-and-nightlights/worklights"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    # Extract product categories URLs
    product_categories =
      response.body
      |> Floki.find("div.product-list-footer a")
      |> Floki.attribute("href")

    # Extract individual product page URLs
    product_pages =
      response.body
      |> Floki.find("a.product-tile  ")
      |> Floki.attribute("href")

    urls = product_pages ++ product_categories

    # Convert URLs into Requests
    requests =
      urls
      |> Enum.uniq()
      |> Enum.map(&build_absolute_url/1)
      |> Enum.map(&Crawly.Utils.request_from_url/1)

    category =
      response.body
      |> Floki.find(".breadcrumb span")
      |> nth(2)
      |> Floki.text()

    images = response.body |> Floki.find("img.rsTmb") |> Floki.attribute("src")

    # Create item (for pages where items exists)
    item = %{
      title: response.body |> Floki.find(".page-title h1") |> Floki.text(),
      id:
        response.body
        |> Floki.find(".product-header-heading span")
        |> Floki.text(),
      images: images,
      category: category,
      description:
        response.body
        |> Floki.find(".product-details__description")
        |> Floki.text()
    }

    Enum.each(images, fn url -> save_image(category, url) end)

    %Crawly.ParsedItem{:items => [item], :requests => requests}
  end

  defp nth(list, num) do
    :lists.nth(num, list)
  end

  defp build_absolute_url(url), do: URI.merge(base_url(), url) |> to_string()

  defp save_image(category, url),
    do: ProductsAdvisor.Spider.save_image(category, url)
end
