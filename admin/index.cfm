<cfscript>
    c = new cloudfile.client.client();
    
</cfscript>

<html>
    <head>
        <title>CloudFile Admin Console</title>
        <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script> 
        <link rel="stylesheet"  href="../vendor/tablesorter/tablesorter.css" type="text/css" />
        <script type="text/javascript" src="../vendor/tablesorter/jquery.tablesorter.min.js"></script>
        <script type="text/javascript" src="../vendor/tablesorter/jquery.metadata.js"></script>
        <script type="text/javascript" src="app.js"></script>
        <script type="text/javascript">
            $(function(){
                // delete functionality without page refreshing
                $(".removeItem").bind("click", function(){
                    $.ajax({
                        type:'POST',
                        context: $('#' + this.id).parent().parent(),
                        url:'<cfoutput>#c.getEndpoint()#?method=removeItem</cfoutput>',
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
                    $.ajax({
                        type:'POST',
                        url:'<cfoutput>#c.getEndpoint()#?method=removeBucket</cfoutput>',
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
                    $.ajax({
                        type:'POST',
                        url:'<cfoutput>#c.getEndpoint()#?method=addBucket</cfoutput>',
                        data: {
                            bucket: prompt('enter a bucket name'),
                        },
                        success: function(data, textStatus) {
                            if(data.success){
                                // redirect back to the main page
                                window.location = '?' + this.data;
                            } else {
                                alert(data.error_message);
                            }
                        },
                        dataType: "json"
                    });
                    
                    return false;
                });
                
                $(".renameBucket").bind("click", function(){
                    $.ajax({
                        type:'POST',
                        url:'<cfoutput>#c.getEndpoint()#?method=renameBucket</cfoutput>',
                        data: {
                            oldName: this.name,
                            newName: prompt('change name to what'),
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


            });
        </script>
    </head>
    
    <body>
        <h1><a href=".">Admin Home</a></h1>
        <cfif structKeyExists(url,"bucket")>
            <!--- Show bucket info --->
            <cfset r = c.getContents(url.bucket).result.files />
            <h1>Contents of <cfoutput>#url.bucket#</cfoutput> ( <a class="removeBucket" name="<cfoutput>#url.bucket#</cfoutput>" href="#">remove bucket</a> )</h1>
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
                    <li><a href="##" name="#i#" class="removeBucket">[x]</a> <a href="?bucket=#i#">#i#</a> - <a href="##" class="renameBucket" name="#i#">rename</a></li>
                </cfoutput></cfloop>
            </ul>
        </cfif>
    </body>
</html>