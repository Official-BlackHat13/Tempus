//
//  Class:
//      JModalDialog
//
//  Class used for displaying modal dialogs. (faked with divs and iframes)
//  
//  Since:      
//      13-01-2006
//  Changed:
//      --
//  Version:    
//      0.9
//  Creator:    
//      Data Access Europe (Judith Hilgerink)
//

//  PRIVATE
var JModalDialog_TabbableTags = new Array("A","BUTTON","TEXTAREA","INPUT","IFRAME", "SELECT"); 
// MM: changed to array to keep track of all opened Modal Dialogs
var oJModalDialog_ActiveDragMasks = new Array();
var oJModalDialog_CurrentDialog = new Array();

//
//  Displays a modal dialog with the given html.
//
//  Params:
//      sHTML       String with the html content displayed in the dialog
//      sTitle      (optional) The text displayed in the title bar
//      sWidth      (optional) The width of the dialog in pixels
//      sHeight     (optional) The height of the dialog in pixels
//      sContainer  (default = null) Id of dom element container to be used 
//                  instead of generated
//  Returns:
//      Reference tot the JModalDialog object 
//   
function JModalDialog_DisplayHTML(sHTML, sTitle, sWidth, sHeight, sContainer){
    var oJModalDialog, oDialogDiv;
    
    //  Create dialog
    oJModalDialog = new JModalDialog(sWidth, sHeight);
    oJModalDialog.sTitle = sTitle;
    if(typeof(sContainer) != "undefined" && sContainer != null){
            oJModalDialog.sContainer = sContainer;
    }    
    oDialogDiv = oJModalDialog.customDialog();    
    
    // set content of dialog
    oDialogDiv.innerHTML = sHTML;
    
    //  Position the modal dialog
    oJModalDialog.positionDialog(true);
    
    return oJModalDialog;
}

//
//  Displays a modal dialog with the given dom element as content. The content 
//  is moved from its original dom position to the dialog and returned when 
//  the dialog is closed.
//
//  Params:
//      oContent    The dom element displayed in the dialog
//      sTitle      (optional) The text displayed in the title bar
//      sWidth      (optional) The width of the dialog in pixels
//      sHeight     (optional) The height of the dialog in pixels
//      sContainer  (default = null) Id of dom element container to be used 
//                  instead of generated
//  Returns:
//      Reference to the JModalDialog object
//
function JModalDialog_DisplayDOM(oContent, sTitle, sWidth, sHeight, sContainer){
    var oJModalDialog, oDialogDiv, oContentParent, oContentNext;
    
    //  Save the parent element from the content
    oContentParent = oContent.parentNode;
    oContentNext = oContent.nextSibling;
    
    //  Init custom dialog and get content div
    oJModalDialog = new JModalDialog(sWidth, sHeight);
    oJModalDialog.sTitle = sTitle;
    if(typeof(sContainer) != "undefined" && sContainer != null){
            oJModalDialog.sContainer = sContainer;
    }
    
    //  Attach to special internal onClose event and reset the content if possible
    oJModalDialog.onClose = function(){
            if(oContentParent != null){
                oContentParent.insertBefore(oContent, oContentNext);
            }
        }
    
    oDialogDiv = oJModalDialog.customDialog();    
    
    //  Add the content to the dialog
    oDialogDiv.appendChild(oContent);
    
    
    
    var aoInputs = oDialogDiv.getElementsByTagName("INPUT");
    for (var iCount = 0; iCount<aoInputs.length; iCount++){
        aoInputs[iCount].tabIndex = aoInputs[iCount].getAttribute("origtabindex");
    }

    var aoSelects = oDialogDiv.getElementsByTagName("SELECT");
    for (var iCount = 0; iCount<aoSelects.length; iCount++){
        aoSelects[iCount].tabIndex = aoSelects[iCount].getAttribute("origtabindex");
    }
    
    var aoTextAreas = oDialogDiv.getElementsByTagName("TEXTAREA");
    for (var iCount = 0; iCount<aoTextAreas.length; iCount++){
        aoTextAreas[iCount].tabIndex = aoTextAreas[iCount].getAttribute("origtabindex");
    }
    
    oDialogDiv.appendChild(oContent);
    
    //  Position the modal dialog
    oJModalDialog.positionDialog(true);
    
    return oJModalDialog;
}



//  Displays a modal dialog with the given html.
//
//  Params:
//      sURL        String with the url to file being displayed
//      sTitle      (optional) The text displayed in the title bar
//      sWidth      (optional) The width of the dialog in pixels
//      sHeight     (optional) The height of the dialog in pixels
//      sContainer  (default = null) Id of dom element container to be used 
//                  instead of generated
//  Returns:
//      Reference tot the JModalDialog object 
//   
function JModalDialog_DisplayURL(sURL, sTitle, sWidth, sHeight, sContainer){
    var oJModalDialog;
    
    //  Create dialog
    oJModalDialog = new JModalDialog(sWidth, sHeight);
    oJModalDialog.sTitle = sTitle;
    if(typeof(sContainer) != "undefined" && sContainer != null){
            oJModalDialog.sContainer = sContainer;
    }    
    oJModalDialog.showPage(sURL);    
    
    return oJModalDialog;
}

//  Queue with waiting alert messages so they won't show on top of each other
//  PRIVATE
var aJModalDialog_Alert_Queue = new Array();

//
//  Handles the onAfterClose event from the modal dialog. It displays the next 
//  waiting modal dialog.
//
//  PRIVATE
function JModalDialog_AlertClosed(){
    aJModalDialog_Alert_Queue.shift();

    if(aJModalDialog_Alert_Queue.length > 0){
        JModalDialog_AleryFromQueue();
    }
}

//
//  Displays the first alert message waiting in the queue in a modal dialog.
//
//  PRIVATE
function JModalDialog_AleryFromQueue(){
    //  Fetch from queue
    var oQueuedAlert = aJModalDialog_Alert_Queue[0];
    
    //  Create dialog
    var oJModalDialog = new JModalDialog();
    oJModalDialog.sContainer = oQueuedAlert.sContainer;
    oJModalDialog.sTitle = oQueuedAlert.sTitle;
    if(oQueuedAlert.sContainer != null){
        oJModalDialog.sContainer = oQueuedAlert.sContainer;
    }
    oJModalDialog.onAfterClose = JModalDialog_AlertClosed;
    
    if (oQueuedAlert.sText == "" || oQueuedAlert.sText.length < 15) oJModalDialog.iWidth = 300;
    
    //  Display dialog
    oJModalDialog.showMessage(oQueuedAlert.sText);
}

//
//  Displays the given message in a modal dialog. If there is already a message
//  shown the message is queued until the previous is closed.
//
//  Params:
//      sText       The text to be shown in the dialog
//      sTitle      (optional) The title of the dialog
//      sContainer  (optional) Id of existing container instead of generated
//
function JModalDialog_Alert(sText, sTitle, sContainer){
    var oQueuedAlert;
    
    //  Set default values if not given
    if(typeof(sTitle) == "undefined"){
        var sTitle = "Alert";
    }
    if(typeof(sContainer) == "undefined"){
        var sContainer = null;
    }
    
    //  Add to queue
    oQueuedAlert = { "sText" : sText, "sTitle" : sTitle, "sContainer" : sContainer }
    aJModalDialog_Alert_Queue.push(oQueuedAlert);
    
    //  If no others waiting display
    if(aJModalDialog_Alert_Queue.length == 1){
        JModalDialog_AleryFromQueue();
    }
}

//
//  Closes the current dialog after calling the onFinished function.
//
//  Params:
//      sValue  The return value
//
function JModalDialog_Return(sValue){
    var oDialog = JModalDialog_Find();
    
    if(oDialog != null){
        oDialog.returns(sValue);
    }    
}

//
//  Closes the current dialog.
//
function JModalDialog_Hide(){
    var oDialog = JModalDialog_Find();    

    if(oDialog != null){
        oDialog.hide();
    }
}

//
//  Finds the current dialog (can also be used from the dialog frame)
//
//  Returns:
//      The current dialog (null if not found)
//
function JModalDialog_Find(){
    var oResult = oJModalDialog_CurrentDialog[oJModalDialog_CurrentDialog.length - 1];
    
    if(oResult == null && typeof(window.top.oJModalDialog_CurrentDialog) == "array"){
        oResult = window.top.oJModalDialog_CurrentDialog[window.top.oJModalDialog_CurrentDialog.length - 1];
    }
    
    return oResult;
}

//
//  Constructor: Sets the default values and the given size.
//
function JModalDialog(iWidth, iHeight){
    if(iWidth == null || typeof(iWidth) == "undefined") var iWidth = 0;
    if(iHeight == null || typeof(iHeight) == "undefined") var iHeight = 0;
    
    //  Public Properties
    this.sTitle         = "New modal dialog";
    this.iWidth         = iWidth;
    this.iHeight        = iHeight;
    this.sContainer     = "";

    //  Private Properties
    this.iX             = -1;
    this.iY             = -1;
    this.iDragOffsetY   = 0;
    this.iDragOffsetX   = 0;
    
    this.oDivInner      = null;
    this.oDivMask       = null;
    this.oDivDragMask   = null;
    this.oDivContainer  = null;
    this.oDivTitlebar   = null;
    this.oDivTitle      = null;
    this.oDivControls   = null;
    this.oAnchorClose   = null;
    this.oPopupFrame    = null;
    this.fOrigMouseDown = null;
    	    
    this.bDragging;
    
    this.iCount = oJModalDialog_CurrentDialog.length;
    oJModalDialog_CurrentDialog[this.iCount] = this;
        
}

//
//  Displays the dialog and loads an external page into it.
//
//  Params:
//      sUrl    Url of page to load 
//
JModalDialog.prototype.showPage = function(sUrl){
    this.disableTabIndexes();
    this.createDialog();
    
    this.oPopupFrame = document.createElement("iframe");
    this.oDivInner.appendChild(this.oPopupFrame);
    this.oPopupFrame.setAttribute("id","popupFrame" + this.iCount);
    this.oPopupFrame.setAttribute("name","popupFrame" + this.iCount);
    this.oPopupFrame.className = "popupFrame";
    this.oPopupFrame.setAttribute("scrolling","auto");
    this.oPopupFrame.setAttribute("frameborder","0");
    this.oPopupFrame.setAttribute("allowtransparency","true"); 
    this.oPopupFrame.src = sUrl;  

    this.positionDialog(true);
}

//
//  Displays a dialog with the given message and hides the focus.
//
//  Params:
//      sText The text shown in the dialog
//
JModalDialog.prototype.showMessage = function(sText){
    var oTextDiv, oFocusInput;
    
    this.disableTabIndexes();
    this.createDialog();
        
    //  Create and add text div
    oTextDiv = document.createElement("div");
    oTextDiv.setAttribute("id","alertText"); 
    browser.dom.setElementText(oTextDiv, sText);
    this.oDivInner.appendChild(oTextDiv);
    
    //  Create a focus holder
    oFocusInput = document.createElement("input")
    oFocusInput.setAttribute("id", "give_away_focus")
    oFocusInput.style.position = "absolute";
    oFocusInput.style.width = "0";
    oFocusInput.style.height = "0";    
    document.body.appendChild(oFocusInput);
    
    //  Timed function that sets the focus and removes the focus element
    var fSetFocus = function(){
        oFocusInput.focus();
        document.body.removeChild(oFocusInput); 
    }
    setTimeout(fSetFocus, 100);
    
    this.positionDialog(true);
}

//
//  Creates a dialog for custom usage, the inner div is returned so it van be 
//  filled for own needs.
//
JModalDialog.prototype.customDialog = function(){
    this.disableTabIndexes();
    this.createDialog();  
    
    return this.oDivInner;
}

//
//  Hides the dialog and calls the onFinished function with the result and the
//  loadobject.
//
//  Params:
//      oResult  The return value
//
JModalDialog.prototype.returns = function(oResult){
    this.hide();
    this.onFinished(this, oResult);
}

//
//  Deletes / hides the dialog
//
JModalDialog.prototype.hide = function(){
    //  Call the onBeforeClose event
    if(this.onBeforeClose(this)){
        //  Restore mousedown event
        if(this.fOrigMouseDown != null){
            document.onmousedown = this.fOrigMouseDown;
            this.fOrigMouseDown = null;
        }
        
        //  Remove event listeners
        browser.events.removeGenericListener("mousedown", this.oDivContainer, this.onTitle_MouseDown);
        browser.events.removeGenericListener("mousedown", this.oDivInner, browser.events.stop);
        if (this.oAnchorClose) browser.events.removeGenericListener("mousedown", this.oAnchorClose, browser.events.stop);
        browser.events.removeGenericListener("resize", window, this.onWindow_Resize);
        if(browser.isIE && browser.iVersion <= 6){
            browser.events.removeGenericListener("scroll", window, this.onWindow_Scroll);
        }
        
        //  Restore tabindexes and select boxes
        this.restoreTabIndexes();
        browser.gui.displaySelectBoxes(this.oDivMask, this.oDivInner);
        
        
        //  Remove elements from DOM
        document.body.removeChild(this.oDivMask);
        document.body.removeChild(this.oDivContainer);

        //  Remove references
        this.oDivInner      = null;
        this.oDivMask       = null;
        this.oDivDragMask   = null;
        this.oDivContainer  = null;
        this.oDivTitlebar   = null;
        this.oDivTitle      = null;
        this.oDivControls   = null;
        this.oAnchorClose   = null;
        this.oPopupFrame    = null;
        
    	// MM: Remove closed Modal Dialog from array
        oJModalDialog_CurrentDialog.splice((this.iCount),1);
        
        //  Call internal onClose used in JModalDialog_DisplayDOM
        if(typeof(this.onClose) == "function"){
            this.onClose();
        }
        
        //  Call the onAfterClose Event
        this.onAfterClose(this);
    }
}

//
//  Creates the dialog objects (divs, iframes, etc..)
//
//  PRIVATE
JModalDialog.prototype.createDialog = function(){
    var bCustomContainer = false;
    var iAdjust = 0;
    
    if (typeof(scrollMaxY) != "undefined") if (scrollMaxY > 0) iAdjust = 16;
    
   //This will first create all the html DOM elements and after that set the height and width.
    var oDivMask = document.createElement("div");
    document.body.appendChild(oDivMask);
    oDivMask.setAttribute("id","popupMask" + this.iCount);
    oDivMask.className = "popupMask";
    oDivMask.style.zIndex = 900 + (1 * (this.iCount + 1));
    oDivMask.innerHTML = "&nbsp;";
    this.setFixedX(oDivMask, 0);
    this.setFixedY(oDivMask, 0);
    oDivMask.style.height = browser.gui.getViewportHeight() + "px";
    oDivMask.style.width = (browser.gui.getViewportWidth()) - iAdjust + "px";
    
    if (this.sContainer != "") {
        if (document.getElementById(this.sContainer)){
            var oDivContainer = document.getElementById(this.sContainer).cloneNode(true);
            if (oDivContainer) bCustomContainer = true;
        }
    }

    if (!bCustomContainer) var oDivContainer = document.createElement("div");
    document.body.appendChild(oDivContainer);
    oDivContainer.setAttribute("id","popupContainer" + this.iCount);
    oDivContainer.className = "popupContainer";
    oDivContainer.style.zIndex=900+(2 * (this.iCount + 1));

    
    if (bCustomContainer){
        this.scanCustomDialog(oDivContainer);
        
        var oDivTitlebar = document.getElementById("popupTitleBar" + this.iCount);        
        var oDivTitle = document.getElementById("popupTitle" + this.iCount);
        oDivTitle.innerHTML = this.sTitle;	        
        var oDivControls = document.getElementById("popupControls" + this.iCount);            
        var oAnchorClose = document.getElementById("a" + this.iCount);        
        var oImgClose = document.getElementById("img" + this.iCount);
        var oDivInner = document.getElementById("popupInner" + this.iCount);
    }else{
        var oDivTitlebar = document.createElement("div");
        oDivContainer.appendChild(oDivTitlebar);
        oDivTitlebar.setAttribute("id","popupTitleBar" + this.iCount);
        oDivTitlebar.className = "popupTitleBar";
        browser.gui.disableTextSelection(oDivTitlebar);
        
        var oDivStretch = document.createElement("div");
        oDivTitlebar.appendChild(oDivStretch);
        oDivStretch.className = "popupTitleBarStretcher"
        
        var oDivControls = document.createElement("div");
        oDivTitlebar.appendChild(oDivControls);
        oDivControls.setAttribute("id","popupControls" + this.iCount);
        oDivControls.className = "popupControls";
        
        var oDivTitle = document.createElement("div");
        oDivTitlebar.appendChild(oDivTitle);
        oDivTitle.setAttribute("id","popupTitle" + this.iCount);
        oDivTitle.className = "popupTitle";    
        oDivTitle.innerHTML = this.sTitle;	

        oDivStretch = document.createElement("div");
        oDivTitlebar.appendChild(oDivStretch);
        oDivStretch.className = "popupTitleBarStretcher"
        
        var oAnchorClose = document.createElement("a");
        oDivControls.appendChild(oAnchorClose);
        oAnchorClose.setAttribute("href","javascript: JModalDialog_Hide();");
        oAnchorClose.setAttribute("id","a" + this.iCount);
        
        var oImgClose = document.createElement("img");
        oAnchorClose.appendChild(oImgClose);
        oImgClose.setAttribute("src","Images/ModalDialog/Close.gif");
        oImgClose.setAttribute("id","img" + this.iCount);
            
        var oDivInner = document.createElement("div");
        oDivContainer.appendChild(oDivInner);
        oDivInner.setAttribute("id","popupInner" + this.iCount);
        oDivInner.style.position = "relative";  //  Strange FF problem when setting from the CSS Sheet
        oDivInner.className = "popupInner";
    }   
    
    if(this.iHeight > 0){
        oDivInner.style.height = this.iHeight + "px";
    }    
    if(this.iWidth > 0){
        oDivInner.style.width = this.iWidth + "px";
        oDivTitlebar.style.width = this.iWidth + "px";
    }
    
    this.oDivMask = oDivMask;
    this.oDivInner = oDivInner;
    this.oDivTitlebar = oDivTitlebar;
    this.oDivTitle = oDivTitle;
    this.oDivControls = oDivControls
    this.oDivContainer = oDivContainer;
    this.oAnchorClose = oAnchorClose;
    
    //  Store origional mousedown handler and remove it if first dialog
    if (oJModalDialog_CurrentDialog.length == 1)
    {
        this.fOrigMouseDown = document.onmousedown;
        document.onmousedown = "";
    }
    
    //  When resizing we will reposition & resize the dialog
    browser.events.addGenericListener("resize", window, this.onWindow_Resize);

    //  IE6 doesn't support fixed positioning so this is done absolute and requires a onScroll event to move all the stuff
    if(browser.isIE && browser.iVersion <= 6){
        browser.events.addGenericListener("scroll", window, this.onWindow_Scroll);
        oDivContainer.style.position = "absolute";
        oDivMask.style.position = "absolute";
    }
    
    //  Drag event
    if(browser.isIE){
        browser.events.addGenericListener("mousedown", oDivContainer, this.onTitle_MouseDown);
        browser.events.addGenericListener("mousedown", oDivInner, browser.events.stop);
    }else{
        browser.events.addGenericListener("mousedown", oDivTitlebar, this.onTitle_MouseDown);
    }
    
    
    //  Make sure close buttons won't couse drag
    if (oAnchorClose) browser.events.addGenericListener("mousedown", oAnchorClose, browser.events.stop);
    
    this.bSelectsHidden = false;
}

//
//  recursive function used for adding unique ids to custom dialog elements
//
//  PRIVATE
JModalDialog.prototype.scanCustomDialog = function(oModalElement){
    
    for (var iCount = 0; iCount<oModalElement.childNodes.length; iCount++){
        if (typeof(oModalElement.childNodes[iCount].id) != "undefined" && oModalElement.childNodes[iCount].id !="udefined") {
            oModalElement.childNodes[iCount].setAttribute("id",oModalElement.childNodes[iCount].id + this.iCount);
        }
        this.scanCustomDialog(oModalElement.childNodes[iCount]);
    }   
}


//
//  Updates the position and sets a small timeout that updates the position 
//  again to prevent strange errors from occurring.
//
//  Params:
//      bCalculateSizes   If true the width of the dialog is recalculated.
//
JModalDialog.prototype.positionDialog = function(bCalculateSizes){
    var oDialog = this;
    
    if(bCalculateSizes && !(browser.isIE && browser.iVersion <= 6)){
        oDialog.calculateSizes();
    }
    oDialog.calculatePosition();
    
    
    if(bCalculateSizes){
        setTimeout(function(){
            oDialog.calculateSizes.call(oDialog);
        }, 10);
    }
    
    setTimeout(function(){
        oDialog.calculatePosition.call(oDialog);
        oDialog.oDivContainer.style.visibility = "visible";
        
        // for IE <= 6
        if(!oDialog.bSelectsHidden){
            oDialog.bSelectsHidden = true;
            browser.gui.hideSelectBoxes(oDialog.oDivMask, oDialog.oDivInner);
        }
    }, 20);
}

//
//  (re)calculates the size of the dialog (if it isn't static) and sets it. It 
//  makes sure the dialog isn't to big for the page.
//
JModalDialog.prototype.calculateSizes = function(){
    var iFullWidth, iFullHeight, iAdjust;
    
    iAdjust = ((typeof(scrollMaxY) != "undefined") && (scrollMaxY > 0) ? 16 : 0);
    
    if(!(this.iWidth > 0)){
        iTitleWidth = this.oDivTitle.offsetWidth + this.oDivControls.offsetWidth + 18;
        iContentWidth = this.oDivInner.offsetWidth;
        iWantedWidth = (iTitleWidth > iContentWidth ? iTitleWidth : iContentWidth);
        
        iFullWidth = browser.gui.getViewportWidth() - iAdjust;
        if(iWantedWidth > iFullWidth){
            iWantedWidth = iFullWidth;
        }
        
        this.oDivContainer.style.width = iWantedWidth + "px";
    }
    
    if(!(this.iHeight > 0)){
        iFullHeight = browser.gui.getViewportHeight() - iAdjust;
        if(this.oDivContainer.offsetHeight > iFullHeight){
            this.oDivContainer.style.height = iFullHeight;
        }
    }
}

//
//  (re)calculates the position of the dialog. If the position is outside the 
//  screen it resets it to the middle of the page.
//
JModalDialog.prototype.calculatePosition = function(){
    var iFullWidth, iFullHeight, iDialogWidth, iDialogHeight, iAdjust;

    iAdjust = ((typeof(scrollMaxY) != "undefined") && (scrollMaxY > 0) ? 16 : 0);
    
    iFullWidth = browser.gui.getViewportWidth() - iAdjust;
    iFullHeight = browser.gui.getViewportHeight() - iAdjust;
    iDialogWidth = this.oDivContainer.offsetWidth;
    iDialogHeight = this.oDivContainer.offsetHeight;

     //  Set mask size
    this.oDivMask.style.height = (iFullHeight + iAdjust) + "px";
    this.oDivMask.style.width = (iFullWidth + iAdjust) + "px";
    this.setFixedX(this.oDivMask, 0);
    this.setFixedY(this.oDivMask, 0);

    //  Calculate if dialog is not offscreen
    if(this.iX < (iDialogWidth / 2) || this.iX > (iFullWidth - (iDialogWidth / 2))){
        this.iX = (iFullWidth / 2);
    }
    if(this.iY < (iDialogHeight / 2) || this.iY > (iFullHeight - (iDialogHeight / 2))){
        this.iY = (iFullHeight / 2);
    }
    
    //  Set position and size
    this.setFixedX(this.oDivContainer, (this.iX - (iDialogWidth / 2)))
    this.setFixedY(this.oDivContainer, (this.iY - (iDialogHeight / 2)));
}

//
//  Sets the vertical position of the given element. The position is given 
//  fixed in pixels (the amount of pixels from the top of the screen, 
//  regardless the scroll position). If the element is positioned absolute it 
//  calculates the absolute position (usually the case for IE 6 and older which
//  doesn't support fixed positioning).
//
//  Params:
//      eElement    The element to position
//      iY          Fixed vertical position in pixels
//
JModalDialog.prototype.setFixedY = function(eElement, iY){
    if(eElement.style.position == "absolute"){
        iY = iY + parseInt(document.documentElement.scrollTop, 10);
    }
    eElement.style.top = iY + "px";
}

//
//  Sets the horizontal position of the given element. The position is given
//  fixed in pixels and if nessacary it is translated to a absolute position.
//
//
//  Params:
//      eElement    The element to position
//      iX          Fixed horizontal position in pixels
//
JModalDialog.prototype.setFixedX = function(eElement, iX){
    if(eElement.style.position == "absolute"){
        var iX = iX + parseInt(document.documentElement.scrollLeft, 10);
    }
    eElement.style.left = iX + "px";
}

//
//  Determines the fixed vertical position of the element (the amount of pixels 
//  between the top of the browser window and the element). If the element is 
//  positioned absolute it calculates the value using the scrollTop value.
//
//  Params:
//      eElement    Element to get the position of.
//  Returns:
//      The fixed vertical position of the element.
//
JModalDialog.prototype.getFixedY = function(eElement){
    if(eElement.style.position == "absolute"){
        return parseInt(eElement.style.top) - parseInt(document.documentElement.scrollTop, 10);
    }else{
        return parseInt(eElement.style.top);
    }
}

//
//  Determines the fixed horizontal position of the element.
//
//  Params:
//      eElement    Element to get the position of.
//  Returns:
//      The fixed horizontal position of the element.
//
JModalDialog.prototype.getFixedX = function(eElement){
    if(eElement.style.position == "absolute"){
        return parseInt(eElement.style.left) - parseInt(document.documentElement.scrollLeft, 10);
    }else{
        return parseInt(eElement.style.left);
    }
}

// 
//  Disables the tabindex of the background elements.
//
//  TODO: Find a way to do it under firefox
//
//  PRIVATE
JModalDialog.prototype.disableTabIndexes = function()
{
    if(oJModalDialog_CurrentDialog.length == 1){    
        var i = 0;
        for (var j = 0; j < JModalDialog_TabbableTags.length; j++)
        {
            var tagElements = document.getElementsByTagName(JModalDialog_TabbableTags[j]);
            for (var k = 0 ; k < tagElements.length; k++)
            {
                tagElements[k].setAttribute("origTabIndex", tagElements[k].tabIndex);
                tagElements[k].tabIndex="-1";            
                i++;
            }
        }
    }
}


//
//  Restores the tabindex of the background elemtns
//
//  TODO: Find a way to do it under firefox
//
//  PRIVATE
JModalDialog.prototype.restoreTabIndexes = function()
{
    if(oJModalDialog_CurrentDialog.length == 1){
        var i = 0;
        for (var j = 0; j < JModalDialog_TabbableTags.length; j++)
        {
            var tagElements = document.getElementsByTagName(JModalDialog_TabbableTags[j]);
            for (var k = 0 ; k < tagElements.length; k++)
            {
                tagElements[k].tabIndex = tagElements[k].getAttribute("origTabIndex");
                i++;
            }
        }
    }
}

//
//  Starts the dragging by creating the overlaying div and attaching the event 
//  listeners. Also saves the mouse offset from the upper left corner of the 
//  dialog.
//
//  Params:
//      mouseX  Current horizontal mouse position
//      mouseY  Current vertical mouse position
//
//  PRIVATE
JModalDialog.prototype.startDrag = function(mouseX, mouseY){
    if (!this.bDragging){
        this.bDragging = true;
        
        //  Create overlaying div
        this.oDivDragMask = document.createElement("div");
        document.body.appendChild(this.oDivDragMask);
        // MM: unique id
        this.oDivDragMask.setAttribute("id","popupDragMask" + this.iCount);
        // MM: add class for style settings
        this.oDivDragMask.className = "popupDragMask";
        this.oDivDragMask.innerHTML="&nbsp;";
        if(browser.isIE && browser.iVersion <= 6){
            this.oDivDragMask.style.position = "absolute";
        }
        
         // Get & Set overlaying div size & location
        var fullHeight = browser.gui.getViewportHeight();
        var fullWidth = browser.gui.getViewportWidth();
        this.setFixedX(this.oDivDragMask, 0);
        this.setFixedY(this.oDivDragMask, 0);
        this.oDivDragMask.style.height = fullHeight + "px";
        this.oDivDragMask.style.width = fullWidth + "px";
        
        //  Get drag offset
        this.iDragOffsetY = mouseY - this.getFixedY(this.oDivContainer);
        this.iDragOffsetX = mouseX - this.getFixedX(this.oDivContainer);
        
        //  Add eventlisteners
        browser.events.addGenericListener("mouseup", this.oDivDragMask, this.onDragMask_MouseUpOut);
        browser.events.addGenericListener("mouseout", this.oDivDragMask, this.onDragMask_MouseUpOut);
        browser.events.addGenericListener("mousemove", this.oDivDragMask, this.onDragMask_MouseMove);
        
        oJModalDialog_ActiveDragMasks.push(this.oDivDragMask);
    }
}

//
//  Stops the dragging by deattaching the event listeners and removing the 
//  overlaying div.
//
//  PRIVATE
JModalDialog.prototype.stopDrag = function(){

    for(var iPos in oJModalDialog_ActiveDragMasks){
        this.oDivDragMask = oJModalDialog_ActiveDragMasks[iPos];
        //  Remove event listeners
        browser.events.removeGenericListener("mouseup", this.oDivDragMask, this.onDragMask_MouseUpOut);
        browser.events.removeGenericListener("mouseout", this.oDivDragMask, this.onDragMask_MouseUpOut);
        browser.events.removeGenericListener("mousemove", this.oDivDragMask, this.onDragMask_MouseMove);
        //  Remove overlaying div
        document.body.removeChild(this.oDivDragMask);
        this.oDivDragMask = null;
        
    }
    
    oJModalDialog_ActiveDragMasks.length = 0;
    this.bDragging = false;
}

//
//  Drags the dialog using the given mouse position.
//
//  Params:
//      mouseX  Current horizontal mouse position
//      mouseY  Current vertical mouse position
//
//  PRIVATE
JModalDialog.prototype.drag = function(mouseX, mouseY){
    if (this.bDragging){
        var newX = (mouseX - this.iDragOffsetX);
        var newY = (mouseY - this.iDragOffsetY);
        var iAdjust = ((typeof(scrollMaxY) != "undefined") && (scrollMaxY > 0) ? 16 : 0);
        
        if(newX > 0 && newX < (browser.gui.getViewportWidth() - this.oDivContainer.offsetWidth - iAdjust)){ 
            this.setFixedX(this.oDivContainer, newX);
            this.iX = newX;
        }else{
            this.iDragOffsetX = mouseX - this.getFixedX(this.oDivContainer);
        }
        if(newY > 0 && newY < (browser.gui.getViewportHeight() - this.oDivContainer.offsetHeight - iAdjust)){
            this.setFixedY(this.oDivContainer, newY);
            this.iY = newY;
        }else{
            this.iDragOffsetY = mouseY - this.getFixedY(this.oDivContainer);
        }   
    }
}

//
//  Fetches the onscroll event and relocates the frame. Only used for IE6 and 
//  older.
//
//  PRIVATE
JModalDialog.prototype.onWindow_Scroll = function(e){
    if(oJModalDialog_CurrentDialog[oJModalDialog_CurrentDialog.length-1] != null){
    	// MM: get last Modal Dialog in araray (the one currently active)
        oDialog = oJModalDialog_CurrentDialog[oJModalDialog_CurrentDialog.length-1];
    	
        oDialog.iX = 0;
        oDialog.iY = 0;
        oDialog.setFixedX(oDialog.oDivContainer, 0);
        oDialog.setFixedY(oDialog.oDivContainer, 0);
        oDialog.positionDialog();
        oDialog.setFixedX(oDialog.oDivMask, 0);
        oDialog.setFixedY(oDialog.oDivMask, 0);
    }
}

//
//  Fetches the onresize event, relocates the frame
//
//  PRIVATE
JModalDialog.prototype.onWindow_Resize = function(e){
    var oDialog;
    if(oJModalDialog_CurrentDialog[oJModalDialog_CurrentDialog.length-1] != null){
        // MM: get last Modal Dialog in araray (the one currently active)
        oDialog = oJModalDialog_CurrentDialog[oJModalDialog_CurrentDialog.length-1];
    	 
        oDialog.iX = 0;
        oDialog.iY = 0;
        if(oDialog.oDivContainer != null){
            oDialog.setFixedX(oDialog.oDivContainer, 0);
            oDialog.setFixedY(oDialog.oDivContainer, 0);
            oDialog.oDivContainer.style.width = "";
            oDialog.positionDialog(true);
        }
    }
}

//
//  Fetches the mousedown on the titlebar, starts draging.
//
//  PRIVATE
JModalDialog.prototype.onTitle_MouseDown = function(e){
    if(oJModalDialog_CurrentDialog[oJModalDialog_CurrentDialog.length-1] != null){
        var x = browser.events.getMouseX(e);
        var y = browser.events.getMouseY(e);
        // MM: get last Modal Dialog in araray (the one currently active)
        oJModalDialog_CurrentDialog[oJModalDialog_CurrentDialog.length-1].startDrag(x, y);
        
        return false;
    }
}

//
//  Fetches the onmouseup or onmouseout event from the overlaying div, stops
//  dragging.
//
//  PRIVATE
JModalDialog.prototype.onDragMask_MouseUpOut = function(e){
	  if(oJModalDialog_CurrentDialog[oJModalDialog_CurrentDialog.length-1] != null){
	  	  // MM: get last Modal Dialog in araray (the one currently active)
        oJModalDialog_CurrentDialog[oJModalDialog_CurrentDialog.length-1].stopDrag();
    }
}

//
//  Fetches onmousemove from dragmask, drags the dialog.
//
//  PRIVATE
JModalDialog.prototype.onDragMask_MouseMove = function(e){
    if(oJModalDialog_CurrentDialog[oJModalDialog_CurrentDialog.length-1] != null){
        var x = browser.events.getMouseX(e);
        var y = browser.events.getMouseY(e);
        // MM: get last Modal Dialog in araray (the one currently active)
        oJModalDialog_CurrentDialog[oJModalDialog_CurrentDialog.length-1].drag(x, y);
    }
}



//  - - - - - - - USER EVENTS - - - - - - - -

//
//  Should be overloaded with function that handles the result
//
//  Params:
//      oJModalDialog   Reference to the dialog object
//      oResult         The return value
//
JModalDialog.prototype.onFinished = function(oJModalDialog, oResult){
    
}

//
//  Is called before the dialog is closed
//
//  Params:
//      oJModalDialog   Reference to the dialog object
//  Returns:
//      If false the dialog won't be closed
//
JModalDialog.prototype.onBeforeClose = function(oJModalDialog){
    return true;
}

//
//  Is called after the dialog is closed
//
//  Params:
//      oJModalDialog   Reference to the dialog object
//
JModalDialog.prototype.onAfterClose = function(oJModalDialog){
    
}

