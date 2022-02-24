/*
Class:
    df.WebColumn
Mixin:
    df.WebColumn_mixin (df.WebColumnBase)
Extends:
    df.WebForm

This is the client-side representation of the cWebColumn control. The cWebColumn control is 
the default column for the cWebList & cWebGrid controls and should only be used as a nested object 
for those classes. It extends the input form and adds the functionality needed to let it function 
within the grid or list.
    
Revision:
    2011/12/01  (HW, DAW) 
        Initial version.
    2013/08/15  (HW, DAW)
        Rewrote to use df.WebColumn_mixin.
*/


df.wbNone = 0;        // No wrapping, no line breaks
df.wbWrap = 1;          // Wrap on words, no line breaks
df.wbPre  = 2;          // No wrapping, line breaks
df.wbPreWrap = 3;       // Word wrapping and line breaks
df.wbEllipsis = 4;      // No wrapping and "..." when clipping



//  Generate new base class using df.WebColumn_mixin and df.WebForm
df.WebColumnBase = df.mixin("df.WebColumn_mixin", "df.WebForm");


df.WebColumn = function WebColumn(sName, oParent){
    df.WebColumn.base.constructor.call(this, sName, oParent);
    
    this.prop(df.tInt, "peWordBreak", df.wbNone);
    
    //  Configure super class
    //this._sCellClass = "WebCol";
};
df.defineClass("df.WebColumn", "df.WebColumnBase",{

create : function(){
    this._sCellClass = "WebCol " + this.getWordBreakClass(this.peWordBreak);
},

/* 
Augments the cellHtml function with support for the pbPassword property.

@param  tCell   Struct with cell data.
@return HTML content of the cell &bull;&bull; for passwords.
*/
cellHtml : function(tCell){
    if(this.pbPassword){
        return tCell.sValue.replace(/./g, "&bull;");
    }else{
        return df.WebColumn.base.cellHtml.call(this, tCell);
    }
},

tooltipValue : function(tCell){
    if(this.pbPassword){
        return tCell.sValue.replace(/./g, "&bull;");
    }else{
        return df.WebColumn.base.tooltipValue.call(this, tCell);
    }
    
},

set_peWordBreak : function(iVal){
    if(this.peWordBreak !== iVal){
        this._sCellClass = "WebCol " + this.getWordBreakClass(iVal);
        this._oParent.redraw();
    }
},

getWordBreakClass : function(eMode){
    switch(eMode){
        case df.wbWrap:
            return "WebWrp_Wrap";
        case df.wbPre:
            return "WebWrp_Pre";
        case df.wbPreWrap:
            return "WebWrp_PreWrap";
        case df.wbEllipsis:
            return "WebWrp_Ellipsis";
            
    }
    //  df.wbNone
    return "WebWrp_None";
}

});