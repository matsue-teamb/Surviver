require 'dxruby'

# �}�b�v
class Map
  attr_reader :mapdata
  # target�͕`����RenderTarget/Window
  def initialize(filename, mapimage, target=Window)
    @mapimage, @target = mapimage, target
    @mapdata = []
    File.open(filename, "rt") do |fh|
      lines = fh.readlines
      lines.each do |line|
        ary = []
        line.chomp.each_char do |o|
          if o != "x"
            ary << o.to_i
          else
            ary << nil
          end
        end
        @mapdata << ary
      end
    end
  end

  def draw(x, y)
    image = @mapimage[0]
    @target.draw_tile(0, 0, @mapdata, @mapimage, x, y,
                      (@target.width + image.width - 1) / image.width,
                      (@target.height + image.height - 1) / image.height)
  end

  def [](x, y)
    @mapdata[y % @mapdata.size][x % @mapdata[0].size]
  end

  def []=(x, y, v)
    @mapdata[y % @mapdata.size][x % @mapdata[0].size] = v
  end

  def size_x
    @mapdata[0].size
  end

  def size_y
    @mapdata.size
  end
end