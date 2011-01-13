/*
the point of this application is to loosely couple applications to the files they manage

*/
component {
    function onApplicationStart(){
        // setup the cloudfile object that will serve all subsequent requests
        this.server = new cloudfile();
    }

    function onRequestStart(string targetPage){
        onApplicationStart();

        try {
            var ret = "";
            
            switch(url.method){
                case "put":
                    form.content = BinaryDecode(form.content,"Base64");
                    this.server.put(argumentCollection=form);
                    break;
                case "get":
                    // do nothing
                    ret = this.server.get(argumentCollection=form);
                    break;
                case "show":
                    // our special case function to display the content on screen
                    local.response = getPageContext().getResponse().getResponse();
                    local.out = response.getOutputStream();
                    local.f = this.server.get(argumentCollection=url);
                    local.mime = getPageContext().getServletContext().getMimeType(url.filename);
                    
                    // set the mimetype, or make this an attachment
                    if(mime != ""){
                        response.setContentType(mime);
                    } else {
                        response.setHeader("Content-Disposition","attachment;filename=#url.filename#");
                    }
                    
                    // if we can't, just let the user download the attachment
                    response.setContentLength(ArrayLen(f));
                    
                    // write the output stream
                    out.write(f);
                    out.flush();
                    out.close();
                    return; 
                default:
                    ret = {"success" = false, error_message = "invalid method."};
            }
            
            // write the output to screen
            WriteOutput(SerializeJSON({"success" = true, "result" = ret}));
        } catch(java.lang.Exception e) {
            // unforeseen errors
            WriteOutput(SerializeJSON({"success" = false, "error_message" = e.message}));
        }
    }
}