/*
Name:
    vdf.deo.SpinForm
Type:
    Prototype

Revisions:
    2011/03/01  Created the initial version. (HW, DAE)
*/

/*
The constructor of the SpinForm component that implements the API for automatic control 
initialization defined in the vdf.core.Control class. 

@param  eElement        The DOM element defining the menu.
@param  oParentControl  Reference to the parent control if the control is nested.
*/
vdf.deo.SpinForm = function SpinForm(eElement, oParentControl){
    this.TextField(eElement, oParentControl);
    
    /*
    This property determines the number used to increment or decrement the value. For numeric fields 
    it is possible to use values like '0.5' or '0.01' for numeric fields. With date fields this 
    determines the amount of days that are added or subtracted to the date.
    */
    this.nStep = this.getVdfAttribute("nStep", 1, false);
    
    /*
    The CSS class set to the DOM element.
    */
    this.sCssClass          = this.getVdfAttribute("sCssClass", "spinform", false);
    
    // @privates
    this.eNextBtn = null;
    this.ePrevBtn = null;
    this.oActionKeys            = {};
    
    //  Copy settings
    for(sKey in vdf.settings.spinKeys){
        if(typeof(vdf.settings.spinKeys[sKey]) == "object"){
            this.oActionKeys[sKey] = vdf.settings.spinKeys[sKey];
        }
    }
    
    //  Set classname
    vdf.sys.gui.addClass(this.eElement, this.sCssClass);
    this.bDisabled = false;
}
/*
The vdf.deo.SpinForm control will display increment and decrement buttons behind the field. These 
buttons can be used to manipulate the value of the field. It supports numeric and date values. The 
sDataType should be set properly (this happens automatically for data bound fields). While editing 
the field the user can also use the up and down buttons on the keyboard to manipulate the value. If 
the button or key is hold down it will keep on spinning. This control should be used on the HTML 
input element with the type set to text. It can be combined with masks without problems.

The following example shows a numeric non-databound field:
@code
<input vdfControlType="vdf.deo.SpinForm" type="text" name="numfield" vdfDataType="bcd" vdfDataLength="10" vdfPrecision="2">
@code

The following example shows a numeric non-databound  field with a mask and a smaller step:
@code
<input vdfControlType="vdf.deo.SpinForm" class="Data" type="text" value="0" name="numfield" vdfDataType="bcd" vdfMaskType="num" vdfMask=",*.00;(,*.00)" vdfDataLength="10" vdfPrecision="2" vdfZeroSuppress="true" vdfStep="0.1">
@code

The following example shows a non-databound date field:
@code
<input vdfControlType="vdf.deo.SpinForm" class="Data" type="text" value="" name="datefield" vdfDataType="date">
@code

The following example shows a non-databound date field with a mask:
@code
<input vdfControlType="vdf.deo.SpinForm" class="Data" type="text" value="" name="datefield" vdfDataType="date" vdfMaskType="dat" vdfMask="dd Mmm, yyyy" vdfRequired="true">
@code
*/
vdf.definePrototype("vdf.deo.SpinForm", "vdf.core.TextField",{

/*
This method is an initializer that is called by the vdf.core.Form and provides a hook for controls 
to initialize themselves.

@private
*/
formInit : function(){
    var ePrev, eNext;

    this.TextField.prototype.formInit.call(this);
    
    //  Validate / parse the step
    if(typeof this.nStep != "number"){
        this.nStep = this.stringToNum(this.nStep || "1");
    }
    
    //  Create the decrement button
    ePrev = document.createElement('a');
    ePrev.innerHTML = "&nbsp;";
    ePrev.href = "javascript: vdf.sys.nothing();";
    ePrev.className = this.sCssClass + "_prev";
    ePrev.tabIndex = "-1";
    
    vdf.sys.dom.insertAfter(ePrev, this.eElement);
    
    
    //  Create the increment button
    eNext = document.createElement('a');
    eNext.innerHTML = "&nbsp;";
    eNext.href = "javascript: vdf.sys.nothing();";
    eNext.className = this.sCssClass + "_next";
    eNext.tabIndex = "-1";
    
    vdf.sys.dom.insertAfter(eNext, ePrev);
    
    //  Attach event listeners
    vdf.events.addDomListener("mousedown", ePrev, this.onBtnPrev, this);    
    vdf.events.addDomListener("mousedown", eNext, this.onBtnNext, this);    
    vdf.events.addDomListener("keydown", ePrev, this.onKeyDown, this);    
    vdf.events.addDomListener("keydown", eNext, this.onKeyDown, this);    
    vdf.events.addDomListener("keydown", this.eElement, this.onKeyDown, this);    
    
    //  Store references
    this.ePrevBtn = ePrev;
    this.eNextBtn = eNext;
},

/*
The disabled state of the spinform is programmed manually. This method augments the default disable 
method to enable the increment and decrement buttons and to remember the disabled state. 

@private
*/
disable : function(){
    this.TextField.prototype.disable.call(this);
    
    //  Set the disabled attribute (doesn't work on anchors but is picked up by the CSS)
    this.ePrevBtn.setAttribute("disabled", "true");
    this.eNextBtn.setAttribute("disabled", "true");
    this.bDisabled = true;
},

/*
The disabled state of the spinform is programmed manually. This method augments the default enable 
method to enable the increment and decrement buttons and to remember the disabled state. 

@private
*/
enable : function(){
    this.TextField.prototype.enable.call(this);
    
    //  Remove the disabled attribute (doesn't work on anchors but is picked up by the CSS)
    this.ePrevBtn.removeAttribute("disabled");
    this.eNextBtn.removeAttribute("disabled");
    this.bDisabled = true;
},

/*
This method overrides the default insertElementAfter since we have the custom next button after the 
main element.

@private
*/
insertElementAfter : function(eElement){
    if(this.oLookup && typeof this.oLookup.eElement === "object" && this.eElement.parentNode === this.oLookup.eElement.parentNode){
        vdf.sys.dom.insertAfter(eElement, this.oLookup.eElement);
    }else{
        vdf.sys.dom.insertAfter(eElement, this.eNextBtn);
    }
},

/*
This method handles the keydown event of the input element and the button elements. If the key 
matches the up or down key it will call the run method that will start incrementing or decrementing.

@param  oEvent  The event object (see vdf.events.DOMEvent).
@private
*/
onKeyDown : function(oEvent){
    var oPressedKey = {
        iKeyCode : oEvent.getKeyCode(),
        bCtrl : oEvent.getCtrlKey(),
        bShift : oEvent.getShiftKey(),
        bAlt : oEvent.getAltKey()
    };

    
    if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.moveUp)){ 
        this.run(oEvent.eSource, ["keyup", "blur"], true);
        oEvent.stop();
    }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.moveDown)){ 
        this.run(oEvent.eSource, ["keyup", "blur"], false);
        oEvent.stop()
    }
},

/*
This method handles the mousedown event of the next button.

@param  oEvent  The event object (see vdf.events.DOMEvent).
@private
*/
onBtnNext : function(oEvent){
    this.run(oEvent.eSource, ["mouseup", "mouseout"], true);
},

/*
This method handles the mousedown event of the previous button.

@param  oEvent  The event object (see vdf.events.DOMEvent).
@private
*/
onBtnPrev : function(oEvent){
    this.run(oEvent.eSource, ["mouseup", "mouseout"], false);
},

/*
This method performs the actual incrementing or decrementing. It will attach a listener to the 
specified stop event and keeps on spinning until it occurs. 

@param  eElem       The DOM element that initiated the spinning.
@param  aStopEvents Array with string names of the events that should stop the spinning ('mouseup' 
                    or 'keyup').
@param  bUp         Boolean indicating the spin direction (true is up, false is down).
@private
*/
run : function(eElem, aStopEvents, bUp){
    var tInt, that = this, bRun = true, iTimeout = 150, nStep = this.nStep, iStop;
    
    if(!this.bDisabled){
        if(!bUp){
            nStep = 0.0 - nStep;
        }
        
        function onStop(oInEvent){
            bRun = false;
            
            for(iStop = 0; iStop < aStopEvents.length; iStop++){
                vdf.events.removeDomListener(aStopEvents[iStop], eElem, onStop);
            }
        }
        
        //  Add stop listener
        for(iStop = 0; iStop < aStopEvents.length; iStop++){
            vdf.events.addDomListener(aStopEvents[iStop], eElem, onStop);
        }
        
        //  Inner method
        function count(){
            if(bRun){
                that.count(nStep);
                
                //  Decreate timeout to pick up speed
                if(iTimeout > 30){
                    iTimeout -= 10;
                }
                
                //  Schedule next
                setTimeout(count, iTimeout);
            }
        }
        
        //  Do first coun
        this.count(nStep);
        
        //  First time we wait for 300 milli's
        setTimeout(count, 300);
    }
},

/*
This method adds the provided number to the field value. It will only work if the sDataType is set 
to "bcd" or "date".
@code
vdf.getForm("myform").getDEO("myfield").count(-11);
@code

@param  nDiff   The number to add to the value which might be a negative value. Only integers should 
                be used for date fields.
*/
count : function(nDiff){
    var nVal, nMax, nMin, dVal;

    if(this.sDataType == "bcd"){
        nVal = this.getNumber();
        nVal += nDiff;
        
        this.setNumber(nVal);
    }else if(this.sDataType == "date"){
        nDiff = parseInt(nDiff, 10);    //  For dates we only support integers
        
        dVal = this.getDate() || new Date();
        dVal.setDate(dVal.getDate() + nDiff);
        
        this.setDate(dVal);
    }
}



});