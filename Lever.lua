Lever = Object:extend()

Lever.frames = {}

for i=1,3 do
    table.insert(Lever.frames, love.graphics.newImage("images/lever" .. i .. ".png"))
end

function Lever:new(x, y, link)
    self.x = x
    self.y = y
    self.link = tonumber(link)

    self.state = "up"

    world[self.y][self.x].t = 5

    self.activated = false
end

function Lever:update(dt)
    if self.activated then
        if self.state == "right" then
            self.state = "up"
            for i,v in ipairs(doors) do
                if v.link == self.link then
                    v.state = "closing"
                end
            end
            self.activated = false
        else
            self.state = "right"
            for i,v in ipairs(doors) do
                if v.link == self.link then
                    v.state = "opening"
                end
            end
            self.activated = false
        end
    end
end

function Lever:draw()
    if self.state == "left" then
        love.graphics.draw(self.frames[1], self.x * 8, self.y * 8, 0, 
                            8 / self.frames[1]:getWidth(),
                            8 / self.frames[1]:getHeight())
    elseif self.state == "up" then
        love.graphics.draw(self.frames[2], self.x * 8, self.y * 8, 0, 
                            8 / self.frames[2]:getWidth(),
                            8 / self.frames[2]:getHeight())
    else
        love.graphics.draw(self.frames[3], self.x * 8, self.y * 8, 0, 
                            8 / self.frames[3]:getWidth(),
                            8 / self.frames[3]:getHeight())
    end
end