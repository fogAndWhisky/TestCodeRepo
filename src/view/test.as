package {
     import flash.display.Sprite;

     public class _Arial extends Sprite {

          [Embed(source='C:/WINDOWS/Fonts/ARIAL.TTF', fontName='_Arial', unicodeRange='U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E')]

          public static var _Arial:Class;

     }
}


package {

     import flash.display.Loader;
     import flash.display.Sprite;
     import flash.events.Event;
     import flash.net.URLRequest;
     import flash.text.*;

     public class FontLoader extends Sprite {

          public function FontLoader() {
               loadFont("_Arial.swf");
          }

          private function loadFont(url:String):void {
               var loader:Loader = new Loader();
               loader.contentLoaderInfo.addEventListener(Event.COMPLETE, fontLoaded);
               loader.load(new URLRequest(url));
          }

          private function fontLoaded(event:Event):void {
               var FontLibrary:Class = event.target.applicationDomain.getDefinition("_Arial") as Class;
               Font.registerFont(FontLibrary._Arial);
               drawText();
          }

          public function drawText():void {
               var tf:TextField = new TextField();
               tf.defaultTextFormat = new TextFormat("_Arial", 16, 0);
               tf.embedFonts = true;
               tf.antiAliasType = AntiAliasType.ADVANCED;
               tf.autoSize = TextFieldAutoSize.LEFT;
               tf.border = true;
               tf.text = "Scott was here\nScott was here too\nblah scott...:;*&^% ";
               tf.rotation = 15;

               addChild(tf);
          }
     }
}