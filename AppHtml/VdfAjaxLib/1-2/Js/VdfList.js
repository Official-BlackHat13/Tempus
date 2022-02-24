//
//  Class:
//      VdfList
//
//  Base of the scrollable Lookups/Grids.
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
//  Constructor of the DbList object. Initializes the properties.
//
//  Params:
//      oTable   HTML table element representing the list
//      oVdfForm     Parent form object
//
function VdfList(oTable, oVdfForm){
    if(typeof(oVdfForm) != "undefined"){
        //  Main references
        this.oTable             = oTable;
        this.oTable.oVdfList    = this;
        this.oVdfForm           = oVdfForm;
        this.sName              = browser.dom.getVdfAttribute(this.oTable, "sControlName", "List1");
        this.sControlType       = browser.dom.getVdfAttribute(this.oTable, "sControlType", "form");
        this.oVdfForm.aVdfChilds[this.oVdfForm.aVdfChilds.length] = this;
        
        //  Settings
        this.sMainTable         = browser.dom.getVdfAttribute(this.oTable, "sMainTable", this.oVdfForm.sMainTable).toLowerCase();
        this.iIndex             = browser.dom.getVdfAttribute(this.oTable, "iIndex", "");
            
        this.iRowLength         = parseInt(browser.dom.getVdfAttribute(this.oTable, "iRowLength", "10"));
        this.iMinBuffer         = parseInt(browser.dom.getVdfAttribute(this.oTable, "iMinBuffer", (this.iRowLength + 1)));
        this.iMaxBuffer         = parseInt(browser.dom.getVdfAttribute(this.oTable, "iMaxBuffer", (this.iRowLength * 2)));
        
        this.bReturnCurrent     = browser.dom.getVdfAttribute(this.oTable, "bReturnCurrent", true);
        this.bJumpIntoList      = browser.dom.getVdfAttribute(this.oTable, "bJumpIntoList", true);
        this.bMouseWheelSupport = browser.dom.getVdfAttribute(this.oTable, "bMouseWheelSupport", true);
        this.bDisplayNewRow     = browser.dom.getVdfAttribute(this.oTable, "bDisplayNewRow", false);
        this.bDisplayScrollbar  = browser.dom.getVdfAttribute(this.oTable, "bDisplayScrollbar", true);
        this.bHoldFocus         = browser.dom.getVdfAttribute(this.oTable, "bHoldFocus", true);
        this.bFocus             = browser.dom.getVdfAttribute(this.oTable, "bFocus", true);
        this.bAutoLabel         = browser.dom.getVdfAttribute(this.oTable, "bAutoLabel", false);
        this.bFixedColumnWidth  = browser.dom.getVdfAttribute(this.oTable, "bFixedColumnWidth", true);
        this.bDetermineWidth    = browser.dom.getVdfAttribute(this.oTable, "bDetermineWidth", true);
        
        this.sCssHeaderIndex    = browser.dom.getVdfAttribute(this.oTable, "sCssHeaderIndex", "VdfHeaderIndex");
        this.sCssHeaderSelected = browser.dom.getVdfAttribute(this.oTable, "sCssHeaderSelected", "VdfHeaderSelected");
        this.sCssLookupJumper   = browser.dom.getVdfAttribute(this.oTable, "sCssLookupJumper", "VdfLookupJumper");
        this.sCssFilledRow      = browser.dom.getVdfAttribute(this.oTable, "sCssFilledRow", "");
        this.sCssEmptyRow       = browser.dom.getVdfAttribute(this.oTable, "sCssEmptyRow", "");
        this.sCssNewRow         = browser.dom.getVdfAttribute(this.oTable, "sCssNewRow", "");
        this.sCssRowEven        = browser.dom.getVdfAttribute(this.oTable, "sCssRowEven", "VdfRowEven");
        this.sCssRowOdd         = browser.dom.getVdfAttribute(this.oTable, "sCssRowOdd", "VdfRowOdd");
        
        //  Data structures
        this.aHeaderColumns     = new Object();
        this.aColumns           = new Object();
        this.aRecords           = new Array();
        
        this.aStatusFields      = null;
        
        this.oNewRecord         = null;
        this.oSelectedRecord    = null;
        this.iFirstShownRecord  = 0;
        this.bBuffering         = false;
        this.bFilled            = false;
        
        this.oScrollBar         = null;
        this.oPrototypeRow      = null;
        this.oHeaderRow         = null;
        this.oFocusHolder       = null;
    }
}

//
//  Initializes the list. First it scans the (prototype)rows for the needed
//  rows. The it initializes the focusholder, scrollbar, display and newrow.
//
//  PRIVATE
VdfList.prototype.initAfter = function(){
    var iRow, oRow, oFocus, oElement, sColumn, sTable, sStatusField;

    this.initComponents();

    //  Checks
    if(this.oVdfForm.aTables[this.sMainTable].bHasList){
        throw new VdfError(216, "Multiple lists on one DD not allowed", null, null, this.oVdfForm, this);
    }
    this.oVdfForm.aTables[this.sMainTable].bHasList = true;
    
    if(this.oPrototypeRow == null) throw new VdfError(211, "Displayrow required", null, null, this.oVdfForm, this);
    if(this.oHeaderRow == null) throw new VdfError(212, "Headerrow required", null, null, this.oVdfForm, this);
    this.oPrototypeRow.parentNode.removeChild(this.oPrototypeRow); // Remove gently from the DOM
        
    
    if(this.bAutoLabel){
        this.displayHeaderLabels();
    }

    //  Clear the the display
    this.displayClear(this.bDetermineWidth);
    
    //  Insert the newrow if needed
    if(this.bDisplayNewRow){
		this.oNewRecord = new VdfDataSet(this.oVdfForm, null);
        this.aRecords[0] = this.oNewRecord
        this.displayRow(this.oNewRecord, true);
        this.select(this.oNewRecord, true, false);
    }
        
    //  Lock the column width
    if(this.bFixedColumnWidth){
        this.lockColumnWidth();
    }
    
    //  If needed remove test values
    if(this.bDetermineWidth){
        this.displayClear();
    }
    this.displayHeaderCSS();
 
    
    if(this.bDisplayScrollbar){
        var oVdfList = this;
    
        //  Timed function that sets the focus and removes the focus element
        var fSetSizes = function(){
            oVdfList.resizeScrollbar(false);
            oVdfList.positionScrollbar();
        }
        
        setTimeout(fSetSizes, 100);
    }
}

//
//  Is called when a field is found that belongs to the VdfList. Calls the 
//  initField method and forwards the field to the form if needed.
//
//  Params:
//      oField          The VdfField object that belongs to the field
//      sDataBinding    Data bingding of the field
//
//  PRIVATE
VdfList.prototype.addField = function(oField, sDataBinding){
    var bParent = true, eElement = oField.eElement, eRow;
    
    eRow = browser.dom.searchParentByVdfAttribute(eElement, "sRowType", null);
    if(eRow != null){
        bParent = this.initField(eRow, browser.dom.getVdfAttribute(eRow, "sRowType"), oField);
    }
    
    if(bParent){
        this.oVdfForm.addField(oField, sDataBinding);
    }
}

//
//  Is called when a field is added to the list. If it is a header or display 
//  field it is added to the administration after initialisation.
//
//  Params:
//      eRow        Dom row element in which field is located
//      sRowType    Type of the row ("display"/"header")
//      oField      The VdfField to initialise
//  Returns:
//      True if the field should be forwarded to the form
//
//  PRIVATE
VdfList.prototype.initField = function(eRow, sRowType, oField){
    if(sRowType == "header"){
        //  Safe reference to the header row
        if(this.oHeaderRow == null){
            this.oHeaderRow = eRow;
        }
        
        //  Check if exists
        if(this.oVdfForm.oVdfInfo.columnExists(oField.sDataBinding)){
            this.aHeaderColumns[oField.sDataBinding] = oField;
            
            if(oField.getTableName() == this.sMainTable){
                iIndex = this.oVdfForm.oVdfInfo.getColumnProperty(oField.sDataBinding, "iIndex");
                if(iIndex != null && iIndex != "0"){
                    oField.addGenericListener("click", this.onIndexClick);
                }
            }
        }else{
            throw new VdfFieldError(213, "Unknown field in header", oField, this.oVdfForm, this, [ "header" ]);
        }
        
    }else if(sRowType == "display"){
        //  Safe reference to the display row
        if(this.oPrototypeRow == null){
            this.oPrototypeRow = eRow;
        }
        
        //  Check if exists
        
        if(oField.sDataBinding.indexOf("__") >= 0){
            if(this.oVdfForm.oVdfInfo.columnExists(oField.sDataBinding)){
                this.aColumns[oField.sDataBinding] = oField;
            }else{        
                throw new VdfFieldError(213, "Unknown field in display", oField, this.oVdfForm, this, [ "display" ]);
            }
        }
    }else{
        throw new VdfError(213, "Unknown row type", null, null, this.oVdfForm, this, [ sRowType ]);
    }
    
    return false;
}

//
//  Initializes special components (if needed). First initializes the scrollbar 
//  and then it initializes the focus holder.
//
//  PRIVATE
VdfList.prototype.initComponents = function(){
    var oScrollBar, oFocusHolder, oFocus;
    
    //  Initialize scrollbar (if needed)
    if(this.bDisplayScrollbar){
        oScrollBar = new JScrollBar();
        oScrollBar.oSource = this;
        oScrollBar.oDomParent = this.oTable;
        oScrollBar.oScrollElement = this.oTable;
        oScrollBar.onScroll = this.onScroll;
        oScrollBar.construct();    
        this.oScrollBar = oScrollBar;
        this.resizeScrollbar(true);
    }
    
    //  Insert & initialize focus holder (A Element) (if needed)
    if(this.bHoldFocus){
        oFocus = document.createElement("a");
        oFocus.href = "javascript: browser.nothing();";
        oFocus.style.textDecoration = "none";
        oFocus.hideFocus = true;
        browser.events.addKeyListener(oFocus, this.onFocusHolderKey);
        if(this.bJumpIntoList){
            browser.events.addGenericListener("keypress", oFocus, this.onJumpIntoListKey);
        }
        browser.events.addGenericListener("focus", oFocus, this.onFocusHolderFocus);
        this.oTable.parentNode.appendChild(oFocus);
        
        this.oFocusHolder = oFocus;
        oFocus.oVdfList = this;
        
        if(this.bFocus){
            browser.dom.setFocus(oFocus);
        }
    }
    
    //  Attach mousewheel event listener
    if(this.bMouseWheelSupport){
        browser.events.addMouseWheelListener(this.oTable, this.onMouseWheelScroll);
    }
}

//
//  Deselects the selected record and then refills the table with empty rows.
//
//  Params:
//      bOutfillColumns Fills the columns with a maximum length stretch value.
//
VdfList.prototype.displayClear = function(bOutfillColumns){
    var iLoop, oTable = this.oTable;
    
    //  Deselect selected row
    if(this.oSelectedRecord != null){
        this.deSelect(true);
    }
    
    //  Delete all rows
    for(iLoop = oTable.rows.length - 1; iLoop >= 0; iLoop--){
        if(browser.dom.getVdfAttribute(oTable.rows[iLoop], "sRowType") != "header"){
            if(browser.dom.getVdfAttribute(oTable.rows[iLoop], "sRowType") == "edit"){
                oTable.rows[iLoop].parentNode.removeChild(oTable.rows[iLoop]);
            }else{
                if(oTable.rows[iLoop].oRecord != null){
                    oTable.rows[iLoop].oRecord.oRow = null;
                    oTable.rows[iLoop].oRecord = null;
                }
                oTable.deleteRow(iLoop);
            }
        }
    }
    
    //  Fill table with empty rows
    for(iLoop = 0; iLoop < this.iRowLength; iLoop++){
        this.displayEmptyRow((bOutfillColumns));
    }
}

//
//  Inserts a row into the table with the values of the given record.
//
//  Params:
//      oRecord     The record to display
//      bBottom     If true it will be inserted at the bottom
//
//  PRIVATE
VdfList.prototype.displayRow = function(oRecord, bBottom, bBeforeNewRow){
    var oTable = this.oTable, oNewRow, oTempRow, iRow, oOrig = null, oElement;

    if(typeof(bBeforeNewRow) == "undefined"){
        var bBeforeNewRow = false;
    }
    
    //  Fill row
    for(sColumn in this.aColumns){
        this.aColumns[sColumn].setDataSetValue(oRecord);
    }
    
    oNewRow = this.oPrototypeRow.cloneNode(true);

    if(bBottom){
        if(bBeforeNewRow && this.bDisplayNewRow && this.oNewRecord.oRow != null){
            //  Insert before empty row
            this.oNewRecord.oRow.parentNode.insertBefore(oNewRow, this.oNewRecord.oRow);
            
            if(this.hasEmptyRow()){
                for(iRow = 0; iRow < oTable.rows.length && oOrig == null; iRow++){
                    if(browser.dom.getVdfAttribute(oTable.rows[iRow], "sRowType") == "spaceFiller"){
                        oTable.deleteRow(iRow);
                        break;
                    }
                }
            }else{
                for(iRow = 0; iRow < oTable.rows.length && oOrig == null; iRow++){
                    if(browser.dom.getVdfAttribute(oTable.rows[iRow], "sRowType") != "header"){
                        oTable.deleteRow(iRow);
                        break;
                    }
                }
                
                this.iFirstShownRecord++
            }
        }else{
    
            //  Insert at the bottom
            if(this.hasEmptyRow()){
                //  If empty rows available replace with the top row
                for(iRow = 0; iRow < oTable.rows.length && oOrig == null; iRow++){
                    if(browser.dom.getVdfAttribute(oTable.rows[iRow], "sRowType") == "spaceFiller"){
                        oOrig = oTable.rows[iRow];
                    }
                }
                
                browser.dom.swapNodes(oOrig, oNewRow);
            }else{
                //  Else remove row at the top and append to bottom
                for(iRow = 0; iRow < oTable.rows.length && oOrig == null; iRow++){
                    if(browser.dom.getVdfAttribute(oTable.rows[iRow], "sRowType") != "header"){
                        oTable.deleteRow(iRow);
                        break;
                    }
                }
                
                oTempRow = this.oTable.insertRow(this.oTable.rows.length);
                browser.dom.swapNodes(oTempRow, oNewRow);
                
                this.iFirstShownRecord++
            }
        }
    }else{
        //  Insert at the top (delete from bottom, insert new row at top)
        oTable.deleteRow(oTable.rows.length - 1);
        oOrig = oTable.insertRow(1);
        browser.dom.swapNodes(oOrig, oNewRow);
        this.iFirstShownRecord--;
    }
    
    //  Attach eventlisteners & css sheets
    browser.events.addGenericListener("click", oNewRow, this.onRecordClick);
    browser.events.addGenericListener("dblclick", oNewRow, this.onRecordDoubleClick);
    browser.events.addGenericListener("mouseover", oNewRow, this.onRecordMouseOver);
    browser.events.addGenericListener("mouseout", oNewRow, this.onRecordMouseOut);
    if(oRecord == this.oNewRecord && this.sCssNewRow != ""){
        oNewRow.className = this.sCssNewRow;
    }else if(this.sCssFilledRow != ""){
        oNewRow.className = this.sCssFilledRow;
    }
    
    //  Set CSS class for even / odd rows
    sRowType = this.sCssRowOdd;
    if (oNewRow.rowIndex > 1){
        if (oTable.rows[oNewRow.rowIndex-1].className.contains(this.sCssRowOdd)) sRowType = this.sCssRowEven;
    }
    if (sRowType!= this.sCssRowEven && oNewRow.parentNode.rows.length-1 > oNewRow.rowIndex){
        if (oTable.rows[((oNewRow.rowIndex*1)+(1))].className.contains(this.sCssRowOdd)) sRowType = this.sCssRowEven;
    }
    oNewRow.className = oNewRow.className + " " + sRowType;
    
    
    oRecord.oRow = oNewRow;
    oNewRow.oRecord = oRecord;
    
    //  Call user event
    this.onAfterDisplayRow(this, oRecord);
}

//
//  Inserts an empty row into (at the end) the table.
//
//  PRIVATE
VdfList.prototype.displayEmptyRow = function(bOutfillColumn){
    var oNewRow, sColumn, oTempRow;

    
    for(sColumn in this.aColumns){
        if(bOutfillColumn){
            this.aColumns[sColumn].setValue(this.getStretchValue(sColumn));
        }else{
            if(this.aColumns[sColumn].sType == "dom"){  //  Only fields of type dom have innerHTML and need to be filled to be displayed
                this.aColumns[sColumn].eElement.innerHTML = "&nbsp;";
            }
        }
    }
    
    oNewRow = this.oPrototypeRow.cloneNode(true);
    browser.dom.setVdfAttribute(oNewRow, "sRowType", "spaceFiller");
        
    oTempRow = this.oTable.insertRow(this.oTable.rows.length);
    browser.dom.swapNodes(oTempRow, oNewRow);
    
    //  Attach eventlisteners & css sheets
    browser.events.addGenericListener("click", oNewRow, this.onEmptyRowClick);
    if(this.sCssEmptyRow != ""){
        oNewRow.className = this.sCssEmptyRow;
    }
}

//
//  It clears the displayed table and refills it with records from the buffer.
//
VdfList.prototype.displayRefresh = function(){
    var iLoop;

    this.displayClear();
    
    for(iLoop = this.iFirstShownRecord; iLoop < this.aRecords.length && iLoop < (this.iRowLength + this.iFirstShownRecord); iLoop++){
        if(iLoop < this.aRecords.length){
            this.displayRow(this.aRecords[iLoop], true);
        }
    }    
}

//
//  Loop through header elements with data binding and set the header style (if
//  column has usable index / selected index).
//
VdfList.prototype.displayHeaderCSS = function(){
    var aChilds, iChild, sColumn, iIndex, iWidth;

    for(sColumn in this.aHeaderColumns){
        sColumn = sColumn.toLowerCase();            
        
        //  Set styles for index columns and selected indexes
        if(this.aHeaderColumns[sColumn].sTable == this.sMainTable){
            iIndex = this.oVdfForm.oVdfInfo.getColumnProperty(sColumn, "iIndex");
            if(iIndex == this.getIndex()){
                if(this.aHeaderColumns[sColumn].getCSSClass() == this.sCssHeaderSelected){
                    this.aHeaderColumns[sColumn].setCSSClass(this.sCssHeaderSelected + " ReverseSort");
                }else{
                    this.aHeaderColumns[sColumn].setCSSClass(this.sCssHeaderSelected);
                }
                
            }else if(iIndex != null && iIndex != "0"){
                this.aHeaderColumns[sColumn].setCSSClass(this.sCssHeaderIndex);
            }
        } 
    }
}    


//
//  Loops through the elements of the header row and if databinding is set it 
//  loads the datadictionary label into the element. Uses Shortlabel and if not 
//  available Longlabel is used.
//
VdfList.prototype.displayHeaderLabels = function(){
    var sColumn, sLabel;

    for(sColumn in this.aHeaderColumns){
        sLabel = this.oVdfForm.oVdfInfo.getColumnProperty(sColumn, "sShortLabel");
        if(sLabel == null || sLabel == ""){
            sLabel = this.oVdfForm.oVdfInfo.getColumnProperty(sColumn, "sLongLabel");
            if(sLabel == null || sLabel == ""){
                sLabel = sColumn;
            }
        }
        
        this.aHeaderColumns[sColumn].setValue(sLabel);
    }
}

//
//  Calculates stretchvalue for the given column. This is a value that has the 
//  maximum length for the column. Used to determine the fixed column width.
//
//  Params:
//      sColumn Name of the column
//  Returns:
//      Value that has the maximum length
//
//  PRIVATE
VdfList.prototype.getStretchValue = function(sColumn){
    var iLength, iCurrent, sValuesType;

    iLength = parseInt(this.oVdfForm.oVdfInfo.getColumnProperty(sColumn, "iDataLength"));
    sType = this.oVdfForm.oVdfInfo.getColumnProperty(sColumn, "sDataType");
    sValue = "";
    
    if(sType == "ascii" || sType == "text"){
        for(iCurrent = 0; iCurrent < iLength; iCurrent++){
            sValue += "W";
        }
    }else if(sType == "bcd"){
        for(iCurrent = 0; iCurrent < iLength; iCurrent++){
            sValue += "8";
        }
        iLength = parseInt(this.oVdfForm.oVdfInfo.getColumnProperty(sColumn, "iPrecision"));
        if(iLength > 0){
            sValue += this.oVdfForm.oVdfInfo.sDecimalSeparator;
        }
        for(iCurrent = 0; iCurrent < iLength; iCurrent++){
            sValue += "8";
        }
    }else if(sType == "date"){
        sValue = this.oVdfForm.oVdfInfo.sDateMask.toLowerCase().replace('m','8').replace('y', '8').replace('d', '8');
    }
    
    return sValue;
}

//
//  Loops through the elements in the header row and for each column it sets the 
//  current width to the width in style so it won't change any more.
//
VdfList.prototype.lockColumnWidth = function(){
    var sColumn;
    
    for(sColumn in this.aColumns){
        this.aHeaderColumns[sColumn].eElement.style.width = this.aHeaderColumns[sColumn].eElement.clientWidth + "px";
    }
}


//
//  Determines if the list should be refilled with the form find. This should 
//  only be done if the the maintable is the maintable of the list or a direct
//  constrained parent from the lists maintable.
//
//  Params:
//      sRequestFile    Name of the table on which the action is performed
//  Returns:
//      String with the parent requestset
//
//  PRIVATE
VdfList.prototype.getFindRequestSets = function(sRequestFile){
    var oMainTable = this.oVdfForm.aTables[this.sMainTable];
    
	if(this.sMainTable == sRequestFile || oMainTable.isTableDirectConstrainedParent(sRequestFile)){
        return this.getParentRequestSet(sRequestFile, "", "", this.sMainTable == sRequestFile);
    }else{
        return "";
    }
}

//
//  Determines if the list should be refilled with the form delete. This should 
//  only be done if the delete table is a direct constrained parent of the 
//  maintable of the list. If the delete is on the maintable of the list a 
//  special refresh is done.
//
//  Params:
//      sRequestFile    Name of the table on which the action is performed
//  Returns:
//      String with the parent requestset or the special refresh requestset
//
//  PRIVATE
VdfList.prototype.getDeleteRequestSets = function(sRequestFile){
    var oMainTable, iPosition;
    
    oMainTable = this.oVdfForm.aTables[this.sMainTable];
    
    if(this.sMainTable == sRequestFile){
        //  Determine wich record should be selected after the delete
        iPosition = this.getRecordNr(this.oSelectedRecord) + 1;
        if(iPosition < this.aRecords.length){
            return this.getRefreshRequestSets(this.aRecords[iPosition]);
        }else{
            return this.getRefreshRequestSets(null, true);
        }
    }else if(oMainTable.isTableConstrainedParent(sRequestFile)){
        return this.getParentRequestSet();
    }else{
        return "";
    }
}

//
//  Determines if the list should be refilled with the form save. This should 
//  only be done if the save table is a direct constrained parent of the 
//  maintable of the list. If the save is on the maintable of the list a special
//  refresh is done.
//
//  Params:
//      sRequestFile    Name of the table on which the action is performed.
//      bAutoClearDeoState  If true a Refresh is done instead of a refill.
//  Returns:
//      String with the parent requestset or the special refresh requestset
//
//  PRIVATE
VdfList.prototype.getSaveRequestSets = function(sRequestFile, bAutoClearDeoState){
    var oMainTable = this.oVdfForm.aTables[this.sMainTable];
    
    if(this.sMainTable == sRequestFile){
        return this.getRefreshRequestSets();
    }else if(oMainTable.isTableConstrainedParent(sRequestFile)){
        if(bAutoClearDeoState){
            return this.getParentRequestSet();
        }else{
            return this.getRefreshRequestSets();
        }
    }else{
        return "";
    }
}

//
//  Determines if the list should be refilled with the form clear. This should
//  only be done if the clear table is direct constrained parent of the 
//  maintable of the list.
//
//  Params:
//      sRequestFile    Name of the table on which the action is performed
//  Returns:
//      String with the parent requestset or empty string if no refill is needed
//
//  PRIVATE
VdfList.prototype.getClearRequestSets = function(sRequestFile){
    var oMainTable = this.oVdfForm.aTables[this.sMainTable];
	if(oMainTable.isTableConstrainedParent(sRequestFile)){
        return this.getParentRequestSet();
    }else{
        return "";
    }
}

//
//  On a fill request the list should always be (re)filled.
//
//  Params:
//      sRequestFile    Name of the table on wich the action is performed
//  Returns:
//      String with xml requestset
//
//  PRIVATE
VdfList.prototype.getFillRequestSets = function(sRequestFile){
    return this.getParentRequestSet(sRequestFile, "", "_Fill", true);
}

//
//	Generates requestset needed to refill the table when action is er performed
//	on the parent.
//
//  Returns:
//		String with requestset to refill the table
//
//  PRIVATE
VdfList.prototype.getParentRequestSet = function(sRequestFile, sFieldValues, sNameExtend, bReturnCurrent){
    if (typeof(sFieldValues) == "undefined") var sFieldValues = "";
    if (typeof(sNameExtend) == "undefined") var sNameExtend = "";
    if (typeof(bReturnCurrent) == "undefined") var bReturnCurrent = this.bReturnCurrent;
    
    return this.getDefaultRequestSet("find", this.iRowLength, null, true, bReturnCurrent, "Full" + sNameExtend, false, true, sFieldValues);
}

//
//  Generates requestset(s) needed for a full refresh of the list. It makes sure 
//  the given record will be reselected when handling the requestset(s).
//
//  Params:
//      oSelectRecord   Record that must be selected after refresh
//  Returns:
//      String with refresh requestsets
//
//  PRIVATE
VdfList.prototype.getRefreshRequestSets = function(oSelectRecord){
    var iPosition = 0, sField, sRowIdValues = "";
    var sXml = new JStringBuilder();
    
    if(typeof(oSelectRecord) == "undefined"){
        var oSelectRecord = this.oSelectedRecord;
    }
    
    //  Determine position of the selectrecord
    if(oSelectRecord != null){
        iPosition = this.getRecordNr(oSelectRecord) - this.iFirstShownRecord;
    }
    
    if(oSelectRecord == this.oNewRecord){
        //  Complete refresh in one requestset from bottom to top (last (new)record will be selected)
        sXml.append(this.getDefaultRequestSet("find", this.iRowLength + this.iMaxBuffer, oSelectRecord, false, true, "Refresh_CompleteTop", true, false));
    }else if(oSelectRecord == null){
        //  Complete refresh in one requerstset from top to bottom (first record will be selected)
        sXml.append(this.getDefaultRequestSet("find", this.iRowLength + this.iMaxBuffer, oSelectRecord, true, true, "Refresh_CompleteBottom", false, false));
    }else{
        //  Two requestsets from selected to top and from selected to bottom + two status findByRowId requestsets
        for(sField in this.oVdfForm.aStatusFields){
            if(sField == (this.sMainTable + "__rowid")){
                sRowIdValues += VdfGlobals.soap.getFieldXml(sField, oSelectRecord.getValue(sField), true);
            }else{
                sRowIdValues += VdfGlobals.soap.getVdfFieldXml(this.oVdfForm.aStatusFields[sField]);
            }
        }
    
        sXml.append(this.getRequestSet("findByRowId", "", 1, sRowIdValues, true, false, "Status", "", false));
        sXml.append(this.getDefaultRequestSet("find", iPosition + this.iMaxBuffer, null, false, false, "Refresh_Top", false, true));
        sXml.append(this.getRequestSet("findByRowId", "", 1, sRowIdValues, true, false, "Status", "", false));
        sXml.append(this.getDefaultRequestSet("find", this.iRowLength - iPosition + this.iMaxBuffer, null, true, true, "Refresh_Bottom", false, true));
    }
    
    return sXml.toString();
}


//
//  Generates an Xml request set with the given properties and using the given
//  record for data. Uses the getRequestSetUserData of the form to fetch user 
//  data.
//
//  Params:
//      sRequestType    Type of request
//      iMaxRows        Maximum number of rows returned
//      oRecord         Record used to fill the RequestSet
//      bBottom         True if requesting records at after oRecord
//      bReturnCurrent  True if current file value should be returned
//      sType           String used to find correct way to handle response
//      bParentStatus   If true the status of the parents is added
//      bNoClear        True if requestset depends on previous
//  Returns:
//      String with Xml requestset
//
//  PRIVATE
VdfList.prototype.getDefaultRequestSet = function(sRequestType, iMaxRows, oRecord, bBottom, bReturnCurrent, sType, bParentStatus, bNoClear, sAddFieldValues){
    var sFieldValues;
        
    //  Fetch    
    sFieldValues = this.getXmlValues(oRecord, (typeof(bParentStatus) != "boolean" || bParentStatus));
    
    if (typeof(sAddFieldValues) != "undefined") sFieldValues = sAddFieldValues + sFieldValues;
    
    if(typeof(bReturnCurrent) == "undefined"){
        var bReturnCurrent = this.bReturnCurrent;
    }
    
    if(typeof(sType) == "undefined"){
        var sType = "";
    }
    
    if(typeof(bNoClear) == "undefined"){
        var bNoClear = false;
    }
    
    return this.getRequestSet(sRequestType, "", iMaxRows, sFieldValues, bBottom, bReturnCurrent, sType, null, bNoClear);
}

//
//  Generates an request set according to the given properties using the given
//  data. Uses the getRequestSetUserData of the form to fetch user data.
//
//  Params:
//      sRequestType    Type of the request (find/save/delete/clear..)
//      iMaxRows        MAximum number of rows returned
//      sFieldValues    String with xml containing the field values
//      bBottom         True if request records for the bottom of the list
//      bReturnCurrent  True fi the current buffer value should be returned
//      sType           String determining how the result should be handled
//      sFindMode       Mode used for the find
//      bNoClear        True if requestset depends on previous
//  Returns:
//      String with XML requestset
//
//  PRIVATE
VdfList.prototype.getRequestSet = function(sRequestType, sColumn, iMaxRows, sFieldValues, bBottom, bReturnCurrent, sType, sFindMode, bNoClear){
    var sName = this.sName;
    
    if(typeof(sFindMode) == "undefined" || sFindMode == null){
        if(bBottom){
            var sFindMode = (this.bReverseIndex ? dfLT : dfGT);
        }else{
            sFindMode = (this.bReverseIndex ? dfGT : dfLT);
        }
    }
    
    if(typeof(bReturnCurrent) == "undefined"){
        var bReturnCurrent = this.bReturnCurrent;
    }
    
    if(typeof(sType) == "string"){
        sName += "_" + sType;
    }
    
    if(typeof(bNoClear) == "undefined"){
        var bNoClear = false;
    }
    
    return VdfGlobals.soap.getRequestSet(sName, sRequestType, this.sMainTable, sColumn, sFieldValues, this.getIndex(), sFindMode, iMaxRows, this.oVdfForm.getRequestSetUserData(sRequestType, this.sName), bReturnCurrent, "", bNoClear);
}

//
//  Generates the request xml for the field containing the values of oRecord
//
//  Params:
//      	oRecord     	Record to get the values of (null if empty)
//      	bParentStatus	If true the parents status fields are added
//		bChangedState	(Optional) Changedstate for value fields
//          bStatusFields   (Optional) Append Status field values or not, 
//                          default true, settting this to false will also
//                          overwrite bParentStatus
//  Returns:
//      String with Request Xml
//
//  PRIVATE
VdfList.prototype.getXmlValues = function(oRecord, bParentStatus, bChangedState, bStatusFields){
    var sField, sName, aFields;
    var sXml = new JStringBuilder();
    
    if(typeof(bParentStatus) == "undefined"){
        var bParentStatus = true;
    }

    if(typeof(bStatusFields) == "undefined"){
        var bStatusFields = true;
    }

    //  Get child status fields
    if(this.aStatusFields == null){
        this.aStatusFields = this.oVdfForm.aTables[this.sMainTable].getFields(true, false, true, false);
    }
    
    for(sName in this.aStatusFields){
        if(oRecord != null && oRecord && bStatusFields){
            if (typeof(oRecord.aValues[sName])=="undefined") oRecord.aValues[sName]="";
            sXml.append(VdfGlobals.soap.getFieldXml(sName, oRecord.aValues[sName], (bChangedState)));
        }else{
            sXml.append(VdfGlobals.soap.getFieldXml(sName, ""));
        }
    }

    
    if(bParentStatus){
        for(sName in this.oVdfForm.aStatusFields){
            if(this.aStatusFields[sName] == null && bStatusFields){
                sXml.append(VdfGlobals.soap.getFieldXml(sName, this.oVdfForm.aStatusFields[sName].getValue()));
            }
        }
    }
        
    //  Append field values
    for(sName in this.aColumns){
        if(oRecord != null){
            sXml.append(VdfGlobals.soap.getFieldXml(sName, oRecord.aValues[sName], (bChangedState)));
        }else{
            sXml.append(VdfGlobals.soap.getFieldXml(sName, ""));
        }
    }
    
    return sXml.toString();
}

//
//  Refills the list starting at the given value. Generates an request set with
//  the parent status info, the index fields filled with the value and empty 
//  fields. The requests special name is "ValueFind".
//
//  Params:
//      sValue  The value to find on
//      sName   Name of the column
//
VdfList.prototype.findByColumn = function(sValue, sName){
	var oRecord, iIndex, sName, sFieldValues, sColumn;
	var sXml = new JStringBuilder();
   
	//	Fetch DataSet
	oRecord = this.oSelectedRecord;
	
	//	Set Values of index fields
	if (oRecord){
	    oRecord.setValue(sName, sValue);
	}
	
	//	Convert to xml
	sFieldValues = this.getXmlValues(oRecord, true, true, true);
    
    sColumn = sName.substr(sName.indexOf('__') + 2);
    
    //  Fetch requestsets
    sXml.append("<aDataSets>\n");
    sXml.append(this.getRequestSet("findByField", sColumn, this.iRowLength / 2 + this.iMaxBuffer + 1, sFieldValues, false, false, "ValueFind_Top", (this.bReverseIndex ? dfGE : dfLE), false));
	sXml.append(this.getRequestSet("findByField", sColumn, this.iRowLength - (this.iRowLength / 2) + this.iMaxBuffer, sFieldValues, true, false, "ValueFind_Bottom", (this.bReverseIndex ? dfLE : dfGE), false));
	sXml.append("</aDataSets>\n");
    
    //  Send Request
    this.oVdfForm.sendRequest(sXml.toString(), false);
}

//
//  Sends an asynchronous buffer request (if needed)
//
//  Params:
//      iDirection  If positive it buffers only at top, if negative only at 
//                  bottom (so 0 buffers both)
//
VdfList.prototype.buffer = function(iDirection){
    var saDataSets, oRecord, iBottomBuffer, bSend = false, iLoop, oNew;
    
    //  Save emptyrow record if needed
    if(this.bDisplayNewRow){
        oNew = this.aRecords.pop();
    }
    
    //  Check top buffer
    saDataSets = "<aDataSets>\n";
    if(iDirection <= 0 && this.iFirstShownRecord < this.iMinBuffer){
        if(this.aRecords.length > 0 && this.aRecords[0] != this.oNewRecord){
            oRecord = this.aRecords[0];
        }else{
            oRecord = null;
        }
        
        bSend = true;        
        saDataSets += this.getDefaultRequestSet("find", (this.iMaxBuffer - this.iFirstShownRecord), oRecord, false, false, "_Buffer_Top", false, false);
    }else if(this.iFirstShownRecord > this.iMaxBuffer){
        while(this.iFirstShownRecord > this.iMaxBuffer){
            this.aRecords.shift();            
            this.iFirstShownRecord--;
        }
    }
    
    //  Check bottom buffer
    iBottomBuffer = this.aRecords.length - this.iRowLength - this.iFirstShownRecord;
    if(iDirection >= 0 && iBottomBuffer < this.iMinBuffer){
        if(this.aRecords.length > 0){
            oRecord = this.aRecords[(this.aRecords.length - 1)];
            
            if(oRecord == this.oNewRecord){
                oRecord = this.aRecords[(this.aRecords.length - 2)];
            }
        }else{
            oRecord = null;
        }
        
        bSend = true;
        saDataSets += this.getDefaultRequestSet("find", (this.iMaxBuffer - iBottomBuffer), oRecord, true, false, "_Buffer_Bottom", false, false);
    }else if(iBottomBuffer > this.iMaxBuffer){
        while(iBottomBuffer > this.iMaxBuffer){
            this.aRecords.pop();
            iBottomBuffer--;
        }
    }
    saDataSets += "</aDataSets>\n";
    
    //  Restore emptyrow record if needed
    if(this.bDisplayNewRow){
        this.aRecords.push(oNew);
    }
    
    //  If needed send request
    if(bSend && !this.bBuffering){
        this.bBuffering = true;
        this.oVdfForm.sendRequest(saDataSets, true);
    }
}

//
//  Handles the result of a FindByRowId request (that comes from the VdfForm). 
//  It filters custom requests from autorequests by the name.
//
//  Params:
//      oXmlData    The xml data element
//      sName       The name of the request
//  Returns:
//      True if successfully handled
//
//  PRIVATE
VdfList.prototype.handleFindByRowId = function(oXmlData, sName){
    if(sName.indexOf("_Custom") != -1){
        return this.handleCustomFindByRowId(oXmlData, sName);
    }else{
        return this.handleAutoFindByRowId(oXmlData, sName);
    }
}

//
//  Switches between the different AutoFindByRowId handling methods. 
//
//  Params:
//      oXmlData    The xml data element
//      sName       The name of the request
//  Returns:
//      True if successfully handled
//
//  PRIVATE
VdfList.prototype.handleAutoFindByRowId = function(oXmlData, sName){
    if(sName.indexOf("_Fill") != -1){
        return true;
    }else if(sName.indexOf("_Status") != -1){
        //  Rowid finds are used to refill the DD's sometimes
        return true;
    }else{
        throw new VdfError(215, "Unknown autofind request", null, null, this.oVdfForm, this, [ sName ]);
        return false;
    }
}

//
//  Handles the result of a findByField request which is forwarded by the 
//  VdfForm. It parses the rows in the xml data and switched to the correct 
//  handling method (Only ValueFind uses findByField currently).
//
//  Params:
//      oXmlData    XML tree containing the find resultset
//      sName       Name of the requestset
//
//  PRIVATE
VdfList.prototype.handleFindByField = function(oXmlData, sName){
    var aXmlRecords, iCurrent, aNew = new Array(), bResult = false;
    
    //  Parse records
    aXmlRecords = browser.xml.find(oXmlData, "TAjaxResponseRow");
    for(iCurrent = 0; iCurrent < aXmlRecords.length; iCurrent++){
        aNew[iCurrent] = new VdfDataSet(this.oVdfForm, aXmlRecords[iCurrent]);
    }

    //  Switch to the correct handling method
    if(sName.indexOf("_ValueFind") != -1){
        bResult = this.handleAutoFindValue(aNew, sName);
    }
    
    //  Position scrollbar
    this.positionScrollbar();
    
    return bResult;
}


//
//  Handles the result of a find request (given by the VdfForm). It parses the 
//  xml data and handles it according to the type (in the name of the request).
//
//  Params:
//      oXmlData    The xml data element
//      sName       The name of the request
//  Returns:
//      True if successfully handled
//
//  PRIVATE
VdfList.prototype.handleFind = function(oXmlData, sName){
    if(sName.indexOf("_Custom") != -1){
        return this.handleCustomFind(oXmlData, sName);
    }else{
        return this.handleAutoFind(oXmlData, sName);
    }
}

//
//  Switches to the correct autofind handling method (buffer / refresh / full)
//  with the records parsed from the given xml and positions the scrollbar 
//  after handling the request.
//
//  Params:
//      oXmlData    XML data element containing new records
//      sName       Name of the request (containing information about the type)
//  Returns:
//      True if successfully handled
//
//  PRIVATE
VdfList.prototype.handleAutoFind = function(oXmlData, sName){
    var aXmlRecords, iCurrent, aNew = new Array(), bResult = false;
    
    //  Parse records
    aXmlRecords = browser.xml.find(oXmlData, "TAjaxResponseRow");
    for(iCurrent = 0; iCurrent < aXmlRecords.length; iCurrent++){
        aNew[iCurrent] = new VdfDataSet(this.oVdfForm, aXmlRecords[iCurrent]);
    }

    //  Switch to correct handling procedure
    if(sName.indexOf("_Buffer") != -1){
        bResult = this.handleAutoFindBuffer(aNew, sName);
    }else if(sName.indexOf("_Refresh") != -1){
        bResult = this.handleAutoFindRefresh(aNew, sName);
    }else if(sName.indexOf("_Full") != -1){
        bResult = this.handleAutoFindFill(aNew, sName);
    }else{
        throw new VdfError(215, "Unknown autofind request", null, null, this.oVdfForm, this, [ sName ]);
    }
    
    //  Position scrollbar
    this.positionScrollbar();
    
    return bResult;
}

//
//  Handles an full request (after find/clear/delete on parent). It clears the
//  complete buffer, refills and redisplays it.
//
//  Params:
//      aNewRecords     Array with new records
//      sName           Name of the request
//  Returns:
//      True if successfully handled
//
//  PRIVATE
VdfList.prototype.handleAutoFindFill = function(aNewRecords, sName){
    var bReverse, iSelect;
  
    if(!sName.contains("_Fill") || !this.bFilled){
        this.bFilled = true; // Make sure it is only filled on initialisation if no other fill action is done.
  
        bReverse = (sName.indexOf("_Reverse") != -1);
        
        if(bReverse){
            //  scrollToEnd fills bottom up and selects last record
            this.aRecords = aNewRecords.reverse();
        }else{
            this.aRecords = aNewRecords;
        }
        
        //  Add new record if needed
        if(this.bDisplayNewRow){
            this.aRecords.push(this.oNewRecord);
        }

        if(bReverse){
            this.iFirstShownRecord = this.aRecords.length - 1;
            iSelect = this.aRecords.length - 1;
        }else{
            iSelect = 0;
            this.iFirstShownRecord = 0;
        }

        //  Refresh display
        this.displayRefresh();
        if(this.aRecords.length > 0){
            this.select(this.aRecords[iSelect], true, true);
        }else{
            if (this.oVdfForm.aTables[this.sMainTable]) this.oVdfForm.aTables[this.sMainTable].setValues(new VdfDataSet(this.oVdfForm, null), true, false);
        }
       
        //  Buffer asynchronous
        this.buffer(0);
    }
    
    return true 
}

//
//  Handles buffer response by adding records to the buffer on the top or the 
//  bottom. If space in the table the records are also displayed in the 
//  table.
//
//  Params:
//      aNewRecords     Array with new records
//      sName           Name of the request
//  Returns:
//      True if successfully handled
//
//  PRIVATE
VdfList.prototype.handleAutoFindBuffer = function(aNewRecords, sName){
    if(sName.indexOf("_Top") != -1){
        this.iFirstShownRecord += aNewRecords.length;
        this.aRecords = aNewRecords.reverse().concat(this.aRecords);
        
        //  If there are empty rows fill the table
        while(this.iFirstShownRecord > 0 && this.hasEmptyRow()){
            this.displayRow(this.aRecords[this.iFirstShownRecord - 1], false);
        }
    }else{
        //  TODO: How to handle the editrow?
        if(this.bDisplayNewRow){
            this.aRecords.pop();
        }

        //  If there are empty rows fill the table
        while(aNewRecords.length > 0){
            oNewRecord = aNewRecords.shift();
            this.aRecords.push(oNewRecord);
            
            if(this.hasEmptyRow()){
                this.displayRow(oNewRecord, true, true);
            }
            
        }
        
        //  If needed add the newrecord again
        if(this.bDisplayNewRow){
            this.aRecords.push(this.oNewRecord);
        }
    }
    
    this.bBuffering = false;
    
    return true;
}

//
//  Handles the different refresh responsesets, these are generated using the 
//  getRefreshRequestSets methods. It refreshes the display and reselects the
//  correct records.
//  
//  Params:
//      aNewRecords     Array with new records
//      sName           Name of the request
//  Returns:
//      True if successfully handled
//
//  PRIVATE
VdfList.prototype.handleAutoFindRefresh = function(aNewRecords, sName){
    var iSelect, bBuffer = false;
    
    if(sName.indexOf("_CompleteTop") != -1){
        //  Complete refresh, all records are refound and last is selected
        if(this.oSelectedRecord == null || this.deSelect(true)){
            this.aRecords = aNewRecords.reverse();
            
            if(this.bDisplayNewRow){
                this.aRecords.push(this.oNewRecord);
            }
            
            this.iFirstShownRecord = this.aRecords.length - this.iRowLength;
            if(this.iFirstShownRecord < 0) this.iFirstShownRecord = 0;
            
            this.displayRefresh();
            
            if(this.aRecords.length > 0){
                this.select(this.aRecords[this.aRecords.length - 1], false, true);
            }
            
            this.buffer(0);
        }
    }else if(sName.indexOf("_CompleteBottom") != -1){
        //  Complete refresh, all records are refound and first is selected
        if(this.oSelectedRecord == null || this.deSelect(true)){
            this.aRecords = aNewRecords;
            
            if(this.bDisplayNewRow){
                this.aRecords.push(this.oNewRecord);
            }
            
            this.iFirstShownRecord = 0;
            
            this.displayRefresh();
            
            if(this.aRecords.length > 0){
                this.select(this.aRecords[0], false, true);
            }
            
            this.buffer(0);
        }
    }else if(sName.indexOf("_Top") != -1){
        //  The records above are found first
        this.iSelectAfterRefresh = this.getRecordNr(this.oSelectedRecord) - this.iFirstShownRecord;
        
        if(this.oSelectedRecord == null || this.deSelect(true)){
            this.aRecords = aNewRecords.reverse();
        }
    }else if(sName.indexOf("_Bottom") != -1){
        //  Then the records below are found
        if(this.oSelectedRecord == null){
            iSelect = this.aRecords.length;
            this.iFirstShownRecord = iSelect - this.iSelectAfterRefresh;
            if(this.iFirstShownRecord < 0) this.iFirstShownRecord = 0;
            
            this.aRecords = this.aRecords.concat(aNewRecords);
            
            if(this.bDisplayNewRow){
                this.aRecords.push(this.oNewRecord);
            }
            
            //  Move selected view frame up according to results
            while((this.iFirstShownRecord + this.iRowLength) > this.aRecords.length && this.iFirstShownRecord > 0){
                this.iFirstShownRecord--;
                bBuffer = true;
            }
            
            this.displayRefresh();
            
            if(this.aRecords.length > iSelect){
                this.select(this.aRecords[iSelect], false, true);
            }else{
                this.select(this.aRecords[this.aRecords.length - 1], false, true);
            }
            
            if(bBuffer){
                this.buffer(0);
            }
        }
        
        this.iSelectAfterRefresh = null;
    }   
    
    return true;
}

//
//  Handles the result of the find on value using the current index. It displays 
//  the results and selects the first records. It does nothing if there are no 
//  results. 
//
//  Params:
//      aNewRecords     Array with new records
//      sName           Name of the request
//  Returns:
//      True if successfully handled
//
//  PRIVATE
VdfList.prototype.handleAutoFindValue = function(aNewRecords, sName){
    var bBuffer = false, iSelect;
    
	if(sName.indexOf("_Top") != -1){
        //  The records above are found first
        this.iSelectAfterValueFind = this.getRecordNr(this.oSelectedRecord) - this.iFirstShownRecord;
		
        if(this.oSelectedRecord == null || this.deSelect(true)){
            this.aRecords = aNewRecords.reverse();
        }
    }else if(sName.indexOf("_Bottom") != -1){
        //  Then the records below are found
        if(this.oSelectedRecord == null){
            //	Throw away the last record (if it is also found in bottom set)
            if(aNewRecords.length > 0 && this.aRecords.length > 0){
                if(this.aRecords[this.aRecords.length - 1].getValue(this.sMainTable + "__rowid") == aNewRecords[0].getValue(this.sMainTable + "__rowid")){
                    this.aRecords.pop();
                }
            }
            
            //  Determine the record to select
            iSelect = this.aRecords.length;
            this.iFirstShownRecord = iSelect - this.iSelectAfterValueFind;
            if(this.iFirstShownRecord < 0) this.iFirstShownRecord = 0;

            //  Add new records to the buffer
            this.aRecords = this.aRecords.concat(aNewRecords);
            
            //  Add newrow
            if(this.bDisplayNewRow){
                this.aRecords.push(this.oNewRecord);
            }
            
            //  Move selected view frame up according to results
            while((this.iFirstShownRecord + this.iRowLength) > this.aRecords.length && this.iFirstShownRecord > 0){
                this.iFirstShownRecord--;
                bBuffer = true;
            }
            
            //  Refresh the display
            this.displayRefresh();
            
            //  Select the record
            if(this.aRecords.length > iSelect){
                this.select(this.aRecords[iSelect], false, true);
            }else{
                this.select(this.aRecords[this.aRecords.length - 1], false, true);
            }
            
            if(bBuffer){
                this.buffer(0);
            }
            this.iSelectAfterValueFind = null;
        }
    }  
    
    return true;
}

//
//  Reselects the current record so the form is refilled.
//
VdfList.prototype.reSelect = function(){
    if(this.oSelectedRecord != null){
        this.select(this.oSelectedRecord, false, true);
    }
}

//
//  Selects a record (sets properties and calls selectRecord ( must be in 
//  subclass)
//
//  Params:
//      oRecord The record that will be selected
//      bAuto   True when select action is caused by header action
//      bUpdateForm 
//
//  PRIVATE
VdfList.prototype.select = function(oRecord, bAuto, bUpdateForm, bNoClear){
    var iField, sStatusField, bFormUpdateNeeded;
    if (typeof(oRecord) == "undefined") return false;
    if (typeof(bAuto) == "undefined") var bAuto = false;
    if (typeof(bUpdateForm) == "undefined") var bUpdateForm = false;
    if (typeof(bNoClear) == "undefined") var bNoClear = false;
    
    //  Call user event
    if (this.onBeforeSelect(this, oRecord) == false) return false;
    
    //  Set the selected record
    this.oSelectedRecord = oRecord;
    
    //  Call the sub select method (grid / list)
    this.selectRecord(oRecord, bAuto);
    
    
    //  Update the displayed form values
    if(this.oVdfForm.aTables[this.sMainTable] != null && this.oVdfForm.aTables[this.sMainTable].oStatusField != null){
        bFormUpdateNeeded = true; //(this.oVdfForm.aTables[this.sMainTable].oStatusField.getValue() != oRecord.getValue(this.sMainTable + "__rowid"));
        
        //  Set buffer values to form (especially status fields)
        this.oVdfForm.aTables[this.sMainTable].setValues(oRecord, true, false, true, true);
    }else{
        bFormUpdateNeeded = false;
    }
    
    //  Position the scrollbar
    this.positionScrollbar();
    
    //  Send find or clear request if needed
    if(bUpdateForm && bFormUpdateNeeded){
        if(oRecord.bNew){
            if(!bNoClear){
                this.oVdfForm.childClear(this.sMainTable, this);
            }
        }else{
            this.oVdfForm.childFindByRowId(this.sMainTable, oRecord.getValue(this.sMainTable + "__rowid"), this);
        }
    }
    
    //  Call user event
    this.onAfterSelect(this, oRecord);
}

//
//  Deselects a record (sets properties and calls deSelectRecord (must be in 
//  subclass)
//
//  Returns:
//      True if succesfull
//
VdfList.prototype.deSelect = function(bForced){
    var oRecord = this.oSelectedRecord;
    //  Call user event
    if (this.onBeforeDeSelect(this, oRecord) ==  false) return false;
    
    if(this.deSelectRecord(bForced)){
        this.oSelectedRecord = null;
       
        //  Call user event
        this.onAfterDeSelect(this, oRecord, true);
       
        return true;
    }else{
        //  Call user event
        this.onAfterDeSelect(this, oRecord, false);
    
        return false;
    }
}

//
//  Selects the row according to the given dom element. Searches until TR 
//  element and selects the record that belongs to it.
//
//  Params:
//      oDomElement HTML Dom element of row or element inside the row
//  Returns:
//      True if successfully selected
//
VdfList.prototype.selectByRow = function(oDomElement){
    var oRecord, iRowNr;
    
    try{

        //  Fetch row & record
        if(oDomElement.tagName != "tr"){
            oDomElement = browser.dom.searchParent(oDomElement, "tr");
        }    
        oRecord = oDomElement.oRecord;

        if(oRecord != null){
            //  Select the record
            if(this.oSelectedRecord != null){
                if(this.oSelectedRecord != oRecord){
                    
                    //  Use rownumber to find the record again after deSelect because 
                    //  deSelect can save (and so refresh the list)
                    iRowNr = this.getRecordNr(oRecord) - this.iFirstShownRecord;
                                
                    if(this.deSelect()){
                        this.select(this.aRecords[iRowNr + this.iFirstShownRecord], false, true);
                    }
                }
            }else{
                this.select(oRecord, false, true);
            }
            
            return true;
        }else{
            return false;
        }
    }catch(oError){
        VdfErrorHandle(oError);
    }
}

//
//  Sets the position of the scrollbar according to the position of the 
//  selected record.
//
VdfList.prototype.positionScrollbar = function(){    
    var iNr;
    if(this.bDisplayScrollbar){
        iNr = this.getRecordNr(this.oSelectedRecord);
        
        if(iNr == 0){
            this.oScrollBar.scrollTop();
        }else if(iNr == (this.aRecords.length - 1)){
            this.oScrollBar.scrollBottom();
        }else{
            this.oScrollBar.center();
        }
        
        //  Check if the scrollbar should be enabled.
        if(this.aRecords.length > this.iRowLength){
            this.oScrollBar.enable();
        }else{
            this.oScrollBar.disable();
        }
    }    
}

//
//  (Re)calculates the scrollbar sizes, makes sure there is space for it and 
//  lets the scrollbar resize itsef.
//
VdfList.prototype.resizeScrollbar = function(bFirst){
    var sPadding;
    var aoDisplayedElements =  new Array();
    var oScrollElement = this.oScrollBar.oScrollElement;
    
    while (oScrollElement.parentNode)
    {
        oScrollElement = oScrollElement.parentNode;
        if (oScrollElement.style){
            if (oScrollElement.style.display == "none"){
                aoDisplayedElements[aoDisplayedElements.length] = oScrollElement;
                oScrollElement.style.visibility = "hidden";
                oScrollElement.style.display = "";                
            }
        }        
    }
    
    //  Calculate top & right margin of scrollbar (to make it fit nice into the
    //  list table)
    this.oScrollBar.iMarginTop = this.oHeaderRow.clientHeight + 4;
    if(typeof(this.oTable.currentStyle) != "undefined" && !isNaN(this.oTable.currentStyle.borderRightWidth) ){
        this.oScrollBar.iMarginRight = parseInt(this.oTable.currentStyle.borderRightWidth) + 1;
    }else{
        this.oScrollBar.iMarginRight = 2;
    }

    //  Let scrollbar resize itself
    this.oScrollBar.setSizes();
    
    if(bFirst){
        //  Make sure there is enough room (firefox knows <table>.paddingRight)
        sPadding = this.oScrollBar.iBlockSize + this.oScrollBar.iMarginRight + "px";
        if(browser.isIE){
            if(this.oEditRow != null){
                this.oEditRow.cells[(this.oEditRow.cells.length - 1)].style.paddingRight = sPadding;
            }
            this.oHeaderRow.cells[(this.oHeaderRow.cells.length - 1)].style.paddingRight = sPadding;
            this.oPrototypeRow.cells[(this.oPrototypeRow.cells.length - 1)].style.paddingRight = sPadding;
        }else{
            this.oTable.style.paddingRight = sPadding;
        }
    }
    
    for (var iPos in aoDisplayedElements){
        aoDisplayedElements[iPos].style.display = "none";
        aoDisplayedElements[iPos].style.visibility = "";
    }
}



//
//  Moves selection one step. If nessacary there will be scrolled one step. The 
//  scrollbar position is updated afterwards.
//
//  Params:
//       bBottom                True moves down
//
VdfList.prototype.scroll = function(bBottom){
    var iNr, iViewNr, oRecord;
    if(this.oSelectedRecord != null){
        iNr = this.getRecordNr(this.oSelectedRecord);
        
        iViewNr = iNr - this.iFirstShownRecord;
        
        if(bBottom){
            iNr++;
        }else{
            iNr--;
        }
        
        //  Check if new record is in buffer
        if(iNr >= 0 && iNr < this.aRecords.length){
            //  Try to deselect current record
            if(this.deSelect()){
                //  Recalculate iNr because deSelect can refresh the buffer
                iNr = iViewNr + this.iFirstShownRecord;
                if(bBottom){
                    iNr++;
                }else{
                    iNr--;
                }
                
                //  Scroll a row if nessacary
                if((bBottom && iViewNr == (this.iRowLength - 1)) || (!bBottom && iViewNr == 0)){
                     this.displayRow(this.aRecords[iNr], bBottom);
                }
                
                this.select(this.aRecords[iNr], false, true);

                this.buffer((bBottom ? 1 : -1));
            }
        }else{
            this.buffer((bBottom ? 1 : -1));
        }
    }
}

//
//  Scrolls to the end of the list using a complete refill. Scrollbars are 
//  updated afterwards.
//
//  Params:
//      bBottom                     True scrolls to the bottom
//
VdfList.prototype.scrollEnd = function(bBottom){
    var iRecord, sData, sDataSet;
    if(this.oSelectedRecord == null || this.deSelect()){
        sDataSet = "<aDataSets>";
        sDataSet += this.getDefaultRequestSet("find", this.iRowLength, null, (!bBottom), false, (bBottom ? "Full_Reverse_NoAuto" : "Full_NoAuto"));
        sDataSet += "</aDataSets>";
        
        this.oVdfForm.sendRequest(sDataSet, false);

        this.buffer((bBottom ? -1 : 1));
    }
}


//
//  Scrolls one page. If unable to scroll that far the selection will be moved. 
//  Scrollbar position is updated afterwards.
//
//  Param:
//      bBottom                     True scrolls down
//
VdfList.prototype.scrollPart = function(bBottom){
    var iLast, iLoop, iNr, iDiff, iViewNr;
    if(this.oSelectedRecord != null && !this.bBuffering){
        iNr = this.getRecordNr(this.oSelectedRecord);
        iViewNr = iNr - this.iFirstShownRecord;
    
        if(this.deSelect()){
            //  Recalculate iNr because deSelect can refresh the buffer
            iNr = iViewNr + this.iFirstShownRecord;
        
            iLoop = 0;
            iDiff = (bBottom ? 1 : -1);
            
            if(bBottom){
                iLast = this.iFirstShownRecord + this.iRowLength - 1;
            }else{
                iLast = this.iFirstShownRecord;
            }
            
            //  Scroll 1 page
            while(iLast > 0 && iLast < (this.aRecords.length - 1) && iLoop < (this.iRowLength - 1)){
                iLast += iDiff;
                iNr += iDiff;
                iLoop++;                
                this.displayRow(this.aRecords[iLast], bBottom);
            }
            
            //  If no complete page scrolled (because end of list) move selection
            while((iNr > 0 || bBottom) && (iNr < (this.aRecords.length - 1) || !bBottom) && iLoop < (this.iRowLength - 1)){
                iLoop++;
                iNr+= iDiff;
            }
            
            this.select(this.aRecords[iNr], false, true);
            this.buffer((bBottom ? 1 : -1));
        }
    }
}

//
//  Switches index to the index of the given column and redisplays the records.
//
//  Params:
//      sColumn The name of the column of witch the index should be used.
//
VdfList.prototype.switchIndex = function(sColumn){
    var iNewIndex;
    
    iNewIndex = this.oVdfForm.oVdfInfo.getColumnProperty(sColumn, "iIndex");
    
    if(iNewIndex != this.getIndex()){
        this.iIndex = iNewIndex;
        this.bReverseIndex = false; 
    }else{
        this.bReverseIndex = !this.bReverseIndex;
    }
    this.displayHeaderCSS();    
    
    this.refresh();
}

//
//  Generates and sends the refresh requestsets (see getRefreshRequestSets)
//
VdfList.prototype.refresh = function(){
    var sXml = "<aDataSets>\n" + this.getRefreshRequestSets(this.oSelectedRecord) + "</aDataSets>\n";
    
    this.oVdfForm.sendRequest(sXml, false);
}

//
//  Displays the jump into list div with the input element and attaches the
//  events.
//
//  Params:
//      iKeyCode    (Code of the pressed key)
//      iCharCode   (Code of the pressed key)
//  Returns:
//      True if succesfull (false if bJumpIntoList = false)
// 
//  PRIVATE
VdfList.prototype.jumpIntoListDisplay = function(iKeyCode, iCharCode){
    var iColumn, sColumn = null, oField, oInput, oPositionElement = null, aChilds, iChild, sDataBinding;

    if(this.bJumpIntoList && this.oJumpIntoList == null){
        //  Find first index column
        for(sColumn in this.aColumns){
            if(this.oVdfForm.oVdfInfo.getColumnProperty(sColumn, "iIndex") == this.getIndex()){
                break;
            }
        }
        
        //  Create element & set properties
        oInput = document.createElement("input");
        oInput.style.position = "absolute";
        oInput.type = "text";
        oInput.style.zIndex = 1000;
        oInput.className = this.sCssLookupJumper;
        oInput.name = sColumn;
        browser.dom.setVdfAttribute(oInput, "bDisplayOnly", "false");
        browser.dom.setVdfAttribute(oInput, "bNoEnter", "false");

        //  Attach event listeners
        browser.events.addKeyListener(oInput, this.onJumpIntoListKeyPress);        
        browser.events.addGenericListener("blur", oInput, this.onJumpIntoListBlur);

        //  Initialize adjustment & prevention
        oField = new VdfField(oInput, this.oVdfForm, sColumn);
        if(this.oVdfForm.oVdfValidator != null){
            this.oVdfForm.oVdfValidator.initField(oField);
        }
        
        //  Set references
        oInput.oVdfList = this;
        this.oTable.parentNode.insertBefore(oInput, this.oTable);
        //document.body.appendChild(oInput);
        this.oJumpIntoList = oInput;
        
        //  Find dom element to overlay
        if(this.oSelectedRecord != null){
            aChilds = browser.dom.getAllChildElements(this.oSelectedRecord.oRow);
            for(iChild = 0; iChild < aChilds.length && oPositionElement == null; iChild++){
                sDataBinding = browser.dom.getVdfAttribute(aChilds[iChild], "sDataBinding");
                if(sDataBinding != null){
                    if(sDataBinding.toLowerCase() == sColumn){
                        oPositionElement = aChilds[iChild];
                    }
                }
            }
        }
        
        //  Position element   
        if(oPositionElement != null){   
            oInput.style.left = (browser.gui.getAbsoluteOffsetLeft(oPositionElement)) + "px";
            oInput.style.top = (browser.gui.getAbsoluteOffsetTop(oPositionElement)) + "px";
            oInput.style.width = oPositionElement.clientWidth + "px";
            oInput.style.height = oPositionElement.clientHeight  + "px";
        }else{
            oInput.style.left = ((browser.gui.getAbsoluteOffsetLeft(this.oTable) + this.oTable.clientWidth) - oInput.clientWidth) + "px";
            oInput.style.top = ((browser.gui.getAbsoluteOffsetTop(this.oTable) + this.oTable.clientHeight) - oInput.clientHeight) + "px";
        }
        
        browser.dom.setFocus(oInput);
        if(iCharCode > 0){
            oInput.value = "" + String.fromCharCode(iCharCode);
        }
        
        return true;
    }else{
        return false;
    }
}

//
//  Hides the JumpInto display by removing the elements and the attached 
//  listeners.
//  
//  PRIVATE
VdfList.prototype.jumpIntoListHide = function(){
    if(this.oJumpIntoList != null){
        browser.events.removeKeyListener(this.oJumpIntoList, this.onJumpIntoListKeyPress);
        browser.events.removeGenericListener("blur", this.oJumpIntoList, this.onJumpIntoListBlur);
        this.oJumpIntoList.oField = null;
        this.oJumpIntoList.oVdfList = null;
        // document.body.removeChild(this.oJumpIntoList);
        this.oTable.parentNode.removeChild(this.oJumpIntoList);
        this.oJumpIntoList = null;
        
        this.returnToField();
    }
}

//
//  If there belongs an action to the pressed key it initiates this action.
//
//  Returns:
//      True if an action is initiated
//
//  PRIVATE
VdfList.prototype.keyAction = function(iKeyCode, iCharCode, bCrtl, bShift, bAlt){
    var bResult = false;

    switch(iKeyCode){
        case 38:
            //  arrow up -> scroll up
            this.scroll(false);
            bResult = true;
            break;
        case 40:
            //  arrow down -> scroll down
            this.scroll(true);
            bResult = true;
            break;
        case 33:
            //  page up -> scroll page up           
            this.scrollPart(false);
            bResult = true;
            break;
        case 34:
            //  page down -> scroll page down
            this.scrollPart(true);
            bResult = true;
            break;
        case 36:
            //  ctrl - home -> scroll to end
            if(bCrtl){
                this.scrollEnd(false);
                bResult = true;
            }
            break;
        case 35:
            //  ctrl - end -> scroll to begin
            if(bCrtl){
                this.scrollEnd(true);
                bResult = true;
            }
            break;
    }
    return bResult;
}

//
//  Checks if the table has empty rows.
//
//  Returns:
//      True if empty rows found
//
//  PRIVATE
VdfList.prototype.hasEmptyRow = function(){
    var oTable = this.oTable, iRow, bFound = false;

    iRow = oTable.rows.length - 1;    
    while(iRow >= 0 && !bFound){
        bFound = (browser.dom.getVdfAttribute(oTable.rows[iRow], "sRowType") == "spaceFiller");
        iRow--;
    }    
    
    return bFound;
}

//
//  If index is not set ("") then it sets the index to the index of the first 
//  indexed column. If no indexed columns found it uses the default index 1.
//
//  Returns:
//      Index
//
VdfList.prototype.getIndex = function(){
    if(this.iIndex == ""){
        //  If index not set determin index using column order
        var iIndex, sColumn;
        
        for(sColumn in this.aColumns){
            iIndex = this.oVdfForm.oVdfInfo.getColumnProperty(sColumn, "iIndex");
            if(iIndex != "0" && iIndex != ""  && iIndex != null){
                this.iIndex = iIndex;
                break;
            }
        }
        
        //  If no column with index found use index 1
        if(this.iIndex == ""){
            this.iIndex = "1";
        }
    }
    
    return this.iIndex;
}

//
//  Params:
//      oRecord The searched record
//  Returns:
//      The number of the record in the array (buffer) (0 if not found)
//
//  PRIVATE
VdfList.prototype.getRecordNr = function(oRecord){
    var iNr;
    
    for(iNr = 0; iNr < this.aRecords.length; iNr++){
        if(this.aRecords[iNr] == oRecord){
            return iNr;
        }
    }
    
    return 0;
}

//
//  Searches the record using its rowid.
//
//  Params:
//      sRowId  Rowid of the searched record
//  Returns:
//      The num,ber of the record in the array (buffer) (0 if not found)
//
//  PRIVATE
VdfList.prototype.getRecordNrByRowId = function(sRowId){
    var iRecord;
    
    for(iRecord = 0; iRecord < this.aRecords.length; iRecord++){
        if(this.aRecords[iRecord].getValue(this.sMainTable + "__rowid") == sRowId){
            return iRecord;
        }
    }
    
    return 0;    
}

//
//  Called to give the list the focus. It checks if a focusholder is available 
//  and sets the focus to it.
//
VdfList.prototype.returnToField = function(){
    if(this.oFocusHolder != null){
        var oFocusHolder = this.oFocusHolder;
    
        setTimeout(function(){ 
            browser.dom.setFocus(oFocusHolder);
        }, 10);
    }
}

//
//  Forwards delete request to the form with the correct maintable.
//
VdfList.prototype.doDelete = function(){
    this.oVdfForm.doDelete(this.sServerTable);
}

//
//  Forwards save request tot the form with the correct maintable.
//
//  Returns:
//      True if save succesfull
//
VdfList.prototype.doSave = function(){
    return this.oVdfForm.doSave(this.sServerTable, false);
}


//
//  Handles a click on record table row
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfList.prototype.onRecordClick = function(e){
    var oTable, oTarget, oVdfList;
    
    try{
        //  Get nessacary information carefully
        oTarget = browser.events.getTarget(e);

        if(oTarget == null)
            return false;
            
        oTable = browser.dom.searchParent(oTarget, "table");
        if(oTable == null || oTable.oVdfList == null)
            return false;
        
        oVdfList = oTable.oVdfList;

        
        
        oVdfList.selectByRow(oTarget);
        
        oVdfList.returnToField();
    }catch(oError){
        VdfErrorHandle(oError);
    }
}

//
//  Handles the double click on a record row.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfList.prototype.onRecordDoubleClick = function(e){
    var oTarget, oVdfList;
    
    try{
        //  Get nessacary information carefully
        oTarget = browser.events.getTarget(e);
        
        if(oTarget == null)
            return false;
            
        if(oTarget.tagName != "table"){
            oTarget = browser.dom.searchParent(oTarget, "table");
        }
        
        if(oTarget == null)
            return false;
        
        oVdfList = oTarget.oVdfList;
        
        
        if(oVdfList.onEnter()){
            return true;
        }else{
            return oVdfList.oVdfForm.onEnter();
        }
    }catch(oError){
        VdfErrorHandle(oError);
    }
}

//
//  Fetches the mouseover event of grid rows.
//
//  Params:
//      e   Event object (on some browsers)
//
//  PRIVATE
VdfList.prototype.onRecordMouseOver = function(e){
}

//
//  Fetches the mouseout event of grid rows.
//
//  Params:
//      e   Event object (on some browsers)
//
//  PRIVATE
VdfList.prototype.onRecordMouseOut = function(e){
}

//
//  Handles a click on an header cell of a column with an index.
//
//  Params:
//      e   Event object on some browsers
//
VdfList.prototype.onIndexClick = function(e){
    var oTarget, oTable, oVdfList;
    
    try{
        
        //  Get nessacary information carefully
        oTarget = browser.events.getTarget(e);
        
        if(oTarget == null)
            return false;
            
        if(oTarget.tagName != "table"){
            oTable = browser.dom.searchParent(oTarget, "table");
        }
        
        if(oTable == null)
            return false;
        
        oVdfList = oTable.oVdfList;
        
        if(browser.dom.getVdfAttribute(oTarget, "sDataBinding") != null){
            //  Call function that switches index
            oVdfList.switchIndex(browser.dom.getVdfAttribute(oTarget, "sDataBinding").toLowerCase());
        }
        
        oVdfList.returnToField();
    }catch(oError){
        VdfErrorHandle(oError);
    }
}

//
//  Handles click on empty row, makes sure the focusholder (if available) gets 
//  the focus.
//
//  Params:
//      e   Event object (on some browsers)
//
//  PRIVATE
VdfList.prototype.onEmptyRowClick = function(e){
    var oTarget, oVdfList;
    
    try{
        //  Get nessacary information carefully
        oTarget = browser.events.getTarget(e);
        
        if(oTarget == null)
            return false;
            
        if(oTarget.tagName != "table"){
            oTarget = browser.dom.searchParent(oTarget, "table");
        }
        
        if(oTarget == null)
            return false;
        
        oVdfList = oTarget.oVdfList;
        
        oVdfList.returnToField();}
    catch(oError){
        VdfErrorHandle(oError);
    }
}

//
//  Fetches the keypress events. Calls the keyhandling methods in the correct 
//  order. First the VdfList then the VdfForm and then the jumpIntoList method.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfList.prototype.onFocusHolderKey = function(e){
    var oTarget, oVdfList, iKeyCode, iCharCode;

    if(!browser.events.canceled(e)){
        try{
            oTarget = browser.events.getTarget(e);
            if(oTarget == null)
                return false;
            
            oTarget = browser.dom.searchParent(oTarget, "a");
            oVdfList = oTarget.oVdfList;

            
            iKeyCode = browser.events.getKeyCode(e);
            iCharCode = browser.events.getCharCode(e);
            if(oVdfList.keyAction(iKeyCode, iCharCode, e.ctrlKey, e.shiftKey, e.altKey)){
                if(typeof(browser) == "object"){
                    browser.events.stop(e);
                    return false;
                }
            }else if(oVdfList.oVdfForm.keyAction(iKeyCode, iCharCode, e.ctrlKey, e.shiftKey, e.altKey)){
                if(typeof(browser) == "object"){
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
//  Fetches the keypress event of the focusholder (also under IE the keypress 
//  event is used so the iKeyCode is also with the numeric part of the keyboard
//  correct). Displays the jumpintolist thingy.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfList.prototype.onJumpIntoListKey = function(e){
    var oTarget, oVdfList, iKeyCode, iCharCode, aIgnoreKeys;
    
    aIgnoreKeys = {9:1, 13:1, 16:1, 27:1, 33:1, 34:1, 35:1, 36:1, 37:1, 38:1, 39:1, 40:1, 46:1, 112:1, 113:1, 114:1, 115:1, 116:1, 117:1, 118:1, 119:1, 120:1, 121:1, 122:1, 123:1};

    if(typeof(browser) == "object" && !browser.events.canceled(e)){
        try{
            oTarget = browser.events.getTarget(e);
            if(oTarget == null)
                return false;
            
            oTarget = browser.dom.searchParent(oTarget, "a");
            oVdfList = oTarget.oVdfList;    
        
            iKeyCode = browser.events.getKeyCode(e);
            iCharCode = browser.events.getCharCode(e);
            
            if(oVdfList.bJumpIntoList && !e.ctrlKey && !e.altKey && !aIgnoreKeys[iKeyCode]){
                if(oVdfList.jumpIntoListDisplay(iKeyCode, iCharCode)){
                    browser.events.stop(e);
                    return false;
                }
            } else if(iKeyCode == 34){
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
//  Fetches the onfocus event of the focusholder. Makes sure this is the active
//  in the form.
//
//  Params:
//      e   Event object (on some browsers)
//
//  PRIVATE
VdfList.prototype.onFocusHolderFocus = function(e){
    var oTarget, oVdfList;
    
    if(!browser.events.canceled(e)){
        try{
            oTarget = browser.events.getTarget(e);
            if(oTarget == null)
                return false;
                
            oTarget = browser.dom.searchParent(oTarget, "a");
            
            oVdfList = oTarget.oVdfList;
            
            
            oVdfList.oVdfForm.oVdfActiveObject = oVdfList;
        }catch(oError){
            VdfErrorHandle(oError);
        }
    }
}

//
//  Fake event catcher for scrollbar events. Called when the scrollbar is used
//  to scroll.
//
//  Params:
//      iScroll The scrollbar scroll nr (step up, up, top, bottom, down, step 
//      down)
//
//  PRIVATE
VdfList.prototype.onScroll = function(iScroll){
    var oVdfList, bBottom;
    
    try{
        oVdfList = this.oSource;
        bBottom = (iScroll > 0);
        
        if(iScroll == JScrollBar_Bottom || iScroll == JScrollBar_Top){
            oVdfList.scrollEnd(bBottom);
        }else if(iScroll == JScrollBar_Down   || iScroll == JScrollBar_Up){
            oVdfList.scrollPart(bBottom);
        }else if(iScroll == JScrollBar_StepDown || iScroll == JScrollBar_StepUp){
            oVdfList.scroll(bBottom);
        }
        
        oVdfList.returnToField();
    }catch(oError){
        VdfErrorHandle(oError);
    }
}

//
//  Catcht the mousewheel scroll event. It searches for the dom table to get the
//  vdflist object. It fetches the delta of the mousewheel scroll event and call
//  the scroll method which scrolls the list one step.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfList.prototype.onMouseWheelScroll = function(e){
    var oVdfList, iDelta, oTarget;
    
    try{
        oTarget = browser.events.getTarget(e);
        if(oTarget == null)
            return false;
            
        oTarget = browser.dom.searchParent(oTarget, "table");
        oVdfList = oTarget.oVdfList;
        
        iDelta = browser.events.getMouseWheelDelta(e);

        if(iDelta != 0){
            oVdfList.scroll((iDelta < 0));       
            browser.events.stop(e);
        }
    }catch(oError){
        VdfErrorHandle(oError);
    }
}


//
//  Catches the onblur event of the input element making it disappear when the 
//  user clicks on another element.
//
//  Params:
//      e   Event object (on some browsers)
//
//  PRIVATE
VdfList.prototype.onJumpIntoListBlur = function(e){
    var oInput, oVdfList;
    
    try{
        oInput= browser.events.getTarget(e);
        if(oInput == null)
            return false;
            
        oInput = browser.dom.searchParent(oInput, "input");
        oVdfList = oInput.oVdfList;  
        
        oVdfList.jumpIntoListHide();
    }catch(oError){
        VdfErrorHandle(oError);
    }
}

//
//  Catches keypress event of JumpInto input element. Calls findByIndex with the
//  entered value on return. And hides the JumpIntoList thingy on return and
//  escape.
//
//  Params:
//      e   Event object (on some browsers)
//
//  PRIVATE
VdfList.prototype.onJumpIntoListKeyPress = function(e){
    var oInput, oVdfList;
    
    try{
        oInput = browser.events.getTarget(e);
        if(oInput == null)
            return false;

        oInput = browser.dom.searchParent(oInput, "input");
        oVdfList = oInput.oVdfList;  
     
        if(browser.events.getKeyCode(e) == 13){ // On return
            //  Do jump and disable / hide jump display
            
            oVdfList.findByColumn(oInput.value, oInput.name);
            oVdfList.jumpIntoListHide(oInput);
            browser.events.stop(e);
        }else if(browser.events.getKeyCode(e) == 27){ // On escape
            oVdfList.jumpIntoListHide(oInput);
        }
    }catch(oError){
        VdfErrorHandle(oError);
    }
}

//  - - - - - - - USER EVENTS - - - - - - - -

//
//  Is called when enter is pressed or a child event (like doubleclick in
//  DbList). If true is returned the event will be killed and no other
//  handling is possible.
//
//  Returns:
//      True if an action is done
//
VdfList.prototype.onEnter = function(){
    return false;
}

//
//  Is called when a row is displayed in the list.
//
//  Params:
//      oVdfList    Reference to the list object
//      oRecord     VdfDataSet object of the displayed record
//
VdfList.prototype.onAfterDisplayRow = function(oVdfList, oRecord){
    
}

//
//  Is called when a row is selected in the list.
//
//  Params:
//      oVdfList    Reference to the list object
//      oRecord     VdfDataSet object of the record to select
//  Returns:
//      False to cancel the action
//
VdfList.prototype.onBeforeSelect = function(oVdfList, oRecord){
    
}

//
//  Is called when a row is selected in the list.
//
//  Params:
//      oVdfList    Reference to the list object
//      oRecord     VdfDataSet object of the newly selected record
//
VdfList.prototype.onAfterSelect = function(oVdfList, oRecord){
    
}

//
//  Is called when a row is selected in the list.
//
//  Params:
//      oVdfList    Reference to the list object
//      oRecord     VdfDataSet object of the currently selected record
//  Returns:
//      False to cancel the action
//
VdfList.prototype.onBeforeDeSelect = function(oVdfList, oRecord){
    
}

//
//  Is called when a row is selected in the list.
//
//  Params:
//      oVdfList    Reference to the list object
//      oRecord     VdfDataSet object of the deselected record
//      bSuccess    If true the record is deselected
//
VdfList.prototype.onAfterDeSelect = function(oVdfList, oRecord, bSuccess){
    
}
