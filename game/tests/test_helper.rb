module GTK
  class Assert
    def includes!(collection, element, message = nil)
      @assertion_performed = true
      return if collection.include? element

      raise "#{collection_description(collection)}\n\ndid not contain:\n  #{element}\n#{message}."
    end

    def includes_all!(collection, elements, message = nil)
      @assertion_performed = true
      missing_elements = elements.reject { |element| collection.include? element }
      return if missing_elements.empty?

      raise "#{collection_description(collection)}\n\ndid not contain:\n  #{elements.inspect}\n#{message}."
    end

    def includes_no!(collection, element, message = nil)
      @assertion_performed = true
      return unless collection.include? element

      raise "#{collection_description(collection)}was not expected to contain:\n  #{element}\n#{message}."
    end

    def includes_none_of!(collection, elements, message = nil)
      @assertion_performed = true
      included_elements = elements.select { |element| collection.include? element }
      return if included_elements.empty?

      raise "#{collection_description(collection)}\n\nwas not expected to contain:\n  #{elements.inspect}\n#{message}."
    end

    def contains_exactly!(collection, elements, message = nil)
      @assertion_performed = true
      expected_description = "#{collection_description(collection)}was expected to contain exactly:\n#{elements.inspect}\n\n"
      missing_elements = elements.reject { |element| collection.include? element }
      unless missing_elements.empty?
        raise "#{expected_description}but it was was missing:\n#{missing_elements.inspect}\n#{message}"
      end

      unexpected_elements = collection.reject { |element| elements.include? element }
      return if unexpected_elements.empty?

      raise "#{expected_description}but it additionally contained:\n#{unexpected_elements.inspect}\n#{message}"
    end

    def has_attributes!(object, attributes)
      @assertion_performed = true
      missing_attributes = attributes.each_key.reject { |name| object.respond_to?(name) }

      expectation_message = "Object:\n  #{object}\n\nwas expected to have attributes:\n  #{attributes.inspect}\n\n"
      raise "#{expectation_message}but it didn't respond to:\n  #{missing_attributes}" unless missing_attributes.empty?

      actual_values = attributes.each_key.map { |name| [name, object.send(name)] }.to_h
      return if actual_values == attributes

      raise "#{expectation_message}but it's actual attributes were:\n  #{actual_values}"
    end

    def raises_with_message!(exception_class, exception_message, message = nil)
      @assertion_performed = true

      expected_description = "#{exception_class} with #{exception_message.inspect}"
      error_message = nil
      begin
        yield
        error_message = "Expected:\n  #{expected_description}\n\nto be raised, but nothing was raised.\n #{message}."
      rescue exception_class => e
        return if e.message == exception_message

        error_message = "Actual exception:\n  #{exception_description(e)}\n\nwas raised but expected:\n  #{expected_description}\n#{message}."
      rescue StandardError => e
        error_message = "Actual exception:\n  #{exception_description(e)}\n\nwas raised but expected:\n  #{expected_description}\n#{message}."
      end

      raise error_message if error_message
    end

    def raises_no_exception!(message = nil)
      @assertion_performed = true

      begin
        yield
      rescue StandardError => e
        raise "Actual exception:\n  #{exception_description(e)}\n\nwas raised but expected none to be raised.\n#{message}."
      end
    end

    def not_empty!(collection, message = nil)
      @assertion_performed = true
      return unless collection.empty?

      raise "#{collection_description(collection)}\n\nwas not expected to be empty:\n it contains #{collection}\n#{message}."
    end

    # Game specific

    def will_advance_turn!
      @assertion_performed = true
      advance_turn_calls = mock_method $game, :advance_turn

      yield

      raise 'Turn was not advanced!' if advance_turn_calls.empty?
    end

    def will_not_advance_turn!
      @assertion_performed = true
      advance_turn_calls = mock_method $game, :advance_turn

      yield

      raise 'Turn was advanced!' unless  advance_turn_calls.empty?
    end

    def will_produce_action!(input_event, expected_action)
      with_mocked_method $game, :handle_action do |handle_action_calls|
        $game.handle_input_events([input_event])

        actual_actions = handle_action_calls.map { |call| call[0] }
        equal! actual_actions, [expected_action]
      end
    end

    def will_produce_no_action!(input_event)
      with_mocked_method $game, :handle_action do |handle_action_calls|
        $game.handle_input_events([input_event])

        actual_actions = handle_action_calls.map { |call| call[0] }
        equal! actual_actions, [nil]
      end
    end

    def will_change_scene_to!(scene_object_or_class)
      previous_scene = $game.scene

      yield

      not_equal! $game.scene, previous_scene, "Scene didn't change"
      if scene_object_or_class.is_a? Scenes::BaseScene
        equal! $game.scene, scene_object_or_class
      else
        equal! $game.scene.class, scene_object_or_class
      end
    end

    def will_not_change_scene!
      previous_scene = $game.scene

      yield

      equal! $game.scene, previous_scene, 'Scene was not supposed to change'
    end

    private

    def exception_description(exception)
      "#{exception.class} with #{exception.message.inspect}"
    end

    def collection_description(collection)
      "Collection:\n  #{collection.inspect}\n\n"
    end
  end
end

module TestHelper
  class Spy
    attr_reader :calls

    def initialize(wrapped_object = nil)
      @wrapped_object = wrapped_object
      @calls = []
    end

    def method_missing(name, *args)
      @calls << [name, args]
      @wrapped_object.send(name, *args) if @wrapped_object && @wrapped_object.respond_to?(name)
    end
  end

  class Mock
    def initialize
      @defined_methods = []
      @expected_calls = []
      @index = 0
    end

    def expect_call(method_name, args: nil, return_value: nil)
      define_mock_method method_name unless @defined_methods.include? method_name
      @expected_calls << [method_name, args || [], return_value]
    end

    def define_mock_method(name)
      define_singleton_method name do |*args|
        actual_call = "#{name} was called with args:\n#{args}\n\n"
        raise "#{actual_call} as call \##{@index + 1} but no more calls are expected." unless @index < @expected_calls.size

        expected_name, expected_args, return_value = expected_call
        if name == expected_name && args == expected_args
          @index += 1
          return return_value
        end

        raise "#{expected_call_description} but actually #{actual_call}"
      end
      @defined_methods << name
    end

    def expected_call
      @expected_calls[@index]
    end

    def expected_call_description
      expected_name, expected_args = expected_call[0..1]
      "Expected call \##{@index + 1} to be to #{expected_name} with args:\n  #{expected_args}\n\n"
    end

    def assert_all_calls_received!(assert)
      assert.ok!
      return if @index == @expected_calls.size

      raise "#{expected_call_description} but it was never received."
    end
  end
end

def log_messages
  $message_log.messages.map(&:text)
end

def build_entity(attributes = nil)
  values = attributes || {}
  final_attributes = {
    x: nil, y: nil, parent: nil,
    color: [255, 255, 255],
    render_order: RenderOrder::ACTOR,
    blocks_movement: true,
    name: values.delete(:name) || 'Entity'
  }
  final_attributes[:char] ||= final_attributes[:name][0]
  final_attributes.update(values)
  unique_entity_type = :"#{final_attributes[:name]}_#{GTK::Entity.strict_entities.size}"
  Entity.build(
    unique_entity_type,
    final_attributes
  )
end

def build_actor(attributes = nil)
  values = attributes || {}
  final_attributes = {
    name: values.delete(:name) || 'Monster',
    combatant: {
      hp: values.delete(:hp) || 20,
      base_power: values.delete(:base_power) || 5,
      base_defense: values.delete(:base_defense) || 5,
      base_vision: values.delete(:base_vision) || 5
    },
    inventory: { items: [] },
    ai: { type: :enemy, data: {} },
    received_xp: 0,
    equipment: {}
  }
  final_attributes[:combatant][:max_hp] = values.delete(:max_hp) || final_attributes[:combatant][:hp]
  items = values.delete(:items) || []
  final_attributes.update(values)
  build_entity(final_attributes).tap { |result|
    items.each do |item|
      item.place(result.inventory)
    end
  }
end

def build_player
  EntityPrototypes.build(:player)
end

def build_item(attributes = nil)
  values = attributes || {}
  final_attributes = {
    name: values.delete(:name) || 'Item',
    blocks_movement: false,
  }.merge(values.empty? ? { consumable: { type: :healing, amount: 5 } } : values)
  build_entity(final_attributes)
end

def build_game_map(width: 10, height: 10, tiles: nil, portal_location: nil)
  game_map_tiles = Array.new(width * height) { :floor }
  (tiles || {}).each do |position, tile|
    game_map_tiles[position.y * width + position.x] = tile
  end
  GameMap.new(
    width: width,
    height: height,
    tiles: game_map_tiles,
    portal_location: portal_location || [0, 0]
  ).tap { |game_map|
    game_map.define_singleton_method :visible? do |_x, _y|
      true
    end
  }
end

def build_game_map_with_entities(*entities)
  entities_by_position = TestHelper.assign_random_positions_if_necessary(entities)
  width = entities_by_position.keys.map(&:x).max + 3
  height = entities_by_position.keys.map(&:y).max + 3
  build_game_map(width: width, height: height).tap { |game_map|
    entities_by_position.each do |position, entities_at_position|
      TestHelper.ensure_array(entities_at_position).each do |entity|
        entity.place(game_map, x: position.x, y: position.y)
      end
    end
  }
end

module TestHelper
  class << self
    def assign_random_positions_if_necessary(entities)
      return entities[0] if entities[0].is_a? Hash

      assign_random_positions(entities)
    end

    def assign_random_positions(entities)
      {}.tap { |result|
        entities.each do |entity|
          position = nil
          position = [(rand * 10).floor, (rand * 10).floor] until position && !result.key?(position)
          result[position] = entity
        end
      }
    end

    def ensure_array(value)
      return value if value.is_a? Array

      [value]
    end
  end
end

def make_positions_non_visible(game_map, positions)
  original_method = game_map.method(:visible?)
  game_map.define_singleton_method :visible? do |x, y|
    return false if positions.include? [x, y]

    original_method.call(x, y)
  end
end

def with_replaced_method(object, name, implementation)
  original_method = object.method(name)
  object.define_singleton_method(name, &implementation)
  yield
  object.define_singleton_method(name, &original_method)
end

def with_mocked_method(object, name)
  calls = []
  with_replaced_method(object, name, ->(*args) { calls << args }) do
    yield calls
  end
end

def replace_method(object, name, &implementation)
  object.define_singleton_method(name, &implementation)
end

def stub_attribute(object, attribute, value)
  replace_method(object, attribute) { value }
end

def stub_attribute_with_mock(object, attribute)
  stub_attribute object, attribute, TestHelper::Spy.new
end

def mock_method(object, name)
  [].tap { |calls|
    replace_method(object, name) { |*args| calls << args }
  }
end

def spy_method(object, name)
  original_method = object.method(name)
  [].tap { |calls|
    replace_method(object, name) { |*args|
      calls << args
      original_method.call(*args)
    }
  }
end

def stub(methods)
  Object.new.tap { |result|
    methods.each do |method_name, return_value|
      result.define_singleton_method method_name do |*args|
        return return_value.call(*args) if return_value.respond_to? :call

        return_value
      end
    end
  }
end

$before_each_blocks = []

def before_each(&block)
  $before_each_blocks << block
end

module TestExtension
  def start
    # mruby currently throws an error: "superclass info lost [mruby limitations]"
    # if you define a block in a prepended module method that calls
    # super
    # By moving the block to a separate method, it works
    extend_test_methods_with_before_each_blocks
    super
  end

  def extend_test_methods_with_before_each_blocks
    (test_methods + test_methods_focused).each do |method_name|
      old_method = method(method_name)
      define_singleton_method method_name do |args, assert|
        $before_each_blocks.each do |before_each_block|
          before_each_block.call(args, assert)
        end
        old_method.call(args, assert)
      end
    end
  end
end

GTK::Tests.prepend TestExtension

before_each do |args|
  $state = args.state
  GTK::Entity.strict_entities.clear
  args.state.entities = Entities.build_data
  Entities.data = args.state.entities
  Entities.player = build_player
  args.state.message_log = []
  $message_log = MessageLog.new args.state.message_log
  $game = Game.new
  $game.player = Entities.player
  $game.game_map = build_game_map_with_entities(Entities.player)
  args.state.game_world = {}
  $game.game_world = GameWorld.new(args.state.game_world)
  $game.scene = Scenes::Gameplay.new(player: Entities.player)
end
