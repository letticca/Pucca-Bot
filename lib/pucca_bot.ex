defmodule PuccaBot do
  use Nostrum.Consumer
  alias Nostrum.Api
  alias PuccaBot.Command.Pokedex
  alias PuccaBot.Command.Jokes
  alias PuccaBot.Command.Movie
  alias PuccaBot.Command.Dicio
  alias PuccaBot.Command.Monsters
  alias PuccaBot.Command.Got
  alias PuccaBot.Command.Dogs


  def handle_event({:MESSAGE_CREATE, msg, _ws_status}) do
    cond do

      String.starts_with?(msg.content, "!help") ->
        Api.Message.create(msg.channel_id,
        "Comandos disponíveis:\n
        !pokemon <nome de um pokemon> - retorna informações sobre um pokemon\n
        !jokes - conta uma piada aleatoria\n
        !movie <nome de um filme> - retorna informações sobre um filme\n
        !significado <palavra em inglês> - retorna a definição de uma palavra\n
        !random monster - retorna informações sobre um monstro aleatorio do D&D\n
        !got - retorna informações sobre um personagem aleatorio de Game of Thrones\n
        !dog - retorna uma foto aleatoria sobre cachorros
        ")


      # Comando para puxar a pokedex
      String.starts_with?(msg.content, "!pokemon") ->
        Api.Message.create(msg.channel_id, Pokedex.handle_pokemon_command(msg.content))

      # Comando de piadas
      String.starts_with?(msg.content, "!jokes") ->
        Api.Message.create(msg.channel_id, Jokes.handle_jokes_command())

      #Comando de Filmes
      String.starts_with?(msg.content, "!movie") ->
        Api.Message.create(msg.channel_id, Movie.handle_movie_command(msg.content))

      #Comando de dicionario
      String.starts_with?(msg.content, "!significado") ->
        Api.Message.create(msg.channel_id, Dicio.handle_significado_command(msg.content))

      #Comando de monstro aleatorio do D&D
      String.starts_with?(msg.content, "!random monster") ->
        Api.Message.create(msg.channel_id, Monsters.handle_random_monster_command(msg.content))

      #Comando de um personagem aleatorio de game of thrones
      String.starts_with?(msg.content, "!got") ->
        Api.Message.create(msg.channel_id, Got.handle_got_command())

      #Foto de cachorro aleatorio
      String.starts_with?(msg.content, "!dog") ->
        Api.Message.create(msg.channel_id, Dogs.handle_dog_command())
      true ->
        :ignore
    end
  end
end
