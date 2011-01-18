/**
* @accessors
*/
component {
    property name="storage";

    function init(string storage){
        setStorage(arguments.storage);
    }
    
    // GETTERS
    struct function get(required string id){
        // retrieves the specified file from a given bucket
        var ret = {};
        var f = EntityLoadByPK("Files",arguments.id);
        
        ret["file"] = FileReadBinary("#getStorage()#\#arguments.id#");
        ret["filename"] = f.getFileName();
        ret["filesize"] = f.getFileSize();
        
        // touch the file
        f.setAccessed(now());
        f.setDisplayCount(f.getDisplayCount()+1);
        EntitySave(f);
        
        if( isNull(f) ){
            throw("Unable to load file #arguments.id#");
        }
        
        return ret;
    }
    
    function getContents(string bucket=""){
        if( arguments.bucket == "" ){
            return ormExecuteQuery("select name from Buckets");
        } else {
            return EntityLoad("buckets", {"name" = LCase(arguments.bucket)});
        }
    }
    
    // SETTERS
    string function put(required string bucket, required string filename, required binary content){
        /* 
        the following atomic operation must take place when we perform a put operation:
        - if the bucket does not exist, it must be created
        - file information must be added to the database
        - file information must be added to the file system
        
        if the following does not occur, then we will have an inconsistent state
        */
        var f = EntityNew("Files");
        var b = EntityLoad("Buckets",{"name" = LCase(arguments.bucket)},true);
        
        // create the bucket if it doesn't exist
        if( isNull(b) ){
            b = EntityNew("Buckets");
            b.setName(LCase(arguments.bucket));
            EntitySave(b);
        }
        
        // now prepare the file object
        f.setBucket(b);
        f.setFileName(arguments.filename);
        f.setFileSize(ArrayLen(arguments.content));
        
        // save and flush the operation
        EntitySave(f);
        ormFlush();
        
        // write the file
        FileWrite("#getStorage()#\#f.getId()#",arguments.content);
        
        return f.getId();
    }
    
    // DELETE
    function removeBucket(required string bucket){
        var b = EntityLoad("buckets",{"name" = LCase(arguments.bucket)},true);
        
        // if the bucket doesn't exist, return normally
        if( isNull(b) ) return true;
        
        // otherwise continue on normally
        local.f = b.getFiles();
        
        for(i=1; i<= ArrayLen(f); i++){
            // remove each associated file from the file system
            removeItem(f[i].getId());
        }
        
        // perform all the necessary writes before we attempt to remove the bucket
        ormFlush();
        
        // remove the bucket from the db (cascade is set to remove children on deletion)
        EntityDelete(b);
        
        return true;
    }
    
    function removeItem(required string id){
        // remove the file
        FileDelete("#getStorage()#\#arguments.id#");
        
        // and the reference to it
        EntityDelete(EntityLoadByPK("Files",arguments.id));
        
        return true;
    }
}