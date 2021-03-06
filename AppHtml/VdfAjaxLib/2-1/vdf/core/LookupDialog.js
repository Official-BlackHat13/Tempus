/*
Name:
    vdf.core.LookupDialog
Type:
    Prototype
Revisions:
    2007/01/02  Created the initial version. (HW, DAE)
    2008/09/01  Complete rewrite into the 2.0 structure. It now works with the 
    initialization system and works with the DDs and the new ModalDialog. (HW, 
    DAE)
*/

/*
@require    vdf/gui/ModalDialog.js
@require    vdf/deo/Lookup.js
*/

/*
Constructor that applies to the interface required by the initialization system 
(see vdf.core.init).

@param  eElement        Reference to the DOM element.
@param  oParentControl  Reference to the parent control.
*/
vdf.core.LookupDialog = function LookupDialog(eElement, oParentControl){
    var iField, sLookupFields, sAttachedFields, sColumnWidths;

    /*
    Reference to the DOM element.
    */
    this.eElement = eElement;
    /*
    Reference to the parent control.
    */
    this.oParentControl = oParentControl;
    /*
    The name of the control.
    
    @html
    */
    this.sName = vdf.determineName(this, "lookupdialog");
    /*
    Reference to the form.
    */
    this.oForm = null;
    
    /*
    The main table for the lookup.
    */
    this.sLookupTable = this.getVdfAttribute("sLookupTable", null, false);
    /*
    The web object used by the lookup.
    */
    this.sWebObject = this.getVdfAttribute("sWebObject", null, true);
    /*
    The webservice URL used by the lookup.
    */
    this.sWebServiceUrl = this.getVdfAttribute("sWebServiceUrl", "WebService.wso", true);
    /*
    Determines which field receives the focus after a record is selected. If not 
    set the lookup will manually try to determine which field should receive the
    focus.
    */
    this.sFocusField = this.getVdfAttribute("sFocusField", null, false);
    /*
    List with the names / data binding of fields in the opening form. These 
    fields are filled with the values from the selected record in the lookup. 
    The first field is filled with the value from the first column, the second 
    with the second, etc... If it is set from HTML it can be set as a comma 
    separated list. 
    
    @html
    */
    this.aAttachedFields = null;
    /*
    List with databindings of fields that should be displayed in the lookup. If 
    set from HTML it can be set as a comma separated list.
    
    @html
    */
    this.aLookupFields = null;
    /*
    List with the widths of the columns in pixels. If given the bDetermineWidth 
    setting of the list is disabled. If set from HTML the list should be a comma 
    separated list.
    
    @html
    */
    this.aColumnWidths = null;
    /*
    The amount of rows shown in the lookup dialog.
    */
    this.iLength = this.getVdfAttribute("iLength", this.getVdfAttribute("iRowLength", 10, false), true);
    /*
    The title for the lookup dialog.
    */
    this.sTitle = this.getVdfAttribute("sTitle", vdf.lang.getTranslation("lookupdialog", "title", "Lookup"));
    /*
    The CSS class set on the content div of the generated lookup dialog.
    */
    this.sCssContent = this.getVdfAttribute("sCssContent", "lookupdialog", true);
    
    /*
    Fired before the lookup is opened. If this event is stopped the lookup won't 
    be displayed.
    
    @prop   oOpeningField   The field from which the lookup is opened (null if 
                unknown).
    */
    this.onBeforeOpen = new vdf.events.JSHandler();
    /*
    Fired after the lookup is opened. Note that lookup is still filling itself 
    with data asynchronously.
    
    @prop   oOpeningField   The field from which the lookup is opened (null if 
                unknown).
    */
    this.onAfterOpen = new vdf.events.JSHandler();
    /*
    Fired before the lookup dialog is closed. If the event is stopped the dialog 
    won't be closed.
    */
    this.onBeforeClose = new vdf.events.JSHandler();
    /*
    Fired after the dialog is closed.
    */
    this.onAfterClose = new vdf.events.JSHandler();
    /*
    Fired before the findbyrowid is performed on the opening form.
    
    @prop   sRowId  The serialized rowid of the selected record.    
    */
    this.onBeforeSelect = new vdf.events.JSHandler();
    /*
    Fired after the findByRowId is performed on the opening form.
    */
    this.onAfterSelect = new vdf.events.JSHandler();
    
    // @privates
    this.eDiv = null;
    this.oDialog = null;
    this.oLookup = null;
    this.oLookupForm = null;
    this.oSource = null;
    
    
    //  Lowercase stuff
    if(this.sLookupTable !== null){
        this.sLookupTable = this.sLookupTable.toLowerCase();
    }
    
    //  Determine forced attach fields
    sAttachedFields = this.getVdfAttribute("sAttachedFields", null);
    if(sAttachedFields !== null){
        this.aAttachedFields = sAttachedFields.split(",");
        for(iField = 0; iField < this.aAttachedFields.length; iField++){
            this.aAttachedFields[iField] = vdf.sys.string.trim(this.aAttachedFields[iField].toLowerCase());
        }
    }else{
        this.aAttachedFields = [];
    }
    
    //  Determine the lookup fields
    sLookupFields = this.getVdfAttribute("sLookupFields", null);
    if(sLookupFields !== null){
        this.aLookupFields = sLookupFields.split(",");
        for(iField = 0; iField < this.aLookupFields.length; iField++){
            this.aLookupFields[iField] = vdf.sys.string.trim(this.aLookupFields[iField].toLowerCase().replace("__", "."));
        }
    }
    
    sColumnWidths = this.getVdfAttribute("sColumnWidths", null);
    if(sColumnWidths){
        this.aColumnWidths = sColumnWidths.split(",");
    }
    
};
/*
This class contains the functionality to generate a lookup dialog by just giving
a list of field names to define the columns that should be displayed. The 
lookup dialog will be displayed if the element on which it is defined is 
clicked. It also attaches itself to Data Entry Objects that are related so that 
F4 key can be used to open the lookup dialog. The lookup dialog should be used 
inside forms only. The initialization system is able instantiate this class 
using the short-name "lookupdialog" or if the full name "vdf.core.LookupDialog" 
is used. The example below shows how a lookup dialog can be defined.

@code
<input type="button" vdfControlType="lookupdialog" vdfLookupTable="Customer" vdfWebObject="oCustomer" vdfLookupFields="customer__customer_number, customer__name, customer__address" />
@code

*/
vdf.definePrototype("vdf.core.LookupDialog", {

/*
Called by the form to initialize the lookup dialog.
*/
formInit : function(){
    var iField, oField, sIndex, iDeo;
    
    //  Attach to the fields
    for(iDeo = 0; iDeo < this.oForm.aDEOs.length; iDeo++){
        oField = this.oForm.aDEOs[iDeo];
        if(oField.sDataBindingType === "D" && oField.sTable === this.sLookupTable){
            sIndex = oField.getMetaProperty("iIndex");
            if(sIndex !== "" && sIndex > 0){
                if(this.oForm.aDEOs[iDeo].oLookup === null){
                    this.oForm.aDEOs[iDeo].oLookup = this;
                }
            }
        }
    }
    
    //  Attach to the attached fields, overwrite lookups that are already there
    for(iField = 0; iField < this.aAttachedFields.length; iField++){
        oField = this.oForm.getDEO(this.aAttachedFields[iField]);
        if(oField !== null){
            oField.oLookup = this;
        }
    }
    
    vdf.events.addDomListener("click", this.eElement, this.onButtonClick, this);
},

/*
Destroys the element by removing the DOM references. This should prevent 
browsers from leaking memory.
*/
destroy : function(){
    vdf.events.removeDomListener("click", this.eElement, this.onButtonClick);
    this.eElement = null;
    this.eDiv = null;
},

/*
Displays the DOM lookup dialog.

@param  oSource (optional) Reference to the field from which the lookup is 
            opened.
*/
display : function(oSource){
    var oGrid;
    
    if(typeof(oSource) == "undefined"){
        oSource = null;
    }
    this.oSource = oSource;

    if(this.onBeforeOpen.fire(this, { oOpeningField : oSource })){

        //  Cancel the bAutoSaveState save of grids where we are in..
        oGrid = vdf.core.init.findParentControl(this.eElement, "vdf.deo.Grid");
        if(oGrid){
            oGrid.bSkipAutoSave = true;
        }
        
        //  Actually display the dialog
        this.eDiv = this.generateDialog();
        this.generateElements(oSource, this.eDiv);
        
        vdf.onControlCreated.addListener(this.onControlCreated, this);
        vdf.core.init.initializeControls(this.eDiv);
    }
},

/*
@private
*/
onControlCreated : function(oEvent){
    if(oEvent.sPrototype === "vdf.deo.Lookup"){
        this.oLookup = oEvent.oControl;
        this.oLookup.onInitialized.addListener(this.onLookupInitialized, this);
        vdf.onControlCreated.removeListener(this.onControlCreated);
    }
    if(oEvent.sPrototype === "vdf.core.Form"){
        this.oLookupForm = oEvent.oControl;
        
        //  Note: Web Object restriction that is removed in 2.1.1.5
        //if(this.sWebObject === this.oForm.sWebObject){
            this.oLookupForm.oUserDataFields = this.oForm.oUserDataFields;
        //}
    }
},

/*
@private
*/
onLookupInitialized : function(oEvent){
    var iField;

    this.oDialog.calculatePosition();
    this.oLookup.onEnter.addListener(this.onLookupEnter, this);
    
    for(iField = 0; iField < this.aAttachedFields.length; iField++){
        if(this.aAttachedFields[iField] !== ""){
            if(this.oSource === null){
                this.oLookup.findByColumn(this.aLookupFields[iField], this.oForm.getBufferValue(this.aAttachedFields[iField]));
                break;
            }else if(this.oSource.sDataBinding === this.aAttachedFields[iField]){
                this.oLookup.findByColumn(this.aLookupFields[iField], this.oSource.getValue());
                break;
            }
        }
    }
    
    this.onAfterOpen.fire(this, { oOpeningField : this.oSource });
},

/*
@private
*/
generateDialog : function(){
    var oDialog, eDiv;
    
    oDialog = new vdf.gui.ModalDialog();
    oDialog.sTitle = this.sTitle;
    
    oDialog.initializeDialog();

    eDiv = document.createElement("div");
    eDiv.className = this.sCssContent;
    oDialog.eCellContent.appendChild(eDiv);
    
    oDialog.addButton("select", vdf.lang.getTranslation("lookupdialog", "select", "select"), "btnSelect");
    oDialog.addButton("cancel", vdf.lang.getTranslation("lookupdialog", "cancel", "cancel"), "btnCancel");
    oDialog.addButton("search", vdf.lang.getTranslation("lookupdialog", "search", "search"), "btnSearch");
    
    oDialog.onButtonClick.addListener(this.onDialogButtonClick, this);
    oDialog.onBeforeClose.addListener(this.onBeforeDialogClose, this);
    oDialog.onAfterClose.addListener(this.onAfterDialogClose, this);
    
    this.oDialog = oDialog;
    
    return eDiv;
},

/*
@private
*/
generateElements : function(oSource, eDiv){
    var eForm, sDD, oDD, eInput, eTable, sIndex, eHeaderRow, eDisplayRow, eCell, eCellDiv, iField;
    
    //  Form
    eForm = document.createElement("form");
    eDiv.appendChild(eForm);
    eForm.autocomplete = "off";
    eForm.setAttribute("vdfControlType", "form");
    eForm.setAttribute("vdfName", this.sName + "_lookup_form");
    eForm.setAttribute("vdfMainTable", this.sLookupTable);
    eForm.setAttribute("vdfServerTable", this.sLookupTable);
    eForm.setAttribute("vdfWebObject", this.sWebObject);
    eForm.setAttribute("vdfWebServiceUrl", this.sWebServiceUrl);
    // eForm.setAttribute("vdfAutoFill", "false");
    
    //  Generate status fields
    for(sDD in this.oForm.oDDs){
        if(this.oForm.oDDs[sDD].bIsDD){
            //  If the lookup works on a different WO (which can be done but isn't adviced) we only add the lookup table rowid field
            if(this.sWebObject === this.oForm.sWebObject || sDD === this.sLookupTable){
                oDD = this.oForm.oDDs[sDD];
                eInput = document.createElement("input");
                eInput.type = "hidden";
                eInput.setAttribute("vdfDataBinding", oDD.sName + "__rowid");
                eInput.name = oDD.sName + "__rowid_lookup_form";
                eInput.value = (oDD.tStatus.sValue !== null ? oDD.tStatus.sValue : "");
                eForm.appendChild(eInput);
            }
        }
    }
    
    //  Lookup
    eTable = document.createElement("table");
    eForm.appendChild(eTable);
    eTable.className = "VdfLookup";
    eTable.setAttribute("vdfControlType", "lookup");
    eTable.setAttribute("vdfName", this.sName + "_lookup");
    eTable.setAttribute("vdfMainTable", this.sLookupTable);
    eTable.setAttribute("vdfLength", this.iLength);
    eTable.setAttribute("vdfFocus", "false");
    eTable.setAttribute("vdfAutoLabel", "true");
    eTable.setAttribute("vdfFixedColumnWidth", "true");
    if(this.aColumnWidths){
        eTable.setAttribute("vdfDetermineWidth", "false");
    }
    
    sIndex = this.getVdfAttribute("sIndex", "", true);
    if(oSource !== null && oSource.bIsField){
        sIndex = oSource.getMetaProperty("iIndex");
    }
    if(sIndex !== ""){
        eTable.setAttribute("vdfIndex", sIndex);
    }
    
    
    //  Rows
    eHeaderRow = eTable.insertRow(0);
    eHeaderRow.setAttribute("vdfRowType", "header");
    eDisplayRow = eTable.insertRow(1);
    eDisplayRow.setAttribute("vdfRowType", "display");
    
    for(iField = 0; iField < this.aLookupFields.length; iField++){
        eCell = document.createElement("th");
        eCell.setAttribute("vdfDataBinding", this.aLookupFields[iField]);
        
        if(this.aColumnWidths && this.aColumnWidths.length > iField){
            eCell.style.width = parseInt(this.aColumnWidths[iField], 10) + "px";
        }
        
        vdf.sys.dom.setElementText(eCell, this.aLookupFields[iField]);
        eHeaderRow.appendChild(eCell);
        
        eCell = eDisplayRow.insertCell(iField);
        eCellDiv = document.createElement("div");
        eCellDiv.setAttribute("vdfDataBinding", this.aLookupFields[iField]);
        eCellDiv.innertHtml = "&nbsp;";
        eCell.appendChild(eCellDiv);
    }
    
    

},

/*
Sets the selected record to the opening form (by value of using a find by rowid).
*/
finish : function(){
    this.select();
    this.close();
},

/*
Tries to perform a findByRowId on the opening form. If attached fields are set 
it fills these by value.
*/
select : function(){
    var iField, sRowId = this.oLookupForm.getBufferValue(this.sLookupTable  + ".rowid");
    
    if(this.onBeforeSelect.fire(this, {sRowId : sRowId })){
        //  Manually set the field values (if sAttachedFields is set)
        for(iField = 0; iField < this.aAttachedFields.length; iField++){
            if(this.aAttachedFields[iField] !== ""){
                this.oForm.setBufferValue(this.aAttachedFields[iField], this.oLookupForm.getBufferValue(this.aLookupFields[iField]));
            }
        }
        
        //  If DD is available we do a find by rowid
        if(this.oForm.containsDD(this.sLookupTable)){
            this.oForm.doFindByRowId(this.sLookupTable, sRowId);
        }

        this.onAfterSelect.fire(this, { });
    }
},

/*
Closes the dialog.
*/
close : function(){
    this.oDialog.close();
},

/*
@private
*/
onBeforeDialogClose : function(oEvent){
    if(!this.onBeforeClose.fire(this, { })){
        oEvent.stop(0);
    }
},

/*
Returns the focus to the correct field.

@private
*/
returnFocus : function(){
    var oField = null, iDeo;

    //  Determine focus field
    //  Step 1: Focus field property
    if(this.sFocusField){
        oField = this.oForm.getDEO(this.sFocusField);
    }
    
    //  Step 2: Field that opened the lookup (using F4)
    if(oField === null && this.oSource){
        oField = this.oSource;
    }
    
    //  Step 3: The first field of the form bound to a field of this table 
    for(iDeo = 0; oField === null && iDeo < this.oForm.aDEOs.length; iDeo++){
        if(this.oForm.aDEOs[iDeo].sTable === this.sLookupTable && this.oForm.aDEOs[iDeo].sDataBindingType === "D"){
            oField = this.oForm.aDEOs[iDeo];
        }
    }
    
    //  Step 3: Take the last active field
    if(oField === null){
        oField = this.oForm.oActiveField;
    }
    
    //  Give the focus
    if(oField && oField.bFocusable){
        oField.focus();
    }
},

/*
@private
*/
onAfterDialogClose : function(oEvent){
    this.returnFocus();

    this.oLookup.onEnter.removeListener(this.onLookupEnter);
    this.oLookup.onInitialized.removeListener(this.onLookupInitialized);
    vdf.core.init.destroyControls(this.eDiv);
    this.oLookup = null;
    this.oLookupForm = null;
    this.eDiv = null;
    
    this.oDialog.onButtonClick.removeListener(this.onDialogButtonClick);
    this.oDialog.onAfterClose.removeListener(this.onDialogClose);
    this.oDialog = null;
    
    this.onAfterClose.fire(this, { });
},

/*
@private
*/
onDialogButtonClick : function(oEvent){
    if(oEvent.sButtonName === "select"){
        this.finish();
    }else if(oEvent.sButtonName === "cancel"){
        this.close();
    }else if(oEvent.sButtonName === "search"){
        this.oLookup.displayJumpIntoList();
    }

},

/*
@private
*/
onButtonClick : function(oEvent){
    this.display();
},

/*
@private
*/
onLookupEnter : function(oEvent){
    this.finish();
},

/*
Default implementation that assumes that there is one element referenced by 
eElement. Exceptions must be implemented in the subclass.

@param  sName       Name of the attribute.
@param  sDefault    Value returned if attribute not set.
@return Value of the attribute (sDefault if not set).
*/
getVdfAttribute : function(sName, sDefault, bBubble){
    var sResult = vdf.getDOMAttribute(this.eElement, sName, null);
    
    if(sResult === null){
        if((bBubble) && this.oParentControl !== null && typeof(this.oParentControl.getVdfAttribute) == "function"){
            sResult = this.oParentControl.getVdfAttribute(sName, sDefault, true);
        }else if((bBubble) && this.oForm !== null && typeof(this.oForm) !== "undefined"){
            sResult = this.oForm.getVdfAttribute(sName, sDefault, true);
        }else{
            sResult = sDefault;
        }
    }
    
    return sResult;
}

});

