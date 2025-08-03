local unitdefs = include( "sim/unitdefs" )
local util = include( "modules/util" )

-- TODO API plan
-- needs some kind of register method (but no un/reload because stuff simply doesn't take effect if the agent isn't available)
-- needs the "get def via agent ID" thing

local function init(modApi)
    util.transistor_templates = {}
    util.getTransistorForAgentId = function() end --TODO
end

return {
    init = init
}
