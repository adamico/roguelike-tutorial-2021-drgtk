module Scenes
  class MainMenu < BaseScene
    attr :buttons

    def initialize
      create_buttons
      super
    end

    def create_buttons
      width = 24
      height = 1
      bg = [0, 0, 0, 150]
      fg = Colors.menu_text

      @buttons = []

      [
        {
          text: NEW_GAME_TEXT,
          display_condition: true
        },
        {
          text: CONTINUE_GAME_TEXT,
          display_condition: SaveGame.exists?
        },
        {
          text: QUIT_TEXT,
          display_condition: !$gtk.platform?(:web)
        }
      ].tap do |buttons|
        buttons.each_with_index do |button, index|
          @buttons << {
            x_offset: 0, y_offset: index,
            width: width, height: height,
            bg: bg, fg: fg,
            text: button.text,
            display_condition: button.display_condition
          }
        end
      end
    end

    def render(console)
      console.background_image = 'data/menu_background.png'
      render_title(console)
      render_menu(console)
    end

    def dispatch_action_for_main_menu_new_game
      new_game
    end

    def dispatch_action_for_main_menu_continue_game
      SaveGame.load if SaveGame.exists?
    end

    def dispatch_action_for_main_menu_quit_game
      return if $gtk.platform? :web

      $game.quit
    end

    def new_game
      $state.entities = Entities.build_data
      Entities.data = $state.entities
      Entities.player = EntityPrototypes.build :player
      dagger = EntityPrototypes.build :dagger
      dagger.place Entities.player.inventory
      Entities.player.equipment.set_slot :weapon, dagger
      leather_armor = EntityPrototypes.build :leather_armor
      leather_armor.place Entities.player.inventory
      Entities.player.equipment.set_slot :armor, leather_armor

      $state.message_log = []
      $message_log = MessageLog.new $state.message_log
      $message_log.add_message(
        text: WELCOME_TEXT,
        fg: Colors.welcome_text
      )

      $state.game_world = {}
      $game.game_world = GameWorld.new($state.game_world)

      $game.player = Entities.player
      $game.generate_next_floor
      $game.scene = Scenes::Gameplay.new(player: Entities.player)
    end

    def render_title(console)
      console.print_centered(
        x: console.width.idiv(2), y: console.height.idiv(2) + 16,
        string: TITLE_TEXT,
        fg: Colors.menu_title
      )
      console.print_centered(
        x: console.width.idiv(2), y: 2,
        string: AUTHOR_TEXT,
        fg: Colors.menu_title
      )
    end

    def render_menu(console)
      @buttons.each do |button|
        render_menu_entry(console, button)
      end
    end

    def render_menu_entry(console, button)
      return unless button.display_condition

      x, y = console.width.idiv(2) - 12, y = console.height.idiv(2) - 2 - button.y_offset
      width, height = button.width, button.height
      bg, fg = button.bg, button.fg
      console.draw_rect(x: x, y: y, width: 24, height: 1, bg: [0, 0, 0, 150])
      console.print(x: x, y: y, string: button.text, fg: Colors.menu_text)
    end
  end
end
