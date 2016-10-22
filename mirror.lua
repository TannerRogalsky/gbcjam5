local Mirror = class('Mirror', Base):include(Stateful)

function Mirror:initialize(x, y, width, height, rotation)
  Base.initialize(self)

  self.x = x
  self.y = y
  self.rotation = rotation
  self.width = width
  self.height = height

  self.body = love.physics.newBody(game.world, x, y)
  local shape = love.physics.newPolygonShape(-width / 2, -height / 2,
                                             width / 2, -height / 2,
                                             width / 2,  height / 2,
                                            -width / 2,  height / 2)
  self.fixture = love.physics.newFixture(self.body, shape)
  self.fixture:setUserData(self)

  self.mesh = g.newMesh({
    {-width / 2, -height / 2, 0, 0, 50, 50, 50},
    { width / 2, -height / 2, 1, 0, 50, 50, 50},
    { width / 2,  height / 2, 1, 1, 255, 255, 255},
    {-width / 2,  height / 2, 0, 1, 255, 255, 255},
  })

  self.body:setAngle(rotation)
end

function Mirror:draw()
  g.push('all')
  -- g.setColor(255, 255, 0)
  g.translate(self.x, self.y)
  g.rotate(self.rotation)
  -- g.scale(self.radius)

  -- g.rectangle('fill', -1, -0.25, 2, 0.5)
  -- g.polygon('fill', self.fixture:getShape():getPoints())
  -- g.setColor(255, 255, 0)
  -- g.rectangle('fill', -self.width / 2, -self.height / 2, self.width, self.height)
  -- g.setColor(255, 255, 255)
  g.draw(self.mesh)



  g.pop()
end

function Mirror:setRotation(phi)
  self.rotation = phi
  self.body:setAngle(phi)
end

function Mirror:destroy()
  self.body:destroy()
end

return Mirror
