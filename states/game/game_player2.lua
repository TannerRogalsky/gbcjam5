local Player2 = Game:addState('Player2')

function worldRayCastCallback(fixture, x, y, xn, yn, fraction)
  table.insert(game.hits, {
    object = fixture:getUserData(),
    x = x,
    y = y,
    xn = xn,
    yn = yn,
    fraction = fraction
  })
  return 1
end

local function allReceptorsFull(receptors)
  for i,receptor in ipairs(receptors) do
    if receptor.charge_ratio ~= 1 then
      return false
    end
  end
  return true
end

function Player2:enteredState()
  local Camera = require("lib/camera")
  self.camera = Camera:new()

  self.world = love.physics.newWorld(0, 0, true)

  self.num_players = 2
  self.player_index = 1

  local w, h = g.getDimensions()
  local level = {
    lights = {
      {w * 0.1, h * 0.5, -math.pi / 4},
      {w * 0.9, h * 0.5, math.pi / 4 * 3},
    },
    receptors = {
      {w * 0.5, h * 0.1, 50, 50, 0, 255, 255, 0},
      {w * 0.1, h * 0.9, 50, 50, math.pi * 1.25, 255, 0, 255},
      {w * 0.9, h * 0.9, 50, 50, -math.pi * 1.25, 0, 255, 255},
    },
    mirrors = {},
    prisms = {
      {w * 0.5, h * 0.5, 50, math.pi / 2}
    },
  }

  self.lights = {}
  for i,light_data in ipairs(level.lights) do
    self.lights[i] = LightSource:new(unpack(light_data))
    self.lights[i].name = "Player " .. i
  end

  self.receptors = {}
  for i,receptor_data in ipairs(level.receptors) do
    self.receptors[i] = Receptor:new(unpack(receptor_data))
  end

  self.mirrors = {}
  for i,mirror_data in ipairs(level.mirrors) do
    self.mirrors[i] = Mirror:new(unpack(mirror_data))
  end
  self.player_mirrors = {}

  self.prisms = {}
  for i,prism_data in ipairs(level.prisms) do
    self.prisms[i] = Prism:new(unpack(prism_data))
  end

  self.rays = {}

  self.mousedown = nil
  self.game_over = false

  g.setLineWidth(6)
  g.setFont(self.preloaded_fonts["04b03_16"])
end

local t = 0
function Player2:update(dt)
  if self.game_over then
    return
  end

  t = t + dt
  -- lightSource.rotation = math.pow(math.sin((t / 4) * math.pi / 2), 2)
  -- mirror:setRotation(t)
  for i,mirror in ipairs(self.mirrors) do
    -- mirror:setRotation(mirror.rotation + dt)
  end

  for i,prism in ipairs(self.prisms) do
    -- prism:setRotation(prism.rotation + dt / 4)
    prism.refracted = false
  end

  for i,receptor in ipairs(self.receptors) do
    receptor.charge_ratio = 0
  end

  self.rays = {}
  for t=1,self.num_players do
    local i = ((t + self.player_index - 1) + 1) % self.num_players + 1
    local light = self.lights[i]
    local x1 = light.x + math.cos(light.rotation) * light.radius / 2
    local y1 = light.y + math.sin(light.rotation) * light.radius / 2
    local x2 = x1 + math.cos(light.rotation) * 1000
    local y2 = y1 + math.sin(light.rotation) * 1000

    local a = 255
    if i ~= self.player_index then
      a = 50
    end
    self:rayCast(dt, x1, y1, x2, y2, 255, 255, 255, a)
  end

  if allReceptorsFull(self.receptors) then
    self.game_over = true
  end
end

function Player2:rayCast(dt, x1, y1, x2, y2, r, g, b, a)
  if #self.rays > 1000 then -- PANIC
    return 0
  end

  self.hits = {}
  self.world:rayCast(x1, y1, x2, y2, worldRayCastCallback)
  if #self.hits == 0 then
    table.insert(self.rays, {
      x1 = x1, y1 = y1,
      x2 = x2, y2 = y2,
      r = r, g = g, b = b, a = a
    })
  else
    local closest_hit = self.hits[1]
    for i,hit in ipairs(self.hits) do
      if hit.fraction < closest_hit.fraction then
        closest_hit = hit
      end
    end

    table.insert(self.rays, {
      x1 = x1, y1 = y1,
      x2 = closest_hit.x, y2 = closest_hit.y,
      r = r, g = g, b = b, a = a
    })
    local dx = x1-x2
    local dy = y1-y2
    local dist = math.sqrt(dx * dx + dy * dy)
    local ixn, iyn = dx / dist, dy / dist

    -- if closest_hit.xn == ixn and closest_hit.yn == iyn then -- FIXME: this examines the normals
    --   -- just going back where we came
    --   return 0
    -- end

    local object = closest_hit.object
    local xn = closest_hit.xn
    local yn = closest_hit.yn
    if object:isInstanceOf(Mirror) then
      local s = 2 * (dx * xn + dy * yn) / (xn * xn + yn * yn)
      local x3 = closest_hit.x + (s * xn - dx) * 1000
      local y3 = closest_hit.y + (s * yn - dy) * 1000
      self:rayCast(dt, closest_hit.x, closest_hit.y, x3, y3, r, g, b, a)
    elseif object:isInstanceOf(Prism) then
      local phi = math.atan2(closest_hit.xn, closest_hit.yn)
      local exitRays = object:getExitRays(closest_hit.x, closest_hit.y, phi)
      for i,ray in ipairs(exitRays) do
        local x1 = ray.x
        local y1 = ray.y
        local x2 = ray.x + math.cos(ray.angle) * 1000
        local y2 = ray.y + math.sin(ray.angle) * 1000
        self:rayCast(dt, x1, y1, x2, y2, ray.color[1], ray.color[2], ray.color[3], a)
      end
    elseif object:isInstanceOf(Receptor) then
      if a == 255 then
        object:charge(dt, r, g, b)
      end
    end
  end
end

function Player2:draw()
  g.draw(self.preloaded_images['background.png'])

  self.camera:set()

  for i,light in ipairs(self.lights) do
    light:draw()
  end

  for i,mirror in ipairs(self.mirrors) do
    mirror:draw()
  end

  for i,mirror in ipairs(self.player_mirrors) do
    mirror:draw()
  end

  for i,prism in ipairs(self.prisms) do
    prism:draw()
  end

  for i,receptor in ipairs(self.receptors) do
    receptor:draw()
  end

  g.push('all')
  for i,ray in ipairs(self.rays) do
    g.setColor(ray.r, ray.g, ray.b, ray.a)
    g.line(ray.x1, ray.y1, ray.x2, ray.y2)
  end
  g.pop()

  if self.mousedown then
    local x, y = love.mouse.getPosition()
    local dx = x - self.mousedown.x
    local dy = y - self.mousedown.y
    local cx = (self.mousedown.x + x) / 2
    local cy = (self.mousedown.y + y) / 2
    local phi = math.atan2(dy, dx) + math.pi / 2
    local len = math.sqrt(dx * dx + dy * dy)

    g.push('all')
    g.translate(self.mousedown.x, self.mousedown.y)
    g.rotate(phi)
    g.rectangle('fill', -len / 2, -25 / 2, len, 25)
    g.pop()
  end

  if self.game_over then
    g.push('all')
    g.setColor(0, 0, 0, 100)
    g.rectangle('fill', 0, 0, g.getWidth(), g.getHeight())
    g.setColor(255, 255, 255)
    g.setFont(game.preloaded_fonts['04b03_24'])
    g.printf("Player " .. self.player_index .. " Wins!", 0, g.getHeight() / 3, g.getWidth(), 'center')
    g.pop()
  end

  self.camera:unset()
end

function Player2:mousepressed(x, y, button, isTouch)
  if button == 1 and not self.game_over then
    self.mousedown = {
      x = x,
      y = y
    }
  elseif button == 2 and self.mousedown then
    self.mousedown = nil
  end
end

function Player2:mousereleased(x, y, button, isTouch)
  if self.game_over then
    self:gotoState("Menu")
    return
  end

  if button == 1 and self.mousedown then
    local dx = x - self.mousedown.x
    local dy = y - self.mousedown.y

    if math.abs(dx) > 0 and math.abs(dy) > 0 then
      local cx = (self.mousedown.x + x) / 2
      local cy = (self.mousedown.y + y) / 2
      local phi = math.atan2(dy, dx) + math.pi / 2
      local len = math.sqrt(dx * dx + dy * dy)

      local new_mirror = Mirror:new(self.mousedown.x, self.mousedown.y, len, 25, phi)
      table.insert(self.player_mirrors, new_mirror)
      self.player_index = (self.player_index % self.num_players) + 1
    end
    self.mousedown = nil
  elseif button == 2 then
    local index_to_remove = 0
    for i,mirror in ipairs(self.player_mirrors) do
      local body = mirror.body
      local shape = mirror.fixture:getShape()
      if shape:testPoint(body:getX(), body:getY(), body:getAngle(), x, y) then
        index_to_remove = i
      end
    end

    if index_to_remove > 0 then
      local mirror = self.player_mirrors[index_to_remove]
      mirror:destroy()
      table.remove(self.player_mirrors, index_to_remove)
    end
  end
end

function Player2:keypressed(key, scancode, isrepeat)
end

function Player2:keyreleased(key, scancode)
  if self.game_over then
    self:gotoState('Menu')
  elseif key == 'r' then
    self:gotoState('Player2')
  end
end

function Player2:gamepadpressed(joystick, button)
end

function Player2:gamepadreleased(joystick, button)
end

function Player2:focus(has_focus)
end

function Player2:exitedState()
  self.camera = nil
  self.world:destroy()
end

return Player2
