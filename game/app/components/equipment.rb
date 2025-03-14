module Components
  class Equipment < BaseComponent
    attr_reader :weapon, :armor, :tool

    def power_bonus
      bonus_for('power')
    end

    def defense_bonus
      bonus_for('defense')
    end

    def vision_bonus
      bonus_for('vision')
    end

    def bonus_for(stat)
      (weapon&.equippable&.send("#{stat}_bonus") || 0) + (armor&.equippable&.send("#{stat}_bonus") || 0) + (tool&.equippable&.send("#{stat}_bonus") || 0)
    end

    def equipped?(item)
      item && (weapon == item || armor == item || tool == item)
    end

    def equip(item)
      equipped_item = get_slot(item.equippable.slot)
      unequip equipped_item if equipped_item

      set_slot(item.equippable.slot, item)
      $message_log.add_message(text: "You equip the #{item.name}.")
    end

    def unequip(item)
      set_slot(item.equippable.slot, nil)
      $message_log.add_message(text: "You remove the #{item.name}.")
    end

    def set_slot(slot, item)
      previous_item = get_slot(slot)
      previous_item.equippable.equipped_by = nil if previous_item

      instance_variable_set(:"@#{slot}", item)
      item.equippable.equipped_by = entity if item
    end

    def get_slot(slot)
      instance_variable_get(:"@#{slot}")
    end
  end
end
