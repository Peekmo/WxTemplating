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
}