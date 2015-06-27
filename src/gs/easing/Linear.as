// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//gs.easing.Linear

package gs.easing
{
    public class Linear 
    {


        public static function easeNone(_arg_1:Number, _arg_2:Number, _arg_3:Number, _arg_4:Number):Number
        {
            return ((((_arg_3 * _arg_1) / _arg_4) + _arg_2));
        }

        public static function easeIn(_arg_1:Number, _arg_2:Number, _arg_3:Number, _arg_4:Number):Number
        {
            return ((((_arg_3 * _arg_1) / _arg_4) + _arg_2));
        }

        public static function easeOut(_arg_1:Number, _arg_2:Number, _arg_3:Number, _arg_4:Number):Number
        {
            return ((((_arg_3 * _arg_1) / _arg_4) + _arg_2));
        }

        public static function easeInOut(_arg_1:Number, _arg_2:Number, _arg_3:Number, _arg_4:Number):Number
        {
            return ((((_arg_3 * _arg_1) / _arg_4) + _arg_2));
        }


    }
}//package gs.easing

