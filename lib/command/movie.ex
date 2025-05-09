defmodule PuccaBot.Command.Movie do
  @tmdb_base_url "https://api.themoviedb.org/3/"
  @tmdb_api_key System.get_env("TMDB_API_KEY")

  #pesquisa o filme
  def search_movie(movie_title) do
    url = "#{@tmdb_base_url}search/movie?api_key=#{@tmdb_api_key}&query=#{URI.encode(movie_title)}&language=pt-BR"
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}
      _ ->
        {:error, "Falha ao buscar filme"}
    end
  end

  #chama a função
  def handle_movie_command(content) do
    case parse_movie_title(content) do
      {:ok, movie_title} ->
        case PuccaBot.Command.Movie.search_movie(movie_title) do
          {:ok, results} -> format_response(results)
          {:error, reason} -> "#{reason}"
        end
      :invalid -> "uso correto: !movie <nome do filme>"
    end
  end

  #valida e tira o nome do filme
  defp parse_movie_title(content) do
    case String.split(content," ", parts: 2 ) do
      ["!movie", movie_title] -> {:ok, movie_title}
      _ -> :invalid
    end
  end

  defp format_response(%{"results" => []}) do
    "Nenhum filme encontrado. Tente outro termo!"
  end

  #formata resposta
  defp format_response(%{"results" => [first | _]}) do
    poster_url = if first["poster_path"] do
      "https://image.tmdb.org/t/p/w500#{first["poster_path"]}"
    else
      "Poster não disponível"
    end

    """
    🎬 **Filme Encontrado** 🎬
    Título: #{first["title"]}
    Ano: #{String.slice(first["release_date"], 0..3)}
    Sinopse: #{first["overview"]}
    Poster: #{poster_url}
    """
  end

end
