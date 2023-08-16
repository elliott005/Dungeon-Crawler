Enemy = Object:extend()

Enemy.AnimationBat = {
    love.graphics.newImage("images/enemyBat.png"),
    love.graphics.newImage("images/enemyBat2.png")
}

Enemy.AnimationSorcerer = {
    love.graphics.newImage("images/sorcerer1.png"),
    love.graphics.newImage("images/sorcerer2.png")
}

Enemy.AnimationWarrior = {
    love.graphics.newImage("images/warrior1.png"),
    love.graphics.newImage("images/warrior2.png")
}

Enemy.sorcererFire = love.graphics.newImage("images/new_bullet.png")

function Enemy:new(x, y, type)
    self.x = x
    self.y = y
    self.startX = x
    self.startY = y
    self.type = type
    
    self.timer = 1

    self.turn = false

    self.path = {"left"}
    self.pathfindOnce = false


    if self.type == "bat" then
        self.movePoints = 2
        self.maxHealth = 3
        self.damage = 1
        self.xp = 10
    elseif self.type == "warrior" then
        self.movePoints = 2
        self.maxHealth = 5
        self.damage = 2
        self.xp = 15
    elseif self.type == "sorcerer" then
        self.movePoints = 3
        self.maxHealth = 2
        self.xp = 20

        self.fireball = {
            x = 0,
            y = 0,
            vx = 0,
            vy = 0,
            active = false,
            damage = 2,
            speed = 0.3,
            w = 4,
            h = 4
        }
    end


    self.movePointsMax = self.movePoints
    self.moveTimer = 1
    self.moveIndex = 1
    self.health = self.maxHealth
end

function Enemy:update(dt)
    self.timer = self.timer + dt * 4
    if self.timer >= 3 then
        self.timer = 1
    end

    if self.turn then
        if (math.abs(self.x - player.x) < 2) and (math.abs(self.y - player.y) < 2) and (self.type ~= "sorcerer") then
            player.health = player.health - math.max(self.damage - player.armor, 0)
            turn = turn + 1

        elseif self.type == "sorcerer" and self.fireball.active then
            self.fireball.x = self.fireball.x + self.fireball.vx
            self.fireball.y = self.fireball.y + self.fireball.vy

            if lume.distance(self.fireball.x, self.fireball.y, player.x, player.y) < 0.5 then
                self.fireball.active = false
                player.health = player.health - self.fireball.damage
                turn = turn + 1
            end

            if (world[math.floor(self.fireball.y)][math.floor(self.fireball.x)].t ~= 0) and (world[math.floor(self.fireball.y)][math.floor(self.fireball.x)].t ~= 2) then
                self.fireball.active = false
                turn = turn + 1
            end

        else
            self.moveTimer = self.moveTimer + dt

            if not self.pathfindOnce then
                if self.type == "sorcerer" then
                    if self.x < player.x then
                        self.path = self:pathfind(self.x, self.y, self.x - love.math.random(1, 3), self.y, world)
                    elseif self.x > player.x then
                        self.path = self:pathfind(self.x, self.y, self.x + love.math.random(1, 3), self.y, world)
                    elseif self.y < player.y then
                        self.path = self:pathfind(self.x, self.y, self.x, self.y - love.math.random(1, 3), world)
                    else
                        self.path = self:pathfind(self.x, self.y, self.x, self.y + love.math.random(1, 3), world)
                    end
                else
                    self.path = self:pathfind(self.x, self.y, player.x, player.y, world)
                end

                self.pathfindOnce = true
            end


            if self.moveTimer > 1.3 then
                world[self.y][self.x].t = 0

                if self.path[self.moveIndex] == "left" then
                    self:left()
                elseif self.path[self.moveIndex] == "right" then
                    self:right()
                elseif self.path[self.moveIndex] == "up" then
                    self:up()
                elseif self.path[self.moveIndex] == "down" then
                    self:down()
                elseif self.x < player.x then
                    self:right()
                elseif self.x > player.x then
                    self:left()
                elseif self.y < player.y then
                    self:down()
                else
                    self:up()
                end

                world[self.y][self.x].t = 2

                self.moveIndex = self.moveIndex + 1
                if self.moveIndex > #self.path then
                    if self.type ~= "sorcerer" then
                        turn = turn + 1
                    else
                        self.fireball.active = true
                        self.fireball.vx, self.fireball.vy = lume.vector(lume.angle(self.x, self.y, player.x, player.y), self.fireball.speed)
                        self.fireball.x = self.x
                        self.fireball.y = self.y
                    end
                    self.moveIndex = 1
                end

                self.moveTimer = 1
            end
        end
    else
        self.pathfindOnce = false
    end
end

function Enemy:draw()
    if self.type == "bat" then
        love.graphics.draw(self.AnimationBat[math.floor(self.timer)], self.x * 8, self.y * 8, 0,
                            8 / self.AnimationBat[math.floor(self.timer)]:getWidth(),
                            8 / self.AnimationBat[math.floor(self.timer)]:getHeight())
        -- love.graphics.print(self.x .. ", " .. self.y, font, self.x * 8, self.y * 8)
    elseif self.type == "warrior" then
        love.graphics.draw(self.AnimationWarrior[math.floor(self.timer)], self.x * 8, self.y * 8, 0,
                            8 / self.AnimationWarrior[math.floor(self.timer)]:getWidth(),
                            8 / self.AnimationWarrior[math.floor(self.timer)]:getHeight())
    elseif self.type == "sorcerer" then
        love.graphics.draw(self.AnimationSorcerer[math.floor(self.timer)], self.x * 8, self.y * 8, 0,
                            8 / self.AnimationSorcerer[math.floor(self.timer)]:getWidth(),
                            8 / self.AnimationSorcerer[math.floor(self.timer)]:getHeight())
        if self.fireball.active then
            love.graphics.draw(self.sorcererFire, self.fireball.x * 8, self.fireball.y * 8, 0,
                                self.fireball.w / self.sorcererFire:getWidth(),
                                self.fireball.h / self.sorcererFire:getHeight())
        end
    end
end

function Enemy:left(isTest)
    if world[self.y][self.x - 1].t == 0 then
        if isTest then
            return true
        end
        self.x = self.x - 1
    end
    return false
end

function Enemy:right(isTest)
    if world[self.y][self.x + 1].t == 0 then
        if isTest then
            return true
        end
        self.x = self.x + 1
    end
    return false
end

function Enemy:up(isTest)
    if world[self.y - 1][self.x].t == 0 then
        if isTest then
            return true
        end
        self.y = self.y - 1
    end
    return false
end

function Enemy:down(isTest)
    if world[self.y + 1][self.x].t == 0 then
        if isTest then
            return true
        end
        self.y = self.y + 1
    end
    return false
end



function Enemy:pathfind(startX, startY, destX, destY, world)

    local gridSizeBonus = 10

    local sliceXmin = destX - gridSizeBonus
    local sliceXmax = startX + gridSizeBonus
    if startX < destX then
        sliceXmin = startX - gridSizeBonus
        sliceXmax = destX + gridSizeBonus
    end
    local sliceYmin = destY - gridSizeBonus
    local sliceYmax = startY + gridSizeBonus
    if startY < destY then
        sliceYmax = startY - gridSizeBonus
        sliceYmax = destY + gridSizeBonus
    end
    if sliceXmin < 1 then
        sliceXmin = 1
    end
    if sliceYmin < 1 then
        sliceYmin = 1
    end

    local grid = lume.slice(world, sliceYmin, sliceYmax)
    for y,v in ipairs(grid) do
        grid[y] = lume.slice(grid[y], sliceXmin, sliceXmax)
    end

    -- print(startX, startY)


    local selectedX = startX
    local selectedY = startY

    local iterations = 0
    local maxIterations = 200

    local lowestF = 0
    
    while iterations < maxIterations do
        if (math.abs(selectedX - destX) < 2) and (math.abs(selectedY - destY) < 2) then
            break
        end

        -- print(selectedX, selectedY)

        world[selectedY][selectedX].explored = true

        local gStart = 0
        local hStart = 0



        if world[selectedY][selectedX - 1].t == 0 then
            gStart = world[selectedY][selectedX - 1].g
            hStart = world[selectedY][selectedX - 1].h
            world[selectedY][selectedX - 1].g = math.abs(selectedX - 1 - startX) + math.abs(selectedY - startY)
            world[selectedY][selectedX - 1].h = math.abs(selectedX - 1 - destX) + math.abs(selectedY - destY)

            if ((world[selectedY][selectedX - 1].g + world[selectedY][selectedX - 1].h) < world[selectedY][selectedX - 1].f or (world[selectedY][selectedX - 1].f == 0)) and not world[selectedY][selectedX - 1].explored then
                world[selectedY][selectedX - 1].f = world[selectedY][selectedX - 1].g + world[selectedY][selectedX - 1].h
                world[selectedY][selectedX - 1].path = "right"
                -- print("left", world[selectedY][selectedX - 1].f, "g: " .. world[selectedY][selectedX - 1].g, "h: " .. world[selectedY][selectedX - 1].h)
            else
                world[selectedY][selectedX - 1].g = gStart
                world[selectedY][selectedX - 1].h = hStart
            end
        end


        if world[selectedY - 1][selectedX].t == 0 then
            gStart = world[selectedY - 1][selectedX].g
            hStart = world[selectedY - 1][selectedX].h
            world[selectedY - 1][selectedX].g = math.abs(selectedX - startX) + math.abs(selectedY - 1 - startY)
            world[selectedY - 1][selectedX].h = math.abs(selectedX - destX) + math.abs(selectedY - 1 - destY)

            if ((world[selectedY - 1][selectedX].g + world[selectedY - 1][selectedX].h) < world[selectedY - 1][selectedX].f or (world[selectedY - 1][selectedX].f == 0)) and not world[selectedY - 1][selectedX].explored then
                world[selectedY - 1][selectedX].f = world[selectedY - 1][selectedX].g + world[selectedY - 1][selectedX].h
                world[selectedY - 1][selectedX].path = "down"
                -- print("up", world[selectedY - 1][selectedX].f, "g: " .. world[selectedY - 1][selectedX].g, "h: " .. world[selectedY - 1][selectedX].h)
            else
                world[selectedY - 1][selectedX].g = gStart
                world[selectedY - 1][selectedX].h = hStart
            end
        end


        if world[selectedY][selectedX + 1].t == 0 then
            gStart = world[selectedY][selectedX + 1].g
            hStart = world[selectedY][selectedX + 1].h
            world[selectedY][selectedX + 1].g = math.abs(selectedX + 1 - startX) + math.abs(selectedY - startY)
            world[selectedY][selectedX + 1].h = math.abs(selectedX + 1 - destX) + math.abs(selectedY - destY)

            if ((world[selectedY][selectedX + 1].g + world[selectedY][selectedX + 1].h) < world[selectedY][selectedX + 1].f or (world[selectedY][selectedX + 1].f == 0)) and not world[selectedY][selectedX + 1].explored then
                world[selectedY][selectedX + 1].f = world[selectedY][selectedX + 1].g + world[selectedY][selectedX + 1].h
                world[selectedY][selectedX + 1].path = "left"
                -- print("right", world[selectedY][selectedX + 1].f)
            else
                world[selectedY][selectedX + 1].g = gStart
                world[selectedY][selectedX + 1].h = hStart
            end
        end


        if world[selectedY + 1][selectedX].t == 0 then
            gStart = world[selectedY + 1][selectedX].g
            hStart = world[selectedY + 1][selectedX].h
            world[selectedY + 1][selectedX].g = math.abs(selectedX - startX) + math.abs(selectedY + 1 - startY)
            world[selectedY + 1][selectedX].h = math.abs(selectedX - destX) + math.abs(selectedY + 1 - destY)

            if ((world[selectedY + 1][selectedX].g + world[selectedY + 1][selectedX].h) < world[selectedY + 1][selectedX].f or (world[selectedY + 1][selectedX].f == 0)) and not world[selectedY + 1][selectedX].explored then
                world[selectedY + 1][selectedX].f = world[selectedY + 1][selectedX].g + world[selectedY + 1][selectedX].h
                world[selectedY + 1][selectedX].path = "up"
                -- print("down", world[selectedY + 1][selectedX].f, "g: " .. world[selectedY + 1][selectedX].g, "h: " .. world[selectedY + 1][selectedX].h)
            else
                world[selectedY + 1][selectedX].g = gStart
                world[selectedY + 1][selectedX].h = hStart
            end
        end

        -- print()

        local lowestF = 0
        local lowestH = 0
        for y, v in ipairs(grid) do
            for x, w in ipairs(v) do
                if not (w.f == 0) and not w.explored then
                    if (w.f <= lowestF) or (lowestF == 0) then
                        if not (w.f == lowestF) or w.h <= lowestH then
                            lowestF = w.f
                            lowestH = w.h
                            selectedX = x + sliceXmin - 1
                            selectedY = y + sliceYmin - 1
                        end
                    end
                end
            end 
        end

        -- print("end:\nlowestF: " .. lowestF .."\nx: " .. selectedX .. "\ny: " .. selectedY)
        -- print()


        iterations = iterations + 1
    end

    local path = {}
    if iterations < maxIterations then
        -- print("aaaaaa")
        -- print(selectedX, selectedY, startX, startY)
        while (selectedX ~= startX) or (selectedY ~= startY) do
            local dir = world[selectedY][selectedX].path
            -- print(world[selectedY][selectedX].path)
            -- print(selectedX, selectedY)
            -- print("bbbbbbb")
            if dir == "left" then
                table.insert(path, 1, "right")
                selectedX = selectedX - 1
            elseif dir == "right" then
                table.insert(path, 1, "left")
                selectedX = selectedX + 1
            elseif dir == "up" then
                table.insert(path, 1, "down")
                selectedY = selectedY - 1
            else
                table.insert(path, 1, "up")
                selectedY = selectedY + 1
            end
        end
    end

    for y,v in ipairs(world) do
        for x, w in ipairs(v) do
            w.f = 0
            w.g = 0
            w.h = 0
            w.path = ""
            w.explored = false
        end
    end


    if iterations < maxIterations then
        local returnPath = {}
        for i=1, self.movePoints do
            table.insert(returnPath, path[i])
        end

        return returnPath
    else
        -- print("player coords: " .. player.x .. ", " .. player.y .. "\nenemy coords: " .. self.x .. ", " .. self.y .. "\nselected coords: " .. selectedX .. ", " .. selectedY)
        -- love.event.quit()
        return ""
    end
end