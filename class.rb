def set(map, ban)
	while true
		x = rand(1..(map.size-2))
		y = rand(1..(map.size-2))
		if map[y][x] == 1
			if ban == nil
				return x,y
				break
			else
				if (ban.x - x).abs + (ban.y - y).abs > 3
					return x,y
					break	
				end
			end
		end
	end
end

class Char
	attr_reader :maxhp, :maxstamina, :str, :vit
	attr_accessor :hp, :stamina, :dir, :x, :y, :count, :popCount

	def initialize
		@hp = 32
		@maxhp = 32
		@stamina = 50
		@maxstamina = 100
		@str = 6
		@vit = 5
		@count = 0
		@popCount = 0 #       2
		@dir = 0      #  => 3   1
		@x = 0        #       0
		@y = 0
	end

	def countUp
		self.count += 1
		if self.stamina == 0
			self.hp -= 1
		end
		if self.count == 5
			if self.stamina > 0
				if self.hp < self.maxhp
					self.hp += 1
				end
				self.stamina -= 1
			end
			self.count = 0
		end
	end

	def pop(enemys,map)
		if enemys.size < map.size-5 && enemys.size < 9
			enemys << Enemy.new("Silver Ball", 20, 5, 4, 0)
			enemys[-1].x,enemys[-1].y = set(map,self)
		end
		self.popCount = 0
	end

	def move(enemys,map)
		flg = false
		map[self.y][self.x] = 1
		case self.dir
		when 0
			if (map[self.y+1][self.x] == 1 || map[self.y+1][self.x] == 2) && !Input.key_down?(K_LSHIFT)
				self.y += 1
				flg = true
			end
		when 1
			if (map[self.y][self.x+1] == 1 || map[self.y][self.x+1] == 2) && !Input.key_down?(K_LSHIFT)
				self.x += 1
				flg = true
			end
		when 2
			if (map[self.y-1][self.x] == 1 || map[self.y-1][self.x] == 2) && !Input.key_down?(K_LSHIFT)
				self.y -= 1
				flg = true
			end
		when 3
			if (map[self.y][self.x-1] == 1 || map[self.y][self.x-1] == 2) && !Input.key_down?(K_LSHIFT)
				self.x -= 1
				flg = true
			end
		end
		
		map[self.y][self.x] = 3

		if flg
			self.countUp

			enemys.each do |ene|
				ene.move(map)
			end

			self.popCount += 1
			if self.popCount == 20
				self.pop(enemys,map)
			end
		end
	end

	def attack(enemys,map)
		targetY = 0
		targetX = 0
		case self.dir
		when 0
			if map[self.y+1][self.x] == 4
				targetY = self.y+1
				targetX = self.x
			end
		when 1
			if map[self.y][self.x+1] == 4
				targetY = self.y
				targetX = self.x+1
			end
		when 2
			if map[self.y-1][self.x] == 4
				targetY = self.y-1
				targetX = self.x
			end
		when 3
			if map[self.y][self.x-1] == 4
				targetY = self.y
				targetX = self.x-1
			end
		end

		if targetY != 0
			targetNum = 0
			while targetNum < enemys.size
				if enemys[targetNum].y == targetY && enemys[targetNum].x == targetX
					break
				end
				targetNum += 1
			end

			damage = self.str - enemys[targetNum].vit + rand(-2..4)
			if damage <= 0
				damage = 0
			end
			enemys[targetNum].hp -= damage
			return [damage,targetNum]
		else
			return [nil,nil]
		end
	end
end

class Enemy
	attr_reader :name, :maxhp, :str, :vit
	attr_accessor :hp, :img, :dir, :x, :y
	
	def initialize(name,hp,str,vit,img)
		@name = name
		@hp = hp
		@maxhp = hp
		@str = str
		@vit = vit
		@img = img
		@dir = 0
		@x = 0
		@y = 0
	end

	def move(map)
		map[self.y][self.x] = 1
		flg = 0
		while flg < 4
		    if flg == 0
		        dir = []
		    end
		    while dir.size < flg + 1
		        dir << rand(1..4)
		        dir.uniq!
		    end
		    
		    case dir[-1]
		    when 1
		        if map[self.y][self.x+1] == 1 || map[self.y][self.x+1] == 2
		        	self.x += 1
		        	break
		        else
		            flg += 1
		        end
		    when 2
		        if map[self.y+1][self.x] == 1 || map[self.y+1][self.x] == 2
		        	self.y += 1
		        	break
		        else
		            flg += 1
		        end
		    when 3
		        if map[self.y][self.x-1] == 1 || map[self.y][self.x-1] == 2
		            self.x -= 1
		            break
		        else
		            flg += 1
		        end
		    when 4
		        if map[self.y-1][self.x] == 1 || map[self.y-1][self.x] == 2
		            self.y -= 1
		            break
		        else
		            flg += 1
		        end
		    end
		end
		map[self.y][self.x] = 4
	end
end

class Item
	attr_reader :name, :img
	attr_accessor :drop, :x, :y

	def initialize(name, img)
		@name = name
		@img = img
		@drop = true
		@x = 0
		@y = 0
	end
end
