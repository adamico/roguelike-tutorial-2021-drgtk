require 'tests/test_helper.rb'

def test_parameters_by_floor_max_items(_args, assert)
  parameters_by_floor = TestParametersByFloor.build_parameters_by_foor(
    max_items_per_room: {
      1 => 1,
      3 => 2
    }
  )

  assert.has_attributes! parameters_by_floor.for_floor(1), max_items_per_room: 1
  assert.has_attributes! parameters_by_floor.for_floor(2), max_items_per_room: 1
  assert.has_attributes! parameters_by_floor.for_floor(3), max_items_per_room: 2
end

def test_parameters_by_floor_max_monsters(_args, assert)
  parameters_by_floor =  TestParametersByFloor.build_parameters_by_foor(
    max_monsters_per_room: {
      1 => 1,
      3 => 2
    }
  )

  assert.has_attributes! parameters_by_floor.for_floor(1), max_monsters_per_room: 1
  assert.has_attributes! parameters_by_floor.for_floor(2), max_monsters_per_room: 1
  assert.has_attributes! parameters_by_floor.for_floor(3), max_monsters_per_room: 2
end

def test_parameters_by_floor_item_weights(_args, assert)
  parameters_by_floor =  TestParametersByFloor.build_parameters_by_foor(
    item_weights: {
      1 => { health_potion: 35 },
      2 => { confusion_scroll: 10 },
      4 => { lightning_scroll: 25 },
      6 => { fireball_scroll: 25 }
    }
  )

  assert.has_attributes! parameters_by_floor.for_floor(1), item_weights: { health_potion: 35 }
  assert.has_attributes! parameters_by_floor.for_floor(2), item_weights: {
    health_potion: 35, confusion_scroll: 10
  }
  assert.has_attributes! parameters_by_floor.for_floor(3), item_weights: {
    health_potion: 35, confusion_scroll: 10
  }
  assert.has_attributes! parameters_by_floor.for_floor(4), item_weights: {
    health_potion: 35, confusion_scroll: 10, lightning_scroll: 25
  }
  assert.has_attributes! parameters_by_floor.for_floor(5), item_weights: {
    health_potion: 35, confusion_scroll: 10, lightning_scroll: 25
  }
  assert.has_attributes! parameters_by_floor.for_floor(6), item_weights: {
    health_potion: 35, confusion_scroll: 10, lightning_scroll: 25, fireball_scroll: 25
  }
end

def test_parameters_by_floor_monster_weights(_args, assert)
  parameters_by_floor =  TestParametersByFloor.build_parameters_by_foor(
    monster_weights: {
      1 => { orc: 80 },
      3 => { troll: 15 },
      5 => { troll: 30 },
      7 => { troll: 60 }
    }
  )

  assert.has_attributes! parameters_by_floor.for_floor(1), monster_weights: { orc: 80 }
  assert.has_attributes! parameters_by_floor.for_floor(2), monster_weights: { orc: 80 }
  assert.has_attributes! parameters_by_floor.for_floor(3), monster_weights: {
    orc: 80, troll: 15
  }
  assert.has_attributes! parameters_by_floor.for_floor(4), monster_weights: {
    orc: 80, troll: 15
  }
  assert.has_attributes! parameters_by_floor.for_floor(5), monster_weights: {
    orc: 80, troll: 30
  }
  assert.has_attributes! parameters_by_floor.for_floor(6), monster_weights: {
    orc: 80, troll: 30
  }
  assert.has_attributes! parameters_by_floor.for_floor(7), monster_weights: {
    orc: 80, troll: 60
  }
end

module TestParametersByFloor
  def self.build_parameters_by_foor(values)
    GameWorld::ParametersByFloor.new(
      max_items_per_room: values[:max_items_per_room] || { 1 => 1 },
      max_monsters_per_room: values[:max_monsters_per_room] || { 1 => 1 },
      item_weights: values[:item_weights] || { 1 => { health_potion: 100 } },
      monster_weights: values[:monster_weights] || { 1 => { orc: 100 } }
    )
  end
end
