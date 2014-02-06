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
        var reg = ~/{{[ ]*([^}]+)[ ]*}}/g;

        while (null != data) {
            if (!reg.match(data)) {
                break;
            }

            data = reg.matchedRight();
            var vReg = new EReg('{{[ ]*(' + this.escape(reg.matched(1)) + ')[ ]*}}', '');

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

        // If a function is called
        if (StringTools.endsWith(pieces[1], ')')) {

            var value = this.parseFunction(pieces[0], pieces[1], object);
            // If last one, it will return a value
            if (2 == pieces.length) {
                return value;
            }

            pieces[1] = value;
        }

        // Remove the current var
        pieces.shift();

        // Work on the next variable
        return this.parseVariable(pieces.join('.'), data);
    }

    /**
     * Call the given function on the given variable
     * @param  variable: String        Variable on which is called the function
     * @param  func:     String        Function to call
     * @param  object:   Dynamic       Object where the variable come from
     * @return           Function's result
     */
    private function parseFunction(variable: String, func: String, object: Dynamic) : Dynamic
    {
        var data = func.split('(');
        var functionName = data[0];
        data.shift();

        // If functions in arguments
        var stringArgs = data.join('(');

        // Removes last parenthesis
        stringArgs = stringArgs.substr(0, stringArgs.length - 1);

        // Get arguments as array
        var arrArgs : Array<String> = stringArgs.split(',');
        var arguments : Array<Dynamic> = new Array<Dynamic>();

        var reg = ~/^([0-9\.]+|true|false)$/i;
        for (arg in arrArgs.iterator()) {
            arg = StringTools.trim(arg);

            // If string
            if (StringTools.startsWith(arg, '\'') || StringTools.startsWith(arg, '"')) {
                arguments.push(arg.substr(1, arg.length - 2));
            } else if (reg.match(arg)) {
                if ('true' == arg) arguments.push(true);
                else if ('false' == arg) arguments.push(false);
                else arguments.push(Std.parseFloat(arg));
            } else {
                arguments.push(this.parseVariable(arg));
            }
        }

        var inst = Reflect.field(object, variable);
        var ret = Reflect.callMethod(inst, functionName, arguments);

        return ret;
    }

    /**
     * Escape some characters for Regex
     * @param  string: String        String to escape
     * @return         String escaped
     */
    private function escape(string: String) : String
    {
        var escaped = '';
        var iterator: IntIterator = new IntIterator(0, string.length);

        for (i in iterator) {
            switch (string.charAt(i)) {
                case '(', ')', '\'':
                    escaped += '\\' + string.charAt(i);
                default:
                    escaped += string.charAt(i);
            }
        }

        return escaped;
    }
}
