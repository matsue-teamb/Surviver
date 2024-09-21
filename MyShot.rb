require 'dxruby'

class MyShot < Sprite
    def initialize(x, y, angle)
      @ex = 5
      self.image = Image.load('./images/shot.png')
      super(x, y, image)
      self.collision = [16, 16, 16]
      @dx = Math.cos(angle / 180.0 * Math::PI) * 5 
      @dy = Math.sin(angle / 180.0 * Math::PI) * 5
    end
    def update
      self.x += @dx
      self.y += @dy
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
      # 画面外に出たら消える
      self.vanish if self.x < 16|| self.x > 640-48|| self.y < 16 || self.y > 480-48
    end
    def shot
      if (@ex > 0)
        @ex -= 1
      else
        self.vanish
      end
    end
  end

  