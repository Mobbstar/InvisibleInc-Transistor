----------------------------------------------------------------

local util = include("modules/util")
local simdefs = include("sim/simdefs")
-----------------------------------------------------

local logs = {
	{
		id="transistorlog1",
		file = STRINGS.TRANSISTOR.LOGS.log_transistor1_filename,
		title= STRINGS.TRANSISTOR.LOGS.log_transistor1_title,
		body= STRINGS.TRANSISTOR.LOGS.log_transistor1,
		profileImg = nil,
		profileAnim = "portraits/prism_face",
		profileBuild = "portraits/crash_face",
	},


	{
		id="transistorlog2",
		file = STRINGS.TRANSISTOR.LOGS.log_transistor2_filename,
		title= STRINGS.TRANSISTOR.LOGS.log_transistor2_title,
		body= STRINGS.TRANSISTOR.LOGS.log_transistor2,
		profileImg = nil,
		profileAnim = "portraits/sankaku_drone_camera_new",
		profileBuild = "portraits/badcell_portrait",
	},
	
}



-------------------------------------------------------------
return logs
