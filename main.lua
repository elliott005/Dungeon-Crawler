Object = require "libraries.classic" -- importer des librairies
lume = require "libraries.lume"
gamestate = require "libraries.gamestate"
sti = require "libraries.sti"
camera = require "libraries.camera"
tween = require "libraries.tween"


require "Player"
require "Enemy"
require "Button"
require "Lever"
require "Door"

menu = require "menu"
game = require "game"
controlsMenu = require "controlsMenu"


local windowWidth, windowHeight = love.window.getDesktopDimensions()
love.window.setMode(windowWidth, windowHeight)

font = love.graphics.newFont("game_over.ttf", 100) -- importer un font
font2 = love.graphics.newFont("game_over.ttf", 270)
love.graphics.setFont(font)

love.window.setTitle("Dungeon Crawler!")

startGameFx = love.audio.newSource("sound/startGame.wav", "static")
cureWoundsFx = love.audio.newSource("sound/cureWounds.wav", "static")
fireboltFx = love.audio.newSource("sound/fireBolt.wav", "static")
thunderwaveFx = love.audio.newSource("sound/thunderWave.wav", "static")
restFx = love.audio.newSource("sound/rest.wav", "static")
levelUpFx = love.audio.newSource("sound/chipquest.wav", "static")
buttonFx = love.audio.newSource("sound/click_002.ogg", "static")

music = {
    menu = love.audio.newSource("sound/Epic.mp3", "stream"),
    main = love.audio.newSource("sound/mainTheme.mp3", "stream"),
    battle = love.audio.newSource("sound/8BitBattleLoop.ogg", "stream")
}

music.menu:setLooping(true)
music.main:setLooping(true)
music.battle:setLooping(true)

data = {}

function love.load()
    savedata = "savedata.txt"


    physicsWorld = love.physics.newWorld(0, 0, true)

    love.math.setRandomSeed(os.time())

    cam = camera(0, 0, 8)

    fadeInTimer = 0
    fadeOutTimer = 1
    fadeIn = nil
    fadeOut = nil
    fadeInSpeed = 1
    fadeOutSpeed = 1

    gamestate.registerEvents()
    gamestate.switch(menu)

    mapWidth = 60 * 8
    mapHeight = mapWidth

    map = sti("maps/mapTest.lua")

    enemies = {}
    levers = {}
    doors = {}

    tutorials = {}

    world = {}
    for y = 0, mapHeight / 8 do
        world[y] = {}
        for x = 0, mapHeight / 8 do
            world[y][x] = {t = 0, g = 0, h = 0, f = 0, path = "", explored = false}
        end
    end
end

function love.update(dt)
    if fadeIn ~= nil then
        fadeInTimer = fadeInTimer + dt * fadeInSpeed
        fadeIn:setVolume(fadeInTimer)
        if fadeInTimer > 1 then
            fadeIn = nil
        end
    end
    if fadeOut ~= nil then
        fadeOutTimer = fadeOutTimer - dt * fadeOutSpeed
        fadeOut:setVolume(fadeOutTimer)
        if fadeOutTimer < 0 then
            fadeOut:stop()
            fadeOut = nil
        end
    end
end

function love.draw()
end

function love.keypressed(key)
    
end



function collideTrigger(trig1, trig2)
    return (trig1.x + trig1.w > trig2.x) and (trig1.x < (trig2.x + trig2.w)) and (trig1.y + trig1.h > trig2.y) and (trig1.y < (trig2.y + trig2.h))
end

function createTrigger(x, y, w, h)
    return {x = x, y = y, w = w, h = h}
end



function stopMusic()
    for k,v in pairs(music) do
        v:stop()
    end
end

function fadeInOut(source, which, speed)
    if which == "in" then
        fadeIn = source
        fadeIn:play()
        fadeInTimer = 0
        fadeInSpeed = speed
    elseif which == "out" then
        fadeOut = source
        fadeOutTimer = 1
        fadeOutSpeed = speed
    end
end

function respawnEnemies(map)
    for i,v in ipairs(enemies) do
        world[v.y][v.x].t = 0
    end
    lume.clear(enemies)

    spawnEnemies(map)
end


function createRect(x, y, w, h, t, d, mask) -- x:Xpos, y:Ypos, w:Width, h:Height, t:Type("static", "dynamic"), d:Density, mask:setMask
    local mask = mask or 16
    local rect = {
    body = love.physics.newBody( physicsWorld, x, y, t ),
    shape = love.physics.newRectangleShape(w, h),
    }
    rect.width = w
    rect.height = h 
    rect.fixture = love.physics.newFixture( rect.body, rect.shape, d )
    rect.fixture:setMask(mask)
    return rect
end


function spawnEnemies(map) 
    if map.layers["Bats"] then
        for i, obj in pairs(map.layers["Bats"].objects) do
            local x = obj.x / 8
            local y = obj.y / 8
            table.insert(enemies, Enemy(x, y, "bat"))
            world[y][x].t = 2
        end
    end

    if map.layers["Warriors"] then
        for i, obj in pairs(map.layers["Warriors"].objects) do
            local x = obj.x / 8
            local y = obj.y / 8
            table.insert(enemies, Enemy(x, y, "warrior"))
            world[y][x].t = 2
        end
    end

    if map.layers["Sorcerers"] then
        for i, obj in pairs(map.layers["Sorcerers"].objects) do
            local x = obj.x / 8
            local y = obj.y / 8
            table.insert(enemies, Enemy(x, y, "sorcerer"))
            world[y][x].t = 2
        end
    end
end

function createWorld(map)
    if map.layers["Walls"] then
        for i, obj in pairs(map.layers["Walls"].objects) do
            for ox = 0, obj.width - 1, 8 do
                for oy = 0, obj.height - 1, 8 do 
                    local x = (obj.x + ox) / 8
                    local y = (obj.y + oy) / 8
                    world[y][x].t = 1
                end
            end
        end
    end

    spawnEnemies(map)

    if map.layers["Levers"] then
        for i, obj in pairs(map.layers["Levers"].objects) do
            local x = obj.x / 8
            local y = obj.y / 8
            table.insert(levers, Lever(x, y, obj.name))
        end
    end

    if map.layers["Doors"] then
        for i, obj in pairs(map.layers["Doors"].objects) do
            local x = obj.x / 8
            local y = obj.y / 8
            table.insert(doors, Door(x, y, obj.name))
        end
    end

    if map.layers["Tutorials"] then
        for i, obj in pairs(map.layers["Tutorials"].objects) do
            local x = obj.x / 8
            local y = obj.y / 8
            local w = obj.width / 8
            local h = obj.height / 8
            table.insert(tutorials, {x = x, y = y, w = w, h = h, what = obj.name})
        end
    end
end



function drawChunk1(v)
    if v.layers["Ground"] then
        v:drawLayer(v.layers["Ground"])
    end
    if v.layers["Objects"] then
        v:drawLayer(v.layers["Objects"])
    end
end

function drawChunk2(v)
    if v.layers["Objects2"] then
        v:drawLayer(v.layers["Objects2"])
    end
end

function saveGame()
    data.player = {
        x = player.x,
        y = player.y,
        health = player.health,
        spellSlots = {player.spellSlots[1], player.spellSlots[2], player.spellSlots[3]},
        shortRests = player.shortRests,
        level = player.level,
        xp = player.xp
    }

    data.enemies = {}
    for i,v in ipairs(enemies) do
        table.insert(data.enemies, {startX = v.startX, startY = v.startY})
    end

    data.doors = {}
    for i,v in ipairs(doors) do
        table.insert(data.doors, {x = v.x, y = v.y, state = v.state})
    end

    data.levers = {}
    for i,v in ipairs(levers) do
        table.insert(data.levers, {x = v.x, y = v.y, state = v.state})
    end

    serialized = lume.serialize(data)
    love.filesystem.write(savedata, serialized)
end

function resetGame()
    love.filesystem.remove(savedata)
    love.event.quit("restart")
end