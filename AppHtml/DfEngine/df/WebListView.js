/*
Class:
    df.WebListView

The simple non scrolling body view for the WebList its mini MVC model. It simply renders all rows 
without a scollbar.
    
Revision:
    2017/02/10  (HW, DAW) 
        Initial version.
*/
df.WebListView = function WebListView(oList, oModel, oController){
    this.oL = oList;
    this.oM = oModel;
    this.oC = oController;
    this.oR = oList._oRowRenderer;
    
    this.bPreventSubmit = false;    //  If true the double click will not triger the onsubmit. This is used by OnTableClick to explicitly prevent the OnSubmit if OnRowClick is fired.
    this.bCancelClick = false;      //  If true clicks are ignored
    
    this.bScroll = false;

    this.onRowsRendered = new df.events.JSHandler();
    
    oModel.onDataUpdate.on(this.onDataUpdate, this);
    oModel.onRowChange.on(this.onRowChange, this);
    oList._onSettingChange.on(this.onSettingChange, this);
    oController.onCellClick.on(this.onCellClick, this);
    oController.onAfterCellClick.on(this.onAfterCellClick, this);
};
df.defineClass("df.WebListView", {

genHtml : function(aHtml){
    
    aHtml.push('<div class="WebList_BodyWrp">');
    aHtml.push('<div class="WebList_Body', (this.oL.pbShowSelected ? ' WebList_ShowSelected' : ''), '">');
    
    this.tableHtml(aHtml);
    
    aHtml.push('</div></div>');
    
},

afterRender : function(eList){
    this.eBody = df.dom.query(eList, "div.WebList_Body");
    this.eBodyWrp = df.dom.query(eList, "div.WebList_BodyWrp");

    df.dom.addClass(this.oL._eControl, (this.bScroll ? 'WebList_Scrolling' : 'WebList_NoScrolling'));
    
    df.events.addDomListener("click", this.eBody, this.onTableClick, this);
    df.events.addDomListener("dblclick", this.eBody, this.onTableDblClick, this);

    //  Notify other modules of the rendering of rows (genHtml generates rows right away)
    this.onRowsRendered.fire(this);
},

rowHtml : function(tRow, aHtml, bZebra){
    this.oR.rowHtml(tRow, aHtml, bZebra);
},

tableHtml : function(aHtml){
    var oM = this.oM, oR = this.oR, bZebra = false, i;
    
    for(i = 0; i < oM.aData.length; i++){
        this.rowHtml(oM.aData[i], aHtml, bZebra);
        
        bZebra = !bZebra;
    }
},

refreshDisplay : function(){
    var aHtml = [];
    
    if(this.eBody){
        this.tableHtml(aHtml);
        
        this.eBody.innerHTML = aHtml.join("");
        
        //  Notify other modules
        this.onRowsRendered.fire(this);

        //  Trigger a resize on surrounding controls
        this.oL.sizeChanged(false);
    }
},

refreshRow : function(sRowId, sNewRowId){
    var oM = this.oM, iRow, eRow, eNewRow, aHtml = [];
    
    //  Lookup row details
    iRow = oM.rowIndexByRowId(sNewRowId);
    eRow = (this.eBody && df.dom.query(this.eBody, "table[data-dfrowid='" + sRowId + "']")) || null;
    if(iRow >= 0 && eRow){
        
        //  Create new row
        this.rowHtml(oM.aData[iRow], aHtml, (eRow.className.indexOf("WebList_RowOdd") >= 0));
        eNewRow = df.dom.create(aHtml.join(""));
        
        eRow.parentNode.replaceChild(eNewRow, eRow);
    }
},

refreshCell : function(sRowId, oCol){
    var oM = this.oM, eCell, iRow;
    
    eCell = this.cell(sRowId, oCol._iCol);
    iRow = oM.rowIndexByRowId(sRowId);
    if(eCell && iRow >= 0){
        eCell.innerHTML = this.oR.cellHtml(oCol, this.oM.aData[iRow].aCells[oCol._iColIndex]);
    }  
},
    
onDataUpdate : function(oEv){
    
    
    if(oEv.sType === "row"){
        this.refreshRow(oEv.sUpdateRowId, oEv.sNewRowId);
    }if(oEv.sType === "cell"){
        this.refreshCell(oEv.sUpdateRowId, oEv.oCol);
    }else{
        this.refreshDisplay();
    }
},

onRowChange : function(oEv){
    var eRow, ePrevRow;
    
    if(this.eBody){
        if(oEv.sPrevRowId){
            ePrevRow = this.row(oEv.sPrevRowId);
            if(ePrevRow){
                df.dom.removeClass(ePrevRow, "WebList_Selected");
            }
        }
        
        eRow = this.row(oEv.sGotoRowId);
        if(eRow){
            df.dom.addClass(eRow, "WebList_Selected");
        }
    }
},

onSettingChange : function(oEv){
    var oL = this.oL;
    
    if(oEv.sType === "redraw"){
        this.refreshDisplay();
    }else if(oEv.sType === "prop"){
        switch(oEv.sProp){
            case "pbShowSelected":
                if(this.eBody){
                    df.dom.toggleClass(this.eBody, "WebList_ShowSelected", oL.pbShowSelected);
                }
                break;
        }
    }
},

/* 
Returns the DOM element for a specific row (based on the rowid). Null if not found (might not be rendered).
*/
row : function(sRowId){
    return (this.eBody && df.dom.query(this.eBody, 'table.WebList_Row[data-dfrowid="'  + sRowId + '"]')) || null;
},

currentRowElem : function(){
    return this.row(this.oM.sCurrentRowId);
},


/* 
This function handles the click event on the list table. It determines which row and which column is 
clicked. It will trigger the cellClick on the column object and change row if needed.

@param  oEvent  Event object.
@private
*/
onTableClick : function(oEv){
    var eElem = oEv.getTarget(), eRow = null, iCol = -1, that = this;
    
    //  Check enabled state
    if(!this.oL.isEnabled() || this.bCancelClick){
        return;
    }
    
    //  We need to determine if and which row was clicked so we start at the clicked element and move up untill we find the row
    while(eElem.parentNode && eElem !== this.eBody && !eRow){
        //  Check if we found the tr element and if it is part of the table
        if(eElem.tagName === "TD" && eElem.hasAttribute("data-dfcol")){
            
            iCol = parseInt(eElem.getAttribute("data-dfcol"), 10);
            
        }else if(eElem.tagName === "TD" && eElem.hasAttribute("data-dfswbtn")){
            //  This is a bit of a shortcut but we talk to to the touch handler in person
            this.oL._oTouchHandler.swipeBtnClick(oEv, eElem);
            return;
        }else if(eElem.tagName === "TABLE" && eElem.hasAttribute("data-dfisrow")){  
            //  Trigger cell click
            if(this.oC.cellClick(oEv, eElem.getAttribute("data-dfrowid"), iCol)){
                this._bPreventSubmit = true;
                setTimeout(function(){
                    that.bPreventSubmit = false;
                }, 250);
                oEv.stop();    
            }
            return;
        }
        eElem = eElem.parentNode;
    }
},


onTableDblClick : function(oEv){
    //  Check enabled state
    if(!this.oL.isEnabled() || this.bPreventSubmit){
        return;
    }
    
    this.oL.fireSubmit();
},


/* 
Handles the cellclick event from the controller to visualize the click.
*/
onCellClick : function(oEv){
    var that = this;

    this.bHitDone = false;
    this.eHitElem = this.row(oEv.sRowId);
    df.dom.addClass(this.eHitElem, df.CssHit);
    this.tHitTimer = setTimeout(function(){
        if(that.bHitDone){
            df.dom.removeClass(that.eHitElem, df.CssHit);
        }
        that.tHitTimer = null;
    }, df.hitTimeout);
},


onAfterCellClick : function(oEv){
    if(!this.tHitTimer){
        df.dom.removeClass(this.eHitElem, df.CssHit);
    }
    this.bHitDone = true;
},



setHeight : function(iHeight){

},

/* 
Finds the cell element for the specified row and column.

@param  sRowId    RowId for which we want the cell element.
@param  iCol    Column number for the cell.
@return DOM element (TD) for the column (null if not found / available).
*/
cell : function(sRowId, iCol){
    return (this.eBody && df.dom.query(this.eBody, "table[data-dfrowid='" + sRowId + "'] td[data-dfcol='" + iCol + "']")) || null;
},

/* 
Returns the cell for provided column in the current row.

@param  oCol    Column object.
@return DOM element for the current cell (null if not available).
*/
colCell : function(oCol){
    return this.cell(this.oM.sCurrentRowId, oCol._iCol);
},

colCellByIndex : function(iCol){
    return this.cell(this.oM.sCurrentRowId, iCol);
},

/* 
Used by the WebListHeaderView to align headers with scrollbar.
*/
scrollbarWidth : function(){
    return 0;
},

/* 
Used by WebListController to determine page size for page up and page down.
*/
getViewSize : function(){
    return 10;
},

fullwidth : function(){
    return (this.eBody && this.eBody.clientWidth) || 0;
},

setExtraRowHeight : function(sRowId, iExtra){

},

getExtraRowHeight : function(sRowId){
    return 0;
}

});