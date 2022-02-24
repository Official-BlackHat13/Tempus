/*
Name:
    vdf.core.init
Type:
    Library(object)
Revisions:
    2008/01/04  Created the initial initialization framework which in previous 
    releases was embedden into the VdfForm. (HW, DAE)
*/

/*
@require    vdf/events.js
*/

/*
The initialization system for Visual DataFlex AJAX Library controls. These 
controls are declared in the page by adding vdf.. attributes to DOM elements. 
Controls are defined in the HTML using the vdfControlType attribute. The 
vdfControlType contains the full prototype name (like vdf.core.Form) or one of 
the short names for commonly used controls.

After the browser has finished loading the page and initializing the DOM the 
initializer automatically scans the complete page. A set of functions is also 
available to initialize a part of the DOM or to register custom created 
controls. This can be necessary if parts of the page are generated or are loaded 
manually.
*/
vdf.core.init = {

/*
A short list to map short vdfControlType names to longer library paths.

@private
*/
oControlShortList : {
    "form" : "vdf.core.Form",
    "grid" : "vdf.deo.Grid",
    "lookup" : "vdf.deo.Lookup",
    "lookupdialog" : "vdf.core.LookupDialog",
    "tabmenu" : "vdf.gui.TabContainer",
    "tabcontainer" : "vdf.gui.TabContainer",
    "datepicker" : "vdf.deo.DatePicker",
    "popupcalendar" : "vdf.gui.PopupCalendar"    
},

/*
Maps specific tagnames of elements to library paths for controls.

@private
*/
oTagShortList : {
    "select" : "vdf.deo.Select",
    "textarea" : "vdf.deo.Textarea"
},

/*
Maps types of input elements to library paths for controls.

@private
*/
oTypeShortList : {
    "text" : "vdf.deo.Text",
    "radio" : "vdf.deo.Radio",
    "checkbox" : "vdf.deo.Checkbox",
    "hidden" : "vdf.deo.Hidden",
    "password" : "vdf.deo.Password"
},


/*
Scans the given DOM elements and its childs for controls and initializes these.

@param  eStartElement   DOM element to start the scan.
*/
initializeControls : function(eStartElement){
    var oInitializer;
    
    oInitializer = new vdf.core.init.Scanner();
    if(eStartElement === document.body || typeof(vdf.core.findForm) !== "function"){
        oInitializer.scan(eStartElement, null, null, true);
    }else{
        oInitializer.scan(eStartElement, null, vdf.core.findForm(eStartElement), true);
    }
    oInitializer.initialize();
},


/*
Event listener for the window load event that initializes all controls on the 
page.

@param  oEvent  Reference to a vdf.events.DOMEvent object containing event 
            information.
@private
*/
autoInit : function(oEvent){
    vdf.require("vdf.events", function(){
        try{
            vdf.core.init.initializeControls(document.body);
        }catch (oErr){
            vdf.errors.handle(oErr);
        }
    });
},


/*
Scans the given DOM element and its childs for controls and destroyes these.

@param  eStartElement  Reference to a vdf.events.DOMEvent object containing 
            event information.
*/
destroyControls : function(eStartElement){
    var oInitializer;
    oInitializer = new vdf.core.init.Scanner();
    oInitializer.scan(eStartElement, null, false);
    oInitializer.destroy();
},

/*
Handles the unload event of the window and destroys all objects that where on 
the page to prevent memory leaks.

@param  oEvent  Event object.
@private
*/
autoDestroy : function(oEvent){
    vdf.core.init.destroyControls(document.body);
},

/*
Registers a control in the oControls object and fires the onControlCreated event. 
Eventually throws an error if the name already exists.

@param  oControl    Reference to the control.
@param  sPrototype  Full name of the Prototype of the control (example: 
            "vdf.deo.Grid").
@param  oForm       (optional) Reference to the Form control in which the 
            control is located.
*/
registerControl : function(oControl, sPrototype, oForm){
    if(typeof oControl.sName === "string" && oControl.sName !== ""){
        oControl.sControlType = sPrototype;
    
        if(oControl.hasOwnProperty("bIsForm")){
            //  
            if(vdf.oForms[oControl.sName]){
                if(vdf.oForms[oControl.sName] !== oControl){
                    throw new vdf.errors.Error(144, "Control name must be unique within the form", this, [oControl.sName]);
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
                        throw new vdf.errors.Error(144, "Control name must be unique within the form", this, [oControl.sName, oForm.sName]);
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
        throw new vdf.errors.Error(145, "Control should have a name", this, [oControl.sName]);
    }
},

/*
Destroys a control. It removes the control from the administration. It also 
calls the destroy method of the control.

@param  oControl    Reference to the control.
*/
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
        if(oControl.eElement.oVdfControl){
            oControl.eElement.oVdfControl = null;
        }
        delete oControl.eElement;
    }
    
},


/*
Bubbles up in the DOM to find a parent control. If a control type is given it 
will only find controls of that type.

@param  eElement        Element to start the search.
@param  sControlType    (optional) Type of control (like: "vdf.deo.Grid").
@reutrn Reference to the JavaScript control object (null if none found).
*/
findParentControl : function(eElement, sControlType){
    //  Initialize control type
    if(sControlType){
        //  Map name using short list
        if(typeof(vdf.core.init.oControlShortList[sControlType.toLowerCase()]) === "string"){
            sControlType = vdf.core.init.oControlShortList[sControlType.toLowerCase()];
        }
    }else{
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


/*
Constructor of the scanner that initializes the properties.

@private
*/
vdf.core.init.Scanner = function Scanner(){
    //  @privates
    this.aControls = [];
    this.iCurrent = 0;
};
/*
The initialization system encapsulated in a Prototype so its tempolary 
variables won't disturbe any other processes. The DOM is scanned starting from 
the given element for "VDF Controls". All the elements with the 
"vdfControlType" attribute are considered VDF controls and elements can be 
mapped to controls by tagName and input elements by their type. 

After scanning the controls are initialized in the sequence in which they are 
found. If a control library isn't loaded the vdf.require method is called and 
the initialization is stopped until the vdf.onLibraryLoaded event tells the 
initializer that the library is loaded.

@private
*/
vdf.definePrototype("vdf.core.init.Scanner", {


/*
Recursive scan method that recognizes control elements and stores the found 
elements with their type in the aControls array.

@param  eElement    Reference to the current element.
@param  oParent     Reference to the parent "control".
@param  oForm       Reference to the parent Form.
*/
scan : function(eElement, oParent, oForm){
    var sControlType, oControl, iChild;
    
    //  Detect vdf controls
    sControlType = vdf.getDOMAttribute(eElement, "sControlType", null);
    
    //  Perform special control detection (mostly field detection)
    if(sControlType === null){
        if(eElement.tagName === "INPUT"){    //  INPUT elements are mapped on type using the oTagShortList
            sControlType = vdf.core.init.oTypeShortList[eElement.type.toLowerCase()];
        }else{  //  Other tags are mapped using the oTagShortList
            sControlType = vdf.core.init.oTagShortList[eElement.tagName.toLowerCase()];
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
    if(sControlType !== null){
        //  Map name using short list
        if(typeof(vdf.core.init.oControlShortList[sControlType.toLowerCase()]) !== "undefined"){
            sControlType = vdf.core.init.oControlShortList[sControlType.toLowerCase()];
        }
        
        oControl = {bPreInit : true, "eElement" : eElement, sPrototype : sControlType, oParent : oParent, oForm : (oForm || null)};
        if(sControlType.toLowerCase() === "vdf.core.form" || sControlType.toLowerCase() === "vdf.core.formmeta" || sControlType.toLowerCase() === "vdf.core.formbase"){
            oForm = oControl;
        }
        
        this.aControls.push(oControl);
        oParent = oControl;
    }
    

    //  Scan child elements
    for(iChild = 0; iChild < eElement.childNodes.length; iChild++){
        if(eElement.childNodes[iChild].nodeType !== 3 && eElement.childNodes[iChild].nodeType !== 8){
            this.scan(eElement.childNodes[iChild], oParent, oForm);
        }
    }
},

/*
Initializes controls starting with the this.iCurrent control in the aControls 
array. If a control library isn't loaded it calls vdf.require to load the 
control and stops initialization.
*/
initialize : function(){
    var fConstructor, oControl, oCurrent, iControl;
    
    
    
    
   for(iControl = 0; iControl < this.aControls.length; iControl++){
        oCurrent = this.aControls[iControl];
        
        //  Check if library is loaded
        if(vdf.isAvailable(oCurrent.sPrototype)){
            if(typeof oCurrent.eElement.oVdfControl === "undefined"){
                //  Search constructor and initialize contorl
                fConstructor = vdf.sys.ref.getNestedObjProperty(oCurrent.sPrototype);
                oControl = new fConstructor(oCurrent.eElement, (oCurrent.oParent !== null ? oCurrent.oParent.oControl : null));
                
                //  Register to parent (if interrested
                if(oCurrent.oParent !== null && typeof(oCurrent.oParent.oControl.addChild) === "function"){                                     
                    oCurrent.oParent.oControl.addChild(oControl);
                }
                
                // Store control references
                oCurrent.oControl = oControl;
                vdf.core.init.registerControl(oControl, oCurrent.sPrototype, (oCurrent.oForm ? (oCurrent.oForm.hasOwnProperty("bPreInit") ? oCurrent.oForm.oControl : oCurrent.oForm) : null));
            }
        }else{
            throw new vdf.errors.Error(148, "Unknown control type", this, [oCurrent.sPrototype]);
        }
    }
    
    //  Call the init methods
    for(iControl = 0; iControl < this.aControls.length; iControl++){
        if(this.aControls[iControl].oControl){
            if(typeof(this.aControls[iControl].oControl.init) === "function"){
                try{
                    this.aControls[iControl].oControl.init();
                }catch (oError){
                    vdf.errors.handle(oError);
                }
            }
        }
    }

},

/*
Destroys the found controls (should be called after the scan method).
*/
destroy : function(){
    var iControl;
    for(iControl = 0; iControl < this.aControls.length; iControl++){
        if(typeof(this.aControls[iControl].eElement.oVdfControl) !== "undefined" && this.aControls[iControl].eElement.oVdfControl !== null){
            vdf.core.init.destroyControl(this.aControls[iControl].eElement.oVdfControl);
        }
        
       
    }
}

});

//  Make sure that the autoInit function after the DOM is initialized (Which can be in the future but also can be right now)
if (navigator.appVersion.match("MSIE") && document.readyState === "complete"){
    vdf.core.init.autoInit();
}else{
    //  Attach the listener
    if(window.addEventListener){ // W3C
        window.addEventListener("load", vdf.core.init.autoInit, false);
    }else{ // IE
        window.attachEvent("onload", vdf.core.init.autoInit);
    }
}


vdf.register("vdf.core.init");