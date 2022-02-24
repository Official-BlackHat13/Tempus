/*
Name:
    vdf.deo.Select
Type:
    Prototype
Extends:
    vdf.core.Field
Revisions:
    2008/02/07  Implemented the initial version based on the VdfField in 
    previous releases. (HW, DAE)
*/

/*
@require    vdf/core/Field.js
*/

/*
Constructor, calls the parent constructor (Field) and initializes the 
properties.

@param  eSelect         Select element.
@param  oParentControl  Control in which the select is located.
*/
vdf.deo.Select = function Select(eSelect, oParentControl){
    this.Field(eSelect, oParentControl);
    
    /*
    If true the validation table is loaded into the select list.
    */
    this.bAutoFill = this.getVdfAttribute("bAutoFill", true);
    /*
    If true the description balue from the validation table is displayed instead 
    of the value.
    */
    this.bUseDescriptionValue = this.getVdfAttribute("bUseDescriptionValue", true);
};
/*
Implements the field with specific Select box functionallity. Is initialized by
the vdf.core.Initializer for <select elements. Contains the functionallity to 
load description values.
*/
vdf.definePrototype("vdf.deo.Select", "vdf.core.Field", {

/*
Called by the form to initialize the field. Loads description values if needed.

@private
*/
formInit : function(){
    this.Field.prototype.formInit.call(this);
    
    if(this.bAutoFill && this.sDataBindingType == "D"){
        //  Tell the form to wait for us with finishing initialization
        this.oForm.iInitFinishedStage++;
        
        this.oForm.oMetaData.loadDescriptionValues(this.sDataBinding, this.onDValuesLoaded, this);
    }
},

/*
Handles the meta data field values response. It displays the values and 
notifies the form that the initialization is completed.

@private
*/
onDValuesLoaded : function(aValues){
    var iVal;

    for(iVal = 0; iVal < aValues.length; iVal++){
        this.eElement.options[this.eElement.options.length] = new Option((this.bUseDescriptionValue ? aValues[iVal].sDescription : aValues[iVal].sValue), aValues[iVal].sValue);
        //  TODO: SET Default Value?
    }
    
    //  Update the display value
    this.sDisplayValue = this.getValue();
    
    this.oForm.childInitFinished();
},

/*
Overrides the setValue method and adds the functionallity that makes sure that 
the first option is selected if the field is set to empty and no empty value is 
selected. This rules out the differences between the different browsers.

@param  sValue          The new value.
@param  bNoNotify       (optional) If true the DD is not updated with this change.
@param  bResetChange    (optional) If true the display changed is cleared.
*/
setValue : function(sValue, bNoNotify, bResetChange){
    //  If value is empty we select the first already
    if(sValue === ""){
        this.eElement.selectedIndex = 0;
    }
    
    this.eElement.value = sValue;
    
    //  IE can be empty, if that happens we do like other browsers and select the first
    if(this.eElement.selectedIndex < 0){
        this.eElement.selectedIndex = 0;
    }
    
    //  Update DD
    if(!bNoNotify){
        this.update();
    }
    
    //  Fire event
    this.onChange.fire(this, { "sValue" : sValue });
    
    //  Store origional value
    this.sOrigValue = sValue;
    
    if(bResetChange){
        this.sDisplayValue = this.getValue();
    }
},


/*
Gives the focus to the field by giving the focus to the input element.
*/
focus : function(){
    vdf.sys.dom.focus(this.eElement);
}

});
