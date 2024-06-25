r = {
	ai = 20,
	
	cam = 1,
	dir = 0,
	pos = 0,
	tryingOffice = false;
	
	moveTree = {
		[1] = {9, 2}, -- stage
		[2] = {9, 4}, -- dining area
		[4] = {6, 5}, -- 2A
		[5] = {6, 50}, -- 2B
		[6] = {50, 4}, -- closet
		[9] = {2, 4}, -- backstage
		[50] = {1, 1}
	}
}
function onCreate()
	setCamRobot(r.cam, 2, 'BONNIE'); -- bonnie's first move is ignored if chica moves too because scott
	
	setVar('leftAtDoor', false);
	setVar('leftSnd', false);
	
	runTimer('bonnieMove', pl(4.98), 0);
end

function updateRoom(n)
	setCamRobot(r.cam, 2, '');
	
	r.cam = n;
	
	setCamRobot(n, 2, 'BONNIE' .. (n == 2 and getRandomInt(1, 2) or ''));
end

function onUpdatePost(e)
	if r.tryingOffice then tryEnter(); end
end

function moveRobot()
	if r.cam == 100 then return; end
	
	local want = r.moveTree[r.cam][r.dir];
	
	if want == 50 or r.cam == 50 then -- he want go window or he at window
		if r.tryingOffice then return; end
		
		if want == 50 then
			setVar('leftAtDoor', true);
			playAnim('leftOfficeLight', 'lBONNIE', true);
			runMainFunc('disableLight');
			
			setCamRobot(r.cam, 2, '');
			
			r.cam = 50;
		else
			tryEnter();
		end
		
		return;
	end
	
	updateRoom(want);
end

function tryEnter()
	local doorPhase = getMainVar('leftDoor').phase;
	r.tryingOffice = true;
	
	if doorPhase == 0 then
		r.tryingOffice = false;
		r.cam = 100;
		
		leaveLight();
		doorProp('left', 'stuck', true);
	elseif doorPhase == 2 then
		r.tryingOffice = false;
		leaveLight();
		
		r.cam = 2;
		setCamRobot(2, 2, 'BONNIE' .. getRandomInt(1, 2));
	end
end

function leaveLight()
	setVar('leftSnd', false);
	setVar('leftAtDoor', false);
	playAnim('leftOfficeLight', 'l', true);
	runMainFunc('disableLight');
end

local firstMove = true;
local timers = {
	['updateSec'] = function()
		r.dir = getRandomInt(1, 2);
	end,
	['bonnieMove'] = function()
		if firstMove then
			firstMove = false;
			if getVar('chicaMoved') then return; end
		end
		
		if getRandomInt(1, 20) <= r.ai then moveRobot(); end
	end
}
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
