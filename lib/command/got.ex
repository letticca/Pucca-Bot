defmodule PuccaBot.Command.Got do
  def handle_got_command() do
    :rand.uniform(2000) # Gera um ID aleatório entre 1 e 2000
    |> get_character_result()
    |> format_response()
  end

  defp get_character_result(id) do
    case HTTPoison.get("https://www.anapioficeandfire.com/api/characters/#{id}") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, json} -> {:ok, parse_character_data(json)}
          _ -> {:error, "Erro ao decodificar resposta da API"}
        end

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Personagem não encontrado (ID: #{id})"}

      _ ->
        {:error, "Falha na conexão com a API"}
    end
  end

  defp parse_character_data(json) do
    %{
      name: json["name"] || "Desconhecido",
      titles: json["titles"] || [],
      aliases: json["aliases"] || []
    }
  end

  defp format_response({:ok, %{name: name, titles: titles, aliases: aliases}}) do
    titles_str = format_list(titles, "Títulos")
    aliases_str = format_list(aliases, "Apelidos")

    """
    🏰 Personagem Aleatório de Game of Thrones 🏰
    Nome: #{name}
    #{titles_str}
    #{aliases_str}
    """
  end

  defp format_response({:error, message}) do
    "#{message}"
  end

  defp format_list([], _label), do: ""
  defp format_list(list, label) do
    items = list |> Enum.reject(&(&1 == "")) |> Enum.join(", ")
    if items != "", do: "#{label}: #{items}\n", else: ""
  end
end
