-- Generated with TexturePacker (http://www.codeandweb.com/texturepacker)
-- with a custom export by Stewart Bracken (http://stewart.bracken.bz)
--
-- $TexturePacker:SmartUpdate:54d0b1c2bbea078959344ab3db2ba705:1d8b58a98a39129400b303e5eeaf9bd6:707b801c8cc9badf1754d9a468718fa0$
--
--[[------------------------------------------------------------------------
-- Example Usage --

function love.load()
	myAtlas = require("receptor")
	batch = love.graphics.newSpriteBatch( myAtlas.texture, 100, "stream" )
end
function love.draw()
	batch:clear()
	batch:bind()
		batch:add( myAtlas.quads['mySpriteName'], love.mouse.getX(), love.mouse.getY() )
	batch:unbind()
	love.graphics.draw(batch)
end

--]]------------------------------------------------------------------------

local TextureAtlas = {}
local Quads = {}
local Texture = game.preloaded_images["receptor.png"]

Quads["receptor-base"] = love.graphics.newQuad(1, 1, 50, 50, 364, 52 )
Quads["receptor-progress-1"] = love.graphics.newQuad(53, 1, 50, 50, 364, 52 )
Quads["receptor-progress-2"] = love.graphics.newQuad(105, 1, 50, 50, 364, 52 )
Quads["receptor-progress-3"] = love.graphics.newQuad(157, 1, 50, 50, 364, 52 )
Quads["receptor-progress-4"] = love.graphics.newQuad(209, 1, 50, 50, 364, 52 )
Quads["receptor-progress-5"] = love.graphics.newQuad(261, 1, 50, 50, 364, 52 )
Quads["receptor-sprite"] = love.graphics.newQuad(313, 1, 50, 50, 364, 52 )

function TextureAtlas:getDimensions(quadName)
	local quad = self.quads[quadName]
	if not quad then
		return nil
	end
	local x, y, w, h = quad:getViewport()
    return w, h
end

TextureAtlas.quads = Quads
TextureAtlas.texture = Texture

return TextureAtlas
