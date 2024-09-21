require 'dxruby'
require './map'
require_relative 'MyShot'
require_relative 'enemy'
require_relative 'boss_enemy'
require_relative "title"

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

$score = 0
$player_hp = 100
$invincible = 0
$soundclear = Sound.new('./bgm/clear.wav')
$sound = 0

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

  def initialize(x, y, map)
    @mx, @my, @map = x, y, map, @direction = 1, @frame = 0, @count = 0
    super(304, 224)
    @shot_cooldown = 60

    @soundshot = Sound.new('./bgm/shot.wav')


    # アニメーション設定
    @character_image = [] 
    @character_image.push(Image.load_tiles('./images/player_up.png',3,1,true))
    @character_image.push(Image.load_tiles('./images/player_down.png',3,1,true))
    @character_image.push(Image.load_tiles('./images/player_left.png',3,1,true))
    @character_image.push(Image.load_tiles('./images/player_right.png',3,1,true))
    self.image = @character_image[1][0]
  end

  # Player#updateすると呼ばれるFiberの中身
  def fiber_proc
    angle = 0
    loop do
      ix, iy = Input.x, Input.y

      # 押されたチェック
      if ix + iy != 0 and (ix == 0 or iy == 0) 
        @frame = (@frame + 1) % 3
        @count += 1
        if @count > 4
        case
        when ix > 0
          @direction = 3
        when ix < 0
          @direction = 2
        when iy > 0
          @direction = 1
        when iy < 0
          @direction = 0
        end
        self.image=@character_image[@direction][@frame]
        @count = 0
        @last_direction = @direction
        end
      elsif ix != 0 && iy != 0
        @frame = (@frame + 1) % 3 
        @count += 1
        if @count > 4
          self.image=@character_image[@last_direction][@frame]
          @count = 0
        end
      end

      # デフォルトの向き
      if ix == 0 && iy == 0
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
     
      if ix + iy != 0 and (ix == 0 or iy == 0) 
      @mx += ix * 4
      @my += iy * 4
      else
        @mx += ix * (4 / Math.sqrt(2)) # 斜め移動時の速度調整
        @my += iy * (4 / Math.sqrt(2))
      end
      wait # waitすると次のフレームへ
  
      if @shot_cooldown > 0
        @shot_cooldown -= 1  # カウントダウン
      else
        # クールダウンが0になったら弾を発射
        $my_shots << MyShot.new(x, y, angle)

        @soundshot.play
        @shot_cooldown = 60  # 次の弾発射までの時間をリセット（1秒後に再発射）

      end
    end
  end
end

enemies = []
boss_enemies = []
spawn_interval = 20
flame_count = 0

# RenderTarget作成
rt = RenderTarget.new(640-64, 480-64)

# マップの作成
map_base = Map.new("map.dat", mapimage, rt)
map_sub = Map.new("map_sub.dat", mapimage, rt)

# 自キャラ
player = Player.new(0, 0, map_base)
$my_shots = []

scene = "title"

  if flame_count % spawn_interval == 0
    enemies << enemy = Enemy.new(0, 0)
    boss_enemies << boss_enemy = Bossenemy.new(0, 0)
  end

  
Window.loop do
  case scene
  when "title" # タイトル画面
    Window.draw_font(200, 200, "Surviver", Font.new(80))
    Window.draw_font(220, 280, "Push space to start.", Font.new(24))
    scene = "main" if Input.key_push?(K_SPACE)
  when "main"
    # 人移動処理
    player.update

    if flame_count % spawn_interval == 0
      enemies << enemy = Enemy.new(0, 0)
      boss_enemies << boss_enemy = Bossenemy.new(0, 0)
    end

    flame_count += 1

    map_base.draw(player.mx - player.x, player.my - player.y)

  # rtを画面に描画
  Window.draw(32, 32, rt)

  # rtに人描画
  player.draw

    # rtに人描画
    player.draw

    
  enemies.each do |enemy|
    enemy.update(player)
    enemy.draw
  end

  boss_enemies.each do |boss_enemy|
    boss_enemy.update(player)
    boss_enemy.draw
  end

  # rtに上層マップを描画
  map_sub.draw(player.mx - player.x, player.my - player.y)

  $my_shots.each do |shot|
    shot.update
    shot.draw
  end

  Sprite.check($my_shots, enemies)
  Sprite.check($my_shots, boss_enemies)
  
  # 弾が画面外に出たら削除
  $my_shots.reject!(&:vanished?)
  enemies.reject!(&:vanished?)

    # 弾が画面外に出たら削除
    $my_shots.reject!(&:vanished?)

if Sprite.check(player,enemies)  || Sprite.check(player,boss_enemies) 
    if $invincible >= 20
      $player_hp -= 10  # HPを減少
      $invincible = 0
    end
end
      
if $invincible < 20
  $invincible += 1
end 
    

    Window.draw_font(100, 10, "Score: #{$score}", Font.new(24))
    Window.draw_font(10, 10, "HP: #{$player_hp}", Font.new(24))

    # エスケープキーで終了
    scene = "end"  if Input.key_push?(K_ESCAPE)
    scene = "gameover" if $player_hp <= 0
    scene = "gameclear" if $score > 3000
    
  when "end"
    Window.draw_font(200, 200, "thanks for playing", Font.new(50))
when "gameover"
  Window.draw_font(200, 200, "GameOver", Font.new(50))
when "gameclear"
  Window.draw_font(200, 200, "GameClear", Font.new(50))
  if $sound == 0
    $soundclear.play
    $sound = 1
  end
end
end
