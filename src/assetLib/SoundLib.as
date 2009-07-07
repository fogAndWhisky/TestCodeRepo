/**
 * Embedded Sounds
 */

package assetLib
{
	public class SoundLib
	{
		/** Lightning */
		[Embed (source="sounds/zap.mp3")]
		public static const ZAP_SOUND:Class;
		
		/** Particle explodes */
		[Embed (source="sounds/explode.mp3")]
		public static const EXPLODE_SOUND:Class;
		
		/** User fails level */
		[Embed (source="sounds/higgs.mp3")]
		public static const FAIL_SOUND:Class;
		
		/** User succeeds at level */
		[Embed (source="sounds/fanfare.mp3")]
		public static const SUCCESS_SOUND:Class;
	}
}