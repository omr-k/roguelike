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

def setString
	while $messageLog.size > 5
		$messageLog.shift
	end

	str = ""
	$messageLog.size.times do |n|
		str += $messageLog[n] + "\n"
	end

	return str
end

def stragetxt(strage)
	str = ""
	strage.each do |itm|
		str += itm.name + "\n"
	end

	return str
end

class Char
	attr_reader :maxstamina, :maxstrage
	attr_accessor :level, :maxhp, :hp, :stamina, :str, :vit,
	:exp, :strage, :count, :popCount, :dir, :x, :y

	def initialize
		@level = 1
		@hp = 32
		@maxhp = 32
		@stamina = 50
		@maxstamina = 100
		@str = 6
		@vit = 5
		@exp = 0
		@strage = []
		@maxstrage = 16
		@count = 0
		@popCount = 0 #       2
		@dir = 0      #  => 3   1
		@x = 0        #       0
		@y = 0
	end

	def levelup
		self.level += 1
		self.maxhp += rand(3..5)
		self.str += rand(1..4)
		self.vit += rand(1..4)
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
		case rand(0..1)
		when 0
			enemys << Enemy.new("Silver Ball", 20, 5, 4, 4, 0)
		when 1
			enemys << Enemy.new("Blue Slime", 20, 4, 6, 5, 1)
		end

		enemys[-1].x,enemys[-1].y = set(map, self)
		self.popCount = 0
	end

	def drop(items,map,num)
		if num < 5
			case rand(0..1)
			when 0
				items << Item.new("apple", "food", 40, 0)
			when 1
				items << Item.new("green herb", "herb", 10, 2)
			end
		elsif num < 10
			case rand(0..3)
			when 0
				items << Item.new("apple", "food", 40, 0)
			when 1
				items << Item.new("green apple", "food", 70, 1)	
			when 2
				items << Item.new("green herb", "herb", 10, 2)
			when 3
				items << Item.new("red herb", "herb", 20, 3)
			end
		elsif num < 15
			case rand(0..4)
			when 0
				items << Item.new("apple", "food", 40, 0)
			when 1
				items << Item.new("green apple", "food", 70, 1)	
			when 2
				items << Item.new("green herb", "herb", 10, 2)
			when 3
				items << Item.new("red herb", "herb", 20, 3)
			when 4
				items << Item.new("blue herb", "herb", 40, 4)
			end
		else
			case rand(0..6)
			when 0
				items << Item.new("apple", "food", 40, 0)
			when 1
				items << Item.new("green apple", "food", 70, 1)	
			when 2
				items << Item.new("green herb", "herb", 10, 2)
			when 3
				items << Item.new("red herb", "herb", 20, 3)
			when 4
				items << Item.new("blue herb", "herb", 40, 4)
			when 5												
				items << Item.new("potion", "potion", 60, 5)
			when 6
				items << Item.new("green potion", "potion", 80, 6)	
			end
		end

		items[-1].x,items[-1].y = set(map, self)
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

	def pickup(items)
		items.each do |itm|
			if itm.drop == true && itm.x == self.x && itm.y == self.y
				self.strage << itm
				itm.drop = false
				$messageLog << "#{itm.name}を拾った"
				break
			end
		end
	end

	def useItem(item)
		case item.category
		when "food"
			self.stamina += item.value
			if self.stamina > 100
				self.stamina = 100
			end
		when "herb"
			self.hp += item.value
			if self.hp > self.maxhp
				self.hp = self.maxhp
			end

			self.stamina += 5
			if self.stamina > 100
				self.stamina = 100
			end
		when "potion"
			self.hp += item.value
			if self.hp > self.maxhp
				self.hp = self.maxhp
			end

			self.stamina -= 10
			if self.stamina < 0
				self.stamina = 0
			end
		when "scroll"
				
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
	attr_reader :name, :maxhp, :str, :vit, :exp, :img
	attr_accessor :hp, :dir, :x, :y
	
	def initialize(name,hp,str,vit,exp,img)
		@name = name
		@hp = hp
		@maxhp = hp
		@str = str
		@vit = vit
		@exp = exp
		@img = img
		@dir = 0
		@x = 0
		@y = 0
	end

	def move(map)
		map[self.y][self.x] = 1
		flg = true
		if map.transpose[self.x].include?(3)
			player = map.transpose[self.x].index(3)
			if player > self.y
				if !map.transpose[self.x].values_at(self.y..player).include?(0)
					self.dir = 0
					if player - self.y == 1
						self.attack(map)
					elsif map[self.y+1][self.x] == 1
			        	self.y += 1
					end
				else
					flg = false
				end
			else
				if !map.transpose[self.x].values_at(player..self.y).include?(0)
					self.dir = 2
					if self.y - player == 1
						self.attack(map)
					elsif map[self.y-1][self.x] == 1
						self.y -= 1
					end
				else
					flg = false
				end
			end
		elsif map[self.y].include?(3)
			player = map[self.y].index(3)
			if player > self.x
				if !map[self.y].values_at(self.x..player).include?(0)
					self.dir = 1
					if player - self.x == 1
						self.attack(map)
					elsif map[self.y][self.x+1] == 1
						self.x += 1
					end
				else
					flg = false
				end
			else
				if !map[self.y].values_at(player..self.x).include?(0)
					self.dir = 3
					if self.x - player == 1
						self.attack(map)
					elsif map[self.y][self.x-1] == 1
						self.x -= 1
					end
				else
					flg = false
				end
			end
		else
			flg = false
		end

		if !flg
			count = 0
			while count < 4
			    if count == 0
			        dir = []
			    end
			    while dir.size < count + 1
			        dir << rand(0..3)
			        dir.uniq!
			    end
			    
			    case dir[-1]
			    when 0
			        if map[self.y+1][self.x] == 1 || map[self.y+1][self.x] == 2
			        	self.y += 1
						self.dir = 0
			        	break
			        end
		            count += 1
			    when 1
			        if map[self.y][self.x+1] == 1 || map[self.y][self.x+1] == 2
			        	self.x += 1
						self.dir = 1
			        	break
			        end
		            count += 1
			    when 2
			        if map[self.y-1][self.x] == 1 || map[self.y-1][self.x] == 2
			            self.y -= 1
						self.dir = 2
			            break
			        end
		            count += 1
			    when 3
			        if map[self.y][self.x-1] == 1 || map[self.y][self.x-1] == 2
			            self.x -= 1
						self.dir = 3
			            break
			        end
		            count += 1
			    end
			end
		end
		map[self.y][self.x] = 4
	end

	def attack(map)
		damage = self.str - $mine.vit + rand(-2..4)
		if damage <= 0
			damage = 0
		end
		if damage == 0
			$messageLog << "#{self.name}はダメージを与えられなかった"
		else
			$messageLog << "#{self.name}は#{damage}ダメージ与えた"
		end
		$mine.hp -= damage
	end
end

class Item
	attr_reader :name, :img, :category
	attr_accessor :drop, :value, :x, :y

	def initialize(name, category, value, img)
		@name = name
		@drop = true
		@category = category
		@value = value
		@img = img
		@x = 0
		@y = 0
	end
end
