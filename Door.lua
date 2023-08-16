Door = Object:extend()

Door.frames = {}

for i=1,4 do
    table.insert(Door.frames, love.graphics.newImage("images/door" .. i .. ".png"))
end

function Door:new(x, y, link)
    self.x = x
    self.y = y
    self.link = tonumber(link)

    self.state = "closed"

    self.timer = 1

    world[self.y][self.x].t = 4
end

function Door:update(dt)
    if self.state == "opening" then
        self.timer = self.timer + dt * 3
        if self.timer >= 5 then
            self.timer = 4.9
            self.state = "open"
            world[self.y][self.x].t = 0
        end
    elseif self.state == "closing" then
        self.timer = self.timer - dt * 3
        if self.timer <= 1 then
            self.timer = 1
            self.state = "closed"
            world[self.y][self.x].t = 4
        end
    elseif self.state == "closed" then
        world[self.y][self.x].t = 4
    else
        world[self.y][self.x].t = 0
    end
end

function Door:draw()
    if self.state == "closed" then
        love.graphics.draw(self.frames[1], self.x * 8, self.y * 8, 0, 
                            8 / self.frames[1]:getWidth(),
                            8 / self.frames[1]:getHeight())
    elseif self.state == "opening" or (self.state == "closing") then
        love.graphics.draw(self.frames[math.floor(self.timer)], self.x * 8, self.y * 8, 0, 
                            8 / self.frames[math.floor(self.timer)]:getWidth(),
                            8 / self.frames[math.floor(self.timer)]:getHeight())
    else
        love.graphics.draw(self.frames[4], self.x * 8, self.y * 8, 0, 
                            8 / self.frames[4]:getWidth(),
                            8 / self.frames[4]:getHeight())
    end
end