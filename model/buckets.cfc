/**
* @persistent
*/
component table="buckets" {
    property name="id" fieldtype="id" generator="sequence" ormtype="int" params="{sequence='BUCKETS_SEQ'}";
    property name="name" column="name";
    
    // associated files
    property name="files" fkcolumn="bucket_id" cfc="files" type="array" fieldtype="one-to-many" orderby="CREATED_DATE asc";
    
    // EVENTS
    function preInsert(){
        setName(LCase(getName()));
    }
}