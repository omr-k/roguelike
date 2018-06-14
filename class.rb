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
	attr_accessor :hp, :maxhp, :stamina, :maxstamina, :count, :popCount, :dir, :x, :y

	def initialize
		@hp = 32
		@maxhp = 32
		@stamina = 50
		@maxstamina = 100
		@count = 0
		@popCount = 0
		@dir = 0
		@x = 0
		@y = 0
	end

	def move(enemys,map)
		self.count += 1
		if self.count == 5
			if self.stamina > 0
				self.stamina -= 1
			end
			if self.hp < self.maxhp
				self.hp += 1
			end
			self.count = 0
		end
		if self.stamina == 0
			self.hp -= 1
		end

		self.popCount += 1
		enemys.each do |ene|
			ene.move(map)
		end
		if self.popCount == 15
			p map.size
			if enemys.size < map.size-5
				enemys << Enemy.new("Silver Ball", 20, 5, 4, 0)
				enemys[-1].x,enemys[-1].y = set(map,self)
			end
			self.popCount = 0
		end
	end
end

class Enemy
	attr_reader :name, :maxhp, :str, :deff
	attr_accessor :hp, :img, :dir, :x, :y
	
	def initialize(name,hp,str,deff,img)
		@name = name
		@hp = hp
		@maxhp = hp
		@str = str
		@def = deff
		@img = img
		@dir = 0
		@x = 0
		@y = 0
	end

	def move(map)
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
		        if map[self.y][self.x+1] != 0
		        	self.x += 1
		        	break
		        else
		            flg += 1
		        end
		    when 2
		        if map[self.y+1][self.x] != 0
		        	self.y += 1
		        	break
		        else
		            flg += 1
		        end
		    when 3
		        if map[self.y][self.x-1] != 0
		            self.x -= 1
		            break
		        else
		            flg += 1
		        end
		    when 4
		        if map[self.y-1][self.x] != 0
		            self.y -= 1
		            break
		        else
		            flg += 1
		        end
		    end
		end
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
