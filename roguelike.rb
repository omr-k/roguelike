require 'dxruby'
require_relative "mapcreate"
require_relative "class"

Window.width = 1024
Window.height = 576

font = Font.new(18)

windows = Image.load('resource/image/windows.png')
messageLog = []
str = ""

glass = Image.load('resource/image/glass.png')
wall = Image.load('resource/image/wall.png')
stair = Image.load('resource/image/stair.png')
mapdata = []
mapping = []

charImage = [Image.load('resource/image/char_front.png'),
			Image.load('resource/image/char_right.png'),
			Image.load('resource/image/char_back.png'),
			Image.load('resource/image/char_left.png')]

eneImage = [[Image.load('resource/image/ball_front.png'),Image.load('resource/image/ball_right.png'),Image.load('resource/image/ball_back.png'),Image.load('resource/image/ball_left.png'),],
			[Image.load('resource/image/slime.png'),Image.load('resource/image/slime.png'),Image.load('resource/image/slime.png'),Image.load('resource/image/slime.png')]
			]

enemys = []

apple = Image.load('resource/image/apple.png')

items = []

mine = Char.new()

mapflg = 0
blind = true
floorCount = 0
Window.loop do
	Window.draw_font_ex(0,560,"push esc to end", font)
	Window.draw_font_ex(0,0,"#{floorCount}F", font)
	Window.draw_font_ex(0,17,"HP:#{mine.hp}", font)
	Window.draw_font_ex(60,17,"stamina:#{mine.stamina}", font)
	Window.draw_font(50,390,str,font)

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
			Window.draw(0,0,windows)
			x = -2
			while x < 3
				y = -2
				while y < 3
					if mine.x+x < 0 || mine.y+y < 0 || mine.x+x >= mapdata.size || mine.y+y >= mapdata.size || mapdata[mine.y+y][mine.x+x] == 0
						Window.draw(250+x*32,180+y*32,wall)
					elsif mapdata[mine.y+y][mine.x+x] == 2
						Window.draw(250+x*32,180+y*32,stair)
					elsif mapdata[mine.y+y][mine.x+x] == 1
						Window.draw(250+x*32,180+y*32,glass)
					end
					y += 1
				end
				x += 1
			end

			items.each do |it|
				if it.drop && (it.x - mine.x).abs <= 2 && (it.y - mine.y).abs <= 2
					Window.draw(250+(it.x - mine.x)*32,180+(it.y - mine.y)*32,it.img)
				end
			end

			mapping = Marshal.load(Marshal.dump(mapdata))
			enemys.each do |en|
				if (en.x - mine.x).abs <= 2 && (en.y - mine.y).abs <= 2
					Window.draw(250+(en.x - mine.x)*32,180+(en.y - mine.y)*32,eneImage[en.img][en.dir])
					mapping[en.y][en.x] = 4
				end
			end

			mapping[mine.y][mine.x] = 3
			Window.draw(250,180,charImage[mine.dir])

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

			items.each do |it|
				if it.drop
					Window.draw(155+it.x*32,5+it.y*32,it.img)
				end
			end

			enemys.each do |en|
				Window.draw(155+en.x*32,5+en.y*32,eneImage[en.img][en.dir])
			end

			Window.draw(155+mine.x*32,5+mine.y*32,charImage[mine.dir])

			if Input.key_push?(K_SPACE)
				blind = true
			end
		end

		if Input.key_push?(K_UP)
			mine.dir = 2
			mine.move(enemys,mapping)
		elsif Input.key_push?(K_RIGHT)
			mine.dir = 1
			mine.move(enemys,mapping)
		elsif Input.key_push?(K_DOWN)
			mine.dir = 0
			mine.move(enemys,mapping)
		elsif Input.key_push?(K_LEFT)
			mine.dir = 3
			mine.move(enemys,mapping)
		end

		if Input.key_push?(K_Z)
			if mine.x == items[0].x && mine.y == items[0].y && items[0].drop
				mine.stamina += 50
				if mine.stamina > mine.maxstamina
					mine.stamina = mine.maxstamina
				end
				items[0].drop = false
			elsif mapdata[mine.y][mine.x] == 2
				mine.popCount = 0
				mapflg = 0
			else
				attack = mine.attack(enemys,mapping)
				if attack[0] == nil
					str = message(messageLog,"素振りをした")
				elsif attack[0] == 0
					str = message(messageLog,"#{enemys[attack[1]].name}にダメージを与えられなかった")
				else
					str = message(messageLog,"#{enemys[attack[1]].name}に#{attack[0]}ダメージ与えた")
					if enemys[attack[1]].hp <= 0
						str = message(messageLog,"#{enemys[attack[1]].name}は倒れた")
						enemys.delete_at(attack[1])
					end
				end
			end

			mine.countUp
			enemys.each do |en|
				en.move(mapping)
			end
		end
	end

	break if Input.key_push?(K_ESCAPE)
end