module Scenes
  class ItemSelection < BaseScene
    def initialize(previous_scene, inventory:, title: nil, window_x: 0, &build_action_for_selected_item)
      @inventory = inventory
      @build_action_for_selected_item = build_action_for_selected_item
      @previous_scene = previous_scene
      @item_list = UI::ItemList.new(
        @inventory,
        top: 44, x: window_x,
        title: title || 'Select item'
      )
      super()
    end

    def render(console)
      @previous_scene.render(console)
      @item_list.render(console)
    end

    def after_action_performed
      $game.pop_scene
      @previous_scene.after_action_performed
    end

    protected

    def build_input_handler
      InputEventHandler.new(@item_list, @build_action_for_selected_item)
    end

    class InputEventHandler < BaseInputHandler
      def initialize(selection_ui, build_action_for_selected_item)
        super()
        @selection_ui = selection_ui
        @build_action_for_selected_item = build_action_for_selected_item
      end

      def dispatch_action_for_char_typed(event)
        unless @selection_ui.valid_input_char? event.char
          $game.pop_scene
          return
        end

        selected_item = @selection_ui.item_for_char event.char
        return unless selected_item

        @build_action_for_selected_item.call(selected_item)
      end

      def dispatch_action_for_quit
        $game.pop_scene
        nil
      end
    end
  end
end
