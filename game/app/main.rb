require 'lib/builtin_extensions.rb'
require 'lib/array_2d.rb'
require 'lib/data_backed_object.rb'
require 'lib/priority_queue.rb'
require 'lib/engine.rb'
require 'lib/serializer.rb'

require 'app/constants.rb'

require 'app/rng.rb'
require 'app/colors.rb'
require 'app/render_order.rb'
require 'app/actions.rb'
require 'app/components.rb'
require 'app/entity.rb'
require 'app/entity_prototypes.rb'
require 'app/entities.rb'
require 'app/message_log.rb'
require 'app/scenes.rb'
require 'app/debug.rb'
require 'app/game.rb'
require 'app/ui.rb'
require 'app/game_tile.rb'
require 'app/tiles.rb'
require 'app/procgen.rb'
require 'app/game_map.rb'
require 'app/game_world.rb'
require 'app/screen_layout.rb'
require 'app/save_game.rb'

def tick(args)
  setup(args) if args.tick_count.zero?
  $debug.render(args, $gtk.current_framerate.to_i)
  
  $render_context.gtk_outputs = args.outputs

  begin
    $game.cursor_position = $render_context.mouse_coordinates(args.inputs) if args.inputs.mouse.moved
    $game.render($render_console)
    $game.handle_input_events(process_input(args.inputs))
    $render_context.present($render_console)
  rescue StandardError => e
    message = e.inspect
    log_error(message)
    $message_log.add_message(text: message, fg: Colors.error)
  end
end

def setup(_args)
  tileset = Engine::Tileset.new('data/cheepicus_16x16.png')
  $render_context = Engine::RenderContext.new(SCREEN_WIDTH, SCREEN_HEIGHT, tileset: tileset)
  $render_console = Engine::Console.new(SCREEN_WIDTH, SCREEN_HEIGHT)

  $game = Game.new
  $game.scene = Scenes::MainMenu.new

  $debug = Debug
end

$keydown_frames = {}

def process_input(gtk_inputs)
  keyboard = gtk_inputs.keyboard
  key_down = keyboard.key_down
  mouse = gtk_inputs.mouse
  [].tap { |result|
    result << { type: :character_screen } if key_down.c
    result << { type: :char_typed, char: gtk_inputs.text[0] } unless gtk_inputs.text.empty?
    result << { type: :quit } if key_down.escape
    result << { type: :up } if down_or_held_any?(keyboard, UP_KEYS)
    result << { type: :down } if down_or_held_any?(keyboard, DOWN_KEYS)
    result << { type: :left } if down_or_held_any?(keyboard, LEFT_KEYS)
    result << { type: :right } if down_or_held_any?(keyboard, RIGHT_KEYS)
    result << { type: :up_right } if down_or_held_any?(keyboard, UP_RIGHT_KEYS)
    result << { type: :up_left } if down_or_held_any?(keyboard, UP_LEFT_KEYS)
    result << { type: :down_right } if down_or_held_any?(keyboard, DOWN_RIGHT_KEYS) 
    result << { type: :down_left } if down_or_held_any?(keyboard, DOWN_LEFT_KEYS)
    result << { type: :wait } if down_or_held_any?(keyboard, WAIT_KEYS)
    result << { type: :view_history } if key_down.v
    result << { type: :page_up } if key_down.pageup
    result << { type: :page_down } if key_down.pagedown
    result << { type: :home } if key_down.home
    result << { type: :end } if key_down.end
    result << { type: :interact } if down_any?(keyboard, INTERACTION_KEYS)
    result << { type: :get } if key_down.g
    result << { type: :inventory } if key_down.i
    result << { type: :drop } if key_down.d
    result << { type: :confirm } if key_down.enter
    result << { type: :click } if mouse.down
    result << { type: :look } if down_any?(keyboard, LOOK_KEYS)
    result << { type: :help } if key_down.question_mark
    result << { type: :enter_portal } if key_down.greater_than
    result << { type: :main_menu_new_game } if key_down.n
    result << { type: :main_menu_continue_game } if key_down.c
    result << { type: :main_menu_quit_game } if key_down.q
  }
end

def down_any?(keyboard, keys)
  keys.any? { |key| keyboard.key_down?(key) }
end

def down_or_held_any?(keyboard, keys)
  keys.any? { |key| down_or_held(keyboard, key) }
end

def down_or_held(keyboard, key)
  if keyboard.key_down?(key)
    $keydown_frames[key] = 0
    true
  elsif keyboard.key_held?(key)
    $keydown_frames[key] += 1
    $keydown_frames[key] > 10 && $keydown_frames[key] % 5 == 0
  end
end

$gtk.reset