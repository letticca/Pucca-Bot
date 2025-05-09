defmodule PuccaBot.Command.Jokes do
  @api_url "https://geek-jokes.sameerkumar.website/api?format=json"

  def handle_jokes_command do
    case fetch_joke() do
      {:ok, joke} -> format_response(joke)
      {:error, reason} -> "Erro: #{reason}"
    end
  end

  #busca a piada
  defp fetch_joke do
    case HTTPoison.get(@api_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"joke" => joke}} -> {:ok, joke}
          _ -> {:error, "Resposta inválida da API"}
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Erro na requisição: #{reason}"}

      _ ->
        {:error, "Erro desconhecido"}
    end
  end

  #formatação para enviar
  defp format_response(joke) do
     "PIADA NERD🤓 #{joke}"

  end

end
