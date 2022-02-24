/*
Name:
    vdf.gui.ModalDialog
Type:
    Prototype
Revisions:
    2006/01/13  Created the initial version. (JH, DAE)
    2006/11/03  Moved from global methods to prototype structure and renamed to
    JModalDialog. (HW, DAE)
    2008/08/12  Rebuild into the new structure. Is now located in the vdf.gui 
    namespace and names ModalDialog.(HW, DAE)

*/

//  Includes the CSS file that belongs to the Modal Dialog
vdf.includeCSS("ModalDialog");

/*
Constructor of the modal dialog. The following example shows the HTML structure 
of the generated dialog.

@code
<div class="modaldialog">
    <table cellspacing="0" cellpadding="0">
        <tr class="titlebar">
            <td>
                <table cellspacing="0" cellpadding="0">
                    <tr>
                        <td class="left"> </td>
                        <td class="title">{{title}}</td>
                        <td class="controls"><a href="javascript: vdf.sys.nothing();"><div class="close"/></a></td>
                        <td class="right"> </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="content">{{content}}</td>
        </tr>
        <tr class="buttonbar">
            <td>
                <table cellspacing="0" cellpadding="0">
                    <tr>
                        <td class="left"> </td>
                        <td class="buttons">{{buttons}}</td>
                        <td class="right"> </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</div>
@code

In this example is {{title}} replaced with the content of the sTitle property. 
The {{content}} is replaced with the dialog content (depending on the method 
used to display the dialog). The {{buttons}} are replaced with the buttons 
registered by the dialog. The example below shows how a button is generated:

@code
<a class="btnClose" href="javascript: vdf.sys.nothing();">Close</a>
@code
*/
vdf.gui.ModalDialog = function ModalDialog(){
    /*
    The title displayed in the title bar.
    */
    this.sTitle = "New modal dialog!";
    /*
    Optional, the width of the modal dialog.
    */
    this.iWidth = null;
    /*
    Optional, the height of the modal dialog.
    */
    this.iHeight = null;
    /*
    Optional, id of an DOM element used to display the modal dialog (instead of 
    generating one).
    */
    this.sContainerId = null;
    
    /*
    The CSS class set to the modal dialog element.
    */
    this.sCssClass = "modaldialog";
    /*
    If true it sets the focus on the close button.
    */
    this.bTakeFocus = false;
    /*
    Property that can be used to "return a value".
    */
    this.sReturnValue = null;

    /*
    Optional, the horizontal position of the dialog.
    */
    this.iX = -1;
    /*
    Optional, the vertical position of the dialog.
    */
    this.iY = -1;
    
    /*
    Fired before the dialog is closed. If the event is stopped the dialog is not 
    closed.
    
    @prop   sReturnValue    The value of the sReturnValue property.
    */
    this.onBeforeClose = new vdf.events.JSHandler();
    /*
    Fired after the dialog is closed.
    
    @prop   sReturnValue    The value of the sReturnValue property.
    */
    this.onAfterClose = new vdf.events.JSHandler();
    /*
    Fired after the user has clicked one of the buttons in the button bar.
    
    @prop   sButtonName     The name of the button that is clicked.
    */
    this.onButtonClick = new vdf.events.JSHandler();
    
    // @privates
    
    this.iLastWidth = 0;
    this.iLastHeight = 0;
    this.eContentElement = null;
    this.eContentParent = null;
    this.eContentNext = null;
    this.eCellButtons = null;
    this.eDivMask = null;
    this.eDivContainer = null;
    this.eTableTitle = null;
    this.eAnchorClose = null;
    this.eDivInner = null;    

    this.aButtons = [];
};
/*
Contains a modal dialog that can be used to display HTML content. Also contains
a few global methods for closing the current dialog and display "alert" boxes. 
The modal dialog isn't really a modal dialog but consists of a set DOM 
elements. Modal means that it tries to prevent the user from giving the focus 
to background elements using a transparant div element (mask) and modifies the 
tabIndex.
*/
vdf.definePrototype("vdf.gui.ModalDialog",{

//  - - - - - - - - - - - PUBLIC INTERFACE - - - - - - - - - - - 

/*
Displays the modal dialog with an IFrame in which the given URL is loaded. Note
that the iWidth & iHeight properties should be set when working with an IFrame.

@param  sUrl    The url to load in the IFrame.
@return Reference to the IFrame element.
*/
displayPage : function(sUrl){
    var eIFrame;

    this.initializeDialog();
    
    eIFrame = document.createElement("iframe");
    this.eCellContent.appendChild(eIFrame);
    eIFrame.className = "page";
    eIFrame.setAttribute("scrolling","auto");
    eIFrame.setAttribute("frameborder","0");
    eIFrame.setAttribute("allowtransparency","true"); 
    eIFrame.src = sUrl;
    
    this.calculatePosition();
    
    return eIFrame;
},

/*
Displays the modal dialog with a given text as content. The message is 
located in a div with the class name set to "message".

@param  sText   The text to display.
@return Reference to the content div element.
*/
displayMessage : function(sText){
    var eDiv;
    
    this.initializeDialog();
    
    eDiv = document.createElement("div");
    eDiv.className = "message";
    this.eCellContent.appendChild(eDiv);
    vdf.sys.dom.setElementText(eDiv, sText);
    
    this.calculatePosition();
    
    return eDiv;
},

/*
Displays the modal dialog with the given HTML as content. The HTML should be 
provided as string. Note that VDF controls defined in the HTML are not 
automatically initialized.

@param  sHTML   String with the HTML content.
@return Reference to the content div element.
*/
displayHTML : function(sHTML){
    var eDiv, eFocus;
    
    this.initializeDialog();
    
    eDiv = document.createElement("div");
    eDiv.className = "html";
    this.eCellContent.appendChild(eDiv);
    eDiv.innerHTML = sHTML;
    
    this.calculatePosition();
    
    eFocus = vdf.sys.dom.getFirstFocusChild(eDiv);
    if(eFocus){
        vdf.sys.dom.focus(eFocus);
    }
    
    return eDiv;
},

/*
Displays a dialog with the given DOM element as content. If the DOM element is 
attached to the DOM it is placed back when the dialog is closed.

@param  eElement    Reference to the DOM element used as content.
@return Reference to the content div element.
*/
displayDOM : function(eElement){
    var eDiv, eFocus;
    
    this.initializeDialog();

    this.eContentElement = eElement;
    this.eContentParent = eElement.parentNode;
    this.eContentNext = eElement.nextSibling;
    
    eDiv = document.createElement("div");
    eDiv.className = "dom";
    this.eCellContent.appendChild(eDiv);
    eDiv.appendChild(eElement);
    
    vdf.sys.gui.restoreTabIndexes(eElement);
    
    this.calculatePosition();
    
    eFocus = vdf.sys.dom.getFirstFocusChild(eDiv);
    if(eFocus){
        vdf.sys.dom.focus(eFocus);
    }
},

/*
Adds a button to the dialogs button bar (usually displayed at the bottom of the
dialog).

@param  sNewName    Name of the button (used for identification).
@param  sNewText    Text displayed on the button.
@param  sNewCSS     CSS class attached to the button.
*/
addButton : function(sNewName, sNewText, sNewCSS){
    var oButton = { sName : sNewName, sText : sNewText, sCSS : sNewCSS };
    
    this.aButtons.push(oButton);
    
    if(this.eCellButtons !== null){
        this.createButton(oButton);
    }       
},

/*
Gives the focus to a button. Only works after the dialog is displayed.

@param  sName   Name of the button to focus.
*/
focusButton : function(sName){
    var iButton;
    
    for(iButton = 0; iButton < this.aButtons.length; iButton++){
        if(this.aButtons[iButton].sName.toLowerCase() === sName.toLowerCase()){
            if(this.aButtons[iButton].eAnchor){
                vdf.sys.dom.focus(this.aButtons[iButton].eAnchor);
            }
            break;
        }
    }
},

/*
If onBeforeClose isn't cancelled it closes the dialog by hiding it and then 
removing the elements and the references. It calls the onDialogClose event 
when finished. 

@return True if the dialog is closed.
*/
close : function(){
    var bResult = false, iDialog;

    try{
        if(this.onBeforeClose.fire(this, { sReturnValue : this.sReturnValue })){
            vdf.sys.gui.displaySelectBoxes(this.eDivMask, this.eDivInner);
            
            //  Hide dialog
            this.eDivContainer.style.display = "none";
            this.eDivMask.style.display = "none";
            
            //  displayDOM: Put back element content
            if(this.eContentElement !== null && this.eContentParent !== null){
                this.eContentParent.insertBefore(this.eContentElement, this.eContentNext);
            }
            
            
            vdf.sys.gui.restoreTabIndexes(document);
            
            //  Remove & clear stuff
            vdf.events.removeDomListener("mousedown", this.eTableTitle, this.onStartDrag);
            vdf.events.removeDomListener("click", this.eAnchorClose, this.onCloseClick);
            vdf.events.removeDomListener("mousedown", this.eAnchorClose, vdf.events.stop);
            vdf.events.removeDomListener("resize", window, this.onWindow_Resize);
            if(vdf.sys.isIE && vdf.sys.iVersion <= 6){
                vdf.events.removeDomListener("scroll", window, this.onWindow_Scroll);
            }
            vdf.gui.freeZIndex(this.eDivContainer.style.zIndex);
            vdf.gui.freeZIndex(this.eDivMask.style.zIndex);
            
            document.body.removeChild(this.eDivContainer);
            document.body.removeChild(this.eDivMask);
            
            this.eContentElement = null;
            this.eContentParent = null;
            this.eContentNext = null;
            
            this.eDivMask = null;
            this.eDivContainer = null;
            this.eTableTitle = null;
            this.eAnchorClose = null;
            this.eDivInner = null;
            
            //  Remove from vdf.gui.aModalDialogs
            for(iDialog = 0; iDialog < vdf.gui.aModalDialogs.length; iDialog++){
                if(vdf.gui.aModalDialogs[iDialog] === this){
                    vdf.gui.aModalDialogs.splice(iDialog, 1);
                    break;
                }
            }
            
            //  Call onAfterClose
            bResult = this.onAfterClose.fire(this, { sReturnValue : this.sReturnValue });
        }


    }catch (oError){
        vdf.errors.handle(oError);
    }
    
    
    return bResult;
},

//  - - - - - - - - - - - DIALOG FUNCTIONALLITY - - - - - - - - - - - 

/*
Initializes the dialog by calling the methods that create the elements. The 
calculatePosition method should be called manually.

@private
*/
initializeDialog : function(){
    var oDialog = this;
    
    vdf.sys.gui.disableTabIndexes(document);
    
    this.createMask();

    if(this.sContainerId !== null){
    
    }else{
        this.createDialog();
    }
    
    // for IE <= 6
    vdf.sys.gui.hideSelectBoxes(this.eDivMask, this.eDivInner);
    
    //  IE6 doesn't support fixed positioning so this is done absolute and requires a onScroll event to move all the stuff
    if(vdf.sys.isIE && vdf.sys.iVersion <= 6){
        vdf.events.addDomListener("scroll", window, this.onWindow_Scroll, this);
        this.eDivContainer.style.position = "absolute";
        this.eDivMask.style.position = "absolute";
    }
    
    if(this.bTakeFocus){
        setTimeout(function(){
            if(oDialog.bTakeFocus && oDialog.eAnchorClose){
                oDialog.eAnchorClose.focus();
            }
        }, 50);
    }
},

/*
Creates the mask that makes the background look dark and makes sure that the 
user can't click on background elements.

<div class="modaldialog_mask"> </div>

@private
*/
createMask : function(){

    //This will first create all the html DOM elements and after that set the height and width.
    var eDiv = document.createElement("div");
    document.body.appendChild(eDiv);
    eDiv.className = this.sCssClass + "_mask";
    eDiv.style.zIndex = vdf.gui.reserveZIndex();
    
    eDiv.innerHTML = "&nbsp;";
    this.setFixedX(eDiv, 0);
    this.setFixedY(eDiv, 0);
    eDiv.style.height = vdf.sys.gui.getViewportHeight() + "px";
    eDiv.style.width = vdf.sys.gui.getViewportWidth() + "px";
    
    this.eDivMask = eDiv;
},

/*
Creates the dialog elements which results in the elements below that are 
inserted into the document body.

@private
*/
createDialog : function(){
    var eDiv, eDivMain, eTable, eRow, eCell, eTitleTable, eAnchor, eButtonTable, iBut;

    //  Main container
    eDivMain = document.createElement("div");
    document.body.appendChild(eDivMain);
    this.eDivContainer = eDivMain;
    eDivMain.className = this.sCssClass;
    eDivMain.style.zIndex = vdf.gui.reserveZIndex();
    eDivMain.style.visibility = "hidden";
    
    eTable = document.createElement("table");
    eDivMain.appendChild(eTable);
    eTable.cellPadding = 0;
    eTable.cellSpacing = 0;
    
    //  Titlebar
    eRow = eTable.insertRow(0);
    eRow.className = "titlebar";
    eCell = eRow.insertCell(0);
    
    eTitleTable = document.createElement("table");
    this.eTableTitle = eTitleTable;
    vdf.events.addDomListener("mousedown", eTitleTable, this.onStartDrag, this);
    vdf.sys.gui.disableTextSelection(eTitleTable);
    eCell.appendChild(eTitleTable);
    eTitleTable.cellPadding = 0;
    eTitleTable.cellSpacing = 0;
    eRow = eTitleTable.insertRow(0);
    
    
    eCell = eRow.insertCell(0);
    eCell.className = "left";
    eCell.innerHTML = "&nbsp";
    
    eCell = eRow.insertCell(1);
    eCell.className = "title";
    vdf.sys.dom.setElementText(eCell, this.sTitle);
    
    eCell = eRow.insertCell(2);
    eCell.className = "controls";
    
    eAnchor = document.createElement("a");
    this.eAnchorClose = eAnchor;
    eCell.appendChild(eAnchor);
    vdf.events.addDomListener("click", eAnchor, this.onCloseClick, this);
    vdf.events.addDomListener("mousedown", eAnchor, vdf.events.stop);
    eAnchor.href = "javascript: vdf.sys.nothing();";
    
    eDiv = document.createElement("div");
    eAnchor.appendChild(eDiv);
    eDiv.className = "close";
    
    
    eCell = eRow.insertCell(3);
    eCell.className = "right";
    eCell.innerHTML = "&nbsp;";
    
    //  Content
    eRow = eTable.insertRow(1);
    eCell = eRow.insertCell(0);
    eCell.className = "content";
    if(this.iWidth !== null){
        eCell.style.width = "" + this.iWidth + "px";
    }
    if(this.iHeight !== null){
        eCell.style.height = "" + this.iHeight + "px";
    }
    this.eCellContent = eCell;
    
    //  Button bar
    eRow = eTable.insertRow(2);
    eRow.className = "buttonbar";
    eCell = eRow.insertCell(0);
    
    eButtonTable = document.createElement("table");
    eCell.appendChild(eButtonTable);
    eButtonTable.cellPadding = 0;
    eButtonTable.cellSpacing = 0;
    eRow = eButtonTable.insertRow(0);
    
    
    eCell = eRow.insertCell(0);
    eCell.className = "left";
    eCell.innerHTML = "&nbsp";
    
    eCell = eRow.insertCell(1);
    this.eCellButtons = eCell;
    eCell.className = "buttons";
    eCell.innerHTML = "&nbsp;";
    
    for(iBut = 0; iBut < this.aButtons.length; iBut++){
        this.createButton(this.aButtons[iBut]);
    }
    
    eCell = eRow.insertCell(2);
    eCell.className = "right";
    eCell.innerHTML = "&nbsp;";
    
    //  When resizing we will reposition & resize the dialog
    vdf.events.addDomListener("resize", window, this.onWindow_Resize, this);

    
    //  Register
    vdf.gui.aModalDialogs.push(this);
},

/*
Creates a button from the button struct. The button is added to the buttons 
cell.

@code
<a class="btnClose" href="javascript: vdf.sys.nothing();">Close</a>
@code

@param  tButton Struct with button info { sCSS : "..", sName : "..", sText : ".." }
    
@private
*/
createButton : function(tButton){
    var eAnchor = document.createElement("a");
    
    this.eCellButtons.appendChild(eAnchor);
    eAnchor.className = tButton.sCSS;
    eAnchor.href = "javascript: vdf.sys.nothing();";
    vdf.sys.dom.setElementText(eAnchor, tButton.sText);
    tButton.eAnchor = eAnchor;
    
    vdf.events.addDomListener("click", eAnchor, this.onButtonClicked, this);
},

/*
Sets the positions of the dialog and the mask. If the dialog position is 
offscreen it centers it again.
*/
calculatePosition : function(){
    var iDialogWidth, iDialogHeight, iFullWidth, iFullHeight;
    
    iDialogWidth = this.eDivContainer.offsetWidth;
    iDialogHeight = this.eDivContainer.offsetHeight;
    iFullWidth = vdf.sys.gui.getViewportWidth();
    iFullHeight = vdf.sys.gui.getViewportHeight();
    
    //  Mask
    this.setFixedX(this.eDivMask, 0);
    this.setFixedY(this.eDivMask, 0);
    this.eDivMask.style.height =  iFullHeight + "px";
    this.eDivMask.style.width = iFullWidth + "px";
    
    
    
    //  Calculate if dialog is not offscreen
    if(this.iX < 0 || this.iX > (iFullWidth - iDialogWidth) || iDialogWidth !== this.iLastWidth){
        this.iX = (iFullWidth / 2) - (iDialogWidth / 2);
        if(this.iX < 0){
            this.iX = 0;
        }
    }
    if(this.iY < 0 || this.iY > (iFullHeight - iDialogHeight) || iDialogHeight !== this.iLastHeight){
        this.iY = (iFullHeight / 2)- (iDialogHeight / 2);
        if(this.iY < 0){
            this.iY = 0;
        }
    }
    
    this.iLastHeight = iDialogHeight;
    this.iLastWidth = iDialogWidth;

    //  Set position and size
    this.setFixedX(this.eDivContainer, this.iX);
    this.setFixedY(this.eDivContainer, this.iY);
    
    this.eDivContainer.style.visibility = "";
},

/*
Handle the mousedown event of the title bar and starts the drag meganism by 
adding a invisible overlay div which prevents the user from accidentally 
selecting stuff when moving the mouse too fast. It also stores the position of 
the mouse on the title bar for further calculations.

@param  oEvent  The vdf.events.DOMEvent object.

@private
*/
onStartDrag : function(oEvent){
    var eDiv;
    
    if (!this.bDragging){
        this.bDragging = true;
        
        //  Create overlaying div
        eDiv = document.createElement("div");
        document.body.appendChild(eDiv);
        this.eDivDragMask = eDiv;
        eDiv.className = this.sCssClass + "_dragmask";
        eDiv.style.zIndex = vdf.gui.reserveZIndex();
        eDiv.innerHTML = "&nbsp;";
        this.setFixedX(eDiv, 0);
        this.setFixedY(eDiv, 0);
        eDiv.style.height = vdf.sys.gui.getViewportHeight() + "px";
        eDiv.style.width = vdf.sys.gui.getViewportWidth() + "px";
        
        if(vdf.sys.isIE && vdf.sys.iVersion <= 6){
            eDiv.style.position = "absolute";
        }

        //  Get drag offset
        this.iDragOffsetY = oEvent.getMouseY() - this.getFixedY(this.eDivContainer);
        this.iDragOffsetX = oEvent.getMouseX() - this.getFixedX(this.eDivContainer);
        
        //  Add eventlisteners
        vdf.events.addDomListener("mouseup", eDiv, this.onStopDrag, this);
        vdf.events.addDomListener("mouseout", eDiv, this.onStopDrag, this);
        vdf.events.addDomListener("mousemove", eDiv, this.onDrag, this);
    }
},

/*
Handles the mousemove event of the drag overlay element and actually moves the 
dialog to the new mouse position.

@param  oEvent  The vdf.events.DOMEvent object.

@private
*/
onDrag : function(oEvent){
    var iMouseX, iMouseY, iNewX, iNewY;

    if (this.bDragging){
        iMouseX = oEvent.getMouseX();
        iMouseY = oEvent.getMouseY();
        
        iNewX = (iMouseX - this.iDragOffsetX);
        iNewY = (iMouseY - this.iDragOffsetY);
        
        //window.status = "iNewX[" + iNewX + "] > 0 && iNewX[" + iNewX + "] < (vdf.sys.gui.getViewportWidth()[" + vdf.sys.gui.getViewportWidth() + "] - this.eDivContainer.offsetWidth[" + this.eDivContainer.offsetWidth + "])[" + (vdf.sys.gui.getViewportWidth() - this.eDivContainer.offsetWidth) + "]";
        if(iNewX > 0 && iNewX < (vdf.sys.gui.getViewportWidth() - this.eDivContainer.offsetWidth)){ 
            this.setFixedX(this.eDivContainer, iNewX);
            this.iX = iNewX;
        }else{
            this.iDragOffsetX = iMouseX - this.getFixedX(this.eDivContainer);
        }
        if(iNewY > 0 && iNewY < (vdf.sys.gui.getViewportHeight() - this.eDivContainer.offsetHeight)){
            this.setFixedY(this.eDivContainer, iNewY);
            this.iY = iNewY;
        }else{
            this.iDragOffsetY = iMouseY - this.getFixedY(this.eDivContainer);
        }  

        oEvent.stop();
    }
},

/*
Handles the mouseout and mouseup events of the drag mask which stop the 
dragging by removing the dragmask and the listeners.

@param  oEvent  The vdf.events.DOMEvent object.
    
@private
*/
onStopDrag : function(oEvent){
    vdf.events.removeDomListener("mouseup", this.eDivDragMask, this.onStopDrag);
    vdf.events.removeDomListener("mouseout", this.eDivDragMask, this.onStopDrag);
    vdf.events.removeDomListener("mousemove", this.eDivDragMask, this.onDrag);
    
    document.body.removeChild(this.eDivDragMask);
    this.eDivDragMask = null;
    
    this.bDragging = false;
},

/*
Handles the click event of the close button in the title bar. It calls the 
close method and stops the event.

@param  oEvent  The vdf.events.DOMEvent object.
    
@private
*/
onCloseClick : function(oEvent){
    if(this.close()){
        oEvent.stop();
    }
},

/*
Handles the click event of the buttons added to the dialog. It fires the 
onButtonClick event with the name of the button as poperty.

@param  oEvent  The vdf.events.DOMEvent object.
    
@private
*/
onButtonClicked : function(oEvent){
    var eTarget, iBut, sName;
    
    eTarget = oEvent.getTarget();
    
    for(iBut = 0; iBut < this.aButtons.length; iBut++){
        if(this.aButtons[iBut].eAnchor === eTarget){
            sName = this.aButtons[iBut].sName;
            break;
        }
    }
    
    this.onButtonClick.fire(this, { sButtonName : sName });
},

/*
Handles the resize event of the window. Calls the calculatePosition method to 
reposition the dialog.

@param  oEvent  The vdf.events.DOMEvent object.
    
@private
*/
onWindow_Resize : function(oEvent){
    this.calculatePosition();
},

/*
Handles the scroll event of the window when working with I6 or older and calls 
the calculatePosition method to reposition the dialog.

@param  oEvent  The vdf.events.DOMEvent object.
    
@private
*/
onWindow_Scroll : function(oEvent){
    this.calculatePosition();
},

//  - - - - - - - - - - - SPECIAL FUNCTIONALLITY - - - - - - - - - - - 

/*
Sets the vertical position of the given element. The position is given 
fixed in pixels (the amount of pixels from the top of the screen, 
regardless the scroll position). If the element is positioned absolute it 
calculates the absolute position (usually the case for IE 6 and older which
doesn't support fixed positioning).

@param  eElement    The element to position
@param  iY          Fixed vertical position in pixels
@private
*/
setFixedY : function(eElement, iY){
    if(eElement.style.position == "absolute"){
        iY = iY + parseInt(document.documentElement.scrollTop, 10);
    }
    eElement.style.top = iY + "px";
},

/*
Sets the horizontal position of the given element. The position is given
fixed in pixels and if nessacary it is translated to a absolute position.


@param  eElement    The element to position
@param  iX          Fixed horizontal position in pixels
@private
*/
setFixedX : function(eElement, iX){
    if(eElement.style.position == "absolute"){
        iX = iX + parseInt(document.documentElement.scrollLeft, 10);
    }
    eElement.style.left = iX + "px";
},

/*
Determines the fixed vertical position of the element (the amount of pixels 
between the top of the browser window and the element). If the element is 
positioned absolute it calculates the value using the scrollTop value.

@param  eElement    Element to get the position of.
@return The fixed vertical position of the element.
@private
*/
getFixedY : function(eElement){
    if(eElement.style.position == "absolute"){
        return parseInt(eElement.style.top, 10) - parseInt(document.documentElement.scrollTop, 10);
    }else{
        return parseInt(eElement.style.top, 10);
    }
},

/*
Determines the fixed horizontal position of the element.

@param  eElement    Element to get the position of.
@return The fixed horizontal position of the element.
@private
*/
getFixedX : function(eElement){
    if(eElement.style.position == "absolute"){
        return parseInt(eElement.style.left, 10) - parseInt(document.documentElement.scrollLeft, 10);
    }else{
        return parseInt(eElement.style.left, 10);
    }
}


});



/*
Array with currently displayed modal dialogs in this window. Is used to enable
global access in the global close method.

@private
*/
vdf.gui.aModalDialogs = [];

/*
Searches the dialog which is currently displayed at the top and closes it.

@param  sReturnValue    The new returnvalue for the dialog.
*/
vdf.gui.closeModalDialog = function(sReturnValue){
    var oDialog = vdf.gui.getCurrentModalDialog();
    
    if(oDialog !== null){
        if(typeof(sReturnValue) !== "undefined"){
            oDialog.sReturnValue = sReturnValue;
        }
        return oDialog.close();
    }
    
    return false;
};

/*
Searches the dialog which is currently displayed at the top.

@return Reference to the dialog (null if no dialog is found).
*/
vdf.gui.getCurrentModalDialog = function(){
    var oResult = null;

    if(vdf.gui.aModalDialogs.length > 0){
        oResult = vdf.gui.aModalDialogs[vdf.gui.aModalDialogs.length - 1];
    }else{
        if(typeof(window.top.vdf) === "object"){
            if(typeof(window.top.vdf.gui) === "object"){
                if(typeof(window.top.vdf.gui.aModalDialogs) !== "undefined" && window.top.vdf.gui.aModalDialogs.length > 0){
                    oResult = window.top.vdf.gui.aModalDialogs[window.top.vdf.gui.aModalDialogs.length - 1];
                }
            }   
        }
    }
    
    return oResult;
};

/*
Queued alert messages.

@private
*/
vdf.gui.aAlertQueue = [];

/*
Displays the modal dialog with the given text and title. If there is already
an alert displayed it queues this alert.

@param  sText       The text to display
@param  sTitle      (optional) The title of the dialog
@param  sContainer  (optional) Container name to be used by the dialog
*/
vdf.gui.alert = function(sText, sTitle, sContainer){
    if(typeof(sTitle) == "undefined"){
        sTitle = "Alert";
    }
    if(typeof(sContainer) == "undefined"){
        sContainer = null;
    }
    
    //  Add to queue
    vdf.gui.aAlertQueue.push({ "sText" : sText, "sTitle" : sTitle, "sContainer" : sContainer });
    
    if(vdf.gui.aAlertQueue.length == 1){
        vdf.gui.alertFromQueue();
    }
};

/*
Displays the first alert dialog in the queue using a vdf.gui.ModalDialog.

@private
*/
vdf.gui.alertFromQueue = function(){
    var oDialog, tAlert = vdf.gui.aAlertQueue[0];
    
    //  Create dialog
    oDialog = new vdf.gui.ModalDialog();
    oDialog.sTitle = tAlert.sTitle;
    oDialog.sContainer = tAlert.sContainer;
    oDialog.bTakeFocus = false;
    oDialog.onAfterClose.addListener(vdf.gui.onAlertClosed);
    
    //  Add OK button
    oDialog.addButton("oke", vdf.lang.getTranslation("global", "ok", "OK", []), "btnOke");
    oDialog.onButtonClick.addListener(vdf.gui.onAlertButtonClick);
    
    //  Display the message
    oDialog.displayMessage(tAlert.sText);
    
    //  Pass the focus to the OK button
    oDialog.focusButton("oke");
};

/*
Handles the onButtonClick event of the alert dialog and closes the dialog that throws the event.

@param  oEvent  Reference to the event object.
@private
*/
vdf.gui.onAlertButtonClick = function(oEvent){
    if(oEvent.sButtonName === "oke"){
        oEvent.oSource.close();
    }
};

/*
Handles the onAfterClose event and removes the closed dialog from the queue and
calls alertFromQueue to display the next.

@param  oEvent  Reference to the event object.
@private
*/
vdf.gui.onAlertClosed = function(oEvent){
    vdf.gui.aAlertQueue.shift();
    if(vdf.gui.aAlertQueue.length > 0){
        vdf.gui.alertFromQueue();
    }
};

/*
Displays a modal dialog with the given DOM element as content.

@param  eElement    Reference to a DOM element with the dialog content.
@param  sTitle      Title of the dialog.
@param  iWidth      Width of the dialog (null is stretched).
@param  iHeight     Height of the dialog (null is stretched).
@return Reference to the created dialog object.
*/
vdf.gui.displayDOMDialog = function(eElement, sTitle, iWidth, iHeight){
    var oDialog = new vdf.gui.ModalDialog();
    
    oDialog.sTitle = sTitle || "Modal dialog";
    oDialog.iWidth = iWidth || null;
    oDialog.iHeight = iHeight || null;
    oDialog.displayDOM(eElement);
    
    return oDialog;
};

/*
Displays a modal dialog with the given HTML as content.

@param  sHTML       String with HTML content of the dialog.
@param  sTitle      Title of the dialog.
@param  iWidth      Width of the dialog (null is stretched).
@param  iHeight     Height of the dialog (null is stretched).
@return Reference to the created dialog object.
*/
vdf.gui.displayHTMLDialog = function(sHTML, sTitle, iWidth, iHeight){
    var oDialog = new vdf.gui.ModalDialog();
    
    oDialog.sTitle = sTitle || "Modal dialog";
    oDialog.iWidth = iWidth || null;
    oDialog.iHeight = iHeight || null;
    oDialog.displayHTML(sHTML);
    
    return oDialog;
};
