defmodule Aprb.Views.PurchaseSlackView do
  import ViewHelper

  def render(event) do
    %{
      text: ":shake: #{cleanup_name(event["subject"]["display"])} #{event["verb"]} #{artwork_link(event["properties"]["artwork"]["id"])}",
      attachments: "[{
                      \"fields\": [
                        {
                          \"title\": \"Price\",
                          \"value\": \"#{format_price(event["properties"]["sale_price"] || 0)}\",
                          \"short\": true
                        }
                      ]
                    }]",
      unfurl_links: true
    }
  end
end
