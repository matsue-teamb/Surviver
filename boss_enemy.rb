

class Bossenemy < Sprite
    def initialize(x, y)
        sp = rand(4)
        case sp
        when 0 then
            sx = 0
            sy = rand(480)
        when 1 then
            sx = 640
            sy = rand(480)
        when 2 then
            sx = rand(640)
            sy = 0
        when 3 then
            sx = rand(640)
            sy = 480
        end
        super(sx,sy)
        self.collision = [16, 16, 16]
        self.image = Image.load('./images/pipo-enemy001a.png')
        @speed = 1
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
        self.x -= ix * 4
        self.y -= iy * 4  
    end

    def hit
        self.vanish
    end
end