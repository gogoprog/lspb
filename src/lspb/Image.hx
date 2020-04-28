package lspb;

@:pythonImport("PIL.Image")
extern class Image {
    @:native("new")
    static public function _new(mode:String, size:Vector2):Image;
    static public function open(path:String):Image;
    public function save(path:String):Void;
    public function paste(image:Image, ?offset:Vector2):Void;
    public function thumbnail(size:Vector2):Void;
    public var width:Int;
    public var height:Int;
}
