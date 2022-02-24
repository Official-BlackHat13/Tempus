//
//  Class:
//      VdfGlobals
//
//  Contains some global methods & constants.
//  
//  Since:      
//      25-01-2006
//  Changed:
//      --
//  Version:    
//      0.9
//  Creator:    
//      Data Access Europe (Harm Wibier)
//

if(typeof(VdfGlobals) != "Object"){
    var VdfGlobals = new Object();
}

var dfLT    = 0;
var dfLE    = 1;
var dfEQ    = 2;
var dfGE    = 3;
var dfGT    = 4;
var dfFirst = 6;
var dfLast  = 7;
//  DEPRECATED
var dfRowID = "";

VdfGlobals.soap = new Object();

//
//  Generates xml for VdfField
//
//  Params:
//      oField  VdfField object
//      bEmpty  (optional) If true the field is left blank
//  Returns:
//      Default field xml ("<TResponseCol>")
//
VdfGlobals.soap.getVdfFieldXml = function(oField, bEmpty){
    return VdfGlobals.soap.getFieldXml(oField.getName(), ((bEmpty) ? "" :  oField.getValue()), oField.getChangedState());
}

//
//  Generates xml for field
//
//  Params:
//      sName           Name of the field
//      sValue          Value of the field
//      bChangedState   Changed state of the field
//  Returns:
//      String with xml representing the field
//
VdfGlobals.soap.getFieldXml = function(sName, sValue, bChangedState){
    var sXml = new JStringBuilder();
    
    sXml.append("<TAjaxRequestCol>\n");
    sXml.append("<sName>" + sName.replace("__", ".") + "</sName>\n");
    sXml.append("<sType>D</sType>\n");
    sXml.append("<bChangedState>" + (bChangedState ? "true" : "false") + "</bChangedState>\n");
    sXml.append("<sValue>" + browser.xml.encode(sValue) + "</sValue>\n");
    sXml.append("</TAjaxRequestCol>\n");
    
    return sXml.toString();
}

//
//  Params:
//      sName               Name of the message (usualy source object)
//      sRequestType        Name of the type of request
//      sTable              Name of main table used for the action
//      sColumn             Column on which the action is performed 
//      sFieldValues        Field values needed for the action
//      sIndex              Index used for the action (default = "")
//      sFindMode           Mode used for the (find)action (default = "")
//      iMaxRows            Maximum number of rows the server may return 
//                          (default = 1)
//      sUserData           User fields
//      bReturnCurrent      Return current DD values (default = false)
//      sType               Extra type for handling response in correct way 
//                          (default = "")
//      bNoClear            If true the data of the last requestset will be 
//                          used again (no clears are performed between) 
//                          (default = false)
//      
VdfGlobals.soap.getRequestSet = function(sName, sRequestType, sTable, sColumn, sFieldValues, sIndex, sFindMode, iMaxRows, sUserData, bReturnCurrent, sType, bNoClear){
    var sXml = new JStringBuilder();
    
    //  Parse optional params if needed:
    if(typeof(sType) == "string"){
        sName += "_" + sType;
    }
    if(typeof(bReturnCurrent) != "boolean"){
        var bReturnCurrent = false;
    }
    if(typeof(iMaxRows) == "undefined"){
        var iMaxRows = 1;
    }
    if(typeof(sIndex) == "undefined"){
        var sIndex = "";
    }
    if(typeof(sFindMode) == "undefined"){
        var sFindMode = "";
    }
    if(typeof(sUserData) == "undefined"){
        var sUserData = "";
    }
    if(typeof(bNoClear) == "undefined"){
        var bNoClear = false;
    }
    
    //  Generate XML
    sXml.append("<TAjaxRequestSet>\n");
    sXml.append("<sName>" + sName + "</sName>\n");
    sXml.append("<sRequestType>" + sRequestType + "</sRequestType>\n");
    sXml.append("<iMaxRows>" + iMaxRows + "</iMaxRows>\n");
    sXml.append("<sTable>" + sTable + "</sTable>\n");
    sXml.append("<sColumn>" + sColumn + "</sColumn>\n");
    sXml.append("<sIndex>" +sIndex + "</sIndex>\n");
    sXml.append("<sFindMode>" + sFindMode + "</sFindMode>\n");
    sXml.append("<bReturnCurrent>" + bReturnCurrent + "</bReturnCurrent>\n");
    sXml.append("<bNoClear>" + bNoClear + "</bNoClear>\n");
    sXml.append("<aRows>\n");
    sXml.append("<TAjaxRequestRow>\n");
    sXml.append("<aCols>\n");
    sXml.append(sFieldValues);
    sXml.append("</aCols>\n");
    sXml.append("</TAjaxRequestRow>\n");
    sXml.append("</aRows>\n");
    sXml.append("<aUserData>\n");
    sXml.append(sUserData);
    sXml.append("</aUserData>\n");
    sXml.append("</TAjaxRequestSet>\n");
    
    return sXml.toString();
}

//
//  Generates the XML for a userdata field.
//  
//  Params:
//      sName   Name of the field
//      sValue  Value of the field
//  Returns:
//      String with user data XML
//
VdfGlobals.soap.getUserData = function(sName, sValue){
    var sXml = new JStringBuilder();
    
    sXml.append("<TAjaxUserData>\n");
    sXml.append("<sName>" + sName + "</sName>\n");
    sXml.append("<sValue>" + browser.xml.encode(sValue) + "</sValue>\n");
    sXml.append("</TAjaxUserData>\n");
    
    return sXml.toString();
}