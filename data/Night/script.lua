local night = 'gameAssets/night/'; -- 65535
local hud = night .. 'hud/';
local office = night .. 'office/';
local panel = night .. 'panel/';
local HITBOX = 'hitboxes/HITBOX';

curCam = 1;

local curNight = 1;
local curHour = 12; -- next hour is 1, then so on
local curMin = 0; -- when the next hour hits reset this to 1
local power = 999;

local staticBase = 0;

local callMuted = true;

local seenYellow = false;
local yellowPhase = 0;
local lookYellow = 0;
local staticStuck = 0;
local camBugging = false;
wasGot = false;
slotGot = 0;
gotYou = false;

local bugVal = 0;

local randForPic = 0;

local camTriggers = {};

itsMe = false;

local bugRobot = 0;
local bugRobotView = 0;

local outOfPower = false;
local buzzPower = false;
local doNothing = false;

--[[
	TODO:
	 - make saves and going to menu work after rudy pushes the menu stuff!!
	 - find more things todo n fix!!
]]
function create()
	luaDebugMode = true;
	
	runHaxeCode([[
		import openfl.filters.ShaderFilter;
		import flixel.FlxCamera;
		import psychlua.LuaUtils;
		
		var shad = game.createRuntimeShader('panorama');
		var perspShader = new ShaderFilter(shad);
		
		var mainCam = FlxG.cameras.add(new FlxCamera(-22, -22, 1324, 754), false);
		mainCam.setFilters([perspShader]);
		mainCam.pixelPerfectRender = true;
		mainCam.antialiasing = false;
		mainCam.scroll.set(-22, -22);
		setVar('mainCam', mainCam);
		
		var hitboxCam = FlxG.cameras.add(new FlxCamera(0, 0, 1280, 720), false);
		hitboxCam.bgColor = 0x00000000;
		hitboxCam.alpha = 0;
		setVar('hitboxCam', hitboxCam);
		
		var cameraCam = FlxG.cameras.add(new FlxCamera(-22, -22, 1324, 754), false);
		cameraCam.setFilters([perspShader]);
		cameraCam.pixelPerfectRender = true;
		cameraCam.antialiasing = false;
		cameraCam.scroll.set(-22, -22);
		cameraCam.alpha = 0.00001;
		setVar('cameraCam', cameraCam);
		
		var panelOvCam = FlxG.cameras.add(new FlxCamera(0, 0, 1280, 720), false);
		panelOvCam.bgColor = 0x00000000;
		panelOvCam.alpha = 0.00001;
		setVar('panelOvCam', panelOvCam);
		
		var hudCam = FlxG.cameras.add(new FlxCamera(0, 0, 1280, 720), false);
		hudCam.bgColor = 0x00000000;
		setVar('hudCam', hudCam);
		
		var panelCam = FlxG.cameras.add(new FlxCamera(0, 0, 1280, 720), false);
		panelCam.bgColor = 0x00000000;
		panelCam.pixelPerfectRender = true;
		setVar('panelCam', panelCam);
		
		var halluCam = FlxG.cameras.add(new FlxCamera(0, 0, 1280, 720), false);
		halluCam.bgColor = 0xFF000000;
		halluCam.pixelPerfectRender = true;
		halluCam.alpha = 0.00001;
		setVar('halluCam', halluCam);
		
		var hitboxHudCam = FlxG.cameras.add(new FlxCamera(0, 0, 1280, 720), false);
		hitboxHudCam.bgColor = 0x00000000;
		hitboxHudCam.alpha = 0;
		setVar('hitboxHudCam', hitboxHudCam);
		
		var endCam = FlxG.cameras.add(new FlxCamera(0, 0, 1280, 720), false);
		endCam.pixelPerfectRender = true;
		endCam.antialiasing = false;
		endCam.bgColor = 0xFF000000;
		endCam.alpha = 0.00001;
		setVar('endCam', endCam);
		
		var allObjs = [];
		createCallback('addBoxCam', function(o, f, r) {
			var obj = LuaUtils.getObjectDirectly(o);
			if (obj == null) return;
			
			obj.camera = hitboxCam;
			setVar('OBJHITPR_' + o, [obj, obj.x, obj.y, f, r]);
			allObjs.push(o);
		});
		
		createCallback('officeClick', function() {
			for (o in allObjs) {
				var props = getVar('OBJHITPR_' + o);
				var obj = props[0];
				if (obj != null && FlxG.mouse.overlaps(obj, hitboxCam)) {
					var toCall = [ props[3], props[4] ];
					if (toCall[0] != null && toCall[0] != '') parentLua.call(toCall[0], [ toCall[1] ]);
				}
			}
		});
		
		createCallback('finAnim', function(o, f, s) {
			var obj = LuaUtils.getObjectDirectly(o);
			if (obj == null) return;
			
			obj.animation.finishCallback = function(n) {
				parentLua.call(f, [s, n, obj.animation.curAnim.reversed]);
			}
		});
		
		createGlobalCallback('setCamRobot', function(c, i, r) {
			parentLua.call('setRobotRoom', [c, i, r]);
		});
		
		createGlobalCallback('getMainVar', function(v) {
			return parentLua.call('varMain', [v]);
		});
		
		createGlobalCallback('setMainVar', function(v, f) {
			parentLua.call('varSetMain', [v, f]);
		});

		createGlobalCallback('runMainFunc', function(v, ?n) {
			return parentLua.call('mainFunc', [v, n]);
		});
		
		createGlobalCallback('doorProp', function(d, p, v) {
			parentLua.call('propDoor', [d, p, v]);
		});
		
		createGlobalCallback('addBugTrigger', function(a, b) {
			parentLua.call('setBugTrigger', [a, b]);
		});
		
		createGlobalCallback('addScareSlot', function(t, s, y) {
			parentLua.call('addScare', [t, s, y]);
		});
		
		createCallback('objFrameChange', function(o, c) {
			var obj = LuaUtils.getObjectDirectly(o);
			
			obj.animation.callback = function(n, f) {
				parentLua.call(c, [f]);
			}
		});
		
		function killCams() {
			FlxG.cameras.remove(mainCam);
			FlxG.cameras.remove(cameraCam);
			FlxG.cameras.remove(panelOvCam);
			FlxG.cameras.remove(hudCam);
			FlxG.cameras.remove(panelCam);
			FlxG.cameras.remove(halluCam);
		}
		
		function panelCol(t) {
			panelOvCam.bgColor = (t ? 0xFF000000 : 0x00000000);
		}
		
		function updateScroll(x) {
			var realX = (x - 640);
			
			mainCam.scroll.x = -22 + realX;
			updateBoxes(realX);
		}
		
		function camUpdatePos(x) {
			var realX = (x - 640);
			
			cameraCam.scroll.x = -22 + realX;
		}
		
		function updateBoxes(x) {
			for (o in allObjs) {
				var props = getVar('OBJHITPR_' + o);
				props[0].x = props[1] - x;
			}
		}
		
		function killSounds() {
			// manually destroying all of the sounds cuz `FlxG.sound.destroy(true);` crashes the game
			while (FlxG.sound.list.members.length > 0) {
				final sound:FlxSound = FlxG.sound.list.members[FlxG.sound.list.members.length - 1];

				if (sound == null) {
					FlxG.sound.list.members.remove(sound);
					continue;
				}

				sound.stop();
				FlxG.sound.list.members.pop();
			}
		}
		
		function stopAllStuff() {
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) tmr.active = false); // copy pasted this part from Rudy!!
			
			// manually destroying all of the sounds cuz `FlxG.sound.destroy(true);` crashes the game
			while (FlxG.sound.list.members.length > 0) {
				final sound:FlxSound = FlxG.sound.list.members[FlxG.sound.list.members.length - 1];

				if (sound == null) {
					FlxG.sound.list.members.remove(sound);
					continue;
				}
				
				sound.stop();
				FlxG.sound.list.members.pop();
			}
			
			for (obj in game.members) if (Std.isOfType(obj, FlxSprite) && obj.active) obj.active = false;
		}
		
		updateScroll(640);
	]]);
	
	addLuaScript('scripts/objects/COUNTERDOUBDIGIT');
	
	checkHalloween();
	makeOffice();
	
	makePanel();
	makeHUD();
	make6Am();
	
	cacheSounds();
	
	setVar('jumpscared', false);
	setVar('interCam3Sfx', false);
	setVar('night', curNight);
	
	addLuaScript('scripts/night/animatronics/foxy');
	addLuaScript('scripts/night/animatronics/freddy');
	addLuaScript('scripts/night/animatronics/chica');
	addLuaScript('scripts/night/animatronics/bonnie');
	
	randForPic = getRandomInt(1, 100);
	
	doSound('buzzFan', 0.25, 'fanSound', true);
	doSound('coldPresc', 0.5, 'bgAmb', true);
	doSound('humMed2', 0, 'lightHum', true);
	doSound('robotVoice', 0, 'robotVoice', true);
	doSound('eerieAmb', 0, 'scaryAmb', true);
	
	startCall();
	
	runTimer('updateSec', pl(1), 0);
	if curNight > 1 then runTimer('extraDrain', bound(-curNight + 8, 3, 6), 0); end
	if curNight >= 4 then runTimer('robotBug', pl(0.05), 0); end
	runTimer('randCircus', pl(5), 0);
	runTimer('randDoorSound', pl(10), 0);
	runTimer('randStartFred', pl(5), 0); -- im fucking killing you scott
	runTimer('hideStuff', 0.1);
end

local isHalloween = false;
function checkHalloween()
	local d = os.date();
	local s = stringSplit(d, '/');
	local month = s[1];
	local day = s[2]
	
	isHalloween = (month == 10 and day == 31); -- this is halloween
end

function makeOffice()
	makeLuaSprite('office', office .. 'office');
	setCam('office');
	addLuaSprite('office');
	
	makeAnimatedLuaSprite('leftOfficeLight', office .. 'l/left');
	addAnimationByPrefix('leftOfficeLight', 'l', 'LeftLight', 1);
	addAnimationByPrefix('leftOfficeLight', 'lBONNIE', 'LeftBonnie', 1);
	playAnim('leftOfficeLight', 'l', true);
	setCam('leftOfficeLight');
	addLuaSprite('leftOfficeLight');
	setAlpha('leftOfficeLight', 0.00001);
	
	makeAnimatedLuaSprite('rightOfficeLight', office .. 'l/right');
	addAnimationByPrefix('rightOfficeLight', 'r', 'RightLight', 1);
	addAnimationByPrefix('rightOfficeLight', 'rCHICA', 'RightChica', 1);
	playAnim('rightOfficeLight', 'r', true);
	setCam('rightOfficeLight');
	addLuaSprite('rightOfficeLight');
	setAlpha('rightOfficeLight', 0.00001);
	
	makeLuaSprite('scareLayer');
	setCam('scareLayer');
	addLuaSprite('scareLayer');
	setAlpha('scareLayer', 0);
	
	makeAnimatedLuaSprite('officeNoPower', office .. 'officeNoPower');
	addAnimationByPrefix('officeNoPower', 'g', 'Office', 0, false);
	playAnim('officeNoPower', 'g', true);
	setCam('officeNoPower');
	addLuaSprite('officeNoPower');
	setAlpha('officeNoPower', 0.00001);
	
	makeAnimatedLuaSprite('fan', office .. 'o/fan', 868 - 88, 400 - 97);
	addAnimationByPrefix('fan', 'fan', 'Fan', 59);
	setFrameRate('fan', 'fan', 59.4);
	playAnim('fan', 'fan', true);
	setCam('fan');
	addLuaSprite('fan');
	
	makeDoors();
	
	if isHalloween then
		makeAnimatedLuaSprite('pump', office .. 'o/h/pumpkin', 734 - 71, 485 - 130);
		addAnimationByPrefix('pump', 'glow', 'Glow', 15);
		playAnim('pump', 'glow', true);
		setCam('pump');
		addLuaSprite('pump');
		
		makeLuaSprite('lightHallow', office .. 'o/h/lights', 0, -78);
		setCam('lightHallow');
		addLuaSprite('lightHallow');
	end
	
	makeLuaSprite('yellowBear', office .. 'o/yellowBear', 660 - 270, 478 - 260);
	setCam('yellowBear');
	addLuaSprite('yellowBear');
	setAlpha('yellowBear', 0.00001);
	
	makeLuaSprite('noseBox', HITBOX, 678 - 4, 240 - 4);
	scaleObject('noseBox', 8, 8);
	addBoxCam('noseBox', 'noseFunc', '');
	addLuaSprite('noseBox');
end

local clickCool = 0;
lightOn = false;
local lastLightOn = '';
function makeDoors()
	for _, d in pairs({'left', 'right'}) do
		_G[d .. 'Door'] = {
			clicked = false, -- if it is in the closed state or open state
			fullClick = false, -- fully open or fully closed
			midPhase = false, -- in the middle of opening / closing
			light = false, -- if the light has been tapped
			stuck = false, -- if the door is stuck
			phase = 0, -- current door phase for whatever
			drain = 0, -- current door drain value
		};
	end
	
	makeAnimatedLuaSprite('leftDoor', office .. 'o/d/d/left', 72, -1);
	addAnimationByPrefix('leftDoor', 'open', 'Open', 1);
	addAnimationByPrefix('leftDoor', 'closed', 'Closed', 1);
	addAnimationByPrefix('leftDoor', 'closing', 'Closing', 30, false);
	playAnim('leftDoor', 'open', true);
	finAnim('leftDoor', 'doorFin', 'left');
	setCam('leftDoor');
	addLuaSprite('leftDoor');
	
	makeAnimatedLuaSprite('rightDoor', office .. 'o/d/d/right', 1270, -2);
	addAnimationByPrefix('rightDoor', 'open', 'Open', 1);
	addAnimationByPrefix('rightDoor', 'closed', 'Closed', 1);
	addAnimationByPrefix('rightDoor', 'closing', 'Closing', 30, false);
	playAnim('rightDoor', 'open', true);
	finAnim('rightDoor', 'doorFin', 'right');
	setCam('rightDoor');
	addLuaSprite('rightDoor');
	
	
	makeAnimatedLuaSprite('leftButton', office .. 'o/d/l/left', 48 - 42, 390 - 127);
	addAnimationByPrefix('leftButton', 'L', 'LOFF');
	addAnimationByPrefix('leftButton', 'LDOOR', 'LDOOR');
	addAnimationByPrefix('leftButton', 'LLIGHT', 'LLIGHT');
	addAnimationByPrefix('leftButton', 'LDOORLIGHT', 'LBOTH');
	playAnim('leftButton', 'L', true);
	setCam('leftButton');
	addLuaSprite('leftButton');
	
	makeAnimatedLuaSprite('rightButton', office .. 'o/d/l/right', 1546 - 49, 400 - 127);
	addAnimationByPrefix('rightButton', 'R', 'ROFF');
	addAnimationByPrefix('rightButton', 'RDOOR', 'RDOOR');
	addAnimationByPrefix('rightButton', 'RLIGHT', 'RLIGHT');
	addAnimationByPrefix('rightButton', 'RDOORLIGHT', 'RBOTH');
	playAnim('rightButton', 'R', true);
	setCam('rightButton');
	addLuaSprite('rightButton');
	
	
	makeLuaSprite('leftBoxDoor', HITBOX, 54 - 29, 307 - 56);
	scaleObject('leftBoxDoor', 62, 120);
	addBoxCam('leftBoxDoor', 'doorFunc', 'left');
	addLuaSprite('leftBoxDoor');
	
	makeLuaSprite('leftBoxLight', HITBOX, 54 - 29, 449 - 56);
	scaleObject('leftBoxLight', 62, 120);
	addBoxCam('leftBoxLight', 'lightFunc', 'left');
	addLuaSprite('leftBoxLight');
	
	
	makeLuaSprite('rightBoxDoor', HITBOX, 1538 - 29, 323 - 56);
	scaleObject('rightBoxDoor', 62, 120);
	addBoxCam('rightBoxDoor', 'doorFunc', 'right');
	addLuaSprite('rightBoxDoor');
	
	makeLuaSprite('rightBoxLight', HITBOX, 1538 - 29, 454 - 56);
	scaleObject('rightBoxLight', 62, 120);
	addBoxCam('rightBoxLight', 'lightFunc', 'right');
	addLuaSprite('rightBoxLight');
end

local markerPos = {{983, 353}, {963, 409}, {931, 487}, {983, 603}, {983, 643}, {899, 585}, {1089, 604}, {1089, 644}, {857, 436}, {1186, 568}, {1195, 437}};
local camNamePos = {{961, 341}, {939, 397}, {908, 475}, {960, 590}, {960, 630}, {877, 574}, {1066, 592}, {1066, 632}, {834, 424}, {1163, 556}, {1174, 424}};
local markerNames = {'1A', '1B', '1C', '2A', '2B', '3', '4A', '4B', '5', '6', '7'};

cameraProps = {};
function makePanel()
	makeAnimatedLuaSprite('panel', panel .. 'panel');
	addAnimationByPrefix('panel', 'panel', 'Panel', 30, false);
	playAnim('panel', 'panel', true);
	finAnim('panel', 'panelFin', '');
	setCam('panel', 'panelCam');
	addLuaSprite('panel');
	setAlpha('panel', 0.00001);
	
	
	staticBase = Random(3);
	makeAnimatedLuaSprite('staticCam', panel .. 'hud/static');
	addAnimationByPrefix('staticCam', 'static', 'Satic', 60);
	playAnim('staticCam', 'static', true);
	setCam('staticCam', 'panelOvCam');
	addLuaSprite('staticCam');
	updateStaticAlpha();
	
	makeLuaSprite('frameCam', panel .. 'hud/frame');
	setCam('frameCam', 'panelOvCam');
	addLuaSprite('frameCam');
	
	
	makeAnimatedLuaSprite('rec', panel .. 'hud/rec', 92 - 24, 76 - 24);
	addAnimationByPrefix('rec', 'rec', 'Rec', 1);
	setFrameRate('rec', 'rec', 1.2);
	playAnim('rec', 'rec', true);
	setCam('rec', 'panelOvCam');
	addLuaSprite('rec');
	
	makeLuaSprite('noVideo', hud .. 'audioOnly', 384 + 80, 69);
	setCam('noVideo', 'panelOvCam');
	addLuaSprite('noVideo');
	setAlpha('noVideo', 0.00001);
	
	
	makeAnimatedLuaSprite('map', panel .. 'hud/map', 848, 313);
	addAnimationByPrefix('map', 'map', 'Map', 1);
	setFrameRate('map', 'map', 1.2);
	playAnim('map', 'map', true);
	setCam('map', 'panelOvCam');
	addLuaSprite('map');
	
	makeAnimatedLuaSprite('roomNames', panel .. 'cams/roomNames', 832, 292);
	addAnimationByPrefix('roomNames', 'cam', 'Cam', 0, false);
	playAnim('roomNames', 'cam', true);
	setCam('roomNames', 'panelOvCam');
	addLuaSprite('roomNames');
	
	makeLuaSprite('blipLayer');
	setCam('blipLayer', 'panelOvCam');
	addLuaSprite('blipLayer');
	setAlpha('blipLayer', 0);
	
	
	for i = 1, 11 do
		local t = i .. 'Cam';
		local m = i .. 'Marker';
		local c = m .. 'Name';
		local a = markerNames[i];
		
		table.insert(cameraProps, {
			slots = {'', '', '', ''}; -- waow
		});
		
		if i ~= 10 then
			makeAnimatedLuaSprite(t, panel .. 'cams/cams/cam' .. a);
			addAnimationByPrefix(t, 'cam', 'Cam', 0, false);
			playAnim(t, 'cam', true);
			setCam(t, 'cameraCam');
			addLuaSprite(t);
			setAlpha(t, 0.00001);
		end
		
		makeAnimatedLuaSprite(m, panel .. 'hud/camFrame', markerPos[i][1] - 29, markerPos[i][2] - 19);
		addAnimationByPrefix(m, 'idle', 'Idle', 1);
		addAnimationByPrefix(m, 'glow', 'Sel', 1);
		setFrameRate(m, 'glow', 1.8);
		playAnim(m, 'idle', true);
		setCam(m, 'panelOvCam');
		addLuaSprite(m);
		
		makeLuaSprite(c, panel .. 'cams/markers/cam' .. a, camNamePos[i][1], camNamePos[i][2]);
		setCam(c, 'panelOvCam');
		addLuaSprite(c);
	end
	
	makeAnimatedLuaSprite('cam2AFox', panel .. 'cams/cams/cam2AFoxy');
	addAnimationByPrefix('cam2AFox', 'cam', 'Foxy', 39, false);
	playAnim('cam2AFox', 'cam', true);
	setCam('cam2AFox', 'cameraCam');
	addLuaSprite('cam2AFox');
	setAlpha('cam2AFox', 0.00001);
end

function makeHUD()
	makeLuaSprite('panelShow', HITBOX, 589 - 496, 599 - 38);
	scaleObject('panelShow', 1070, 82);
	setCam('panelShow', 'hitboxHudCam');
	addLuaSprite('panelShow');
	
	makeLuaSprite('panelUp', HITBOX, 442 - 367, 691 - 38);
	scaleObject('panelUp', 792, 82);
	setCam('panelUp', 'hitboxHudCam');
	addLuaSprite('panelUp');
	

	makeLuaSprite('panelFlick', hud .. 'panelTab', 554 - 299, 668 - 30);
	setCam('panelFlick', 'hudCam');
	addLuaSprite('panelFlick');
	
	
	
	makeCounterSpr('hourNum', 1185, 59, curHour);
	setCam('hourNum', 'hudCam');
	addLuaSprite('hourNum');
	
	makeLuaSprite('amTxt', hud .. 'am', 1198 + 2, 31);
	setCam('amTxt', 'hudCam');
	addLuaSprite('amTxt');
	
	
	makeLuaSprite('nightTxt', hud .. 'night', 754 + 394, 74);
	setCam('nightTxt', 'hudCam');
	addLuaSprite('nightTxt');
	
	makeCounterSpr('nightNum', 1237, 89, curNight, hud .. 'nums/nightNum/num');
	setCam('nightNum', 'hudCam');
	addLuaSprite('nightNum');
	
	
	
	makeLuaSprite('powerLeft', hud .. 'powerLeft', 106 - 68, 638 - 7);
	setCam('powerLeft', 'hudCam');
	addLuaSprite('powerLeft');
	
	makeCounterSpr('powerNum', 221, 646, math.floor(power / 10), hud .. 'nums/power/num');
	setCam('powerNum', 'hudCam');
	addLuaSprite('powerNum');
	
	makeLuaSprite('powerPer', hud .. 'per', -196 + 420, 632);
	setCam('powerPer', 'hudCam');
	addLuaSprite('powerPer');
	
	
	makeLuaSprite('powerUse', hud .. 'Usage', 74 - 36, 674 - 7);
	setCam('powerUse', 'hudCam');
	addLuaSprite('powerUse');
	
	makeAnimatedLuaSprite('powerBar', hud .. 'useBar', 120, 657);
	addAnimationByPrefix('powerBar', 'bar', 'Use', 0, false);
	playAnim('powerBar', 'bar', true);
	setCam('powerBar', 'hudCam');
	addLuaSprite('powerBar');
	
	if curNight < 6 then
		makeLuaSprite('muteCall', hud .. 'muteCall', 87 - 60, 37 - 15);
		setCam('muteCall', 'hudCam');
		addLuaSprite('muteCall');
		setAlpha('muteCall', 0.00001);
	end
	
	
	makeAnimatedLuaSprite('itsMe', night .. 'fx/itsMe');
	addAnimationByPrefix('itsMe', 'scare', 'Scare', 45);
	playAnim('itsMe', 'scare', true);
	setCam('itsMe', 'halluCam');
	addLuaSprite('itsMe');
end

local doing6Am = false;
function make6Am()
	makeLuaSprite('amSpr', 'gameAssets/NextDay/AMText', 645, 296);
	setCam('amSpr', 'endCam');
	addLuaSprite('amSpr');
	
	makeLuaSprite('5Spr', 'gameAssets/NextDay/5', 549, 298);
	setCam('5Spr', 'endCam');
	addLuaSprite('5Spr');
	
	makeLuaSprite('6Spr', 'gameAssets/NextDay/6', 549 + 4, 408);
	setCam('6Spr', 'endCam');
	addLuaSprite('6Spr');
	
	makeLuaSprite('topCover', nil, 572 - 74, 224 - 55);
	makeGraphic('topCover', 1, 1, '000000');
	scaleObject('topCover', 158, 118);
	setCam('topCover', 'endCam');
	addLuaSprite('topCover');
	setVis('topCover', false);
	
	makeLuaSprite('botCover', nil, 573 - 74, 440 - 55);
	makeGraphic('botCover', 1, 1, '000000');
	scaleObject('botCover', 158, 118);
	setCam('botCover', 'endCam');
	addLuaSprite('botCover');
	setVis('botCover', false);
end

function startCall()
	if curNight > 5 then return; end
	
	doSound('call' .. curNight, 1, 'voiceOver');
	callMuted = false;
	
	runTimer('showMute', pl(20));
end
 
local scareSlots = {};
local curScare = '';
function addScare(t, s, y)
	scareSlots[s] = {
		tag = t,
		ty = y
	}
end

--[[ scare types
	type 1: panel	
		- when in panels theres a 1 in 5 chance for the scare to happen next time you pull it down
		- after 20 seconds, it is automatically pulled down
	type 2: office
		- when in office theres a 1 in 5 chance for the scare to occur
	type 3: foxy
		- works like office but doesnt hide a lot of the office elements
]]
local scares = {
	[1] = function(s)
		setAlpha(s.tag, 1);
		playAnim(s.tag, 'scare', true);
		
		hideOffice();
		
		runTimer('scareSndTime', pl(9 / 60));
		runTimer('toDeathTimer', pl(39 / 60));
	end,
	[2] = function(s)
		setAlpha(s.tag, 1);
		playAnim(s.tag, 'scare', true);
		objFrameChange(s.tag, 'scareFrame');
		finAnim(s.tag, 'toDied', '');
		
		hideOffice();
	end,
	[3] = function(s)
		setAlpha('office', 0);
		setAlpha('leftDoor', 0);
		setAlpha('rightDoor', 0);
		
		doSound('xScream', 1, 'scareSnd');
		
		setAlpha(s.tag, 1);
		playAnim(s.tag, 'scare', true);
		finAnim(s.tag, 'toDied', '');
	end
}
function triggerScare(s)
	if getVar('jumpscared') or outOfPower then return; end
	setVar('jumpscared', true);
	
	goYelBear();
	disableLight();
	
	local slot = scareSlots[s];
	scares[slot.ty](slot);
	curScare = slot.tag;
end

function killScare() -- kills the scare, for the powerout :)
	if curScare ~= '' then
		setAlpha(curScare, 0);
	end
end

local didScareSnd = false;
function scareFrame(f)
	if f >= 7 and not didScareSnd and not outOfPower then
		didScareSnd = true;
		
		doSound('xScream', 1, 'scareSnd');
	end
end

function toDied()
	if not outOfPower then
		switchState('died');
	end
end

function hideOffice()
	setAlpha('leftDoor', 0);
	setAlpha('rightDoor', 0);
	setAlpha('leftButton', 0);
	setAlpha('rightButton', 0);
	setAlpha('office', 0);
	
	setAlpha('fan', 0);
	if isHalloween then
		setAlpha('pump', 0);
		setAlpha('lightHallow', 0);
	end
end

local tickRate = 0;
local xCam = 640;
local viewingOffice = true;
local isFlick = true;

local viewingBug = false;
local hoverPanel = false;
local canFlip = true;
local inCams = false; -- triggered the panel flick
viewingCams = false; -- actually LOOKING in the cams

local curUsage = 1;
leftDrain = 0;
rightDrain = 0;
lightDrain = 0;
panelDrain = 0;
function onUpdatePost(e)
	e = e * playbackRate;
	local ti = (e * 60);
	
	if doing6Am or doNothing then return; end
	
	clickCool = clickCool - ti;
	updateCam(ti);
	checkPanel();
	
	if not outOfPower then
		for i = 1, 11 do
			if camTriggers[i] then
				camTriggers[i] = camTriggers[i] - ti;
				
				if camTriggers[i] <= 0 then camTriggers[i] = nil; end
			end
		end
		
		if camBugging then
			staticStuck = staticStuck - ti;
			
			if staticStuck <= 0 then
				runHaxeFunction('panelCol', {false});
				setVis('cameraCam', true);
				camBugging = false;
				
				onNewCam();
			end
		end
		
		if not callMuted and mouseClicked() and mouseOverlaps('muteCall') then
			callMuted = true;
			stopSound('voiceOver');
			removeLuaSprite('muteCall');
		end
		
		if viewingBug then
			bugRobotView = bugRobotView + e;
			
			while bugRobotView >= 0.1 do
				bugRobotView = bugRobotView - 0.1;
				
				if not itsMe then
					local vol = 1 + (Random(5) * 20);
					setSoundVolume('robotVoice', vol / 100);
				end
			end
		else
			bugRobot = bugRobot + e;
			
			while bugRobot >= 0.1 do
				bugRobot = bugRobot - 0.1;
				
				if not itsMe then
					local vol = 1 + (Random(5) * 5);
					setSoundVolume('robotVoice', vol / 100);
				end
			end
		end
	else
		if leftDoor.phase == 2 then
			doorFunc('left', true);
		end
		if rightDoor.phase == 2 then
			doorFunc('right', true);
		end
		
		if viewingCams then trigPanel(); setAlpha('fan', 0); end
	end
	
	tickRate = tickRate + e;
	while (tickRate >= 1 / 60) do
		tickRate = tickRate - (1 / 60);
		tickUpdate();
	end
end

local flickerCam = false;
function tickUpdate()
	isFlick = (getRandomInt(1, 10) > 1); -- i love flickering
	
	if not outOfPower then -- elseif owie
		setVis('leftOfficeLight', isFlick);
		setVis('rightOfficeLight', isFlick);
	
		if lightOn then
			setSoundVolume('lightHum', isFlick);
		end
	
		flickerCam = (getRandomInt(1, 10) <= 3);
		if curCam == 4 then updateACam(); end
	elseif buzzPower then
		local b = getRandomBool();
		
		setVis('mainCam', b);
		setSoundVolume('buzzFlicker', (b and 0.5 or 0));
	end
	
	
	if itsMe then setVis('halluCam', (Random(10) == 1)); end
	
	updateStaticAlpha();
end

function updateUsage()
	curUsage = 1 + leftDrain + rightDrain + lightDrain + panelDrain;
	
	setFrame('powerBar', curUsage - 1);
end

local camMoves = {
	{
		x = 153,
		p = -7
	},
	{
		x = 315,
		p = -2
	},
	
	{
		x = 539,
		p = 0
	},
	
	{
		x = 759,
		p = 2
	},
	{
		x = 999,
		p = 7
	},
	{
		x = 1143,
		p = 12
	}
};
local camFollow = { -- if youre looking at cam 3, the cam doesnt move wahoo
	phase = 0,
	totTime = 0,
};
local posCam = 640;
function updateCam(t)
	if not outOfPower then updateCamMove(t); end
	
	moveCam(t);
end

function updateCamMove(t)
	local movePhase = (camFollow.phase % 2 == 0);
	local timeIn = (movePhase and 320 or 100);
	
	camFollow.totTime = camFollow.totTime + t;
	
	if movePhase then
		local back = camFollow.phase == 2;
		posCam = 640 + ((bound(camFollow.totTime, 0, 320) * (back and -1 or 1)) + (back and 320 or 0));
	end
	
	if camFollow.totTime >= timeIn then
		camFollow.totTime = 0;
		camFollow.phase = (camFollow.phase + 1) % 4;
	end
end

function moveCam(t)
	if not viewingOffice then 
		if viewingCams then
			if mouseClicked() then camsClick(); end
			
			if curCam ~= 6 then
				runHaxeFunction('camUpdatePos', {posCam});
			end
		end
	else
		local camSpd = -12; -- so we can ignore the first one :)
		local m = camMouseX();
		
		for i = 1, #camMoves do
			if m > camMoves[i].x then
				camSpd = camMoves[i].p;
			else break; end
		end
		
		xCam = bound(xCam + (camSpd * t), 640, 960);
		runHaxeFunction('updateScroll', {xCam});
		
		if mouseClicked() then officeClick(); end
	end
end

local leaveCam = {
	[3] = function()
		setSoundVolume('cam3Sfx', 0.05);
	end,
	[4] = function()
		setVis('cam2AFox', false);
		setAlpha('cam2AFox', 0);
	end,
	[10] = function()
		setAlpha('noVideo', 0);
		
		if cameraProps[10].slots[3] ~= '' then setSoundVolume('kitchenSnd', (viewingCams and 0.2 or 0.1)); end
		setSoundVolume('fredKitchen', 0.05);
	end
}
function camsClick()
	for i = 1, 11 do
		if mouseOverlaps(i .. 'Marker') then
			if curCam ~= i then
				setAlpha(curCam .. 'Cam', 0);
				setAlpha(i .. 'Cam', 1);
			
				playAnim(curCam .. 'Marker', 'idle', true);
				playAnim(i .. 'Marker', 'glow', true);
				
				if leaveCam[curCam] then leaveCam[curCam](); end
				curCam = i;
			end
			
			onNewCam();
			cameraBlip();
		end
	end
end

local onCamFunc = {
	[3] = function()
		setSoundVolume('cam3Sfx', 0.15);
	end,
	[4] = function()
		setVis('cam2AFox', true);
		
		local ph = getVar('foxPhase');
		if ph == 3 then
			setVar('foxPhase', 4);
			setAlpha('cam2AFox', 1);
			playAnim('cam2AFox', 'cam', true);
			
			doSound('run', 1, 'foxRun');
		elseif ph > 3 then
			setAlpha('cam2AFox', 1);
		end
	end,
	[5] = function()
		if yellowPhase == 1 then
			doSound('laughGiggle1', 1, 'laughYellow');
			yellowPhase = 2;
		end
	end,
	[6] = function()
		runHaxeFunction('camUpdatePos', {640});
	end,
	[10] = function()
		setAlpha('noVideo', 1);
		if cameraProps[10].slots[3] ~= '' then setSoundVolume('kitchenSnd', 0.75); end
		setSoundVolume('fredKitchen', 0.5);
	end
}

function onNewCam()
	if onCamFunc[curCam] then onCamFunc[curCam](); end
	if camTriggers[curCam] then camStuck(); end
	setFrame('roomNames', curCam - 1);
	
	if curNight >= 4 then
		local view = cameraProps[curCam].slots;
		viewingBug = ((curCam == 5 or curCam == 8) and (view[2] == 'BONNIE' or view[3] == 'CHICA'));
	end
	updateACam();
end

local totBlips = 0;
function cameraBlip()
	doSound('blip', 1, 'blipSound');
	
	totBlips = totBlips + 1;
	local t = 'blipCam' .. totBlips;
	makeAnimatedLuaSprite(t, panel .. 'hud/blipCam');
	addAnimationByPrefix(t, 'blip', 'Blip', 42, false);
	playAnim(t, 'blip', true);
	setCam(t, 'panelOvCam');
	setObjectOrder(t, getObjectOrder('blipLayer'));
	removeOnFin(t);
end

local camsDisabled = false;
function checkPanel()
	if outOfPower or camsDisabled or getVar('jumpscared') then return; end
	
	if hoverPanel then
		if mouseOverlaps('panelShow') then
			hoverPanel = false;
		end
	else
		if canFlip then
			setAlpha('panelFlick', 1);
			
			if mouseOverlaps('panelUp') then
				trigPanel();
			end
		end
	end
end

function trigPanel()
	hoverPanel = true;
	setAlpha('panelFlick', 0);
	onPanelFunc();
end

local randSndGot = {'vocalsBreaths06', 'vocalsBreaths08', 'vocalsBreaths12', 'vocalsBreaths14'};
function randGotSound()
	local snd = getRandomInt(1, 4);
	
	if randSndGot[snd] then
		doSound(randSndGot[snd], 1, 'vocalsRand');
		table.remove(randSndGot, snd);
	end
end

function volEerieChecks() -- each individual one is worth 30, two of them equal 50, all of them together equal 75
	if getSoundVolume('scaryAmb') == 1 then return; end
	
	local tot = {};
	local vol = 0;
	local bonnieZone = false;
	local chicaZone = false;
	local foxyPhase = getVar('foxPhase') >= 2;
	
	for i = 4, 8 do
		if cameraProps[i].slots[2] ~= '' then bonnieZone = true; end
		if cameraProps[i].slots[3] ~= '' then chicaZone = true; end
	end
	
	if bonnieZone then table.insert(tot, 1); end
	if chicaZone then table.insert(tot, 1); end
	if foxyPhase then table.insert(tot, 1); end
	
	if #tot == 0 then
		setSoundVolume('scaryAmb', 0);
	else
		vol = (#tot * 25);
		if #tot == 1 then vol = 30; end
		
		setSoundVolume('scaryAmb', vol / 100);
	end
end

local panelTrig = false;
function onPanelFunc()
	canFlip = false;
	inCams = not inCams;
	
	viewingOffice = not inCams;
	if viewingOffice then
		if yellowPhase == 2 then
			yellowPhase = 3;
			
			triggerItsMe();
			setAlpha('yellowBear', 1);
			runTimer('yellowScare', pl(5));
		end
	
		setAlpha('mainCam', 1);
		setAlpha('fan', 1);
		
		exitCams();
		
		doSound('putDown', 1, 'panelSound');
	else
		setAlpha('fan', 0);
		
		doSound('camVidLoad', 1, 'panelSound');
	end
	
	panelTrig = true;
	setAlpha('panel', 1);
	playAnim('panel', 'panel', true, not inCams);
end

function panelFin()
	if not panelTrig then return; end
	panelTrig = false;
	canFlip = true;
	
	if inCams then
		viewingCams = true;
		
		setAlpha('mainCam', 0);
		enterCams();
	end
	
	setAlpha('panel', 0);
end

function enterCams()
	disableLight();
	panelDrain = 1;
	updateUsage();
	
	setAlpha(curCam .. 'Cam', 1);
	playAnim(curCam .. 'Marker', 'glow', true);
	
	goYelBear();
	cameraBlip();
	onNewCam();
	
	setAlpha('panelOvCam', 1);
	setAlpha('cameraCam', 1);
	
	doSound('tapeEject', 1, 'tapeSound');
	setSoundVolume('fanSound', 0.1);
end

function exitCams()
	viewingCams = false;
	panelDrain = 0;
	updateUsage();
	
	if leaveCam[curCam] then leaveCam[curCam](); end
	
	setAlpha(curCam .. 'Cam', 0);
	
	setAlpha('panelOvCam', 0);
	setAlpha('cameraCam', 0);
	
	setSoundVolume('tapeSound', 0);
	setSoundVolume('fanSound', 0.25);
	
	if gotYou then
		triggerScare(slotGot);
	end
	
	randForPic = getRandomInt(1, 100);
end

function disableLight()
	if not lightOn then return; end
	
	local lastDoor = _G[lastLightOn .. 'Door']; -- get that door
	
	lastDoor.light = false;
	updateAPanel(lastLightOn, lastDoor);
	lightOn = false;
	
	updateOfficeLight();
end

function noseFunc()
	doSound('partyFavor', 1, 'noseSound');
end

function doorFunc(d, f)
	local door = _G[d .. 'Door'];
	
	if (not outOfPower and clickCool > 0) or (outOfPower and not f) or getVar('jumpscared') then return; end
	
	if door.stuck and not f then
		doSound('error', 1, 'doorSound');
	elseif door.midPhase then return; else
		clickCool = 10;
		door.clicked = not door.clicked;
		updateADoor(d, door);
		updateAPanel(d, door);
	end
end

function lightFunc(d)
	local door = _G[d .. 'Door'];
	
	if clickCool > 0 or outOfPower or getVar('jumpscared') then return; end
	
	if door.stuck then
		doSound('error', 1, 'doorSound');
		
		return;
	end
	clickCool = 10;
	
	door.light = not door.light;
	updateAPanel(d, door);
	
	if door.light then
		if lightOn then -- disable the light
			local lastDoor = _G[lastLightOn .. 'Door']; -- get that door
			
			lastDoor.light = false;
			updateAPanel(lastLightOn, lastDoor);
		end
		if getVar(d .. 'AtDoor') and not getVar(d .. 'Snd') then
			setVar(d .. 'Snd', true);
			
			doSound('windowScare', 1, 'scareWin');
		end
		
		lastLightOn = d;
	end
	lightOn = door.light;
	
	updateOfficeLight();
end

function updateADoor(t, d)
	d.midPhase = true;
	
	d.phase = (d.clicked and 1 or 3);
	playAnim(t .. 'Door', 'closing', true, not d.clicked);
	doSound('doorSfx', 1, 'doorSound');
end

function updateAPanel(t, d)
	local newAnim = (t:sub(1, 1):upper()) .. (d.clicked and 'DOOR' or '') .. (d.light and 'LIGHT' or '');
	
	playAnim(t .. 'Button', newAnim);
end

function doorFin(s, n, r)
	local t = s .. 'Door';
	local door = _G[t];
	
	_G[s .. 'Drain'] = (door.clicked and 1 or 0);
	updateUsage();
	
	door.midPhase = false;
	door.phase = (door.clicked and 2 or 0);
	door.fullClick = door.clicked;
	playAnim(t, (r and 'open' or 'closed'), true);
end

function updateOfficeLight()
	lightDrain = (lightOn and 1 or 0);
	updateUsage();
	
	setSoundVolume('lightHum', (lightOn and isFlick)); -- i love bools
	
	setAlpha('leftOfficeLight', leftDoor.light);
	setAlpha('rightOfficeLight', rightDoor.light);
end

local camDescFr = {
	{
		[''] = 0,
		['FREDDYBONNIECHICA'] = 5,
		['FREDDYCHICA'] = 4,
		['FREDDYBONNIE'] = 3,
		['FREDDY'] = 1,
		['FREDDYSPECIAL'] = 2,
		['FREDDYBONNIECHICASPECIAL'] = 6 -- this ISNT coded into the game, but i decided to export it because why not
	},
	{
		[''] = 0,
		['BONNIE1'] = 1,
		['BONNIE2'] = 2,
		['CHICA1'] = 3,
		['CHICA2'] = 4,
		['FREDDY'] = 5
	},
	{
		[''] = 0,
		['FOXY1'] = 1,
		['FOXY2'] = 2,
		['FOXY3'] = 3,
		['FOXY3SPECIAL'] = 4
	},
	{
		[''] = 0,
		['ON'] = 1,
		['BONNIE'] = 0,
		['ONBONNIE'] = 2,
	},
	{
		[''] = 0,
		['BONNIE'] = 1,
		['BONNIEBUG1'] = 1,
		['BONNIEBUG2'] = 2,
		['BONNIEBUG3'] = 3,
		['SPECIAL'] = 5,
		['YELLOW'] = 4
	},
	{
		[''] = 0,
		['BONNIE'] = 1,
	},
	{
		[''] = 0,
		['CHICA1'] = 1,
		['CHICA2'] = 2,
		['FREDDY'] = 3,
		['SPECIAL1'] = 4,
		['SPECIAL2'] = 5
	},
	{
		[''] = 0,
		['CHICA'] = 1,
		['CHICABUG1'] = 1,
		['CHICABUG2'] = 2,
		['CHICABUG3'] = 3,
		['FREDDY'] = 4,
		['SPECIAL1'] = 5,
		['SPECIAL2'] = 6,
		['SPECIAL3'] = 7,
		['SPECIAL4'] = 8
	},
	{
		[''] = 0,
		['BONNIE'] = 1,
		['BONNIESPECIAL'] = 2,
		['SPECIAL'] = 3
	},
	[11] = {
		[''] = 0,
		['CHICA1'] = 1,
		['CHICA2'] = 2,
		['FREDDY'] = 3
	}
};
local camExtraAdd = {
	[1] = function(s)
		if s == 'FREDDY' and randForPic <= 10 then
			s = s .. 'SPECIAL';
		end
		
		return s;
	end,
	[3] = function(s)
		if s == 'FOXY3' and randForPic <= 10 then
			s = s .. 'SPECIAL';
		end
		
		return s;
	end,
	[4] = function(s)
		if flickerCam then
			s = 'ON' .. s;
		end
		return s;
	end,
	[5] = function(s)
		if s == 'BONNIE' and curNight >= 4 then -- make him do the bugging
			if bugVal < 25 then
				return 'BONNIEBUG1';
			elseif bugVal >= 25 and bugVal < 29 then
				return 'BONNIEBUG2';
			else
				return 'BONNIEBUG3';
			end
		end
		
		if yellowPhase >= 1 then -- yellow bear overrides the rare chance for the pic
			return 'YELLOW';
		elseif randForPic < 2 then
			return 'SPECIAL';
		end
		
		return s;
	end,
	[7] = function(s)
		if s ~= '' then return s; end
		
		if randForPic >= 99 then
			s = 'SPECIAL' .. bound(randForPic - 98, 1, 2);
		end
		
		return s;
	end,
	[8] = function(s)
		if s == 'FREDDY' then return s; end
		
		if s == 'CHICA' and curNight >= 4 then -- make her do the bugging
			if bugVal < 25 then
				return 'CHICABUG1';
			elseif bugVal >= 25 and bugVal < 29 then
				return 'CHICABUG2';
			else
				return 'CHICABUG3';
			end
		end
		
		if randForPic >= 97 then
			s = 'SPECIAL' .. bound(randForPic - 96, 1, 4);
		end
		
		return s;
	end,
	[9] = function(s)
		if s == 'BONNIE' then
			if randForPic <= 10 then s = s .. 'SPECIAL'; end
		else
			if randForPic <= 5 then s = s .. 'SPECIAL'; end
		end
		
		return s;
	end
};
function updateACam() -- if the frame returns nil, then skip the loops before the n'th suffix (starting at 1)
	if curCam == 10 or not viewingCams then return; end
	
	local c = cameraProps[curCam];
	local startPoint = 0;
	local str = '';
	local fr = nil;
	
	while fr == nil and startPoint < 4 do
		str = '';
		startPoint = startPoint + 1;
		
		for i = startPoint, 4 do
			str = str .. c.slots[i];
		end
		
		if camExtraAdd[curCam] then str = camExtraAdd[curCam](str); end
		fr = camDescFr[curCam][str];
	end
	
	if fr == nil then return; end
	setFrame(curCam .. 'Cam', fr);
end

function setRobotRoom(c, i, r)
	if c > 0 and c < 12 then
		cameraProps[c].slots[i] = r;
		volEerieChecks();
	end
end

function setBugTrigger(a, b) -- if you enter either cam a or cam b during their 10 tick duration it'll block your cam for 300 ticks (5 seconds
	camTriggers[a] = 10;
	camTriggers[b] = 10;
	
	if viewingCams and (curCam == a or curCam == b) then
		updateACam();
		camStuck();
	end
end

local randGarble = {'compDigital', 'garble1', 'garble2', 'garble3'};
function camStuck()
	cameraBlip();
	runHaxeFunction('panelCol', {true});
	setVis('cameraCam', false);
	staticStuck = 300;
	camBugging = true;
	
	camTriggers[curCam] = nil;
	
	doSound(randGarble[getRandomInt(1, 4)], 1, 'camStuckSnd');
end

local kitSnd = {'ovenDra1', 'ovenDra2', 'ovenDra7', 'ovenDra7', 'ovenDraGen'};
function kitchenChanceSnd()
	local rand = getRandomInt(1, 10);
	if kitSnd[rand] then
		local vol = (viewingCams and (curCam == 10 and 0.75 or 0.2) or 0.1);
		
		doSound(kitSnd[rand], vol, 'kitchenSnd');
	end
end

local onHour = {
	[2] = function()
		addBonnie();
	end,
	[3] = function()
		addBonnie();
		addChica();
		addFoxy();
	end,
	[4] = function()
		addBonnie();
		addChica();
		addFoxy();
	end
}
function updateTime()
	curMin = curMin + 1;
	
	if curMin >= 90 then
		curMin = 1;
		
		curHour = curHour + 1;
		if curHour >= 13 then curHour = 1; end
		
		if onHour[curHour] then onHour[curHour](); end
		
		updateCounterSpr('hourNum', curHour);
		
		if curHour >= 6 then
			start6AM();
		end
	end
end

function start6AM()
	doing6Am = true;
	
	killScripts();
	runHaxeFunction('stopAllStuff');
	
	doSound('chimes', 1);
	doTweenAlpha('nextDayIN', 'endCam', 1, pl(1.01));
	
	setProperty('5Spr.active', true);
	setProperty('6Spr.active', true);
end

function takePower(p)
	power = power - p;
	
	updatePower();
end

function updatePower()
	updateCounterSpr('powerNum', bound(math.floor(power / 10), 0, 100));
	
	if power <= 0 and not outOfPower then
		startPowerOut();
	end
end

function startPowerOut()
	if isRunning('scripts/night/animatronics/freddy') then
		removeLuaScript('scripts/night/animatronics/freddy');
	end
	
	runHaxeFunction('killSounds');
	
	killScare();
	goYelBear();
	disableLight();
	outOfPower = true;
	
	doSound('powerDown', 1, 'noPower');
	doSound('ambience2', 0.5, 'ambNoPower', true);
	
	setAlpha('hudCam', 0);
	
	setAlpha('leftButton', 0);
	setAlpha('rightButton', 0);
	
	setAlpha('office', 0);
	setAlpha('fan', 0);
	
	if isHalloween then
		setAlpha('pump', 0);
		setAlpha('lightHallow', 0);
	end
	
	setAlpha('officeNoPower', 1);
	
	
	runTimer('forceStartFred', pl(20));
end

function startMusPower()
	doSound('musicBox', 1, 'noPowerMus');
	
	runTimer('flickerFred', pl(0.05), 0);
	runTimer('randEndFred', pl(5), 0);
	runTimer('forceEndFred', pl(20));
end

function endMusPower()
	runHaxeFunction('killSounds');
	
	doSound('buzzFan', 0.5, 'buzzFlicker');
	
	setFrame('officeNoPower', 0);
	cancelTimer('flickerFred');
	runTimer('powerGone', pl(2 / 6));
	buzzPower = true;
end

function updateStaticAlpha()
	if outOfPower then return; end
	
	local newAlph = 150 + Random(50) + (staticBase * 15);
	
	setAlpha('staticCam', clAlph(newAlph));
end

function triggerItsMe()
	itsMe = true;
	setVis('halluCam', (Random(10) == 1));
	setAlpha('halluCam', 1);
	setSoundVolume('robotVoice', 1);
	
	runTimer('stopHallu', pl(100 / 60));
end

function rollYelBear()
	if not seenYellow and Random(32768) == 1 then -- due to Clickteam fusion limitations, the number overflows at 65535 and also has some devitation due to innacuracy
		seenYellow = true;
		yellowPhase = 1;
		
		if viewingCams and curCam == 5 then
			onNewCam();
		end
	end
end

function goYelBear()
	if yellowPhase == 3 then
		yellowPhase = 0;
		
		setAlpha('yellowBear', 0);
		cancelTimer('yellowScare');
	end
end

local timers = {
	['hideStuff'] = function()
		setAlpha('yellowBear', 0);
		
		setAlpha('officeNoPower', 0);
		
		setAlpha('muteCall', 0);
		setAlpha('cameraCam', 0);
		setAlpha('panelOvCam', 0);
		setAlpha('noVideo', 0);
		setAlpha('endCam', 0);
		
		setVis('cam2AFox', false);
		setAlpha('cam2AFox', 0);
		
		setVis('6Spr', false);
		setVis('topCover', false);
		setVis('botCover', false);
		
		setAlpha('halluCam', 0);
		
		for i = 1, 11 do
			local t = i .. 'Cam';
			setAlpha(t, 0);
		end
	end,
	
	['updateSec'] = function()
		updateTime();
		takePower(curUsage);
		rollYelBear();
		
		if Random(1000) == 1 and not itsMe then triggerItsMe(); end
		
		staticBase = Random(3);
	end,
	
	['extraDrain'] = function()
		takePower(1);
	end,
	
	['randCircus'] = function()
		if (not luaSoundExists('cam3Sfx') or getVar('interCam3Sfx')) and getRandomInt(1, 30) == 1 then
			local looking = (viewingCams and curCam == 3);
			setVar('interCam3Sfx', true);
			doSound('circus', (looking and 0.15 or 0.05), 'cam3Sfx');
		end
	end,
	['randDoorSound'] = function()
		if getRandomInt(1, 50) == 1 then
			local vol = (10 + Random(40)) / 100;
			doSound('doorPound', vol, 'ambDoor');
		end
	end,
	
	['scareSndTime'] = function()
		if not outOfPower then
			doSound('xScream', 1, 'scareSnd');
		end
	end,
	['toDeathTimer'] = function()
		toDied();
	end,
	
	['robotBug'] = function()
		bugVal = getRandomInt(1, 30);
		
		if viewingCams and (curCam == 5 or curCam == 8) then
			updateACam();
		end
	end,
	
	['stopHallu'] = function()
		setAlpha('halluCam', 0);
		if getSoundVolume('robotVoice') == 1 then setSoundVolume('robotVoice', 0); end
	end,
	['showMute'] = function()
		runTimer('hideMute', pl(20));
		setAlpha('muteCall', 1);
	end,
	['hideMute'] = function()
		setAlpha('muteCall', 0);
	end,
	
	['forceScare'] = function()
		if viewingCams then
			trigPanel();
		end
	end,
	
	['randSoundBonnie'] = function()
		if viewingCams and getRandomInt(1, 3) == 1 then
			randGotSound();
		end
	end,
	['randSoundChica'] = function()
		if viewingCams and getRandomInt(1, 3) == 1 then
			randGotSound();
		end
	end,
	
	['randStartFred'] = function()
		if not outOfPower then return; end
		
		if getRandomInt(1, 5) == 1 then
			startMusPower();
			
			cancelTimer('randStartFred');
			cancelTimer('forceStartFred');
		end
	end,
	['forceStartFred'] = function()
		startMusPower();
		
		cancelTimer('randStartFred');
	end,
	
	['flickerFred'] = function()
		local isFred = getRandomInt(1, 4) == 1;
		
		setFrame('officeNoPower', isFred);
	end,
	
	['randEndFred'] = function()
		if getRandomInt(1, 5) == 1 then
			endMusPower();
			
			cancelTimer('randEndFred');
			cancelTimer('forceEndFred');
		end
	end,
	['forceEndFred'] = function()
		endMusPower();
		cancelTimer('randEndFred');
	end,
	
	['powerGone'] = function()
		buzzPower = false;
		doNothing = true;
		
		setVis('mainCam', false);
		runHaxeFunction('killSounds');
		
		runTimer('randScareFred', pl(2), 0);
		runTimer('forceScareFred', pl(20), 0);
	end,
	
	['randScareFred'] = function()
		switchState('Freddy');
	end,
	['forceScareFred'] = function()
		switchState('Freddy');
	end,
	
	['yellowScare'] = function()
		switchState('CreepyEnd');
	end
}

function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end

local tweens = {
	['nextDayIN'] = function()
		runHaxeFunction('killCams');
		
		doTweenY('5Out', '5Spr', 186, pl(4.75));
		doTweenY('6In', '6Spr', 296, pl(4.75));
		
		setVis('6Spr', true);
		setVis('topCover', true);
		setVis('botCover', true);
	end,
	['5Out'] = function()
		doSound('crowdChild', 1);
		
		runTimer('toNext', pl(200 / 60));
	end
}

function onTweenCompleted(t)
	if tweens[t] then tweens[t](); end
end

function varMain(v)
	return _G[v];
end

function varSetMain(v, n)
	_G[v] = n;
end

function mainFunc(f, n)
	return _G[f](n);
end

function propDoor(d, p, v)
	_G[d .. 'Door'][p] = v;
end

function cacheSounds()
	precacheSound('partyFavor');
	precacheSound('error');
	precacheSound('doorSfx');
	precacheSound('humMed2');
	precacheSound('robotVoice');
	
	precacheSound('compDigital');
	precacheSound('garble1');
	precacheSound('garble2');
	precacheSound('garble3');
	
	precacheSound('xScream');
	precacheSound('xScream2');
	
	precacheSound('run');
	precacheSound('deepSteps');
	precacheSound('runningFast');
	precacheSound('musicBox');
	
	precacheSound('camVidLoad');
	precacheSound('tapeEject');
	precacheSound('putDown');
	precacheSound('blip');
	
	precacheSound('blip');
	
	precacheSound('whispering');
	
	precacheSound('laughGiggle1');
	
	precacheSound('laughGiggle1d');
	precacheSound('laughGiggle2d');
	precacheSound('laughGiggle8d');
	
	precacheSound('ovenDra1');
	precacheSound('ovenDra2');
	precacheSound('ovenDra7');
	precacheSound('ovenDraGen');
	
	precacheSound('windowScare');
	precacheSound('pirateSong');
	precacheSound('doorPound');
	precacheSound('circus');
	
	precacheSound('knock');
	
	precacheSound('chimes');
	precacheSound('crowdChild');
	
	precacheSound('static');
	
	precacheSound('powerDown');
	precacheSound('ambience2');
end

function killScripts()
	if isRunning('scripts/night/animatronics/freddy') then
		removeLuaScript('scripts/night/animatronics/freddy');
	end
	
	removeLuaScript('scripts/night/animatronics/foxy');
	removeLuaScript('scripts/night/animatronics/chica');
	removeLuaScript('scripts/night/animatronics/bonnie');
end
