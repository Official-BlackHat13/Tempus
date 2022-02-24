//
//  Class:
//      VdfTable
//
//  The table has a lot of information about itself, its fields and its parents.
//  Its functions are mostly recursive to its parents and are so very usefull 
//  for fetching, updating, validating, ... its fields.
//
//  Since:
//      5-10-2006
//  Changed:
//      --
//  Version:
//      0.1
//  Creator:
//      Data Access Europe (Harm Wibier)
//

//
//  Constructor, initializes the properties.
//
//  Params:
//      oVdfForm    Reference to the form object to wich it belongs
//      sName       Name of the table
//  
function VdfTable(oVdfForm, sName){
    this.oVdfForm           = oVdfForm;
    this.sName              = sName;
    
    this.oStatusField       = null;
    this.sConstrainedTo     = null;
    this.sConstrainedFrom   = null;
    this.aParents           = null;
    this.aFields            = new Object();
}

//
//  Loads information from the vdfinfo object.
//
//  PRIVATE
VdfTable.prototype.init = function(){
    this.aParents           = this.oVdfForm.oVdfInfo.getTableParents(this.sName);
    
    this.sConstrainedTo     = this.oVdfForm.oVdfInfo.getTableProperty(this.sName, "sConstrainFile");
    if(this.sConstrainedTo != null){
        this.oVdfForm.aTables[this.sConstrainedTo].sConstrainedFrom = this.sName;
    }

    this.sConstrainedFrom   = null;
}


//
//  Loops through the fields and collects the field xml.
//
//  Params:
//      bRecursive		If true the parent tables fields are also added
//      bEmpty       		If true the fields will be returned empty
//      bOnCallGetData  	If true the global OnGetData will be called 
//                      		(default: true)
//	bConstrained	If false constrained tables won't be added (default: true)
//      aDone           	Array with tables that are already done (to prevent
//                      		looping) (should not be given on initial call)
//  Returns:
//      String with fields xml
//      
VdfTable.prototype.getDataXml = function(bRecursive, bEmpty, bCallOnGetData, bConstrained, aDone){
    var sField, iField, oField, iTable;
    var sXml = new JStringBuilder();
    
    if(typeof(bRecursive) == "undefined"){
        var bRecursive = true;
    }    
    if(typeof(aDone) == "undefined"){
        var aDone = new Object();
    }
    if(typeof(bCallOnGetData) == "undefined"){
        var bCallOnGetData = true;
    }
	if(typeof(bConstrained) == "undefined"){
		var bConstrained = true;
	}
    aDone[this.sName] = true;
    
    if(bCallOnGetData){
        if(typeof(OnGetData) == "function"){
            OnGetData(this.oVdfForm, this.sName);
        }
    }
    
    //  Gather field xml
    for(sField in this.aFields){
        //  Take the first field or the changed field
        oField = this.aFields[sField][0];
        for(iField in this.aFields[sField]){
            if(this.aFields[sField][iField].getChangedState()){
                oField = this.aFields[sField][iField];
                break;
            }
        }
        
        //  Add the field
        sXml.append(VdfGlobals.soap.getVdfFieldXml(oField, (bEmpty)));
    }
    
    for (sField in this.oVdfForm.aDisplayFields){     
        if (document.getElementById(this.oVdfForm.aDisplayFields[sField].value)) sXml.append(VdfGlobals.soap.getFieldXml(document.getElementById(this.oVdfForm.aDisplayFields[sField].value).getAttribute("name"),document.getElementById(this.oVdfForm.aDisplayFields[sField].value).innerHTML, false))
    }
    
    //  Call parents (if needed)
    if(bRecursive){
        for(iTable = 0; iTable < this.aParents.length; iTable++){
            if(!aDone[this.aParents[iTable]] && (bConstrained || this.aParents[iTable] != this.sConstrainedTo)){
                sXml.append(this.oVdfForm.aTables[this.aParents[iTable]].getDataXml(bRecursive, (bEmpty), bCallOnGetData, bConstrained, aDone));
            }
        }
        
        if(bConstrained && this.sConstrainedFrom != null && !aDone[this.sConstrainedFrom]){
            sXml.append(this.oVdfForm.aTables[this.sConstrainedFrom].getDataXml(bRecursive, (bEmpty), bCallOnGetData, bConstrained, aDone));
        }
    }
    
    return sXml.toString();
}

//
//  Validates the fields of the table and of it parents.
//
//  Params:
//      bValidateServer If false no server side validation is done (for save)
//                      (optional, default true)
//      aDone           Array with tables that are already done (to prevent 
//                      looping) (should not be given on initial call)
//  Returns:
//      True if no validation errors
//
VdfTable.prototype.validate = function(bValidateServer, aDone){
    var sField, iField, iTable, bResult = true;
    
    if(this.oVdfForm.oVdfValidator){
        if(typeof(bValidateServer) == "undefined"){
            var bValidateServer = true;
        }
        if(typeof(aDone) == "undefined"){
            var aDone = new Object();
        }
        aDone[this.sName] = true;
        
        //  Validate fields
        for(sField in this.aFields){
            for(iField in this.aFields[sField]){
                bResult = (this.oVdfForm.oVdfValidator.validateField(this.aFields[sField][iField], bValidateServer) && bResult);
            }
        }
        
        //  Validate parents (if needed)
        for(iTable = 0; iTable < this.aParents.length; iTable++){
            if(!aDone[this.aParents[iTable]]){
                if(this.oVdfForm.oVdfInfo.getTableProperty(this.sName, "bValidate_Foreign_File_State") == "true"){
                    bResult = (this.oVdfForm.aTables[this.aParents[iTable]].validate(bValidateServer, aDone) && bResult);
                }
            }
        }
    }
    
    return bResult;
}

//
//  Creates an array of all fields.
//
//  Params:
//      bStatus         If true status fields are also added
//      bDatafields     If true the data fields are also added
//      bRecursive      If true the parent tables will also be called
//      bConstrained    if false constrained parents will be skipped
//      aDone           Array with tables that are already done (to prevent 
//                      looping)(should not be given on initial call)
//      aResult         Array to add the fields to (should not be given on 
//                      initial call)
//  Returns:
//      Array with all requested VdfField objects.
//
VdfTable.prototype.getFields = function(bStatusFields, bDataFields, bRecursive, bConstrained, aDone, aResult){
    var sField, iField, oField, iTable;
    
    if(typeof(aResult) == "undefined"){
        var aResult = new Object();
    }
    if(typeof(aDone) == "undefined"){
        var aDone = new Object();
    }
    aDone[this.sName] = true;
    
    
    
    //  If needed add status field
    if(bStatusFields){
        aResult[this.oStatusField.getName()] = this.oStatusField;
    }
    
    //  Add fields
    if(bDataFields){
        for(sField in this.aFields){
            //  Take the first field or the changed field
            oField = this.aFields[sField][0];
            for(iField in this.aFields[sField]){
                if(this.aFields[sField][iField].getChangedState()){
                    oField = this.afields[sField][iField];
                    break;
                }
            }
        
            aResult[oField.getName()] = oField;
        }
    }
    
    //  Call parents recursivly (if bConstrained false constrained tables will be skipped)
    if(bRecursive){
        for(iTable = 0; iTable < this.aParents.length; iTable++){
            if(!aDone[this.aParents[iTable]] && (bConstrained || this.aParents[iTable] != this.sConstrainedTo)){
                this.oVdfForm.aTables[this.aParents[iTable]].getFields((bStatusFields), (bDataFields), (bRecursive), (bConstrained), aDone, aResult);
            }
        }
    }
    
    return aResult;
}

//
//  Checks if the user has changed the data or in the parent files using the 
//  displaychangedstate.
//
//  Params:
//      bRecursive      If true the parent tables will also be called
//      bConstrained    If false constrained parents will be skipped
//      bStatus         If true status fields are also checked
//      aDone           Array with tables that are already done (to prevent 
//                      looping)(should not be given on initial call)
//  Returns:
//      True if the data is changed
//
VdfTable.prototype.isDataChanged = function(bRecursive, bConstrained, bStatus, aDone){
    var iTable, sField, iField, bResult = false;
    
    if(typeof(bStatus) == "undefined"){
        var bStatus = true;
    }
    if(typeof(aDone) == "undefined"){
        var aDone = new Object();
    }
    if(typeof(oVdfDataSet) == "undefined"){
        var oVdfDataSet = null;
    }
    aDone[this.sName] = true;
    
    //  Compare status field
    if(bStatus){
        bResult = (bResult || this.oStatusField.getDisplayChangedState());
    }

    
    //  Set fields
    for(sField in this.aFields){
        for(iField in this.aFields[sField]){
            bResult = (bResult || this.aFields[sField][iField].getDisplayChangedState());
        }
    }
    
      //  Call parents recursivly (if bConstrained false constrained tables will be skipped)
    if(bRecursive){
        for(iTable = 0; iTable < this.aParents.length && !bResult; iTable++){
            if(!aDone[this.aParents[iTable]] && (bConstrained || this.aParents[iTable] != this.sConstrainedTo)){
                bResult = (bResult || this.oVdfForm.aTables[this.aParents[iTable]].isDataChanged(bRecursive, bConstrained, bStatus, aDone));
            }
        }
    }
    
    return bResult;
}

//
//  Sets the values of the fields to the values in the given dataset.
//  
//  Params:
//      oVdfDataSet     Dataset to compare the current data to
//      bRecursive      If true the parent tables will also be called
//      bConstrained    If false constrained parents will be skipped
//      bStatus         If true status fields are also checked
//      bResetStatus    If true the changedstate of the status fields will be resetted to
//      bCallOnSetData  If true the global method OnSetData will be called 
//                      (default: true)
//      aDone           Array with tables that are already done (to prevent 
//                      looping)(should not be given on initial call)
//
VdfTable.prototype.setValues = function(oVdfDataSet, bRecursive, bConstrained, bStatus, bResetStatus, bCallOnSetData, aDone){
    var iTable, sField, iField;
    
    if(typeof(bStatus) == "undefined"){
        var bStatus = true;
    }
    if(typeof(bResetStatus) == "undefined"){
        var bResetStatus = true;
    }
    if(typeof(aDone) == "undefined"){
        var aDone = new Object();
    }
    if(typeof(bCallOnSetData) == "undefined"){
        var bCallOnSetData = true;
    }
    aDone[this.sName] = true;
    
    //  Set status fields
    if (oVdfDataSet) this.oStatusField.setDataSetValue(oVdfDataSet, bResetStatus);
    
    //  Set fields
    for(sField in this.aFields){
        for(iField in this.aFields[sField]){
            this.aFields[sField][iField].setDataSetValue(oVdfDataSet, true);
        }
    }
       
    //  Call the global OnSetData method
    if(bCallOnSetData){
        if(typeof(OnSetData) == "function"){
            OnSetData(this.oVdfForm, this.sName);
        }
    }
    
    //  Call parents recursivly (if bConstrained false constrained tables will be skipped)
    if(bRecursive){
        for(iTable = 0; iTable < this.aParents.length; iTable++){
            if(!aDone[this.aParents[iTable]] && (bConstrained || this.aParents[iTable] != this.sConstrainedTo)){
                if (oVdfDataSet) this.oVdfForm.aTables[this.aParents[iTable]].setValues(oVdfDataSet, bRecursive, bConstrained, bStatus, bResetStatus, bCallOnSetData, aDone);
            }
        }
        
        if(this.sConstrainedFrom != null && !aDone[this.sConstrainedFrom]){
            if (oVdfDataSet) this.oVdfForm.aTables[this.sConstrainedFrom].setValues(oVdfDataSet, bRecursive, bConstrained, bStatus, bResetStatus, bCallOnSetData, aDone);
        }
    }
}


//
//  Checks if the table contains a record (by checking if the status field is 
//  filled).
//
//  Returns:
//      True if a record is available
//
VdfTable.prototype.hasRecord = function(){
    return (this.oStatusField.getValue() != "");
}

//
//  Checks if there is data filled in in the table fields(can also be found 
//  child records).
//
//  Returns:
//      True if the table contains data
//
//  PRIVATE
VdfTable.prototype.hasData = function(){
    var bResult = (this.hasRecord() || this.isDataChanged(false));
    
    for(iTable = 0; iTable < this.aParents.length && !bResult; iTable++){
        bResult = (bResult || this.oVdfForm.aTables[this.aParents[iTable]].hasRecord());
    }
    
    return bResult;
}

//
//  Checks if the table is (direct or indirect parent of this table)
//
//  Params:
//      sName   Name of the searched table
//      aDone           Array with tables that are already done (to prevent 
//                      looping)(should not be given on initial call)
//      
VdfTable.prototype.isTableParent = function(sName, aDone){
    var iTable, bResult = false;
    
    //  Create done array if needed (used to prevent recursive looping)
    if(typeof(aDone) == "undefined"){
        var aDone = new Object();
    }
    aDone[this.sName] = true;
    
    for(iTable = 0; iTable < this.aParents.length && !bResult; iTable++){
        if(this.aParents[iTable] == sName){
            bResult = true;
        }else{
            if(!aDone[this.aParents[iTable]]){
                bResult = this.oVdfForm.aTables[this.aParents[iTable]].isTableParent(sName, aDone);
            }
        }
    }
    
    return bResult;
}

//
//  Checks of the table is a direct parent.
//
//  Params:
//      sName   Name of the searched table
//  Returns:
//      True if the table is a direct parent
//
VdfTable.prototype.isTableDirectParent = function(sName){
    var bResult = false;
    
    for(iTable = 0; iTable < this.aParents.length && !bResult; iTable++){
        bResult = (this.aParents[iTable] == sName);
    }
    
    return bResult;
}

//
//  Checks if the table is an (indirect) constrained parent.
//
//  Params:
//      sName   Name of the searched table
//  Returns:
//      True if the table is an (indirect) constrained parent.
//
VdfTable.prototype.isTableConstrainedParent = function(sName){
    var bResult = false;
    
    if(this.sConstrainedTo != null && this.sConstrainedTo != ""){
        bResult = (sName == this.sConstrainedTo || this.oVdfForm.aTables[this.sConstrainedTo].isTableParent(sName));
    }
    
    return bResult;
}



//
//  Checks if the table is an direct constrained parent.
//
//  Params:
//      sName   Name of the searched table
//  Returns:
//      True if the table is the constrained table
//
VdfTable.prototype.isTableDirectConstrainedParent = function(sName){
    return (sName == this.sConstrainedTo);
}

//
//  Checks wether a table is a foreign table according to the given maintable 
//  by checking if the table is the mainfile or the mainfile is a parent of the 
//  table.
//
//  Params:
//      sMainTable   The maintable
//  
VdfTable.prototype.isForeign = function(sMainTable){
    
    if(this.sName == sMainTable){
        return false;
    }
    
    if(this.isTableParent(sMainTable)){
        return false;
    }

    return true;
}