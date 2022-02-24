//
//  Class:
//      VdfForm
//
//  Core of the DataFlex ajax framework. It contains generic functionality for
//  forms using ajax.
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

//	The default keycodes for the actions
var aVdfFormActionKeys = {
	findGT : 119,
	findLT : 118,
	findGE : 120,
	findFirst : 36,
	findLast : 35,
	save : 113,
	clear : 116,
	remove : 113,
	lookup : 115
};

//
//  Used to fetch the form that an html object is in. It bubbles up through
//  the html dom and until an form element is found an returns the VdfForm that
//  is attached to the form.
//
//  Params:
//      oObj    An object in the form
//  Returns:
//      The VdfForm or null if not found
//
function findForm(oObj){
    var oForm = browser.dom.searchParent(oObj, "form");

    if(oForm == null)
        return null;

    return oForm.oVdfForm;
}

//  Keeps all vdfcontrols (forms, grids, lookups, ...)
//  PRIVATE
var aVdfControls = new Object();

//
//  Used to fetch controls to call functions (like find() on initialisation)
//
//  Params:
//      sName   Name of the searched object
//  Returns:
//      Vdf control with the given name (null & alert if not found)
//
function getVdfControl(sName){
    sName = sName.toLowerCase();

    if(aVdfControls[sName] != null){
        return aVdfControls[sName];
    }else{
        alert("Control " + sName + " not found!");
        return null;
    }
}

//  When true the initialisation already has been done
//  PRIVATE
var bVdfInitialized = false;
//  Attaches the onload event
browser.events.addGenericListener("load", window, VdfAutoInit);

//
//  Fetches the onload event and starts the initialisationprocess once.
//
//  PRIVATE
function VdfAutoInit(e){
    if (!bVdfInitialized){
        bVdfInitialized = true;
        
        try{
            VdfInitControls();
        }
        catch(oError){
            VdfErrorHandle(oError);
        }
    }
}

//
//  Initializes the vdfControls and fields that the given dom element contain.    
//
//  Params:
//      eStartElement   Element to start the scan
//      bCallInitForm   If true the initForm method is called after 
//                      initialisation
//
function VdfInitControls(eStartElement, bCallInitForm){
    var iControl, aInitAfter = new Array();
    
    if(typeof(eStartElement) == "undefined"){
        var eStartElement = document.body;
    }
    if(typeof(bCallInitForm) == "undefined"){
        var bCallInitForm = true;
    }
    
    //  Start scan
    VdfScanControls(eStartElement, null, null, aInitAfter, new Array());
    
    //  Call after initialisation methods
    for(iControl in  aInitAfter){
        aInitAfter[iControl].initAfter();
    }
    
    //  Call initForm if initialisation is finished
    if(bCallInitForm && typeof(initForm) == "function"){
        initForm();
    }
    
    
}

//
//  Recursive scan method that loops through the whole html dom to detect vdf 
//  controls and fields. It initializes and attaches the javascript objects 
//  that contain the libraries functionality.
//
//  Params:
//      eElement    Current element in the scanning proces
//      oVdfParent  Parent VdfControl
//      oVdfForm    Parent VdfForm
//      aInitAfter  Array with objects for bottom-up initialisation 
//      aFields     Array of fields that are already initialised within the 
//                  form used for radio buttons
//
//  PRIVATE
function VdfScanControls(eElement, oVdfParent, oVdfForm, aInitAfter, aFields){
    var sControlType, sControlName, fControlMethod, oVdfControl = null, oField = null, iChild, sDataBinding;
    
    //  If vdfControl then initiate it
    sControlType = browser.dom.getVdfAttribute(eElement, "sControlType");
    if(sControlType != null){
        sControlName = "Vdf" + sControlType.substr(0, 1).toUpperCase() + sControlType.substring(1).toLowerCase();
        
        //  Create control if type exists
        if(eval('typeof(' + sControlName + ') == "function"')){
            fControlMethod = eval(sControlName);
            oVdfControl = new fControlMethod(eElement, oVdfForm, oVdfParent);
            oVdfParent = oVdfControl;
            
            //  Forms are threated specially
            if(sControlName == "VdfForm" ){
                oVdfForm = oVdfControl;
                aFields = new Array();
            }
            
            //  Add to controls array
            if(typeof(oVdfControl.sName) != "undefined"){
                aVdfControls[oVdfControl.sName.toLowerCase()] = oVdfControl;
            }
            
            //  Do before child detection init call
            if(typeof(oVdfControl.init) == "function"){
                oVdfControl.init();
            }
                        
        }else{
			throw new VdfError(141, "Unknown controltype", null, null, oVdfForm, null, [ sControlType ]);
        }
    }else{
        if(oVdfForm != null){
            //  Detect and add fields directly
            sDataBinding = browser.dom.getVdfAttribute(eElement, "sDataBinding", null);
            if(sDataBinding != null || (eElement.tagName == "INPUT" && eElement.type != "button") || eElement.tagName == "SELECT" || eElement.tagName == "TEXTAREA"){
                if(sDataBinding == null){
                    sDataBinding = eElement.name;
                }
                sDataBinding = sDataBinding.toLowerCase();
                
                //  Create VdfField element
                if(eElement.type != null && eElement.type.toLowerCase() == "radio"){
                    if(aFields[sDataBinding] != null){
                        aFields[sDataBinding].addElement(eElement);
                    }else{
                        oField = new VdfField(eElement, oVdfForm, sDataBinding);
                        aFields[sDataBinding] = oField;
                    }
                }else{
                    oField = new VdfField(eElement, oVdfForm, sDataBinding);
                }
                
                //  Add field element to the parent
                if(oField != null && oVdfParent != null){
                    oVdfParent.addField(oField, sDataBinding);
                }
            }
        }
    }
    
    //  Scan child elements
    for(iChild = 0; iChild < eElement.childNodes.length; iChild++){
        if(eElement.childNodes[iChild].nodeType != 3 && eElement.childNodes[iChild].nodeType != 8){
            VdfScanControls(eElement.childNodes[iChild], oVdfParent, oVdfForm, aInitAfter, aFields);
        }
    }
    
    if(oVdfControl != null){
        //  Queue after child detecion init call
        if(typeof(oVdfControl.initAfter) == "function"){
            aInitAfter.push(oVdfControl);
        }
    }

}


//
//  Constructor of the VdfForm class. Initializes properties.
//
//  Params:
//      oForm   The html form element
//
function VdfForm(oForm, oVdfParent){
    // Main references
    this.oForm                  = oForm;
    oForm.oVdfForm              = this;

    //  Public properties
    this.sVersion               = "1.2";
    
    //  Settings
    this.sWebObject             = browser.dom.getVdfAttribute(this.oForm, "sWebObject", null);
    this.sMainTable             = browser.dom.getVdfAttribute(this.oForm, "sMainTable", null);
    this.sServerTable           = browser.dom.getVdfAttribute(this.oForm, "sServerTable", null);
    this.sWebServiceUrl         = browser.dom.getVdfAttribute(this.oForm, "sWebServiceUrl", "WebService.wso");
    this.sName                  = browser.dom.getVdfAttribute(this.oForm, "sControlName", "Form1");
    this.sControlType           = browser.dom.getVdfAttribute(this.oForm, "sControlType", "form");
    
    this.bValidateServer        = browser.dom.getVdfAttribute(this.oForm, "bValidateServer", true);
    this.bValidateClient        = browser.dom.getVdfAttribute(this.oForm, "bValidateClient", true);
    this.bValidateAdjust        = browser.dom.getVdfAttribute(this.oForm, "bValidateAdjust", true);
    this.bValidatePrevent       = browser.dom.getVdfAttribute(this.oForm, "bValidatePrevent", true);
        
    this.bAttachVdfKeyActions   = browser.dom.getVdfAttribute(this.oForm, "bAttachVdfKeyActions", true);
    this.bAutoClearDeoState     = browser.dom.getVdfAttribute(this.oForm, "bAutoClearDeoState", true);
    this.bAutoFill              = browser.dom.getVdfAttribute(this.oForm, "bAutoFill", true);
    
    this.aTables                = new Object();  //  2 dimension array with al fields ordered by table 
                                            //  (this.aTables["TableName"]["FieldName"])
    
    //  Private properties
    
    //  Child objects of the form (DbGrid/DbLookup/..)
    this.aVdfChilds             = new Array();
    this.oVdfInfo               = new VdfInfo(this);
    this.oVdfActiveObject       = this;
    this.oVdfValidator          = new VdfValidator(this);    
        
    // Key codes (are loaded from sActionKeys property and merged with the global defaults)
	var aUserKeys				= eval("({" + browser.dom.getVdfAttribute(this.oForm, "sActionKeys", "") + "})");
	this.aActionKeys			= browser.data.merge(aUserKeys, aVdfFormActionKeys);
    
    //  Data structures
    this.aStatusFields          = new Object();  //  Set of all statusfields managed by this form (rowid fields)
    this.aFields                = new Object();  //  Set of all fields managed by this form
	
    this.aUserFields            = new Object();
    this.aLookupDialogs         = new Object();  //  Set of all lookupdialogs attached indexed by the field name
    
    this.oPreviousFocus         = null;
    this.oLastFocus             = null; //  The last focused field
    
    //  Check required settings
    if(this.sWebObject == null){
        throw new VdfError(131, "Webobject required", null, null, this, this);
    }
    if(this.sMainTable == null){
        throw new VdfError(132, "Maintable required", null, null, this, this);
    }
    if(this.sServerTable == null){
        this.sServerTable = this.sMainTable;
    }
    
    this.sServerTable = this.sServerTable.toLowerCase();
    this.sMainTable = this.sMainTable.toLowerCase();
    
    this.bParentControl = true;
}

//
//  Initializes the form "engine" by requesting info about the WBO and scanning
//  for fields, initializing children, attaching events and doing the autofill.
//
//  PRIVATE
VdfForm.prototype.init = function(){
    //  Load DDInfo
    if(!this.oVdfInfo.isInfoLoaded()){
        this.oVdfInfo.loadInfo(this.sWebObject, this.sWebServiceUrl);
    }
    
     for(sTable in this.oVdfInfo.aTables){
        this.aTables[sTable] = new VdfTable(this, sTable);
        this.aTables[sTable].init();
     }
}

//
//  Is called by the initialisation methods after initialisation of the child 
//  elements. Performs autofill and makes sure the 
//
//  PRIVATE
VdfForm.prototype.initAfter = function(){
    //  Initialize fields
    this.initFields();

    //  Auto fill using rowid's already in the hidden status fields
    if(this.bAutoFill){
        this.fill();
    }
    
    this.returnToFirstField();
}

//
//  Attaches field events listeners and builds the <table><field> structure,
//
//  PRIVATE
VdfForm.prototype.initFields = function(){
    var sField, oField, sTable, oDiv, sField, sTable, sColumn, iField;
    
    //  Initialize status fields
    for(sTable in this.aTables){
        //  Create statusfield if needed
        if(this.aStatusFields[sTable + "__rowid"] == null){
            oInput = document.createElement("input");
            oInput.type = "hidden";
            oInput.name = sTable + "__rowid";
            this.oForm.appendChild(oInput);
            oField = new VdfField(oInput, this, sTable + "__rowid");
            this.aStatusFields[sTable + "__rowid"] = oField;
        }else{
            oField = this.aStatusFields[sTable + "__rowid"];
        }
        
        //  Attach statusfield
        this.aTables[sTable].oStatusField = oField;
        
        //  Attach listeners if needed
        if(oField.sType != "hidden"){
            oField.addGenericListener("focus", this.onFieldFocus);
            oField.addKeyListener(this.onFieldKeyPress);
            oField.addGenericListener("change", this.onStatusFieldChange);
        }
    }    
    
    //  Initialize fields
    for(sField in this.aFields){
        sTable = this.aFields[sField][0].getTableName();
        sColumn = this.aFields[sField][0].getFieldName();
        
        //	Add to <TABLE><FIELD> structure 
        if(this.oVdfInfo.fieldExists(sTable, sColumn)){
            this.aTables[sTable].aFields[sColumn] = this.aFields[sField];
        }else{
            throw new VdfFieldError(152, "Unknown field", this.aFields[sField][0], this, this);
        }
        
        for(iField in this.aFields[sField]){
            oField = this.aFields[sField][iField];
                       
            //  Attach generic form events
            oField.addGenericListener("focus", this.onFieldFocus);
            oField.addGenericListener("dblclick",  this.onFieldKeyPress)
            //  Set server table
            oField.setServerTable(this.sServerTable, false);
            
            //  Attach key listeners
            oField.addKeyListener(this.onFieldKeyPress);
            
            //  Initiate validation addons
            this.oVdfValidator.initField(oField, oField.getServerTable());
        }
        
        //  Call fields own initialisation method
        oField.init();
    }
    
    for(sField in this.aUserFields){
        this.aUserFields[sField].init();
    }
}

//
//  Adds a field to the administration. Shifs user & status fields from 
//  ordinary data fields. 
//
//  Params:
//      oField          VdfField object that belongs to the field
//      sDataBinding    Databinding of the field
//
//  PRIVATE
VdfForm.prototype.addField = function(oField, sDataBinding){
    var iField;
    
    //  Shift data fields from user fields
    if(sDataBinding.contains("__")){
        
        //  Shift status fields (rowid) from data fields
        if(oField.getFieldName() == "rowid"){
            this.aStatusFields[sDataBinding] = oField;
        }else{
        
            //  More data fields with the same name are supported
            if(this.aFields[sDataBinding] == null){
                this.aFields[sDataBinding] = new Array();
            }
            
            //  Add new fields
            this.aFields[sDataBinding].push(oField);
        }
    }else{
        //  Build userfield administration
        this.aUserFields[sDataBinding] = oField;
    }    
}

//
//  Method used for filling the form using the rowid fields. If no rowid fields
//  are available it won't send the VdfForm requestset. It also asks child 
//  elements for fill requestsets.
//
//  Params:
//      bSuppressError  If true no errors will be shown while handling the 
//                      request.
//  
VdfForm.prototype.fill = function(bSuppressError){
    var iChild, sXml = "", sField, bSend = false, sFieldValues = "";
    var sXml = new JStringBuilder();

    //  Check if fill request should be sent
    for(sField in this.aStatusFields){
        if(this.aStatusFields[sField].getValue() != ""){
            bSend = true;
            break;
        }
    }
    
    sXml.append("<aDataSets>\n");
    
    //  Create requestset
    if(bSend){    
        //  Throw user event
        if (this.onBeforeFind(this, "", "", true) == false) return false;
        
        //  Fetch status values (make sure changedstate is true for filled fields)
        for(sField in this.aStatusFields){
            sFieldValues += VdfGlobals.soap.getFieldXml(sField, this.aStatusFields[sField].getValue(), (this.aStatusFields[sField].getValue() != ""));
        }
        //  Fetch fields
        sFieldValues += this.aTables[this.sMainTable].getDataXml(true, false);
        
        //  Create requestset
        sXml.append(this.getRequestSet("findByRowId", 1, this.sMainTable, "", "", dfRowID, (bSuppressError ? "_NoWarning" : ""), sFieldValues));
    }    
    
    for(iChild = 0; iChild < this.aVdfChilds.length; iChild++){
        if(typeof(this.aVdfChilds[iChild].getFillRequestSets) == "function"){
            sXml.append(this.aVdfChilds[iChild].getFillRequestSets(this.sMainTable));
        }
    }
        
    sXml.append("</aDataSets>\n");
        
    if(bSend || sXml.strings.length > 2){
        this.sendRequest(sXml.toString(), false);
    }

}

//
//  doFind now performs a findByField on the server which makes doFindByField 
//  redundant but exists for more clearance to the user.
//
//  Params:
//      sFindMode       The mode to use for the find
//      oField          VdfField object of field to perform find on
//      bSuppressError  If true the not found error will not be shown
//  Returns:
//      True if the find request is send
//  
//  DEPRECATED
VdfForm.prototype.doFindByField = function(sFindMode, oField, bSuppressError){
    if(typeof(oField) == "object"){
        return this.doFind(sFindMode, oField, bSuppressError);
    }
}

//
//  Sends a findByRowId request for the given table after replacing the rowid 
//  fields value with the given value. Childs are asked for their additional
//  requestsets.
//
//  Params:
//      sTable          Name of the table to do the find on
//      sRowId          RowId used for the find
//      bSuppressError  If true the not found error will not be shown
//
VdfForm.prototype.doFindByRowId = function(sTable, sRowId, bSuppressError){
    var sField, bHandled = false, oField;
    var sXml= new JStringBuilder();
    
    if(typeof(sVdfControlName) == "undefined") var sVdfControlName = null;
    
    try{
        //  Find the statusfield
        oField = this.getStatusField(sTable + "__rowid");

        //  Clear errors
        VdfErrorsClearAll();
        
        if(oField != null){
            //  Make sure changedstate is true
            oField.setValue("", true);
            oField.setValue(sRowId);
            
            //  Initiate user event
            if (this.onBeforeFind(this, sTable, "", true) == false) return false;
            
            //  Append requestsets to the find
            sXml.append("<aDataSets>\n");
            sXml.append(this.getRequestSet("findByRowId", 1, sTable, "", "", "", (bSuppressError ? "_NoWarning" : "")));

            //  Loop through childs for their additional requestsets
            for(iChild = 0; iChild < this.aVdfChilds.length; iChild++){
                if(typeof(this.aVdfChilds[iChild].getFindRequestSets) == "function"){
                    sXml.append(this.aVdfChilds[iChild].getFindRequestSets(sTable));
                }
            }

            sXml.append("</aDataSets>\n");

            this.sendRequest(sXml.toString(), false);
        }
     }catch(oError){
        VdfErrorHandle(oError);
    }
}


//
//  Performs a find by rowid for a child component (usually the list) for when 
//  a record is selected. If no fields are displayed or other child components
//  are attached no find is done.
//
//  Params:
//      sTable      Name of the table to perform the find on
//      sRowId      Rowid of the record to be found
//      oVdfSource  Vdf object that initiated the find (won't be asked for 
//                  requestsets)
//
//  PRIVATE
VdfForm.prototype.childFindByRowId = function(sTable, sRowId, oVdfSource){
    var sField, oField, sFieldValues;
    var sXml = new JStringBuilder();
    var sChildXml = new JStringBuilder();
    
    if(typeof(sVdfControlName) == "undefined") var sVdfControlName = null;
    
    //  Find the statusfield
    oField = this.getStatusField(sTable + "__rowid");

    //  Clear errors
    VdfErrorsClearAll();
    
    if(oField != null){
        //  Fetch fields
        sFieldValues = this.aTables[sTable].getDataXml(true, false, true, false);
        
        //  Loop through childs for their additional requestsets
        for(iChild = 0; iChild < this.aVdfChilds.length; iChild++){
            if(this.aVdfChilds[iChild] != oVdfSource){
                if(typeof(this.aVdfChilds[iChild].getFindRequestSets) == "function"){
                    sChildXml.append(this.aVdfChilds[iChild].getFindRequestSets(sTable));
                }
            }
        }
        
        //  Determine if request is nessacary
        if(sFieldValues != "" || sChildXml.toString() != ""){
            //  Make sure changedstate is true
            oField.setValue("", true);
            oField.setValue(sRowId);
        
            //  Fetch status xml
            sFieldValues = this.getCurrentStatusXml() + sFieldValues;
            
            //  Initiate user event
            if (this.onBeforeFind(this, sTable, "", true) == false) return false;
            
            //  Append requestsets to the find
            sXml.append("<aDataSets>\n");
            sXml.append(this.getRequestSet("findByRowId", 1, sTable, "", "", "", "_NoConstrained_NoFocus", sFieldValues));
            sXml.append(sChildXml.toString());
            sXml.append("</aDataSets>\n");
            
            this.sendRequest(sXml.toString(), false);    
        }
    }
}

//
//  Performs a clear for a child component (usually the list) for when an empty
//  row is selected. If no fields are displayed or other child components are 
//  attached no clear is sent.
//
//  Params:
//      sMainTable  Forced maintable for the action (optional)
//      oVdfsource  Vdf object that sent the request (won't be asked for 
//                  requestssets)
//
//  PRIVATE
VdfForm.prototype.childClear = function(sMainTable, oVdfSource){
    var bHandled = false;
    var sXml = new JStringBuilder();
    var sChildXml = new JStringBuilder();

    // Clear errors
	VdfErrorsClearAll();
    
    //  Make sure a maintable is given
    if(typeof(sMainTable) != "undefined" && sMainTable != null){
        for(iChild = 0; iChild < this.aVdfChilds.length && !bHandled; iChild++){
            if(this.aVdfChilds[iChild] != oVdfSource){
                if(typeof(this.aVdfChilds[iChild].doClear) == "function"){
                    bHandled = this.aVdfChilds[iChild].doClear(sMainTable);
                }
            }
        }
        
        if(!bHandled){
            //  Fetch fields
            sFieldValues = this.aTables[sMainTable].getDataXml() 
            
            //  Loop through childs for their additional requestsets
            for(iChild = 0; iChild < this.aVdfChilds.length; iChild++){
                if(this.aVdfChilds[iChild] != oVdfSource){
                    if(typeof(this.aVdfChilds[iChild].getClearRequestSets) == "function"){
                        sChildXml.append(this.aVdfChilds[iChild].getClearRequestSets(sMainTable));
                    }
                }
            }
            
            //  Determine if request is nessacary
            if(sFieldValues != "" || sChildXml.toString() != ""){
        
                //  Fetch status xml
                sFieldValues = this.getCurrentStatusXml() + sFieldValues;
            
                //  Initiate user event
                if (this.onBeforeClear(this, sMainTable) == false) return false;
            
                sXml.append("<aDataSets>\n");
            	sXml.append(this.getRequestSet("clear", 1, sMainTable, "", "", "", "_NoFocus", sFieldValues));
            	sXml.append(sChildXml.toString());
                sXml.append("</aDataSets>\n");

                this.sendRequest(sXml.toString(), false);
            }
        }
    }
}
    

//
//  Performes a findByField operation using the given findmode on the given (or
//  the last focussed) field. The childs are asked for additional requestsets. 
//  
//  Params:
//      sFindMode       Findmode used for the find
//      oField          Field for the find (optional)
//      bSuppressError  If true the not found error will not be shown (optional)
//  Returns:
//      True if request is sent
//
VdfForm.prototype.doFind = function(sFindMode, oField, bSuppressError){
    var sXml = new JStringBuilder(), sIndex;
    
    try{
        if(typeof(oField) != "object"){
            var oField = this.oLastFocus;
        }
        
        if(oField != null){
            
            sIndex = this.getVdfFieldAttribute(oField, "iIndex");
            if(sIndex != null && sIndex != "" && sIndex != "0"){
            
                // Clear errors
                VdfErrorsClearAll();
    
                //  Initiate user event
                if (this.onBeforeFind(this, oField.sTable, oField.sField, false, sFindMode) == false) return false;
            
                //  Append requestsets to the find
                sXml.append("<aDataSets>\n");
                sXml.append(this.getRequestSet("findByField", 1, oField.sTable, oField.sField, "", sFindMode, (bSuppressError ? "_NoWarning" : "")));

                //  Loop through childs for their additional requestsets
                for(iChild = 0; iChild < this.aVdfChilds.length; iChild++){
                    if(typeof(this.aVdfChilds[iChild].getFindRequestSets) == "function"){
                        sXml.append(this.aVdfChilds[iChild].getFindRequestSets(oField.sTable));
                    }
                }

                sXml.append("</aDataSets>\n");

                this.sendRequest(sXml.toString(), false);
                
                return true;
            }else{
                throw new VdfFieldError(151, "Field not indexed", this.oLastFocus, this, this);                
            }
        }
    }catch(oError){
        VdfErrorHandle(oError);
    }
    
    return false;
}

//
//  Sends a save request using the servertable of the last selected field as 
//  maintable.
//
//  Params:
//      sForcedMainTable            Forced maintable for the action (optional)
//      bForcedAutoClearDeoState    Forced autoclear deo state value (optional) 
//  Returns:
//      True if save was successfull
//  
VdfForm.prototype.doSave = function(sForcedMainTable, bForcedAutoClearDeoState){
    var iChild, bResult = false, sMainTable, bAutoClearDeoState = this.bAutoClearDeoState;
    var sXml = new JStringBuilder();

    if(typeof(bForcedAutoClearDeoState) == "boolean"){
        bAutoClearDeoState = bForcedAutoClearDeoState;
    }
    
    try{
    
        if(typeof(sForcedMainTable) != "undefined"){
            sMainTable = sForcedMainTable;
        }
        
        // Clear errors
        VdfErrorsClearAll();
        
        //  Get last selected field / mainfile
        if(this.oLastFocus != null || sMainTable != null){
            if(sMainTable == null){
                sMainTable = this.oLastFocus.getServerTable();
            }
            
        	if(this.aTables[sMainTable].validate(false)){
            
                //  Initiate user event
                if (this.onBeforeSave(this, sMainTable) == false) return false;
            
                sXml.append("<aDataSets>\n");
            	sXml.append(this.getRequestSet("save", 1, sMainTable, "", "", ""));
                
                //  Add clear requestset if AutoClearDeoState is true
                if(bAutoClearDeoState){
                    sXml.append(this.getRequestSet("clear", 1, sMainTable, "", "", ""));
                }
            
                for(iChild = 0; iChild < this.aVdfChilds.length; iChild++){
                    if(typeof(this.aVdfChilds[iChild].getSaveRequestSets) == "function"){
                        sXml.append(this.aVdfChilds[iChild].getSaveRequestSets(sMainTable, this.bAutoClearDeoState));
                    }
                }
                    
            	sXml.append("</aDataSets>\n");

                this.bSaveResult = false;
            	this.sendRequest(sXml.toString(), false);
                
                bResult = this.bSaveResult;
        	}else{
                this.returnToField();
            }
        }
    
    }catch(oError){
        VdfErrorHandle(oError);
    }
    
    return bResult;
}

//
//  Sends a clear request using the servertable of the last selected field as 
//  maintable.
//
//  Params:
//      sMainTable  Forced maintable for the action (optional)
//
VdfForm.prototype.doClear = function(sMainTable){
    var bHandled = false;
    var sXml = new JStringBuilder();
    
    try{
        if(typeof(sMainTable) == "undefined"){
            var sMainTable = null;
        }
        
       // Clear errors
    	VdfErrorsClearAll();
    
        //  Get last selected field / mainfile
        if(this.oLastFocus != null || sMainTable != null){
            if(sMainTable == null){
                sMainTable = this.oLastFocus.getServerTable();
            }
            for(iChild = 0; iChild < this.aVdfChilds.length && !bHandled; iChild++){
                if(typeof(this.aVdfChilds[iChild].doClear) == "function"){
                    bHandled = this.aVdfChilds[iChild].doClear(sMainTable);
                }
            }
            
            if(!bHandled){
            
                //  Initiate user event
                if (this.onBeforeClear(this, sMainTable) == false) return false;
            
                sXml.append("<aDataSets>\n");
            	sXml.append(this.getRequestSet("clear", 1, sMainTable, "", "", ""));

            	for(iChild = 0; iChild < this.aVdfChilds.length; iChild++){
                    if(typeof(this.aVdfChilds[iChild].getClearRequestSets) == "function"){
                        sXml.append(this.aVdfChilds[iChild].getClearRequestSets(sMainTable));
                    }
                }
            	
                sXml.append("</aDataSets>\n");

                this.sendRequest(sXml.toString(), false);
            }
        }
    }catch(oError){
        VdfErrorHandle(oError);
    }
}

//
//  Sends a delete request using the servertable of the last selected field as 
//  maintable.
//
//  Params:
//      sMainTable  Forced maintable for the action (optional)
//
VdfForm.prototype.doDelete = function(sMainTable){
    var sXml = new JStringBuilder();
    
    if(typeof(sMainTable) == "undefined"){
        var sMainTable = null;
    }

    try{
    
        // Clear errors
    	VdfErrorsClearAll();
    
        //  Get last selected field / mainfile
        if(this.oLastFocus != null || sMainTable != null){
            if(sMainTable == null){
                sMainTable = this.oLastFocus.getServerTable();
            }
            
            //  Initiate user event
            if (this.onBeforeDelete(this, sMainTable) == false) return false;
        
            sXml.append("<aDataSets>\n");
            sXml.append(this.getRequestSet("delete", 1, sMainTable, "", "", ""));
        	
        	for(iChild = 0; iChild < this.aVdfChilds.length; iChild++){
                if(typeof(this.aVdfChilds[iChild].getDeleteRequestSets) == "function"){
                    sXml.append(this.aVdfChilds[iChild].getDeleteRequestSets(sMainTable));
                }
            }
    	
            sXml.append("</aDataSets>\n");

            this.sendRequest(sXml.toString(), false);
        }
    }catch(oError){
        VdfErrorHandle(oError);
    }
}

//
//  Is called when a responseset for this form of a find request is received. It
//  generates datasets from the responsrows and sets the values using the 
//  recursive setValues method of the VdfTable.
//
//  Param:
//      oXmlData    The xml response data
//      sName       The name of the Request / Response set
//  Returns:
//      True if successfully handled (false if errors occurred)
//
//  PRIVATE
VdfForm.prototype.handleFindByField = function(oXmlData, sName){
    var bResult = true, aRows, iRow, sTable = null, sColumn;

    sTable = browser.xml.findNodeContent(oXmlData, "sTable");
    sColumn = browser.xml.findNodeContent(oXmlData, "sColumn");
    
    if(browser.xml.findNodeContent(oXmlData, "bFound") == "true"){
        aRows = browser.xml.find(oXmlData, "TAjaxResponseRow");
        for(iRow = 0; iRow < aRows.length; iRow++){
            oDataSet = new VdfDataSet(this, aRows[iRow]);
            this.aTables[sTable].setValues(oDataSet, true, true, true, !this.aTables[sTable].isForeign(this.sMainTable));
        }
        
        if(this.oVdfActiveObject == this || this.oVdfActiveObject.sMainTable != sTable){ // Workarround to prevent the form from stealing the grids focus
            this.returnToField(sTable);
        }
    }else{
        if(!sName.contains("_NoWarning")){
            //throw new VdfError(133, "Not found", null, null, this, this);
        }
        
        bResult = false;
        
        this.returnToField();
    }

    //  Initiate user event
    this.onAfterFind(this, sTable, sColumn, bResult, false);
    
    return bResult;
}

//
//  Is called when a responseset for this form of a findByRowId request is 
//  received. It generates datasets and updates the displayed values. Then it
//  tries to select the first field of the table.
//
//  Param:
//      oXmlData    The xml response data
//      sName       The name of the Request / Response set
//  Returns:
//      True if successfully handled (false if errors occurred)
//
//  PRIVATE
VdfForm.prototype.handleFindByRowId = function(oXmlData, sName){
    var bResult = true, aRows, iRow, sTable, sField, oDataSet;

    sTable = browser.xml.findNodeContent(oXmlData, "sTable");
    
    if(browser.xml.findNodeContent(oXmlData, "bFound") == "true"){
        //  Set new field values
        aRows = browser.xml.find(oXmlData, "TAjaxResponseRow");
        for(iRow = 0; iRow < aRows.length; iRow++){
            oDataSet = new VdfDataSet(this, aRows[iRow]);
            this.aTables[sTable].setValues(oDataSet, true, !sName.contains("_NoConstrained"), true, !this.aTables[sTable].isForeign(this.sMainTable));
        }
        
        
        //  Set focus to the first field of this table
        if(sName.contains("_NoFocus")){
            this.returnToField();
        }else{
            this.returnToField(sTable);
        }
    }else{
        //  Give error if needed
        
		if(!sName.contains("_NoWarning")){
			//throw new VdfError(133, "Not found", null, null, this, this);
			bResult = false;
		}
        
		this.returnToField();
    }
    
    //  Initiate user event
    this.onAfterFind(this, sTable, "", bResult, true);
    
    return bResult;
    
}

//
//  Is called when a responseset for this form of a save request is received. It
//  generates a dataset from the responsrows and sets the values using the 
//  recursive setValues method of the VdfTable. The global bSaveResult property 
//  is set to true so the save method can return true if the save was 
//  succesfull.
//
//  Params:
//
//  Param:
//      oXmlData    The xml response data
//      sName       The name of the Request / Response set
//  Returns:
//      True if successfully handled (false if errors occurred)
//
//  PRIVATE
VdfForm.prototype.handleSave = function(oXmlData, sName){
    var oXmlRow, bResult = true, sMainTable;

    sMainTable = browser.xml.findNodeContent(oXmlData, "sTable");
    
    if(browser.xml.findFirst(oXmlData, "iRows").firstChild.nodeValue > 0){
        oXmlRow = browser.xml.findFirst(oXmlData, "TAjaxResponseRow");
        
        oDataSet = new VdfDataSet(this, oXmlData);
        this.aTables[sMainTable].setValues(oDataSet, true, true, true, true);

        this.bSaveResult = true;
        
        this.returnToField();
    }else{
        bResult = false;
     
        this.returnToField();
    }
    
    //  Initiate user event
    this.onAfterSave(this, sMainTable, bResult);
    
    return bResult;
}

//
//  Is called when a responseset for this form of a clear request is received. 
//  It generates a dataset from the responsrow and sets the values using the 
//  recursive setValues method of the VdfTable. 
//
//  Param:
//      oXmlData    The xml response data
//      sName       The name of the Request / Response set
//  Returns:
//      True if successfully handled (false if errors occurred)
//
//  PRIVATE
VdfForm.prototype.handleClear = function(oXmlData, sName){
    var oXmlRow, bResult = true, oDataSet, sMainTable;
    
    sMainTable = browser.xml.findNodeContent(oXmlData, "sTable");

    if(browser.xml.findFirst(oXmlData, "iRows").firstChild.nodeValue > 0){
        oXmlRow = browser.xml.findFirst(oXmlData, "TAjaxResponseRow");

        oDataSet = new VdfDataSet(this, oXmlData);
        this.aTables[sMainTable].setValues(oDataSet, true, true, true, !this.aTables[sMainTable].isForeign(this.sMainTable));
        
        //  Set focus to the first field
        if(sName.contains("_NoFocus")){
            this.returnToField();
        }else{
            this.returnToFirstField();
        }
    }else{
        bResult = false;
        this.returnToField();
    }
    
    //  Initiate user event
    this.onAfterClear(this, sMainTable, bResult);
    
    return bResult;
}

//
//  Is called when a responseset for this form of a clear request is received. 
//  It generates a dataset from the responsrow and sets the values using the 
//  recursive setValues method of the VdfTable. It calls the returnToFirstField
//  method if the delete was succesfull.
//
//  Param:
//      oXmlData    The xml response data
//      sName       The name of the Request / Response set
//  Returns:
//      True if successfully handled (false if errors occurred)
//
//  PRIVATE
VdfForm.prototype.handleDelete = function(oXmlData, sName){
    var oXmlRow, oDataSet, bResult = true, sMainTable;
    
    sMainTable = browser.xml.findNodeContent(oXmlData, "sTable");

    if(browser.xml.findFirst(oXmlData, "iRows").firstChild.nodeValue > 0){
        oXmlRow = browser.xml.findFirst(oXmlData, "TAjaxResponseRow");

        oDataSet = new VdfDataSet(this, oXmlData);
        this.aTables[sMainTable].setValues(oDataSet, true, true, true, !this.aTables[sMainTable].isForeign(this.sMainTable));

        this.returnToFirstField();
    }else{
        bResult = false;
        this.returnToField();
    }
    
    //  Initiate user event
    this.onAfterDelete(this, sMainTable, bResult);
    
    return bResult;
}

//
//  Called when lookup should be opened. Loops through aLookupDialogs to find 
//  lookup for the table of the currently selected field.
//
//  Returns:
//      True if lookup is shown
//
VdfForm.prototype.doLookup = function(){
    var bResult = false;
    var bAttachedField = false;
    
    if(this.oLastFocus != null){
        if(typeof(this.oLastFocus.oVdfLookupDialog) == "object"){
            bResult = this.oLastFocus.oVdfLookupDialog.display(this.oLastFocus);
        }else{
            if(typeof(this.aLookupDialogs[this.oLastFocus.sTable]) == "object"){
                bResult = this.aLookupDialogs[this.oLastFocus.sTable].display(this.oLastFocus);
            }
        }
    }
    return bResult;
}




//
//  Generates a requestset using the given properties and the 
//  VdfGlobals.soap.getRequestSet method. If no field values are given it adds
//  all statusfields and the fields of the maintable and its childs.
//
//  Params:
//      sRequestType    Type of request (find/save/delete)
//      iMaxRows        Maximum number of records
//      sTable          Name of the table to perform the action on
//      sColumn         Name of the column to perform the action on
//      sIndex          Index
//      sFindMode       Findmode constant nr
//      sNameExtend     Extension to add to the name
//      sFieldValues    (Optional field values)
//      bNoClear        True if requestset depends on previous(default = false)
//  Returns:
//      String with xml containing the requestset
//
//  PRIVATE
VdfForm.prototype.getRequestSet = function(sRequestType, iMaxRows, sTable, sColumn, sIndex, sFindMode, sNameExtend, sFieldValues, bNoClear){
    var sRequestName = (this.sName + (sNameExtend ? sNameExtend : ""));
    
    if(typeof(sFieldValues) == "undefined" || sFieldValues == null){
        var sFieldValues = this.getCurrentStatusXml();
        sFieldValues += this.aTables[sTable].getDataXml();
    }
    
    if(typeof(bNoClear) == "undefined"){
        var bNoClear = false;
    }

    return VdfGlobals.soap.getRequestSet(sRequestName, sRequestType, sTable, sColumn, sFieldValues, sIndex, sFindMode, iMaxRows, this.getRequestSetUserData(sRequestType, sRequestName), false, "", bNoClear);
}


//
//  Generates xml for the status fields using the VdfGlobals.soap.getVdfFieldXml
//  method.
//
//  Returns:
//      TRequestCol xml for the status fields
//
//  PRIVATE
VdfForm.prototype.getCurrentStatusXml = function(){
    var sField, iChild;
    var sXml = new JStringBuilder();

    for(sField in this.aStatusFields){
        if(this.aStatusFields[sField] != null){
            sXml.append(VdfGlobals.soap.getVdfFieldXml(this.aStatusFields[sField]));
        }
    }

    return sXml.toString();
}

//
//  Params:
//      sName   Full name of the statusfield
//  Returns:
//      Statusfield VdfField object (null if not found)
//
VdfForm.prototype.getStatusField = function(sName){
    return this.aStatusFields[sName.toLowerCase()];
}

//
//  Params:
//      sName   Full name of the statusfield
//      iNumber Number of the field requested (optional)
//  Returns:
//      Field VdfField object (null if not found)
//
VdfForm.prototype.getField = function(sName, iField){
    if(typeof(iField) == "undefined"){
        var iField = 0;
    }

    if(this.aFields[sName.toLowerCase()] != null){
        return this.aFields[sName.toLowerCase()][iField];
    }
    
    return null;
}

//
//  Params:
//      sName   Full name of the user field
//  Returns:
//      Userfield VdfField object (null if not found)
//
VdfForm.prototype.getUserField = function(sName){
    return this.aUserFields[sName.toLowerCase()];
}


//
//  It returns the value of the field attribute. The attribute of the html dom 
//  element if set, else the vdfinfo value and if this is false it uses the 
//  foreign field value.
//
//  Params:
//      oField      VdfField object with field info
//      sAttribute  Name of the attribute
//  Returns:
//      Value of attribute (null if not found)
//
VdfForm.prototype.getVdfFieldAttribute = function(oField, sAttribute){
    var sResult, sForeign, sServerTable;
    
    sServerTable = oField.getServerTable();
    if(sServerTable == null){
        sServerTable = this.sServerTable;
    }
   
    //  Get field attribute
    sResult = oField.getVdfAttribute(sAttribute);
    
    //  Else get from info request
    if(sResult == null){
        sResult = this.oVdfInfo.getColumnProperty(oField.getName(), sAttribute);
        
        //  Properties inheritted from the form
        if(sResult == null){
            switch(sAttribute){
                case "bValidateServer":
                    return this.bValidateServer;
                case "bValidateClient":
                    return this.bValidateClient;
                case "bValidateAdjust":
                    return this.bValidateAdjust;
                case "bValidatePrevent":
                    return this.bValidatePrevent;
            }
        }
        
        //  If result is false return foreign field value (if it has one)
        if(!sResult || sResult == "false"){
            sForeign = "bAutoFind, bAutoFind_GE, bDisplayOnly, bFindReq, bNoEnter, bNoPut, bSkipFound";

            if(sForeign.contains(sAttribute)){
                if(this.aTables[sServerTable]){
                    if(this.aTables[sServerTable].isForeign(this.sMainTable)){
                        sAttribute = "b" + "Foreign_" + sAttribute.substr(1);
                    }
                }
                
                sResult = this.oVdfInfo.getColumnProperty(oField.getName(), sAttribute);
            }
        }
    }
    
    //  Convert string to boolean
    if(sResult == "true"){
        return true;
    }else if(sResult == "false"){
        return false;
    }else{
        return sResult;
    }
}



//
//  Sends an request using the XmlRequest object of the given type containing
//  the given datasets. It adds the sessionkey, target webobject (see 
//  sWebObject property) and the request user data.
//
//  Params:
//      saDataSets  String with xml datasets
//      bASynchronous True if the request should be send ASynchronous
//
//  PRIVATE
VdfForm.prototype.sendRequest = function(saDataSets, bASynchronous, sWebObject){
    var sXml = new JStringBuilder();
    
    if (typeof(sWebObject)=="undefined"){
        sWebObject = this.sWebObject;
    }

    //  Complete request
    sXml.append("<tRequestData>\n");
    sXml.append("<sSessionKey>" + browser.cookie.get("vdfSessionKey") + "</sSessionKey>\n");
    sXml.append("<sWebObject>" + sWebObject + "</sWebObject>\n");
    sXml.append(saDataSets);
    sXml.append("<aUserData>\n");
    sXml.append(this.getRequestUserData());
    sXml.append("</aUserData>\n");
    sXml.append("</tRequestData>\n");

    //  Send request
    oRequest = new comm.XmlRequest(bASynchronous, "Request", sXml.toString(), this.handleRequest, this, this.sWebServiceUrl);
    oRequest.request();
}

//
//  Is called by the request object when the request is finished. (overloads
//  XmlRequest.onFinished method) It makes sure (using sRequestType and sName)
//  that the correct function & object (parent or one of the childs) handles
//  the request.
//
//  Param:
//      oRequest    The request object
//
//  PRIVATE
VdfForm.prototype.handleRequest = function(oRequest){
    var oResult, bResult = true, oSource = null, aResponseSets, aErrors, sName, iSet; 
    var iError, iChild, aUserDataSets;
    var sName, sNextName, sTempName;
    var sType, sNextType;

    if(oRequest.iError == 0){
        oResult = oRequest.getResponseXml();

        aErrors = browser.xml.find(oResult, "TAjaxError");
        if(aErrors.length > 0){            
            for(iError = 0; iError < aErrors.length; iError++){
                throw new VdfServerError(aErrors[iError], this, this);
            }
        }else{   
            aResponseSets = browser.xml.find(oResult, "TAjaxResponseSet");

            //  Loop through responsesets
            for(iSet = 0; iSet < aResponseSets.length && bResult; iSet++){
                sName = browser.xml.findNodeContent(aResponseSets[iSet], "sName");
				sType = browser.xml.findNodeContent(aResponseSets[iSet], "sResponseType");
				if (iSet < aResponseSets.length - 1){
				    sNextName = browser.xml.findNodeContent(aResponseSets[iSet+1], "sName");
				    sNextType = browser.xml.findNodeContent(aResponseSets[iSet+1], "sResponseType");
				}
				
                //  Find source of requestset
                if(sName.contains(this.sName)){
                    oSource = this;
                }else{
                    for(iChild = 0; iChild < this.aVdfChilds.length; iChild++){
                        if(sName.contains(this.aVdfChilds[iChild].sName)){
                            oSource = this.aVdfChilds[iChild];
                        }
                    }
                    
                    if(oSource == null){
                        for(sTempName in this.aFields){
                            if(sName.contains(sTempName)){
                                oSource = this.aFields[sTempName][0];
                                break;
                            }
                        }
                        
                        if(oSource == null){
                            for(sTempName in this.aUserFields){
                                if(sName.contains(sTempName) && sTempName != ""){
                                    oSource = this.aUserFields[sTempName];
                                    break;
                                }
                            }
                        }
                    }
                }

                //  Call source to handle result
                if(sType == "findByField"){
                    bResult = oSource.handleFindByField(aResponseSets[iSet], sName);
                }else if(sType == "find"){
                    bResult = oSource.handleFind(aResponseSets[iSet], sName);
                }else if(sType == "findByRowId"){
                    bResult = oSource.handleFindByRowId(aResponseSets[iSet], sName);
                }else if(sType == "save"){
                    bResult = oSource.handleSave(aResponseSets[iSet], sName);
                }else if(sType == "delete"){
                    bResult = oSource.handleDelete(aResponseSets[iSet], sName);
                }else if(sType == "clear"){
                    bResult = oSource.handleClear(aResponseSets[iSet], sName);
                }

                this.handleRequestSetUserData(browser.xml.findFirst(aResponseSets[iSet], "aUserData"), sType, sName);
            }
            aUserDataSets = browser.xml.find(oResult, "aUserData");
            this.handleRequestUserData(aUserDataSets[aUserDataSets.length - 1]);
        }
    }else{
        throw new VdfRequestError(oRequest.iError, oRequest.sErrorMessage, this, this);
    }
}

//
//  Is calles to handle keyactions using the given event information. It 
//  executes the action that belongs to the keyaction.
//
//  Params:
//      iKeyCode    Keycode of the pressed key
//      iCharCode   Code of the char that belongs to the key
//      bCrtl       True if control (ctrl) is down
//      bShift      True if shift key is down
//      bAlt        True if alt key is down
//  Returns:
//      True if an action is executed
//
//  PRIVATE
VdfForm.prototype.keyAction = function(iKeyCode, iCharCode, bCrtl, bShift, bAlt){
    var bResult = false;

    if(this.bAttachVdfKeyActions){
        if(!bCrtl && !bShift && !bAlt){
            switch(iKeyCode){
                case this.aActionKeys["findGT"]:   // F8:  find next
                    this.doFind(dfGT);
                    bResult = true;
                    break;
                case this.aActionKeys["findLT"]:   // F7:  find previous
                    this.doFind(dfLT);
                    bResult = true;
                    break;
                case this.aActionKeys["findGE"]:   // F9:  find equal
                    this.doFind(dfGE);
                    bResult = true;
                    break;
                case this.aActionKeys["save"]:   // F2:  save
                    this.doSave();
                    bResult = true;
                    break;
                case this.aActionKeys["clear"]:   // F5:  clear
                    this.doClear();
                    bResult = true;
                    break;
                case this.aActionKeys["lookup"]:   // F4:  lookup
                    bResult = this.doLookup();
                    break;
                case 13:
                    bResult = this.onEnter();
                    break;
            }
        }else if(bCrtl && !bShift && !bAlt){
            switch(iKeyCode){
                case this.aActionKeys["findFirst"]:    // ctrl - home: find first
                    this.doFind(dfFirst);
                    bResult = true;
                    break;
                case this.aActionKeys["findLast"]:    // ctrl - end:  find last
                    this.doFind(dfLast);
                    bResult = true;
                    break;
            }
        }else if(!bCrtl && bShift && !bAlt){
            switch(iKeyCode){
                case this.aActionKeys["remove"]:   // shift - F2:  delete
                    this.doDelete();
                    bResult = true;
                    break;
            }
        }
    }

    return bResult;
}



//
//  Returns the focus to the last selected field (if known) otherwise selects 
//  the first field.
//
//  Params:
//      sTable  (Optional) Restricts to a table
//
VdfForm.prototype.returnToField = function(sTable){
    var sField;
    
    if(typeof(sTable) != "undefined"){  //  Return focus to a table field
        if(this.oLastFocus != null && this.oLastFocus.getTableName() == sTable){
            this.oLastFocus.focusSelect();
        }else{
            for(sField in this.aFields){
                if(this.aFields[sField][0].getTableName() == sTable && this.aFields[sField][0].sType != "hidden"){
                    this.aFields[sField][0].focusSelect();
                    this.oLastFocus = this.aFields[sField][0];
                    break;
                }
            }
        }
    }else{  //  Return focus to the last or a table field
        if(this.oLastFocus != null){
            this.oLastFocus.focusSelect();
        }else{
            this.returnToFirstField();
        }
    }
}

//
//  Gives the focus to the first field or the field with the vdfFocus property
//
VdfForm.prototype.returnToFirstField = function(){
    var sField, iField, oField, bFirst = true;
    
    if(this.oVdfActiveObject == this){ 
        for(sField in this.aFields){
            for(iField in this.aFields[sField]){
                oField = this.aFields[sField][iField];
                
                //  If first field or focus attribute is set give the focus
                if((bFirst && oField.sType != "hidden") || oField.getAttribute("bFocus") == "true"){
                    oField.focusSelect();
                    
                    if(this.oLastFocus != oField){
                        if(this.oPreviousFocus != this.oLastFocus){
                            this.oPreviousFocus = this.oLastFocus;
                        }
                        this.oLastFocus = oField;
                    }
                    bFirst = false;
                }
            }
        }
    }
}

//
//  Fetches user data by adding the fields in aUserFields and calling the user
//  defined onRequestUserData method.
//
//  Returns:
//      String with user data xml.
//
//  PRIVATE
VdfForm.prototype.getRequestUserData = function(){
    var sUserField;
    var sXml = new JStringBuilder();
    
    for(sUserField in this.aUserFields){
        sXml.append(VdfGlobals.soap.getUserData(this.aUserFields[sUserField].getName(), this.aUserFields[sUserField].getValue()));
    }
    
    sXml.append(this.onRequestUserData());
    return sXml.toString();
}             

//
//  Fetches user data for the requestset by calling the onRequestSetUserData 
//  method.
//  
//  Params:
//      sRequestType    Type of request (find/save/clear/delete...)
//      sRequestName    Name of request
//  Returns:
//      String with user data xml
//
//  PRIVATE
VdfForm.prototype.getRequestSetUserData = function(sRequestType, sRequestName){
    return this.onRequestSetUserData(sRequestType, sRequestName);
}

//
//  Called when the request is finished and handled. Parses the user data and
//  updates the userfields where needed. Then it calls the user defined 
//  onRequestFinished method.
//
//  Params:
//      oUserDataXml    Xml node with user data
//
//  PRIVATE
VdfForm.prototype.handleRequestUserData = function(oUserDataXml){
    var aUserData = this.parseUserData(oUserDataXml);
    
    for(sVar in aUserData){
        if(this.aUserFields[sVar] != null){
            this.aUserFields[sVar].setValue(aUserData[sVar]);
        }
    }
    
    this.onRequestFinished(aUserData);
}

//
//  Called when an requestset is finished and handled. Parses the user data and
//  calls the user defined onRequestSetFinished.
//
//  Params:
//      oUserDataXml    Xml node with user data
//      sRequestType    Type of request (find/save/clear/delete...)
//      sRequestName    Name of request
//
//  PRIVATE
VdfForm.prototype.handleRequestSetUserData = function(oUserDataXml, sRequestType, sRequestName){
    var aUserData = this.parseUserData(oUserDataXml);
    
    this.onRequestSetFinished(aUserData, sRequestType, sRequestName);
}

//
//  Parses xml node with user data into array with name value pairs.
//
//  Params:
//      oUserDataXml    Xml node with user data
//  Returns:
//      Array with user data pairs
//
//  PRIVATE
VdfForm.prototype.parseUserData = function(oUserDataXml){
    var aPairs, iPair, aUserData = new Object();
    
    aPairs = browser.xml.find(oUserDataXml, "TAjaxUserData");
    for(iPair = 0; iPair < aPairs.length; iPair++){
        aUserData[browser.xml.findNodeContent(aPairs[iPair], "sName")] = browser.xml.findNodeContent(aPairs[iPair], "sValue");
    }
    
    return aUserData;
}


//
//  Catches the onfocus event of the standart input elements of the form
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfForm.prototype.onFieldFocus = function(e){
    var oSource, oForm, oField = null;

    if(!browser.events.canceled(e)){
        try{
        oSource = browser.events.getTarget(e);
        if(oSource == null) return false;

        oField = oSource.oVdfField;
        if(oField == null) return false;
                
        oForm = oField.oVdfForm;
            
        oForm.oVdfActiveObject = oForm;
            
                  
        if(oField != null){
            if(oForm.oPreviousFocus != oForm.oLastFocus){
                oForm.oPreviousFocus = oForm.oLastFocus;
            }
            oForm.oLastFocus = oField;
        }
        }catch(oError){
            VdfErrorHandle(oError);
        }
    }
}

//
//  Catches the keypress event of the standart input elements of the form and
//  then calls the method according to the pressed key.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfForm.prototype.onFieldKeyPress = function(e){
    var oSource, oForm;

    if(!browser.events.canceled(e)){
        try{
            oSource = browser.events.getTarget(e);
            if(oSource == null) return false;
            
            if(oSource.oVdfField != null){
                oForm = oSource.oVdfField.oVdfForm;
            }
            
            if(oForm == null){
                oForm = findForm(oSource);
                if(oForm == null) return false;
            }
            
            if(oForm.keyAction(browser.events.getKeyCode(e), browser.events.getCharCode(e), e.ctrlKey, e.shiftKey, e.altKey)){
                browser.events.stop(e);
                return false;
            }
        }catch(oError){
            VdfErrorHandle(oError);
        }
    }
    
    return true;
}


//
//  Catches the change event of status fields that aren't hidden and calls the 
//  findByRowId method.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfForm.prototype.onStatusFieldChange = function(e){
    var oSource, oForm;

    if(!browser.events.canceled(e)){
        try{
            oSource = browser.events.getTarget(e);
            if(oSource == null) return false;
            
            oForm = findForm(oSource);
            if(oForm == null) return false;
            
            oField = oForm.aStatusFields[oSource.name.toLowerCase()];
            
            if(oField != null){
                oForm.doFindByRowId(oField.getTableName(), oField.getValue());
            }
        }catch(oError){
            VdfErrorHandle(oError);
        }
    }
        
}




//  - - - - - - - USER EVENTS - - - - - - - -


//
//  Are called before and after user actions
//
//  Overloading can be done in asp file like:
//
//  function initForm(){
//      getVdfControl("form").onBeforeFind = function(oVdfForm, sTable, sField, bFindByRowId, sFindMode){
//          alert("A find well be performed on form: " + oVdfForm.sName + " on table: " + sTable);
//      }
//  }
//
//  The onBefore functions can be used to cancel the event by returning false as value;


//
//  Is called when enter is pressed or a child event (like doubleclick in
//  DbList). If true is returned the event will be killed and no other
//  handling is possible.
//
//  Returns:
//      True if an action is done
//
VdfForm.prototype.onEnter = function(){
    return false;
}

//
//  Is called before an request is send to give developer an change to add his 
//  own data. Should be overloaded and return userdat (use 
//  VdfGlobals.soap.getUserData to generate userdata xml) (should be overloaded)
//
//  Returns:
//      User data xml
//
VdfForm.prototype.onRequestUserData = function(){
    return "";
}

//
//  Is called begore anr equest is send for each requestset to give the 
//  developer an change to add his own requestset data. (use 
//  VdfGlobals.soap.getUserData to generate userdata xml) (should be overloaded)
//
//  Params:
//      sRequestType    Type of request (find/save/delete/clear..)
//      sRequestName    Name of request
//  Returns:
//      User data xml
//
VdfForm.prototype.onRequestSetUserData = function(sRequestType, sRequestName){
    return "";
}

//
//  Is called when the request is finished and the response is handled. Gives
//  the developer an chance to handle the returned user data. (should be 
//  overloaded)
//
//  Params:
//      aUserData   Array with user data aUserData[<name>] == <value>
//
VdfForm.prototype.onRequestFinished = function(aUserData){
    
}

//
//  Is called after each requestset that is handled giving the developer an 
//  change to handler the returned user data. (should be overloaded)
//
//  Params:
//      aUserData       Array with user data aUserData[<name>] == <value>
//      sRequestType    Type of request (find/save/delete/clear..)
//      sRequestName    Name of request
//
VdfForm.prototype.onRequestSetFinished = function(aUserData, sRequestType, sRequestName){
    
}


VdfForm.prototype.onBeforeFind = function(oVdfForm, sTable, sColumn, bFindByRowId, sFindMode){}

VdfForm.prototype.onAfterFind = function(oVdfForm, sTable, sColumn, bFound, bFindByRowId){}

VdfForm.prototype.onBeforeClear = function(oVdfForm, sTable){}

VdfForm.prototype.onAfterClear = function(oVdfForm, sTable, bSuccess){}

VdfForm.prototype.onBeforeDelete = function(oVdfForm, sTable){}

VdfForm.prototype.onAfterDelete = function(oVdfForm, sTable, bSuccess){}

VdfForm.prototype.onBeforeSave = function(oVdfForm, sTable){}

VdfForm.prototype.onAfterSave = function(oVdfForm, sTable, bSuccess){}
