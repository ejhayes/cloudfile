<!---
    This page shows example usage of the client
--->
<cfscript>
    // a sample file
    samplePayloadBinary = FileReadBinary(ExpandPath("./samplePayload.txt"));
    
    // our destination bucket
    bucket = "documents";
    otherBucket = "other";
    
    // the client service
    c = new client(); // you can also specify your own endpoint url here
    
    // cleanup before running stuff
    c.removeBucket(bucket);
    c.removeBucket(otherBucket);
    
    // store out results
    r = c.put(bucket, "payload.txt", samplePayloadBinary);
    r1 = c.put(otherBucket, "payload.txt", samplePayloadBinary);
    
    if( r.success ){
        
        // Add a file to CloudFile
        WriteOutput("<h1>Adding a file</h1>");
        WriteDump(r);
        
        // Retrieve a file from cloudfile (actually downloads the item)
        WriteOutput("<h1>Getting a file</h1>");
        documentId = r.result;
        WriteDump(c.get(documentId));
        
        // Generate a link to display this file (does not retrieve the file)
        WriteOutput("<h1>Linking to a file</h1>");
        WriteDump(c.link(documentId))
        
        // What are the contents of my bucket?
        WriteOutput("<h1>Bucket contents</h1>");
        WriteDump(c.getContents(bucket));
        
        // What buckets are there?
        WriteOutput("<h1>All buckets</h1>");
        WriteDump(c.getContents());
        
        // Remove a specific item
        WriteOutput("<h1>Remove specific item</h1>");
        WriteDump(c.removeItem(r1.result));
        
        // Remove an entire bucket (and any items in it)
        WriteOutput("<h1>Remove entire bucket</h1>");
        WriteDump(c.removeBucket(otherBucket));
        
    } else {
        // An error occured!
        WriteDump(r);
    }
</cfscript>