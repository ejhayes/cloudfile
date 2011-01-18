/**
* @accessors
*/
component {
    property name="endpoint";

    function init(string endpoint){
        setEndpoint(arguments.endpoint);
        return this;
    }
    
    function call(string method, struct args=StructNew()){
        var s = new http(url=getEndpoint(), charset="utf-8", method="post");
        var ret = {"success" = false};
        var r = "";
        
        // clean this up before doing another call
        s.clearParams();
        
        // make the call
        s.addParam(type="url",name="method",value=arguments.method);
        
        // any variable number of arguments
        for(key in arguments.args){
            s.addParam(type="formfield",name=key,value=arguments.args[key]);
        }
        
        // attempt to call the service
        try {
            r = s.send().getPrefix();
        } catch(java.lang.Exception e) {
            ret["error_message"] = e.message;
        }
        
        // and any post processing efforts
        ret["status"] = r.ResponseHeader.Status_Code;
        
        if(ret.status != 200){
            ret["error_message"] = r.ResponseHeader.explanation;
        } else {
            return deserializeJSON(r.FILECONTENT);
        }
        
        return ret;
    }
}
