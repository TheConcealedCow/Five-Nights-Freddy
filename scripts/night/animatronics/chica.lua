r = {
	ai = 20,
	
	cam = 1,
	dir = 0,
	tryingOffice = false,
	
	moveTree = {
		[1] = {2, 2}, -- too lazy to check table lengths
		[2] = {11, 10},
		[7] = {2, 8},
		[8] = {7, 50},
		[10] = {11, 7},
		[11] = {10, 7},
		[50] = {1, 1}
	}
}
function onCreate()
	setCamRobot(r.cam, 3, 'CHICA');
	
	setVar('chicaMoved', false);
	setVar('rightAtDoor', false);
	setVar('rightSnd', false);
	
	runTimer('chicaMove', pl(4.97), 0);
end

local canRand = {
	[2] = true,
	[7] = true,
	[11] = true
}
function updateRoom(n)
	setCamRobot(r.cam, 3, '');
	
	r.cam = n;
	
	setCamRobot(n, 3, 'CHICA' .. (canRand[n] and getRandomInt(1, 2) or '')); -- dining room, bathroom, 4A
end

function onUpdatePost(e)
	if r.tryingOffice then tryEnter(); end
end

function moveRobot()
	if r.cam == 100 then return; end
	
	local want = r.moveTree[r.cam][r.dir];
	
	if want == 50 or r.cam == 50 then -- she want go window or she at window
		if r.tryingOffice then return; end
		
		if want == 50 then
			setVar('rightAtDoor', true);
			playAnim('rightOfficeLight', 'rCHICA', true);
			runMainFunc('disableLight');
			
			setCamRobot(r.cam, 3, '');
			
			r.cam = 50;
		else
			tryEnter();
		end
		
		return;
	end
	
	updateRoom(want);
end

function tryEnter()
	local doorPhase = getMainVar('rightDoor').phase;
	r.tryingOffice = true;
	
	if doorPhase == 0 then
		r.tryingOffice = false;
		r.cam = 100;
		
		leaveLight();
		doorProp('right', 'stuck', true);
	elseif doorPhase == 2 then
		r.tryingOffice = false;
		leaveLight();
		
		r.cam = 7;
		setCamRobot(7, 3, 'CHICA' .. getRandomInt(1, 2));
	end
end

function leaveLight()
	setVar('rightSnd', false);
	setVar('rightAtDoor', false);
	playAnim('rightOfficeLight', 'r', true);
	runMainFunc('disableLight');
end

local timers = {
	['updateSec'] = function()
		r.dir = getRandomInt(1, 2);
	end,
	['chicaMove'] = function()
		if getRandomInt(1, 20) <= r.ai then
			setVar('chicaMoved', true);
			moveRobot();
		end
	end
}
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
