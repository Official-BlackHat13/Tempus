//
//  Class:
//      VdfErrorHandler
//
//  Handles the errors for the ajax framework in a standard way. It holds error
//  objects that contain error information for occurred errors. It works with 
//  standard error objects for which a few different constructors are 
//  available. It displays field errors in dom objects with the id 
//  <table>__<field>__error and css class fieldError if they are available. If 
//  the JModalDialog is available this is used to display the errors.
//
//  Errors are catched by:
//  try{
//      ....
//  }catch(oError){
//      VdfErrorHandle(oError);
//  }
//  Errors are thrown like:
//  throw new VdfError(200, "Short description", "table", "column", this.oVdfForm, this);
//  throw new VdfFieldError(200, "Short description", oVdfField, this.oVdfForm, this);
//  And can be reported without breaking out of the code:
//  VdfErrorHandle(new VdfError(200, "Shor description", "table", "column", this.oVdfForm, this);
//  
//
//  Since:
//      11-11-2005
//  Changed:
//      05-03-2006  Harm Wibier     Restructured and made compatible with the 
//                                  new error class.
//      17-08-2007  Harm Wibier     Total rewrite of the code for throw, try & 
//                                  catch meganism. Now uses only global 
//                                  methods for more easy user changes.
//  Version:
//      1.1
//  Creator:
//      Data Access Europe (Harm Wibier)
//

//  PRIVATE
var aVdfErrors = new Array();   //  Array with outstanding field errors

var sVdfErrorCss = "fieldError";    //  CSS class attached
var sVdfErrorExtension = "__error";  //  Id extencion for field error fields

//  Object / Array of all known errors
var aVdfErrorMessages = {
    131 : "sWebObject / vdfWebObject must be set",
    132 : "sMainTable / vdfMainTable must be set",
    133 : "No record found",
	141 : "Unknown control type: {{0}}",
    151 : "Field not indexed",
    152 : "Unknown field",
    201 : "Edit row required for grid",
    202 : "Header table should be saved / found first",
    211 : "Display row required for list",
    212 : "Header row required for list",
    213 : "Unknown field in {{0}} row",
    214 : "Unknown row type: {{0}}",
    215 : "Unknown autofind request: {{0}}",
    216 : "Multiple lists (grid / lookup) on a singe table are not allowed",
    301 : "Value must be in uppercase",
    302 : "Value should not be changed",
    303 : "Field requires find",
    304 : "Value is not a valid number",
    305 : "Value is not a valid date",
    306 : "Value is required (0 is not valid)",
    307 : "Value does not match the mask",
    308 : "Value does not matches one of the options",
    309 : "Value is longer then maximum allowed length",
    310 : "Value is higher then maximum allowed value",
    311 : "Value is lower then minimum allowed value",
    312 : "Value is required",
    501 : "Could not find response node in response XML",
    502 : "Could not parse response XML"
};

//
//  Global error handling method. Makes sure error messages are displayed.
//
//  Params:
//      oError  Error that occured
//
function VdfErrorHandle(oError){
    var bHandle = true, iDisplayed;
    
    //  Forward unknown errors (throw them again)
    if(oError.message != null || oError.description != null){
        bHandle = false;
        throw oError;
    }
    
    //  Check if error isn't already out there
    if(oError.sTable != null){
        for(iDisplayed = 0; iDisplayed < aVdfErrors.length; iDisplayed++){
            if(oError.sTable == aVdfErrors[iDisplayed].sTable && oError.sColumn == aVdfErrors[iDisplayed].sColumn && oError.iErrorNr == aVdfErrors[iDisplayed].iErrorNr){
                bHandle = false;
                break;
            }
        }
    }
    
    //  Call displaying method if needed
    if(bHandle){
        VdfErrorDisplay(oError);
    }
}

//
//  Displays the given error. Makes sure the correct display method (global, 
//  table or field is called).
//
//  Params:
//      oError  Error to be displayed
//
function VdfErrorDisplay(oError){
    if(oError.sTable != null && oError.sColumn != null && oError.sTable != "" && oError.sColumn != ""){
        VdfErrorDisplayField(oError);
    }else if(oError.sTable != null && oError.sTable != ""){
        VdfErrorDisplayTable(oError);
    }else{
        VdfErrorDisplayGlobal(oError);
    }
}

//
//  Displays the error as a modal dialog.
//
//  Params:
//      oError  Object representing the error
//
function VdfErrorDisplayGlobal(oError){
    var sTitle;

    if(typeof(JModalDialog_Alert) == "function"){
        sTitle = "Error " + oError.iErrorNr + " occurred";
        if(oError.sLocation == "client" && oError.oVdfSource != null && oError.oVdfSource.sName != null){
            sTitle += " in " + oError.oVdfSource.sName;
        }else if(oError.sLocation == "client" && oError.oVdfForm != null && oError.oVdfForm.sName != null){
            sTitle += " in " + oError.oVdfForm.sName;
        }
        
        sTitle += " on the " + oError.sLocation;
        
        JModalDialog_Alert(oError.sDescription, sTitle);
    }else{
        alert(oError.sDescription);
    }
}

//
//  Adds the table to the description and calls the global display method.
//
//  Params:
//      oError  Error to be displayed
//
function VdfErrorDisplayTable(oError){
    oError.sDescription += " (table: " + oError.sTable + ")";
    VdfErrorDisplayGlobal(oError);
}

//
//  Displays the field error by adding a span with the error text to the error 
//  dom element if found and marks the  field red.
//
//  Params:
//      oError  Field error
//
function VdfErrorDisplayField(oError){
    var aErrorFields, iPos, oErrorField, oField, sOrigCSS;
    
    if(oError.oVdfForm != null){
        //  Find the dom object for field error messages
        aErrorFields = browser.dom.getElementsByClassName(oError.oVdfForm.oForm, "*", "Error")
        for(iPos in aErrorFields){
            if (aErrorFields[iPos].id.toLowerCase() == (oError.sTable + "__" + oError.sColumn + sVdfErrorExtension).toLowerCase())
            {
                oErrorField = aErrorFields[iPos];
                break;   
            }
        }
    }
    
    if(oErrorField != null){
        aVdfErrors.push(oError);
    
        //  Add span with error to the error field
        oError.oDomObject = document.createElement("span");
        browser.dom.setCellText(oError.oDomObject, oError.sDescription.replace('\n' + '<br>') + ";");
     	oErrorField.appendChild(oError.oDomObject);
        

        //  Find field and if not already done add error css class
        oField = oError.oVdfForm.getField(oError.sTable + "__" + oError.sColumn);
        
        if(oField != null){
            sOrigCSS = oField.getCSSClass();
        
            if(sOrigCSS.indexOf((" " + sVdfErrorCss)) == -1){
                oError.sOriginalCSS = sOrigCSS;
                
                if(sOrigCSS != ""){
                    oField.setCSSClass((sOrigCSS + " " + sVdfErrorCss));
                }else{
                    oField.setCSSClass(sVdfErrorCss);
                }
            }else{
                oError.sOriginalCSS = null;
            }
            
            //  If not selected select field
            if(oError.oVdfForm.oLastFocus != oField){
                oField.focusSelect();
            }
        }
        
        oError.oVdfField = oField;
        
        //  If tabmenu in the page call it to make sure the error is visible
        oTabMenu = document.getElementById("JTabMenu");
        if(document.getElementById("JTabMenu") != null){
            oTabMenu.oJTabMenu.displayTabWithElement(oErrorField);
        }
    }else{
        //
        oError.sDescription = oError.sDescription + " (Table: " + oError.sTable + " Column: " + oError.sColumn + ")";
        VdfErrorDisplayGlobal(oError);
		

    }    
}

//
//  Clears all errors with the given number on the given field.
//
//  Params:
//      sTable      Table of the error
//      sColumn     Column of the error
//      iErrorNr    Number of the error
//
function VdfErrorsClearError(sTable, sColumn, iErrorNr){
    var iError;
    
    for(iError = 0; iError < aVdfErrors.length; iError++){
        if(aVdfErrors[iError].sTable == sTable && aVdfErrors[iError].sColumn == sColumn && aVdfErrors[iError].iErrorNr == iErrorNr){
            VdfErrorClear(aVdfErrors[iError]);
            aVdfErrors.splice(iError, 1);
            iError--;
        }
    }
}

//
//  Clears all errors on the given field.
//
//  Params:
//      sTable  Table of the field
//      sColumn Column name of the field
//
function VdfErrorsClearField(sTable, sColumn){
    var iError;
    
    for(iError = 0; iError < aVdfErrors.length; iError++){
        if(aVdfErrors[iError].sTable == sTable && aVdfErrors[iError].sColumn == sColumn){
            VdfErrorClear(aVdfErrors[iError]);
            aVdfErrors.splice(iError, 1);
            iError--;
        }
    }
}

//
//  Clears all errors currently out there.
//
function VdfErrorsClearAll(){
    var iError;
    
    for(iError = 0; iError < aVdfErrors.length; iError++){
        VdfErrorClear(aVdfErrors[iError]);
        aVdfErrors.splice(iError, 1);
        iError--;
    }
}

//  
//  Clears the given error, switches between the different error types (field, 
//  table and global).
//
//  Params:
//      oError  The displayed error to be cleared
//
function VdfErrorClear(oError){
    if(oError.sTable != null && oError.sColumn != null){
        VdfErrorClearField(oError);
    }else if(oError.sTable != null){
        VdfErrorClearTable(oError);
    }else{
        VdfErrorClearGlobal(oError);
    }
}

//
//  Clears global errors (does nothing)
//
//	Params:
//		oError	Error to clear
//
function VdfErrorClearGlobal(oError){

}

//
//	Clears table errors (does nothing)
//
//	Params:
//		oError	Error to clear
//
function VdfErrorClearTable(oError){

}

//
//	Clears field errors by removing their error span and resetting orrigional 
//	css.
//
//	Params:
//		oError	Error to clear
//
function VdfErrorClearField(oError){
    if(oError.oDomObject){
        oError.oDomObject.parentNode.removeChild(oError.oDomObject);
        oError.oDomObject = null;
        
        if(oError.oVdfField != null && oError.sOriginalCSS != null){
            oError.oVdfField.setCSSClass(oError.sOriginalCSS);            
        }
    }
}

//
//  Searched for the predefined error description in the array and replace the 
//  given parts in the text. Replacements are defined like: {{0}} {{1}}
//
//  Params:
//      iError          Number of the error
//      aReplacements   Array with replacements for the description
//  Returns:
//      String with error description
//
function VdfErrorGenerate(iErrorNr, aReplacements){
    var sDescription, iReplacement;
    
    sDescription = aVdfErrorMessages[iErrorNr];
    
    if(sDescription != null && aReplacements != null){
        for(iReplacement in aReplacements){
            sDescription = sDescription.replace("{{" + iReplacement + "}}", aReplacements[iReplacement]);
        }
    }
    
    return sDescription;
}

//
//	Contructor of a error object that can be handled by the error handling 
//	methods. Sets the given properties to itself. Is usually thrown or given to
//	the VdfErrorHanlde method.
//
//	Params:
//      iErrorNr            Number identifying the error
//      sLocalDescription   Short description of the error (used if unknown error)
//      sTable              Table on which the error applies (optional)
//      sColumn             Column on which the error applies (optional)
//      oVdfForm            VdfForm on which the error occured (optional)
//      oVdfSource          VdfSource object on which the error occured 
//                          (optional)
//      aReplacements       Array with text snippets to replace in the error 
//                          (optional)
//
function VdfError(iErrorNr, sLocalDescription, sTable, sColumn, oVdfForm, oVdfSource, aReplacements){
    var sDescription;
    
    if(typeof(oVdfForm) == "undefined"){
        var oVdfForm = null;
    }
    if(typeof(oVdfSource) == "undefined"){
        var oVdfSource = null;
    }
    if(typeof(sTable) == "undefined"){
        var sTable = null;
    }
    if(typeof(sColumn) == "undefined"){
        var sColumn = null;
    }
    if(typeof(aReplacements) == "undefined"){
        var aReplacements = null;
    }
    
    this.iErrorNr = iErrorNr;
    this.sTable = sTable;
    this.sColumn = sColumn;
    this.oVdfForm = oVdfForm;
    this.oVdfSource = oVdfSource;
    this.sLocation = "client"
    
    sDescription = VdfErrorGenerate(iErrorNr, aReplacements);
    if(sDescription != null){
        this.sDescription = sDescription;
    }else{
        this.sDescription = sLocalDescription;
    }
}

//
//	Contructor of a error object that can be handled by the error handling 
//	methods. Sets the given properties to itself. Is usually thrown or given to
//	the VdfErrorHanlde method.
//
//	Params:
//      iErrorNr            Number identifying the error
//      sLocalDescription   Short description of the error (used if unknown error)
//      oVdfField           VdfField on which the error applies
//      oVdfForm            VdfForm on which the error occured (optional)
//      oVdfSource          VdfSource object on which the error occured 
//                          (optional)
//      aReplacements       Array with text snippets to replace in the error 
//                          (optional)
//
function VdfFieldError(iErrorNr, sLocalDescription, oVdfField, oVdfForm, oVdfSource, aReplacements){
    var sDescription;
    
    if(typeof(oVdfForm) == "undefined"){
        var oVdfForm = oVdfField.oVdfForm;
    }
    if(typeof(oVdfSource) == "undefined"){
        var oVdfSource = null;
    }
    if(typeof(aReplacements) == "undefined"){
        var aReplacements = null;
    }
    
    this.iErrorNr = iErrorNr;
    this.sTable = oVdfField.sTable;
    this.sColumn = oVdfField.sField;
    this.oVdfForm = oVdfForm;
    this.oVdfSource = oVdfSource;
    this.sLocation = "client"
    this.oVdfField = oVdfField;
    
    sDescription = VdfErrorGenerate(iErrorNr, aReplacements);
    if(sDescription != null){
        this.sDescription = sDescription;
    }else{
        this.sDescription = sLocalDescription;
    }
}

//
//  Constructor of a error object using an xml server error.
//
//  Params:
//      oXmlError   Xml object containing the vdf error
//      oVdfForm    Form object in which the error occured (optional)
//      oVdfSource  Vdf object in which the error occured (optional)
//
function VdfServerError(oXmlError, oVdfForm, oVdfSource){
    if(typeof(oVdfForm) == "undefined"){
        var oVdfForm = null;
    }
    if(typeof(oVdfSource) == "undefined"){
        var oVdfSource = null;
    }
    
    this.iErrorNr = browser.xml.findNodeContent(oXmlError, 'iNumber');
    this.sTable = browser.xml.findNodeContent(oXmlError, 'sTableName').toLowerCase();
    this.sColumn = browser.xml.findNodeContent(oXmlError, 'sColumnName').toLowerCase();
    this.sDescription = browser.xml.findNodeContent(oXmlError, 'sErrorText');
    this.oVdfForm = oVdfForm;
    this.oVdfSource = oVdfSource;
    this.sLocation = "server";
}

//
//  Constructor of a error object using just a error number and description.
//
//	Params:
//      iErrorNr            Number identifying the error
//      sLocalDescription   Short description of the error (used if unknown error)
//      oVdfForm    Form object in which the error occured (optional)
//      oVdfSource  Vdf object in which the error occured (optional)
//
//  PRIVATE
function VdfRequestError(iErrorNr, sLocalDescription, oVdfForm, oVdfSource, aReplacements){
    var sDescription;
    
    if(typeof(oVdfForm) == "undefined"){
        var oVdfForm = null;
    }
    if(typeof(oVdfSource) == "undefined"){
        var oVdfSource = null;
    }
    if(typeof(aReplacements) == "undefined"){
        var aReplacements = null;
    }
    
    this.iErrorNr = iErrorNr;
    this.sTable = null;
    this.sColumn = null;
    
    
    sDescription = VdfErrorGenerate(iErrorNr, aReplacements);
    if(sDescription != null){
        this.sDescription = sDescription;
    }else{
        this.sDescription = sLocalDescription;
    }
    
    this.oVdfForm = oVdfForm;
    this.oVdfSource = oVdfSource;
    this.sLocation = "server";
}
