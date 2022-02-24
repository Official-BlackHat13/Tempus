/*
Name:
    vdf.deo.Grid
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
vdf.deo.Grid = function Grid(eElement, oParentControl){
    this.List(eElement, oParentControl);

    /*
    If true the grid will be able to hold the focus. Defaults to false because 
    the fields in the grid are usually already able to have the focus.
    */
    this.bHoldFocus         = this.getVdfAttribute("bHoldFocus", false);
    /*
    If true the grid will take the focus. Defaults to false because the fields 
    inside the grid already have this functionallity.
    */
    this.bFocus             = this.getVdfAttribute("bFocus", false);
    /*
    If true the grid will always display an empty row at the end which can be 
    used to add a new record.
    */
    this.bDisplayNewRow     = this.getVdfAttribute("bDisplayNewRow", true);
    /*
    If true the grid tries to save the row if it is changed and it lozes the 
    focus or a different row is selected.
    */
    this.bAutoSaveState     = this.getVdfAttribute("bAutoSaveState", true);
    /*
    If true the column width is locked after initialization. Usually this isn't 
    nesecary with grids because the fields do make sure the the column width 
    is correct.
    */
    this.bFixedColumnWidth  = this.getVdfAttribute("bFixedColumnWidth", false);
    /*
    The CSS class that is set to the edit row of the grid.
    */
    this.sCssRowEdit        = this.getVdfAttribute("sCssRowEdit", "rowedit");
    
    /*
    Fired if the grid lozes the focus.
    */
    this.onBlur = new vdf.events.JSHandler();
    /*
    Fired if the grid receives the focus.
    */
    this.onFocus = new vdf.events.JSHandler();
    /*
    Fires before the grid tries to save a row. If stopped the save is cancelled.
    */
    this.onConfirmSave = new vdf.events.JSHandler();
    /*
    Fires before the grid tries to clear a row to its orrigional values. If 
    stopped the clear is cancelled.
    */
    this.onConfirmClear = new vdf.events.JSHandler();
    
    //  @privates
    this.aFields = [];
    
    this.bSaveAction = false;
    this.oSaveInitiator = null;
    this.oSaveFinished = null;
    
    this.eEditRow = null;
    
    this.bHasFocus = false;
    this.bDetectBlur = true;
    this.bDetermineBlur = false;
    this.bSkipAutoSave = false;
    
};
/*
Extends the List with the ability to edit the values of the selected row. 
*/
vdf.definePrototype("vdf.deo.Grid", "vdf.core.List", {

/*
@private
*/
initializeComponents : function(){
    var iField, eHiddenAnchor;
    
    // Initialization of the edit fields
    for(iField = 0; iField < this.aFields.length; iField++){
        if(typeof(this.aFields[iField].formInit) == "function"){
            this.aFields[iField].formInit();
        }
    }
    
    //  Call super
    this.List.prototype.initializeComponents.call(this);
    
    //  Add key listeners
    for(iField = 0; iField < this.aFields.length; iField++){
        this.aFields[iField].addKeyListener(this.onKey, this);
        this.aFields[iField].addDomListener("focus", this.onFieldFocus, this);
    }
    
    //  Attach events that are going to determine the global grid blur event
    if(vdf.sys.isMoz){  //  Mozilla doesn't bubble focus & blur events and hasn't got a FocusIn or FocusOut
        vdf.events.addDomCaptureListener("blur", this.eElement, this.onTableBlur, this);
        vdf.events.addDomCaptureListener("focus", document, this.onCaptureWinFocus, this);
    }else if(window.addEventListener){ // Other browsers with W3C event system have DOMFocusIn & DOMFocusOut that bbuble
        vdf.events.addDomListener("DOMFocusIn", document, this.onWinFocus, this);
        vdf.events.addDomListener("DOMFocusIn", this.eElement, this.onTableFocus, this);
        vdf.events.addDomListener("DOMFocusOut", this.eElement, this.onTableBlur, this);
    }else{ // IE bubbles focusin and focusout
        vdf.events.addDomListener("focusin", document, this.onWinFocus, this);
        vdf.events.addDomListener("focusin", this.eElement, this.onTableFocus, this);
        vdf.events.addDomListener("focusout", this.eElement, this.onTableBlur, this);
    }
    
    if(this.aFields.length > 0){
        eHiddenAnchor = document.createElement("a");
        eHiddenAnchor.href = "javascript: vdf.sys.nothing();";
        eHiddenAnchor.style.textDecoration = "none";
        eHiddenAnchor.hideFocus = true;
        eHiddenAnchor.innerHTML = "&nbsp;";
        eHiddenAnchor.style.position = "absolute";
        eHiddenAnchor.style.left = "-3000px";
        
        //vdf.sys.dom.insertAfter(eHiddenAnchor, this.eElement);
        
        this.aFields[this.aFields.length - 1].insertElementAfter(eHiddenAnchor);
        vdf.events.addDomListener("focus", eHiddenAnchor, this.onHiddenAnchorFocus, this);
    }
    
    
    //  Add onclear listener to create our own clear functionallity
    this.oServerDD.onBeforeClear.addListener(this.onServerBeforeClear, this);
    
    //  Set classname
    this.eEditRow.className = this.sCssRowEdit;
},

// - - - - - - - - - - - BLUR / FOCUS DETECTION - - - - - - - - - - - 

/*
If a blur is bubbled / captured on the table we remember this for possible 
focus events.

@param  oEvent  The event object.
@private
*/
onTableBlur : function(oEvent){
    if(this.bDetectBlur){
        this.bDetermineBlur = true;
    }
},

/*
The mozilla window focus is fetched here and we try to to determine if the 
target is part of the grid (if not the focus left the grid so we execute the 
blur) by searching the parent elements for the table element. We set 
bDetermineBlur to false before executing the blur to prevent looping.

@param  oEvent  The event object.
@private
*/
onCaptureWinFocus : function(oEvent){
    var eElement = oEvent.getTarget();
    
    if(this.bDetectBlur && this.bDetermineBlur && !vdf.sys.dom.isParent(eElement, this.eElement)){
        this.bDetermineBlur = false;
        this.doBlur();
    }
    
    this.bDetermineBlur = false;
},

/*
If a focus bubbles to the window and bDetermineBlur is (still) true we know
that an element outside the grid has received the focus so the grid has lost 
it. It executes the blur functionallity after bDetermineBlur is set to false to 
prevent looping.

@param  oEvent  The event object.
@private
*/
onWinFocus : function(oEvent){
    if(this.bDetectBlur && this.bDetermineBlur){
        this.bDetermineBlur = false;
        this.doBlur();
    }
    this.bDetermineBlur = false;
},

/*
If focus bubbles to the table we know that the focus is still in the grid and 
we set bDetermineBlur to false so onWinFocus won't execute the grids blur 
functionallity.

@param  oEvent  The event object.
@private
*/
onTableFocus : function(oEvent){
    this.bDetermineBlur = false;
},

/*
Handles the field focus event and calls doFocus if the grid wasn't having the 
focus already.

@param  oEvent  Event object.
@private
*/
onFieldFocus : function(oEvent){
    if(!this.bHasFocus){
        this.doFocus();
    }
},

/*
Sets the bHasFocus property to true and fires the onFocus event.

@private
*/
doFocus : function(){
    this.bHasFocus = true;
    
    //  Set focussed style
    if(this.eElement.tBodies[0].className.match("focussed") === null){
        this.eElement.tBodies[0].className += " focussed";
    }
    
    this.onFocus.fire(this);
},


/*
Determines wether we should save and fires the onBlur event.
@private
*/
doBlur : function(){
    this.bHasFocus = false;
    
    //  Remove focussed style
    this.eElement.tBodies[0].className = this.eElement.tBodies[0].className.replace("focussed", "");
    
    this.onBlur.fire(this);

    if(!this.bSkipAutoSave){
        return this.determineSave();
    }
    this.bSkipAutoSave = false;
},

// - - - - - - - - - - - CORE FUNCTIONALLITY - - - - - - - - - - - 

/*
Augments the select function with the editrow functionallity.

@param  tRow        Structure representing the row to select.
@param  fFinished   (optional) Function that is called after the select action is 
                finished.
@param  oEnvir      (optional) Environment used when calling fFinished.
*/
select : function(tRow, fFinished, oEnvir){
    var oField, fFunction;
    
    //  Tempolary disable the blur detection.
    this.bDetectBlur = false;
    
    this.eEditRow.className = this.sCssRowEdit + " " + (tRow.__eDisplayRow.className.match(this.sCssRowEven) !== null ? this.sCssRowEven : this.sCssRowOdd);

    vdf.sys.dom.swapNodes(tRow.__eRow, this.eEditRow);
    tRow.__eRow = this.eEditRow;
    
    //  TODO: Think about optimizing by setting the buffer row values to the fields here...
    
    oField = this.oForm.oActiveField;
    fFunction = function(){
        oField.focus();
    };
    
    
    //  Give the focus back to the field
    for(var iField = 0; iField < this.aFields.length; iField++){
        if(oField === this.aFields[iField]){
            oField.focus();
            setTimeout(fFunction, 20);
            break;
        }
    }    
    
    this.List.prototype.select.call(this, tRow, fFinished, oEnvir);
    
    this.bDetectBlur = true;
},

/*
Handles the onBefore clear of the server DD. If something else initiated the 
clear we perform our own clear and cancel the DD clear.

@param  oEvent  Event object.
@private
*/
onServerBeforeClear : function(oEvent){
    if(oEvent.oInitiator !== this ){
        if(this.isDataChanged()){
            if(this.confirmClear()){
                this.select(this.tSelectedRow);
            }
        }
        
        oEvent.stop();
    }
},

/*
Checks if the user has changed the data of the grid.

@return True if the current row / record is supposed to be changed.
*/
isDataChanged : function(){
    return this.oServerDD.isChanged((this.tSelectedRow === this.tNewRecord ? null : this.tSelectedRow), true);
},

/*
Augments the deselect function with with the autosave check and the editrow 
functionallity.

@return True if the row succesfully deselected.
*/
deSelect : function(){
    
    //  Check if save should be performed
    if(this.bSaveAction && this.determineSave()){
        return false;
    }else{
        //  Replace the editrow with the orrigional row
        this.bDetectBlur = false;
        
        vdf.sys.dom.swapNodes(this.eEditRow, this.tSelectedRow.__eDisplayRow);
        this.tSelectedRow.__eRow = this.tSelectedRow.__eDisplayRow;
    
        this.List.prototype.deSelect.call(this);
    
        this.bDetectBlur = true;
        return true;
    }
},

/*
Handles the focus event of the hidden anchor. If the grid already had the focus 
it moves the selection one row down. If not it gives the focus to the last 
focusable field of the grid.

@param  oEvent  Event object.
@private
*/
onHiddenAnchorFocus : function(oEvent){
    var iField, oAction;
    
    if(this.bHasFocus){
        //  Give first focusable field the focus
        for(iField = 0; iField < this.aFields.length; iField++){
            if(this.aFields[iField].bFocusable){
                this.aFields[iField].focus();
                this.oForm.oActiveField = this.aFields[iField];
                break;
            }
        }
        
        //  If the newrow is selected we need to save and the scrolldown because scrolldown doesn't perform a save if it cancels
        if(this.tSelectedRow === this.tNewRecord){
            oAction = new vdf.core.Action("save", this.oForm, this, this.oServerDD, true);
            oAction.onFinished.addListener(function(oEvent){
                this.scrollDown();
            }, this);
            this.oServerDD.doSave(oAction);
        }else{
            this.scrollDown();
        }
    }else{
        //  Forward focus to the last (focusable) field
        for(iField = this.aFields.length - 1; iField >= 0; iField--){
            if(this.aFields[iField].bFocusable){
                this.aFields[iField].focus();
                break;
            }
        }
    }
},

// - - - - - - - - - - - AUTOSAVE - - - - - - - - - - - 

/*
Stores the reference to the action function and the arguments and sets 
bSaveAction to true. Then it calls the action function which will usually call 
the deSelect function that checks if a save should be done because bSaveAction 
is true and can call the action function again if the save completed 
succesfully.

@param  fSaveAction     Reference to the action function (like scrollUp).
@param  aSaveArguments  The arguments array with the argumetents for calling the 
            action function.
@return The result of the action function.
@private
*/
saveAction : function(fSaveAction, aSaveArguments){
    var result;
    
    this.bSaveAction = true;
    this.oSaveInitator = { fAction : fSaveAction, aArguments : aSaveArguments };

    result = fSaveAction.apply(this, aSaveArguments);
    
    this.bSaveAction = false;
    return result;
},

/*
@private
*/
scrollUp : function(){
    return this.saveAction(this.List.prototype.scrollUp, arguments);
},

/*
@private
*/
scrollDown : function(){
    return this.saveAction(this.List.prototype.scrollDown, arguments);
},

/*
@private
*/
scrollTop : function(){
    return this.saveAction(this.List.prototype.scrollTop, arguments);
},

/*
@private
*/
scrollBottom : function(){
    return this.saveAction(this.List.prototype.scrollBottom, arguments);
},

/*
@private
*/
scrollPageUp : function(){
    return this.saveAction(this.List.prototype.scrollPageUp, arguments);
},

/*
@private
*/
scrollPageDown : function(){
    return this.saveAction(this.List.prototype.scrollPageDown, arguments);
},

/*
@private
*/
scrollToRow : function(){
    return this.saveAction(this.List.prototype.scrollToRow, arguments);
},

/*
@private
*/
scrollToRowID : function(){
    return this.saveAction(this.List.prototype.scrollToRowID, arguments);
},

/*
@private
*/
determineSave : function(){
    var oAction;

    if(this.bAutoSaveState && this.isDataChanged()){
        if(this.confirmSave()){
            this.bDetectBlur = false;
            if(this.bSaveAction){
                this.oSaveFinished = this.oSaveInitator;
            }else{
                this.oSaveFinished = null;
            }
            
            oAction = new vdf.core.Action("save", this.oForm, this, this.oServerDD, true);
            oAction.onFinished.addListener(this.onAfterSave, this);
            this.oServerDD.doSave(oAction);
            
            return true;
        }
    }
    
    return false;
    
},

/*
@private
*/
onAfterSave : function(oEvent){
    if(!oEvent.bError){
        if(this.oSaveFinished !== null){
            this.oSaveFinished.fAction.apply(this, this.oSaveFinished.aArguments);
        }
    }
    this.bDetectBlur = true;
},

/*
@private
*/
confirmSave : function(){
    var bResult = false;
    
    this.bDetectBlur = false;
    bResult = this.onConfirmSave.fire(this);
    this.bDetectBlur = true;
    
    return bResult;
},

/*
Gives the developer a chance to display his own "Abandon changes?" message by 
firing the onConfirmClear event.

@return True if the onConfirmClear event was not cancelled.
@private
*/
confirmClear : function(){
    var bResult = false;
    
    this.bDetectBlur = false;
    bResult = this.onConfirmClear.fire(this);
    this.bDetectBlur = true;
    
    return bResult;
},

/*
Is called when a field is added to the list. If it is a header or display 
field it is added to the administration after initialisation.

@param  eRow        Dom row element in which field is located.
@param  sRowType    Type of the row ("display"/"header").
@param  oField      The Field to initialize.
@return True if the field should be forwarded to the form.
     
@private
*/
checkField : function(eRow, sRowType, oField){
    if(sRowType === "edit"){
        if(this.eEditRow === null){
            this.eEditRow = eRow;
        }
        
        this.aFields.push(oField);
        
        return true;
    }else{
        return this.List.prototype.checkField.call(this, eRow, sRowType, oField);
    }
}


});