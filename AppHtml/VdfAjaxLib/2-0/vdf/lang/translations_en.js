/*
The english translations that are used by default.

@private
*/
vdf.lang.translations_en = {
    error : {
        131 : "sWebObject / vdfWebObject must be set",
        132 : "sMainTable / vdfMainTable must be set",
        133 : "No record found",
        134 : "Reference to form object required in {{0}}",
        135 : "No language loaded!",
        
    	141 : "Unknown control type: {{0}}",
        142 : "Invalid library: {{0}}",
        143 : "Listener should be a function (event: {{0}})",
        144 : "Control name '{{0}}' already exists within the form '{{1}}'",
        145 : "Control should have a name",
        146 : "Control with the name '{{0}}' already exists within the page",
        147 : "Could not find initialization method '{{0}}'",
        148 : "Control defined for prototype({{0}}) that is not available",
        151 : "Field not indexed",
        152 : "Unknown field",
        153 : "Unknown table {{0}}",
        154 : "Unknown field {{0}} in table {{1}}",
        155 : "Unknown data binding: {{0}}",
        
        201 : "Edit row required for grid",
        202 : "Header table should be saved / found first",
        211 : "Display row required for list",
        212 : "Header row required for list",
        213 : "Unknown field in {{0}} row",
        214 : "Unknown row type: {{0}}",
        215 : "Unknown autofind request: {{0}}",
        216 : "Multiple lists (grid / lookup) on a singe table are not allowed",
        217 : "Tab container without a button: {{0}}",
        218 : "Tab button without a container: {{0}}",
        
        301 : "Value must be in uppercase",
        302 : "Value should not be changed",
        303 : "Field requires find",
        304 : "Value is not a valid number",
        305 : "Value is not a valid date",
        306 : "Value is required (0 is not valid)",
        307 : "Value does not match the mask",
        308 : "Value does not matches one of the options",
        309 : "Value is longer then maximum allowed length",
        310 : "Value must be lower than {{0}}",
        311 : "Value must be higher than {{0}}",
        312 : "Value is required",
        501 : "Could not find response node in response XML",
        502 : "Could not parse response XML",
        503 : "HTTP error occurred (Status: {{0}}, Text: {{1}})",
        504 : "Server returned soap error (Code: {{0}}, Text: {{1}})",
        title : "Error {{0}} occurred!"
    },
    
    list : {
        search_title : "Search..",
        search_value : "Search value",
        search_column : "Column",
        search : "Search",
        cancel : "Cancel"
    },
    
    lookupdialog : {
        title : "Lookup dialog",
        select : "Select",
        cancel : "Cancel",
        search : "Search",
        lookup : "Lookup"
    },
    
    calendar : {
        today : "Today is",
        wk : "Wk",
        daysShort : ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
        daysLong : ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Firday", "Saturday"],
        monthsShort : ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
        monthsLong : ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    },
    
    global : {
        ok : "OK",
        cancel : "Cancel"
    }
};
vdf.register("vdf.lang.translations_en");