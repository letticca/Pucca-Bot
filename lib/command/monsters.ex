defmodule PuccaBot.Command.Monsters do
  @api_base "https://www.dnd5eapi.co/api"

  def handle_random_monster_command(_arg) do
    case fetch_random_monster() do
      {:ok, monster} -> build_monster_response(monster)
      {:error, reason} -> "❌ #{reason}"
    end
  end

  defp fetch_random_monster do
    with {:ok, monsters} <- get_monster_list(),
         random_index <- Enum.random(monsters)["index"],
         {:ok, details} <- get_monster_details(random_index) do
      {:ok, details}
    else
      error -> error
    end
  end

  defp get_monster_list do
    case api_request("#{@api_base}/monsters") do
      {:ok, %{"results" => monsters}} -> {:ok, monsters}
      {:error, _} = error -> error
    end
  end

  defp get_monster_details(index) do
    api_request("#{@api_base}/monsters/#{index}")
  end

  defp api_request(url) do
    case HTTPoison.get(url, [], follow_redirect: true) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode(body)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Monstro não encontrado"}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, "Erro HTTP #{code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Erro de conexão: #{reason}"}
    end
  end

  defp build_monster_response(monster) do
    """
    **#{monster["name"]}**
    **Tamanho:** #{monster["size"]}
    **Tipo:** #{monster["type"]}
    **AC:** #{format_armor_class(monster)}
    **PV:** #{monster["hit_points"]} (#{monster["hit_dice"]})
    **Velocidade:** #{format_speed(monster["speed"])}
    **Habilidades:** #{format_abilities(monster["special_abilities"] || [])}
    """
  end

  defp format_armor_class(%{"armor_class" => [ac | _]}) do
    "#{ac["value"]} (#{ac["type"]})"
  end
  defp format_armor_class(%{"armor_class" => ac}) when is_integer(ac) do
    "#{ac}"
  end

  defp format_speed(speed_map) do
    speed_map
    |> Enum.map_join(", ", fn {type, value} -> "#{type}: #{value}" end)
  end

  defp format_abilities(abilities) do
    abilities
    |> Enum.map_join("\n", fn %{"name" => name, "desc" => desc} ->
      "• **#{name}**: #{desc}"
    end)
    |> case do
      "" -> "Nenhuma habilidade especial"
      formatted -> formatted
    end
  end
end
