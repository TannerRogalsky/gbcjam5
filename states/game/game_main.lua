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

function Main:enteredState()
  local Camera = require("lib/camera")
  self.camera = Camera:new()

  self.world = love.physics.newWorld(0, 0, true)

  lightSource = LightSource:new(100, 100, 0)

  self.mirrors = {}
  for i=1,10 do
    local w, h = g.getDimensions()
    self.mirrors[i] = Mirror:new(love.math.random(w), love.math.random(h), 75, 10, love.math.random(math.pi * 2))
  end
  prism = Prism:new(400, 100, 50, 0)

  self.rays = {}

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
    mirror:setRotation(mirror.rotation + dt)
  end
  prism:setRotation(t / 10)
  prism.refracted = false

  self.rays = {}
  do
    local x1 = lightSource.x + math.cos(lightSource.rotation) * lightSource.radius / 2
    local y1 = lightSource.y + math.sin(lightSource.rotation) * lightSource.radius / 2
    local x2 = x1 + math.cos(lightSource.rotation) * 1000
    local y2 = y1 + math.sin(lightSource.rotation) * 1000
    self:rayCast(x1, y1, x2, y2)
  end
end

function Main:rayCast(x1, y1, x2, y2)
  if #self.rays > 1000 then -- PANIC
    return 0
  end

  self.hits = {}
  self.world:rayCast(x1, y1, x2, y2, worldRayCastCallback)
  if #self.hits == 0 then
    table.insert(self.rays, {
      x1 = x1, y1 = y1,
      x2 = x2, y2 = y2
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
      x2 = closest_hit.x, y2 = closest_hit.y
    })
    local dx = x1-x2
    local dy = y1-y2
    local dist = math.sqrt(dx * dx + dy * dy)
    local ixn, iyn = dx / dist, dy / dist

    if closest_hit.xn == ixn and closest_hit.yn == iyn then
      -- just going back where we came
      return 0
    end

    local object = closest_hit.object
    if object:isInstanceOf(Mirror) then
      local x3 = closest_hit.x + closest_hit.xn * 1000
      local y3 = closest_hit.y + closest_hit.yn * 1000
      self:rayCast(closest_hit.x, closest_hit.y, x3, y3)
    elseif object:isInstanceOf(Prism) then
      local phi = math.atan2(closest_hit.xn, closest_hit.yn)
      local exitRays = object:getExitRays(closest_hit.x, closest_hit.y, phi)
      for i,ray in ipairs(exitRays) do
        local x1 = ray.x
        local y1 = ray.y
        local x2 = ray.x + math.cos(ray.angle) * 1000
        local y2 = ray.y + math.sin(ray.angle) * 1000
        self:rayCast(x1, y1, x2, y2)
        -- table.insert(game.rays, {startX = x1, startY = y1, endX = x2, endY = y2})
        -- game.world:rayCast(x1, y1, x2, y2, worldRayCastCallback)
      end
    end
  end
end

function Main:draw()
  self.camera:set()

  lightSource:draw()

  for i,mirror in ipairs(self.mirrors) do
    mirror:draw()
  end

  prism:draw()

  for i,ray in ipairs(self.rays) do
    g.line(ray.x1, ray.y1, ray.x2, ray.y2)
  end

  -- do
  --   local x1 = lightSource.x + math.cos(lightSource.rotation) * lightSource.radius / 2
  --   local y1 = lightSource.y + math.sin(lightSource.rotation) * lightSource.radius / 2
  --   local x2 = x1 + math.cos(lightSource.rotation) * 1000
  --   local y2 = y1 + math.sin(lightSource.rotation) * 1000
  --   g.line(x1, y1, x2, y2)
  -- end

  self.camera:unset()
end

function Main:mousepressed(x, y, button, isTouch)
end

function Main:mousereleased(x, y, button, isTouch)
end

function Main:keypressed(key, scancode, isrepeat)
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
end

return Main
