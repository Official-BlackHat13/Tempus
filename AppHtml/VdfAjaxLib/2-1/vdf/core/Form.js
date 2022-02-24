/*
Name:
    vdf.core.Form
Type:
    Prototype
Revisions:
    2005/10/24  Created the initial version (HW, DAE).
    2008/05/10  Remodelled it into the 2.0 model. It is now called 
    vdf.core.Form. (HW, DAE)
*/

/*
@require    vdf/core/MetaData.js
@require    vdf/core/ClientDataDictionary.js
@require    vdf/core/Action.js
*/

/*
Bubbles up in the DOM to search for the Form control or the Toolbar control 
(which points to the correct Form).

@param  eElement   Reference to a DOM element to start with.
@return Reference to the Form object (null if not found).
*/
vdf.core.findForm = function findForm(eElement){
    //  Bubble up in the DOM searching for VDF controls
    while(eElement !== null && eElement !== document){
        if(typeof(eElement.oVdfControl) === "object"){
            if(eElement.oVdfControl.sControlType === "vdf.core.Form" || eElement.oVdfControl.sControlType === "vdf.core.FormMeta" || eElement.oVdfControl.sControlType === "vdf.core.FormBase"){
                return eElement.oVdfControl;
            }else if(eElement.oVdfControl.sControlType === "vdf.core.Toolbar" && eElement.oVdfControl.oForm !== null){
                return eElement.oVdfControl.oForm;
            }
        }

        eElement = eElement.parentNode;
    }

    return null;
};


/*
Constuctor that has interface required by the vdf.core.Initializer. It 
initializes the properties and starts the initialization proces which 
creates the meta data object and DDO structure.

@param  eElement        Reference to the form DOM element.
@param  oParentControl  Reference to a parent control (if available).
*/
vdf.core.Form = function Form(eElement, oParentControl){
    this.FormMeta(eElement, oParentControl, true);
    
    var sKey;
    
    
    /*
    Reference to the server data dictionary. Can be set from the HTML API using 
    the sServerTable (html: vdfServerTable) property.
    */
    this.oServerDD = null;
    /*
    Property used during initialization to determine the server data dictionary 
    (see: oServerDD property).
    
    @html
    @htmlbubble
    */
    this.sServerTable = null;
    
    /*
    TODO: Implement!
    @private
    */
    this.bAutoClearDeoState     = this.getVdfAttribute("bAutoClearDeoState", true);
    /*
    Can be used to disable the autofill method. The autofill method 
    automatically performes find by RowID for each rowid that are available in 
    the status fields before initialization. When using lookups inside the Form 
    it is adviced to leave this option.
    
    The example shows how a record can be loaded into the buffer directly after 
    the page load by setting the rowid in the html.
@code
<input type="hidden" name="customer__rowid" value="05000000" />
@code
    */
    this.bAutoFill              = this.getVdfAttribute("bAutoFill", true);
    /*
    Switches the default key actions (like find, save, clear, delete) on and 
    off.
    */
    this.bAttachKeyActions      = this.getVdfAttribute("bAttachKeyActions", true);
    
    /*
    Fired before the initial fill is performed. The initial fill can be canceled 
    using event.stop(). The initial fill can also be switched of using the 
    bAutoFill property. Note that the initial fill can send an AJAX call with 
    findByRowIds but the onBeforeFindByRowId and onAfterFindByRowId of the 
    ClientDataDictionary objects are not fired.
    */
    this.onBeforeInitialFill    = new vdf.events.JSHandler();
    /*
    Fired after the initial fill is completed. The initial fill can have 
    performed a server request (AJAX Call).
    
    @prop   bAccessedServer If true the server is accessed.
    @prop   bError          If true an error occurred on the server.
    @prop   iErrorNr        The error number if an error occurred on the server.
    @prop   aResponseSets   Array with responsesets received from the server (if 
                the server is accessed).
    */
    this.onAfterInitialFill     = new vdf.events.JSHandler();
    
    
    
    //  @privates
    this.oDDs                   = {};
    this.oUserDataFields        = {};
    this.oActionKeys            = {};
    
    //  Copy settings
    for(sKey in vdf.settings.formKeys){
        if(typeof(vdf.settings.formKeys[sKey]) == "object"){
            this.oActionKeys[sKey] = vdf.settings.formKeys[sKey];
        }
    }
    
    this.iInitFinishedStage     = 6;
    
    //  Start the loading proces
    this.initStage();
};
/*
The Form is the core of data entry pages within the AJAX Library. The Form 
component contains the functionality to create the client-side DDO structure 
that performs the data binding. It builds this structure using the meta 
information which is loaded by the super class vdf.core.FormMeta using the 
vdf.core.MetaData class. During the initialization the Form creates instances of 
the vdf.core.ClientDataDictionary class for all the DDO objects that are defined 
in the Web Object on the server. These objects contain the logic for performing 
operations like finds and saves. All data entry objects that are bound to 
database fields will register themselves so they will receive updates of the 
DDs. 

Within the application the Form can be seen as a container that maintains its 
nested objects. For data entry objects it will initialize the validation 
systems. It also has an API for getting references to its child elements so 
multiple forms can be maintained in a single page without problems. Important 
settings like the sWebOject, sWebServiceUrl and sServerTable will be inherited 
by its child elements during initialization.

The following example defines a (simplified) inventory form:
@code
<form vdfControlType="vdf.core.Form" vdfName="myForm" vdfWebObject="oInvt" vdfServerTable="invt">
    ID: <input type="text" value="" name="invt__item_id" size="10" /><br/>
    Description: <input type="text" value="" name="invt__description" size="35" vdfSuggestSource="find" /><br/>
    Vendor ID: <input type="text" value="0" name="vendor__id" size="6" /><br/>
    Vendor Name: <input type="text" value="" name="vendor__name" size="30" vdfSuggestSource="find" /><br/>
    Part ID: <input type="text" value="" name="invt__vendor_part_id" size="15" /><br/>
    Price: <input type="text" value="0" name="invt__unit_price" size="8" /><br/>
    On hand: <input type="text" value="0" name="invt__on_hand" size="6" /><br/>
</form>
@code
*/
vdf.definePrototype("vdf.core.Form", "vdf.core.FormMeta", {

// - - - - - - - - - - INITIALIZATION - - - - - - - - - - -

/*
Loads the field meta data and starts building the DDO structure.

@private
*/
initStageFieldMetaDDO : function(){
    //vdf.log("Form: Loading stage " + this.iInitStage + ": Field Meta Load & DD Structure");
    
    //  Load field meta data
    this.loadFieldMeta();
    //  Build DD structure
    this.buildDDStructure();
},

/*
Finalizes the initialization by calling the application initialization and 
performing the initial fill.

@private
*/
initStageFinalize : function(){
    //vdf.log("Form: Loading stage " + this.iInitStage + ": Calls initializers & do autofill");
    this.callInitializers();
    
    //  Do initial fill
    if(this.bAutoFill){
        this.oServerDD.initialFill({});
    }
    
    if(this.oActiveField && this.bAutoFocusFirst){
        this.oActiveField.focus();
    }
},

/*
Initialization is done in three stages where stages can contain multiple tasks.

Stage 1:
    1 - The global meta data is loaded ASynchronously from the server.
    2 - The document is scanned further and fields are added to the form.
    
Stage 2:
    3 - The field meta data is loaded ASynchronously from the server.
    4 - The DDO structure is created.
Stage 3:
    5 - Child objects (lists / grids / lookups) can initialize themself
    
Stage 4:
    6 - Initial fill requests are made ASynchronously
    7 - The initialized are fired

@private
*/
initStage : function(){
    switch(this.iInitStage){
        case 1:
            this.initStageGlobalMetaFields();
            break;
        case 3:
            this.initStageFieldMetaDDO();
            break;
        case 5:
            this.initStageChildren();
            break;
        case this.iInitFinishedStage:
            this.initStageFinalize();
            
            
    }
},



/*
Is called after the intial meta data request is made and the fields are all 
found. It initializes the DDO structure by creating the ClientDataDictionary 
objects.

@private
*/
buildDDStructure : function(){
    var tMeta = this.oMetaData.getMetaData(), iDD, iDEO, sServerTable;
    
    //  Create DDs
    for(iDD = 0; iDD < tMeta.aDDs.length; iDD++){
        this.oDDs[tMeta.aDDs[iDD].sName] = new vdf.core.ClientDataDictionary(tMeta.aDDs[iDD].sName, this);  
    }
    
    //  Initialize DD structure
    for(iDD = 0; iDD < tMeta.aDDs.length; iDD++){
        this.oDDs[tMeta.aDDs[iDD].sName].buildStructure(tMeta.aDDs[iDD]);
    }
    
    //  Find the ServerDD
    sServerTable = this.getVdfAttribute("sServerTable", null, true);
    if(sServerTable !== null){
        this.oServerDD = this.oDDs[sServerTable.toLowerCase()];
        if(this.oServerDD === null || typeof(this.oServerDD) !== "object" || !this.oServerDD.bIsDD){
            this.oServerDD = null;
        }
    }
    if(this.oServerDD === null && this.aDEOs.length > 0){
        throw new vdf.errors.Error(0, "Form with fields must have a server DD!");
    }
    
    
    //  Initialize data bindings
    for(iDEO = 0; iDEO < this.aDEOs.length; iDEO++){
        this.aDEOs[iDEO].bindDD();
    }    
    
    //  Move to next step / stage
    this.iInitStage++;
    this.initStage();
},



// - - - - - - - - - - CENTRAL FUNCTIONALITY - - - - - - - - - - 

/*
Searches for the data dictionary object with the given name. 

@param  sName   Name of the DD.
@return Reference to the ClientDataDictionary object (null if not found).
*/
getDD : function(sName){
    sName = sName.toLowerCase();
    if(typeof(this.oDDs[sName]) === "object" && this.oDDs[sName].bIsDD){
        return this.oDDs[sName];
    }
    return null;
},

/*
Searches for the given databinding in the buffer (for userdata fields it 
returns the field value).

@param  sDataBinding    Data binding from the field.
@return Buffer value (null if not found).
*/
getBufferValue : function(sDataBinding){
    var aParts, sTable, sField, oDD, oField;

    sDataBinding = sDataBinding.toLowerCase().replace("__", ".");
    
    aParts = sDataBinding.split(".");
    if(aParts.length >= 2){
        sTable = aParts[0];
        sField = aParts[1];
        
        //  Search DD
        oDD = this.oDDs[sTable];
        if(typeof(oDD) === "object" && oDD.bIsDD){
            return oDD.getFieldValue(sTable, sField);
        }
    }else{
        //  User data fields are not in buffer, but for the ease of use we also return this values
        oField = this.oUserDataFields[sDataBinding];
        if(typeof(oField) === "object" && oField.bIsField){
            return oField.getValue();
        }
    }
    
    return null;
},

/*
Sets a new value to the buffer. If databinding points to a userdata field it 
directly sets the value to this field.

@param  sDataBinding    The data binding.
@param  sValue          The new value for the field.
*/
setBufferValue : function(sDataBinding, sValue){
    var aParts, sTable, sField, oDD;

    sDataBinding = sDataBinding.toLowerCase().replace("__", ".");
    
    aParts = sDataBinding.split(".");
    if(aParts.length >= 2){
        sTable = aParts[0];
        sField = aParts[1];
        
        //  Search DD
        oDD = this.oDDs[sTable];
        if(typeof(oDD) === "object" && oDD.bIsDD){
            oDD.setFieldValue(sTable, sField, sValue, false);
        }else{
            throw new vdf.errors.Error(0, "Table {{0}} not found!", this, [ sTable, sField ]);
        }
    }else{
        //  User data fields are not in buffer, but for the ease of use we also set this values
        if(this.oUserDataFields.hasOwnProperty(sDataBinding)){
            this.oUserDataFields[sDataBinding].setValue(sValue);
        }else{
            throw new vdf.errors.Error(0, "Field {{0}} not found!", this, [ sDataBinding ]);
        }
    }
},

/*
Checks if a DD with the given name is available.

@param  sTableName  Name of the DD object.
@return True if the DD is found (false if it is not).
*/
containsDD : function(sTableName){
    return (typeof(this.oDDs[sTableName]) === "object" && this.oDDs[sTableName].bIsDD);
},

// - - - - - - - - - - USER DATA - - - - - - - - - -

/*
Called by a field/DEO to register itself as user data field.

@param  oField  Reference to the field.
*/
registerUserDataField : function(oField){
    this.oUserDataFields[oField.sDataBinding.toLowerCase()] = oField;
},

/*
Gathers the user data with so it can be sent with a request.

@return Array containing vdf.dataStructs.TAjaxUserdata objects that represent the 
        user data fields.

@private
*/
getUserData : function(){
    var sField, tField, aResult = [];
    
    for(sField in this.oUserDataFields){
        if(this.oUserDataFields[sField].bIsField){
            tField = new vdf.dataStructs.TAjaxUserData();
            tField.sName = this.oUserDataFields[sField].sDataBinding;
            tField.sValue = this.oUserDataFields[sField].getValue();
            aResult.push(tField);
        }
    }
    
    return aResult;
},

/*
Updates the user data fields with the given values. Called by a vdf.core.Action
object.

@param  aUserData   Array with vdf.dataStruct.TAjaxUserData objects.
@private
*/
setUserData : function(aUserData){
    var iField, tField;
    
    for(iField = 0; iField < aUserData.length; iField++){
        tField = aUserData[iField];
        
        if(this.oUserDataFields.hasOwnProperty(tField.sName.toLowerCase())){
            this.oUserDataFields[tField.sName.toLowerCase()].setValue(tField.sValue);
        }
    }
},




// - - - - - - - - - - ACTION FORWARDING - - - - - - - - - - 

/*
Performs a find on this field. The find is performed by the Data Dictionary on 
the fields main index. Note that the find is send asynchronously! If no field is 
given the last active field is used.

@param  sFindMode       Findmode used for the find
@param  oField          Field for the find (optional)
@return True if request is sent
*/
doFind : function(sFindMode, oField){
    try{
        if(typeof oField === "object" && oField.bIsField){
            return oField.doFind(sFindMode);
        }else{
            if(typeof this.oActiveField === "object" && this.oActiveField.bIsField){
                return this.oActiveField.doFind(sFindMode);
            }else{
                throw new vdf.errors.Error(0, "No active field", this);
            }
        }
    }catch (oErr){
        vdf.errors.handle(oErr);
    }
    
    return false;
},

/*
Forwards a findByRowId request to the correct Data Dictionary. Note that this 
action is performed asynchronously!

@param  sTable  Name of the table.
@param  sRowId  Serialized rowid.
@return True if succesfully send.
*/
doFindByRowId : function(sTable, sRowId){
    try{
        sTable = sTable.toLowerCase();
        if(this.oDDs[sTable].bIsDD){
            return this.oDDs[sTable].doFindByRowId(sRowId);
        }    
    }catch (oErr){
        vdf.errors.handle(oErr);
    }
    
    return false;
},

/*
Performs a save. The save is performed on the server DD or on the DD with the 
given name. Note that the save is performed asynchronously.

@param  sTable  (optional) Table to perform the save on.
@return True if save was successfully send.
*/
doSave : function(sTable){
    try{
        if(typeof(sTable) === "string"){
            sTable = sTable.toLowerCase();
            if(this.oDDs[sTable].bIsDD){
                return this.oDDs[sTable].doSave();
            }else{
                throw new vdf.errors.Error(0, "Table unknown", this, [sTable]);
            } 
        }else{
            if(typeof this.oActiveField === "object" && this.oActiveField.bIsField){
                return this.oActiveField.doSave();
            }else{
                return this.oServerDD.doSave();
            }
        }
    }catch (oErr){
        vdf.errors.handle(oErr);
    }
    
    return false;
},

/*
Performs a clear. The clear is performed on the server DD or on the DD with the 
given name. Note that the clear is performed asynchronously.

@param  sTable  (optional) Table to perform clear on.
@return True if clear was successfully send.
*/
doClear : function(sTable){
    try{
        if(typeof(sTable) === "string"){
            sTable = sTable.toLowerCase();
            if(this.oDDs[sTable].bIsDD){
                return this.oDDs[sTable].doClear();
            }else{
                throw new vdf.errors.Error(0, "Table unknown", this, [sTable]);
            }
        }else{
            if(typeof this.oActiveField === "object" && this.oActiveField.bIsField){
                return this.oActiveField.doClear();
            }else{
                return this.oServerDD.doClear();
            }
        }
    }catch (oErr){
        vdf.errors.handle(oErr);
    }

    return false;
},

/*
Performs a delete. The delete is performed on the server DD or on the DD with 
the given name.

@param  sTable  (optional) Table to perform the delete on.
@return True if delete was succesfully send.
*/
doDelete : function(sTable){
    try{
        if(typeof(sTable) === "string"){
            sTable = sTable.toLowerCase();
            if(this.oDDs[sTable].bIsDD){
                return this.oDDs[sTable].doDelete();
            }else{
                throw new vdf.errors.Error(0, "Table unknown", this, [sTable]);
            }
        }else{
            if(typeof this.oActiveField === "object" && this.oActiveField.bIsField){
                return this.oActiveField.doDelete();
            }else{
                return this.oServerDD.doDelete();
            }
        }
    }catch (oErr){
        vdf.errors.handle(oErr);
    }
    
    return false;
}


});