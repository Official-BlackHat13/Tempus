//
//  Class:
//      JScrollBar
//
//  Contains code the code that display's an scrollbar with the visual  dataflex
//  features. The scrollbar has a function that should be overriden (because we 
//  are unable to throw custom events): onScroll(iScroll)
//
//  Since:
//      07-2005
//  Changed:
//      --
//  Version:
//      0.9
//  Creator:
//      Data Access Europe (Harm Wibier)
//


//  Used for resizing on window resize
//  PRIVATE
var JScrollBar_Count        = 0;
var jScrollBars = new Array();


//  PRIVATE
function resizeScrollBars(e){
    for(var iLoop = 0; iLoop < jScrollBars.length; iLoop++){
        jScrollBars[iLoop].setSizes();
    }
}

browser.events.addGenericListener('resize', window, resizeScrollBars);

var JScrollBar_Top          = -3;
var JScrollBar_Up           = -2;
var JScrollBar_StepUp       = -1;
var JScrollBar_StepDown     = 1;
var JScrollBar_Down         = 2;
var JScrollBar_Bottom       = 3;


//
//  Function:
//      JScrollBar
//
//  Description:
//      Constructor, creates the object and sets the default settings.
//  Parameters:
//      sName           Name of the object variable (not used..)
//
function JScrollBar(){
    JScrollBar_Count++;
    
    //  Public properties
    this.iBlockSize = 16;
    this.iSliderLength = 30;
    this.sCssMain = "JScrollBar"
    this.sCssBtnUp = "btnUp";
    this.sCssBtnDown = "btnDown";
    this.sCssSlider = "slider";
    this.sCssFillerBars = "filler";
    this.oScrollElement = null;
    this.bAutoScroll = true;
    this.iAutoScrollWait = 60;
    this.iAutoScrollStart = 500;   
    
    //  Private properties
    this.bDrag = false;
    this.iSliderDiff = null;
    
    this.iMarginRight = 0;
    this.iMarginTop = 0;
    this.iCount = JScrollBar_Count;
    
    return this;
}


//
//  Function:
//      JScrollBar.construct
//
//  Description:
//      Creates the scrollbar objects in the parent object.
//
JScrollBar.prototype.construct = function(){
    var oTable, oRow, oBtnUp, oBtnDown, oSpaceBefore, oSpaceAfter, oSlider, oScrollElement, oClearDiv;

    oScrollElement = this.oScrollElement;
    oScrollElement.setAttribute("id", "JScroll" + this.iCount);
    
    //    Generate html objects   
    oTable = document.createElement('table');
    oTable.setAttribute("id", "JScrollBar" + this.iCount);
    oTable.oJScroll = this;
    
    oRow = oTable.insertRow(oTable.rows.length);
    oBtnUp = oRow.insertCell(oRow.cells.length);
    oBtnUp.innerHTML = '';
    oBtnUp.setAttribute("id", "BtnUp" + this.iCount);
    
    oRow = oTable.insertRow(oTable.rows.length);
    oSpaceBefore = oRow.insertCell(oRow.cells.length);
    oSpaceBefore.innerHTML = '';
    oSpaceBefore.setAttribute("id", "SpaceBefore" + this.iCount);
    
    oRow = oTable.insertRow(oTable.rows.length);
    oSlider = oRow.insertCell(oRow.cells.length);
    oSlider.innerHTML = '';
    oSlider.setAttribute("id", "Slider" + this.iCount);
    
    oRow = oTable.insertRow(oTable.rows.length);
    oSpaceAfter = oRow.insertCell(oRow.cells.length);
    oSpaceAfter.innerHTML = '';
    oSpaceAfter.setAttribute("id", "SpaceAfter" + this.iCount);
    
    oRow = oTable.insertRow(oTable.rows.length);
    oBtnDown = oRow.insertCell(oRow.cells.length);
    oBtnDown.innerHTML = '';
    oBtnDown.setAttribute("id", "BtnDown" + this.iCount);
    
    //    Set styles & start sizes
    oTable.style.cursor = 'default';
    oTable.className = this.sCssMain;
    oBtnUp.className = this.sCssBtnUp;
    oBtnDown.className = this.sCssBtnDown;
    oSpaceAfter.className = this.sCssFillerBars;
    oSpaceBefore.className = this.sCssFillerBars
    oSlider.className = this.sCssSlider;
    oTable.cellPadding = 0;
    oTable.cellSpacing = 0;

    oClearDiv = document.createElement('div');
    oClearDiv.style.clear = "both";
    
    //    Append to parent
    if(oScrollElement.nextSibling != null){
        oScrollElement.parentNode.insertBefore(oClearDiv, oScrollElement.nextSibling);
        oScrollElement.parentNode.insertBefore(oTable, oScrollElement.nextSibling);        
    }else{
        oScrollElement.parentNode.appendChild(oTable);
        oScrollElement.parentNode.appendChild(oClearDiv);
    }
    
    //  Set CSS Styles
    oScrollElement.style.cssFloat = "left";
    oScrollElement.style.styleFloat = "left";
    oTable.style.cssFloat = "left";
    oTable.style.styleFloat = "left";
    
    //    Set properties
    this.oTable = oTable;
    this.oBtnUp = oBtnUp;
    this.oBtnDown = oBtnDown;
    this.oSpaceBefore = oSpaceBefore;
    this.oSpaceAfter = oSpaceAfter;
    this.oSlider = oSlider;

    this.setSizes();
    
    this.iValue = this.iTotal / 2;
    
    //    Attach event listeners
    if(this.bAutoScroll){
        browser.events.addGenericListener("mousedown", oBtnUp, this.onBtnUpStart);
        browser.events.addGenericListener("mouseup", oBtnUp, this.onBtnUpStop);
        browser.events.addGenericListener("mouseout", oBtnUp, this.onBtnUpStop);

        browser.events.addGenericListener("mousedown", oBtnDown, this.onBtnDownStart);
        browser.events.addGenericListener("mouseup", oBtnDown, this.onBtnDownStop);
        browser.events.addGenericListener("mouseout", oBtnDown, this.onBtnDownStop);
    }else{
        browser.events.addGenericListener('click', oBtnUp, this.onBtnUpClick);
        browser.events.addGenericListener('click', oBtnDown, this.onBtnDownClick);
    }

    browser.events.addGenericListener('mousedown', oSlider, this.onSliderMouseDown);
    browser.events.addGenericListener('click', oSpaceAfter, this.onSpaceAfterClick);
    browser.events.addGenericListener('click', oSpaceBefore, this.onSpaceBeforeClick);
    
    if(browser.isIE){
        //  Stops selection on IE
        browser.events.addGenericListener('selectstart', oBtnUp, browser.events.stop);
        browser.events.addGenericListener('selectstart', oBtnDown, browser.events.stop);
        browser.events.addGenericListener('selectstart', oSpaceAfter, browser.events.stop);
        browser.events.addGenericListener('selectstart', oSpaceBefore, browser.events.stop);
    }
 
    //  Adds the scrollbar to the resize array   
    jScrollBars[jScrollBars.length] = this;
}


//
//  Function:    
//      JScrollBar.setSizes
//
//  Description:
//      Sets the sizes of the object
//
JScrollBar.prototype.setSizes = function(){
    var iBlockSize = this.iBlockSize;   

    if(this.oScrollElement.tBodies[0].clientHeight > 0) {
        var iTotalHeight = this.oScrollElement.tBodies[0].clientHeight + this.oScrollElement.tBodies[0].offsetTop - this.iMarginTop;
    } else {
        var iTotalHeight = this.oScrollElement.clientHeight - this.iMarginTop;
    }

    if(iTotalHeight < (iBlockSize * 2 + this.iSliderLength + 2)){
        iTotalHeight = (iBlockSize * 2 + this.iSliderLength + 2);
    }

    this.oTable.style.marginLeft = "-" + (this.iBlockSize + this.iMarginRight) + "px";
    this.oTable.style.marginTop = this.iMarginTop + "px";

    this.oTable.style.height = iTotalHeight + "px";
    this.oTable.style.width = iBlockSize + "px";
    this.oBtnUp.style.width = iBlockSize + "px";
    this.oBtnDown.style.width = iBlockSize + "px";
    this.oSpaceBefore.style.width = iBlockSize + "px";
    this.oSpaceAfter.style.width = iBlockSize + "px";
    this.oSlider.style.width = iBlockSize + "px";
    
    this.oBtnUp.height = iBlockSize;
    this.oBtnDown.height = iBlockSize;
    this.oSlider.height = this.iSliderLength;
    
    this.iTotal = iTotalHeight - (2 * iBlockSize) - this.iSliderLength;
}

//
//  Enables the scrollbar (by setting the CSS styles)
//
JScrollBar.prototype.enable = function(){
    this.oBtnUp.className = this.sCssBtnUp;
    this.oSlider.className = this.sCssSlider;
    this.oBtnDown.className = this.sCssBtnDown;
    this.oSpaceBefore.className = this.sCssFillerBars;
    this.oSpaceAfter.className = this.sCssFillerBars;
}

//  
//  Disables the scrollbar (by setting the CSS styles)
//
JScrollBar.prototype.disable = function(){   
    this.oBtnUp.className = this.sCssBtnUp + "Disabled";
    this.oSlider.className = this.sCssSlider + "Disabled";
    this.oBtnDown.className = this.sCssBtnDown + "Disabled";
    this.oSpaceBefore.className = this.sCssFillerBars + "Disabled";
    this.oSpaceAfter.className = this.sCssFillerBars + "Disabled";
}  

//
//  Function:
//      JScrollBar.onSliderMouseDown
//
//  Description:
//      Handles the mousedown event of the slider cell. Initializes the drag of the 
//      slider. Attaches the events and sets the start variables. 
//
//  PRIVATE
JScrollBar.prototype.onSliderMouseDown = function(e){
    var oDiv;
    
    var oScroll = JScrollBar_FetchScroll(e);
    
    if (oScroll.oSlider.className == oScroll.sCssSlider + "Disabled") return false;
    
    if(!oScroll)
        return false;
    
    oScroll.oSlider.className = "sliderPress";
    oScroll.iSliderDiff = browser.events.getMouseY(e) - browser.gui.getAbsoluteOffsetTop(oScroll.oSlider);
    oScroll.iOrigValue = oScroll.iValue;
    oScroll.bDrag = true;
    
    document.oCurrentJScroll = oScroll;

    browser.events.addGenericListener('selectstart', document, browser.events.stop);
    browser.events.addGenericListener('mouseup', document, oScroll.onSliderMouseUp);
    browser.events.addGenericListener('mousemove', document, oScroll.onMouseMove);        
    
    //    Kill the event to prevent object selection
    browser.events.stop(e);
}


//
//  Function:
//      JScrollBar.onMouseMove
//
//  Description:
//      Handles the mousemove event of the document object when draaging the slider.
//      Calculates the scrollbar value according to the mouse position and sets the
//      slider (actually the height of the filling fields above and below it) to
//      according possition.
//
//  PRIVATE
JScrollBar.prototype.onMouseMove = function(e){
    var iPixelY, iTotal;
    
    var oScroll = document.oCurrentJScroll;
    if(!oScroll)
        return false;
        
    if(oScroll.bDrag){
    
        iPixelY =  browser.events.getMouseY(e) - browser.gui.getAbsoluteOffsetTop(oScroll.oTable) - oScroll.iSliderDiff - oScroll.iBlockSize;
        if(iPixelY <= 0){
            iPixelY = 1;
        }
        if(iPixelY >= oScroll.iTotal){
            iPixelY = oScroll.iTotal - 1;
        }

        oScroll.iValue = iPixelY;
        
        oScroll.oSpaceBefore.style.height = iPixelY + "px";
        oScroll.oSpaceAfter.style.height = (oScroll.iTotal - iPixelY) + "px";
       
        //    Kill the event to prevent object selection        
        browser.events.stop(e);
    }
}


//
//  Function:
//      JScrollBar.onSliderMouseUp
//
//  Description:
//      Handles the document mouseup when dragging the slider. Stops the dragging 
//      and clears the event listeners.
//
//  PRIVATE
JScrollBar.prototype.onSliderMouseUp = function(e){
    var oDiv;
    
    var oScroll = document.oCurrentJScroll;
    if(!oScroll)
        return false;
    
    if(oScroll.bDrag){    
        
        oScroll.oSlider.className = "slider";
        browser.events.removeGenericListener('mouseup', document, oScroll.onSliderMouseUp);
        browser.events.removeGenericListener('mousemove', document, oScroll.onMouseMove);
        browser.events.removeGenericListener('selectstart', document, browser.events.stop);
        
        oScroll.bDrag = false;
    
        oScroll.scrolled();
        
        //    Kill the event to prevent object selection
        browser.events.stop(e);
    }
}


//
//  Function:
//      JScrollBar.scrolled
//
//  Description:
//      Called when the slider is dragged. Calls the onscroll function with the 
//      correct iScroll value.
//
//  PRIVATE
JScrollBar.prototype.scrolled = function(){
    var iScroll, iValue, iOrigValue;

    iValue = this.iValue;
    iOrigValue = this.iOrigValue;
    
    if(iValue < 4 && !(iValue > iOrigValue)){
        iScroll = JScrollBar_Top
    }else if(iValue > (this.iTotal - 4) && !(iValue < iOrigValue)){
        iScroll = JScrollBar_Bottom;
    }else if(iValue > iOrigValue){
        iScroll = JScrollBar_Down;
    }else if(iValue < iOrigValue){
        iScroll = JScrollBar_Up;
    }else{
        iScroll = 0;
    }
    
    this.onScroll(iScroll);
}


//
//  Handles the mousedown event of the up button. Starts an timed loop by 
//  calling an interal method using the setTimeOut method. Can be stopped by 
//  clearing the tScrollUpTimeout property.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JScrollBar.prototype.onBtnUpStart = function(e){
    var fScrollUp, oScroll = JScrollBar_FetchScroll(e);
    
    if (oScroll.oBtnUp.className == oScroll.sCssBtnUp + "Disabled") return false;
    
    //  Create timout method
    fScrollUp = function(){
        oScroll.onScroll(JScrollBar_StepUp);
        oScroll.tScrollUpTimeout = setTimeout(fScrollUp, oScroll.iAutoScrollWait);
    }
    
    //  Set style, scroll step and set timeout
    oScroll.oBtnUp.className = oScroll.sCssBtnUp + "Press";
    oScroll.onScroll(JScrollBar_StepUp);
    oScroll.tScrollUpTimeout = setTimeout(fScrollUp, oScroll.iAutoScrollStart);
}

//
//  Stops scrolling down by clearing the timout.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JScrollBar.prototype.onBtnUpStop = function(e){
    var oScroll = JScrollBar_FetchScroll(e);
    
    if (oScroll.oBtnUp.className == oScroll.sCssBtnUp + "Disabled") return false;
    
    if(oScroll.tScrollUpTimeout != null){
        oScroll.oBtnUp.className = oScroll.sCssBtnUp;
        clearTimeout(oScroll.tScrollUpTimeout);
        oScroll.tScrollUpTimeout = null;
    }
}

//
//  Handles the mousedown event of the down button. Starts an timed loop by 
//  calling an interal method using the setTimeOut method. Can be stopped by 
//  clearing the tScrollUpTimeout property.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JScrollBar.prototype.onBtnDownStart = function(e){
    var fScrollDown, oScroll = JScrollBar_FetchScroll(e);
    
    if (oScroll.oBtnDown.className == oScroll.sCssBtnDown + "Disabled") return false;
    
    //  Create timout method
    fScrollDown = function(){
        oScroll.onScroll(JScrollBar_StepDown);
        oScroll.tScrollDownTimeout = setTimeout(fScrollDown, oScroll.iAutoScrollWait);
    }
    
    //  Set style, scroll step and set timeout
    oScroll.oBtnDown.className = oScroll.sCssBtnDown + "Press";
    oScroll.onScroll(JScrollBar_StepDown);
    oScroll.tScrollDownTimeout = setTimeout(fScrollDown, oScroll.iAutoScrollStart);
}

//
//  Stops scrolling up by clearing the timout.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JScrollBar.prototype.onBtnDownStop = function(e){  
    
    var oScroll = JScrollBar_FetchScroll(e);
    
    if (oScroll.oBtnDown.className == oScroll.sCssBtnDown + "Disabled") return false;
    
    if(oScroll.tScrollDownTimeout != null){
        oScroll.oBtnDown.className = oScroll.sCssBtnDown;
        clearTimeout(oScroll.tScrollDownTimeout);
        oScroll.tScrollDownTimeout = null;
    }
}

//
//  Handles the click event of the up button when bAutoScroll is false.
//
//  PRIVATE
JScrollBar.prototype.onBtnUpClick = function(e){
    var oScroll = JScrollBar_FetchScroll(e);
    
    if (oScroll.oBtnUp.className == oScroll.sCssBtnUp + "Disabled") return false;

    oScroll.onScroll(JScrollBar_StepUp);
    
    browser.events.stop(e);
}


//
//  Handles the click event of the down button when bAutoScroll is false.
//
//  PRIVATE
JScrollBar.prototype.onBtnDownClick = function(e){
    var oScroll = JScrollBar_FetchScroll(e);
    
    if (oScroll.oBtnDown.className == oScroll.sCssBtnDown + "Disabled") return false;
    
    oScroll.onScroll(JScrollBar_StepDown);
    
    browser.events.stop(e);
}

//
//  Function:
//      JScrollBar.center
//
//  Description:
//      Centers the scrollbar slider
//
JScrollBar.prototype.center = function(){
    this.oSpaceBefore.style.height = (this.iTotal / 2) + "px";
    this.oSpaceAfter.style.height = (this.iTotal / 2) + "px";
    this.iValue = this.iTotal / 2;
}


//
//  Function:
//      JScrollBar.scrollBottom
//
//  Description:
//      Sets the slider to the bottom of the scrollbar
//
JScrollBar.prototype.scrollBottom = function(){
    this.oSpaceBefore.style.height = (this.iTotal - 1) + "px";
    this.oSpaceAfter.style.height = "1px";
    this.iValue = this.iTotal - 1;
}


//
//  Function:
//      JScrollBar.scrollTop
//
//  Description:
//      Sets the slider to the top of the scrollbar
//
JScrollBar.prototype.scrollTop = function(){
    this.oSpaceBefore.style.height = "1px";
    this.oSpaceAfter.style.height = (this.iTotal - 1) + "px";
    this.iValue = 1;
}


//
//  Function:
//      JScrollBar.onSpaceBeforeClick
//
//  Description:
//      Catches the onclick event of the space above the scrollbar. It 
//      generates the same event as by dragging the slider downwards.
//  Parameters:
//      e                               Event object (on some browsers)
//
//  PRIVATE
JScrollBar.prototype.onSpaceBeforeClick = function(e){
    var oScroll = JScrollBar_FetchScroll(e);
 
    if (oScroll.oSlider.className == oScroll.sCssSlider + "Disabled") return false;
    oScroll.onScroll(JScrollBar_Up);
    
    browser.events.stop(e); 
}


//
//  Function:
//      JScrollBar.onSpaceBeforeClick
//
//  Description:
//      Catches the onclick event of the space below the scrollbar. It 
//      generates the same event as by dragging the slider a upwards.
//  Parameters:
//      e                               Event object (on some browsers)
//
//  PRIVATE
JScrollBar.prototype.onSpaceAfterClick = function(e){
    var oScroll = JScrollBar_FetchScroll(e);
    
    if (oScroll.oSlider.className == oScroll.sCssSlider + "Disabled") return false; 
    oScroll.onScroll(JScrollBar_Down);
    
    browser.events.stop(e); 
}


//
//  Function:
//      JScrollBar_FetchScroll
//
//  Description:
//      Fetches the java scrollbar object from the underlying table.
//
//  PRIVATE
function JScrollBar_FetchScroll(e){
    var oSource, oTable, oScroll;
    
    oSource = browser.events.getTarget(e);
    if(oSource == null)
        return false;
    
    oTable = browser.dom.searchParent(oSource, 'table');
    if(oTable == null)
        return false;
    
    oScroll = oTable.oJScroll;
    if(oScroll == null)
        return false;
        
    return oScroll;
}

//    
//  Function:
//      JScrollBar.onScroll
//
//  Description:
//      Called when there is scrolled! Should be overridden by the the outer world!!
//
JScrollBar.prototype.onScroll = function(iScroll){

}