Player = Object:extend()

function Player:new(T)
    self.x = T.x
    self.y = T.y
    world[self.y][self.x].t = 3

    self.moveImage1 = love.graphics.newImage("images/button.png")
    self.moveImage2 = love.graphics.newImage("images/button2.png")
    self.moveX = 0
    self.moveY = 0

    self.frames = {
        love.graphics.newImage("images/player1.png"),
        love.graphics.newImage("images/player2.png")
    }
    self.timer = 1

    self.selectFrames = {
        love.graphics.newImage("images/select1.png"),
        love.graphics.newImage("images/select2.png")
    }
    self.selectTimer = 1

    self.heartHalf = love.graphics.newImage("images/heartHalf.png")
    self.heartSize = 80


    self.inCombat = false

    self.turn = false

    self.enteredCombatOnce = false

    self.movePoints = 3
    self.movePointsMax = self.movePoints

    self.armor = 0

    self.actions = 1
    self.actionsMax = self.actions

    self.selected = {x = 0, y = 0, clicked = false}

    self.angle = 0

    self.moving = false
    self.moveTimer = 1
    self.moveIndex = 1
    self.path = {}

    self.speed = 1.2

    
    self.health = T.health--4
    self.maxHealth = 6

    self.delayTimer = 0
    self.delay = 0
    self.whatDelay = {what = {}, amount = 0}

    self.interacting = false
    self.interactingWith = ""

    self.xp = T.xp
    self.level = T.level
    self.levelUpXp = {
        30,
        80,
    }
    self.maxLevel = #self.levelUpXp + 1

    self.spells = {}


    self.spellSlotsMax = {
        1,
        0,
        0
    }


    self.spellSlots = T.spellSlots
    
    self.spells["firebolt"] = {
        level = 0,
        x = 0,
        y = 0,
        vx = 0,
        vy = 0,
        active = false,
        damage = 1,
        speed = 0.3,
        range = 7,
        targetX = 0,
        targetY = 0,
        w = 4,
        h = 4,

        image = love.graphics.newImage("images/fireball.png")
    }
    self.spells["cureWounds"] = {
        level = 1,
        amount = 1
    }
    self.spells["invisibility"] = {
        level = 2,
        duration = 10,
        timer = 0,
        active = false
    }
    self.spells["thunderwave"] = {
        level = 1,
        damage = 2,
        range = 3,
        active = false,
        radius = 0,
        speed = 50,

        image = love.graphics.newImage("images/thunderWave.png")
    }

    self.buttons = {
        Button(125, 250, 250, 150, "cure wounds\n      level: " .. self.spells["cureWounds"].level, "cure wounds", 0, 30),
        Button(125, 400, 250, 150, "thunderwave\n      level: " .. self.spells["thunderwave"].level, "thunderwave", 0, 30),
        Button(125, 550, 250, 150, "  invisibility\n      level: " .. self.spells["invisibility"].level, "invisibility", 0, 30),
        Button(125, 700, 250, 150, "firebolt\n level: " .. self.spells["firebolt"].level, "firebolt", 50, 30),

        Button(125, 850, 250, 150, "move", "move", 50, 0),

        Button(125, love.graphics.getHeight() - 200, 250, 150, "time", "time", 0, 0, love.graphics.newImage("images/Hourglass.png")),
        Button(375, love.graphics.getHeight() - 200, 250, 150, "short rest", "short", 40, 30),
        Button(625, love.graphics.getHeight() - 200, 250, 150, "long rest", "long", 40, 30),

        Button(love.graphics.getWidth() - 100, love.graphics.getHeight() - 200, 200, 200, "gear", "gear", 0, 0, love.graphics.newImage("images/Gear Icon.png")),
        Button(love.graphics.getWidth() - 300, love.graphics.getHeight() - 200, 200, 200, "save", "save", 50, 0),
        Button(love.graphics.getWidth() - 500, love.graphics.getHeight() - 200, 200, 200, "save &\nquit", "saveQuit", 50, 0),
        Button(love.graphics.getWidth() - 700, love.graphics.getHeight() - 200, 200, 200, "    save &\n    quit\nto desktop", "saveDesktop", 0, 0),

        Button(love.graphics.getWidth() - 125, 500, 250, 150, "end turn", "endTurn", 0, 0),
    }

    self.timeClicked = false
    self.gearClicked = false

    self.shortRestsMax = 2
    self.shortRests = T.shortRests


    self:levelUp(self.level)
end

function Player:update(dt)
    if self.health < 1 then
        gamestate.switch(menu)
    end

    if not (self.level >= self.maxLevel) and (self.xp >= self.levelUpXp[self.level]) then
        levelUpFx:play()
        self.level = self.level + 1
        self:levelUp(self.level)
        self.health = self.maxHealth
        for i,v in ipairs(self.spellSlotsMax) do
            self.spellSlots[i] = v
        end
    end


    self.timer = self.timer + dt * 6
    if self.timer >= 3 then
        self.timer = 1
    end

    self.selectTimer = self.selectTimer + dt * 4
    if self.selectTimer >= 3 then
        self.selectTimer = 1
    end

    if self.selected.clicked and (lume.distance(self.selected.x, self.selected.y, self.x, self.y) > 20) then
        self.selected.clicked = false
    end

    if self.interacting and ((math.abs(self.x - self.selected.x) + math.abs(self.y - self.selected.y)) <= 1) then
        if self.interactingWith == "lever" then
            for i,v in ipairs(levers) do
                if self.selected.x == v.x and (self.selected.y == v.y) then
                    v.activated = true
                    self.interacting = false
                end
            end
        end
    end

    if not self.moving then
        self.interacting = false
    end

    if self.spells["invisibility"].active then
        self.spells["invisibility"].timer = self.spells["invisibility"].timer + dt
        if self.spells["invisibility"].timer > self.spells["invisibility"].duration then
            self.spells["invisibility"].active = false
            self.spells["invisibility"].timer = 0
        end
    end


    if self.delay ~= 0 then
        self.delayTimer = self.delayTimer + dt
        if self.delayTimer >= self.delay then
            self.delayTimer = 0
            self.delay = 0

            if self.whatDelay.what == "heal" then
                self.health = self.health + self.whatDelay.amount
            end
        end


    elseif self.spells["thunderwave"].active then
        self.spells["thunderwave"].radius = self.spells["thunderwave"].radius + dt * self.spells["thunderwave"].speed
        if self.spells["thunderwave"].radius > ((self.spells["thunderwave"].range) * 8) + 10 then
            self.spells["thunderwave"].active = false
            self.spells["thunderwave"].radius = 0
        end

    elseif self.spells["firebolt"].active then
        self.spells["firebolt"].x = self.spells["firebolt"].x + self.spells["firebolt"].vx
        self.spells["firebolt"].y = self.spells["firebolt"].y + self.spells["firebolt"].vy

        if lume.distance(self.spells["firebolt"].x, self.spells["firebolt"].y, self.spells["firebolt"].targetX, self.spells["firebolt"].targetY) < 0.5 then
            self.spells["firebolt"].active = false

            for i,v in ipairs(enemies) do
                if (v.x == self.spells["firebolt"].targetX) and (v.y == self.spells["firebolt"].targetY) then
                    v.health = v.health - self.spells["firebolt"].damage

                    if lume.find(peopleInCombat, v) == nil then
                        table.insert(peopleInCombat, v)
                    end
                end
            end
        end

        if world[math.floor(self.spells["firebolt"].y)][math.floor(self.spells["firebolt"].x)].t == 1 then
            self.spells["firebolt"].active = false
        end

    elseif self.moving then
        self.moveTimer = self.moveTimer + dt

        if self.moveTimer > self.speed then
            if not (self.inCombat and self.movePoints < 1) then

                world[self.y][self.x].t = 0

                if self.path[self.moveIndex] == "left" then
                    self:left()
                elseif self.path[self.moveIndex] == "right" then
                    self:right()
                elseif self.path[self.moveIndex] == "up" then
                    self:up()
                elseif self.path[self.moveIndex] == "down" then
                    self:down()
                end

                world[self.y][self.x].t = 3
            end

            self.moveIndex = self.moveIndex + 1
            if self.moveIndex > #self.path then
                self.moveIndex = 1
                self.moving = false
                lume.clear(self.path)
            end

            self.moveTimer = 1
        end
    end

    if self.inCombat then
        if not self.enteredCombatOnce then
            table.insert(peopleInCombat, self)
            self.enteredCombatOnce = true
        end

        if not self.turn then
            self.movePoints = self.movePointsMax
            self.actions = self.actionsMax
        end
    else
        self.movePoints = self.movePointsMax
        self.enteredCombatOnce = false
        self.actions = self.actionsMax
    end
end

function Player:draw()
    if self.spells["invisibility"].active then
        love.graphics.setColor(1, 1, 1, 0.5)
    end
    love.graphics.draw(self.frames[math.floor(self.timer)], self.x * 8, self.y * 8, 0,
                        8 / self.frames[math.floor(self.timer)]:getWidth(),
                        8 / self.frames[math.floor(self.timer)]:getHeight())

    if self.spells["firebolt"].active then
        love.graphics.draw(self.spells["firebolt"].image, self.spells["firebolt"].x * 8, self.spells["firebolt"].y * 8, 0,
                            self.spells["firebolt"].w / self.spells["firebolt"].image:getWidth(),
                            self.spells["firebolt"].h / self.spells["firebolt"].image:getHeight())
    end

    if self.spells["thunderwave"].active then
        love.graphics.draw(self.spells["thunderwave"].image, 
                            self.x * 8 + 4 - self.spells["thunderwave"].radius / 2, 
                            self.y * 8 + 4 - self.spells["thunderwave"].radius / 2, 
                            0,
                            self.spells["thunderwave"].radius / self.spells["thunderwave"].image:getWidth(),
                            self.spells["thunderwave"].radius / self.spells["thunderwave"].image:getHeight())
    end

    if self.selected.clicked then
        love.graphics.draw(self.selectFrames[math.floor(self.selectTimer)], self.selected.x * 8, self.selected.y * 8, 0,
                            8 / self.selectFrames[math.floor(self.selectTimer)]:getWidth(),
                            8 / self.selectFrames[math.floor(self.selectTimer)]:getHeight())

        self.moveX = self.x
        self.moveY = self.y
        for i,v in ipairs(self.path) do
            if (not self.moving or (self.moving and (self.moveIndex <= i))) then
                if v == "left" then
                    self.moveX = self.moveX - 1
                elseif v == "right" then
                    self.moveX = self.moveX + 1
                elseif v == "up" then
                    self.moveY = self.moveY - 1
                elseif v == "down" then
                    self.moveY = self.moveY + 1
                end

                if self.inCombat and ((math.abs(self.x - self.moveX) + math.abs(self.y - self.moveY)) > self.movePoints) then
                    love.graphics.draw(self.moveImage2, self.moveX * 8, self.moveY * 8, 0, 8 / self.moveImage1:getWidth(), 8 / self.moveImage1:getHeight())
                else
                    love.graphics.draw(self.moveImage1, self.moveX * 8, self.moveY * 8, 0, 8 / self.moveImage2:getWidth(), 8 / self.moveImage2:getHeight())
                end
            end
        end
    end

    love.graphics.setColor(1, 1, 1)
end

function Player:drawUi(x, y)
    -- love.graphics.print(self.x .. ", " .. self.y .. "\nmovement points: " .. self.movePoints .. "/" .. self.movePointsMax .. "\nturn: " .. tostring(self.turn) .. "\nin combat: " .. tostring(self.inCombat) .. "\nselect x, y: " .. self.selected.x .. ", " .. self.selected.y .. "\nfps: " .. love.timer.getFPS() .. "\nhealth: " .. self.health .. " / " .. self.maxHealth .. "\nactions: " .. self.actions .. "\ninteracting: " .. tostring(self.interacting), 0, 100)
    for i=1,self.maxHealth do
        if i <= self.health then
            if i % 2 == 1 then
                love.graphics.draw(self.heartHalf, (self.heartSize) * (i - 1) + 5, 5, 0,
                                    self.heartSize / self.heartHalf:getWidth(),
                                    self.heartSize / self.heartHalf:getHeight())
            else
                love.graphics.draw(self.heartHalf, (self.heartSize) * (i - 1) + 5 + self.heartSize / 2, 5, 0,
                                    -(self.heartSize / self.heartHalf:getWidth()),
                                    self.heartSize / self.heartHalf:getHeight())
            end
        end
    end

    for i, v in ipairs(self.buttons) do
        if v.fn == "move" and self.selected.clicked and (world[self.selected.y][self.selected.x].t == 5) then
            v.text = "move,\ninteract"
        elseif v.fn == "move" then
            v.text = "move"
        end

        if (v.fn == "move") or (v.fn == "firebolt") then
            if self.selected.clicked then
                v:draw()
            end
        elseif v.fn == "time" then
            if not self.inCombat then
                v:draw()
            end
        elseif (v.fn == "short") or (v.fn == "long") then
            if self.timeClicked and not self.inCombat then
                v:draw()
            end
        elseif (v.fn == "save") or (v.fn == "saveQuit") or (v.fn == "saveDesktop") then
            if self.gearClicked then
                v:draw()
            end
        elseif v.fn == "endTurn" then
            if self.inCombat and self.turn then
                v:draw()
            end
        elseif v.fn == "invisibility" then
            if self.level > 2 then
                v:draw()
            end
        else
            v:draw()
        end
    end

    love.graphics.print("spell slots:", love.graphics.getWidth() - 400, 0)
    for i,v in ipairs(self.spellSlots) do
        love.graphics.print("level " .. i .. ":   " .. v, love.graphics.getWidth() - 400, 30 * (i + 1))
    end

    love.graphics.print("level: " .. self.level, 800, 0)
    love.graphics.print("xp: " .. self.xp, 1300, 0)

    if self.inCombat then
        love.graphics.print("move points available:  " .. self.movePoints, 800, 40)
        love.graphics.print("actions available:  " .. self.actions, 1300, 40)
    else
        love.graphics.print("short rests available:  " .. self.shortRests, love.graphics.getWidth() - 450, 200)
    end

    for i,v in ipairs(tutorials) do
        if collideTrigger(v, createTrigger(self.x, self.y, 1, 1)) then
            if v.what == "move" then
                love.graphics.print("move:  arrow keys\ninteract:  click lever then space", 800, 80)
            elseif v.what == "fight" then
                love.graphics.print("firebolt clicked space:  f\nmovement points are indicated at the top of the screen\nalong with remaining actions\nattacking costs an action\nend turn with enter\neverything will appear when combat begins", 800, 80)
            elseif v.what == "spells" then
                love.graphics.print("higher level spells like thunderwave cost spell slots\nyour spell slots are indicated at the top right of the screen  --<\n >-- cast spells with these buttons", 800, 80)
            elseif v.what == "rest" then
                love.graphics.print("rest:  click the hourglass and select a rest option\nshort rest:  recover half your max health\nlong rest:  recover all your spell slots and all your health, \nbut enemies respawn", 800, 80)
            end
        end
    end

    -- love.graphics.print("fps: " .. love.timer.getFPS(), 1000, 1000)
end

function Player:mousepressed(x, y, button)
    local returnValue = "not clicked"
    for i, v in ipairs(self.buttons) do
        returnValue = v:update(x, y)
        if returnValue ~= "not clicked" then
            break
        end
    end

    if returnValue == "move" then
        self:move()

    elseif returnValue == "cure wounds" and (self.actions > 0) then
        self:castSpell("cureWounds", self.selected.x, self.selected.y)
    elseif returnValue == "thunderwave" and (self.actions > 0) then
        self:castSpell("thunderwave", self.selected.x, self.selected.y)
    elseif returnValue == "firebolt" and (self.actions > 0) and self.selected.clicked then
        self:castSpell("firebolt", self.selected.x, self.selected.y)
    elseif returnValue == "invisibility" and (self.actions > 0) and (self.level > 2) then
        self:castSpell("invisibility", self.selected.x, self.selected.y)

    elseif returnValue == "time" and not self.inCombat then
        self.timeClicked = not self.timeClicked
    elseif returnValue == "short" and not self.inCombat and self.timeClicked and (self.shortRests > 0) then
        self:heal(math.floor(self.maxHealth / 2))
        restFx:play()
        self.shortRests = self.shortRests - 1
    elseif returnValue == "long" and not self.inCombat and self.timeClicked then
        restFx:play()
        self.health = self.maxHealth
        for i,v in ipairs(self.spellSlots) do
            self.spellSlots[i] = self.spellSlotsMax[i]
        end
        self.shortRests = self.shortRestsMax
        respawnEnemies(map)

    elseif returnValue == "gear" then
        self.gearClicked = not self.gearClicked
    elseif returnValue == "save" and self.gearClicked then
        saveGame()
    elseif returnValue == "saveQuit" and self.gearClicked then
        saveGame()
        gamestate.switch(menu)
    elseif returnValue == "saveDesktop" and self.gearClicked then
        saveGame()
        love.event.quit()

    elseif returnValue == "endTurn" and self.inCombat and self.turn then
        turn = turn + 1
    end

    if returnValue == "not clicked" then
        x, y = cam:worldCoords(x, y)

        if math.floor(x / 8) < 1 then
            x = 8
        elseif math.floor(x / 8 * cam.scale) > (mapWidth - 8) then
            x = mapWidth - 16
        end
        if math.floor(y / 8) < 1 then
            y = 8
        elseif math.floor(y / 8 * cam.scale) > (mapHeight - 8) then
            y = mapHeight - 16
        end
        
        if (self.selected.x == math.floor(x / 8)) and (self.selected.y == math.floor(y / 8)) and self.selected.clicked then
            self.selected.clicked = false
        else
            self.selected.x = math.floor(x / 8)
            self.selected.y = math.floor(y / 8)
            self.selected.clicked = true
        end

        if self.selected.clicked then
            if world[self.selected.y][self.selected.x].t ~= 0 then
                self.path = self:pathfind(self.x, self.y, self.selected.x, self.selected.y, world, true)
            else
                self.path = self:pathfind(self.x, self.y, self.selected.x, self.selected.y, world)
            end

            if button == 2 then
                self:move()
            end
        end
    end
end

function Player:keypressed(key)
    if self.delay == 0 then
        if (not self.inCombat or (self.movePoints > 0)) and not self.spells["firebolt"].active then
            if key == "left" then
                world[self.y][self.x].t = 0
                self:left()
                world[self.y][self.x].t = 3
            elseif key == "right" then
                world[self.y][self.x].t = 0
                self:right()
                world[self.y][self.x].t = 3
            elseif key == "up" then
                world[self.y][self.x].t = 0
                self:up()
                world[self.y][self.x].t = 3
            elseif key == "down" then
                world[self.y][self.x].t = 0
                self:down()
                world[self.y][self.x].t = 3
            end
        end

        if (key == "space") and self.selected.clicked then
            self:move()

        elseif (key == "f") and self.selected.clicked and (self.actions > 0) then
            self:castSpell("firebolt", self.selected.x, self.selected.y)
        
        elseif (key == "c") and (self.actions > 0) then
            self:castSpell("cureWounds", self.selected.x, self.selected.y)

        elseif (key == "x") and (self.actions > 0) then
            self:castSpell("thunderwave", self.selected.x, self.selected.y)

        elseif (key == "i") and (self.actions > 0) and (self.level > 2) then
            self:castSpell("invisibility", self.selected.x, self.selected.y)

        elseif key == "return" then
            turn = turn + 1
        end
    end
end

function Player:left()
    if world[self.y][self.x - 1].t == 0 then
        self.x = self.x - 1
        if self.inCombat then
            self.movePoints = self.movePoints - 1
        end

        if not self.moving then
            if self.selected.clicked then
                if world[self.selected.y][self.selected.x].t ~= 0 then
                    self.path = self:pathfind(self.x, self.y, self.selected.x, self.selected.y, world, true)
                else
                    self.path = self:pathfind(self.x, self.y, self.selected.x, self.selected.y, world)
                end
            end
        end
    end
end

function Player:right()
    if world[self.y][self.x + 1].t == 0 then
        self.x = self.x + 1
        if self.inCombat then
            self.movePoints = self.movePoints - 1
        end

        if not self.moving then
            if self.selected.clicked then
                if world[self.selected.y][self.selected.x].t ~= 0 then
                    self.path = self:pathfind(self.x, self.y, self.selected.x, self.selected.y, world, true)
                else
                    self.path = self:pathfind(self.x, self.y, self.selected.x, self.selected.y, world)
                end
            end
        end
    end
end

function Player:up()
    if world[self.y - 1][self.x].t == 0 then
        self.y = self.y - 1
        if self.inCombat then
            self.movePoints = self.movePoints - 1
        end

        if not self.moving then
            if self.selected.clicked then
                if world[self.selected.y][self.selected.x].t ~= 0 then
                    self.path = self:pathfind(self.x, self.y, self.selected.x, self.selected.y, world, true)
                else
                    self.path = self:pathfind(self.x, self.y, self.selected.x, self.selected.y, world)
                end
            end
        end
    end
end

function Player:down()
    if world[self.y + 1][self.x].t == 0 then
        self.y = self.y + 1
        if self.inCombat then
            self.movePoints = self.movePoints - 1
        end

        if not self.moving then
            if self.selected.clicked then
                if world[self.selected.y][self.selected.x].t ~= 0 then
                    self.path = self:pathfind(self.x, self.y, self.selected.x, self.selected.y, world, true)
                else
                    self.path = self:pathfind(self.x, self.y, self.selected.x, self.selected.y, world)
                end
            end
        end
    end
end

function Player:move()
    if self.moving then
        self.moving = false
        lume.clear(self.path)
        self.selected.clicked = false
        self.moveIndex = 1
    else
        self.moving = true

        if world[self.selected.y][self.selected.x].t == 5 then
            self.interacting = true
            self.interactingWith = "lever"
        end
    end
end

function Player:heal(amount)
    self.health = self.health + amount
    if self.health > self.maxHealth then
        self.health = self.maxHealth
    end
end

function Player:castSpell(spell, x, y)
    self.spells["invisibility"].active = false

    if spell == "firebolt" and (lume.distance(self.x, self.y, x, y) < self.spells["firebolt"].range) then
        self.spells["firebolt"].active = true
        self.spells["firebolt"].targetX = x
        self.spells["firebolt"].targetY = y
        self.spells["firebolt"].x = self.x
        self.spells["firebolt"].y = self.y
        self.spells["firebolt"].vx, self.spells["firebolt"].vy = lume.vector(lume.angle(self.spells["firebolt"].x, self.spells["firebolt"].y, x, y), self.spells["firebolt"].speed)

        fireboltFx:play()

        if self.inCombat then
            self.actions = self.actions - 1
        end
    elseif spell == "cureWounds" then
        if self.health < self.maxHealth then
            if self.spellSlots[self.spells["cureWounds"].level] > 0 then
                self.spellSlots[self.spells["cureWounds"].level] = self.spellSlots[self.spells["cureWounds"].level] - 1

                cureWoundsFx:play()
                self.delay = 0.8
                self.whatDelay.what = "heal"
                self.whatDelay.amount = 1

                if self.inCombat then
                    self.actions = self.actions - 1
                end
            end
        end
    elseif spell == "thunderwave" then
        if self.spellSlots[self.spells["thunderwave"].level] > 0 then
            self.spellSlots[self.spells["thunderwave"].level] = self.spellSlots[self.spells["thunderwave"].level] - 1

            thunderwaveFx:play()

            for i,v in ipairs(enemies) do
                if lume.distance(self.x, self.y, v.x, v.y) < self.spells["thunderwave"].range then
                    v.health = v.health - self.spells["thunderwave"].damage
                end
            end

            self.spells["thunderwave"].active = true

            if self.inCombat then
                self.actions = self.actions - 1
            end
        end
    elseif spell == "invisibility" then
        if self.spellSlots[self.spells["invisibility"].level] > 0 then
            self.spellSlots[self.spells["invisibility"].level] = self.spellSlots[self.spells["invisibility"].level] - 1

            self.spells["invisibility"].active = true
        end
    end
end


function Player:levelUp(level)
    if level == 2 then
        self.maxHealth = 8
        self.spellSlotsMax[1] = 2
    elseif level == 3 then
        self.maxHealth = 10
        self.spellSlotsMax[1] = 2
        self.spellSlotsMax[2] = 1
    end
end



function Player:pathfind(startX, startY, destX, destY, world, adj)

    local gridSizeBonus = 20

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
        if not adj then
            if (selectedX == destX) and (selectedY == destY) then
                break
            end
        else
            if ((math.abs(selectedX - destX) + math.abs(selectedY - destY)) <= 1) then
                break
            end
        end

        -- print(selectedX, selectedY)

        world[selectedY][selectedX].explored = true

        local gStart = 0
        local hStart = 0



        if world[selectedY][selectedX - 1].t == 0 then
            gStart = world[selectedY][selectedX - 1].g
            hStart = world[selectedY][selectedX - 1].h
            world[selectedY][selectedX - 1].g = world[selectedY][selectedX].g + 1
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
            world[selectedY - 1][selectedX].g = world[selectedY][selectedX].g + 1
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
            world[selectedY][selectedX + 1].g = world[selectedY][selectedX].g + 1
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
            world[selectedY + 1][selectedX].g = world[selectedY][selectedX].g + 1
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

        -- print("x:", selectedX, "y:", selectedY)

        -- print()

        local lowestF = 0
        local lowestH = 0
        for y, v in ipairs(grid) do
            for x, w in ipairs(v) do
                if not (w.f == 0) and not w.explored then
                    if (w.f <= lowestF) or (lowestF == 0) then
                        if (not (w.f == lowestF)) or w.h <= lowestH then
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
        return path
    else
        -- print("player coords: " .. player.x .. ", " .. player.y .. "\nenemy coords: " .. self.x .. ", " .. self.y .. "\nselected coords: " .. selectedX .. ", " .. selectedY)
        -- love.event.quit()
        return {}
    end
end