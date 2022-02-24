//
//  Class:
//      VdfGrid
//
//  Extends the DbList to an edit-in-place grid lookalike of the VDF grid.
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

//
//  Constructor of the DbGrid object. Calls the parent (DbList) constructor 
//  and initializes the attributes.
//
//  Params:
//      oTable      HTML DOM element of list table
//      oVdfForm    Parent form object
//
function VdfGrid(oTable, oVdfForm){
    //  Parent initialisation
    this.base = VdfList;
    this.base(oTable, oVdfForm);
    
    //  Settings (may overide list defaults)
    this.sServerTable       = browser.dom.getVdfAttribute(this.oTable, "sServerTable", null);
    
    this.bDetermineWidth    = browser.dom.getVdfAttribute(this.oTable, "bDetermineWidth", false);
    this.bReturnCurrent     = browser.dom.getVdfAttribute(this.oTable, "bReturnCurrent", false);
    this.bJumpIntoList      = browser.dom.getVdfAttribute(this.oTable, "bJumpIntoList", false);
    this.bDisplayNewRow     = browser.dom.getVdfAttribute(this.oTable, "bDisplayNewRow", true);
    this.bFocus             = browser.dom.getVdfAttribute(this.oTable, "bFocus", false);
    
    this.sCssOrigEditRow    = "";
    
    //  Data structures
    this.oEditRow           = null;
    this.aEditFields        = new Object();
    this.oLastEditField     = null;
    this.oFirstEditField    = null;

    this.oLastFocus         = null;
    this.bRowChanged        = false;    

    if(this.sServerTable != null){
        this.sServerTable = this.sServerTable.toLowerCase();
    }
}

//  Extend DbList
VdfGrid.prototype = new VdfList;


//  Rename origional init method so it can be extended
VdfGrid.prototype.origInitAfter = VdfGrid.prototype.initAfter;

//
//  Initializes the grid by searching the edit row prototype and scanning for 
//  fields. Calls initField for each editfield found. When finished origInit is
//  called for the list initialisation part.
//
//  PRIVATE
VdfGrid.prototype.initAfter = function(){
    var iRow, oRow, aChilds, iChild, sColumn, oCurrentElement, oAnchor;

    if(this.oEditRow == null) throw new VdfError(201, "Editrow required", null, null, this.oVdfForm, this);
    this.sCssOrigEditRow = this.oEditRow.className;
    
    //  Create a hidden anchor to detect when the user tabs out of the grid
    oAnchor = document.createElement("a");
    oAnchor.href = "javascript: browser.nothing();";
    oAnchor.style.textDecoration = "none";
    oAnchor.hideFocus = true;
    oAnchor.oVdfList = this;
    
    var eAfter = this.oLastEditField.eElement;
    if(eAfter == null){
        eAfter = this.oLastEditField.aElements[this.oLastEditField.aElements - 1];
    }
    if(eAfter == null){
        this.oTable.parentNode.insertBefore(oAnchor, this.oTable.nextSibling);
        
    }else{
        eAfter.parentNode.appendChild(oAnchor);
    }
    browser.events.addGenericListener("focus", oAnchor, this.onFocusHiddenA);
    
    
    //  Call origional initialisation method
    this.origInitAfter();
}



VdfGrid.prototype.origInitField = VdfGrid.prototype.initField;

//
//  Initialises the given field by attaching events, adding it to the 
//  administration structure and giving it the focus if needed.
//
//  Params:
//      oVdfField   VdfField object
//
//  PRIVATE
VdfGrid.prototype.initField = function(eRow, sRowType, oVdfField){
    var bParent = true;

    if(sRowType == "edit"){
        if(this.oEditRow == null){
            this.oEditRow = eRow;
        }
    
         this.oLastEditField = oVdfField;
         
        //  Attach listeners
        oVdfField.addKeyListener(this.onFieldKeyPress);
        oVdfField.addGenericListener('focus', this.onFieldFocus);
        
        //  Add to administration
        this.aEditFields[oVdfField.getName()] = oVdfField;
        if(this.oFirstEditField == null){
            this.oFirstEditField = oVdfField;
        }
        
        //  Set server table
        if(this.sServerTable != null){
            oVdfField.setServerTable(this.sServerTable, false);
        }
    }else{
        bParent = this.origInitField(eRow, sRowType, oVdfField);
    }
    
    return bParent;
}

//
//  Selects an record by replacing its row with the editrow (filled with the 
//  record values). It tries to reselect the last edited field (column) in the
//  grid.
//
//  Parameters
//      oRecord             The record that should be selected
//
//  PRIVATE
VdfGrid.prototype.selectRecord = function(oRecord, bAuto){  
    var oOrigRow, oEditRow, sCss;
    
    if (typeof(bAuto) == "undefined") bAuto = false;
    if (oRecord){    
        //  Fetch row objects
        oEditRow = this.oEditRow;
        oOrigRow = oRecord.oRow;
               
        //  Set values
        this.bRowChanged = false;
        
        //  Attach css style
        this.oEditRow.className = this.sCssOrigEditRow + " " + (oRecord == this.oNewRecord ? this.sCssNewRow : this.sCssFilledRow) + " " + (oOrigRow.className.contains(this.sCssRowEven) ? this.sCssRowEven : this.sCssRowOdd);
 
        //  Place row        
        browser.dom.swapNodes(oOrigRow, oEditRow);
        oRecord.oOrigRow = oRecord.oRow;
        oRecord.oRow = oEditRow;
        
        //  Reselect field    
        if(this.oVdfForm.oVdfActiveObject == this && !bAuto){
            this.returnToField();
        }
    }
}

//
//  Selects a record by removing the css class
//
//  Params:
//      bNoSave     If true the record will not be saved
//  Returns:
//      True if succesfull
//
//  PRIVATE
VdfGrid.prototype.deSelectRecord = function(bNoSave){
    var oRecord;

    //  Save if needed
    if(bNoSave || !this.isRowChanged() || this.doSave()){
        oRecord = this.oSelectedRecord;
    
        //  Replace row with original
        browser.dom.swapNodes(this.oEditRow, oRecord.oOrigRow);
    
    
        oRecord.oRow = oRecord.oOrigRow;
        oRecord.oOrigRow = null;
        
        return true;
    }else{
        //  Return false if save failed
        return false;
    }
}

//
//  The clear of the grid is special regarding to the find / save / delete 
//  methods. It puts the original buffered values of the selected record back
//  after user confirmation.
//
//  Params:
//      sClearTable Name of the table on which the action should be applied
//  Returns:
//      True if the clear is handled (only handles clear when on maintable of
//      the grid.)
//
VdfGrid.prototype.doClear = function(sClearTable){    
    if(this.sMainTable == sClearTable && this.oSelectedRecord != null){
        if(this.onBeforeClear(this, sClearTable) != false){
            this.oVdfForm.aTables[this.sMainTable].setValues(this.oSelectedRecord, true, false);
            
            this.onAfterClear(this, sClearTable, true);
        }
        return true;
    }else{
        return false;
    }
}

//
//  Used to fetch a field input element from the grid
//
//  Params:
//      sName   Name of the field
//  Returns:
//      Field input element or null if not found
//
//  DEPRECATED
VdfGrid.prototype.getField = function(sName){
    return this.aEditFields[sName];
}

//
//  Checks if the constrain table of the mainfile (if it has one) has an 
//  record loaded. If not it sends an globalerror and returns false.
//
//  Returns:
//      True if access is alowed
//
//  PRIVATE
VdfGrid.prototype.checkAccessAlowed = function(){
    var sConstrainFile, bResult = true;
    
    //  Check constrain file
    sConstrainFile = this.oVdfForm.aTables[this.sMainTable].sConstrainedTo;
    if(sConstrainFile != null){
        if(!this.oVdfForm.aTables[sConstrainFile].hasRecord()){
            if(this.oVdfForm.aTables[sConstrainFile].hasData() && confirm("Save the NEW header? (VdfGrid: " + this.sName + ")")){
                bResult = this.oVdfForm.doSave(sConstrainFile, false);
            }else{
                bResult = false;

                throw new VdfError(202, "Headertable should be saved", null, null, this.oVdfForm, this);
                
                if(this.oVdfForm.oPreviousFocus != null){
                    this.oVdfForm.oPreviousFocus.focusSelect();
                }
            }
        }
    }
    
    return bResult;
}

//
//  Returns:
//      True if the selected row is changed (by find or direct input)
//
VdfGrid.prototype.isRowChanged = function(){
    return this.oVdfForm.aTables[this.sMainTable].isDataChanged(true, false);
}

//
//  (Overloads origional VdfList returnToField) Puts the focus back to the last
//  selected field or gives focus to the first field if none selected.
//
VdfGrid.prototype.returnToField = function(){
    //  Focus last selected field (or first)
    if(this.oLastFocus != null){
        this.oLastFocus.focusSelect();
    }else{
        this.returnToFirstField();
    }
}

//
//  Returns focus to the first field (if has been set)
//
VdfGrid.prototype.returnToFirstField = function(){
    if(this.oFirstEditField != null){
        this.oFirstEditField.focusSelect();
    }
}


//
//  Fetches the keypress event of a grid field in a editeable row. It calls
//  the keyAction function to let the list do its actions.
//
//  Params:
//      e   Event object
// 
VdfGrid.prototype.onFieldKeyPress = function(e){
    var oInput, oTable, oVdfList, iKey;
    
    if(!browser.events.canceled(e)){
        try{
            
            //  Get needed objects and information
            oInput = browser.events.getTarget(e);

            oTable = browser.dom.searchParent(oInput, 'table');
            if(oTable == null)
                return false;
                        
            oVdfList = oTable.oVdfList;
            if(oVdfList == null)
                return false;

        	iKey = browser.events.getKeyCode(e);

            //  Call global list key handling method
            if(oVdfList.keyAction(iKey, browser.events.getCharCode(e), e.ctrlKey, e.shiftKey, e.altKey)){            
                browser.events.stop(e);
                return false;
            }
        }catch(oError){
            VdfErrorHandle(oError);
        }
    }

	return true;	
}


VdfGrid.prototype.onFocusHiddenA = function(e){
    var oAnchor, oVdfList;
    
    if(!browser.events.canceled(e)){
        try{
            oAnchor = browser.events.getTarget(e);
            if(oAnchor == null || oAnchor.oVdfList == null) return false;
            
            oVdfList = oAnchor.oVdfList;
            
            if(oVdfList.bBlurred){
                oVdfList.bBlurred = false;
                
                // If tabbing out the last field select the next
                if(oVdfList.oSelectedRecord == oVdfList.oNewRecord){
                    if(oVdfList.doSave()){
                        oVdfList.scroll(true);
                    }else{
                        oVdfList.oLastFocus.focusSelect();
                    }
                }else{
                    oVdfList.scroll(true);
                }
                oVdfList.oFirstEditField.focusSelect();
                browser.events.stop(e);
                return false;
            }
        }catch(oError){
            VdfErrorHandle(oError);
        }
    }
}

//
//  Called when an input element is selected. It stops the event and saves id 
//  of the selected column.
//
//  Param:
//      e   Event object (on some browsers)
//
VdfGrid.prototype.onFieldFocus = function(e){
    var oInput, oTable, oVdfList;

    if(!browser.events.canceled(e)){
        try{
            //  Get needed objects and information
            oInput = browser.events.getTarget(e);

            oTable = browser.dom.searchParent(oInput, 'table');
            if(oTable == null)
                return false;
                    
            
            oVdfList = oTable.oVdfList;
            if(oVdfList == null)
                return false;
            
            //  The bBlurred property is checked by the onFocusHiddenA to determine wether a field had the focus before
            oVdfList.bBlurred = true;

            //  Check if parents loaded
            if(!oVdfList.checkAccessAlowed()){
                browser.events.stop(e);
            }else{
                //  Save information about the selected object
                if(oVdfList.aEditFields[oInput.name] != null){
                    oVdfList.oVdfForm.oVdfActiveObject = oVdfList;
                    oVdfList.oLastFocus = oVdfList.aEditFields[oInput.name];
                    
                    if(oVdfList.oVdfForm.oPreviousFocus != oVdfList.oVdfForm.oLastFocus){
                        oVdfList.oVdfForm.oPreviousFocus = oVdfList.oVdfFormoLastFocus;
                    }                                   
                    oVdfList.oVdfForm.oLastFocus = oVdfList.aEditFields[oInput.name];
                    
                    browser.events.stop(e);
                }
            }
        }catch(oError){
            VdfErrorHandle(oError);
        }
    }
}

//
//  U S E R   E V E N T S
//
//  Event methods that should be overriden by the user. The onBefore events can
//  be used to cancel the action by returning false. Some events have a default 
//  implementation that can be overridden.
//

VdfGrid.prototype.onBeforeClear = function(oVdfGrid, sTable){
    return confirm("Abandon changes?");
}

VdfGrid.prototype.onAfterClear = function(oVdfGrid, sTable, bSuccess){}
