local Prism = class('Prism', Base):include(Stateful)

local hsl = require('lib.hsl')

function Prism:initialize(x, y, radius, rotation)
  Base.initialize(self)

  self.x = x
  self.y = y
  self.rotation = rotation
  self.radius = radius

  local verts = {}
  local interval = math.pi * 2 / 3
  for i=1,3 do
    table.insert(verts, math.cos(interval * i) * radius)
    table.insert(verts, math.sin(interval * i) * radius)
  end

  self.body = love.physics.newBody(game.world, x, y)
  local shape = love.physics.newPolygonShape( verts[1], verts[2],
                                              verts[3], verts[4],
                                              verts[5], verts[6])
  self.fixture = love.physics.newFixture(self.body, shape)
  self.fixture:setUserData(self)

  self.mesh = g.newMesh({
    {verts[1], verts[2], 0, 0, 255, 0, 0},
    {verts[3], verts[4], 0, 0, 0, 255, 0},
    {verts[5], verts[6], 0, 0, 0, 0, 255},
  })

  self.body:setAngle(rotation)

  self.refracted = false
end

function Prism:draw()
  g.push('all')
  g.translate(self.x, self.y)
  g.rotate(self.rotation)

  g.draw(self.mesh)

  g.pop()
end

function Prism:setRotation(phi)
  self.rotation = phi
  self.body:setAngle(phi)
end

function Prism:getExitRays(ix, iy, iPhi)
  if self.refracted then
    return {}
  end
  self.refracted = true

  local exitRays = {}

  local interval = math.pi * 2 / 3
  for i=1,3 do
    local angle = interval * i + math.pi / 3 + self.rotation
    local x = math.cos(angle) * self.radius * math.cos(math.pi / 3)
    local y = math.sin(angle) * self.radius * math.cos(math.pi / 3)
    exitRays[i] = {
      x = self.x + x,
      y = self.y + y,
      angle = angle,
      color = {hsl((interval * i - math.pi / 3) / (math.pi * 2), 1, 0.5)}
    }
  end
  return exitRays
end

return Prism
