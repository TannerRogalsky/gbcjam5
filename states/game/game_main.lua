local Main = Game:addState('Main')

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

function Main:enteredState()
  local Camera = require("lib/camera")
  self.camera = Camera:new()

  self.world = love.physics.newWorld(0, 0, true)

  local level = self.preloaded_levels.level002
  self.light = LightSource:new(unpack(level.source))

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

  g.setLineWidth(6)
  g.setFont(self.preloaded_fonts["04b03_16"])
end

local t = 0
function Main:update(dt)
  if love.keyboard.isDown('p') then
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

  self.rays = {}
  do
    local x1 = self.light.x + math.cos(self.light.rotation) * self.light.radius / 2
    local y1 = self.light.y + math.sin(self.light.rotation) * self.light.radius / 2
    local x2 = x1 + math.cos(self.light.rotation) * 1000
    local y2 = y1 + math.sin(self.light.rotation) * 1000
    self:rayCast(dt, x1, y1, x2, y2, 255, 255, 255)
  end

  if allReceptorsFull(self.receptors) then
    self:gotoState('Over')
  end
end

function Main:rayCast(dt, x1, y1, x2, y2, r, g, b)
  if #self.rays > 1000 then -- PANIC
    return 0
  end

  self.hits = {}
  self.world:rayCast(x1, y1, x2, y2, worldRayCastCallback)
  if #self.hits == 0 then
    table.insert(self.rays, {
      x1 = x1, y1 = y1,
      x2 = x2, y2 = y2,
      r = r, g = g, b = b
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
      r = r, g = g, b = b
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
      self:rayCast(dt, closest_hit.x, closest_hit.y, x3, y3, r, g, b)
    elseif object:isInstanceOf(Prism) then
      local phi = math.atan2(closest_hit.xn, closest_hit.yn)
      local exitRays = object:getExitRays(closest_hit.x, closest_hit.y, phi)
      for i,ray in ipairs(exitRays) do
        local x1 = ray.x
        local y1 = ray.y
        local x2 = ray.x + math.cos(ray.angle) * 1000
        local y2 = ray.y + math.sin(ray.angle) * 1000
        self:rayCast(dt, x1, y1, x2, y2, ray.color[1], ray.color[2], ray.color[3])
      end
    elseif object:isInstanceOf(Receptor) then
      object:charge(dt, r, g, b)
    end
  end
end

function Main:draw()
  self.camera:set()

  self.light:draw()

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
    g.setColor(ray.r, ray.g, ray.b)
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

  self.camera:unset()
end

function Main:mousepressed(x, y, button, isTouch)
  if button == 1 then
    self.mousedown = {
      x = x,
      y = y
    }
  end
end

function Main:mousereleased(x, y, button, isTouch)
  if button == 1 then
    local dx = x - self.mousedown.x
    local dy = y - self.mousedown.y

    if math.abs(dx) > 0 and math.abs(dy) > 0 then
      local cx = (self.mousedown.x + x) / 2
      local cy = (self.mousedown.y + y) / 2
      local phi = math.atan2(dy, dx) + math.pi / 2
      local len = math.sqrt(dx * dx + dy * dy)

      local new_mirror = Mirror:new(self.mousedown.x, self.mousedown.y, len, 25, phi)
      table.insert(self.player_mirrors, new_mirror)
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

function Main:keypressed(key, scancode, isrepeat)
  if key == 'r' then
    self:gotoState('Main')
  end
end

function Main:keyreleased(key, scancode)
end

function Main:gamepadpressed(joystick, button)
end

function Main:gamepadreleased(joystick, button)
end

function Main:focus(has_focus)
end

function Main:exitedState()
  self.camera = nil
  self.world:destroy()
end

return Main
