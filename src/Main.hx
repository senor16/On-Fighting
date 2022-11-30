class Main extends hxd.App {
	var background:h2d.Bitmap;
	var sceneGameplay:h2d.Scene;
	var hero:Fighter;
	var ennemy:Fighter;
	var window:hxd.Window;
	var comboSequence:String;
	var playerInput:PlayerInput;
	var ennemyInput:PlayerInput;
	var comboTimer:Float;
	var comboTimerMax:Float;
	var ennemyAttackTimer:Float;
	var fightTimer:Float;
	var ennemyAttackTimerMax:Float;
	var font:h2d.Font;
	var fontResult:h2d.Font;
	var fightTimerText:h2d.Text;
	var heroGauge:h2d.Graphics;
	var heroGaugeBack:h2d.Graphics;
	var ennemyGauge:h2d.Graphics;
	var ennemyGaugeBack:h2d.Graphics;
	var fightWon:Bool;
	var fightFailed:Bool;
	var fightResultText:h2d.Text;
	var listProjectiles:List<Projectile>;

	public function distance(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
	}

	public function isColliding(x1:Float, y1:Float, w1:Float, h1:Float, x2:Float, y2:Float, w2:Float, h2:Float):Bool {
		return x1 < x2 + w2 && x2 < x1 + w1 && y1 < y2 + h2 && y2 < y1 + h1;
	}

	override function init() {
		@:privateAccess haxe.MainLoop.add(() -> {});
		super.init();
		font = hxd.res.DefaultFont.get();
		fontResult = hxd.res.DefaultFont.get();
		window = hxd.Window.getInstance();
		hxd.Key.ALLOW_KEY_REPEAT = true;
		comboSequence = "";
		playerInput = new PlayerInput();
		ennemyInput = new PlayerInput();
		listProjectiles = new List<Projectile>();
		comboTimer = 0;
		comboTimerMax = 2;
		ennemyAttackTimer = 0;
		ennemyAttackTimerMax = 3;

		// Scene gmeplay
		sceneGameplay = new h2d.Scene();
		setScene(sceneGameplay);
		sceneGameplay.camera.x = 90;

		// Background image
		background = new h2d.Bitmap(hxd.Res.img.fond.toTile(), sceneGameplay);
		background.scale(2);

		// Fight timer
		font.resizeTo(20);
		fightTimer = 60;
		fightTimerText = new h2d.Text(font, sceneGameplay);
		fightTimerText.text = '${Math.floor(fightTimer)}';
		fightTimerText.x = (window.width - fightTimerText.textWidth) / 2 + 80;

		fightTimerText.y = -10;
		fightTimerText.scale(2);
		fightTimerText.textColor = 0x000000;

		// Fight result
		fightFailed = false;
		fightWon = false;

		/** Ennemy **/

		// Animation
		var ennemyIdle = new h2d.Anim([
			hxd.Res.img.hibiki.stance.stance_0.toTile().center(),
			hxd.Res.img.hibiki.stance.stance_1.toTile().center(),
			hxd.Res.img.hibiki.stance.stance_2.toTile().center(),
			hxd.Res.img.hibiki.stance.stance_3.toTile().center(),
			hxd.Res.img.hibiki.stance.stance_4.toTile().center(),
			hxd.Res.img.hibiki.stance.stance_5.toTile().center(),
		], 15, sceneGameplay);

		ennemyIdle.name = "idle";

		var ennemyVictory = new h2d.Anim([
			hxd.Res.img.hibiki.victory.victory_0.toTile().center(),
			hxd.Res.img.hibiki.victory.victory_1.toTile().center(),
			hxd.Res.img.hibiki.victory.victory_2.toTile().center(),
			hxd.Res.img.hibiki.victory.victory_3.toTile().center(),
		], 10, sceneGameplay);
		ennemyVictory.loop = false;

		ennemyVictory.name = "victory";

		var ennemyHaduken = new h2d.Anim([
			hxd.Res.img.hibiki.gaduken.gaduken_0.toTile().center(),
			hxd.Res.img.hibiki.gaduken.gaduken_1.toTile().center(),
			hxd.Res.img.hibiki.gaduken.gaduken_2.toTile().center(),
			hxd.Res.img.hibiki.gaduken.gaduken_3.toTile().center(),
		], 10, sceneGameplay);
		ennemyHaduken.name = "gaduken";

		var ennemyHit = new h2d.Anim([
			hxd.Res.img.hibiki.highthit.highthit_1.toTile().center(),
			hxd.Res.img.hibiki.highthit.highthit_2.toTile().center(),
			hxd.Res.img.hibiki.highthit.highthit_3.toTile().center(),
			hxd.Res.img.hibiki.highthit.highthit_4.toTile().center(),
		], 15, sceneGameplay);
		ennemyHit.name = "hit";

		var ennemyWalkForward = new h2d.Anim([
			hxd.Res.img.hibiki.walkforward.walkforward_1.toTile().center(),
			hxd.Res.img.hibiki.walkforward.walkforward_2.toTile().center(),
			hxd.Res.img.hibiki.walkforward.walkforward_3.toTile().center(),
			hxd.Res.img.hibiki.walkforward.walkforward_4.toTile().center(),
			hxd.Res.img.hibiki.walkforward.walkforward_5.toTile().center(),
			hxd.Res.img.hibiki.walkforward.walkforward_6.toTile().center(),
		], 15, sceneGameplay);
		ennemyWalkForward.name = "walkForward";

		var ennemyWalkBackward = new h2d.Anim([
			hxd.Res.img.hibiki.walkbackward.walkforward_1.toTile().center(),
			hxd.Res.img.hibiki.walkbackward.walkforward_6.toTile().center(),
			hxd.Res.img.hibiki.walkbackward.walkforward_5.toTile().center(),
			hxd.Res.img.hibiki.walkbackward.walkforward_4.toTile().center(),
			hxd.Res.img.hibiki.walkbackward.walkforward_3.toTile().center(),
			hxd.Res.img.hibiki.walkbackward.walkforward_2.toTile().center(),
		], 15, sceneGameplay);

		ennemyWalkBackward.name = "walkBackward";

		ennemy = new Fighter(ennemyIdle, sceneGameplay);
		ennemy.name = "Hibiki";
		ennemy.lifeTo = 100;
		ennemy.scaleX = -2;
		ennemy.scaleY = 2;
		ennemy.speed = 15;
		ennemy.x = sceneGameplay.camera.x + window.width - 200;
		ennemy.y = window.height - ennemy.height * ennemy.scaleY + 20;
		ennemy.hurtBox = new CollideBox("idle", -20, -35, 40, 70, ennemy);
		// Add animations to ennemy
		ennemy.addAnim(ennemyWalkForward);
		ennemy.addAnim(ennemyWalkBackward);
		ennemy.addAnim(ennemyHit);
		ennemy.addAnim(ennemyHaduken);
		ennemy.addAnim(ennemyVictory);

		// Hero Gauge
		ennemyGaugeBack = new h2d.Graphics(sceneGameplay);
		ennemyGauge = new h2d.Graphics(sceneGameplay);
		drawGauge(ennemy.life - 30, 100, ennemyGauge, ennemyGaugeBack, 530);

		/** Hero **/
		// Animation
		var heroIdle = new h2d.Anim([
			hxd.Res.img.ken.stance.tile000.toTile().center(),
			hxd.Res.img.ken.stance.tile001.toTile().center(),
			hxd.Res.img.ken.stance.tile002.toTile().center(),
			hxd.Res.img.ken.stance.tile003.toTile().center(),
			hxd.Res.img.ken.stance.tile004.toTile().center(),
			hxd.Res.img.ken.stance.tile005.toTile().center()
		], 15, sceneGameplay);

		heroIdle.name = "idle";

		var heroVictory = new h2d.Anim([
			hxd.Res.img.ken.victory.victory_0.toTile().center(),
			hxd.Res.img.ken.victory.victory_1.toTile().center(),
			hxd.Res.img.ken.victory.victory_2.toTile().center(),
			hxd.Res.img.ken.victory.victory_3.toTile().center(),
			hxd.Res.img.ken.victory.victory_4.toTile().center(),
		], 15, sceneGameplay);
		heroVictory.loop = false;

		heroVictory.name = "victory";

		var heroHaduken = new h2d.Anim([
			hxd.Res.img.ken.haduken.haduken_1.toTile().center(),
			hxd.Res.img.ken.haduken.haduken_2.toTile().center(),
			hxd.Res.img.ken.haduken.haduken_3.toTile().center(),
			hxd.Res.img.ken.haduken.haduken_4.toTile().center(),
			hxd.Res.img.ken.haduken.haduken_5.toTile().center(),
			hxd.Res.img.ken.haduken.haduken_6.toTile().center(),
		], 15, sceneGameplay);
		heroHaduken.name = "haduken";

		var heroHit = new h2d.Anim([
			hxd.Res.img.ken.highthit.highthit_1.toTile().center(),
			hxd.Res.img.ken.highthit.highthit_2.toTile().center(),
			hxd.Res.img.ken.highthit.highthit_3.toTile().center(),
			hxd.Res.img.ken.highthit.highthit_4.toTile().center(),
		], 15, sceneGameplay);
		heroHit.name = "hit";

		var heroWalkForward = new h2d.Anim([
			hxd.Res.img.ken.walkforward.walkforward_1.toTile().center(),
			hxd.Res.img.ken.walkforward.walkforward_2.toTile().center(),
			hxd.Res.img.ken.walkforward.walkforward_3.toTile().center(),
			hxd.Res.img.ken.walkforward.walkforward_4.toTile().center(),
			hxd.Res.img.ken.walkforward.walkforward_5.toTile().center(),
			hxd.Res.img.ken.walkforward.walkforward_6.toTile().center(),
		], 15, sceneGameplay);
		heroWalkForward.name = "walkForward";

		var heroWalkBackward = new h2d.Anim([
			hxd.Res.img.ken.walkbackward.walkbackward_1.toTile().center(),
			hxd.Res.img.ken.walkbackward.walkbackward_2.toTile().center(),
			hxd.Res.img.ken.walkbackward.walkbackward_3.toTile().center(),
			hxd.Res.img.ken.walkbackward.walkbackward_4.toTile().center(),
			hxd.Res.img.ken.walkbackward.walkbackward_5.toTile().center(),
			hxd.Res.img.ken.walkbackward.walkbackward_6.toTile().center(),
			hxd.Res.img.ken.walkbackward.walkbackward_7.toTile().center(),
		], 15, sceneGameplay);

		heroWalkBackward.name = "walkBackward";

		hero = new Fighter(heroIdle, sceneGameplay);
		hero.name = "Ken";
		hero.scale(2);
		hero.lifeTo = 100;
		hero.x = 100 + sceneGameplay.camera.x;
		hero.speed = 15;
		hero.y = window.height - hero.height * hero.scaleY + 20;
		hero.hurtBox = new CollideBox("idle", -20, -35, 40, 70, hero);
		// Add animations to hero
		hero.addAnim(heroWalkForward);
		hero.addAnim(heroWalkBackward);
		hero.addAnim(heroHit);
		hero.addAnim(heroHaduken);
		hero.addAnim(heroVictory);
		// Add combo to hero
		hero.addCombo(new Combo("haduken", "DRDR", hxd.Key.I, sceneGameplay));
		// Hero Gauge
		heroGaugeBack = new h2d.Graphics(sceneGameplay);
		heroGauge = new h2d.Graphics(sceneGameplay);
		drawGauge(hero.life - 30, 100, heroGauge, heroGaugeBack, 50);
	}

	function testCombo(pFighter:Fighter) {
		for (combo in pFighter.listCombo.iterator()) {
			var comb = comboSequence.substring(comboSequence.length - combo.sequence.length, comboSequence.length);
			if (combo.sequence == comb && hxd.Key.isDown(combo.trigger)) {
				comboSequence = "";
				comboTimer = 0;
				hero.playAnim(combo.name);
			}
		}
	}

	function addProjectile(pTarget:String) {
		var speed = 30;
		if (pTarget == ennemy.name) {
			var vx:Float;
			var dir = hero.scaleX / Math.abs(hero.scaleX);
			vx = speed * dir;

			var heroProjectile = new h2d.Anim([
				hxd.Res.img.ken.projectile.projectile_0.toTile().center(),
				hxd.Res.img.ken.projectile.projectile_1.toTile().center(),
			], 5, sceneGameplay);
			heroProjectile.loop = false;
			heroProjectile.name = "projectile";

			var heroProjectileHit = new h2d.Anim([
				hxd.Res.img.ken.projectilehit.projectilehit_1.toTile().center(),
				hxd.Res.img.ken.projectilehit.projectilehit_2.toTile().center(),
				hxd.Res.img.ken.projectilehit.projectilehit_3.toTile().center(),
				hxd.Res.img.ken.projectilehit.projectilehit_4.toTile().center(),
				hxd.Res.img.ken.projectilehit.projectilehit_5.toTile().center(),
				hxd.Res.img.ken.projectilehit.projectilehit_6.toTile().center(),
			], 15, sceneGameplay);
			heroProjectileHit.loop = false;
			heroProjectileHit.name = "projectileHit";

			var proj = new Projectile(vx, pTarget, heroProjectile, sceneGameplay);
			proj.scaleX = dir;
			proj.scale(2);
			proj.x = hero.x + hero.width * dir;
			proj.y = hero.y - 20;
			proj.addAnim(heroProjectileHit);
			listProjectiles.add(proj);
		} else if (pTarget == hero.name) {
			var vx:Float;
			var dir = ennemy.scaleX / Math.abs(ennemy.scaleX);
			vx = speed * dir;

			var pro = new h2d.Anim([
				hxd.Res.img.ken.projectile.projectile_0.toTile().center(),
				hxd.Res.img.ken.projectile.projectile_1.toTile().center(),
			], 5, sceneGameplay);
			pro.loop = false;
			pro.name = "projectile";

			var hit = new h2d.Anim([
				hxd.Res.img.ken.projectilehit.projectilehit_1.toTile().center(),
				hxd.Res.img.ken.projectilehit.projectilehit_2.toTile().center(),
				hxd.Res.img.ken.projectilehit.projectilehit_3.toTile().center(),
				hxd.Res.img.ken.projectilehit.projectilehit_4.toTile().center(),
				hxd.Res.img.ken.projectilehit.projectilehit_5.toTile().center(),
				hxd.Res.img.ken.projectilehit.projectilehit_6.toTile().center(),
			], 15, sceneGameplay);
			hit.loop = false;
			hit.name = "projectileHit";

			var proj = new Projectile(vx, pTarget, pro, sceneGameplay);
			proj.scaleX = dir;
			proj.scale(2);
			proj.x = ennemy.x + ennemy.width * dir;
			proj.y = ennemy.y - 20;
			proj.addAnim(hit);
			listProjectiles.add(proj);
		}
	}

	function updateHero(dt:Float) {
		if (hero.life <= 0 && hero.lifeTo <= 0) {
			hero.life = 0;
			hero.state = "Dead";
			fightFailed = true;
			ennemy.state = "Victory";
		}
		if (hero.state != "Dead") {
			comboTimer += dt;

			// Animate Health value modification
			if (hero.life > hero.lifeTo) {
				hero.life -= (hero.life - hero.lifeTo) * 0.15;
				if (Math.abs(hero.life - hero.lifeTo) <= 0.1) {
					hero.life = hero.lifeTo;
				}
			}
			if (hero.life < hero.lifeTo) {
				hero.life += (hero.lifeTo - hero.life) * 0.15;
				if (Math.abs(hero.life - hero.lifeTo) <= 0.1) {
					hero.life = hero.lifeTo;
				}
			}

			// Move the hero to the left
			hero.vx = hero.vy = 0;

			// Input Left
			if (hxd.Key.isDown(hxd.Key.LEFT) || hxd.Key.isDown(hxd.Key.A)) {
				playerInput.left = true;
			}
			if (hxd.Key.isReleased(hxd.Key.LEFT) || hxd.Key.isReleased(hxd.Key.A)) {
				playerInput.left = false;
				comboSequence += playerInput.textLeft;
				hero.playAnim("idle");
			}
			// Input Right
			if (hxd.Key.isDown(hxd.Key.RIGHT) || hxd.Key.isDown(hxd.Key.D)) {
				playerInput.right = true;
			}
			if (hxd.Key.isReleased(hxd.Key.RIGHT) || hxd.Key.isReleased(hxd.Key.D)) {
				playerInput.right = false;
				comboSequence += playerInput.textRight;
				hero.playAnim("idle");
			}
			// Input Up
			if (hxd.Key.isDown(hxd.Key.UP) || hxd.Key.isDown(hxd.Key.W)) {
				playerInput.up = true;
			}
			if (hxd.Key.isReleased(hxd.Key.UP) || hxd.Key.isReleased(hxd.Key.W)) {
				playerInput.up = false;
				comboSequence += playerInput.textUp;
			}
			// Input Down
			if (hxd.Key.isDown(hxd.Key.DOWN) || hxd.Key.isDown(hxd.Key.S)) {
				playerInput.down = true;
			}
			if (hxd.Key.isReleased(hxd.Key.DOWN) || hxd.Key.isReleased(hxd.Key.S)) {
				playerInput.down = false;
				comboSequence += playerInput.textDown;
			}
			// Input A
			if (hxd.Key.isDown(hxd.Key.I)) {
				playerInput.A = true;
			}

			if (hxd.Key.isReleased(hxd.Key.I)) {
				playerInput.A = false;
				playerInput.timerA = 0;
			}

			if (playerInput.left) {
				hero.vx = -hero.speed;
				if (hero.x < hero.width * Math.abs(hero.scaleX) / 2)
					hero.x = hero.width * Math.abs(hero.scaleX) / 2;
				var anim = "walkBackward";
				hero.playAnim(anim);
				if (hero.x - hero.width * Math.abs(hero.scaleX) * 3 < sceneGameplay.camera.x) {
					sceneGameplay.camera.x -= 2.5;
				}
			}
			if (playerInput.right) {
				hero.vx = hero.speed;
				var anim = "walkForward";
				hero.playAnim(anim);
				if (hero.x > background.tile.width * background.scaleX - hero.width * Math.abs(hero.scaleX) / 2)
					hero.x = background.tile.width * background.scaleX - hero.width * Math.abs(hero.scaleX) / 2;
				if (hero.x + hero.width * 3 * Math.abs(hero.scaleX) > sceneGameplay.camera.x + window.width) {
					sceneGameplay.camera.x += 2.5;
				}
			}

			// Mirror effect on hero
			if (hero.x > ennemy.x) {
				hero.scaleX = -Math.abs(hero.scaleX);
			} else {
				hero.scaleX = Math.abs(hero.scaleX);
			}

			if (hero.currentAnim.name == "hit") {
				if (hero.currentAnim.currentFrame >= hero.currentAnim.frames.length - 1)
					hero.playAnim("idle");
			}
			if (hero.currentAnim.name == "haduken") {
				if (hero.currentAnim.currentFrame >= hero.currentAnim.frames.length - 1) {
					hero.playAnim("idle");
					hero.shot = false;
				}
				if (hero.currentAnim.currentFrame >= hero.currentAnim.frames.length - 2 && hero.shot == false) {
					addProjectile(ennemy.name);
					hero.shot = true;
				}
			}
			if (hero.state == "Victory") {
				hero.playAnim("victory");
			}

			hero.update(dt);
		}
	}

	function updateEnnemy(dt:Float) {
		if (ennemy.life <= 0 && ennemy.lifeTo <= 0) {
			ennemy.life = 0;
			ennemy.state = "Dead";
			fightWon = true;
			hero.state = "Victory";
		}
		if (ennemy.state != "Dead") {
			ennemyAttackTimer += dt;

			// Animate Health value modification
			if (ennemy.life > ennemy.lifeTo) {
				ennemy.life -= (ennemy.life - ennemy.lifeTo) * 0.15;
				if (Math.abs(ennemy.life - ennemy.lifeTo) <= 0.1) {
					ennemy.life = ennemy.lifeTo;
				}
			}
			if (ennemy.life < ennemy.lifeTo && !ennemy.filled) {
				ennemy.life += (ennemy.lifeTo - ennemy.life) * 0.15;
				if (Math.abs(ennemy.life - ennemy.lifeTo) <= 0.1) {
					ennemy.life = ennemy.lifeTo;
					ennemy.filled = true;
				}
			}

			var dist = Math.abs(ennemy.x - hero.x);
			if (!fightFailed) {
				if (ennemyAttackTimer >= ennemyAttackTimerMax) {
					ennemyAttackTimer = 0;
					ennemy.state = "Attack";
				}
			}
			ennemyInput.left = ennemyInput.right = false;
			ennemy.vx = ennemy.vy = 0;
			if (dist > 500) {
				if (hero.x > ennemy.x) {
					ennemyInput.right = true;
				}
				if (hero.x < ennemy.x) {
					ennemyInput.left = true;
				}
			} else if (dist < 300) {
				if (hero.x < ennemy.x) {
					ennemyInput.right = true;
				}

				if (hero.x > ennemy.x) {
					ennemyInput.left = true;
				}
			} else {
				if (ennemy.state == "WalkForward" || ennemy.state == "WalkBackward")
					ennemy.state = "Idle";
			}

			var anim = "idle";

			if (ennemyInput.left) {
				ennemy.state = "WalkForward";
				ennemy.vx = -ennemy.speed;
				anim = "walkForward";
				if (ennemy.currentAnim.name != anim)
					ennemy.playAnim(anim);
				if (ennemy.x < ennemy.width * Math.abs(ennemy.scaleX) / 2) {
					ennemy.x = ennemy.width * Math.abs(ennemy.scaleX) / 2;
					if (dist >= 300)
						ennemy.state = "Idle";
				}
			}
			if (ennemyInput.right) {
				ennemy.state = "WalkBackward";
				ennemy.vx = ennemy.speed;
				anim = "walkBackward";
				if (ennemy.currentAnim.name != anim)
					ennemy.playAnim(anim);
				if (ennemy.x > background.tile.width * background.scaleX - ennemy.width * Math.abs(ennemy.scaleX) / 2) {
					ennemy.x = background.tile.width * background.scaleX - ennemy.width * Math.abs(ennemy.scaleX) / 2;
					if (dist >= 300)
						ennemy.state = "Idle";
				}
			}

			// Mirror effect on ennemy
			if (ennemy.x > hero.x) {
				ennemy.scaleX = -Math.abs(ennemy.scaleX);
			} else {
				ennemy.scaleX = Math.abs(ennemy.scaleX);
			}

			// React according to enemy state
			if (ennemy.state == "Attack") {
				anim = "gaduken";
				if (ennemy.currentAnim.name != anim)
					ennemy.playAnim(anim);
				ennemy.vx = ennemy.vy = 0;
				if (ennemy.currentAnim.currentFrame >= ennemy.currentAnim.frames.length - 1) {
					ennemy.state = "Idle";
					ennemy.shot = false;
				}
				if (ennemy.currentAnim.currentFrame >= ennemy.currentAnim.frames.length - 2 && ennemy.shot == false) {
					addProjectile(hero.name);
					ennemy.shot = true;
				}
			}
			if (ennemy.state == "Victory") {
				ennemy.playAnim("victory");
			}
			if (ennemy.state == "Idle") {
				ennemyInput.A = false;
				ennemyInput.timerA = 0;
				if (ennemy.currentAnim.name != "idle")
					ennemy.playAnim("idle");
			}
			if (ennemy.state == "Hit") {
				if (ennemy.currentAnim.name != "hit")
					ennemy.playAnim("hit");
				if (ennemy.currentAnim.currentFrame >= ennemy.currentAnim.frames.length - 1)
					ennemy.state = "Idle";
			}

			ennemy.update(dt);
		}
	}

	function drawGauge(pValue:Float, pMAx:Float, pGauge:h2d.Graphics, pBack:h2d.Graphics, pX:Float) {
		var w:Float;
		var h:Float = 30;
		var y:Float = 2;

		w = pValue * 300 / pMAx;

		pBack.clear();
		pBack.beginFill(0x7C7979);
		pBack.drawRect(sceneGameplay.camera.x + pX, y, 300, h);
		pBack.endFill();

		pGauge.clear();
		pGauge.beginFill(0xECCE20);
		pGauge.drawRect(sceneGameplay.camera.x + pX, y, w, h);
		pGauge.endFill();
	}

	function updateProjectiles(dt) {
		for (projA in listProjectiles.iterator()) {
			for (projB in listProjectiles.iterator()) {
				if (projA.target != projB.target) {
					if (isColliding(projA.x
						+ projA.width / 2, projA.y
						+ projA.height / 2, projA.width / 2, projA.height / 2, projB.x
						+ projB.width / 2,
						projB.y
						+ projB.height / 2, projB.width / 2, projB.height / 2)) {
						projA.vx = 0;
						projA.playAnim("projectileHit");
						projB.vx = 0;
						projB.playAnim("projectileHit");
					}
				}
			}
		}

		for (projectile in listProjectiles.iterator()) {
			if (projectile.currentAnim.name == "projectile") {
				if (projectile.target == hero.name) {
					if (isColliding(hero.x
						+ hero.hurtBox.x, hero.y
						+ hero.hurtBox.y, hero.hurtBox.w, hero.hurtBox.h,
						projectile.x
						- projectile.width * projectile.scaleX / 4, projectile.y
						- projectile.height * projectile.scaleX / 4,
						projectile.width / 2, projectile.height / 2)) {
						projectile.vx = 0;
						projectile.playAnim("projectileHit");
						projectile.hurtTarget = true;
					}
				} else if (projectile.target == ennemy.name) {
					if (isColliding(ennemy.x
						+ ennemy.hurtBox.x, ennemy.y
						+ ennemy.hurtBox.y, ennemy.hurtBox.w, ennemy.hurtBox.h,
						projectile.x
						- projectile.width, projectile.y
						- projectile.height, projectile.width, projectile.height)) {
						projectile.vx = 0;
						projectile.playAnim("projectileHit");
						projectile.hurtTarget = true;
					}
				}
			} else if (projectile.currentAnim.name == "projectileHit" && projectile.hurtTarget) {
				if (projectile.currentAnim.currentFrame >= projectile.currentAnim.frames.length - 2) {
					projectile.hurtTarget = false;
					if (projectile.target == hero.name) {
						if (hero.life > 0) {
							hero.lifeTo -= 5;
						}
					} else if (projectile.target == ennemy.name) {
						if (ennemy.life > 0) {
							ennemy.lifeTo -= 5;
						}
					}
				}
				if (projectile.target == hero.name) {
					if (hero.life > 0) {
						hero.playAnim("hit");
						hero.state = "Hit";
					}
				} else if (projectile.target == ennemy.name) {
					if (ennemy.life > 0) {
						ennemy.state = "Hit";
					}
				}
			}
		}

		for (projectile in listProjectiles.iterator()) {
			projectile.update(dt);
			if (projectile.currentAnim.name == "projectileHit"
				&& projectile.currentAnim.currentFrame >= projectile.currentAnim.frames.length) {
				projectile.delete();
				listProjectiles.remove(projectile);
			}
		}
	}

	override function update(dt:Float) {
		fightTimerText.text = '${Math.floor(fightTimer)}';
		fightTimerText.x = (window.width - fightTimerText.textWidth) / 2 + -20 + sceneGameplay.camera.x;
		if (!fightFailed && !fightWon) {
			fightTimer -= dt;
		}
		drawGauge(ennemy.life, 100, ennemyGauge, ennemyGaugeBack, 530);
		drawGauge(hero.life, 100, heroGauge, heroGaugeBack, 50);
		testCombo(hero);
		if (comboTimer >= comboTimerMax) {
			comboTimer = 0;
			comboSequence = "";
		}
		updateProjectiles(dt);
		if (!fightFailed)
			updateHero(dt);
		else {
			hero.currentAnim.visible = false;
		}
		if (!fightWon)
			updateEnnemy(dt);
		else {
			ennemy.currentAnim.visible = false;
		}

		// Exit when `Escape` key is pressed
		if (hxd.Key.isPressed(hxd.Key.ESCAPE)) {
			hxd.System.exit();
		}
		if (sceneGameplay.camera.x + window.width > background.tile.width * background.scaleX) {
			sceneGameplay.camera.x = background.tile.width * background.scaleX - window.width;
		}
		if (sceneGameplay.camera.x < 0) {
			sceneGameplay.camera.x = 0;
		}

		if (fightTimer <= 0) {
			fightTimer = 0;
			if (hero.life > ennemy.life) {
				fightWon = true;
			} else {
				fightFailed = true;
			}
		}
	}

	static function main() {
		#if js
		hxd.Res.initEmbed({compressSounds: true});
		#else
		hxd.res.Resource.LIVE_UPDATE = true;
		hxd.Res.initLocal();
		#end
		new Main();
	}
}
