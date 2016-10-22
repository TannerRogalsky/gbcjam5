local Menu = Game:addState('Menu')

function Menu:enteredState()
end

function Menu:draw()
  g.draw(self.preloaded_images['title-1.png'])
end

function Menu:mousereleased()
  self:gotoState("Player2")
end

function Menu:keyreleased()
  self:gotoState("Player2")
end

function Menu:exitedState()
end

return Menu
