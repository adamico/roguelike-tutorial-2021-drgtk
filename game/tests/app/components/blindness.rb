require 'tests/test_helper.rb'

def test_blindness_changes_ai_to_blind(_args, assert)
  item = build_item consumable: { type: :blindness, turns: 10 }
  npc = build_actor(items: [item])
  orc = build_actor name: 'Orc'
  build_game_map_with_entities(
    [3, 3] => npc,
    [5, 7] => orc
  )

  item.consumable.activate npc, [5, 7]

  assert.has_attributes! orc.ai, class: Components::AI::Blind,
                                 turns: 10,
                                 previous_ai: { type: :enemy, data: {} }
  assert.includes! log_messages, "The head of the Orc is enveloped in a black cloud. It's blinded!"
  assert.includes_no! npc.inventory.items, item
end

def test_blindness_get_action_starts_position_selection(_args, assert)
  item = build_item consumable: { type: :blindness, turns: 10 }
  npc = build_actor(items: [item])

  item.get_action(npc)

  assert.equal! $game.scene.class, Scenes::PositionSelection

  returned_action = $game.scene.action_for_position [5, 4]

  assert.equal! returned_action, UseItemOnPositionAction.new(npc, item, position: [5, 4])
end

def test_blindness_cannot_target_non_visible_position(_args, assert)
  item = build_item consumable: { type: :blindness, turns: 10 }
  npc = build_actor(items: [item])
  game_map = build_game_map_with_entities(
    [3, 3] => npc
  )
  make_positions_non_visible(game_map, [[4, 4]])

  assert.raises_with_message! Action::Impossible, 'You cannot target an area that you cannot see.' do
    item.consumable.activate npc, [4, 4]
  end
end

def test_blindness_must_target_actor(_args, assert)
  item = build_item consumable: { type: :blindness, turns: 10 }
  npc = build_actor(items: [item])
  build_game_map_with_entities(
    [3, 3] => npc
  )

  assert.raises_with_message! Action::Impossible, 'You must select an enemy to target.' do
    item.consumable.activate npc, [4, 4]
  end
end

def test_blindness_cannot_target_self(_args, assert)
  item = build_item consumable: { type: :blindness, turns: 10 }
  npc = build_actor(items: [item])
  build_game_map_with_entities(
    [3, 3] => npc
  )

  assert.raises_with_message! Action::Impossible, 'You cannot blind yourself!' do
    item.consumable.activate npc, [3, 3]
  end
end