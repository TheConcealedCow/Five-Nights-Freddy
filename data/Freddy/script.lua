function create()
	makeAnimatedLuaSprite('freddy', 'gameAssets/Jumpscares/freddy2');
	addAnimationByPrefix('freddy', 'scare', 'Scare', 36, false);
	playAnim('freddy', 'scare', true);
	addLuaSprite('freddy');
	
	makeAnimatedLuaSprite('static', 'gameAssets/night/panel/hud/static');
	makeAnimatedLuaSprite('blip', 'gameAssets/night/panel/hud/blipCam');
	
	runHaxeCode([[
		game.modchartSprites.get('freddy').animation.finishCallback = function() {
			parentLua.call('switchState', ['died']);
		}
	]]);
	
	doSound('xScream', 1, 'scareSnd');
	
	runTimer('toGameOver', pl(10));
end

