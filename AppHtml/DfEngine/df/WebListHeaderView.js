/*
Class:
    df.WebListHeaderView

One of the view classes in the list its mini MVC model. It is responsible for rendering the header 
and triggers click events on the controller. The WebList and WebListRowModel provide details needed 
to display the header.

Revision:
    2017/02/10  (HW, DAW) 
        Initial version.
*/
df.WebListHeaderView = function WebListHeaderView(oList, oModel, oController){
    this.oL = oList;
    this.oC = oController;
    this.oR = oList._oRowRenderer;
    
    oList._onResize.on(this.onResize, this);
    oList._onSettingChange.on(this.onSettingChange, this);
    oList._onModulesCreated.on(this.onModulesCreated, this);
};
df.defineClass("df.WebListHeaderView", {

onModulesCreated : function(oEv){
    var oV = this.oL._oBody;

    if(oV instanceof df.WebListScrollingView){
        oV.onHorizontalScroll.on(this.onHorizontalScroll, this);
    }
},

genHtml : function(aHtml){
    var oL = this.oL;
    

    aHtml.push('<div class="WebList_Head"', (oL.pbShowHeader ? '' : ' style="display:none"'), '>');
    aHtml.push('<div class="WebList_HeadWrp', (oL.pbColumnsResizable ? ' WebList_ColResizable' : ''), (oL.pbAutoColumnSizing ? " WebList_AutoSize" : " WebList_HorizScroll"), '">');
    this.headerHtml(aHtml);
    aHtml.push('</div>');
    aHtml.push('</div>');
},

afterRender : function(eList){
    this.eHead = df.dom.query(eList, "div.WebList_Head");
    this.eHeadWrp = df.dom.query(eList, "div.WebList_HeadWrp");
    
    df.dom.on("click", this.eHead, this.onHeadClick, this);
    df.dom.on("mousedown", this.eHead, this.onHeadMouseDown, this);
    df.dom.on("dblclick", this.eHead, this.onHeadDblClick, this);
},

headerHtml : function(aHtml){
    var oL = this.oL, oR = this.oR, sCssClass, i, oCol, oCurCol, oPrevCol, oLast = null;
    
    aHtml.push('<table style="width:', oR.sTableWidth, '">');
    oR.resizeRowHtml(aHtml);
    aHtml.push('<tr>');
    
    //  Determine last
    for(i = oL._aColumns.length - 1; i >= 0; i--){
        if(oL._aColumns[i].pbRender){
            oLast = oL._aColumns[i];
            break;
        }
    }

    for(i = 0; i < oL._aColumns.length; i++){
        
        oCol = oL._aColumns[i];
        
        if(oCol.pbRender){
            oPrevCol = oCurCol;
            oCurCol = oCol;
            
            if(oCol.pbNewLine){
                aHtml.push('</tr><tr>');
            }
        
            //  Determine column CSS class
            sCssClass = "WebList_ColHead";
            if(i === oL.piSortColumn){
                sCssClass += (!oL.pbReverseOrdering ? " WebList_SortedReverse" : " WebList_Sorted");
            }
            if(oL.pbColumnSortable && oCol.pbSortable){
                sCssClass += " WebList_Sortable";
            }
            sCssClass += " " + this.oR.cellClass(oCol, null);
                    
            
            aHtml.push('<th class="', sCssClass, '" data-dfcol="', i, '"');
            if(oCol.piListRowSpan > 1){
                aHtml.push(' rowspan="', oCol.piListRowSpan, '"');
            }
            if(oCol.piListColSpan > 1){
                aHtml.push(' colspan="', oCol.piListColSpan, '"');
            }
            if(oCol.psToolTip){
                aHtml.push(' title="', df.dom.encodeHtml(oCol.psToolTip), '"');
            }
            
            aHtml.push('><div>');
            aHtml.push('<div class="WebList_ColCap">', (oCol.psCaption || '&nbsp;'), '</div>');
            if(oCol.pbResizable && (!oL.pbAutoColumnSizing || oCol !== oLast)){
                aHtml.push('<div class="WebList_ColSep" data-dfcol="', oCol._iCol, '"></div>');
            }
            
            // if(!oL.pbAutoColumnSizing){
            //     bLast = true;
            //     for(x = i + 1; x < oL._aColumns.length; x++){
            //         if(oL._aColumns[x].pbRender){
            //             bLast = false;
            //             break;
            //         }
            //     }
            //     if(bLast){
            //         aHtml.push('<div class="WebList_ColSep" data-dfcol="', oCol._iCol, '"></div>');
            //     }
            // }
            aHtml.push('</div></th>');
                
        }
        
    }
    aHtml.push('</tr></table>');
    
},

updateHeader : function(){
    var aHtml = [];
    
    if(this.eHeadWrp){
        this.headerHtml(aHtml);
        this.eHeadWrp.innerHTML = aHtml.join("");
    }
},

/* 
Queried by WebList to determine height used in height calculation of the body.
*/
offsetHeight : function(){
    if(this.eHead){
        return this.eHead.offsetHeight;
    }
},


/*
Handles the onclick event on the list header. It will determine which column is clicked and if 
pbColumnSortable is true and pbSortable of the column is true it will update the sorting by calling 
the changeSorting method.

@param  oEv  The event object (df.events.DOMEvent).
@return
*/
onHeadClick : function(oEv){
    var eElem = oEv.getTarget(), iCol;
    
    //  Check enabled state
    if(!this.oL.isEnabled()){
        return;
    }
    
    
    //  Find the column header div
    while(eElem.parentNode && eElem !== this._eHead){
        if(eElem.tagName === "TH" && eElem.hasAttribute("data-dfcol")){
            //  Determine the column
            iCol = parseInt(eElem.getAttribute("data-dfcol"), 10);
            
            if(this.oC.headClick(oEv, iCol)){
                oEv.stop();
            }
            return;
        }
        
        eElem = eElem.parentNode;
    }
    
},

/*
Handles the double click event on the list header. It will determine which column is clicked and if 
pbColumnSortable is true and pbSortable of the column is true it will update the sorting by calling 
the changeSorting method.

@param  oEv  The event object (df.events.DOMEvent).
@return
*/
onHeadDblClick : function(oEv){
    var eElem = oEv.getTarget(), iCol;
    
    //  Check enabled state
    if(!this.oL.isEnabled()){
        return;
    }
    
    
    //  Find the column header div
    while(eElem.parentNode && eElem !== this._eHead){
        if(eElem.tagName === "TH" && eElem.hasAttribute("data-dfcol")){
            //  Determine the column
            iCol = parseInt(eElem.getAttribute("data-dfcol"), 10);
            
            if(this.oC.headDblClick(oEv, iCol)){
                oEv.stop();
            }
            return;
        }
        
        eElem = eElem.parentNode;
    }
    
},

onHeadMouseDown : function(oEv){
    var eTarget = oEv.getTarget();
    
    //  Check enabled state
    if(!this.oL.isEnabled()){
        return;
    }

    //    Check if it is the resize div
    if(eTarget.className === 'WebList_ColSep' && this.oL.pbColumnsResizable){
        this.resizeColumn(oEv, parseInt(eTarget.getAttribute('data-dfcol'), 10));
        
        oEv.stop();
        return false;
    }
    
    return true;
},


resizeColumn : function(oEv, iCol){
    var oL = this.oL, oR = this.oR, eMask, eGhost, iLeft = 0, iRatio, iPX = 0, iStartX, iDiff = 0, iMin, iMax = 0, i, iVCol, oRect;
    
    //  First create our drag mask
    eMask = df.gui.dragMask();
    eMask.style.cursor = "e-resize";

    //  Determine percentage to pixel ratio
    iRatio = oR.calcPixelRatio(); //this.findColNr(oR.aColWidths[iCol].oCol));
    iVCol = oR.findVColNr(oL._aColumns[iCol]);
    
    //  Get fixed position of slider
    oRect = oEv.getTarget().getBoundingClientRect();

    //  Determine current position and maximum
    if(oL.pbAutoColumnSizing){
        for(i = iVCol + 1; i < oR.aColWidths.length; i++){
            if(oR.aColWidths[i].oCol.pbResizable){   //  Do not increase maximum with columns that are not resizable so they never get smaller
                if(oR.aColWidths[i].bFixed){
                    iPX = oR.aColWidths[i].iPixels;
                }else{
                    iPX = (oR.aColWidths[i].iPercent * iRatio);
                }
                //    Determine minimum
                iMax += iPX - oR.iColMin;
            }
        }
    }else{
        iMax = screen.width - oRect.left;
    }
    iStartX = oEv.getMouseX();
    
    //    Determine minimum
    if(oR.aColWidths[iVCol].bFixed || !oL.pbAutoColumnSizing){
        iMin = -oR.aColWidths[iVCol].iPixels + oR.iColMin;
    }else{
        iMin = -(oR.aColWidths[iVCol].iPercent * iRatio) + oR.iColMin;
    }
    
    //    Create ghost separator
    
    iLeft = oRect.left;
    eGhost = df.dom.create('<div class="WebList_ColResizer"></div>');
    this.eHead.appendChild(eGhost);
    eGhost.style.left = iLeft + "px";
    eGhost.style.top = oRect.top + "px";
    eGhost.style.height = oL._eElem.clientHeight + "px"; //(this._eHead.clientHeight + this._eBody.clientHeight) + "px";
    
    //  Resizer function that handles the mousemove and calculates the pixel difference and moves the ghost separator
    function onResize(oEv){
        var iNewX = oEv.getMouseX(), iNewLeft;
        
        //  Calculate new difference
        iDiff = iNewX - iStartX;
        
        //  Check against min and max
        if(iDiff < iMin){
            iDiff = iMin;
        }
        if(iDiff > iMax){
            iDiff = iMax;
        }
        
        // df.debug("iDiff (" + iDiff + ") = iNewX(" + iNewX + " - iStartX(" + iStartX + ");");
        //  Apply to ghost
        iNewLeft = iLeft + iDiff;
        eGhost.style.left = iNewLeft + "px";
    }
    
    //  Handles the events that should stop the drag and 
    function onStopResize(oEv){
        
        //  Remove event handlers
        df.dom.off("mouseup", eMask, onStopResize);
        df.dom.off("mouseup", window, onStopResize);
        //df.dom.off("mouseout", eMask, onStopResize);
        df.dom.off("mousemove", eMask, onResize);
        
        //  Remove ghost & mask
        eGhost.parentNode.removeChild(eGhost);
        eMask.parentNode.removeChild(eMask);
        
        //  Update column sizes
        this.oR.recalcColumnSizes(iVCol, iDiff, false);
    }
    
    //  Attach event handlers
    df.dom.on("mouseup", eMask, onStopResize, this);
    df.dom.on("mouseup", window, onStopResize, this);
    //df.dom.on("mouseout", eMask, onStopDrag, this);
    df.dom.on("mousemove", eMask, onResize, this);
},

colCell : function(oCol){
    return this.colCellByIndex(oCol._iCol);
},

colCellByIndex : function(iCol){
    return df.dom.query(this.eHeadWrp, "th.WebList_ColHead[data-dfcol='" + iCol + "']");
},

onSettingChange : function(oEv){
    var oL = this.oL;
    
    if(oEv.sType === "redraw"){
        this.updateHeader();
    }else if(oEv.sType === "sorting"){
        this.updateHeader();
    }else if(oEv.sType === "prop"){
        switch(oEv.sProp){
            case "piSortColumn":
            case "pbReverseOrdering":
                this.updateHeader();
                break;
            case "pbShowHeader":
                if(this.eHead){
                    this.eHead.style.display = (oL.pbShowHeader ? "" : "none");
                    oL.sizeChanged();
                }
                break;
            case "pbColumnsResizable":
                if(this.eHead){
                    df.dom.toggleClass(this.eHeadWrp, "WebList_ColResizable", oL.pbColumnsResizable);
                }
                break;
            case "pbAutoColumnSizing":
                df.dom.toggleClass(this.eHeadWrp, "WebList_AutoSize", this.oL.pbAutoColumnSizing);
                df.dom.toggleClass(this.eHeadWrp, "WebList_HorizScroll", !this.oL.pbAutoColumnSizing);
        }
    }
},

onResize : function(oEv){
    
    if(this.eHead && this.oL._oBody){
        this.eHead.style.paddingRight = this.oL._oBody.scrollbarWidth() + "px";
    }
},

onHorizontalScroll : function(oEv){
    if(this.eHeadWrp){
        this.eHeadWrp.scrollLeft = oEv.nScrollX;
    }
}

});