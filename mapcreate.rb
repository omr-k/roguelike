def mapcreate(n)
	n = n*2 +5
	map = []

	n.times do |num|
	    map << Array.new(n,0)
	end

	wid = n/2
	point = wid ** 2

	count = 0
	while count < point
		if count == 0
		    num = rand(1..point)-1
		    x = (num % wid) * 2 + 1
		    y = (num / wid) * 2 + 1
		    map[y][x] = 1
		    count += 1
		else
		    while true
		        num = rand(1..point)-1
		        x = (num % wid) * 2 + 1
		        y = (num / wid) * 2 + 1
		        if map[y][x] == 1
		            break
		        end
		    end
		end

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
		        if x+2 < map.size && map[y][x+2] == 0
		            map[y][x+1] = 1
		            map[y][x+2] = 1
		            x += 2
		            count += 1
		            flg = 0
		        else
		            flg += 1
		        end
		    when 2
		        if y+2 < map.size && map[y+2][x] == 0
		            map[y+1][x] = 1
		            map[y+2][x] = 1
		            y += 2
		            count += 1
		            flg = 0
		        else
		            flg += 1
		        end
		    when 3
		        if x-2 > 0 && map[y][x-2] == 0
		            map[y][x-2] = 1
		            map[y][x-1] = 1
		            x -= 2
		            count += 1
		            flg = 0
		        else
		            flg += 1
		        end
		    when 4
		        if y-2 > 0 && map[y-2][x] == 0
		            map[y-2][x] = 1
		            map[y-1][x] = 1
		            y -= 2
		            count += 1
		            flg = 0
		        else
		            flg += 1
		        end
		    end
		end
	end
	return map
end