local unitrig = include( "gameplay/unitrig" )
local simquery = include( "sim/simquery" )
local util = include( "modules/util" )

local oldrefreshProp = unitrig.rig.refreshProp
local olddestroy = unitrig.rig.destroy
local oldplaySound = unitrig.rig.playSound

--borrowed from AGP by Cyberboy2000
unitrig.rig.refreshProp = function( self, refreshLoc )
	local unit = self:getUnit()
	local ret = oldrefreshProp( self, refreshLoc )
	if not self._mischiefFX then
		self._mischiefFX = self:createHUDProp("kanim_mischief_fx", "effect", "idle", self._boardRig:getLayer("floor"), self._prop )
		self._mischiefFX:setSymbolModulate("innercicrle",1,1,1,0.75)
		self._mischiefFX:setSymbolModulate("innerring",1,1,1,0.75)
		self._mischiefFX:setVisible(false)
	end
	if unit:getTraits().mischiefMarked then
		self._mischiefFX:setVisible(true)
	else
		self._mischiefFX:setVisible(false)
	end

	return ret
end

unitrig.rig.destroy = function( self )
	olddestroy( self )
	if self._mischiefFX then
		self._boardRig:getLayer("floor"):removeProp( self._mischiefFX  )			
	end
end