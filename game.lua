local game = {}

function game:enter()
    createWorld(map)

    if love.filesystem.getInfo(savedata) then
        file = love.filesystem.read(savedata)
        data = lume.deserialize(file)

        player = Player(data.player)

        for i=#enemies, 1, -1 do
            local same = false
            for j,w in ipairs(data.enemies) do
                if (enemies[i].startX == w.startX) and (enemies[i].startY == w.startY) then
                    same = true
                end
            end
            if not same then
                world[enemies[i].y][enemies[i].x].t = 0
                table.remove(enemies, i)
            end
        end

        for i,v in ipairs(doors) do
            for j,w in ipairs(data.doors) do
                if (v.x == w.x) and (v.y == w.y) then
                    v.state = w.state
                end
            end
        end

        for i,v in ipairs(levers) do
            for j,w in ipairs(data.levers) do
                if (v.x == w.x) and (v.y == w.y) then
                    v.state = w.state
                end
            end
        end
    else
        player = Player({x = 3, y = mapHeight / 8 - 2, health = 10, spellSlots = {1, 0, 0}, shortRests = 2, level = 1, xp = 0})
    end

    peopleInCombat = {}
    turn = 1

    aggroRange = 5

    brightnessShader = love.graphics.newShader[[
    vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
        vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
        return pixel * color * 1.7;
    }
    ]]
    love.graphics.setShader(brightnessShader)


    -- shading radius
    lightRadius = 25
    radius = 20

    fadeInOut(music.main, "in", 0.3)
    -- music.main:play()

    stopBattleMusicOnce = false

    blasts = {}
    blastsTweens = {}
end

function game:update(dt)
    for i,v in ipairs(enemies) do
        if lume.distance(v.x, v.y, player.x, player.y) < aggroRange then
            if lume.find(peopleInCombat, v) == nil then
                table.insert(peopleInCombat, v)
            end
        elseif lume.distance(v.x, v.y, player.x, player.y) > aggroRange * 2 then
            lume.remove(peopleInCombat, v)
        end
    end

    if player.spells["invisibility"].active then
        player.inCombat = false
        lume.clear(peopleInCombat)
    end

    if turn > #peopleInCombat then
        turn = 1
    end

    if #peopleInCombat > 0 then
        if not music.battle:isPlaying() then
            fadeInOut(music.battle, "in", 0.5)
            fadeInOut(music.main, "out", 0.5)
        end
        player.inCombat = true
        peopleInCombat[turn].turn = true
        for i,v in ipairs(peopleInCombat) do
            if not (i == turn) then
                v.turn = false
            end
        end
    else
        player.inCombat = false
    end

    player:update(dt)

    for i=#enemies, 1, -1 do
        if enemies[i].health < 1 then
            player.xp = player.xp + enemies[i].xp
            world[enemies[i].y][enemies[i].x].t = 0
            lume.remove(peopleInCombat, enemies[i])
            table.insert(blasts, {r = 0, a = 1, x = enemies[i].x + 0.5, y = enemies[i].y + 0.5})
            table.insert(blastsTweens, tween.new(0.5, blasts[#blasts], {r = 16, a = 0, x = enemies[i].x + 0.5, y = enemies[i].y + 0.5}, "linear"))
            table.remove(enemies, i)
        else
            enemies[i]:update(dt)
        end
    end

    if #peopleInCombat < 2 then
        player.inCombat = false
        lume.remove(peopleInCombat, player)

        if music.battle:isPlaying() and not stopBattleMusicOnce then
            fadeInOut(music.battle, "out", 0.5)
            fadeInOut(music.main, "in", 0.5)
            stopBattleMusicOnce = true
        end
    else
        stopBattleMusicOnce = false
    end


    for i,v in ipairs(doors) do
        v:update(dt)
    end

    for i,v in ipairs(levers) do
        v:update(dt)
    end

    for i,v in ipairs(blastsTweens) do
        local complete = v:update(dt)
        if complete then
            table.remove(blasts, i)
            table.remove(blastsTweens, i)
        end
    end


    cam:lookAt(player.x * 8, player.y * 8)
end

function game:draw()
    cam:attach()

        drawChunk1(map)

        player:draw()

        drawChunk2(map)

        for i,v in ipairs(enemies) do
            v:draw()
        end

        for i,v in ipairs(doors) do
            v:draw()
        end

        for i,v in ipairs(levers) do
            v:draw()
        end

        for y = player.y - radius, player.y + radius do
            for x = player.x - radius, player.x + radius do
                love.graphics.setColor(0, 0, 0, lume.distance(x, y, player.x, player.y) / lightRadius)
                love.graphics.rectangle("fill", x * 8, y * 8, 8, 8)
            end
        end

        for i,v in ipairs(blasts) do
            love.graphics.setColor(1, 1, 1, v.a)
            love.graphics.circle("fill", v.x * 8, v.y * 8, v.r)
        end

        love.graphics.setColor(1, 1, 1)

        -- for y = 1, 10 do
        --     for x = 1, 10 do
        --         if world[y][x] == 1 then
        --             love.graphics.rectangle("fill", x * 8, y * 8, 8, 8)
        --         end
        --     end
        -- end

    cam:detach()

    player:drawUi(0, 0)
end

function game:mousepressed(x, y, button)
    player:mousepressed(x, y, button)
end

function game:keypressed(key)
    if not player.inCombat or player.turn then
        player:keypressed(key)
    end
    if key == 'escape' then
        saveGame()
        gamestate.switch(menu)
    end
end

function game:leave()
    lume.clear(enemies)
    lume.clear(doors)
    lume.clear(levers)
    for y,v in ipairs(world) do
        for x, w in ipairs(v) do
            w.t = 0
            w.f = 0
            w.g = 0
            w.h = 0
            w.path = ""
            w.explored = false
        end
    end

    love.graphics.setShader()

    stopMusic()
end

return game