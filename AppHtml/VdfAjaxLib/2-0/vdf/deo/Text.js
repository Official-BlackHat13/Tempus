/*
Name:
    vdf.deo.Text
Type:
    Prototype
Extends:
    vdf.core.TextField
Revisions:
    2008/01/17  Initial version in the new 2.0 architecture. (HW, DAE)
*/

/*
@require    vdf/core/TextField.js
*/

/*
Constructor of that calls the super constructor (of the Textfield) and applies to 
the initializer interface (see vdf.core.init).

@param  eText           Reference to the DOM element.
@param  oParentControl  Reference to the parent control.
*/
vdf.deo.Text = function Text(eText, oParentControl){
    this.TextField(eText, oParentControl);
    
    this.sSuggestSource         = this.getVdfAttribute("sSuggestSource", "none");
    this.bSuggestAutoFind       = this.getVdfAttribute("bSuggestAutoFind", (this.sSuggestSource.toLowerCase() == "find"));
    this.bSuggestStaticWidth    = this.getVdfAttribute("bSuggestStaticWidth", true);
    this.sSuggestValues         = this.getVdfAttribute("sSuggestValues", "");
    this.iSuggestLength         = this.getVdfAttribute("iSuggestLength", 10);
    this.sSuggestSourceTable    = this.getVdfAttribute("sSuggestSourceTable", this.sTable);
    this.sSuggestSourceField    = this.getVdfAttribute("sSuggestSourceField", this.sField);
    this.aSuggestValues         = null;
    
    //  @privates
    this.sSuggestPrevValue      = null;
    this.tSuggestDisplay        = null;
    this.tSuggestHide           = null;
    this.eSuggestDiv            = null;
    
    this.sSuggestSource = this.sSuggestSource.toLowerCase();
    if(this.sSuggestSourceTable){
        this.sSuggestSourceTable = this.sSuggestSourceTable.toLowerCase();
    }
    if(this.sSuggestSourceField){
        this.sSuggestSourceField = this.sSuggestSourceField.toLowerCase();
    }
};
/*
Implementation of the regular form field (<input type="text").
*/
vdf.definePrototype("vdf.deo.Text", "vdf.core.TextField", {
/*
Gives the focus to the field by giving the focus to the input element.
*/
focus : function(){
    vdf.sys.dom.focus(this.eElement);
    //this.eElement.select();
},


//  - - - - - - - - - - SuggestionList - - - - - - - - - - 
/*
Called by the form to initialize the data entry object.

@private
*/
formInit : function(){
    var aValues, iValue;

    if(typeof this.TextField.prototype.formInit === "function"){
        this.TextField.prototype.formInit.call(this);
    }
    
    if(this.sSuggestSource.toLowerCase() !== "none"){
        //  Attach keylistener
        this.addKeyListener(this.onSuggestFieldKeyPress, this);
        this.addDomListener("blur", this.onSuggestFieldBlur, this);

        if(this.sSuggestSource.toLowerCase() == "validationtable"){
            //  Fetch descriptionvalues and clone so we can manipulate them
            //this.aSuggestValues = browser.data.clone(this.oVdfForm.getVdfFieldAttribute(this, "aDescriptionValues"));
            //  Tell the form to wait for us with finishing initialization
            this.oForm.iInitFinishedStage++;
            
            this.oForm.oMetaData.loadDescriptionValues(this.sDataBinding, this.onSuggestDVLoaded, this);
            
            
        }else if(this.sSuggestSource.toLowerCase() == "custom"){
            //  Fetch values JSON style and add them to the array
            this.aSuggestValues = [];
            
            aValues = eval("([" + this.sSuggestValues + "])");
            for(iValue = 0; iValue < aValues.length; iValue++){
                if(aValues[iValue] !== ""){
                    this.aSuggestValues.push({ sValue : aValues[iValue] });
                }
            }
            
            //  Sort items alphabetically
            this.aSuggestValues.sort(this.suggestCompare);
        }
    }
},

/*
@private
*/
onSuggestDVLoaded : function(aValues){
    this.aSuggestValues = vdf.sys.data.deepClone(aValues);
    this.aSuggestValues.sort(this.suggestCompare);
    
    this.oForm.childInitFinished();
},


/*
Displays / Updates the suggestionlist. Uses the value in aSuggestOptions or
with the find source sends a find request.
*/
suggestDisplay : function(){
    var oDD, oAction, tRequestSet, tSnapshot, tField, iDD;
    
    try{
        //  Without value no suggest list should be displayed
        if(this.eElement.value !== ""){
            
            //  For validation and custom use the already loaded values.
            if(this.sSuggestSource == "validationtable" || this.sSuggestSource == "custom"){
                this.suggestBuildList(this.aSuggestValues, this.eElement.value);
            }else if(this.sSuggestSource == "find"){
                //  Append requestsets to the find
                // sXml += "<aDataSets>\n";
                // sFieldXml = VdfGlobals.soap.getFieldXml(this.sSuggestSourceTable + "__" + this.sSuggestSourceField, this.eElement.value, true);
                
                // sXml += VdfGlobals.soap.getRequestSet(this.sDataBinding, "findByField", this.sSuggestSourceTable, this.sSuggestSourceField, sFieldXml, "", dfGE, this.iSuggestLength, this.oVdfForm.getRequestSetUserData("find", this.sDataBinding), false, "", true);

                // sXml += "</aDataSets>\n";
            
                // send the request
                //this.oVdfForm.sendRequest(sXml, true);
                
                
                oDD = this.oForm.getDD(this.sSuggestSourceTable);
                
                oAction = new vdf.core.Action("find", this.oForm, this, oDD, false);
                
                tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
                tRequestSet.sName = "SuggestFind";
                tRequestSet.sRequestType = "findByField";
                tRequestSet.iMaxRows = this.iSuggestLength;
                tRequestSet.sTable = this.sSuggestSourceTable;
                tRequestSet.sColumn = this.sSuggestSourceField;
                tRequestSet.sFindMode = vdf.GE;
                tRequestSet.bReturnCurrent = false;
            
                tSnapshot = oDD.generateExtSnapshot(false);
                for(iDD = 0; iDD < tSnapshot.aDDs.length; iDD++){
                    if(tSnapshot.aDDs[iDD].sName === this.sSuggestSourceTable){
                        tField = new vdf.dataStructs.TAjaxField();
                        tField.sBinding = this.sSuggestSourceTable + "." + this.sSuggestSourceField;
                        tField.sValue = this.eElement.value;
                        tSnapshot.aDDs[iDD].aFields.push(tField);
                        break;
                    }
                }
                tRequestSet.aRows.push(tSnapshot);
                
                oAction.addRequestSet(tRequestSet);
                oAction.onResponse.addListener(this.suggestHandleFind, this);
                oAction.send();
                
            }
        }else{
            if(this.eSuggestDiv !== null){
                this.suggestHide();
            }
        }
    }catch(oError){
        vdf.errors.handle(oError);
    }
},


/*
Handles the find for the suggestlist. Builds a list of the find results in
the [ { sValue : "", sDescription : "" }, { sVal... ] format. And calls the 
suggestBuildList method to dislay it.

@param  oEvent  The event object.
@private
*/
suggestHandleFind : function(oEvent){
    var tResponseSet, iRow, iDD, tSnapshot, aList = [];
    
    if(!oEvent.bError){
        tResponseSet = oEvent.tResponseData.aDataSets[0];
        for(iRow = 0; iRow < tResponseSet.aRows.length; iRow++){
            tSnapshot = tResponseSet.aRows[iRow];
            
            for(iDD = 0; iDD < tSnapshot.aDDs.length; iDD++){
                if(tSnapshot.aDDs[iDD].sName === this.sSuggestSourceTable){
                    aList.push({sValue : tSnapshot.aDDs[iDD].aFields[0].sValue, sDescription : null});
                    break;
                }
            }
        }
      
        // go display the suggestion list
        this.suggestBuildList(aList, this.eElement.value);
    }
},

/*


Builds the suggest list according to the given list of possible values by 
checking them agains the current input value. Only displays the items of 
which the value matches. Displays the descriptionvalue if this is available
in the list.

@param  aCompleteList   The list of possible values (should already be sorted)
@param  sValue          The current value of the field to which the values are
            checked.
@private
*/
suggestBuildList : function(aCompleteList, sValue){
    var aList, eSuggestDiv, eElement, eTable, iLength, eRow, eCell, sNewSelectedValue = null, iNewSelectedItem = -1, iItem;
    
    iLength = sValue.length;
    sValue = sValue.toLowerCase();
    aList = [];
    eElement = this.eElement;
    
    //  Fetch items that match against the value from the list
    for(iItem = 0; iItem < aCompleteList.length; iItem++){
        if(aCompleteList[iItem].sValue.substr(0, iLength).toLowerCase() == sValue){
            aList.push(aCompleteList[iItem]);
        }
    }
    
    //  Remove a list if it already exists
    if(this.eSuggestDiv !== null){
        //  IE =< 6  have select list z-index bug
        vdf.sys.gui.displaySelectBoxes(this.eSuggestDiv);
    
        this.eSuggestDiv.parentNode.removeChild(this.eSuggestDiv);
        this.eSuggestDiv.eTable = null;
        this.eSuggestDiv = null;
    }
    
    //  Only generate if items are found
    if(aList.length > 0){
    
        //  Generate div and table
        eSuggestDiv = document.createElement("div");
        eSuggestDiv.className = "vdfSuggest";
        eElement.parentNode.style.position = "relative";
        if (vdf.sys.isIE){
            eSuggestDiv.style.top = (eElement.offsetHeight + 2) + "px";
            eSuggestDiv.style.left = "1px";
        }
        
        eTable = document.createElement("table");
        eTable.cellSpacing = 0;

        
        if(this.bSuggestStaticWidth){
            eSuggestDiv.style.width = (eElement.offsetWidth - 2) + "px";
            eTable.style.width = "100%";
        }
        
        vdf.sys.dom.insertAfter(eSuggestDiv, eElement);
        eSuggestDiv.appendChild(eTable);
        
        
        //  For each item generate the row
        for(iItem = 0; iItem < aList.length && iItem < this.iSuggestLength; iItem++){
            eRow = eTable.insertRow(eTable.rows.length);
            eRow.setAttribute("iNum", iItem);
            eRow.setAttribute("sValue", aList[iItem].sValue);
            
            eCell = eRow.insertCell(0);
            eCell.innerHTML = "<b>" + aList[iItem].sValue.substr(0, iLength) + "</b>" + aList[iItem].sValue.substr(iLength);
            
            //  Add description if available
            if(aList[iItem].sDescription !== null){
                eCell = eRow.insertCell(1);
                vdf.sys.dom.setElementText(eCell, aList[iItem].sDescription);
            }
            
            if(aList[iItem].sValue == this.sSuggestSelectedValue){
                eRow.className = "selected";
                sNewSelectedValue = aList[iItem].sValue;
                iNewSelectedItem = iItem;
            }
            
            vdf.events.addDomListener("mouseover", eRow, this.onSuggestMouseOver, this);
            vdf.events.addDomListener("click", eRow, this.onSuggestMouseClick, this);
        }
        
        this.eSuggestDiv = eSuggestDiv;
        this.eSuggestDiv.eTable = eTable;
        
        //  IE =< 6  have select list z-index bug
        vdf.sys.gui.hideSelectBoxes(this.eSuggestDiv);
    }
    
    this.sSuggestSelectedValue = sNewSelectedValue;
    this.iSuggestSelectedItem = iNewSelectedItem;
},

/*
Removes the suggest list if one is displayed.
*/
suggestHide : function(){
    try{
        if(this.eSuggestDiv !== null){
            //  IE =< 6  have select list z-index bug
            vdf.sys.gui.displaySelectBoxes(this.eSuggestDiv);
            this.eSuggestDiv.parentNode.removeChild(this.eSuggestDiv);
            this.eSuggestDiv.eTable = null;
            this.eSuggestDiv = null;
            this.sSuggestSelectedValue = null;
            this.iSuggestSelectedItem = -1;
        }
    }catch(oError){
        vdf.errors.handle(oError);
    }
},

/*
Sets the selected value to the form, performs a FindByField if need and 
hides the suggest list.    
*/
suggestFinish : function(){
    if(this.sSuggestSelectedValue !== null){
        this.setValue(this.sSuggestSelectedValue);
        this.sSuggestPrevValue = this.sSuggestSelectedValue.toLowerCase();
        if(this.bSuggestAutoFind){
            this.doFind(vdf.GE);
        }
        this.focus();
    }
    
    this.suggestHide();
},

/*
Moves the selects the next or the previous row in the suggest list.

@param  bDown   If true the next row is selected else the previous.
*/
suggestMoveSelection : function(bDown){
    var eTable, iSelectItem, iRow;
    
    eTable = this.eSuggestDiv.eTable;
    iSelectItem = this.iSuggestSelectedItem;
  
    //  Calculate which row to select
    if(bDown){
        iSelectItem++;
        if(iSelectItem >= eTable.rows.length){
            iSelectItem = eTable.rows.length - 1;
        }
    }else{
        iSelectItem--;
        if(iSelectItem < -1){
            iSelectItem = eTable.rows.length - 1;
        }else if(iSelectItem == -1){
            iSelectItem = 0;
        }
    }

    //  Loop through the rows and update the styles and get the values of the new selected row
    for(iRow = 0; iRow < eTable.rows.length; iRow++){
        if(iRow == iSelectItem){
            eTable.rows[iRow].className = "selected";
            this.sSuggestSelectedValue = eTable.rows[iRow].getAttribute("sValue"); 
            this.iSuggestSelectedItem = eTable.rows[iRow].getAttribute("iNum");
        }else{
            eTable.rows[iRow].className = "";
        }
    }
},

/*
Selects a list item using the given row element.

@param  eRow    The row element to select.
*/
suggestSelectRow : function(eRow){
    var eTable, iRow;
    
    eTable = this.eSuggestDiv.eTable;
    
    //  Loop through the rows and update the styles and get the values of the new selected row
    for(iRow = 0; iRow < eTable.rows.length; iRow++){
        if(eTable.rows[iRow] == eRow){
            eTable.rows[iRow].className = "selected";
            this.sSuggestSelectedValue = eTable.rows[iRow].getAttribute("sValue"); 
            this.iSuggestSelectedItem = eTable.rows[iRow].getAttribute("iNum");
        }else{
            eTable.rows[iRow].className = "";
        }
    }
},    

/*
Called if a key is pressed in the field. If a special key (tab, escape, 
enter, arrow up/down) a special action is undertakenh, otherwise the list 
is updated (unless the key is in the special keys list).

@param  oEvent  The event object.
@return True if special action is done.
@private
*/
onSuggestFieldKeyPress : function(oEvent){
    var iKeyCode = oEvent.getKeyCode(), oField = this;

    if(this.eSuggestDiv !== null && !oEvent.getShiftKey() && !oEvent.getCtrlKey() && !oEvent.getAltKey()){
        if (iKeyCode == 27 || iKeyCode == 9){ // escape/tab hides the list
            this.suggestHide();
            oEvent.stop();
            return;
        }else if (iKeyCode == 13){ // enter selects the value
            this.suggestFinish();
            oEvent.stop();
            return;
        }else if(iKeyCode == 38 || iKeyCode==40){ // Up and down go trough the list
            this.suggestMoveSelection(iKeyCode == 40);
            oEvent.stop();
            return;
        }
    }
    
    if(this.sSuggestPrevValue !== this.eElement.value.toLowerCase()){
        this.sSuggestPrevValue = this.eElement.value.toLowerCase();
        
        //  Set a timeout so the list wont show immediately
        if(this.tSuggestHide !== null){
            clearTimeout(this.tSuggestHide);
        }
        this.tSuggestDisplay = setTimeout(function(){
            oField.tSuggestDisplay = null;
            oField.suggestDisplay();
        }, 200);
    }
},


/*
@private

Is called when the the field is blurred (loses the focus). If the suggest 
list is enabled it sets a timeout to hide to list.

@param  oEvent  Event object.
*/
onSuggestFieldBlur : function(oEvent){
    var oField = this;

    //  Suggest keyaction
    if(this.sSuggestSource.toLowerCase() !== "none"){
        if(this.tSuggestDisplay !== null){
            clearTimeout(this.tSuggestDisplay);
        }
        this.tSuggestHide = setTimeout(function(){ 
            oField.suggestHide(); 
        }, 500);
    }
},

/*
Is called by the array sort method. Compares two suggestionlist objects 
{ sValue : "value" , sDescription : "descr" } and determines using their 
value in which order the belong.

@param  oSuggestion1    First suggestion object.
@param  oSuggestion2    Second suggestion object.
@return 1 if value the first belongs after the last, -1 if the first belongs 
        before the last, 0 if a problem occured.
@private
*/
suggestCompare : function(oSuggestion1, oSuggestion2){
    var sValue1, sValue2;
    
    sValue1 = oSuggestion1.sValue.toUpperCase();
    sValue2 = oSuggestion2.sValue.toUpperCase();
    try{
        if (sValue1 > sValue2){
            return 1;
        }
        if (sValue2 > sValue1){
            return -1;
        }
    }catch(e){

    }
    return 0;
},

/*
@private

Handles the mouseover event of the suggest list rows and selects the row 
that the mouse goes over.

@param  oEvent  Event object.
*/
onSuggestMouseOver : function(oEvent){
    var eSource;
 
    eSource = oEvent.getTarget();
    
    eSource = vdf.sys.dom.searchParent(eSource, "tr");
    if(eSource === null){
        return;
    }
    
    this.suggestSelectRow(eSource);
},

/*
@private

Handles the mouseclick event of the suggest list rows. Makes sure the row 
is selected and calls the finish method.

@param  oEvent  Event object.
*/
onSuggestMouseClick : function(oEvent){
    var eSource;
 
    eSource = oEvent.getTarget();
    
    eSource = vdf.sys.dom.searchParent(eSource, "tr");
    if(eSource === null){
        return;
    }
    
    this.suggestSelectRow(eSource);
    this.suggestFinish();
}


});
