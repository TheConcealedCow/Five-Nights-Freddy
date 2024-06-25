r = {
	ai = 0,
	refCam = 0,
	disTime = 0,
	progress = 0,
	
	foxWaitRun = 0,
	foxWaitAtt = 0,
	
	knocks = 0,
}
function onCreate()
	runTimer('foxyMove', pl(5.01), 0);
	
	setVar('foxPhase', r.progress);
end

local dumTime = 0;
function onUpdatePost(e)
	e = e * playbackRate;
	local ti = e * 60; -- tick value
	
	if getMainVar('viewingCams') then
		r.refCam = r.refCam + e;
		while r.refCam >= 0.1 do
			r.refCam = r.refCam - 0.1;
			r.disTime = 50 + Random(1000);
		end
	end
	
	if r.disTime > 0 then r.disTime = r.disTime - ti; end
	
	if r.progress == 0 then -- these ends make me go owie
		dumTime = dumTime + e;
		while dumTime >= 4 do
			dumTime = dumTime - 4;
			
			if getRandomInt(1, 30) == 1 then
				local looking = (getMainVar('viewingCams') and getMainVar('curCam') == 3);
				setVar('interCam3Sfx', false);
				doSound('pirateSong', (looking and 0.15 or 0.05), 'cam3Sfx');
			end
		end
	elseif r.progress == 3 then
		r.foxWaitRun = r.foxWaitRun + ti;
		if r.foxWaitRun > 1500 then
			r.foxWaitRun = 0;
			r.progress = 5;
			setVar('foxPhase', 5);
			
			foxTryAttack();
		end
	elseif r.progress == 5 then foxTryAttack(); end
	
	if getVar('foxPhase') == 4 then
		r.foxWaitAtt = r.foxWaitAtt + ti;
		if r.foxWaitAtt > 100 then
			r.foxWaitAtt = 0;
			r.progress = 5;
			setVar('foxPhase', 5);
			
			foxTryAttack();
		end
	end
end

function foxTryAttack()
	local doorPhase = getMainVar('leftDoor').phase;
	
	if getMainVar('viewingCams') then
		runMainFunc('trigPanel');
	end
	
	runMainFunc('disableLight');
	
	if doorPhase == 0 then
		if not getVar('jumpscared') then
			r.progress = 6;
			
			setVar('jumpscared', true);
		
			debugPrint('boo');
		end
	elseif doorPhase == 2 then
		r.progress = Random(2);
		setCamRobot(3, 4, (r.progress == 0 and '' or 'FOXY' .. r.progress));
		
		foxyKnock();
	end
end

function foxyKnock()
	local toTake = 10 + (r.knocks * 50);
	
	doSound('knock', 1, 'foxKnock');
	runMainFunc('takePower', toTake);
	removePower(toTake);
	
	r.knocks = r.knocks + 1;
end

local timers = {
	['foxyMove'] = function()
		if r.progress < 3 and r.disTime <= 0 and getRandomInt(1, 20) <= r.ai then
			r.progress = r.progress + 1;
			r.foxWaitRun = 0;
			setVar('foxPhase', r.progress);
			
			debugPrint('moved a phase!');
			setCamRobot(3, 4, 'FOXY' .. r.progress);
		end
	end
}
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
