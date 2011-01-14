/**
* @persistent
*/
component table="bucket_files" {
    property name="id" fieldtype="id" type="string" generator="uuid" length="32";
    property name="bucket" column="bucket_id" cfc="Buckets" fieldtype="one-to-one";
    property name="filename" column="filename";
    property name="filesize" column="filesize" ormtype="int";
    property name="created" column="created_date";
    property name="accessed" column="accessed_date";
    property name="displayCount" column="display_count" ormtype="int";
    
    // EVENT HANDLING
    function preInsert(){
        setCreated(now());
        setAccessed(now());
        setDisplayCount(JavaCast("int",1));
    }
    
    // ADDITIONAL FUNCTIONALITY
    function loadByBucketFilename(required Buckets bucket, required string filename){
        // return file object
        return EntityLoadByExample(new Files(bucket=arguments.bucket, filename=arguments.filename), true);
    }
}