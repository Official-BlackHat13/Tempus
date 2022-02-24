/*
Name:
    vdf.gui.PopupCalendar
Type:
    Prototype
Revisions:
    2008/10/08  Initial version created after rewriting the Calendar for the 
    2.0 release (HW, DAE)
*/

/*
@require    vdf/gui/Calendar.js
*/


/*
Constructor that applies to the initializer interface.

@param  eElement        DOM element that will open the calendar.
@param  oParentControl  (optional) Parent control like a Form or Grid.
*/
vdf.gui.PopupCalendar = function PopupCalendar(eElement, oParentControl){
    /*
    Reference to the DOM element that opens the calendar.
    */
    this.eElement = eElement;
    /*
    Reference to the parent control.
    */
    this.oParentControl = (typeof(oParentControl) === "object" ? oParentControl : null);
    /*
    The name of the control.
    
    @html
    */
    this.sName = vdf.determineName(this, "popupcalendar");
    
    /*
    The CSS class set to the generated popup calendar.
    */
    this.sCssClass = this.getVdfAttribute("sCssClass", "popupcalendar", true);
    /*
    Optional, the field name or data binding of the data entry object that 
    should be filled with the value and is used to determine the initial date. 
    Requires the popup calendar to be defined inside a Form.
    */
    this.sFieldName = this.getVdfAttribute("sFieldName", null, false);
    /*
    Optional, reference to an input element that should be filled with the 
    picked date and is used to determine the initial date.
    */
    this.eInput = null;
    /*
    If true the popup calendar attaches itself to the onclick event of the 
    opening element. If a sFieldName is given it also sets itself as the lookup 
    object for this field (usually opened using F4).
    */
    this.bAttach = this.getVdfAttribute("bAttach", true, false);
    
    /*
    The date format used when getting and setting the date.
    
    @html
    @htmlbubble
    */
    this.sDateFormat = null;
    /*
    The date mask used for displaying the date (in the the today bar).
    
    @html
    @htmlbubble
    */
    this.sDateMask = null;
    /*
    The date separator used within the date format.
    
    @html
    @htmlbubble
    */
    this.sDateSeparator = null;
    
    /*
    Fired when the popup calendar is closed.
    */
    this.onClose = new vdf.events.JSHandler();
    
    // @privates
    this.eContainerDiv = null;
    this.oCalendar = null;
    this.oForm = null;
    this.oField = null;
    
    
    //  Find reference to form
    if(oParentControl !== null && typeof(oParentControl) === "object"){
        if(oParentControl.bIsForm){    
            this.oForm = oParentControl;
        }else if(typeof(oParentControl.getForm) === "function"){
            this.oForm = oParentControl.getForm();
        }
    }
};
/*
A wrapper for the vdf.gui.Calendar that displays it as a popup window inside the 
page. It contains the functionality to bind it to a field so it gets and sets 
the value from there. The Calendar can be used by declaring it in the page 
using the vdfControlType="PopupCalendar" or by calling the 
vdf.gui.show_FieldPopupCalendar. It can also work directly on input elements 
using the vdf.gui.show_FieldPopupCalendar method.

Declarative (inside a Form):
@code
<input type="button" vdfControlType="popupcalendar" vdfFieldName="order__date" vdfDisplayToday="false" />
@code
JavaScript API:
@code
<input type="button" onclick="vdf.gui.show_InputPopupCalendar(this, document.getElementById('myspecialdatefield'), 'YYYY/MM/DD');" />
@code
@code
<input type="button" onclick="vdf.gui.show_FieldPopupCalendar(this, 'orderhea__order_date');" />
@code
*/
vdf.definePrototype("vdf.gui.PopupCalendar", {

/*
Initialize by finding a reference to the Field object. It tries to find a date 
format and if needed it attaches the onclick of the button and sets itself as 
the oLookup of the field.

@private
*/
formInit : function(){
    var oField;
    
    //  Find a reference to the field
    if(this.sFieldName !== null){
        oField = (this.oForm && this.oForm.getDEO(this.sFieldName)) || vdf.getControl(this.sFieldName);

        if(oField !== null){
            this.oField = oField;
            
            //  Attach to the field object (so it opens on the lookup key (F4))
            if(this.bAttach){
                oField.oLookup = this;
            }
        }
    }
    
     //  Load date format
    if(this.oForm !== null){
        this.sDateFormat = this.getVdfAttribute("sDateFormat", this.oForm.oMetaData.getGlobalProperty("sDateFormat"), true);
        this.sDateMask = this.getVdfAttribute("sDateMask", (this.oField !== null ? this.oField.getMetaProperty("sMask") : this.oForm.oMetaData.getGlobalProperty("sDateFormat")), true);
        this.sDateSeparator = this.getVdfAttribute("sDateSeparator", this.oForm.oMetaData.getGlobalProperty("sDateSeparator"), true);
    }
    
    //  Attach event listeners
    if(this.bAttach){
        vdf.events.addDomListener("click", this.eElement, this.onButtonClick, this);
    }
},  

/*
Displays the calendar popup and tries to load the value into it.

@param  oSource (not used) Source object for the action.
*/
display : function(oSource){
    var eContainerDiv, oCalendar, sValue = "";

    if(this.oCalendar === null){
        //  Generate a absolute positioned div in which the calendar should be displayed.
        eContainerDiv = document.createElement("div");
        eContainerDiv.className = this.sCssClass;
        vdf.sys.dom.insertAfter(eContainerDiv, this.eElement);
        
        //  Generate the calendar
        oCalendar = new vdf.gui.Calendar(this.eElement, this);
        oCalendar.eContainerElement = eContainerDiv;
        oCalendar.onEnter.addListener(this.onCalendarEnter, this);
        oCalendar.onClose.addListener(this.onCalendarClose, this);
        oCalendar.bExternal = true;
        this.eElement.oVdfControl = this;
        
        if(this.sDateFormat !== null){
            oCalendar.sDateFormat = this.sDateFormat;
        }
        if(this.sDateMask !== null){
            oCalendar.sDateMask = this.sDateMask;
        }
        if(this.sDateSeparator !== null){
            oCalendar.sDateSeparator = this.sDateSeparator;
        }
        
        oCalendar.construct();
        
        //  Find & set the value
        if(this.oField !== null){
            sValue = this.oField.getValue();
         
        }else if(this.eInput !== null){
            sValue = this.eInput.value;
        }
        
        if(!oCalendar.setValue(sValue)){
            //  If the value is not set display the calendar on the default date (today)
            oCalendar.displayCalendar();
        }
        
        oCalendar.takeFocus();
        
        // for IE <= 6
        vdf.sys.gui.hideSelectBoxes(eContainerDiv, null);
        
        this.eContainerDiv = eContainerDiv;
        this.oCalendar = oCalendar;
    }
},

/*
Hides the popup dialog and fires the onClose.
*/
hide : function(){
    if(this.oCalendar !== null){
        // for IE <= 6
        vdf.sys.gui.displaySelectBoxes(this.eContainerDiv, null);
    
        this.oCalendar.destroy();
        this.oCalendar = null;
        this.eContainerDiv.parentNode.removeChild(this.eContainerDiv);
        this.eContainerDiv = null;
        
        this.onClose.fire(this, null);
    }
},



/*
Clears the event listeners and DOM references.
*/
destroy : function(){
    this.hide();
    
    if(this.bHandleOnClick){
        vdf.events.removeDomListener("click", this.eElement, this.onButtonClick);
    }
    this.eElement = null;
    this.eContainerDiv = null;
    
    this.oParentControl = null;
    this.oCalendar = null;
},

/*
Handles the onclick event of the eElement element if attached.

@param  oEvent  Event object

@private
*/
onButtonClick : function(oEvent){
    if(this.oCalendar === null){
        this.display();
    }else{
        this.hide();
    }
},

/*
Handles the onEnter event of the calendar object and hides the calendar after 
loading the value.

@param  oEvent  Event object

@private
*/
onCalendarEnter : function(oEvent){
    var sValue = this.oCalendar.getValue();
    
    this.hide();
    
    if(this.oField !== null){
        this.oField.setValue(sValue);
        this.oField.focus();
    }else if(this.eInput !== null){
        this.eInput.value = sValue;
        vdf.sys.dom.focus(this.eInput);
    }
},

/*
Handles the onClose event of the calendar and hides the calendar.

@param  oEvent  Event object

@private
*/
onCalendarClose : function(oEvent){
    this.hide();
},


/*
Method used to determine vdf attributes (which are usually set on the element).
Some attributes bubble which means that if a parent control is known this 
parent control is asked for the attribute value. Almost all attributes have a 
default value.

@param  sName       Name of the attribute.
@param  sDefault    Value returned if attribute not available.
@param  bBubble     If true the parent is asked for the value.
@return Value of the attribute (sDefault if not set).
*/
getVdfAttribute : function(sName, sDefault, bBubble){
    var sResult = null;
    
    if(this.eElement !== null){
        sResult = vdf.getDOMAttribute(this.eElement, sName, null);
    }

    if(sResult === null){
        if((bBubble) && this.oParentControl !== null && typeof(this.oParentControl.getVdfAttribute) == "function"){
            sResult = this.oParentControl.getVdfAttribute(sName, sDefault, true);
        }else{
            sResult = sDefault;
        }
    }
    
    return sResult;
}

});

/*
Displays a popup calender next to the eOpener element and gets and sets the 
value of the field with the given sFieldName.

@param  eOpener         DOM element that opens the calendar.
@param  sFieldName      Name of the field.
@param  sDateFormat     (optional) The date format used to get and set the date 
            from the field.
@param  sDateMask       (optional) Mask used when displaying a date.
@param  sDateSeparator  (optional) Date separator used within the date format.
*/
vdf.gui.show_FieldPopupCalendar = function(eOpener, sFieldName, sDateFormat, sDateMask, sDateSeparator){
    var oForm, oPopupCalendar;
    
    oForm = vdf.core.findForm(eOpener);
    
    oPopupCalendar = new vdf.gui.PopupCalendar(eOpener, null);
    oPopupCalendar.sFieldName = sFieldName;
    oPopupCalendar.bAttach = false;
    oPopupCalendar.oForm = oForm;
    
    oPopupCalendar.formInit();
    
    if(typeof(sDateFormat) === "string"){
        oPopupCalendar.sDateFormat = sDateFormat;
    }
    if(typeof(sDateMask) === "string"){
        oPopupCalendar.sDateMask = sDateMask;
    }
    if(typeof(sDateSeparator) === "string"){
        oPopupCalendar.sDateSeparator = sDateSeparator;
    }
    
    oPopupCalendar.display();
};

/*
Displays a popup calendar next to the eOpener element and gets & sets the value
of the eInput element.

@param  eOpener     Element that opens the calendar.
@param  eInput      Input element to get and set the value from.
@param  sDateFormat     (optional) The date format used to get and set the date 
            from the field.
@param  sDateMask       (optional) Mask used when displaying a date.
@param  sDateSeparator  (optional) Date separator used within the date format.
*/
vdf.gui.show_InputPopupCalendar = function(eOpener, eInput, sDateFormat, sDateMask, sDateSeparator){
    var oForm, oPopupCalendar;
    
    oForm = vdf.core.findForm(eInput);
    
    oPopupCalendar = new vdf.gui.PopupCalendar(eOpener, null);
    oPopupCalendar.bAttach = false;
    oPopupCalendar.oForm = oForm;
    oPopupCalendar.eInput = eInput;
    oPopupCalendar.formInit();
    
    if(typeof(sDateFormat) === "string"){
        oPopupCalendar.sDateFormat = sDateFormat;
    }
    if(typeof(sDateMask) === "string"){
        oPopupCalendar.sDateMask = sDateMask;
    }
    if(typeof(sDateSeparator) === "string"){
        oPopupCalendar.sDateSeparator = sDateSeparator;
    }
    oPopupCalendar.display();
};