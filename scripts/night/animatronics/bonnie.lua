r = {
	ai = 20,
	
}
function onCreate()
	setCamRobot(1, 2, 'BONNIE'); -- bonnie's first move is ignored if chica moves too because scott
	
	runTimer('bonnieMove', pl(4.98), 0);
end

local firstMove = true;
local timers = {
	['bonnieMove'] = function()
		if firstMove then
			firstMove = false;
			
			if getVar('chicaMoved') then return; end
		end
		
		debugPrint('bunny moved');
	end
}
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end