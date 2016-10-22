local w, h = g.getDimensions()

return {
  source = {w * 0.1, h * 0.5, -math.pi / 4},
  receptors = {
    {w * 0.5, h * 0.1, 75, 25, 0, 255, 255, 0},
    {w * 0.1, h * 0.9, 75, 25, math.pi * 1.25, 255, 0, 255},
    {w * 0.9, h * 0.9, 75, 25, -math.pi * 1.25, 0, 255, 255},
  },
  mirrors = {},
  prisms = {
    {w * 0.5, h * 0.5, 50, math.pi / 2}
  },
}
