module Scenes
  class Gameplay < BaseScene
    def initialize(player:)
      @player = player
      super()
      @hp_bar = UI::Bar.new(
        name: 'HP',
        maximum_value: @player.combatant.max_hp,
        total_width: 20,
        fg: Colors.hp_bar_filled,
        bg: Colors.hp_bar_empty
      )
      @xp_bar = UI::Bar.new(
        name: 'XP',
        maximum_value: @player.level.experience_to_next_level,
        total_width: 20,
        fg: Colors.xp_bar_filled,
        bg: Colors.xp_bar_empty
      )
      @message_log = UI::MessageLog.new(x: 21, y: 0, width: 40, height: 5)
    end

    def render(console)
      render_game_map(console)
      render_hp_bar(console)
      render_xp_bar(console)
      render_message_log(console)
      render_names_at_cursor_position(console)
      render_dimension_name(console)
    end

    def dispatch_action_for_quit
      SaveGame.save

      if $gtk.platform? :web
        $gtk.reset seed: Time.now.to_i
      else
        $game.quit
      end
    end

    def dispatch_action_for_up
      BumpIntoEntityAction.new(player, dx: 0, dy: 1)
    end

    def dispatch_action_for_down
      BumpIntoEntityAction.new(player, dx: 0, dy: -1)
    end

    def dispatch_action_for_left
      BumpIntoEntityAction.new(player, dx: -1, dy: 0)
    end

    def dispatch_action_for_right
      BumpIntoEntityAction.new(player, dx: 1, dy: 0)
    end

    def dispatch_action_for_up_right
      BumpIntoEntityAction.new(player, dx: 1, dy: 1)
    end

    def dispatch_action_for_up_left
      BumpIntoEntityAction.new(player, dx: -1, dy: 1)
    end

    def dispatch_action_for_down_right
      BumpIntoEntityAction.new(player, dx: 1, dy: -1)
    end

    def dispatch_action_for_down_left
      BumpIntoEntityAction.new(player, dx: -1, dy: -1)
    end

    def dispatch_action_for_get
      PickupAction.new(player)
    end

    def dispatch_action_for_interact
      if !game_map.items_at(player.x, player.y).empty?
        PickupAction.new(player)
      elsif game_map.portal_location == [player.x, player.y]
        EnterPortalAction.new(player)
      end
    end

    def dispatch_action_for_wait
      WaitAction
    end

    def dispatch_action_for_view_history
      push_scene Scenes::HistoryViewer.new
    end

    def dispatch_action_for_inventory
      $game.show_inventory('Select an item to use') do |selected_item|
        selected_item.get_action(player)
      end
    end

    def dispatch_action_for_drop
      $game.show_inventory('Select an item to drop') do |selected_item|
        DropItemAction.new(player, selected_item)
      end
    end

    def dispatch_action_for_look
      push_scene Scenes::PositionSelection.new(help_topic: 'Look') do
        # no op - don't perform action on enter
      end
    end

    def dispatch_action_for_character_screen
      $game.show_character_screen
    end

    def dispatch_action_for_help
      $game.show_help('Gameplay')
    end

    def dispatch_action_for_enter_portal
      EnterPortalAction.new(player)
    end

    private

    attr_reader :player

    def game_map
      $game.game_map
    end

    def render_game_map(console)
      game_map.render(console, offset_y: ScreenLayout.map_offset.y)
    end

    def render_hp_bar(console)
      @hp_bar.current_value = @player.combatant.hp
      @hp_bar.maximum_value = @player.combatant.max_hp
      @hp_bar.render(console, x: 0, y: 4)
    end

    def render_xp_bar(console)
      @xp_bar.current_value = @player.level.current_xp
      @xp_bar.maximum_value = @player.level.experience_to_next_level
      @xp_bar.render(console, x: 0, y: 3)
    end

    def render_message_log(console)
      @message_log.messages = $message_log.messages
      @message_log.render(console)
    end

    def render_names_at_cursor_position(console)
      cursor_x, cursor_y = ScreenLayout.console_to_map_position $game.cursor_position
      return unless game_map.in_bounds?(cursor_x, cursor_y) && game_map.visible?(cursor_x, cursor_y)

      names_at_cursor_position = game_map.entities_at(cursor_x, cursor_y).map(&:name).join(', ').capitalize
      console.print(x: 21, y: 5, string: names_at_cursor_position) if $game.scene.class == Scenes::PositionSelection
    end

    def render_dimension_name(console)
      console.print(x: 1, y: 1, string: 'Dimension:')
      console.print(x: 1, y: 0, string: "#{$game.game_world.seed}-#{$game.game_world.current_floor}")
    end
  end
end
