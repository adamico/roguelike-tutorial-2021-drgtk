class String
  def unicode_chars
    [].tap { |result|
      original_chars = chars
      index = 0
      while index < original_chars.size
        char = original_chars[index]
        if char == "\xe2"
          result << self[index..(index + 2)]
          index += 3
        else
          result << char
          index += 1
        end
      end
    }
  end
end

module Engine
  # Tileset in 16x16 tiles Dwarf Fortress layout
  class Tileset
    attr_reader :path, :tile_w, :tile_h

    def initialize(path)
      @path = path
      calc_tile_dimensions
    end

    TILES = [
      [].freeze,
      [].freeze,
      %( !"#$%&'()*+,-./).chars.freeze,
      '0123456789:;<=>?'.chars.freeze,
      '@ABCDEFGHIJKLMNO'.chars.freeze,
      'PQRSTUVWXYZ[\]^_'.chars.freeze,
      '`abcdefghijklmno'.chars.freeze,
      'pqrstuvwxyz{|}~⌂'.chars.freeze,
      [].freeze,
      [].freeze,
      [].freeze,
      '░▒▓│┤╡╢╖╕╣║╗╝╜╛┐'.unicode_chars.freeze,
      '└┴┬├─┼╞╟╚╔╩╦╠═╬╧'.unicode_chars.freeze,
      '╨╤╥╙╘╒╓╫╪┘┌█▄▌▐▀'.unicode_chars.freeze
    ].freeze

    TILE_POSITIONS = {}.tap { |result|
      TILES.each_with_index { |row, y_from_top|
        row.each_with_index do |char, x|
          result[char] = [x, 15 - y_from_top].tap { |position|
            position.mark_as_point!
            position.freeze
          }
        end
      }
    }.freeze

    def tile_x(string)
      TILE_POSITIONS[string].x * @tile_w
    end

    def tile_y(string)
      TILE_POSITIONS[string].y * @tile_h
    end

    private

    def calc_tile_dimensions
      w, h = $gtk.calcspritebox @path
      @tile_w = w.idiv(16)
      @tile_h = h.idiv(16)
    end
  end
end
