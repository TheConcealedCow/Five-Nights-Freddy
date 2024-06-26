r = {
	ai = 0,
	
	cam = 1,
	dir = 0,
	
	timeKitchen = 0,
	tryingOffice = false,
	
	moveTree = {
		[1] = {2, 2}, -- 0.1, 0.1 too lazy to check table lengths
		[2] = {11, 10}, -- 
		[7] = {2, 8},
		[8] = {7, 50},
		[10] = {11, 7},
		[11] = {10, 7},
		[50] = {1, 1}
	},
	soundMove = {
		[1] = {0.1, 0.1},
		[2] = {0.1, 0.1},
		[7] = {0.3, 0.3},
		[8] = {0.4, 0.4},
		[10] = {0.1, 0.2},
		[11] = {0.2, 0.2}
	}
}
function onCreate()
	runHaxeCode([[
		createGlobalCallback('addChica', function() {
			parentLua.call('addAI', []);
		});
	]]);
	
	setCamRobot(r.cam, 3, 'CHICA');
	
	setVar('chicaMoved', false);
	setVar('rightAtDoor', false);
	setVar('rightSnd', false);
	
	runTimer('chicaMove', pl(4.97), 0);
	
	makeAnimatedLuaSprite('scareCHICA', 'gameAssets/jumpscares/chica');
	addAnimationByPrefix('scareCHICA', 'scare', 'Scare', 30, false);
	addScareSlot('scareCHICA');
end

local canRand = {
	[2] = true,
	[7] = true,
	[11] = true
}
function updateRoom(n)
	local prev = r.cam;
	setCamRobot(r.cam, 3, '');
	r.cam = n;
	setCamRobot(n, 3, 'CHICA' .. (canRand[n] and getRandomInt(1, 2) or '')); -- dining room, bathroom, 4A
	addBugTrigger(prev, n);
end

function onUpdatePost(e)
	e = e * playbackRate;
	
	if r.tryingOffice then tryEnter(); end
	
	if r.cam == 10 then
		r.timeKitchen = r.timeKitchen + e;
		while r.timeKitchen >= 4 do
			r.timeKitchen = r.timeKitchen - 4;
			
			runMainFunc('kitchenChanceSnd');
		end
	end
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
	
	doSound('deepSteps', r.soundMove[r.dir], 'chicaStep');
	updateRoom(want);
	if r.cam ~= 10 then setSoundVolume('kitchenSnd', 0); end
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
		doSound('deepSteps', 0.4, 'chicaStep');
	end
end

function leaveLight()
	setVar('rightSnd', false);
	setVar('rightAtDoor', false);
	playAnim('rightOfficeLight', 'r', true);
	runMainFunc('disableLight');
end

function addAI()
	r.ai = r.ai + 1;
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
