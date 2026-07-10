local player_size = 16

local bullet_timer = 0
local bullet_delay = 0.2
local bullet_speed = 5
local bullet_width = 4
local bullet_height = 10

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
  State = {
    player = {
      x = usagi.GAME_W / 2 - player_size / 2,
      y = usagi.GAME_H - 60,
      bullets = {}
    }
  }
end

local function shoot()
  local shoot_y = State.player.y - bullet_height

  local new_bullets = {
    { x = State.player.x - bullet_width, y = shoot_y },
    { x = State.player.x + player_size / 2 - bullet_width / 2, y = shoot_y },
    { x = State.player.x + player_size, y = shoot_y }
  }
  table.insert(State.player.bullets, new_bullets[1])
  table.insert(State.player.bullets, new_bullets[2])
  table.insert(State.player.bullets, new_bullets[3])
end

local function update_bullets()
  for i = #State.player.bullets, 1, -1 do
    local bullet = State.player.bullets[i]

    for j = #enemies, 1, -1 do
      local enemy = enemies[j]
      if util.circ_rect_overlap(
        { x = enemy.x, y = enemy.y, r = 8 },
        { x = bullet.x, y = bullet.y, w = bullet_width, h = bullet_height }
      ) then
        table.remove(enemies, j)
        table.remove(State.player.bullets, i)
        break
      elseif bullet.y < 0 - bullet_height then
        table.remove(State.player.bullets, i)
        break
      end
    end

    bullet.y = bullet.y - bullet_speed
  end
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
      State.player.x = 40
      State.player.y = 60
      game_over = false
    end
  end

  if input.held(input.LEFT) then
    State.player.x = State.player.x - 4

    if State.player.x < 0 then
      State.player.x = 0
    end
  end

  if input.held(input.RIGHT) then
    State.player.x = State.player.x + 4

    if State.player.x > usagi.GAME_W - player_size then
      State.player.x = usagi.GAME_W - player_size
    end
  end

  if input.held(input.UP) then
    State.player.y =State.player. y - 4

    if State.player.y < 0 then
      State.player.y = 0
    end
  end

  if input.held(input.DOWN) then
    State.player.y = State.player.y + 4

    if State.player.y > usagi.GAME_H - player_size then
      State.player.y = usagi.GAME_H - player_size
    end
  end

  update_bullets()

  bullet_timer -= dt
  if input.held(input.BTN2) then
    if bullet_timer < 0 then
      shoot()
      bullet_timer = bullet_delay
    end
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
      { x = State.player.x, y = State.player.y, h = player_size, w = player_size }
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
    gfx.rect_fill(State.player.x, State.player.y, player_size, player_size, gfx.COLOR_BLUE)

    for i = 1, #enemies do
      local enemy = enemies[i]
      gfx.circ_fill(enemy.x, enemy.y, 8, gfx.COLOR_RED)
    end

    for i = 1, #State.player.bullets do
      local bullet = State.player.bullets[i]
      gfx.rect_fill(bullet.x, bullet.y, bullet_width, bullet_height, gfx.COLOR_LIGHT_GRAY)
    end

    gfx.text("Score : " .. score, 8, 8, gfx.COLOR_WHITE)
  end
end
