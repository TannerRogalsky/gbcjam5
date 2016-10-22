local w, h = g.getDimensions()

return {
  source = {w * 0.1, h * 0.5, 0},
  receptor = {w * 0.5, h * 0.1, 75, 25, 0},
  mirrors = {},
  prisms = {},
}
