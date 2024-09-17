#��l���̍U�����@
require 'dxruby'

class MyShot < Sprite
    def initialize(x, y, angle)
      image = Image.new(16, 16).circle_fill(8, 8, 8, [255, 0, 0])  # �Ԃ��e
      super(x, y, image)
      @dx = Math.cos(angle / 180.0 * Math::PI) * 5  # �e�̈ړ����x
      @dy = Math.sin(angle / 180.0 * Math::PI) * 5
    end
  
    def update
      self.x += @dx
      self.y += @dy
      # ��ʊO�ɏo���������
      self.vanish if self.x < 0 || self.x > Window.width || self.y < 0 || self.y > Window.height
    end
  end

  