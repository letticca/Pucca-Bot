defmodule PuccaBot.Command.Pokedex do
  def handle_pokemon_command(content) do
    content
    |> valid_pokemon_command()
    |> get_pokemon_result()
    |> format_response()
  end

  defp valid_pokemon_command(content) do
    command =
      content
      |> String.downcase()
      |> String.split(" ", parts: 2)

    case command do
      ["!pokemon", value] -> {:ok, String.trim(value)}
      _ -> :error
    end
  end

  #pesquisa o nome do pokemon
  defp get_pokemon_result({:ok, value}) do
    case HTTPoison.get("https://pokeapi.co/api/v2/pokemon/#{value}/") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, json} -> {:ok, parse_pokemon_data(json)}
          _ -> {:error, "Erro na API"}
        end
      _ -> {:error, "Pokémon não encontrado"}
    end
  end

  defp get_pokemon_result(:error), do: {:error, "Comando inválido"}
    
  #puxa 
  defp parse_pokemon_data(json) do
    %{
      id: json["id"],
      name: String.capitalize(json["name"]),
      type: Enum.map(json["types"], fn t -> String.capitalize(t["type"]["name"]) end) |> Enum.join(", "),
      height: json["height"],
      weight: json["weight"],
      sprite: json["sprites"]["front_default"]
    }
  end

  defp format_response({:ok, data}) do
    """
    🎮 Pokémon Encontrado! 🎮
    ID: #{data.id}
    Nome: #{data.name}
    Tipo: #{data.type}
    Altura: #{data.height} dm
    Peso: #{data.weight} hg
    Sprite: #{data.sprite}
    """
  end

  defp format_response({:error, message}) do
    "#{message}"
  end
end
