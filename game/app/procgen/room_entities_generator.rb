module Procgen
  class RoomEntitiesGenerator
    def initialize(rng, max_monsters_per_room:, max_items_per_room:)
      @rng = rng
      @max_monsters_per_room = max_monsters_per_room
      @max_items_per_room = max_items_per_room
    end

    def generate_for(room)
      entity_area = room.inner_rect
      [].tap { |result|
        add_monsters(result, entity_area)
        add_items(result, entity_area)
      }
    end

    def add_monsters(result, area)
      @rng.random_int_between(0, @max_monsters_per_room).each do
        x, y = @rng.random_position_in_rect(area)
        result << {
          x: x,
          y: y,
          type: @rng.rand < 0.8 ? :mutant_spider : :cyborg_bearman
        }
      end
    end

    def add_items(result, area)
      @rng.random_int_between(0, @max_items_per_room).each do
        x, y = @rng.random_position_in_rect(area)
        type = @rng.rand < 0.7 ? :bandages : :megavolt_capsule
        result << { x: x, y: y, type: type }
      end
    end
  end
end
