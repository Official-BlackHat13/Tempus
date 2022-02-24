df.tWebRow = { 
    sRowId : df.tString, 
    sCssClassName : df.tString, 
    aCells : [ { 
        sValue : df.tString,  
        sTooltip : df.tString,
        sCssClassName : df.tString,
        aOptions : [ df.tString ]
    } ] 
};


/*
Class:
    df.WebList
Extends:
    df.WebBaseControl

This is the client-side representation of the cWebList control which shows a multi column list of 
data. The nested cWebColumn objects represent the grid columns. The cWebCheckboxColumn and 
cWebComboColumn classes will represent different types of columns. The cWebList is readonly and only 
allows the users to select a row. The cWebList can be data bound and then it will automatically find 
records.

The control is implemented using a MVC strategy where there are several views, a model and a 
controller. The following classes are part of this system:
df.WebList
    - Handles communication with the server.
    - Model for the server settings (properties, columns).
df.WebListModel
    - Model for the list data (all data is loaded at once).
df.WebListPagedModel
    - Model for paged list data (loads data in chunks from the server).
df.WebListView
    - Main view showing the list of data that does not support scrolling.
df.WebListScrollingView
    - Extends the list view with the scrolling logic.
df.WebListHeaderView
    - View displaying the header above the list.
df.WebListController
    - Executes row changes.
    - Executes loading of data pages.
df.WebListRowModel
    - Maintains the model of a row (multi line rows, row widths) and is capable of rendering a 
      single row (used by the View classes).
df.WebListTouchHandler
    - Implementation of touch scrolling for the WebListScrollingView and swipe buttons.

Communication between the classes mainly occurs events (onSettingChange, onDataChange, onRowChange) 
thrown by the WebList and the WebListModel. The WebList class (as the API with the server) 
communicates directly with the controller and the views do communicate with the controller. The 
controller on its turn manipulates the model which updates the views.

    
Revision:
    2011/12/02  (HW, DAW) 
        Initial version.
    2017/02/14  (HW, DAW)
        Refactored into mini MVC model.
*/
df.WebList = function WebList(sName, oParent){
    df.WebList.base.constructor.call(this, sName, oParent);
    
    this.prop(df.tString, "psCurrentRowId", "");
    this.prop(df.tInt, "piCurrentRowIndex", -1);
    this.prop(df.tInt, "piRowCount", 0);
    
    this.prop(df.tBool, "pbShowHeader", true);
    this.prop(df.tBool, "pbShowSelected", true);
    
    this.prop(df.tBool, "pbDataAware", true);
    this.prop(df.tInt, "peDbGridType", df.gtAutomatic);
    this.prop(df.tBool, "pbOfflineEditing", false);
    
    this.prop(df.tBool, "pbAutoSearch", true);
    this.prop(df.tBool, "pbColumnSortable", true);
    this.prop(df.tBool, "pbReverseOrdering", true);
    this.prop(df.tInt, "piSortColumn", 0);
    
    this.prop(df.tInt, "piMinHeight", 0);
    this.prop(df.tInt, "piHeight", 0);
    this.prop(df.tBool, "pbColumnsResizable", true);
    this.prop(df.tBool, "pbAutoColumnSizing", true);
    this.prop(df.tString, "psPlaceHolder", "");
    
    this.prop(df.tString, "psKeyBuddy", "");
    
    this.prop(df.tBool, "pbScroll", true);

    this.event("OnRowClick", df.cCallModeWait);
    
    //  Child objects
    this._aColumns = [];
    this._aSwipeBtns = [];
    
    //  Modules
    this._oRowRenderer = null;
    this._oModel = null;
    this._oHeader = null;
    this._oBody = null;
    this._oTouchHandler = null;
    
    //  Privates
    this._iColCount = 0;
    this._tRedraw = null;
    this._bLozingFocus = false;
    
    
    this._onSettingChange = new df.events.JSHandler();
    this._onResize = new df.events.JSHandler();
    this._onModulesCreated = new df.events.JSHandler();
    
    this.addSync("piCurrentRowIndex");
    this.addSync("psCurrentRowId");
    this.addSync("piRowCount");
    
    //  Actions we need to wait for due to integrety
    this.setActionMode("HandleProcessDataSet", df.cCallModeWait);
    this.setActionMode("ChangeCurrentRow", df.cCallModeWait);

    
    this._sControlClass = "WebList";
    
};
df.defineClass("df.WebList", "df.WebBaseControl",{

/*
Augmenting the addChild method to filter out columns and the swipe buttons.

@private
*/
addChild : function(oChild){
    if(oChild._bIsColumn){
        oChild._iColIndex = this._iColCount++;
        oChild._iCol = this._aColumns.length;
        this._aColumns.push(oChild);
    }
    if(oChild._bIsSwipeButton){
        oChild._iColIndex = this._iColCount++;
        this._aSwipeBtns.push(oChild);
    }
    
    df.WebList.base.addChild.call(this, oChild);
},

/* 
Initializes the modules that make the WebList component.
*/
create : function(){
    this._oModel = this.createModel();
    this._oController = this.createController();
    
    this._oRowRenderer = new df.WebListRowModel(this, this._oModel);
        
    
    this._oHeader = new df.WebListHeaderView(this, this._oModel, this._oController);
    this._oBody = this.createView();
    this._oTouchHandler = new df.WebListTouchHandler(this, this._oBody, this._oModel, this._oController);
    
    
    this._oPlaceHolder = new df.WebListPlaceHolderView(this, this._oModel);
    
    this._oRowRenderer.init();

    this._onModulesCreated.fire(this);
},   

/* 
Creates the view (body) module. Can be augmented for customization.
*/
createView : function(){
    if(this.pbScroll){
        return new df.WebListScrollingView(this, this._oModel, this._oController);
    }else{
        return new df.WebListView(this, this._oModel, this._oController);
    }
},

/* 
Creates the controller module. Can be augmented for customization.
*/
createController : function(){
    return new df.WebListController(this, this._oModel);
},

/* 
Creates the model module. Can be augmented for customization.
*/
createModel : function(){
    if(this.peDbGridType === df.gtAllData || this.peDbGridType === df.gtManual || !this.pbDataAware || !this.pbScroll){    
        return new df.WebListModel(this);
    }else{
        return new df.WebListPagedModel(this);
    }
},
    
openHtml : function(aHtml){
    df.WebList.base.openHtml.call(this,aHtml);
    
    aHtml.push('<div class="WebList_Focus" tabindex="', (this.isEnabled() ? '0' : '-1'), '">');
    this._oHeader.genHtml(aHtml);
    this._oBody.genHtml(aHtml);
    this._oPlaceHolder.genHtml(aHtml);
},

closeHtml : function(aHtml){
    aHtml.push('</div>');
    
    df.WebList.base.closeHtml.call(this, aHtml);
},

afterRender : function(){
    var oObj;
    
    this._eControl = this._eFocus = df.dom.query(this._eElem, 'div.WebList_Focus');
    
    if(this._oHeader){
        this._oHeader.afterRender(this._eElem);
    }
    
    this._oBody.afterRender(this._eElem);
    this._oPlaceHolder.afterRender(this._eElem);
    this._oTouchHandler.afterRender(this._eElem);
    
    df.WebList.base.afterRender.call(this);
    
    this.updateEnabled();
    
    df.dom.on("keydown", this._eFocus, this.onKeyDown, this);
    df.dom.on("keypress", this._eFocus, this.onKeyPress, this);
    df.dom.on("click", this._eElem, this.onListClick, this);
    
    //  We set _bRenderChildren to true so that events like afterShow properly reach columns components (needed for previewer as well)
    this._bRenderChildren = true;
    
    //  Attach key handler to key buddy control when set
    if(this.psKeyBuddy){
        oObj = this.getWebApp().findObj(this.psKeyBuddy);
        if(oObj){
            if(oObj instanceof df.WebBaseControl){
                this._eKeyBuddy = oObj._eControl;
            }
            if(!this._eKeyBuddy){
                this._eKeyBuddy = oObj._eElem;
            }
            
            df.events.addDomListener("keydown", this._eKeyBuddy, this.onKeyDown, this);
        }
    }
},

afterRenderChildren : function(){

},

/* 
Called by the WebBaseControl sizing logic when the height of the control changes and during i
nitialization.

@param  iHeight     The height in pixels (0 if it should size naturally).
@param  bSense      If false the size is expected to not be the final size.
*/
setHeight : function(iHeight, bSense){
    if(this._eElem){
        //  If the label is on top we reduce that (note that this means that piMinHeight and piHeight are including the label)
        if(this._eLbl && this.peLabelPosition === df.ciLabelTop){
            iHeight -= this._eLbl.offsetHeight;
        }
        
        iHeight -= df.sys.gui.getVertBoxDiff(this._eInner);
        iHeight -= df.sys.gui.getVertBoxDiff(this._eControlWrp);
        
        if(this._oHeader){
            iHeight -= this._oHeader.offsetHeight();
        }
        
        this._oBody.setHeight(iHeight);
    }
},

resize : function(){
    this._onResize.fire(this);

    df.WebList.base.resize.call(this);
},

/*
Handles the keypress event and will initiate the auto search if needed. The keypress is used because 
we need the character code and are not interested in special keys anyway. 

@param  oEv  The event object.
@private
*/
onKeyPress : function(oEv){
    //  Check enabled state
    if(!this.isEnabled()){
        return;
    }
    
    return this._oController.keyPress(oEv);    
},

/*
This method handles the keypress event and initiates the actions bound to it. The 
df.settings.listKeys define the exact key code's / combinations for the different actions.

@param  oEv  The event object.
@return False if we did handle the event and performed an action, true if we didn't do anything.
*/
onKeyDown : function(oEv){
    //  Check enabled state
    if(!this.isEnabled()){
        return;
    }
    
    return this._oController.keyDown(oEv);    
},

/* 
Augments applyEnabled to set the tabindex attribute of the control element.

@param  bVal    The enabled state.
*/
applyEnabled : function(bVal){
    if(this._eFocus){
        this._eFocus.tabIndex = (bVal ? 0 : -1);
    }

    df.WebList.base.applyEnabled.call(this, bVal);
},

//  - - - - Server API - - - -

/*

@client-action
*/
gridRefresh : function(bFirst, bLast){
    var aRows = this.deserializeVT(this._tActionData);
    
    //  Cancel row change and row click because we are going to refresh the data set and the row might not exist any more
    this.cancelServerAction("ChangeCurrentRow");
    this.cancelServerAction("OnRowClick");  //  Also cancel onclick as this causes problems because of the assumption that the ChangeCurrentRow has been executed
    
    this._oController.handleData(aRows, "page", "", df.toBool(bFirst), df.toBool(bLast));
},

/*
This function handles a new page of data and adds it to the cache. Depending on the sType parameter 
it will add or replace the cache. After this it will refresh the display.

@client-action
*/
handleDataPage : function(sType, sStartRowId, bFirst, bLast){
    var aRows = this.deserializeVT(this._tActionData);
    
    this._oController.handleData(aRows, sType, sStartRowId, df.toBool(bFirst), df.toBool(bLast));
},

/* 
Called during the row change process.

@param  bVal    True if row change was successful.
@client-action
*/
handleRowChange : function(bVal){
    this._oController.handleRowChange(bVal);
},

/*
This method is called by the server to update a single row in the cache or on the display; it is 
usually called after a save. If sRowID is empty then it means that a new row is saved which is added 
to the cache at the last location where a new row was displayed.

@param  sRowID  The original rowid of the row to be updated; empty string if it's a new row.


@client-action
*/
updateRow : function(sRowId){
    var aRows = this.deserializeVT(this._tActionData);
    
    if(aRows.length > 0){
        this._oController.updateRow(sRowId, aRows[0]);
    }
},

/* 
Appends the received row (action data) to the list. Should only be used on non data aware lists.

@client-action
*/
dataSetAppendRow : function(){
    var aRows = this.deserializeVT(this._tActionData);
    
    if(aRows.length > 0){
        this._oController.appendRow(aRows[0]);
    }
},

/* 
Inserts the received row (action data) to the list. Should only be used on non data aware lists.

@param  sBeforeRowID    RowID of the row indicating the position where the row should be inserted 
                        into the list.
@client-action
*/
dataSetInsertRowBefore : function(sBeforeRowID){
    var aRows = this.deserializeVT(this._tActionData);
    
    if(aRows.length > 0){
        this._oController.insertBefore(sBeforeRowID, aRows[0]);
    }
},

/* 
Removes a row from the list. Should only be used on non data aware lists.

@param  sRowID  RowID indicating which row to remove.
@client-action
*/
dataSetRemoveRow : function(sRowId){
    this._oController.removeRow(sRowId);
},

/* 
Updates a row in the list based on the row passed in the action data.

@param  sRowID  RowID indicating which row needs to be updated.
@client-action
*/
dataSetUpdateRow : function(sRowID){
    var iRow, aRows = this.deserializeVT(this._tActionData);
    
    if(aRows.length > 0){
        this._oController.updateRow(aRows[0].sRowId, aRows[0]);
    }
},



/*
This method is called by the server to update the cache when a row is deleted. It removes the row 
from the cache and updates the display.

@param  sRowID   The unique ID of the row that is deleted.

@client-action
*/
removeRow : function(sRowId){
    this._oController.removeRow(sRowId);
},

/*
Augment the processDataSet function so that it copies data from the DEO’s to the cache before 
sending the data to the server.

@client-action
*/
processDataSet : function(eOperation){
    this._oController.processDataSet(eOperation);
},

/*
Scrolls to the first record and selects it. It is called by the keyboard handler or from the server. 
In case of a static grid it will directly call the selectRow function to select the first row, for a 
non-static grid (pbDataAware is true or peDbGridType is not gtAutomatic) it will always refresh the 
cache by loading the first page of records. Note that when pbOfflineEditing is true we need to load 
the first cache page before changing rows.

@client-action
*/
moveToFirstRow : function(){
    this._oController.moveToFirstRow();
},

/*
Scrolls to the last record and selects it. It is called by the keyboard handler or from the server. 
In case of a static grid it will directly call the selectRow function to select the last row, for a 
non-static grid (pbDataAware is true or peDbGridType is not gtAutomatic) it will always refresh the 
cache by loading the last page of records. Note that when pbOfflineEditing is true we need to load 
the last cache page before changing rows.

@client-action
*/
moveToLastRow : function(){
    this._oController.moveToLastRow();
},

/*
This method selects the next row available in the cache and returns true if successful. It is called 
by the key handler or the server.

@return True if a next row is available.
@client-action
*/
moveDownRow : function(){
    this._oController.moveDownRow();
},

/*
This method selects the previous row available in the cache and returns true if successful. It is 
called by the key handler or the server.

@return True if a previous row is available.
@client-action
*/
moveUpRow : function(){
    this._oController.moveUpRow();
},

/*
This method performs a page down which means that it select the record one page down in the cache 
and scrolls to it. A page in this context means the amount of rows that fit inside the grid view. It 
is called by the key handler or the server.

@client-action
*/
movePageDown : function(){
    this._oController.movePageDown();
},

/*
This method performs a page up which means that it select the record one page up in the cache and 
scrolls to it. A page in this context means the amount of rows that fit inside the grid view. It is 
called by the key handler or the server.

@client-action
*/
movePageUp : function(){
    this._oController.movePageUp();
},

/*
This method moves to a specific row based on its row index.

@client-action
*/
moveToRow : function(iRowIndex){
    this._oController.moveToRow(iRowIndex);
},

/*
This method moves to a specific row based on its unique row ID.

@client-action
*/
moveToRowByID : function(sRowId){
    this._oController.moveToRowByID(sRowId);
},

/* 
This method scrolls horizontally to make sure a column is visible.

@param  iCol    Column index.
@client-action
*/
scrollToCol : function(iCol){
    if(this.pbScroll && this._oBody){
        this._oBody.scrollToCol(iCol);
    }
},

/*
@client-action
*/
search : function(sSearch){
    this._oController.search(sSearch);
},

/*
@client-action
*/
showSearch : function(sSearch){
    this._oController.showSearch(sSearch);
},

set_psCurrentRowId : function(sVal){
    if(this._oController){
        this._oController.setCurrentRowId(sVal);        
    }
},

get_psCurrentRowId : function(){
    return this.currentRowId();
},
get_piRowCount : function(){
    return (this._oModel && this._oModel.aData.length) || 0;
},
get_piCurrentRowIndex : function(){
    return (this._oModel && this._oModel.iCurrentRow);
},

set_piSortColumn : function(iVal){
    this.propertyUpdate("piSortColumn", iVal);
},
set_pbReverseOrdering : function(bVal){
    this.propertyUpdate("pbReverseOrdering", bVal);
},
set_psPlaceHolder : function(bVal){
    this.propertyUpdate("psPlaceHolder", bVal);
},
set_pbShowHeader : function(bVal){
    this.propertyUpdate("pbShowHeader", bVal);
},
set_pbShowSelected : function(bVal){
    this.propertyUpdate("pbShowSelected", bVal);
},
set_pbColumnsResizable : function(bVal){
    this.propertyUpdate("pbColumnsResizable", bVal);
},
set_pbAutoColumnSizing : function(bVal){
    this.propertyUpdate("pbAutoColumnSizing", bVal);
    this.redraw();
},

// - - - - Supportive - - - -

/* 
Handles the update of a property by triggering onSettingChange so the modules can respond to the 
change. It first stores the new values.

@param  sProp   Name of the property.
@param  val     The new value.
*/
propertyUpdate : function(sProp, val){
    var prev;
    
    if(this[sProp] !== val){
        prev = this[sProp];
        this[sProp] = val;
        this._onSettingChange.fire(this, {
            sType : "prop",
            sProp : sProp,
            newval : val,
            prevval : prev
        });
    }
},

/* 
Called by the column object when its psValue is being updated.


@param  oCol    The column object.
@param  sVal    The new value.
*/
updateCurrentCell : function(oCol, sVal){
    this._oController.updateCell(oCol, sVal);
},

/* 
Function that is called mainly by columns if their properties have changed. Forces a full redraw of 
the grid after a short timeout. This timeout is added so that call handlers (like HandleChangeRow) 
are not disturbed.
*/
redraw : function(){
    var that = this;
    
    if(this._tRedraw){
        clearTimeout(this._tRedraw);
    }
    
    this._tRedraw = setTimeout(function(){
        that._onSettingChange.fire(that, {
            sType : "prepare-redraw"
        });
        that._onSettingChange.fire(that, {
            sType : "redraw"
        });

        that._tRedraw = null;
    }, 10);
},

/* 
Finds the cell element that belongs to this column for the current row.

@param  oCol    Column object (df.WebColumn).
@return DOM element (TD) for the column (null if not found / available).
*/
getColCell : function(oCol){
    return this._oBody.colCell(oCol);
},

/* 
Finds the header cell for the specified column.

@param  oCol    Column object (df.WebColumn).
@return DOM element (TH) for the column header (null if not found / available).
*/
getColHead : function(oCol){
    return this._oHeader.colCell(oCol);
},


/* 
Finds the cell element for the specified row and column.

@param  iRow    Row number for which we want the cell element.
@param  iCol    Column number for the cell.
@return DOM element (TD) for the column (null if not found / available).
*/
getCell : function(iRow, iCol){
    var sRowId = this._oModel.rowIdByRowIndex(iRow);
    
    return this._oBody.cell(sRowId, iCol);
},

currentRowId : function(){
    return (this._oModel && this._oModel.sCurrentRowId) || "";
},

// - - - - - - - Focus - - - - - - -
/*
We override the focus method and make it give the focus to the hidden focus holder element.

@return True if the List can take the focus.
*/
focus : function(){
    if(this._bFocusAble && this.isEnabled() && this._eFocus){
        this._eFocus.focus();
        
        this.objFocus();
        return true;
    }

    return false;
},

onListClick : function(oEv){
    this.focus();
},

onFocus : function(oEvent){
    if(!this._bHasFocus){
        df.WebList.base.onFocus.call(this, oEvent);
    }
    
    this._bLozingFocus = false;
},

onBlur : function(oEvent){
    var that = this;
    
    this._bLozingFocus = true;
    
    setTimeout(function(){
        if(that._bLozingFocus){
            df.WebList.base.onBlur.call(that, oEvent);
            
            that._bLozingFocus = false;
        }
    }, 100);
},

deserializeVT : df.sys.vt.generateDeserializer([ df.tWebRow ]),
serializeVT : df.sys.vt.generateSerializer([ df.tWebRow ])

});