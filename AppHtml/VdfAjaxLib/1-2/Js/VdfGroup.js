//
//  Class:
//      VdfGroup
//
//  Object that represents a group of fields inside a form. Can be used to set 
//  the servertable of the child fields. Can be attached to any dom element 
//  that can contain fields.
//  
//  Since:      
//      07-03-2007
//  Changed:
//      --
//  Version:    
//      0.1
//  Creator:    
//      Data Access Europe (Harm Wibier)
//

//
//  Constructor, gets the properties.
//
//  Params:
//      oElement    The DOM object representing the group
//      oVdfForm    The vdf form object
//  
function VdfGroup(oElement, oVdfForm){
    this.oVdfForm       = oVdfForm;
    this.oElement       = oElement;
    
    //  Public properties
    this.sName                  = browser.dom.getVdfAttribute(this.oElement, "sControlName", "Group1");
    this.sControlType           = browser.dom.getVdfAttribute(this.oElement, "sControlType", "group");
    this.sServerTable           = browser.dom.getVdfAttribute(this.oElement, "sServerTable", null);
    
    
    
    this.oVdfForm.aVdfChilds[this.oVdfForm.aVdfChilds.length] = this;
    
    if(this.sServerTable != null){
        this.sServerTable = this.sServerTable.toLowerCase();
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
VdfGroup.prototype.addField = function(oField, sDataBinding){
    if(this.sServerTable != null){
        oField.setServerTable(this.sServerTable, false);
    }
    
    this.oVdfForm.addField(oField, sDataBinding);
}