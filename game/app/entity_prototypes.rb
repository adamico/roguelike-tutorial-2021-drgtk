module EntityPrototypes
  class << self
    def build(type)
      prototype = copy_prototype @prototypes.fetch(type)
      Entity.build(type, build_initial_attributes(prototype))
    end

    def define(type, data)
      @prototypes ||= {}
      @prototypes[type] = data
    end

    def define_actor(type, data)
      define(
        type,
        {
          blocks_movement: true,
          render_order: RenderOrder::ACTOR,
          inventory: {},
          equipment: {},
          ai: { type: :enemy, data: {} }
        }.merge(data)
      )
    end

    def define_item(type, data)
      define(type, { blocks_movement: false, render_order: RenderOrder::ITEM }.merge(data))
    end

    private

    def copy_prototype(prototype)
      $gtk.deserialize_state $gtk.serialize_state(prototype)
    end

    def build_initial_attributes(prototype)
      { x: nil, y: nil, parent: nil }.tap { |result|
        result.update(prototype)
        result[:combatant][:max_hp] = result[:combatant][:hp] if result.key? :combatant
      }
    end
  end
end

EntityPrototypes.define_actor :player,
                              name: 'Player',
                              char: '@', color: [255, 255, 255],
                              combatant: { hp: 30, base_defense: 1, base_power: 2, base_vision: 3},
                              ai: { type: :none, data: {} },
                              level: { level_up_base: 200, level_up_factor: 150 }

EntityPrototypes.define_actor :orc,
                              name: 'Orc',
                              char: 'o', color: [63, 127, 63],
                              combatant: { hp: 10, base_defense: 0, base_power: 3, base_vision: 3 },
                              received_xp: 35

EntityPrototypes.define_actor :troll,
                              name: 'Troll',
                              char: 'T', color: [0, 127, 0],
                              combatant: { hp: 16, base_defense: 1, base_power: 4, base_vision: 5 },
                              received_xp: 100

EntityPrototypes.define_item  :health_potion,
                              name: 'Health Potion',
                              char: '!', color: [127, 0, 255],
                              consumable: { type: :healing, amount: 4 }

EntityPrototypes.define_item  :lightning_scroll,
                              name: 'Lightning Scroll',
                              char: '~', color: [255, 255, 0],
                              consumable: { type: :lightning_damage, amount: 20, maximum_range: 5 }

EntityPrototypes.define_item  :confusion_scroll,
                              name: 'Confusion Scroll',
                              char: '~', color: [207, 63, 255],
                              consumable: { type: :confusion, turns: 10 }

EntityPrototypes.define_item  :blindness_scroll,
                              name: 'Blindness Scroll',
                              char: '~', color: [0, 0, 255],
                              consumable: { type: :blindness, turns: 10 }

EntityPrototypes.define_item  :fireball_scroll,
                              name: 'Fireball Scroll',
                              char: '~', color: [255, 0, 0],
                              consumable: { type: :explosion, damage: 12, radius: 3 }

EntityPrototypes.define_item  :dagger,
                              name: 'Dagger',
                              char: ')', color: [0, 191, 255],
                              equippable: { slot: :weapon, power_bonus: 2 }

EntityPrototypes.define_item  :sword,
                              name: 'Sword',
                              char: ')', color: [0, 191, 255],
                              equippable: { slot: :weapon, power_bonus: 4 }

EntityPrototypes.define_item  :leather_armor,
                              name: 'Leather Armor',
                              char: '[', color: [139, 69, 19],
                              equippable: { slot: :armor, defense_bonus: 1 }

EntityPrototypes.define_item  :chain_mail,
                              name: 'Chain Mail',
                              char: '[', color: [139, 69, 19],
                              equippable: { slot: :armor, defense_bonus: 3 }

EntityPrototypes.define_item  :lantern,
                              name: 'Lantern',
                              char: "(", color: [139, 69, 19],
                              equippable: { slot: :tool, vision_bonus: 2 }
