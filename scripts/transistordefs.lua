local td = "transistordaemon" -- prefix to ensure unique ability id

--Note: (ARCHIVE) agents get specific IDs if SAA is installed
return {
    {
        agents = {1, 230},
        ability = td.. "decker"
    },
    {
        agents = {2, 232},
        ability = td.. "shalem"
    },
    {
        agents = {3, 234},
        ability = td.. "xu"
    },
    {
        agents = {4, 233},
        ability = td.. "banks"
    },
    {
        agents = {5, 231},
        ability = td.. "maria"
    },
    {
        agents = {6, 235},
        ability = td.. "nika"
    },
    {
        agents = {7, 236},
        ability = td.. "sharp"
    },
    {
        agents = {8, 237},
        ability = td.. "prism"
    },
    {
        agents = {99, 100},
        ability = td.. "monster"
    },
    {
        agents = {107, 108},
        ability = td.. "central"
    },
    {
        agents = {1000},
        ability = td.. "olivia"
    },
    {
        agents = {1001},
        ability = td.. "derek"
    },
    {
        agents = {1002},
        ability = td.. "rush"
    },
    {
        agents = {1003},
        ability = td.. "draco"
    },
    {
        agents = {"transistor_red"},
        ability = td.. "red"
    },
    {
        agents = {"carmen_sandiego_o"},
        ability = td.. "carmen"
    },
    {
        agents = {"mod_01_pedler"},
        ability = td.. "pedler"
    },
    {
        agents = {"mod_02_mist"},
        ability = td.. "mist",
        abilityPermadeath = td.. "mistkia"
    },
    {
        agents = {"mod_03_ghuff"},
        ability = td.. "ghuff"
    },
    {
        agents = {"mod_04_n_umi"},
        ability = td.. "numi"
    },
    {
        agents = {"mod_goose"},
        ability = td.. "goose"
    },
    {
        agents = {"gunpoint_conway"},
        ability = td.. "conway"
    },
    {
        agents = {"agent_47_o"},
        ability = td.. "agent_47"
    },
}
