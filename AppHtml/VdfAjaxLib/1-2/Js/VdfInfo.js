//
//  Class:
//      VdfInfo
//
//  Requests and stores the information about the data structur of the web
//  object. Has easy access to column property's.
//
//  Since:
//      24-10-2005
//  Changed:
//      --
//  Version:
//      0.9
//  Creator:
//      Data Access Europe (Harm Wibier)
//

//
//  Constructor of VdfInfo object. Initializes column array.
//
//  Params:
//      oVdfForm     The VdfForm object (needed for throwing errors)
//
function VdfInfo(oVdfForm){
    
    //  Global properties
    this.oVdfForm           = oVdfForm;
    this.sDateMask          = null;
    this.sDecimalSeparator  = null;
    this.iDate4_State       = null;
    this.iEpoch             = null;
    this.bInfoLoaded        = false;
    
    //  Private properties
    this.aTables            = new Object();
}

//
//  Loads DDInfo from the server
//
//  Params:
//      sWebObject      Name of the WO to load info of
//      sUrl            Url to request info (null will use default AjaxService.wso)
//
VdfInfo.prototype.loadInfo = function(sWebObject, sUrl){
    var aErrors, oRequest, oInfoDoc;
    var sXml = new JStringBuilder();
    
    sXml.append("<sWebObject>" + sWebObject + "</sWebObject>\n");
    sXml.append("<sSessionKey>" + browser.cookie.get("vdfSessionKey") + "</sSessionKey>\n");
    sXml.append("<sVersion>" + this.oVdfForm.sVersion + "</sVersion>\n");

    oRequest = new comm.XmlRequest(false, "ServiceMetaData", sXml.toString(), null, null, sUrl);
    oRequest.request();
    
    if(oRequest.iError == 0){
        oInfoDoc = oRequest.getResponseXml();
        
        aErrors = browser.xml.find(oInfoDoc, "TAjaxError");
        if(aErrors.length > 0){
            for(iError = 0; iError < aErrors.length; iError++){
                throw new VdfServerError(aErrors[iError], this.oVdfForm);
            }
        }else{
            this.parseResult(oInfoDoc);
            this.bInfoLoaded = true;
        }
    }else{
        throw new VdfRequestError(oRequest.iError, oRequest.sErrorMessage, this.oVdfForm, this);
    }
}

//
//  Fills the aColumns array with information of the columns by looping through
//  the tables and columns callin parseColumnInfo for each column.
//
//  Params:
//      oXmlDoc     Info Xml document
//
//  PRIVATE
VdfInfo.prototype.parseResult = function(oXmlDoc){
    var sTable, sColumn, iTable, iColumn, aTables, aColumns, oGlobalSettings, oParents, sParents;

	// Get Global Settings
	oGlobalSettings = browser.xml.findFirst(oXmlDoc, "tGlobalSettings");
    this.sDateMask = browser.xml.findNodeContent(oGlobalSettings, "sDateMask").toLowerCase();
    this.sDecimalSeparator = browser.xml.findNodeContent(oGlobalSettings, "sDecimalSeparator").toLowerCase();
    this.iDate4_State = browser.xml.findNodeContent(oGlobalSettings, "iDate4_State").toLowerCase();
    this.iEpoch = browser.xml.findNodeContent(oGlobalSettings, "iEpoch").toLowerCase();

	// Get Column information
    aTables = browser.xml.find(oXmlDoc, "TAjaxTableMetaData");
    for(iTable = 0; iTable < aTables.length; iTable++){
        sTable = browser.xml.findFirst(aTables[iTable], "sName").firstChild.nodeValue.toLowerCase();
        
        this.aTables[sTable] = new Object();
        
        this.aTables[sTable].aColumns = new Object();
        
        aColumns = browser.xml.find(aTables[iTable], "TAjaxColumnMetaData");
        for(iColumn = 0; iColumn < aColumns.length; iColumn++){
            sColumn = browser.xml.findFirst(aColumns[iColumn], "sName").firstChild.nodeValue.toLowerCase();

            this.aTables[sTable].aColumns[sColumn] = new Object();
            this.aTables[sTable].aColumns[sColumn].aProperties = this.parseColumnInfo(aColumns[iColumn]);
        }
        

        
        this.aTables[sTable].aProperties = this.parseTableInfo(aTables[iTable]);
        
    }
}

//
//  Parses the column info xml into an array with al the properties of the
//  column.
//
//  Params:
//      oColumnXml  The Xml element with column information
//  Returns:
//      Array with column properties
//
//  PRIVATE
VdfInfo.prototype.parseColumnInfo = function(oColumnXml){
    var result, oCurrent;

    result = new Object();

    oCurrent = oColumnXml.firstChild;

    while(oCurrent != null){
        if(oCurrent.nodeType == 1){
            if(browser.xml.getNodeName(oCurrent) == "aDescriptionValues"){
                result["aDescriptionValues"] = (oCurrent.firstChild != null ? this.parseDescriptionValues(oCurrent) : null);
            }else{
                if(oCurrent.firstChild != null){
                    result[browser.xml.getNodeName(oCurrent)] = oCurrent.firstChild.nodeValue;
                }else{
                    result[browser.xml.getNodeName(oCurrent)] = "";
                }
            }
        }
        oCurrent = oCurrent.nextSibling;
    }

    return result;
}

//
//  Parses the description values into an array of descriptionvalue objects. 
//  Structure: aResult[0].sValue aResult[1].sDescription
//
//  Params:
//      oXmlDescriptionValues   Xml nodes with description values
//  Returns:
//      Array with descriptionvalues
//
//  PRIVATE
VdfInfo.prototype.parseDescriptionValues = function(oXmlDescriptionValues){
    var aResults, aValues, iValue, sValue, sDescription;
    
    aResults = new Array();
    
    aValues = browser.xml.find(oXmlDescriptionValues, "TAjaxDescriptionValue");
    
    for(iValue = 0; iValue < aValues.length; iValue++){
        sValue = browser.xml.findNodeContent(aValues[iValue], "sValue");
        sDescription = browser.xml.findNodeContent(aValues[iValue], "sDescription");
        
        if(sValue != null){
            aResults.push({ sValue : sValue, sDescription : sDescription });
        }
    }
    
    return aResults;
}

//
//  Parses the table info into an array with the property name as index and its
//  value as value.
//  
//  Params:
//      oTableXml   Xml node with information about the table
//  Returns:
//      Array with properties
//
//  PRIVATE
VdfInfo.prototype.parseTableInfo = function(oTableXml){
    var result, oCurrent, sName, aParents = null, aXmlParents, iParent;

    result = new Object();
    aParents = new Array();
    
    //  Loop through table properties
    oCurrent = oTableXml.firstChild;
    while(oCurrent != null){
        if(oCurrent.nodeType == 1){
            if(oCurrent.firstChild != null){
                sName = browser.xml.getNodeName(oCurrent);
                
                if(sName == "aParents"){
                    //  Parse parent tables
                    aXmlParents = browser.xml.find(oCurrent, "string");
                    
                    for(iParent = 0; iParent < aXmlParents.length; iParent++){
                        aParents[iParent] = aXmlParents[iParent].firstChild.nodeValue;
                    }
                    
                    //  Skip column and name childs
                }else if(sName != "sName" && sName != "aColumnMetaData"){
                    result[sName] = oCurrent.firstChild.nodeValue;
                }
            }
        }
        oCurrent = oCurrent.nextSibling;
    }
    
    result["aParents"] = aParents;

    return result;
}

//
//  Gets a column property from the info arrays.
//
//  Params:
//      sColumn     Column name <table>__<column>
//      sProperty   Name of property
//  Returns:
//      String with property value (null if not found)
//
VdfInfo.prototype.getColumnProperty = function(sColumn, sPropertyName){
    var oTable, oColumn, sResult = null;
    
    oTable = this.aTables[sColumn.substr(0, sColumn.indexOf("__"))];
    if(oTable != null){
        oColumn = oTable.aColumns[sColumn.substr(sColumn.indexOf("__") + 2)];
        if(oColumn != null){
            sResult = oColumn.aProperties[sPropertyName];
        }
    }

    return sResult;
}

//
//  Gets a table specific property from the info arrays/
//
//  Params:
//      sTable          Name of the table
//      sPropertyName   Name of the property
//  Returns:
//      Property value (null if not found)
//
VdfInfo.prototype.getTableProperty = function(sTable, sPropertyName){
    var sResult = null;
    
    if(this.aTables[sTable] != null){
        if(this.aTables[sTable].aProperties[sPropertyName] != null){
            sResult = this.aTables[sTable].aProperties[sPropertyName];
        }
    }
    
    return sResult;
}

//
//  Returns array with names of the parent tables of the given table.
//
//  Params:
//      sTable  Name of the table
//  Returns:
//      Array with the parents (null if not found)
//
VdfInfo.prototype.getTableParents = function(sTable){
	return this.getTableProperty(sTable, "aParents");
}

//
//  Params:
//      sTable  Name of the table
//  Returns:
//      Array with the columns of the table
//
VdfInfo.prototype.getTableColumns = function(sTable){
    var aColumns, aResult, sColumn;

    aColumns = this.aTables[sTable].aColumns;
    aResult = new Array();
    
    for(sColumn in aColumns){
        aResult[aResult.length] = sColumn;
    }
    
    return aResult;
}

//
//  Params:
//      sTable  Name of the table
//  Returns:
//      True if the given table name exists in the WO
//
VdfInfo.prototype.tableExists = function(sTable){
    return (this.aTables[sTable] != null);
}

//
//  Params:
//      sTable  Name of the table to which the field belongs
//      sField  Name of the field
//  Returns:
//      True if the given table an field names exist in the WO
//
VdfInfo.prototype.fieldExists = function(sTable, sField){
    return (this.tableExists(sTable) && this.aTables[sTable].aColumns[sField] != null);
}

//
//  Splits the column name into table and field and calls field exists
//
//  Params:
//      sColumn Name of the column <table>__<field>
//  Returns:
//      True if the given column exist in the WO
//
//  DEPRECATED
VdfInfo.prototype.columnExists = function(sColumn){
    var sTable, sField;

    sTable = sColumn.toLowerCase().substr(0, sColumn.indexOf('__'));
    sField = sColumn.toLowerCase().substr(sColumn.indexOf('__') + 2);
    
    return this.fieldExists(sTable, sField);
}

//
//  Returns:
//      True if information already loaded
//
//  DEPRECATED
VdfInfo.prototype.isInfoLoaded = function(){
    return this.bInfoLoaded;
}

