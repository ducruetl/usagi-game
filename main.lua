function _config()
    ---@type Usagi.Config
    return { name = "Game", game_id = "com.usagiengine.YOURGAMENAME" }
end

function _init()
    -- Live reload preserves globals across saved edits but resets locals.
    -- Stash mutable game state in a capitalized global like `State` so it
    -- survives reloads; F5 calls _init again to reset.
    State = {}
end

local x = 0
local y = 0

function _update(dt)
    if input.key_held(input.KEY_W) then y = y - 1 end
    if input.key_held(input.KEY_S) then y = y + 1 end
    if input.key_held(input.KEY_A) then x = x - 1 end
    if input.key_held(input.KEY_D) then x = x + 1 end
end

function _draw(dt)
    gfx.clear(gfx.COLOR_BLACK)
    gfx.text("Hello, Usagi!", 10, 10, gfx.COLOR_WHITE)
    gfx.rect_fill(x, y, 16, 16, gfx.COLOR_BLUE)
end
