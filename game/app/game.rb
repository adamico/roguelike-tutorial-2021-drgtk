class Game
  attr_reader :player, :rng
  attr_accessor :cursor_position, :scene, :game_map

  def initialize(player:)
    @player = player
    @scene_stack = []
    @cursor_position = [player.x, player.y]
    @rng = RNG.new
  end

  def handle_input_events(input_events)
    @scene.handle_input_events(input_events)
  end

  def push_scene(next_scene)
    @scene_stack.push @scene
    @scene = next_scene
  end

  def pop_scene
    @scene = @scene_stack.pop
  end

  def render(console)
    console.clear
    @scene.render(console)
  end

  def show_history(console)
    push_scene Scenes::HistoryViewer.new(previous_scene: @scene, console: console)
  end

  def show_inventory
    item_selection = Scenes::ItemSelection.new(
      @scene,
      inventory: player.inventory,
      title: 'Select an item to use',
      window_x: item_window_x
    ) do |selected_item|
      selected_item.consumable.get_action(@player)
    end
    push_scene item_selection
  end

  def show_drop_item_menu
    item_selection = Scenes::ItemSelection.new(
      @scene,
      inventory: player.inventory,
      title: 'Select an item to drop',
      window_x: item_window_x
    ) do |selected_item|
      DropItemAction.new(@player, selected_item)
    end
    push_scene item_selection
  end

  def start_look
    position_selection = Scenes::PositionSelection.new(@scene) do
      # no op - don't perform action on enter
    end
    push_scene position_selection
  end

  def quit
    $gtk.request_quit
  end

  private

  def item_window_x
    @player.x <= 30 ? 40 : 0
  end
end
