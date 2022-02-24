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
            if(eElement.oVdfControl.sControlType === "vdf.core.Form"){
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
    var sKey;
    
    /*
    Reference to the form DOM element.
    */
    this.eElement = eElement;
    /*
    Name of the form.
    
    @html
    */
    this.sName = vdf.determineName(this, "form");
    /*
    Reference to a parent control (if the form is located inside another control).
    */
    this.oParentControl = (typeof(oParentControl) === "object" ? oParentControl : null);

    /*
    Name of the Web Object that belongs to this form. The Form will replicate 
    its DDO structure and find, save, clear & delete actions are performed on 
    that Web Object.
    */
    this.sWebObject             = this.getVdfAttribute("sWebObject", null);
    /*
    The URL to the webservice that can be used to access the Visual DataFlex web 
    application using the AJAX Library interface.
    */
    this.sWebServiceUrl         = this.getVdfAttribute("sWebServiceUrl", "WebService.wso");
    /*
    The CSS class that is set on the form element.
    */
    this.sCssClass              = this.getVdfAttribute("sCssClass", "vdfform", false);
    
    /*
    Name of the initializer method. Might be encapsulated inside an global 
    object (like myObj.mySub.myFunct). This method is called after the form and 
    its child controls are finished with their initialization.
    
@code
<script type="text/javascript">
    function myInitializer(oForm){
        ...
    }
</script>

<form vdfControlType="form" vdfName="MyForm" vdfInitializer="myInitializer" ..>
    ...
</form>
@code
    */
    this.sInitializer           = this.getVdfAttribute("sInitializer", null);
    
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
    If true the focus will be given to the first field after initialization.
    */
    this.bAutoFocusFirst        = this.getVdfAttribute("bAutoFocusFirst", true);
    
    /*
    Fired after the form has finished its initialization.
    */
    this.onInitialized          = new vdf.events.JSHandler();
    /*
    Fired if the user presses enter or double clicks inside a lookup.
    */
    this.onEnter                = new vdf.events.JSHandler();
    
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
    
    
    /*
    Reference to the meta data object (vdf.core.MetaData).
    */
    this.oMetaData              = new vdf.core.MetaData(this.sWebObject, this.sWebServiceUrl);
    
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
    @privates
    */
    this.oDDs                   = {};
    this.aDEOs                  = [];
    this.oUserDataFields        = {};
    this.oActionKeys            = {};
    this.aChildren              = [];
    this.oControls              = {};
    
    
    //  Private properties
    this.oActiveField           = null;
    this.iInitStage             = 1;
    this.iInitFinishedStage     = 6;
    this.bIsForm                = true;
    this.eElement.oVdfControl   = this;
    
    
    //  Copy settings
    for(sKey in vdf.settings.formKeys){
        if(typeof(vdf.settings.formKeys[sKey]) == "object"){
            this.oActionKeys[sKey] = vdf.settings.formKeys[sKey];
        }
    }
    
    //  Start the loading proces
    this.initStage();
    
    //  Set classname
    if(this.eElement.className.match(this.sCssClass) === null){
        this.eElement.className = this.sCssClass;
    }
};
/*
The Form is the core of the data entry pages within the AJAX Library. It is 
comparable to the dbView in windows applications. It manages the DDO structure 
and the Data Entry Objects. The Form also keeps an administration of all 
controls inside so it can be used to get references by their name. This way the 
Form can be used prevent naming conflicts from happening with multiple data 
entry views in a single page.
*/
vdf.definePrototype("vdf.core.Form", {

// - - - - - - - - - - INITIALIZATION - - - - - - - - - - -

/*
Initialization is done in three stages where stages can contain multiple tasks.

Stage 1:
    1 - The global meta data is loaded ASynchronously from the server.
    2 - The document is scanned further and fields are added to the form.
    
Stage 2:
    3 - The field meta data is loaded ASynchronously from the server.
    4 - The Client Data Dictionaries are created and the DEOs are bound.
    
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
            //vdf.log("Form: Loading stage 1: Global Meta Load & Field Scan");
            //  Load the global meta data
            this.oMetaData.loadGlobalData(this.onGlobalMetaLoaded, this);
            //  The fields add themself when they are created by the Initializer
            break;
        case 3:
            //vdf.log("Form: Loading stage 2: Field Meta Load & DD Structure");
            //  Load field meta data
            this.loadFieldMeta();
            //  Build DD structure
            this.buildDDStructure();
            break;
        case 5:
            //vdf.log("Form: Loading stage 3: Child intialization");
           
            //  Init childs
            this.initChilds();
            break;
        case this.iInitFinishedStage:
            //vdf.log("Form: Loading stage 4: Initial fill");
            this.callInitializers();
            
            //  Do initial fill
            if(this.bAutoFill){
                this.oServerDD.initialFill({});
            }
            
            if(this.oActiveField && this.bAutoFocusFirst){
                this.oActiveField.focus();
            }
            
            
    }
},

/*
Handler function called by the Meta Data system if the global meta data is 
loaded. Moves to the next step of the initialization proces.

@private
*/
onGlobalMetaLoaded : function(){
    this.iInitStage++;
    this.initStage();
},

/*
Called by the DEO objects to register themself.

@private
*/
addDEO : function(oDeo){
    this.aDEOs.push(oDeo);
    oDeo.oForm = this;
    
    if(this.oActiveField === null && oDeo.bFocusable){
        this.oActiveField = oDeo;
    }
},

/*
Called by the initializer which is an indication that the document scan is 
finished so we can move on to the next step / stage of the initialization.
*/
init : function(){
    this.iInitStage++;
    this.initStage();
},

/*
Loads the basic field data.

@private
*/
loadFieldMeta : function(){
    var aFields = [], iDEO;

    for(iDEO = 0; iDEO < this.aDEOs.length; iDEO++){
        if(this.aDEOs[iDEO].sDataBindingType == "D"){
            aFields.push(this.aDEOs[iDEO].sDataBinding);
        }
    }
    
    this.oMetaData.loadFieldData(aFields, this.onFieldMetaLoaded, this);
},

/*
Is called by the MetaData object if the field info is loaded. Moves on to the 
next step / stage of the initialization.

@private
*/
onFieldMetaLoaded : function(){
    this.iInitStage++;
    this.initStage();
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

/*
The last step of the initialization which initializes the fields and the 
validation.

@private
*/
initChilds : function(){
    var iDEO;

    this.formInit();
    
    //  Init fields
    for(iDEO = 0; iDEO < this.aDEOs.length; iDEO++){
        this.aDEOs[iDEO].update();
        
        if(typeof(this.aDEOs[iDEO].initValidation) == "function"){
            this.aDEOs[iDEO].initValidation();
        }
    }
    
    //vdf.log("Finished state: " + this.iInitFinishedStage);
    
    //  Move on to the next stage
    this.iInitStage++;
    this.initStage();
    
},

/*
Called when a child has finished initialization. It increases the 
initialization stage counter and moves on with the next step.

@private
*/
childInitFinished : function(){
    this.iInitStage++;
    this.initStage();
},

/*
Throws the onInitialized event and calls the initializer (if one is set).

@private
*/
callInitializers : function(){
    var fInitializer  = null;
    
    //  Throw the onInitialized event
    this.onInitialized.fire(this, null);
    
    if(typeof this.sInitializer === "string"){
        fInitializer = vdf.sys.ref.getNestedObjProperty(this.sInitializer);
        
        //  Call the function
        if(typeof fInitializer === "function"){
            fInitializer(this);
        }else{
            throw new vdf.errors.Error(147, "Init method not found '{{0}}'", this, [ this.sInitializer ]);
        }
    }
},
// - - - - - - - - - - CENTRAL FUNCTIONALITY - - - - - - - - - - 

/*
Can be used to fetch global meta data properties. First it tries to load the 
property from the Form element, if not available there it loads the property 
from the meta data.

@param  sProp   Name of the meta data property.
@return Property value (null if not available)
*/
getMetaProperty : function(sProp){
    var sResult = this.getVdfAttribute(sProp, null);
    
    if(sResult === null){
        sResult = this.oMetaData.getGlobalProperty(sProp);
    }
    
    return sResult;
},

/*
Gets a vdf attribute from the element. The first letter of the name is replaced with "vdf" so all HTML properties are recognizable.

@param  sName       Name of the attribute.
@param  sDefault    Value returned if attribute not set.
@return Value of the attribute (sDefault if not set).
*/
getVdfAttribute : function(sName, sDefault){
    return vdf.getDOMAttribute(this.eElement, sName, sDefault);
},

/*
It searches for the DEO with the given name. The name can be the control name 
or the data binding.

@param  sName   Name of the DEO or the data binding ("customer.name").
@return Reference to the data entry object (null if not found).
*/
getDEO : function(sName){
    var i;
    
    for(i = 0; i < this.aDEOs.length; i++){
        if((this.aDEOs[i].sName !== null && this.aDEOs[i].sName.toLowerCase() === sName.toLowerCase()) || (this.aDEOs[i].sDataBinding !== null && this.aDEOs[i].sDataBinding === sName.toLowerCase())){
            return this.aDEOs[i];
        }
    }
    
    return null;
},

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
},

// - - - - - - - - - - CONTAINER FUNCTIONALITY - - - - - - - - - - 

/*
Searches for a control within the form. Should be used with multiple views per 
page systems.

@param  sName   Name of the searched control.
@return Reference to the control (null if not found).
*/
getControl : function(sName){
    if(typeof(this.oControls[sName.toLowerCase()]) !== "undefined"){
        return this.oControls[sName.toLowerCase()];
    }else{
        return null;
    }
},

/*
Called by the initializer if a nested control is found. Adds the control into 
the aChildren array so it will get bubbling event messages.

@param  oControl    Reference to the control object.
*/
addChild : function(oControl){
    this.aChildren.push(oControl);
},

/*
Calls the formInit function on the children so they can do their intialization.
Usually used if the childs initialization requires meta data to be loaded or DD
structures to be initialized.

@private
*/
formInit : function(){
    var iChild;
    
    for(iChild = 0; iChild < this.aChildren.length; iChild++){
        if(typeof(this.aChildren[iChild].formInit) === "function"){
            this.aChildren[iChild].formInit();
        }
    }
},

/*
Called to recalculate the sizes & position. Usually fired by an element that has 
resized (for some reason). Can bubble up and down.

@param bDown    If true it bubbles up to parent components.
@private
*/
recalcDisplay : function(bDown){
    var iChild;

    if(bDown){
        for(iChild = 0; iChild < this.aChildren.length; iChild++){
            if(typeof this.aChildren[iChild].recalcDisplay === "function"){
                this.aChildren[iChild].recalcDisplay(bDown);
            }
        }
    }else{
        if(this.oParentControl !== null && typeof(this.oParentControl.recalcDisplay) === "function"){
            this.oParentControl.recalcDisplay(bDown);
        }
    }
},

/*
(Recursive) Called to determine if parent elements need to wait with messing 
with the DOM (especially hiding stuff) because the children are still 
initializing and need to do some pixel calculation.

@return Amount of children that need waiting.
@private
*/
waitForCalcDisplay : function(){
    var iChild, iWait = 0;
    
    for(iChild = 0; iChild < this.aChildren.length; iChild++){
        if(typeof(this.aChildren[iChild].waitForCalcDisplay) === "function"){
            iWait =  iWait + this.aChildren[iChild].waitForCalcDisplay();
        }
    }
    
    return iWait;
}

});