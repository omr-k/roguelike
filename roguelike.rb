require 'dxruby'
require_relative "mapcreate"
require_relative "class"

Window.width = 1024
Window.height = 576

glass = Image.load('resource/image/glass.png')
wall = Image.load('resource/image/wall.png')
stair = Image.load('resource/image/stair.png')
mapdata = []

charImage = [Image.load('resource/image/char_front.png'),
		Image.load('resource/image/char_right.png'),
		Image.load('resource/image/char_back.png'),
		Image.load('resource/image/char_left.png')]

eneImage = [[Image.load('resource/image/ball_front.png'),Image.load('resource/image/ball_right.png'),Image.load('resource/image/ball_back.png'),Image.load('resource/image/ball_left.png'),],
		]

enemys = []

apple = Image.load('resource/image/apple.png')

items = []

mine = Char.new()

mapflg = 0
blind = true
floorCount = 0
Window.loop do
	Window.draw_font_ex(0,560,"push esc to end", Font.new(16))
	Window.draw_font_ex(0,0,"#{floorCount}F", Font.new(18))
	Window.draw_font_ex(0,17,"HP:#{mine.hp}", Font.new(18))
	Window.draw_font_ex(60,17,"stamina:#{mine.stamina}", Font.new(18))

	if mapflg == 0
		floorCount += 1
		mapdata = mapcreate(rand(floorCount..floorCount+1))
		x,y = set(mapdata, nil)
		mapdata[y][x] = 2

		mine.x,mine.y = set(mapdata, nil)

		enemys.clear
		enemys << Enemy.new("Silver Ball", 20, 5, 4, 0)
		enemys[0].x,enemys[0].y = set(mapdata, mine)

		items.clear
		items << Item.new("apple",apple)
		items[0].x,items[0].y = set(mapdata, mine)
		mapflg = 1
	elsif mapflg == 1
		if blind
			x = -2
			while x < 3
				y = -2
				while y < 3
					if mine.x+x < 0 || mine.y+y < 0 || mine.x+x >= mapdata.size || mine.y+y >= mapdata.size || mapdata[mine.y+y][mine.x+x] == 0
						Window.draw(274+x*32,274+y*32,wall)
					elsif mapdata[mine.y+y][mine.x+x] == 2
						Window.draw(274+x*32,274+y*32,stair)
					elsif mapdata[mine.y+y][mine.x+x] == 1
						Window.draw(274+x*32,274+y*32,glass)
					end
					y += 1
				end
				x += 1
			end

			if items[0].drop && (items[0].x - mine.x).abs <= 2 && (items[0].y - mine.y).abs <= 2
				Window.draw(274+(items[0].x - mine.x)*32,274+(items[0].y - mine.y)*32,items[0].img)
			end

			enemys.each do |ene|
				if (ene.x - mine.x).abs <= 2 && (ene.y - mine.y).abs <= 2
					Window.draw(274+(ene.x - mine.x)*32,274+(ene.y - mine.y)*32,eneImage[ene.img][ene.dir])
				end
			end

			Window.draw(274,274,charImage[mine.dir])

			if Input.key_push?(K_SPACE)
				blind = false
			end
		else
			wid = mapdata.size
			wid.times do |y|
				wid.times do |x|
					if mapdata[y][x] == 0
						Window.draw(155+x*32,5+y*32,wall)
					elsif mapdata[y][x] == 2
						Window.draw(155+x*32,5+y*32,stair)
					else
						Window.draw(155+x*32,5+y*32,glass)
					end
				end
			end

			if items[0].drop
				Window.draw(155+items[0].x*32,5+items[0].y*32,items[0].img)
			end

			enemys.each do |ene|
				Window.draw(155+ene.x*32,5+ene.y*32,eneImage[ene.img][ene.dir])
			end

			Window.draw(155+mine.x*32,5+mine.y*32,charImage[mine.dir])

			if Input.key_push?(K_SPACE)
				blind = true
			end
		end

		if Input.key_push?(K_UP)
			mine.dir = 2
			if mapdata[mine.y-1][mine.x] != 0 && !Input.key_down?(K_LSHIFT)
				mine.y -= 1
				mine.move(enemys,mapdata)
			end
		elsif Input.key_push?(K_RIGHT)
			mine.dir = 1
			if mapdata[mine.y][mine.x+1] != 0 && !Input.key_down?(K_LSHIFT)
				mine.x += 1
				mine.move(enemys,mapdata)
			end
		elsif Input.key_push?(K_DOWN)
			mine.dir = 0
			if mapdata[mine.y+1][mine.x] != 0 && !Input.key_down?(K_LSHIFT)
				mine.y += 1
				mine.move(enemys,mapdata)
			end
		elsif Input.key_push?(K_LEFT)
			mine.dir = 3
			if mapdata[mine.y][mine.x-1] != 0 && !Input.key_down?(K_LSHIFT)
				mine.x -= 1
				mine.move(enemys,mapdata)
			end
		end

		if mine.x == items[0].x && mine.y == items[0].y && Input.key_push?(K_Z) && items[0].drop
			mine.stamina += 50
			if mine.stamina > mine.maxstamina
				mine.stamina = mine.maxstamina
			end
			items[0].drop = false
		end

		if Input.key_push?(K_Z) && mapdata[mine.y][mine.x] == 2
			mine.popCount = 0
			mapflg = 0
		end
	end

	break if Input.key_push?(K_ESCAPE)
end