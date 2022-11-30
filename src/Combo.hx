class Combo extends h2d.Object {
	public var sequence:String;
	public var trigger:Int;

	public function new(pName:String, pSequence:String, pTrigger:Int, pParent) {
		super(pParent);
		this.sequence = pSequence;
		this.trigger = pTrigger;
		this.name = pName;
	}
}
