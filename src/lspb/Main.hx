package lspb;

import haxe.io.Path;

class Main {
    static var thumbnailSize = Vector2.make(196, 128);
    static var margin = Vector2.make(4, 48);

    private var display:Display;

    static function main() {
        new Main();
    }

    public function new() {
        var targetPath = getTargetDirectory();
        Sys.stdout().writeString("Generating...");

        if(sys.FileSystem.isDirectory(targetPath)) {
            display = new Display();
            var imageFiles = getImageList(targetPath);
            var layout = generateLayout(imageFiles);
            var image = layout.image;

            if(image != null) {
                var offset = 0;

                while(true) {
                    display.draw(layout, offset);
                    Sys.stdout().writeString("\r:");
                    Sys.stdout().flush();

                    switch(getUserCharCode()) {
                        case 113 | 27:
                            break;

                        case 65:
                            offset -= getLinesPerRow();

                        case 66:
                            offset += getLinesPerRow();
                    }
                }
            }

            urxvt.Pixbuf.clear();
            Sys.command("clear");
        }
    }

    static function getTargetDirectory():String {
        var args = Sys.args();

        if(args.length > 0) {
            return args[0];
        }

        return ".";
    }

    static function getImageList(directory:String):Array<String> {
        var result = [];

        for(file in sys.FileSystem.readDirectory(directory)) {
            var path = new Path(file);

            if(path.ext == "png") {
                result.push(directory + "/" + file);
            }
        }

        return result;
    }

    static function insertString(lines:Array<String>, string:String, lineIndex:Int, col:Int) {
        var line = lines[lineIndex];

        if(line == null) {
            line = lines[lineIndex] = "";
        }

        for(i in 0...(col - line.length)) { line += " "; }

        line += string;
        lines[lineIndex] = line;
    }

    function getLinesPerRow():Int {
        var y_spacing = thumbnailSize._2 + margin._2;
        return Std.int(y_spacing / display.getCharHeight());
    }

    function generateLayout(imageFiles:Array<String>):Layout {
        var lines = new Array<String>();
        var col = 0;
        var row = 0;
        var x_spacing = thumbnailSize._1 + margin._1;
        var y_spacing = thumbnailSize._2 + margin._2;
        var maxDisplayNameSize = Std.int(x_spacing / display.getCharWidth());
        var itemsPerRow:Int = Std.int(display.getWidth() / x_spacing);
        var totalRows:Int = Std.int(Math.ceil(imageFiles.length / itemsPerRow));
        var size = Vector2.make(display.getWidth(), y_spacing * totalRows);
        var resultImage = Image._new("RGBA", size);
        var layout = { image:resultImage, lines:lines };

        for(file in imageFiles) {
            if(display.getWidth() - col * x_spacing < thumbnailSize._1) {
                col = 0;
                row++;
            }

            try {
                var image = Image.open(file);
                image.thumbnail(thumbnailSize);
                var offset = Vector2.make(
                                 col * x_spacing + Std.int(thumbnailSize._1/2 - image.width/2),
                                 row * y_spacing + Std.int(thumbnailSize._2/2 - image.height/2)
                             );
                resultImage.paste(image, offset);
            } catch(e:Dynamic) {
                // Skip.
            }

            {
                var path = new Path(file);
                var lineIndex = Std.int((y_spacing * (row + 1)) / display.getCharHeight()) - 1;
                var charIndex = Std.int((x_spacing * col) / display.getCharWidth());
                var displayName = path.file + "." + path.ext;

                if(displayName.length > maxDisplayNameSize) {
                    displayName = displayName.substr(0, maxDisplayNameSize);
                }

                var offset = Std.int((maxDisplayNameSize - displayName.length)/2);
                insertString(lines, displayName, lineIndex, charIndex + offset);
            }

            col++;
            Sys.stdout().writeString(".");
            Sys.stdout().flush();
        }

        return layout;
    }

    static function getUserInput():String {
        var fd = python.lib.Sys.stdin.fileno();
        var old_settings = python.lib.Termios.tcgetattr(fd);
        var ch:String = null;

        try {
            python.lib.Tty.setraw(python.lib.Sys.stdin.fileno());
            ch = python.lib.Sys.stdin.read(1);
        } catch(e:Dynamic) {
        }

        python.lib.Termios.tcsetattr(fd, python.lib.Termios.TCSADRAIN, old_settings);

        return ch;
    }

    static function getUserCharCode():Int {
        var input = getUserInput();
        var firstCharCode = input.charCodeAt(0);

        if(firstCharCode == 27) {
            input = getUserInput();
            firstCharCode = input.charCodeAt(0);
        }

        return firstCharCode;
    }
}
