local LightSource = class('LightSource', Base):include(Stateful)

function LightSource:initialize(x, y, rotation)
  Base.initialize(self)

  self.x = x
  self.y = y
  self.rotation = rotation
  self.radius = 65

  self.image = game.preloaded_images['light-source.png']
end

function LightSource:draw()
  -- g.push('all')
  -- g.setColor(255, 0, 0)
  -- g.translate(self.x, self.y)
  -- g.rotate(self.rotation + math.pi / 2)
  -- g.scale(self.radius)

  -- g.polygon('fill', 0, -0.5, 0.5, 0.5, -0.5, 0.5)
  local w, h = self.image:getDimensions()
  g.draw(self.image, self.x, self.y, self.rotation + math.pi / 2, 1, 1, w / 2, h / 2)

  -- g.pop()
end

return LightSource
