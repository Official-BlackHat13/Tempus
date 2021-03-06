/*
 * Visual DataFlex AJAX Library 2.3
 * Copyright(c) 2011, Data Access Worldwide.
 */







var vdf = {

//  GLOBALS

sVersion : "2.3.5.16",

LT    : "LT",//0,

LE    : "LE",//1,

EQ    : "EQ",//2,

GE    : "GE",//3,

GT    : "GT",//4,

FIRST : "FIRST_RECORD", //6,

LAST  : "LAST_RECORD",//7,

//  NAMESPACES

deo : {},

ajax : {},

core : {},

gui : {


aZReservations : [true],


reserveZIndex : function(){
    return this.aZReservations.push(true) - 1;
},


freeZIndex : function(iIndex){
    var iRes;

    this.aZReservations[iIndex] = false;

    for(iRes = this.aZReservations.length - 1; iRes >= 0; iRes--){
        if(!this.aZReservations[iRes]){
            this.aZReservations.pop();
        }else{
            break;
        }
    }
}

},


oControls : {},

oForms : {},


onControlCreated : null,


onLibraryLoaded : null,


onLoad : null,


aDependingCode : [],



getControl : function(sName){
    if(typeof(vdf.oControls[sName.toLowerCase()]) !== "undefined"){
        return vdf.oControls[sName.toLowerCase()];
    }else{
        return null;
    }
},


getForm : function(sName){
    if(typeof(vdf.oForms[sName.toLowerCase()]) !== "undefined"){
        return vdf.oForms[sName.toLowerCase()];
    }else{
        return null;
    }
},


isAvailable : function(sLib){
    var aSteps, oCurrent, iStep;

    //  Split library into roadmap
    aSteps = sLib.split(".");

    //  Check if name can be a valid library
    // if(aSteps.length < 2 || aSteps[0] != "vdf"){
        // throw new vdf.errors.Error(142, "Invalid library", null, [sLib]);
    // }

    //  Loop through object structure looking for the library
    oCurrent = window;
    for(iStep = 0; iStep < aSteps.length; iStep++){
        oCurrent = oCurrent[aSteps[iStep]];

        if(typeof(oCurrent) === "undefined"){
            return false;
        }
    }

    return true;
},



require : function(sLib, fWaiting){
    var aSteps, oCurrent, bResult = true, sCurrent, iStep;

    if(arguments.length < 2 || typeof fWaiting !== "function"){
        return;
    }
    
    
    
//    try{

        //  Split library into roadmap
        aSteps = sLib.split(".");

        //  Check if name can be a valid library
        if(aSteps.length < 2 || aSteps[0] != "vdf"){
            throw new vdf.errors.Error(5130, "Invalid library", null, [sLib]);
        }

        //  Loop through object structure looking for the library
        oCurrent = vdf;
        sCurrent = "vdf";
        for(iStep = 1; iStep < aSteps.length; iStep++){
            sCurrent += "." + aSteps[iStep];

            if(typeof(oCurrent) != "undefined"){
                oCurrent = oCurrent[aSteps[iStep]];
            }

            if(typeof(oCurrent) == "undefined"){
                bResult = false;
            }
        }
//    }catch(oError){
//        vdf.err.handle(oError);
//    }

    //  If a waiting function is given we call it now or we queue it..
    if(typeof fWaiting === "function"){
        if(bResult){
            fWaiting(sLib);
        }else{
            vdf.aDependingCode.push({ sLibrary : sLib, fFunction : fWaiting});
        }
    }

    return bResult;
},


determineLoadScript : function(){
    var aScripts, iScript;

    aScripts = document.getElementsByTagName("script");
    for(iScript = 0; iScript < aScripts.length; iScript++){
        if(aScripts[iScript].src){
            if(aScripts[iScript].src.match(/vdf\/library(-.*)*\.js(\?[a-zA-Z0-9]+=[a-zA-Z0-9%]*(&[a-zA-Z0-9]+=[a-zA-Z0-9%]*)*)?$/)){
                return aScripts[iScript];
            }
        }
    }
    return null;
},


determineLoadUrl : function(){
    var eScript = vdf.determineLoadScript();
    
    if(eScript){
        return eScript.src;
    }
    return null;
},


getUrlParameter : function(sName){
    var sUrl, aPairs, iPair, sParams;

    sUrl = vdf.determineLoadUrl();
    if(sUrl.indexOf("?") >= 0){
        sParams = sUrl.substr(sUrl.indexOf("?") + 1);

        aPairs = sParams.split("&");

        for(iPair = 0; iPair < aPairs.length; iPair++){
            if(aPairs[iPair].substr(0, sName.length).toLowerCase() === sName.toLowerCase()){
                if(aPairs[iPair].indexOf("=") >= 0){
                    return aPairs[iPair].substr(aPairs[iPair].indexOf("=") + 1).replace("%20", " ");
                }
            }
        }
    }

    return null;
},


register : function(sLib){
    var iWait;

    //  Fire the onLibraryLoaded event
    if(vdf.onLibraryLoaded !== null){
        vdf.onLibraryLoaded.fire(vdf, { sLibrary : sLib });
    }

    iWait = 0;
    for(iWait = 0; iWait < vdf.aDependingCode.length; iWait++){
        if(vdf.aDependingCode[iWait].sLibrary.toLowerCase() === sLib.toLowerCase()){
            try{
                vdf.aDependingCode[iWait].fFunction(sLib);
            }catch(e){
                vdf.errors.handle(e);
            }

            vdf.aDependingCode.splice(iWait, 1);
            iWait--;
        }

    }
},



aIncludeJSQueue : [],

iIncludeJSRunning : 0,

iMaxConcurrentIncludes : 4,


includeJS : function(sUrl){
    this.aIncludeJSQueue.push(sUrl);
    this.doIncludeJS();
},


doIncludeJS : function(){
    var eLoadScript, eScript, aScripts, iScript, sUrl, eHead;

    //  Determine if a script should be loaded
    while(vdf.iIncludeJSRunning < vdf.iMaxConcurrentIncludes && vdf.aIncludeJSQueue.length > 0){
        sUrl = vdf.aIncludeJSQueue.shift();

        //  Check if it isn't already loaded
        aScripts = document.getElementsByTagName("script");
        for(iScript = 0; iScript < aScripts.length; iScript++){
            if(aScripts[iScript].src === sUrl){
                this.doIncludeJS();
                return;
            }
        }

        //  If we are running IE we can't manipulate the DOM before it is fully initialized so we use document.write. But if the library.js is already "completed" the environment is "wrong" so then we wait..
        if(document.readyState === "uninitialized" || document.readyState === "loading" || document.readyState === "loaded" || document.readyState === "interactive"){
            eLoadScript = vdf.determineLoadScript();

            if(eLoadScript.readyState === "complete"){
                this.aIncludeJSQueue.unshift(sUrl);
                document.onreadystatechange = function(){
                    vdf.doIncludeJS();
                };
                return;
            }else{
                document.write('<script type="text/javascript" src="' + sUrl + '"></script>');
            }
        }else{
            eHead = document.getElementsByTagName('head').item(0);
            vdf.iIncludeJSRunning++;
            eScript = document.createElement('script');
            eScript.type = 'text/javascript';
            eScript.src = sUrl;
            
            //  IE fires the onreadystatechange event after a script is loaded
            eScript.onreadystatechange = function(){
                if (eScript.readyState === "complete" || eScript.readyState === "loaded") {
                    //  Update the counters and include next
                    vdf.iIncludeJSRunning--;
                    vdf.doIncludeJS();

                    //  Clear memory
                    eScript.onreadystatechange = null;
                    eScript.onload = null;
                }
            };

            //  Other browsers fire the onload event after a script is loaded
            eScript.onload = function(){
                    //  Update the counters and include next
                    vdf.iIncludeJSRunning--;
                    vdf.doIncludeJS();

                    //  Clear memory
                    eScript.onreadystatechange = null;
                    eScript.onload = null;
            };
            eHead.appendChild(eScript);
        }
    }
},



definePrototype : function(constructor, sSuper, oProto){
    var fConstructor, fSuper, oPrototype, fTemp, sProp;

    //  Constructor can be given as string or as reference
    if(typeof(constructor) == "string"){
        if(vdf.sys){
            fConstructor = vdf.sys.ref.getNestedObjProperty(constructor);
        }else{
            fConstructor = eval(constructor);
        }
    }else{
        fConstructor = constructor;
    }

    //  Three parameters means the second points to prototype to extend
    if(arguments.length > 2){ // Three or more parameters means a Prototype to extend is given
        oPrototype = arguments[arguments.length - 1];


        //  The inherited constructor can be given by name in string
        if(typeof(arguments[1]) == "string"){
            //  If the constructor is inside the vdf. we check if it is loaded
            if(arguments[1].substr(0,4) == "vdf."){
                if(!vdf.isAvailable(arguments[1])){

                    alert("Super prototype for '" + constructor + "' must be defined first ('" + arguments[1] + "')");
                    return;
                }
            }

            //  Get a reference to the constructor using eval
            if(vdf.sys){
                fSuper = vdf.sys.ref.getNestedObjProperty(arguments[1]);
            }else{
                fSuper = eval(arguments[1]);
            }
        }else{
            //  The reference can also be given directly
            fSuper = arguments[1];
        }

        //  The third parameter is the prototype object
        oPrototype = arguments[2];

        //  Do the inheritance thing
        fTemp = function(){};
        fTemp.prototype = fSuper.prototype;
        fConstructor.prototype = new fTemp();

        //  Copy in the new methods
        for(sProp in oPrototype){
            if(oPrototype.hasOwnProperty(sProp)){
                fConstructor.prototype[sProp] = oPrototype[sProp];
            }
        }

        //fConstructor.prototype[vdf.sys.ref.getMethodName(fSuper)] = fSuper;
        var sSuperName = fSuper.toString();
        sSuperName = sSuperName.substring(sSuperName.indexOf("function") + 8, sSuperName.indexOf('(')).replace(/ /g,'');
        fConstructor.prototype[sSuperName] = fSuper;
    }if(arguments.length == 2){
        oPrototype = arguments[1];

        fConstructor.prototype = oPrototype;
    }

    fConstructor.prototype.constructor = fConstructor;

    //  If the constructor is given as string and is inside the vdf. object automatically register it.
    if(typeof(constructor) == "string" && constructor.substr(0,4) == "vdf."){
        vdf.register(constructor);
    }
},



getDOMAttribute : function(eElement, sProperty, sDefault){
    var sResult;

    sProperty = "vdf" + sProperty.substr(1);
    sResult = eElement.getAttribute(sProperty);

    if(sResult === null){
        sResult = sDefault;
    }

    if(typeof(sResult) == "string"){
        if(sResult.toLowerCase() == "true"){
            sResult = true;
        }else if(sResult.toLowerCase() == "false"){
            sResult = false;
        }
    }

    return sResult;
},


setDOMAttribute : function(eElement, sProperty, sValue){
    sProperty = "vdf" + sProperty.substr(1);
    eElement.setAttribute(sProperty, sValue);
},


lastTime : new Date().getTime(),

aLog : [],


log : function(sLog){
    var currentTime, time;

    currentTime = new Date().getTime();
    time = (currentTime - this.lastTime) / 1000;
    this.lastTime = currentTime;
    sLog = "" + currentTime + " : " + time + " : " + sLog;

    vdf.aLog.push(sLog);
    
    try{
        console.log(sLog);
    }catch(e){
    
    }
}

};

//  If events library is loaded we create the global events
vdf.require("vdf.events", function(){

    vdf.onLibraryLoaded = new vdf.events.JSHandler();

    vdf.onControlCreated = new vdf.events.JSHandler();

    vdf.onLoad = new vdf.events.JSHandler();
    
});



//  Register the base library
vdf.register("vdf");




vdf.dataStructs = {


TAjaxError : function TAjaxError(){
    this.iNumber = null;
    this.iLine = null;
    this.sTableName = null;
    this.sColumnName = null;
    this.sErrorText = null;
},

//
// A C T I O N   R E Q U E S T S
//


TAjaxUserData : function TAjaxUserData(){
    this.sName = null;
    this.sValue = "";
},


TAjaxField : function TAjaxField(){
    this.__isField = true;
    this.sBinding = null;   //  Expression or <field>.<value>
    this.sType = "D";       //  "D" for database field "E" for expression "R" for rowid
    this.sValue = "";     //  Current value for the field
    this.bChanged = false;  //  True if the value is changed
},


TAjaxDD : function TAjaxDD(){
    this.sName = null;
    this.tStatus = null;
    this.bLight = false;
    this.aFields = [];
},


TAjaxSnapShot : function TAjaxSnapShot(){
    this.aDDs = [];
},

//  RESPONSE DATA


TAjaxResponseSet : function TAjaxResponseSet(){
    this.sName = null;
    this.sResponseType = null;
    this.sResponseValue = null;
    
    this.sTable = null;
    this.sColumn = null;
    this.iRows = null;
    this.bFound = null;
    this.aRows = [];
    this.aUserData = [];
},


TAjaxResponseData : function TAjaxResponseData(){
    this.aDataSets = [];
    this.aUserData = [];
    this.aErrors = [];
},

//  REQUEST DATA

TAjaxRequestSet : function TAjaxRequestSet(){
    this.sName = null;
    this.sRequestType = null;
    
    this.sMethod = null;
    this.asParams = [];

    this.iMaxRows = 1;
    this.sTable = null;
    this.sColumn = null;
    this.sIndex = null;
    this.sFindMode = null;
    this.sFindValue = null;
    this.bReturnCurrent = false;
    this.bLoadStatus = true;

    this.aRows = [];
    this.aUserData = [];
},


TAjaxRequestData : function TAjaxRequestData(){
    this.sSessionKey = null;
    this.sWebObject = null;
    this.aDataSets = [];
    this.aUserData = [];
},

//  FIELD VALIDATION


TAjaxValidationRequest : function TAjaxValidationRequest(){
    this.sSessionKey = null;
    this.sWebObject = null;
    this.sFieldName = null;
    this.tRow = null;
},


TAjaxValidationResponse : function TAjaxValidationResponse(){
    this.sFieldName = null;
    this.sFieldValue = null;
    this.iError = null;
    this.aErrors = null;
},


//
// M E T A   D A T A
//


TAjaxMetaDD : function TAjaxMetaDD(){
    // Structure contains information about a table and an array with column information.
    this.sName = null;
    this.sDriverName = null;
    this.aServers = [];
    this.sConstrainFile = null;
    this.bValidate_Foreign_File_State = null;
},


TAjaxMetaWO : function TAjaxMetaWO(){
    this.sName = null;
    this.sDateMask = null;
    this.sDecimalSeparator = null;
    this.iDate4_State = null;
    this.iEpoch = null;

    this.aDDs = [];
    this.aErrors = [];
},


TAjaxMetaField : function TAjaxMetaField(){
    this.sName = null;
    this.sTable = null;

    this.bAutoFind = null;
    this.bAutoFindGE = null;
    this.bCapsLock = null;
    this.bDisplayOnly = null;
    this.bFindReq = null;
    this.bNoEnter = null;
    this.bNoPut = null;
    this.bRequired = null;
    this.bSkipFound = null;
    this.bZeroSuppress = null;
    this.bForeign_AutoFind = null;
    this.bForeign_AutoFindGE = null;
    this.bForeign_DisplayOnly = null;
    this.bForeign_FindReq = null;
    this.bForeign_NoEnter = null;
    this.bForeign_NoPut = null;
    this.bForeign_SkipFound = null;
    this.bValidateServer = null;

    this.iDataLength = null;
    this.iIndex = null;
    this.iPrecision = null;
    this.sCheck = null;
    this.sDataType = null;
    this.sDefaultValue = null;
    this.sMaskType = null;
    this.sMask = null;
    this.sMaxValue = null;
    this.sMinValue = null;
    this.sChecked = null;
    this.sUnchecked = null;
    this.sShortLabel = null;
    this.sStatusHelp = null;
},


TAjaxMetaFields : function TAjaxMetaFields(){
    this.aFields = [];
    this.aErrors = [];
},


TAjaxMetaProperty : function TAjaxMetaProperty(){
    this.sProperty = null;
    this.sValue = null;
},


TAjaxMetaPropField : function TAjaxMetaPropField(){
    this.sTable = null;
    this.sField = null;
    this.aProperties = [];
},


TAjaxMetaProperties : function TAjaxMetaProperties(){
    this.aFields = [];
    this.aErrors = [];
},


TAjaxDescriptionValue : function TAjaxDescriptionValue(){
    this.sValue = null;
    this.sDescription = null;
},


TAjaxMetaDescriptionValues : function TAjaxMetaDescriptionValues(){
    this.sTable = null;
    this.sField = null;
    this.aValues = [];
    this.aErrors = [];
},

//
// R E M O T E   M E T H O D   I N V O C A T I O N
//

TAjaxRMIResponse : function TAjaxRMIResponse(){
    this.sReturnValue = null;
    this.aErrors = [];
},

//
// A J A X   T R E E   V I E W
//
TAjaxTreeNode : function TAjaxTreeNode(){
	this.sName = null;
	this.sAltText = null;
    
    this.sId = null;
    this.sValue = null;
    this.sIconClass = null;
    this.sParentId = null;
    this.bExpanded = false;
    this.bHasChildren = false;
    
    this.__aSubItems = [];
    this.__tParent = null;
    this.__eElement = null;
    this.__eSubMenuRow = null;
    this.__eSubMenuTable = null;
    this.__fSelectHandler = null;
    this.__oSelectEnv = null;
    
    this.__bChildrenLoaded = false;
    this.__bIsLoading = false;
}

};
vdf.register("vdf.dataStructs");




vdf.events = {


KEY_CODE_TAB : 9,


KEY_CODE_NON_EDIT : {37:1, 38:1, 39:1, 40:1, 35:1, 36:1, 9:1},


KEY_CODE_SPECIAL : {37:1, 38:1, 39:1, 40:1, 35:1, 36:1, 46:1, 8:1, 9:1},
//  37, 38, 39, 40 cursor keys
//  35  end
//  36  home
//  46  delete
//  8   backspace
//  9   tab


addDomCaptureListener : function(sEvent, eElement, fListener, oEnvironment){
    //  Attach the listener
    if(window.addEventListener){ // W3C
        sEvent = "capture_" + sEvent;
    }
    
    this.addDomListener(sEvent, eElement, fListener, oEnvironment);
},


removeDomCaptureListener : function(sEvent, eElement, fListener){
    //  Attach the listener
    if(window.addEventListener){ // W3C
        sEvent = "capture_" + sEvent;
    }
    
    this.removeDomListener(sEvent, eElement, fListener);
},


addDomListener : function(sEvent, eElement, fListener, oEnvironment){
    var oDOMHandler;
    
    //  Find or create DOM Handler
    if(typeof(eElement._oDOMHandlers) === "undefined" || typeof(eElement._oDOMHandlers[sEvent]) === "undefined"){
        oDOMHandler = new vdf.events.DOMHandler(sEvent, eElement);
    }else{
        oDOMHandler = eElement._oDOMHandlers[sEvent];
    }
    
    //  Add listener to handler
    oDOMHandler.addListener(fListener, oEnvironment);
},



removeDomListener : function(sEvent, eElement, fListener){
    //  Find handler and call remove method
    if(typeof(eElement._oDOMHandlers) !== "undefined" && typeof(eElement._oDOMHandlers[sEvent]) !== "undefined"){
        eElement._oDOMHandlers[sEvent].removeListener(fListener);
    }
},



addDomKeyListener : function(eElement, fListener, oEnvironment){
    // if(window.addEventListener){ // W3C
        // vdf.events.addDomListener("keypress", eElement, fListener, oEnvironment);
    // }else{ // IE
        vdf.events.addDomListener("keydown", eElement, fListener, oEnvironment);
    // }
},



removeDomKeyListener : function(eElement, fListener){
    if(window.addEventListener){ // W3C
        vdf.events.removeDomListener("keypress", eElement, fListener);
    }else{ // IE
        vdf.events.removeDomListener("keydown", eElement, fListener);
    }
},



addDomMouseWheelListener : function(eElement, fListener, oEnvironment){
    if(vdf.sys.isMoz){ //   Mozilla
        vdf.events.addDomListener("DOMMouseScroll", eElement, fListener, oEnvironment);
    }else{ // IE, WebKit
        vdf.events.addDomListener("mousewheel", eElement, fListener, oEnvironment);
    }
},



removeDomMouseWheelListener : function(eElement, fListener){
    if(vdf.sys.isMoz){  //  Mozilla
        vdf.events.removeDomListener("DOMMouseScroll", eElement, fListener);
    }else{ // IE, WebKit
        vdf.events.removeDomListener("mousewheel", eElement, fListener);
    }
},


stop : function(oEvent){
    oEvent.stop();
},



iDOMHandlers : 0,

oDOMHandlers : {},



clearDomHandlers : function(){
    var iHandlerId;
    
    for(iHandlerId in vdf.events.oDOMHandlers){
        if(vdf.events.oDOMHandlers[iHandlerId].__DOMHandler){
            vdf.events.oDOMHandlers[iHandlerId].clear();
        }
    }
},


clearDomListeners : function(eElement, bRecursive){
    var sEvent;
    
    //  Loop through DOM handlers and remove them
    if(eElement._oDOMHandlers){
        for(sEvent in  eElement._oDOMHandlers){
            if(eElement._oDOMHandlers.hasOwnProperty(sEvent)){
                eElement._oDOMHandlers[sEvent].clear();
            }
        }
    }
    
    //  Move into children
    if(bRecursive){
        vdf.sys.dom.loopChildren(eElement, function(eChild){
            vdf.events.clearDomListeners(eChild, true);
        });
    }
}
};





vdf.events.DOMHandler = function DOMHandler(sEvent, eElement){
    //  @privates
    this.sEvent = sEvent;
    this.eElement = eElement;
    
    
    this.aListeners = [];
    this.aRemoveListeners = [];
    this.bFiring = false;
    this.fHandler = null;
    this.__DOMHandler = true;
    
    this.iHandlerId = vdf.events.iDOMHandlers;
    vdf.events.iDOMHandlers++;
    
    this.attach();
};

vdf.definePrototype("vdf.events.DOMHandler", {


attach : function(){
    var oDOMHandler, fHandler;
    oDOMHandler = this;

    //  Create inline method that calls the handling method with the correct environment
    fHandler = function(e){
        return oDOMHandler.fire.call(oDOMHandler, e);
    };
    
    //  Attach the listener
    if(window.addEventListener){ // W3C
        if(this.sEvent.substr(0, 8) === "capture_"){
            this.eElement.addEventListener(this.sEvent.substr(8), fHandler, true);
        }else{
            this.eElement.addEventListener(this.sEvent, fHandler, false);
        }
    }else{ // IE
        this.eElement.attachEvent("on" + this.sEvent, fHandler);
    }
    
    //  Register the handler on the element
    if(!this.eElement._oDOMHandlers){
        this.eElement._oDOMHandlers = { };
    }
    this.eElement._oDOMHandlers[this.sEvent] = this;
    
    //  Register the handler globally
    vdf.events.oDOMHandlers[this.iHandlerId] = this;
    
    this.fHandler = fHandler;
},



clear : function(){
    //vdf.log("Clearing '" + this.sEvent + "' of element '" + this.eElement.tagName + "'");

    //  Deattach the listener
    if(window.addEventListener){
        this.eElement.removeEventListener(this.sEvent, this.fHandler, false);
    }else{
        this.eElement.detachEvent("on" + this.sEvent, this.fHandler);
    }
    
    //  Unregister the handler on the element
    delete this.eElement._oDOMHandlers[this.sEvent];
    
    //  Unregister the global handler
    delete vdf.events.oDOMHandlers[this.iHandlerId];
},



addListener : function(fListener, oEnvironment){
    if(typeof(fListener) !== "function"){
        throw new vdf.errors.Error(5131, "Listener must be a function", this, [ this.sEvent ]);
    }

    this.aListeners.push({ "fListener" : fListener, "oEnvironment" : oEnvironment });
},



removeListener : function(fListener){
    var iListener;
    
    for(iListener = 0; iListener < this.aListeners.length; iListener++){
    
        if(this.aListeners[iListener].fListener == fListener){
            if(this.bFiring){
                this.aListeners[iListener].fListener = null;
            
                this.aRemoveListeners.push(fListener);
            }else{
                if(this.aListeners.length > 1){
                    this.aListeners.splice(iListener, 1);
                }else{
                    this.clear();
                }
            }
            
            break;
        }
    }
},



fire : function(e){
    var iListener, oEvent;
    
    //  Create event object
    oEvent = new vdf.events.DOMEvent(e, this.eElement, this.sEvent);
    
    //  Lock
    this.bFiring = true;
    
    //  Call the listeners
    for(iListener = 0; iListener < this.aListeners.length && !oEvent.bCanceled; iListener++){
        if(typeof(this.aListeners[iListener].fListener) === "function"){
            try{
                if(this.aListeners[iListener].fListener.call((typeof(this.aListeners[iListener].oEnvironment) !== "undefined" ? this.aListeners[iListener].oEnvironment : this.eElement), oEvent) === false){
                    oEvent.stop();
                }
            }catch (oError){
                vdf.errors.handle(oError);
            }
        }
    }
    
    //  Unlock
    this.bFiring = false;
    
    //  Remove the listeners that where placed for removal during the event execution.
    while(this.aRemoveListeners.length > 0){
        this.removeListener(this.aRemoveListeners.pop());
    }
    
    //  If the event is canceled we do anything we can to stop the event!
    if (oEvent.bCanceled){
        // necessary for addEventListener, works with traditional
        if(e.preventDefault){
            e.preventDefault();
        }
        // necessary for attachEvent, works with traditional
        e.returnValue = false; 
        
        // works with traditional, not with attachEvent or addEventListener
        return false; 
    }else{
        return true;
    }
}

});




vdf.events.DOMEvent = function DOMEvent(e, eSource, sName){
    
    this.eSource = eSource;
    
    if(!e){
        this.e = window.event;
    }else{
        this.e = e;
    }
    
    this.sName = sName;
    
    // @privates
    this.bCanceled = false;
};

vdf.definePrototype("vdf.events.DOMEvent", {



getTarget : function(){
    var eTarget;
    
    if (this.e.target){
        eTarget = this.e.target; // W3C
    }else if (this.e.srcElement){
        eTarget = this.e.srcElement;    // IE
    }
    
    if (eTarget.nodeType == 3){
        eTarget = eTarget.parentNode; // Safari bug
    }
    
    return eTarget;
},



getMouseX : function(){
    return this.e.clientX;
},



getMouseY : function(){
    return this.e.clientY;
},



getKeyCode : function(){
//    if(this.e.keyCode){
        return this.e.keyCode;  // IE
//    }else{
//        return this.e.which; // W3C
//    }
},


isSpecialKey : function(){
    var iKeyCode = this.getKeyCode();
    
    //  IE and webkit browsers do not fire keypress events for special keys
    if((vdf.sys.isIE || vdf.sys.isSafari) && this.e.type === "keypress"){
        return false;
    }
    
    return (this.getAltKey() || this.getCtrlKey() || (iKeyCode !== 0 && vdf.events.KEY_CODE_SPECIAL[iKeyCode]));
},


getCharCode : function(){
    if(this.e.charCode){
        return this.e.charCode;
    }else if(this.e.which){
        return this.e.which;
    }else{
        return this.e.keyCode;
    }
},


getCtrlKey : function(){
    return this.e.ctrlKey;
},


getShiftKey : function(){
    return this.e.shiftKey;
},


getAltKey : function(){
    return this.e.altKey;
},


getMouseButton : function(){
    if(this.e.which){ // W3C
        switch(this.e.which){
            case 0:
                return 1;
            case 1:
                return 4;
            case 2:
                return 2;
            default:
                return 0;
        }
    }else{ // IE
        return this.e.button;
    }    
},



getMouseWheelDelta : function(){
    var iDelta = 0;
    
    if(this.e.detail){ 
        //  Mozilla has multiple of 3 as detail
        iDelta = -this.e.detail/3;
    }else if(this.e.wheelDelta){ // IE / Opera
        iDelta = this.e.wheelDelta / 120;
    } 

    return iDelta;
},



stop : function(){
    this.bCanceled = true;
    this.e.returnValue = false;
    this.e.cancelBubble = true;
    this.e.canceled = true;

    if(this.e.preventDefault){
        this.e.preventDefault();
    }
    if(this.e.stopPropagation){
        this.e.stopPropagation();
    }
    
    if(vdf.sys.isIE && this.sName.indexOf("key") >= 0){
        this.e.keyCode = 0;
    }
}

});



vdf.events.addDomListener("unload", window, vdf.events.clearDomHandlers);



vdf.events.JSHandler = function JSHandler(){
    // @privates
    this.aListeners = [];
    
    this.aRemoveListeners = [];
    this.bFiring = false;
};

vdf.definePrototype("vdf.events.JSHandler", {


addListener : function(fListener, oEnvironment){
    if(typeof(fListener) !== "function"){
        throw new vdf.errors.Error(5131, "Listener must be a function", this, [ this.sEvent ]);
    }
    
    this.aListeners.push({ "fListener" : fListener, "oEnvironment" : oEnvironment });
},



removeListener : function(fListener){
    var iListener;
    
    for(iListener = 0; iListener < this.aListeners.length; iListener++){
        if(this.aListeners[iListener].fListener == fListener){
            if(this.bFiring){
                this.aListeners[iListener].fListener = null;
            
                this.aRemoveListeners.push(fListener);
            }else{
                this.aListeners.splice(iListener, 1);
            }
        }
    }
},


fire : function(oSource, oOptions){
    if (this.aListeners.length > 0){
        var iListener, oEvent = new vdf.events.JSEvent(oSource, oOptions);

        //  Lock
        this.bFiring = true;
        
        //  Call the listeners
        for(iListener = 0; iListener < this.aListeners.length && !oEvent.bCanceled; iListener++){
            if(typeof(this.aListeners[iListener].fListener) === "function"){
                try{
                    if(this.aListeners[iListener].fListener.call((typeof(this.aListeners[iListener].oEnvironment) !== "undefined" ? this.aListeners[iListener].oEnvironment : this.eElement), oEvent) === false){
                        oEvent.stop();
                    }
                }catch (oError){
                    vdf.errors.handle(oError);
                }
            }
        }
        
        //  Unlock
        this.bFiring = false;
        
        //  Remove the listeners that where placed for removal during the event execution.
        while(this.aRemoveListeners.length > 0){
            this.removeListener(this.aRemoveListeners.pop());
        }
    
        return !oEvent.bCanceled;
    }
    
    
    
    return true;
}

});



vdf.events.JSEvent = function JSEvent(oSource, oOptions){
    var sProp;
    
    
    this.oSource = oSource;
    
    //  @privates
    this.bCanceled = false;
    
    if(typeof(oOptions) == "object"){
        for(sProp in oOptions){
            if(oOptions.hasOwnProperty(sProp)){
                this[sProp] = oOptions[sProp];
            }
        }
    }
};

vdf.definePrototype("vdf.events.JSEvent", {


getTarget : function(){
    return this.oSource;
},



stop : function(){
    this.bCanceled = true;
}

});

vdf.register("vdf.events");






vdf.errors = {


sCSS : "fieldError",


handle : function(oError){
    var bHandle = true, oField, bFieldError;
    
    //  Forward unknown errors (throw them again)
    if(typeof(oError.message) !== "undefined" || typeof(oError.description) !== "undefined"){
        bHandle = false;
        throw oError;
    }
    
    oField = oError.oField;
    bFieldError =(oField && oField.bIsDEO ? true : false);
        
    if(vdf.errors.onError.fire(oError.oSource || null, { oError : oError, bFieldError : bFieldError })){
        
        //  Field errors are displayed a bit different by default ;)
        if(bFieldError){
            if(!oField.oErrorDisplay){
                oField.oErrorDisplay = new vdf.errors.FieldErrorDisplay(oField);
            }
            
            oField.oErrorDisplay.addError(oError);
        }else{
            oError.display();
        }
    }
},



clear : function(iErrorNr, oField){
    if(oField.oErrorDisplay){
        oField.oErrorDisplay.clearByNr(iErrorNr);
    }
},



clearByField : function(oField){
    if(oField.oErrorDisplay){
        oField.oErrorDisplay.clearAll();
    }
},


checkServerError : function(aArray, oSource){
    var i;
    
    for(i = 0; i < aArray.length; i++){
        this.handle(this.createServerError(aArray[i], oSource || null));
    }
    
    return (aArray.length === 0);
},



createServerError : function(tErrorInfo, oSource){
    var oForm, oField;
    
    if(tErrorInfo.sColumnName !== "" && tErrorInfo.sTableName !== "" && vdf.isAvailable("vdf.core.Form")){
        if(oSource){
            if(oSource.bIsForm){
                oForm = oSource;
            }else if(typeof oSource.getForm === "function"){
                oForm = oSource.getForm();
            }else if(oSource.oForm){
                oForm = oSource.oForm;
            }else if(oSource.eElement){
                oForm = vdf.core.findForm(oSource.eElement);
            }
        }
        
        if(oForm && oForm.bIsForm){
            oField = oForm.getDEO(tErrorInfo.sTableName + "." + tErrorInfo.sColumnName);
            
            if(oField){
                return new vdf.errors.FieldError(tErrorInfo.iNumber, tErrorInfo.sErrorText, oField, null, true);
            }
        }
    }
   
    return new vdf.errors.Error(tErrorInfo.iNumber, tErrorInfo.sErrorText, oSource || null, null, null, true);
}

};
vdf.require("vdf.events.JSHandler", function(){
    
    vdf.errors.onError = new vdf.events.JSHandler();
});

vdf.register("vdf.errors");




vdf.errors.Error = function Error(iErrorNr, sLocalDescription, oSource, aReplacements, sDetails, bServer){
    
    this.iErrorNr = iErrorNr;
    
    this.oSource = oSource || null;
    
    this.sDetails = sDetails || null;
    
    
    this.bServerError = bServer || false;
    
    this.sLocalDescription = sLocalDescription;
    
    //  Load description from translations
    if(iErrorNr > 0){
        
        this.sDescription = vdf.lang.getTranslation("error", iErrorNr, sLocalDescription, aReplacements);
    }else{
        
        this.sDescription = sLocalDescription;
    }
	
    if(aReplacements){
        this.sDescription = vdf.sys.data.format(this.sDescription, aReplacements);
    }
	
};

vdf.definePrototype("vdf.errors.Error", {


display : function(){
	if(vdf.isAvailable("vdf.gui.ModalDialog")){
		if(!this.sDetails){
			var aHTML = [], oSrc = this.oSource;
			
            aHTML.push(
                "<b>Error location:</b> ", (this.bServerError ? "Server" : "Client"), "<br/>",
				"<b>Error number:</b> ", this.iErrorNr, "<br/>",
				"<b>Error description:</b> ", this.sDescription, "<br/>"
            );
            if(this.sLocalDescription !== this.sDescription){
                aHTML.push("<b>Local description:</b> ", this.sLocalDescription, "<br/>");
            }
            aHTML.push("<br/>");

			this.sDetails = aHTML.join("");
			
			if(typeof(oSrc.debugDetails) === "function"){
				this.sDetails += oSrc.debugDetails(this);
			}else if(oSrc){
				aHTML = [
					"<b>Object type:</b> ", vdf.sys.ref.getType(oSrc), "<br/>"
				];
				
				if(oSrc.sName){
					aHTML.push("<b>Object name:</b> ", oSrc.sName, "<br/>");
				}
				
				this.sDetails += aHTML.join("");
			}
		}
	
        vdf.gui.alert(this.sDescription, vdf.sys.data.format(vdf.lang.getTranslation("error", (this.bServerError ? "titleServer" : "title"), "Error {{0}} occurred"), [ this.iErrorNr ]), this.sDetails);
    }else{
        alert(this.sDescription);
    }
},


clear : function(){

}

});


vdf.errors.FieldErrorDisplay = function FieldErrorDisplay(oField){
    this.oField = oField;
    this.aErrors = [];
    
    // @privates
    this.oBalloon = null;
    this.eBtnSpan = null;
    this.eBalloonElem = null;
    this.sOrigCSS = null;
};

vdf.definePrototype("vdf.errors.FieldErrorDisplay", {


clearAll : function(){
    this.aErrors = [];
    this.update();
},


clearByNr : function(iErrorNr){
    var iErr;
    
    for(iErr = 0; iErr < this.aErrors.length; iErr++){
        if(this.aErrors[iErr].iErrorNr === iErrorNr){
            this.aErrors.splice(iErr, 1);
            break;
        }
    }
    
    this.update();
},


addError : function(oError){
    var iErr, bAdd = true;
    
    for(iErr = 0; iErr < this.aErrors.length; iErr++){
        if(this.aErrors[iErr].iErrorNr === oError.iErrorNr){
            bAdd = false;
            break;
        }
    }
    
    if(bAdd){
        this.aErrors.unshift(oError);
    }
    
    this.update();
},


display : function(){
    var eBtnSpan, oBalloon;
    
    if(this.oField.bDisplayErrorIcon){
        //  Generate error thingy
        eBtnSpan = document.createElement("span");
        eBtnSpan.innerHTML = "&nbsp;";
        eBtnSpan.className = "fieldErrorIcon";
        this.oField.insertElementAfter(eBtnSpan);
        this.eBtnSpan = eBtnSpan;
        this.eBalloonElem = eBtnSpan;
    }else{
        this.eBtnSpan = null;
        this.eBalloonElem = this.oField.eElement;
    }
    
    //  Update CSS
    this.sOrigCSS = this.oField.getCSSClass();
    if(this.sOrigCSS.indexOf(vdf.errors.sCSS) < 0){
        if(this.sOrigCSS !== ""){
            this.oField.setCSSClass(this.sOrigCSS + " " + vdf.errors.sCSS);
        }else{
            this.oField.setCSSClass(vdf.errors.sCSS);
        }
    }else{
        this.sOrigCSS = null;
    }
    
    //  Make sure the correct tabs are displayed to display the error
    this.displayTabs();
    
    //  Generate balloon control
    oBalloon = new vdf.gui.Balloon(this.eBalloonElem, this.oField.oParentControl);
    oBalloon.sContent = this.generateText();
    oBalloon.bDisplay = true; 
    oBalloon.bAttachHover = true;
    if(this.oField.bDisplayErrorIcon){
        oBalloon.bAttachClick = true;
    }else{
        oBalloon.bAttachClick = false;
        oBalloon.sAlignHoriz = "left";
    }
    oBalloon.init();
    this.oBalloon = oBalloon;
    
    vdf.core.init.registerControl(oBalloon, "vdf.gui.Balloon");
    
    
},


update : function(){
    if(this.oBalloon){
        if(this.aErrors.length > 0){
            this.oBalloon.setContent(this.generateText());
            this.displayTabs();
            this.oBalloon.display();
        }else{
            this.remove();
        }
    }else{
        if(this.aErrors.length > 0){
            this.display();
        }
    }
},


displayTabs : function(){
    //  Make sure that it is displayed (even if it is on another tab)
    if(this.eBtnSpan){
        if(vdf.isAvailable("vdf.gui.TabContainer")){
            vdf.gui.displayTabsWithElement(this.eBtnSpan);
        }
    }
},


generateText : function(){
    var iErr, sResult = "";
    
    for(iErr = 0; iErr < this.aErrors.length; iErr++){
        sResult +=  (iErr > 0 ? "<br/>" : "") + '<span class="fieldErrorText">' + this.aErrors[iErr].sDescription + '</span>';
    }
    
    return sResult;
},


remove : function(){
    if(this.oBalloon){
        vdf.core.init.destroyControl(this.oBalloon);
        this.oBalloon = null;
        
        if(this.eBtnSpan){
            this.eBtnSpan.parentNode.removeChild(this.eBtnSpan);
            this.eBtnSpan = null;
        }
        
        if(this.sOrigCSS){
            this.oField.setCSSClass(this.sOrigCSS);
        }
    }
}

});




vdf.errors.FieldError = function FieldError(iErrorNr, sLocalDescription, oField, aReplacements, bServer){
    this.Error(iErrorNr, sLocalDescription, oField.oController, aReplacements);
    
    
    this.oField = oField;
    
    this.bServerError = bServer || false;
    
    // @privates
    this.eBtnSpan = null;
    this.oBalloon = null;
    this.sOrigCSS = null;
};

vdf.definePrototype("vdf.errors.FieldError", "vdf.errors.Error", {


display : function(){
    var sPrefix;
    
 
    sPrefix = ' (field: "' + this.oField.sDataBinding + '")';
    if(this.sDescription.substr(this.sDescription.length - sPrefix.length) !== sPrefix){
        this.sDescription += sPrefix;
    }
    //  Call super display
    this.Error.prototype.display.call(this);
},


clear : function(){
    //  Call super clear
    this.Error.prototype.clear.call(this);
}

});



vdf.lang = {

translations : null,


getTranslation : function(sCategory, sLabel, sDefault){
    var oCat, sTrans, iRep;
    
    //  Search category
    if(vdf.lang.translations){
        oCat = vdf.lang.translations[sCategory];
        if(typeof(oCat) !== "undefined"){
            //  Search translation
            sTrans = oCat[sLabel];
            if(typeof(sTrans) !== "undefined"){
                //  Return result
                return sTrans;
            }
        }
    }else{
        alert("No language loaded!");
    }
    
    //  Return default
    if(typeof(sDefault) == "undefined"){
        return "[ " + sCategory + " : " + sLabel + " ]";
    }else{
        return sDefault;
    }
},


loadLanguage : function(sLanguage){
    if(vdf.lang["translations_" + sLanguage.toLowerCase()]){
        vdf.lang.translations = vdf.lang["translations_" + sLanguage.toLowerCase()];
    }else{
        vdf.require("vdf.lang.translations_" + sLanguage.toLowerCase(), function(){
            vdf.lang.translations = vdf.lang["translations_" + sLanguage.toLowerCase()];
        });
    }
}

};

if(vdf.getUrlParameter("language")){
    vdf.lang.loadLanguage(vdf.getUrlParameter("language"));
}else{
    vdf.lang.loadLanguage("en");
}

vdf.register("vdf.lang");





vdf.core.Control = function Control(eElement, oParentControl){
    
    this.eElement = eElement;
    
    this.oParentControl = oParentControl;
    
    this.oForm = null;
    
    this.sName = this.determineName();
	
	// @privates
	this.bIsControl = true;
	
    //  Init DOM reference
    if(this.eElement && !this.eElement.oVdfControl){
        this.eElement.oVdfControl = this;
    }
};

vdf.definePrototype("vdf.core.Control",{

getAttribute : function(sName){
    return this.eElement.getAttribute(sName);
},


setAttribute : function(sName, sValue){
    this.eElement.setAttribute(sName, sValue);
},


setCSSClass : function(sNewClass){
    this.eElement.className = sNewClass;
},


getCSSClass : function(){
    return this.eElement.className;
},


disable : function(){
    this.bFocusable = false;
    this.eElement.disabled = true;
},


enable : function(){
    this.bFocusable = true;
    this.eElement.disabled = false;
},


addDomListener : function(sEvent, fListener, oEnvironment){
    vdf.events.addDomListener(sEvent, this.eElement, fListener, oEnvironment);
},


removeDomListener : function(sEvent, fListener){
    vdf.events.removeDomListener(sEvent, this.eElement, fListener);
},


addKeyListener : function(fListener, oEnvironment){
    vdf.events.addDomKeyListener(this.eElement, fListener, oEnvironment);
},


removeKeyListener : function(fListener){
    vdf.events.removeDomKeyListener(this.eElement, fListener);
},


insertElementAfter : function(eElement){
    vdf.sys.dom.insertAfter(eElement, this.eElement);
    
    //this.eElement.parentNode.appendChild(eElement);
    
},


getDOMAttribute : function(sName, sDefault){
    if(this.eElement){
        return vdf.getDOMAttribute(this.eElement, sName, sDefault);
    }else{
        return sDefault;
    }
},


setDOMAttribute : function(sName, sValue){
    if(this.eElement){
        vdf.setDOMAttribute(this.eElement, sName, sValue);
    }
},


getVdfAttribute : function(sName, sDefault, bBubble, bProp){
    var sResult = this.getDOMAttribute(sName, null);
    
    if(sResult === null){
        if((bBubble) && this.oParentControl !== null && typeof(this.oParentControl.getVdfAttribute) == "function"){
            sResult = this.oParentControl.getVdfAttribute(sName, sDefault, true);
        }else if((bBubble) && this.oForm !== null && typeof(this.oForm) !== "undefined"){
            sResult = this.oForm.getVdfAttribute(sName, sDefault, true);
        }else{
            sResult = sDefault;
        }
    }
    
    return sResult;
},


determineName : function(){
    var sStartName, sName = null, iCount;

    sName = this.getVdfAttribute("sName");
    if(typeof sName === "string"){
        return sName.toLowerCase();
    }
    sName = this.getVdfAttribute("sControlName");
    if(typeof sName === "string"){
        return sName.toLowerCase();
    }

    if(typeof this.eElement === "object" && this.eElement !== null){
        sName = this.eElement.getAttribute("name");
    }
    if(typeof sName !== "string" || sName === ""){
        sName = vdf.sys.ref.getType(this);
    }

    sName = sName.toLowerCase();

    sStartName = sName;
    iCount = 0;
    while(vdf.oControls.hasOwnProperty(sName)){
        iCount++;
        sName = sStartName + "_" + iCount;
    }

    return sName;
},


debugDetails : function(oErr){
	var aHTML, sSource;
    
    sSource = (this.eElement ? vdf.sys.string.encodeHtml(vdf.sys.dom.getOuterHTML(this.eElement)) : "");
    
    if(sSource.length > 100){
        sSource = sSource.substr(0, 100) + "...";
    }
    
    aHTML = [
		"<b>Control type:</b> ", vdf.sys.ref.getType(this), "<br/>",
		"<b>Control name:</b> ", this.sName, "<br/>",
		"<br />",
		"<b>Control element source:</b><hr />",
		"<pre>", sSource, "</pre>"
	];
	
	return aHTML.join("");
}

});




//  @requireCSS Balloon.css


vdf.gui.Balloon = function(eElement, oParentControl){
    this.Control(eElement, oParentControl);
    
    
    this.sCssClass          = this.getVdfAttribute("sCssClass", "balloon", false);
    
    this.iLeft              = this.getVdfAttribute("iLeft", 0, false);
    
    this.iRight             = this.getVdfAttribute("iRight", 0, false);
    
    this.iWidth             = this.getVdfAttribute("iWidth", 0, false);
    
    this.iTuteOffset        = this.getVdfAttribute("iTuteOffset", 12, false);
    
    this.sContent           = this.getVdfAttribute("sContent", "&nbsp;", false);
    
    
    this.sAlignHoriz        = this.getVdfAttribute("sAlignHoriz", "center", false);
    
    this.iOffsetRight       = this.getVdfAttribute("iOffsetRight", 12, false);
    
    this.iOffsetLeft       = this.getVdfAttribute("iOffsetLeft", 12, false);
    
    this.bDisplay           = this.getVdfAttribute("bDisplay", true, false);
    
    this.bAttachHover       = this.getVdfAttribute("bAttachHover", true, false);
    
    this.bAttachClick       = this.getVdfAttribute("bAttachClick", true, false);
    
    this.iTimeout           = this.getVdfAttribute("iTimeout", 2500, false);
    
    // @privates
    this.tTimeout = null;
    this.eTable = null;
    this.eContent = null;
    this.bDisplayed = false;
    this.bClicked = false;
    
};

vdf.definePrototype("vdf.gui.Balloon", "vdf.core.Control", {


init : function(){
    this.createBalloon();
    this.recalcDisplay(false);
    
    if(this.bDisplay){
        this.display();
    }
},


display : function(bNoTimeout){
    this.recalcDisplay(false);
    this.bDisplayed = true;
    if(this.eTable){
        this.eTable.style.display = "";
    }
    
    if(!(bNoTimeout)){
        this.setTimeout();
    }
},


hide : function(){
    this.clearTimeout();
    this.bDisplayed = false;
    if(this.eTable){
        this.eTable.style.display = "none";
    }
},


setContent : function(sNewContent){
    this.sContent = sNewContent;
    
    if(this.eContent){
        this.eContent.innerHTML = sNewContent;
    }
},


setTimeout : function(){
    var oBalloon = this;
    
    this.clearTimeout();

    this.tTimeout = setTimeout(function(){
        oBalloon.hide();
    }, this.iTimeout);
},


clearTimeout : function(){
    if(this.tTimeout){
        clearTimeout(this.tTimeout);
        this.tTimeout = null;
    }
},


createBalloon : function(){
    var eTable, eRow, eCell, eContent;

    eTable = document.createElement("table");
    eTable.className = this.sCssClass;
    eTable.cellPadding = 0;
    eTable.cellSpacing = 0;
    eTable.style.display = "none";
    
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


onMouseOver : function(oEvent){
    if(!this.bDisplayed){
        this.display(true);
    }
    this.clearTimeout();
},


onMouseOut : function(oEvent){
    if(!this.bClicked){
        this.setTimeout();
    }
},


calculatePosition : function(){
    this.recalcDisplay(false);
},


recalcDisplay : function(bDown){
    var oOffset, iLeft = this.iLeft || 0, iTop = this.iTop || 0;

    if(this.eElement){
        oOffset = vdf.sys.gui.getAbsoluteOffset(this.eElement);
        if(this.sAlignHoriz === "left"){
            iLeft += oOffset.left + this.iOffsetLeft;
        }else if(this.sAlignHoriz === "right"){
            iLeft += oOffset.left + parseInt(this.eElement.offsetWidth, 10) - this.iOffsetRight;
        }else{
            iLeft += oOffset.left + parseInt((this.eElement.offsetWidth / 2), 10);
        }
        iTop += oOffset.top + parseInt(this.eElement.offsetHeight, 10);
    }
    iLeft = iLeft - this.iTuteOffset;

    this.eTable.style.left = iLeft + "px";
    this.eTable.style.top = iTop + "px";
    
    if(!bDown && this.oParentControl !== null && typeof(this.oParentControl.recalcDisplay) === "function"){
        this.oParentControl.recalcDisplay(bDown);
    }
},


destroy : function(){
    this.clearTimeout();
    
    if(this.eElement){
        //  Do this manually since the element could very well be used otherwise
        vdf.events.removeDomListener("click", this.eElement, this.onClick);
        vdf.events.removeDomListener("mouseover", this.eElement, this.onMouseOver);
        vdf.events.removeDomListener("mouseout", this.eElement, this.onMouseOut);
    }
    if(this.eTable && this.eTable.parentNode){
        this.eTable.parentNode.removeChild(this.eTable);
    }
    this.eContent = null;
    this.eTable = null;
}
    
});





vdf.gui.Calendar = function(eElement, oParentControl){
    var iDay, dToday = new Date();
    
    this.Control(eElement, oParentControl);
    
    
    this.eContainerElement = eElement;
    
    
    this.sCssClass = this.getVdfAttribute("sCssClass", "calendar", false);
    
    
    this.iStartAt = this.getVdfAttribute("iStartAt", 1, false);
        
    this.sDateFormat = this.getVdfAttribute("sDateFormat", "mm/dd/yyyy", true);
    
    this.sDateSeparator = this.getVdfAttribute("sDateSeparator", "/", true);
    
    this.sDateMask = this.getVdfAttribute("sDateMask", this.sDateFormat, true);
    
    
    this.bOutFill = this.getVdfAttribute("bOutFill", true, false);
    
    this.bShowToday = this.getVdfAttribute("bShowToday", true, false);
    
    this.bShowWeekNumber = this.getVdfAttribute("bShowWeekNumber", true, false);
    
    this.bHoldFocus = this.getVdfAttribute("bHoldFocus", true, false);
    
    this.bExternal = this.getVdfAttribute("bExternal", false, false);
    
    this.iYearMenuLength = this.getVdfAttribute("iYearMenuLength", 9, false);
    
    this.iAutoScrollWait = parseInt(this.getVdfAttribute("iAutoScrollWait", 40, false), 10);
    
    this.iAutoScrollStart = parseInt(this.getVdfAttribute("iAutoScrollStart", 400, false), 10);
    
    this.iMenuHideWait = parseInt(this.getVdfAttribute("iMenuHideWait", 1000, false), 10);
    
    
    this.iDate = this.getVdfAttribute("iDate", dToday.getDate(), false);
    
    this.iMonth = this.getVdfAttribute("iMonth", dToday.getMonth(), false);
    
    this.iYear = this.getVdfAttribute("iYear", dToday.getFullYear(), false);
   
    
    this.onChange = new vdf.events.JSHandler();
    
    this.onEnter = new vdf.events.JSHandler();
    
    this.onClose = new vdf.events.JSHandler();

    //  @privates
    this.aMonthNames = [].concat(vdf.lang.getTranslation("calendar", "monthsLong"));
    this.aMonthNamesShort = [].concat(vdf.lang.getTranslation("calendar", "monthsShort"));
    this.aDaysShort = [].concat(vdf.lang.getTranslation("calendar", "daysShort"));
    this.aDaysLong = [].concat(vdf.lang.getTranslation("calendar", "daysLong"));
    this.oActionKeys = vdf.sys.data.deepClone(vdf.settings.calendarKeys);
    
    //  Scroll to the starting day
    for(iDay = 0; iDay < this.iStartAt; iDay++){
        this.aDaysShort.push(this.aDaysShort.shift());
        this.aDaysLong.push(this.aDaysLong.shift());
    }
    
    
    this.tHideMenu = null;
    this.tScrollTimeout = null;
    this.tUpdateTimeout = null;
    
    this.aDayCells = [];
    this.eMainTable = null;
    this.eYearDiv = null;
    this.eYearSpan = null;
    this.eTodaySpan = null;
    this.eMonthDiv = null;
    this.eMonthSpan = null;
    this.eMonthMenu = null;
    this.eYearMenu = null;
    this.eBtnYearUp = null;
    this.eBtnYearDown = null;
    this.eBtnPrev = null;
    this.eBtnNext = null;
    this.eBtnClose = null;
    this.eContentCell = null;    
    
    this.eBodyTable = null;
    this.eSelectedDay = null;
    this.eFocus = null;
    this.bHasFocus = false;
};

vdf.definePrototype("vdf.gui.Calendar", "vdf.core.Control", {


init : function(){
    this.construct();
    this.displayCalendar();
},

//  ENGINE


construct : function(){
    var eTable, eRow, eCell, eBtnPrev, eBtnNext, eMonthSpan, eMonthDiv, eMonthMenu, eLi, eYearSpan, eYearDiv, eYearMenu, eNextSpan, ePrevSpan;
    var iMonth, eBtnYearUp, eBtnYearDown, eTodaySpan, eContentCell, eBtnClose = null, eFocus = null;
     

    eTable = document.createElement("table");
    eTable.cellPadding = 0;
    eTable.cellSpacing = 0;
    eTable.className = this.sCssClass;
    this.eContainerElement.appendChild(eTable);
    
    eRow = eTable.insertRow(0);
    eRow.className = (this.bExternal ? "titlebarextern" : "titlebarintern" );
    
    eCell = eRow.insertCell(0);
    eCell.className = "left";
    
    eCell = eRow.insertCell(1);
    
    //  Previous button
    eBtnPrev = document.createElement("div");
    eBtnPrev.className = "btnprevious";
    ePrevSpan = document.createElement("span");
    eBtnPrev.appendChild(ePrevSpan);
    eCell.appendChild(eBtnPrev);
    vdf.events.addDomListener("click", eBtnPrev, this.onPreviousClick, this);
    
    //  Next button
    eBtnNext = document.createElement("div");
    eBtnNext.className = "btnnext";
    eNextSpan = document.createElement("span");
    eBtnNext.appendChild(eNextSpan);

    eCell.appendChild(eBtnNext);
    vdf.events.addDomListener("click", eBtnNext, this.onNextClick, this);
    
    //  Month picker
    eMonthDiv = document.createElement("div");
    eMonthDiv.className = "btnmonth";
    eCell.appendChild(eMonthDiv);
    
    eMonthSpan = document.createElement("span");
    vdf.sys.dom.setElementText(eMonthSpan, this.aMonthNames[this.iMonth]);
    eMonthDiv.appendChild(eMonthSpan);
    vdf.events.addDomListener("click", eMonthDiv, this.onBtnMonthClick, this);
    
    eMonthMenu = document.createElement("ul");
    for(iMonth = 0; iMonth < 12; iMonth++){
        eLi = document.createElement("li");
        vdf.sys.dom.setElementText(eLi, this.aMonthNames[iMonth]);
        eLi.setAttribute("iMonth", iMonth);
        eMonthMenu.appendChild(eLi);
        vdf.events.addDomListener("click", eLi, this.onMonthClick, this);
    }
    vdf.events.addDomListener("mouseout", eMonthMenu, this.onMonthMenuOut, this);
    vdf.events.addDomListener("mouseover", eMonthMenu, this.onMonthMenuOver, this);
    vdf.events.addDomListener("click", eMonthMenu, this.onSubMenuClick, this);
    eMonthDiv.appendChild(eMonthMenu);
    
    //  Year picker
    eYearDiv = document.createElement("div");
    eYearDiv.className = "btnyear";
    eCell.appendChild(eYearDiv);
    
    eYearSpan = document.createElement("span");
    vdf.sys.dom.setElementText(eYearSpan, this.iYear);
    eYearDiv.appendChild(eYearSpan);
    vdf.events.addDomListener("click", eYearDiv, this.onBtnYearClick, this);
    
    eYearMenu = document.createElement("ul");
    eYearDiv.appendChild(eYearMenu);
    vdf.events.addDomListener("mouseout", eYearMenu, this.onYearMenuOut, this);
    vdf.events.addDomListener("mouseover", eYearMenu, this.onYearMenuOver, this);
    vdf.events.addDomListener("click", eYearMenu, this.onSubMenuClick, this);
    
    eBtnYearUp = document.createElement("li");
    eBtnYearUp.className = "btnyearup";
    eYearMenu.appendChild(eBtnYearUp);
    vdf.events.addDomListener("mousedown", eBtnYearUp, this.onYearBtnUpDown, this);
    vdf.events.addDomListener("mouseup", eBtnYearUp, this.onYearBtnUpStop, this);
    vdf.events.addDomListener("mouseout", eBtnYearUp, this.onYearBtnUpStop, this);
    
    eLi = this.constructYearMenuItem(2009);
    eYearMenu.appendChild(eLi);
    
    eBtnYearDown = document.createElement("li");
    eBtnYearDown.className = "btnyeardown";
    eYearMenu.appendChild(eBtnYearDown);
    vdf.events.addDomListener("mousedown", eBtnYearDown, this.onYearBtnDownDown, this);
    vdf.events.addDomListener("mouseup", eBtnYearDown, this.onYearBtnDownStop, this);
    vdf.events.addDomListener("mouseout", eBtnYearDown, this.onYearBtnDownStop, this);

    //  Close buttn
    if(this.bExternal){
        eBtnClose = document.createElement("div");
        eBtnClose.className = "btnclose";
        eCell.appendChild(eBtnClose);
        vdf.events.addDomListener("click", eBtnClose, this.onBtnClose, this);
    }
    
    eCell = eRow.insertCell(2);
    eCell.className = "right";
    
    
        
    eRow = eTable.insertRow(1);
    eContentCell = eRow.insertCell(0);
    eContentCell.colSpan = 3;
    eContentCell.className = (this.bExternal ? "contentextern" : "contentintern" );
    
    if(this.bShowToday){
        eRow = eTable.insertRow(2);
        eRow.className = (this.bExternal ? "todaybarextern" : "todaybarintern" );
        
        eCell = eRow.insertCell(0);
        eCell.className = "left";
        
        eCell = eRow.insertCell(1);
        vdf.sys.dom.setElementText(eCell, vdf.lang.getTranslation("calendar", "today") + " ");
        
        eTodaySpan = document.createElement("span");
        this.eTodaySpan = eTodaySpan;
        this.updateToday();
        eCell.appendChild(eTodaySpan);
        vdf.events.addDomListener("click", eTodaySpan, this.onTodayClick, this);
        vdf.events.addDomListener("mousedown", eTable, vdf.events.stop);
        
        eCell = eRow.insertCell(2);
        eCell.className = "right";
    }
    
    
    if(this.bHoldFocus){
        eFocus = document.createElement("a");
        eFocus.href = "javascript: vdf.sys.nothing();";
        eFocus.style.textDecoration = "none";
        eFocus.hideFocus = true;
        eFocus.innerHTML = "&nbsp;";
        eFocus.style.position = "absolute";
        eFocus.style.left = "-3000px";
        
        vdf.events.addDomKeyListener(eFocus, this.onKey, this);
        vdf.events.addDomListener("focus", eFocus, this.onFocus, this);
        vdf.events.addDomListener("blur", eFocus, this.onBlur, this);
        
        //  In safari we put the anchor arround the table because it won't get a focus when its not "visible"
        //  TODO: Find a better sollution with less side effects
        // if(vdf.sys.isSafari){
            // this.eContainerElement.insertBefore(eFocus, eTable);
            // eFocus.appendChild(eTable);
        // }else{
            this.eContainerElement.insertBefore(eFocus, eTable);
        // }
        
        this.eFocus = eFocus;
    }
    
    vdf.sys.gui.disableTextSelection(eTable);
    
    this.eMainTable = eTable;
    this.eYearDiv = eYearDiv;
    this.eYearSpan = eYearSpan;
    this.eTodaySpan = eTodaySpan;
    this.eMonthDiv = eMonthDiv;
    this.eMonthSpan = eMonthSpan;
    this.eMonthMenu = eMonthMenu;
    this.eYearMenu = eYearMenu;
    this.eBtnYearUp = eBtnYearUp;
    this.eBtnYearDown = eBtnYearDown;
    this.eBtnPrev = eBtnPrev;
    this.eBtnNext = eBtnNext;
    this.eBtnClose = eBtnClose;
    this.eContentCell = eContentCell;
},


constructYearMenuItem : function(iYear){
    var eLi = document.createElement("li");
    eLi.setAttribute("iYear", iYear);
    if(iYear === this.iYear){
        eLi.className = "current";
    }
    vdf.sys.dom.setElementText(eLi, "" + iYear);
    vdf.events.addDomListener("click", eLi, this.onYearClick, this);
    
    return eLi;
},


updateToday : function(){
    var dToday = new Date();
    
    if(this.bShowToday){
        this.eTodaySpan.setAttribute("iDate", dToday.getDate());
        this.eTodaySpan.setAttribute("iMonth", dToday.getMonth());
        this.eTodaySpan.setAttribute("iYear", dToday.getFullYear());
        vdf.sys.dom.setElementText(this.eTodaySpan, vdf.sys.data.applyDateMask(dToday, this.sDateMask, this.sDateSeparator));
    }
},


displayCalendar : function(){
    var dToday, dEnd, dDate, eTable, eRow, eCell, iDayPointer, iDay;
    var sCSS, iRows, iYear = this.iYear, iMonth = this.iMonth;

    vdf.sys.dom.setElementText(this.eYearSpan, iYear);
    vdf.sys.dom.setElementText(this.eMonthSpan, this.aMonthNames[iMonth]);
    
    //  Generate dates
    dToday = new Date();
    dDate = new Date(iYear, iMonth, 1);
    dEnd = new Date(iYear, (iMonth + 1), 1);

    //    Generate & insert table
    eTable = document.createElement("table");
    eTable.className = "bodytable";
    eTable.cellPadding = 0;
    eTable.cellSpacing = 0;
    
    //  Remove old table & listeners if needed
    if(this.eBodyTable !== null){
        this.eContentCell.removeChild(this.eBodyTable);
        
        for(iDay = 0; iDay < this.aDayCells.length; iDay++){
            vdf.events.removeDomListener("click", this.aDayCells[iDay], this.onDayClick);
        }
        this.aDayCells = [];
    }
    this.eContentCell.appendChild(eTable);
    this.eBodyTable = eTable;
        
    
    //  Header
    eRow = eTable.insertRow(0);
    eRow.className = "header";
    if(this.bShowWeekNumber){
        eCell = eRow.insertCell(0);
        vdf.sys.dom.setElementText(eCell, vdf.lang.getTranslation("calendar", "wk"));
        eCell.className = "weeknumber";
    }
    for(iDay = 0; iDay < 7; iDay++){
        eCell = eRow.insertCell(eRow.cells.length);
        vdf.sys.dom.setElementText(eCell, this.aDaysShort[iDay]);
        
        iDayPointer = (iDay + this.iStartAt > 6 ? iDay + this.iStartAt - 7 : iDay + this.iStartAt);
        if(iDayPointer === 0 || iDayPointer === 6){
            eCell.className = "weekend";
        }
    }
    
    //  Calculate start date
    iDayPointer = dDate.getDay() - this.iStartAt;
    if(iDayPointer < 0){
        iDayPointer = 7 + iDayPointer;
    }
    dDate.setDate(dDate.getDate() - iDayPointer);
    iDayPointer = 0;
    iRows = 0;
    
    //  Loop through the days
    while(dDate < dEnd || (iDayPointer < 7 && iDayPointer !== 0) || (this.bOutFill && iRows < 6)){
        //  Add weeknr & correct daypointere if needed
        if(iDayPointer === 0 || iDayPointer > 6){
            iRows++;
            eRow = eTable.insertRow(eTable.rows.length);
            if(this.bShowWeekNumber){
                eCell = eRow.insertCell(0);
                vdf.sys.dom.setElementText(eCell, this.getWeekNr(dDate));
                eCell.className = "weeknumber";
            }
            iDayPointer = 0;
        }
        
        //  Create cell
        eCell = eRow.insertCell(eRow.cells.length);
        eCell.setAttribute("iDate", dDate.getDate());
        eCell.setAttribute("iMonth", dDate.getMonth());
        eCell.setAttribute("iYear", dDate.getFullYear());
        vdf.sys.dom.setElementText(eCell, dDate.getDate());

        
        //  Determine styles
        sCSS = "day";
        if(dDate.getMonth() !== iMonth){
            sCSS += (sCSS !== "" ? " " : "") + "overflow";
        }
        if(dDate.getDay() === 0|| dDate.getDay() === 6){
            sCSS += (sCSS !== "" ? " " : "") + "weekend";
        }
        if(dDate.getDate() === this.iDate && dDate.getMonth() === this.iMonth && dDate.getFullYear() === this.iYear){
            this.eSelectedDay = eCell;
            sCSS += (sCSS !== "" ? " " : "") + "selected" + (this.bHasFocus ? " focussed" : "");
        }
        if(dDate.getDate() === dToday.getDate() && dDate.getMonth() === dToday.getMonth() && dDate.getFullYear() === dToday.getFullYear()){
            sCSS += (sCSS !== "" ? " " : "") + "today";
        }
        eCell.className = sCSS;
        
        this.aDayCells.push(eCell);
        
        //  Move to the next day
        dDate.setDate(dDate.getDate() + 1);
        iDayPointer++;
    }
    
    vdf.events.addDomListener("click", eTable, this.onDayClick, this);
    
    this.updateSelectedMonth();
},


updateSelectedMonth : function(){
    var iElem;
    
    for(iElem = 0; iElem < this.eMonthMenu.childNodes.length; iElem++){
        if(this.eMonthMenu.childNodes[iElem].getAttribute("iMonth") == this.iMonth){
            this.eMonthMenu.childNodes[iElem].className = "current";
        }else{
            this.eMonthMenu.childNodes[iElem].className = "";
        }
    }
},


scrollYearUp : function(){
    var iYear;

    //  Remove first element
    vdf.events.removeDomListener("click", this.eYearMenu.childNodes[this.eYearMenu.childNodes.length - 2], this.onYearClick);
    this.eYearMenu.removeChild(this.eYearMenu.childNodes[this.eYearMenu.childNodes.length - 2]);
    
    //  Create year item
    iYear = this.eYearMenu.childNodes[1].getAttribute("iYear") - 1;
    this.eYearMenu.insertBefore(this.constructYearMenuItem(iYear), this.eYearMenu.childNodes[1]);
},


scrollYearDown : function(){
    var iYear;

    //  Remove first element
    vdf.events.removeDomListener("click", this.eYearMenu.childNodes[1], this.onYearClick);
    this.eYearMenu.removeChild(this.eYearMenu.childNodes[1]);
    
    //  Create year item
    iYear = parseInt(this.eYearMenu.childNodes[this.eYearMenu.childNodes.length - 2].getAttribute("iYear"), 10) + 1;
    this.eYearMenu.insertBefore(this.constructYearMenuItem(iYear), this.eYearMenu.childNodes[this.eYearMenu.childNodes.length - 1]);
},


destroy : function(){
    if(this.eMainTable){
        vdf.events.clearDomListeners(this.eMainTable, true);
        
        this.eMainTable.parentNode.removeChild(this.eMainTable);
        if(this.bHoldFocus){
            vdf.events.clearDomListeners(this.eFocus);
            this.eFocus.parentNode.removeChild(this.eFocus);
        }
    }

    this.eMainTable = null;
    this.eYearSpan = null;
    this.eYearDiv = null;
    this.eTodaySpan = null;
    this.eMonthSpan = null;
    this.eMonthDiv = null;
    this.eMonthMenu = null;
    this.eYearMenu = null;
    this.eBtnYearUp = null;
    this.eBtnYearDown = null;
    this.eBtnPrev = null;
    this.eBtnNext = null;
    this.eBtnClose = null;
    this.eContentCell = null;    

    this.eBodyTable = null;
    this.eSelectedDay = null;
    this.eFocus = null;
    
    if(this.eElement.oVdfControl === this){
        this.eElement.oVdfControl = null;
    }
    this.eElement = null;
    this.eContainerElement = null;
},


constructDate : function(iYear, iMonth, iDate){
    var sResult = this.sDateMask;

    sResult = sResult.replace('DDD', '<n>');
    sResult = sResult.replace("DD","<e>");
    sResult = sResult.replace("D","<d>");
    sResult = sResult.replace("<e>", vdf.sys.math.padZero(iDate, 2));
    sResult = sResult.replace("<d>", iDate);
    sResult = sResult.replace("MMM","<o>");
    sResult = sResult.replace("MM","<n>");
    sResult = sResult.replace("M","<m>");
    sResult = sResult.replace("<m>", iMonth + 1);
    sResult = sResult.replace("<n>", vdf.sys.math.padZero(iMonth + 1, 2));
    sResult = sResult.replace("<o>", this.aMonthNamesShort[iMonth]);
    sResult = sResult.replace("YYYY", iYear);
    return sResult.replace("YY", vdf.sys.math.padZero(iYear % 100, 2));    
    
},


getWeekNr : function(dDate){
    var iYear, iMonth, iDate, dNow, dFirstDay, dThen, iCompensation, iNumberOfWeek;
    
    iYear = dDate.getFullYear();
    iMonth = dDate.getMonth();
    iDate = dDate.getDate();
    dNow = Date.UTC(iYear,iMonth,iDate+1,0,0,0);
    
    dFirstDay = new Date();
    dFirstDay.setFullYear(iYear);
    dFirstDay.setMonth(0);
    dFirstDay.setDate(1);
    dThen = Date.UTC(iYear,0,1,0,0,0);
    iCompensation = dFirstDay.getDay();
    
    if (iCompensation > 3){
        iCompensation -= 4;
    }else{
        iCompensation += 3;
    }
    iNumberOfWeek =  Math.round((((dNow-dThen)/86400000)+iCompensation)/7);
    return iNumberOfWeek;
},


fireChange : function(){
    this.onChange.fire(this, { iYear : this.iYear, iMonth : this.iMonth, iDate : this.iDate, sValue : this.getValue() });
},


fireEnter : function(){
    return !this.onEnter.fire(this, { iYear : this.iYear, iMonth : this.iMonth, iDate : this.iDate, sValue : this.getValue() });
},


fireClose : function(){
    return !this.onClose.fire(this, { iYear : this.iYear, iMonth : this.iMonth, iDate : this.iDate, sValue : this.getValue() });
},


//  PUBLIC INTERFACE


takeFocus : function(){
    if(this.eFocus !== null){
        this.eFocus.focus();
    }
},


setDate : function(dDate){
    this.iDate = dDate.getDate();
    this.iMonth = dDate.getMonth();
    this.iYear = dDate.getFullYear();
    
    this.displayCalendar();
    this.fireChange();
},


getDate : function(){
    var dDate = new Date(1, 1, 1, 1, 1, 1);
    
    dDate.setFullYear(this.iYear);
    dDate.setMonth(this.iMonth);
    dDate.setDate(this.iDate);
    
    return dDate;
},


getValue : function(){
    return vdf.sys.data.parseDateToString(this.getDate(), this.sDateFormat);
},


setValue : function(sValue){
    var dDate = vdf.sys.data.parseStringToDate(sValue, this.sDateFormat, this.sDateSeparator);
    
    if(dDate === null){
        dDate = new Date();
    }
    
    this.setDate(dDate);
    
    return true;
},


//  MONTH MENU


onBtnMonthClick : function(oEvent){
    this.eMonthMenu.style.display = (vdf.sys.gui.getCurrentStyle(this.eMonthMenu).display === "none" ? "block" : "none");
    this.eYearMenu.style.display = "none";
    
    //  Clear hide timeout
    if(this.tHideMenu !== null){
        clearTimeout(this.tHideMenu);
        this.tHideMenu = null;
    }
    
    this.takeFocus();
    oEvent.stop();
},


onMonthClick : function(oEvent){
    this.eMonthMenu.style.display = "none";
    
    this.iMonth = parseInt(oEvent.getTarget().getAttribute("iMonth"), 10);
    this.takeFocus();
    this.displayCalendar();
    this.fireChange();
    
    //  Clear hide timeout
    if(this.tHideMenu !== null){
        clearTimeout(this.tHideMenu);
        this.tHideMenu = null;
    }
    oEvent.stop();
},


onMonthMenuOut : function(oEvent){
    var fHideMonth, oCalendar = this;

    if(this.iMenuHideWait > 0){
        fHideMonth = function(){
            if(oCalendar.eMonthMenu){
                oCalendar.eMonthMenu.style.display = "none";
            }
            oCalendar.tHideMenu = null;
        };
        
        this.tHideMenu = setTimeout(fHideMonth, this.iMenuHideWait);
    }
},


onMonthMenuOver : function(oEvent){
    if(this.tHideMenu !== null){
        clearTimeout(this.tHideMenu);
        this.tHideMenu = null;
    }
},

//  YEAR MENU


onYearMenuOut : function(oEvent){
    var fHideMonth, oCalendar = this;

    if(this.iMenuHideWait > 0){
        fHideMonth = function(){
            if(oCalendar.eYearMenu){
                oCalendar.eYearMenu.style.display = "none";
            }
            oCalendar.tHideMenu = null;
        };
        
        this.tHideMenu = setTimeout(fHideMonth, this.iMenuHideWait);
    }
},


onYearMenuOver : function(oEvent){
    //  Clear hide timeout
    if(this.tHideMenu !== null){
        clearTimeout(this.tHideMenu);
        this.tHideMenu = null;
    }
},


onBtnYearClick : function(oEvent){
    var iStart, iItem;

    this.eYearMenu.style.display = (vdf.sys.gui.getCurrentStyle(this.eYearMenu).display === "none" ? "block" : "none");
    this.eMonthMenu.style.display = "none";
    
    //  Clear hide timeout
    if(this.tHideMenu !== null){
        clearTimeout(this.tHideMenu);
        this.tHideMenu = null;
    }
    
    //  Clear year menu
    while(this.eYearMenu.childNodes.length > 2){
        vdf.events.removeDomListener("click", this.eYearMenu.childNodes[1], this.onYearClick);
        this.eYearMenu.removeChild(this.eYearMenu.childNodes[1]);
    }
    
    //  Fill year menu
    iStart = this.iYear - Math.round((this.iYearMenuLength - 1) / 2);
    for(iItem = 0; iItem < this.iYearMenuLength; iItem++){
        //  Create year item
        this.eYearMenu.insertBefore(this.constructYearMenuItem(iStart + iItem), this.eYearMenu.childNodes[this.eYearMenu.childNodes.length - 1]);
    }

    this.takeFocus();
    oEvent.stop();
},


onYearClick : function(oEvent){
    this.eYearMenu.style.display = "none";
    
    //  Clear hide timeout
    if(this.tHideMenu !== null){
        clearTimeout(this.tHideMenu);
        this.tHideMenu = null;
    }
    
    this.iYear = parseInt(oEvent.getTarget().getAttribute("iYear"), 10);
    this.takeFocus();
    this.displayCalendar();

    this.fireChange();
    
    oEvent.stop();
},


onYearBtnUpDown : function(oEvent){
    var fScrollUp, oCalendar = this;

    fScrollUp = function(){
        oCalendar.scrollYearUp();
        oCalendar.tScrollTimeout = setTimeout(fScrollUp, oCalendar.iAutoScrollWait);
    };
    
    this.eBtnYearUp.className = "btnyearup_down";    
    this.scrollYearUp();
    this.tScrollTimeout = setTimeout(fScrollUp, oCalendar.iAutoScrollStart);
    
    oEvent.stop();
},


onYearBtnUpStop : function(oEvent){
    //  Stop scrolling
    if(this.tScrollTimeout !== null){
        clearTimeout(this.tScrollTimeout);
        this.tScrollTimeout = null;
    }
    
    //  Update display
    this.eBtnYearUp.className = "btnyearup";
    
    //oEvent.stop();
},


onYearBtnDownDown : function(oEvent){
    var fScrollUp, oCalendar = this;

    fScrollUp = function(){
        oCalendar.scrollYearDown();
        oCalendar.tScrollTimeout = setTimeout(fScrollUp, oCalendar.iAutoScrollWait);
    };
    
    this.eBtnYearDown.className = "btnyeardown_down";    
    this.scrollYearDown();
    this.tScrollTimeout = setTimeout(fScrollUp, oCalendar.iAutoScrollStart);
    
    oEvent.stop();
},


onYearBtnDownStop : function(oEvent){
    //  Stop scrolling
    if(this.tScrollTimeout !== null){
        clearTimeout(this.tScrollTimeout);
        this.tScrollTimeout = null;
    }
    
    //  Update display
    this.eBtnYearDown.className = "btnyeardown";
    
    //oEvent.stop();
},

//  OTHER EVENTS


onNextClick : function(oEvent){
    this.iMonth++;
    if(this.iMonth >= 12){
        this.iYear++;
        this.iMonth = 0;
    }

    this.takeFocus();
    this.displayCalendar();
    this.fireChange();
    
    oEvent.stop();
},


onPreviousClick : function(oEvent){
    this.iMonth--;
    if(this.iMonth < 0){
        this.iYear--;
        this.iMonth = 11;
    }
    
    this.takeFocus();
    this.displayCalendar();
    this.fireChange();
    
    oEvent.stop();
},


onDayClick : function(oEvent){
    var eCell = oEvent.getTarget();
    
    if(eCell.getAttribute("iDate") !==null){
        this.iYear = parseInt(eCell.getAttribute("iYear"), 10);
        this.iMonth = parseInt(eCell.getAttribute("iMonth"), 10);
        this.iDate = parseInt(eCell.getAttribute("iDate"), 10);
       
        this.takeFocus();
        this.displayCalendar();
        
        this.fireChange();
        this.fireEnter();
        
        oEvent.stop();
    }
},


onTodayClick : function(oEvent){
    var eAnchor = oEvent.getTarget();
    
    this.iYear = parseInt(eAnchor.getAttribute("iYear"), 10);
    this.iMonth = parseInt(eAnchor.getAttribute("iMonth"), 10);
    this.iDate = parseInt(eAnchor.getAttribute("iDate"), 10);
    
    this.takeFocus();
    this.displayCalendar();
    
    this.fireChange();
    this.fireEnter();
    
    oEvent.stop();
},


onKey : function(oEvent){
    var dDate, oPressedKey;
    
    //  Generate key object to compare
    oPressedKey = {
        iKeyCode : oEvent.getKeyCode(),
        bCtrl : oEvent.getCtrlKey(),
        bShift : oEvent.getShiftKey(),
        bAlt : oEvent.getAltKey()
    };
    
    if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.dayUp)){ // Up (decrement with 7 days)
        dDate = this.getDate();
        dDate.setDate(dDate.getDate() - 7);
        this.setDate(dDate);
        
        oEvent.stop();
    }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.dayDown)){ //  Down (increment with 7 days)
        dDate = this.getDate();
        dDate.setDate(dDate.getDate() + 7);
        this.setDate(dDate);
        
        oEvent.stop();
    }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.dayLeft)){ // Left (decrement with one day)
        dDate = this.getDate();
        dDate.setDate(dDate.getDate() - 1);
        this.setDate(dDate);
        
        oEvent.stop();
    }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.dayRight)){ // Right (increment with one day)
        dDate = this.getDate();
        dDate.setDate(dDate.getDate() + 1);
        this.setDate(dDate);
        
        oEvent.stop();
    }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.monthUp)){ //  Month up
        dDate = this.getDate();
        dDate.setMonth(dDate.getMonth() + 1);
        this.setDate(dDate);
        
        oEvent.stop();
    }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.monthDown)){ //    Month down
        dDate = this.getDate();
        dDate.setMonth(dDate.getMonth() - 1);
        this.setDate(dDate);
        
        oEvent.stop();
    }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.yearUp)){ //   Year up
        dDate = this.getDate();
        dDate.setFullYear(dDate.getFullYear() + 1);
        this.setDate(dDate);
        
        oEvent.stop();
    }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.yearDown)){ // Year down
        dDate = this.getDate();
        dDate.setFullYear(dDate.getFullYear() - 1);
        this.setDate(dDate);
        
        oEvent.stop();
    }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.enter)){ //    Enter
        if(this.fireEnter()){
            oEvent.stop();
        }
    }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.close)){ //    Close
        if(this.fireClose()){
            oEvent.stop();
        }
    }
},


onFocus : function(oEvent){
    if(this.eSelectedDay !== null){
        this.bHasFocus = true;
        this.bLozingFocus = false;
        this.eSelectedDay.className += " focussed";
    }
},


onBlur : function(oEvent){
    var oCalendar = this;
    
    if(this.eSelectedDay !== null){
        this.bLozingFocus = true;

        setTimeout(function(){
            if(oCalendar.bLozingFocus){
                oCalendar.bHasFocus = false;
                if(oCalendar.eSelectedDay !== null){
                    oCalendar.eSelectedDay.className = oCalendar.eSelectedDay.className.replace(" focussed", "");
                }
            }
        }, 200);
    }
},


onBtnClose : function(oEvent){
    if(this.fireClose()){
        oEvent.stop();
    }
},


onSubMenuClick : function(oEvent){
    oEvent.stop();
}

});








vdf.gui.CollapsePanel = function CollapsePanel(eElement, oParent){
    this.Control(eElement, oParent);
    
    
    this.sCssClass          = this.getVdfAttribute("sCssClass", "collapsepanel", false);
    
    
    this.bExpanded          = this.getVdfAttribute("bExpanded", true, false);
    
    this.bAnimate    = this.getVdfAttribute("bAnimate", true, true);
    
    this.iAnimDuration    = this.getVdfAttribute("iAnimDuration", 400, false);
    
    this.iAnimDelay    = this.getVdfAttribute("iAnimDelay", 40, false);
    
    this.bLockWidth    = this.getVdfAttribute("bLockWidth", false, false);
    
    
    this.eContent = null;
    
    this.eTitle = null;
    
    this.eSwitchBtn = null;
    
    //  @privates
    this.oAnim = null;
    this.iTotalHeight = 0;
    
    //  Container stuff
    this.aChildren          = [];
    
    
    //  Set classname
    vdf.sys.gui.addClass(this.eElement, this.sCssClass);
};

vdf.definePrototype("vdf.gui.CollapsePanel", "vdf.core.Control",{


init : function(){
    var eSwitch;
    
    //  Find the content & title eElement
    vdf.sys.dom.loopChildren(this.eElement, function(eElement){
        if(!this.eContent && eElement.tagName === "DIV"){
            this.eContent = eElement;
        }else if(vdf.getDOMAttribute(eElement, "sElement") === "content"){
            this.eContent = eElement;
        }else if(!this.eTitle && (eElement.tagName === "H1" || eElement.tagName === "H2" || eElement.tagName === "H3" || eElement.tagName === "H4")){
            this.eTitle = eElement;
        }else if(vdf.getDOMAttribute(eElement, "sElement") === "title"){
            this.eTitle = eElement;
        }
    }, this);
    
    if(!this.eContent){
        throw new vdf.errors.Error(5149, "No content element found!", this, [ "content", "vdf.gui.CollapsePanel" ]);
    }
    vdf.sys.gui.addClass(this.eContent, "cp_content");
    
    //  Set CSS
    if(this.eTitle && this.eTitle.className.match(this.sCssClass) === null){
        this.eTitle.className = "cp_title";
    }
    
    //  Create switch button
    eSwitch = document.createElement("A");
    eSwitch.className = "cp_button"; //(this.bExpanded ? "cp_btn_collapse" : "cp_btn_expand");
    eSwitch.href = "javascript: vdf.sys.nothing();";
    eSwitch.innerHTML = "&nbsp;";
    this.eElement.insertBefore(eSwitch, (this.eTitle ? this.eTitle : this.eElement.firstChild));        
    vdf.events.addDomListener("click", eSwitch, this.toggle, this);
    this.eSwitchBtn = eSwitch;
    
    if(this.bLockWidth){
        this.eElement.style.width = this.eElement.clientWidth + "px";
    }
    
    this.sPrevOverflow = this.eContent.style.overflowY;
    this.sPrevDisplay = this.eContent.style.visibility;
    
    if(!this.bExpanded){
        this.collapse(true);
    }else{
        this.expand(true);
    }
    
    
},


toggle : function(){
    if(this.bExpanded){
        this.collapse();
    }else{
        this.expand();
    }
},


collapse : function(bOptNoAnim){
    var that = this, fFinished;

    this.bExpanded = false;
    vdf.sys.gui.removeClass(this.eElement, "cp_expanded");
    //this.eSwitchBtn.className = "cp_btn_expand";
    
    fFinished = function(){
        that.oAnim = null;
        that.eContent.style.height = "0px";
        that.eContent.style.visibility = "hidden";
    };
    
    
    if(!this.bAnimate || bOptNoAnim){
        this.sPrevOverflow = this.eContent.style.overflowY;
        this.sPrevDisplay = this.eContent.style.visibility;
        fFinished();
    }else{
        if(this.oAnim){
            this.oAnim.stop();
        }else{
            this.sPrevOverflow = this.eContent.style.overflowY;
            this.sPrevDisplay = this.eContent.style.visibility;
            this.eContent.style.overflowY = "hidden";

        }
        this.oAnim = vdf.sys.fx.doEffect({
            eTarget : this.eContent,
            
            sType : "height",
            sTo : "0px",
            iDuration : this.iAnimDuration,
            
            fFinished : fFinished
        }, 1, this.iAnimDelay);
    }
},


expand : function(bOptNoAnim){
    var that = this, fFinished;

    this.bExpanded = true;
    vdf.sys.gui.addClass(this.eElement, "cp_expanded");
    //this.eSwitchBtn.className = "cp_btn_collapse"
    
    fFinished = function(){
        that.oAnim = null;
        that.eContent.style.overflowY = that.sPrevOverflow;
        that.eContent.style.height = "";
    };
    
    if(!this.bAnimate || bOptNoAnim){
        fFinished();
    }else{
        if(this.oAnim){
            this.oAnim.stop();
        }else{
            this.eContent.style.overflowY = "hidden";
            this.eContent.style.visibility = this.sPrevDisplay;
        }
        this.oAnim = vdf.sys.fx.doEffect({
            eTarget : this.eContent,
            
            sType : "height",
            sTo : this.eContent.scrollHeight + "px",
            iDuration : this.iAnimDuration,
            
            fFinished : fFinished
        }, 1, this.iAnimDelay);
    }
},

// - - - - - - - - - - CONTAINER FUNCTIONALITY - - - - - - - - - - 


addChild : function(oControl){
    this.aChildren.push(oControl);
},


addDEO : function(oDeo){
    if(this.oParentControl !== null && typeof(this.oParentControl.addDEO) === "function"){
        this.oParentControl.addDEO(oDeo);
    }
},


formInit : function(){
    var iChild;
    
    for(iChild = 0; iChild < this.aChildren.length; iChild++){
        if(typeof(this.aChildren[iChild].formInit) === "function"){
            this.aChildren[iChild].formInit();
        }
    }
},


getForm : function(){
    //  Find reference to form
    if(this.oParentControl !== null && this.oParentControl.bIsForm){    
        return this.oParentControl;
    }else if(this.oParentControl !== null && typeof(this.oParentControl.getForm) === "function"){
        return this.oParentControl.getForm();
    }
    
    return null;
}

});



vdf.gui.CustomMenu = function CustomMenu(eElement, oParentControl){
    this.Control(eElement, oParentControl);
    
    
    this.bHideFocus = this.getVdfAttribute("bHideFocus", true, false);
    
    this.bFadeOpacity = this.getVdfAttribute("bFadeOpacity", true, false);
    
    //  @privates
    
    this.oMainMenu = {
        bIsMenu : true,
        bDisplayed : true,
        sName : null,
        eElement : this.eElement,
        aReferenced : [],
        aItems : []
    };
    this.oMenus = {};
    this.aMenus = [ this.oMainMenu ];
    this.aItems = [];
    this.oEffect = null;
};

vdf.definePrototype("vdf.gui.CustomMenu", "vdf.core.Control", {


init : function(){
    var iItem, iMenu, oItem, oCurrentItem = null;

    //  Scan for elements
    this.scan(this.eElement, this.oMainMenu, null);
    
    //  Loop through the elements and attach event listeners
    for(iItem = 0; iItem < this.aItems.length; iItem++){
        oItem = this.aItems[iItem];

        vdf.events.addDomListener("click", oItem.eElement, this.onItemClick, this);

        if(oItem.eAnchor !== null){
            //  Determine if the url is current page
            if(this.isCurrentUrl(oItem.eAnchor.href)){
                oItem.eElement.className = "currentpage";
                oCurrentItem = oItem;
            }
            
            //  Try to hide anchor focus
            if(this.bHideFocus){
                oItem.eAnchor.hideFocus = true;
            }
            vdf.events.addDomListener("click", oItem.eAnchor, this.onItemClick, this);
        }
        
        //  Determine submenu
        if(oItem.sTarget !== null){
            if(this.oMenus[oItem.sTarget] !== null){
                oItem.oSubMenu = this.oMenus[oItem.sTarget];
                oItem.oSubMenu.aReferenced.push(oItem);
            }else{
                throw new vdf.errors.Error(5150, "SubMenu not found: {{0}}", this, [oItem.sTarget]);
            }
        }
    }

    //  Select current item if needed
    if(oCurrentItem !== null){
        this.select(oCurrentItem);
    }

    //  Set opacity to zero if effects are used
    for(iMenu = 0; iMenu < this.aMenus.length; iMenu++){
        if(this.aMenus[iMenu] !== this.oMainMenu && !this.aMenus[iMenu].bDisplayed){
            if(this.bFadeOpacity){
                vdf.sys.gui.setOpacity(this.aMenus[iMenu].eElement, 0);
            }
            
            this.aMenus[iMenu].eElement.style.display = "none";
        }
    }
},


scan : function(eElement, oMenu, oMenuItem){
    var sElement, sSubMenu, sMenuName;
    
    sElement = vdf.getDOMAttribute(eElement, "sElement", "");
    sElement = sElement.toLowerCase();
    
    if(sElement === "item"){
        sSubMenu = vdf.getDOMAttribute(eElement, "sSubMenu", null);
        oMenuItem = { 
            bSelected : false, 
            sTarget : sSubMenu, 
            oSubMenu : null,
            oMenu : oMenu, 
            eElement : eElement, 
            eAnchor : null 
        };
        
        this.aItems.push(oMenuItem);
        oMenu.aItems.push(oMenuItem);
    }else if(sElement === "menu"){
        sMenuName = vdf.getDOMAttribute(eElement, "sName", null);
       
        oMenu = {
            bIsMenu : true,
            bDisplayed : false, 
            sName : sMenuName, 
            eElement : eElement,
            aReferenced : [],
            aItems : []
        };
        
        this.oMenus[sMenuName] = oMenu;
        this.aMenus.push(oMenu);
    }else if(eElement.tagName.toLowerCase() === "a" && oMenuItem !== null){
        oMenuItem.eAnchor = eElement;
    }
    
    
    //  Move into children
    vdf.sys.dom.loopChildren(eElement, function(eChild){
        this.scan(eChild, oMenu, oMenuItem);
    }, this);
},


select : function(oItem){
    var iItem;

    if(!oItem.bSelected){
        //  Deselect other items in menu
        for(iItem = 0; iItem < oItem.oMenu.aItems.length; iItem++){
            if(oItem.oMenu.aItems[iItem].bSelected && oItem.oMenu.aItems[iItem] !== oItem){
                this.deSelect(oItem.oMenu.aItems[iItem]);
            }
        }
        
        oItem.bSelected = true;
        oItem.eElement.className += " selected";
        
        if(oItem.oSubMenu !== null){
            this.displayMenu(oItem.oSubMenu);
        }
        
        for(iItem = 0; iItem < oItem.oMenu.aReferenced.length; iItem++){
            this.select(oItem.oMenu.aReferenced[iItem]);
        }
    }
    
},


deSelect : function(oItem){
    if(oItem.bSelected){
        oItem.eElement.className = oItem.eElement.className.replace("selected", "");
        oItem.bSelected = false;
        
        if(oItem.oSubMenu !== null){
            this.hideMenu(oItem.oSubMenu);
        }
    }
},


displayMenu : function(oMenu){
    if(!oMenu.bDisplayed){
        oMenu.bDisplayed = true;
        oMenu.eElement.style.display = "";
        
        if(this.bFadeOpacity){
            if(this.oEffect){
                this.oEffect.stop();
            }
            
            //  Animates the opacity of the menu element to 100% in 0,5 second
            this.oEffect = vdf.sys.fx.doEffect({
               eTarget : oMenu.eElement,
               sType : "opacity",
               sTo : "100%",
               iDuration : 500
            });
        }
    }
},


hideMenu : function(oMenu){
    if(oMenu.bDisplayed){
        oMenu.bDisplayed = false;
        oMenu.eElement.style.display = "none";
        
        if(this.bFadeOpacity){
            if(this.oEffect){
                this.oEffect.stop();
                this.oEffect = null;
            }
        
            //vdf.sys.gui.stopFadeOpacity(oMenu.eElement);
            vdf.sys.gui.setOpacity(oMenu.eElement, 0);
        }
    }
},


onItemClick : function(e){
    var iItem, oItem, eSource = e.getTarget();
    
    //  Search for the items element
    eSource = vdf.sys.dom.searchParentByVdfAttribute(eSource, "sElement", "item");
    
    //  Search for the item and call the select method
    for(iItem = 0; iItem < this.aItems.length; iItem++){
        oItem = this.aItems[iItem];
        
        if(oItem.eElement === eSource || oItem.eAnchor === eSource){
            this.select(oItem);
            break;
        }
    }
},


isCurrentUrl : function(sUrl){
    var sCurrent = document.location.href.toLowerCase();
    
    sUrl = sUrl.toLowerCase();
    
    if(sUrl !== "" && sUrl.substr(0, 10) !== "javascript:"){
    
        if(sUrl === sCurrent.substring(sCurrent.length - sUrl.length)){
            return true;
        }

        if(sUrl.indexOf("?") === -1 && sCurrent.indexOf("?") !== -1){
            if(sUrl === sCurrent.substring(sCurrent.indexOf("?") - sUrl.length, sCurrent.indexOf("?"))){
                return true;
            }
        }
    }
    
    return false;
},


destroy : function(){
    if(this.eElement){
        vdf.events.clearDomListeners(this.eElement, true);
    }
    
    this.oMenus = {};
    this.aMenus = [];
    this.aItems = [];
    this.eContent = null;
    this.eTable = null;
}

});


//  @requireCSS DropDownMenu.css


vdf.gui.DropDownMenu = function DropDownMenu(eUL, oParentControl){
    this.Control(eUL, oParentControl);
    
    this.sCssClass      = this.getVdfAttribute("sCssClass", "DropDownMenu", false);
    
    //  @privates
    
    //  Set classname
    if(eUL.className.match(this.sCssClass) === null){
        eUL.className = this.sCssClass;
    }
    
    //  Reserve z-Index
    eUL.style.zIndex = vdf.gui.reserveZIndex();
};

vdf.definePrototype("vdf.gui.DropDownMenu", "vdf.core.Control", {


walkTree : function(eElement, bFirst, bLast){
    var bSub = false, iChild, aChildren = [];
    
    //  Scan child elements
    vdf.sys.dom.loopChildren(eElement, function(eChild){
        aChildren.push(eChild);
    }, this);
    
    for(iChild = 0; iChild < aChildren.length; iChild++){
        bSub = this.walkTree(aChildren[iChild], iChild === 0, iChild === (aChildren.length - 1)) || bSub;
    }
    
    
    if(eElement.nodeName == "UL"){
        bSub = true;
    }
    
    if(eElement.nodeName == "LI"){
        this.initMenuItem(eElement, bSub, bFirst, bLast);
    }
    
    return bSub;
},


initMenuItem : function(eElement, bSub, bFirst, bLast){
    if(bSub){
        if(eElement.className.indexOf("hasSub") < 0){
            eElement.className = eElement.className + " hasSub";
        }
    }else{
        if(eElement.className.indexOf("noSub") < 0){
            eElement.className = eElement.className + " noSub";
        }
    }
    
    if(bFirst && eElement.className.indexOf("isFirst") < 0){
        eElement.className = eElement.className + " isFirst";
    }
    
    if(bLast && eElement.className.indexOf("isLast") < 0){
        eElement.className = eElement.className + " isLast";
    }

    
    if (vdf.sys.isIE && vdf.sys.iVersion <= 6) {
        //  Attach onmouseover & onmouseout events
        if (eElement.nodeName == "LI") {
            vdf.events.addDomListener("mouseover", eElement, this.onMenuMouseOver, this);
            vdf.events.addDomListener("mouseout", eElement, this.onMenuMouseOut, this);
        }
    }
},


onMenuMouseOver : function(oEvent){
    var iChild, eLI = oEvent.eSource;
    
    //  Check if the previously hovered element isn't inside the element of 
    //  which we catched the element (if this is the case the event has bubbled 
    //  and the hover is already set)
    
    //  Note that contains and fromElement are IE only functions / properties
    if(!eLI.contains(oEvent.e.fromElement)){
        eLI.className = eLI.className + " hover";
        
        //  Hide the select boxes for child menu's
        for(iChild = 0; iChild < eLI.childNodes.length; iChild++){
            if(eLI.childNodes[iChild].tagName === "UL"){
                vdf.sys.gui.hideSelectBoxes(eLI.childNodes[iChild]);
            }
        }
        
    }
},


onMenuMouseOut : function(oEvent){
    var iChild, eLI = oEvent.eSource;
    
    //  Check if the newly hovered element isn't inside this element which would 
    //  mean that the class doesn't need to change.
    
    //  Note that contains and fromElement are IE only functions / properties
    if(!eLI.contains(oEvent.e.toElement)){
        //  Display the select boxes again
        for(iChild = 0; iChild < eLI.childNodes.length; iChild++){
            if(eLI.childNodes[iChild].tagName === "UL"){
                vdf.sys.gui.displaySelectBoxes(eLI.childNodes[iChild]);
            }
        }
        
        eLI.className = eLI.className.replace(" hover", "");
    }
},



init : function(){
    this.walkTree(this.eElement);
},


destroy : function(){
    if(this.eElement && vdf.sys.isIE && vdf.sys.iVersion <= 6){
        vdf.events.clearDomListeners(this.eElement, true);
    }
}

});


//  @requireCSS ModalDialog.css


vdf.gui.ModalDialog = function ModalDialog(){
    
    this.sTitle = "New modal dialog!";
    
    this.iWidth = null;
    
    this.iHeight = null;
    
    this.sCssClass = "modaldialog";
    
    this.bTakeFocus = false;
    
    this.bCloseOnEscape = true;
    
    this.bHideCloseButton = false;
    
    this.sReturnValue = null;

    
    this.iX = -1;
    
    this.iY = -1;
    
    
    this.onBeforeClose = new vdf.events.JSHandler();
    
    this.onAfterClose = new vdf.events.JSHandler();
    
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

vdf.definePrototype("vdf.gui.ModalDialog",{

//  - - - - - - - - - - - PUBLIC INTERFACE - - - - - - - - - - - 


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


displayMessage : function(sText, sDetails){
    var eDiv, eSpan, eDetails, eDetDiv, eDetTxtDiv, eDetH2, oDetails;
    
    this.initializeDialog();
    
    eDiv = document.createElement("div");
    eDiv.className = "message";
    eSpan = document.createElement("span");    
    eDiv.appendChild(eSpan);
    this.eCellContent.appendChild(eDiv);
    vdf.sys.dom.setElementText(eSpan, sText);
    
    if(sDetails){
        eDetails = document.createElement("div");
        eDetails.className = "vdfMsgDetails";
        
        eDetH2 = document.createElement("h2");
        vdf.sys.dom.setElementText(eDetH2, vdf.lang.getTranslation("global", "details", "Details"));
        eDetails.appendChild(eDetH2);
        
        eDetDiv = document.createElement("div");
        eDetTxtDiv = document.createElement("div");
        
        eDetTxtDiv.innerHTML = sDetails;
        
        eDetDiv.appendChild(eDetTxtDiv);
        eDetails.appendChild(eDetDiv);
        eDiv.appendChild(eDetails);
        
        //  Manually create an instance of the balloon
        oDetails = new vdf.gui.CollapsePanel(eDetails, this);
        oDetails.bExpanded = false;
        //  Tell the AJAX Library we created this component
        vdf.core.init.registerControl(oDetails, "vdf.gui.CollapsePanel");
        
        oDetails.init();
    }
    
    this.calculatePosition();
    
    return eDiv;
},


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


addButton : function(sNewName, sNewText, sNewCSS){
    var oButton = { sName : sNewName, sText : sNewText, sCSS : sNewCSS };
    
    this.aButtons.push(oButton);
    
    if(this.eCellButtons !== null){
        this.createButton(oButton);
    }       
},


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
            vdf.events.clearDomListeners(this.eDivContainer, true);
            if(vdf.sys.isIE && vdf.sys.iVersion <= 6){
                vdf.events.removeDomListener("scroll", window, this.onWindow_Scroll);
            }
            vdf.events.removeDomListener("resize", window, this.onWindow_Resize);
            
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


initializeDialog : function(){
    var oDialog = this;
    
    vdf.sys.gui.disableTabIndexes(document);
    
    this.createMask();

    this.createDialog();
    
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
    if(this.bHideCloseButton){
        eAnchor.style.visibility = "hidden";
    }
    
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
    vdf.events.addDomKeyListener(this.eDivContainer, this.onContainerKey, this);
    
    //  Register
    vdf.gui.aModalDialogs.push(this);
},


createButton : function(tButton){
    var eAnchor = document.createElement("a");
    
    this.eCellButtons.appendChild(eAnchor);
    eAnchor.className = tButton.sCSS;
    eAnchor.href = "javascript: vdf.sys.nothing();";
    vdf.sys.dom.setElementText(eAnchor, tButton.sText);
    tButton.eAnchor = eAnchor;
    
    vdf.events.addDomListener("click", eAnchor, this.onButtonClicked, this);
},


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


onStopDrag : function(oEvent){
    vdf.events.removeDomListener("mouseup", this.eDivDragMask, this.onStopDrag);
    vdf.events.removeDomListener("mouseout", this.eDivDragMask, this.onStopDrag);
    vdf.events.removeDomListener("mousemove", this.eDivDragMask, this.onDrag);
    
    document.body.removeChild(this.eDivDragMask);
    this.eDivDragMask = null;
    
    this.bDragging = false;
},


onCloseClick : function(oEvent){
    if(this.close()){
        oEvent.stop();
    }
},


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


onContainerKey : function(oEvent){

    if(oEvent.getKeyCode() === 27 && this.bCloseOnEscape){
        if(this.close()){
            oEvent.stop();
        }
    }
},


onWindow_Resize : function(oEvent){
    this.calculatePosition();
},


onWindow_Scroll : function(oEvent){
    this.calculatePosition();
},

//  - - - - - - - - - - - SPECIAL FUNCTIONALLITY - - - - - - - - - - - 


setFixedY : function(eElement, iY){
    if(eElement.style.position == "absolute"){
        iY = iY + parseInt(document.documentElement.scrollTop, 10);
    }
    eElement.style.top = iY + "px";
},


setFixedX : function(eElement, iX){
    if(eElement.style.position == "absolute"){
        iX = iX + parseInt(document.documentElement.scrollLeft, 10);
    }
    eElement.style.left = iX + "px";
},


getFixedY : function(eElement){
    if(eElement.style.position == "absolute"){
        return parseInt(eElement.style.top, 10) - parseInt(document.documentElement.scrollTop, 10);
    }else{
        return parseInt(eElement.style.top, 10);
    }
},


getFixedX : function(eElement){
    if(eElement.style.position == "absolute"){
        return parseInt(eElement.style.left, 10) - parseInt(document.documentElement.scrollLeft, 10);
    }else{
        return parseInt(eElement.style.left, 10);
    }
}


});




vdf.gui.aModalDialogs = [];


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


vdf.gui.aAlertQueue = [];


vdf.gui.alert = function(sText, sTitle, sDetails){
    if(typeof(sTitle) == "undefined"){
        sTitle = "Alert";
    }

    //  Add to queue
    vdf.gui.aAlertQueue.push({ sText : sText, sTitle : sTitle, sDetails : sDetails || null });
    
    if(vdf.gui.aAlertQueue.length == 1){
        vdf.gui.alertFromQueue();
    }
};


vdf.gui.alertFromQueue = function(){
    var oDialog, tAlert = vdf.gui.aAlertQueue[0];
    
    //  Create dialog
    oDialog = new vdf.gui.ModalDialog();
    oDialog.sTitle = tAlert.sTitle;
    oDialog.bTakeFocus = false;
    oDialog.onAfterClose.addListener(vdf.gui.onAlertClosed);
    
    //  Add OK button
    oDialog.addButton("oke", vdf.lang.getTranslation("global", "ok", "OK"), "btnOke");
    oDialog.onButtonClick.addListener(vdf.gui.onAlertButtonClick);
    
    //  Display the message
    oDialog.displayMessage(tAlert.sText, tAlert.sDetails);
    
    //  Pass the focus to the OK button
    oDialog.focusButton("oke");
};


vdf.gui.onAlertButtonClick = function(oEvent){
    if(oEvent.sButtonName === "oke"){
        oEvent.oSource.close();
    }
};


vdf.gui.onAlertClosed = function(oEvent){
    vdf.gui.aAlertQueue.shift();
    if(vdf.gui.aAlertQueue.length > 0){
        vdf.gui.alertFromQueue();
    }
};


vdf.gui.displayDOMDialog = function(eElement, sTitle, iWidth, iHeight){
    var oDialog = new vdf.gui.ModalDialog();
    
    oDialog.sTitle = sTitle || "Modal dialog";
    oDialog.iWidth = iWidth || null;
    oDialog.iHeight = iHeight || null;
    oDialog.displayDOM(eElement);
    
    return oDialog;
};


vdf.gui.displayHTMLDialog = function(sHTML, sTitle, iWidth, iHeight){
    var oDialog = new vdf.gui.ModalDialog();
    
    oDialog.sTitle = sTitle || "Modal dialog";
    oDialog.iWidth = iWidth || null;
    oDialog.iHeight = iHeight || null;
    oDialog.displayHTML(sHTML);
    
    return oDialog;
};







vdf.gui.PopupCalendar = function PopupCalendar(eElement, oParentControl){
    this.Control(eElement, oParentControl);
    
    
    this.sCssClass = this.getVdfAttribute("sCssClass", "popupcalendar", true);
    
    this.sFieldName = this.getVdfAttribute("sFieldName", null, false);
    
    this.eInput = null;
    
    this.bAttach = this.getVdfAttribute("bAttach", true, false);
    
    
    this.sDateFormat = null;
    
    this.sDateMask = null;
    
    this.sDateSeparator = null;
    
    
    this.onEnter = new vdf.events.JSHandler();
    
    this.onClose = new vdf.events.JSHandler();
    
    this.onBeforeDisplay = new vdf.events.JSHandler();
    
    this.onAfterDisplay = new vdf.events.JSHandler();

    
    // @privates
    this.eContainerDiv = null;
    this.oCalendar = null;
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

vdf.definePrototype("vdf.gui.PopupCalendar", "vdf.core.Control", {


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


display : function(oSource){
    var eContainerDiv, oCalendar, sValue = "";
    
    if(this.oCalendar === null){
        if(this.onBeforeDisplay.fire(this, {})){
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
            
            this.onAfterDisplay.fire(this, { oCalendar : oCalendar });
        }
    }
},


hide : function(){
    if(this.oCalendar !== null){
        // for IE <= 6
        vdf.sys.gui.displaySelectBoxes(this.eContainerDiv, null);
    
        this.oCalendar.destroy();
        this.oCalendar = null;
        this.eContainerDiv.parentNode.removeChild(this.eContainerDiv);
        this.eContainerDiv = null;

    }
},


destroy : function(){
    this.hide();
    
    if(this.bHandleOnClick && this.eElement){
        vdf.events.removeDomListener("click", this.eElement, this.onButtonClick);
    }
    this.eElement = null;
    this.eContainerDiv = null;
    
    this.oParentControl = null;
    this.oCalendar = null;
},


onButtonClick : function(oEvent){
    if(this.oCalendar === null){
        this.display();
    }else{
        this.hide();
    }
},


onCalendarEnter : function(oEvent){
    var sValue;

    if(this.onEnter.fire(this, { iYear : oEvent.iYear, iMonth : oEvent.iMonth, iDate : oEvent.iDate, sValue : oEvent.sValue })){
        sValue = oEvent.sValue;
        
        this.hide();
        
        if(this.oField !== null){
            this.oField.setValue(sValue);
            this.oField.focus();
        }else if(this.eInput !== null){
            this.eInput.value = sValue;
            vdf.sys.dom.focus(this.eInput);
        }
    }else{
        return false;
    }
},


onCalendarClose : function(oEvent){
    if(this.onClose.fire(this, { iYear : oEvent.iYear, iMonth : oEvent.iMonth, iDate : oEvent.iDate, sValue : oEvent.sValue })){
        this.hide();
    }else{
        return false;
    }
}

});


vdf.gui.show_FieldPopupCalendar = function(eOpener, sFieldName, sDateFormat, sDateMask, sDateSeparator){
    return vdf.gui.showPopupCalendar(eOpener, sFieldName, sDateFormat, sDateMask, sDateSeparator);
};


vdf.gui.show_InputPopupCalendar = function(eOpener, eInput, sDateFormat, sDateMask, sDateSeparator){
    return vdf.gui.showPopupCalendar(eOpener, eInput, sDateFormat, sDateMask, sDateSeparator);
};


vdf.gui.showPopupCalendar = function(eOpener, oTarget, sOptDateFormat, sOptDateMask, sOptDateSeparator, oOptEnvir){
    var oForm = null, oPopCal;
    
    oPopCal = new vdf.gui.PopupCalendar(eOpener, null);
    oPopCal.bAttach = false;
    
    //  The second parameter determines where the value needs to go
    if(typeof(oTarget) === "function"){ //  If it is a function we attach it to the onEnter event
        oPopCal.onEnter.addListener(oTarget, (oOptEnvir ? oOptEnvir : null));
        oForm = vdf.core.findForm(eOpener);
    }else if(typeof(oTarget) === "object"){
        if(oTarget.bIsDEO){ //  Check if it is an VDF Data Entry Object
            oPopCal.oField = oTarget;
            oForm = oTarget.oForm;
        }else{  //  Else we assume it is an input element
            oPopCal.eInput = oTarget;
            oForm = vdf.core.findForm(oTarget);
        }
    }else if(typeof(oTarget) === "string"){ //  A string means fieldname
        oPopCal.sFieldName = oTarget;
        oForm = vdf.core.findForm(eOpener);
    }
    
    oPopCal.oForm = oForm;
    oPopCal.formInit();
    
    if(typeof(sOptDateFormat) === "string"){
        oPopCal.sDateFormat = sOptDateFormat;
    }
    if(typeof(sOptDateMask) === "string"){
        oPopCal.sDateMask = sOptDateMask;
    }
    if(typeof(sOptDateSeparator) === "string"){
        oPopCal.sDateSeparator = sOptDateSeparator;
    }
    oPopCal.display();
    
    return oPopCal;
};


//  Includes the CSS file that belongs to the scrollbar
//  @requireCSS Scrollbar.css


vdf.gui.SCROLL_TOP = -3;

vdf.gui.SCROLL_UP = -2;

vdf.gui.SCROLL_STEP_UP = -1;

vdf.gui.SCROLL_STEP_DOWN = 1;

vdf.gui.SCROLL_DOWN = 2;

vdf.gui.SCROLL_BOTTOM = 3;


vdf.gui.Scrollbar = function ScrollBar(eElement, oParentControl){
    this.Control(eElement, oParentControl);
    
    
    this.eScrollElement = null;
    
    this.sCssClass = this.getVdfAttribute("sCssClass", "scrollbar", false);
    
    
    this.bOverLay = this.getVdfAttribute("bOverLay", false, false);
    
    this.iMarginTop = this.getVdfAttribute("iMarginTop", 0, false);
    
    this.iMarginRight = this.getVdfAttribute("iMarginRight", 0, false);
    
    this.iMarginBottom = this.getVdfAttribute("iMarginBottom", 0, false);
    
    
    this.bAutoScroll = this.getVdfAttribute("bAutoScroll", true, false);
    
    this.iAutoScrollWait = parseInt(this.getVdfAttribute("iAutoScrollWait", 60, false), 10);
    
    this.iAutoScrollStart = parseInt(this.getVdfAttribute("iAutoScrollStart", 500, false), 10);
    
    this.iDeadZone = parseInt(this.getVdfAttribute("iDeadZone", 5, false), 10);
    
    //  Events
    
    this.onScroll = new vdf.events.JSHandler();
    
    // @privates
    this.iLastWidth = 0;
    this.iValue = -1;
    this.iSpaceTotal = 0;
    this.iSpaceBefore = 0;
    this.iSpaceAfter = 0;
    this.iStartDragY = 0;
    this.iStartDragBefore = 0;
    this.tScrollTimeout = null;
    
    this.eBtnDown = null;
    this.eBtnUp = null;
    this.eSpaceBefore = null;
    this.eSpaceAfter = null;
    this.eSlider = null;
};

vdf.definePrototype("vdf.gui.Scrollbar", "vdf.core.Control", {


init : function(){
    if(this.eElement === null){
        this.createScrollbar();
    }else{
        //  TODO: Find references
    }
    
    //  Init DOM reference
    this.eElement.oVdfControl = this;
    
    this.attachEvents();
},


createScrollbar : function(){
    var eTable, eRow, eBtnUp, eSpaceBefore, eSlider, eSpaceAfter, eBtnDown, eClearDiv;

    //  TABLE
    eTable = document.createElement("table");
    eTable.className = this.sCssClass;
    eTable.cellPadding = 0;
    eTable.cellSpacing = 0;
    
    //  Button up
    eRow = eTable.insertRow(eTable.rows.length);
    eBtnUp = eRow.insertCell(0);
    eBtnUp.innerHTML = "";
    eBtnUp.className = "btnup";
    
    //  Space before
    eRow = eTable.insertRow(eTable.rows.length);
    eSpaceBefore = eRow.insertCell(0);
    eSpaceBefore.innerHTML = "";
    eSpaceBefore.className = "before";
    
    //  Slider
    eRow = eTable.insertRow(eTable.rows.length);
    eSlider = eRow.insertCell(0);
    eSlider.innerHTML = "";
    eSlider.className = "slider";
    
    //  Space after
    eRow = eTable.insertRow(eTable.rows.length);
    eSpaceAfter = eRow.insertCell(0);
    eSpaceAfter.innerHTML = "";
    eSpaceAfter.className = "after";
    
    //  Button down
    eRow = eTable.insertRow(eTable.rows.length);
    eBtnDown = eRow.insertCell(0);
    eBtnDown.innerHTML = "";
    eBtnDown.className = "btndown";
    
    //  Insert into the DOM
    if(this.eScrollElement !== null){
        vdf.sys.dom.insertAfter(eTable, this.eScrollElement);
        
        //  Usually the scrollbar is displayed above the element it scrolls
        //  which is done making them both float and adding a clear div below.
        if(this.bOverLay){
            if(typeof(eTable.style.cssFloat) !== "undefined"){
                eTable.style.cssFloat = "left";
                this.eScrollElement.style.cssFloat = "left";
            }else{
                eTable.style.styleFloat = "left";
                this.eScrollElement.style.styleFloat = "left";
            }
            
            eClearDiv = document.createElement("div");
            eClearDiv.style.clear = "both";
            vdf.sys.dom.insertAfter(eClearDiv, eTable);
        }
    }else{
        document.body.appendChild(eTable);
    }
    
    //  Store references
    this.eElement = eTable;
    this.eBtnDown = eBtnDown;
    this.eBtnUp = eBtnUp;
    this.eSpaceBefore = eSpaceBefore;
    this.eSpaceAfter = eSpaceAfter;
    this.eSlider = eSlider;
},


attachEvents : function(){
    //    Attach event listeners
    if(this.bAutoScroll){
        vdf.events.addDomListener("mousedown", this.eBtnUp, this.onBtnUpStart, this);
        vdf.events.addDomListener("mouseup", this.eBtnUp, this.onBtnUpStop, this);
        vdf.events.addDomListener("mouseout", this.eBtnUp, this.onBtnUpStop, this);

        vdf.events.addDomListener("mousedown", this.eBtnDown, this.onBtnDownStart, this);
        vdf.events.addDomListener("mouseup", this.eBtnDown, this.onBtnDownStop, this);
        vdf.events.addDomListener("mouseout", this.eBtnDown, this.onBtnDownStop, this);
    }else{
        vdf.events.addDomListener('click', this.eBtnUp, this.onBtnUpClick, this);
        vdf.events.addDomListener('click', this.eBtnDown, this.onBtnDownClick, this);
    }

    vdf.events.addDomListener('mousedown', this.eSlider, this.onSliderMouseDown, this);
    vdf.events.addDomListener('click', this.eSpaceAfter, this.onSpaceAfterClick, this);
    vdf.events.addDomListener('click', this.eSpaceBefore, this.onSpaceBeforeClick, this);
},


destroy : function(){
    //    Remove event listeners
    if(this.eElement){
        vdf.events.clearDomListeners(this.eElement);
    }
    
    //  Destroy references
    this.eElement.oVdfControl = null;    
    this.eElement = null;
    this.eBtnDown = null;
    this.eBtnUp = null;
    this.eSpaceBefore = null;
    this.eSpaceAfter = null;
    this.eSlider = null;
},




recalcDisplay : function(bDown){
    var iHeight, iSpace, iLeft = 0, iBefore, iAfter;

    //  Determine height
    if(this.eScrollElement !== null){
        iHeight = this.eScrollElement.offsetHeight - this.iMarginTop - this.iMarginBottom; // - (vdf.sys.isMoz ? this.eScrollElement.offsetTop : 0)
    }else{
        iHeight = this.eElement.clientHeight;
    }
    
    if(iHeight > 0){
        //  Determine & set space before and after slider
        iSpace = iHeight - this.eBtnDown.offsetHeight - this.eBtnUp.offsetHeight - this.eSlider.offsetHeight; // Use offsetHeight because clientHeight doesn't work here with Safari engine
        iSpace = (iSpace > 0 ? iSpace : 10);
        if(this.iValue < 0){
            iBefore = 1;
            iAfter = iSpace - 1;
        }else if(this.iValue > 0){
            iBefore = iSpace - 1;
            iAfter = 1;
        }else{
            iBefore = Math.round(iSpace / 2);
            iAfter = Math.round(iSpace / 2);
            if(iSpace > 0 && iSpace%2){
                iAfter--;
            }
        }
        
        this.iSpaceTotal = iSpace;
        this.iSpaceBefore = iBefore;
        this.iSpaceAfter = iAfter;
        
        this.eSpaceBefore.style.height = iBefore + "px";
        this.eSpaceAfter.style.height = iAfter + "px";
        
        //  Calculate the position of the scrollbar
        if(this.bOverLay){
            iLeft = 0 - this.determineWidth() - this.iMarginRight;
            
            this.eElement.style.marginLeft = iLeft + "px";
            this.eElement.style.marginTop = this.iMarginTop + "px";
        }
        this.eElement.style.height = iHeight + "px";
    }
},


determineWidth : function(){
    if(this.eElement.offsetWidth > 0){
        this.iLastWidth = this.eElement.offsetWidth;
        return this.eElement.offsetWidth;
    }else{
        return this.iLastWidth;
    }
},


onSliderMouseDown : function(oEvent){
    if(this.bDisabled){
        return;
    }
    
    //  Update display
    this.eSlider.className = "slider_down";
    
    //  Save values
    this.iStartDragY = oEvent.getMouseY();
    this.iStartDragBefore = this.iSpaceBefore;
    
    //  Attach listeners
    vdf.events.addDomListener("mouseup", document, this.onSliderMouseUp, this);
    vdf.events.addDomListener("mousemove", document, this.onSliderMouseMove, this);
    
    oEvent.stop();
},


onSliderMouseMove : function(oEvent){
    var iBefore, iAfter;

    if(this.bDisabled){
        return;
    }
        
    //  Calcuate positions
    iBefore = this.iStartDragBefore - (this.iStartDragY - oEvent.getMouseY());
    
    iBefore = (iBefore < 1 ? 1 : (iBefore > this.iSpaceTotal - 1 ? this.iSpaceTotal - 1 : iBefore));
    iAfter = this.iSpaceTotal - iBefore;
    
    //  Update display
    this.eSpaceBefore.style.height = iBefore + "px";
    this.eSpaceAfter.style.height = iAfter + "px";
    this.iSpaceBefore = iBefore;
    this.iSpaceAfter = iAfter;
    
    oEvent.stop();
},


onSliderMouseUp : function(oEvent){
    var iDiff;

    //  Remove listeners
    vdf.events.removeDomListener("mouseup", document, this.onSliderMouseUp);
    vdf.events.removeDomListener("mousemove", document, this.onSliderMouseMove);
    
    if(!this.bDisabled){
        //  Update display
        this.eSlider.className = "slider";
    
        //  Calculate & perform the action
        iDiff = this.iSpaceBefore - this.iSpaceAfter;
        if(this.iDeadZone < iDiff || iDiff < -this.iDeadZone){
            if(iDiff < 0){
                this.notifyScrolled((this.iSpaceBefore < this.iDeadZone ? vdf.gui.SCROLL_TOP : vdf.gui.SCROLL_UP));
            }else{
                this.notifyScrolled((this.iSpaceAfter < this.iDeadZone ? vdf.gui.SCROLL_BOTTOM : vdf.gui.SCROLL_DOWN));
            }
        }
    }

    //  Reset the display
    this.recalcDisplay(false);
    
    oEvent.stop();
},


onBtnUpStart : function(oEvent){
    var oScroll = this, fScrollUp;
    
    if(this.bDisabled){
        return;
    }

    this.eBtnUp.className = "btnup_down";
    
    fScrollUp = function(){
        oScroll.notifyScrolled(vdf.gui.SCROLL_STEP_UP);
        oScroll.tScrollTimeout = setTimeout(fScrollUp, oScroll.iAutoScrollWait);
    };
    
    this.notifyScrolled(vdf.gui.SCROLL_STEP_UP);
    this.tScrollTimeout = setTimeout(fScrollUp, this.iAutoScrollStart);
},


onBtnUpStop : function(oEvent){
    if(!this.bDisabled){
        this.eBtnUp.className = "btnup";
    }
    
    if(this.tScrollTimeout !== null){
        clearTimeout(this.tScrollTimeout);
        this.tScrollTimeout = null;
    }
},


onBtnDownStart : function(oEvent){
    var oScroll = this, fScrollUp;
    
    if(this.bDisabled){
        return;
    }

    this.eBtnDown.className = "btndown_down";
    
    fScrollUp = function(){
        oScroll.notifyScrolled(vdf.gui.SCROLL_STEP_DOWN);
        oScroll.tScrollTimeout = setTimeout(fScrollUp, oScroll.iAutoScrollWait);
    };
    
    this.notifyScrolled(vdf.gui.SCROLL_STEP_DOWN);
    this.tScrollTimeout = setTimeout(fScrollUp, this.iAutoScrollStart);

},


onBtnDownStop : function(oEvent){
    if(!this.bDisabled){
        this.eBtnDown.className = "btndown";
    }
    
    if(this.tScrollTimeout !== null){
        clearTimeout(this.tScrollTimeout);
        this.tScrollTimeout = null;
    }
},


onBtnUpClick : function(oEvent){
    if(!this.bDisabled){
        this.notifyScrolled(vdf.gui.SCROLL_STEP_UP);
        oEvent.stop();
    }
},


onBtnDownClick : function(oEvent){
    if(!this.bDisabled){
        this.notifyScrolled(vdf.gui.SCROLL_STEP_DOWN);
        oEvent.stop();
    }
},


onSpaceAfterClick : function(oEvent){
    if(!this.bDisabled){
        this.notifyScrolled(vdf.gui.SCROLL_DOWN);
        oEvent.stop();
    }
},


onSpaceBeforeClick : function(oEvent){
    if(!this.bDisabled){
        this.notifyScrolled(vdf.gui.SCROLL_UP);
        oEvent.stop();
    }
},


center : function(){
    this.iValue = 0;
    this.recalcDisplay(false);
},


scrollBottom : function(){
    this.iValue = 1;
    this.recalcDisplay(false);
},


scrollTop : function(){
    this.iValue = -1;
    this.recalcDisplay(false);
},


enable : function(){
    if(this.bDisabled){
        this.bDisabled = false;
        
        this.eBtnUp.className = "btnup";
        this.eBtnDown.className = "btndown";
        this.eSpaceBefore.className = "before";
        this.eSpaceAfter.className = "after";
        this.eSlider.className = "slider";
    }
},


disable : function(){
    if(!this.bDisabled){
        this.bDisabled = true;
        
        this.eBtnUp.className = "btnup_disabled";
        this.eBtnDown.className = "btndown_disabled";
        this.eSpaceBefore.className = "before_disabled";
        this.eSpaceAfter.className = "after_disabled";
        this.eSlider.className = "slider_disabled";
    }
},


notifyScrolled : function(iValue){
    this.onScroll.fire(this, { iDirection : iValue });
}

});


//  Include style sheet
//  @requireCSS TabContainer.css


vdf.gui.TabContainer = function TabContainer(eElement, oParentControl){
    this.Control(eElement, oParentControl);
    
    
    this.sCssClass          = this.getVdfAttribute("sCssClass", "tabcontainer", false);
    
    this.bHideTabFocus      = this.getVdfAttribute("bHideTabFocus", true, false);
    
    this.bAutoNextTab       = this.getVdfAttribute("bAutoNextTab", true, false);
    
    this.bDetermineWidth    = this.getVdfAttribute("bDetermineWidth", false, false);
    
    this.bDetermineHeight   = this.getVdfAttribute("bDetermineHeight", true, false);
    
    
    this.onBeforeChange     = new vdf.events.JSHandler();    
    
    this.onAfterChange      = new vdf.events.JSHandler();    
    
    //  @privates
    this.aTabs              = [];
    this.oDisplayedTab      = null;
    this.bIsTabContainer    = true;
    this.aChildren          = [];
    
    this.oFirst             = null;
    this.eHeader = null;
    this.eContainer = null;
    this.eContainerDiv = null;
    
    this.iInitWaitForChildren = 0;
    this.iHeight = 0;
    this.iWidth = 0;
    
    //  Set classname
    vdf.sys.gui.addClass(this.eElement, this.sCssClass);};

vdf.definePrototype("vdf.gui.TabContainer", "vdf.core.Control", {


init : function(){

    this.scan(this.eElement);
    
    this.initialize();
    
    this.iInitWaitForChildren = this.waitForCalcDisplay();
    
    if(this.iInitWaitForChildren <= 0){
        this.iInitWaitForChildren = 1;
        this.recalcDisplay(false);
    }
},


scan : function(eElement){
    var sElement = vdf.getDOMAttribute(eElement, "sElement", null);
    
    if(sElement !== null){ 
        sElement = sElement.toLowerCase();
    }
    
    switch(sElement){
        case "header":
            this.eHeader = eElement;
            this.eHeader.className = "tabHeader";
            this.scanTabs(eElement, true);
            break;
        case "container":
            this.eContainer = eElement;
            this.eContainer.className = "container";
            this.scanTabs(eElement, false);
            break;
        default:
            vdf.sys.dom.loopChildren(eElement, function(eChild){
                 this.scan(eChild);
            }, this);
    }
},


scanTabs : function(eElement, bHeader){
    var oTab, sTabName;

    sTabName = vdf.getDOMAttribute(eElement, "sTabName", null);
    
    if(sTabName !== null){
        sTabName = sTabName.toLowerCase();
        oTab = this.getTab(sTabName);
        
        if(oTab === null){
            oTab = { "sTabName" : sTabName, eButton : null, eContainer : null, eNextAnchor : null, iLastHeight : 0, iLastWidth : 0 };
            this.aTabs.push(oTab);
        }
        
        if(bHeader){
            oTab.eButton = eElement;
        }else{
            oTab.eContainer = eElement;
            if(oTab.eContainer.className.indexOf("tabcontent") < 0){
                oTab.eContainer.className += " tabcontent";
            }
        }
        
    }else{
        vdf.sys.dom.loopChildren(eElement, function(eChild){
            this.scanTabs(eChild, bHeader);
        }, this);
    }
},


initialize : function(){
    var iTab, oTab, aAnchors, iAnchor, eAnchor;
    
    
    for(iTab = 0; iTab < this.aTabs.length; iTab++){
        oTab = this.aTabs[iTab];
        
        //  Check if complete
        if(oTab.eButton === null && typeof(oTab.eButton) !== "undefined"){
            throw new vdf.errors.Error(5141, "Tab without button", this, [ oTab.sTabName ]);
        }
        if(oTab.eContainer === null  & typeof(oTab.eContainer) !== "undefined"){
            throw new vdf.errors.Error(5142, "Button without tab", this, [ oTab.sTabName ]);
        }
        
        //  Add listener
        vdf.events.addDomListener("click", oTab.eButton, this.onButtonClick, this);
        
        //  Add anchor if needed
        if(this.bAutoNextTab && iTab !== this.aTabs.length - 1){
            eAnchor = document.createElement("a");
            oTab.eContainer.appendChild(eAnchor);
            eAnchor.href = "javascript: vdf.sys.nothing();";
            eAnchor.hideFocus = true;
            vdf.events.addDomListener("focus", eAnchor, this.onNextTabFocus, this);
            oTab.eNextAnchor = eAnchor;
            eAnchor.innerHTML = "&nbsp;";
            eAnchor.style.position = "absolute";
            eAnchor.style.left = "-2000px";
            eAnchor.style.top = "-2000px";
        }
        
        //  If first of attribute bFirst set display this tab after initialization
        if(this.oFirst === null || vdf.getDOMAttribute(oTab.eButton, "bFirst", false)){
            this.oFirst = oTab;
        }
    }
    
    
    
    //  Tries to hide the focus for the tab (the dotted line arround the anchor)
    if(this.bHideTabFocus){
        aAnchors = this.eHeader.getElementsByTagName("a");
        for(iAnchor = 0; iAnchor < aAnchors.length; iAnchor++){
            aAnchors[iAnchor].hideFocus = true;
        }
    }
    
},


displayTab : function(sName, bFocus){
    var oTab = this.getTab(sName.toLowerCase());
    
    if(oTab !== null){
        this.display(oTab, (bFocus));
        
        this.recalcDisplay(true);
        
        return true;
    }
    
    return false;
},


displayTabWithElement : function(eElement, bFocus){
    var sTabName = null;
        
    while(sTabName === null && eElement !== null && eElement !== document){
        sTabName = vdf.getDOMAttribute(eElement, "sTabName", null);
        eElement = eElement.parentNode;
    }

    if(sTabName !== null){
        return this.displayTab(sTabName, (bFocus));
    }
    
    return false;
},


display : function(oTab, bFocus){
    var iTab, eElement;
    
    if(oTab === this.oDisplayTab || this.onBeforeChange.fire(this, { oCurrentTab : this.oSelectedTab, oNewTab : oTab })){
    
        for(iTab = 0; iTab < this.aTabs.length; iTab++){
            if(this.aTabs[iTab] !== oTab){
                this.aTabs[iTab].eButton.className = "inactive";
                this.aTabs[iTab].eContainer.style.display = "none";
                //this.aTabs[iTab].eContainer.style.visibility = "hidden";
            }
        }
        
        oTab.eButton.className = "active";
        oTab.eContainer.style.display = "";
        //oTab.eContainer.style.visibility = "";
        
        if(bFocus){
            eElement = vdf.sys.dom.getFirstFocusChild(oTab.eContainer);
            if(eElement !== null && eElement !== oTab.eNextAnchor){
                vdf.sys.dom.focus(eElement, true);
            }
        }
        
        if(this.oDisplayedTab !== oTab){
            this.oDisplayedTab = oTab;
            
            this.onAfterChange.fire(this, { oNewTab : oTab });
        }
    }
},


getTab : function(sName){
    var iTab;
    
    sName = sName.toLowerCase();
    
    for(iTab = 0; iTab < this.aTabs.length; iTab++){
        if(this.aTabs[iTab].sTabName === sName){
            return this.aTabs[iTab];
        }
    }
    
    return null;
},


getCurrentTabName : function(){
    return (this.oDisplayedTab !== null ? this.oDisplayedTab.sTabName : null);
},


onButtonClick : function(oEvent){
    this.displayTabWithElement(oEvent.getTarget(), true);
},


onNextTabFocus : function(oEvent){
    var iTab, eSource = oEvent.getTarget();

    for(iTab = 0; iTab < this.aTabs.length; iTab++){
        if(this.aTabs[iTab].eNextAnchor === eSource && iTab + 1 < this.aTabs.length ){
            this.display(this.aTabs[iTab + 1], true);
            oEvent.stop();
        }
    }
},


destroy : function(){
    var iTab, oTab;
    
    if(this.eElement){
        //  Go through all tavs and remove the hidden next anchor's and clear the listeners
        for(iTab = 0; iTab < this.aTabs.length; iTab++){
            oTab = this.aTabs[iTab];
            vdf.events.clearDomListeners(oTab.eButton);
            
            if(oTab.eNextAnchor){
                vdf.events.clearDomListeners(oTab.eNextAnchor);
                oTab.eNextAnchor.parentNode.removeChild(oTab.eNextAnchor);
            }
            oTab.eNextAnchor = null;
            oTab.eButton = null;
        }
    
        vdf.events.clearDomListeners(this.eElement, true);
    }
    
    this.aTabs  = [];
    this.eHeader = null;
    this.eContainer = null;
    this.eContainerDiv = null;
},


// - - - - - - - - - - CONTAINER FUNCTIONALITY - - - - - - - - - - 


addChild : function(oControl){
    this.aChildren.push(oControl);
},


addDEO : function(oDeo){
    if(this.oParentControl !== null && typeof(this.oParentControl.addDEO) === "function"){
        this.oParentControl.addDEO(oDeo);
    }
},


formInit : function(){
    var iChild;
    
    for(iChild = 0; iChild < this.aChildren.length; iChild++){
        if(typeof(this.aChildren[iChild].formInit) === "function"){
            this.aChildren[iChild].formInit();
        }
    }
},


getForm : function(){
    //  Find reference to form
    if(this.oParentControl !== null && this.oParentControl.bIsForm){    
        return this.oParentControl;
    }else if(this.oParentControl !== null && typeof(this.oParentControl.getForm) === "function"){
        return this.oParentControl.getForm();
    }
    
    return null;
},


recalcDisplay : function(bDown){
    var iTab, iMaxHeight = this.iHeight, iMaxWidth = this.iWidth, oCurrent, iWidth, iHeight, iChild;
    //  Call initialize method if it was waiting for children
    this.iInitWaitForChildren--;

    
    if(this.iInitWaitForChildren <= 0){
        
        //  Loop through the tabs determining their width and height.
        for(iTab = 0; iTab < this.aTabs.length; iTab++){
            oCurrent = vdf.sys.gui.getCurrentStyle(this.aTabs[iTab].eContainer);
            
            //  Measure size (use size from previous measurement if zero (which happens if elements are invisible)
            iHeight = this.aTabs[iTab].eContainer.offsetHeight;
            this.aTabs[iTab].iLastHeight = iHeight = (iHeight > 0 ? iHeight : this.aTabs[iTab].iLastHeight);
            
            iWidth = this.aTabs[iTab].eContainer.offsetWidth;
            this.aTabs[iTab].iLastWidth = iWidth = (iWidth > 0 ? iWidth : this.aTabs[iTab].iLastWidth);
            
            //  Remember the highest
            if(iHeight > iMaxHeight){
                iMaxHeight = iHeight;
            }
            if(iWidth > iMaxWidth){
                iMaxWidth = iWidth;
            } 
        }
    
    
        //  Set the calculated sizes to the container
        if(this.bDetermineHeight){
            this.eContainer.style.height = iMaxHeight + "px";
        }
        if(this.bDetermineWidth){
            this.eContainer.style.width = iMaxWidth + "px";
        }
        
        //  If this is the first time (that we are not waiting for children) we display the first tab
        if(this.iInitWaitForChildren === 0){
            //  Display the first tab
            this.display(this.oFirst, false);
        }
    }
    
    //  Bubble up or down
    if(bDown){
        for(iChild = 0; iChild < this.aChildren.length; iChild++){
            if(typeof this.aChildren[iChild].recalcDisplay === "function"){
                this.aChildren[iChild].recalcDisplay(bDown);
            }
        }
        this.recalcDisplay(false);
    }else{
        if(this.oParentControl !== null && typeof(this.oParentControl.recalcDisplay) === "function"){
            this.oParentControl.recalcDisplay(bDown);
        }
    }
},


waitForCalcDisplay : function(){
    var iChild, iWait = 0;
    
    for(iChild = 0; iChild < this.aChildren.length; iChild++){
        if(typeof(this.aChildren[iChild].waitForCalcDisplay) === "function"){
            iWait =  iWait + this.aChildren[iChild].waitForCalcDisplay();
        }
    }
    
    return iWait;
}

});


vdf.gui.displayTabsWithElement = function(eElement){
    var sTabName = null;


    while(eElement !== null && eElement !== document){
        if(sTabName === null){
            sTabName = vdf.getDOMAttribute(eElement, "sTabName", null);
        }
        if(sTabName !== null){
            if(typeof(eElement.oVdfControl) === "object" && eElement.oVdfControl.bIsTabContainer){
                eElement.oVdfControl.displayTab(sTabName);
                sTabName = null;
            }
        }
        eElement = eElement.parentNode;
    }
};






vdf.gui.TreeView = function TreeView(eElement, oParentControl){
    var sKey;
    
    this.Control(eElement, oParentControl);
    
    
    this.sCssClass          = this.getVdfAttribute("sCssClass", "treeview", false);
    
    this.bHoldFocus         = this.getVdfAttribute("bHoldFocus", true, true);
    
    this.bFocus             = this.getVdfAttribute("bFocus", false, true);
    
    this.bDisplayIcons = this.getVdfAttribute("bDisplayIcons", true, false);
    
    this.sInitializer           = this.getVdfAttribute("sInitializer", null);
    
    this.oActionKeys        = {};
    
    
    this.onSelect = new vdf.events.JSHandler();
    
    this.onEnter            = new vdf.events.JSHandler();
    
    
    
    
    //  @privates
    this.eRootTable = null;
    this.aRootItems = [];
	this.aItems = [];
    this.tSelectedNode = null;
    this.eFocus = null;
    this.bFocussed = false;
    this.bLozingFocus = false;
    
    //  Copy settings
    for(sKey in vdf.settings.treeKeys){
        if(typeof(vdf.settings.treeKeys[sKey]) == "object"){
            this.oActionKeys[sKey] = vdf.settings.treeKeys[sKey];
        }
    }
    
    //  Set classname
    vdf.sys.gui.addClass(this.eElement, this.sCssClass);
};

vdf.definePrototype("vdf.gui.TreeView", "vdf.core.Control", {


init : function(){
    var eFocus;

    this.scanHTMLTree(this.eElement, "");
    
    this.eElement.innerHTML = "";
    
    this.callInitializers();
        
    //  Insert & initialize focus holder (A Element) (if needed)
    if(this.bHoldFocus){
        eFocus = document.createElement("a");
        this.eFocus = eFocus;
        eFocus.href = "javascript: vdf.sys.nothing();";
        eFocus.style.textDecoration = "none";
        eFocus.hideFocus = true;
        eFocus.innerHTML = "&nbsp;";
        eFocus.style.position = "absolute";
        eFocus.style.left = "-3000px";
        
        vdf.events.addDomKeyListener(eFocus, this.onKey, this);
        vdf.events.addDomListener("focus", eFocus, this.onFocus, this);
        vdf.events.addDomListener("blur", eFocus, this.onBlur, this);
        this.eElement.parentNode.insertBefore(eFocus, this.eElement);
        
        vdf.events.addDomListener("click", this.eElement, this.onGlobalClick, this);
        
        if(this.bFocus){
            vdf.sys.dom.focus(eFocus);
        }
    }
    
    if(this.aItems.length > 0 && !this.eRootTable){
        this.refresh();
    }
},


destroy : function(){
    if(this.eElement){
        vdf.events.clearDomListeners(this.eElement);
    }
    this.eRootTable = null;
    this.tSelectedNode = null;
    this.eFocus = null;
},


callInitializers : function(){
    var fInitializer  = null;
    
    if(typeof this.sInitializer === "string"){
        fInitializer = vdf.sys.ref.getNestedObjProperty(this.sInitializer);
        
        //  Call the function
        if(typeof fInitializer === "function"){
            fInitializer(this);
        }else{
            throw new vdf.errors.Error(5134, "Init method not found '{{0}}'", this, [ this.sInitializer ]);
        }
    }
},


addNode : function(sId, sParentId, sName, sAltText, sIconClass, bExpanded, sValue, fSelectHandler, oSelectEnv){
    var tNode = new vdf.dataStructs.TAjaxTreeNode();
    
    tNode.sId = sId;
    tNode.sValue = sValue || "";
    tNode.sParentId = sParentId;
    tNode.sName = sName;
    tNode.sAltText = sAltText || "";
    tNode.sIconClass = sIconClass || null;
    tNode.bExpanded = bExpanded || null;
    
    tNode.__fSelectHandler = fSelectHandler || null;
    tNode.__oSelectEnv = oSelectEnv || null;
    
    this.insertNode(tNode);
},


removeNodeById : function(sId){
    var tNode = this.getNodeById(sId);
    
    if(tNode){
        this.removeNode(tNode);
    }
},


removeNode : function(tNode){
    var eTable, aList, fRemove, iNode;

    fRemove = function(tNode, bSub){
        var iSub;
        //  Move into subnodes
        for(iSub = 0; iSub < tNode.__aSubItems.length; iSub++){
            fRemove.call(this, tNode.__aSubItems[iSub], true);
        }
        
        //  Remove DOM <-> JS references
        if(tNode.__eElement){
            vdf.events.clearDomListeners(tNode.__eElement, true);
            tNode.__eElement.tNode = null;
        }
        tNode.__eElement = null;
        tNode.__eSubMenuRow = null;
        tNode.__eSubMenuTable = null;
        
        if(tNode === this.tSelectedNode){
            this.tSelectedNode = null;
        }
        
        //  Remove from global list
        vdf.sys.data.removeFromArray(this.aItems, tNode);
    };
    
    //  Remove from DOM
    if(tNode.__eElement){
        vdf.events.clearDomListeners(tNode.__eElement, true);
        
        eTable = (tNode.__tParent ? tNode.__tParent.__eSubMenuTable : this.eRootTable);
        
        if(tNode.__eSubMenuRow){
            eTable.deleteRow(tNode.__eSubMenuRow.rowIndex);
        }
        eTable.deleteRow(tNode.__eElement.rowIndex);
    }
    
    fRemove.call(this, tNode, false);
    
    aList = (tNode.__tParent ? tNode.__tParent.__aSubItems : this.aRootItems);
    if(aList){
        //  Remove from structure
        vdf.sys.data.removeFromArray(aList, tNode);
        
        //  Update other nodes on this level
        for(iNode = 0; iNode < aList.length; iNode++){
            this.updateNodeCSS(aList[iNode]);
        }
    }
    
    //  Reselect a node if needed
    if(this.aItems.length > 0){
        this.select((aList && aList.length > 0 && aList[0].__tParent) || this.aItems[0]);
    }
},


clear : function(){
    var iItem;

    if(this.eRootTable){
        vdf.events.clearDomListeners(this.eRootTable, true);
        this.eElement.removeChild(this.eRootTable);
        
        for(iItem = 0; iItem < this.aItems.length; iItem++){
            if(this.aItems[iItem].__eElement){
                this.aItems[iItem].__eElement.tNode = null;
            }
            this.aItems[iItem].__eElement = null;
            this.aItems[iItem].__eSubMenuRow = null;
            this.aItems[iItem].__eSubMenuTable = null;
        }
    }
    
    this.tSelectedNode = null;
    this.aItems = [];
    this.aRootItems = [];
    this.eRootTable = this.constructTable();
    this.eRootTable.className = (this.bHasFocus ? "treeFocussed" : "");
    
    this.eElement.appendChild(this.eRootTable);
},


insertNode : function(tNode){
    var tParent, sParentId;
    
    //  Determine parent id
    sParentId = tNode.sParentId;
    
    //  Check if item doesn't already exist
    if(this.getNodeById(tNode.sId)){
        throw new vdf.errors.Error(5151, "Node ID's must be unique", this, [ tNode.sId ]);
    }
    
    //  Search for parent
    if(sParentId){
        tParent = this.getNodeById(sParentId);
    }
    
    //  Add to its parent
    if(tParent){
        tNode.__tParent = tParent;
        tParent.__aSubItems.push(tNode);
    }else{
        this.aRootItems.push(tNode);
    }
    
    //  Add to the full item list
    this.aItems.push(tNode);
    
    //  If no node selected select this node
    if(!this.tSelectedNode){
        this.select(tNode);
    }
},


scanHTMLTree : function(eElement, sParentId){
    var tNode;
    
    //  Generate node if found
    if((eElement.tagName && eElement.tagName.toUpperCase()) === "LI"){
        tNode = new vdf.dataStructs.TAjaxTreeNode();
    
        tNode.sId = vdf.getDOMAttribute(eElement, "sId", String(this.aItems.length));
        tNode.sValue = vdf.getDOMAttribute(eElement, "sValue", "");
        tNode.sParentId = sParentId || "";
        tNode.sName = (eElement.firstChild && (eElement.firstChild.textContent || eElement.firstChild.nodeValue)) || "New node " + tNode.sId;
        tNode.sAltText = vdf.getDOMAttribute(eElement, "sAltText", "");
        tNode.sIconClass = vdf.getDOMAttribute(eElement, "sIconClass", null);
        tNode.bExpanded = vdf.getDOMAttribute(eElement, "bExpanded", false);
    
        this.insertNode(tNode);

        sParentId = tNode.sId;
    }
    
    //  Go into children
    vdf.sys.dom.loopChildren(eElement, function(eChild){
        this.scanHTMLTree(eChild, sParentId);
    }, this);
},



refresh : function(){
    var iItem;
    
    if(this.eRootTable){
        vdf.events.clearDomListeners(this.eRootTable, true);
        this.eElement.removeChild(this.eRootTable);
        
        for(iItem = 0; iItem < this.aItems.length; iItem++){
            if(this.aItems[iItem].__eElement){
                this.aItems[iItem].__eElement.tNode = null;
            }
            this.aItems[iItem].__eElement = null;
            this.aItems[iItem].__eSubMenuRow = null;
            this.aItems[iItem].__eSubMenuTable = null;
        }
    }
    this.eRootTable = this.constructTable();
    this.eRootTable.className = (this.bHasFocus ? "treeFocussed" : "");
    
    this.eElement.appendChild(this.eRootTable);
    
    this.constructMenu(this.aRootItems, this.eRootTable);
},


constructTable : function(){
    var eTable = document.createElement("table");
    
    eTable.cellPadding = 0;
    eTable.cellSpacing = 0;
    
    return eTable;
},


constructNode : function(tNode, eTable, iPos, bIsStart, bIsLast){
    var bDoSub, eRow, eCell, eSpan;
    
    //  Determine if node has sub menu
    bDoSub = this.hasChildren(tNode);
    
    //  Determine tree CSS class
    
    //  Create row
    eRow = eTable.insertRow(iPos);
    tNode.__eElement = eRow;
    eRow.tNode = tNode;
    
    //  Tree cell
    eCell = eRow.insertCell(0);
    eCell.innerHTML = "<div>&nbsp;</div>";
    
    //  Content cell
    eCell = eRow.insertCell(eRow.cells.length);
    
    //  Text span
    eSpan = document.createElement("span");
    eSpan.title = (tNode.sAltText ? tNode.sAltText : "");
    eSpan.className = "treeText";
    vdf.sys.dom.setElementText(eSpan, tNode.sName);
    eCell.appendChild(eSpan);
    
    
    vdf.events.addDomListener("click", eCell, this.onItemClick, this);
    vdf.events.addDomListener("dblclick", eCell, this.onEnterAction, this);
    
    this.updateNodeCSS(tNode);
    
    //  Add listener(s)
    if(bDoSub){
        vdf.events.addDomListener("click", eRow, this.onExpandClick, this);
        
        if(tNode.bExpanded){
            iPos++;
            this.constructSubmenu(tNode, eTable, iPos, bIsLast);
        }
    }
    
    return iPos;
},


constructMenu : function(aNodes, eTable){
    var iNode, iPos = 0;

    for(iNode = 0; iNode < aNodes.length; iNode++){
        iPos = this.constructNode(aNodes[iNode], eTable, iPos, (iNode === 0 && eTable === this.eRootTable), (iNode == aNodes.length - 1));
        iPos++;
    }
},


constructSubmenu : function(tNode, eTable, iPos, bIsLast){
    var eRow, eCell, eNewTable;

    eRow = eTable.insertRow(iPos);

    eCell = eRow.insertCell(0);
    eCell.className = (bIsLast ? "treeConLast" : "treeCon");
    
    eCell = eRow.insertCell(1);
    eNewTable = this.constructTable();
    eCell.appendChild(eNewTable);
    
    tNode.__eSubMenuRow = eRow;
    tNode.__eSubMenuTable = eNewTable;
    
    this.constructMenu(tNode.__aSubItems, eNewTable, false);
},


moveUp : function(){
    var aList, iPos, tNode;
    
    if(this.tSelectedNode){
        tNode = this.tSelectedNode;
        iPos = this.getPosition(tNode);
        if(iPos > 0){   //  Select the previous node on this level
            aList = (tNode.__tParent ? tNode.__tParent.__aSubItems : this.aRootItems);
            
            //  If this node is expanded move down till the last end node
            tNode = aList[iPos - 1];
            while(tNode.bExpanded && tNode.__aSubItems.length > 0){
                tNode = tNode.__aSubItems[tNode.__aSubItems.length - 1];
            }
            
            this.select(tNode);
        }else{  //  Select the parent if available
            if(tNode.__tParent){
                this.select(tNode.__tParent);
            }
        }
    }
},


moveDown : function(){
    var tNode, aList, iPos;
    
    if(this.tSelectedNode){
        tNode = this.tSelectedNode;
        if(tNode.bExpanded && tNode.__aSubItems.length > 0){  //  Select the first child
            this.select(tNode.__aSubItems[0]);
        }else{  
            while(tNode){   //  Keep on moving levels up until a next node on the level is available or the root is reached
                aList = (tNode.__tParent ? tNode.__tParent.__aSubItems : this.aRootItems);
                iPos = this.getPosition(tNode);
            
                if(iPos < aList.length - 1){
                    this.select(aList[iPos + 1]);
                    break;
                }else{
                    tNode = tNode.__tParent;
                }
            }
        }
    }

},


collapse : function(){
    var tNode;
    
    if(this.tSelectedNode){
        tNode = this.tSelectedNode;
        
        if(tNode.bExpanded && this.hasChildren(tNode)){
            this.doCollapse(tNode);
        }else{
            if(tNode.__tParent){
                this.select(tNode.__tParent);
            }
        }
    }
},


extend : function(){
    var tNode;
    
    if(this.tSelectedNode){
        tNode = this.tSelectedNode;
        
        if(!tNode.bExpanded && this.hasChildren(tNode)){
            this.doExpand(tNode);
        }else{
            if(tNode.__aSubItems.length > 0){
                this.select(tNode.__aSubItems[0]);
            }
        }
    }
},


moveFirst : function(){
    if(this.aRootItems.length > 0){
        this.select(this.aRootItems[0]);
    }
},


moveLast : function(){
    var tNode;
    
    if(this.aRootItems.length > 0){
        tNode = this.aRootItems[this.aRootItems.length - 1];
        
        while(tNode.bExpanded && tNode.__aSubItems.length > 0){
            tNode = tNode.__aSubItems[tNode.__aSubItems.length - 1];
        }
        
        this.select(tNode);
    }
},


toggle : function(tNode){
    if(tNode.bExpanded){
        this.doCollapse(tNode);
    }else{
        this.doExpand(tNode);
    }
},


doExpand : function(tNode){
    tNode.bExpanded = true;
    
    if(tNode.__eSubMenuRow){ //  Unhide if DOM elements are already there
        tNode.__eSubMenuRow.style.display = "";
    }else{  //  Generate DOM elements
        this.constructSubmenu(tNode, (tNode.__tParent ? tNode.__tParent.__eSubMenuTable : this.eRootTable), tNode.__eElement.rowIndex + 1, this.isLast(tNode));
    }
    
    this.updateNodeCSS(tNode);
},



doCollapse : function(tNode){
    tNode.bExpanded = false;

    if(tNode.__eSubMenuRow){ 
       tNode.__eSubMenuRow.style.display = "none";
    }
    
    //  If the selected item is now hidden we select the collapsed one
    if(this.isParent(this.tSelectedNode, tNode)){
        while(tNode && !this.select(tNode)){
            tNode = tNode.__tParent;
        }
    }
    
    this.updateNodeCSS(tNode);
},


updateNodeCSS : function(tNode){
    var bFirst, bLast, bRoot, bSub;

    if(tNode.__eElement){
        //  Update node CSS
        tNode.__eElement.className = (tNode.bExpanded ? "treeExpanded" :  "treeCollapsed") + (tNode === this.tSelectedNode ? " treeSelected" : "");
        
        bFirst = this.isFirst(tNode);
        bLast = this.isLast(tNode);
        bRoot = this.isRoot(tNode);
        bSub = this.hasChildren(tNode);
        
        tNode.__eElement.cells[0].className = "treeItem tree" + (bFirst && bRoot || bLast ? (bFirst && bRoot ? "Start" : "") + (bLast ? "End" : "") : "Entry") + (bSub ? "Sub" : "");
        
        if(this.bDisplayIcons){
            tNode.__eElement.cells[1].className = (tNode.__aSubItems.length > 1 || tNode.bHasChildren ? "treeFolder " : "treeIcon ") + (tNode.sIconClass || "");
        }
    }
},


expandAll : function(){
    var iItem;

	for(iItem = 0; iItem < this.aItems.length; iItem++){
        this.aItems[iItem].bExpanded = true;
    }
    
    this.refresh();
},


collapseAll : function(){
    var iItem;

	for(iItem = 0; iItem < this.aItems.length; iItem++){
        this.aItems[iItem].bExpanded = false;
    }
    
    this.refresh();
},


select : function(tNode){
    var bContinue = true, oEventInfo, tPrevSelected, oEvent;
    
    oEventInfo = { tNode : tNode, sNodeId : tNode.sId, sParentNodeId : tNode.sParentId, sNodeValue : tNode.sValue };
    
    //  Call the select handler method of the node (if available) with an official event method
    if(typeof tNode.__fSelectHandler == "function"){
        oEvent = new vdf.events.JSEvent(this, oEventInfo);
        if(tNode.__fSelectHandler.call((tNode.__oSelectEnv || null), oEvent) === false){
            bContinue = false;
        }
        
        bContinue = (bContinue && !oEvent.bCanceled);
    }
    
    //  If select handler method wasn't canceled 
    if(bContinue && this.onSelect.fire(this, oEventInfo)){
        tPrevSelected = this.tSelectedNode;
    
        //  Select the new node
        this.tSelectedNode = tNode;
        
        if(tPrevSelected){
            this.updateNodeCSS(tPrevSelected);
        }
        this.updateNodeCSS(tNode);
        
        if(tNode.__eElement){
            this.scrollToElement(tNode.__eElement);
        }
        
        return true;
    }
    
    return false;
},


selectById : function(sId){
    var tNode = this.getNodeById(sId);
    
    if(tNode){
        this.select(tNode);
    }
},


scrollToElement : function(eElement){
    var iTop, iLeft, oElem, oDiv;
    
    oElem = vdf.sys.gui.getAbsoluteOffset(eElement);
    oDiv = vdf.sys.gui.getAbsoluteOffset(this.eElement);
    
    iTop = oElem.top - oDiv.top;
    
    if(iTop < this.eElement.scrollTop){
        this.eElement.scrollTop = iTop;
    }else if(iTop + eElement.clientHeight > this.eElement.scrollTop + this.eElement.clientHeight){
        this.eElement.scrollTop = iTop + eElement.clientHeight - this.eElement.clientHeight;
    }
},


getPosition : function(tNode){
    var aList, iPos;
    
    aList = (tNode.__tParent ? tNode.__tParent.__aSubItems : this.aRootItems);
    
    for(iPos = 0; iPos < aList.length; iPos++){
        if(aList[iPos] === tNode){
            return iPos;
        }
    }
    
    return -1;
},


isLast : function(tNode){
    var aList = (tNode.__tParent ? tNode.__tParent.__aSubItems : this.aRootItems);
    
    return (aList[aList.length - 1] === tNode);
},


isFirst : function(tNode){
    var aList = (tNode.__tParent ? tNode.__tParent.__aSubItems : this.aRootItems);
    
    return (aList[0] === tNode);
},



isRoot : function(tNode){
    return (tNode.__tParent ? false : true);
},


isParent : function(tNode, tParent){
    while(tNode){
        if(tNode === tParent){
            return true;
        }
        
        tNode = tNode.__tParent;
    }

    return false;
},


getLevel : function(tNode){
    var iLevel = 1;
    
    while(tNode.__tParent){
        iLevel++;
        tNode = tNode.__tParent;
    }
    
    return iLevel;
},


getNodeById : function(sNodeId){
	var iItem;

	for(iItem = 0; iItem < this.aItems.length; iItem++){
		if(this.aItems[iItem].sId === sNodeId){
            return this.aItems[iItem];
        }
	}
    
    return null;
},


hasChildren : function(tNode){
    return tNode.__aSubItems.length > 0;
},


getSelectedNode : function(){
    return this.tSelectedNode;
},


getSelectedNodeId : function(){
    return (this.tSelectedNode ? this.tSelectedNode.sId : null);
},

getSelectedNodeValue : function(){
    return (this.tSelectedNode ? this.tSelectedNode.sValue : null);
},



returnFocus : function(){
    if(this.eFocus){
        vdf.sys.dom.focus(this.eFocus);
    }
},


onItemClick : function(oEvent){
    var tNode = (oEvent.eSource && vdf.sys.dom.searchParent(oEvent.eSource, "tr")).tNode;
    
    if(tNode){
        if(this.tSelectedNode !== tNode){
            this.returnFocus();
            if(this.select(tNode)){
                //  Expand the node if we want to
                if(!tNode.bExpanded && this.hasChildren(tNode)){
                    this.doExpand(tNode);
                }
                oEvent.stop();
            }
        }
    }
},


onEnterAction : function(){
    if(!this.onEnter.fire(this, null)){
        return true;
    }else if(this.oParentControl && this.oParentControl.onEnter && this.oParentControl.onEnter.fire && !this.oForm.onEnter.fire(this, null)){
        return true;
    }
    
    return false;
},


onKey : function(oEvent){
    var oPressedKey = {
        iKeyCode : oEvent.getKeyCode(),
        bCtrl : oEvent.getCtrlKey(),
        bShift : oEvent.getShiftKey(),
        bAlt : oEvent.getAltKey()
    };

    try{
        if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.moveUp)){ 
            this.moveUp();
            oEvent.stop();
        }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.moveDown)){ 
            this.moveDown();
            oEvent.stop();
        }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.collapse)){ 
            this.collapse();
            oEvent.stop();
        }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.extend)){ 
            this.extend();
            oEvent.stop();
        }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.moveFirst)){ 
            this.moveFirst();
            oEvent.stop();
        }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.moveLast)){ 
            this.moveLast();
            oEvent.stop();
        }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.enter)){
            if(this.onEnterAction()){
                oEvent.stop();
            }
        }
    }catch (oError){
        vdf.errors.handle(oError);
    }
},


onFocus : function(oEvent){

    this.bHasFocus = true;
    this.bLozingFocus = false;
    if(this.eRootTable){
        this.eRootTable.className = "treeFocussed";
    }
},


onBlur : function(oEvent){
    var oTree = this;
    
    this.bLozingFocus = true;

    setTimeout(function(){
        if(oTree.bLozingFocus){
            oTree.bHasFocus = false;
            if(oTree.eRootTable){
                oTree.eRootTable.className = "";
            }
        }
    }, 200);
},


onGlobalClick : function(oEvent){
    this.returnFocus();
},


onExpandClick : function(oEvent){
    var tNode = oEvent.eSource.tNode;
    
    if(tNode){
        this.returnFocus();
        //  Switch expanded
        this.toggle(tNode);
    }
}

});




vdf.gui.AjaxTreeView = function(eElement, oParentControl){
    this.TreeView(eElement, oParentControl);
    
    
    this.sWebObject = this.getVdfAttribute("sWebObject", null, true);
    
    this.sWebServiceUrl = this.getVdfAttribute("sWebServiceUrl", "WebService.wso", true);
    
    
    this.bKnowChildren = this.getVdfAttribute("bKnowChildren", true, false);
    
    
    this.bLoadRoot = this.getVdfAttribute("bLoadRoot", true, false);
    
    
    this.onLoadNodes = new vdf.events.JSHandler();
    
};

vdf.definePrototype("vdf.gui.AjaxTreeView", "vdf.gui.TreeView", {


init : function(){
    this.TreeView.prototype.init.call(this);
    
    if(this.bLoadRoot){
        this.loadChildren(null);
    }
},


hasChildren : function(tNode){
    return (tNode.__aSubItems.length > 0 || (this.bKnowChildren ? tNode.bHasChildren && !tNode.__bChildrenLoaded : !tNode.__bChildrenLoaded));
},


reload : function(){
    this.clear();
    
    this.loadChildren(null);
},


doExpand : function(tNode){
    if(tNode.__bIsLoading){
        return;
    }

    //  Determine if subnodes need to be loaded
    if(tNode.__aSubItems.length === 0 && !tNode.__bChildrenLoaded && (!this.bKnowChildren || tNode.bHasChildren)){
        this.loadChildren(tNode);
    }else{
        //  Call the orrigional 
        this.TreeView.prototype.doExpand.call(this, tNode);
    }
},


expandAll : function(){
    //  TODO: Add load the complete tree functionallity
    
},


addNode : function(sId, sParentId, sName, sAltText, sIconClass, bExpanded, bHasChildren, sValue, fSelectHandler, oSelectEnv){
    var tNode = new vdf.dataStructs.TAjaxTreeNode();
    
    tNode.sId = sId;
    tNode.sValue = sValue || "";
    tNode.sParentId = sParentId;
    tNode.sName = sName;
    tNode.sAltText = sAltText || "";
    tNode.sIconClass = sIconClass || null;
    tNode.bExpanded = bExpanded || null;
    tNode.bHasChildren = bHasChildren || null;
    
    tNode.__fSelectHandler = fSelectHandler || null;
    tNode.__oSelectEnv = oSelectEnv || null;
    
    this.insertNode(tNode);
},


loadChildren : function(tNode){
    var oCall;

    if(tNode){
        tNode.__bIsLoading = true;
    }
    this.displayLoading(tNode);
    
    //  Give the application developer a change to append custom node loading code
    if(this.onLoadNodes.fire(this, { tNode : tNode, sParentId : (tNode && tNode.sId), sParentValue : (tNode && tNode.sValue) })){
        //  Send the call
        oCall = new vdf.ajax.JSONCall("LoadTreeNodes", null, this.sWebServiceUrl);
        oCall.addParam("sWebObject", this.sWebObject);
        oCall.addParam("sSessionKey", vdf.sys.cookie.get("vdfSessionKey"));
        oCall.addParam("sObjectName", this.sName);
        oCall.addParam("sParentId", (tNode ? tNode.sId : ""));
        oCall.addParam("sParentValue", (tNode ? tNode.sValue : ""));
        oCall.addParam("iLevel", (tNode ? this.getLevel(tNode) : 0));
        
        oCall.onFinished.addListener(this.handleLoadChildren, this);
        oCall.onError.addListener(this.handleLoadChildrenError, this);
        oCall.__tNode = tNode;
        
        oCall.send(true);
    }
},


handleLoadChildren : function(oEvent){
    var tResult, tParent, tNode, iNode;
    
    tResult = oEvent.oSource.getResponseValue();
    tParent = oEvent.oSource.__tNode;
    
    if(vdf.errors.checkServerError(tResult.aErrors, this)){
        //  Insert the new nodes into the tree
        for(iNode = 0; iNode < tResult.aNodes.length; iNode++){
            tNode = this.transformObjToStruct(tResult.aNodes[iNode]);
        
            //  Add autonumbers if needed
            tNode.sId = tResult.aNodes[iNode].sId || this.aItems.length;
            tNode.sParentId = tNode.sParentId || (tParent ? tParent.sId : "");
        
            this.insertNode(tNode);
        }
        
        this.loadingFinished(tParent, true);
    }else{
        this.loadingFinished(tParent, false);
    }
},


loadingFinished : function(tParent, bSuccess){
    if(tParent){
        if(bSuccess){
            //  Update the node's display and expand it
            tParent.__bIsLoading = false;
            this.hideLoading(tParent);

            this.updateNodeCSS(tParent);
            tParent.__bChildrenLoaded = true;
            
            this.TreeView.prototype.doExpand.call(this, tParent);
        }else{
            tParent.__bIsLoading = false;
            this.hideLoading(tParent);
        }
    }else{
        //  Update the global display and refresh
        this.hideLoading(null);
        this.refresh();
    }
},


handleLoadChildrenError : function(oEvent){
    var tParent = oEvent.oSource.__tNode;
    
    if(tParent){
        tParent.__bIsLoading = false;
        this.hideLoading(tParent);
    }
},


transformObjToStruct : function(oObj){
    var tNode = new vdf.dataStructs.TAjaxTreeNode();
    
    tNode.sName = oObj.sName;
	tNode.sAltText = oObj.sAltText;
    
    tNode.sId = oObj.sId;
    tNode.sValue = oObj.sValue;
    tNode.sIconClass = oObj.sIconClass;
    tNode.sParentId = oObj.sParentId;
    tNode.bExpanded = oObj.bExpanded;
    
    tNode.bHasChildren = oObj.bHasChildren;
    
    return tNode;
},


hasUnloadedItems : function(){
    var iNode;
    
    for(iNode = 0; this.aItems.length; iNode++){
        if(!this.aItems[iNode].__bChildrenLoaded){
            return true;
        }
    }
    
    return false;
},


displayLoading : function(tNode){
    if(tNode){
        this.updateNodeCSS(tNode);
    }else{
        this.eElement.className += " treeLoading";
    }    
},


hideLoading : function(tNode){
    if(tNode){
        this.updateNodeCSS(tNode);
    }else{
        this.eElement.className = this.eElement.className.replace("treeLoading");
    }
},


updateNodeCSS : function(tNode){
    this.TreeView.prototype.updateNodeCSS.call(this, tNode);
    
    if(tNode.__bIsLoading && tNode.__eElement){
        tNode.__eElement.cells[1].className = "treeIconLoading";
    }
}
    
});




vdf.settings = {
    
    iAjaxConcurrencyLimit : 2,

    
    formKeys : {
        findGT : {
            iKeyCode : 119,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        findLT : {
            iKeyCode : 118,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        findGE : {
            iKeyCode : 120,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        findFirst : {
            iKeyCode : 36,
            bCtrl : true,
            bShift : false,
            bAlt : false
        },
        findLast : {
            iKeyCode : 35,
            bCtrl : true,
            bShift : false,
            bAlt : false
        },
        save : {
            iKeyCode : 113,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        clear : {
            iKeyCode : 116,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        clearAll : {
            iKeyCode : 116,
            bCtrl : true,
            bShift : false,
            bAlt : false
        },
        remove : {
            iKeyCode : 113,
            bCtrl : false,
            bShift : true,
            bAlt : false
        },
        lookup : {
            iKeyCode : 115,
            bCtrl : false,
            bShift : false,
            bAlt : false
        }
    },
    
    
    listKeys : {
        scrollUp : {
            iKeyCode : 38,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        scrollDown : {
            iKeyCode : 40,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        scrollPageUp : {
            iKeyCode : 33,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        scrollPageDown : {
            iKeyCode : 34,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        scrollTop : {
            iKeyCode : 36,
            bCtrl : true,
            bShift : false,
            bAlt : false
        },
        scrollBottom : {
            iKeyCode : 35,
            bCtrl : true,
            bShift : false,
            bAlt : false
        },
        search : {
            iKeyCode : 70,
            bCtrl : true,
            bShift : false,
            bAlt : false
        },
        enter : {
            iKeyCode : 13,
            bCtrl : false,
            bShift : false,
            bAlt : false
        }
    },
    
    
    calendarKeys : {
        dayUp : {
            iKeyCode : 38,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        dayDown : {
            iKeyCode : 40,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        dayLeft : {
            iKeyCode : 37,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        dayRight : {
            iKeyCode : 39,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        monthUp : {
            iKeyCode : 33,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        monthDown : {
            iKeyCode : 34,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        yearUp : {
            iKeyCode : 33,
            bCtrl : true,
            bShift : false,
            bAlt : false
        },
        yearDown : {
            iKeyCode : 34,
            bCtrl : true,
            bShift : false,
            bAlt : false
        },
        enter : {
            iKeyCode : 13,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        close : {
            iKeyCode : 27,
            bCtrl : false,
            bShift : false,
            bAlt : false
        }
    },
    
    
    treeKeys : {
        moveUp : {
            iKeyCode : 38,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        moveDown : {
            iKeyCode : 40,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        collapse : {
            iKeyCode : 37,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        extend : {
            iKeyCode : 39,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        moveFirst : {
            iKeyCode : 36,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        moveLast : {
            iKeyCode : 35,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        enter : {
            iKeyCode : 13,
            bCtrl : false,
            bShift : false,
            bAlt : false
        }
    },
    
    spinKeys : {
        moveUp : {
            iKeyCode : 38,
            bCtrl : false,
            bShift : false,
            bAlt : false
        },
        moveDown : {
            iKeyCode : 40,
            bCtrl : false,
            bShift : false,
            bAlt : false
        }
    }
};
vdf.register("vdf.settings");




vdf.sys = {


isSafari : false,

isChrome : false,

isOpera : false,

isMoz : false,

isIE : false,

isWebkit : false,


iVersion : 0,


ref : {


getType : function(oObject){
    var sType = typeof(oObject);

    if(sType === "object"){
        if(oObject === null || typeof(oObject) === "undefined"){
            sType = "null";
        }else if(oObject.constructor === Array){
            sType = "array";
        }else if(oObject.constructor === Date){
            sType = "date";
        }else{
            sType = this.getConstructorName(oObject);
        }
    }

    return sType;
},


getConstructorName : function(oObject){
    var sName = this.getMethodName(oObject.constructor);

    if(sName === ""){
        sName = "object";
    }

    return sName;
},


getMethodName : function(fFunction){
    var sString;

    try {
        sString = fFunction.toString();
        return sString.substring(sString.indexOf("function") + 8, sString.indexOf('(')).replace(/ /g,'');
    }catch(e){
        return "";
    }
},


matchByValues : function(oObj1, oObj2){
    var sProp;

    if(oObj1 !== oObj2){
        //  Check if no null values given
        if(oObj1 === null || typeof(oObj1) === "undefined" || oObj2 === null || typeof(oObj2) === "undefined"){
            return false;
        }

        //  Check if properties match
        for(sProp in oObj1){
            if(typeof(oObj2[sProp]) === "undefined" || oObj1[sProp] !== oObj2[sProp]){
                return false;
            }
        }

        for(sProp in oObj2){
            if(typeof(oObj1[sProp]) === "undefined" || oObj1[sProp] !== oObj2[sProp]){
                return false;
            }
        }
    }

    return true;

},


getGlobalObject : function(){
    return (function(){
        return this;
    }).call(null);
},


getNestedObjProperty : function(sPath){
    var aParts, oProp, iPart;

    //  Split into parts
    aParts = sPath.split(".");

    //  We start our search at the global object
    oProp = vdf.sys.ref.getGlobalObject();

    //  Loop through parts and object properties
    for(iPart = 0; iPart < aParts.length; iPart++){
        if(typeof oProp === "object" && oProp !== null){
            oProp = oProp[aParts[iPart]];
        }else{
            return null;
        }
    }

    return oProp;
}

},


math : {

padZero : function(iNum, iDigits)
{
    var sResult = "" + iNum;

    while(sResult.length < iDigits){
        sResult = "0" + sResult;
    }

    return sResult;
},


unique : function(aSet){
    var i, x, n, y, aResult = [];
    o:for(i = 0, n = aSet.length; i < n; i++){
        for(x = 0, y = aResult.length; x < y; x++){
            if(aResult[x] === aSet[i]){
                continue o;
            }
        }
        aResult[aResult.length] = aSet[i];
    }
    return aResult;
}

},


data : {


applyDateMask : function(dValue, sMask, sDateSeparator){
    return sMask.replace(/(m{1,4}|d{1,4}|yyyy|yy|\/)/gi, function (sValue, iPos){

        switch(sValue.toLowerCase()){
            case "m":
                return dValue.getMonth() + 1;
            case "mm":
                return vdf.sys.math.padZero(dValue.getMonth() + 1, 2);
            case "mmm":
                return vdf.sys.string.copyCase(vdf.lang.translations.calendar.monthsShort[dValue.getMonth()], sValue);
            case "mmmm":
                return vdf.sys.string.copyCase(vdf.lang.translations.calendar.monthsLong[dValue.getMonth()], sValue);

            case "d":
                return dValue.getDate();
            case "dd":
                return vdf.sys.math.padZero(dValue.getDate(), 2);
            case "ddd":
                return vdf.sys.string.copyCase(vdf.lang.translations.calendar.daysShort[dValue.getDay()], sValue);
            case "dddd":
                return vdf.sys.string.copyCase(vdf.lang.translations.calendar.daysLong[dValue.getDay()], sValue);

            case "yy":
                return vdf.sys.math.padZero(dValue.getFullYear() % 100, 2);
            case "yyyy":
                return vdf.sys.math.padZero(dValue.getFullYear(), 4);

            case "/":
                return sDateSeparator;
        }

        return sValue;
    });
},


parseStringToDate : function(sValue, sFormat, sDateSeparator){
    var dResult, dToday, iChar, aMask, aData, sChar, iPart, iDate, iMonth, iYear;

    sFormat = sFormat.toLowerCase();

    if(vdf.sys.string.trim(sValue) === ""){
        return null;
    }

    //  Determine separator if its not given
    if(typeof sDateSeparator !== "string"){
        for(iChar = 0; iChar < sFormat.length; iChar++){
            sChar = sFormat.charAt(iChar).toLowerCase();
            if(sChar !== "m" && sChar !== "d" && sChar !== "y"){
                sDateSeparator = sChar;
                break;
            }
        }
    }

    //  Split the date
    aMask = sFormat.toLowerCase().split(sDateSeparator);
    aData = sValue.toLowerCase().split(sDateSeparator);

    //  Loop throught the parts finding the year, date and month
    for(iPart = 0; iPart < aData.length && iPart < aMask.length; iPart++){
        switch(aMask[iPart]){
            case "d":
            case "dd":
                iDate = parseInt(aData[iPart], 10);
                break;
            case "m":
            case "mm":
                iMonth = parseInt(aData[iPart], 10);
                break;
            case "yy":
                iYear = parseInt(aData[iPart], 10);
                iYear = (iYear > 50 ? iYear + 1900 : iYear + 2000);
                break;
            case "yyyy":
                iYear = parseInt(aData[iPart], 10);
                break;
        }
    }

    //  Set the determined values to the new data object, decrement if to high
    dResult = new Date(1, 1, 1, 1, 1, 1);
    dToday = new Date();

    //  Year
    if(iYear){
        if(iYear > 9999){
            iYear = 9999;
        }
        if(iYear < -9999){
            iYear = 0;
        }
        dResult.setFullYear((iYear > 9999 ? 9999 : (iYear < 0 ? 0 : iYear)));
    }else{
        dResult.setFullYear(dToday.getFullYear());
    }

    //  Month
    if(iMonth){
        dResult.setMonth((iMonth < 0 ? 0 : (iMonth > 12 ? 11 : iMonth - 1)));
    }else{
        dResult.setMonth(dToday.getMonth());
    }

    //  Date
    if(iDate){
        iDate = (iDate < 1 ? 1 : (iDate > 31 ? 31 : iDate));
    }else{
        iDate = dToday.getDate();
    }

    //  Make sure that it didn't shifted the month (retry and reduce the day until it doesn't);
    iMonth = dResult.getMonth();
    iYear = dResult.getFullYear();
    dResult.setDate(iDate);
    while(dResult.getMonth() !== iMonth){
        dResult.setFullYear(iYear);
        dResult.setMonth(iMonth);
        iDate--;
        dResult.setDate(iDate);
    }





    return dResult;
},


parseDateToString : function(dValue, sFormat){
    return this.applyDateMask(dValue, sFormat, "/");
},


deepClone : function(oObj){
    var oResult = null, sProp, i;


    if(typeof(oObj) === "object"){
        if(oObj.constructor === Array){
            oResult = [];

            for(i = 0; i < oObj.length; i++){
                oResult.push(this.deepClone(oObj[i]));
            }
        }else{
            oResult = { };

            for(sProp in oObj){
                //  TODO: Think about adding hasOwnProperty check here
                oResult[sProp] = this.deepClone(oObj[sProp]);
            }
        }
    }else{
        oResult = oObj;
    }

    return oResult;
},


removeFromArray : function(aArray, oObj){
    var i;
    
    for(i = 0; i < aArray.length; i++){
        if(aArray[i] === oObj){
            aArray.splice(i, 1);
        }
    }
},


formatRegExp : /{{([0-1a-zA-Z]+)}}/gi,

format : function(sStr, oReps){
    var reps = oReps || { };
    
    
    return sStr.replace(this.formatRegExp, function(str, p1, offset, s){
        if(reps.hasOwnProperty(p1)){
            return reps[p1];
        }else{
            return str;
        }
    });
}
},


xml : {


parseSoapDate : function(sDate){
    var dDate, aParts;

    dDate = new Date();
    aParts = sDate.split(/[\-T:.]/);

    dDate.setFullYear(aParts[0]);
    dDate.setMonth(aParts[1]);
    dDate.setDate(aParts[2]);
    if(aParts.length > 3){
        dDate.setHours(aParts[3]);
        dDate.setMinutes(aParts[4]);
        dDate.setSeconds(aParts[5]);
        dDate.setMilliseconds(aParts[6]);
    }else{
        dDate.setHours(0);
        dDate.setMinutes(0);
        dDate.setSeconds(0);
        dDate.setMilliseconds(0);
    }

    return dDate;
},


getNodeName : function(oNode){
    //return oNode.nodeName.substr(oNode.nodeName.indexOf(":") + 1);
    return oNode.nodeName.replace(/.*:/, "");
},


parseXmlString : function(sString){
    var oDoc = null, oParser;

    if(window.DOMParser){
        // code for Mozilla, Firefox, Opera, etc.
        oParser = new DOMParser();
        oDoc = oParser.parseFromString(sString, "text/xml");
    }else if(window.ActiveXObject){
        // code for IE
        oDoc=new ActiveXObject("Microsoft.XMLDOM");
        oDoc.async="false";
        oDoc.loadXML(sString);
    }else{
        throw new vdf.errors.Error(0, "Browser doesn't support XML parsing!");
    }

    return oDoc;
},


getXMLRequestObject : function(){
    var oResult = null;

    if(window.XMLHttpRequest){
        //  code for Mozilla, Opera, WebKit, IE7+
        oResult = new XMLHttpRequest();
    }else if(window.ActiveXObject){
        //  code for IE6-
        try {
            oResult = new ActiveXObject("Msxml2.XMLHTTP");
        } catch (e) {
            try {
                oResult = new ActiveXObject("Microsoft.XMLHTTP");
            } catch (E) {
                throw new vdf.errors.Error(0, "Browser doesn't support the XMLHttpRequest!");
            }
        }
    }

    return oResult;
},


find : function(oNode, sNodeName, sPrefix){
    var aResult;

    if(typeof(sPrefix) === "undefined"){
        sPrefix = "m";
    }

    //  FF also requires prefix since version 3 so the version check is removed, this makes firefox 2 and older perform finds always twice, so upgrade!
    aResult = oNode.getElementsByTagName(sPrefix + ":" + sNodeName);

    if(aResult === null || typeof(aResult) === "undefined" || aResult.length === 0){
        aResult = oNode.getElementsByTagName(sNodeName);
    }

    return aResult;
},


findContent : function(oNode, sNodeName, sPrefix){
    var oXml, result = "";

    oXml = this.find(oNode, sNodeName, sPrefix)[0];

    if(oXml !== null && typeof(oXml) !== "undefined"){
        for (var iCount=0; iCount<oXml.childNodes.length; iCount++){
            result += oXml.childNodes[iCount].nodeValue;
        }
    }

    if(typeof(result) === "undefined"){
        result = "";
    }

    return result;
}

},


cookie : {


set : function(sVar, sValue){
    var date = new Date();
    
    date.setDate(date.getDate()+2);

    document.cookie = sVar + "=" + sValue + "; expires=" + date.toGMTString();	
},


del : function(sVar){
    var date = new Date();
    
    date.setTime(date.getTime()-1);

    document.cookie = sVar + "=; expires=" + date.toGMTString();		
},


get : function(sVar, sDefault){
    var sResult = null, aVars, aVar, iVar;
    
    if(document.cookie){
        aVars = document.cookie.split(';');
        
        for(iVar = 0; iVar < aVars.length && sResult === null; iVar++){
            aVar = aVars[iVar].split('=');
            
            if(aVar.length > 1){
                if(vdf.sys.string.trim(aVar[0]) === vdf.sys.string.trim(sVar)){
                    sResult = aVar[1];	
                }
            }
        }
    }
    
    if(sResult !== null){
        return sResult;
    }else{
        return sDefault;
    }
}


},


dom : {


aTabbableTags : ["A","BUTTON","TEXTAREA","INPUT","IFRAME", "SELECT"],

oTabbableTags : {"A" : true,"BUTTON" : true,"TEXTAREA" : true,"INPUT" : true,"IFRAME" : true, "SELECT" : true},


setElementText : function(eElement, sValue){
    if(sValue === " "){
        eElement.innerHTML = "&nbsp;";
    }else{
        if(typeof(eElement.innerText) !== "undefined"){
            eElement.innerText = sValue;
        }else{
            eElement.textContent = sValue;
        }
    }
},


getElementText : function(eElement){
     if(typeof(eElement.innerText) !== "undefined"){
        return eElement.innerText;
    }else{
        return eElement.textContent;
    }
},


getOuterHTML : function(eElem){
	var eParent, eFake, sHTML;
	
	if(eElem.outerHTML){
		return eElem.outerHTML;
	}else if(eElem.parentNode){
		eParent = eElem.parentNode;
		eFake = document.createElement(eParent.tagName);

		eFake.appendChild(eElem);
		sHTML = eFake.innerHTML;
		eParent.appendChild(eElem);

		return sHTML;
	}else{
		return null;
	}
},


deepClone : function(eOrig){
    var eClone, fChecker;

    eClone = eOrig.cloneNode(true);
    
    fChecker = function(eClone, eOrig){
        var iChild;
        
        if(eClone.tagName === "SELECT" || eClone.tagName === "TEXTAREA"){
            eClone.value = eOrig.value;
        }
        
        for(iChild = 0; iChild < eClone.childNodes.length; iChild++){
            if(eClone.childNodes[iChild].nodeType !== 3 && eClone.childNodes[iChild].nodeType !== 8){
                fChecker(eClone.childNodes[iChild], eOrig.childNodes[iChild]);
            }
        }
    };
    
    fChecker(eClone, eOrig);
    
    return eClone;
},


swapNodes : function(eOrig, eNew){
    if (eOrig){
        if (eNew){
            if(typeof(eOrig.replaceNode) !== "undefined"){
                eOrig.replaceNode(eNew);
            }else{
                eOrig.parentNode.replaceChild(eNew, eOrig);
            }
        }
    }
},


insertAfter : function(eNewElement, eElement){
    if(eElement.nextSibling !== null){
        eElement.parentNode.insertBefore(eNewElement, eElement.nextSibling);
    }else{
        eElement.parentNode.appendChild(eNewElement);
    }
},


isParent : function(eStart, eSearch){
    if(eStart === null){
        return false;
    }else if(eStart === eSearch){
        return true;
    }else if(typeof(eStart.parentNode) !== "undefined"){
        return this.isParent(eStart.parentNode, eSearch);
    }else{
        return false;
    }
},


searchParent : function(eElem, sTagName){
    sTagName = sTagName.toUpperCase();

    if(eElem.tagName === sTagName){
        return eElem;
    }else if(typeof(eElem.parentNode) !== "undefined" && eElem !== document){
        return this.searchParent(eElem.parentNode, sTagName);
    }else{
        return null;
    }
},


searchParentByVdfAttribute : function(eElement, sAttribute, sSearchValue){
    if(eElement !== window.document){
        var sValue = vdf.getDOMAttribute(eElement, sAttribute, null);

        if(sValue !== null && (sValue === sSearchValue || sSearchValue === null || typeof(sSearchValue) === "undefined")){
            return eElement;
        }else if(eElement.parentNode !== null){
            return this.searchParentByVdfAttribute(eElement.parentNode, sAttribute, sSearchValue);
        }
    }

    return null;
},


focus : function(eElement, bSelect){
    try {
        eElement.focus();
        if(bSelect && eElement.select){
            eElement.select();
        }
        
        if(typeof(eElement.setActive) === "function"){
            eElement.setActive();
        }
    } catch (err) {
        //ignore focus error
    }


},


getCaretPosition : function(eField) {
    // Initialize
    var oSelection, oSelection2, iSelection;

    try{
        // IE Support
        if(document.selection){
            if (eField.tagName.toLowerCase() == "textarea"){
                oSelection = document.selection.createRange();
                oSelection2 = oSelection.duplicate();
                
                oSelection2.moveToElementText(eField);
                oSelection2.setEndPoint('StartToEnd', oSelection);
                
                return eField.value.length - oSelection2.text.length
            }else{
                // Set focus on the element
                eField.focus();

                // To get cursor position, get empty selection range
                oSelection = document.selection.createRange();

                iSelection = oSelection.text.length;

                // Move selection start to 0 position
                oSelection.moveStart('character', -eField.value.length);

                // The caret position is selection length
                return oSelection.text.length - iSelection;
            }
        }else if(eField.selectionStart || eField.selectionStart == '0'){  // Firefox support
            return eField.selectionStart;
        }

    }catch (e){

    }

    // Return results
    return 0;
},


getSelectionLength : function(eField){
    var oBookmark, oSelection;

    try{
        if(eField.selectionStart || eField.selectionStart === 0){ //  Mozilla / Opera / Safari / Chrome
            return eField.selectionEnd - eField.selectionStart;
        }else if(document.selection){ //  Internet Explorer
            oBookmark = document.selection.createRange().getBookmark();
            oSelection = eField.createTextRange();
            oSelection.moveToBookmark(oBookmark);

            return oSelection.text.length;
        }
    }catch (e){

    }

    return 0;
},



setCaretPosition : function(eField, iCaretPos){
    try{

        // IE Support
        if(document.selection){

            // Set focus on the element
            eField.focus();

            // Create empty selection range
            var oSel = document.selection.createRange();

            // Move selection start and end to 0 position
            oSel.moveStart('character', -eField.value.length);
            oSel.moveEnd('character', -eField.value.length);

            // Move selection start and end to desired position
            oSel.moveStart('character', iCaretPos);
            oSel.select();
        }else if(eField.selectionStart || eField.selectionStart == '0'){ // Firefox support
            eField.selectionStart = iCaretPos;
            eField.selectionEnd = iCaretPos;
            eField.focus();
        }
    }catch (e){

    }
},


getFirstFocusChild : function(eElement){
    var eResult = null;

    if(typeof(eElement.tagName) === "string"){
        if(this.oTabbableTags[eElement.tagName] === true){
            return eElement;
        }
    }

    //  Scan child elements
    vdf.sys.dom.loopChildren(eElement, function(eChild){
        eResult = this.getFirstFocusChild(eChild);

        if(eResult !== null){
            return false;
        }
    }, this);

    return eResult;
},


loopChildren : function(eElement, fWorker, oEnv){
    var iChild;

    //  Go into children
    if(eElement.childNodes){
        for(iChild = 0; iChild < eElement.childNodes.length; iChild++){
            if(eElement.childNodes[iChild].nodeType !== 3 && eElement.childNodes[iChild].nodeType !== 8){
                if(fWorker.call((oEnv ? oEnv : this), eElement.childNodes[iChild]) === false){
                    return false;
                }
            }
        }
    }
    
    return true;
},


ready : function(fWorker, oEnv){
    function call(){
        fWorker.call((oEnv ? oEnv : null));
    }

    if (navigator.appVersion.match("MSIE") && document.readyState === "complete"){
        call();
    }else{
        //  Attach the listener
        if(window.addEventListener){ // W3C
            window.addEventListener("load", call, false);
        }else{ // IE
            window.attachEvent("onload", call);
        }
    }

}
},


gui : {


hideSelectBoxes : function(eObject, eContent){
    var iTop, iBottom, iLeft, iRight, oAllSelects, iTopSelect;
    var iBottomSelect, iLeftSelect, iRightSelect, sVisibilityState;
    var iVisibilityCount, i;

    if(typeof(eContent) === "undefined"){
        eContent = null;
    }

    if(typeof(eObject) === "object"){
        // check to see if this is IE version 6 or lower. hide select boxes if so
        if(vdf.sys.isIE && vdf.sys.iVersion <= 6){

            //  Determine coordinates for element
            iTop = this.getAbsoluteOffsetTop(eObject);
            iBottom = iTop + eObject.offsetHeight;
            iLeft = this.getAbsoluteOffsetLeft(eObject);
            iRight = iLeft + eObject.offsetWidth;

            //  Loop through all selects
            oAllSelects = document.getElementsByTagName("select");
            for(i = 0; i < oAllSelects.length; i++){

                //  Check vertical position
                iTopSelect = this.getAbsoluteOffsetTop(oAllSelects[i]);
                iBottomSelect = this.getAbsoluteOffsetTop(oAllSelects[i]) + oAllSelects[i].offsetHeight;
                if(((iTopSelect > iTop && iTopSelect < iBottom) || (iBottomSelect > iTop && iBottomSelect < iBottom)) || (iTopSelect < iTop && iBottomSelect > iBottom)){

                    //  Check horizontal position
                    iLeftSelect= this.getAbsoluteOffsetLeft(oAllSelects[i]);
                    iRightSelect= this.getAbsoluteOffsetLeft(oAllSelects[i]) + oAllSelects[i].offsetWidth;
                    if((iLeftSelect > iLeft && iLeftSelect<iRight || (iRightSelect > iLeft && iRightSelect<iRight)) || (iLeftSelect<iLeft && iRightSelect>iRight)){

                        //  Special check if the select isn't inside the content element
                        if(eContent === null || !vdf.sys.dom.isParent(oAllSelects[i], eContent)){

                            //  Check if already hidden, if so increase visibillity count
                            sVisibilityState = oAllSelects[i].getAttribute("VisibilityState");
                            if(sVisibilityState){
                                iVisibilityCount = parseInt(oAllSelects[i].getAttribute("VisibilityCount"), 10);
                                oAllSelects[i].setAttribute("VisibilityCount",iVisibilityCount+1);
                            }else{
                                //  Hide and store current visibility state
                                if(oAllSelects[i].style.visibility){
                                    sVisibilityState = oAllSelects[i].style.visibility;
                                }else{
                                    sVisibilityState = "";
                                }
                                
                                if(sVisibilityState !== "hidden"){
                                    oAllSelects[i].setAttribute("VisibilityState", sVisibilityState);
                                    oAllSelects[i].setAttribute("VisibilityCount", "1");
                                    oAllSelects[i].style.visibility = "hidden";
                                }
                            }
                        }
                    }
                }
            }
        }
    }
},


displaySelectBoxes : function(eObject, eContent){
    var iTop, iBottom, iLeft, iRight, oAllSelects, iTopSelect;
    var iBottomSelect, iLeftSelect, iRightSelect, sVisibilityState;
    var iVisibilityCount, i;

    if(typeof(eContent) === "undefined"){
        eContent = null;
    }

    if(typeof(eObject) === "object"){
        // check to see if this is IE version 6 or lower. display select boxes if so
        if(vdf.sys.isIE && vdf.sys.iVersion <= 6){

            //  Determine dimentions of object
            iTop = this.getAbsoluteOffsetTop(eObject);
            iBottom = iTop + eObject.offsetHeight;
            iLeft = this.getAbsoluteOffsetLeft(eObject);
            iRight = iLeft + eObject.offsetWidth;

            //  Loop through all selects
            oAllSelects = document.getElementsByTagName("select");
            for(i = 0; i < oAllSelects.length; i++){

                //  Check vertical position
                iTopSelect = this.getAbsoluteOffsetTop(oAllSelects[i]);
                iBottomSelect = this.getAbsoluteOffsetTop(oAllSelects[i]) + oAllSelects[i].offsetHeight;
                if(((iTopSelect > iTop && iTopSelect < iBottom) || (iBottomSelect > iTop && iBottomSelect < iBottom)) || (iTopSelect < iTop && iBottomSelect > iBottom)){

                    //  Check horizontal position
                    iLeftSelect = this.getAbsoluteOffsetLeft(oAllSelects[i]);
                    iRightSelect = this.getAbsoluteOffsetLeft(oAllSelects[i]) + oAllSelects[i].offsetWidth;
                    if((iLeftSelect > iLeft && iLeftSelect < iRight || (iRightSelect > iLeft && iRightSelect<iRight)) || (iLeftSelect < iLeft && iRightSelect > iRight)){

                        //  Special check if the select isn't inside the content element
                        if(eContent === null || !vdf.sys.dom.isParent(oAllSelects[i], eContent)){

                            //  Check if hidden, if so decrement counter and redisplay
                            sVisibilityState = oAllSelects[i].getAttribute("VisibilityState");
                            if(typeof sVisibilityState !== "undefined"){
                                iVisibilityCount = parseInt(oAllSelects[i].getAttribute("VisibilityCount"), 10);
                                if(iVisibilityCount <= 1){
                                    oAllSelects[i].removeAttribute("VisibilityCount");
                                    oAllSelects[i].style.visibility = sVisibilityState;
                                    oAllSelects[i].removeAttribute("VisibilityState");
                                }else{
                                    oAllSelects[i].setAttribute("VisibilityCount", iVisibilityCount - 1);	
                                }
                            }
                        }
                    }
                }
            }
        }
    }	
},


disableTabIndexes : function(eElement){
    var iTag, iElem, aElements;

    for(iTag = 0; iTag < vdf.sys.dom.aTabbableTags.length; iTag++){
        aElements = eElement.getElementsByTagName(vdf.sys.dom.aTabbableTags[iTag]);

        for(iElem = 0; iElem < aElements.length; iElem++){
            if(aElements[iElem].getAttribute("_origTabIndex") === null){
                aElements[iElem].setAttribute("_origTabIndex", aElements[iElem].tabIndex);
                aElements[iElem].tabIndex = "-1";
            }
        }
    }
},


restoreTabIndexes : function(eElement){
    var iTag, iElem, aElements;

    for(iTag = 0; iTag < vdf.sys.dom.aTabbableTags.length; iTag++){
        aElements = eElement.getElementsByTagName(vdf.sys.dom.aTabbableTags[iTag]);

        for(iElem = 0; iElem < aElements.length; iElem++){
            if(aElements[iElem].getAttribute("_origTabIndex") !== null){
                aElements[iElem].tabIndex = aElements[iElem].getAttribute("_origTabIndex");
                aElements[iElem].removeAttribute("_origTabIndex");
            }
        }
    }
},


getAbsoluteOffsetLeft : function(eElement){
    return this.getAbsoluteOffset(eElement).left;
},


getAbsoluteOffsetTop : function(eElement){
   return this.getAbsoluteOffset(eElement).top;
},


getAbsoluteOffset : function(eElement){
    var oReturn = { left : 0, top : 0 };
    var bFirst = true;

    if (eElement.offsetParent){
        while (eElement && (bFirst || vdf.sys.gui.getCurrentStyle(eElement).position !== "absolute") && vdf.sys.gui.getCurrentStyle(eElement).position !== "fixed" && vdf.sys.gui.getCurrentStyle(eElement).position !== "relative"){
            bFirst = false;
            oReturn.top += eElement.offsetTop;
            oReturn.left += eElement.offsetLeft;
            eElement = eElement.offsetParent;
        }
    }else if (eElement.y){
        oReturn.left += eElement.x;
        oReturn.top += eElement.y;
    }

    return oReturn;

},


getViewportHeight : function(){
    if (typeof(window.innerHeight) !== "undefined"){
        return window.innerHeight;
    }

    if (document.compatMode === "CSS1Compat"){
        return document.documentElement.clientHeight;
    }
    if (document.body){
        return document.body.clientHeight;
    }
    return null;
},


getViewportWidth : function(){
    if (document.compatMode=='CSS1Compat'){
        return document.documentElement.clientWidth;
    }
    if (document.body){
        return document.body.clientWidth;
    }
    if (typeof(window.innerWidth) !== "undefined"){
        return window.innerWidth;
    }
    
    return null;
},


getSize : function(eElem){
    if(vdf.sys.isIE || vdf.sys.isWebkit){
        return { width : eElem.offsetWidth, height : eElem.offsetHeight }
    }else{
        var oStyle = vdf.sys.gui.getCurrentStyle(eElem);
        return { width : parseInt(oStyle.getPropertyValue("width"), 10), height : parseInt(oStyle.getPropertyValue("height"), 10) }
    }
},


disableTextSelection : function(eElement){
    eElement.onselectstart = function() {
        return false;
    };
    eElement.unselectable = "on";
    eElement.style.MozUserSelect = "none";
},


getOpacity : function(eElement, bCurrent){
    var oStyle = (bCurrent ? vdf.sys.gui.getCurrentStyle(eElement) : eElement.style);

    if(oStyle.opacity){
        return oStyle.opacity * 100;
    }else if(typeof(oStyle.filter) === "string" && oStyle.filter.search("opacity=") >= 0){
        return parseInt(oStyle.filter.substr(oStyle.filter.search("opacity=") + 8, 4), 10);
    }

    return 100;
},


setOpacity : function(eElement, iOpacity){
    if(typeof eElement.style.opacity !== "undefined"){
        eElement.style.opacity = parseFloat(iOpacity) / 100.0;
    }else{
        eElement.style.filter = "alpha(opacity=" + iOpacity + ")";
    }
},


parseColor : function(sString){
    var aBits, rRGB, oResult = { iR : 0, iG : 0, iB : 0 };

    //  Parse color string
    sString = sString.toLowerCase();
    if(sString.charAt(0) == "#"){
        if(sString.length > 4){
            oResult.iR = parseInt(sString.substr(1, 2), 16);
            oResult.iG = parseInt(sString.substr(3, 2), 16);
            oResult.iB = parseInt(sString.substr(5, 2), 16);
        }else{
            oResult.iR = parseInt(sString.substr(1, 2), 16);
            oResult.iG = parseInt(sString.substr(2, 2), 16);
            oResult.iB = parseInt(sString.substr(3, 2), 16);
        }
    }else if(sString.substr(0, 3) === "rgb"){
        rRGB = /^rgb\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3})\)$/;
        aBits = rRGB.exec(sString);
        oResult.iR = parseInt(aBits[1], 10);
        oResult.iG = parseInt(aBits[2], 10);
        oResult.iB = parseInt(aBits[3], 10);
    }

    //  Function to create hex
    oResult.toHex = function(){
        var sR = parseInt(this.iR, 10).toString(16);
        var sG = parseInt(this.iG, 10).toString(16);
        var sB = parseInt(this.iB, 10).toString(16);
        if (sR.length == 1){
            sR = '0' + sR;
        }
        if (sG.length == 1){
            sG = '0' + sG;
        }
        if (sB.length == 1){
            sB = '0' + sB;
        }
        return '#' + sR + sG + sB;
    };

    //  Function to create rgb
    oResult.toRGB = function(){
        return 'rgb(' + parseInt(this.iR, 10) + ', ' + parseInt(this.iG, 10) + ', ' + parseInt(this.iB, 10) + ')';
    };

    return oResult;
},


getCurrentStyle : function(eElem){
    return (typeof(window.getComputedStyle) === "function" ? window.getComputedStyle(eElem, null) : eElem.currentStyle);
},



getPropCurrentStyle : function (eElem){
    var oResult = {}, oStyle, i, sKey, fReplace, sNewKey;
    
    fReplace = function(sAll, sLetter){
        return sLetter.toUpperCase();
    };
    
    oStyle = (typeof(window.getComputedStyle) === "function" ? window.getComputedStyle(eElem, null) : eElem.currentStyle);
    
    if(oStyle.length && oStyle[0] && oStyle[oStyle[0]]){
        for(i = 0; i < oStyle.length; i++){
            sKey = oStyle[i];
            if (typeof(oStyle[sKey]) === 'string'){
                sNewKey = sKey.replace(/\-(\w)/g, fReplace);
                oResult[sNewKey] = oStyle[sKey];
            }
        }
    }else{
        for(sKey in oStyle){
            if (typeof(oStyle[sKey]) === 'string' && isNaN(sKey)){
                oResult[sKey] = oStyle[sKey];
            }
        }
    }
    
    return oResult;
},


addClass : function(eElem, sClass){
    var aClasses, sClassName, i;
    if(eElem.className){
        aClasses = (sClass || "").split(/\s+/);
        sClassName = " " + eElem.className + " ";
        for(i = 0; i < aClasses.length; i++){
            if(sClassName.indexOf(" " + aClasses[i] + " ") < 0){
                sClassName += " " + aClasses[i];
            }
        }
        eElem.className = vdf.sys.string.trim(sClassName);
    }else{
        eElem.className = sClass;
    }
},


removeClass : function(eElem, sClass){
    var aClasses, sClassName, i;
    if(eElem.className){
        sClass = " " + sClass + " ";
        aClasses = eElem.className.split(/\s+/);
        sClassName = "";
        for(i = 0; i < aClasses.length; i++){
            if(sClass.indexOf(" " + aClasses[i] + " ") < 0){
                sClassName += " " + aClasses[i];
            }
        }
        eElem.className = vdf.sys.string.trim(sClassName);
    }
},


initCSS : function(){
    var sClass;

    if(vdf.sys.isIE){
        sClass = "vdf-ie";
        
        sClass = "vdf-ie" + (vdf.sys.iVersion <= 6 ? " vdf-ie6" : (vdf.sys.iVersion <= 7 ? " vdf-ie7" : (vdf.sys.iVersion <= 8 ? " vdf-ie8" : " vdf-ie9")));
    }else if(vdf.sys.isSafari){
        sClass = "vdf-safari";
    }else if(vdf.sys.isChrome){
        sClass = "vdf-chrome";
    }else if(vdf.sys.isOpera){
        sClass = "vdf-opera";
    }else if(vdf.sys.isMoz){
        sClass = "vdf-mozilla";
    }

    if(vdf.sys.isWebkit){
        sClass += " vdf-webkit";
    }

    document.body.className = document.body.className + " " + sClass;
}

},


string : {


trim : function(sString){
    return sString.replace(/^\s+|\s+$/g,"");
},


ltrim : function(sString){
    return sString.replace(/^\s+/,"");
},


rtrim : function(sString){
    return sString.replace(/\s+$/,"");
},


copyCase : function(sValue, sSample){
    var bUpper, iChar, sResult = "";

    for(iChar = 0; iChar < sValue.length; iChar++){
        bUpper = (iChar < sSample.length ? sSample.charAt(iChar) === sSample.charAt(iChar).toUpperCase() : bUpper);

        sResult += (bUpper ? sValue.charAt(iChar).toUpperCase() : sValue.charAt(iChar).toLowerCase());
    }

    return sResult;
},


encodeHtml : function(sValue){
    return (sValue || "").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

},


nothing : function(){

}

};



if(navigator.userAgent.indexOf("Chrome") >= 0){
    vdf.sys.isChrome = true;
    vdf.sys.iVersion = parseFloat(navigator.appVersion.substr(navigator.appVersion.indexOf("Chrome/") + 7));
}else if (navigator.userAgent.indexOf("Safari") >= 0){
    vdf.sys.isSafari = true;
    vdf.sys.iVersion = parseFloat(navigator.appVersion.substr(navigator.appVersion.indexOf("Version/") + 8));
}else if (navigator.product === "Gecko"){
    vdf.sys.isMoz = true;
    vdf.sys.iVersion = parseFloat(navigator.userAgent.substr(navigator.userAgent.indexOf("Firefox/") + 8));
}else if (navigator.userAgent.indexOf("Opera") >= 0){
    vdf.sys.isOpera = true;
    vdf.sys.iVersion = parseFloat(navigator.appVersion);
}else{
    vdf.sys.isIE = true;
    vdf.sys.iVersion = parseInt(navigator.appVersion.substr(navigator.appVersion.indexOf("MSIE") + 4), 10);
}

if (navigator.userAgent.indexOf("AppleWebKit") >= 0){
    vdf.sys.isWebkit = true;
}

//  Make sure that the autoInit function after the DOM is initialized (Which can be in the future but also can be right now)
vdf.sys.dom.ready(vdf.sys.gui.initCSS);



vdf.register("vdf.sys");

vdf.sys.fx = {


valRegex : /^([+\-]=)?([\d+\-.]+)(.*)$/,


skipStyles : {
    outlineColor : true,
    scrollbarBaseColor : true
},


createEffect : function(oProps, oSet){
    if(oProps.sType.toLowerCase().indexOf("color") >= 0){
        return new vdf.sys.fx.FadeColor(oProps, oSet);
    }else{
        return new vdf.sys.fx.Fade(oProps, oSet);
    }
},


doEffect : function(oProps, iLoop, iDelay){
    return this.doSet({ aEffects : (oProps instanceof Array ? oProps : [ oProps ]), iLoop : iLoop, iDelay : iDelay });
},


doSet : function(oProps){
    var oSet = new vdf.sys.fx.Set(oProps);
    oSet.run();
    return oSet;
},

doAnimation : function(oProps){
    var oAni = new vdf.sys.fx.Animation(oProps);
    oAni.run();
    return oAni;
},

copyAniStyles : function(eElem){
    var oResult = { }, oStyle, sProp, aParts;
    
    oStyle = vdf.sys.gui.getPropCurrentStyle(eElem);
    
    for(sProp in oStyle){
        if(sProp == "backgroundPosition"){
            aParts = (oStyle[sProp] || "").split(" ");
            if(aParts.length > 1){
                oResult.backgroundx = aParts[0];
                oResult.backgroundy = aParts[1];
            }
        }else if(oStyle[sProp] && 
                (!isNaN(parseFloat(oStyle[sProp])) || sProp.toLowerCase().indexOf("color") >= 0) && 
                (sProp.substr(0, 3) !== "Moz")){
            
            oResult[sProp] = oStyle[sProp];
        }
    }
    
    oResult.opacity = this.defaults.opacity(eElem);
    
    return oResult;
},

animDiffClass : function(eElem, sClass, iType, iDuration, fFinished, oFinishEnv){
    var sCurStyle, sCurClass, oFrom, oTo, sProp, aEffects = [], bSkip, fFinal, oSet;
    
    sCurStyle = eElem.getAttribute("style") || " ";
    sCurClass = eElem.className;
    oFrom = this.copyAniStyles(eElem);
    
    if(iType === 0){
        vdf.sys.gui.addClass(eElem, sClass);
    }else if(iType === 1){
        vdf.sys.gui.removeClass(eElem, sClass);
    }else{
        eElem.className = sClass;
    }
    
    oTo = this.copyAniStyles(eElem);
    eElem.className = sCurClass;
    
    for(sProp in oTo){
        if(oTo.hasOwnProperty(sProp) && oTo[sProp] !== oFrom[sProp]){
            bSkip = this.skipStyles.hasOwnProperty(sProp) && this.skipStyles[sProp];
            
            //  If the right or bottom changes this is probably caused by a change in width / height, since we want to do this without defining a from (to make a pause more flexible) we check for this
            if(sProp == "right"){
                bSkip = ((parseInt(oTo.width, 10) - parseInt(oFrom.width, 10)) === (parseInt(oFrom.right, 10) - parseInt(oTo.right, 10)));
            }       
            if(sProp == "bottom"){
                bSkip = ((parseInt(oTo.height, 10) - parseInt(oFrom.height, 10)) === (parseInt(oFrom.bottom, 10) - parseInt(oTo.bottom, 10)));
            }
            
            if(!bSkip){
                aEffects.push({
                    sType : sProp,
                    eTarget : eElem,
                    sTo : oTo[sProp],
                    iDuration : iDuration || 1000
                });
            }
        }
    }
    
    fFinal = function(){
        if(iType === 0){
            vdf.sys.gui.addClass(eElem, sClass);
        }else if(iType === 1){
            vdf.sys.gui.removeClass(eElem, sClass);
        }else{
            eElem.className = sClass;
        }
        if(typeof(eElem.getAttribute("style")) == "object"){
            eElem.style.cssText = "";
            eElem.style.cssText = sCurStyle;
        }else{
            eElem.setAttribute("style", sCurStyle);
        }
        if(fFinished){
            fFinished.call(oFinishEnv);
        }
    };
    
    if(aEffects.length > 0){
        oSet = new vdf.sys.fx.Set({
            aEffects : aEffects,
            fFinished : fFinal
        });
        return oSet;
    }else{
        fFinal();
        return null;
    }
},

animAddClass : function(eElem, sClass, iDuration, fFinished, oFinishEnv){
    return this.animDiffClass(eElem, sClass, 0, iDuration, fFinished, oFinishEnv);
},
animRemoveClass : function(eElem, sClass, iDuration, fFinished, oFinishEnv){
    return this.animDiffClass(eElem, sClass, 1, iDuration, fFinished, oFinishEnv);
},
animSetClass : function(eElem, sClass, iDuration, fFinished, oFinishEnv){
    return this.animDiffClass(eElem, sClass, 2, iDuration, fFinished, oFinishEnv);
},

workers : {
    opacity : function(eElem, oOpts, iVal){
        vdf.sys.gui.setOpacity(eElem, iVal);
    },
    
    backgroundx : function(eElem, oOpts, iVal){
        var aParts, x = 0, y = 0;
        
        aParts = (eElem.style.backgroundPosition + '').split(" ");
        if(aParts.length >= 2){
            x = parseInt(aParts[0], 10);
            y = parseInt(aParts[1], 10);
        }
        
        eElem.style.backgroundPosition = iVal + oOpts.sUnit + ' ' + y + oOpts.sUnit;  
    },
    
    backgroundy : function(eElem, oOpts, iVal){
        var aParts, x = 0, y = 0;
        
        aParts = (eElem.style.backgroundPosition + '').split(" ");
        if(aParts.length >= 2){
            x = parseInt(aParts[0], 10);
            y = parseInt(aParts[1], 10);
        }
        
        eElem.style.backgroundPosition = x + oOpts.sUnit + ' ' + iVal + oOpts.sUnit;  
    },
    
    _default : function(eElem, oOpts, iVal){
        eElem.style[oOpts.sType] = Math.ceil(iVal) + oOpts.sUnit;
    }
},

defaults : {
    width : function(eElem){
        return parseInt(eElem.offsetWidth, 10);
    },
    height : function(eElem){
        return parseInt(eElem.offsetHeight, 10);
    },
    left : function(eElem){
        return vdf.sys.gui.getAbsoluteOffsetLeft(eElem);
    },
    top : function(eElem){
        return vdf.sys.gui.getAbsoluteOffsetTop(eElem);
    },
    opacity : function(eElem){
        return vdf.sys.gui.getOpacity(eElem, true);
    },
    backgroundx : function(eElem){
        var aParts = (vdf.sys.gui.getCurrentStyle(eElem).backgroundPosition + '').split(" ");

        return (aParts.length >= 2 ?parseInt(aParts[0], 10) : 0);
    },
    
    backgroundy : function(eElem){
        var aParts = (vdf.sys.gui.getCurrentStyle(eElem).backgroundPosition + '').split(" ");
        
        return (aParts.length >= 2 ?parseInt(aParts[1], 10) : 0);
    },
    _default : function(eElem, oOpts){
        return parseInt(vdf.sys.gui.getCurrentStyle(eElem)[oOpts.sType], 10);
    }
}

};

vdf.sys.fx.Effect = function Effect(oProps, oSet){
     this.eTarget = oProps.eTarget;
    if(!this.eTarget){
        throw new vdf.errors.Error(0, "The eTarget is a required property.", this);
    }

    this.fFinished = oProps.fFinished || null; 
    this.oFinishEnv = oProps.oFinishEnv || null; 
    
    this.iHold = (isNaN(oProps.iHold) ? 0 : oProps.iHold);
    this.iGear = (isNaN(oProps.iGear) ? 1 : oProps.iGear);
    
    this.iCur = 0;
    this.iDelay = oSet.iDelay;
    this.bDone = false;
    this.bPaused = false;
};
vdf.definePrototype("vdf.sys.fx.Effect",{

process : function(oSet, iMill){
    if(iMill >= this.iHold && !this.bDone && !this.bPaused){
        this.iCur++;
        if(this.iCur >= this.iGear){
            this.iCur = 0;
            
            this.doEffect(oSet, iMill);
        }
    }
},

finish : function(oSet, iMill){
    //vdf.log("Finished at tick: " + iMill + " With step: " + this.iStep);
    this.bDone = true;
    oSet.iDone++;
    
    if(this.fFinished){
        this.fFinished.call(this.oFinishEnv);
    }
},

prepare : function(){
    this.bDone = false;
},

doEffect : function(iMill){

},

stop : function(){
    if(!this.bDone){
        this.finish();
    }
},

pause : function(){
    this.bPaused = true;
},

resume : function(){
    this.bPaused = false;
}

});

vdf.sys.fx.Fade = function Fade(oProps, oSet){
    var aParts;
    
    this.Effect(oProps, oSet);

    //  Determine type
    this.sType = oProps.sType || "function";
    
    //  Determine worker
    if(typeof(oProps.fWorker) == "function"){
        this.fWorker = oProps.fWorker;
    }else{
        if(vdf.sys.fx.workers[this.sType]){
            this.fWorker = vdf.sys.fx.workers[this.sType];
        }else{
            this.fWorker = vdf.sys.fx.workers._default;
        }
    }
    if(typeof(this.fWorker) !== "function"){
        throw new vdf.errors.Error(0, "No worker method found!", this);
    }
    
    
    aParts = vdf.sys.fx.valRegex.exec((oProps.sFrom ? oProps.sFrom : ""));
    this.iFrom = (aParts ? parseInt(aParts[2], 10) : (isNaN(oProps.iFrom) ? null : oProps.iFrom));
    
    aParts = vdf.sys.fx.valRegex.exec((oProps.sTo ? oProps.sTo : ""));
    this.iTo = (aParts ? parseInt(aParts[2], 10) : (isNaN(oProps.iTo) ? 100 : oProps.iTo));
    this.sUnit = oProps.sUnit || (aParts && aParts[3] ? aParts[3] : "px");
    this.iStep = (isNaN(oProps.iStep) ? null : oProps.iStep);
    
    this.iDuration = (isNaN(oProps.iDuration) ? 1000 : oProps.iDuration);
    
    //  @privates
    this.iVal = 0;
    this.iStartFrom = this.iFrom;
    this.iStartStep = this.iStep;
};
vdf.definePrototype("vdf.sys.fx.Fade", "vdf.sys.fx.Effect", {

doEffect : function(oSet, iMill){
    this.iVal = (this.iStep < 0 ? Math.floor(this.iVal + this.iStep) : Math.ceil(this.iVal + this.iStep));
            
    if((this.iTo >= this.iFrom && this.iVal >= this.iTo) || (this.iTo < this.iFrom && this.iVal <= this.iTo)){
        this.iVal = this.iTo;
        this.fWorker(this.eTarget, this, this.iVal);
        //vdf.log("Effect: " + this.sType + " Finished at: " + this.iVal);
        this.finish(oSet, iMill);
    }else{
        this.fWorker(this.eTarget, this, this.iVal);
    }
},

prepare : function(){
    this.Effect.prototype.prepare.call(this);

    //  Determine start value 
    if(this.iStartFrom === null){
        this.iFrom = this.getCurrent();
        
        if(this.sUnit !== "px"){
            this.fWorker(this.eTarget, this, this.iTo);
            this.iFrom = this.iTo / this.getCurrent() * this.iFrom;
            if(isNaN(this.iFrom)){
                this.iFrom = 0;
            }
        }
    }
    this.fWorker(this.eTarget, this, this.iFrom);
    this.iVal = this.iFrom;
    
    //  Determine the step size
    if(this.iStartStep === null){
        this.iStep = (this.iTo - this.iFrom) / (this.iDuration / (this.iDelay * this.iGear));
    }
},

getCurrent : function(){
    var i;
    
    if(vdf.sys.fx.defaults[this.sType]){
        i = vdf.sys.fx.defaults[this.sType](this.eTarget, this);
    }else{
        i = vdf.sys.fx.defaults._default(this.eTarget, this);
    }
    
    return (isNaN(i) ? 0 : i);
}


});


vdf.sys.fx.FadeColor = function FadeColor(oProps, oSet){
    this.Effect(oProps, oSet);

    //  Determine type
    this.sType = oProps.sType || "function";
    
    this.oFrom = (oProps.sFrom ? vdf.sys.gui.parseColor(oProps.sFrom) : null);
    this.oTo = vdf.sys.gui.parseColor(oProps.sTo);
    
    this.iR = 0;
    this.iG = 0;
    this.iB = 0;    
    
    this.iSR = 0;
    this.iSG = 0;
    this.iSB = 0;

    this.iDuration = (isNaN(oProps.iDuration) ? 1000 : oProps.iDuration);
    
    
    //  @privates
    this.oStartFrom = (oProps.sFrom ? vdf.sys.gui.parseColor(oProps.sFrom) : null);
};
vdf.definePrototype("vdf.sys.fx.FadeColor", "vdf.sys.fx.Effect", {


doEffect : function(oSet, iMill){
    this.iR += this.iSR;
    this.iG += this.iSG;
    this.iB += this.iSB;
    
    this.eTarget.style[this.sType] = 'rgb(' + parseInt(this.iR, 10) + ', ' + parseInt(this.iG, 10) + ', ' + parseInt(this.iB, 10) + ')';
    
    if((this.iSR < 0 ? this.iR <= this.oTo.iR : this.iR >= this.oTo.iR) && 
            (this.iSG < 0 ? this.iG <= this.oTo.iG : this.iG >= this.oTo.iG) && 
            (this.iSB < 0 ? this.iB <= this.oTo.iB : this.iB >= this.oTo.iB)){
        
        this.finish(oSet, iMill);
    }

},

prepare : function(){
    this.Effect.prototype.prepare.call(this);

    if(this.oStartFrom === null){
        if(vdf.sys.fx.defaults[this.sType]){
            this.oFrom = vdf.sys.fx.defaults[this.sType](this.eTarget);
        }else{
            this.oFrom = vdf.sys.gui.parseColor(vdf.sys.gui.getCurrentStyle(this.eTarget)[this.sType]); //vdf.sys.gui.parseColor((typeof(window.getComputedStyle) === "function" ? window.getComputedStyle(this.eTarget, null) : this.eTarget.currentStyle)[this.sType]); //
        }
    }
    
    this.iR = this.oFrom.iR;
    this.iG = this.oFrom.iG;
    this.iB = this.oFrom.iB;
    
    this.eTarget.style[this.sType] = 'rgb(' + parseInt(this.iR, 10) + ', ' + parseInt(this.iG, 10) + ', ' + parseInt(this.iB, 10) + ')';

    this.iSR = (this.oTo.iR - this.oFrom.iR) / (this.iDuration / (this.iDelay * this.iGear));
    this.iSG = (this.oTo.iG - this.oFrom.iG) / (this.iDuration / (this.iDelay * this.iGear));
    this.iSB = (this.oTo.iB - this.oFrom.iB) / (this.iDuration / (this.iDelay * this.iGear));
}


});

vdf.sys.fx.Set = function Set(oProps, oTime){
    var i;
    
    this.fFinished = oProps.fFinished || null; 
    this.oFinishEnv = oProps.oFinishEnv || null; 
    
    this.iLoops = (isNaN(oProps.iLoops) ? 1 : oProps.iLoops);
    this.iDelay = (isNaN(oProps.iDelay) ? (oTime ? oTime.oAni.iDelay : 80) : oProps.iDelay);
    
    this.iDone = 0;
    this.iLoop = 0;
    this.iTicks = 0;
    this.bPaused = false;
    this.bStopped = false;
    this.bRunning = false;
    
    this.aEffects = [];
    this.oTime = oTime || null;
    
    if(oProps.aEffects){
        for(i = 0; i < oProps.aEffects.length; i++){
            this.aEffects.push(vdf.sys.fx.createEffect(oProps.aEffects[i], this));
        }
    }
};
vdf.definePrototype("vdf.sys.fx.Set",{

run : function(){
    var fTick, that = this;
    
    if(!this.bRunning){
        this.bRunning = true;
        this.prepare();
        
        fTick = function(){
            that.process();
            
            if(!that.bStopped){
                setTimeout(fTick, that.iDelay);
            }
        };

        setTimeout(fTick, this.iDelay);
    }else{
        this.resume();
    }
},

prepare : function(){
    var i;
    
    this.bStopped = false;
    this.iDone = 0;
    this.iTicks = 0;
    
    for(i = 0; i < this.aEffects.length; i++){
        this.aEffects[i].prepare();
    }
},

process : function(oTime){
    var iMill, i;

    if(!this.bPaused && !this.bStopped){
        this.iTicks++;
        if(this.iDone >= this.aEffects.length){
            this.iLoop++;
            
            if(this.iLoops < 0 || this.iLoop < this.iLoops){
                this.prepare();
            }else{
                this.finish(oTime);
            }
        }else{
            iMill = this.iTicks * this.iDelay;
            
            for(i = 0; i < this.aEffects.length; i++){
                this.aEffects[i].process(this, iMill);
            }
        }
    }
},

pause : function(){
    this.bPaused = true;
},

resume : function(){
    this.bPaused = false;
},

finish : function(oTime, bNoFinish){
    if(oTime){
        oTime.setFinished();
    }else if(this.oTime){
        this.oTime.setFinished();
    }
    this.bStopped = true;
      
    if(!bNoFinish && this.fFinished){
        this.fFinished.call(this.oFinishEnv);
    }
},

stop : function(bNoFinish){
    this.bStopped = true;
    this.finish(null, bNoFinish);
},

addEffect : function(oEffect){
    this.aEffects.push(oEffect);
}

});


vdf.sys.fx.Timeline = function Timeline(oProps, oAni){
    var i;
    
    this.iLoops = (isNaN(oProps.iLoops) ? 1 : oProps.iLoops);
    this.iLoop = 0;
    
    this.bDone = false;
    this.iCurrent = 0;
    this.aQueue = [];
    this.oAni = oAni;
    
    if(oProps.aQueue){
        for(i = 0; i < oProps.aQueue.length; i++){
            this.aQueue.push(new vdf.sys.fx.Set(oProps.aQueue[i], this));
        }
    }
};
vdf.definePrototype("vdf.sys.fx.Timeline",{

prepare : function(){
    this.bDone = false;
    this.iCurrent = 0;
    
    if(this.aQueue.length > 0){
        this.aQueue[0].prepare();
    }
},

process : function(){
    if(!this.bDone && this.iCurrent < this.aQueue.length){
        this.aQueue[this.iCurrent].process(this);
    }
},

setFinished : function(){
    this.iCurrent++;
    
    if(this.iCurrent >= this.aQueue.length){
        this.iLoop++;
        if(this.iLoops < 0 || this.iLoop < this.iLoops){
            this.prepare();
        }else{
            this.bDone = true;
            if(this.oAni){
                this.oAni.iDone++;
            }
        }
    }else{
        this.aQueue[this.iCurrent].prepare();
    }
},

addSet : function(oSet){
    oSet.oTime = this;
    this.aQueue.push(oSet);
}

});


vdf.sys.fx.Animation = function Animation(oProps){
    var i;

    this.fFinished = oProps.fFinished || null; 
    this.oFinishEnv = oProps.oFinishEnv || null; 
    
    this.aTimelines = [];
    this.iDone = 0;
    this.iLoop = 0;
    this.iLoops = (isNaN(oProps.iLoops) ? 1 : oProps.iLoops);
    this.iDelay = (isNaN(oProps.iDelay) ? 80 : oProps.iDelay);
    this.bRunning = false;
    this.bStopped = false;
    
    if(oProps.aTimelines){
        for(i = 0; i < oProps.aTimelines.length; i++){
            this.aTimelines.push(new vdf.sys.fx.Timeline(oProps.aTimelines[i], this));
        }
    }
};
vdf.definePrototype("vdf.sys.fx.Animation",{

run : function(){
    var fTick, that = this;
    
    if(!this.bRunning){
        this.bRunning = true;
        this.bStopped = false;
        
        this.prepare();
        
        fTick = function(){
            that.process();
            
            if(!that.bStopped){
                setTimeout(fTick, that.iDelay);
            }
        };

        setTimeout(fTick, this.iDelay);
    }else{
        this.resume();
    }
},

prepare : function(){
    var i;
    
    this.bStopped = false;
    this.iDone = 0;
    
    for(i = 0; i < this.aTimelines.length; i++){
        this.aTimelines[i].prepare();
    }
},

process : function(){
    var i;

    if(!this.bPaused && !this.bStopped){
        if(this.iDone >= this.aTimelines.length){
            this.iLoop++;
            
            if(this.iLoops < 0 || this.iLoop < this.iLoops){
                this.prepare();
            }else{
                this.finish();
            }
        }else{
            for(i = 0; i < this.aTimelines.length; i++){
                this.aTimelines[i].process(this);
            }
        }
    }
},

pause : function(){
    this.bPaused = true;
},

resume : function(){
    this.bPaused = false;
},

finish : function(){
    this.bRunning = false;
    this.bStopped = true;
    if(this.fFinished){
        this.fFinished.call(this.oEnvironment);
    }
},

stop : function(){
    if(!this.bStopped){
        this.finish();
    }
},

addTimeline : function(oTimeline){
    oTimeline.oAni = this;
    this.aTimelines.push(oTimeline);
},

addSet : function(oSet){
    var oTimeline = new vdf.sys.fx.Timeline({}, this);
    
    this.addTimeline(oTimeline);
    oTimeline.addSet(oSet);
}

});





vdf.ajax.PriorityPipe = function PriorityPipe(sUrl, sXmlNS){
    // @publics
    
    this.sUrl = sUrl;
    
    this.sXmlNS = sXmlNS;
    
    // @privates
    this.aQueue = [];
};

vdf.definePrototype("vdf.ajax.PriorityPipe", {


send : function(oCall, iPriority, fHandler, oEnv){
    var oRequest;
    
    oRequest = { oCall : oCall, iPriority : iPriority, fHandler : fHandler, oEnv : oEnv };
    

    //  Do settings if needed
    if(this.sUrl !== null && typeof(this.sUrl) !== "undefined"){
        oCall.sUrl = this.sUrl;
    }
    if(this.sXmlNS !== null && typeof(this.sXmlNS) !== "undefined"){
        oCall.sXmlNS = this.sXmlNS;
    }
    
    oCall.onFinished.addListener(this.onResponse, this);
    this.aQueue.push(oRequest);
    oCall._oRequest = oRequest;
    oCall.send(true);
},


onResponse : function(oEvent){
    var i, iHigh = 0, oRequest = oEvent.oSource._oRequest;
    
    //  Current request is finished
    oRequest.bFinished = true;
    oRequest.oEvent = oEvent;
    
    //  Loop through the queue
    for(i = 0; i < this.aQueue.length; i++){
        //  If the priority isn't lower than the highest priority seen call the handler and remove from the queue
        if(this.aQueue[i].bFinished && this.aQueue[i].iPriority >= iHigh){
            this.aQueue[i].fHandler.call(this.aQueue[i].oEnv, this.aQueue[i].oEvent);
            this.aQueue.splice(i, 1);
            i--;
        }
        //  Remember the highest priority
        if(i >= 0 && iHigh < this.aQueue[i].iPriority){
            iHigh = this.aQueue[i].iPriority;
        }
    }
}


});



vdf.ajax.RequestQueue = function RequestQueue(iLimit){
    // @public
    
    this.iLimit = (iLimit || 0);
    
    // @private
    this.iCurrent = 0;
    this.aQueue = [];
};

vdf.definePrototype("vdf.ajax.RequestQueue", {


send : function(oCall){
    this.aQueue.push(oCall);
    this.determineSend();
},


onClose : function(oEvent){
    oEvent.oSource.onClose.removeListener(this.onClose);
    this.iCurrent--;
    this.determineSend();
},


removeCall : function(oCall){
    var iCall;
    
    for(iCall = 0; iCall < this.aQueue.length; iCall++){
        if(this.aQueue[iCall] === oCall){
            this.aQueue.splice(iCall, 1);
            return;
        }
    }
},


determineSend : function(){
    var oCall;

    while(this.aQueue.length > 0 && (this.iCurrent < this.iLimit || this.iLimit <= 0)){
        oCall = this.aQueue.shift();
        this.iCurrent++;
        oCall.onClose.addListener(this.onClose, this);
        oCall.communicate();
    }
}


});





vdf.ajax.REQUEST_STATE_UNITIALIZED  = 0;

vdf.ajax.REQUEST_STATE_LOADING      = 1;

vdf.ajax.REQUEST_STATE_LOADED       = 2;

vdf.ajax.REQUEST_STATE_INTERACTIVE  = 3;

vdf.ajax.REQUEST_STATE_COMPLETE     = 4;


vdf.ajax.HttpRequest = function HttpRequest(sUrl, sData){
    if(typeof(sData) === "undefined"){
        sData = null;
    }
    //  Public
    
    this.sUrl = sUrl;
    
    this.sData = sData;
    
    this.bAsynchronous = true;

    //  Events
    
    this.onFinished = new vdf.events.JSHandler();
    
    this.onError = new vdf.events.JSHandler();
    
    // @privates
    this.onClose = new vdf.events.JSHandler();
    
    this.oLoader = null;
};

vdf.definePrototype("vdf.ajax.HttpRequest", {


send : function(bAsynchronous){
    if(typeof bAsynchronous === "boolean"){
        this.bAsynchronous = bAsynchronous;
    }

    if(vdf.ajax.oDefaultQueue && this.bAsynchronous){
        vdf.ajax.oDefaultQueue.send(this);
    }else{
        this.communicate();
    }
},


communicate : function(){
    var oXmlRequest = this, sData;
    this.oLoader = vdf.sys.xml.getXMLRequestObject();
    sData = this.getData();

    //  If asynchronousattach onreadystatechange function (if synchronous it
    //  is called mannualy)
    if(this.bAsynchronous){
        this.oLoader.onreadystatechange = function(){
            oXmlRequest.onReadyStateChange.call(oXmlRequest);
        };
    }

    //  Open connection, set headers, send request
    this.oLoader.open((sData) ? "POST" : "GET", this.getRequestUrl(), this.bAsynchronous);
    this.setHeaders(this.oLoader);
    this.oLoader.send(sData);
    
    //  If synchronous request call readyStateChange manually (IE won't do 
    //  it)
    if(!this.bAsynchronous){
        this.onReadyStateChange();
    }
},


onReadyStateChange : function(){
    var oRequest = this;

    try{
        if(this.oLoader.readyState == vdf.ajax.REQUEST_STATE_COMPLETE){
            if(this.oLoader.status > 0){    //  Scary check but it prevents firefox from throwing the could not parse XML error on page load
                this.onClose.fire(this);
            
                this.checkErrors();
                
                this.onFinished.fire(this, this.getFinishedDetails());
                
                //  Set a timeout to destroy this object
                setTimeout(function(){
                    oRequest.destroy();
                }, 1000);
            }
        }
    }catch (e){
        if(this.onError.fire(this, { oError : e })){
            vdf.errors.handle(e);
        }
    }
    
},


getFinishedDetails : function(){
    return { oResponseXml : this.getResponseXml(), sResponseText : this.getResponseText() };
},


checkErrors : function(bSkip500){
    if(this.oLoader.status >= 300 && (!bSkip500 || this.oLoader.status != 500)){
        var aDetails, sDetailHtml = this.oLoader.responseText; 
        
        //  We strip out anything above and below the body element, then we remove style and script elements...
        sDetailHtml = sDetailHtml.replace(/(^(.|\n|\r)*<body.*?>)|(<\/body>(.|\n|\r)*$)/gi, "");
        sDetailHtml = sDetailHtml.replace(/<style(.|\n|\r)*\/style>/gi, "");
        sDetailHtml = sDetailHtml.replace(/<script(.|\n|\r)*\/script>/gi, "");
        
        aDetails = [
            "<b>Target:</b> ", this.sUrl, "<br/>",
            "<b>Full URL:</b> ", this.getRequestUrl(), "<br/>",
            "<b>Status code:</b> ", this.oLoader.status, "<br/>",
            "<b>Status text:</b> ", this.oLoader.statusText, "<br/>",
            "<br />",
            "<hr />",
            sDetailHtml
        ];
        
        throw new vdf.errors.Error(5120, "Received HTTP error", this, [this.oLoader.status, this.oLoader.statusText, this.sUrl], aDetails.join(""));
    }
},


setHeaders : function(oLoader){
    
},


getRequestUrl : function(){
    var sPath, iPos;
    
    //  Dynamically find the path to post the data to
    if(this.sUrl.substr(0,7).toLowerCase() != "http://"){
        
        //  Fetch current path (without file)
        sPath = window.location.pathname;
    
        //  In IE modal dialogs the pathname wont start with "/"
        if(sPath.substr(0, 1) != "/"){
            sPath = "/" + sPath;   
        }
        iPos = sPath.lastIndexOf("/");
        if (iPos >= 0){
            sPath = sPath.substring(0, iPos);
        }
        
        //  Create request url
        if (this.sUrl.substr(0, 1) != "/"){
            return sPath + "/" + this.sUrl ;
        }else{
            return sPath + this.sUrl;
        }
    }
    
    return this.sUrl;
},


getResponseXml : function(){
    return this.oLoader.responseXML;
},


getResponseText : function(){
    return this.oLoader.responseText;
},


getData : function(){
    return this.sData;
},


cancel : function(){
    if(this.oLoader !== null){
        this.onClose.fire(this);
        
        this.oLoader.onreadystatechange = function(){ };
        this.oLoader.abort();
        this.oLoader = null;
    }else if(vdf.ajax.oDefaultQueue && this.bAsynchronous){
        vdf.ajax.oDefaultQueue.removeCall(this);
    }
    
    this.onFinished.aListener = [];
},


destroy : function(){
    try{
        if(this.bAsynchronous && this.oLoader && this.oLoader.onreadystatechange){
            this.oLoader.onreadstatechange = null;
        }
    }catch(oErr){
    
    }
    this.oLoader = null;
}

});

vdf.require("vdf.ajax.RequestQueue", function(){
    
    vdf.ajax.oDefaultQueue = new vdf.ajax.RequestQueue((typeof vdf.settings.iAjaxConcurrencyLimit === "number" ? vdf.settings.iAjaxConcurrencyLimit  : 1));
    
    setTimeout(function(){
        
        vdf.ajax.oDefaultQueue.iLimit = (typeof vdf.settings.iAjaxConcurrencyLimit === "number" ? vdf.settings.iAjaxConcurrencyLimit  : 1);
    }, 100);
});



vdf.ajax.xmlSerializer = {


deSerialize : function(oSource, sMainObjectName){
    var oNode;

    //  If XML is supplied as string we let the browser parse it first
    if(vdf.sys.ref.getType(oSource) == "string"){
        oNode = vdf.sys.xml.parseXmlString(oSource).documentElement;
    }else{
        oNode = oSource;
    }

    return this.switchFromXml(oNode, sMainObjectName);
},


serialize : function(oObject, bTopElem){
    var aXml = [];
    
    if(typeof(bTopElem) == "undefined" || bTopElem){
        aXml.push("<");
        aXml.push(vdf.sys.ref.getType(oObject));
        aXml.push(">\n");
    }
    
    this.switchToXml(oObject, aXml);
    
    if(typeof(bTopElem) == "undefined" || bTopElem){
        aXml.push("</");
        aXml.push(vdf.sys.ref.getType(oObject));
        aXml.push(">\n");
    }
    
    return aXml.join("");
},    
    

switchToXml : function(object, aXml){
    switch(vdf.sys.ref.getType(object)){
        case "array":
            this.arrayToXml(object, aXml);
            break;
        case "string":
            this.stringToXml(object, aXml);
            break;
        case "number":
            this.numberToXml(object, aXml);
            break;
        case "boolean":
            this.booleanToXml(object, aXml);
            break;
        case "date":
            this.dateToXml(object, aXml);
            break;
        case "null":
            break;
        default:
            this.objectToXml(object, aXml);
            break;
    }
},


objectToXml : function(oObj, aXml){
    var sProp;
    
    if(oObj !== null && typeof(oObj) !== "undefined"){
        for(sProp in oObj){
            if(typeof(oObj[sProp]) != "function" && sProp.substr(0, 2) != "__"){
                aXml.push("<");
                aXml.push(sProp);
                aXml.push(">");
                
                this.switchToXml(oObj[sProp], aXml);
                
                aXml.push("</");
                aXml.push(sProp);
                aXml.push(">\n");
            }
        }
    }
},


arrayToXml : function(aArray, aXml){
    var iItem;
    
    for(iItem = 0; iItem < aArray.length; iItem++){
        aXml.push("<");
        aXml.push(vdf.sys.ref.getType(aArray[iItem]));
        aXml.push(">");

        this.switchToXml(aArray[iItem], aXml);
        
        aXml.push("</");
        aXml.push(vdf.sys.ref.getType(aArray[iItem]));
        aXml.push(">\n");
    }
},


stringToXml : function(sString, aXml){
    //  Add CDATA if the value contains special characters
    if(sString.match(/[<>&'"]/) !== null){
        aXml.push("<![CDATA[");
        aXml.push(sString.replace("]]>", "]]>]]><![CDATA["));
        aXml.push("]]>");
    }else{
        aXml.push(sString);
    }
},


numberToXml : function(nNumber, aXml){
    aXml.push(nNumber.toString());
},


dateToXml : function(dDate, aXml){
    aXml.push(vdf.sys.math.padZero(dDate.getFullYear(), 4));
    aXml.push("-");
    aXml.push(vdf.sys.math.padZero(dDate.getMonth() + 1, 2));
    aXml.push("-");
    aXml.push(vdf.sys.math.padZero(dDate.getDate(), 2));
    aXml.push("T");
    aXml.push(vdf.sys.math.padZero(dDate.getHours(), 2));
    aXml.push(":");
    aXml.push(vdf.sys.math.padZero(dDate.getMinutes(),2));
    aXml.push(":");
    aXml.push(vdf.sys.math.padZero(dDate.getSeconds(), 2));
    aXml.push(".");
    aXml.push(vdf.sys.math.padZero(dDate.getMilliseconds(), 3));
},


booleanToXml : function(bBoolean, aXml){
    aXml.push(bBoolean.toString());
},


switchFromXml : function(oNode, sMainObjectName){
    var  bContainer = false, sName, iChild, sPrefix;
    
    //  If a name is given it is used
    if(typeof(sMainObjectName) != "undefined"){
        sName = sMainObjectName;
    }else{
        sName = vdf.sys.xml.getNodeName(oNode);
    }
    
    sPrefix = sName.substr(0, 1);
    
    //  If the name starts with an "a" we assume it is an array
    if(sPrefix === "a"){
        return this.arrayFromXml(oNode);
    }else{
        
        //  Detect if there are child elements
        for(iChild = 0; iChild < oNode.childNodes.length; iChild++){
            if(oNode.childNodes.item(iChild).nodeType == 1){
                bContainer = true;
                break;
            }
        }   
        
        //  If child elements found we assume it is an object, else it must be a value
        if(bContainer){
            return this.objectFromXml(oNode, sMainObjectName);
        }else{
            //  Use the prefix to switch between the different types
            switch(sPrefix){
                case "i":
                    return this.integerFromXml(oNode);
                case "b":
                    return this.booleanFromXml(oNode);
                default:
                    return this.valueFromXml(oNode);
            }
        }
    }
    
},


objectFromXml : function(oNode, sObjectName){
    var sName, oObject, iChild, oChild, sChild;

    if(sObjectName){
        sName = sObjectName;
    }else{
        sName = vdf.sys.xml.getNodeName(oNode);
    }
    
    if(typeof(vdf.dataStructs) === "object" && typeof(vdf.dataStructs[sName]) === "function"){
        oObject = new vdf.dataStructs[sName]();
    }else{
        oObject = {};
    }
    
    for(iChild = 0; iChild < oNode.childNodes.length; iChild++){
        oChild = oNode.childNodes.item(iChild);
        if(oChild.nodeType == 1){ //    1 = ELEMENT NODE
            sChild = vdf.sys.xml.getNodeName(oChild);
        
            oObject[sChild] = this.switchFromXml(oChild);
        }
    }
    
    return oObject;
},


arrayFromXml : function(oNode){
    var aArray = [], iChild, oChild;
    
    for(iChild = 0; iChild < oNode.childNodes.length; iChild++){
        oChild = oNode.childNodes.item(iChild);
         
        if(oChild.nodeType == 1){ //    1 = ELEMENT NODE
            aArray.push(this.switchFromXml(oChild));
        }
    }
    
    return aArray;
},


integerFromXml : function(oNode){
    
    if(oNode.childNodes.length > 0){
        oNode = oNode.firstChild;
    }

    return (oNode.nodeValue !== null ? parseInt(oNode.nodeValue, 10) : 0);
},


booleanFromXml : function(oNode){
    if(oNode.childNodes.length > 0){
        oNode = oNode.firstChild;
    }

    return (typeof(oNode.nodeValue) === "string" ? (oNode.nodeValue.toLowerCase() === "true" || oNode.nodeValue === "1") : oNode.nodeValue);
},


valueFromXml : function(oNode){
    var sResult = "", iCount;
    
    if(oNode.childNodes.length > 0){
        for (iCount = 0; iCount < oNode.childNodes.length; iCount++){            
            sResult += (oNode.childNodes[iCount].nodeValue !== null ? oNode.childNodes[iCount].nodeValue : "");
        }
        
        return sResult;
    }else{
        return (oNode.nodeValue !== null ? oNode.nodeValue : "");
    }
}

};

vdf.register("vdf.ajax.xmlSerializer");



vdf.ajax.jsonSerializer = {


deserialize : function(sString){
    if(typeof JSON === "object" && typeof JSON.parse === "function"){
        return JSON.parse(sString);
    }else{
        //  Replace characters that JavaScript doesn't handle very well
        this.oDecodeRegex.lastIndex = 0;
        if (this.oDecodeRegex.test(sString)) {
            sString = sString.replace(this.oDecodeRegex, function (sVal, iPos) {
                return '\\u' +
                    ('0000' + sVal.charCodeAt(0).toString(16)).slice(-4);
            });
        }
        
        //  Test if JSON is save to eval
        if (this.validate(sString)) {
            return eval("(" + sString + ")");
        }else{
            throw new SyntaxError('JSON.parse');
        }
    }
},


validate : function(sJSON){
    return (/^[\],:{}\s]*$/.
            test(sJSON.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@').
            replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']').
            replace(/(?:^|:|,)(?:\s*\[)+/g, '')));
},


serialize  : function(oObject){
    // Check if we can use native JSON support
    if(typeof JSON === "object" && typeof JSON.stringify === "function"){
        // Call native JSON stringify function 
        // replacer function is given to make sure properties with "__" are skipped
        return JSON.stringify(oObject, function(sKey, sValue){
            return (typeof sKey === "string" && sKey.substr(0, 2) === "__" ? undefined : sValue);
        });
    }else{
        //  Call our own recursive JSON functions
        var aResult = [];
        
        this.switchToJson(oObject, aResult);
        
        return aResult.join("");
    }
},




switchToJson : function(object, aResult){
    switch(vdf.sys.ref.getType(object)){
        case "array":
            this.arrayToJson(object, aResult);
            break;
        case "string":
            this.stringToJson(object, aResult);
            break;
        case "number":
            this.numberToJson(object, aResult);
            break;
        case "boolean":
            this.booleanToJson(object, aResult);
            break;
        case "date":
            this.dateToJson(object, aResult);
            break;
        case "null":
            break;
        default:
            this.objectToJson(object, aResult);
            break;
    }
},


objectToJson : function(oObj, aResult){
    var sProp, bFirst = true;
    
    
    if(oObj !== null && typeof(oObj) !== "undefined"){
        aResult.push("{");
        for(sProp in oObj){
            if(typeof(oObj[sProp]) != "function" && sProp.substr(0, 2) != "__"){
                if(!bFirst){
                    aResult.push(",");
                }
                aResult.push('"');
                aResult.push(sProp);
                aResult.push('":');
                
                this.switchToJson(oObj[sProp], aResult);
                bFirst = false;
           }
        }
        aResult.push("}");
    }
    
},


arrayToJson : function(aArray, aResult){
    var iItem, bFirst = true;
    
    aResult.push("[");
    
    for(iItem = 0; iItem < aArray.length; iItem++){
        if(!bFirst){
            aResult.push(",");
        }

        this.switchToJson(aArray[iItem], aResult);
        bFirst = false;
    }
    
    aResult.push("]");
},


oEncodeChars : {
    '\b': '\\b',
    '\t': '\\t',
    '\n': '\\n',
    '\f': '\\f',
    '\r': '\\r',
    '"' : '\\"',
    '\\': '\\\\'
},



stringToJson : function(sString, aResult){
    aResult.push('"');
    
    //  Check if and replace special character
    this.oEncodeRegex.lastIndex = 0;
    if (this.oEncodeRegex.test(sString)){
        sString = sString.replace(this.oEncodeRegex, function(sValue, iPos){
            var sRep = vdf.ajax.jsonSerializer.oEncodeChars[sValue];
            return (typeof sRep === "string" ? sRep : '\\u' + ('0000' + sValue.charCodeAt(0).toString(16)).slice(-4));
        });
    }
    
    aResult.push(sString);
    aResult.push('"');
},


booleanToJson : function(bBool, aResult){
    aResult.push(String(bBool));
},


numberToJson : function(nNumber, aResult){
    aResult.push((isFinite(nNumber) ? String(nNumber) : nNumber));
},


dateToJson : function(dDate, aResult){
    aResult.push('"');
    aResult.push(dDate.getUTCFullYear());
    aResult.push("-");
    aResult.push(vdf.sys.math.padZero(dDate.getUTCMonth() + 1, 2));
    aResult.push('-');
    aResult.push(vdf.sys.math.padZero(dDate.getUTCDate(), 2));
    aResult.push('T');
    aResult.push(vdf.sys.math.padZero(dDate.getUTCHours(), 2));    
    aResult.push(':');
    aResult.push(vdf.sys.math.padZero(dDate.getUTCMinutes(), 2));
    aResult.push(':');
    aResult.push(vdf.sys.math.padZero(dDate.getUTCSeconds(), 2));
    aResult.push('Z');
    aResult.push('"');
}

};


vdf.ajax.jsonSerializer.oEncodeRegex = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g;

vdf.ajax.jsonSerializer.oDecodeRegex = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g;

vdf.register("vdf.ajax.jsonSerializer");





vdf.ajax.JSONCall = function SoapCall(sFunction, oParams, sUrl){
    if(typeof(sUrl) == "undefined" || sUrl === null){
        sUrl = "WebService.wso";
    }
    this.HttpRequest(sUrl);
    
    
    this.sFunction = sFunction;
    
    this.oParams = ((oParams) ? oParams : {});
    
    this.bUsePOST = true;
    
    this.bExtendURL = true;
};

vdf.definePrototype("vdf.ajax.JSONCall", "vdf.ajax.HttpRequest", {


addParam : function(sName, sValue){
    this.oParams[sName] = sValue;
},


setHeaders : function(oLoader){
    this.HttpRequest.prototype.setHeaders.call(this, oLoader);

    if(this.bUsePOST){
        oLoader.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    }
},


getData : function(){
    var sParam, aParams = [];

    if(this.bUsePOST){
        //  Append parameters
        for(sParam in this.oParams){
            if(this.oParams.hasOwnProperty(sParam)){
                if(aParams.length > 0){
                    aParams.push("&");
                }
                aParams.push(encodeURIComponent(sParam));
                aParams.push("=");
                aParams.push(encodeURIComponent(String(this.oParams[sParam])));
            }
        }
        
        return aParams.join("");
    }else{
        return null;
    }
},


getRequestUrl : function(){
    var sUrl, sParam, aParams = [];
    
    //  Call super method for start URL
    sUrl = this.HttpRequest.prototype.getRequestUrl.call(this);
    
    //  Append /JSON
    if(sUrl.indexOf("/JSON") >= 0){
        sUrl = sUrl.replace("/JSON", "/" + this.sFunction + "/JSON");
    }else{
        if(sUrl.indexOf("?") >= 0){
            sUrl = sUrl.replace("?", "/" + this.sFunction + "/JSON");
        }else{
            sUrl = sUrl + (sUrl.charAt(sUrl.length - 1) !== "/" ? "/" : "") + this.sFunction + "/JSON";
        }
    }
    
    if(!this.bUsePOST){
        //  Append parameters
        for(sParam in this.oParams){
            if(this.oParams.hasOwnProperty(sParam)){
                aParams.push((aParams.length <= 0 && sUrl.indexOf("?") < 0 ? "?" : "&"));
                aParams.push(encodeURIComponent(sParam));
                aParams.push("=");
                aParams.push(encodeURIComponent(String(this.oParams[sParam])));
            }
        }
    
        //  Return the url
        return sUrl + aParams.join("");
    }else{
        return sUrl;
    }
},


getResponseXml : function(){
    return null;
},


checkErrors : function(){
    this.HttpRequest.prototype.checkErrors.call(this);

    //  TODO:   Probably check JSON here?
},


getResponseValue : function(){
    var sJSON = this.getResponseText();
    
    
    return vdf.ajax.jsonSerializer.deserialize(sJSON);
}

});





vdf.ajax.SoapCall = function SoapCall(sFunction, oParams, sUrl, sXmlNS){
    if(typeof(sUrl) == "undefined" || sUrl === null){
        sUrl = "WebService.wso";
    }
    this.HttpRequest(sUrl);
    
    
    this.sFunction = sFunction;
    
    this.oParams = ((oParams) ? oParams : {});
    
    this.sXmlNS = ((sXmlNS) ? sXmlNS : "http://tempuri.org/");
};

vdf.definePrototype("vdf.ajax.SoapCall", "vdf.ajax.HttpRequest", {


addParam : function(sName, oValue){
    this.oParams[sName] = oValue;
},


setHeaders : function(oLoader){
    this.HttpRequest.prototype.setHeaders.call(this, oLoader);

    oLoader.setRequestHeader("Content-Type", "text/xml");
},


getData : function(){
    var aXml = [
        '<?xml version="1.0" encoding="utf-8"?>\n',
        '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">\n',
        "<soap:Body>\n",
        "<", this.sFunction, ' xmlns="', this.sXmlNS, '">\n',
        vdf.ajax.xmlSerializer.serialize(this.oParams, false),
        "</", this.sFunction,">\n",
        "</soap:Body>\n",
        "</soap:Envelope>\n"
    ];

    return aXml.join("");
},


checkErrors : function(){
    var oXml, aFaults, aDetails, oParseError;
    
    this.HttpRequest.prototype.checkErrors.call(this, true);
    
    oXml = this.getResponseXml();
    if(oXml !== null && typeof(oXml) !== "undefined"){
        aFaults = vdf.sys.xml.find(oXml, "Fault", "soap");
        
        if(aFaults.length > 0){
            aDetails = [
                "<b>Target:</b> ", this.sUrl, "<br/>",
                "<b>Full URL:</b> ", this.getRequestUrl(), "<br/>",
                "<b>Fault code:</b> ", vdf.sys.xml.findContent(aFaults[0], "faultcode"), "<br/>",
                "<b>Status text:</b> ", vdf.sys.xml.findContent(aFaults[0], "faultstring"), "<br/>",
                "<br />",
                "<hr />",
                "<pre>", vdf.sys.string.encodeHtml(this.oLoader.responseText), "</pre>"
            ];
        
            throw new vdf.errors.Error(5121, "Server returned soap fault", this, [vdf.sys.xml.findContent(aFaults[0], "faultcode"),  vdf.sys.xml.findContent(aFaults[0], "faultstring")], aDetails.join(""));
        }
        
        oParseError = this.oLoader.responseXML.parseError;
        if(oParseError && oParseError.errorCode){
            aDetails = [
                "<b>Target:</b> ", this.sUrl, "<br/>",
                "<b>Full URL:</b> ", this.getRequestUrl(), "<br/>",
                "<pre>", oParseError.reason, "<br/>",
                oParseError.srcText, "</pre><br/>"
            ];
        
            throw new vdf.errors.Error(5122, "Error parsing the received xml", this, [], aDetails.join(""));
        }
        
        aFaults = vdf.sys.xml.find(oXml, "parsererror");
        if(aFaults.length > 0){
            aDetails = [
                "<b>Target:</b> ", this.sUrl, "<br/>",
                "<b>Full URL:</b> ", this.getRequestUrl(), "<br/>",
                "<pre> ",  aFaults[0].childNodes[0].nodeValue, "<br/>",
                vdf.sys.string.encodeHtml(vdf.sys.xml.findContent(aFaults[0], "sourcetext")) , "</pre><br/>"
            ];
        
            throw new vdf.errors.Error(5122, "Error parsing the received xml", this, [], aDetails.join(""));
        
        }
    }else{
        aDetails = [
            "<b>Target:</b> ", this.sUrl, "<br/>",
            "<b>Full URL:</b> ", this.getRequestUrl(), "<br/>",
            "<br />",
            "<hr />",
            "<pre>", vdf.sys.string.encodeHtml(this.oLoader.responseText), "</pre>"
        ];
        throw new vdf.errors.Error(5123, "Unknown parse error", this, [], aDetails.join(""));
    }
},


getResponseValue : function(sReturnObjectName){
    var aResponse = vdf.sys.xml.find(this.getResponseXml(), this.sFunction + "Result");
    
    if(aResponse.length > 0){
        return vdf.ajax.xmlSerializer.deSerialize(aResponse[0], sReturnObjectName);
    }else{
        throw new vdf.errors.Error(5151, "Result node not found", this);
    }
}

});





vdf.ajax.VdfCall = function VdfCall(sWebObject, sMethod, aParams, sUrl, sXmlNS){
    this.SoapCall("RemoteMethodInvocation", null, sUrl, sXmlNS);
    
    //  PUBLIC
    
    this.sWebObject = sWebObject;
    
    this.sMethod = sMethod;
    
    this.aParams = ((aParams) ? aParams : []);
    
    
    this.bSuppressError = false;
    
    this.aErrors = null;
        
    //  @privates
    this.tResponse = null;
};

vdf.definePrototype("vdf.ajax.VdfCall", "vdf.ajax.SoapCall", {
    

addParameter : function(sValue){
    this.aParams.push(sValue);
},


getData : function(){
    this.addParam("sWebObject", this.sWebObject);
    this.addParam("sSessionKey", vdf.sys.cookie.get("vdfSessionKey"));
    this.addParam("sMethodName", this.sMethod);
    this.addParam("asParams", this.aParams);
    
    return this.SoapCall.prototype.getData.call(this);
},


getFinishedDetails : function(){
    var oResult = this.SoapCall.prototype.getFinishedDetails.call(this);
    
    oResult.sReturnValue = this.getReturnValue();
    
    return oResult;
},


checkErrors : function(){
    var iError;
    
    this.SoapCall.prototype.checkErrors.call(this);

    this.tResult = this.getResponseValue("TAjaxRMIResponse");
    
    this.aErrors = this.tResult.aErrors;
    
    if(!this.bSuppressError){
        for(iError = 0; iError < this.tResult.aErrors.length; iError++){
            vdf.errors.handle(new vdf.errors.createServerError(this.tResult.aErrors[iError], this));
        }
    }
},


getReturnValue : function(){
    return this.tResult.sReturnValue;
}

});



vdf.core.Action = function(sMode, oForm, oInitiator, oMainDD, bLockExclusive){
    
    this.sMode = sMode;
    
    this.oForm = oForm;
    
    this.oMainDD = oMainDD;
    
    this.oInitiator = oInitiator;
    
    this.bLockExclusive = (bLockExclusive);
    
    this.onResponse = new vdf.events.JSHandler();
    
    this.onFinished = new vdf.events.JSHandler();
    
    //  @privates
    this.oRequest = null;    
    this.aLocked = [];
    this.tRequestData = new vdf.dataStructs.TAjaxRequestData();
    
    this.oLockAnim = null;
    this.oUnlockAnim = null;
};

vdf.definePrototype("vdf.core.Action", {


addRequestSet : function(tRequestSet){
    this.tRequestData.aDataSets.push(tRequestSet);
},


lock : function(oObject){
    if(oObject.lock(this.bLockExclusive, this) === false){
        this.bLockSucceeded = false;
        return false;
    }else{
        this.aLocked.push(oObject);
        return true;
    }
},


unlock : function(){
    var iObj;
    
    for(iObj = 0; iObj < this.aLocked.length; iObj++){
        this.aLocked[iObj].unlock(this.bLockExclusive, this);
    }
    
    this.aLocked = [];
    
    if(this.oUnlockAnim){
        this.oUnlockAnim.run();
    }
},

addLockAnim : function(oSet){
    if(!this.oLockAnim){
        this.oLockAnim = new vdf.sys.fx.Animation({});
    }
    this.oLockAnim.addSet(oSet);
},

addUnlockAnim : function(oSet){
    if(!this.oUnlockAnim){
        this.oUnlockAnim = new vdf.sys.fx.Animation({});
    }
    this.oUnlockAnim.addSet(oSet);
},


send : function(){
    if(!this.bLockSucceeded){
                
        if(this.oLockAnim){
            this.oLockAnim.run();
        }
    
        //  Gather data
        this.tRequestData.sSessionKey = vdf.sys.cookie.get("vdfSessionKey");
        this.tRequestData.sWebObject = this.oForm.sWebObject;
        this.tRequestData.aUserData = this.oForm.getUserData();
        
        this.oRequest = new vdf.ajax.SoapCall("Request", { "tRequestData" : this.tRequestData }, this.oForm.sWebServiceUrl, this.oForm.sXmlNS);
        this.oRequest.onFinished.addListener(this.handleRequest, this);
        this.oRequest.onError.addListener(this.onRequestError, this);
        this.oRequest.send(true);
    }else{
        alert("Locked! Sorry!");
        this.unlock();
    }
},


handleRequest : function(oEvent){
    var iError, oEventInfo, tResponseData = oEvent.oSource.getResponseValue("TAjaxResponseData");
    
    oEventInfo = {
        bError : false, 
        iErrorNr : 0, 
        tResponseData : tResponseData, 
        oInitiator : this.oInitiator
    };
    
    try{
        if(tResponseData.aErrors.length === 0){
            this.oForm.setUserData(tResponseData.aUserData);
        }else{
            for(iError = 0; iError < tResponseData.aErrors.length; iError++){
                vdf.errors.handle(vdf.errors.createServerError(tResponseData.aErrors[iError], this.oForm));
            }
            
            oEventInfo.bError = true;
            oEventInfo.iErrorNr = tResponseData.aErrors[0].iNumber;
        }
        
        this.onResponse.fire(this, oEventInfo);
        
        //  Unlock if the onResponse didn't do that..
        if(this.aLocked.length > 0){
            this.unlock();
        }
        
        this.onFinished.fire(this, oEventInfo);
    }catch(oError){
        vdf.errors.handle(oError);
        this.unlock();
    }
},


onRequestError : function(oEvent){
    var oEventInfo = {
        bError : true, 
        iErrorNr : oEvent.oError.iErrorNr, 
        tResponseData : null, 
        oInitiator : this.oInitiator
    };


    this.onResponse.fire(this, oEventInfo);
    this.unlock();
    this.onFinished.fire(this, oEventInfo);
},


cancel : function(){
    if(this.oRequest !== null){
        this.oRequest.cancel();
        this.oRequest = null;
        this.unlock();
    }
}

});



vdf.core.ClientDataDictionary = function ClientDataDictionary(sName, oForm){
    
    this.oForm = oForm;
    
    this.sName = sName;
    
    //  REFERENCES
    
    this.oStatus = null;
    
    this.aDEO = [];
    
    this.aServers = [];
    
    this.aChildren = [];
    
    this.oConstrainedTo = null;
    
    this.aConstrainedFrom = [];
    
        
    //  EVENTS
    
    this.onBeforeFind = new vdf.events.JSHandler();
    
    this.onAfterFind = new vdf.events.JSHandler();
    
    this.onBeforeFindByRowId = new vdf.events.JSHandler();
    
    this.onAfterFindByRowId = new vdf.events.JSHandler();
    
    this.onBeforeClear = new vdf.events.JSHandler();
    
    this.onAfterClearAll = new vdf.events.JSHandler();
    
    this.onBeforeClearAll = new vdf.events.JSHandler();
    
    this.onAfterClear = new vdf.events.JSHandler();
    
    this.onBeforeSave = new vdf.events.JSHandler();
    
    this.onAfterSave = new vdf.events.JSHandler();
    
    this.onBeforeDelete = new vdf.events.JSHandler();
    
    this.onAfterDelete = new vdf.events.JSHandler();
    
    this.onRefresh = new vdf.events.JSHandler();
    
    this.onUpdate = new vdf.events.JSHandler();
    
    this.onValidate = new vdf.events.JSHandler();

    // @privates
    
    //  LOCKS
    this.iLocked = 0;
    this.bLockedExclusive = false;
    
    //  DATA
    this.tStatus = null;
    this.oBuffer = {};
    
    this.bIsDD = true;
};

vdf.definePrototype("vdf.core.ClientDataDictionary", {


buildStructure : function(tMetaDD){
    var iServer;
    
    //  Find servers
    for(iServer = 0; iServer < tMetaDD.aServers.length; iServer++){
        this.aServers.push(this.oForm.oDDs[tMetaDD.aServers[iServer]]);
        this.oForm.oDDs[tMetaDD.aServers[iServer]].aChildren.push(this);
    }
    
    //  Find constrained
    if(tMetaDD.sConstrainFile !== ""){
        this.oConstrainedTo = this.oForm.oDDs[tMetaDD.sConstrainFile];
        this.oConstrainedTo.aConstrainedFrom.push(this);
    }
    
    //  Create rowid buffer
    this.tStatus = new vdf.dataStructs.TAjaxField();
    this.tStatus.sBinding = this.sName + ".rowid";
    this.tStatus.sType = "R";
    
},

// - - - - - - - - - - Data Entry Object Communication - - - - - - - - - - 


setFieldValue : function(sTable, sField, sValue, bNoPut){
    var iDEO, tField;
    
    sTable = sTable.toLowerCase();
    sField = sField.toLowerCase();
    
    //  If no bNoPut is geven we asume it is false
    if(typeof(bNoPut) === "undefined"){
        bNoPut = false;
    }
    
    //  Forward to the correct DD
    if(sTable != this.sName){
        this.oForm.oDDs[sTable].setFieldValue(sTable, sField, sValue, bNoPut);
    }else{
        if(sField == "rowid"){
            tField = this.tStatus;
        }else{
            tField = this.oBuffer[sTable + "." + sField];
        }
        
        if(tField !== null){
            //  Only update if value is really different
            if(tField.sValue != sValue){
            
                //  Update buffer
                tField.sValue = sValue;
                if(!bNoPut){
                    tField.bChanged = true;
                }
                
                //  Notify DEO
                for(iDEO = 0; iDEO < this.aDEO.length; iDEO++){
                    this.aDEO[iDEO].fieldValueChanged(sTable, sField, sValue);
                }
            }
        }else{
            throw new vdf.errors.Error(5138, "Field not found!", this, [ sTable, sField, "ClientDataDictionary(setFieldValue)" ]);
        }
    }
},


getFieldChangedState : function(sTable, sField){
    sTable = sTable.toLowerCase();
    sField = sField.toLowerCase();

    if(sTable != this.sName){
        return this.oForm.oDDs[sTable].getFieldChangedState(sTable, sField);
    }else{
        if(sField != "rowid"){
            return this.oBuffer[sTable + "." + sField].bChanged;
        }else{
            return false;
        }
    }
},


getFieldValue : function(sTable, sField){
    sTable = sTable.toLowerCase();
    sField = sField.toLowerCase();

    if(sTable != this.sName){
        return this.oForm.oDDs[sTable].getFieldValue(sTable, sField);
    }else{
        if(sField != "rowid"){
            return this.oBuffer[sTable + "." + sField].sValue;
        }else{
            return this.tStatus.sValue;
        }
    }
},


getExpressionValue : function(sExpression){
    sExpression = sExpression.toLowerCase();
    return (this.oBuffer[sExpression] ? this.oBuffer[sExpression].sValue : null);
},


registerDEO : function(oDEO){
    if(oDEO.isBound()){
        //  Forward register call to table DEO if bound to a specific table
        if(oDEO.sTable !== null && oDEO.sTable !== this.sName){
            this.oForm.oDDs[oDEO.sTable].registerDEO(oDEO);
        }else{
        
            //  Add to aDEO if it isn't already in there
            if(!this.deoExists(oDEO)){
                this.aDEO.push(oDEO);
            }
            
            if(oDEO.sField === "rowid"){
                //  Rowid fields are referenced separately as this.oStatus
                if(oDEO.sTable === this.sName){
                    this.oStatus = oDEO;
//                alert(this.sName + " DEO Status value = '" + oDEO.getValue() + "'");
                    this.tStatus.sValue = oDEO.getValue();  //  Instead of using update() we do this manually to prevent a findByRowId from happening
                }
            }else{
                //  Create fields in buffer if needed
                if(oDEO.sDataBindingType === "D" && oDEO.sTable === this.sName && oDEO.sField){
                    this.createBufferField(oDEO.sDataBinding, "D");
                }else if(oDEO.sDataBindingType === "E" && oDEO.sDataBinding){
                    this.createBufferField(oDEO.sDataBinding, "E");
                }
                
                //oDEO.update();
            }
        }
    }
},


deoExists : function(oDEO){
    var iDEO;
    
    for(iDEO = 0; iDEO < this.aDEO.length; iDEO++){
        if(this.aDEO[iDEO] == oDEO){
            return true;
        }   
    }
    
    return false;
},


createBufferField : function(sBinding, sType){
    var tField = new vdf.dataStructs.TAjaxField();
    
    tField.sBinding = sBinding;
    tField.sType = sType;
    
    this.oBuffer[sBinding] = tField;
},

// - - - - - - - - - - Create & Load Snapshots - - - - - - - - - - 


crawlFind : function(fWorker){
    var oDone = { }, fServer;
    
    
    fServer = function(oDD, bLight, bFirst){
        var i;
        
        if(!oDone[oDD.sName]){
            oDone[oDD.sName] = true;
            
            fWorker.call(oDD, oDD, bLight);
            
            for(i = 0; i < oDD.aServers.length; i++){
                fServer.call(this, oDD.aServers[i], (bLight || this.oConstrainedTo === oDD.aServers[i]), false);
            }
            
            if(bFirst){
                for(i = 0; i < oDD.aConstrainedFrom.length; i++){
                    fServer.call(oDD, oDD.aConstrainedFrom[i], false, true);
                }
            }
        }
    };
    
    fServer.call(this, this, false, true);
    
    
},


crawlUp : function(fWorker){
    var oDone = { }, fServer;
    
    
    fServer = function(oDD){
        var i;
        
        if(!oDone[oDD.sName]){
            oDone[oDD.sName] = true;
            
            fWorker.call(oDD, oDD);
            
            for(i = 0; i < oDD.aServers.length; i++){
                fServer.call(this, oDD.aServers[i]);
            }
        }
    };
    
    fServer.call(this, this);
},


crawlAll : function(fWorker){
    var sDD, oForm = this.oForm;
    
    for(sDD in oForm.oDDs){
        if(oForm.oDDs.hasOwnProperty(sDD)){
            fWorker.call(oForm.oDDs[sDD], oForm.oDDs[sDD]);
        }
    }
},


generateExtSnapshot : function(bAddFields){
    var tResult = new vdf.dataStructs.TAjaxSnapShot();

    this.crawlFind(function(oDD, bLight){
        var sBuf, tDD;

        tDD = new vdf.dataStructs.TAjaxDD();
        tDD.sName = oDD.sName;        
        tDD.tStatus = vdf.sys.data.deepClone(oDD.tStatus);
        tDD.bLight = bLight;

        //  Add buffer values
        if(bAddFields && !bLight){
            for(sBuf in oDD.oBuffer){
                if(oDD.oBuffer[sBuf].__isField){
                    tDD.aFields.push(vdf.sys.data.deepClone(oDD.oBuffer[sBuf]));
                }
            }
        }
                
        tResult.aDDs.push(tDD);
    });
    
    return tResult;
},



createSnapshot : function(){
    var sBuf, tResult = new vdf.dataStructs.TAjaxDD();
       
    tResult.sName = this.sName;        
        
    //  Add buffer values
    for(sBuf in this.oBuffer){
        if(this.oBuffer[sBuf].__isField){
            tResult.aFields.push(this.oBuffer[sBuf]);
        }
    }
    tResult.tStatus = this.tStatus;
    tResult.bLight = false;
    
    return tResult;
},


createLiteSnapshot : function(){
    var tResult = new vdf.dataStructs.TAjaxDD();
       
    tResult.sName = this.sName;        
        
    tResult.tStatus = this.tStatus;
    tResult.bLight = true;
    
    return tResult;
},


loadSnapshot : function(oAction, tSnapshot, bRefreshDEO){
    var iDD;
    
    for(iDD = 0; iDD < tSnapshot.aDDs.length; iDD++){
        if(!tSnapshot.aDDs[iDD].bLight){
            this.oForm.oDDs[tSnapshot.aDDs[iDD].sName].loadSnapshotDD(oAction, tSnapshot.aDDs[iDD]);
        }
    }
    
    if(bRefreshDEO || typeof(bRefreshDEO) === "undefined"){
        for(iDD = 0; iDD < tSnapshot.aDDs.length; iDD++){
            if(!tSnapshot.aDDs[iDD].bLight){
                this.oForm.oDDs[tSnapshot.aDDs[iDD].sName].loadSnapshotDEO(oAction);
            }
        }
    }
},


loadSnapshotDD : function(oAction, tDD){
    var iField;
    
//    alert("RECEIVED: " + tDD.sName + " status '" + tDD.tStatus.sValue + "' " + (tDD.tStatus.sValue === null));
    if(!tDD.bLight){
        this.tStatus = tDD.tStatus;
        
        for(iField = 0; iField < tDD.aFields.length; iField++){
            this.oBuffer[tDD.aFields[iField].sBinding] = tDD.aFields[iField];
        }
    }
},


loadSnapshotDEO : function(oAction){
    var iDEO;

    for(iDEO = 0; iDEO < this.aDEO.length; iDEO++){
        this.aDEO[iDEO].refresh(oAction);
    }
    
    this.onRefresh.fire(this);
},

// - - - - - - - - - - Action Implementation - - - - - - - - - - 


initialFill : function(oAction){
    var tRequestSet, bDepending, tRow;
    
    //  Fire event
    if(this.oForm.onBeforeInitialFill.fire(this, {})){
        if(typeof(oAction) !== "object"){
            oAction = new vdf.core.Action("find", this.oForm, this, this, false);
        }else{
            oAction.sMode = "find";
            oAction.oMainDD = this;
        }
        
        
        bDepending = false;
        this.crawlAll(function(oDD){
            if(oDD.tStatus.sValue !== ""){
                bDepending = bDepending || oDD.hasDependingDEO([], {});
            }
        });
        
        if(bDepending){
            //  Generate request objects & collect fields
            tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
            tRequestSet.sName = "initialFill";
            tRequestSet.sRequestType = "initialFill";
            tRequestSet.iMaxRows = 1;
            tRequestSet.bReturnCurrent = false;
            
            //  Create snapshot
            tRow = new vdf.dataStructs.TAjaxSnapShot();
            tRequestSet.aRows.push(tRow);
            
            this.crawlAll(function(oDD){
                var iDeo;
                
                oDD.onUpdate.fire(oDD, { sAction : "findByRowId", oAction : oAction } );
            
                //  Lock DD
                oAction.lock(oDD);
                
                //  Visit DEO for update and lock
                for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                    vdf.errors.clearByField(oDD.aDEO[iDeo]);
                    oDD.aDEO[iDeo].update();
                    oAction.lock(oDD.aDEO[iDeo]);
                }
                
                //  Create snapshot
                tRow.aDDs.push(oDD.createSnapshot());
            });
            
            oAction.addRequestSet(tRequestSet);
            
            //  Send request
            oAction.onResponse.addListener(this.handleInitialFill, this);
            oAction.send();
        }else{
            //  Refresh the DEO's manually
            this.crawlAll(function(oDD){
                var iDeo;
             
                //  Visit DEO for update and lock
                for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                    oDD.aDEO[iDeo].refresh();
                }
            });
            
            //  Fire event
            this.oForm.onAfterInitialFill.fire(this.oForm, { 
                bAccessedServer : false,
                bError : false, 
                iErrorNr : 0, 
                aResponseSets : null 
            });
            
            oAction.unlock();
        }
    }
},


handleInitialFill : function(oEvent){
    var oAction = oEvent.oSource, tResponseSet, oEventInfo; 
    
    //  Fetch final responseset
    tResponseSet = (oEvent.tResponseData ? oEvent.tResponseData.aDataSets[oEvent.tResponseData.aDataSets.length - 1] : null);
    
    oEventInfo = { 
        bAccessedServer : true,
        bError : false, 
        iErrorNr : 0, 
        aResponseSets : (oEvent.tResponseData ? oEvent.tResponseData.aDataSets : null) 
    };
    
    //  If no errors occurred load the snapshot
    if(!oEvent.bError && tResponseSet.aRows.length > 0){
        this.loadSnapshot(oEvent.oSource, tResponseSet.aRows[0]);
    }else{
        if(oEvent.bError){
            oEventInfo.bError = true;
            oEventInfo.iErrorNr = oEvent.iErrorNr;
        }
            
        //  Refresh the DEO's manually
        this.crawlAll(function(oDD){
            var iDeo;
         
            //  Visit DEO for update and lock
            for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                oDD.aDEO[iDeo].refresh();
            }
        });
    }
    
    //  Unlock so the lock's won't block actions done in the onAfterInitialFill
    oAction.unlock();
    
    this.oForm.onAfterInitialFill.fire(this.oForm, oEventInfo);
},


doFind : function(sMode, oField, oAction){
    var tRequestSet, tRow;

    if(oField.sTable !== null && oField.sField !== null){
        
        //  Forward find to the correct DD
        if(oField.sTable !== this.sName){
            this.oForm.oDDs[oField.sTable].doFind(sMode, oField, oAction);
        }else{
            //  Check if the field has an index
            if(parseInt(oField.getMetaProperty("iIndex"), 10) > 0){
                if(this.iLocked <= 0 && !this.bLockedExclusive){
                    if(this.onBeforeFind.fire(this, {sMode : sMode, oField : oField, oInitiator : (oAction ? oAction.oInitiator : this)})){
                        if(typeof(oAction) !== "object"){
                            oAction = new vdf.core.Action("find", this.oForm, this, this, false);
                        }else{
                            oAction.sMode = "find";
                            oAction.oMainDD = this;
                        }
                        //  Generate request objects & collect fields
                        tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
                        tRequestSet.sName = "DDFind";
                        tRequestSet.sRequestType = "findByField";
                        tRequestSet.iMaxRows = 1;
                        tRequestSet.sTable = oField.sTable;
                        tRequestSet.sColumn = oField.sField;
                        tRequestSet.sFindMode = sMode;
                        tRequestSet.bReturnCurrent = false;
                    
                        tRow = new vdf.dataStructs.TAjaxSnapShot();
                        tRequestSet.aRows.push(tRow);
                        
                        this.crawlFind(function(oDD, bLight){
                            var iDeo;
                            
                            oDD.onUpdate.fire(oDD, { sAction : "find", oAction : oAction });
                            
                            if(bLight){
                                //  Visit DEO for update
                                for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                                    oDD.aDEO[iDeo].update();
                                }
                                
                                //  Create lite snapshot
                                tRow.aDDs.push(oDD.createLiteSnapshot());
                            }else{
                                //  Lock DD
                                oAction.lock(oDD);
                                
                                //  Visit DEO for update and lock
                                for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                                    vdf.errors.clearByField(oDD.aDEO[iDeo]);
                                    oDD.aDEO[iDeo].update();
                                    oAction.lock(oDD.aDEO[iDeo]);
                                }
                                
                                //  Create snapshot
                                tRow.aDDs.push(oDD.createSnapshot());
                            }
                        });
                    
                        oAction.addRequestSet(tRequestSet);
                        oAction.__oField = oField;
                        oAction.__sMode = sMode;
                        
                        //  Send request
                        oAction.onResponse.addListener(this.handleFind, this);
                        oAction.send();

                    }
                }
            }else{
                vdf.errors.handle(new vdf.errors.FieldError(5136, "Field not indexed", oField, []));
            }
        }
    }
},


handleFind : function(oEvent){
    var oAction = oEvent.oSource, tResponseSet, oEventInfo; 

    tResponseSet = (oEvent.tResponseData ? oEvent.tResponseData.aDataSets[0] : null);
    
    oEventInfo = { 
        bError : false, 
        iErrorNr : 0, 
        bFound : false, 
        sMode : oAction.__sMode, 
        oField : oAction.__oField, 
        tResponseSet : tResponseSet 
    };
    
    if(!oEvent.bError){
        if(tResponseSet.bFound && tResponseSet.aRows.length > 0){
            oEventInfo.bFound = true;
            this.loadSnapshot(oEvent.oSource, tResponseSet.aRows[0]);
        }
    }else{
        oEventInfo.bError = true;
        oEventInfo.iErrorNr = oEvent.iErrorNr;
    }
    
    //  Unlock so the lock's won't block actions done in the onAfterFind
    oAction.unlock();
    
    this.onAfterFind.fire(this, oEventInfo);
},


doFindByRowId : function(sRowId, oAction){
    var tRequestSet, tRow;

    if(this.iLocked <= 0 && !this.bLockedExclusive){
        if(this.onBeforeFindByRowId.fire(this, {sRowId : sRowId, oInitiator : (oAction ? oAction.oInitiator : this)})){
            if(typeof(oAction) !== "object"){
                oAction = new vdf.core.Action("find", this.oForm, this, this, false);
            }else{
                oAction.sMode = "find";
                oAction.oMainDD = this;
            }
            
            //  Generate request objects & collect fields
            tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
            tRequestSet.sName = "DDFindByRowId";
            tRequestSet.sRequestType = "findByRowId";
            tRequestSet.iMaxRows = 1;
            tRequestSet.sTable = this.sName;
            tRequestSet.sColumn = "rowid";
            tRequestSet.sFindValue = sRowId;
            tRequestSet.bReturnCurrent = false;
            
            //  Create snapshot
            tRow = new vdf.dataStructs.TAjaxSnapShot();
            tRequestSet.aRows.push(tRow);
            
            this.crawlFind(function(oDD, bLight){
                var iDeo;
                
                oDD.onUpdate.fire(oDD, { sAction : "findByRowId", oAction : oAction } );
                if(bLight){
                    //  Visit DEO for update
                    for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                        oDD.aDEO[iDeo].update();
                    }
                    
                    //  Create lite snapshot
                    tRow.aDDs.push(oDD.createLiteSnapshot());
                }else{
                    //  Lock DD
                    oAction.lock(oDD);
                    
                    //  Visit DEO for update and lock
                    for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                        vdf.errors.clearByField(oDD.aDEO[iDeo]);
                        oDD.aDEO[iDeo].update();
                        oAction.lock(oDD.aDEO[iDeo]);
                    }
                    
                    //  Create snapshot
                    tRow.aDDs.push(oDD.createSnapshot());
                }
            });
            
            oAction.addRequestSet(tRequestSet);
            oAction.__sRowId = sRowId;
            
            //  Send request
            oAction.onResponse.addListener(this.handleFindByRowId, this);
            oAction.send();
        }
    }
},


handleFindByRowId : function(oEvent){
    var oAction = oEvent.oSource, tResponseSet, oEventInfo; 

    tResponseSet = (oEvent.tResponseData ? oEvent.tResponseData.aDataSets[0] : null);
    
    oEventInfo = { 
        bError : false, 
        iErrorNr : 0, 
        bFound : false, 
        sRowId : oAction.__sRowId,
        tResponseSet : tResponseSet 
    };
    
    if(!oEvent.bError){
        if(tResponseSet.bFound && tResponseSet.aRows.length > 0){
            oEventInfo.bFound = true;
            this.loadSnapshot(oEvent.oSource, tResponseSet.aRows[0]);
        }
    }else{
        oEventInfo.bError = true;
        oEventInfo.iErrorNr = oEvent.iErrorNr;
    }
    
    //  Unlock so the lock's won't block actions done in the onAfterFindByRowId
    oAction.unlock();
        
    this.onAfterFindByRowId.fire(this, oEventInfo);
},


doDelete : function(oAction){
    var tRequestSet, tRow;
    
    //  TODO:   Add a "has record" check here
    if(this.iLocked <= 0 && !this.bLockedExclusive){
        if(this.onBeforeDelete.fire(this, {oInitiator : (oAction ? oAction.oInitiator : this)})){
            if(typeof(oAction) !== "object"){
                oAction = new vdf.core.Action("delete", this.oForm, this, this, true);
            }else{
                oAction.sMode = "delete";
                oAction.oMainDD = this;
            }
            
            //  Generate request objects & collect fields
            tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
            tRequestSet.sName = "DDDelete";
            tRequestSet.sRequestType = "delete";
            tRequestSet.sTable = this.sName;
            tRequestSet.iMaxRows = 1;
            tRequestSet.bReturnCurrent = false;
            
            tRow = new vdf.dataStructs.TAjaxSnapShot();
            tRequestSet.aRows.push(tRow);
            
            this.crawlAll(function(oDD){
                var iDeo;

                oDD.onUpdate.fire(oDD, { sAction : "delete", oAction : oAction } );
                
                //  Lock DD
                oAction.lock(oDD);
                
                //  Visit DEO for update and lock
                for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                    vdf.errors.clearByField(oDD.aDEO[iDeo]);
                    oDD.aDEO[iDeo].update();
                    oAction.lock(oDD.aDEO[iDeo]);
                }
                
                //  Create snapshot
                tRow.aDDs.push(oDD.createSnapshot());
            });
            
            oAction.addRequestSet(tRequestSet);

            //  Send request
            oAction.onResponse.addListener(this.handleDelete, this);
            oAction.send();
        }
    }
},


handleDelete : function(oEvent){
    var oAction = oEvent.oSource, tResponseSet, oEventInfo; 

    tResponseSet = (oEvent.tResponseData ? oEvent.tResponseData.aDataSets[0] : null);
    
    oEventInfo = { 
        bError : false, 
        iErrorNr : 0, 
        tResponseSet : tResponseSet 
    };
    
    if(!oEvent.bError){
        if(tResponseSet.aRows.length > 0){
            this.loadSnapshot(oEvent.oSource, tResponseSet.aRows[0]);
        }
    }else{
        oEventInfo.bError = true;
        oEventInfo.iErrorNr = oEvent.iErrorNr;
    }
    
    //  Unlock so the lock's won't block actions done in the onAfterDelete
    oAction.unlock();
        
    this.onAfterDelete.fire(this, oEventInfo);
},


doSave : function(oAction){
    var tRequestSet, tRow, iError;

    //  Lock
    if(this.iLocked <= 0 && !this.bLockedExclusive){
    
        //  Developer event
        if(this.onBeforeSave.fire(this, { oInitiator : (oAction ? oAction.oInitiator : this) })){
            
            //  Clientside validation
            iError = this.validate();
            if(iError === 0){
                if(typeof(oAction) !== "object"){
                    oAction = new vdf.core.Action("save", this.oForm, this, this, true);
                }else{
                    oAction.sMode = "save";
                    oAction.oMainDD = this;
                }
                
                //  Generate request objects & collect fields
                tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
                tRequestSet.sName = "DDSave";
                tRequestSet.sRequestType = "save";
                tRequestSet.sTable = this.sName;
                tRequestSet.iMaxRows = 1;
                tRequestSet.bReturnCurrent = false;
                
                tRow = new vdf.dataStructs.TAjaxSnapShot();
                tRequestSet.aRows.push(tRow);
                
                
                this.crawlAll(function(oDD){
                    var iDEO;
                    
                    oDD.onUpdate.fire(oDD, { sAction : "save", oAction : oAction } );
                    
                    //  Lock DD
                    oAction.lock(oDD);
                    
                    //  Visit DEO for update and lock
                    for(iDEO = 0; iDEO < oDD.aDEO.length; iDEO++){
                        vdf.errors.clearByField(oDD.aDEO[iDEO]);
                        oDD.aDEO[iDEO].update();
                        oAction.lock(oDD.aDEO[iDEO]);
                    }
                    
                    //  Create snapshot
                    tRow.aDDs.push(oDD.createSnapshot());
                });
                
                oAction.addRequestSet(tRequestSet);

                //  Send request
                oAction.onResponse.addListener(this.handleSave, this);
                oAction.send();
            }else{
                this.onAfterSave.fire(this, { 
                    bError : true, 
                    iErrorNr : iError, 
                    tResponseSet : null 
                });
            }
        }
    }
},


handleSave : function(oEvent){
    var oAction = oEvent.oSource, tResponseSet, oEventInfo; 

    tResponseSet = (oEvent.tResponseData ? oEvent.tResponseData.aDataSets[0] : null);
    
    oEventInfo = { 
        bError : false, 
        iErrorNr : 0, 
        tResponseSet : tResponseSet 
    };
    
    if(!oEvent.bError){
        if(tResponseSet.aRows.length > 0){
            this.loadSnapshot(oEvent.oSource, tResponseSet.aRows[0]);
        }
    }else{
        oEventInfo.bError = true;
        oEventInfo.iErrorNr = oEvent.iErrorNr;
    }
    
    //  Unlock so the lock's won't block actions done in the onAfterSave
    oAction.unlock();
    
    this.onAfterSave.fire(this, oEventInfo);
},


doClear : function(oAction){
    var tRequestSet, tRow;

    if(this.iLocked <= 0 && !this.bLockedExclusive){
        if(this.onBeforeClear.fire(this, { oInitiator : (oAction ? oAction.oInitiator : this) })){
            if(typeof(oAction) !== "object"){
                oAction = new vdf.core.Action("clear", this.oForm, this, this, true);
            }else{
                oAction.sMode = "clear";
                oAction.oMainDD = this;
            }
            
            //  Generate request objects & collect fields
            tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
            tRequestSet.sName = "DDClear";
            tRequestSet.sRequestType = "clear";
            tRequestSet.sTable = this.sName;
            tRequestSet.iMaxRows = 1;
            tRequestSet.bReturnCurrent = false;
            
            tRow = new vdf.dataStructs.TAjaxSnapShot();
            tRequestSet.aRows.push(tRow);
            
            this.crawlFind(function(oDD, bLight){
                var iDeo;
                
          
                oDD.onUpdate.fire(oDD, { sAction : "clear", oAction : oAction } );
            
                if(bLight){
                    //  Visit DEO for update
                    for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                        oDD.aDEO[iDeo].update();
                    }
                    
                    //  Create lite snapshot
                    tRow.aDDs.push(oDD.createLiteSnapshot());
                }else{
                    //  Lock DD
                    oAction.lock(oDD);
                    
                    //  Visit DEO for update and lock
                    for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                        vdf.errors.clearByField(oDD.aDEO[iDeo]);
                        oDD.aDEO[iDeo].update();
                        oAction.lock(oDD.aDEO[iDeo]);
                    }
                    
                    //  Create snapshot
                    tRow.aDDs.push(oDD.createSnapshot());
                }
            });

            oAction.addRequestSet(tRequestSet);
            
            //  Send request
            oAction.onResponse.addListener(this.handleClear, this);
            oAction.send();
        }
    }   
},


handleClear : function(oEvent){
    var oAction = oEvent.oSource, tResponseSet, oEventInfo; 

    tResponseSet = (oEvent.tResponseData ? oEvent.tResponseData.aDataSets[0] : null);
    
    oEventInfo = { 
        bError : false, 
        iErrorNr : 0, 
        tResponseSet : tResponseSet 
    };
    
    if(!oEvent.bError){
        if(tResponseSet.aRows.length > 0){
            this.loadSnapshot(oEvent.oSource, tResponseSet.aRows[0]);
        }
    }else{
        oEventInfo.bError = true;
        oEventInfo.iErrorNr = oEvent.iErrorNr;
    }
     
    //  Unlock so the lock's won't block actions done in the onAfterClear
    oAction.unlock();
    
    this.onAfterClear.fire(this, oEventInfo);
},



doClearAll : function(oAction){
    var tRequestSet, tRow;

    if(this.iLocked <= 0 && !this.bLockedExclusive){
        if(this.onBeforeClearAll.fire(this, { oInitiator : (oAction ? oAction.oInitiator : this) })){
            if(typeof(oAction) !== "object"){
                oAction = new vdf.core.Action("clear", this.oForm, this, this, true);
            }else{
                oAction.sMode = "clear";
                oAction.oMainDD = this;
            }
            
            //  Generate request objects & collect fields
            tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
            tRequestSet.sName = "DDClearAll";
            tRequestSet.sRequestType = "clearAll";
            tRequestSet.sTable = this.sName;
            tRequestSet.iMaxRows = 1;
            tRequestSet.bReturnCurrent = false;
            
            tRow = new vdf.dataStructs.TAjaxSnapShot();
            tRequestSet.aRows.push(tRow);
            
            this.crawlAll(function(oDD){
                var iDeo;
                
                oDD.onUpdate.fire(oDD, { sAction : "clear", oAction : oAction } );
            
                //  Lock DD
                oAction.lock(oDD);
                
                //  Visit DEO for update and lock
                for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                    vdf.errors.clearByField(oDD.aDEO[iDeo]);
                    oDD.aDEO[iDeo].update();
                    oAction.lock(oDD.aDEO[iDeo]);
                }
                
                //  Create snapshot
                tRow.aDDs.push(oDD.createSnapshot());
            });

            oAction.addRequestSet(tRequestSet);
            
            //  Send request
            oAction.onResponse.addListener(this.handleClearAll, this);
            oAction.send();
        }
    }   
},


handleClearAll : function(oEvent){
    var oAction = oEvent.oSource, tResponseSet, oEventInfo; 

    tResponseSet = (oEvent.tResponseData ? oEvent.tResponseData.aDataSets[0] : null);
    
    oEventInfo = { 
        bError : false, 
        iErrorNr : 0, 
        tResponseSet : tResponseSet 
    };
    
    if(!oEvent.bError){
        if(tResponseSet.aRows.length > 0){
            this.loadSnapshot(oEvent.oSource, tResponseSet.aRows[0]);
        }
    }else{
        oEventInfo.bError = true;
        oEventInfo.iErrorNr = oEvent.iErrorNr;
    }
     
    //  Unlock so the lock's won't block actions done in the onAfterClear
    oAction.unlock();
    
    this.onAfterClearAll.fire(this, oEventInfo);
},


//  - - - - - - - - - Special functionallity - - - - - - - - - - - -



validate : function(){
    var iError = 0;
    if(this.onValidate.fire(this)){
        this.crawlUp(function(oDD){
            var iDeo, iResult = 0;
            
            oDD.onUpdate.fire(oDD, { sAction : "validate", oAction : null } );
            
            //  First update the buffers
            for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                oDD.aDEO[iDeo].update();
            }
            
            //  Validate the DEOs
            for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                iResult = oDD.aDEO[iDeo].validate();
                
                if(iResult > 0 && iError === 0){
                    iError = iResult;
                }
            }     
        });
    }else{
        iError = 1;
    }
    
    return iError;
},


hasRecord : function(){
    return this.tStatus.sValue !== null && this.tStatus.sValue !== "";
},


lock : function(bExclusive, oAction){
    if(this.bLockedExclusive || bExclusive && this.iLocked > 0){
        return false;
    }else{
        if(bExclusive){
            this.bLockedExclusive = true;
        }
        
        this.iLocked++;
        
        return true;
    }
},


unlock : function(bExclusive, oAction){
    if(bExclusive){
        this.bLockedExclusive = false;
    }
    
    this.iLocked--;
},


hasDependingDEO : function(aSearchedDEO, oDone){
    var iCurrent, iDEO, iSearch;

    if(typeof(oDone) === "undefined"){
        oDone = {};
    }
    
    if(!oDone[this.sName]){
        //  Mark as done
        oDone[this.sName] = true;
        
        d:for(iDEO = 0; iDEO < this.aDEO.length; iDEO++){
            for(iSearch = 0; iSearch < aSearchedDEO.length; iSearch++){
                if(this.aDEO[iDEO] === aSearchedDEO[iSearch] || this.aDEO[iDEO].sDataBindingType == "R"){
                    continue d;
                }
            }
            
            return true;
        }   
        
        //  Move to servers
        // for(iCurrent = 0; iCurrent < this.aServers.length; iCurrent++){
            // if(this.aServers[iCurrent].hasDependingDEO(aSearchedDEO, oDone)){
                // return true;
            // }
        // }
        
        //  Move into DDs constrained to this DD
        for(iCurrent = 0; iCurrent < this.aConstrainedFrom.length; iCurrent++){
            if(this.aConstrainedFrom[iCurrent].hasDependingDEO(aSearchedDEO, oDone)){
                return true;
            }
        }
    }
    
    return false;    
},


isParent : function(oSearchedDD, oDone){
    var iCurrent;

    if(typeof(oDone) === "undefined"){
        oDone = {};
    }
    
    if(!oDone[this.sName]){
        //  Mark as done
        oDone[this.sName] = true;
        
        //  Move to servers
        for(iCurrent = 0; iCurrent < this.aServers.length; iCurrent++){
            if(this.aServers[iCurrent] === oSearchedDD || this.aServers[iCurrent].isParent(oSearchedDD, oDone)){
                return true;
            }
        }
    }
    
    return false;
},


isChanged : function(tSnapshot, bSkipConstrainedTo){
    var bChanged = false;
    
    this.crawlFind(function(oDD, bLight){
        var iDeo, iDD;
        
        if(!bLight || !bSkipConstrainedTo){
            
            //  Check rowid (if no snapshot is given we asume it might not be empty
            if(tSnapshot){
                for(iDD = 0; iDD < tSnapshot.aDDs.length; iDD++){
                    if(tSnapshot.aDDs[iDD].sName === oDD.sName){
                        if(tSnapshot.aDDs[iDD].tStatus.sValue !== oDD.tStatus.sValue){
                            bChanged = true;
                        }
                    }
                }
            }else{
                if(oDD.tStatus.sValue !== ""){
                    bChanged = true;
                }
            }
            
            //  Check if data entry objects are changed
            for(iDeo = 0; iDeo < oDD.aDEO.length && !bChanged; iDeo++){
                if(oDD.aDEO[iDeo].isChanged()){
                    bChanged = true;
                }
            }
            
            
        }
    });
    
    return bChanged;
}, 


debugDetails : function(oErr){
	var aHTML, sField;

	aHTML = [
		"<b>Control type:</b> ", vdf.sys.ref.getType(this), "<br/>",
		"<b>Table name:</b> ", this.sName, "<br/>",
		"<br/>",
		"<b>Buffer content:</b><hr/>",
		"<table><tr><th>Field name</th><th>Changed</th><th><th>Value</th></tr>"
	];
	
	for(sField in this.oBuffer){
		if(this.oBuffer.hasOwnProperty(sField)){
			aHTML.push("<tr><td>", sField, "</td><td>", this.oBuffer[sField].bChanged, "</td><td>",  this.oBuffer[sField].sValue, "</td></tr>");
		}
	}
	
	aHTML.push("</table>");
	
	return aHTML.join("");
}


});




vdf.core.DEO = function DEO(eElement, oParentControl){
    this.Control(eElement, oParentControl);
    
    this.oServerDD = null;
    
    this.sServerTable = null;
    
    
    this.sDataBindingType = null;
    
    this.sDataBinding = null;
    
    this.sTable = null;
    
    this.sField = null;
    
    //  @privates
    this.bIsDEO = true;
    this.oErrorDisplay = null;
    
    this.iLocked = 0;
};

vdf.definePrototype("vdf.core.DEO", "vdf.core.Control", {


bindDD : function(){

},


isBound : function(){
    return true;
},


fieldValueChanged : function(sTable, sField, sValue){

},


refresh : function(oAction){

},


validate : function(oAction){
    this.update();

    return 0;
},


update : function(){

},


getMetaProperty : function(sProperty){
    return null;
},


isChanged : function(){
    return false;
},


lock : function(bExclusive, oAction){
    this.iLocked++;
},


unlock : function(bExclusive, oAction){
    this.iLocked--;
},


debugDetails : function(oErr){

	var aHTML = [
		"<b>Data binding:</b> ", this.sDataBinding, "<br/>",
		"<b>Server DD:</b> ", (this.oServerDD ? this.oServerDD.sName : "unknown" ),
		"<br/>",
		this.Control.prototype.debugDetails.call(this, oErr)
	];
	
	return aHTML.join("");
}

});






vdf.core.Field = function Field(eElement, oParentControl){
    this.DEO(eElement, oParentControl);
    
    //  PUBLIC
    
    
    this.sLockDisplay = this.getVdfAttribute("sLockDisplay", this.getVdfAttribute("sDisplayLock", "CssClass", true), true);
    
    this.iLockDuration = this.getVdfAttribute("iLockDuration", 400, true);
    
    this.sLockClass = this.getVdfAttribute("sLockClass", "locked", true);
    
    
    this.bDisplayErrorIcon = this.getVdfAttribute("bDisplayErrorIcon", (!this.oParentControl || vdf.sys.ref.getType(this.oParentControl) !== "Grid"), true);
    
    
    this.oLookup = null;
    
    //  Validation properties (will be inialized later due to meta data request)
    
    this.bValidateServer = null;
    
    this.sDataType = null;
    
    this.sDefaultValue = null;
    
    this.bCapslock = null;
    
    this.bNoPut = null;
    
    this.bDisplayOnly = null; 
    
    this.bNoEnter = null;
    
    this.bSkipFound = null;
    
    
    this.bRequired = null;
    
    this.sCheck = null;
    
    this.bFindReq = null;
    
    this.sMinValue = null;
    
    this.sMaxValue = null;
    
    
    this.onValidate = new vdf.events.JSHandler();
    
    this.onChange = new vdf.events.JSHandler();
    
    //  @privates
    this.bIsField = true;
    this.bHasFocus = false;
    this.sOrigValue = null;
    this.sDisplayValue = this.getValue();
    this.eOverlay = null;
    this.sFadeOrigColor = null;
    this.sFadeColor = null;
    
    //  Init databinding
    this.detectBinding();
    
    //  Register to parent as data entry object
    if(oParentControl !== null && typeof(oParentControl.addDEO) == "function"){
        oParentControl.addDEO(this);
    }
};

vdf.definePrototype("vdf.core.Field", "vdf.core.DEO", {


bFocusable : true,


formInit : function(){
    var sStatusHelp;
    
    //  Load validation properties
    this.bValidateServer = this.getMetaProperty("bValidateServer");
    this.sDataType = this.getMetaProperty("sDataType");
    this.bCapslock = this.getMetaProperty("bCapslock");
    this.bNoPut = this.getMetaProperty("bNoPut");
    this.bDisplayOnly = this.getMetaProperty("bDisplayOnly");
    this.bNoEnter = this.getMetaProperty("bNoEnter");
    this.bSkipFound = this.getMetaProperty("bSkipFound");
    
    this.bRequired = this.getMetaProperty("bRequired");
    this.sCheck = this.getMetaProperty("sCheck");
    this.bFindReq = this.getMetaProperty("bFindReq");
    
    this.sMinValue = this.getMetaProperty("sMinValue");
    this.sMaxValue = this.getMetaProperty("sMaxValue");

    this.sDataType = this.getMetaProperty("sDataType");
    this.sDefaultValue = this.getMetaProperty("sDefaultValue");    
    
    //  Add DOM listeners
    this.addDomListener("focus", this.onFocus, this);
    this.addDomListener("blur", this.onBlur, this);
    this.addDomListener("change", this.onElemChange, this);
    if(this.oForm.bAttachKeyActions){
        this.addKeyListener(this.onKey, this);
    }
    
    //  Update the display value
    this.sDisplayValue = this.getValue();
    
    //  Set the title to the statushelp (if not set)
    if(this.getAttribute("title") === null){
        sStatusHelp = this.getMetaProperty("sStatusHelp");
        if(sStatusHelp){
            this.setAttribute("title", sStatusHelp);
        }
    }
    
    if(this.sDefaultValue !== null){
        this.setValue(this.sDefaultValue, false, true);
    }
    
    this.initDisplayLock();
},


destroy : function(){
    if(this.eElement){
        vdf.events.clearDomListeners(this.eElement);
    }
    this.eOverlay = null;
},


onElemChange : function(oEvent){
    this.update();
},


onKey : function(oEvent){
    var oPressedKey = {
        iKeyCode : oEvent.getKeyCode(),
        bCtrl : oEvent.getCtrlKey(),
        bShift : oEvent.getShiftKey(),
        bAlt : oEvent.getAltKey()
    };
    
    //vdf.log("Keypress code: " + oPressedKey.iKeyCode + " ctrl: " + oPressedKey.bCtrl + " shift: " + oPressedKey.bShift + " alt: " + oPressedKey.bAlt);
    
    try{
        if(this.oForm.oActionKeys){
            if(vdf.sys.ref.matchByValues(oPressedKey, this.oForm.oActionKeys.findGT)){ 
                this.doFind(vdf.GT);  // F8:  find next
                oEvent.stop();
            }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oForm.oActionKeys.findLT)){ 
                this.doFind(vdf.LT);  // F7:  find previous
                oEvent.stop();
            }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oForm.oActionKeys.findGE)){ 
                this.doFind(vdf.GE);  // F9:  find equal
                oEvent.stop();
            }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oForm.oActionKeys.save)){ 
                this.doSave();        // F2:  save
                oEvent.stop();
            }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oForm.oActionKeys.clear)){ 
                this.doClear();       // F5:  clear
                oEvent.stop();
            }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oForm.oActionKeys.clearAll)){ 
                this.doClearAll();    // Crtl - F5:  clear all
                oEvent.stop();
            }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oForm.oActionKeys.lookup)){ 
                if(this.oLookup !== null){  // F4:  lookup
                    this.oLookup.display(this);
                    oEvent.stop();
                }
            }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oForm.oActionKeys.findFirst)){ 
                this.doFind(vdf.FIRST); // ctrl - home: find first
                oEvent.stop();
            }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oForm.oActionKeys.findLast)){ 
                this.doFind(vdf.LAST);  // ctrl - end:  find last
                oEvent.stop();
            }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oForm.oActionKeys.remove)){ 
                this.doDelete();      // shift - F2:  delete
                oEvent.stop();
            }
        }
        
    }catch (oError){
        vdf.errors.handle(oError);
    }
},


onFocus : function(oEvent){
    this.bHasFocus = true;
    this.oForm.oActiveField = this;
},


onBlur : function(oEvent){
    this.bHasFocus = false;
},


focus : function(bSelect){
    vdf.sys.dom.focus(this.eElement, bSelect);
},


getValue : function(){
    return this.eElement.value;
},


setValue : function(sValue, bNoNotify, bResetChange){
    this.eElement.value = sValue;
    
    if(!bNoNotify){
        this.update();
    }
    
    this.onChange.fire(this, { "sValue" : sValue, sPrevValue : this.sOrigValue });
    
    this.sOrigValue = sValue;
    
    if(bResetChange){
        this.sDisplayValue = this.getValue();
    }
},


isChanged : function(){
    return this.getValue() !== this.sDisplayValue;
},


insertElementAfter : function(eElement){
    if(this.oLookup && typeof this.oLookup.eElement === "object" && this.eElement.parentNode === this.oLookup.eElement.parentNode){
        vdf.sys.dom.insertAfter(eElement, this.oLookup.eElement);
    }else{
        vdf.sys.dom.insertAfter(eElement, this.eElement);
    }
    
    //this.eElement.parentNode.appendChild(eElement);
    
},


getMetaProperty : function(sProp){
    //  Note: The vdf.core.Label class also uses this method

    var sForeign = "bAutoFind, bAutoFindGE, bDisplayOnly, bFindReq, bNoEnter, bNoPut, bSkipFound";
    var sResult = this.getVdfAttribute(sProp, null, false);

    if(sResult === null && this.oForm && this.oForm.oMetaData){
        if(this.sDataBindingType === "D"){
            sResult = this.oForm.oMetaData.getFieldProperty(sProp, this.sTable, this.sField);
            
            //  If this propery has a foreign equalivant and this field is foreign and origional value is false load the foreign value
            if((!sResult || sResult === "false") && sForeign.match(sProp) !== null && this.isForeign()){
                sProp = "b" + "Foreign_" + sProp.substr(1);
                sResult = this.oForm.oMetaData.getFieldProperty(sProp, this.sTable, this.sField);
            }
        }else if(this.sDataBindingType === "E"){
            //  Hardcode display only for expression fields!
            if(sProp === "bDisplayOnly"){
                sResult = "true";
            }
        }
    }
    
    //  Convert string to boolean
    if(sResult == "true"){
        return true;
    }else if(sResult == "false"){
        return false;
    }else{
        return sResult;
    }
},


getGlobalMetaProperty : function(sProp, sDefault, bBubble){
    var sResult = this.getVdfAttribute(sProp, null, !!bBubble);
    
    if(sResult === null){
        sResult = this.oForm && this.oForm.oMetaData && this.oForm.oMetaData.getGlobalProperty(sProp);
        
        if(sResult === null || sResult === undefined){
            return sDefault;
        }
    }
    
    return sResult;
},


getChangedState : function(){
    if(this.sDataBindingType === "D"){
        return this.oServerDD.getFieldChangedState(this.sTable, this.sField);
    }
    
    return false;
},



isForeign : function(){
    if(this.oServerDD !== null){
        return this.oServerDD.isParent(this.oForm.oDDs[this.sTable]);
    }else{
        return null;
    }
},

//  - - - - -   V A L I D A T I O N   - - - - - 


initValidation : function(bAttachListeners){
    if(typeof(bAttachListeners) === "undefined"){
        bAttachListeners = true;
    }
    
    //  Disables the field if needed
    if(this.bNoEnter || this.bDisplayOnly || (this.bSkipFound && this.sDataBindingType === "D" && this.oForm.getDD(this.sTable).hasRecord())){
        this.disable();
    }
    
    //  Attaches validation keylistener
    if(bAttachListeners){
        this.addKeyListener(this.onValidateField, this);
    }
},


onValidateField : function(oEvent){
    if(oEvent.getKeyCode() == 9 && !oEvent.getShiftKey()){
        if(this.validate(true) > 0){
            oEvent.stop();
        }else{
            if(this.bValidateServer){
                this.validateServer();
            }
        }
    }
},


validate : function(bWaitAutoFind){
    var aValues, sValue, iResult, bCheck, bRequired = true, iVal, bResult;
    
    vdf.errors.clearByField(this);
    
    iResult = this.DEO.prototype.validate.call(this);
    sValue = this.getValue();
    
    //  Fire the onValidate event
    if(!this.onValidate.fire(this, { bWaitAutoFind : (bWaitAutoFind && (this.bAutoFind || this.bAutoFindGE)) })){
        iResult = 1;
    }
    
    //  Required...
    if(this.bRequired){
        if((this.sDataType === "bcd" && (parseInt(sValue, 10) === 0 || sValue === "") ) || this.sDataType !== "bcd" && sValue === ""){
            vdf.errors.handle(new vdf.errors.FieldError(5128, "Required", this));
            iResult = (iResult > 0 ? iResult : 5128);
            bRequired = false;
        }else{
            vdf.errors.clear(5128, this);
        }
    }
    
    //  Check values
    if(this.sCheck){
        aValues = this.sCheck.split("|");
        bCheck = false;
        
        for(iVal = 0; iVal < aValues.length && !bCheck; iVal++){
            bCheck = (sValue === aValues[iVal]);
        }
        
        if(bCheck){
            vdf.errors.clear(5125, this);
        }else{
            vdf.errors.handle(new vdf.errors.FieldError(5125, "Unmatched check value", this));
            iResult = (iResult > 0 ? iResult : 5125);
        }
    }
    
    //  Find required (if autofind or autofindge are enabled it doesn't validate findrequired yet to prevent errors from flashing before autofind is finished)
    if((bWaitAutoFind && !this.bAutoFind && !this.bAutoFindGE && this.bFindReq) || (!bWaitAutoFind && this.bFindReq)){
        if(this.oServerDD && this.sDataBindingType === "D"){
            if(this.oForm.getDD(this.sTable).hasRecord() && !this.getChangedState() && !this.isChanged()){
                vdf.errors.clear(5124, this);
            }else{
                vdf.errors.handle(new vdf.errors.FieldError(5124, "Find required", this));
                bResult = false;
                iResult = (iResult > 0 ? iResult : 5124);
            }

        }
    }
    
    //  Min / Max value
    if(this.sMaxValue || this.sMaxValue === 0){
        if((this.sDataType === "bcd" && parseFloat(sValue) <= parseFloat(this.sMaxValue)) || (this.sDataType !== "bcd" && sValue > this.sMaxValue) || sValue === ""){
            vdf.errors.clear(5126, this);
        }else{
            vdf.errors.handle(new vdf.errors.FieldError(5126, "Maximum value", this, [this.sMaxValue]));
            iResult = (iResult > 0 ? iResult : 5126);
        }
    }
    if(this.sMinValue || this.sMinValue === 0){
        if((this.sDataType === "bcd" && parseFloat(sValue) >= parseFloat(this.sMinValue)) || (this.sDataType !== "bcd" && sValue > this.sMinValue) || sValue === ""){
            vdf.errors.clear(5127, this);
        }else{
            vdf.errors.handle(new vdf.errors.FieldError(5127, "Minimum value", this, [this.sMinValue]));
            iResult = (iResult > 0 ? iResult : 5127);
        }
    }
    
    
    
    return iResult;
},


validateServer : function(){
    var tRequest, oCall;

    if(this.oServerDD && this.sDataBindingType === "D"){
        
        
        //  Update buffer
        this.update();
        
        //  Generate request
        tRequest = new vdf.dataStructs.TAjaxValidationRequest();
        tRequest.sSessionKey = vdf.sys.cookie.get("vdfSessionKey");
        tRequest.sWebObject = this.oForm.sWebObject;
        tRequest.sFieldName = this.sDataBinding;
        tRequest.tRow = this.oServerDD.generateExtSnapshot(true);
        
        //  Send request
        oCall = new vdf.ajax.SoapCall("ValidateField", { tRequest : tRequest }, this.oForm.sWebServiceUrl);
        oCall.onFinished.addListener(this.handleValidateServer, this);
        oCall.send(true);
    }
},


handleValidateServer : function(oEvent){
    var iError, tResponse = oEvent.oSource.getResponseValue("TAjaxValidationResponse");
    
    if(tResponse.sFieldValue == this.getValue()){
        for(iError = 0; iError < tResponse.aErrors.length; iError++){
            vdf.errors.handle(vdf.errors.createServerError(tResponse.aErrors[iError], this));
        }
        
        if(tResponse.iError !== 0){
            this.focus();
        }
    }
},

//  - - - - -   D E O   - - - - - 


detectBinding : function(){
    //  Note: The vdf.core.Label also uses this method

    var aParts, sBinding, sType;

    sBinding = this.getVdfAttribute("sDataBinding", null, false);
    sType = this.getVdfAttribute("sDataBindingType", null, false);

    //  Use name for binding if none given
    if(sBinding === null){
        sBinding = this.getAttribute("name");
    }
    //  Uppercase type
    if(sType !== null){
        sType = sType.toUpperCase();
    }
    
    if(sBinding !== null){
        if((sType === "R" || sType === "D" || sType === null) && sBinding.replace("__", ".").match(/^[a-zA-Z][a-zA-Z0-9_@#]*\.[a-zA-Z][a-zA-Z0-9_@#]*$/)){
            //  Regular database fields must apply to the <table>(.|__)<field> format
            
            //  Clean binding and split into table and field name.
            sBinding = sBinding.replace("__", ".").toLowerCase();
            aParts = sBinding.split(".");
            
            //  Save binding data
            this.sTable = aParts[0];
            this.sField = aParts[1];
            this.sDataBinding = sBinding;
            this.sDataBindingType = (this.sField == "rowid" ? "R" : "D");
        }else if((sBinding.match(/^[eE]\:[a-zA-Z][a-zA-Z0-9_@#]*$/) && (sType === "E" || sType === null)) || (sBinding.match(/^[a-zA-Z][a-zA-Z0-9_@#]*$/) && sType === "E")){
            //  Expression fields start with a "e:<functionname>" or have their data binding name explicitly set to "E"
            if(sBinding.substr(0, 2).toUpperCase() === "E:"){
                sBinding = sBinding.substr(2);
            }
            
            this.sDataBindingType = "E";
            this.sDataBinding = sBinding.toLowerCase();
        }else{  
            //  Else we assume it is a user data field
            this.sDataBindingType = "U";
            this.sDataBinding = sBinding.toLowerCase();
        }
    }
    
    
    
},


bindDD : function(){
    var sServerTable;

    if(this.oForm !== null){
        //  Detect server dd
        sServerTable = this.getVdfAttribute("sServerTable", null, true);
        if(sServerTable !== null){
            this.oServerDD = this.oForm.oDDs[sServerTable.toLowerCase()];
        }
        
        //  Register...
        if(this.sDataBindingType === "U"){
            this.oForm.registerUserDataField(this);
        }else{
            if(this.oServerDD){
                this.oServerDD.registerDEO(this);
            }
        }
    }
},


isBound : function(){
    return this.sDataBindingType !== null && this.sDataBindingType !== "U";
},


fieldValueChanged : function(sTable, sField, sValue){
    if(this.sTable === sTable && this.sField === sField){
        this.setValue(sValue, true, false);
    }
},


refresh : function(oAction){
    if(this.sDataBindingType === "E") {
        this.setValue(this.oServerDD.getExpressionValue(this.sDataBinding), true, true);
    }else{
        this.setValue(this.oServerDD.getFieldValue(this.sTable, this.sField), true, true);
    }
    
    if(this.bSkipFound && this.sDataBindingType === "D"){
        if(this.oForm.getDD(this.sTable).hasRecord()){
            this.disable();
        }else{
            this.enable();
        }
    }
},


displayLockAniFinished : function(){
    this.oAniCurLock = null;
},


displayUnlockAniFinished : function(){
    this.oAniCurLock = null;
    
    if(this.sLockDisplay === "FadeOverlay"){
        //  Hide the overlay element
        this.eOverlay.style.display ="none";
    }
},


initDisplayLock : function(){
    if(this.sLockDisplay === "CssClass"){
        //  Create lock animation based on adding the CSS class
        this.oAniSetLock = vdf.sys.fx.animAddClass(this.eElement, this.sLockClass, this.iLockDuration, this.displayLockAniFinished, this);
        
        //  Create unlock animation based on removing the CSS class
        vdf.sys.gui.addClass(this.eElement, this.sLockClass);
        this.oAniSetUnlock = vdf.sys.fx.animRemoveClass(this.eElement, this.sLockClass, this.iLockDuration, this.displayUnlockAniFinished, this);
        vdf.sys.gui.removeClass(this.eElement, this.sLockClass);
    }else if(this.sLockDisplay === "FadeOverlay"){
        //  Create the overlay div
        if(this.eOverlay === null){
            this.eOverlay = document.createElement("div");
            this.eOverlay.className = "locked_overlay";
            vdf.sys.dom.insertAfter(this.eOverlay, this.eElement);
        }
        var oOffset = vdf.sys.gui.getAbsoluteOffset(this.eElement);
        this.eOverlay.style.display = "none";
        this.eOverlay.style.top = oOffset.top + "px";
        this.eOverlay.style.left = oOffset.left + "px";
        this.eOverlay.style.width = this.eElement.offsetWidth + "px";
        this.eOverlay.style.height = this.eElement.offsetHeight + "px";
        vdf.sys.gui.setOpacity(this.eOverlay, 0);
        
        //  Create lock animation (fade in)
        this.oAniSetLock  = new vdf.sys.fx.Set({
            aEffects : [{
                eTarget : this.eOverlay,
                sType : "opacity",
                sTo : "70",
                iDuration : this.iLockDuration,
                fFinished : this.displayLockAniFinished,
                oFinishEnv  : this
            }]
        });
        
        //  Create unlock animation (fade out)
        this.oAniSetUnlock  = new vdf.sys.fx.Set({
            aEffects : [{
                eTarget : this.eOverlay,
                sType : "opacity",
                sTo : "0",
                iDuration : this.iLockDuration,
                fFinished : this.displayUnlockAniFinished,
                oFinishEnv  : this
            }]
        });
    }
},



displayLock : function(oAction){
    //  Stop running animation
    if(this.oAniCurLock){
        this.oAniCurLock.stop(true);
        this.oAniCurLock = null;
    }
    
    //  Add lock animation
    if(this.oAniSetLock){
        this.oAniCurLock = this.oAniSetLock;
        oAction.addLockAnim(this.oAniSetLock);
    }
    
    
    if(this.sLockDisplay === "FadeOverlay"){
        //  Hide the overlay element.
        this.eOverlay.style.display ="";
    }
        
    return;    
},


displayUnlock : function(oAction){
    //  Stop running animation
    if(this.oAniCurLock){
        this.oAniCurLock.stop(true);
        this.oAniCurLock = null;
    }
    
    //  Add unlock animation
    if(this.oAniSetUnlock){
        this.oAniCurLock = this.oAniSetUnlock;
        oAction.addUnlockAnim(this.oAniSetUnlock);
    }
    
    return;  
},


update : function(){
    //  Check if the value is changed
    var sValue = this.getValue();
    if(sValue != this.sOrigValue){
        //  If we are data bound we tell the DD, the DD will call the setValue which will fire the onChange, else we fire onChange by ourselves
        if((this.sDataBindingType === "D" || this.sDataBindingType === "R") && this.oServerDD !== null){
            //  If value is changed we give the new value to the DD and if bNoPut or bDisplayOnly is true we tell it not to update the changed-state
            this.oServerDD.setFieldValue(this.sTable, this.sField, sValue, (this.bNoPut || this.bDisplayOnly));
        }else{
            this.onChange.fire(this, { "sValue" : sValue, sPrevValue : this.sOrigValue });
            this.sOrigValue = sValue;
        }
    }
},


lock : function(bExclusive, oAction){
    if(this.iLocked === 0){
        this.displayLock(oAction);
    }
    
    this.iLocked++;
},


unlock : function(bExclusive, oAction){
    this.iLocked--;
    
    if(this.iLocked === 0){
        this.displayUnlock(oAction);
    }
},

// - - - - - - - - - - ACTION FORWARDING - - - - - - - - - - 


doFind : function(sFindMode){
    if(this.oServerDD !== null){
        this.oServerDD.doFind(sFindMode, this);
    }
},


doDelete : function(){
    if(this.oServerDD !== null){
        this.oServerDD.doDelete();
    }
},


doSave : function(){
    if(this.oServerDD !== null){
        this.oServerDD.doSave();
    }
},


doClear : function(){
    if(this.oServerDD !== null){
        this.oServerDD.doClear();
    }
},


doClearAll : function(){
    if(this.oServerDD !== null){
        this.oServerDD.doClearAll();
    }
},


debugDetails : function(oErr){

	var aHTML = [
		"<b>Value:</b> ", vdf.sys.string.encodeHtml(this.getValue()), "<br/>",
		this.DEO.prototype.debugDetails.call(this, oErr)
	];
	
	return aHTML.join("");
}



});






vdf.core.init = {


initializeControls : function(eStartElement){
    var fScan, aControls = [], iControl, oControlShortList, oTagShortList, oTypeShortList;
    
    //  A short list to map short vdfControlType names to longer library paths.
    oControlShortList = {
        "form" : "vdf.core.Form",
        "grid" : "vdf.deo.Grid",
        "lookup" : "vdf.deo.Lookup",
        "label" : "vdf.core.Label",
        "lookupdialog" : "vdf.core.LookupDialog",
        "tabmenu" : "vdf.gui.TabContainer",
        "tabcontainer" : "vdf.gui.TabContainer",
        "datepicker" : "vdf.deo.DatePicker",
        "popupcalendar" : "vdf.gui.PopupCalendar"    
    };

    //  Maps specific tagnames of elements to library paths for controls.
    oTagShortList = {
        "select" : "vdf.deo.Select",
        "textarea" : "vdf.deo.Textarea"
    };

    //  Maps types of input elements to library paths for controls.
    oTypeShortList = {
        "text" : "vdf.deo.Text",
        "radio" : "vdf.deo.Radio",
        "checkbox" : "vdf.deo.Checkbox",
        "hidden" : "vdf.deo.Hidden",
        "password" : "vdf.deo.Password"
    };
    
    //  Recursive DOM scan method that finds and creates controls
    fScan = function(eElement, oParent, oForm){
        var sControlType, oControl, iChild, fConstructor;
        
        //  Detect vdf controls
        sControlType = vdf.getDOMAttribute(eElement, "sControlType", null);
        
        //  Perform special control detection (mostly field detection)
        if(!sControlType){
            if(eElement.tagName === "INPUT"){    //  INPUT elements are mapped on type using the oTagShortList
                sControlType = oTypeShortList[eElement.type.toLowerCase()];
            }else{  //  Other tags are mapped using the oTagShortList
                sControlType = oTagShortList[eElement.tagName.toLowerCase()];
            }
            
            if(typeof(sControlType) === "undefined"){ 
                sControlType = null; 
            }
            
            //  Elements with the sDataBinding are an exception
            if(sControlType === null && vdf.getDOMAttribute(eElement, "sDataBinding", null) !== null){
                sControlType = "vdf.deo.DOM";
            }
        }
        
        //  Add found control to administration
        if(sControlType){
            //  Map name using short list
            if(oControlShortList[sControlType.toLowerCase()]){
                sControlType = oControlShortList[sControlType.toLowerCase()];
            }
            
            //  Check if library is loaded
            if(vdf.isAvailable(sControlType)){
                if(typeof eElement.oVdfControl === "undefined"){
                    //  Search constructor and initialize contorl
                    fConstructor = vdf.sys.ref.getNestedObjProperty(sControlType);
                    oControl = new fConstructor(eElement, (oParent !== null ? oParent : null));
                    
                    //  Register to parent (if interrested
                    if(oParent && typeof(oParent.addChild) === "function"){ //oParent !== null && typeof(oParent.oControl.addChild) === "function"){                                     
                        oParent.addChild(oControl);
                    }
                    //vdf.log("create control: " + oControl.sName + " (" + vdf.sys.ref.getType(oControl) + ")");
                    
                    // Store control references
                    vdf.core.init.registerControl(oControl, sControlType, (oForm ? oForm : null));
                }
            }else{
                throw new vdf.errors.Error(5135, "Unknown control type", this, [sControlType]);
            }
            
            //  Store references
            aControls.push(oControl);
            if(sControlType.toLowerCase() === "vdf.core.form" || sControlType.toLowerCase() === "vdf.core.formmeta" || sControlType.toLowerCase() === "vdf.core.formbase"){
                oForm = oControl;
            }
            oParent = oControl;
        }
        

        //  Scan child elements
        for(iChild = 0; iChild < eElement.childNodes.length; iChild++){
            if(eElement.childNodes[iChild].nodeType !== 3 && eElement.childNodes[iChild].nodeType !== 8){
                fScan(eElement.childNodes[iChild], oParent, oForm);
            }
        }
    
    };

    //  Call the recursive scan method
    if(eStartElement === document.body || typeof(vdf.core.findForm) !== "function"){
        fScan(eStartElement, null, null, true);
    }else{
        fScan(eStartElement, null, vdf.core.findForm(eStartElement), true);
    }
    
    //  Call the init methods
    for(iControl = 0; iControl < aControls.length; iControl++){
        if(typeof(aControls[iControl].init) === "function"){
            try{
                aControls[iControl].init();
            }catch (oError){
                vdf.errors.handle(oError);
            }
        }

    }
    
},



autoInit : function(oEvent){
    try{
        vdf.core.init.initializeControls(document.body);
        
        vdf.onLoad.fire(vdf.init, {});
    }catch (oErr){
        vdf.errors.handle(oErr);
    }
},



destroyControls : function(eStartElement){
    var oControl, fScan;
    
    fScan = function(eElement){
        var iChild;
        
        if(eElement.oVdfControl){
            oControl = eElement.oVdfControl;
            
            //vdf.log("destroy control: " + oControl.sName + " (" + vdf.sys.ref.getType(oControl) + ")");
            vdf.core.init.destroyControl(oControl);
        }
        
        
        //  Scan child elements
        for(iChild = 0; iChild < eElement.childNodes.length; iChild++){
            if(eElement.childNodes[iChild].nodeType !== 3 && eElement.childNodes[iChild].nodeType !== 8){
                fScan(eElement.childNodes[iChild]);
            }
        }
    };
    
    fScan(eStartElement);
},


autoDestroy : function(oEvent){
    vdf.core.init.destroyControls(document.body);
},


registerControl : function(oControl, sPrototype, oForm){
    if(typeof oControl.sName === "string" && oControl.sName !== ""){
        oControl.sControlType = sPrototype;
    
        if(oControl.hasOwnProperty("bIsForm")){
            //  
            if(vdf.oForms[oControl.sName]){
                if(vdf.oForms[oControl.sName] !== oControl){
                    throw new vdf.errors.Error(5132, "Control name must be unique within the form", this, [oControl.sName]);
                }
            }else{
                vdf.oForms[oControl.sName] = oControl;
            }
        }else{
            //  Register at the form
            if(oForm){
                oControl.oForm = oForm;
                if(oForm.oControls[oControl.sName]){
                    if(oForm.oControls[oControl.sName] !== oControl){
                        throw new vdf.errors.Error(5132, "Control name must be unique within the form", this, [oControl.sName, oForm.sName]);
                    }
                }else{
                    oForm.oControls[oControl.sName] = oControl;
                }
            }
        }

        //  Register globally
        if(vdf.oControls[oControl.sName]){
            //  We allow global name conflicts and only keep the old reference
        }else{
            vdf.oControls[oControl.sName] = oControl;
        }
        
        
        
        vdf.onControlCreated.fire(this, { "oControl" : oControl, sPrototype : sPrototype });
    }else{
        throw new vdf.errors.Error(5133, "Control should have a name", this, [oControl.sName]);
    }
},


destroyControl : function(oControl){
    if(oControl.sName !== null){
        delete vdf.oControls[oControl.sName];
    }
    if(oControl.oForm){
        delete oControl.oForm.oControls[oControl.sName];
    }
    if(oControl.hasOwnProperty("bIsForm")){
        delete vdf.oForms[oControl.sName];
    }

    if(typeof(oControl.destroy) === "function"){
        oControl.destroy();
    }
    if(oControl.eElement){
        if(oControl.eElement.oVdfControl === oControl){
            oControl.eElement.oVdfControl = null;
        }
        delete oControl.eElement;
    }
    
},



findParentControl : function(eElement, sControlType){
    //  Initialize control type
    if(!sControlType){
        sControlType = null;
    }
    
    //  Bubble up in the DOM searching for VDF controls
    while(eElement !== null && eElement !== document){
        if(typeof(eElement.oVdfControl) === "object" && (sControlType === null || eElement.oVdfControl.sControlType === sControlType)){
            return eElement.oVdfControl;
        }

        eElement = eElement.parentNode;
    }
    
    //  If nothing found return null
    return null;
}

};

//  Make sure that the autoInit function after the DOM is initialized (Which can be in the future but also can be right now)
vdf.sys.dom.ready(vdf.core.init.autoInit);


vdf.register("vdf.core.init");





vdf.core.Label = function Label(eElement, oParentControl){
    this.Control(eElement, oParentControl);
    
    
    this.sDataBindingType = null;
    
    this.sDataBinding = null;
    
    this.sTable = null;
    
    this.sField = null;
    
    this.bAutoLabel = this.getVdfAttribute("bAutoLabel", true, false);
    
    this.sType = this.getVdfAttribute("sType", "shortlabel", true);
    
    //  @privates
    this.bIsLabel = true;
    
    //  Nasty: Call method of Field in context of this object.
    vdf.core.Field.prototype.detectBinding.call(this);
};

vdf.definePrototype("vdf.core.Label", "vdf.core.Control", {



formInit : function(){
    if(this.bAutoLabel){
        this.determineLabel();
    }
},


determineLabel : function(){
    var sLabel;
    
    switch(this.sType.toLowerCase()){
        case "shortlabel":
            sLabel = this.oForm.oMetaData.getFieldProperty("sShortLabel", this.sTable, this.sField);
            break;
        case "statushelp":
            sLabel = this.oForm.oMetaData.getFieldProperty("sStatusHelp", this.sTable, this.sField);
            break;
        case "longlabel":
            sLabel = this.oForm.oMetaData.getFieldProperty("sLongLabel", this.sTable, this.sField);
            break;
    }
    if(sLabel === null || sLabel === ""){
        if (this.sDataBindingType === "D"){
            sLabel = vdf.sys.string.copyCase(this.sField, "Xx");
        }else if(this.sDataBindingType === "E"){
            sLabel = "Expression";
        }else{
            sLabel = "Unknown";
        }
    }
    this.setLabel(sLabel);
},


getMetaProperty : function(sProp){
    //  Nasty: Call method of Field in context of this object.
    return vdf.core.Field.prototype.getMetaProperty.call(this, sProp);
},


getLabel : function(){
    return vdf.sys.dom.getElementText(this.eElement);
},


setLabel : function(sLabel){
    vdf.sys.dom.setElementText(this.eElement, sLabel);
}

});






vdf.core.List = function List(eElement, oParentControl){
    var sKey;

    this.DEO(eElement, oParentControl);
    
    //  PUBLIC
    
   
    //  Properties

    
    this.sTable             = this.getVdfAttribute("sTable", this.getVdfAttribute("sMainTable", null, false), true);
    
    
    this.iIndex             = this.getVdfAttribute("iIndex", "", true);
    
    this.bReverseIndex      = this.getVdfAttribute("bReverseIndex", false, true);
    
    this.iLength            = parseInt(this.getVdfAttribute("iLength", this.getVdfAttribute("iRowLength", 10, false), true), 10);
    
    this.iMinBuffer         = parseInt(this.getVdfAttribute("iMinBuffer", (this.iLength * 1 + 1), true), 10);
    
    this.iMaxBuffer         = parseInt(this.getVdfAttribute("iMaxBuffer", (this.iLength * 3), true), 10);
    
    this.iBufferWait        = parseInt(this.getVdfAttribute("iBufferWait", 1500, true), 10);
    
    this.iRefreshTimeout    = parseInt(this.getVdfAttribute("iRefreshTimeout", 300, true), 10);
    
    this.sCssClass          = this.getVdfAttribute("sCssClass", "list", true);
    
    this.sCssRowHeader      = this.getVdfAttribute("sCssRowHeader", "rowheader", true);
    
    this.sCssRowEmpty       = this.getVdfAttribute("sCssRowEmpty", "rowempty", true);
    
    this.sCssRowDisplay     = this.getVdfAttribute("sCssRowDisplay", "rowdisplay", true);
    
    this.sCssRowOdd         = this.getVdfAttribute("sCssRowOdd", "rowodd");
    
    this.sCssRowEven        = this.getVdfAttribute("sCssRowEven", "roweven");
    
    this.sCssHeaderIndex    = this.getVdfAttribute("sCssHeaderIndex", "headerindex");
    
    this.sCssHeaderReversed = this.getVdfAttribute("sCssHeaderReversed", "headerreversed");
    
    this.sCssHeaderSelected = this.getVdfAttribute("sCssHeaderSelected", "headerselected");
    
    
    this.bAlwaysInOrder     = this.getVdfAttribute("bAlwaysInOrder", true, true);
    
    this.bForceDDSync       = this.getVdfAttribute("bForceDDSync", false, true);
    
    this.bFixedColumnWidth  = this.getVdfAttribute("bFixedColumnWidth", true, true);
    
    this.bDetermineWidth    = this.getVdfAttribute("bDetermineWidth", true, true);
    
    this.bHoldFocus         = this.getVdfAttribute("bHoldFocus", true, true);
    
    this.bFocus             = this.getVdfAttribute("bFocus", true, true);
    
    this.bDisplayNewRow     = this.getVdfAttribute("bDisplayNewRow", false, true);
    
    this.bDisplayScrollbar  = this.getVdfAttribute("bDisplayScrollbar", true, true);
    
    this.bDisplayLoading    = this.getVdfAttribute("bDisplayLoading", true, true);
    
    this.bSearch            = this.getVdfAttribute("bSearch", true, true);
    
    
    this.bAllowSorting      = this.getVdfAttribute("bAllowSorting", true, true);
    
    
    this.onSelect           = new vdf.events.JSHandler();
    
    this.onDeselect         = new vdf.events.JSHandler();
    
    this.onEnter            = new vdf.events.JSHandler();
    
    this.onInitialized      = new vdf.events.JSHandler();
    
    this.onNewRow           = new vdf.events.JSHandler();
    
    
    //  @privates
    this.aChildren = []; // Contains references to all children exept for the fields
    this.aHeaderFields = [];
    this.aPrototypeFields = [];
    this.eHeaderRow = null;
    this.ePrototypeRow = null;
    this.eFocus = null;
    this.eLoadingDiv = null;
    this.tSelectedRow = null;
    
    this.tNewRecord = this.initResponseSnapshot(new vdf.dataStructs.TAjaxSnapShot());
    
    this.aDisplay = [];
    this.aBufferBottom = [];
    this.aBufferTop = [];
    this.oActionKeys            = {};
    this.bDDSync = null;
    this.iInsertLocation = -1;
    this.oJumpIntoList = null;
    this.iInitStage = 0;
    this.iDisplayRightPadding = 0;
    
    this.oScrollAction = null;
    this.oFillAction = null;
    this.oBufferAction = null;
    this.oSelectAction = null;
    
    this.sLastBufferUp = null;
    this.iLastBufferUp = 0;

    this.sLastBufferDown = null;
    this.iLastBufferDown = 0;
    
    this.tRefreshTimeout = null;
    this.oRefreshAction = null;
    
    this.bHasFocus = false;
    this.bLozingFocus = false;
    this.tFocusTimeout = null;
    
    
    //  Copy settings
    for(sKey in vdf.settings.listKeys){
        if(typeof(vdf.settings.listKeys[sKey]) == "object"){
            this.oActionKeys[sKey] = vdf.settings.listKeys[sKey];
        }
    }
    
    //  Set classname
    vdf.sys.gui.addClass(this.eElement, this.sCssClass);

    if(this.eElement.getAttribute("cellpadding") === null || this.eElement.getAttribute("cellpadding") === ""){
        this.eElement.cellPadding = 0;
    }
    if(this.eElement.getAttribute("cellspacing") === null || this.eElement.getAttribute("cellspacing") === ""){
        this.eElement.cellSpacing = 0;
    }
    
    if(this.sTable !== null){
        this.sTable = this.sTable.toLowerCase();
    }
    
    //  Register to parent as data entry object
    if(oParentControl !== null && typeof(oParentControl.addDEO) == "function"){
        oParentControl.addDEO(this);
    }
};

vdf.definePrototype("vdf.core.List", "vdf.core.DEO", {

// - - - - - - - - - - INITIALIZATION - - - - - - - - - - -


init : function(){
    if(!this.oForm || this.oForm.sControlType !== "vdf.core.Form"){
        throw new vdf.errors.Error(5129, "Reference to vdf.core.Form required", this, [ this.sName ]);
    }
},


initStage : function(){
    switch(this.iInitStage){
        case 1:
            //vdf.log("List: Loading stage 1: Loading field meta data");
            this.loadFieldMetaData();
            break;
        case 2:
            //vdf.log("List: Loading stage 2: Internal initialization");
            this.initializeComponents();
            //this.oForm.childInitFinished();
            break;
        case 3:
            //vdf.log("List: Loading stage 3: Automatic fill");
            this.oForm.childInitFinished();
            this.onInitialized.fire(this, {});
            break;
    }
},


addDEO : function(oField, sDataBinding){
    var bParent = true, eElement = oField.eElement, eRow;
    
    eRow = vdf.sys.dom.searchParentByVdfAttribute(eElement, "sRowType", null);
    
    if(eRow !== null){
        bParent = this.checkField(eRow, vdf.getDOMAttribute(eRow, "sRowType"), oField);
    }
    
    if(bParent){
        if(this.oParentControl !== null && typeof(this.oParentControl.addDEO) === "function"){
            this.oParentControl.addDEO(oField, sDataBinding);
        }else{
            this.oForm.addDEO(oField, sDataBinding);
        }
        
        //  Add it to the children collection so it will get initialized
        this.aChildren.push(oField);
    }else{
        oField.oForm = this.oForm;
    }
},


checkField : function(eRow, sRowType, oField){
    if(sRowType == "header"){
        //  Safe reference to the header row
        if(this.eHeaderRow === null){
            this.eHeaderRow = eRow;
        }
        
        //  Set classname
        if(this.eHeaderRow.className.match(this.sCssRowHeader) === null){
            this.eHeaderRow.className = this.sCssRowHeader;
        }
        
        this.aHeaderFields.push(oField);
    }else if(sRowType == "display"){
        //  Safe reference to the display row
        if(this.ePrototypeRow === null){
            this.ePrototypeRow = eRow;
        }
        
        if(!oField.bIsLabel){
            this.aPrototypeFields.push(oField);
        }
    }else{
        throw new vdf.errors.Error(5140, "Unknown row type", this, [ sRowType ]);
    }
    
    return false;
},


formInit : function(){
    //  Tell the form to wait for us with finishing initialization
    this.oForm.iInitFinishedStage++;
    
    this.iInitStage++;
    this.initStage();
},


loadFieldMetaData : function(){
    var aFields = [], iHeader, iProto;
    
    for(iHeader = 0; iHeader < this.aHeaderFields.length; iHeader++){
        if(this.aHeaderFields[iHeader].sDataBindingType == "D"){
            aFields.push(this.aHeaderFields[iHeader].sDataBinding);
        }
    }
    
    for(iProto = 0; iProto < this.aPrototypeFields.length; iProto++){
        if(this.aPrototypeFields[iProto].sDataBindingType == "D"){
            aFields.push(this.aPrototypeFields[iProto].sDataBinding);
        }
    }

    this.oForm.oMetaData.loadFieldData(vdf.sys.math.unique(aFields), this.onFieldMetaLoaded, this);
},


onFieldMetaLoaded : function(oEvent){
    this.iInitStage++;
    this.initStage();
},


initializeComponents : function(){
    var iField, iChild, iRow, oScrollbar, oList, eFocus;

    //  If we don't have a reference to a header row yet we need to make sure to find one..
    if(!this.eHeaderRow){
        for(iRow = 0; iRow < this.eElement.rows.length; iRow++){
            if(vdf.getDOMAttribute(this.eElement.rows[iRow], "sRowType") === "header"){
                this.eHeaderRow = this.eElement.rows[iRow];
                
                //  Set classname
                if(this.eHeaderRow.className.match(this.sCssRowHeader) === null){
                    this.eHeaderRow.className = this.sCssRowHeader;
                }
                break;
            }
        }
    }
    
    
    //  Initialize other children
    for(iChild = 0; iChild < this.aChildren.length; iChild++){
        if(typeof(this.aChildren[iChild].formInit) === "function"){
            this.aChildren[iChild].formInit();
        }
    }

    
    // Initialization of the prototype fields (header fields are not initialized)
    for(iField = 0; iField < this.aPrototypeFields.length; iField++){
        if(typeof(this.aPrototypeFields[iField].formInit) == "function"){
            this.aPrototypeFields[iField].formInit();
        }
        
        if(typeof(this.aPrototypeFields[iField].initValidation) === "function"){
            this.aPrototypeFields[iField].initValidation();
        }
    }
    

    
    //  Determine the current location of the prototype row
    for(iRow = 0; iRow < this.eElement.rows.length; iRow++){
        if(this.eElement.rows[iRow] === this.ePrototypeRow){
            this.iInsertLocation = iRow;
            break;
        }
    }

        
   
    
    //  Initialize scrollbar  
    if(this.bDisplayScrollbar){
        oScrollbar = new vdf.gui.Scrollbar(null, null);
        oScrollbar.eScrollElement = this.eElement;
        oScrollbar.bOverLay = true;
        oScrollbar.init();
        oScrollbar.onScroll.addListener(this.onScroll, this);
        this.oScrollbar = oScrollbar;
        
                
        // oList = this;
        // setTimeout(function(){
            // oList.positionScrollbar();
        // }, 10);
    }
    
    //  Insert & initialize focus holder (A Element) (if needed)
    if(this.bHoldFocus){
        eFocus = document.createElement("a");
        this.eFocus = eFocus;
        eFocus.href = "javascript: vdf.sys.nothing();";
        eFocus.style.textDecoration = "none";
        eFocus.hideFocus = true;
        eFocus.innerHTML = "&nbsp;";
        eFocus.style.position = "absolute";
        eFocus.style.left = "-3000px";
        
        vdf.events.addDomKeyListener(eFocus, this.onKey, this);
        vdf.events.addDomListener("focus", eFocus, this.onFocus, this);
        vdf.events.addDomListener("blur", eFocus, this.onBlur, this);
        this.eElement.parentNode.insertBefore(eFocus, this.eElement);
        
        vdf.events.addDomListener("click", this.eElement, this.onTableClick, this);
        
        if(this.bFocus){
            this.focus();
        }
    }
    
    //  Remove gently from the DOM    
    this.ePrototypeRow.parentNode.removeChild(this.ePrototypeRow); 
    
    //  Take space
    this.displayClear(this.bDetermineWidth);

    //  Set header labels and CSS & index clicks
    this.initializeHeader();
    
    
    //  Lock column width
    if(this.bFixedColumnWidth){
        this.lockColumnWidth();
    }
    if(this.bDetermineWidth){
        this.displayClear(false);
    }
    
    //  Attach events
    vdf.events.addDomMouseWheelListener(this.eElement, this.onMouseWheelScroll, this);
    
    //  Determine sync method
    this.bDDSync = this.determineSync();
    
    this.iInitStage++;
    this.initStage();
    
    this.recalcDisplay(false);
    
    //  Unfortunately we still need to do the uggly positioning work arround
    oList = this;
    setTimeout(function(){
        if(oList.bDisplayScrollbar){
            oList.spaceScrollbar();
        }
    
        oList.recalcDisplay(false);
    }, 300);
},


destroy : function(){
    if(this.eElement){
        //  Remove the rows and all their listeners..
        vdf.events.clearDomListeners(this.eElement, true);
    }
    
    if(this.eFocus){
        vdf.events.clearDomListeners(this.eFocus);
    }
    
    this.eHeaderRow = null;
    this.ePrototypeRow = null;
    this.eFocus = null;
    this.eLoadingDiv = null;
},


initializeHeader : function(){
    var iHeader, oField, iIndex, eDiv;
    

    //  Attach listeners
    for(iHeader = 0; iHeader < this.aHeaderFields.length; iHeader++){
        oField = this.aHeaderFields[iHeader];

        //  Work arround for IE background styles and advanced header designs.
        if(vdf.sys.ref.getType(oField) === "DOM" || oField.bIsLabel){
            eDiv = document.createElement("div");
            eDiv.innerHTML = oField.eElement.innerHTML;
            oField.eElement.innerHTML = "";
            oField.eElement.removeAttribute("oVdfControl");
            oField.eElement.appendChild(eDiv);
            oField.eElement = eDiv;
            eDiv.oVdfControl = oField;
        }
        
        if(this.bAllowSorting){
            if(oField.sTable === this.sTable){
                iIndex = oField.getMetaProperty("iIndex");
                
                if(iIndex !== "" && iIndex !== null && iIndex !== 0){
                    oField.addDomListener("click", this.onIndexClick, this);
                }
            }
        }
    }
    
    //  Update header CSS
    this.displayHeaderCSS();
},

// - - - - - - - - - - DISPLAY FUNCTIONALLITY - - - - - - - - - - -


displayHeaderCSS : function(){
    var iHeader, oField, iIndex, iSelectedIndex = this.getIndex();

    for(iHeader = 0; iHeader < this.aHeaderFields.length; iHeader++){
        oField = this.aHeaderFields[iHeader];
        if(this.bAllowSorting){
            if(oField.sTable === this.sTable){
                iIndex = oField.getMetaProperty("iIndex");
                
                 if(iIndex !== "" && iIndex !== null && iIndex !== 0){
                    if(iIndex === iSelectedIndex){
                        if(this.bReverseIndex){
                            oField.eElement.parentNode.className = this.sCssHeaderReversed;
                        }else{
                            oField.eElement.parentNode.className = this.sCssHeaderSelected;
                        }   
                    }else{
                        oField.eElement.parentNode.className = this.sCssHeaderIndex;
                    }
                }
            }
        }
    }
},


displayClear : function(bOutfillColumns){
    var iLoop, eTable = this.eElement;
    
    //  Deselect selected row
    if(this.tSelectedRow !== null){
        this.deSelect();
    }
    
    this.aDisplay = [];
    this.aBufferBottom = [];
    this.aBufferTop = [];

    //  Delete all rows
    for(iLoop = eTable.rows.length - 1; iLoop >= 0; iLoop--){
        if(vdf.getDOMAttribute(eTable.rows[iLoop], "sRowType") === "display" || vdf.getDOMAttribute(eTable.rows[iLoop], "sRowType") === "spaceFiller"){
            if(eTable.rows[iLoop].tRow){
                this.destroyRow(eTable.rows[iLoop].tRow);
            }else{
                eTable.deleteRow(iLoop);
            }
        }
    }
    
    //  Fill table with empty rows
    for(iLoop = 0; iLoop < this.iLength; iLoop++){
        if(iLoop === 0 && this.bDisplayNewRow){
            this.insertOnBottom(this.createRow(this.tNewRecord));
            this.aDisplay.push(this.tNewRecord);
        }else{
            this.insertOnBottom(this.createEmptyRow(bOutfillColumns));
        }
    }
    
    //  Select the first record
    if(this.aDisplay.length > 0){
        this.select(this.aDisplay[0]);
    }
},


displayRefresh : function(){
    var iDisplayRow = 0, iRow, sType, eRow;
    
    //  Loop through the rows in the table
    for(iRow = 0; iRow < this.eElement.rows.length; iRow++){
        
        //  Determine the type
        sType = vdf.getDOMAttribute(this.eElement.rows[iRow], "sRowType", null);
        if(sType !== null){
            if(sType === "display" || sType === "spaceFiller"){
                
                //  (re)generate the display row
                if(iDisplayRow < this.aDisplay.length){
                    eRow = this.createRow(this.aDisplay[iDisplayRow]);
                }else{
                    eRow = this.createEmptyRow(false);
                }                
                
                //  Set the CSS class (odd or even)
                eRow.className = eRow.className + " " + (iDisplayRow % 2 === 0 ? this.sCssRowEven : this.sCssRowOdd);
                
                vdf.events.clearDomListeners(this.eElement.rows[iRow]);
                this.eElement.rows[iRow].tRow = null;
                
                vdf.sys.dom.swapNodes(this.eElement.rows[iRow], eRow);
                
                iDisplayRow++;
            }
        }
    }
},


createRow : function(tRow){
    var iField, eRow, sVal, iChild;

    //  Set the data
    if(tRow !== this.tNewRecord){
        for(iField = 0; iField < this.aPrototypeFields.length; iField++){
            this.aPrototypeFields[iField].setValue(tRow.__oData[this.aPrototypeFields[iField].sDataBinding]);
        }
    }else{
        for(iField = 0; iField < this.aPrototypeFields.length; iField++){
            sVal = this.aPrototypeFields[iField].getMetaProperty("sDefaultValue");
            this.aPrototypeFields[iField].setValue((sVal !== null ? sVal : ""));
        }
    }
    
    //  Copy the row
    eRow = vdf.sys.dom.deepClone(this.ePrototypeRow);
    
    //  Set the references, attributes and event listeners
    eRow.tRow = tRow;
    tRow.__eRow = eRow;
    tRow.__eDisplayRow = eRow;
    vdf.setDOMAttribute(eRow, "sRowType", "display");
    vdf.events.addDomListener("click", eRow, this.onRowClick, this);
    vdf.events.addDomListener("dblclick", eRow, this.onEnterAction, this);
    
    //  Set the CSS class
    if(this.sCssRowDisplay !== ""){
        eRow.className = this.sCssRowDisplay;
    }
    
    if(this.bDisplayScrollbar && this.iDisplayRightPadding > 0){
        for(iChild = eRow.childNodes.length - 1; iChild >= 0; iChild--){
            if(eRow.childNodes[iChild].tagName === "TD" || eRow.childNodes[iChild].tagName === "TH"){
                eRow.childNodes[iChild].style.paddingRight = this.iDisplayRightPadding + "px";
                break;
            }
        }
    }
    
    //  Give the developer a chance to modify the row
    this.onNewRow.fire(this, { eRow : eRow, tRow : tRow, bNewRow : (tRow === this.tNewRecord), bEmptyRow : false});
    
    return eRow;
},


destroyRow : function(tRow){
    vdf.events.clearDomListeners(tRow.__eRow);

    tRow.__eRow.parentNode.removeChild(tRow.__eRow);
    tRow.__eDisplayRow.tRow = null;
    tRow.__eRow = null;
    tRow.__eDisplayRow = null;
},


createEmptyRow : function(bOutfillColumn){
    var iField, eRow;
    
    //  Fill the row
    for(iField = 0; iField < this.aPrototypeFields.length; iField++){
        this.aPrototypeFields[iField].setValue((bOutfillColumn ? this.getStretchValue(this.aPrototypeFields[iField]) : ""), true);
    }
    
    //  Make a copy
    eRow = this.ePrototypeRow.cloneNode(true);
    
    //  Set properties and attach listeners
    vdf.setDOMAttribute(eRow, "sRowType", "spaceFiller");
    if(this.sCssRowEmpty !== ""){
        eRow.className = this.sCssRowEmpty;
    }
    //vdf.events.addDomListener("click", eNewRow, this.onEmptyRowClick, this);
    
    //  Give the developer a change to modify the row
    this.onNewRow.fire(this, { eRow : eRow, tRow : null, bNewRow : false, bEmptyRow : true});
    
    return eRow;
},


insertOnTop : function(eRow){
    var bOdd = true;

    if(this.aDisplay.length > 0){
        this.aDisplay[0].__eRow.parentNode.insertBefore(eRow, this.aDisplay[0].__eRow);
        bOdd = (this.aDisplay[0].__eDisplayRow.className.match(this.sCssRowOdd) !== null);
    }else{
        if(this.iInsertLocation >= this.eElement.rows.length){
            this.iInsertLocation = this.eElement.rows.length;
        }
        vdf.sys.dom.swapNodes(this.eElement.insertRow(this.iInsertLocation), eRow);
    }
    
    //  Set classname  (odd or even)
    eRow.className = eRow.className + " " + (bOdd ? this.sCssRowEven : this.sCssRowOdd);
},


insertOnBottom : function(eRow){
    var bOdd = true;

    if(this.aDisplay.length > 0){
        vdf.sys.dom.insertAfter(eRow, this.aDisplay[this.aDisplay.length - 1].__eRow);
        bOdd = (this.aDisplay[this.aDisplay.length - 1].__eDisplayRow.className.match(this.sCssRowOdd) !== null);
    }else{
        if(this.iInsertLocation >= this.eElement.rows.length){
            this.iInsertLocation = this.eElement.rows.length;
        }
        vdf.sys.dom.swapNodes(this.eElement.insertRow(this.iInsertLocation), eRow);
    }
    
    eRow.className = eRow.className + " " + (bOdd ? this.sCssRowEven : this.sCssRowOdd);
},


deleteEmptyRow : function(){
    var iLoop;
    
    for(iLoop = this.eElement.rows.length - 1; iLoop >= 0; iLoop--){
        if(vdf.getDOMAttribute(this.eElement.rows[iLoop], "sRowType") === "spaceFiller"){
            this.eElement.deleteRow(iLoop);
            return;
        }
    }
},


lockColumnWidth : function(){
    var iCol, eRow;    
    
    eRow = (this.eHeaderRow ? this.eHeaderRow : this.eElement.arows[0]);
    
    for(iCol = 0; iCol < eRow.cells.length; iCol++){
        eRow.cells[iCol].style.width = eRow.cells[iCol].clientWidth + "px";
    }
},


spaceScrollbar : function(){
    var oList, iRow, eRow, eCell, oCurrentStyle, iWidth, iScrollbarWidth, sRowType;

    iScrollbarWidth = this.oScrollbar.determineWidth();
    
    if(iScrollbarWidth > 0){
        for(iRow = 0; iRow < this.eElement.rows.length; iRow++){
            eRow = this.eElement.rows[iRow];
            
            if(eRow.cells.length > 0){
                eCell = eRow.cells[eRow.cells.length - 1];
                oCurrentStyle = vdf.sys.gui.getCurrentStyle(eCell);
                iWidth = parseInt(oCurrentStyle.paddingRight, 10) + iScrollbarWidth;
                sRowType = vdf.getDOMAttribute(eRow, "sRowType");
                eCell.style.paddingRight = iWidth + "px";
                
                
                if(typeof(sRowType) === "string" && (sRowType.toLowerCase() === "display" || sRowType.toLowerCase() === "spacefiller")){
                    this.iDisplayRightPadding = iWidth;
                }
            }
        }
    }else{
        oList = this;
        
        setTimeout(function(){ 
            oList.spaceScrollbar.call(oList); 
        }, 300);
    }
},


recalcDisplay : function(bDown){
    var iChild, oCurrentStyle;

    if(this.bDisplayScrollbar && this.oScrollbar){
        oCurrentStyle = vdf.sys.gui.getCurrentStyle(this.eElement);
        
        if(this.eHeaderRow){
            this.oScrollbar.iMarginTop = this.eHeaderRow.offsetHeight + parseInt(this.eHeaderRow.offsetTop, 10);
        }

        //  Calculate right margin (using border size en padding)
        this.oScrollbar.iMarginRight = 0;
        if(!isNaN(parseInt(oCurrentStyle.borderRightWidth, 10))){
            this.oScrollbar.iMarginRight += parseInt(oCurrentStyle.borderRightWidth, 10);
        }
        if(!isNaN(parseInt(oCurrentStyle.paddingRight, 10))){
            this.oScrollbar.iMarginRight += parseInt(oCurrentStyle.paddingRight, 10);
        }
        
        //  Calculate bottom margin (using border size en padding)
        this.oScrollbar.iMarginBottom = 0;
        if(!isNaN(parseInt(oCurrentStyle.borderBottomWidth, 10))){
            this.oScrollbar.iMarginBottom += parseInt(oCurrentStyle.borderBottomWidth, 10);
        }
        if(!isNaN(parseInt(oCurrentStyle.paddingBottom, 10))){
            this.oScrollbar.iMarginBottom += parseInt(oCurrentStyle.paddingBottom, 10);
        }
        
        this.oScrollbar.recalcDisplay(false);
    }
    
    if(bDown){
        for(iChild = 0; iChild < this.aChildren.length; iChild++){
            if(typeof this.aChildren[iChild].recalcDisplay === "function"){
                this.aChildren[iChild].recalcDisplay(bDown);
            }
        }
    }else{
        if(this.oParentControl !== null && typeof(this.oParentControl.recalcDisplay) === "function"){
            this.oParentControl.recalcDisplay(bDown);
        }
    }
},


updateScrollbar : function(){
    if(this.bDisplayScrollbar && this.oScrollbar){
        if(this.aDisplay.length > 1){
            this.oScrollbar.enable();
            
            if(this.aBufferTop.length === 0 && this.aDisplay[0] === this.tSelectedRow){
                this.oScrollbar.scrollTop();
            }else if(this.aBufferBottom.length === 0 && this.aDisplay[this.aDisplay.length - 1] === this.tSelectedRow && (!this.bDisplayNewRow || this.aDisplay[this.aDisplay.length - 1] === this.tNewRecord)){
                this.oScrollbar.scrollBottom();
            }else{
                this.oScrollbar.center();
            }
        }else{
            this.oScrollbar.disable();
        }
    }
},


displayRowCSS : function(){
    var iDataRow = 0, iRow, bOdd = true, eElem, sType;

    for(iRow = 0; iRow < this.eElement.rows.length; iRow++){
        sType = vdf.getDOMAttribute(this.eElement.rows[iRow], "sRowType", null);
        
        if(sType === "display" || sType === "spaceFiller" || sType === "edit"){
            eElem = (sType === "edit" ? this.tSelectedRow.__eDisplayRow : this.eElement.rows[iRow]);
            
            if(iDataRow === 0){
                bOdd = (eElem.className.match(this.sCssRowOdd) !== null);
            }else{
                bOdd = !bOdd;
            }
            
            eElem.className = eElem.className.replace(this.sCssRowOdd, "").replace(this.sCssRowEven, "") + " " + (bOdd ? this.sCssRowOdd : this.sCssRowEven);
            
            iDataRow++;
        }
        
    }

},

// - - - - - - - - - - LIST LOGIC - - - - - - - - - - -




select : function(tRow, sField, fFinished, oEnvir){
    this.tSelectedRow = tRow;
    
    if(this.oSelectAction !== null){
        this.oSelectAction.cancel();
    }
    
    this.oSelectAction = new vdf.core.Action(null, this.oForm, this, this.oServerDD, false);
    this.oSelectAction.onFinished.addListener(this.onSelectFinished, this);
    if(typeof fFinished === "function"){
        this.oSelectAction.onFinished.addListener(fFinished, oEnvir);
    }
    this.oServerDD.loadSnapshot(this.oSelectAction, tRow, false);
    
    if(this.iInitStage >= 3){   //  We don't need to talk to the DD's during initialization
        if(this.bDDSync || tRow === this.tNewRecord){
            if(tRow !== this.tNewRecord && tRow.__sRowId !== null){
                this.oServerDD.doFindByRowId(tRow.__sRowId, this.oSelectAction);
            }else{
                this.oServerDD.doClear(this.oSelectAction);
            }
        }else{
            this.oServerDD.loadSnapshot(this.oSelectAction, tRow, true);
            
            if(typeof fFinished === "function"){
                fFinished.call(oEnvir);
            }
        }
    }
    
    this.updateScrollbar();
    
    this.returnFocus();
    
    this.onSelect.fire(this, { tRow : tRow });
},


onSelectFinished : function(oEvent){
    this.oSelectAction = null;
},


deSelect : function(){
    var tRow = this.tSelectedRow;
    this.tSelectedRow = null;
    
    this.onDeselect.fire(this, { tRow : tRow });
    
    return true;
},


scrollVisualUp : function(){
    var bResult = false, tNewRow, tOldRow;

    if(this.aBufferTop.length > 0){
        //  Insert new row on top
        tNewRow = this.aBufferTop.shift();
        this.insertOnTop(this.createRow(tNewRow));
        this.aDisplay.unshift(tNewRow);
        
        //  Remove the old on the bottom
        tOldRow = this.aDisplay.pop();
        this.destroyRow(tOldRow);
        
        //  If this is the newrow we don't want it in the buffer
        if(tOldRow !== this.tNewRecord){
            this.aBufferBottom.unshift(tOldRow);
        }
        
        bResult = true;
    }
    
    return bResult;
},


scrollVisualDown : function(){
    var bResult = false, tNewRow, tOldRow;

    if(this.aBufferBottom.length > 0){
        //  Insert new row on the bottom
        tNewRow = this.aBufferBottom.shift();
        this.insertOnBottom(this.createRow(tNewRow));
        this.aDisplay.push(tNewRow);
        
        //  Remove the old row on the top
        tOldRow = this.aDisplay.shift();
        this.destroyRow(tOldRow);
        this.aBufferTop.unshift(tOldRow);
        
        bResult = true;
    }else if(this.bDisplayNewRow && this.aDisplay[this.aDisplay.length - 1] !== this.tNewRecord){
        //  Insert newrow if needed
        this.insertOnBottom(this.createRow(this.tNewRecord));
        this.aDisplay.push(this.tNewRecord);
        
        //  Remove the old row on the top
        tOldRow = this.aDisplay.shift();
        this.destroyRow(tOldRow);
        this.aBufferTop.unshift(tOldRow);
        
        bResult = true;
    }
    
    return bResult;
},


scrollUp : function(){
    var iSelected = this.getSelectedRowNr(), oList = this;
    
    if(iSelected === 0){
        if(this.scrollVisualUp()){
            if(this.deSelect()){
                this.select(this.aDisplay[iSelected]);
            }
        }
        
        setTimeout(function(){
            oList.buffer(-1);
        }, 10);
    }else{
        iSelected--;
        
        if(iSelected < this.aDisplay.length && iSelected >= 0){
            if(this.deSelect()){
                this.select(this.aDisplay[iSelected]);
            }
        }
    }    

},


scrollDown : function(){
    var iSelected = this.getSelectedRowNr(), oList = this;   
    if(iSelected === (this.aDisplay.length - 1)){
        if(this.scrollVisualDown()){
            if(this.deSelect()){
                this.select(this.aDisplay[iSelected]);
            }
        }
        
        setTimeout(function(){
            oList.buffer(1);
        }, 10);
    }else{
        iSelected++;
        
        if(iSelected < this.aDisplay.length && iSelected >= 0){
            if(this.deSelect()){
                this.select(this.aDisplay[iSelected]);
            }
        }
    }
},


scrollBottom : function(){
    var oAction, tRequestSet, tEmptyRow;

    if(this.oScrollAction !== null){
        this.oScrollAction.cancel();
    }
    
    //  Deselect selected row
    if(this.deSelect()){
    
        oAction = new vdf.core.Action("find", this.oForm, this, this.oServerDD, false);
        if(oAction.lock(this)){
            
            if(this.oSelectAction !== null){
                this.oSelectAction.cancel();
            }
        
            tEmptyRow = this.createEmptySnapshot();
                
            tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
            tRequestSet.sName = "List_ScrollBottom_Find";
            tRequestSet.sRequestType = "find";
            tRequestSet.iMaxRows = this.iLength;
            tRequestSet.sIndex = this.getIndex();
            tRequestSet.sTable = this.sTable;
            tRequestSet.sFindMode = (this.bReverseIndex ? vdf.FIRST : vdf.LAST); // LAST & FIRST are after the first row automatically changed into LT & GT
            tRequestSet.aRows.push(tEmptyRow);
            oAction.addRequestSet(tRequestSet);
            oAction.onResponse.addListener(this.handleScrollBottom, this);
            oAction.send();
        }
    }
},


handleScrollBottom : function(oEvent){
    var iRow, tSet;
    
    this.oScrollAction = null;
    if(!oEvent.bError){
        
        //  Reset buffers
        this.aDisplay = [];
        this.aBufferTop = [];
        this.aBufferBottom = [];
        
        //  Find response set
        tSet = oEvent.tResponseData.aDataSets[0];

        //  Refill buffer
        for(iRow = tSet.aRows.length - 1; iRow >= 0; iRow--){
            this.aDisplay.push(this.initResponseSnapshot(tSet.aRows[iRow]));
        }
        
        //  Insert the empty row
        if(this.bDisplayNewRow){
            //this.tNewRecord = this.initResponseSnapshot(this.createEmptySnapshot());
            this.aDisplay.push(this.tNewRecord);
            if(this.aDisplay.length > this.iLength){
                this.aBufferTop.push(this.aDisplay.shift());
            }
        }
        
        
        //  Refresh display
        this.displayRefresh();
        
        if(this.aDisplay.length > 0){
            this.select(this.aDisplay[this.aDisplay.length - 1]);
        }
        
        //  Reset the buffer to much prevention
        this.sLastBufferUp = null;
        this.sLastBufferDown = null;
        
        //  Buffer if needed
        if(this.aDisplay.length == this.iLength){
            this.buffer(-1);
        }
    }
},


scrollTop : function(){
    var oAction, tRequestSet, tEmptyRow;

    if(this.oScrollAction !== null){
        this.oScrollAction.cancel();
    }
    
    if(this.deSelect()){
        oAction = new vdf.core.Action("find", this.oForm, this, this.oServerDD, false);
        if(oAction.lock(this)){
            this.oScrollAction = oAction;
            tEmptyRow = this.createEmptySnapshot();
            
            tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
            tRequestSet.sName = "List_ScrollTop_Find";
            tRequestSet.sRequestType = "find";
            tRequestSet.iMaxRows = this.iLength;
            tRequestSet.sIndex = this.getIndex();
            tRequestSet.sTable = this.sTable;
            tRequestSet.sFindMode = (this.bReverseIndex ? vdf.LAST : vdf.FIRST); // LAST & FIRST are after the first row automatically changed into LT & GT
            tRequestSet.aRows.push(tEmptyRow);
            oAction.addRequestSet(tRequestSet);
            
            oAction.onResponse.addListener(this.handleScrollTop, this);
            oAction.send();
        }
    }
},


handleScrollTop : function(oEvent){
    var iRow, tSet;
    
    this.oScrollAction = null;
    
    if(!oEvent.bError){
        //  Reset buffers
        this.aDisplay = [];
        this.aBufferTop = [];
        this.aBufferBottom = [];
        
        //  Find response set
        tSet = oEvent.tResponseData.aDataSets[0];

        //  Refill buffer
        for(iRow = 0; iRow < tSet.aRows.length; iRow++){
            this.aDisplay.push(this.initResponseSnapshot(tSet.aRows[iRow]));
        }
        
        //  Insert the empty row if needed (and create a new because rowids might have changed)
        if(this.bDisplayNewRow){
            //this.tNewRecord = this.initResponseSnapshot(this.createEmptySnapshot());
            
            if(this.aDisplay.length < this.iLength){
                this.aDisplay.push(this.tNewRecord);
            }
        }
        
        //  Refresh display
        this.displayRefresh();
        
        if(this.aDisplay.length > 0){
            this.select(this.aDisplay[0]);
        }
        
        //  Reset the buffer to much prevention
        this.sLastBufferUp = null;
        this.sLastBufferDown = null;
        
        //  Buffer if needed
        if(this.aDisplay.length == this.iLength){
            this.buffer(1);
        }
    }
},


scrollPageDown : function(){
    var iScroll = this.iLength, iSelected = this.getSelectedRowNr(), oList = this;
    
    if(this.deSelect()){
        while(iScroll > 0 && this.scrollVisualDown()){
            iScroll--;
        }
        
        while(iSelected < (this.aDisplay.length - 1) && iScroll > 0){
            iScroll--;
            iSelected++;
        }
        
        if(iSelected !== null){
            this.select(this.aDisplay[iSelected]);
        }
        
        setTimeout(function(){
            oList.buffer(1);
        }, 10);
    }
},


scrollPageUp : function(){
    var iScroll = this.iLength, iSelected = this.getSelectedRowNr(), oList = this;
    
    if(this.deSelect()){
        while(iScroll > 0 && this.scrollVisualUp()){
            iScroll--;
        }
        
        while(iSelected > 0 && iScroll > 0){
            iScroll--;
            iSelected--;
        }
        
        if(iSelected !== null){
            this.select(this.aDisplay[iSelected]);
        }
        
        setTimeout(function(){
            oList.buffer(-1);
        }, 10);

    }
    
},


scrollToRow : function(eRow, sField, fFinished, oEnvir){
    if(eRow.tRow){
        if(eRow.tRow === this.tSelectedRow){
            if(typeof fFinished === "function"){
                fFinished.call(oEnvir);
            }
        }else if(this.deSelect()){
            this.select(eRow.tRow, sField, fFinished, oEnvir);
            
            return true;
        }        
    }
    
    return false;
},


scrollToRowId : function(sRowId){
    var iDisplayRow = null, iRow;
    
    if(this.deSelect() || this.tSelectedRow !== null){
        //  Search in top buffer..
        for(iRow = 0; iRow < this.aBufferTop.length; iRow++){
            if(this.aBufferTop[iRow].__sRowId === sRowId){
                //  Scroll up
                while(iRow >= 0){
                    this.scrollVisualUp();
                    iRow--;
                }
                
                iDisplayRow = 0;
                break;
            }
        }
        
        //  Search in displayed rows
        if(iDisplayRow === null){
            for(iRow = 0; iRow < this.aDisplay.length; iRow++){
                if(this.aDisplay[iRow].__sRowId === sRowId){
                    //  Scroll up
                    iDisplayRow = iRow;
                    break;
                }
            }
        }
        
        //  Search in bottom buffer
        if(iDisplayRow === null){
            for(iRow = 0; iRow < this.aBufferBottom.length; iRow++){
                if(this.aBufferBottom[iRow].__sRowId === sRowId){
                    //  Scroll down
                    while(iRow >= 0){
                        this.scrollVisualDown();
                        iRow--;
                    }
                    
                    iDisplayRow = this.aDisplay.length - 1;
                    break;
                }
            }
        }
        
        if(iDisplayRow !== null){
            this.select(this.aDisplay[iDisplayRow]);
        }else{
            this.fillByRowId(sRowId);
        }
    }
},


fill : function(oAction){
    var tRequestSet, tEmptyRow, bContinue = true;
    
    this.cancelRequests();

    if(oAction === null || typeof(oAction) === "undefined"){
        oAction = new vdf.core.Action("find", this.oForm, this, this.oServerDD, false);
        bContinue = oAction.lock(this);
    }
    
    if(bContinue){
        this.oFillAction = oAction;
    
        tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
        tEmptyRow = this.createEmptySnapshot();
        tRequestSet.sName = "List_Fill_Find";
        tRequestSet.sRequestType = "find";
        tRequestSet.iMaxRows = this.iLength;
        tRequestSet.sIndex = this.getIndex();
        tRequestSet.sTable = this.sTable;
        tRequestSet.sFindMode = (this.ddHasRecord() ? (this.bReverseIndex ? vdf.LT : vdf.GT) : (this.bReverseIndex ? vdf.LAST : vdf.FIRST) );
        tRequestSet.aRows.push(tEmptyRow);
        oAction.addRequestSet(tRequestSet);
        
        oAction.onResponse.addListener(this.handleFill, this);
        oAction.send();
    }
},


handleFill : function(oEvent){
    var iRow, tSet;

    this.oFillAction = null;
    
    if(!oEvent.bError){
        //  Deselect selected row
        if(this.tSelectedRow !== null){
            this.deSelect();
        }
        
        //  Reset buffers
        this.aDisplay = [];
        this.aBufferTop = [];
        this.aBufferBottom = [];
        
        //  Find response set
        tSet = oEvent.tResponseData.aDataSets[0];
        
        //  Refill buffer
        for(iRow = 0; iRow < tSet.aRows.length; iRow++){
            this.aDisplay.push(this.initResponseSnapshot(tSet.aRows[iRow]));
        }
        
        //  Insert the empty row if needed (and create a new because rowids might have changed)
        if(this.bDisplayNewRow){
            //this.tNewRecord = this.initResponseSnapshot(this.createEmptySnapshot());
            
            if(this.aDisplay.length < this.iLength){
                this.aDisplay.push(this.tNewRecord);
            }
        }
        
        //  Refresh display
        this.displayRefresh();
        
        if(this.aDisplay.length > 0){
            this.select(this.aDisplay[0]);
        }
        
        //  Reset the buffer to much prevention
        this.sLastBufferUp = null;
        this.sLastBufferDown = null;
        
        //  Buffer if needed
        if(this.aDisplay.length == this.iLength){
            this.buffer(1);
        }
    }
},



fillBottomUp : function(oAction){
    var tRequestSet, tEmptyRow, bContinue = true;
    
    this.cancelRequests();

    if(oAction === null || typeof(oAction) === "undefined"){
        oAction = new vdf.core.Action("find", this.oForm, this, this.oServerDD, false);
        bContinue = oAction.lock(this);
    }
    
    if(bContinue){
        this.oFillAction = oAction;
    
        tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
        tEmptyRow = this.createEmptySnapshot();
        tRequestSet.sName = "List_Fill_FindBottomUp";
        tRequestSet.sRequestType = "find";
        tRequestSet.iMaxRows = this.iLength;
        tRequestSet.sIndex = this.getIndex();
        tRequestSet.sTable = this.sTable;
        tRequestSet.sFindMode = (this.bReverseIndex ? vdf.FIRST : vdf.LAST); // LAST & FIRST are after the first row automatically changed into LT & GT
        tRequestSet.aRows.push(tEmptyRow);
        oAction.addRequestSet(tRequestSet);
        
        oAction.onResponse.addListener(this.handleFillBottomUp, this);
        oAction.send();
    }
},


handleFillBottomUp : function(oEvent){
    var iRow, tSet;

    this.oFillAction = null;
    
    if(!oEvent.bError){
        //  Deselect selected row
        if(this.tSelectedRow !== null){
            this.deSelect();
        }
        
        //  Reset buffers
        this.aDisplay = [];
        this.aBufferTop = [];
        this.aBufferBottom = [];
        
        //  Find response set
        tSet = oEvent.tResponseData.aDataSets[0];

        //  Refill buffer
        for(iRow = tSet.aRows.length - 1; iRow >= 0; iRow--){
            this.aDisplay.push(this.initResponseSnapshot(tSet.aRows[iRow]));
        }
        
        //  Insert the empty row
        if(this.bDisplayNewRow){
            //this.tNewRecord = this.initResponseSnapshot(this.createEmptySnapshot());
            this.aDisplay.push(this.tNewRecord);
            if(this.aDisplay.length > this.iLength){
                this.aBufferTop.push(this.aDisplay.shift());
            }
        }
        
        
        //  Refresh display
        this.displayRefresh();
        
        if(this.aDisplay.length > 0){
            this.select(this.aDisplay[this.aDisplay.length - 1]);
        }
        
        //  Reset the buffer to much prevention
        this.sLastBufferUp = null;
        this.sLastBufferDown = null;
        
        //  Buffer if needed
        if(this.aDisplay.length == this.iLength){
            this.buffer(-1);
        }
    }
},



fillByRowId : function(sRowId, oAction){
    var iSelected, tEmptyRow, tStatusSet, tRequestSet, bContinue = true;

    this.cancelRequests();

     if(oAction === null || typeof(oAction) === "undefined"){
        oAction = new vdf.core.Action("find", this.oForm, this.oServerDD, false);
        bContinue = oAction.lock(this);
    }
    
    if(bContinue){
        this.oFillAction = oAction;
        
        iSelected = this.getSelectedRowNr();
        tEmptyRow = this.createEmptySnapshot();
        
        tStatusSet = new vdf.dataStructs.TAjaxRequestSet();
        tStatusSet.sName = "List_RefreshByRowId_StatusFind";
        tStatusSet.sRequestType = "findByRowId";
        tStatusSet.iMaxRows = 1;
        tStatusSet.sTable = this.sTable;
        tStatusSet.sFindValue = sRowId;
        tStatusSet.bReturnCurrent = false;
        tStatusSet.aRows.push(tEmptyRow);
        
        
        if(iSelected > 0){
            tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
            tRequestSet.sName = "List_RefreshByRowId_FindTop";
            tRequestSet.sRequestType = "find";
            tRequestSet.iMaxRows = iSelected;
            tRequestSet.sIndex = this.getIndex();
            tRequestSet.sTable = this.sTable;
            tRequestSet.sFindMode = (this.bReverseIndex ? vdf.GT : vdf.LT);
            tRequestSet.bLoadStatus = false;
            tRequestSet.aRows.push(tEmptyRow);
            
            oAction.addRequestSet(tStatusSet);
            oAction.addRequestSet(tRequestSet);
        }
     
        
        tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
        tRequestSet.sName = "List_RefreshByRowId_FindBottom";
        tRequestSet.sRequestType = "find";
        tRequestSet.iMaxRows = this.iLength;
        tRequestSet.sIndex = this.getIndex();
        tRequestSet.sTable = this.sTable;
        tRequestSet.sFindMode = (this.bReverseIndex ? vdf.LT : vdf.GT);
        tRequestSet.bLoadStatus = false;
        tRequestSet.bReturnCurrent = true;
        tRequestSet.aRows.push(tEmptyRow);
        
        oAction.addRequestSet(tStatusSet);
        oAction.addRequestSet(tRequestSet);
        
        oAction.onResponse.addListener(this.handleFillByRowId, this);
        oAction.send();
    }
},


handleFillByRowId : function(oEvent){
    var iSelected = 0, iSet, iRow, tResponseSet;
    
    this.oFillAction = null;
    
    if(!oEvent.bError){
        //  Deselect selected row
        if(this.tSelectedRow !== null){
            iSelected = this.getSelectedRowNr();
            this.deSelect();
        }
        
        //  Reset buffers
        this.aDisplay = [];
        this.aBufferTop = [];
        this.aBufferBottom = [];
        
        
        for(iSet = 0; iSet < oEvent.tResponseData.aDataSets.length; iSet++){
            tResponseSet = oEvent.tResponseData.aDataSets[iSet];
            
            //  Add the findtop result
            if(tResponseSet.sName === "List_RefreshByRowId_FindTop"){
                for(iRow = 0; iRow < tResponseSet.aRows.length; iRow++){
                    this.aDisplay.unshift(this.initResponseSnapshot(tResponseSet.aRows[iRow]));
                }
                
                iSelected = iRow;
            }
            
            //  Add the findbottom
            if(tResponseSet.sName === "List_RefreshByRowId_FindBottom"){
                for(iRow = 0; iRow < tResponseSet.aRows.length; iRow++){
                    if(this.aDisplay.length < this.iLength){
                        this.aDisplay.push(this.initResponseSnapshot(tResponseSet.aRows[iRow]));
                    }else{
                        this.aBufferBottom.push(this.initResponseSnapshot(tResponseSet.aRows[iRow]));
                    }
                }
            }
        }
        
        //  Insert the empty row if needed (and create a new because rowids might have changed)
        if(this.bDisplayNewRow){
            //this.tNewRecord = this.initResponseSnapshot(this.createEmptySnapshot());
            
            if(this.aDisplay.length < this.iLength){
                this.aDisplay.push(this.tNewRecord);
            }
        }
        
        //  Refresh display
        this.displayRefresh();
        
        if(this.aDisplay.length > iSelected){
            this.select(this.aDisplay[iSelected]);
        }else if(this.aDisplay.length > 0){
            this.select(this.aDisplay[0]);
        }
        
        //  Reset the buffer to much prevention
        this.sLastBufferUp = null;
        this.sLastBufferDown = null;
        
        this.buffer(0);
    }
},


findByColumn : function(sBinding, sValue){
    var iIndex, bContinue = true, oAction, iSelected, tEmptyRow, tStatusSet, tRequestSet, sField;

    if(this.sTable === sBinding.substr(0, this.sTable.length)){
        iIndex = this.oForm.oMetaData.getFieldProperty("iIndex", sBinding);
        sField = sBinding.replace("__", ".").substr(this.sTable.length + 1);
        if(iIndex !== null && iIndex !== ""){
            this.cancelRequests();

            if(oAction === null || typeof(oAction) === "undefined"){
                oAction = new vdf.core.Action("find", this.oForm, this, this.oServerDD, false);
                bContinue = oAction.lock(this);
            }
            
            if(bContinue){
                this.oFillAction = oAction;
             
                iSelected = this.getSelectedRowNr();
                tEmptyRow = this.createEmptySnapshot(sBinding, sValue);
                                
                tStatusSet = new vdf.dataStructs.TAjaxRequestSet();
                tStatusSet.sName = "List_FindByColumn_Status";
                tStatusSet.sRequestType = "findByField";
                tStatusSet.sFindMode = vdf.GE;
                tStatusSet.iMaxRows = 1;
                tStatusSet.sTable = this.sTable;
                tStatusSet.sColumn = sField;
                tStatusSet.bReturnCurrent = false;
                tStatusSet.aRows.push(tEmptyRow);
                
                
                if(iSelected > 0){
                    tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
                    tRequestSet.sName = "List_FindByColumn_FindTop";
                    tRequestSet.sRequestType = "find";
                    tRequestSet.iMaxRows = iSelected;
                    tRequestSet.sIndex = this.getIndex();
                    tRequestSet.sTable = this.sTable;
                    tRequestSet.sFindMode = (this.bReverseIndex ? vdf.GT : vdf.LT);
                    tRequestSet.bLoadStatus = false;
                    tRequestSet.aRows.push(tEmptyRow);
                    
                    oAction.addRequestSet(tStatusSet);
                    oAction.addRequestSet(tRequestSet);
                }
             
                
                tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
                tRequestSet.sName = "List_FindByColumn_FindBottom";
                tRequestSet.sRequestType = "find";
                tRequestSet.iMaxRows = this.iLength - iSelected;
                tRequestSet.sIndex = this.getIndex();
                tRequestSet.sTable = this.sTable;
                tRequestSet.sFindMode = (this.bReverseIndex ? vdf.LT : vdf.GT);
                tRequestSet.bLoadStatus = false;
                tRequestSet.bReturnCurrent = true;
                tRequestSet.aRows.push(tEmptyRow);
                
                oAction.addRequestSet(tStatusSet);
                oAction.addRequestSet(tRequestSet);
                
                oAction.onResponse.addListener(this.handleFindByColumn, this);
                oAction.send();
                
                
             
            }    
        }else{
            throw new vdf.errors.Error(5147, "Column not in index.", this, [ sBinding ]);
        }
    }else{
        throw new vdf.errors.Error(5148, "Column not in the maintable.", this, [ sBinding ]);
    }
    
},


handleFindByColumn : function(oEvent){
    var iSelected = 0, iSet, iRow, tResponseSet;
    
    this.oFillAction = null;
    
    if(!oEvent.bError){
        //  Deselect selected row
        if(this.tSelectedRow !== null){
            iSelected = this.getSelectedRowNr();
            this.deSelect();
        }
        
        //  Reset buffers
        this.aDisplay = [];
        this.aBufferTop = [];
        this.aBufferBottom = [];
        
        
        for(iSet = 0; iSet < oEvent.tResponseData.aDataSets.length; iSet++){
            tResponseSet = oEvent.tResponseData.aDataSets[iSet];
            
            if(tResponseSet.sName === "List_FindByColumn_FindTop"){
                for(iRow = 0; iRow < tResponseSet.aRows.length; iRow++){
                    this.aDisplay.unshift(this.initResponseSnapshot(tResponseSet.aRows[iRow]));
                }
            }
            
            
            if(tResponseSet.sName === "List_FindByColumn_FindBottom"){
                for(iRow = 0; iRow < tResponseSet.aRows.length; iRow++){
                    this.aDisplay.push(this.initResponseSnapshot(tResponseSet.aRows[iRow]));
                }
            }
        }
        
        //  Insert the empty row if needed (and create a new because rowids might have changed)
        if(this.bDisplayNewRow){
            //this.tNewRecord = this.initResponseSnapshot(this.createEmptySnapshot());
            
            if(this.aDisplay.length < this.iLength){
                this.aDisplay.push(this.tNewRecord);
            }
        }
        
        //  Refresh display
        this.displayRefresh();
        
        if(this.aDisplay.length > iSelected){
            this.select(this.aDisplay[iSelected]);
        }else if(this.aDisplay.length > 0){
            this.select(this.aDisplay[0]);
        }
        
        //  Reset the buffer to much prevention
        this.sLastBufferUp = null;
        this.sLastBufferDown = null;
        
        this.buffer(0);
    }
},



buffer : function(iDir){
    var oAction, tRequestSet, sRowId, iTime;
    
    if(this.oBufferAction !== null){
        return;
    }
    
    oAction = new vdf.core.Action("find", this.oForm, this, this.oServerDD, false);
    this.oBufferAction = oAction;
    
    
    //  Determine if top buffer needs to be filled
    if(iDir <= 0){
        if(this.aBufferTop.length < this.iMinBuffer && this.aDisplay.length > 0){
            tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
            tRequestSet.sName = "List_BufferTop_Find";
            tRequestSet.sRequestType = "find";
            tRequestSet.iMaxRows = this.iMaxBuffer - this.aBufferTop.length;
            tRequestSet.sIndex = this.getIndex();
            tRequestSet.sTable = this.sTable;
            tRequestSet.sFindMode = (this.bReverseIndex ? vdf.GT : vdf.LT);
            
            //  Determine first record to buffer from
            if(this.aBufferTop.length > 0){
                tRequestSet.aRows.push(this.aBufferTop[this.aBufferTop.length - 1]);
            }else{
                if(this.aDisplay[0] !== this.tNewRecord){
                    tRequestSet.aRows.push(this.aDisplay[0]);
                }
            }
            
            if(tRequestSet.aRows.length > 0){
                //  Make sure we do not keep on trying to find records that are not available more than once per iBufferWait milliseconds
                sRowId = tRequestSet.aRows[0].__sRowId;
                iTime = new Date().getTime();
                if(sRowId !== this.sLastBufferUp || iTime > this.iLastBufferUp + this.iBufferWait){
                    this.sLastBufferUp = sRowId;
                    this.iLastBufferUp = iTime;
                    
                    oAction.addRequestSet(tRequestSet);
                }
            }
        }
    }
    
    if(this.aBufferTop.length > this.iMaxBuffer){
        this.aBufferTop.splice(this.iMaxBuffer, (this.aBufferTop.length - this.iMaxBuffer));
    }
    
    //  Determine if bottom buffer needs to be filled
    if(iDir >= 0){
        if(this.aBufferBottom.length < this.iMinBuffer && this.aDisplay.length > 0){
            tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
            tRequestSet.sName = "List_BufferBottom_Find";
            tRequestSet.sRequestType = "find";
            tRequestSet.iMaxRows = this.iMaxBuffer - this.aBufferBottom.length;
            tRequestSet.sIndex = this.getIndex();
            tRequestSet.sTable = this.sTable;
            tRequestSet.sFindMode = (this.bReverseIndex ? vdf.LT :  vdf.GT);
            
            if(this.aBufferBottom.length > 0){
                tRequestSet.aRows.push(this.aBufferBottom[this.aBufferBottom.length - 1]);
            }else{
                if(this.aDisplay[this.aDisplay.length - 1] !== this.tNewRecord){
                    tRequestSet.aRows.push(this.aDisplay[this.aDisplay.length - 1]);
                }else{
                    if(this.aDisplay.length > 2){
                        tRequestSet.aRows.push(this.aDisplay[this.aDisplay.length - 2]);
                    }
                }
            }
            
            if(tRequestSet.aRows.length > 0){
                //  Make sure we do not keep on trying to find records that are not available more than once per iBufferWait milliseconds
                sRowId = tRequestSet.aRows[0].__sRowId;
                iTime = new Date().getTime();
                if(sRowId !== this.sLastBufferDown || iTime > this.iLastBufferDown + this.iBufferWait){
                    this.sLastBufferDown = sRowId;
                    this.iLastBufferDown = iTime;
                    
                    oAction.addRequestSet(tRequestSet);
                }
            }
        }
    }
    
    if(this.aBufferBottom.length > this.iMaxBuffer){
        this.aBufferBottom.splice(this.iMaxBuffer, (this.aBufferBottom.length - this.iMaxBuffer));
    }

    
    if(oAction.tRequestData.aDataSets.length > 0){
        oAction.onResponse.addListener(this.handleBuffer, this);
        oAction.send();
    }else{
        this.oBufferAction = null;
    }
},


handleBuffer : function(oEvent){
    var tResponseSet, iSet, tNewRow, iRow;

    if(!oEvent.bError){
        for(iSet = 0; iSet < oEvent.tResponseData.aDataSets.length; iSet++){
            tResponseSet = oEvent.tResponseData.aDataSets[iSet];
            
            if(tResponseSet.sName === "List_BufferTop_Find"){
                for(iRow = 0; iRow < tResponseSet.aRows.length; iRow++){
                    tNewRow = this.initResponseSnapshot(tResponseSet.aRows[iRow]);
                
                    if(this.aDisplay.length < this.iLength){
                        this.deleteEmptyRow();
                        this.insertOnTop(this.createRow(tNewRow));
                        this.aDisplay.unshift(tNewRow);
                    }else{  
                        this.aBufferTop.push(tNewRow);
                    }
                }
            }
            
            
            if(tResponseSet.sName === "List_BufferBottom_Find"){
                for(iRow = 0; iRow < tResponseSet.aRows.length; iRow++){
                    tNewRow = this.initResponseSnapshot(tResponseSet.aRows[iRow]);

                    if(this.aDisplay.length < this.iLength){
                        this.deleteEmptyRow();
                        this.insertOnBottom(this.createRow(tNewRow));
                        this.aDisplay.push(tNewRow);
                    }else{  
                        this.aBufferBottom.push(tNewRow);
                    }
                }
            }
        }
        
        this.oBufferAction = null;
        
        this.updateScrollbar();
    }
},


cancelRequests : function(){
    if(this.oFillAction !== null){
        this.oFillAction.cancel();
        this.oFillAction = null;
    }
    if(this.oScrollAction !== null){
        this.oScrollAction.cancel();
        this.oScrollAction = null;
    }
    if(this.oBufferAction !== null){
        this.oBufferAction.cancel();
        this.oBufferAction = null;
    }
    
},

// - - - - - - - - - - DATA ENTRY IMPLEMENTATION - - - - - - - - - - -

bindDD : function(){
    var sServerTable, iProto;
    
    sServerTable = this.getVdfAttribute("sServerTable", null, true);
    if(sServerTable !== null){
        this.oServerDD = this.oForm.oDDs[sServerTable.toLowerCase()];
        this.oServerDD.registerDEO(this);
        
        //  Create fields used by the list in the DD buffers
        for(iProto = 0; iProto < this.aPrototypeFields.length; iProto++){
            if(this.aPrototypeFields[iProto].sDataBindingType == "D"){
                if(this.oForm.oDDs[this.aPrototypeFields[iProto].sTable]){
                    this.oForm.oDDs[this.aPrototypeFields[iProto].sTable].createBufferField(this.aPrototypeFields[iProto].sDataBinding, "D");
                }
            }
        }
    }
},


doRefresh : function(){
    this.refresh();
},


refresh : function(oInvokeAction){

    //  Determine the best refresh method based on the action details and the current situation
    if(oInvokeAction && oInvokeAction.sMode === "save"){
        if(this.bAlwaysInOrder){
            if(this.oServerDD.tStatus.sValue !== this.getSelectedRowId()){
                if(this.tSelectedRow === this.tNewRecord){
                    this.rowRefresh();
                }else{
                    this.fullRefresh(oInvokeAction, true);
                }
            }else{
                this.rowRefresh();
            }
        }else{
            if(this.tSelectedRow === this.tNewRecord){
                this.fullRefresh(oInvokeAction, true, true);
            }else{
                this.fullRefresh(oInvokeAction, true);
            }
        }
    }else if(oInvokeAction && oInvokeAction.sMode === "delete"){
        if(this.oServerDD.tStatus.sValue !== this.getSelectedRowId() && oInvokeAction.oMainDD === this.oServerDD){
            this.rowRefreshDelete();
        }else{
            this.fullRefresh(oInvokeAction, true);
        }
    }else{
        if(oInvokeAction){
            if(oInvokeAction.oInitiator !== this){
                if(this.tSelectedRow === null  || this.oServerDD.tStatus.sValue !== this.getSelectedRowId() || this.oServerDD.tStatus.sValue === "" || !this.bAlwaysInOrder){
                    this.fullRefresh(oInvokeAction, true);
                }else{
                    this.rowRefresh();
                }
            }
        }else{
            this.fullRefresh();
        }
    }
},


rowRefresh : function(){
    var tNewRow, eNewRow, iSelected, tOrigRow;

    iSelected = this.getSelectedRowNr();
    tOrigRow = this.aDisplay[iSelected];
    
    //  Generate a new snapshot
    tNewRow = this.oServerDD.generateExtSnapshot(true);
    tNewRow = this.initResponseSnapshot(tNewRow);
    
    //  If the origional record was the new record and the new record was empty we asume that it was a different save and that we are not involved
    if(tOrigRow === this.tNewRecord && tNewRow.__sRowId === this.tNewRecord.__sRowId){
        return;
    }
       
    
    eNewRow = this.createRow(tNewRow);
    
    //  Update snapshot in buffer

    this.aDisplay[iSelected] = tNewRow;
    this.tSelectedRow = tNewRow;
    tNewRow.__eRow = (tOrigRow.__eRow === tOrigRow.__eDisplayRow ? eNewRow : tOrigRow.__eRow);
    tNewRow.__eDisplayRow = eNewRow;
    eNewRow.className = tOrigRow.__eDisplayRow.className;
    
    //  Update displayed snapshot (if needed)  
    if(tOrigRow.__eDisplayRow.parentNode !== null){
        vdf.sys.dom.swapNodes(tOrigRow.__eDisplayRow, eNewRow);
    }
    
    if(tOrigRow === this.tNewRecord){
        //  If the selected row was a newrow we asume it doesn't exists any more and so we insert the new row on the bottom
        if(this.aDisplay.length < this.iLength){
            this.insertOnBottom(this.createRow(this.tNewRecord));
            this.deleteEmptyRow();
            this.aDisplay.push(this.tNewRecord);
        }
    }else{
        //  Destroy orrigionall snapshot & DOM elements
        tOrigRow.__eDisplayRow.tRow = null;
        tOrigRow.__eDisplayRow = null;
        tOrigRow.__eRow = null;
        
    }
    
    //  Fix Odd & Even CSS classes
    this.displayRowCSS();
    
},


rowRefreshDelete : function(){
    var iSelected, tOldRow, tNewRow;
    
    //  Store selected row number
    iSelected = this.getSelectedRowNr();
    tOldRow = this.tSelectedRow;
    this.deSelect();
    
    //  Remove row from the list
    this.aDisplay.splice(iSelected, 1);
    if(this.aBufferBottom.length > 0){
        //  Insert new row on the bottom
        tNewRow = this.aBufferBottom.shift();
        this.insertOnBottom(this.createRow(tNewRow));
        this.aDisplay.push(tNewRow);
    }else if(this.bDisplayNewRow && this.aDisplay[this.aDisplay.length - 1] !== this.tNewRecord){
        //  Insert newrow if needed
        this.insertOnBottom(this.createRow(this.tNewRecord));
        this.aDisplay.push(this.tNewRecord);
    }else if(this.aBufferTop.length > 0){
        //  Insert new row on top
        tNewRow = this.aBufferTop.shift();
        this.insertOnTop(this.createRow(tNewRow));
        this.aDisplay.unshift(tNewRow);
    }else{
        this.insertOnBottom(this.createEmptyRow(false));
    }
    
    this.destroyRow(tOldRow);
    
    
    //  Select the row that is the closest to the current row
    if(iSelected >= this.aDisplay.length){
        iSelected--;
    } 
    if(iSelected >= 0 && iSelected < this.aDisplay.length){
        this.select(this.aDisplay[iSelected]);
    }
   
    //  Fix Odd & Even CSS classes
    this.displayRowCSS();
},





fullRefresh : function(oInvokeAction, bWait, bBottomUp){
    var bContinue = true;

    if(this.tRefreshTimeout !== null){
        clearTimeout(this.tRefreshTimeout);
    }else{
        this.oRefreshAction = new vdf.core.Action("find", this.oForm, this, this.oServerDD, false);
        bContinue = this.oRefreshAction.lock(this);
    }
        
    if(bContinue){
        if(bWait){
            this.fullRefreshWait(bBottomUp);
        }else{
            this.fullRefreshPerform(bBottomUp);
        }
    }
},


fullRefreshWait : function(bBottomUp){
    var oList = this;

    this.tRefreshTimeout = setTimeout(function(){
        oList.fullRefreshPerform.call(oList, bBottomUp);
    }, this.iRefreshTimeout);
},


fullRefreshPerform : function(bBottomUp){
    var sRowId;

    if(this.oServerDD.iLocked > 0){
        this.fullRefreshWait();
    }else{
        this.tRefreshTimeout = null;
    
        if(bBottomUp){
            this.fillBottomUp(this.oRefreshAction);
        }else{
            sRowId = this.oServerDD.getFieldValue(this.sTable, "rowid");
        
            if(sRowId !== null && sRowId !== ""){
                this.fillByRowId(sRowId, this.oRefreshAction);
            }else{
                this.fill(this.oRefreshAction);
            }
        }
    }
},

ddHasRecord : function(){
    var sRowId = this.oServerDD.getFieldValue(this.sTable, "rowid");
        
    return (sRowId !== null && sRowId !== "");
},

// - - - - - - - - - - SPECIFIC FUNCTIONALLITY - - - - - - - - - - -


displayJumpIntoList : function(){
    var eForm, eTable, eRow, eCell, eInput, iSelect, eSelect, iCol, iIndex, oDialog;
    
    //  Generate elements
    eForm = document.createElement("form");

    eTable = document.createElement("table");
    eTable.className = "EntryTable";
    eForm.appendChild(eTable);
    
    eRow = eTable.insertRow(0);
    eCell = eRow.insertCell(0);
    eCell.className = "Label";
    vdf.sys.dom.setElementText(eCell, vdf.lang.getTranslation("list", "search_value", "Search value"));
    
    eCell = eRow.insertCell(1);
    eCell.className = "Data";
    
    //  Search value input
    eInput = document.createElement("input");
    eInput.type = "text";
    eInput.maxLength = 50;
    eCell.appendChild(eInput);
    
    eRow = eTable.insertRow(1);
    eCell = eRow.insertCell(0);
    eCell.className = "Label";
    vdf.sys.dom.setElementText(eCell, vdf.lang.getTranslation("list", "search_column", "Column"));
    
    eCell = eRow.insertCell(1);
    eCell.className = "Data";
    
    //  Loop through the header fields and generate the select with field indexes
    iSelect = 0;
    eSelect = document.createElement("select");
    for(iCol = 0; iCol < this.aHeaderFields.length; iCol++){
        if(this.aHeaderFields[iCol].sTable === this.sTable){
            iIndex = this.aHeaderFields[iCol].getMetaProperty("iIndex");
                
            if(iIndex !== "" && iIndex !== null && parseInt(iIndex, 10) !== 0){
                eSelect.options[eSelect.options.length] = new Option((this.aHeaderFields[iCol].bIsLabel ? this.aHeaderFields[iCol].getLabel() : this.aHeaderFields[iCol].getValue()), this.aHeaderFields[iCol].sDataBinding);
                
                if(iSelect === 0 && iIndex === this.iIndex){
                    iSelect = eSelect.options.length - 1;
                }
            }
        }
    }
    eSelect.selectedIndex = iSelect;
    eCell.appendChild(eSelect);
    
    oDialog = new vdf.gui.ModalDialog();
    oDialog.sTitle = vdf.lang.getTranslation("list", "search_title", "Search");
    
    oDialog.addButton("search", vdf.lang.getTranslation("list", "search", "Search"), "btnSearch");
    oDialog.addButton("cancel", vdf.lang.getTranslation("list", "cancel", "Cancel"), "btnCancel");
    
    vdf.events.addDomListener("submit", eForm, this.onJumpIntoListFormSubmit, this);
    oDialog.onButtonClick.addListener(this.onJumpIntoListButtonClick, this);
    oDialog.onAfterClose.addListener(this.onJumpIntoListDialogClose, this);
    
    this.oJumpIntoList = { oDialog : oDialog, eFieldSelect : eSelect, eValueText : eInput, eForm : eForm };
    
    oDialog.displayDOM(eForm);
    vdf.sys.dom.focus(eInput);
},


doJumpIntoList : function(){
    if(this.oJumpIntoList){
        this.findByColumn(this.oJumpIntoList.eFieldSelect.value, this.oJumpIntoList.eValueText.value);
        this.oJumpIntoList.oDialog.close();
    }
},


onJumpIntoListFormSubmit : function(oEvent){
    this.doJumpIntoList();
    
    oEvent.stop();
},


onJumpIntoListButtonClick : function(oEvent){
    if(this.oJumpIntoList){
        switch(oEvent.sButtonName){
            case "cancel":
                this.oJumpIntoList.oDialog.close();
                break;
            case "search":
                this.doJumpIntoList();
                break;
        }
    }
},


onJumpIntoListDialogClose : function(oEvent){
    if(this.oJumpIntoList){
        vdf.events.removeDomListener("submit",  this.oJumpIntoList.eForm, this.onJumpIntoListFormSubmit);
        this.oJumpIntoList.oDialog.onButtonClick.removeListener(this.onJumpIntoListButtonClick);
        this.oJumpIntoList.oDialog.onAfterClose.removeListener(this.onJumpIntoListDialogClose);
        
        this.focus();
        
        this.oJumpIntoList = null;
    }
},


switchToFieldIndex : function(oField, bReversed){
    var iIndex;
    
    if(oField.sTable === this.sTable){
        iIndex = oField.getMetaProperty("iIndex");
        
        if(iIndex !== null && iIndex !== ""){
            this.switchIndex(iIndex, bReversed);
        }
    }
},


switchIndex : function(iIndex, bReversed){
    if(typeof(bReversed) !== "boolean"){
        if(iIndex === this.iIndex){
            bReversed = !this.bReverseIndex;
        }else{
            bReversed = false;
        }
    }
    
    this.iIndex = iIndex;
    this.bReverseIndex = bReversed;
    
    this.displayHeaderCSS();
    this.fullRefresh();
},


createEmptySnapshot : function(sBinding, sValue){
    var tRow, iField, oField, tField, iDD, sTable;
    
    if(typeof(sBinding) === "undefined"){
        sBinding = null;
    }
    
    //  Create an empty snapshot
    tRow = this.oServerDD.generateExtSnapshot(false);
    
    //  Add the lists field to the snapshot
    for(iField = 0; iField < this.aPrototypeFields.length; iField++){
        oField = this.aPrototypeFields[iField];
        if(oField.isBound()){
            
            //  Create field
            tField = new vdf.dataStructs.TAjaxField();
            tField.sBinding = oField.sDataBinding;
            tField.sType = oField.sDataBindingType;
            
            //  Set value if given
            if(tField.sBinding === sBinding){
                tField.sValue = sValue;
            }
            
            //  Add the field to the snapshot by searching the right DD
            if(oField.sDataBindingType === "D"){
                for(iDD = 0; iDD < tRow.aDDs.length; iDD++){
                    if(tRow.aDDs[iDD].sName === oField.sTable){
                        tRow.aDDs[iDD].aFields.push(tField);
                        tRow.aDDs[iDD].bLight = false;
                        break;
                    }
                }
            }else if(oField.sDataBindingType === "E"){
                sTable = oField.getVdfAttribute("sServerTable", null, true);
                if(sTable !== null){
                    sTable = sTable.toLowerCase();
                
                    for(iDD = 0; iDD < tRow.aDDs.length; iDD++){
                        if(tRow.aDDs[iDD].sName === sTable){
                            tRow.aDDs[iDD].bLight = false;
                            tRow.aDDs[iDD].aFields.push(tField);
                            break;
                        }
                    }
                }
            }
        }
    }
    
    return tRow;
},


initResponseSnapshot : function(tRow){
    var iDD, iField;
    tRow.__oData = { };
    tRow.__sRowId = "";
    
    for(iDD = 0; iDD < tRow.aDDs.length; iDD++){
        for(iField = 0; iField < tRow.aDDs[iDD].aFields.length; iField++){
            tRow.__oData[tRow.aDDs[iDD].aFields[iField].sBinding] = tRow.aDDs[iDD].aFields[iField].sValue;
        }
       
        if(tRow.aDDs[iDD].sName === this.sTable){
            tRow.__sRowId = tRow.aDDs[iDD].tStatus.sValue;
        }
        
        tRow.__oData[tRow.aDDs[iDD].tStatus.sBinding] = tRow.aDDs[iDD].tStatus.sValue;
    }

    return tRow;
},


determineSync : function(){
    return this.oServerDD.hasDependingDEO([ this ]);
},


getSelectedRowNr : function(){
    var iRow;
    
    for(iRow = 0; iRow < this.aDisplay.length; iRow++){
        if(this.aDisplay[iRow] === this.tSelectedRow){
            return iRow;
        }
    }
    
    return null;
},


getSelectedRowId : function(){
    return (this.tSelectedRow !== null ? this.tSelectedRow.__sRowId : null);
},


getStretchValue : function(oField){
    var sValue, sType, iLength, iCurrent;
    
    iLength = parseInt(oField.getMetaProperty("iDataLength"), 10);
    sType = oField.getMetaProperty("sDataType");
    sValue = "";

    if(sType == "ascii" || sType == "text"){
        for(iCurrent = 0; iCurrent < iLength; iCurrent++){
            sValue += "W";
        }
    }else if(sType == "bcd"){
        for(iCurrent = 0; iCurrent < iLength; iCurrent++){
            sValue += "8";
        }
        iLength = parseInt(oField.getMetaProperty("iPrecision"), 10);
        if(iLength > 0){
            sValue += this.oForm.getMetaProperty("sDecimalSeparator");
        }
        for(iCurrent = 0; iCurrent < iLength; iCurrent++){
            sValue += "8";
        }
    }else if(sType == "date"){
        sValue = this.oForm.getMetaProperty("sDateFormat").toLowerCase().replace('m','8').replace('y', '8').replace('d', '8');
    }
    
    return sValue;
},


returnFocus : function(){
    //vdf.log("returnFocus (eFocus:" + this.eFocus  + " bHasFocus:" + this.bHasFocus + " bLozingFocus:" + this.bLozingFocus + "");
    if(this.eFocus){
        if(this.bHasFocus || this.bLozingFocus){
            vdf.sys.dom.focus(this.eFocus);
            this.onFocus();
        }
    }
},


focus : function(){
    //vdf.log("focus (eFocus:" + this.eFocus  + " bHasFocus:" + this.bHasFocus + " bLozingFocus:" + this.bLozingFocus + "");
    if(this.eFocus !== null){
        vdf.sys.dom.focus(this.eFocus);
        this.onFocus();
    }
},


findRowElement : function(eElem){
    var oResult = { eRow : null, sBinding : null };

    while(eElem && eElem !== document){
        if(oResult.sBinding === null && eElem.getAttribute("vdfDataBinding")){
            oResult.sBinding =  eElem.getAttribute("vdfDataBinding");
            oResult.sBinding = (typeof oResult.sBinding === "string" ? oResult.sBinding.replace("__", ".").toLowerCase() : null);
        }
        if(eElem.tagName === "TR" && vdf.getDOMAttribute(eElem, "sRowType")){
            oResult.eRow = eElem;
            return oResult;
        }
        
        eElem = eElem.parentNode;
    }

    return null;
},


selectByRow : function(eElement){
    var oClicked = this.findRowElement(eElement);
    
    if(oClicked && vdf.getDOMAttribute(oClicked.eRow, "sRowType") === "display"){
        this.scrollToRow(oClicked.eRow, oClicked.sBinding);
    }
},


deleteByRow : function(eElement){
    var oClicked = this.findRowElement(eElement);
   
    return this.scrollToRow(oClicked.eRow, null, function(){
        if(this.oForm.getDD(this.sTable).hasRecord()){
            this.oForm.getDD(this.sTable).doDelete();
        }
    }, this);
},


onRowClick : function(oEvent){
    var oClicked = this.findRowElement(oEvent.getTarget());
    
    if(oClicked && vdf.getDOMAttribute(oClicked.eRow, "sRowType") === "display"){
        this.scrollToRow(oClicked.eRow, oClicked.sBinding);
    }
    
    this.focus();
},


onMouseWheelScroll : function(oEvent){
    var iDelta = oEvent.getMouseWheelDelta();
    
    if(iDelta > 0){
        this.scrollUp();
        oEvent.stop();
    }else if(iDelta < 0){
        this.scrollDown();
        oEvent.stop();
    }
},


onEnterAction : function(){
    if(!this.onEnter.fire(this, null)){
        return true;
    }else if(this.oForm !== null && !this.oForm.onEnter.fire(this, null)){
        return true;
    }
    
    return false;
},


onKey : function(oEvent){
    var oPressedKey = {
        iKeyCode : oEvent.getKeyCode(),
        bCtrl : oEvent.getCtrlKey(),
        bShift : oEvent.getShiftKey(),
        bAlt : oEvent.getAltKey()
    };

    try{
        if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.scrollUp)){ 
            this.scrollUp();
            oEvent.stop();
        }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.scrollDown)){ 
            this.scrollDown();
            oEvent.stop();
        }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.scrollPageUp)){ 
            this.scrollPageUp();
            oEvent.stop();
        }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.scrollPageDown)){ 
            this.scrollPageDown();
            oEvent.stop();
        }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.scrollTop)){ 
            this.scrollTop();
            oEvent.stop();
        }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.scrollBottom)){ 
            this.scrollBottom();
            oEvent.stop();
        }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.search)){
            if(this.bSearch){
                this.displayJumpIntoList();
                oEvent.stop();
            }
        }else if(vdf.sys.ref.matchByValues(oPressedKey, this.oActionKeys.enter)){
            if(this.onEnterAction()){
                oEvent.stop();
            }
        }
    }catch (oError){
        vdf.errors.handle(oError);
    }
},


onFocus : function(oEvent){
    //vdf.log("onfocus (eFocus:" + this.eFocus  + " bHasFocus:" + this.bHasFocus + " bLozingFocus:" + this.bLozingFocus + "");
    if(this.tFocusTimeout){
        clearTimeout(this.tFocusTimeout);
        this.tFocusTimeout = null;
    }

    this.bHasFocus = true;
    this.bLozingFocus = false;
    if(this.eElement.tBodies[0].className.match("focussed") === null){
        this.eElement.tBodies[0].className += " focussed";
    }
},


onBlur : function(oEvent){
    var oList = this;
    
    //vdf.log("blur (eFocus:" + this.eFocus  + " bHasFocus:" + this.bHasFocus + " bLozingFocus:" + this.bLozingFocus + "");
    if(this.bHasFocus){
        this.bLozingFocus = true;
        
        if(this.tFocusTimeout){
            clearTimeout(this.tFocusTimeout);
            this.tFocusTimeout = null;
        }
        
        this.tFocusTimeout = setTimeout(function(){
            if(oList.bLozingFocus){
                //vdf.log("blur timeout (eFocus:" + this.eFocus  + " bHasFocus:" + this.bHasFocus + " bLozingFocus:" + this.bLozingFocus + "");
                oList.bHasFocus = false;
                oList.bLozingFocus = false;
                if(oList.eElement){
                    oList.eElement.tBodies[0].className = oList.eElement.tBodies[0].className.replace("focussed", "");
                }
            }
        }, 200);
    }
},


onTableClick : function(oEvent){
    this.focus();
},


onIndexClick : function(oEvent){
    var eField = oEvent.getTarget();
    
    if(typeof(eField.oVdfControl) !== "undefined" && (eField.oVdfControl.bIsField || eField.oVdfControl.bIsLabel)){
        this.switchToFieldIndex(eField.oVdfControl, null);
    }
},


onScroll : function(oEvent){
    switch(oEvent.iDirection){
        case vdf.gui.SCROLL_TOP:
            this.scrollTop();
            break;
        case vdf.gui.SCROLL_UP:
            this.scrollPageUp();
            break;
        case vdf.gui.SCROLL_STEP_UP:
            this.scrollUp();
            break;
        case vdf.gui.SCROLL_STEP_DOWN:
            this.scrollDown();
            break;
        case vdf.gui.SCROLL_DOWN:
            this.scrollPageDown();
            break;
        case vdf.gui.SCROLL_BOTTOM:
            this.scrollBottom();
            break;
    }
    
    var oList = this;
    
    setTimeout(function(){
        oList.returnFocus();
    }, 100);
},


getIndex : function(){
    var iIndex = this.iIndex, iCol;
    
    if(iIndex === "" || iIndex === null || parseInt(iIndex, 10) === 0){
        for(iCol = 0; iCol < this.aHeaderFields.length; iCol++){
            iIndex = this.aHeaderFields[iCol].getMetaProperty("iIndex");
            
            if(iIndex !== "" && iIndex !== null && parseInt(iIndex, 10) !== 0){
                this.iIndex = iIndex;
                return iIndex;
            }
        }
        
        iIndex = "1";
    }
    
    return iIndex;
},


lock : function(bExclusive, oAction){
    var oOffset;

    if(oAction !== this.oSelectAction){
        this.iLocked++;
    }
    
    if(this.bDisplayLoading){
        if(this.iLocked > 0){
            //  Generate loading div
            if(this.eLoadingDiv === null){
                this.eLoadingDiv = document.createElement("div");
                vdf.sys.dom.insertAfter(this.eLoadingDiv, this.eElement);
                //document.body.appendChild(this.eLoadingDiv);
                this.eLoadingDiv.className = this.sCssClass + "_loading";
                this.eLoadingDiv.style.zIndex = vdf.gui.reserveZIndex();
            }
            this.eLoadingDiv.style.display = "";

            oOffset = vdf.sys.gui.getAbsoluteOffset(this.eElement);
            this.eLoadingDiv.style.left = oOffset.left + "px";
            this.eLoadingDiv.style.top = oOffset.top + "px";
            this.eLoadingDiv.style.width = this.eElement.clientWidth + "px";
            this.eLoadingDiv.style.height = this.eElement.clientHeight + "px";
        }
    }
},


unlock : function(bExclusive, oAction){
    if(oAction !== this.oSelectAction){
        this.iLocked--;

        if(this.bDisplayLoading && this.iLocked <= 0){
            this.eLoadingDiv.style.display = "none";
        }
    }
},

// - - - - - - - - - - CONTAINER FUNCTIONALITY - - - - - - - - - - 


addChild : function(oControl){
    var eRow, bParent;
    
    if(!(oControl.bIsField)){
        if(oControl.bIsLabel){
            eRow = vdf.sys.dom.searchParentByVdfAttribute(oControl.eElement, "sRowType", null);
    
            if(eRow !== null){
                bParent = this.checkField(eRow, vdf.getDOMAttribute(eRow, "sRowType"), oControl);
            }
        }
        this.aChildren.push(oControl);
    }
},


// formInit is defined above




// recalcDisplay is defined above


waitForCalcDisplay : function(){
    var iChild, iWait = 1;
    
    for(iChild = 0; iChild < this.aChildren.length; iChild++){
        if(typeof(this.aChildren[iChild].waitForCalcDisplay) === "function"){
            iWait =  iWait + this.aChildren[iChild].waitForCalcDisplay();
        }
    }
    
    return iWait;
}



});






vdf.core.LookupDialog = function LookupDialog(eElement, oParentControl){
    var iField, sLookupFields, sAttachedFields, sColumnWidths, sColumnTitles;

    this.Control(eElement, oParentControl);
    
    
    this.sLookupTable = this.getVdfAttribute("sLookupTable", null, false);
    
    this.sServerTable = this.getVdfAttribute("sServerTable", this.sLookupTable, true);
    
    
    this.sWebObject = this.getVdfAttribute("sWebObject", null, true);
    
    this.sWebServiceUrl = this.getVdfAttribute("sWebServiceUrl", "WebService.wso", true);
    
    this.sXmlNS = this.getVdfAttribute("sXmlNS", "http://tempuri.org/", true);
    
    this.sFocusField = this.getVdfAttribute("sFocusField", null, false);
    
    this.aAttachedFields = null;
    
    this.aLookupFields = null;
    
    this.aColumnWidths = null;
    
    this.aColumnTitles = null;
    
    this.iLength = this.getVdfAttribute("iLength", this.getVdfAttribute("iRowLength", 10, false), false);
    
    
    this.bEnabled           = this.getVdfAttribute("bEnabled", true, true);
    
    
    this.iIndex             = this.getVdfAttribute("iIndex", "", false);
    
    this.bReverseIndex      = this.getVdfAttribute("bReverseIndex", false, false);
    
    this.bAllowSorting      = this.getVdfAttribute("bAllowSorting", true, false);
        
    
    this.sTitle = this.getVdfAttribute("sTitle", vdf.lang.getTranslation("lookupdialog", "title", "Lookup"));
    
    this.sCssContent = this.getVdfAttribute("sCssContent", "lookupdialog", true);
    
    
    this.onBeforeOpen = new vdf.events.JSHandler();
    
    this.onAfterOpen = new vdf.events.JSHandler();
    
    this.onBeforeClose = new vdf.events.JSHandler();
    
    this.onAfterClose = new vdf.events.JSHandler();
    
    this.onBeforeSelect = new vdf.events.JSHandler();
    
    this.onAfterSelect = new vdf.events.JSHandler();
    
    // @privates
    this.eDiv = null;
    this.oDialog = null;
    this.oLookup = null;
    this.oLookupForm = null;
    this.oSource = null;
    
    
    //  Lowercase stuff
    if(this.sLookupTable !== null){
        this.sLookupTable = this.sLookupTable.toLowerCase();
    }
    
    //  Determine forced attach fields
    sAttachedFields = this.getVdfAttribute("sAttachedFields", null);
    if(sAttachedFields !== null){
        this.aAttachedFields = sAttachedFields.split(",");
        for(iField = 0; iField < this.aAttachedFields.length; iField++){
            this.aAttachedFields[iField] = vdf.sys.string.trim(this.aAttachedFields[iField].toLowerCase());
        }
    }else{
        this.aAttachedFields = [];
    }
    
    //  Determine the lookup fields
    sLookupFields = this.getVdfAttribute("sLookupFields", null);
    if(sLookupFields !== null){
        this.aLookupFields = sLookupFields.split(",");
        for(iField = 0; iField < this.aLookupFields.length; iField++){
            this.aLookupFields[iField] = vdf.sys.string.trim(this.aLookupFields[iField].toLowerCase().replace("__", "."));
        }
    }
    
    //  Determine the column widths
    sColumnWidths = this.getVdfAttribute("sColumnWidths", null);
    if(sColumnWidths){
        this.aColumnWidths = sColumnWidths.split(",");
    }
    
    //  Determine the column titles
    sColumnTitles = this.getVdfAttribute("sColumnTitles", null);
    if(sColumnTitles){
        this.aColumnTitles = sColumnTitles.split(",");
        
        for(iField = 0; iField < this.aColumnTitles.length; iField++){
            this.aColumnTitles[iField] = vdf.sys.string.trim(this.aColumnTitles[iField]);
        }
    }
   
    
};

vdf.definePrototype("vdf.core.LookupDialog", "vdf.core.Control", {


formInit : function(){
    var iField, oField, sIndex, iDeo;
    
    //  Attach to the fields
    for(iDeo = 0; iDeo < this.oForm.aDEOs.length; iDeo++){
        oField = this.oForm.aDEOs[iDeo];
        if(oField.sDataBindingType === "D" && oField.sTable === this.sLookupTable){
            sIndex = oField.getMetaProperty("iIndex");
            if(sIndex !== "" && sIndex > 0){
                if(this.oForm.aDEOs[iDeo].oLookup === null){
                    this.oForm.aDEOs[iDeo].oLookup = this;
                }
            }
        }
    }
    
    //  Attach to the attached fields, overwrite lookups that are already there
    for(iField = 0; iField < this.aAttachedFields.length; iField++){
        oField = this.oForm.getDEO(this.aAttachedFields[iField]);
        if(oField !== null){
            oField.oLookup = this;
        }
    }
    
    vdf.events.addDomListener("click", this.eElement, this.onButtonClick, this);
    
    if(!this.bEnabled){
        this.disable();
    }
},


enable : function(){
    this.bEnabled = true;
    
    if(typeof(this.eElement.disabled) !== "undefined"){
        this.eElement.disabled = false;
    }
},


disable : function(){
    this.bEnabled = false;
    
    if(typeof(this.eElement.disabled) !== "undefined"){
        this.eElement.disabled = true;
    }
},


destroy : function(){
    if(this.eElement){
        vdf.events.removeDomListener("click", this.eElement, this.onButtonClick);
    }
    this.eElement = null;
    this.eDiv = null;
},


display : function(oSource){
    var oGrid, that = this;
    
    if(this.bEnabled){
        if(typeof(oSource) == "undefined"){
            oSource = null;
        }
        this.oSource = oSource;

        if(this.onBeforeOpen.fire(this, { oOpeningField : oSource })){

            //  Cancel the bAutoSaveState save of grids where we are in..
            oGrid = vdf.core.init.findParentControl(this.eElement, "vdf.deo.Grid");
            if(oGrid){
                oGrid.bSkipAutoSave = true;
            }
            
            //  Actually display the dialog
            this.eDiv = this.generateDialog();
            this.generateElements(oSource, this.eDiv);
            
            vdf.onControlCreated.addListener(this.onControlCreated, this);
            vdf.core.init.initializeControls(this.eDiv);
            
            //  We schedule a calculatePosition so the dialog will also be visible if errors occur during initialization (so the user can close it)
            setTimeout(function(){
                that.oDialog.calculatePosition();
            }, 1000);
        }
    }
},


onControlCreated : function(oEvent){
    if(oEvent.sPrototype === "vdf.deo.Lookup"){
        this.oLookup = oEvent.oControl;
        this.oLookup.onInitialized.addListener(this.onLookupInitialized, this);
        vdf.onControlCreated.removeListener(this.onControlCreated);
    }
    if(oEvent.sPrototype === "vdf.core.Form"){
        this.oLookupForm = oEvent.oControl;
        
        //  Note: Web Object restriction that is removed in 2.1.1.5
        //if(this.sWebObject === this.oForm.sWebObject){
            this.oLookupForm.oUserDataFields = this.oForm.oUserDataFields;
        //}
    }
},


onLookupInitialized : function(oEvent){
    var iField;

    this.oDialog.calculatePosition();
    this.oLookup.onEnter.addListener(this.onLookupEnter, this);
    
    for(iField = 0; iField < this.aAttachedFields.length; iField++){
        if(this.aAttachedFields[iField] !== ""){
            if(this.oSource === null){
                this.oLookup.findByColumn(this.aLookupFields[iField], this.oForm.getBufferValue(this.aAttachedFields[iField]));
                break;
            }else if(this.oSource.sDataBinding === this.aAttachedFields[iField]){
                this.oLookup.findByColumn(this.aLookupFields[iField], this.oSource.getValue());
                break;
            }
        }
    }
    
    this.onAfterOpen.fire(this, { oOpeningField : this.oSource });
},


generateDialog : function(){
    var oDialog, eDiv;
    
    oDialog = new vdf.gui.ModalDialog();
    oDialog.sTitle = this.sTitle;
    
    oDialog.initializeDialog();

    eDiv = document.createElement("div");
    eDiv.className = this.sCssContent;
    oDialog.eCellContent.appendChild(eDiv);
    
    oDialog.addButton("select", vdf.lang.getTranslation("lookupdialog", "select", "select"), "btnSelect");
    oDialog.addButton("cancel", vdf.lang.getTranslation("lookupdialog", "cancel", "cancel"), "btnCancel");
    oDialog.addButton("search", vdf.lang.getTranslation("lookupdialog", "search", "search"), "btnSearch");
    
    oDialog.onButtonClick.addListener(this.onDialogButtonClick, this);
    oDialog.onBeforeClose.addListener(this.onBeforeDialogClose, this);
    oDialog.onAfterClose.addListener(this.onAfterDialogClose, this);
    
    this.oDialog = oDialog;
    
    return eDiv;
},


generateElements : function(oSource, eDiv){
    var eForm, sDD, oDD, eInput, eTable, sIndex, eHeaderRow, eDisplayRow, eCell, eCellDiv, iField;
    
    //  Form
    eForm = document.createElement("form");
    eDiv.appendChild(eForm);
    eForm.autocomplete = "off";
    eForm.setAttribute("vdfControlType", "form");
    eForm.setAttribute("vdfName", this.sName + "_lookup_form");
    eForm.setAttribute("vdfServerTable", this.sServerTable);
    eForm.setAttribute("vdfWebObject", this.sWebObject);
    eForm.setAttribute("vdfWebServiceUrl", this.sWebServiceUrl);
    eForm.setAttribute("vdfXmlNS", this.sXmlNS);
    // eForm.setAttribute("vdfAutoFill", "false");
    
    //  Generate status fields
    for(sDD in this.oForm.oDDs){
        if(this.oForm.oDDs[sDD].bIsDD){
            //  If the lookup works on a different WO (which can be done but isn't adviced) we only add the lookup table rowid field
            if(this.sWebObject === this.oForm.sWebObject || sDD === this.sLookupTable){
                oDD = this.oForm.oDDs[sDD];
                eInput = document.createElement("input");
                eInput.type = "hidden";
                eInput.setAttribute("vdfDataBinding", oDD.sName + "__rowid");
                eInput.name = oDD.sName + "__rowid_lookup_form";
                eInput.value = (oDD.tStatus.sValue !== null ? oDD.tStatus.sValue : "");
                eForm.appendChild(eInput);
            }
        }
    }
    
    //  Lookup
    eTable = document.createElement("table");
    eForm.appendChild(eTable);
    eTable.className = "VdfLookup";
    eTable.setAttribute("vdfControlType", "lookup");
    eTable.setAttribute("vdfName", this.sName + "_lookup");
    eTable.setAttribute("vdfMainTable", this.sLookupTable);
    eTable.setAttribute("vdfLength", this.iLength);
    eTable.setAttribute("vdfFocus", "true");
    eTable.setAttribute("vdfAutoLabel", "true");
    eTable.setAttribute("vdfIndex", this.iIndex);
    eTable.setAttribute("vdfReverseIndex", this.bReverseIndex);
    eTable.setAttribute("vdfAllowSorting", this.bAllowSorting);
    
    eTable.setAttribute("vdfFixedColumnWidth", "true");
    if(this.aColumnWidths){
        eTable.setAttribute("vdfDetermineWidth", "false");
    }
    
    sIndex = this.getVdfAttribute("sIndex", "", true);
    if(oSource !== null && oSource.bIsField){
        sIndex = oSource.getMetaProperty("iIndex");
    }
    if(sIndex !== ""){
        eTable.setAttribute("vdfIndex", sIndex);
    }
    
    
    //  Rows
    eHeaderRow = eTable.insertRow(0);
    eHeaderRow.setAttribute("vdfRowType", "header");
    eDisplayRow = eTable.insertRow(1);
    eDisplayRow.setAttribute("vdfRowType", "display");
    
    for(iField = 0; iField < this.aLookupFields.length; iField++){
        eCell = document.createElement("th");
        
        
        if(this.aColumnWidths && this.aColumnWidths.length > iField){
            eCell.style.width = parseInt(this.aColumnWidths[iField], 10) + "px";
        }
        
        eCell.setAttribute("vdfControlType", "label");
        eCell.setAttribute("vdfDataBinding", this.aLookupFields[iField]);
        if(this.aColumnTitles && this.aColumnTitles.length > iField && this.aColumnTitles[iField]){
            vdf.sys.dom.setElementText(eCell, this.aColumnTitles[iField]);
            eCell.setAttribute("vdfAutoLabel", "false");
        }else{
            eCell.innertHtml = "&nbsp;";
        }
                
        eHeaderRow.appendChild(eCell);
        
        eCell = eDisplayRow.insertCell(iField);
        eCellDiv = document.createElement("div");
        eCellDiv.setAttribute("vdfDataBinding", this.aLookupFields[iField]);
        
        eCellDiv.innertHtml = "&nbsp;";
        eCell.appendChild(eCellDiv);
    }
    
    

},


finish : function(){
    this.select();
    this.close();
},


select : function(){
    var iField, sRowId = this.oLookupForm.getBufferValue(this.sLookupTable  + ".rowid");
    
    if(this.onBeforeSelect.fire(this, {sRowId : sRowId })){
        //  Manually set the field values (if sAttachedFields is set)
        for(iField = 0; iField < this.aAttachedFields.length; iField++){
            if(this.aAttachedFields[iField] !== ""){
                this.oForm.setBufferValue(this.aAttachedFields[iField], this.oLookupForm.getBufferValue(this.aLookupFields[iField]));
            }
        }
        
        //  If DD is available we do a find by rowid
        if(this.oForm.containsDD(this.sLookupTable)){
            this.oForm.doFindByRowId(this.sLookupTable, sRowId);
        }

        this.onAfterSelect.fire(this, { });
    }
},


close : function(){
    this.oDialog.close();
},


onBeforeDialogClose : function(oEvent){
    if(!this.onBeforeClose.fire(this, { })){
        oEvent.stop(0);
    }else{
        this.oLookup.onEnter.removeListener(this.onLookupEnter);
        this.oLookup.onInitialized.removeListener(this.onLookupInitialized);
        vdf.core.init.destroyControls(this.eDiv);
        this.oLookup = null;
        this.oLookupForm = null;
        this.eDiv.parentNode.removeChild(this.eDiv);
        this.eDiv = null;
    }
},


returnFocus : function(){
    var oField = null, iDeo;

    //  Determine focus field
    //  Step 1: Focus field property
    if(this.sFocusField){
        oField = this.oForm.getDEO(this.sFocusField);
    }
    
    //  Step 2: Field that opened the lookup (using F4)
    if(oField === null && this.oSource){
        oField = this.oSource;
    }
    
    //  Step 3: The first field of the form bound to a field of this table 
    for(iDeo = 0; oField === null && iDeo < this.oForm.aDEOs.length; iDeo++){
        if(this.oForm.aDEOs[iDeo].sTable === this.sLookupTable && this.oForm.aDEOs[iDeo].sDataBindingType === "D"){
            oField = this.oForm.aDEOs[iDeo];
        }
    }
    
    //  Step 3: Take the last active field
    if(oField === null){
        oField = this.oForm.oActiveField;
    }
    
    //  Give the focus
    if(oField && oField.bFocusable){
        oField.focus();
    }
},


onAfterDialogClose : function(oEvent){
    this.returnFocus();

    
    
    this.oDialog.onButtonClick.removeListener(this.onDialogButtonClick);
    this.oDialog.onAfterClose.removeListener(this.onDialogClose);
    this.oDialog = null;
    
    this.onAfterClose.fire(this, { });
},


onDialogButtonClick : function(oEvent){
    if(oEvent.sButtonName === "select"){
        this.finish();
    }else if(oEvent.sButtonName === "cancel"){
        this.close();
    }else if(oEvent.sButtonName === "search"){
        this.oLookup.displayJumpIntoList();
    }

},


onButtonClick : function(oEvent){
    this.display();
},


onLookupEnter : function(oEvent){
    this.finish();
}

});







vdf.core.oMetaData = {};


vdf.core.MetaData = function MetaData(sWebObject, sWebServiceUrl, sXmlNS){
    this.sWebObject = sWebObject;
    
    this.oPipe = new vdf.ajax.PriorityPipe(sWebServiceUrl, sXmlNS);
};

vdf.definePrototype("vdf.core.MetaData", {


loadGlobalData : function(fHandler, oEnv){
    var oCall;

    //  Check if meta data for this WO isn't already loaded / loading
    if(vdf.core.oMetaData[this.sWebObject] !== undefined){
        //  If loading we add ourself to the listeners else we call the handler directly
        if(typeof(vdf.core.oMetaData[this.sWebObject].bLoading) === "boolean"){
            vdf.core.oMetaData[this.sWebObject].aWaiting.push({ oEnv : oEnv, fHandler : fHandler });
        }else{
            fHandler.call(oEnv);
        }
    }else{
        //  Create tempolary object with array with handling methods
        vdf.core.oMetaData[this.sWebObject] = { bLoading : true, aWaiting : [ { oEnv : oEnv, fHandler : fHandler } ] };
        
        //  Create and send request
        oCall = new vdf.ajax.JSONCall("MetaDataWO", { sSessionKey : vdf.sys.cookie.get("vdfSessionKey"), sWebObject :  this.sWebObject, sVersion : vdf.sVersion });
        this.oPipe.send(oCall, 3, this.handleGlobalData, this);
    }
},


handleGlobalData : function(oEvent){
    var i, tResponse = oEvent.oSource.getResponseValue("TAjaxMetaWO"), aWaiting;
    
    //  Check for errors
    if(vdf.errors.checkServerError(tResponse.aErrors, this)){
    
        //  Remap DDs by their name in oDDs
        tResponse.oDDs = { };
        for(i = 0; i < tResponse.aDDs.length; i++){
            tResponse.oDDs[tResponse.aDDs[i].sName] = tResponse.aDDs[i];
            tResponse.aDDs[i].oFields = { };
        }
        
        //  Store result
        aWaiting = vdf.core.oMetaData[this.sWebObject].aWaiting;
        vdf.core.oMetaData[this.sWebObject] = tResponse;

        for(i = 0; i < aWaiting.length; i++){
            aWaiting[i].fHandler.call(aWaiting[i].oEnv);
        }
    }
},


loadFieldData : function(aFields, fHandler, oEnv){
    var oMeta = this.getMetaData(), oCall, aParts, iField;
    
    //  Remove fields that are already loaded
    if(oMeta !== null){
        for(iField = 0; iField < aFields.length; iField++){
            aFields[iField] = aFields[iField].replace("__", ".").toLowerCase();
            aParts = aFields[iField].split(".");
            if(typeof(oMeta.oDDs[aParts[0]]) !== "undefined" && typeof(oMeta.oDDs[aParts[0]].oFields[aParts[1]]) !== "undefined"){
                aFields.splice(iField, 1);
                iField--;
            }
        }
    }
    
    if(aFields.length > 0){
        //  If fields left send request for these
        oCall = new vdf.ajax.JSONCall("MetaDataFields", { sSessionKey : vdf.sys.cookie.get("vdfSessionKey"), sWebObject : this.sWebObject, "sFields" : aFields.join("|") });
        oCall._fHandler = fHandler;
        oCall._oEnv = oEnv;
        this.oPipe.send(oCall, 2, this.handleFieldData, this);
    }else{
        //  If all already available call "listener"
        fHandler.call(oEnv);
    }
},


handleFieldData : function(oEvent){
    var oMeta, tResponse, aFields, iField;
    
    oMeta = this.getMetaData();
    tResponse = oEvent.oSource.getResponseValue("TAjaxMetaFields");
    
    //  Check for errors
    if(vdf.errors.checkServerError(tResponse.aErrors, this)){
        aFields = tResponse.aFields;
        
        //  Push in the right structure
        for(iField = 0; iField < aFields.length; iField++){
            if(!oMeta.oDDs[aFields[iField].sTable].oFields[aFields[iField].sName]){
                oMeta.oDDs[aFields[iField].sTable].oFields[aFields[iField].sName] = aFields[iField];        
            }
        }
        
        oEvent.oSource._fHandler.call(oEvent.oSource._oEnv);
    }
},


loadFieldProperties : function(aFields, aProperties, fHandler, oEnv){
    var oCall, iField;
    
    //  Naming convention
    for(iField = 0; iField < aFields.length; iField++){
        aFields[iField] = aFields[iField].replace("__", ".").toLowerCase();
    }
    
    //  Create and send the request
    oCall = new vdf.ajax.SoapCall("MetaDataProperties", { sSessionKey : vdf.sys.cookie.get("vdfSessionKey"), sWebObject : this.sWebObject, "aFields" : aFields, "aProperties" : aProperties});
    oCall._fHandler = fHandler;
    oCall._oEnv = oEnv;
    this.oPipe.send(oCall, 1, this.handleFieldProperties, this);
},


handleFieldProperties : function(oEvent){
    var oMeta, tResponse, iField, tField, iProp, oField;
    
    oMeta = this.getMetaData();
    tResponse = oEvent.oSource.getResponseValue("TAjaxMetaProperties");
    
    //  Check for errors
    if(vdf.errors.checkServerError(tResponse.aErrors, this)){
    
        //  Push in the right structure
        for(iField = 0; iField < tResponse.aFields.length; iField++){
            tField = tResponse.aFields[iField];
            
            //  Find the table object in the data structure
            if(typeof(oMeta.oDDs[tField.sTable]) !== "undefined"){
                if(oMeta.oDDs[tField.sTable].oFields[tField.sField]){
                    oField = oMeta.oDDs[tField.sTable].oFields[tField.sField];
                    
                    //  Add the loaded properties
                    for(iProp = 0; iProp < tField.aProperties.length; iProp++){
                        oField[tField.aProperties[iProp].sProperty] = tField.aProperties[iProp].sValue;
                    }
                        
                }else{
                    throw new vdf.errors.Error(5138, "Unknown field", this, [ tField.sField, tField.sTable, "vdf.core.MetaData(handleFieldProperties)" ]);
                }            
            }else{
                throw new vdf.errors.Error(5137, "Unknown table", this, [ tField.sTable, "vdf.core.MetaData(handleFieldProperties)" ]);
            }
        }
        
        oEvent.oSource._fHandler.call(oEvent.oSource._oEnv);
    }
},



loadDescriptionValues : function(sField, fHandler, oEnv){
    var oCall, sTable, aParts, oCurrent, oMeta;
    
    //  Determine current value
    oMeta = this.getMetaData();

    //  Split field name into table and column
    aParts = sField.replace("__", ".").toLowerCase().split(".");
    sField = aParts[1];
    sTable = aParts[0];

    //  Get current value
    oCurrent = this.getFieldProperty("aDescriptionValues", sTable, sField);
    
    if(oCurrent){
        //  If it is currently loading we register as waiting
        if(oCurrent.hasOwnProperty("bLoading")){
            oCurrent.aWaiting.push({oEnv : oEnv, fHandler : fHandler});
        }else{
            //  Else we directly call the handling function
            fHandler.call(oEnv, oCurrent);
        }
    }else{
        //  Set tempolary object
        if(typeof(oMeta.oDDs[sTable]) !== "undefined"){
            if(oMeta.oDDs[sTable].oFields[sField]){
                oMeta.oDDs[sTable].oFields[sField].aDescriptionValues = { bLoading : true, aWaiting : [ { oEnv : oEnv, fHandler : fHandler } ] };
                
                //  Send request
                oCall = new vdf.ajax.JSONCall("MetaDataDescriptionValues", { sSessionKey : vdf.sys.cookie.get("vdfSessionKey"), sWebObject : this.sWebObject, "sField" : sTable + "." + sField});
                this.oPipe.send(oCall, 1, this.handleDescriptionValues, this);
            }else{
                throw new vdf.errors.Error(5138, "Unknown field", this, [ sField, sTable, "vdf.core.MetaData(loadDescriptionValues)" ]);
            }            
        }else{
            throw new vdf.errors.Error(5137, "Unknown table", this, [ sTable, "vdf.core.MetaData(loadDescriptionValues)" ]);
        }
    }
},


handleDescriptionValues : function(oEvent){
    var oMeta, tResponse, oLoading, iHandler;
    
    oMeta = this.getMetaData();
    tResponse = oEvent.oSource.getResponseValue("TAjaxMetaDescriptionValues");
    
    
    oLoading = oMeta.oDDs[tResponse.sTable].oFields[tResponse.sField].aDescriptionValues;
    oMeta.oDDs[tResponse.sTable].oFields[tResponse.sField].aDescriptionValues = tResponse.aValues;
    
    if(oLoading.hasOwnProperty("bLoading")){
        for(iHandler = 0; iHandler < oLoading.aWaiting.length; iHandler++){
            oLoading.aWaiting[iHandler].fHandler.call(oLoading.aWaiting[iHandler].oEnv, tResponse.aValues);
        }
    }
},


getGlobalProperty : function(sProp){
    return this.getMetaData()[sProp];
},


getDDProperty : function(sProp, sTable){
    var oMeta = this.getMetaData();
    
    if(typeof(oMeta.oDDs[sTable]) !== "undefined"){
        return oMeta.oDDs[sTable][sProp];
    }
    
    return null;
},


getFieldProperty : function(sProp, sTable, sField){
    var oMeta = this.getMetaData(), sResult = null;
    
    if(typeof(sField) == "undefined"){
        var aParts = sTable.replace("__", ".").split(".");
        sField = aParts[1];
        sTable = aParts[0];
    }
    
    if(typeof(oMeta.oDDs[sTable]) !== "undefined"){
        if(typeof(oMeta.oDDs[sTable].oFields[sField]) !== "undefined"){
            sResult = oMeta.oDDs[sTable].oFields[sField][sProp];
            
            if(typeof(sResult) == "undefined"){
                sResult = null;
            }
        }
    }
    
    return sResult;
},



getMetaData : function(){
    var oMeta = vdf.core.oMetaData[this.sWebObject];
    
    if(typeof(oMeta) !== "undefined"){
        return oMeta;
    }
    
    return null;
}

});




vdf.core.FormBase = function FormBase(eElement, oParentControl, bSkipInit){
    this.Control(eElement, oParentControl);
  
    
    this.sCssClass              = this.getVdfAttribute("sCssClass", "vdfform", false);
    
    
    this.sInitializer           = this.getVdfAttribute("sInitializer", null);
    
    
    this.bAutoFocusFirst        = this.getVdfAttribute("bAutoFocusFirst", true);
    
    
    this.bValidateOnSubmit      = this.getVdfAttribute("bValidateOnSubmit", true, false);
    
    //  EVENTS
    
    
    this.onInitialized          = new vdf.events.JSHandler();
    
    this.onEnter                = new vdf.events.JSHandler();
    

    
    //  @privates
    this.aDEOs                  = [];
    
    
    this.aChildren              = [];
    this.oControls              = {};
    
    //  Private properties
    this.oActiveField           = null;
    this.iInitStage             = 1;
    this.iInitFinishedStage     = 3;
    this.bIsForm                = true;
    this.eElement.oVdfControl   = this;
    
    
    
    //  Set classname
    vdf.sys.gui.addClass(this.eElement, this.sCssClass);
    
    if(this.bValidateOnSubmit){
        vdf.events.addDomListener("submit", this.eElement, this.onSubmitValidate, this);
    }
    
    if(!bSkipInit){
        //  Start the loading proces
        this.initStage();
    }
};

vdf.definePrototype("vdf.core.FormBase", "vdf.core.Control", {


initStageChildren : function(){
    //vdf.log("Form: Loading stage " + this.iInitStage + ": Child intialization");
   
    //  Init childs
    this.initChilds();
},


initStageFinalize : function(){
    //vdf.log("Form: Loading stage " + this.iInitStage + ": Calls initializers");
    this.callInitializers();
    
    if(this.oActiveField && this.bAutoFocusFirst){
        this.oActiveField.focus();
    }
},


initStage : function(){
    switch(this.iInitStage){
        case 1:
            //  wait for children
            break;
        case 2:
            this.initStageChildren();
            break;
        case this.iInitFinishedStage:
            this.initStageFinalize();
            break;
            
            
    }
},


init : function(){
    this.iInitStage++;
    this.initStage();
},


addDEO : function(oDeo){
    this.aDEOs.push(oDeo);
    oDeo.oForm = this;
    
    if(this.oActiveField === null && oDeo.bFocusable){
        this.oActiveField = oDeo;
    }
},


initChilds : function(){
    var iDEO;

    this.formInit();
    
    //  Init fields
    for(iDEO = 0; iDEO < this.aDEOs.length; iDEO++){
        this.aDEOs[iDEO].update();
        
        if(typeof(this.aDEOs[iDEO].initValidation) == "function"){
            this.aDEOs[iDEO].initValidation();
        }
    }
    
    //vdf.log("Finished state: " + this.iInitFinishedStage);
    
    //  Move on to the next stage
    this.iInitStage++;
    this.initStage();
    
},


childInitFinished : function(){
    this.iInitStage++;
    this.initStage();
},


callInitializers : function(){
    var fInitializer  = null;
    
    //  Throw the onInitialized event
    this.onInitialized.fire(this, null);
    
    if(typeof this.sInitializer === "string"){
        fInitializer = vdf.sys.ref.getNestedObjProperty(this.sInitializer);
        
        //  Call the function
        if(typeof fInitializer === "function"){
            fInitializer(this);
        }else{
            throw new vdf.errors.Error(5134, "Init method not found '{{0}}'", this, [ this.sInitializer ]);
        }
    }
},


// - - - - - - - - - - CENTRAL FUNCTIONALITY - - - - - - - - - - 


getMetaProperty : function(sProp){
    return this.getVdfAttribute(sProp, null);
},


getDEO : function(sName){
    var i;
    
    for(i = 0; i < this.aDEOs.length; i++){
        if((this.aDEOs[i].sName !== null && this.aDEOs[i].sName.toLowerCase() === sName.toLowerCase()) || (this.aDEOs[i].sDataBinding !== null && this.aDEOs[i].sDataBinding === sName.toLowerCase())){
            return this.aDEOs[i];
        }
    }
    
    return null;
},

// - - - - - - - - - - CONTAINER FUNCTIONALITY - - - - - - - - - - 


getControl : function(sName){
    if(typeof(this.oControls[sName.toLowerCase()]) !== "undefined"){
        return this.oControls[sName.toLowerCase()];
    }else{
        return null;
    }
},


addChild : function(oControl){
    this.aChildren.push(oControl);
},


formInit : function(){
    var iChild;
    
    for(iChild = 0; iChild < this.aChildren.length; iChild++){
        if(typeof(this.aChildren[iChild].formInit) === "function"){
            this.aChildren[iChild].formInit();
        }
    }
},


recalcDisplay : function(bDown){
    var iChild;

    if(bDown){
        for(iChild = 0; iChild < this.aChildren.length; iChild++){
            if(typeof this.aChildren[iChild].recalcDisplay === "function"){
                this.aChildren[iChild].recalcDisplay(bDown);
            }
        }
    }else{
        if(this.oParentControl !== null && typeof(this.oParentControl.recalcDisplay) === "function"){
            this.oParentControl.recalcDisplay(bDown);
        }
    }
},


waitForCalcDisplay : function(){
    var iChild, iWait = 0;
    
    for(iChild = 0; iChild < this.aChildren.length; iChild++){
        if(typeof(this.aChildren[iChild].waitForCalcDisplay) === "function"){
            iWait =  iWait + this.aChildren[iChild].waitForCalcDisplay();
        }
    }
    
    return iWait;
},

// - - - - - - - - - - VALIDATION FUNCTIONALITY - - - - - - - - - - 


validate : function(){
    var iResult = 0, iDeo, iError;
    
    for(iDeo = 0; iDeo < this.aDEOs.length; iDeo++){
        iError = this.aDEOs[iDeo].validate();
        
        if(iError > 0 && iResult === 0){
            iResult = iError;
        }
    }
    
    return iResult;
},


onSubmitValidate : function(oEvent){
    if(this.validate() > 0){
        oEvent.stop();
    }
},


destroy : function(){
    if(this.eElement){
        vdf.events.clearDomListeners(this.eElement);
    }
}

}); 




vdf.core.FormMeta = function FormMeta(eElement, oParentControl, bSkipInit){
    this.FormBase(eElement, oParentControl, true);
    
    
    this.sWebObject             = this.getVdfAttribute("sWebObject", null);
    
    this.sWebServiceUrl         = this.getVdfAttribute("sWebServiceUrl", "WebService.wso");
    
    this.sXmlNS                 = this.getVdfAttribute("sXmlNS", "http://tempuri.org/");
    
    this.oMetaData              = new vdf.core.MetaData(this.sWebObject, this.sWebServiceUrl, this.sXmlNS);
    

    
    //  @privates
    this.iInitFinishedStage     = 5;
    
	//	Check required properties
	if(!this.sWebObject){
		throw new vdf.errors.Error(5143, "sWebObject is required", this, [ "sWebObject", "FormMeta" ]);
	}
	
    if(!bSkipInit){
        //  Start the loading proces
        this.initStage();
    }
	
	
};

vdf.definePrototype("vdf.core.FormMeta", "vdf.core.FormBase", {

// - - - - - - - - - - INITIALIZATION - - - - - - - - - - -


initStageGlobalMetaFields : function(){
    //vdf.log("Form: Loading stage " + this.iInitStage + ": Global Meta Load & Field Scan");
    //  Load the global meta data
    this.oMetaData.loadGlobalData(this.onGlobalMetaLoaded, this);
    //  The fields add themself when they are created by the Initializer
},


initStageFieldMeta : function(){
    //vdf.log("Form: Loading stage " + this.iInitStage + ": Field Meta Load");
    
    //  Load field meta data
    this.loadFieldMeta();
},


initStage : function(){
    switch(this.iInitStage){
        case 1:
            this.initStageGlobalMetaFields();
            break;
        case 3:
            this.initStageFieldMeta();
            break;
        case 4:
            this.initStageChildren();
            break;
        case this.iInitFinishedStage:
            this.initStageFinalize();
            
            
    }
},


onGlobalMetaLoaded : function(){
    this.iInitStage++;
    this.initStage();
},


loadFieldMeta : function(){
    var aFields = [], iDEO;

    for(iDEO = 0; iDEO < this.aDEOs.length; iDEO++){
        if(this.aDEOs[iDEO].sDataBindingType == "D"){
            aFields.push(this.aDEOs[iDEO].sDataBinding);
        }
    }
    
    this.oMetaData.loadFieldData(aFields, this.onFieldMetaLoaded, this);
},


onFieldMetaLoaded : function(){
    this.iInitStage++;
    this.initStage();
},

// - - - - - - - - - - CENTRAL FUNCTIONALITY - - - - - - - - - - 


getMetaProperty : function(sProp){
    var sResult = this.getVdfAttribute(sProp, null);
    
    if(sResult === null){
        sResult = this.oMetaData.getGlobalProperty(sProp);
    }
    
    return sResult;
}

});





vdf.core.findForm = function findForm(eElement){
    //  Bubble up in the DOM searching for VDF controls
    while(eElement !== null && eElement !== document){
        if(typeof(eElement.oVdfControl) === "object"){
            if(eElement.oVdfControl.sControlType === "vdf.core.Form" || eElement.oVdfControl.sControlType === "vdf.core.FormMeta" || eElement.oVdfControl.sControlType === "vdf.core.FormBase"){
                return eElement.oVdfControl;
            }else if(eElement.oVdfControl.sControlType === "vdf.core.Toolbar" && eElement.oVdfControl.oForm !== null){
                return eElement.oVdfControl.oForm;
            }
        }

        eElement = eElement.parentNode;
    }

    return null;
};



vdf.core.Form = function Form(eElement, oParentControl){
    this.FormMeta(eElement, oParentControl, true);
    
    var sKey;
    
    
    
    this.oServerDD = null;
    
    this.sServerTable = null;
    
    
    this.bAutoClearDeoState     = this.getVdfAttribute("bAutoClearDeoState", true);
    
    this.bAutoFill              = this.getVdfAttribute("bAutoFill", true);
    
    this.bAttachKeyActions      = this.getVdfAttribute("bAttachKeyActions", true);
    
    
    this.onBeforeInitialFill    = new vdf.events.JSHandler();
    
    this.onAfterInitialFill     = new vdf.events.JSHandler();
    
    this.onBeforeDbCall         = new vdf.events.JSHandler();
    
    
    this.onAfterDbCall         = new vdf.events.JSHandler();
    
    //  @privates
    this.oDDs                   = {};
    this.oUserDataFields        = {};
    this.oActionKeys            = {};
	
    //  Copy settings
    for(sKey in vdf.settings.formKeys){
        if(typeof(vdf.settings.formKeys[sKey]) == "object"){
            this.oActionKeys[sKey] = vdf.settings.formKeys[sKey];
        }
    }
    
    this.iInitFinishedStage     = 6;
    
    //  Start the loading proces
    this.initStage();
};

vdf.definePrototype("vdf.core.Form", "vdf.core.FormMeta", {

// - - - - - - - - - - INITIALIZATION - - - - - - - - - - -


initStageFieldMetaDDO : function(){
    //vdf.log("Form: Loading stage " + this.iInitStage + ": Field Meta Load & DD Structure");
    
    //  Load field meta data
    this.loadFieldMeta();
    //  Build DD structure
    this.buildDDStructure();
},


initStageFinalize : function(){
    //vdf.log("Form: Loading stage " + this.iInitStage + ": Calls initializers & do autofill");
    this.callInitializers();
    
    //  Do initial fill
    if(this.bAutoFill){
        this.oServerDD.initialFill();
    }
    
    if(this.oActiveField && this.bAutoFocusFirst){
        this.oActiveField.focus();
    }
},


initStage : function(){
    switch(this.iInitStage){
        case 1:
            this.initStageGlobalMetaFields();
            break;
        case 3:
            this.initStageFieldMetaDDO();
            break;
        case 5:
            this.initStageChildren();
            break;
        case this.iInitFinishedStage:
            this.initStageFinalize();
            
            
    }
},




buildDDStructure : function(){
    var tMeta = this.oMetaData.getMetaData(), iDD, iDEO, sServerTable;
    
    //  Create DDs
    for(iDD = 0; iDD < tMeta.aDDs.length; iDD++){
        this.oDDs[tMeta.aDDs[iDD].sName] = new vdf.core.ClientDataDictionary(tMeta.aDDs[iDD].sName, this);  
    }
    
    //  Initialize DD structure
    for(iDD = 0; iDD < tMeta.aDDs.length; iDD++){
        this.oDDs[tMeta.aDDs[iDD].sName].buildStructure(tMeta.aDDs[iDD]);
    }
    
    //  Find the ServerDD
    sServerTable = this.getVdfAttribute("sServerTable", null, true);
    if(sServerTable !== null){
        this.oServerDD = this.oDDs[sServerTable.toLowerCase()];

        if(!this.oServerDD){
			throw new vdf.errors.Error(5137, "Unknown table '{{0}}'", this, [sServerTable, "vdf.core.Form[sServerTable]"]);
        }
    }
    if(this.oServerDD === null && this.aDEOs.length > 0){
        throw new vdf.errors.Error(5144, "Form with fields must have a server DD!", this);
    }
    
    
    //  Initialize data bindings
    for(iDEO = 0; iDEO < this.aDEOs.length; iDEO++){
        this.aDEOs[iDEO].bindDD();
    }    
    
    //  Move to next step / stage
    this.iInitStage++;
    this.initStage();
},



// - - - - - - - - - - CENTRAL FUNCTIONALITY - - - - - - - - - - 


getDD : function(sName){
    sName = sName.toLowerCase();
    if(typeof(this.oDDs[sName]) === "object" && this.oDDs[sName].bIsDD){
        return this.oDDs[sName];
    }
    return null;
},


getBufferValue : function(sBinding){
    var aParts, sTable, sField, oDD, oField, sDD, sValue;

    sBinding = sBinding.toLowerCase().replace("__", ".");
    if(sBinding.replace("__", ".").match(/^[a-zA-Z][a-zA-Z0-9_@#]*\.[a-zA-Z][a-zA-Z0-9_@#]*$/)){
        //  It is a regular database field
        
        //  Split into table and field name
        aParts = sBinding.split(".");
        sTable = aParts[0];
        sField = aParts[1];
        
        //  Find the DD for this table
        oDD = this.oDDs[sTable];
        if(typeof(oDD) === "object" && oDD.bIsDD){
            return oDD.getFieldValue(sTable, sField);
        }
    }else if(sBinding.match(/^[eE]\:[a-zA-Z][a-zA-Z0-9_@#]*$/)){
        //  It is an expression field
        
        //  Cut of the e: part
        sBinding = sBinding.substr(2);
        
        //  We go through the DD's untill we find the value (we simply don't know which DD to use)
        for(sDD in this.oDDs){
            if(this.oDDs.hasOwnProperty(sDD)){
                sValue = this.oDDs[sDD].getExpressionValue(sBinding);
                
                if(sValue !== null){
                    return sValue;
                }
            }
        }
    }else{
        //  User data fields are not in buffer, but for the ease of use we also return this values
        oField = this.oUserDataFields[sBinding];
        if(typeof(oField) === "object" && oField.bIsField){
            return oField.getValue();
        }        
    }
       
    return null;
},


setBufferValue : function(sDataBinding, sValue){
    var aParts, sTable, sField, oDD;

    sDataBinding = sDataBinding.toLowerCase().replace("__", ".");
    
    aParts = sDataBinding.split(".");
    if(aParts.length >= 2){
        sTable = aParts[0];
        sField = aParts[1];
        
        //  Search DD
        oDD = this.oDDs[sTable];
        if(typeof(oDD) === "object" && oDD.bIsDD){
            oDD.setFieldValue(sTable, sField, sValue, false);
        }else{
            throw new vdf.errors.Error(5138, "Table {{0}} not found!", this, [ sTable, sField, "vdf.core.Form(setBufferValue)" ]);
        }
    }else{
        //  User data fields are not in buffer, but for the ease of use we also set this values
        if(this.oUserDataFields.hasOwnProperty(sDataBinding)){
            this.oUserDataFields[sDataBinding].setValue(sValue);
        }else{
            throw new vdf.errors.Error(5145, "Unknown data binding {{0}}", this, [ sDataBinding, "vdf.core.Form(setBufferValue)" ]);
        }
    }
},


containsDD : function(sTableName){
    return (typeof(this.oDDs[sTableName]) === "object" && this.oDDs[sTableName].bIsDD);
},

// - - - - - - - - - - USER DATA - - - - - - - - - -


registerUserDataField : function(oField){
    this.oUserDataFields[oField.sDataBinding.toLowerCase()] = oField;
},


getUserData : function(){
    var sField, tField, aResult = [];
    
    for(sField in this.oUserDataFields){
        if(this.oUserDataFields[sField].bIsField){
            tField = new vdf.dataStructs.TAjaxUserData();
            tField.sName = this.oUserDataFields[sField].sDataBinding;
            tField.sValue = this.oUserDataFields[sField].getValue();
            aResult.push(tField);
        }
    }
    
    return aResult;
},


setUserData : function(aUserData){
    var iField, tField;
    
    for(iField = 0; iField < aUserData.length; iField++){
        tField = aUserData[iField];
        
        if(this.oUserDataFields.hasOwnProperty(tField.sName.toLowerCase())){
            this.oUserDataFields[tField.sName.toLowerCase()].setValue(tField.sValue);
        }
    }
},

// - - - - - - - - - - (DATA BOUND) VDFCALL - - - - - - - - - - -


vdfCall : function(sMethod, asParams, fHandler, oEnv){
    var oCall = new vdf.ajax.VdfCall(this.sWebObject,  sMethod, asParams, this.sWebServiceUrl, this.sXmlNS);
    
    if(typeof(fHandler) == "function"){
        
        oCall.onFinished.addListener(function(oEvent){
            //  Gather event details
            var oEventInfo = { 
                bError : (oEvent.oSource.aErrors.length > 0), 
                iErrorNr : (oEvent.oSource.aErrors.length > 0 ? oEvent.oSource.aErrors[0].iNumber : 0), 
                sReturnValue : oEvent.sReturnValue,
                sMethod : sMethod,
                asParams : asParams
            };
            
            //  Call the handler
            fHandler.call(oEnv || null, new vdf.events.JSEvent(this, oEventInfo));
        }, this);
    }
    
    oCall.send(true);
},
    
    

dbCall : function(sMethod, asParams, fHandler, oEnv){
    var tRequestSet, tRow, oAction;
    
    //  TODO:   Add a "has record" check here
    if(this.onBeforeDbCall.fire(this, { sMethod : sMethod, asParams : asParams })){
        oAction = new vdf.core.Action("dbcall", this, this, this.oServerDD, true);
        
        //  Generate request objects & collect fields
        tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
        tRequestSet.sName = "DbCall";
        tRequestSet.sRequestType = "dbcall";
        tRequestSet.iMaxRows = 1;
        tRequestSet.bReturnCurrent = false;
        
        tRequestSet.sMethod = sMethod;
        tRequestSet.asParams = asParams;
        
        tRow = new vdf.dataStructs.TAjaxSnapShot();
        tRequestSet.aRows.push(tRow);
        
        //  Visit DD's to lock and gather field data
        this.oServerDD.crawlAll(function(oDD){
            var iDeo;

            oDD.onUpdate.fire(oDD, { sAction : "dbcall", oAction : oAction } );
            
            //  Lock DD
            oAction.lock(oDD);
            
            //  Visit DEO for update and lock
            for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                vdf.errors.clearByField(oDD.aDEO[iDeo]);
                oDD.aDEO[iDeo].update();
                oAction.lock(oDD.aDEO[iDeo]);
            }
            
            //  Create snapshot
            tRow.aDDs.push(oDD.createSnapshot());
        });
        
        oAction.addRequestSet(tRequestSet);

        oAction.onResponse.addListener(function(oEvent){
            var oEventInfo, tResponseSet = (oEvent.tResponseData && oEvent.tResponseData.aDataSets.length > 0 ?  oEvent.tResponseData.aDataSets[0] : null);
            //  Gather event details
            oEventInfo = { 
                bError : oEvent.bError, 
                iErrorNr : oEvent.iErrorNr, 
                tResponseSet : tResponseSet,
                sReturnValue : tResponseSet && tResponseSet.sReturnValue,
                sMethod : sMethod,
                asParams : asParams
            };
            
            //  Load the new snapshot into the buffer
            if(tResponseSet.aRows.length > 0){
                this.oServerDD.loadSnapshot(oEvent.oSource, tResponseSet.aRows[0]);
            }
            
            //  Unlock so the lock's won't block actions done in the onAfterDelete
            oAction.unlock();
            
            //  Call the handler function (if defined)
            if(typeof(fHandler) == "function"){
                fHandler.call(oEnv || null, new vdf.events.JSEvent(this, oEventInfo));
            }
            
            //  Fire the onAfterDbCall event
            this.onAfterDbCall.fire(this, oEventInfo);
        }, this);
        
        //  Send request
        oAction.send();
    }
},


// - - - - - - - - - - ACTION FORWARDING - - - - - - - - - - 


doFind : function(sFindMode, oField){
    try{
        if(typeof oField === "object" && oField.bIsField){
            return oField.doFind(sFindMode);
        }else{
            if(typeof this.oActiveField === "object" && this.oActiveField.bIsField){
                return this.oActiveField.doFind(sFindMode);
            }else{
                throw new vdf.errors.Error(5146, "No active field to perform operation", this);
            }
        }
    }catch (oErr){
        vdf.errors.handle(oErr);
    }
    
    return false;
},


doFindByRowId : function(sTable, sRowId){
    try{
        sTable = sTable.toLowerCase();
        if(this.oDDs[sTable].bIsDD){
            return this.oDDs[sTable].doFindByRowId(sRowId);
        }    
    }catch (oErr){
        vdf.errors.handle(oErr);
    }
    
    return false;
},


doSave : function(sTable){
    try{
        if(typeof(sTable) === "string"){
            sTable = sTable.toLowerCase();
            if(this.oDDs[sTable].bIsDD){
                return this.oDDs[sTable].doSave();
            }else{
				throw new vdf.errors.Error(5137, "Table unknown", this, [sTable, "vdf.core.Form(doSave)"]);
            } 
        }else{
            if(typeof this.oActiveField === "object" && this.oActiveField.bIsField){
                return this.oActiveField.doSave();
            }else{
                return this.oServerDD.doSave();
            }
        }
    }catch (oErr){
        vdf.errors.handle(oErr);
    }
    
    return false;
},


doClear : function(sTable){
    try{
        if(typeof(sTable) === "string"){
            sTable = sTable.toLowerCase();
            if(this.oDDs[sTable].bIsDD){
                return this.oDDs[sTable].doClear();
            }else{
                throw new vdf.errors.Error(5137, "Table unknown", this, [sTable, "vdf.core.Form(doClear)"]);
            }
        }else{
            if(typeof this.oActiveField === "object" && this.oActiveField.bIsField){
                return this.oActiveField.doClear();
            }else{
                return this.oServerDD.doClear();
            }
        }
    }catch (oErr){
        vdf.errors.handle(oErr);
    }

    return false;
},


doClearAll : function(sTable){
    try{
        if(typeof(sTable) === "string"){
            sTable = sTable.toLowerCase();
            if(this.oDDs[sTable].bIsDD){
                return this.oDDs[sTable].doClearAll();
            }else{
				throw new vdf.errors.Error(5137, "Table unknown", this, [sTable, "vdf.core.Form(doClearAll)"]);
            }
        }else{
            if(typeof this.oActiveField === "object" && this.oActiveField.bIsField){
                return this.oActiveField.doClearAll();
            }else{
                return this.oServerDD.doClearAll();
            }
        }
    }catch (oErr){
        vdf.errors.handle(oErr);
    }

    return false;
},


doDelete : function(sTable){
    try{
        if(typeof(sTable) === "string"){
            sTable = sTable.toLowerCase();
            if(this.oDDs[sTable].bIsDD){
                return this.oDDs[sTable].doDelete();
            }else{
				throw new vdf.errors.Error(5137, "Table unknown", this, [sTable, "vdf.core.Form(doDelete)"]);
            }
        }else{
            if(typeof this.oActiveField === "object" && this.oActiveField.bIsField){
                return this.oActiveField.doDelete();
            }else{
                return this.oServerDD.doDelete();
            }
        }
    }catch (oErr){
        vdf.errors.handle(oErr);
    }
    
    return false;
}


});





vdf.core.TextField = function TextField(eElement, oParentControl){
    this.Field(eElement, oParentControl);
    
    //  Validation properties (are initialized later if meta data is loaded)
    
    this.sDecimalSeparator = null;
    
    this.sThousandsSeparator = null;
    
    this.sDateSeparator = null;
    
    this.sDateFormat = null;
    
    this.sCurrencySymbol = null;
    
    
    this.bCapslock = null;
    
    this.bAutoFind = null;
    
    this.bAutoFindGE = null;
    
    this.bZeroSuppress = null;
    
    this.iDataLength = null;
    
    this.iPrecision = null;
    
    
    this.sMaskType = null;
    
    this.sMask = null;
    
    
    this.bMaskChars = this.getVdfAttribute("bMaskChars", true, true);

    
};

vdf.definePrototype("vdf.core.TextField", "vdf.core.Field", {


formInit : function(){
    //  Load validation properties
    //this.sDecimalSeparator = this.getVdfAttribute("sDecimalSeparator", (this.oForm && this.oForm.oMetaData ? this.oForm.oMetaData.getGlobalProperty("sDecimalSeparator") : ","), true);
    this.sDecimalSeparator = this.getGlobalMetaProperty("sDecimalSeparator", ".", true);
    this.sThousandsSeparator = this.getGlobalMetaProperty("sThousandsSeparator", ",", true);
    this.sDateSeparator = this.getGlobalMetaProperty("sDateSeparator", "-", true);
    this.sDateFormat = this.getGlobalMetaProperty("sDateFormat", "yyyy-mm-dd", true);
    this.sCurrencySymbol = this.getGlobalMetaProperty("sCurrencySymbol", "$", true);
    
    
    
    this.bCapslock = this.getMetaProperty("bCapslock");
    this.bAutoFind = this.getMetaProperty("bAutoFind");
    this.bAutoFindGE = this.getMetaProperty("bAutoFindGE");
    this.bZeroSuppress = this.getMetaProperty("bZeroSuppress");
    this.bNoPut = this.getMetaProperty("bNoPut");
    this.iDataLength = this.getMetaProperty("iDataLength");
    this.iPrecision = this.getMetaProperty("iPrecision");    
    
    this.sMaskType = this.getMetaProperty("sMaskType");
    this.sMask = this.getMetaProperty("sMask");

    
    this.Field.prototype.formInit.call(this);
    
    
    this.setCSSClass(this.getCSSClass() + " " + (this.sDataType ? this.sDataType : "ascii") + "_data");
},
    
//  - - - - -   V A L I D A T I O N   - - - - - 


initValidation : function(bAttachListeners){
    var iChar, sMask;
    
    if(typeof(bAttachListeners) === "undefined"){
        bAttachListeners = true;
    }
    
    //  Forward call
    this.Field.prototype.initValidation.call(this);
    

    
    //  Auto find
    if(this.bAutoFindGE && bAttachListeners){
        this.addKeyListener(this.onAutoFindGE, this);
    }else if(this.bAutoFind && bAttachListeners){
        this.addKeyListener(this.onAutoFind, this);
    }
    
    //  Data type filters
    if(this.sDataType === "bcd"){
        if(bAttachListeners){
            this.addDomListener("keypress", this.filterNumeric, this);
        }
    }else if(this.sDataType === "date"){
        if(bAttachListeners){
            this.addDomListener("keypress", this.filterDate, this);
            this.addDomListener("blur", this.onBlurDate, this);
        }
    }else{
        //  Maximum length (for text fields without a mask!)
        if(this.iDataLength && this.sMask === ""){
            this.eElement.maxLength = this.iDataLength;
        }
        
        //  Attaches the capslock transformations
        if(this.bCapslock){
            if(vdf.sys.isIE && bAttachListeners){
                this.addDomListener("keypress", this.adjustCapslockIE, this);
            }else{
                this.eElement.style.textTransform = "uppercase";
            }
        }
    }

    //  Zero suppress is implemented in the mask functionallity, if no mask is used the zero is suppressed manually.
    if(this.sDataType === "bcd" && (this.bZeroSuppress || this.sMaskType == "num" || this.sMaskType === "cur")){
        this.sMaskOrigValue = this.eElement.value;
        this.bMaskDisplay = true;
        if(bAttachListeners){
            this.addDomListener("focus", this.onFocusNumMask, this);
            this.addDomListener("blur", this.onBlurNumMask, this);
        }
        
        this.eElement.value = this.applyNumMask(this.eElement.value);
    }

    //  MASK
    if(this.sMask !== ""){
        sMask = this.sMask;
        if(this.sMaskType === "win" || this.sMaskType === ""){   // Mask Window or None
            this.aMaskChars = [];
            
            //  Fill character information array for quick access (also take in account the "\" exception) which is used only by the filterWinMask
            for(iChar = 0; iChar < sMask.length; iChar++){
                var sChar = sMask.charAt(iChar);
                
                if(sChar === "\\" && iChar + 1 < this.sMask.length && (sMask.charAt(iChar + 1) === "#" || sMask.charAt(iChar + 1) === "@" || sMask.charAt(iChar + 1) === "!" || sMask.charAt(iChar + 1) === "*")){
                    iChar++;
                    this.aMaskChars.push({ bEnter : false, bNumeric : false, bAlpha : false, bPunct : false, sChar : sMask.charAt(iChar + 1) });
                }else{
                    this.aMaskChars.push({
                        bEnter : (sChar === "#" || sChar === "@" || sChar === "!" || sChar === "*"),
                        bNumeric : (sChar === "#" || sChar === "*"),
                        bAlpha : (sChar === "@" || sChar === "*"),
                        bPunct : (sChar === "!" || sChar === "*"),
                        sChar : sChar 
                    });
                }
            }
            
            //  Attach listeners
            if(bAttachListeners){
                this.addDomListener("keypress", this.filterWinMask, this);
                
                this.addDomListener("keyup", this.correctWinMask, this);
                this.addDomListener("blur", this.correctWinMask, this);
                this.addDomListener("cut", this.onCutPasteWinMask, this);
                this.addDomListener("paste", this.onCutPasteWinMask, this);
            }
        }else if(this.sMaskType === "dat" || this.sMaskType === "dt"){
            this.sMaskOrigValue = this.eElement.value;
            this.bMaskDisplay = true;
            
            if(bAttachListeners){
                this.addDomListener("focus", this.onFocusDateMask, this);
                this.addDomListener("blur", this.onBlurDateMask, this);
            }
        }
    }
},

//  WINDOWS MASK


applyWinMask : function(sValue){
    var iChar = 0, iValChar = 0, aResult = [], bFound, sMask = this.sMask, sChar;
    
    if(sValue === ""){
        return "";
    }
    
    while(iChar < sMask.length){
        sChar = sMask.charAt(iChar);
        
        if(sChar === "\\" && sMask.length > (iChar + 1)){
            aResult.push(sMask.charAt(iChar + 1));
        }else{
            if(sChar === "#" || sChar === "@" || sChar === "!" || sChar === "*"){
                bFound = false;
                while(iValChar < sValue.length && !bFound){
                    if(this.acceptWinChar(sValue.charAt(iValChar), sChar)){
                        aResult.push(sValue.charAt(iValChar));
                        bFound = true;
                    }
                    iValChar++;
                }
                if(!bFound){
                    break;
                }
            }else{
                //  Append mask display character
                aResult.push((this.bMaskChars ? sChar : " "));
            }
        }
        iChar++;
    }
    
    return aResult.join("");
},


clearWinMask : function(sValue){
    var iChar = 0, sResult = "";
    
    while(iChar < sValue.length && iChar < this.aMaskChars.length){
        if(this.aMaskChars[iChar].bEnter || sValue.charAt(iChar) !== (this.bMaskChars ? this.aMaskChars[iChar].sChar : " ")){
            sResult += sValue.charAt(iChar);
        }
        
        iChar++;
    }
    
    return sResult;
},


acceptWinChar : function(sValChar, sChar){
    return ((sChar === "#" && sValChar.match(/[0-9]/)) ||
        (sChar === "@" && sValChar.match(/[a-zA-Z]/)) ||
        (sChar === "!" && sValChar.match(/[^a-zA-Z0-9]/)) ||
        sChar === "*");
},


filterWinMask : function(e){
    var iPos, iNewPos, sChar;
    
    if(!e.isSpecialKey()){
        iPos = vdf.sys.dom.getCaretPosition(this.eElement);
        sChar = String.fromCharCode(e.getCharCode());
        
        //  Skip no enter characters (add them if they aren't already there)
        iNewPos = iPos;
        while(iNewPos < this.aMaskChars.length && !this.aMaskChars[iNewPos].bEnter){
            if(this.eElement.value.length <= iNewPos){
                this.eElement.value += (this.bMaskBackground ? this.aMaskChars[iNewPos].sChar : " ");
            }
            iNewPos++;
        }
        
        //  Set the new caret position if it is moved
        if(iPos !== iNewPos && iNewPos < this.aMaskChars.length){
            vdf.sys.dom.setCaretPosition(this.eElement, iNewPos);
            iPos = iNewPos;
        }
        
        //  Check if character allowed by mask
        if(iPos >= this.aMaskChars.length || !this.acceptWinChar(sChar, this.aMaskChars[iPos].sChar)){
            e.stop();
        }
    }
},


correctWinMask : function(e){
    var iPos, sNewValue;
    
    //  Calculate the correct value
    sNewValue = this.applyWinMask(this.clearWinMask(this.eElement.value));
    
    //  If the correct value is different than the current value update the value (and try to preserve the caret position)
    if(sNewValue !== this.eElement.value){
        iPos = vdf.sys.dom.getCaretPosition(this.eElement);
        this.eElement.value = sNewValue;
        vdf.sys.dom.setCaretPosition(this.eElement, iPos);
    }
},


onCutPasteWinMask : function(e){
    var oField = this;
    
    setTimeout(function(){
        oField.correctWinMask();
    }, 50);
},

//  DATE / DATE TIME


applyDateMask : function(sValue){
    var dDate = this.stringToDate(sValue);
    
    if(dDate === null){
        return "";
    }

    return vdf.sys.data.applyDateMask(dDate, this.sMask, this.sDateSeparator);
},


onFocusDateMask : function(e){
    var bSelect = false;

    this.bMaskDisplay = false;
    if(this.eElement.value !== this.sMaskOrigValue){
        bSelect = (this.eElement.value.length > 0 && vdf.sys.dom.getSelectionLength(this.eElement) > 0);
    
        this.eElement.value = this.sMaskOrigValue;
        
        vdf.sys.dom.focus(this.eElement, bSelect);
    }
},


onBlurDateMask : function(e){
    this.sMaskOrigValue = this.eElement.value;
    this.eElement.value = this.applyDateMask(this.eElement.value);
    this.bMaskDisplay = true;
},


filterDate : function(e){
    var sChar, iCarret, sNumChar, aFormats, aValues, iCur, iStartPos, sCur;

    if(!e.isSpecialKey()){
        sChar = String.fromCharCode(e.getCharCode());
        iCarret = vdf.sys.dom.getCaretPosition(this.eElement);
        sNumChar = "0123456789";
        
        //  Is character allowed?
        if(sNumChar.indexOf(sChar) !== -1 || sChar === this.sDateSeparator){
            //  Make parts arrays
            aFormats = this.sDateFormat.toLowerCase().split(this.sDateSeparator);
            aValues = this.eElement.value.split(this.sDateSeparator);
            
            //  Loop through parts
            iCur = 0; 
            iStartPos = 0;
            while(iCur < aValues.length && iCur < aFormats.length){
                
                //  Determine if carret is inside part
                if(iCarret - iStartPos >= 0 && (iCur + 1 === aValues.length ||  iCarret - iStartPos <= aValues[iCur].length)){
                    sCur = aValues[iCur];
                    
                    if(sChar === this.sDateSeparator){
                        //  Adding a date separator must make valid part before
                        if(iCarret - iStartPos > (aFormats[iCur] === "yyyy" ? 4 : 2) || iCarret - iStartPos <= 0){
                            e.stop();
                            return;
                        }else if(aValues.length >= aFormats.length || sCur.length - (iCarret - iStartPos) > (aFormats[iCur + 1] === "yyyy" ? 4 : 2)){ // There must also be space for a part after
                            e.stop();
                            return;
                        }
                    }else{
                        if(sCur.length >= (aFormats[iCur] === "yyyy" ? 4 : 2)){
                            if(iCur + 1 === aValues.length && aFormats.length > iCur + 1 && sCur.length - (iCarret - iStartPos) < (aFormats[iCur + 1] === "yyyy" ? 4 : 2)){
                                this.eElement.value = this.eElement.value.substring(0, iCarret) + this.sDateSeparator + this.eElement.value.substring(iCarret);
                                vdf.sys.dom.setCaretPosition(this.eElement, iCarret + 1);
                                return;
                            }else{
                                e.stop();
                                return;
                            }
                        }
                    }
                }
                iStartPos += this.sDateSeparator.length + aValues[iCur].length;
                iCur++;
                
            }
        }else{
            e.stop();
        }
        
    }
},


onBlurDate : function(e){
    var dDate = this.stringToDate(this.eElement.value);
    
    if(dDate === null){
        this.eElement.value = "";
    }else{
        this.eElement.value = this.dateToString(dDate);
    }
},

//  CURRENCY / NUMERIC


applyNumMask : function(sValue){
    var nValue, aParts, aResult = [], sChar, bEscape, iChar, iNumChar, iCount, sBefore, sDecimals, sMaskBefore, sMaskDecimals = null, sMask = this.sMask; 
    
    if(sValue === ""){
        return "";
    }
    
    this.sMaskOrigValue = sValue;
    
    //  Parse into number
    nValue = this.stringToNum(sValue);
    if(isNaN(nValue)){ nValue = 0.0; }
    
    //  Zero suppress
    if(nValue === 0.0 && this.bZeroSuppress){
        return "";
    }
    
    if(!sMask){
        return sValue;
    }
    
    //  Determine which mask to use :D
    aParts = sMask.split(";");
    if(nValue < 0.0){
        if(aParts.length > 1){
            sMask = aParts[1];
        }else{
            sMask = "-" + aParts[0];
        }
    }else{
        sMask = aParts[0];
    }

    //  Split into before and and after decimal separator
    aParts = sMask.split(".");
    sMaskBefore = aParts[0];
    if(aParts.length > 1){
        sMaskDecimals = aParts[1];
    }

    
    //  Pre process mask
    var iMaskBefore = 0;
    var iMaskDecimals = 0;
    var bThousands = false;
    var bBefore = true;
    for(iChar = 0; iChar < sMask.length; iChar++){
        switch(sMask.charAt(iChar)){
            case "\\":
                iChar++;
                break;
            case "#":
            case "0":
                if(bBefore){
                    if(iMaskBefore >= 0){
                        iMaskBefore++;
                    }
                }else{
                    if(iMaskDecimals >= 0){
                        iMaskDecimals++;
                    }
                }
                break;
            case "*":
                if(bBefore){
                    iMaskBefore = -1;
                }else{
                    iMaskDecimals = -1;
                }
                break;
            case ",":
                bThousands = true;
                break;
            case ".":
                bBefore = false;
        }
    }
    
    //  Convert number into string with number before and numbers after
    if(iMaskDecimals >= 0){
        nValue = nValue.toFixed(iMaskDecimals);
    }
    sValue = (nValue === 0.0 ? "" : String(nValue));
    aParts = sValue.split(".");
    sBefore = aParts[0];
    if(aParts.length > 1){
        sDecimals = aParts[1];
    }else{
        sDecimals = "";
    }
    if(sBefore.charAt(0) === "-"){
        sBefore = sBefore.substr(1);
    }
    
    //  BEFORE DECIMAL SEPARATOR
    iChar = sMaskBefore.length - 1;
    iNumChar = sBefore.length - 1;
    iCount = 0;
    while(iChar >= 0){
        sChar = sMaskBefore.charAt(iChar);
        bEscape = (iChar > 0 && sMaskBefore.charAt(iChar - 1) === "\\");
        
        if(!bEscape && (sChar === "#" || sChar === "*" || sChar === "0")){
            while(iNumChar >= 0 || sChar === "0"){
                //  Append thousands separator if needed
                if(iCount >= 3){
                    iCount = 0;
                    if(bThousands){
                        aResult.unshift(this.sThousandsSeparator);
                    }
                }
                
                //  Append number
                aResult.unshift((iNumChar >= 0 ? sBefore.charAt(iNumChar) : "0"));
                iNumChar--;
                iCount++;
                
                //  Break out for non repeative characters
                if(sChar === "#" || sChar === "0"){
                    break;
                }
            }
        }else{
            if(sChar === "$" && !bEscape){
                sChar = this.sCurrencySymbol.replace("&euro;", String.fromCharCode(0x20ac)).replace("&#322", String.fromCharCode(0x0142)); // Replace euro and polish html with polish sign..
            }
            if((sChar !== "," && sChar !== "\\") || bEscape){
                aResult.unshift(sChar);
            }
        }
        iChar--;
    }
    
    //  AFTER DECIMAL SEPARATOR
    if(sMaskDecimals !== null){
        aResult.push(this.sDecimalSeparator);
        
        iNumChar = 0;
        for(iChar = 0; iChar < sMaskDecimals.length; iChar++){
            sChar = sMaskDecimals.charAt(iChar);
            bEscape = (iChar > 0 && sMaskBefore.charAt(iChar - 1) === "\\");
            
           
            if(!bEscape && (sChar === "#" || sChar === "*" || sChar === "0")){
                while(iNumChar < sDecimals.length || sChar === "0"){
                    //  Append number
                    aResult.push((iNumChar >= 0 ? sDecimals.charAt(iNumChar) : "0"));
                    iNumChar++;
                    
                    //  Break out for non repeative characters
                    if(sChar === "#" || sChar === "0"){
                        break;
                    }
                }
            }else{
                if(sChar === "$" && !bEscape){
                    sChar = this.sCurrencySymbol;
                }
                if(sChar !== "\\" || bEscape){
                    aResult.push(sChar);
                }
            }
        }
    }
    
    return aResult.join("");
},


onFocusNumMask : function(e){
    this.bMaskDisplay = false;
    this.eElement.value = this.sMaskOrigValue;
    
    try{
        this.eElement.select();
    }catch(oError){
    
    }
},


onBlurNumMask : function(e){
    this.sMaskOrigValue = this.eElement.value;
    this.eElement.value =this.applyNumMask(this.eElement.value);
    this.bMaskDisplay = true;
},


filterNumeric : function(e){
    var sValidChars, sChar, iSeparator, iBefore, iDecimals, iMaxBefore, iPos, sValue, iSel;
        
    if(!e.isSpecialKey()){
        sChar = String.fromCharCode(e.getCharCode());
        iPos = vdf.sys.dom.getCaretPosition(this.eElement);
        iSel = vdf.sys.dom.getSelectionLength(this.eElement);
        sValue = this.eElement.value;
        sValidChars = "0123456789";
        
        if(sChar === "-"){
            //  Only allow "-" at the first position
            if(iPos === 0){ 
                //  When at the first position but a caret is already there we allow the user
                if(sValue.indexOf("-") !== -1){
                    vdf.sys.dom.setCaretPosition(this.eElement, 1);
                    e.stop();
                }
            }else{
                e.stop();
            }
        }else if(sChar === this.sDecimalSeparator){
            iSeparator = sValue.indexOf(this.sDecimalSeparator);
            
            if(iPos === iSeparator && iSel === 0){ // If we are at the decimal separator typing a decimal separator we move the caret one position
                vdf.sys.dom.setCaretPosition(this.eElement, iPos + 1);
                e.stop();
            }else if(iSeparator !== -1 && (iSeparator < iPos || iSeparator > (iPos + iSel))){ //    If there is a separator it must be selected
                e.stop();
            }else if(sValue.indexOf("-") >= iPos && sValue.indexOf("-") >= iPos + iSel){ //  Make sure we don't insert before the "-"
                e.stop();
            }else if(sValue.length - iSel - iPos > this.iPrecision){   //  Make sure we don't get to may decimals
                e.stop();
            }else if(this.iPrecision <= 0){ // Are decimals actually allowed?
                e.stop();
            }
        }else if(sValidChars.indexOf(sChar) !== -1){
            //  When we are before the the "-" we move one character forward
            if(iPos === 0 && sValue.indexOf("-") !== -1 && iSel === 0){
                iPos++;
                vdf.sys.dom.setCaretPosition(this.eElement, iPos);
            }
            
            iMaxBefore = this.iDataLength - this.iPrecision;
            
            if(iMaxBefore >= 0 && this.iPrecision >= 0){
                //  Determine separator, numbers before and decimals
                iSeparator = sValue.indexOf(this.sDecimalSeparator);
                iBefore = (iSeparator === -1 ? sValue.length : iSeparator) - (sValue.indexOf("-") === -1 ? 0 : 1);
                iDecimals = (iSeparator === -1 ? 0 : sValue.length - iSeparator - 1);
                
                
                if(iPos <= iSeparator || iSeparator === -1){
                    //  Don't allow to many numbers before (add / move to after decimal separator if we are there and there is room after)
                    if(iBefore >= iMaxBefore){
                        if(iDecimals < this.iPrecision && iSeparator !== -1 && iPos === iSeparator){
                            iPos++;
                            vdf.sys.dom.setCaretPosition(this.eElement, iPos);
                        }else if(iDecimals < this.iPrecision && iSeparator === -1 && iPos === sValue.length){
                            this.eElement.value = sValue + this.sDecimalSeparator;
                        }else{
                            e.stop();
                        }
                    }
                }else if(iDecimals >= this.iPrecision){ //  Don't allow to may decimals!
                    e.stop();
                }
            }
        }else{
            e.stop();
        }
    }
},


//  GLOBAL


adjustCapslockIE : function(e){
    //  For IE we can write to the keyCode and so uppercase the character immediately
    e.e.keyCode = String.fromCharCode(e.getCharCode()).toUpperCase().charCodeAt(0);
},


onAutoFind : function(oEvent){
    var oAction;

    if(oEvent.getKeyCode() == 9 && !oEvent.getShiftKey()){
        if(this.oServerDD && this.sDataBindingType === "D"){
            if(!this.oForm.getDD(this.sTable).hasRecord() || this.getChangedState() || this.isChanged()){
                oAction = new vdf.core.Action("find", this.oForm, this, this.oServerDD, false);
                oAction.onFinished.addListener(this.onAfterAutoFind, this);
                this.oServerDD.doFind(vdf.EQ, this, oAction);
            }
        }
    }
},


onAutoFindGE : function(oEvent){
    var oAction;
    
    if(oEvent.getKeyCode() == 9 && !oEvent.getShiftKey()){
        if(this.oServerDD && this.sDataBindingType === "D"){
            if(!this.oForm.getDD(this.sTable).hasRecord() || this.getChangedState() || this.isChanged()){
                oAction = new vdf.core.Action("find", this.oForm, this, this.oServerDD, false);
                oAction.onFinished.addListener(this.onAfterAutoFind, this);
                this.oServerDD.doFind(vdf.GE, this, oAction);
            }
        }
    }
},


onAfterAutoFind : function(oEvent){
    if(this.validate() > 0){
        this.focus();
    }
},


setValue : function(sValue, bNoNotify, bResetChange){
    var nValue, bSelect = false;
    
    if(this.oForm.oActiveField === this){
        bSelect = (this.eElement.value.length > 0 && vdf.sys.dom.getSelectionLength(this.eElement) > 0);
    }
    
    if(this.bCapslock){
        sValue = sValue.toUpperCase();
    }

    if(this.sMaskType === "win"){
        sValue = this.applyWinMask(sValue);
    }else if(this.sMaskType === "num" || this.sMaskType === "cur"){
        if(this.bMaskDisplay){
            this.sMaskOrigValue = sValue;
            sValue = this.applyNumMask(sValue);
        }
    }else if(this.sMaskType === "dat" || this.sMaskType === "dt"){    
        if(this.bMaskDisplay){
            this.sMaskOrigValue = sValue;
            sValue = this.applyDateMask(sValue);
        }
    }else if(this.bZeroSuppress && this.sDataType === "bcd"){ // Zero suppress
        if(this.bMaskDisplay){
            this.sMaskOrigValue = sValue;
            
            //  Parse into number
            nValue = this.stringToNum(sValue);
            if(isNaN(nValue)){ nValue = 0.0; }
            if(nValue === 0.0){
                sValue = "";
            }
        }
    }
        
    this.Field.prototype.setValue.call(this, sValue, bNoNotify, bResetChange);
    
    if(bSelect){
        vdf.sys.dom.focus(this.eElement, true);
    }
},


getValue : function(){
    var sValue = "";

    if(this.sMaskType === "win"){
        sValue = this.clearWinMask(this.Field.prototype.getValue.call(this));
    }else if(this.sMaskType === "num" || this.sMaskType === "cur"){
        if(this.bMaskDisplay){
            sValue = this.sMaskOrigValue;
        }else{
            sValue = this.Field.prototype.getValue.call(this);
        }
    }else if(this.sMaskType === "num" || this.sMaskType === "cur"){
        if(this.bMaskDisplay){
            sValue = this.sMaskOrigValue;
        }else{
            sValue = this.Field.prototype.getValue.call(this);
        }
    }else if(this.sMaskType === "dat" || this.sMaskType === "dt"){
        if(this.bMaskDisplay){
            sValue = this.sMaskOrigValue;
        }else{
            var dDate = this.stringToDate(this.Field.prototype.getValue.call(this));
    
            if(dDate === null){
                sValue = "";
            }else{
                sValue = this.dateToString(dDate);
            }
        }
    }else if(this.bZeroSuppress && this.bMaskDisplay){
        sValue = this.sMaskOrigValue;
    }else{
        sValue = this.Field.prototype.getValue.call(this);
    }
    
    if(this.bCapslock){
        sValue = sValue.toUpperCase();
    }
    
    return sValue;
},


stringToNum : function(sVal){
    return sVal && parseFloat(sVal.replace(this.sThousandsSeparator, "").replace(this.sDecimalSeparator, "."));
},


numToString : function(nVal){
    return nVal.toString().replace(".", this.sDecimalSeparator);
},


stringToDate : function(sVal){
    return vdf.sys.data.parseStringToDate(sVal, this.sDateFormat, this.sDateSeparator);
},


dateToString : function(dVal){
    return vdf.sys.data.parseDateToString(dVal, this.sDateFormat, this.sDateSeparator);
},


setNumber : function(nVal, bNoNotify, bResetChange){
    var nMax, nMin;
    
    //  Determine maximum and minimum values
    if(this.sMaxValue){
        nMax = this.stringToNum("" + this.sMaxValue);
    }else{
        nMax = Math.pow(10, this.iDataLength - this.iPrecision) - (1 / Math.pow(10, this.iPrecision));
    }
    if(this.sMinValue){
        nMin = this.stringToNum("" + this.sMinValue);  
    }else{
        nMin = 0.0 - Math.pow(10, this.iDataLength - this.iPrecision) - (1 / Math.pow(10, this.iPrecision));
    }
    
    //  Validate maximum and minimum values
    nVal = (nVal > nMax ? nMax : (nVal < nMin ? nMin : nVal));
    
    //  Round to number of decimals needed
    nVal = Math.round(nVal * Math.pow(10, this.iPrecision), 10) / Math.pow(10, this.iPrecision)
    
    //  Call regular setvalue
    this.setValue(this.numToString(nVal), bNoNotify, bResetChange);
},


getNumber : function(){
    return this.stringToNum(this.getValue() || "0");
},


setDate : function(dVal, bNoNotify, bResetChange){
    this.setValue(this.dateToString(dVal || new Date()), bNoNotify, bResetChange);
},


getDate : function(){
    return this.stringToDate(this.getValue() || "");
}

});




vdf.core.Toolbar = function Toolbar(eElement, oParentControl){
    this.Control(eElement, oParentControl);

    
    this.oForm              = this.getVdfAttribute("oForm", null, false);

    
    this.bReturnFocus       = this.getVdfAttribute("bReturnFocus", true, false);
    
    
    //  @privates
    this.eLastFocus = null;
};

vdf.definePrototype("vdf.core.Toolbar", "vdf.core.Control", {


init : function(){
    //  Determine the form to be used
    if(this.oForm){
        if(typeof this.oForm === "string"){
            this.oForm = vdf.getForm(this.oForm);
        }
    }else{
        this.oForm = vdf.core.findForm(this.eElement);
    }
    
    
    //  Attach return focus functionallity
    if(this.bReturnFocus){
        if(vdf.sys.isMoz){  //  Mozilla doesn't bubble focus & blur events and hasn't got a FocusIn or FocusOut
            vdf.events.addDomCaptureListener("focus", document, this.onCaptureWinFocus, this);
        }else if(window.addEventListener){ // Other browsers with W3C event system have DOMFocusIn & DOMFocusOut that bbuble
            vdf.events.addDomListener("DOMFocusIn", this.eElement, this.onToolbarFocus, this);
            vdf.events.addDomListener("DOMFocusIn", document, this.onWinFocus, this);
        }else{ // IE bubbles focusin and focusout
            vdf.events.addDomListener("focusin", this.eElement, this.onToolbarFocus, this);
            vdf.events.addDomListener("focusin", document, this.onWinFocus, this);
        }
        
        vdf.events.addDomListener("click", this.eElement, this.onToolbarClick, this);
    }
},


onCaptureWinFocus : function(oEvent){
    var oToolbar, eTarget = oEvent.getTarget();

    oToolbar = vdf.core.init.findParentControl(eTarget, this.sControlType);
    if(oToolbar !== null){
        oEvent.stop();
    }else{
        this.eLastFocus = eTarget;
    }
},


onWinFocus : function(oEvent){
    var eTarget = oEvent.getTarget();
    this.eLastFocus = eTarget;
},


onToolbarFocus : function(oEvent){
    oEvent.stop();
},


onToolbarClick : function(oEvent){
    var eFocus = this.eLastFocus;
    
    if(eFocus && typeof eFocus.focus !== "undefined"){
        setTimeout(function(){
            vdf.sys.dom.focus(eFocus);
        }, 30);
    }
},


destroy : function(){
    if(this.eElement){
        vdf.events.clearDomListeners(this.eElement);
        
        if(vdf.sys.isMoz){
            vdf.events.removeDomCaptureListener("focus", document, this.onCaptureWinFocus);
        }else if(window.addEventListener){
            vdf.events.removeDomListener("DOMFocusIn", document, this.onWinFocus);
        }else{
            vdf.events.removeDomListener("focusin", document, this.onWinFocus);
        }
    }
}

});





vdf.deo.Checkbox = function Checkbox(eCheckbox, oParentControl){
    this.Field(eCheckbox, oParentControl);
    
    
    this.sChecked = "Y";
    
    this.sUnchecked = "N";
};

vdf.definePrototype("vdf.deo.Checkbox", "vdf.core.Field", {


formInit : function(){
    var sVal;
    
    //  Load meta data values
    sVal = this.getMetaProperty("sChecked");
    if(sVal !== null){
        this.sChecked = sVal;
    }
    
    sVal = this.getMetaProperty("sUnchecked");
    if(sVal !== null){
        this.sUnchecked = sVal;
    }
    
    //  Call super class..
    this.Field.prototype.formInit.call(this);
    
    //  Attach extra listener so that onChange and DDO update will be performed directly on click (if a change occurred)
    this.addDomListener("click", this.onElemChange, this);
    
    //  Update the display value
    this.sDisplayValue = this.getValue();
},


getValue : function(){
    return (this.isChecked() ? this.sChecked : this.sUnchecked);
},


setValue : function(sValue, bNoNotify, bResetChange){
    this.eElement.checked = (sValue == this.sChecked);
    this.eElement.defaultChecked  = (sValue == this.sChecked);

    if(!bNoNotify){
        this.update();
    }
    
    this.onChange.fire(this, { "sValue" : sValue, sPrevValue : this.sOrigValue });
    
    this.sOrigValue = sValue;
    
    if(bResetChange){
        this.sDisplayValue = this.getValue();
    }
},


isChecked : function(){
    return this.eElement.checked;
}

});






vdf.deo.DatePicker = function DatePicker(eElement, oParentControl){
    this.Field(eElement, oParentControl);

    
    this.oCalendar = new vdf.gui.Calendar(eElement, oParentControl);
    

};

vdf.definePrototype("vdf.deo.DatePicker", "vdf.core.Field", {


init : function(){
    this.oCalendar.init();
},


formInit : function(){
    if(this.getMetaProperty("sMaskType") === "dat"){
        this.oCalendar.sDateMask = this.getMetaProperty("sMask");
        this.oCalendar.updateToday();
    }
    
    this.oCalendar.onChange.addListener(this.onCalendarChange, this);
    
    this.sDisplayValue = this.getValue();
},


getValue : function(){
    if(this.oCalendar){
        return this.oCalendar.getValue();
    }else{
        return "";
    }
},


setValue : function(sValue, bNoNotify, bNoResetChange){
    this.oCalendar.setValue(sValue);
    
    if(!bNoNotify){
        this.update();
    }
    
    this.onChange.fire(this, { "sValue" : sValue, sPrevValue : this.sOrigValue });
    
    this.sOrigValue = sValue;
    
    if(bResetChange){
        this.sDisplayValue = this.getValue();
    }
},


disable : function(){
    //  TODO: Implement disabled state for calendar
    this.bFocusable = false;
},


enable : function(){
    //  TODO: Implement disabled state for calendar
    this.bFocusable = true;
},


onCalendarChange : function(oEvent){
    this.update();
},


displayLock : function(){

},


displayUnlock : function(){

},


destroy : function(){
    if(this.oCalendar){
        this.oCalendar.destroy();
    }
}
});





vdf.deo.DOM = function DOM(eElement, oParentControl){
    this.TextField(eElement, oParentControl);
    
    
    this.bUseDescriptionValue = this.getVdfAttribute("bUseDescriptionValue", false);
    
    //  @privates
    this.aDValues = null;
    this.sValue = vdf.sys.dom.getElementText(this.eElement);
};

vdf.definePrototype("vdf.deo.DOM", "vdf.core.TextField", {


bFocusable : false,


formInit : function(){
    this.TextField.prototype.formInit.call(this);

    if(this.bUseDescriptionValue){
        //  Tell the form to wait for us with finishing initialization
        this.oForm.iInitFinishedStage++;
        
        this.oForm.oMetaData.loadDescriptionValues(this.sDataBinding, this.onDValuesLoaded, this);
    }
},


initValidation : function(){
    this.TextField.prototype.initValidation.call(this, false);
},


onDValuesLoaded : function(aValues){
    this.aDValues = aValues;
    
    this.oForm.childInitFinished();
},


getValue : function(){
    return this.sValue;
},


setValue : function(sValue, bNoNotify, bResetChange){
    var iDV, nValue;
    
    //  Store value
    this.sValue = sValue;
    
    //  Description value translation if needed
    if(this.bUseDescriptionValue && this.aDValues){
        for(iDV = 0; iDV < this.aDValues.length; iDV++){
            if(this.aDValues[iDV].sValue === sValue){
                sValue = this.aDValues[iDV].sDescription;
                break;
            }
        }
    }
    
    //  Apply mask if needed
    if(this.sMaskType === "win"){
        sValue = this.applyWinMask(sValue);
    }else if(this.sMaskType === "num" || this.sMaskType === "cur"){
        sValue = this.applyNumMask(sValue);
    }else if(this.sMaskType === "dat"){
        sValue = this.applyDateMask(sValue);
    }else if(this.sDataType === "bcd" && this.bZeroSupress){    //  Apply zero suppress
        //  Parse into number
        nValue = parseFloat(sValue.replace(this.sThousandsSeparator, "").replace(this.sDecimalSeparator, "."));
        if(isNaN(nValue)){ nValue = 0.0; }
        if(nValue === 0.0){
            sValue = "";
        }
    }
    
    if(sValue === ""){
        sValue = " ";
    }
    
    vdf.sys.dom.setElementText(this.eElement, sValue);
    
    if(!bNoNotify){
        this.update();
    }
    
    this.onChange.fire(this, { "sValue" : sValue, sPrevValue : this.sOrigValue });
    
    this.sOrigValue = sValue;
    
    if(bResetChange){
        this.sDisplayValue = this.getValue();
    }
},


disable : function(){

},


enable : function(){

},


focus : function(){
    //  Can't have focus :S
}

});






vdf.deo.Grid = function Grid(eElement, oParentControl){
    this.List(eElement, oParentControl);

    
    this.bHoldFocus         = this.getVdfAttribute("bHoldFocus", false);
    
    this.bFocus             = this.getVdfAttribute("bFocus", false);
    
    this.bDisplayNewRow     = this.getVdfAttribute("bDisplayNewRow", true);
    
    this.bAutoSaveState     = this.getVdfAttribute("bAutoSaveState", true);
    
    this.bAutoSaveOnBlur    = this.getVdfAttribute("bAutoSaveOnBlur", false);
    
    this.bFixedColumnWidth  = this.getVdfAttribute("bFixedColumnWidth", false);
    
    this.sCssRowEdit        = this.getVdfAttribute("sCssRowEdit", "rowedit");
    
    
    this.onBlur = new vdf.events.JSHandler();
    
    this.onFocus = new vdf.events.JSHandler();
    
    this.onConfirmSave = new vdf.events.JSHandler();
    
    this.onConfirmClear = new vdf.events.JSHandler();
    
    this.onBeforeTabToNextRow = new vdf.events.JSHandler();
    
    //  @privates
    this.aFields = [];
    //  If the focus moves to one of the elements (or the children) in this array the autosave is not performed
    this.aAutoSaveStateExceptions = [];
    
    this.bSaveAction = false;
    this.oSaveInitiator = null;
    this.oSaveFinished = null;
    
    this.eEditRow = null;
    
    this.bHasFocus = false;
    this.bDetectBlur = true;
    this.bDetermineBlur = false;
    this.bSkipAutoSave = false;
    
};

vdf.definePrototype("vdf.deo.Grid", "vdf.core.List", {


initializeComponents : function(){
    var iField, eHiddenAnchor;
    
    //  Check for elements
    if(!this.eEditRow){
        throw new vdf.errors.Error(5139, "Edit row is required", this);
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
    this.oServerDD.onBeforeDelete.addListener(this.onServerBeforeDelete, this);
    

    
    //  Set classname
    this.eEditRow.className = this.sCssRowEdit;
},


destroy : function(){
    this.List.prototype.destroy.call(this);
    
    this.eEditRow = null;
    
    //  Manually remove the document listeners
    if(vdf.sys.isMoz){
        vdf.events.removeDomCaptureListener("focus", document, this.onCaptureWinFocus);
    }else if(window.addEventListener){
        vdf.events.removeDomListener("DOMFocusIn", document, this.onWinFocus);
    }else{
        vdf.events.removeDomListener("focusin", document, this.onWinFocus);
    }
},

// - - - - - - - - - - - BLUR / FOCUS DETECTION - - - - - - - - - - - 


onTableBlur : function(oEvent){
    if(this.bDetectBlur){
        this.bDetermineBlur = true;
    }
},


onCaptureWinFocus : function(oEvent){
    var eElement = oEvent.getTarget();
    
    if(this.bDetectBlur && this.bDetermineBlur && !vdf.sys.dom.isParent(eElement, this.eElement)){
        this.bDetermineBlur = false;
        
        if(this.isAutoSaveStateException(eElement)){
            this.bSkipAutoSave = true;
            this.doBlur();
            this.bDetermineBlur = true;
        }else{
            this.doBlur();
            this.bDetermineBlur = false;
        }
    }else{
        this.bDetermineBlur = false;
    }
},


onWinFocus : function(oEvent){
    if(this.bDetectBlur && this.bDetermineBlur){
        this.bDetermineBlur = false;
        
        if(this.isAutoSaveStateException(oEvent.getTarget())){
            this.bSkipAutoSave = true;
            this.doBlur();
            this.bDetermineBlur = true;
        }else{
            this.doBlur();
            this.bDetermineBlur = false;
        }
    }else{
        this.bDetermineBlur = false;
    }
},


onTableFocus : function(oEvent){
    this.bDetermineBlur = false;
},


onFieldFocus : function(oEvent){
    if(!this.bHasFocus){
        this.doFocus();
    }
},


doFocus : function(){
    this.bHasFocus = true;
    
    //  Set focussed style
    if(this.eElement.tBodies[0].className.match("focussed") === null){
        this.eElement.tBodies[0].className += " focussed";
    }
    
    this.onFocus.fire(this);
},



doBlur : function(){
    this.bHasFocus = false;
    
    //  Remove focussed style
    this.eElement.tBodies[0].className = this.eElement.tBodies[0].className.replace("focussed", "");
    
    this.onBlur.fire(this);

    if(!this.bSkipAutoSave && this.bAutoSaveOnBlur){
        return this.determineSave();
    }
    this.bSkipAutoSave = false;
},


isAutoSaveStateException : function(eElement){
    var iCur;
    
    //  Make sure we are not running loose
    if(eElement === null || this.aAutoSaveStateExceptions.length === 0){
        return false;
    }
    
    //  Check if the element is in the array
    for(iCur = 0; iCur < this.aAutoSaveStateExceptions.length; iCur++){
        if(eElement === this.aAutoSaveStateExceptions[iCur]){
            return true;
        }
    }
    
    //  Move to parent
    if(typeof(eElement.parentNode) !== "undefined"){
        return this.isAutoSaveStateException(eElement.parentNode);
    }else{
        return false;
    }
},

// - - - - - - - - - - - CORE FUNCTIONALLITY - - - - - - - - - - - 


select : function(tRow, sField, fFinished, oEnvir){
    var oField, fFunction, iField;
    
    //  Tempolary disable the blur detection.
    this.bDetectBlur = false;
    
    this.eEditRow.className = this.sCssRowEdit + " " + (tRow.__eDisplayRow.className.match(this.sCssRowEven) !== null ? this.sCssRowEven : this.sCssRowOdd);

        //  Set the field values already so it looks less 'flashy'
    for(iField = 0; iField < this.aFields.length; iField++){
        if(tRow.__oData[this.aFields[iField].sDataBinding]){
            this.aFields[iField].setValue(tRow.__oData[this.aFields[iField].sDataBinding], true);
        }
    }

    
    vdf.sys.dom.swapNodes(tRow.__eRow, this.eEditRow);
    tRow.__eRow = this.eEditRow;
    
    
    //  We need to give the focus back to the field
    oField = null;
    fFunction = function(){
        oField.focus(true);
    };
    
    //  If a data binding is given we use that field (if we can find it)
    if(sField){
        for(iField = 0; iField < this.aFields.length; iField++){
            if(this.aFields[iField].sDataBinding === sField){
                oField = this.aFields[iField];
                break;
            }
        }
    }
    
    //  Else we use the last active field of the form
    if(this.oForm.oActiveField && oField === null){
        for(iField = 0; iField < this.aFields.length; iField++){
            if(this.oForm.oActiveField === this.aFields[iField]){
                oField = this.oForm.oActiveField;
            }
        }
    }
    
    //  Set a timeout to do the change
    if(oField){
        oField.focus(true);
        setTimeout(fFunction, 50);
    }    
    
    //  Call super
    this.List.prototype.select.call(this, tRow, sField, fFinished, oEnvir);
    
    this.bDetectBlur = true;
},



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


onServerBeforeDelete : function(oEvent){
    if(this.tSelectedRow === this.tNewRecord){
        if(this.isDataChanged()){
            if(this.confirmClear()){
                this.select(this.tSelectedRow);
            }
        }
        
        oEvent.stop();
    }    
},


isDataChanged : function(){
    return this.oServerDD.isChanged((this.tSelectedRow === this.tNewRecord ? null : this.tSelectedRow), true);
},


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


onHiddenAnchorFocus : function(oEvent){
    var iField, oAction;
    
    if(this.bHasFocus){
        if(this.onBeforeTabToNextRow.fire(this)){
            //  Give first focusable field the focus
            for(iField = 0; iField < this.aFields.length; iField++){
                if(this.aFields[iField].bFocusable){
                    this.aFields[iField].focus(true);
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
        }
    }else{
        //  Forward focus to the last (focusable) field
        for(iField = this.aFields.length - 1; iField >= 0; iField--){
            if(this.aFields[iField].bFocusable){
                this.aFields[iField].focus(true);
                break;
            }
        }
    }
},

// - - - - - - - - - - - AUTOSAVE - - - - - - - - - - - 


saveAction : function(fSaveAction, aSaveArguments){
    var result;
    
    this.bSaveAction = true;
    this.oSaveInitator = { fAction : fSaveAction, aArguments : aSaveArguments };

    result = fSaveAction.apply(this, aSaveArguments);
    
    this.bSaveAction = false;
    return result;
},


scrollUp : function(){
    return this.saveAction(this.List.prototype.scrollUp, arguments);
},


scrollDown : function(){
    return this.saveAction(this.List.prototype.scrollDown, arguments);
},


scrollTop : function(){
    return this.saveAction(this.List.prototype.scrollTop, arguments);
},


scrollBottom : function(){
    return this.saveAction(this.List.prototype.scrollBottom, arguments);
},


scrollPageUp : function(){
    return this.saveAction(this.List.prototype.scrollPageUp, arguments);
},


scrollPageDown : function(){
    return this.saveAction(this.List.prototype.scrollPageDown, arguments);
},


scrollToRow : function(){
    return this.saveAction(this.List.prototype.scrollToRow, arguments);
},


scrollToRowID : function(){
    return this.saveAction(this.List.prototype.scrollToRowID, arguments);
},


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


onAfterSave : function(oEvent){
    if(!oEvent.bError){
        if(this.oSaveFinished !== null){
            this.oSaveFinished.fAction.apply(this, this.oSaveFinished.aArguments);
        }
    }
    this.bDetectBlur = true;
},


confirmSave : function(){
    var bResult = false;
    
    this.bDetectBlur = false;
    bResult = this.onConfirmSave.fire(this);
    this.bDetectBlur = true;
    
    return bResult;
},


confirmClear : function(){
    var bResult = false;
    
    this.bDetectBlur = false;
    bResult = this.onConfirmClear.fire(this);
    this.bDetectBlur = true;
    
    return bResult;
},


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






vdf.deo.Hidden = function Hidden(eHidden, oParentControl){
    this.Field(eHidden, oParentControl);
};

vdf.definePrototype("vdf.deo.Hidden", "vdf.core.Field", {


bFocusable : false,


focus : function(){

},


displayLock : function(){

},


displayUnlock : function(){

},


initDisplayLock : function(){

}

});






vdf.deo.Lookup = function Lookup(eElement, oParentControl){
    this.List(eElement, oParentControl);
    
    
    this.sCssRowSelected = this.getVdfAttribute("sCssRowSelected", "rowselected");
};

vdf.definePrototype("vdf.deo.Lookup", "vdf.core.List", {


select : function(tRow, fFinished, oEnvir){
    tRow.__eRow.className = this.sCssRowSelected + " " + tRow.__eRow.className;
    
    this.List.prototype.select.call(this, tRow, fFinished, oEnvir);
},

deSelect : function(){
    if(this.tSelectedRow !== null){
        if(this.tSelectedRow.__eRow.className.match(this.sCssRowSelected)){
             this.tSelectedRow.__eRow.className = this.tSelectedRow.__eRow.className.replace(this.sCssRowSelected, "");
        }
    }
    
    this.List.prototype.deSelect.call(this);
    
    return true;
},


getSelectedValue : function(sColumn){
    if(this.tSelectedRow !== null){
        return this.tSelectedRow.__oData[sColumn.toLowerCase().replace("__", ".")];
    }
    
    return null;
}

});





vdf.deo.Password = function Text(eText, oParentControl){
    this.TextField(eText, oParentControl);
};

vdf.definePrototype("vdf.deo.Password", "vdf.core.TextField", {


});






vdf.deo.oRadio = { };


vdf.deo.Radio = function Radio(eRadio, oParentControl){
    if(typeof(vdf.deo.oRadio[eRadio.name]) !== "undefined"){
        vdf.deo.oRadio[eRadio.name].addElement(eRadio);
        
        return vdf.deo.oRadio[eRadio.name];
    }else{
        
        this.oElements = {};
        
        this.eFirstElement = eRadio;
        
        this.eLastElement = eRadio;
        
        //  @privates
        
        this.addElement(eRadio);
        
        this.Field(eRadio, oParentControl);
        
        vdf.deo.oRadio[eRadio.name] = this;
    }
};

vdf.definePrototype("vdf.deo.Radio", "vdf.core.Field", {


formInit : function(){
    this.Field.prototype.formInit.call(this);
    
    this.addDomListener("click", this.onElemChange, this);
},


addElement : function(eRadio){
    this.eLastElement = eRadio;
    this.oElements[eRadio.value] = eRadio;
},


getValue : function(){
    var sCurrentValue;

    for(sCurrentValue in this.oElements){
        if(typeof(this.oElements[sCurrentValue]) == "object" && this.oElements[sCurrentValue].type.toLowerCase() == "radio"){
            if(this.oElements[sCurrentValue].checked){
                return sCurrentValue;
            }
        }
    }
    
    return "";
},


setValue : function(sValue, bNoNotify, bResetChange){
    //  If none given select first
    if(sValue === ""){
        this.eFirstElement.checked = true;
    }
    
    //  Try to select
    if(typeof(this.oElements[sValue]) !== "undefined"){
        this.oElements[sValue].checked = true;
    }
    
    if(!bNoNotify){
        this.update();
    }
    
    this.onChange.fire(this, { "sValue" : sValue, sPrevValue : this.sOrigValue });
    
    this.sOrigValue = sValue;
    
    if(bResetChange){
        this.sDisplayValue = this.getValue();
    }
},

getDOMAttribute : function(sName, sDefault){
    var sElement, sValue;

    for(sElement in this.oElements){
        if(this.oElements.hasOwnProperty(sElement)){
            sValue = vdf.getDOMAttribute(this.oElements[sElement], sName, null);
            
            if(sValue !== null){
                return sValue;
            }
        }
    }
    
    return sDefault;
},

setDOMAttribute : function(sName, sValue){
    var sElement;

    for(sElement in this.oElements){
        if(this.oElements.hasOwnProperty(sElement)){
            vdf.setDOMAttribute(this.oElements[sElement], sName, sValue);
        }
    }
},


getAttribute : function(sName){
    var sElement, sValue;

    for(sElement in this.oElements){
        if(this.oElements.hasOwnProperty(sElement)){
            sValue = this.oElements[sElement].getAttribute(sName);
            
            if(typeof(sValue) !== "undefined" && sValue !== null){
                return sValue;
            }
        }
    }
    return null;
},


setAttribute : function(sName, sValue){
    var sElement;

    for(sElement in this.oElements){
        if(this.oElements.hasOwnProperty(sElement)){
            this.oElements[sElement].setAttribute(sName, sValue);
        }
    }
},


addDomListener : function(sEvent, fListener, oEnvironment){
    var sElement;

    for(sElement in this.oElements){
        if(this.oElements.hasOwnProperty(sElement)){
            vdf.events.addDomListener(sEvent, this.oElements[sElement], fListener, oEnvironment);
        }
    }
},


removeDomListener : function(sEvent, fListener){
    var sElement;

    for(sElement in this.oElements){
        if(this.oElements.hasOwnProperty(sElement)){
            vdf.events.removeDomListener(sEvent, this.eElement, fListener);
        }
    }
},


addKeyListener : function(fListener, oEnvironment){
    var sElement;

    for(sElement in this.oElements){
        if(this.oElements.hasOwnProperty(sElement)){
            vdf.events.addDomKeyListener(this.oElements[sElement], fListener, oEnvironment);
        }
    }
},


removeKeyListener : function(fListener){
    var sElement;

    for(sElement in this.oElements){
        if(this.oElements.hasOwnProperty(sElement)){
            vdf.events.removeDomKeyListener(this.oElements[sElement], fListener);
        }
    }
},


setCSSClass : function(sNewClass){
    var sElement;

    for(sElement in this.oElements){
        if(this.oElements.hasOwnProperty(sElement)){
            this.oElements[sElement].className = sNewClass;
        }
    }
},


getCSSClass : function(){
    var sElement;
    
    for(sElement in this.oElements){
        if(this.oElements.hasOwnProperty(sElement)){
            return this.oElements[sElement].className;
        }
    }
},


disable : function(){
    var sElement;

    for(sElement in this.oElements){
        if(this.oElements.hasOwnProperty(sElement)){
            this.oElements[sElement].disabled = true;
        }
    }
    
    this.bFocusable = false;
},


enabled : function(){
    var sElement;

    for(sElement in this.oElements){
        if(this.oElements.hasOwnProperty(sElement)){
            this.oElements[sElement].disabled = false;
        }
    }
    
    this.bFocusable = true;
},


insertElementAfter : function(eElement){
    vdf.sys.dom.insertAfter(eElement, this.eLastElement);
},


focus : function(){
    vdf.sys.dom.focus(this.eFirstElement);
},


displayLock : function(){

},


displayUnlock : function(){

},


destroy : function(){
    var sElement;
    
     for(sElement in this.oElements){
        if(this.oElements.hasOwnProperty(sElement)){
            vdf.events.clearDomListeners(this.oElements[sElement]);
            this.oElements[sElement].oVdfControl = null;
        }
    }
    
    this.oElements = {};
    this.eFirstElement = null;
    this.eLastElement = null;
}


});






vdf.deo.Select = function Select(eSelect, oParentControl){
    this.Field(eSelect, oParentControl);
    
    
    this.bAutoFill = this.getVdfAttribute("bAutoFill", true);
    
    this.bUseDescriptionValue = this.getVdfAttribute("bUseDescriptionValue", true);
};

vdf.definePrototype("vdf.deo.Select", "vdf.core.Field", {


formInit : function(){
    this.Field.prototype.formInit.call(this);
    
    if(this.bAutoFill && this.sDataBindingType == "D"){
        if(this.oForm && this.oForm.oMetaData){
            //  Tell the form to wait for us with finishing initialization
            this.oForm.iInitFinishedStage++;
            
            this.oForm.oMetaData.loadDescriptionValues(this.sDataBinding, this.onDValuesLoaded, this);
        }
    }
},


onDValuesLoaded : function(aValues){
    var iVal;

    for(iVal = 0; iVal < aValues.length; iVal++){
        this.eElement.options[this.eElement.options.length] = new Option((this.bUseDescriptionValue ? aValues[iVal].sDescription : aValues[iVal].sValue), aValues[iVal].sValue);
        
        //  TODO: SET Default Value?
    }
    
    
    if(this.sDefaultValue !== "" && this.sDefaultValue !== null){
        this.sOrigValue = "";
        this.setValue(this.sDefaultValue, false, true);
    }else{
        //  Update the display value
        this.sDisplayValue = this.getValue();
    }
    
    
    this.oForm.childInitFinished();
},


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
    
    if(!bNoNotify){
        this.update();
    }
    
    this.onChange.fire(this, { "sValue" : sValue, sPrevValue : this.sOrigValue });
    
    this.sOrigValue = sValue;
    
    if(bResetChange){
        this.sDisplayValue = this.getValue();
    }
},



focus : function(){
    vdf.sys.dom.focus(this.eElement);
}

});




vdf.deo.SpinForm = function SpinForm(eElement, oParentControl){
    this.TextField(eElement, oParentControl);
    
    
    this.nStep = this.getVdfAttribute("nStep", 1, false);
    
    
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

vdf.definePrototype("vdf.deo.SpinForm", "vdf.core.TextField",{


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


disable : function(){
    this.TextField.prototype.disable.call(this);
    
    //  Set the disabled attribute (doesn't work on anchors but is picked up by the CSS)
    this.ePrevBtn.setAttribute("disabled", "true");
    this.eNextBtn.setAttribute("disabled", "true");
    this.bDisabled = true;
},


enable : function(){
    this.TextField.prototype.enable.call(this);
    
    //  Remove the disabled attribute (doesn't work on anchors but is picked up by the CSS)
    this.ePrevBtn.removeAttribute("disabled");
    this.eNextBtn.removeAttribute("disabled");
    this.bDisabled = true;
},


insertElementAfter : function(eElement){
    if(this.oLookup && typeof this.oLookup.eElement === "object" && this.eElement.parentNode === this.oLookup.eElement.parentNode){
        vdf.sys.dom.insertAfter(eElement, this.oLookup.eElement);
    }else{
        vdf.sys.dom.insertAfter(eElement, this.eNextBtn);
    }
},


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


onBtnNext : function(oEvent){
    this.run(oEvent.eSource, ["mouseup", "mouseout"], true);
},


onBtnPrev : function(oEvent){
    this.run(oEvent.eSource, ["mouseup", "mouseout"], false);
},


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





vdf.deo.Text = function Text(eText, oParentControl){
    this.TextField(eText, oParentControl);
    
    
    this.sSuggestSource         = this.getVdfAttribute("sSuggestSource", "none");
    
    this.bSuggestAutoFind       = this.getVdfAttribute("bSuggestAutoFind", (this.sSuggestSource.toLowerCase() == "find"));
    
    this.bSuggestStaticWidth    = this.getVdfAttribute("bSuggestStaticWidth", true);
    
    this.sSuggestValues         = this.getVdfAttribute("sSuggestValues", "");
    
    this.iSuggestLength         = this.getVdfAttribute("iSuggestLength", 10);
    
    this.sSuggestSourceTable    = this.getVdfAttribute("sSuggestSourceTable", this.sTable);
    
    this.sSuggestSourceField    = this.getVdfAttribute("sSuggestSourceField", this.sField);
    
    this.aSuggestValues         = null;
    
    
    this.onSuggestFinish  = new vdf.events.JSHandler();
    
    this.onSuggestDisplay = new vdf.events.JSHandler();
    
    //  @privates
    this.sSuggestPrevValue      = null;
    this.tSuggestDisplay        = null;
    this.tSuggestHide           = null;
    this.eSuggestDiv            = null;
    
    this.sSuggestSource = this.sSuggestSource.toLowerCase();
    if(this.sSuggestSourceTable){
        this.sSuggestSourceTable = this.sSuggestSourceTable.toLowerCase();
    }
    if(this.sSuggestSourceField){
        this.sSuggestSourceField = this.sSuggestSourceField.toLowerCase();
    }
};

vdf.definePrototype("vdf.deo.Text", "vdf.core.TextField", {

//  - - - - - - - - - - SuggestionList - - - - - - - - - - 

formInit : function(){
    var aValues, iValue;

    if(typeof this.TextField.prototype.formInit === "function"){
        this.TextField.prototype.formInit.call(this);
    }
    
    if(this.sSuggestSource.toLowerCase() !== "none"){
        //  Attach keylistener
        this.addKeyListener(this.onSuggestFieldKeyPress, this);
        this.addDomListener("blur", this.onSuggestFieldBlur, this);

        if(this.sSuggestSource.toLowerCase() == "validationtable"){
            //  Fetch descriptionvalues and clone so we can manipulate them
            //this.aSuggestValues = browser.data.clone(this.oVdfForm.getVdfFieldAttribute(this, "aDescriptionValues"));
            //  Tell the form to wait for us with finishing initialization
            this.oForm.iInitFinishedStage++;
            
            this.oForm.oMetaData.loadDescriptionValues(this.sDataBinding, this.onSuggestDVLoaded, this);
            
            
        }else if(this.sSuggestSource.toLowerCase() == "custom"){
            //  Fetch values JSON style and add them to the array
            this.aSuggestValues = [];
            
            aValues = eval("([" + this.sSuggestValues + "])");
            for(iValue = 0; iValue < aValues.length; iValue++){
                if(aValues[iValue] !== ""){
                    this.aSuggestValues.push({ sValue : aValues[iValue] });
                }
            }
            
            //  Sort items alphabetically
            this.aSuggestValues.sort(this.suggestCompare);
        }
    }
},


onSuggestDVLoaded : function(aValues){
    this.aSuggestValues = vdf.sys.data.deepClone(aValues);
    this.aSuggestValues.sort(this.suggestCompare);
    
    this.oForm.childInitFinished();
},



suggestDisplay : function(){
    var oDD, oAction, tRequestSet, tSnapshot, tField, iDD;
    
    try{
        //  Without value no suggest list should be displayed
        if(this.eElement.value !== "" && this.onSuggestDisplay.fire(this, { sValue : this.eElement.value })){
            
            //  For validation and custom use the already loaded values.
            if(this.sSuggestSource == "validationtable" || this.sSuggestSource == "custom"){
                this.suggestBuildList(this.aSuggestValues, this.eElement.value);
            }else if(this.sSuggestSource == "find" && this.oForm.doFind){
                oDD = this.oForm.getDD(this.sSuggestSourceTable);
                
                oAction = new vdf.core.Action("find", this.oForm, this, oDD, false);
                
                tRequestSet = new vdf.dataStructs.TAjaxRequestSet();
                tRequestSet.sName = "SuggestFind";
                tRequestSet.sRequestType = "findByField";
                tRequestSet.iMaxRows = this.iSuggestLength;
                tRequestSet.sTable = this.sSuggestSourceTable;
                tRequestSet.sColumn = this.sSuggestSourceField;
                tRequestSet.sFindMode = vdf.GE;
                tRequestSet.bReturnCurrent = false;
            
                tSnapshot = oDD.generateExtSnapshot(false);
                for(iDD = 0; iDD < tSnapshot.aDDs.length; iDD++){
                    if(tSnapshot.aDDs[iDD].sName === this.sSuggestSourceTable){
                        tField = new vdf.dataStructs.TAjaxField();
                        tField.sBinding = this.sSuggestSourceTable + "." + this.sSuggestSourceField;
                        tField.sValue = this.eElement.value;
                        tSnapshot.aDDs[iDD].aFields.push(tField);
                        break;
                    }
                }
                tRequestSet.aRows.push(tSnapshot);
                
                oAction.addRequestSet(tRequestSet);
                oAction.onResponse.addListener(this.suggestHandleFind, this);
                oAction.send();
                
            }
        }else{
            if(this.eSuggestDiv !== null){
                this.suggestHide();
            }
        }
    }catch(oError){
        vdf.errors.handle(oError);
    }
},



suggestHandleFind : function(oEvent){
    var tResponseSet, iRow, iDD, tSnapshot, aList = [];
    
    if(!oEvent.bError){
        tResponseSet = oEvent.tResponseData.aDataSets[0];
        for(iRow = 0; iRow < tResponseSet.aRows.length; iRow++){
            tSnapshot = tResponseSet.aRows[iRow];
            
            for(iDD = 0; iDD < tSnapshot.aDDs.length; iDD++){
                if(tSnapshot.aDDs[iDD].sName === this.sSuggestSourceTable){
                    aList.push({sValue : tSnapshot.aDDs[iDD].aFields[0].sValue, sDescription : null});
                    break;
                }
            }
        }
      
        // go display the suggestion list
        this.suggestBuildList(aList, this.eElement.value);
    }
},


suggestBuildList : function(aCompleteList, sValue){
    var aList, eSuggestDiv, eElement, eTable, iLength, eRow, eCell, sNewSelectedValue = null, iNewSelectedItem = -1, iItem;
    
    iLength = sValue.length;
    sValue = sValue.toLowerCase();
    aList = [];
    eElement = this.eElement;
    
    //  Fetch items that match against the value from the list
    for(iItem = 0; iItem < aCompleteList.length; iItem++){
        if(aCompleteList[iItem].sValue.substr(0, iLength).toLowerCase() == sValue){
            aList.push(aCompleteList[iItem]);
        }
    }
    
    //  Remove a list if it already exists
    if(this.eSuggestDiv !== null){
        //  IE =< 6  have select list z-index bug
        vdf.sys.gui.displaySelectBoxes(this.eSuggestDiv);
    
        this.eSuggestDiv.parentNode.removeChild(this.eSuggestDiv);
        this.eSuggestDiv.eTable = null;
        this.eSuggestDiv = null;
    }
    
    //  Only generate if items are found
    if(aList.length > 0){
    
        //  Generate div and table
        eSuggestDiv = document.createElement("div");
        eSuggestDiv.className = "vdfSuggest";
        eElement.parentNode.style.position = "relative";
        if (vdf.sys.isIE){
            eSuggestDiv.style.top = (eElement.offsetHeight + 2) + "px";
            eSuggestDiv.style.left = "1px";
        }
        
        eTable = document.createElement("table");
        eTable.cellSpacing = 0;

        
        if(this.bSuggestStaticWidth){
            eSuggestDiv.style.width = (eElement.offsetWidth - 2) + "px";
            eTable.style.width = "100%";
        }
        
        vdf.sys.dom.insertAfter(eSuggestDiv, eElement);
        eSuggestDiv.appendChild(eTable);
        
        
        //  For each item generate the row
        for(iItem = 0; iItem < aList.length && iItem < this.iSuggestLength; iItem++){
            eRow = eTable.insertRow(eTable.rows.length);
            eRow.setAttribute("iNum", iItem);
            eRow.setAttribute("sValue", aList[iItem].sValue);
            
            eCell = eRow.insertCell(0);
            eCell.innerHTML = "<b>" + aList[iItem].sValue.substr(0, iLength) + "</b>" + aList[iItem].sValue.substr(iLength);
            
            //  Add description if available
            if(typeof aList[iItem].sDescription == "string"){
                eCell = eRow.insertCell(1);
                vdf.sys.dom.setElementText(eCell, aList[iItem].sDescription);
            }
            
            if(aList[iItem].sValue == this.sSuggestSelectedValue){
                eRow.className = "selected";
                sNewSelectedValue = aList[iItem].sValue;
                iNewSelectedItem = iItem;
            }
            
            vdf.events.addDomListener("mouseover", eRow, this.onSuggestMouseOver, this);
            vdf.events.addDomListener("click", eRow, this.onSuggestMouseClick, this);
        }
        
        this.eSuggestDiv = eSuggestDiv;
        this.eSuggestDiv.eTable = eTable;
        
        //  IE =< 6  have select list z-index bug
        vdf.sys.gui.hideSelectBoxes(this.eSuggestDiv);
    }
    
    this.sSuggestSelectedValue = sNewSelectedValue;
    this.iSuggestSelectedItem = iNewSelectedItem;
},


suggestHide : function(){
    try{
        if(this.eSuggestDiv !== null){
            //  IE =< 6  have select list z-index bug
            vdf.sys.gui.displaySelectBoxes(this.eSuggestDiv);
            this.eSuggestDiv.parentNode.removeChild(this.eSuggestDiv);
            this.eSuggestDiv.eTable = null;
            this.eSuggestDiv = null;
            this.sSuggestSelectedValue = null;
            this.iSuggestSelectedItem = -1;
        }
    }catch(oError){
        vdf.errors.handle(oError);
    }
},


suggestFinish : function(){
    if(this.sSuggestSelectedValue !== null){
        if(this.onSuggestFinish.fire(this, { sValue : this.sSuggestSelectedValue })){
            this.setValue(this.sSuggestSelectedValue);
            this.sSuggestPrevValue = this.sSuggestSelectedValue.toLowerCase();
            if(this.bSuggestAutoFind){
                this.doFind(vdf.GE);
            }
        }
        this.focus();
    }
    
    this.suggestHide();
},


suggestMoveSelection : function(bDown){
    var eTable, iSelectItem, iRow;
    
    eTable = this.eSuggestDiv.eTable;
    iSelectItem = this.iSuggestSelectedItem;
  
    //  Calculate which row to select
    if(bDown){
        iSelectItem++;
        if(iSelectItem >= eTable.rows.length){
            iSelectItem = eTable.rows.length - 1;
        }
    }else{
        iSelectItem--;
        if(iSelectItem < -1){
            iSelectItem = eTable.rows.length - 1;
        }else if(iSelectItem == -1){
            iSelectItem = 0;
        }
    }

    //  Loop through the rows and update the styles and get the values of the new selected row
    for(iRow = 0; iRow < eTable.rows.length; iRow++){
        if(iRow == iSelectItem){
            eTable.rows[iRow].className = "selected";
            this.sSuggestSelectedValue = eTable.rows[iRow].getAttribute("sValue"); 
            this.iSuggestSelectedItem = eTable.rows[iRow].getAttribute("iNum");
        }else{
            eTable.rows[iRow].className = "";
        }
    }
},


suggestSelectRow : function(eRow){
    var eTable, iRow;
    
    eTable = this.eSuggestDiv.eTable;
    
    //  Loop through the rows and update the styles and get the values of the new selected row
    for(iRow = 0; iRow < eTable.rows.length; iRow++){
        if(eTable.rows[iRow] == eRow){
            eTable.rows[iRow].className = "selected";
            this.sSuggestSelectedValue = eTable.rows[iRow].getAttribute("sValue"); 
            this.iSuggestSelectedItem = eTable.rows[iRow].getAttribute("iNum");
        }else{
            eTable.rows[iRow].className = "";
        }
    }
},    


onSuggestFieldKeyPress : function(oEvent){
    var iKeyCode = oEvent.getKeyCode(), oField = this;

    if(this.eSuggestDiv !== null && !oEvent.getShiftKey() && !oEvent.getCtrlKey() && !oEvent.getAltKey()){
        if (iKeyCode == 27 || iKeyCode == 9){ // escape/tab hides the list
            this.suggestHide();
            return;
        }else if (iKeyCode == 13){ // enter selects the value
            this.suggestFinish();
            oEvent.stop();
            return;
        }else if(iKeyCode == 38 || iKeyCode==40){ // Up and down go trough the list
            this.suggestMoveSelection(iKeyCode == 40);
            oEvent.stop();
            return;
        }
    }
    
    if(this.sSuggestPrevValue !== this.eElement.value.toLowerCase()){
        this.sSuggestPrevValue = this.eElement.value.toLowerCase();
        
        //  Set a timeout so the list wont show immediately
        if(this.tSuggestHide !== null){
            clearTimeout(this.tSuggestHide);
        }
        this.tSuggestDisplay = setTimeout(function(){
            oField.tSuggestDisplay = null;
            oField.suggestDisplay();
        }, 200);
    }
},



onSuggestFieldBlur : function(oEvent){
    var oField = this;

    //  Suggest keyaction
    if(this.sSuggestSource.toLowerCase() !== "none"){
        if(this.tSuggestDisplay !== null){
            clearTimeout(this.tSuggestDisplay);
        }
        this.tSuggestHide = setTimeout(function(){ 
            oField.suggestHide(); 
        }, 500);
    }
},


suggestCompare : function(oSuggestion1, oSuggestion2){
    var sValue1, sValue2;
    
    sValue1 = oSuggestion1.sValue.toUpperCase();
    sValue2 = oSuggestion2.sValue.toUpperCase();
    try{
        if (sValue1 > sValue2){
            return 1;
        }
        if (sValue2 > sValue1){
            return -1;
        }
    }catch(e){

    }
    return 0;
},


onSuggestMouseOver : function(oEvent){
    var eSource;
 
    eSource = oEvent.getTarget();
    
    eSource = vdf.sys.dom.searchParent(eSource, "tr");
    if(eSource === null){
        return;
    }
    
    this.suggestSelectRow(eSource);
},


onSuggestMouseClick : function(oEvent){
    var eSource;
 
    eSource = oEvent.getTarget();
    
    eSource = vdf.sys.dom.searchParent(eSource, "tr");
    if(eSource === null){
        return;
    }
    
    this.suggestSelectRow(eSource);
    this.suggestFinish();
}


});






vdf.deo.Textarea = function Textarea(eTextarea, oParentControl){
    this.TextField(eTextarea, oParentControl);
};

vdf.definePrototype("vdf.deo.Textarea", "vdf.core.TextField", {

initValidation : function(bAttachListeners){
    if(typeof(bAttachListeners) === "undefined"){
        bAttachListeners = true;
    }

    //  Maximum length (for text fields without a mask!)
    if(this.iDataLength && this.sMask === "" && bAttachListeners){
        this.addDomListener("keypress", this.preventMaxLength, this);
        //this.addDomListener("paste", this.preventMaxLengthPaste, this);
    }
    
    this.TextField.prototype.initValidation.call(this, bAttachListeners);

},


focus : function(){
    vdf.sys.dom.focus(this.eElement);
},


preventMaxLength : function(oEvent){
    if(!oEvent.isSpecialKey() && this.eElement.value.length >= this.iDataLength && vdf.sys.dom.getSelectionLength(this.eElement) <= 0){
        oEvent.stop();
    }
}




});

