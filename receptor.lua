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
  local shape = love.physics.newPolygonShape(-width / 2, -height / 2,
                                             width / 2, -height / 2,
                                             width / 2,  height / 2,
                                            -width / 2,  height / 2)
  self.fixture = love.physics.newFixture(self.body, shape)
  self.fixture:setUserData(self)

  self.mesh = g.newMesh({
    {-width / 2, -height / 2, 0, 0, 0, 0, 0},
    { width / 2, -height / 2, 1, 0, 0, 0, 0},
    { width / 2,  height / 2, 1, 1, self.r, self.g, self.b},
    {-width / 2,  height / 2, 0, 1, self.r, self.g, self.b},
  })

  self.body:setAngle(rotation)
end

function Receptor:draw()
  g.push('all')
  g.translate(self.x, self.y)
  g.rotate(self.rotation)

  g.draw(self.mesh)

  -- g.setColor(self.r, self.g, self.b, self.charge_ratio * 255)
  -- g.ellipse('fill', 0, 0, self.width, self.height)

  g.pop()
end

function Receptor:charge(dt, r, g, b)
  self.charge_ratio = math.min(self.charge_ratio + dt / 5, 1)
  local color = self.charge_ratio * 255
  self.mesh:setVertexAttribute(1, 3, color, color, color)
  self.mesh:setVertexAttribute(2, 3, color, color, color)
end

function Receptor:setRotation(phi)
  self.rotation = phi
  self.body:setAngle(phi)
end

return Receptor
