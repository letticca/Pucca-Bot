defmodule PuccaBot.Command.Dicio do
  @api_url "https://api.dictionaryapi.dev/api/v2/entries/en/"

  def handle_significado_command(content) do
    case analisar_palavra(content) do
      {:ok, palavra} -> buscar_significado(palavra)  # ✅ Agora funciona
      :error -> {:error, "Comando inválido"}
    end
    |> format_response()
  end

  defp analisar_palavra(content) do
    case String.split(content, " ", parts: 2) do
      ["!significado", palavra] -> {:ok, String.trim(palavra)}
      _ -> :error
    end
  end

  defp buscar_significado(palavra) do  # ✅ Corrigido
    url = @api_url <> URI.encode_www_form(palavra)

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, [entrada | _]} ->
            significados = extrair_significados(entrada)
            {:ok, %{palavra: palavra, significados: significados}}
          _ ->
            {:error, "Resposta inválida"}
        end

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Palavra não encontrada"}

      _ ->
        {:error, "Erro na API"}
    end
  end

  defp extrair_significados(entrada) do
    entrada["meanings"]
    |> Enum.flat_map(fn significado ->
      classe = significado["partOfSpeech"]
      definicoes = significado["definitions"]
      Enum.map(definicoes, &"#{classe}: #{&1["definition"]}")
    end)
  end

  defp format_response({:ok, %{palavra: palavra, significados: significados}}) do
    """
    📚 **Significado de "#{palavra}"** 📚
    #{Enum.join(significados, "\n")}
    """
  end

  defp format_response({:error, reason}) do
    "❌ #{reason}"
  end
end
