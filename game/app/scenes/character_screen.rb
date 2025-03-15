module Scenes
  class CharacterScreen < BaseScene
    def initialize(window_x: 0)
      super
      @window_x = window_x
      @window_top = 44
      @title = CHARACTER_SCREEN_TITLE_TEXT
      @window_w = @title.size + 4
      @window_h = 0
    end

    def render(console)
      console.draw_frame(
        x: @window_x, y: @window_top - @window_h + 1, width: @window_w, height: @window_h,
        title: @title,
        fg: Colors.item_window_fg, bg: Colors.item_window_bg
      )

      player = $game.player
      level = player.level
      combatant = player.combatant

      lines = [
        { label: "Level", value: level.current_level },
        { label: "XP", value: [level.current_xp, level.experience_to_next_level].map(&:to_s).join("/") },
        { label: "Attack", value: combatant.power },
        { label: "Defense", value: combatant.defense },
        { label: "Vision", value: combatant.vision }
      ]

      @window_h = lines.length + 2
      
      lines.each_with_index do |line, index|
        console.print(x: @window_x + 1, y: @window_top - (index + 1), string: [line.label, line.value].map(&:to_s).join(": "))
      end
    end

    def dispatch_action_for_quit
      pop_scene
    end

    alias dispatch_action_for_character_screen dispatch_action_for_quit

    def dispatch_action_for_help
      $game.show_help('Character Screen')
    end
  end
end
