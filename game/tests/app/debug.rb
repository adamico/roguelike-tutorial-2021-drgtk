require 'tests/test_helper.rb'

def test_debug_give_item(_args, assert)
  actor = build_actor
  
  item = build_item name: 'dagger'

  Debug.give(actor, :dagger)
  assert.not_empty! actor.inventory.items
end

def test_debug_spawn_actor(_args, assert)
  game_map = build_game_map

  actor = Debug.spawn(:troll, 1, 1)
  assert.has_attributes!(actor, {x: 1, y: 1})
end