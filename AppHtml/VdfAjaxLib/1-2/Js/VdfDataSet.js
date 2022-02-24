//
//  Class:
//      VdfDataSet
//
//  Represents a set of data (field values) that can be seen / used as a record.
//  Contains functionality to parse the data from xml.
//  
//  Since:      
//      27-10-2005
//  Changed:
//      --
//  Version:    
//      0.9
//  Creator:    
//      Data Access Europe (Harm Wibier)
//

//
//  Constructor: Initializes the attributs and if XmlData is given it calls the
//  parseRowXml method.
//
//  Params:
//      oDbList     DbList to wich the record belongs
//      oXmlData    Xml object that contains the record data
//
function VdfDataSet(oVdfForm, oXmlData){
    this.oVdfForm       = oVdfForm;
    
    //  Private properties
    this.aValues        = new Object();
    this.aDescriptions  = new Object();

    if(oXmlData != null){
        this.bNew = false;
        this.parseRowXml(oXmlData);
    }else{
        this.bNew = true;
    }
}

//
//  Params:
//      sColumn Name of the column
//  Returns:
//      Value of the requested field
//
VdfDataSet.prototype.getValue = function(sColumn){
    var sDefaultValue;

    //  If no value available use the default value
    if(this.aValues[sColumn] == null || this.bNew){
        
        sDefaultValue = this.oVdfForm.oVdfInfo.getColumnProperty(sColumn, "sDefaultValue");
        
        if(sDefaultValue == null) sDefaultValue = "";
                
        if(this.oVdfForm.oVdfInfo.getColumnProperty(sColumn, "sDataType") == "bcd"){
            if (sDefaultValue == "") sDefaultValue = "0";
        }
        return sDefaultValue;
    }else{    
        return this.aValues[sColumn];
    }
}

//
//  Checks if a value is available for the columm.
//
//  Params:
//      sColumn Name of the column (<table>__<column>)
//
VdfDataSet.prototype.hasValue = function(sColumn){
    return typeof(this.aValues[sColumn]) != "undefined";
}

//
//	Params:
//		sColumn	Name of the column
//		sValue	New value of the column
//
VdfDataSet.prototype.setValue = function(sColumn, sValue){
	this.aValues[sColumn] = sValue;
}

//
//  Checks if a value is available for the columm.
//
//  Params:
//      sColumn Name of the column (<table>__<column>)
//
VdfDataSet.prototype.hasDescriptionValue = function(sColumn){
    return typeof(this.aDescriptions[sColumn]) != "undefined";
}


//
//  Used when only displaying values (like in lists / lookups). First checks if 
//  a description is available, if not it returns the normal value.
//
//  Params:
//      sColumn Name of the column
//  Returns:
//      The display value
//
VdfDataSet.prototype.getDisplayValue = function(sColumn){
    if(this.aDescriptions[sColumn] != null){
        return this.aDescriptions[sColumn];
    }else{
        return this.getValue(sColumn);
    }
}

//
//  Fetches the different columns from the xml and calls the parseFieldXml 
//  method for each column.
//
//  Params:
//      oXmlData    Xml object with record data
//
//  PRIVATE
VdfDataSet.prototype.parseRowXml = function(oXmlData){
    var aCols, iCol;
    
    aCols = browser.xml.find(oXmlData, "TAjaxResponseCol");
    
    for(iCol = 0; iCol < aCols.length; iCol++){
        this.parseFieldXml(aCols[iCol]);
    }   
}

//
//  Parses the xml field data. Fetches the name and value and saves it into the
//  values array.
//
//  Params:
//      oXmlData    Xml object with field data
//
//  PRIVATE
VdfDataSet.prototype.parseFieldXml = function(oXmlData){
    var sName, sValue, sDescription;
    sName = browser.xml.findNodeContent(oXmlData, "sName").toLowerCase().replace(".", "__");

    sValue = browser.xml.findNodeContent(oXmlData, "sValue");
    if(sValue == null){
        sValue = "";
    }
    this.aValues[sName] = sValue;
    
    sDescription = browser.xml.findNodeContent(oXmlData, "sDescriptionValue");
    if(sDescription != null && browser.data.trim(sDescription) != ""){
        this.aDescriptions[sName] = sDescription;
    }
}