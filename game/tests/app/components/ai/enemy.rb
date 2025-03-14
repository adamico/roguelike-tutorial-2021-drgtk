require 'tests/test_helper.rb'

def test_enemy_does_not_try_to_move_to_unseen_players(_args, assert)
  player = build_player
  
  enemy = build_actor(
    ai: { type: :enemy, data: {} },
    base_vision: 3
  )

  build_game_map_with_entities(
    [3, 3] => enemy,
    [3 + enemy.combatant.vision + 1, 3] => player
  )

  enemy.ai.perform_action

  assert.has_attributes! enemy, x: 3, y: 3
end

def test_enemy_moves_toward_player(_args, assert)
  player = build_player
  
  enemy = build_actor(
    ai: { type: :enemy, data: {} },
    base_vision: 5
  )

  build_game_map_with_entities(
    [3, 3] => enemy,
    [3 + enemy.combatant.vision, 3] => player
  )

  enemy.ai.perform_action
  assert.has_attributes! enemy, x: 4, y: 3
end