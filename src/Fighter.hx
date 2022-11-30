class Fighter extends h2d.Object {
	public var vx:Float;
	public var vy:Float;
	public var speed:Float;
	public var hurtBox:CollideBox;
	public var currentAnim:h2d.Anim;
	public var listAnim:List<h2d.Anim>;
	public var width:Float;
	public var height:Float;
	public var listCombo:List<Combo>;
	public var life:Float;
	public var lifeTo:Float;
	public var state:String;
	public var filled:Bool;
	public var shot:Bool;

	public function new(pDefaultAnim:h2d.Anim, pParent:h2d.Scene) {
		super(pParent);
		this.vx = 0;
		this.vy = 0;
		this.shot = false;
		this.speed = 0;
		this.filled=false;
		this.life = 0;
		this.hurtBox = null;
		this.currentAnim = pDefaultAnim;
		this.listAnim = new List<h2d.Anim>();
		this.listAnim.add(pDefaultAnim);
		this.height = this.currentAnim.getFrame().height;
		this.width = this.currentAnim.getFrame().width;
		this.listCombo = new List<Combo>();
		this.state = "Idle";
	}

	public function addAnim(pAnim:h2d.Anim) {
		pAnim.visible = false;		
		pAnim.pause=true;
		pAnim.currentFrame=0;
		this.listAnim.add(pAnim);
	}

	public function addCombo(pCombo:Combo) {
		this.listCombo.add(pCombo);
	}

	public function playAnim(pName:String) {
		if (!(this.currentAnim.name == pName)) {
			for (anim in this.listAnim.iterator()) {
				if (anim.name == pName) {
					this.currentAnim.currentFrame=0;
					this.currentAnim.pause = true;
					anim.visible = true;
					anim.pause=false;
					this.currentAnim = anim;
				} else {
					anim.visible = false;
				}
			}
		}
	}

	public function flipX(bool:Bool) {
		this.currentAnim.getFrame().xFlip = bool;
	}

	public function update(dt:Float) {
		this.x += this.vx * dt * 10;
		this.y += this.vy * dt * 10;

		this.height = this.currentAnim.getFrame().height;
		this.width = this.currentAnim.getFrame().width;

		

		for (anim in this.listAnim.iterator()) {		
			
			if (anim.x != this.x)
				anim.x = this.x;
			if (anim.y != this.y)
				anim.y = this.y;

			if (anim.scaleX != this.scaleX)
				anim.scaleX = this.scaleX;
			if (anim.scaleY != this.scaleY)
				anim.scaleY = this.scaleY;
		}

		hurtBox.update(dt);
	}
}
