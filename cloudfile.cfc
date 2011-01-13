component {
    binary function get(required string bucket, required string filename){
        // retrieves the specified file from a given bucket
        var f = "";
        f = FileReadBinary("C:\ColdFusion9\wwwroot\cloudfile\#arguments.bucket#\#arguments.filename#");
        
        if( isNull(f) ){
            throw("Unable to load file #arguments.filename# from bucket:#arguments.bucket#");
        }
        
        return f;
    }
    
    string function show(required string bucket, required string filename){
        return "";
    }
    
    void function put(required string bucket, required string filename, required any content){
        // puts a file in a bucket
        FileWrite("C:\ColdFusion9\wwwroot\cloudfile\#arguments.bucket#\#arguments.filename#",arguments.content);
    }
}