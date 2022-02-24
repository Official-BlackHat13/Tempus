//
//  Class:
//      VdfLookup
//
//  Represents a lookup. Inherrits the buffer, display & scroll functionality 
//  from the VdfList,
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
//  Constructo of the DbLookup class. Calls the super constructor and 
//  initializes the properties.
//
//  Params:
//      oTable      HTML element of table
//      oVdfForm    Parent form object
//
function VdfLookup(oTable, oVdfForm){
    this.base = VdfList;
    this.base(oTable, oVdfForm);
    
    this.sCssRowSelected = browser.dom.getVdfAttribute(this.oTable, "sCssRowSelected", "VdfRowSelected");
}

//  Extend DbList
VdfLookup.prototype = new VdfList;

//
//  Selects a record by setting the css class
//
//  Parameters
//      oRecord             The record that should be selected
//
//  PRIVATE
VdfLookup.prototype.selectRecord = function(oRecord){
    browser.events.removeGenericListener('mouseover', oRecord.oRow, this.onRecordMouseOver);
    browser.events.removeGenericListener('mouseout', oRecord.oRow, this.onRecordMouseOut);
    
    oRecord.oRow.className += " " + this.sCssRowSelected;
}


//
//  Selects a record by removing the css class
//
//  Returns:
//      True if succesfull
//
//  PRIVATE
VdfLookup.prototype.deSelectRecord = function(){
    if(this.oSelectedRecord.oRow.className.contains(this.sCssRowSelected)){
         this.oSelectedRecord.oRow.className = this.oSelectedRecord.oRow.className.replace(" " + this.sCssRowSelected, "");
    }
    
    browser.events.addGenericListener('mouseover', this.oSelectedRecord.oRow, this.onRecordMouseOver);
    browser.events.addGenericListener('mouseout', this.oSelectedRecord.oRow, this.onRecordMouseOut);
    return true;
}


//
//  Params:
//      sColumn Name of the column
//  Returns:
//      The value of the column in the selected record (null if no record 
//      selected)
//
VdfLookup.prototype.getSelectedValue = function(sColumn){
    if(this.oSelectedRecord != null){
        return this.oSelectedRecord.getValue(sColumn);
    }
    
    return null;
}