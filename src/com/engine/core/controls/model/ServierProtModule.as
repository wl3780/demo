// Decompiled by AS3 Sorcerer 3.16
// http://www.as3sorcerer.com/

//com.engine.core.controls.model.ServierProtModule

package com.engine.core.controls.model
{
    import flash.utils.getQualifiedClassName;
    import com.engine.core.controls.service.IMessage;

    public class ServierProtModule extends Module 
    {

        public static const NAME:String = getQualifiedClassName(ServierProtModule);

        public function ServierProtModule()
        {
            this.register(NAME);
        }

        override public function subHandler(_arg_1:IMessage):void
        {
            super.subHandler(_arg_1);
        }


    }
}//package com.engine.core.controls.model

