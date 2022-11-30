class CollideBox extends h2d.Object {
	public var w:Float;
	public var h:Float;
	public var who:Fighter;
	public var graphic:h2d.Graphics;

	var xOr:Float;
	var initScaleX:Float;

	public function new(name:String, x:Float, y:Float, w:Float, h:Float, who:Fighter) {
		super(who.parent);
		this.x = x * who.scaleX;
		this.y = y * who.scaleY;
		this.w = w * who.scaleX;
		this.h = h * who.scaleY;
		this.xOr = x;
		this.initScaleX = who.scaleX;
		this.who = who;
		this.name = name;

		// this.graphic = new h2d.Graphics(who.parent);
		// // specify a color we want to draw with
		// this.graphic.beginFill(0xEA8220);
		// // Draw a rectangle at 10,10 that is 300 pixels wide and 200 pixels tall
		// this.graphic.drawRect(this.who.x + this.x, this.who.y + this.y, this.w, this.h);
		// // End our fill
		// this.graphic.endFill();
	}

	public function update(dt:Float) {
		// if (this.visible != this.graphic.visible)
		// 	this.graphic.visible = this.visible;

		if (this.initScaleX != this.who.scaleX) {
			this.x = this.xOr * this.who.scaleX - this.w;
		} else {
			this.x = this.xOr * this.who.scaleX;
		}

		// this.graphic.clear();

		// this.graphic.beginFill(0xEA8220);
		// // Draw a rectangle at 10,10 that is 300 pixels wide and 200 pixels tall
		// this.graphic.drawRect(this.who.x + this.x, this.who.y + this.y, this.w, this.h);

		// // End our fill
		// this.graphic.endFill();
	}
}
