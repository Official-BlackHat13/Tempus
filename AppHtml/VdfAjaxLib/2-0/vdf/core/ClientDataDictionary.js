/*
Name:
    vdf.core.ClientDataDictionary
Type:
    Prototype
Revisions:
    2008/02/01  Rebuild into the 2.0 structure. The VdfTable is now renamed to 
    ClientDataDictionary and acts like one. It now had a local buffer, DEO 
    references and contains the find/save/clear/delete functionallity. 
    (HW, DAE)
    2006/10/05  Created the VdfTable object that maintains the DDO structure 
    specific functionallity. (HW, DAE)
*/

/*
Constructor which takes the basic information.

@param  sName   Name of the table / DD.
@param  oForm   Reference to the vdf.core.Form object to which the DD belongs.
*/
vdf.core.ClientDataDictionary = function ClientDataDictionary(sName, oForm){
    /*
    Reference to the vdf.core.Form object to which it belongs.
    */
    this.oForm = oForm;
    /*
    Name of the table that is managed by this DD.
    */
    this.sName = sName;
    
    //  REFERENCES
    /*
    Reference to the status DEO (the rowid field).
    */
    this.oStatus = null;
    /*
    Array with references to all DEO's that are updated by this DD.
    */
    this.aDEO = [];
    /*
    Array with references to all server DD's.
    */
    this.aServers = [];
    /*
    Array with references to all child DD's.
    */
    this.aChildren = [];
    /*
    Reference to the DD on which DD is constrained to (Constrain_File in VDF). 
    */
    this.oConstrainedTo = null;
    /*
    Array with references to all DDs constrained to this DD.
    */
    this.aConstrainedFrom = [];
    
        
    //  EVENTS
    /*
    Fired before a find is executed on this DD. If the event is stopped the find 
    action will be cancelled as wel.
    
    @prop   sMode       The find mode that will be used.
    @prop   oField      Reference to the field on which the find is performed.
    @prop   oInitiator  Reference to the object that initiated the find action.
    */
    this.onBeforeFind = new vdf.events.JSHandler();
    /*
    Fired after a find action. 
            
    @prop   bError      True if any errors occurred during the find.
    @prop   iErrorNr    Error number of the first error that occurred.
    @prop   bFound      True if a record is found.
    @prop   sMode       The find mode used for the find.
    @prop   oField      Reference to the field on which the find was performed.
    @prop   tResponseSet    Data object (struct) with response data 
            (see vdf.dataStructs.TResponseSet).
    */
    this.onAfterFind = new vdf.events.JSHandler();
    /*
    Fired before a find by rowid is executed on this DD. If the event is stopped 
    the find action will be cancelled as wel.
    
    @prop   sRowId      String with the serialized rowid.
    @prop   oInitiator  Reference to the object that initiated the find action.
    */
    this.onBeforeFindByRowId = new vdf.events.JSHandler();
    /*
    Fired after a find by rowid action. 

    @prop   bError      True if any errors occurred during the find.
    @prop   iErrorNr    Error number of the first error that occurred.
    @prop   bFound      True if a record is found.
    @prop   sRowId      String with the serialized rowid.    
    @prop   tResponseSet    Data object (struct) with response data 
            (see vdf.dataStructs.TResponseSet).
    */
    this.onAfterFindByRowId = new vdf.events.JSHandler();
    /*
    Fired before a clear is executed on this DD. If the event is stopped the 
    clear action will be cancelled as wel.
    
    @prop   oInitiator  Reference to the object that initiated the action.
    */
    this.onBeforeClear = new vdf.events.JSHandler();
    /*
    Fired after a clear action. 

    @prop   bError      True if any errors occurred during the find.
    @prop   iErrorNr    Error number of the first error that occurred.
    @prop   tResponseSet    Data object (struct) with response data 
            (see vdf.dataStructs.TResponseSet).
    */
    this.onAfterClear = new vdf.events.JSHandler();
    /*
    Fired before a save is executed on this DD. If the event is stopped the 
    save action will be cancelled as wel.
    
    @prop   oInitiator  Reference to the object that initiated the action.
    */
    this.onBeforeSave = new vdf.events.JSHandler();
    /*
    Fired after a save action. 

    @prop   bError      True if any errors occurred during the find.
    @prop   iErrorNr    Error number of the first error that occurred.
    @prop   tResponseSet    Data object (struct) with response data 
            (see vdf.dataStructs.TResponseSet).
    */
    this.onAfterSave = new vdf.events.JSHandler();
    /*
    Fired before a delete is executed on this DD. If the event is stopped the 
    delete action will be cancelled as wel.
    
    @prop   oInitiator  Reference to the object that initiated the action.
    */
    this.onBeforeDelete = new vdf.events.JSHandler();
    /*
    Fired after a delete action. 

    @prop   bError      True if any errors occurred during the find.
    @prop   iErrorNr    Error number of the first error that occurred.
    @prop   tResponseSet    Data object (struct) with response data 
            (see vdf.dataStructs.TResponseSet).
    */
    this.onAfterDelete = new vdf.events.JSHandler();
    /*
    Fired if the DD has loaded a record (or is cleared).
    */
    this.onRefresh = new vdf.events.JSHandler();
    /*
    Fired before a save to validate the fields. If the event is stopped the save 
    is canceled.
    */
    this.onValidate = new vdf.events.JSHandler();

    // @privates
    
    //  LOCKS
    this.iLocked = 0;
    this.bLockedExclusive = false;
    
    //  DATA
    this.tStatus = null;
    this.oBuffer = {};
    
    this.bIsDD = true;
};
/*
The client side representation of the Data Dictionary within data entry forms  
(vdf.core.Form). During the initialization the form engine rebuilds the complete 
DDO structure of the web object to which it belongs on the client. This 
ClientDataDictionary knows its server DDs, its child DDs, the constrains and has 
references to all the Data Entry Objects (vdf.core.DEO). It has an buffer on the 
client that contains all fields of the table that are used by the Data Entry 
Objects.

The ClientDataDictionary contains the actual logic for performing a 
find/clear/delete/save. It determines which other DDs in the structure should be 
involved and contains the logic for making the AJAX call and updating the DEOs 
with the new values.

A reference to the ClientDataDictionary object for a specific table is available 
by the getDD function on the Form. Methods and events of this object can be used 
add custom functionality to a data entry view. The example below shows how an 
event can be handled and how a find by rowid can be initialized.
@code
//
//  Called each time a new customer record is loaded in the buffer.
//
//  Params:
//      oEvent  Event object.
//
function onNewCustomer(oEvent){
    var oDD = oEvent.oSource;
    
    if(oDD.getFieldValue("customer", "active") == "Y"){
        document.getElementById("activeimage").style.display = "";
    }else{
        document.getElementById("activeimage").style.display = "none";
    }
}

//
//  Initializes my form!
//
function myFormInitializer(oForm){
    var oDD = oForm.getDD("customer");
    
    //  Attach event listener
    oDD.onRefresh.addListener(onNewCustomer);
    
    //  Perform a find by rowid
    oDD.doFindByRowId(sCustomerRowId);
}
@code
*/
vdf.definePrototype("vdf.core.ClientDataDictionary", {

/*
Initializes the DDO structure by finding references to servers and constrained 
tables. It does this using the given meta data object.

@param  tMetaDD     Data object (struct) with meta data (see: vdf.dataStructs.TAjaxMetaDD).
@private
*/
buildStructure : function(tMetaDD){
    var iServer;
    
    //  Find servers
    for(iServer = 0; iServer < tMetaDD.aServers.length; iServer++){
        this.aServers.push(this.oForm.oDDs[tMetaDD.aServers[iServer]]);
        this.oForm.oDDs[tMetaDD.aServers[iServer]].aChildren.push(this);
    }
    
    //  Find constrained
    if(tMetaDD.sConstrainFile !== ""){
        this.oConstrainedTo = this.oForm.oDDs[tMetaDD.sConstrainFile];
        this.oConstrainedTo.aConstrainedFrom.push(this);
    }
    
    //  Create rowid buffer
    this.tStatus = new vdf.dataStructs.TAjaxField();
    this.tStatus.sBinding = this.sName + ".rowid";
    this.tStatus.sType = "R";
    
},

// - - - - - - - - - - Data Entry Object Communication - - - - - - - - - - 

/*
Called by DEOs if their value has been edited to synchronize the buffer.

@param  sTable  Name of the table.
@param  sField  Name of the field.
@param  sValue  The new value.
@param  bNoPut  If true the changedstate won't be updated.
*/
setFieldValue : function(sTable, sField, sValue, bNoPut){
    var iDEO, tField;
    
    //  If no bNoPut is geven we asume it is false
    if(typeof(bNoPut) === "undefined"){
        bNoPut = false;
    }
    
    //  Forward to the correct DD
    if(sTable != this.sName){
        this.oForm.oDDs[sTable].setFieldValue(sTable, sField, sValue, bNoPut);
    }else{
        if(sField == "rowid"){
            tField = this.tStatus;
        }else{
            tField = this.oBuffer[sTable + "." + sField];
        }
        
        if(tField !== null){
            //  Only update if value is really different
            if(tField.sValue != sValue){
            
                //  Update buffer
                tField.sValue = sValue;
                if(!bNoPut){
                    tField.bChanged = true;
                }
                
                //  Notify DEO
                for(iDEO = 0; iDEO < this.aDEO.length; iDEO++){
                    this.aDEO[iDEO].fieldValueChanged(sTable, sField, sValue);
                }
            }
        }else{
            throw new vdf.errors.Error(0, "Field not found!", [ sTable, sField ]);
        }
    }
},

/*
Determines the changed state for a field.

@param  sTable  Name of the table.
@param  sField  Name of the field.
@return True if the value is modified and will be stored during a save.
*/
getFieldChangedState : function(sTable, sField){
    if(sTable != this.sName){
        return this.oForm.oDDs[sTable].getFieldChangedState(sTable, sField);
    }else{
        if(sField != "rowid"){
            return this.oBuffer[sTable + "." + sField].bChanged;
        }else{
            return false;
        }
    }
},

/*
Used by DEOs to get their current value.

@param  sTable  Name of the table.
@param  sField  Name of the field.
@return Buffer value for the field.
*/
getFieldValue : function(sTable, sField){
    if(sTable != this.sName){
        return this.oForm.oDDs[sTable].getFieldValue(sTable, sField);
    }else{
        if(sField != "rowid"){
            return this.oBuffer[sTable + "." + sField].sValue;
        }else{
            return this.tStatus.sValue;
        }
    }
},

/*
Used by DEOs to get their current value.

@param  sExpression     The expression.
@return Buffer value for the expression.
@private
*/
getExpressionValue : function(sExpression){
    return this.oBuffer[sExpression].sValue;
},

/*
Adds a Data Entry Object to the administration so it will be updated if a new 
record / value is loaded. If the field belongs to another table the call will be 
forwarded to that DD.

@param  oDEO    Reference to a data entry object (see: vdf.core.DEO).
*/
registerDEO : function(oDEO){
    if(oDEO.isBound()){
        //  Forward register call to table DEO if bound to a specific table
        if(oDEO.sTable !== null && oDEO.sTable !== this.sName){
            this.oForm.oDDs[oDEO.sTable].registerDEO(oDEO);
        }else{
        
            //  Add to aDEO if it isn't already in there
            if(!this.deoExists(oDEO)){
                this.aDEO.push(oDEO);
            }
            
            if(oDEO.sField === "rowid"){
                //  Rowid fields are referenced separately as this.oStatus
                if(oDEO.sTable === this.sName){
                    this.oStatus = oDEO;
//                alert(this.sName + " DEO Status value = '" + oDEO.getValue() + "'");
                    this.tStatus.sValue = oDEO.getValue();  //  Instead of using update() we do this manually to prevent a findByRowId from happening
                }
            }else if(oDEO.sField !== null){
                //  Create fields in buffer if needed
                if(oDEO.sTable === this.sName && oDEO.sField !== null){
                    this.createBufferField(oDEO.sDataBinding, "D");
                }else if(oDEO.sExpression !== null){
                    this.createBufferField(oDEO.sDataBinding, "E");
                }
                
                //oDEO.update();
            }
        }
    }
},

/*
Checks the administration for a specific data entry object.

@param  oDEO    Reference to a data entry object.
@return True if a Data Entry Object is registered at this Data Dictionary.
@private
*/
deoExists : function(oDEO){
    var iDEO;
    
    for(iDEO = 0; iDEO < this.aDEO.length; iDEO++){
        if(this.aDEO[iDEO] == oDEO){
            return true;
        }   
    }
    
    return false;
},

/*


Creates field in the buffer.

@param  sBinding    Data binding of the field.
@param  sType       Type of the field ("D" = Database (field), 
        "E" = Expression).
@private
*/
createBufferField : function(sBinding, sType){
    var tField = new vdf.dataStructs.TAjaxField();
    
    tField.sBinding = sBinding;
    tField.sType = sType;
    
    this.oBuffer[sBinding] = tField;
},

// - - - - - - - - - - Create & Load Snapshots - - - - - - - - - - 

/*
Starts the visiting of all the DDs in the structure calling the worker function
with a set of known parameters.

@param  fWorker Reference to the worker function to call for each DD.
@private
*/
crawlDDS : function(fWorker){
    var aOrder, iCur, oCur;
    
    //  Determine order
    aOrder = this.determineCrawlOrder({}, false, false, false, false);
    
    //  Call worker for DDs
    for(iCur = 0; iCur < aOrder.length; iCur++){
        oCur = aOrder[iCur];
        
        fWorker.call(oCur.oDD, oCur.oDD, oCur.bConstrainedTo, oCur.bConstrainedFrom, oCur.bServer, oCur.bChild);
    }
},

/*
Recursive method that determines the order and the meta data for the DD 
crawling. The order keeps track of constrains so the status load finds are 
performed in the correct order.

2.Customer  3.SalesP  6.Vendor
       \       /        /
     1. OrderHea   5.Inventory
             c\     /
            4.OrderDtl


@param  oDone               Object in which visited DDs are marked.
@param  bConstrainedTo      True if we went over a constrained to relation.
@param  bConstrainedFrom    True if we went over a constrained from relation.
@param  bServer             True if we where going up in the tree.
@param  bChild              True if we where going down in the true.
@return Array with objects representing the order and meta data for the DD 
            crawling.
@private
*/
determineCrawlOrder : function(oDone, bConstrainedTo, bConstrainedFrom, bServer, bChild){
    var iCurrent, aResult = [];
    if(!oDone[this.sName]){
        
        
        //  Mark as done
        oDone[this.sName] = true;
        
        //  Move into DDs constrained to this DD
        for(iCurrent = 0; iCurrent < this.aConstrainedFrom.length; iCurrent++){
            aResult = aResult.concat(this.aConstrainedFrom[iCurrent].determineCrawlOrder(oDone, bConstrainedTo, (!bServer && !bChild && !bConstrainedTo), bServer, (!bServer)));
        }
        
        //  Move to childs
        for(iCurrent = 0; iCurrent < this.aChildren.length; iCurrent++){
            aResult = aResult.concat(this.aChildren[iCurrent].determineCrawlOrder(oDone, bConstrainedTo, bConstrainedFrom, bServer, (!bServer)));
        }
        
        
        //  First do constrained to DD where we are constrained to
        if(this.oConstrainedTo){
            aResult = this.oConstrainedTo.determineCrawlOrder(oDone, (bConstrainedTo || (!bChild && !bConstrainedFrom && !bServer)), bConstrainedFrom, (!bChild), bChild).concat(aResult);
        }
        
        //fWorker.call(this, this, bConstrainedTo, bConstrainedFrom, bServer, bChild);
        
        aResult.push({ 
            oDD : this, 
            bConstrainedTo : bConstrainedTo,
            bConstrainedFrom : bConstrainedFrom, 
            bServer : bServer, 
            bChild : bChild
        });
        
        //  Move to servers
        for(iCurrent = 0; iCurrent < this.aServers.length; iCurrent++){
            aResult = aResult.concat(this.aServers[iCurrent].determineCrawlOrder(oDone, bConstrainedTo, bConstrainedFrom, (!bChild), bChild));
        }       
       
    }
    
    return aResult;
},



/*
Generates an external (find) snapshot crawling through the DDs. The buffer 
structs are cloned so the external compent doesn't accidentally modify buffer 
values.

@param  bAddFields  If true the buffer fields are also added.
@return Data object (struct) with the buffer snapshot (see: vdf.dataStructs.TAjaxSnapShot).
@private
*/
generateExtSnapshot : function(bAddFields){
    var tResult = new vdf.dataStructs.TAjaxSnapShot();

    this.crawlDDS(function(oDD, bConstrainedTo, bConstrainedFrom, bServer, bChild){
        var sBuf, tDD;
        
        if((bChild && bConstrainedFrom) || !bChild){
            tDD = new vdf.dataStructs.TAjaxDD();
            tDD.sName = this.sName;        
            tDD.tStatus = vdf.sys.data.deepClone(this.tStatus);
            tDD.bLight = bConstrainedTo;

            //  Add buffer values
            if(bAddFields){
                for(sBuf in this.oBuffer){
                    if(this.oBuffer[sBuf].__isField){
                        tDD.aFields.push(vdf.sys.data.deepClone(this.oBuffer[sBuf]));
                    }
                }
            }
                    
            tResult.aDDs.push(tDD);
        }
    });
    
    return tResult;
},

/*
The external snapshot is a custom snapshot used by external objects like the 
vdf.core.List. This method loops through the DDO structure calling itself on 
other DDs to create an complete snapshot. Creating an external snapshot 
doesn't lock the DDO & DEO objects

@param  aDDs        Reference to the array to which the DD snapshots need to be 
            stored.
@param  bUpdate     If true the buffers are updated by the DEOs first.
@param  bMarkLight  If true DDs are marked as licht DDs. ConstrainedTo DDs are 
            always marked as light.
@param  bAddFields  If true the buffer fields are also added.
@param  bClone      If true the data isn't referenced but copied.
@param  oDone       Object in whichs we mark which DDs are entered to prevent 
            recursive loops.
@private
*/
createExtSnapshot : function(aDDs, bUpdate, bMarkLight, bAddFields, bClone, oDone){
    if(!oDone[this.sName]){
        var iCurrent;
        
        //  Mark as done
        oDone[this.sName] = true;
        
        //  First do constrained to DD where we are constrained to
        if(this.oConstrainedTo !== null){
            this.oConstrainedTo.createExtSnapshot(aDDs, bUpdate, true, bAddFields, bClone, oDone);
        }

        aDDs.push(this.createExtSnapshotDD(bUpdate, bMarkLight, bAddFields));
        
        //  Move to servers
        for(iCurrent = 0; iCurrent < this.aServers.length; iCurrent++){
            this.aServers[iCurrent].createExtSnapshot(aDDs, bUpdate, bMarkLight, bAddFields, bClone, oDone);
        }
        
        //  Move into DDs constrained to this DD
        for(iCurrent = 0; iCurrent < this.aConstrainedFrom.length; iCurrent++){
            this.aConstrainedFrom[iCurrent].createExtSnapshot(aDDs, bUpdate, bMarkLight, bAddFields, bClone, oDone);
        }
    }
},

/*
The external snapshot is a custom snapshot used by external objects like the 
vdf.core.List. This function returns a snapshot from this DD. Creating an 
external snapshot doesn't lock the DDO & DEO objects

@param  bUpdate     If true the buffers are updated by the DEOs first.
@param  bMarkLight  If true DDs are marked as licht DDs. ConstrainedTo DDs are 
            always marked as light.
@param  bAddFields  If true the buffer fields are also added.
@param  bClone      If true the data isn't referenced but copied.
@private
*/
createExtSnapshotDD : function(bUpdate, bMarkLight, bAddFields, bClone){
    var iDeo, sBuf, tResult = new vdf.dataStructs.TAjaxDD();
    
    //  Ask data entry objects to update the buffer
    if(bUpdate){
        for(iDeo = 0; iDeo < this.aDEO.length; iDeo++){
            this.aDEO[iDeo].update();
        }
    }
    
    tResult.sName = this.sName;        
    tResult.tStatus = (bClone ? vdf.sys.data.deepClone(this.tStatus) : this.tStatus);
    tResult.bLight = bMarkLight;
    
    //  Add buffer values
    if(bAddFields){
        for(sBuf in this.oBuffer){
            if(this.oBuffer[sBuf].__isField){
                tResult.aFields.push((bClone ? vdf.sys.data.deepClone(this.oBuffer[sBuf]) : this.oBuffer[sBuf]));
            }
        }
    }
    
    return tResult;
},

/*
Takes a snapshot of the buffer.

@return vdf.dataStructs.TAjaxDD data object representing the buffer state.
@private
*/
createSnapshot : function(){
    var sBuf, tResult = new vdf.dataStructs.TAjaxDD();
       
    tResult.sName = this.sName;        
        
    //  Add buffer values
    for(sBuf in this.oBuffer){
        if(this.oBuffer[sBuf].__isField){
            tResult.aFields.push(this.oBuffer[sBuf]);
        }
    }
    tResult.tStatus = this.tStatus;
    tResult.bLight = false;
    
    return tResult;
},

/*
Takes a lite snapshot (without field values and marked) of the buffer.

@return vdf.dataStructs.TAjaxDD data object representing the buffer state.
@private
*/
createLiteSnapshot : function(){
    var tResult = new vdf.dataStructs.TAjaxDD();
       
    tResult.sName = this.sName;        
        
    tResult.tStatus = this.tStatus;
    tResult.bLight = true;
    
    return tResult;
},

/*
Loads a snapshot in the buffer refreshing the DEO's if needed.

@param  oAction     Action object.
@param  tSnapshot   Data object (struct) to load the records from (see: 
            vdf.dataStructs.TAjaxSnapShot).
@param  bRefreshDEO If true the DEO's are called to refresh themself.
@private
*/
loadSnapshot : function(oAction, tSnapshot, bRefreshDEO){
    var iDD;
    
    for(iDD = 0; iDD < tSnapshot.aDDs.length; iDD++){
        if(!tSnapshot.aDDs[iDD].bLight){
            this.oForm.oDDs[tSnapshot.aDDs[iDD].sName].loadSnapshotDD(oAction, tSnapshot.aDDs[iDD]);
        }
    }
    
    if(bRefreshDEO || typeof(bRefreshDEO) === "undefined"){
        for(iDD = 0; iDD < tSnapshot.aDDs.length; iDD++){
            if(!tSnapshot.aDDs[iDD].bLight){
                this.oForm.oDDs[tSnapshot.aDDs[iDD].sName].loadSnapshotDEO(oAction);
            }
        }
    }
},

/*
Loads data from a snapshot into the buffer.

@param  oAction Action object.
@param  tDD     Data object (struct) to load the status from (see: 
            vdf.dataStructs.TAjaxDD).
@private
*/
loadSnapshotDD : function(oAction, tDD){
    var iField;
    
//    alert("RECEIVED: " + tDD.sName + " status '" + tDD.tStatus.sValue + "' " + (tDD.tStatus.sValue === null));
    if(!tDD.bLight){
        this.tStatus = tDD.tStatus;
        
        for(iField = 0; iField < tDD.aFields.length; iField++){
            this.oBuffer[tDD.aFields[iField].sBinding] = tDD.aFields[iField];
        }
    }
},

/*
Calls the DEO's to refresh themself.

@param  oAction Action object.
@private
*/
loadSnapshotDEO : function(oAction){
    var iDEO;

    for(iDEO = 0; iDEO < this.aDEO.length; iDEO++){
        this.aDEO[iDEO].refresh(oAction);
    }
    
    this.onRefresh.fire(this);
},

// - - - - - - - - - - Action Implementation - - - - - - - - - - 

/*
Performs the initial fill which means that the DDs & DEO's are synced and 
refreshed and optionally findByRowId's are performed.

@private
*/
initialFill : function(){
    var tRequestSet, aRequestSets, bDepending, tRow, oAction;
    
    //  Fire event
    if(this.oForm.onBeforeInitialFill.fire(this, {})){
        
        aRequestSets = [];
        bDepending = false;
        tRow = new vdf.dataStructs.TAjaxSnapShot();
        oAction = new vdf.core.Action("find", this.oForm, this, this, false);
        
        //  Loop through DDs to lock and optionally generate requestsets
        this.crawlDDS(function(oDD, bConstrainedTo, bConstrainedFrom, bServer, bChild){
            var iDeo;
            
            //  Lock DD
            oAction.lock(this);
            
            //  Visit DEO for update and lock
            for(iDeo = 0; iDeo < this.aDEO.length; iDeo++){
                vdf.errors.clearByField(this.aDEO[iDeo]);
                this.aDEO[iDeo].update();
                oAction.lock(this.aDEO[iDeo]);
            }
            
            //  Determine if we need to do a findbyrowid for this table
            if(this.tStatus.sValue !== ""){
                bDepending = bDepending || this.hasDependingDEO([], {});
            
                //  Generate request objects & collect fields
                tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
                tRequestSet.sName = "DDInitialFill";
                tRequestSet.sRequestType = "findByRowId";
                tRequestSet.iMaxRows = 1;
                tRequestSet.sTable = this.sName;
                tRequestSet.sColumn = "rowid";
                tRequestSet.sFindValue = this.tStatus.sValue;
                tRequestSet.bReturnCurrent = false;
                tRequestSet.bLoadStatus = (aRequestSets.length === 0);
                
                aRequestSets.push(tRequestSet);
                oAction.addRequestSet(tRequestSet);
            }
            
            //  Add to snapshot
            tRow.aDDs.push(this.createSnapshot());
        });
        
        //  If there are depending DEO's we need to send the call
        if(bDepending){
            //  Add snapshot to the first and the last requestset
            aRequestSets[0].aRows.push(tRow);
            
            if(aRequestSets.length > 1){
                aRequestSets[aRequestSets.length - 1].aRows.push(tRow);
            }
            
            //  Send the request
            oAction.onResponse.addListener(this.handleInitialFill, this);
            oAction.send();
        }else{
            //  Refresh the DEO's manually
            this.crawlDDS(function(oDD, bConstrainedTo, bConstrainedFrom, bServer, bChild){
                var iDeo;
             
                //  Visit DEO for update and lock
                for(iDeo = 0; iDeo < this.aDEO.length; iDeo++){
                    this.aDEO[iDeo].refresh();
                }
            });
            
            //  Fire event
            this.oForm.onAfterInitialFill.fire(this.oForm, { 
                bAccessedServer : false,
                bError : false, 
                iErrorNr : 0, 
                aResponseSets : null 
            });
            
            oAction.unlock();
        }
    }
},

/*
Handles the initial fill call by loading the final (last) result snapshot.

@param  oEvent  The event object.
@private
*/
handleInitialFill : function(oEvent){
    var tResponseSet, oEventInfo; 
    
    //  Fetch final responseset
    tResponseSet = (oEvent.tResponseData ? oEvent.tResponseData.aDataSets[oEvent.tResponseData.aDataSets.length - 1] : null);
    
    oEventInfo = { 
        bAccessedServer : true,
        bError : false, 
        iErrorNr : 0, 
        aResponseSets : (oEvent.tResponseData ? oEvent.tResponseData.aDataSets : null) 
    };
    
    //  If no errors occurred load the snapshot
    if(!oEvent.bError && tResponseSet.aRows.length > 0){
        this.loadSnapshot(oEvent.oSource, tResponseSet.aRows[0]);
    }else{
        if(oEvent.bError){
            oEventInfo.bError = true;
            oEventInfo.iErrorNr = oEvent.iErrorNr;
        }
            
        //  Refresh the DEO's manually
        this.crawlDDS(function(oDD, bConstrainedTo, bConstrainedFrom, bServer, bChild){
            var iDeo;
         
            //  Visit DEO for update and lock
            for(iDeo = 0; iDeo < this.aDEO.length; iDeo++){
                this.aDEO[iDeo].refresh();
            }
        });
    }
    
    this.oForm.onAfterInitialFill.fire(this.oForm, oEventInfo);
},

/*
Performs a find on the given field using the given mode. Note that this function 
works asynchronously!

@param  sMode   ("LT", "LE", "EQ", "GE", "GT")
@param  oField  Reference to the field object on which the find should be 
            performed.
@param  oAction (optional) Action object.
*/
doFind : function(sMode, oField, oAction){
    var tRequestSet, tRow;

    if(oField.sTable !== null && oField.sField !== null){
        
        //  Forward find to the correct DD
        if(oField.sTable !== this.sName){
            this.oForm.oDDs[oField.sTable].doFind(sMode, oField, oAction);
        }else{
            //  Check if the field has an index
            if(parseInt(oField.getMetaProperty("iIndex"), 10) > 0){
                if(this.iLocked <= 0 && !this.bLockedExclusive){
                    if(this.onBeforeFind.fire(this, {sMode : sMode, oField : oField, oInitiator : (oAction ? oAction.oInitiator : this)})){
                        if(typeof(oAction) !== "object"){
                            oAction = new vdf.core.Action("find", this.oForm, this, this, false);
                        }else{
                            oAction.sMode = "find";
                            oAction.oMainDD = this;
                        }
                        //  Generate request objects & collect fields
                        tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
                        tRequestSet.sName = "DDFind";
                        tRequestSet.sRequestType = "findByField";
                        tRequestSet.iMaxRows = 1;
                        tRequestSet.sTable = oField.sTable;
                        tRequestSet.sColumn = oField.sField;
                        tRequestSet.sFindMode = sMode;
                        tRequestSet.bReturnCurrent = false;
                    
                        tRow = new vdf.dataStructs.TAjaxSnapShot();
                        tRequestSet.aRows.push(tRow);
                    
                        
                        this.crawlDDS(function(oDD, bConstrainedTo, bConstrainedFrom, bServer, bChild){
                            var iDeo;
                            
                            if((bChild && bConstrainedFrom) || !bChild){
                                if(bConstrainedTo){
                                    //  Visit DEO for update
                                    for(iDeo = 0; iDeo < this.aDEO.length; iDeo++){
                                        this.aDEO[iDeo].update();
                                    }
                                    
                                    //  Create lite snapshot
                                    tRow.aDDs.push(this.createLiteSnapshot());
                                }else{
                                    //  Lock DD
                                    oAction.lock(this);
                                    
                                    //  Visit DEO for update and lock
                                    for(iDeo = 0; iDeo < this.aDEO.length; iDeo++){
                                        vdf.errors.clearByField(this.aDEO[iDeo]);
                                        this.aDEO[iDeo].update();
                                        oAction.lock(this.aDEO[iDeo]);
                                    }
                                    
                                    //  Create snapshot
                                    tRow.aDDs.push(this.createSnapshot());
                                }
                            }
                        });
                    
                        oAction.addRequestSet(tRequestSet);
                        oAction.__oField = oField;
                        oAction.__sMode = sMode;
                        
                        //  Send request
                        oAction.onResponse.addListener(this.handleFind, this);
                        oAction.send();

                    }
                }
            }else{
                vdf.errors.handle(new vdf.errors.FieldError(151, "Field not indexed", oField, []));
            }
        }
    }
},

/*
Handles the find response by loadin the snapshot into the buffer. 

@param  oEvent  Event object.
@private
*/
handleFind : function(oEvent){
    var oAction = oEvent.oSource, tResponseSet, oEventInfo; 

    tResponseSet = (oEvent.tResponseData ? oEvent.tResponseData.aDataSets[0] : null);
    
    oEventInfo = { 
        bError : false, 
        iErrorNr : 0, 
        bFound : false, 
        sMode : oAction.__sMode, 
        oField : oAction.__oField, 
        tResponseSet : tResponseSet 
    };
    
    if(!oEvent.bError){
        if(tResponseSet.bFound && tResponseSet.aRows.length > 0){
            oEventInfo.bFound = true;
            this.loadSnapshot(oEvent.oSource, tResponseSet.aRows[0]);
        }
    }else{
        oEventInfo.bError = true;
        oEventInfo.iErrorNr = oEvent.iErrorNr;
    }
    
    this.onAfterFind.fire(this, oEventInfo);
},

/*
Performs a findByRowId using the given rowid. Note that this function 
works asynchronously!

@param  sRowId  String with a serialized rowid.
@param  oAction (optional) Action object.
*/
doFindByRowId : function(sRowId, oAction){
    var tRequestSet, tRow;

    if(this.iLocked <= 0 && !this.bLockedExclusive){
        if(this.onBeforeFindByRowId.fire(this, {sRowId : sRowId, oInitiator : (oAction ? oAction.oInitiator : this)})){
            if(typeof(oAction) !== "object"){
                oAction = new vdf.core.Action("find", this.oForm, this, this, false);
            }else{
                oAction.sMode = "find";
                oAction.oMainDD = this;
            }
            
            //  Generate request objects & collect fields
            tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
            tRequestSet.sName = "DDFindByRowId";
            tRequestSet.sRequestType = "findByRowId";
            tRequestSet.iMaxRows = 1;
            tRequestSet.sTable = this.sName;
            tRequestSet.sColumn = "rowid";
            tRequestSet.sFindValue = sRowId;
            tRequestSet.bReturnCurrent = false;
            
            //  Create snapshot
            tRow = new vdf.dataStructs.TAjaxSnapShot();
            tRequestSet.aRows.push(tRow);
            
            this.crawlDDS(function(oDD, bConstrainedTo, bConstrainedFrom, bServer, bChild){
                var iDeo;
                
                if((bChild && bConstrainedFrom) || !bChild){
                    if(bConstrainedTo){
                        //  Visit DEO for update
                        for(iDeo = 0; iDeo < this.aDEO.length; iDeo++){
                            this.aDEO[iDeo].update();
                        }
                        
                        //  Create lite snapshot
                        tRow.aDDs.push(this.createLiteSnapshot());
                    }else{
                        //  Lock DD
                        oAction.lock(this);
                        
                        //  Visit DEO for update and lock
                        for(iDeo = 0; iDeo < this.aDEO.length; iDeo++){
                            vdf.errors.clearByField(this.aDEO[iDeo]);
                            this.aDEO[iDeo].update();
                            oAction.lock(this.aDEO[iDeo]);
                        }
                        
                        //  Create snapshot
                        tRow.aDDs.push(this.createSnapshot());
                    }
                }
            });
            
            oAction.addRequestSet(tRequestSet);
            oAction.__sRowId = sRowId;
            
            //  Send request
            oAction.onResponse.addListener(this.handleFindByRowId, this);
            oAction.send();
        }
    }
},

/*
Handles the findByRowId response by loading the snapshot into the buffer. 

@param  oEvent  Event object.
@private
*/
handleFindByRowId : function(oEvent){
    var oAction = oEvent.oSource, tResponseSet, oEventInfo; 

    tResponseSet = (oEvent.tResponseData ? oEvent.tResponseData.aDataSets[0] : null);
    
    oEventInfo = { 
        bError : false, 
        iErrorNr : 0, 
        bFound : false, 
        sRowId : oAction.__sRowId,
        tResponseSet : tResponseSet 
    };
    
    if(!oEvent.bError){
        if(tResponseSet.bFound && tResponseSet.aRows.length > 0){
            oEventInfo.bFound = true;
            this.loadSnapshot(oEvent.oSource, tResponseSet.aRows[0]);
        }
    }else{
        oEventInfo.bError = true;
        oEventInfo.iErrorNr = oEvent.iErrorNr;
    }
    
    this.onAfterFindByRowId.fire(this, oEventInfo);
},

/*
Sends a request to delete the record that is currently in de buffer. Note that 
this function works asynchronously!

@param  oAction (optional) Action object.
*/
doDelete : function(oAction){
    var tRequestSet, tRow;
    
    //  TODO:   Add a "has record" check here
    if(this.iLocked <= 0 && !this.bLockedExclusive){
        if(this.onBeforeDelete.fire(this, {oInitiator : (oAction ? oAction.oInitiator : this)})){
            if(typeof(oAction) !== "object"){
                oAction = new vdf.core.Action("delete", this.oForm, this, this, true);
            }else{
                oAction.sMode = "delete";
                oAction.oMainDD = this;
            }
            
            //  Generate request objects & collect fields
            tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
            tRequestSet.sName = "DDDelete";
            tRequestSet.sRequestType = "delete";
            tRequestSet.sTable = this.sName;
            tRequestSet.iMaxRows = 1;
            tRequestSet.bReturnCurrent = false;
            
            tRow = new vdf.dataStructs.TAjaxSnapShot();
            tRequestSet.aRows.push(tRow);
            
            this.crawlDDS(function(oDD, bConstrainedTo, bConstrainedFrom, bServer, bChild){
                var iDeo;

                //  Lock DD
                oAction.lock(this);
                
                //  Visit DEO for update and lock
                for(iDeo = 0; iDeo < this.aDEO.length; iDeo++){
                    vdf.errors.clearByField(this.aDEO[iDeo]);
                    this.aDEO[iDeo].update();
                    oAction.lock(this.aDEO[iDeo]);
                }
                
                //  Create snapshot
                tRow.aDDs.push(this.createSnapshot());
            });
            
            oAction.addRequestSet(tRequestSet);

            //  Send request
            oAction.onResponse.addListener(this.handleDelete, this);
            oAction.send();
        }
    }
},

/*
Handles the delete response by loading the snapshot into the buffer. Note that 
this function works asynchronously!

@param  oEvent  Event object.
@private
*/
handleDelete : function(oEvent){
    var tResponseSet, oEventInfo; 

    tResponseSet = (oEvent.tResponseData ? oEvent.tResponseData.aDataSets[0] : null);
    
    oEventInfo = { 
        bError : false, 
        iErrorNr : 0, 
        tResponseSet : tResponseSet 
    };
    
    if(!oEvent.bError){
        if(tResponseSet.aRows.length > 0){
            this.loadSnapshot(oEvent.oSource, tResponseSet.aRows[0]);
        }
    }else{
        oEventInfo.bError = true;
        oEventInfo.iErrorNr = oEvent.iErrorNr;
    }
    
    this.onAfterDelete.fire(this, oEventInfo);
},

/*
Sends a save request for the record currently in the buffer. Note that this 
function works asynchronously!

@param  oAction (optional) Action object.
*/
doSave : function(oAction){
    var tRequestSet, tRow, iError;

    //  Lock
    if(this.iLocked <= 0 && !this.bLockedExclusive){
    
        //  Developer event
        if(this.onBeforeSave.fire(this, { oInitiator : (oAction ? oAction.oInitiator : this) })){
            
            //  Clientside validation
            iError = this.validate();
            if(iError === 0){
                if(typeof(oAction) !== "object"){
                    oAction = new vdf.core.Action("save", this.oForm, this, this, true);
                }else{
                    oAction.sMode = "save";
                    oAction.oMainDD = this;
                }
                
                //  Generate request objects & collect fields
                tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
                tRequestSet.sName = "DDSave";
                tRequestSet.sRequestType = "save";
                tRequestSet.sTable = this.sName;
                tRequestSet.iMaxRows = 1;
                tRequestSet.bReturnCurrent = false;
                
                tRow = new vdf.dataStructs.TAjaxSnapShot();
                tRequestSet.aRows.push(tRow);
                
                this.crawlDDS(function(oDD, bConstrainedTo, bConstrainedFrom, bServer, bChild){
                    var iDeo;
                    
                    if(!bChild){
                        //  Lock DD
                        oAction.lock(this);
                        
                        //  Visit DEO for update and lock
                        for(iDeo = 0; iDeo < this.aDEO.length; iDeo++){
                            vdf.errors.clearByField(this.aDEO[iDeo]);
                            this.aDEO[iDeo].update();
                            oAction.lock(this.aDEO[iDeo]);
                        }
                        
                        //  Create snapshot
                        tRow.aDDs.push(this.createSnapshot());
                    }
                });
                
                
                oAction.addRequestSet(tRequestSet);

                //  Send request
                oAction.onResponse.addListener(this.handleSave, this);
                oAction.send();
            }else{
                this.onAfterSave.fire(this, { 
                    bError : true, 
                    iErrorNr : iError, 
                    tResponseSet : null 
                });
            }
        }
    }
},

/*
Handles the save response by loading the snapshot into the buffer.

@param  oEvent  Event object.
@private
*/
handleSave : function(oEvent){
    var tResponseSet, oEventInfo; 

    tResponseSet = (oEvent.tResponseData ? oEvent.tResponseData.aDataSets[0] : null);
    
    oEventInfo = { 
        bError : false, 
        iErrorNr : 0, 
        tResponseSet : tResponseSet 
    };
    
    if(!oEvent.bError){
        if(tResponseSet.aRows.length > 0){
            this.loadSnapshot(oEvent.oSource, tResponseSet.aRows[0]);
        }
    }else{
        oEventInfo.bError = true;
        oEventInfo.iErrorNr = oEvent.iErrorNr;
    }
    
    this.onAfterSave.fire(this, oEventInfo);
},

/*
Sends a clear request to get the default values into the buffer. Note that this 
function works asynchronously!

@param  oAction (optional) Action object.
*/
doClear : function(oAction){
    var tRequestSet, tRow;

    if(this.iLocked <= 0 && !this.bLockedExclusive){
        if(this.onBeforeClear.fire(this, { oInitiator : (oAction ? oAction.oInitiator : this) })){
            if(typeof(oAction) !== "object"){
                oAction = new vdf.core.Action("clear", this.oForm, this, this, true);
            }else{
                oAction.sMode = "clear";
                oAction.oMainDD = this;
            }
            
            //  Generate request objects & collect fields
            tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
            tRequestSet.sName = "DDClear";
            tRequestSet.sRequestType = "clear";
            tRequestSet.sTable = this.sName;
            tRequestSet.iMaxRows = 1;
            tRequestSet.bReturnCurrent = false;
            
            tRow = new vdf.dataStructs.TAjaxSnapShot();
            tRequestSet.aRows.push(tRow);
            
            this.crawlDDS(function(oDD, bConstrainedTo, bConstrainedFrom, bServer, bChild){
                var iDeo;
                
                if((bChild && bConstrainedFrom) || !bChild){
                    if(bConstrainedTo){
                        //  Visit DEO for update
                        for(iDeo = 0; iDeo < this.aDEO.length; iDeo++){
                            this.aDEO[iDeo].update();
                        }
                        
                        //  Create lite snapshot
                        tRow.aDDs.push(this.createLiteSnapshot());
                    }else{
                        //  Lock DD
                        oAction.lock(this);
                        
                        //  Visit DEO for update and lock
                        for(iDeo = 0; iDeo < this.aDEO.length; iDeo++){
                            vdf.errors.clearByField(this.aDEO[iDeo]);
                            this.aDEO[iDeo].update();
                            oAction.lock(this.aDEO[iDeo]);
                        }
                        
                        //  Create snapshot
                        tRow.aDDs.push(this.createSnapshot());
                    }
                }
            });

            oAction.addRequestSet(tRequestSet);
            
            //  Send request
            oAction.onResponse.addListener(this.handleClear, this);
            oAction.send();
        }
    }   
},

/*
Handles the clear response by loading the snapshot into the buffer.

@param  oEvent  Event object.
@private
*/
handleClear : function(oEvent){
    var tResponseSet, oEventInfo; 

    tResponseSet = (oEvent.tResponseData ? oEvent.tResponseData.aDataSets[0] : null);
    
    oEventInfo = { 
        bError : false, 
        iErrorNr : 0, 
        tResponseSet : tResponseSet 
    };
    
    if(!oEvent.bError){
        if(tResponseSet.aRows.length > 0){
            this.loadSnapshot(oEvent.oSource, tResponseSet.aRows[0]);
        }
    }else{
        oEventInfo.bError = true;
        oEventInfo.iErrorNr = oEvent.iErrorNr;
    }
    
    this.onAfterClear.fire(this, oEventInfo);
},


//  - - - - - - - - - Special functionallity - - - - - - - - - - - -


/*
Validates the fields that belong to this DD and all DDs that would be involved 
in a save action.

@return iError  Error number (0 if no errors occurred, 1 if the onValidate event 
            was stopped).
*/
validate : function(){
    var iError = 0;
    if(this.onValidate.fire(this)){
        this.crawlDDS(function(oDD, bConstrainedTo, bConstrainedFrom, bServer, bChild){
            var iDeo, iResult = 0;
            
            if(!bChild){
                //  First update the buffers
                for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                    oDD.aDEO[iDeo].update();
                }
                
                //  Validate the DEOs
                for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                    iResult = oDD.aDEO[iDeo].validate();
                    
                    if(iResult > 0 && iError === 0){
                        iError = iResult;
                    }
                }     
            }
        });
    }else{
        iError = 1;
    }
    
    return iError;
},

/*
Determines if the DD has a record in its buffer.

@return True if this DD has a record in its buffer.
*/
hasRecord : function(){
    return this.tStatus.sValue !== null && this.tStatus.sValue !== "";
},

/*
Locks the DD by incrementing the counter and setting an exclusive lock.

@param  bExclusive  If true the lock will be exclusive.
@param  oAction     The action object that performs the lock.
@return True if the DD is succesfully locked.
@private
*/
lock : function(bExclusive, oAction){
    if(this.bLockedExclusive || bExclusive && this.iLocked > 0){
        return false;
    }else{
        if(bExclusive){
            this.bLockedExclusive = true;
        }
        
        this.iLocked++;
        
        return true;
    }
},

/*
Unlocks the DD by decrementing the counter and removing an exclusive lock.

@param  bExclusive  True if the lock was exclusive.
@param  oAction     Reference to the action object.
@private
*/
unlock : function(bExclusive, oAction){
    if(bExclusive){
        this.bLockedExclusive = false;
    }
    
    this.iLocked--;
},

/*
Checks wether one of the given DEO's has DEO's depending on them. If not a full
findByRowId isn't really nessacary when for example a user selects a record in 
a lookup. This way scrolling in a lookupdialog doesn't cause a AJAX call to be 
made! Recursive method.

@param  aSearchedDEO    Array of DEO objects that are not taken into account 
            (which usually call the method).
@param  oDone           Object with the names of the DDs that are done to 
            prevent recursive loops.
@private            
*/
hasDependingDEO : function(aSearchedDEO, oDone){
    var iCurrent, iDEO, iSearch;

    if(typeof(oDone) === "undefined"){
        oDone = {};
    }
    
    if(!oDone[this.sName]){
        //  Mark as done
        oDone[this.sName] = true;
        
        d:for(iDEO = 0; iDEO < this.aDEO.length; iDEO++){
            for(iSearch = 0; iSearch < aSearchedDEO.length; iSearch++){
                if(this.aDEO[iDEO] === aSearchedDEO[iSearch] || this.aDEO[iDEO].sDataBindingType == "R"){
                    continue d;
                }
            }
            
            return true;
        }   
        
        //  Move to servers
        // for(iCurrent = 0; iCurrent < this.aServers.length; iCurrent++){
            // if(this.aServers[iCurrent].hasDependingDEO(aSearchedDEO, oDone)){
                // return true;
            // }
        // }
        
        //  Move into DDs constrained to this DD
        for(iCurrent = 0; iCurrent < this.aConstrainedFrom.length; iCurrent++){
            if(this.aConstrainedFrom[iCurrent].hasDependingDEO(aSearchedDEO, oDone)){
                return true;
            }
        }
    }
    
    return false;    
},

/*
Recursive method that checks if the searched dd is a parent of this DD.

@param  oSearchedDD     DD that we are looking for.
@param  oDone           (optional) Object with names of passed DDs to prevent 
            ourself from recursive looping.
@return True if found.
@private
*/
isParent : function(oSearchedDD, oDone){
    var iCurrent;

    if(typeof(oDone) === "undefined"){
        oDone = {};
    }
    
    if(!oDone[this.sName]){
        //  Mark as done
        oDone[this.sName] = true;
        
        //  Move to servers
        for(iCurrent = 0; iCurrent < this.aServers.length; iCurrent++){
            if(this.aServers[iCurrent] === oSearchedDD || this.aServers[iCurrent].isParent(oSearchedDD, oDone)){
                return true;
            }
        }
    }
    
    return false;
},

/*
Loops through the DDO structure to determine wether the data is changed. It 
only bubbles up to the servers (like a save does). If a snapshot is given it 
compares the rowid's with the rowid's in the snapshot. It uses the display 
changed state (DEO.isChanged function) and not the buffer changed state.

@param  tSnapshot           (optional) A snapshot to compare rowids against.
@param  bSkipConstrainedTo  If true it doesn't bubble into constrained to DDs.
@return True if the data is changed (so it makes sense to perform a save).
@private
*/
isChanged : function(tSnapshot, bSkipConstrainedTo){
    var bChanged = false;
    
    this.crawlDDS(function(oDD, bConstrainedTo, bConstrainedFrom, bServer, bChild){
        var iDeo, iDD;
        
        if(!bChild && (!bSkipConstrainedTo || !bConstrainedTo)){
            
            //  Check rowid (if no snapshot is given we asume it might not be empty
            if(tSnapshot){
                for(iDD = 0; iDD < tSnapshot.aDDs.length; iDD++){
                    if(tSnapshot.aDDs[iDD].sName === oDD.sName){
                        if(tSnapshot.aDDs[iDD].tStatus.sValue !== oDD.tStatus.sValue){
                            bChanged = true;
                        }
                    }
                }
            }else{
                if(oDD.tStatus.sValue !== ""){
                    bChanged = true;
                }
            }
            
            //  Check if data entry objects are changed
            for(iDeo = 0; iDeo < oDD.aDEO.length && !bChanged; iDeo++){
                if(oDD.aDEO[iDeo].isChanged()){
                    bChanged = true;
                }
            }
            
            
        }
    });
    
    return bChanged;
}

});
