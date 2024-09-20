# スクロールサンプルその１(単純ループスクロール)
require 'dxruby'
require './map'
require_relative 'MyShot'

# 絵のデータを作る
mapimage = []
mapimage.push(Image.new(32, 32, [100, 100, 200])) # 海
mapimage.push(Image.load('./images/field1.png'))   # 平地
mapimage.push(Image.load('./images/field2.png'))
mapimage.push(Image.new(32, 32, [50, 200, 50]).   # 山
                        triangle_fill(15, 0, 0, 31, 31, 31, [200, 100,100]))
mapimage.push(Image.new(32, 32).  # 木のあたま。背景は透明色にしておく。
                        box_fill(13, 16, 18, 31, [200, 50, 50]).
                        circle_fill(16, 10, 8, [0, 255, 0]))

# Fiberを使いやすくするモジュール
module FiberSprite
  def initialize(x=0,y=0,image=nil)
    super
    @fiber = Fiber.new do
      self.fiber_proc
    end
  end

  def update
    @fiber.resume
    super
  end

  def wait(t=1)
    t.times{Fiber.yield}
  end
end

# 自キャラ
class Player < Sprite
  include FiberSprite
  attr_accessor :mx, :my, :shot_cooldown

  def initialize(x, y, map, target=Window)
    @mx, @my, @map, self.target = x, y, map, target
    super(8.5 * 32, 6 * 32)
    @shot_cooldown = 60

    # 頭は上にはみ出して描画されるのでそのぶん位置補正する細工
    self.center_x = 0
    self.center_y = 16
    self.offset_sync = true

    # 棒人間画像
    self.image = player_tiles = Image.load('./images/player.png')
  end

  # Player#updateすると呼ばれるFiberの中身
  def fiber_proc
    loop do
      ix, iy = Input.x, Input.y

      # デフォルトの向き
      if ix == 0 && iy == 0
        angle = 90
      end
      # 入力された方向の向き
      if ix == 1 && iy == 0
        angle = 0
      end
      if ix == 1 && iy == 1
        angle = 45
      end
      if iy == 1 && ix == 0
        angle = 90
      end
      if ix == -1 && iy == 1
        angle = 135
      end
      if ix == -1 && iy == 0
        angle = 180
      end
      if ix == -1 && iy == -1
        angle = 225
      end
      if iy == -1 && ix == 0
        angle = 270
      end
      if ix == 1 && iy == -1
        angle = 315
      end
      
      @mx += ix * 4
      @my += iy * 4
      wait # waitすると次のフレームへ

      if @shot_cooldown > 0
        @shot_cooldown -= 1  # カウントダウン
      else
        # クールダウンが0になったら弾を発射
        $my_shots << MyShot.new(x + 32, y + 24, angle)
        @shot_cooldown = 60  # 次の弾発射までの時間をリセット（1秒後に再発射）
      end
    end
  end
end

class Enemy < Sprite
    def initialize(x, y, target=Window)
        super(x, y)
        self.x = x
        self.y = y
        self.image = Image.new(100, 100).circle_fill(50, 50, 50, C_RED)
        self.target = target
        @speed = 2
    end

    def update(player)
        dx = player.x - self.x
        dy = player.y - self.y
        distance = Math.sqrt(dx**2 + dy**2)
        if (distance > 0)
            edx = dx / distance
            edy = dy / distance
        end
        self.x += edx * @speed
        self.y += edy * @speed
        ix, iy = Input.x, Input.y

      # 押されたチェック
      if ix + iy != 0 and (ix == 0 or iy == 0) 
        # 8フレームで1マス移動
        8.times do
          self.x -= ix * 0.5
          self.y -= iy * 0.5
        end
      end
    end
end

# RenderTarget作成
rt = RenderTarget.new(640-64, 480-64)

# マップの作成
map_base = Map.new("map.dat", mapimage, rt)
map_sub = Map.new("map_sub.dat", mapimage, rt)

# 自キャラ
player = Player.new(0, 0, map_base, rt)
$my_shots = []

enemy = Enemy.new(0, 0, rt)

Window.loop do
  # 人移動処理
  player.update

  enemy.update(player)

  # rtにベースマップを描画
  map_base.draw(player.mx - player.x, player.my - player.y)

  # rtに人描画
  player.draw

  enemy.draw

  # rtに上層マップを描画
  map_sub.draw(player.mx - player.x, player.my - player.y)

  # rtを画面に描画
  Window.draw(32, 32, rt)

  $my_shots.each do |shot|
    shot.update
    shot.draw
  end

  # 弾が画面外に出たら削除
  $my_shots.reject!(&:vanished?)

  # エスケープキーで終了
  break if Input.key_push?(K_ESCAPE)
end
