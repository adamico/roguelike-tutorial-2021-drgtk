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
                              combatant: { hp: 30, base_defense: 2, base_power: 5 },
                              ai: { type: :none, data: {} },
                              level: { level_up_base: 200, level_up_factor: 150 }

EntityPrototypes.define_actor :mutant_spider,
                              name: 'Mutant Spider',
                              char: 's', color: [63, 127, 63],
                              combatant: { hp: 10, base_defense: 0, base_power: 3 },
                              received_xp: 35

EntityPrototypes.define_actor :cyborg_bearman,
                              name: 'Cyborg Bearman',
                              char: 'B', color: [0, 127, 0],
                              combatant: { hp: 16, base_defense: 1, base_power: 4 },
                              received_xp: 100

EntityPrototypes.define_item  :bandages,
                              name: 'Bandages',
                              char: '!', color: [127, 0, 255],
                              consumable: { type: :healing, amount: 4 }

EntityPrototypes.define_item  :megavolt_capsule,
                              name: 'Megavolt Capsule',
                              char: '~', color: [255, 255, 0],
                              consumable: { type: :lightning_damage, amount: 20, maximum_range: 5 }

EntityPrototypes.define_item  :neurosonic_emitter,
                              name: 'Neurosonic emitter',
                              char: '~', color: [207, 63, 255],
                              consumable: { type: :confusion, turns: 10 }

EntityPrototypes.define_item  :grenade,
                              name: 'Grenade',
                              char: '~', color: [255, 0, 0],
                              consumable: { type: :explosion, damage: 12, radius: 3 }

