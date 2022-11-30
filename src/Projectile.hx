class Projectile extends h2d.Object {
	public var target:String;
	public var vx:Float;
	public var currentAnim:h2d.Anim;
	public var listAnim:List<h2d.Anim>;
	public var width:Float;
	public var height:Float;
	public var hurtTarget:Bool;
	public var del:Bool;

	public function new(pVx:Float, pTarget:String, pAnim:h2d.Anim, pParent) {
		super(pParent);
		this.target = pTarget;
		this.vx = pVx;
		this.del = false;
		this.currentAnim = pAnim;
		this.height = this.currentAnim.getFrame().height;
		this.width = this.currentAnim.getFrame().width;
		this.listAnim = new List<h2d.Anim>();
		this.listAnim.add(pAnim);
		this.hurtTarget = false;
	}

	public function addAnim(pAnim:h2d.Anim) {
		pAnim.visible = false;
		pAnim.pause = true;
		pAnim.currentFrame = 0;
		this.listAnim.add(pAnim);
	}

	public function playAnim(pName:String) {
		if (!(this.currentAnim.name == pName)) {
			for (anim in this.listAnim.iterator()) {
				if (anim.name == pName) {
					this.currentAnim.currentFrame = 0;
					this.currentAnim.pause = true;
					anim.visible = true;
					anim.pause = false;
					this.currentAnim = anim;
				} else {
					anim.visible = false;
				}
			}
		}
	}

	public function delete() {
		this.del = true;
		for (anim in this.listAnim.iterator()) {
			anim.remove();
		}
	}

	public function update(dt:Float) {
		this.x += this.vx;
		this.height = this.currentAnim.getFrame().height * Math.abs(this.scaleY);
		this.width = this.currentAnim.getFrame().width * Math.abs(this.scaleX);

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

		if (this.x < -10000 || this.x > 10000) {
			this.delete();
		}

		
	}
}
