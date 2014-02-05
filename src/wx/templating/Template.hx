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
     * @var parameters: Parameters passed to the template
     */
    public var parameters(null, null): Dynamic;

    /**
     * Constructor - Sets resource to execute
     * @param  resource: String        Template
     */
    public function new(resource: String) : Void 
    {
        this.resource = resource;
    }

    /**
     * Method called to start template's parsing
     * @param  ?parameters: Dynamic       Parameters sent to the template
     * @return              Template parsed
     */
    public function execute(?parameters: Dynamic) : String
    {
        this.parameters = parameters;
        return this.print();
    }

    /**
     * Parse all print symbols on the template ( {{ var }} )
     * @return Resource modified
     */
    private function print() : String
    {
        var data: String = this.resource;
        var reg = ~/{{[ ]*([^{]+)[ ]*}}/g;

        while (null != data) {
            if (!reg.match(data)) break;

            data = reg.matchedRight();
            var vReg = new EReg('{{[ ]*(' + StringTools.trim(reg.matched(1)) + ')[ ]*}}', '');

            this.resource = vReg.replace(this.resource, this.parseVariable(reg.matched(1)));
        }

        return this.resource;
    }

    /**
     * Parse a variable
     * @param  variable: String        Full name of the variable (e.g : user.name)
     * @param  ?object:  Dynamic       Source object of attributes (e.g : user for name attribute)
     * @return           Result or an other object
     */
    private function parseVariable(variable: String, ?object: Dynamic) : Dynamic
    {
        if (null == object) {
            object = this.parameters;
        }

        var pieces : Array<String> = StringTools.trim(variable).split('.');
        var data = Reflect.field(object, pieces[0]);

        if (1 == pieces.length) {
            return data;
        }

        // Remove the current var
        pieces.shift();

        // Work on the next variable
        return this.parseVariable(pieces.join('.'), data);
    }
}
