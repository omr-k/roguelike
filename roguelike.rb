require 'dxruby'
require_relative "mapcreate"
require_relative "class"

Window.width = 1024
Window.height = 576

smallFont = Font.new(18)
bigFont = Font.new(32)

windows = Image.load('resource/images/windows.png')
pointer = Image.load('resource/images/pointer.png')
$messageLog = []

gameover = Image.load('resource/images/gameover.png')

floor = [Image.load('resource/images/glass.png'),Image.load('resource/images/dirt.png')]
wall = [Image.load('resource/images/wall.png'),Image.load('resource/images/rock.png')]
stair = Image.load('resource/images/stair.png')
mapdata = []
mapping = []

charImage = [Image.load('resource/images/char_front.png'),
			Image.load('resource/images/char_right.png'),
			Image.load('resource/images/char_back.png'),
			Image.load('resource/images/char_left.png')]

eneImage = [[Image.load('resource/images/ball_front.png'),Image.load('resource/images/ball_right.png'),Image.load('resource/images/ball_back.png'),Image.load('resource/images/ball_left.png'),],
			[Image.load('resource/images/slime.png'),Image.load('resource/images/slime.png'),Image.load('resource/images/slime.png'),Image.load('resource/images/slime.png')]]

enemys = []

itemImage = [Image.load('resource/images/apple.png'),Image.load('resource/images/greenapple.png'),
			Image.load('resource/images/greenherb.png'),Image.load('resource/images/redherb.png'),Image.load('resource/images/blueherb.png'),
			Image.load('resource/images/potion.png'),Image.load('resource/images/greenpotion.png'),
			Image.load('resource/images/redpotion.png'),Image.load('resource/images/bluepotion.png'),
			Image.load('resource/images/scroll.png'),]

items = []

mapflg = 0
deathflg = false
menu = 0
pointerY = 0
start = false
blind = true
floorCount = 0
Window.loop do
	Window.draw_font_ex(0,558,"push esc to end", smallFont)

	if !start
		Window.draw_font_ex(200,250,"push Z to start", bigFont)
		deathflg = false

		if Input.key_push?(K_Z)
			start = true
			floorCount = 0
		end
	else
		if mapflg == 0
			floorCount += 1
			f = floorCount
			if floorCount < 10
				mapdata = mapcreate(rand(floorCount..floorCount+1))
			else
				f = 10
				mapdata = mapcreate(rand(f))
			end
			x,y = set(mapdata, nil)
			mapdata[y][x] = 2

			if floorCount == 1
				$mine = Char.new()
			end

			$mine.x,$mine.y = set(mapdata, nil)

			enemys.clear
			items.delete_if{|itm|itm.drop == true}
			(f/2+1).times do
				$mine.pop(enemys, mapdata)
				$mine.drop(items, mapdata, floorCount)
			end

			mapflg = 1
		elsif mapflg == 1
			Window.draw_font_ex(5,5,"#{floorCount}F", smallFont)
			Window.draw_font_ex(48,5,"Lv#{$mine.level}", smallFont)
			Window.draw_font_ex(5,22,"HP:#{$mine.hp}", smallFont)
			Window.draw_font_ex(65,22,"stamina:#{$mine.stamina}", smallFont)
			Window.draw_font(50,390,setString.to_s,smallFont)
			Window.draw_font(660,40,stragetxt($mine.strage).to_s,smallFont)

			if blind
				Window.draw(0,0,windows)
				x = -2
				while x < 3
					y = -2
					while y < 3
						if $mine.x+x < 0 || $mine.y+y < 0 || $mine.x+x >= mapdata.size || $mine.y+y >= mapdata.size || mapdata[$mine.y+y][$mine.x+x] == 0
							Window.draw(250+x*32,180+y*32,wall[0])
						elsif mapdata[$mine.y+y][$mine.x+x] == 2
							Window.draw(250+x*32,180+y*32,stair)
						elsif mapdata[$mine.y+y][$mine.x+x] == 1
							Window.draw(250+x*32,180+y*32,floor[0])
						end
						y += 1
					end
					x += 1
				end

				items.each do |itm|
					if itm.drop && (itm.x - $mine.x).abs <= 2 && (itm.y - $mine.y).abs <= 2
						Window.draw(250+(itm.x - $mine.x)*32,180+(itm.y - $mine.y)*32,itemImage[itm.img])
					end
				end

				mapping = Marshal.load(Marshal.dump(mapdata))
				enemys.each do |ene|
					if (ene.x - $mine.x).abs <= 2 && (ene.y - $mine.y).abs <= 2
						Window.draw(250+(ene.x - $mine.x)*32,180+(ene.y - $mine.y)*32,eneImage[ene.img][ene.dir])
						mapping[ene.y][ene.x] = 4
					end
				end

				mapping[$mine.y][$mine.x] = 3
				Window.draw(250,180,charImage[$mine.dir])

				if Input.key_push?(K_SPACE)
					blind = false
				end
			else
				wid = mapdata.size
				wid.times do |y|
					wid.times do |x|
						if mapdata[y][x] == 0
							Window.draw(155+x*32,5+y*32,wall[0])
						elsif mapdata[y][x] == 2
							Window.draw(155+x*32,5+y*32,stair)
						else
							Window.draw(155+x*32,5+y*32,floor[0])
						end
					end
				end

				items.each do |itm|
					if itm.drop
						Window.draw(155+itm.x*32,5+itm.y*32,itemImage[itm.img])
					end
				end

				enemys.each do |ene|
					Window.draw(155+ene.x*32,5+ene.y*32,eneImage[ene.img][ene.dir])
				end

				Window.draw(155+$mine.x*32,5+$mine.y*32,charImage[$mine.dir])

				if Input.key_push?(K_SPACE)
					blind = true
				end
			end

			if $mine.hp > 0
				if menu == 0
					if Input.key_push?(K_UP)
						$mine.dir = 2
						$mine.move(enemys,mapping)
					elsif Input.key_push?(K_RIGHT)
						$mine.dir = 1
						$mine.move(enemys,mapping)
					elsif Input.key_push?(K_DOWN)
						$mine.dir = 0
						$mine.move(enemys,mapping)
					elsif Input.key_push?(K_LEFT)
						$mine.dir = 3
						$mine.move(enemys,mapping)
					end

					if $mine.strage.size < $mine.maxstrage
						$mine.pickup(items)
					end

					if Input.key_push?(K_Z)
						if mapdata[$mine.y][$mine.x] == 2
							$mine.popCount = 0
							mapflg = 0
						else
							attack = $mine.attack(enemys,mapping)
							if attack[0] == nil
								$messageLog << "素振りをした"
							elsif attack[0] == 0
								$messageLog << "#{enemys[attack[1]].name}にダメージを与えられなかった"
							else
								$messageLog << "#{enemys[attack[1]].name}に#{attack[0]}ダメージ与えた"
								if enemys[attack[1]].hp <= 0
									$messageLog << "#{enemys[attack[1]].name}は倒れた"
									$mine.exp += enemys[attack[1]].exp
									enemys.delete_at(attack[1])

									if $mine.exp >= (20 * $mine.level ** 1.7).round
										$mine.levelup
									end
								end
							end
						end

						$mine.countUp
						enemys.each do |ene|
							ene.move(mapping)
							if $mine.hp <= 0
								$mine.hp = 0
								break
							end
						end
					end

					if Input.key_push?(K_X)
						menu = 1
						pointerY = 0
					end
				elsif menu == 1
					Window.draw(640,40+pointerY*18,pointer)

					if Input.key_push?(K_UP)
						pointerY -= 1
						if pointerY == -1
							pointerY = 0
						end
					elsif Input.key_push?(K_DOWN)
						pointerY += 1
						if pointerY >= $mine.strage.size
							pointerY -= 1
						end
					end

					if $mine.strage.size > 0 && Input.key_push?(K_Z)
						$mine.useItem($mine.strage[pointerY])
						$mine.strage.delete_at(pointerY)
					end

					if Input.key_push?(K_X)
						menu = 0
					end
				end
			else
				if !deathflg
					deathflg = true
					$messageLog << "あなたはは倒れてしまった"
				end
				Window.draw(100,200,gameover)

				if Input.key_push?(K_Z)
					mapflg = 0
					start = false
				end
			end
		end
	end

	break if Input.key_push?(K_ESCAPE)
end