local LightSource = class('LightSource', Base):include(Stateful)

function LightSource:initialize(x, y, rotation)
  Base.initialize(self)

  self.x = x
  self.y = y
  self.rotation = rotation
  self.radius = 50
end

function LightSource:draw()
  g.push('all')
  g.setColor(255, 0, 0)
  g.translate(self.x, self.y)
  g.rotate(self.rotation + math.pi / 2)
  g.scale(self.radius)

  g.polygon('fill', 0, -0.5, 0.5, 0.5, -0.5, 0.5)

  g.pop()
end

return LightSource
