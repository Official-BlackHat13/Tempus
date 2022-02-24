//
//  Class:
//      VdfField
//
//  Wrapper for html form elements representing an Database field. With this 
//  wrapper all elements (radio, text, select) have the same interface to talk 
//  to.
//
//  Since:
//      20-01-2006
//  Changed:
//      --
//  Version:
//      0.9
//  Creator:
//      Data Access Europe (Harm Wibier)
//


//
//  Constructor of VdfField class.
//
//  Params:
//      eField      The form element to wrap
//      oVdfForm    The VdfForm form for fetching information
//  
function VdfField(eField, oVdfForm, sDataBinding){    
    if(typeof(oVdfForm) == "undefined"){
        this.oVdfForm           = null;
    }else{
        this.oVdfForm           = oVdfForm;
    }

    this.eElement               = eField;

    //  Determine type
    if((eField.tagName == "INPUT" && eField.type != "button") || eField.tagName == "SELECT" || eField.tagName == "TEXTAREA"){
        if(eField.tagName == 'SELECT'){
            this.sType              = 'select';
        }else if(eField.tagName == "TEXTAREA"){
            this.sType = "textarea";
        }else{
            this.sType              = eField.type.toLowerCase();
        }
    }else{
        this.sType = "dom"
    }
    
    //  Determine names   
    this.sDataBinding           = sDataBinding;
    this.sTable                 = this.sDataBinding.substr(0, this.sDataBinding.indexOf('__'));
    this.sField                 = this.sDataBinding.substr(this.sDataBinding.indexOf('__') + 2);
    this.sServerTable           = browser.dom.getVdfAttribute(eField, "sServerTable", null);
    this.bUseDescriptionValue   = browser.dom.getVdfAttribute(eField, "bUseDescriptionValue", this.sType == "select");    
    this.sSuggestSource         = browser.dom.getVdfAttribute(eField, "sSuggestSource", "none");
    this.bSuggestAutoFind       = browser.dom.getVdfAttribute(eField, "bSuggestAutoFind", (this.sSuggestSource.toLowerCase() == "find"));
    this.bSuggestStaticWidth    = browser.dom.getVdfAttribute(eField, "bSuggestStaticWidth", true);
    this.sSuggestValues         = browser.dom.getVdfAttribute(eField, "sSuggestValues", "");
    this.iSuggestLength         = browser.dom.getVdfAttribute(eField, "iSuggestLength", 10);
    this.sSuggestSourceTable    = browser.dom.getVdfAttribute(eField, "sSuggestSourceTable", this.sTable);
    this.sSuggestSourceField    = browser.dom.getVdfAttribute(eField, "sSuggestSourceField", this.sField);
    this.sDefaultValue          = oVdfForm.getVdfFieldAttribute(this, "sDefaultValue");
    
    this.aSuggestValues        = null;
    this.eSuggestDiv            = null;
    
    if(this.sServerTable != null){
        this.sServerTable.toLowerCase();
    }
    
    //  TYPE Specific properties and functionality
    if (this.sType == "select"){
        if(oVdfForm != null){
            //  Fill with descriptionvalues if available
            var aDescriptionValues = oVdfForm.getVdfFieldAttribute(this, "aDescriptionValues");
            
            if(aDescriptionValues != null){
                for (var iCount = 0; iCount < aDescriptionValues.length; iCount++){
                    eField.options[iCount] = new Option((this.bUseDescriptionValue ? aDescriptionValues[iCount].sDescription : aDescriptionValues[iCount].sValue), aDescriptionValues[iCount].sValue);
                    if(aDescriptionValues[iCount].sValue == this.sDefaultValue) eField.selectedIndex = iCount;
                }
            }
        }
    }else if(this.sType == "radio"){
        this.aElements          = new Object();
        this.addElement(eField);
        
    
    }else if(this.sType == "checkbox"){
        
        //  Fetch checked and unchecked values from DD
        this.sCheckedValue      = "1";
        this.sUncheckedValue    = "0";
        if(oVdfForm != null){
            if(oVdfForm.getVdfFieldAttribute(this, "sCheckboxCheckedValue") != null){
                this.sCheckedValue = oVdfForm.getVdfFieldAttribute(this, "sCheckboxCheckedValue");
            }
            if(oVdfForm.getVdfFieldAttribute(this, "sCheckboxUncheckedValue") != null){
                this.sUncheckedValue = oVdfForm.getVdfFieldAttribute(this, "sCheckboxUncheckedValue");
            }
        }
    }
    eField.oVdfField        = this;
    
    //  Set datatype class for alignment (if no css class is set)
    if(this.oVdfForm != null){
        if(this.getCSSClass() == null || this.getCSSClass() == ""){
            this.setCSSClass(this.oVdfForm.getVdfFieldAttribute(this, "sDataType") + "_data");
        }
    }
    
    //  Sets the sOrigValue
    if(this.sType == "text" || this.sType == "textarea"){
        this.sOrigValue = eField.value;
    }else{
        //  Workaround because special elements should always be saved with new record
        this.sOrigValue = "";
    }
    
    this.sOrigDisplayValue = this.getValue();
}

//
//  Initializes the field by attaching keylisteners (if needed).
//
//  PRIVATE
VdfField.prototype.init = function(){
    this.initSuggest();
}


//
//  Add elements for field of a type that contain more elements (radio..)
//
//  Param:
//      eField  Element to add
//
VdfField.prototype.addElement = function(eField){
    if(this.sType == 'radio'){
        this.aElements[eField.value] = eField;
        if(eField.checked){
            this.sOrigDisplayValue = eField.value;
        }
        
        eField.oVdfField = this;
    }
    
    this.sOrigDisplayValue = this.getValue();
}

//
//  Returns:
//      String with the field type (select, radio, text, checkbox etc..)
//
//  DEPRECATED
VdfField.prototype.getType = function(){
    return this.sType;
}

//
//  Returns:
//      The html form element (or an array of elements)
//
VdfField.prototype.getElement = function(){
    var oResult = null;
    
    if(this.sType == 'radio'){
        oResult = this.aElements;
    }else{
        oResult = this.eElement;
    }
    
    return oResult;
}

//
//  Returns:
//      The servertable of the field
//
//  DEPRECATED
VdfField.prototype.getServerTable = function(){
    return this.sServerTable;
}

//
//  Sets the servertable if not set already.
//
//  Params:
//      sNewServerTable New server table for the field
//      bOverwriteOrig  If true the new server table is always set
//
//  PRIVATE
VdfField.prototype.setServerTable = function(sNewServerTable, bOverwriteOrig){
    if(bOverwriteOrig || this.sServerTable == null){
        this.sServerTable = sNewServerTable;
    }
}

//
//  Returns:
//      The current (selected)value of the field
//
VdfField.prototype.getValue = function(){
    var sValue = '', sCurrentValue;
    
    if(this.sType == 'radio'){
        for(sCurrentValue in this.aElements){
            if(this.aElements[sCurrentValue].checked){
                sValue = sCurrentValue;
            }
        }
    }else if(this.sType == "checkbox"){
        sValue = (this.eElement.checked ? this.sCheckedValue : this.sUncheckedValue);
    }else if(this.sType == "dom"){
        sValue = browser.dom.getElementText(this.eElement);
    }else{
        sValue = this.eElement.value;
    }
    
    return sValue;
}

//
//  Set the value of the field
//
//  Params:
//      sValue  The new field value
//      bReset  If true the startvalue and changedstate are resetted 
//              (default: false)
//
VdfField.prototype.setValue = function(sValue, bReset){
    var sElement;
    
    if(typeof(bReset) == "undefined"){
        var bReset = false;
    }
    
    //  If needed reset the origvalue used for the changedstate
    if(bReset){
        this.sOrigValue = sValue;
    }
    
    if(this.sType == 'radio'){
        //  If none given select first
        if(sValue == ""){
            for(sElement in this.aElements){
                this.aElements[sElement].checked = true;
                break;
            }
        }
        
        //  Try to select
        if(this.aElements[sValue] != null){
            this.aElements[sValue].checked = true;
        }
    }else if(this.sType == "checkbox"){
        //  Set checked only if new value matches checkedvalue..
        this.eElement.checked = (sValue == this.sCheckedValue);
        this.eElement.defaultChecked = (sValue == this.sCheckedValue);
    }else if(this.sType == "select"){
        //  Select first if no value given
        if(sValue == ""){
            this.eElement.selectedIndex = 0;
        }
        
        //  Try to set the value
        this.eElement.value = sValue;
    }else if(this.sType == "dom"){
        browser.dom.setElementText(this.eElement, sValue);
    }else if(this.sType == "textarea"){
        this.eElement.value = sValue;
        this.sOrigValue = this.getValue();
    }else{
        //  Just set the value
        this.eElement.value = sValue;
    }
    if(this.sDataBinding == "invt__ext"){
        this.sOrigValue = this.getValue();
    }
    if(bReset){
        this.sOrigDisplayValue = this.getValue();
    }
}

//
//  Should be used to set the field to a value from a dataset. Decides using 
//  the bUseDescriptionValue property if the descriptionvalue should be used.
//
//  Params:
//      oDataSet    The dataset to fetch the value from
//      bReset  If true the startvalue and changedstate are resetted 
//              (default: false)
//
VdfField.prototype.setDataSetValue = function(oDataSet, bReset){
    if(typeof(bReset) == "undefined"){
        var bReset = false;
    }

    if(oDataSet.hasValue(this.sDataBinding) || oDataSet.bNew){
        if(this.bUseDescriptionValue && this.sType != "select"){ // Select boxes display the description value but work with the real value
            this.setValue(oDataSet.getDisplayValue(this.sDataBinding), bReset);
        }else{
            this.setValue(oDataSet.getValue(this.sDataBinding), bReset);
        }
    }
}

//
//  Returns:
//      True if the value is not the origional value so it should be saved
//
VdfField.prototype.getChangedState = function(){
    if(this.sType == "dom"){
        return false;
    }else{
        return (this.getValue() != this.sOrigValue);
    }
}

//
//  Returns:
//      True if the user has changed the value since the last reset to determine
//      wheter save is nessacary
//
VdfField.prototype.getDisplayChangedState = function(){
    if(this.sType == "dom"){
        return false;
    }else{
        return (this.getValue() != this.sOrigDisplayValue);
    }
}

//
//  Returns:
//      The name of the element
//
//  DEPRECATED
VdfField.prototype.getName = function(){
    return this.sDataBinding;
}

//
//  Returns:
//      Name of the table
//
//  DEPRECATED
VdfField.prototype.getTableName = function(){
    return this.sTable;
}

//
//  Returns:
//      Name of the field
//
//  DEPRECATED
VdfField.prototype.getFieldName = function(){
    return this.sField;
}

//
//  Params:
//      sName       Name of the attribute
//      sDefault    The value returned if no value found
//  Returns:
//      The vdf value of the field attribute (Use VdfForm.getVdfFieldAttribute 
//      for datadictionary properties!)
//
VdfField.prototype.getVdfAttribute = function(sName, sDefault){
    var sResult, sCurrentValue;

    if(typeof(sDefault) == "undefined"){
        var sDefault = null;
    }
    sResult = sDefault;
    
    if(this.sType == 'radio'){
        for(sCurrentValue in this.aElements){
            sResult = browser.dom.getVdfAttribute(this.aElements[sCurrentValue], sName, sDefault);
            if(sResult != sDefault){
                break;
            }
        }
    }else{
        sResult = browser.dom.getVdfAttribute(this.eElement, sName, sDefault);
    }
    
    return sResult;
}

//
//  Params:
//      sName       The name of the attribute
//      sDefault    The value returned if no value found
//  Returns:
//      Value of the element attribute (null / default if not set)
//
VdfField.prototype.getAttribute = function(sName, sDefault){
    var sResult, sCurrentValue;
    
    if(typeof(sDefault) == "undefined"){
        var sDefault = null;
    }
    
    //  Fetch value
    if(this.sType == "radio"){
        for(sCurrentValue in this.aElements){
            sResult = this.aElements[sCurrentValue].getAttribute(sName);
            if(sResult != null){
                break;
            }
        }
    }else{
        sResult = this.eElement.getAttribute(sName);
    }
    
    //  Set to default and parse boolean
    if(sResult == null){
        sResult = sDefault;
    }else if(typeof(sResult) == "string"){
        if(sResult.toLowerCase() == "true"){
            sResult = true;
        }else if(sResult.toLowerCase() == "false"){
            sResult = false;
        }
    }
    
    return sResult;
}

//
//  Sets the field elements vdf attribute
//
//  Params:
//      sName   Name of the attribute to set
//      sValue  New value of the attribute
//
VdfField.prototype.setVdfAttribute = function(sName, sValue){
    if(this.sType == 'radio'){
        var sCurrentValue;
        for(sCurrentValue in this.aElements){
            browser.dom.setVdfAttribute(this.aElements[sCurrentValue], sName, sValue);
            break;
        }
    }else{
        browser.dom.setVdfAttribute(this.eElement, sName, sValue);
    }
}

//
//  Set the field elements attributes
//
//  Params:
//      sName   Name of the attribute to set
//      sValue  New value of the attribute
//
VdfField.prototype.setAttribute = function(sName, sValue){
    if(this.sType == 'radio'){
        var sCurrentValue;
        for(sCurrentValue in this.aElements){
            this.aElements[sCurrentValue].setAttribute(sName, sValue);
            break;
        }
    }else{
        this.eElement.setAttribute(sName, sValue);
    }
}

//
//  Set the focus to the field and if possible select the text in the element.
//  (with radio elements the selected element will receive the focus)
//
//  Returns:
//      False if element can't receive focus
//
VdfField.prototype.focusSelect = function(){
    var sCurrentValue, bResult = true;
    
    if(this.sType == 'radio'){
        for(sCurrentValue in this.aElements){
            if(this.aElements[sCurrentValue].checked){
                browser.dom.setFocus(this.aElements[sCurrentValue]);
            }
        }
    }else if(this.sType == 'select' || this.sType == "checkbox"){
        browser.dom.setFocus(this.eElement);
    }else if(this.sType == "dom"){
        bResult = false;
    
    }else{
        browser.dom.setFocus(this.eElement);
        this.eElement.select();
    }
    
    return bResult;
}

//
//  Sets the width of the field element
//
//  Params:
//      iPixels     The new width in pixels
//
VdfField.prototype.setWidth = function(iPixels){
    if(this.sType == 'radio'){
    
    }else{
        this.eElement.style.width = iPixels + 'px';
    }
}

//
//  Params:
//      The new css class for the elemnt
//
VdfField.prototype.setCSSClass = function(sClassName){
    if(this.sType == 'radio'){
        var sCurrent;
        for(sCurrent in this.aElements){
            this.aElements[sCurrent].className = sClassName;
        }
    }else{
        this.eElement.className = sClassName;
    }
}

//
//  Returns:
//      The current css class of the (first) element
//
VdfField.prototype.getCSSClass = function(){
    if(this.sType == 'radio'){
        var sCurrent;
        for(sCurrent in this.aElements){
            return this.aElements[sCurrent].className;
        }
        return null;
    }else{
        return this.eElement.className;
    }
}

//
//  Attaches keylistener to the element
//
//  Params:
//      oListener   Method to fetch event
//
VdfField.prototype.addKeyListener = function(oListener){
    if(this.sType == 'radio'){
        var sCurrent;
        for(sCurrent in this.aElements){
            browser.events.addKeyListener(this.aElements[sCurrent], oListener);
        }
    }else{
        browser.events.addKeyListener(this.eElement, oListener);
    }
}


//
//  Attaches keylistener to the element
//
//  Params:
//      oListener   Method to fetch event
//
//  DEPRECATED
VdfField.prototype.addKeyDownListener = function(oListener){
    if(this.sType == 'radio'){
        var sCurrent;
        for(sCurrent in this.aElements){
            browser.events.addKeyDownListener(this.aElements[sCurrent], oListener);
        }
    }else{
        browser.events.addKeyDownListener(this.eElement, oListener);
    }
}

//
//  Attachers generic listener to the element
//
//  Params:
//      sEvent      Name of the event
//      oListener   Method to fetch the event
//
VdfField.prototype.addGenericListener = function(sEvent, oListener){
    if(this.sType == 'radio'){
        var sCurrent;
        for(sCurrent in this.aElements){
            browser.events.addGenericListener(sEvent, this.aElements[sCurrent], oListener);
        }
    }else{
        browser.events.addGenericListener(sEvent, this.eElement, oListener);
    }
}

//
//  Removes keylistener from the element
//
//  Params:
//      oListener   Method to fetch event
//
VdfField.prototype.removeKeyListener = function(oListener){
    if(this.sType == 'radio'){
        var sCurrent;
        for(sCurrent in this.aElements){
            browser.events.removeKeyListener(this.aElements[sCurrent], oListener);
        }
    }else{
        browser.events.removeKeyListener(this.eElement, oListener);
    }
}

//
//  Removes generic listener from the element
//
//  Params:
//      sEvent      Name of the event
//      oListener   Method to fetch the event
//
VdfField.prototype.removeGenericListener = function(sEvent, oListener){
    if(this.sType == 'radio'){
        var sCurrent;
        for(sCurrent in this.aElements){
            browser.events.removeGenericListener(sEvent, this.aElements[sCurrent], oListener);
        }
    }else{
        browser.events.removeGenericListener(sEvent, this.eElement, oListener);
    }
}

//
//  Checks wether the field is a foreign field in the form or not using the 
//  VdfTable.isForeign method and the form maintable setting.
//
//  Returns:
//      True is field is a foreign field
//
VdfField.prototype.isForeign = function(){
    return this.oVdfForm.aTables[this.sTable].isForeign(this.oVdfForm.sMainTable);
}

//
//  Initializes the suggestlist. If source is validationtable or custom the 
//  values are loaded into the aSuggestOptions array which is sorted directly.
//
//  PRIVATE
VdfField.prototype.initSuggest = function(){
    var aValues, iValue;
    
    if(this.sSuggestSource.toLowerCase() != "none"){
        //  Attach keylistener
        this.addKeyListener(this.onKeyPress);
        this.addGenericListener("blur", this.onBlur);

    
    
        if(this.sSuggestSource.toLowerCase() == "validationtable"){
            //  Fetch descriptionvalues and clone so we can manipulate them
            this.aSuggestValues = browser.data.clone(this.oVdfForm.getVdfFieldAttribute(this, "aDescriptionValues"));
            
            //  Sort items alphabetically
            this.aSuggestValues.sort(this.suggestCompare);
            
        }else if(this.sSuggestSource.toLowerCase() == "custom"){
            //  Fetch values JSON style and add them to the array
            this.aSuggestValues = new Array();
            
            aValues = eval("([" + this.sSuggestValues + "])");
            for(iValue = 0; iValue < aValues.length; iValue++){
                if(aValues[iValue] != ""){
                    this.aSuggestValues.push({ sValue : aValues[iValue] });
                }
            }
            
            //  Sort items alphabetically
            this.aSuggestValues.sort(this.suggestCompare);
        }
    }
}

//
//  Displays / Updates the suggestionlist. Uses the value in aSuggestOptions or
//  with the find source sends a find request.
//
VdfField.prototype.suggestDisplay = function(){
    var sXml, sFieldXml;
    
    try{
        //  Without value no suggest list should be displayed
        if(this.eElement.value != ""){
            
            //  For validation and custom use the already loaded values.
            if(this.sSuggestSource.toLowerCase() == "validationtable" || this.sSuggestSource == "custom"){
                this.suggestBuildList(this.aSuggestValues, this.eElement.value);
            }else if(this.sSuggestSource.toLowerCase() == "find"){
                //  Append requestsets to the find
                sXml += "<aDataSets>\n";
                sFieldXml = VdfGlobals.soap.getFieldXml(this.sSuggestSourceTable + "__" + this.sSuggestSourceField, this.eElement.value, true);
                
                sXml += VdfGlobals.soap.getRequestSet(this.sDataBinding, "findByField", this.sSuggestSourceTable, this.sSuggestSourceField, sFieldXml, "", dfGE, this.iSuggestLength, this.oVdfForm.getRequestSetUserData("find", this.sDataBinding), false, "", true);

                sXml += "</aDataSets>\n";
            
                // send the request
                this.oVdfForm.sendRequest(sXml, true);
            }
        }else{
             if(this.eSuggestDiv != null){
                this.suggestHide();
            }
        }
    }catch(oError){
        VdfErrorHandle(oError);
    }
}


//
//  Handles the find for the suggestlist. Builds a list of the find results in
//  the [ { sValue : "", sDescription : "" }, { sVal... ] format. And calls the 
//  suggestBuildList method to dislay it.
//
//  Params:
//      oXmlData    The xml response data
//      sName       The name of the Request / Response set
//
//  PRIVATE
VdfField.prototype.handleFindByField = function(oXmlData, sName){
    var aList, aRows, iRow, oDataSet, sValue, sDescriptionValue, sField;
    
    sField = this.sSuggestSourceTable + "__" + this.sSuggestSourceField;    
    aList = [];
    aRows = browser.xml.find(oXmlData, "TAjaxResponseRow");
    for(iRow = 0; iRow < aRows.length; iRow++){
        oDataSet = new VdfDataSet(this, aRows[iRow]);
        
        if(oDataSet.hasValue(sField)){
            sValue = oDataSet.getValue(sField);
            sDescriptionValue = (oDataSet.hasDescriptionValue(sField) ? oDataSet.getDisplayValue(sField) : null);
            if(sValue != ""){
                aList.push({sValue : sValue, sDescription : sDescriptionValue });
            }
        }
    }
    
    // go display the suggestion list
    this.suggestBuildList(aList, this.eElement.value);
    
    return true;   
}

//
//  Builds the suggest list according to the given list of possible values by 
//  checking them agains the current input value. Only displays the items of 
//  which the value matches. Displays the descriptionvalue if this is available
//  in the list.
//
//  Params:
//      aCompleteList   The list of possible values (should already be sorted)
//      sValue          The current value of the field to which the values are
//                      checked.
//
//  PRIVATE
VdfField.prototype.suggestBuildList = function(aCompleteList, sValue){
    var aList, eSuggestDiv, eElement, eTable, iLength, eRow, eCell, sNewSelectedValue = null, iNewSelectedItem = -1;
    
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
    if(this.eSuggestDiv != null){
        //  IE =< 6  have select list z-index bug
        browser.gui.displaySelectBoxes(this.eSuggestDiv);
    
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
        if (browser.isIE){
            eSuggestDiv.style.top = (eElement.offsetHeight + 2) + "px";
            eSuggestDiv.style.left = "1px";
        }
        
        eTable = document.createElement("table");
        eTable.oVdfField = this;
        eTable.cellSpacing = 0;
        
        if(this.bSuggestStaticWidth){
            eSuggestDiv.style.width = (eElement.offsetWidth - 2) + "px";
            eTable.style.width = "100%";
        }
        
        browser.dom.insertAfter(eElement, eSuggestDiv);
        eSuggestDiv.appendChild(eTable);
        
        
        //  For each item generate the row
        for(iItem = 0; iItem < aList.length && iItem < this.iSuggestLength; iItem++){
            eRow = eTable.insertRow(eTable.rows.length)
            eRow.setAttribute("iNum", iItem);
            eRow.setAttribute("sValue", aList[iItem].sValue);
            
            eCell = eRow.insertCell(0);
            eCell.innerHTML = "<b>" + aList[iItem].sValue.substr(0, iLength) + "</b>" + aList[iItem].sValue.substr(iLength);
            
            //  Add description if available
            if(aList[iItem].sDescription != null){
                eCell = eRow.insertCell(1);
                browser.dom.setElementText(eCell, aList[iItem].sDescription);
            }
            
            if(aList[iItem].sValue == this.sSuggestSelectedValue){
                eRow.className = "selected";
                sNewSelectedValue = aList[iItem].sValue;
                iNewSelectedItem = iItem;
            }
            
            browser.events.addGenericListener("mouseover", eRow, this.onSuggestMouseOver);
            browser.events.addGenericListener("click", eRow, this.onSuggestMouseClick);
        }
        
        this.eSuggestDiv = eSuggestDiv;
        this.eSuggestDiv.eTable = eTable;
        
        //  IE =< 6  have select list z-index bug
        browser.gui.hideSelectBoxes(this.eSuggestDiv);
    }
    
    this.sSuggestSelectedValue = sNewSelectedValue;
    this.iSuggestSelectedItem = iNewSelectedItem;
}

//
//  Removes the suggest list if one is displayed.
//
VdfField.prototype.suggestHide = function(){
    if(this.eSuggestDiv != null){
        //  IE =< 6  have select list z-index bug
        browser.gui.displaySelectBoxes(this.eSuggestDiv);
        this.eSuggestDiv.parentNode.removeChild(this.eSuggestDiv);
        this.eSuggestDiv.eTable = null;
        this.eSuggestDiv = null;
        this.sSuggestSelectedValue = null;
        this.iSuggestSelectedItem = -1;
    }
}

//
//  Sets the selected value to the form, performs a FindByField if need and 
//  hides the suggest list.    
//
VdfField.prototype.suggestFinish = function(){
    if(this.sSuggestSelectedValue != null){
        this.setValue(this.sSuggestSelectedValue);
        if(this.bSuggestAutoFind){
            this.oVdfForm.doFindByField(dfGE, this, false);
        }
        this.focusSelect();
    }
    
    this.suggestHide();
}

//
//  Moves the selects the next or the previous row in the suggest list.
//
//  Params:
//      bDown   If true the next row is selected else the previous
//
VdfField.prototype.suggestMoveSelection = function(bDown){
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
}

//
//  Selects a list item using the given row element.
//
//  Params:
//      eRow    The row element to select
//
VdfField.prototype.suggestSelectRow = function(eRow){
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
}       

//
//  Called if a key is pressed in the field. If a special key (tab, escape, 
//  enter, arrow up/down) a special action is undertakenh, otherwise the list 
//  is updated (unless the key is in the special keys list).
//
//  Params:
//      iKeyCode    The pressed keycode
//  Returns:
//      True if special action is done
//
//  PRIVATE
VdfField.prototype.suggestKeyAction = function(iKeyCode){
    var aIgnoreKeys, oVdfField;
    aIgnoreKeys = {9:1, 13:1, 16:1, 27:1, 33:1, 34:1, 35:1, 36:1, 37:1, 38:1, 39:1, 40:1, 46:1, 112:1, 113:1, 114:1, 115:1, 116:1, 117:1, 118:1, 119:1, 120:1, 121:1, 122:1, 123:1};
    
    if(this.eSuggestDiv != null){
        if (iKeyCode == 27 || iKeyCode == 9){ // escape/tab hides the list
            this.suggestHide();
            return true;
        }else if (iKeyCode == 13){ // enter selects the value
            this.suggestFinish();
            return true;
        }else if(iKeyCode == 38 || iKeyCode==40){ // Up and down go trough the list
            this.suggestMoveSelection(iKeyCode == 40);
            return true;
        }
    }
    
    if(!aIgnoreKeys[iKeyCode]){ // Special keys are ignored
        oVdfField = this;
        //  Set a timeout so the list wont show immediately
        setTimeout(function(){
            oVdfField.suggestDisplay();
        }, 200);
    }
    
    return false;
}

//
//  Is called by the array sort method. Compares two suggestionlist objects 
//  { sValue : "value" , sDescription : "descr" } and determines using their 
//  value in which order the belong.
//
//  Params:
//      oSuggestion1    First suggestion object
//      oSuggestion2    Second suggestion object
//  Returns:
//      1 if value the first belongs after the last, -1 if the first belongs 
//      before the last, 0 if a problem occured.
//

VdfField.prototype.suggestCompare = function(oSuggestion1, oSuggestion2){
    sValue1 = oSuggestion1.sValue.toUpperCase();
    sValue2 = oSuggestion2.sValue.toUpperCase();
    try{
        if (sValue1 > sValue2) return 1;
        if (sValue2 > sValue1) return -1;
    }catch(e){

    }
    return 0;
}

//
//  Handles the mouseover event of the suggest list rows and selects the row 
//  that the mouse goes over.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfField.prototype.onSuggestMouseOver = function(e){
    var eSource;
    
    if(!browser.events.canceled(e)){
        try{
            eSource = browser.events.getTarget(e);
            if(eSource == null) return false;
            
            if(eSource.tagName.toLowerCase() != "tr"){
                eSource = browser.dom.searchParent(eSource, "tr");
                if(eSource == null) return false;
            }
            
            eTable = browser.dom.searchParent(eSource, "table");
            if(eTable == null) return false;
            
            eTable.oVdfField.suggestSelectRow(eSource);
        }catch(oError){
            VdfErrorHandle(oError);
        }
    }
}

//
//  Handles the mouseclick event of the suggest list rows. Makes sure the row 
//  is selected and calls the finish method.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfField.prototype.onSuggestMouseClick = function(e){
    var eSource;
    
    if(!browser.events.canceled(e)){
        try{
            eSource = browser.events.getTarget(e);
            if(eSource == null) return false;
            
            if(eSource.tagName.toLowerCase() != "tr"){
                eSource = browser.dom.searchParent(eSource, "tr");
                if(eSource == null) return false;
            }
            
            eTable = browser.dom.searchParent(eSource, "table");
            if(eTable == null) return false;

            eTable.oVdfField.suggestSelectRow(eSource);
            eTable.oVdfField.suggestFinish();
        }catch(oError){
            VdfErrorHandle(oError);
        }
    }
}

//
//  Handles the keypress event of the field element. If a suggestionlist is 
//  used the suggestKeyAction method is called.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfField.prototype.onKeyPress = function(e){
    var eSource;

    if(!browser.events.canceled(e)){
        try{
            eSource = browser.events.getTarget(e);
            if(eSource == null) return false;
            if(eSource.oVdfField == null) return false;
            
            //  Suggest keyaction
            if(eSource.oVdfField.sSuggestSource.toLowerCase() != "none"){
                if(eSource.oVdfField.suggestKeyAction(browser.events.getKeyCode(e))){
                    browser.events.stop(e);
                    return false;
                }
            }
        }catch(oError){
            VdfErrorHandle(oError);
        }
    }
    
    return true;
}

//
//  Is called when the the field is blurred (loses the focus). If the suggest 
//  list is enabled it sets a timeout to hide to list.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfField.prototype.onBlur = function(e){
    var eSource;

    if(!browser.events.canceled(e)){
        try{
            eSource = browser.events.getTarget(e);
            if(eSource == null) return false;
            if(eSource.oVdfField == null) return false;
            
            //  Suggest keyaction
            if(eSource.oVdfField.sSuggestSource.toLowerCase() != "none"){
                setTimeout(function(){ eSource.oVdfField.suggestHide() }, 500);
            }
        }catch(oError){
            VdfErrorHandle(oError);
        }
    }
    
    return true;
}

//  - - - - - - - USER EVENTS - - - - - - - -

//
//  This function is called if the field is validated (only if bValidateClient 
//  = true) and can be used to add custom validation methods. Overriding can be 
//  done in asp file like:
//
//  function initForm(){
//      getVdfControl("form").getField("customer__name").onValidate = function(sDataType){
//          if(this.getValue() == "harm"){
//              VdfErrorHandle(new VdfFieldError(600, "Value harm is not allowed ", this, this.oVdfForm));
//              return false;
//          }else{
//              VdfErrorsClearError(this.sTable, this.sField, 301);
//              return true;
//          }
//      }
//  }
//
//  The function should return true if no validation errors occur. If false is
//  returned the action (save or tabbing out) is cancelled.
//
VdfField.prototype.onValidate = function(sDataType){
    return true;
}