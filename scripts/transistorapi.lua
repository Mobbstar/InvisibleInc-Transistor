local util = include("modules/util")
local modApi = include("mod-api")
local abilitydefs = include("sim/abilitydefs")

abilitydefs.transistor_agentid_to_abilityid = {}
abilitydefs.transistor_agentid_to_abilityid_permadeath = {}

function abilitydefs:getBestTransistorId(agentid)
    agentid = agentid or 0
    return self.transistor_agentid_to_abilityid[agentid]
        or "transistordaemongeneric"
end

function abilitydefs:getBestPermadeathTransistorId(agentid)
    agentid = agentid or 0
    return self.transistor_agentid_to_abilityid_permadeath[agentid]
        or self.transistor_agentid_to_abilityid[agentid]
        or "transistordaemongenerickia"
end

function abilitydefs:lookupTransistorForAgentId(agentid)
    local abilityid = self.transistor_agentid_to_abilityid[agentid]
    if abilityid then
        return abilitydefs.lookupAbility(abilityid)
    end
end

-- When [agent] goes down, spawn [ability]. If [ability] requires [agent] to exist, provide an alternate [ability for Permadeath].
function modApi:addTransistorDef(agentid, abilityid, abilityid_permadeath)
    assert(abilitydefs.transistor_agentid_to_abilityid[agentid] == nil, "already have a transistor algorithm for agent " .. tostring(agentid))
    abilitydefs.transistor_agentid_to_abilityid[agentid] = abilityid
    if abilityid_permadeath then
        assert(abilitydefs.transistor_agentid_to_abilityid_permadeath[agentid] == nil, "already have a permadeath transistor algorithm for agent " .. tostring(agentid))
        abilitydefs.transistor_agentid_to_abilityid_permadeath[agentid] = abilityid_permadeath
    end
end
