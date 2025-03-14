module Components
  module AI
    class Blind < BaseComponent
      data_accessor :turns, :previous_ai

      def perform_action
        target = $game.player
        dy = target.y - entity.y
        dx = target.x - entity.x
        distance = [dx.abs, dy.abs].max

        if turns.positive?
          self.turns -= 1
          if distance <= 1
            MeleeAction.new(entity, dx: dx, dy: dy).perform 
          else
            WaitAction.perform
          end
        else
          $message_log.add_message(text: "The #{entity.name} is no longer blind.")
          entity.replace_ai previous_ai
        end
      end
    end
  end
end
