--[[
	TODO: 
	 - when leaving the stage check if bonnie and chica have left as well
	 - make the jumpscare actually work!!!
	 - make the suffix cam check properly account for freddy n friends!!
]]
r = {
	ai = 0,
	cam = 1,
	movePhase = 0,
	moveTime = 0,
	timeKit = 0,
	moveTree = {
		[1] = 2, -- 15, 30
		[2] = 11, -- 20, 35
		[11] = 10, -- 30, 40
		[10] = 7, -- 40, 60
		[7] = 8, -- 60, 75
		[8] = 1 -- 80, 100 if gets in, 60, 75 if leaves
	},
	soundMove = {
		[1] = {0.15, 0.3},
		[2] = {0.2, 0.35},
		[11] = {0.3, 0.4},
		[10] = {0.4, 0.6},
		[7] = {0.6, 0.75},
		[8] = {1, 1} -- this one will be custom
	}
}
function onCreate()
	setCamRobot(r.cam, 1, 'FREDDY');
	
	runTimer('freddyMove', pl(3.02), 0);
	
	--makeAnimatedLuaSprite('scareFREDDY', 'gameAssets/jumpscares/freddy1');
	--addAnimationByPrefix('scareFREDDY', 'scare', 'Scare', 30, false);
end

function updateRoom(n)
	setCamRobot(r.cam, 1, '');
	r.cam = n;
	
	setCamRobot(n, 1, 'FREDDY');
end

function onUpdatePost(e)
	e = e * playbackRate;
	local ti = e * 60; -- tick value
	
	if r.ai <= 0 or r.cam == 0 then return; end
	
	if r.movePhase == 1 then
		r.moveTime = r.moveTime + ti;
		
		if getMainVar('viewingCams') then
			if getMainVar('curCam') == r.cam then
				r.moveTime = 0;
			end
		else
			if r.moveTime >= 1000 - (r.ai * 100) then
				r.moveTime = 0;
				r.movePhase = 2;
				
				moveRobot();
			end
		end
	elseif r.movePhase == 2 then moveRobot(); end
	
	if r.cam == 10 then
		r.timeKit = r.timeKit + e;
		while r.timeKit >= 300 do
			r.timeKit = r.timeKit - 300;
			
			local looking = (getMainVar('viewingCams') and getMainVar('curCam') == 10);
			doSound('musicBox', (looking and 0.5 or 0.05), 'fredKitchen');
		end
	end
end

local extraChecksOnCur = {
	[0] = function() return false; end,
	[1] = function()
		return true; -- check if bonnie and chica left
	end,
	[7] = function()
		return not getMainVar('rightDoor').light;
	end,
	[8] = function()
		local doorPhase = getMainVar('rightDoor').phase;
		local cam = getMainVar('curCam');
		if getMainVar('viewingCams') and cam ~= 8 then
			if doorPhase == 0 then
				r.movePhase = 0;
				robotSound(0.8, 1);
				setCamRobot(r.cam, 1, '');
				r.cam = 0;
				
				runTimer('tryFredScare', pl(1), 0);
				doSound('whispering', 1, 'fredWhisp');
			elseif doorPhase == 2 and cam ~= 7 then
				r.movePhase = 0;
				robotSound(0.6, 0.75);
				updateRoom(7);
			end
		end
		return false;
	end
}
local newCamFunc = {
	[10] = function()
		doSound('musicBox', 0.05, 'fredKitchen');
	end
}
function moveRobot()
	if extraChecksOnCur[r.cam] then
		if not extraChecksOnCur[r.cam]() then return; end
	end
	
	local s = r.soundMove[r.cam];
	r.movePhase = 0;
	robotSound(s[1], s[2]);
	updateRoom(r.moveTree[r.cam]);
	
	stopSound('fredKitchen');
	if newCamFunc[r.cam] then newCamFunc[r.cam](); end
end

local har = {'laughGiggle1d', 'laughGiggle2d', 'laughGiggle8d'};
function robotSound(h, w)
	doSound(har[getRandomInt(1, 3)], h, 'fredSound');
	doSound('runningFast', w, 'runSound');
end

local timers = {
	['freddyMove'] = function()
		if not getMainVar('viewingCams') and getRandomInt(1, 20) <= r.ai then
			r.movePhase = 1;
		end
	end,
	['tryFredScare'] = function()
		if not getMainVar('viewingCams') and not getVar('jumpscared') and Random(4) == 1 then
			cancelTimer('tryFredScare');
			setVar('jumpscared', true);
			
			--doSound('xScream', 1, 'scareSound');
		end
	end
}
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
