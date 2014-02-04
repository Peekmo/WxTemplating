package wx.templating;

/**
 * Whaxe template manager
 * @author Axel Anceau (Peekmo)
 */
class Template 
{
    /**
     * @var resource: String Template to execute
     */
    public var resource(null, null): String;

    /**
     * Constructor - Sets resource to execute
     * @param  resource: String        Template
     */
    public function new(resource: String) : Void 
    {
        this.resource = resource;
    }

    public function execute(?parameters: Dynamic) : String
    {
        return this.print(parameters);
    }

    private function print(parameters: Dynamic) : String
    {
        var data: String = this.resource;
        var reg = ~/{{[ ]*([a-z]+)[ ]*}}/g;

        while (null != data) {
            if (!reg.match(data)) break;

            data = reg.matchedRight();
            var vReg = new EReg('{{[ ]*(' + StringTools.trim(reg.matched(1)) + ')[ ]*}}', '');

            this.resource = vReg.replace(this.resource, Reflect.field(parameters, reg.matched(1)));
        }

        return this.resource;
        //return reg.replace(this.resource, Std.string(Reflect.field(parameters, "$1")));
    }
}