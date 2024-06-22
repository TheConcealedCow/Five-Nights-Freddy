function create()
	luaDebugMode = true;
	
	runHaxeCode([[
		import flixel.FlxCamera;
		import psychlua.LuaUtils;
		
		var scareCam = FlxG.cameras.add(new FlxCamera(0, 0, 1280, 720), false);
		scareCam.bgColor = 0xFF000000;
		setVar('scareCam', scareCam);
	]]);
	
	makeLuaSprite('creepy', 'gameAssets/Jumpscares/yellow');
	setCam('creepy', 'scareCam');
	addLuaSprite('creepy');
	
	doSound('xScream2', 1, 'yellowScream');
	runTimer('toMenu', pl(1));
end

function onTimerCompleted(t) if t == 'toMenu' then exitGame(); end end
