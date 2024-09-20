#��l���̍U�����@
require 'dxruby'

class MyShot < Sprite
    def initialize(x, y, angle)
      @ex = 5
      self.image = player_tiles = Image.load('./images/shot.png')
      super(x, y, image)
      self.collision = [16, 16, 16]
      @dx = Math.cos(angle / 180.0 * Math::PI) * 5  # �e�̈ړ����x
      @dy = Math.sin(angle / 180.0 * Math::PI) * 5
    end
  
    def update
      self.x += @dx
      self.y += @dy
      # ���͂��ꂽ�����Ƃ͋t�̕����ɉ���
      if Input.key_down?(K_RIGHT)
        self.x -= 3
      end
      if Input.key_down?(K_LEFT)
        self.x += 3
      end
      if Input.key_down?(K_DOWN)
        self.y -= 3
      end
      if Input.key_down?(K_UP)
        self.y += 3
      end
      
      # ��ʊO�ɏo���������
      self.vanish if self.x < 0 || self.x > Window.width || self.y < 0 || self.y > Window.height
    end
    def shot
      if (@ex > 0)
        @ex -= 1
      else
        self.vanish
      end
    end
  end

  