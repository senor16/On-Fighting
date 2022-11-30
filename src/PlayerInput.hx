class PlayerInput {
	public var up:Bool;
	public var down:Bool;
	public var left:Bool;
	public var right:Bool;
	public var A:Bool;
	public var timerA:Float;
	public var textLeft:String;
	public var textRight:String;
	public var textDown:String;
	public var textUp:String;
	public var textA:String;
	public var timerMax:Float;

	public function new() {
		this.up = false;
		this.left = false;
		this.right = false;
		this.down = false;
		this.A = false;
		this.timerMax = .5;
		this.timerA = 0;
		this.textLeft = "L";
		this.textRight = "R";
		this.textDown = "D";
		this.textUp = "U";
		this.textA = "A";
	}
}
