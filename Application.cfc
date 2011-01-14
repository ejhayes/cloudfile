/*
the point of this application is to loosely couple applications to the files they manage

*/
component {
    this.name = "cloudfile";
    
    // application configuration
    this.config = new vendor.config.config(ExpandPath("./config.ini"));
    
    // orm settings
    this.dataSource = this.config.dsn;
	this.ormEnabled = true;
	this.ormsettings = {
        dialect="Oracle10g",
		cfclocation="./model",
		eventhandling="true",
		logsql="false",
        savemapping="true"
	};
    

    function onApplicationStart(){
        // setup the cloudfile object that will serve all subsequent requests
        this.server = new cloudfile(this.config.storage);
    }

    function onRequestStart(string targetPage){
        if(structKeyExists(url, "init")) {
            // remove the generated hbxml files since they don't remove themselves
            hibernateFiles = directoryList(ExpandPath(this.ormsettings.cfclocation),false,"path","*.hbmxml");
            for(i=1;i LTE arrayLen(hibernateFiles); i++){
                FileDelete(hibernateFiles[i]);
            }
            
            // now reload the orm and app
            ormReload();
		}
        
        onApplicationStart();
        
        try {
            var ret = "";
            
            switch(url.method){
                case "removeBucket":
                    ret = this.server.removeBucket(argumentCollection=form);
                    break;
                case "getContents":
                    ret = this.server.getContents(argumentCollection=form);
                    break;
                case "put":
                    form.content = BinaryDecode(form.content,"Base64");
                    ret = this.server.put(argumentCollection=form);
                    break;
                case "get":
                    // do nothing
                    ret = this.server.get(argumentCollection=form);
                    ret["file"] = BinaryEncode(ret["file"],"Base64");
                    break;
                case "show":
                    // our special case function to display the content on screen
                    local.response = getPageContext().getResponse().getResponse();
                    local.out = response.getOutputStream();
                    local.f = this.server.get(argumentCollection=url);
                    local.mime = getPageContext().getServletContext().getMimeType(f.FILENAME);
                    
                    // make inline if we have the appropriate mimetype, or just make it an attachment
                    if(mime != ""){
                        response.setContentType(mime);
                        response.setHeader("Content-Disposition","inline;filename=#f.FILENAME#");
                    } else {
                        response.setHeader("Content-Disposition","attachment;filename=#f.FILENAME#");
                    }
                    
                    // if we can't, just let the user download the attachment
                    response.setContentLength(F.FILESIZE);
                    
                    // write the output stream
                    out.write(f.FILE);
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