/*
Name:
    vdf.gui.Balloon
Type:
    Prototype
Revisions:
    2009/01/22  Created the initial version (HW, DAE)
*/


vdf.includeCSS("Balloon");

/*
Constructor that confirms with the required vdf.core.init system.

@param  eElement        Element used to line out the balloon and attach events on.
@param  oParentControl  Reference to an parent control.
*/
vdf.gui.Balloon = function(eElement, oParentControl){
    /*
    Reference to the DOM element on which the balloon is lined out and on which 
    events are attached.
    */
    this.eElement           = eElement || null;
    /*
    Reference to the parent control.
    */
    this.oParentControl     = oParentControl || null;
    /*
    Naam of the component.
    
    @html
    */
    this.sName              = vdf.determineName(this, "balloon");
    
    /*
    The CSS class that is set to the generated balloon element.
    */
    this.sCssClass          = this.getVdfAttribute("sCssClass", "balloon", false);
    /*
    Optional, the horizontal position of the balloon.
    */
    this.iLeft              = this.getVdfAttribute("iLeft", 0, false);
    /*
    Optional, the vertical position of the balloon.
    */
    this.iRight             = this.getVdfAttribute("iRight", 0, false);
    /*
    Optional, the width of the balloon.
    */
    this.iWidth             = this.getVdfAttribute("iWidth", 0, false);
    /*
    The offset of the tute of the balloon in the upper left corner.
    */
    this.iTuteOffset        = this.getVdfAttribute("iTuteOffset", 12, false);
    /*
    The HTML content of the balloon.
    */
    this.sContent           = this.getVdfAttribute("sContent", "&nbsp;", false);
    
    /*
    If true the balloon is displayed after initalization.
    */
    this.bDisplay           = this.getVdfAttribute("bDisplay", true, false);
    /*
    If true the balloon will display if mouse pointer hovers over the element. 
    The iTimeout property defines how long the balloon should stay visible after 
    the mouse pointer leaves the element.
    */
    this.bAttachHover       = this.getVdfAttribute("bAttachHover", true, false);
    /*
    If true a click on the element will display the balloon.
    */
    this.bAttachClick       = this.getVdfAttribute("bAttachClick", true, false);
    /*
    The amount of miliseconds that the balloon stays displayed after the mouse 
    pointer leaves the element when using the hover.
    */
    this.iTimeout           = this.getVdfAttribute("iTimeout", 2500, false);
    
    // @privates
    this.tTimeout = null;
    this.eTable = null;
    this.eContent = null;
    this.bDisplayed = false;
    this.bClicked = false;
    
};
/*
A balloon control that displays an absolute positioned balloon near the element
on which it is defined. It can listen to the mouse events of this element so it
automatically displays and hides (optionally using a timeout). Can be used on 
almost any element like a tool tip system.
*/
vdf.definePrototype("vdf.gui.Balloon", {

/*
Initializes the balloon by creating the elements (and optionally displaying it 
right away). Usually called by the initialization system.
*/
init : function(){
    this.createBalloon();
    this.recalcDisplay(false);
    
    if(this.bDisplay){
        this.display();
    }
},

/*
Displays the balloon.

@param  bNoTimeout (optional) If true the auto hide timeout is not set!
*/
display : function(bNoTimeout){
    this.recalcDisplay(false);
    this.bDisplayed = true;
    if(this.eTable){
        this.eTable.style.visibility = "visible";
    }
    
    if(!(bNoTimeout)){
        this.setTimeout();
    }
},

/*
Hides the balloon.
*/
hide : function(){
    this.clearTimeout();
    this.bDisplayed = false;
    if(this.eTable){
        this.eTable.style.visibility = "hidden";
    }
},

/*
Sets / updates the content of the balloon.

@param  sNewContent String with the HTML content.
*/
setContent : function(sNewContent){
    this.sContent = sNewContent;
    
    if(this.bDisplayed){
        this.eContent.innerHTML = sNewContent;
    }
},

/*
Sets the timeout to hide the balloon.
*/
setTimeout : function(){
    var oBalloon = this;
    
    this.clearTimeout();

    this.tTimeout = setTimeout(function(){
        oBalloon.hide();
    }, this.iTimeout);
},

/*
Clears the timeout that might hide the balloon.
*/
clearTimeout : function(){
    if(this.tTimeout){
        clearTimeout(this.tTimeout);
        this.tTimeout = null;
    }
},

/*
Creates the balloon by creating and adding the elements to the DOM. The 
elements are inserted near to the reference element or directly on the body if 
no element is available.

@private
*/
createBalloon : function(){
    var eTable, eRow, eCell, eContent;

    eTable = document.createElement("table");
    eTable.className = this.sCssClass;
    eTable.cellPadding = 0;
    eTable.cellSpacing = 0;
    eTable.style.visibility = "hidden";
    
    if(this.eElement){
        vdf.sys.dom.insertAfter(eTable, this.eElement);
    }else{
        document.body.appendChild(eTable);
    }
    
    //  Header
    eRow = eTable.insertRow(0);
    eCell = eRow.insertCell(0);
    eCell.className = "topleft";
    
    eCell = eRow.insertCell(1);
    eCell.className = "topmid";
    
    eCell = eRow.insertCell(2);
    eCell.className = "topright";
    
    //  Middle
    eRow = eTable.insertRow(1);
    eCell = eRow.insertCell(0);
    eCell.className = "midleft";
    
    eContent = eRow.insertCell(1);
    eContent.className = "bln_content";
    if(this.iWidth){
        eContent.style.width = this.iWidth + "px";
    }
    eContent.innerHTML = this.sContent;
    
    eCell = eRow.insertCell(2);
    eCell.className = "midright";
    
    //  Bottom
    eRow = eTable.insertRow(2);
    eCell = eRow.insertCell(0);
    eCell.className = "bottomleft";
    
    eCell = eRow.insertCell(1);
    eCell.className = "bottommid";
    
    eCell = eRow.insertCell(2);
    eCell.className = "bottomright";
    
    this.eTable = eTable;
    this.eContent = eContent;
    
    if(this.eElement){
        if(this.bAttachClick){
            vdf.events.addDomListener("click", this.eElement, this.onClick, this);
        }
        if(this.bAttachHover){
            vdf.events.addDomListener("mouseover", this.eElement, this.onMouseOver, this);
            vdf.events.addDomListener("mouseout", this.eElement, this.onMouseOut, this);
            
        }
    }
},

/*
Destroys the balloon and removes the event listeners and DOM <-> JavaScript 
references.
*/
destroy : function(){
    this.clearTimeout();
    
    if(this.eElement){
        if(this.bAttachClick){
            vdf.events.removeDomListener("click", this.eElement, this.onClick);
        }
        if(this.bAttachHover){
            vdf.events.removeDomListener("mouseover", this.eElement, this.onMouseOver);
            vdf.events.removeDomListener("mouseout", this.eElement, this.onMouseOut);
            
        }
    }

    this.eTable.parentNode.removeChild(this.eTable);
    this.eContent = null;
    this.eTable = null;
},


/*
Handles the click event of the element. Displays / hides the balloon.

@param  oEvent  Event object.
@private
*/
onClick : function(oEvent){
    if(this.bDisplayed && (this.bClicked || !this.bAttachHover)){
        this.hide();
        this.bClicked = false;
    }else{
        this.display(true);
        this.clearTimeout();
        this.bClicked = true;
    }
},

/*
Handles the mouseover event of the element. It displays the balloon.

@param  oEvent  Event object.
@private
*/
onMouseOver : function(oEvent){
    if(!this.bDisplayed){
        this.display(true);
    }
    this.clearTimeout();
},

/*
Handles the mouseout event of the element. Sets the timeout to hide the 
balloon.

@param  oEvent  Event object.
@private
*/
onMouseOut : function(oEvent){
    if(!this.bClicked){
        this.setTimeout();
    }
},


/*
Called to recalculate the sizes & position. Usually fired by an element that has 
resized (for some reason). Can bubble up and down.

@param bDown    If true it bubbles up to parent components.
@private
*/
recalcDisplay : function(bDown){
    var oOffset, iLeft = this.iLeft || 0, iTop = this.iTop || 0;

    if(this.eElement){
        oOffset = vdf.sys.gui.getAbsoluteOffset(this.eElement);
        iLeft += oOffset.left + parseInt((this.eElement.offsetWidth / 2), 10);
        iTop += oOffset.top + parseInt(this.eElement.offsetHeight, 10);
    }
    iLeft = iLeft - this.iTuteOffset;

    this.eTable.style.left = iLeft + "px";
    this.eTable.style.top = iTop + "px";
    
    if(!bDown && this.oParentControl !== null && typeof(this.oParentControl.recalcDisplay) === "function"){
        this.oParentControl.recalcDisplay(bDown);
    }
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