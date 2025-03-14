require 'tests/test_helper.rb'

def test_room_entities(_args, assert)
  room = Procgen::RectangularRoom.new(5, 5, 5, 6)
  rng = TestHelper::Mock.new
  monster_weights = { orc: 8, troll: 2 }
  item_weights = {
    health_potion: 7,
    fireball_scroll: 1,
    confusion_scroll: 1,
    lightning_scroll: 1
  }
  # number of monsters
  rng.expect_call :random_int_between, args: [0, 2], return_value: 1
  # monster position
  rng.expect_call :random_position_in_rect, args: [[6, 6, 3, 4]], return_value: [6, 6]
  # monster type -> bearman
  rng.expect_call :random_from_weighted_elements, args:[monster_weights], return_value: :troll
  # number of items
  rng.expect_call :random_int_between, args: [0, 5], return_value: 4
  # item 1 position
  rng.expect_call :random_position_in_rect, args: [[6, 6, 3, 4]], return_value: [7, 7]
  # item 1 type -> health_potion
  rng.expect_call :random_from_weighted_elements, args:[item_weights], return_value: :health_potion
  # item 2 position
  rng.expect_call :random_position_in_rect, args: [[6, 6, 3, 4]], return_value: [8, 7]
  # item 2 type -> lightning_scroll
  rng.expect_call :random_from_weighted_elements, args:[item_weights], return_value: :lightning_scroll
  # item 3 position
  rng.expect_call :random_position_in_rect, args: [[6, 6, 3, 4]], return_value: [6, 7]
  # item 3 type -> confusion_scroll
  rng.expect_call :random_from_weighted_elements, args:[item_weights], return_value: :confusion_scroll
  # item 4 position
  rng.expect_call :random_position_in_rect, args: [[6, 6, 3, 4]], return_value: [6, 8]
  # item 4 type -> fireball_scroll
  rng.expect_call :random_from_weighted_elements, args:[item_weights], return_value: :fireball_scroll
  generator = Procgen::RoomEntitiesGenerator.new(
    max_monsters_per_room: 2,
    max_items_per_room: 5,
    monster_weights: monster_weights,
    item_weights: item_weights
  )
  generator.rng = rng

  result = generator.generate_for(room)

  rng.assert_all_calls_received!(assert)
  assert.equal! result, [
    { type: :troll, x: 6, y: 6 },
    { type: :health_potion, x: 7, y: 7 },
    { type: :lightning_scroll, x: 8, y: 7 },
    { type: :confusion_scroll, x: 6, y: 7 },
    { type: :fireball_scroll, x: 6, y: 8 }
  ]
end
