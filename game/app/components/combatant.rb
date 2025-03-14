module Components
  class Combatant < BaseComponent
    data_accessor :max_hp, :base_power, :base_defense, :base_vision
    data_reader :hp

    def power
      base_power + entity.equipment.power_bonus
    end

    def defense
      base_defense + entity.equipment.defense_bonus
    end

    def vision
      base_vision + entity.equipment.vision_bonus
    end

    def hp=(value)
      data.hp = value.clamp(0, data.max_hp)
      entity.die if dead?
    end

    def heal(amount)
      return 0 if hp == max_hp

      old_hp = hp
      self.hp += amount

      hp - old_hp
    end

    def take_damage(amount)
      self.hp -= amount
    end

    def dead?
      hp.zero?
    end
  end
end
