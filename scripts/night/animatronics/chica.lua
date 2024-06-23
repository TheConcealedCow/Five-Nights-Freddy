r = {
	ai = 20,
	
}
function onCreate()
	setCamRobot(1, 3, 'CHICA');
	setVar('chicaMoved', false);
	
	runTimer('chicaMove', pl(4.97), 0);
end

local timers = {
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
