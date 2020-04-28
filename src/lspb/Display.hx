package lspb;

class Display {
    static var tempFile = "/tmp/lspb.png";
    private var width:Int;
    private var height:Int;
    private var cols:Int;
    private var rows:Int;
    private var charWidth:Int;
    private var charHeight:Int;
    private var backBuffer:Image;

    public function new() {
        var heightLine = new sys.io.Process("xwininfo -id ${WINDOWID} | grep Height").stdout.readAll().toString();
        var widthLine = new sys.io.Process("xwininfo -id ${WINDOWID} | grep Width").stdout.readAll().toString();
        height = parsePropValue(heightLine);
        width = parsePropValue(widthLine);
        cols = Std.parseInt(new sys.io.Process("tput cols").stdout.readAll().toString());
        rows = Std.parseInt(new sys.io.Process("tput lines").stdout.readAll().toString());
        charHeight = Std.int(height/rows);
        charWidth = Std.int(width/cols);
        backBuffer = Image._new("RGBA", getScreenSize());
    }

    public function getWidth() {
        return width;
    }

    public function getHeight() {
        return height;
    }

    public function getCharWidth() {
        return charWidth;
    }

    public function getCharHeight() {
        return charHeight;
    }

    public function getScreenSize() {
        return Vector2.make(width, height);
    }

    public function getRows() {
        return rows;
    }

    static function parsePropValue(prop:String):Int {
        prop = prop.substr(prop.indexOf(':') + 1);
        return Std.parseInt(prop);
    }

    public function draw(layout:Layout, linesOffset:Int) {
        Sys.command("clear");
        var offset = Vector2.make(0, -linesOffset * charHeight);
        backBuffer.paste(layout.image, offset);
        backBuffer.save(tempFile);
        urxvt.Pixbuf.draw(tempFile, 0, 0, 100, 100);

        for(l in 0...rows - 1) {
            var line = layout.lines[l + linesOffset];

            if(line != null) {
                Sys.stdout().writeString(line);
            }

            Sys.stdout().writeString("\n");
        }
    }
}
