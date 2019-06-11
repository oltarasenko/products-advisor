defmodule HarveynormanIe do
  @behaviour Crawly.Spider

  require Logger
  @impl Crawly.Spider
  def base_url(), do: "https://www.harveynorman.ie"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://www.harveynorman.ie/tvs-headphones/"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    pagination_urls =
      response.body |> Floki.find("ol.pager li a") |> Floki.attribute("href")

    product_urls =
      response.body |> Floki.find("a.product-img") |> Floki.attribute("href")

    all_urls = pagination_urls ++ product_urls

    requests =
      all_urls
      |> Enum.map(&build_absolute_url/1)
      |> Enum.map(&Crawly.Utils.request_from_url/1)

    # Extracting items
    title = response.body |> Floki.find("h1.product-title") |> Floki.text()
    id = response.body |> Floki.find(".product-id") |> Floki.text()

    category =
      response.body
      |> Floki.find(".nav-breadcrumbs :nth-child(3)")
      |> Floki.text()

    description =
      response.body |> Floki.find(".product-tab-wrapper") |> Floki.text()

    images =
      response.body
      |> Floki.find("   .pict")
      |> Floki.attribute("src")
      |> Enum.map(&build_image_url/1)

    Enum.each(images, fn url -> save_image(category, url) end)

    %Crawly.ParsedItem{
      :items => [
        %{
          id: id,
          title: title,
          category: category,
          images: images,
          description: description
        }
      ],
      :requests => requests
    }
  end

  defp build_absolute_url(url), do: URI.merge(base_url(), url) |> to_string()

  defp build_image_url(url) do
    URI.merge("https://hniesfp.imgix.net", url) |> to_string()
  end

  defp save_image(category, url),
    do: ProductsAdvisor.Spider.save_image(category, url)
end
