/*
Name:
    vdf.deo.Lookup
Type:
    Prototype
Extends:
    vdf.core.List
Revisions:
    2005/10/24  Created the initial version. (HW, DAE)
    2008/02/15  Started a full rewrite for the 2.0 architecture. (HW, DAE)
*/

/*
@require    vdf/core/List.js
*/

/*
Constructor that applies to the interface required by the initialization system 
(see vdf.core.init). Calls the super constructor of the List.

@param  eElement        Reference to the form DOM element.
@param  oParentControl  Reference to a parent control.
*/
vdf.deo.Lookup = function Lookup(eElement, oParentControl){
    this.List(eElement, oParentControl);
    
    /*
    The CSS class that applied to the currently selected row.
    */
    this.sCssRowSelected = this.getVdfAttribute("sCssRowSelected", "rowselected");
};
/*
Extends the lookup list with the functionallity to display as a lookup list.
*/
vdf.definePrototype("vdf.deo.Lookup", "vdf.core.List", {

/*
Augments the select method with the functionality to display the selected row 
as selected. Does this by adding the sCssRowSelected class to the row.

@param  tRow        The snapshot of the row to select.
@param  fFinished   (optional) Function that is called after the select action is 
                finished.
@param  oEnvir      (optional) Environment used when calling fFinished.
*/
select : function(tRow, fFinished, oEnvir){
    tRow.__eRow.className = this.sCssRowSelected + " " + tRow.__eRow.className;
    
    this.List.prototype.select.call(this, tRow, fFinished, oEnvir);
},
/*
Augments the select method with the functionality to display the selected row 
as selected. Does this by removing the sCssRowSelected class from the selected
row.
*/
deSelect : function(){
    if(this.tSelectedRow !== null){
        if(this.tSelectedRow.__eRow.className.match(this.sCssRowSelected)){
             this.tSelectedRow.__eRow.className = this.tSelectedRow.__eRow.className.replace(this.sCssRowSelected, "");
        }
    }
    
    this.List.prototype.deSelect.call(this);
    
    return true;
},

/*
Determines the value of the column in the currently selected record.

@param  sColumn     Data binding string of the column.
@return The value of the column (null if not found).
*/
getSelectedValue : function(sColumn){
    if(this.tSelectedRow !== null){
        return this.tSelectedRow.__oData[sColumn.toLowerCase().replace("__", ".")];
    }
    
    return null;
}

});