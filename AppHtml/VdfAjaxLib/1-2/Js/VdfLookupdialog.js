//
//  Class:
//      VdfLookupdialog
//
//  This class is a wrapper for lookups. It represents a lookup attachment to an
//  VdfForm. It has several properties for lookups (dialog size, filename, 
//  lookuptable autodisplay (f4)). It is also able to generate a complete lookup
//  using just the tablename and column list.
//
//  Since:
//      02-01-2007
//  Changed:
//      --
//  Version:
//      0.1
//  Creator:
//      Data Access Europe (Harm Wibier)
//

var oLookupForm;    //  Contains form when dialog is opened

//
//  Opens a medium dialog with and opens the sFile in it with the rowid 
//  attribute.
//
//  Params:
//      oForm   VdfForm object that opens the lookup
//      sTable  Name of the main table for the lookup
//      sFile   Filename of the lookup
//      iWidth  Width in pixels of the dialog to open
//      iHeight Height in pixels of the dialog to open
//
function PopLookup(oForm, sTable, sFile, iWidth, iHeight, sTitle, sContainer){
    var sUrl = sFile + "?rowid=" + oForm.getStatusField(sTable + '__rowid').getValue();
    
    PopLookupByUrl(oForm, sUrl, iWidth, iHeight, sTitle, sContainer);
}

//
//  Opens a medium dialog and opens the sFile with the index and value 
//  attributes.
//
//  Params:
//      oForm   VdfForm used for the find when the lookup is closed
//      sIndex  Index selected in the lookup
//      sValue  Value used for initial find
//      sFile   Filename of the lookup
//      iWidth  Width in pixels of the dialog to open
//      iHeight Height in pixels of the dialog to open
//
function PopLookupByField(oForm, oField, sFile, iWidth, iHeight, sTitle, sContainer){
    var sUrl = sFile + "?index=" + oForm.getVdfFieldAttribute(oField, "iIndex") + "&field=" + oField.sDataBinding + "&value=" + oField.getValue();
    
    PopLookupByUrl(oForm, sUrl, iWidth, iHeight, sTitle, sContainer);
}

//
//  Opens a lookup dialog with the given url.
//
//  Params:
//      oForm   VdfForm used for the find when the lookup is closed
//      sUrl    Url to open
//      iWidth  Width in pixels of the dialog to open
//      iHeight Height in pixels of the dialog to open
//
//  PRIVATE
function PopLookupByUrl(oForm, sUrl, iWidth, iHeight, sTitle, sContainer){
    oLookupForm = oForm;

    var oDialog = new JModalDialog(iWidth, iHeight);
    oDialog.sTitle = sTitle;
    oDialog.sContainer = sContainer;
    oDialog.showPage(sUrl);
}

//
//  Lets the form find the selected record and closes the lookup.
//
//  Params:
//      oForm   VdfForm object of the lookup
//      sTable  Maintable of the lookup
//
function HandleLookup(oForm, sTable){   
    var oLookupDialog, iField, sValue;
    oLookupDialog = window.top.oLookupForm.aLookupDialogs[sTable];
    
    //  If attached fields are defined these values are transferred manually without a find
    if(oLookupDialog.aAttachedFields.length > 0){
        //  Walk through the attached fields and transfer their values manually to the openerform
        for(iField = 0; iField < oLookupDialog.aAttachedFields.length; iField++){
            if(oLookupDialog.oVdfForm.aFields[oLookupDialog.aAttachedFields[iField]] != null){
                sValue = oLookupDialog.oVdfLookup.getSelectedValue(this.aLookupFields[iField]);
                if(sValue != null){
                    for(iFieldNum = 0; iFieldNum < oLookupDialog.oVdfForm.aFields[this.aAttachedFields[iField]].length; iFieldNum++){
                        oLookupDialog.oVdfForm.aFields[this.aAttachedFields[iField]][iFieldNum].setValue(sValue);
                    }
                }
            }else if(this.oVdfForm.aUserFields[oLookupDialog.aAttachedFields[iField]] != null){
                sValue = oLookupDialog.oVdfLookup.getSelectedValue(oLookupDialog.aLookupFields[iField]);
                if(sValue != null){
                    oLookupDialog.oVdfForm.aUserFields[oLookupDialog.aAttachedFields[iField]].setValue(sValue);
                }
            }
        }
    }else{
        //  To prefent the FireFox NS_ERROR_NOT_AVAILABLE (0x80040111) error from 
        //  happening we do a litle timeout trick to start a new thread from the 
        //  top window. (The error occurs if an AJAX call is made from a context 
        //  that is killed later on and for some reason the context is determined 
        //  by where the thread is started from)
        window.top.sLookupTable = sTable.toLowerCase();
        window.top.sLookupRowId = oForm.getStatusField(sTable.toLowerCase() + '__rowid').getValue();
        window.top.setTimeout(window.top.HandleLookupFind, 50);   
    }
    
    window.top.JModalDialog_Hide();
}

//
//  Used by the HandleLookup to perform the find on the openening form in the 
//  right "context" to prefent errors from occuring.
//
function HandleLookupFind(){
    window.oLookupForm.doFindByRowId(window.sLookupTable, window.sLookupRowId);
    window.oLookupForm = null;
    window.sLookupTable = null;
    window.sLookupRowId = null;
}

//
//  Closes the modal dialog of the lookup.
//
function CloseLookup(){
    window.top.JModalDialog_Hide();
}



//
//  Constructor: initializes the properties of the object.
//
//  Params:
//      oElement    Html buttom input element
//      oVdfForm    Form to which the lookupdialog belongs
//
function VdfLookupdialog(oElement, oVdfForm){   
    var iField;

    this.oVdfForm       = oVdfForm;
    this.oInput         = oElement;
    oElement.oVdfLookupdialog = this;

    //  Properties
    this.sName          = browser.dom.getVdfAttribute(this.oInput, "sControlName", "vdflookupdialog1");
    this.sControlType   = browser.dom.getVdfAttribute(this.oInput, "sControlType", "lookupdialg");
    this.sLookupTable   = browser.dom.getVdfAttribute(this.oInput, "sLookupTable", null);
    this.iDialogWidth   = parseInt(browser.dom.getVdfAttribute(this.oInput, "iDialogWidth", 0));
    this.iDialogHeight  = parseInt(browser.dom.getVdfAttribute(this.oInput, "iDialogHeight", 0));
    this.bAttachKey     = browser.dom.getVdfAttribute(this.oInput, "bAttachKey", true);
    
    this.sLookupFile    = browser.dom.getVdfAttribute(this.oInput, "sLookupFile", null);
    
    this.sWebObject     = browser.dom.getVdfAttribute(this.oInput, "sWebObject", this.oVdfForm.sWebObject);
    this.sWebServiceUrl = browser.dom.getVdfAttribute(this.oInput, "sWebServiceUrl", this.oVdfForm.sWebServiceUrl);
    this.iRowLength     = browser.dom.getVdfAttribute(this.oInput, "iRowLength", 10);
    this.sAttachedFields= browser.dom.getVdfAttribute(this.oInput, "sAttachedFields", null);
    this.sLookupFields  = browser.dom.getVdfAttribute(this.oInput, "sLookupFields", null);

    this.sTitle         = browser.dom.getVdfAttribute(this.oInput, "sTitle", "Lookup");
    this.sContainer     = browser.dom.getVdfAttribute(this.oInput, "sContainer", "");

    if(this.sLookupTable != null){
        this.sLookupTable = this.sLookupTable.toLowerCase();
    }
    
    if(this.sAttachedFields != null){
        this.aAttachedFields = this.sAttachedFields.split(",");
        for(iField = 0; iField < this.aAttachedFields.length; iField++){
            this.aAttachedFields[iField] = browser.data.trim(this.aAttachedFields[iField].toLowerCase());
        }
    }else{
        this.aAttachedFields = new Array();
    }
    
    if(this.sLookupFields != null){
        this.aLookupFields = this.sLookupFields.split(",");
        for(iField = 0; iField < this.aLookupFields.length; iField++){
            this.aLookupFields[iField] = browser.data.trim(this.aLookupFields[iField].toLowerCase());
        }
    }else{
        this.aLookupFields = new Array();
    }
}

//
//  Called by the form to initialize the element. It adds itself to the lookup 
//  array of the form and attaches the events.
//
//  PRIVATE
VdfLookupdialog.prototype.initAfter = function(){
    var iField, iNumField;

    if(this.bAttachKey && this.sLookupTable != null){
        this.oVdfForm.aLookupDialogs[this.sLookupTable] = this;
    }
    
    //  Attach onto attached fields (override old attachments)
    for(iField = 0; iField < this.aAttachedFields.length; iField++){
        if(this.oVdfForm.aFields[this.aAttachedFields[iField]] != null){
            for(iNumField = 0; iNumField < this.oVdfForm.aFields[this.aAttachedFields[iField]].length; iNumField++){
                this.oVdfForm.aFields[this.aAttachedFields[iField]][iNumField].oVdfLookupDialog = this;
            }
        }else if(this.oVdfForm.aUserFields[this.aAttachedFields[iField]] != null){
            this.oVdfForm.aUserFields[this.aAttachedFields[iField]].oVdfLookupDialog = this;
        }
    }
    
    //  Attach onto lookup columns (only if no lookup is attached)
    for(iField = 0; iField < this.aLookupFields.length; iField++){
        if(this.oVdfForm.aFields[this.aLookupFields[iField]] != null){
            for(iNumField = 0; iNumField < this.oVdfForm.aFields[this.aLookupFields[iField]].length; iNumField++){
                if(typeof(this.oVdfForm.aFields[this.aLookupFields[iField]][iNumField].oVdfLookupDialog) != "object"){
                    this.oVdfForm.aFields[this.aLookupFields[iField]][iNumField].oVdfLookupDialog = this;
                }
            }
        }
    }
    
    browser.events.addGenericListener("click", this.oInput, this.onButtonClick);
}

//
//  Displays the lookup, switches between file and generated version. If field 
//  is given without index no lookup is displayed.
//
//  Params:
//      oVdfOpenerField     Field from which the lookup is opened (optional)
//  Returns:
//      True if the lookup is dispayed
//
VdfLookupdialog.prototype.display = function(oVdfOpenerField){
    var bDisplay = false, sIndex;

    //  Check if lookup should be displayed (only when no field is given or field belongs to index on the lookuptable)
    if(oVdfOpenerField != null){
        sIndex = this.oVdfForm.getVdfFieldAttribute(oVdfOpenerField, "iIndex");
        
        if(sIndex != "" && sIndex != "0"){
            bDisplay = true;
        }
    }else{
        //  If using vdfAttachedFields a OpenerField is required
        if (this.aAttachedFields.length > 0){   
            oVdfOpenerField = this.oVdfForm.getField(this.aAttachedFields[0]);
            if(oVdfOpenerField == null){
                oVdfOpenerField = this.oVdfForm.aUserFields[this.aAttachedFields[0]];
            }
        }
        bDisplay = true;
    }

    //  Switch between the generated and the file lookup
    if(bDisplay){
        if(this.sLookupFile == null){
            this.displayGenerated(oVdfOpenerField);
        }else{
            this.displayFile(oVdfOpenerField);
        }
    }
    
    return bDisplay;
}

//
//  Displays a file lookup (modal dialog with iframe). It switches between the 
//  rowid and the index version according to the given openenfield.
//
//  Params:
//      oVdfOpenerField     Field from which the lookup is opened (optional)
//
VdfLookupdialog.prototype.displayFile = function(oVdfOpenerField){
    var iWidth = this.iDialogWidth, iHeight = this.iDialogHeight;

    //  File lookup requires pixelsize!
    if(iWidth < 1){
        iWidth = 650;
    }
    if(iHeight < 1){
        iHeight = 260;
    }
    
    //  Switch between fillbyrowid or by value find
    if(oVdfOpenerField != null){
        PopLookupByField(this.oVdfForm, oVdfOpenerField, this.sLookupFile, iWidth, iHeight, this.sTitle, this.sContainer);
    }else{
        PopLookup(this.oVdfForm, this.sLookupTable, this.sLookupFile, iWidth, iHeight, this.sTitle, this.sContainer);
    }
}

//
//  Displays a generated lookup (modal dialog with div). It calls the 
//  initialisation methods after each other.
//
//  Params:
//      oVdfOpenerField Field from which the lookup is opened (optional)
//
VdfLookupdialog.prototype.displayGenerated = function(oVdfOpenerField){
    var oDialogDiv, oDialogForm;
    
    //  Check if fields given, else call method for default fields
    if(this.aLookupFields.length == 0){
        this.determineDefaultFields();
    }
    
    //  Generate JModalDialog
    oDialogDiv = this.generateDialog();
    
    //  Generate the form
    this.generateForm(oDialogDiv, oVdfOpenerField);
    
    //  Position the modal dialog
    this.oJModalDialog.positionDialog(true);
    
    //  Do the correct find
    this.initForm(oVdfOpenerField);
}

//
//  Determines the default fields for the lookup by fetching al table fields and
//  filtering the indexed fields.
//
//  PRIVATE
VdfLookupdialog.prototype.determineDefaultFields = function(){
    var aFields, iField, iIndex;
    
    aFields = this.oVdfForm.oVdfInfo.getTableColumns(this.sLookupTable);
    
    for(iField = 0; iField < aFields.length; iField++){
        iIndex = this.oVdfForm.oVdfInfo.getColumnProperty(this.sLookupTable + "__" + aFields[iField], "iIndex");
        if(iIndex != null && iIndex != "0"){
            this.aLookupFields[this.aLookupFields.length] = this.sLookupTable + "__" + aFields[iField];
        }
    }
    
}

//
//  Creates the modal dialog and returns the div in which the lookup should be 
//  created.
//
//  Returns:
//      Html dom div element in which the content of the dialog should be added.
//
//  PRIVATE
VdfLookupdialog.prototype.generateDialog = function(){
    //  Create dialog
    this.oJModalDialog = new JModalDialog(this.iDialogWidth, this.iDialogHeight);
    this.oJModalDialog.sTitle = this.sTitle;
    this.oJModalDialog.sContainer = this.sContainer;
    
    //  Init custom dialog and return div
    return this.oJModalDialog.customDialog();
}

//
//  Generates the objects needed for the form and adds them to the DOM. Also
//  creates the vdf objects needed.
//
//  Params:
//      oParentDiv      Div element in which the lookup is created
//      oVdfOpenerField Field from which the lookup is opened (optional)
//
//  PRIVATE
VdfLookupdialog.prototype.generateForm = function(oParentDiv, oVdfOpenerField){
    var oDomForm, oDomTable, oHeaderRow, oDisplayRow, iField, oCell, oDivControls, oInputSearch, oInputCancel, oInputSelect;
    var oInputUserField, sUserField
    
    //  Form
    oDomForm = document.createElement("form");
    oDomForm.autocomplete = "off";
    oDomForm.setAttribute("vdfControlType", "form");
    oDomForm.setAttribute("vdfControlName", this.sLookupTable + "_lookup_form");
    oDomForm.setAttribute("vdfMainTable", this.sLookupTable);
    oDomForm.setAttribute("vdfServerTable", this.sLookupTable);
    oDomForm.setAttribute("vdfWebObject", this.sWebObject);
    oDomForm.setAttribute("vdfWebServiceUrl", this.sWebServiceUrl);
    oDomForm.setAttribute("vdfAutoFill", "false");
    oParentDiv.appendChild(oDomForm);
    
    //  Lookup
    oDomTable = document.createElement("table");
    oDomTable.className = "VdfLookup";
    oDomTable.setAttribute("vdfControlType", "lookup");
    oDomTable.setAttribute("vdfControlName", this.sLookupTable + "_lookup");
    oDomTable.setAttribute("vdfMainTable", this.sLookupTable);
    oDomTable.setAttribute("vdfRowLength", this.iRowLength);
    oDomTable.setAttribute("vdfFocus", "true");
    oDomTable.setAttribute("vdfAutoLabel", "true");
    oDomTable.setAttribute("vdfFixedColumnWidth", "true")
    if(oVdfOpenerField != null && this.sAttachedFields == null){
        oDomTable.setAttribute("vdfIndex", this.oVdfForm.getVdfFieldAttribute(oVdfOpenerField, "iIndex"));
    }
    oDomForm.appendChild(oDomTable);
    
    //  Rows
    oHeaderRow = oDomTable.insertRow(0);
    oHeaderRow.setAttribute("vdfRowType", "header");
    oDisplayRow = oDomTable.insertRow(1);
    oDisplayRow.setAttribute("vdfRowType", "display");
    
    for(iField = 0; iField < this.aLookupFields.length; iField++){
        oCell = document.createElement("th");
        oCell.setAttribute("vdfDataBinding", this.aLookupFields[iField]);
        browser.dom.setCellText(oCell, this.aLookupFields[iField]);
        oHeaderRow.appendChild(oCell);
        
        oCell = oDisplayRow.insertCell(iField);
        oCell.setAttribute("vdfDataBinding", this.aLookupFields[iField]);
        oCell.innertHtml = "&nbsp;";
    }
    
    //  Div with the buttons
    oDivControls = document.createElement("div");
    oDivControls.style.clear = "both";
    oDivControls.className = "VdfLookupdialogControls";
    oDomForm.appendChild(oDivControls);
    
    oInputSelect = document.createElement("input");
    oInputSelect.type = "button";
    oInputSelect.value = "Select";
    oInputSelect.style.margin = "3px";
    oInputSelect.className = "ButtonNormal";
    oDivControls.appendChild(oInputSelect);
    
    oInputCancel = document.createElement("input");
    oInputCancel.type = "button";
    oInputCancel.value = "Cancel";
    oInputCancel.style.margin = "3px";
    oInputCancel.className = "ButtonNormal";
    oDivControls.appendChild(oInputCancel); 
    
    oInputSearch = document.createElement("input");
    oInputSearch.type = "button";
    oInputSearch.value = "Search";
    oInputSearch.style.margin = "3px";
    oInputSearch.className = "ButtonNormal";
    oDivControls.appendChild(oInputSearch); 
    
    //  Attach events
    browser.events.addGenericListener("click", oInputSelect, this.onSelectClick);
    browser.events.addGenericListener("click", oInputCancel, this.onCancelClick);
    browser.events.addGenericListener("click", oInputSearch, this.onSearchClick);
    
    
    VdfInitControls(oDomForm, false);    

    //  Save references
    oDomForm.oVdfLookupdialog = this;
    this.oVdfDialogForm = getVdfControl(this.sLookupTable + "_lookup_form");
    this.oVdfLookup = getVdfControl(this.sLookupTable + "_lookup");
    
    //  Copy shared settings
    if(this.oVdfForm){
        for (sUserField in this.oVdfForm.aUserFields){            
            this.oVdfDialogForm.aUserFields[sUserField] = this.oVdfForm.aUserFields[sUserField];
        }
    }
}

//
//  Initializes the form by doing the finds (bAutoFill of form is set to false
//  so no double finds are done).
//
//  Params:
//      oVdfOpenerField Field from which the lookup is opened (optional)
//
//  PRIVATE
VdfLookupdialog.prototype.initForm = function(oVdfOpenerField){
    var oVdfLookupdialog = this;
    
    //  Copy status information
    for (sField in this.oVdfForm.aStatusFields){
        if(this.oVdfDialogForm.getStatusField(sField) && this.oVdfForm.getStatusField(sField)) {
            this.oVdfDialogForm.getStatusField(sField).setValue(this.oVdfForm.getStatusField(sField).getValue(), true);
        }
    }
    
    //  Do find (if field given) or fill (if no or rowid field gfiven)
    if(oVdfOpenerField && oVdfOpenerField.getFieldName() != "rowid"){
        this.oVdfDialogForm.fill();
        
        if(this.aAttachedFields.length > 0){
            for(iField = 0; iField < this.aAttachedFields.length; iField++){
                if(this.aAttachedFields[iField] == oVdfOpenerField.sDataBinding){
                    this.oVdfLookup.findByColumn(oVdfOpenerField.getValue(), this.aLookupFields[iField]);
                    break;
                }
            }
        }else{
            this.oVdfLookup.findByColumn(oVdfOpenerField.getValue(), oVdfOpenerField.sDataBinding);
        }
    }else{
        this.oVdfDialogForm.fill();
    }
    
    //  Attach onEnter (done here to spare memory instead of in generateForm with many local variables)
    this.oVdfDialogForm.onEnter = function(){
        oVdfLookupdialog.finished(true);
        return true;
    }
}

//
//  Handles the results of the generated dialog and hides / removes the dialog.
//
//  Params:
//      bSelectResult   If true the result is given to the opener form (false 
//                      for cancel)
//
VdfLookupdialog.prototype.finished = function(bSelectResult){   
    var iField, sValue, iFieldNum;
    
    if(bSelectResult){
        if (this.onBeforeSelect(this) != false){
    
            if (this.aAttachedFields.length > 0){
                //  Walk throught the attachedfields, fetch the selected lookup value and set the value to all attached form fields
                for(iField = 0; iField < this.aAttachedFields.length; iField++){
                    if(this.oVdfForm.aFields[this.aAttachedFields[iField]] != null){
                        sValue = this.oVdfLookup.getSelectedValue(this.aLookupFields[iField]);
                        if(sValue != null){
                            for(iFieldNum = 0; iFieldNum < this.oVdfForm.aFields[this.aAttachedFields[iField]].length; iFieldNum++){
                                this.oVdfForm.aFields[this.aAttachedFields[iField]][iFieldNum].setValue(sValue);
                            }
                        }
                    }else if(this.oVdfForm.aUserFields[this.aAttachedFields[iField]] != null){
                        sValue = this.oVdfLookup.getSelectedValue(this.aLookupFields[iField]);
                        if(sValue != null){
                            this.oVdfForm.aUserFields[this.aAttachedFields[iField]].setValue(sValue);
                        }
                    }
                }        
            }else{
                //  Perform a find by rowid
                this.oVdfForm.doFindByRowId(this.sLookupTable, this.oVdfDialogForm.getStatusField(this.sLookupTable + '__rowid').getValue());
            }
            
            this.onAfterSelect(this);
        }
    }
    
    this.oVdfDialogForm.oForm.oVdfLookupdialog = null;
    this.oVdfDialogForm = null;
    this.oVdfLookup = null;
    
    this.oJModalDialog.hide();
    this.oJModalDialog = null;
}


//
//  Catches the onclick event of the button that belongs to the dialog and calls
//  the display method.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfLookupdialog.prototype.onButtonClick = function(e){
    try{
        var oVdfLookupdialog, oTarget;
        
        oTarget = browser.events.getTarget(e);
        if(oTarget == null || oTarget.oVdfLookupdialog == null)
            return false;
        
        oVdfLookupdialog = oTarget.oVdfLookupdialog;
        
        oVdfLookupdialog.display();
    }catch(oError){
        VdfErrorHandle(oError);
    }
}


//
//  Fetches the onclick event from the select button and searches the 
//  lookupdialog object and calls the finished method.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfLookupdialog.prototype.onSelectClick = function(e){
    try{
        var oTarget, oVdfLookupdialog;
        
        oTarget = browser.events.getTarget(e);
        if(oTarget == null)
            return false;
            
        oTarget = browser.dom.searchParent(oTarget, "form");
        if(oTarget == null || oTarget.oVdfLookupdialog == null)
            return false;
        
        oVdfLookupdialog = oTarget.oVdfLookupdialog;
        
        oVdfLookupdialog.finished(true);
    }catch(oError){
        VdfErrorHandle(oError);
    }
}

//
//  Fetches the onclick event from the cancel button and searches the 
//  lookupdialog object and calls the finished method.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfLookupdialog.prototype.onCancelClick = function(e){
    try{
        var oTarget, oVdfLookupdialog;

        oTarget = browser.events.getTarget(e);
        if(oTarget == null)
            return false;

        oTarget = browser.dom.searchParent(oTarget, "form");
        if(oTarget == null || oTarget.oVdfLookupdialog == null)
            return false;

        oVdfLookupdialog = oTarget.oVdfLookupdialog;
        
        oVdfLookupdialog.finished(false);
    }catch(oError){
        VdfErrorHandle(oError);
    }
}

//
//  Fetches the onclick event from the search button and searches the 
//  lookupdialog object and calls the jumpIntoListDisplay method of the lookup.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfLookupdialog.prototype.onSearchClick = function(e){
    try{
        var oTarget, oVdfLookupdialog;
        
        oTarget = browser.events.getTarget(e);
        if(oTarget == null)
            return false;
        
        oTarget = browser.dom.searchParent(oTarget, "form");
        if(oTarget == null || oTarget.oVdfLookupdialog == null)
            return false;
        
        oVdfLookupdialog = oTarget.oVdfLookupdialog;
        
        oVdfLookupdialog.oVdfLookup.jumpIntoListDisplay();
    }catch(oError){
        VdfErrorHandle(oError);
    }
}

//  - - - - - - - USER EVENTS - - - - - - - -

//
//  Called before the selected data is found / set on the opening form. Action 
//  can be cancelled by returning false.
//
//  Params:
//      oVdfLookupdialog    Reference toe the VdfLookupdialog
//  Returns:
//      False if action should be cancelled
//
VdfLookupdialog.prototype.onBeforeSelect = function(oVdfLookupdialog){ }

//
//  Called after the data is found / set on the opening form. 
//
//  Params:
//      oVdfLookupdialog    Reference to the VdfLookupdialog
//
VdfLookupdialog.prototype.onAfterSelect = function(oVdfLookupdialog){ }