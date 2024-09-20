#主人公の攻撃方法
require 'dxruby'

class MyShot < Sprite
    def initialize(x, y, angle)
      self.image = player_tiles = Image.load('./images/shot.png')
      super(x, y, image)
      @dx = Math.cos(angle / 180.0 * Math::PI) * 5  # 弾の移動速度
      @dy = Math.sin(angle / 180.0 * Math::PI) * 5
    end
  
    def update
      self.x += @dx
      self.y += @dy
      # 入力された方向とは逆の方向に加速
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
      self.vanish if self.x < 0 || self.x > Window.width || self.y < 0 || self.y > Window.height
    end
  end

  