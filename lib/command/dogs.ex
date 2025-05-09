defmodule PuccaBot.Command.Dogs do
  def handle_dog_command() do
    case fetch_dog_image() do
      {:ok, url} -> format_response(url)
      {:error, reason} -> "Erro ao buscar imagem: #{reason}"
    end
  end

  #procura imagem
  defp fetch_dog_image() do
    url = "https://dog.ceo/api/breeds/image/random"
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, json} <- Jason.decode(body) do
      {:ok, json["message"]}
    else
      _ -> {:error, "Falha na API"}
    end
  end

  #formata resposta
  defp format_response(image_url) do
    "🐶 Aqui vai seu cachorro aleatório:\n#{image_url}"
  end
end
