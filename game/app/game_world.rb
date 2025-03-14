require 'app/game_world/parameters_by_floor.rb'

class GameWorld < DataBackedObject
  data_reader :current_floor, :seed

  def initialize(data)
    super()
    @data = data

    self.current_floor ||= 0
    self.seed ||= RNG.new_string_seed
  end

  def generate_next_floor
    self.current_floor += 1
    delete_all_player_unrelated_entities

    $game.game_map = Procgen.generate_dungeon(
      map_width: 80,
      map_height: 40,
      parameters: parameters_for_floor(current_floor),
      player: Entities.player,
      seed: "#{seed}#{current_floor}"
    )
    $state.game_map = $game.game_map.data
  end

  private

  data_writer :current_floor, :seed

  def delete_all_player_unrelated_entities
    return unless $game.game_map

    entities_to_delete = $game.game_map.entities.reject { |entity|
      entity == Entities.player
    }
    entities_to_delete.each do |entity|
      Entities.delete entity
    end
  end

  def parameters_for_floor(floor)
    parameters_by_floor.for_floor floor
  end

  def parameters_by_floor
    @parameters_by_floor ||= ParametersByFloor.new(
      max_items_per_room: {
        1 => 1,
        4 => 2
      },
      max_monsters_per_room: {
        1 => 2,
        4 => 3,
        6 => 5
      },
      item_weights: {
        1 => { health_potion: 35 },
        2 => { confusion_scroll: 10 },
        4 => { lightning_scroll: 25, steel_pipe: 5 },
        6 => { fireball_scroll: 25, light_trooper_vest: 15 }
      },
      monster_weights: {
        1 => { orc: 80 },
        3 => { troll: 15 },
        5 => { troll: 30 },
        7 => { troll: 60 }
      }
    )
  end
end
