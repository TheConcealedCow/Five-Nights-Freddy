r = {
	ai = 0,
	
	cam = 1,
	dir = 0,
	pos = 0,
}
function onCreate()
	setCamRobot(1, 3, 'CHICA');
	
	--playAnim('rightOfficeLight', 'rCHICA', true);
	
	setVar('chicaMoved', false);
	setVar('rightAtDoor', false);
	setVar('rightSnd', false);
	
	runTimer('chicaMove', pl(4.97), 0);
end

local timers = {
	['updateSec'] = function()
		r.dir = getRandomInt(1, 2);
	end,
	['chicaMove'] = function()
		if getRandomInt(1, 20) <= r.ai then
			setVar('chicaMoved', true);
			
			debugPrint('chicken moved');
		end
	end
}
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
