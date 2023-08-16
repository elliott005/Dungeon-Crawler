local controlsMenu = {}

function controlsMenu:draw()
    love.graphics.print("move: arrow keys\nreturn: escape\ntarget: click\nmove to target/interact: space\nfirebolt target: f\ncure wounds: c\nthunderwave: x\ninvisibility: i\nend turn: enter", font, 100, 100)
end

function controlsMenu:keypressed(key)
    if key == 'escape' then
        gamestate.switch(menu)
    end
end

return controlsMenu