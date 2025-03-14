require 'tests/test_helper.rb'

def test_blind_does_not_move_to_player(_args, assert)
  player = build_player
  
  actor = build_actor(
    ai: { type: :blind, data: { turns: 2 } }
  )

  build_game_map_with_entities(
    [3, 3] => actor,
    [5, 3] => player
  )

  actor.ai.perform_action

  assert.has_attributes! actor, x: 3, y: 3
  assert.equal! actor.ai.turns, 1
end