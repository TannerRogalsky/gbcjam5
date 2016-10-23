local Receptor = class('Receptor', Base):include(Stateful)

function Receptor:initialize(x, y, width, height, rotation, red, green, blue)
  Base.initialize(self)

  self.x = x
  self.y = y
  self.rotation = rotation
  self.width = width
  self.height = height

  self.r = red
  self.g = green
  self.b = blue
  self.charge_ratio = 0

  self.body = love.physics.newBody(game.world, x, y)
  local shape = love.physics.newCircleShape(self.width / 2)
  self.fixture = love.physics.newFixture(self.body, shape)
  self.fixture:setUserData(self)

  self.sprites = require('images.receptor')

  self.body:setAngle(rotation)
end

function Receptor:draw()
  g.push('all')
  g.translate(self.x, self.y)
  g.rotate(self.rotation)

  -- g.draw(self.mesh)
  g.setColor(self.r, self.g, self.b)
  g.draw(self.sprites.texture, self.sprites.quads['receptor-base'], 0, 0, 0, 1, 1, self.width / 2, self.height / 2)
  g.setColor(255, 255, 255)
  g.draw(self.sprites.texture, self.sprites.quads['receptor-sprite'], 0, 0, 0, 1, 1, self.width / 2, self.height / 2)

  local frame_index = math.ceil(self.charge_ratio * 5)
  if frame_index > 0 then
    g.draw(self.sprites.texture, self.sprites.quads['receptor-progress-' .. frame_index], 0, 0, 0, 1, 1, self.width / 2, self.height / 2)
  end

  -- g.setColor(self.r, self.g, self.b, self.charge_ratio * 255)
  -- g.ellipse('fill', 0, 0, self.width, self.height)

  g.pop()
end

local function equalish(a, b)
  return math.ceil(a) == math.ceil(b)
end

function Receptor:charge(dt, r, g, b)
  if equalish(r, self.r) and equalish(g, self.g) and equalish(b, self.b) then
    self.charge_ratio = 1
  end
  -- local color = self.charge_ratio * 255
  -- self.mesh:setVertexAttribute(1, 3, color, color, color)
  -- self.mesh:setVertexAttribute(2, 3, color, color, color)
end

function Receptor:setRotation(phi)
  self.rotation = phi
  self.body:setAngle(phi)
end

return Receptor
