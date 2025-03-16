module Debug
  class << self  
    def render(args, constant)
      args.outputs.debug.watch constant
    end

    def give(actor, item_symbol)
      item = EntityPrototypes.build(item_symbol)
      item.place actor.inventory
    end

    def spawn(actor_symbol, x, y)
      actor = EntityPrototypes.build(actor_symbol)
      actor.x = x
      actor.y = y
      $game.game_map.add_entity(actor)
      actor
    end
  end
end