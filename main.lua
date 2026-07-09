local x = 40
local y = 60
local score = 0
local game_over = false
local show_restart = false
local show_restart_timer = 0
local show_restart_delay = 0.5
local enemies = {}
local enemy_spawn_timer = 0
local enemy_spawn_delay = 0.5

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

function _update(dt)
  if game_over then
    show_restart_timer = show_restart_timer - dt
    if show_restart_timer <= 0 then
      show_restart = not show_restart
      show_restart_timer = show_restart_delay
    end

    -- Reset the game
    if input.pressed(input.BTN1) then
      score = 0
      enemies = {}
      enemy_spawn_timer = 0
      x = 40
      y = 60
      game_over = false
    end
  end

  if input.held(input.LEFT) then
    x = x - 4
  end

  if input.held(input.RIGHT) then
    x = x + 4
  end

  if input.held(input.UP) then
    y = y - 4
  end

  if input.held(input.DOWN) then
    y = y + 4
  end

  -- Handle enemy spawn
  local padding = 5
  local min_speed = 2
  local max_speed = 5
  enemy_spawn_timer -= dt
  if enemy_spawn_timer <= 0 then
    table.insert(
      enemies,
      {
        x = usagi.GAME_W,
        y = math.random(padding, usagi.GAME_H - padding),
        speed = math.random(min_speed, max_speed)
      }
    )
    enemy_spawn_timer = enemy_spawn_delay
  end

  for i = 1, #enemies do
    local enemy = enemies[i]

    if util.circ_rect_overlap(
      { x = enemy.x, y = enemy.y, r = 8 },
      { x = x, y = y, h = 16, w = 16 }
    ) then
      game_over = true
    end

    enemy.x -= enemy.speed
  end

  for i = #enemies, 1, -1 do
    if enemies[i].x < -10 then
      table.remove(enemies, i);
      score = score + 1
    end
  end
end

function _draw(dt)
  gfx.clear(gfx.COLOR_BLACK)
  if game_over then
    gfx.text("Game Over", 130, 80, gfx.COLOR_WHITE)
    if show_restart then
      gfx.text("Press " .. input.mapping_for(input.BTN1) .. " to restart",
            110, 100, gfx.COLOR_WHITE)
    end
  else
    gfx.rect_fill(x, y, 16, 16, gfx.COLOR_BLUE)

    for i = 1, #enemies do
      local enemy = enemies[i]
      gfx.circ_fill(enemy.x, enemy.y, 8, gfx.COLOR_RED)
    end

    gfx.text("Score : " .. score, 8, 8, gfx.COLOR_WHITE)
  end
end
