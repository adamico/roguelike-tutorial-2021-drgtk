class Game
  attr_reader :game_map

  def initialize(input_event_handler:, game_map:, player:)
    @input_event_handler = input_event_handler
    @game_map = game_map
    @player = player
    update_fov
  end

  def handle_input_events(input_events)
    input_events.each do |event|
      action = @input_event_handler.dispatch_action_for(event)
      next unless action

      action.perform(self, @player)
      update_fov
    end
  end

  def render(terminal)
    terminal.clear
    @game_map.render(terminal, offset_y: 5)
    terminal.render
  end

  private

  def update_fov
    @game_map.update_fov(x: @player.x, y: @player.y, radius: 8)
  end
end
