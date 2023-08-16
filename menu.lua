local menu = {}

function menu:enter()
    menu.buttons = {
        Button(love.graphics.getWidth() - 1550, 200, 400, 200, "Start!", "start", 50, 10),
        Button(love.graphics.getWidth() - 1550, 400, 400, 200, "Controls", "controls"),
        Button(love.graphics.getWidth() - 1450, 600, 600, 200, "Reset Game", "resetGame"),
        Button(love.graphics.getWidth() - 1550, 800, 400, 200, "Quit  :(", "quit", 50, 10),
    }

    bg = love.graphics.newImage("images/natyyr/background.png")
    hand = love.graphics.newImage("images/natyyr/hand_fire.png")
    handW = 200 * 4
    handH = 50 * 4

    selected = 1

    fadeInOut(music.menu, "in", 0.7)
end

function menu:update(dt)
end

function menu:draw()
    love.graphics.draw(bg, 0, 0, 0, love.graphics.getWidth() / bg:getWidth(), love.graphics.getHeight() / bg:getHeight())
    love.graphics.draw(hand, 5, menu.buttons[selected].rect.body:getY() - menu.buttons[selected].rect.height / 2, 0, handW / hand:getWidth(), handH / hand:getHeight())
    for i,v in ipairs(menu.buttons) do
        v:draw(true)
    end
end

function menu:keypressed(key)
    if key == 'return' then
        menu.buttons[selected]:update(0, 0, true)
    elseif key == 'escape' then
        love.event.quit()
    elseif key == "down" then
        if selected < #menu.buttons then
            selected = selected + 1
            buttonFx:play()
        end
    elseif key == "up" then
        if selected > 1 then
            selected = selected - 1
            buttonFx:play()
        end
    end
end

function menu:mousepressed(x, y, button)
    for i,v in ipairs(menu.buttons) do
        v:update(x, y)
    end
end

function menu:leave()
    for i,v in ipairs(menu.buttons) do
        v.rect.fixture:destroy()
    end
    lume.clear(menu.buttons)
end

return menu