Button = Object:extend()

Button.image = love.graphics.newImage("images/button.png")
Button.image2 = love.graphics.newImage("images/button2.png")

function Button:new(x, y, w, h, text, fn, ox, oy, image3)
    ox = ox or 0
    oy = oy or 0
    fn = fn or text
    self.rect = createRect(x, y, w, h, "static", 1)
    self.text = text
    self.fn = fn
    self.ox = ox
    self.oy = oy
    self.clicked = false
    self.image3 = image3
end

function Button:update(x, y, sel)
    if self.rect.fixture:testPoint(x, y) or sel then
        self.clicked = true
        if self.fn == "start" then
            fadeInOut(music.menu, "out", 1)
            startGameFx:play()
            -- love.timer.sleep(1.5)
            gamestate.switch(game)
        elseif self.fn == "quit" then
            love.event.quit()
        elseif self.fn == "resetGame" then
            resetGame()
        elseif self.fn == "controls" then
            gamestate.switch(controlsMenu)
        else
            return self.fn
        end
    else
        return "not clicked"
    end
end

function Button:draw(big)
    if self.image3 == nil then
        if big then
            love.graphics.setFont(font2)
        end
        if self.clicked then
            love.graphics.draw(self.image2, self.rect.body:getX() - self.rect.width / 2, self.rect.body:getY() - self.rect.height / 2, 0, self.rect.width / self.image:getWidth(), self.rect.height / self.image:getHeight())
            self.clicked = false
        else
            love.graphics.draw(self.image, self.rect.body:getX() - self.rect.width / 2, self.rect.body:getY() - self.rect.height / 2, 0, self.rect.width / self.image:getWidth(), self.rect.height / self.image:getHeight())
        end

        love.graphics.print(self.text, self.rect.body:getX() - self.rect.width / 2 + self.ox, self.rect.body:getY() - self.rect.height / 2 + self.oy)
        love.graphics.setFont(font)
    else
        love.graphics.draw(self.image3, self.rect.body:getX() - self.rect.width / 2, self.rect.body:getY() - self.rect.height / 2, 0, self.rect.width / self.image3:getWidth(), self.rect.height / self.image3:getHeight())
    end
end