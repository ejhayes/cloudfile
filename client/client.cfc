/**
* @accessors
*/
component extends="rest" {
    function init(string bucket){
        return super.init("http://localhost:8500/cloudfile/");
    }
    
    // GETTERS
    function get(required string id){
        // get the actual file content
        var ret = call("get",{"id" = arguments.id});
        ret["result"]["file"] = BinaryDecode(ret["result"]["file"],"Base64");
        
        return ret;
    }
    
    function getContents(string bucket=""){
        // get the contents of cloudfile or a cloudfile bucket
        return call("getContents", {"bucket" = arguments.bucket});
    }
    
    // SETTERS
    function put(required string bucket, required string filename, required any content){
        // call webservice to put the file away
        return call("put",{"bucket" = arguments.bucket, "filename" = arguments.filename, "content" = BinaryEncode(arguments.content,"Base64")});
    }
    
    // DELETE
    function removeBucket(required string bucket){
        return call("removeBucket", {"bucket" = arguments.bucket});
    }
    
    function removeItem(required string id){
        return call("removeItem", {"id" = arguments.id});
    }
    
    // HELPERS
    string function link(string id){
        return "#getEndpoint()#?method=show&id=#arguments.id#";
    };
}
