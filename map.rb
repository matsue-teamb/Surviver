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

  # x/y�̓}�b�v���̍���̍��W(�s�N�Z���\��)
  # �`��T�C�Y�͕`���(initialize��target)�ɂ�莩���I�ɒ��������
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

if __FILE__ == $0
  mapimage = []
  mapimage.push(Image.new(32, 32, [100, 100, 200])) # �C
  mapimage.push(Image.load('./images/field1.png'))   # 平地
  mapimage.push(Image.load('./images/field2.png'))
  mapimage.push(Image.new(32, 32, [50, 200, 50]).   # �R
                          triangle_fill(15, 0, 0, 31, 31, 31, [200, 100,100]))
  mapimage.push(Image.new(32, 32).  # �؂̂����܁B�w�i�͓����F�ɂ��Ă����B
                          box_fill(13, 16, 18, 31, [200, 50, 50]).
                          circle_fill(16, 10, 8, [0, 255, 0]))

  rt = RenderTarget.new(560,400)
  map1 = Map.new("map.dat", mapimage, rt)
  map2 = Map.new("map_sub.dat", mapimage, rt)
  x = 0
  y = 0
  Window.loop do
    map1.draw(x, y)
    map2.draw(x, y)
    Window.draw(40, 40, rt)
    x += 1
    y += 1
    break if Input.key_push?(K_ESCAPE)
  end
end
