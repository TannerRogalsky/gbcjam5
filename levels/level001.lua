local w, h = g.getDimensions()

return {
  source = {w * 0.1, h * 0.5, 0},
  receptors = {
    {w * 0.5, h * 0.1, 75, 25, 0, 255, 255, 255},
  },
  mirrors = {},
  prisms = {},
}
