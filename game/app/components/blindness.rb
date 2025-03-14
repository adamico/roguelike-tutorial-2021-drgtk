module Components
  class Blindness < Consumable
    data_reader :turns

    def get_action(consumer)
      target_selection = Scenes::PositionSelection.new do |position|
        UseItemOnPositionAction.new(consumer, entity, position: position)
      end
      $game.replace_scene target_selection
    end

    def activate(consumer, position)
      raise Action::Impossible, 'You cannot target an area that you cannot see.' unless position_visible? position

      target = game_map.actor_at(position.x, position.y)
      raise Action::Impossible, 'You must select an enemy to target.' unless target
      raise Action::Impossible, 'You cannot blind yourself!' if target == consumer

      $message_log.add_message(
        text: "The head of the #{target.name} is enveloped in a black cloud. It's blinded!",
        fg: Colors.status_effect_applied
      )
      target.replace_ai type: :blind, data: { turns: turns, previous_ai: target.data.ai }
      consume
    end

    def position_visible?(position)
      game_map.visible? position.x, position.y
    end
  end
end
