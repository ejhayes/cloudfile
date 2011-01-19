<cfscript>
    c = new cloudfile.client.client();
    
</cfscript>

<html>
    <head>
        <title>CloudFile Admin Console</title>
        <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script> 
        <!-- File Uploading -->
        <link rel="stylesheet"  href="../vendor/file-uploader/client/fileuploader.css" type="text/css" />
        <script type="text/javascript" src="../vendor/file-uploader/client/fileuploader.js"></script>
        
        <!-- Table sorting -->
        <link rel="stylesheet"  href="../vendor/tablesorter/tablesorter.css" type="text/css" />
        <script type="text/javascript" src="../vendor/tablesorter/jquery.tablesorter.min.js"></script>
        <script type="text/javascript" src="../vendor/tablesorter/jquery.metadata.js"></script>
        <script type="text/javascript" src="app.js"></script>
        <script type="text/javascript">
            $(function(){
                // delete functionality without page refreshing
                $(".removeItem").bind("click", function(){
                    if( !confirm("Are you sure you want to delete this item?  You cannot undo this!") ) return false;
                    
                    $.ajax({
                        type:'POST',
                        context: $('#' + this.id).parent().parent(),
                        url:'<cfoutput>#c.methodLink("removeItem")#</cfoutput>',
                        data: {
                            id: this.id,
                        },
                        success: function(data, textStatus) {
                            if(data.success){
                                this.remove();
                            } else {
                                alert(data.error_message);
                            }
                        },
                        dataType: "json"
                    });
                    
                    return false;
                });
                
                $(".removeBucket").bind("click", function(){
                    if( !confirm("Are you sure you want to delete the bucket '" + this.name + "' and all associated content?  You cannot undo this!") ) return false;
                    
                    $.ajax({
                        type:'POST',
                        url:'<cfoutput>#c.methodLink("removeBucket")#</cfoutput>',
                        data: {
                            bucket: this.name,
                        },
                        success: function(data, textStatus) {
                            if(data.success){
                                // redirect back to the main page
                                window.location = '.';
                            } else {
                                alert(data.error_message);
                            }
                        },
                        dataType: "json"
                    });
                    
                    return false;
                });
                
                $("#addBucket").bind("click", function(){
                    // don't let the user enter bad data
                    var b = prompt('enter a bucket name');
                    if(b=="") return false;
                    
                    $.ajax({
                        type:'POST',
                        url:'<cfoutput>#c.methodLink("addBucket")#</cfoutput>',
                        data: {
                            bucket: b,
                        },
                        success: function(data, textStatus) {
                            if(data.success){
                                // redirect back to the main page
                                window.location = '?' + this.data;
                            } else {
                                alert(data.error);
                            }
                        },
                        dataType: "json"
                    });
                    
                    return false;
                });
                
                $(".renameBucket").bind("click", function(){
                    var n = prompt('change name to what');
                    if(n=="") return false;
                    
                    $.ajax({
                        type:'POST',
                        url:'<cfoutput>#c.methodLink("renameBucket")#</cfoutput>',
                        data: {
                            oldName: this.name,
                            newName: n,
                        },
                        success: function(data, textStatus) {
                            if(data.success){
                                // redirect back to the main page
                                window.location = '.';
                            } else {
                                alert(data.error);
                            }
                        },
                        dataType: "json"
                    });
                    
                    return false;
                });
                
                function addFile(id, filename, showMethod, removeClass){
                    $(".tablesorter").find('tbody')
                        .append($('<tr>')
                            .append($('<td>')
                                .append($('<a>')
                                    .attr('href', showMethod)
                                    .attr('target', '_blank')
                                    .text(filename)
                                )
                            )
                            .append($('<td>')
                                .text('?')
                            )
                            .append($('<td>')
                                .text('Now')
                            )
                            .append($('<td>')
                                .text('Now')
                            )
                            .append($('<td>')
                                .text('1')
                            )
                            .append($('<td>')
                                .append($('<a>')
                                    .attr('href', '#')
                                    .attr('id', id)
                                    .attr('class', removeClass)
                                    .text('DELETE')
                                )
                            )
                        );
                }
                
                var uploader = new qq.FileUploader({
                    element: $('#file-uploader')[0],
                    action: '<cfoutput>#c.methodLink("putXHR")#</cfoutput>',
                    params: {
                        bucket: $('#file-uploader').attr('name')
                    },
                    onComplete: function(id, fileName, responseJSON){
                        // add the item to the table!
                        if(responseJSON.success) {
                            addFile(responseJSON.result, fileName, '<cfoutput>#c.link()#</cfoutput>' + responseJSON.result, 'removeItem');
                        }
                    }
                });


            });
        </script>
    </head>
    
    <body>
        <h1><a href=".">Admin Home</a></h1>
        <cfif structKeyExists(url,"bucket")>
            <!--- Show bucket info --->
            <cfset r = c.getContents(url.bucket).result.files />
            <h1>Contents of <cfoutput>#url.bucket#</cfoutput> ( <a class="removeBucket" name="<cfoutput>#url.bucket#</cfoutput>" href="#">remove bucket</a> )</h1>

            <!-- Add items to the bucket -->
            <div id="file-uploader" name="<cfoutput>#url.bucket#</cfoutput>">       
                <noscript>          
                    <p>Please enable JavaScript to use file uploader.</p>
                    <!-- or put a simple form for upload here -->
                </noscript>         
            </div>
            
            <table class="tablesorter" width="100%">
                <thead>
                    <tr>
                        <th>Filename</th>
                        <th>Filesize</th>
                        <th>Created</th>
                        <th>Last Accesses</th>
                        <th>Display Count</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <cfloop array="#r#" index="i"><cfoutput>
                    <tr>
                        <td><a href="#c.link(i.id)#" target="_blank">#i.filename#</a></td>
                        <td>#i.filesize#</td>
                        <td>#i.created#</td>
                        <td>#i.accessed#</td>
                        <td>#i.displayCount#</td>
                        <td><a href="##" id="#i.id#" class="removeItem">DELETE</a></td>
                    </tr>
                    </cfoutput></cfloop>
                </tbody>
            </table>
        <cfelseif structKeyExists(url,"file")>
            <!--- Show file info --->
        <cfelse>
            <h1>Buckets ( <a id="addBucket" href="#">add new</a> )</h1>
            <ul>
                <cfloop array="#c.getContents().result#" index="i"><cfoutput>
                    <li><a href="?bucket=#i#">#i# - view contents</a> - <a href="##" class="renameBucket" name="#i#">rename</a> <a href="##" name="#i#" class="removeBucket">delete</a></li>
                </cfoutput></cfloop>
            </ul>
        </cfif>
    </body>
</html>