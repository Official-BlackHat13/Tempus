//
//  Library that contains basic functions that work browser independent.
//  
//  Since:      
//      1-9-2005
//  Changed:
//      --
//  Version:    
//      0.9
//  Creator:    
//      Data Access Europe
//

if(typeof(browser) != "Object"){
    var browser = new Object();
}

//  Detect browser type (most functions use object detection, but sometimes that
//  is not possible)
browser.isSafari = false;
browser.isMoz = false;
browser.isIE = false;
browser.iVersion = 0;

if (navigator.userAgent.indexOf("Safari") > 0){
    browser.isSafari = true;
    browser.iVersion = parseInt(navigator.appVersion);
}else if (navigator.product == "Gecko"){
    browser.isMoz = true;
    browser.iVersion = parseInt(navigator.appVersion);
}else{
    browser.isIE = true;
    browser.iVersion = parseInt(navigator.appVersion.substr(navigator.appVersion.indexOf("MSIE") + 4));    
}


//
//  Used when a function needs to be called but nothing should happen.
//
browser.nothing = function(){

}

//  browser.events contains generic methods for event handling
browser.events = new Object();

//  Switch between W3C & IE implementation
if(window.addEventListener){    //  W3C (mozilla, safari) implementation

    //  
    //  Adds the listener to the event.
    //
    //  Params:
    //      sEvent      Name of the event
    //      oElement    Element of wich the events should be listened
    //      oListener   Event listener method
    //
    browser.events.addListener = function(sEvent, oElement, oListener){
        oElement.addEventListener(sEvent, oListener, false);
    }
    
    //  
    //  Removes the listener of the event.
    //
    //  Params:
    //      sEvent      Name of the event
    //      oElement    Element of wich the events should are listened
    //      oListener   Event listener method
    //
    browser.events.removeListener = function(sEvent, oElement, oListener){
        oElement.removeEventListener(sEvent, oListener, false);
    }
    
    //  
    //  Adds the listener to the generic event (some browsers have special 
    //  naming conventions so this level is added).
    //
    browser.events.addGenericListener = function(sEvent, oElement, oListener){
        browser.events.addListener(sEvent, oElement, oListener);
    }
    
    //  
    //  Removes the listener from the generic event.
    //
    browser.events.removeGenericListener = function(sEvent, oElement, oListener){
        browser.events.removeListener(sEvent, oElement, oListener);
    }
    
    //  
    //  Adds the key listener to the object (some browsers only sent correct key 
    //  information on keydown instead of keypress).
    //
    browser.events.addKeyListener = function(oElement, oListener){
        browser.events.addListener("keypress", oElement, oListener);
    }
    
    //  
    //  Removes the key listener from the object.
    //
    browser.events.removeKeyListener = function(oElement, oListener){
        browser.events.removeListener("keypress", oElement, oListener);
    }
    
    //  
    //  Adds the key listener to the object (some browsers only sent correct key 
    //  information on keydown instead of keypress).
    //
    browser.events.addKeyDownListener = function(oElement, oListener){
        browser.events.addListener("keydown", oElement, oListener);
    }
    
    //  
    //  Removes the key listener from the object.
    //
    browser.events.removeKeyDownListener = function(oElement, oListener){
        browser.events.removeListener("keydown", oElement, oListener);
    }
    
    //  
    //  Adds a mousewheel listener to object.
    //
    browser.events.addMouseWheelListener = function(oElement, oListener){
        browser.events.addListener('DOMMouseScroll', oElement, oListener);
    }
    
    //
    //  Removes the mousewheel listener from the object.
    //
    browser.events.removeMouseWheelListener = function(oElement, oListener){
        browser.events.removeListener('DOMMouseScroll', oElement, oListener);
    }
    
}else if(window.attachEvent){   //  IE implementation
    browser.events.aAttachedEvents = new Array();

    //  
    //  Adds the listener to the event. Under IE the calling of the event 
    //  handlers is done manually to make sure it happens in the FIFO order.
    //
    //  Params:
    //      sEvent      Name of the event
    //      oElement    Element of wich the events should be listened
    //      oListener   Event listener method
    //
    browser.events.addListener = function(sEvent, oElement, oListener){
        //  Create object event administration if needed
        if(!oElement.listeners){
            oElement.listeners = new Object();
        }
        
        //  Create event administration and attach default listener
        if(!oElement.listeners[sEvent]){
            oElement.listeners[sEvent] = new Array();
            
            if(!oElement._handler){
                oElement._handler = function(e){
                    browser.events.callListeners(e, oElement);
                }
            }
            oElement.attachEvent("on" + sEvent, oElement._handler);
        }
        
        //  Add listener to administration if needed
        if(browser.events.getIndex(sEvent, oElement, oListener) == -1){
            oElement.listeners[sEvent].push(oListener);
            browser.events.aAttachedEvents.push([oElement, sEvent, oListener]);
        }
        
    }
    
    //  
    //  Removes the listener of the event. To prevent concurency problems while 
    //  handling a event sometimes it creates a removeListeners array so the 
    //  callListeners method can really remove the listeners later on.
    //
    //  Params:
    //      sEvent      Name of the event
    //      oElement    Element of wich the events should are listened
    //      oListener   Event listener method
    //
    browser.events.removeListener = function(sEvent, oElement, oListener){
        var iListener = browser.events.getIndex(sEvent, oElement, oListener);
        
        if(iListener > -1){
            if(oElement.listeners[sEvent].calling){
                delete oElement.listeners[sEvent][iListener];
                if(!oElement.listeners[sEvent].removeListeners){
                    oElement.listeners[sEvent].removeListeners = new Array();
                }
                oElement.listeners[sEvent].removeListeners.push(iListener);
            }else{
                if(oElement.listeners[sEvent].length > 1){
                    oElement.listeners[sEvent].splice(iListener, 1);
                }else{
                    oElement.detachEvent("on" + sEvent, oElement._handler);
                    delete oElement._listeners[sEvent];
                }
            }
        }
    }
    
    //
    //  This method is functions is called when a event occurs, it makes sure
    //  that all the listeners are called in the perfect order.
    //
    //  Params:
    //      e           Event object on some browsers
    //      oElement    Element on which event occurs
    //
    browser.events.callListeners = function(e, oElement){
        var iListener, sEvent = e.type;
        
        //  Set concurrency switch
        oElement.listeners[sEvent].calling = true;
        
        //  Call listeners
        for(iListener = 0; iListener < oElement.listeners[sEvent].length; iListener++){
            if(oElement.listeners[sEvent][iListener]){
                oElement.listeners[sEvent][iListener].call(oElement, e);
            }
        }
        
        //  Remove concurrency switch
        oElement.listeners[sEvent].calling = null;
        
        //  Remove listeners that where set to remove while calling listeners
        if(oElement.listeners[sEvent].removeListeners){
            for(iRemoveListener = 0; iRemoveListeners < oElement._listeners[sEvent].removeListeners.length; iRemoveListeners++){
                if(oElement.listeners[sEvent].length > 1){
                    oElement.listeners[sEvent].splice(oElement._listeners[sEvent].removeListeners[iRemoveListener], 1);
                }else{
                    oElement.detachEvent(sEvent, oElement._handler);
                    delete oElement.listeners[sEvent];
                }
            }
        }        
        oElement.listeners[sEvent].removeListeners = null;
    }
    
    //
    //  Loops through the listeners array an returns the position of the given 
    //  event listener.
    //
    //  Params:
    //      sEvent      Name of the event
    //      oElement    Element to which the event belongs
    //      oListeners  Searched listener
    //  Returns:
    //      Position in listeners array (-1 if not found)
    //
    browser.events.getIndex = function(sEvent, oElement, oListener){
        var iListener;
        
        if(oElement.listeners && oElement.listeners[sEvent]){
            for(iListener = 0; iListener < oElement.listeners[sEvent].lenght; iListener++){
                if(oElement.listeners[sEvent][iListener] == oListener){
                    return iListener;
                }
            }
        }
        
        return -1;
    }
    
    //
    //  Cleans the attached events and the administration on the unload of the
    //  page.
    //
    //  Params:
    //      e   Event onject on some browsers
    //
    browser.events.cleanup = function(e){
        var iEvent, aEvents = browser.events.aAttachedEvents;
        for(iEvent = 0; iEvent < aEvents.length; iEvent++){
            if(aEvents[iEvent][1] != "onunload" || aEvents[iEvent][2] == browser.events.cleanup){
                browser.events.removeListener(aEvents[iEvent][1], aEvents[iEvent][0], aEvents[iEvent][2]);
            }
        }
    }
    browser.events.addListener("unload", window, browser.events.cleanup);
    
    //  
    //  Adds the listener to the generic event (some browsers have special 
    //  naming conventions so this level is added).
    //
    browser.events.addGenericListener = function(sEvent, oElement, oListener){
        browser.events.addListener(sEvent, oElement, oListener);
    }
    
    //  
    //  Removes the listener from the generic event.
    //
    browser.events.removeGenericListener = function(sEvent, oElement, oListener){
        browser.events.removeListener(sEvent, oElement, oListener);
    }
    
    //  
    //  Adds the key listener to the object (some browsers only sent correct key 
    //  information on keydown instead of keypress).
    //
    browser.events.addKeyListener = function(oElement, oListener){
        browser.events.addListener("keydown",oElement, oListener);
    }
    
    //  
    //  Removes the key listener from the object.
    //
    browser.events.removeKeyListener = function(oElement, oListener){
        browser.events.removeListener("keydown",oElement, oListener);
    }
    
    //  
    //  Adds the key listener to the object (some browsers only sent correct key 
    //  information on keydown instead of keypress).
    //
    browser.events.addKeyDownListener = function(oElement, oListener){
        browser.events.addListener("keydown",oElement, oListener);
    }
    
    //  
    //  Removes the key listener from the object.
    //
    browser.events.removeKeyDownListener = function(oElement, oListener){
        browser.events.removeListener("keydown",oElement, oListener);
    }
        
    //  
    //  Adds a mousewheel listener to object.
    //
    browser.events.addMouseWheelListener = function(oElement, oListener){
        browser.events.addListener("mousewheel", oElement, oListener);
    }
    
    //
    //  Removes the mousewheel listener from the object.
    //
    browser.events.removeMouseWheelListener = function(oElement, oListener){
        browser.events.removeListener("mousewheel", oElement, oListener);
    }
    
}

//
//	Fetches the targetevent from the event object.
//
// 	Parameters:
//		e   The event object (on some browsers)
//	Returns:
//		The html element
//
browser.events.getTarget = function(e){
    if(!e) var e = window.event;
    
    if(typeof(e.srcElement) != "undefined"){
        return e.srcElement;
    }else{
        return e.currentTarget;
    }
}

//
//  Returns the keyCode of the last event. 
//
//  Params:
//      e   Event object on some browsers
//  Returns:
//      charCode (0 if not found) WARNING: IE does not have charCode an keyCode
//      will be returned but this wont work with special chars!
//
browser.events.getKeyCode = function(e){
	var iResult = -1;
    
    if(!e) var e = window.event;

    if(typeof(e.keyCode) != "undefined" && e.keyCode > 0){
        iResult = e.keyCode;
    }
    
    return iResult;
}

//
//  Returns:
//      the charCode of the last event (if no charcode available the keycode is 
//      returned)
//
browser.events.getCharCode = function(e){
    var iResult = -1;
    
    if(!e){
        var e = window.event;
    }
    
    if(typeof(e.which) != "undefined" && e.which > 0){
        iResult = e.which;
    }else if(typeof(e.charCode) != "undefined" && e.charCode > 0){
        iResult = e.charCode;
    }else if(typeof(e.keyCode) != "undefined" && e.keyCode > 0){
        iResult = e.keyCode;
    }
    
    return iResult;
}

//
//	Returns the vertical mouse position fetched from the event object.
//
// 	Parameters:
//		e				    Event object on some browsers
//	Returns:
//		Vertical mouse position
//
browser.events.getMouseY = function(e){
    if(!e) var e = window.event;
	
	return e.clientY;
}


//
//	Returns the horizontal mouse position fetched from the event object.
//
// 	Parameters:
//		e   Event object on some browsers
//	Returns:
//		Horizontal mouse position
//
browser.events.getMouseX = function(e){
	if(!e) var e = window.event;
    
	return e.clientX;
}


//
//  On a mousewheel event this method can be used to determine which action is 
//  applied by the user. Positive for scrollup and negative for scrolldown, if 
//  zero nothing has changed.
//
//  Parameters:
//		e   Event object on some browsers
//  Returns:
//      Integer indicating scrollwheel action
//
browser.events.getMouseWheelDelta = function(e){
	var iDelta = 0;
    
    if(!e) var e = window.event;
    
    if(e.wheelDelta){ // IE or Opera
        iDelta = e.wheelDelta / 120;
        
        // Opera works the other way arround
        if (window.opera)
                iDelta = -iDelta;
    }else if(e.detail){ 
        //  Mozilla has multiple of 3 as detail
        iDelta = -e.detail/3;
    }

    return iDelta;
}

//
//	Kills the current / given event.
//
// 	Parameters:
//		e   Event object on some browsers
//
browser.events.stop = function(e){
	if (!e) var e = window.event;

	e.returnValue = false;
    e.cancelBubble = true;
    e.canceled = true;

    if(e.preventDefault){
        
        e.preventDefault();
    }
    if(e.stopPropagation){
        e.stopPropagation();
    }
}

//
//  Returns:
//      True if event is canceled
//
browser.events.canceled = function(e){
    if (!e) var e = window.event;
    
    return (e.canceled);
}


//  Browser independent dom tools
browser.dom = new Object();

//
//	Sets the text of the cell. DEPRECATED!
//
// 	Parameters:
//		oCell    The HTML Cell object
//		sValue	The new text
// 
browser.dom.setCellText = function(oCell, sValue){
    browser.dom.setElementText(oCell, sValue);
}

//
//	Sets the text of the element.
//
// 	Parameters:
//		oElement    HTML DOM Element
//		sValues     The new text
// 
browser.dom.setElementText = function(oElement, sValue){
 	if(typeof(oElement.innerText) != "undefined"){
        oElement.innerText = sValue;
    }else{
		oElement.textContent = sValue;
	}   
}

//
//	Gets the text of the element.
//
// 	Parameters:
//		oElement    HTML DOM Element
// 
browser.dom.getElementText = function(oElement){
 	if(typeof(oElement.innerText) != "undefined"){
        return oElement.innerText;
    }else{
		return oElement.textContent;
	}   
}

//
//  Gives the focus to an element. For IE the element needs to be made active
//  also. On FireFox the .focus() on input element causes an error but still 
//  works (this is a known FireFox bug).
//
//  Parameters:
//      oElement    Html object to give focus
//
browser.dom.setFocus = function(oElement){
    try {
        oElement.focus();
    } catch (err) {
        //ignore focus error
    }

    if(typeof(oElement.setActive) == "function"){
        oElement.setActive();
    }
}

//
//  Returns the a parent object (or itself) with the requested tagname
//
//  Parameters:
//      oObj        Object where to startt the search
//      sTagName	Tagname of searched object
//
browser.dom.searchParent = function(oObj, sTagName){
    sTagName = sTagName.toUpperCase();

    if(oObj.tagName == sTagName){
        return oObj;
    }else if(oObj.parentNode != null){
        return browser.dom.searchParent(oObj.parentNode, sTagName);
    }else{
        return null;
    }
}

//
//  Recursive function that checks if the searched element is a parent of the
//  start element.
//
//  Params:
//      eStart  Start element
//      eSearch Searched element
//  Returns:
//      True if the searched element is a parent
//
browser.dom.isParent = function(eStart, eSearch){
    if(eStart == eSearch){
        return true;
    }else if(eStart.parentNode != null){
        return browser.dom.isParent(eStart.parentNode, eSearch);
    }else{
        return false;
    }
}

browser.dom.searchParentByVdfAttribute = function(eElement, sAttribute, sSearchValue){
    sValue = browser.dom.getVdfAttribute(eElement, sAttribute, null);
    
    if(sValue != null && (sValue == sSearchValue || sSearchValue == null)){
        return eElement;
    }else if(eElement.parentNode != null){
        return browser.dom.searchParentByVdfAttribute(eElement.parentNode, sAttribute, sSearchValue);
    }else{
        return null;
    }
}

//
//  Gets all child elements of the given element. For browsers that support (IE) 
//  element.all that collection is returned. Other browsers cruise recursive 
//  through the child elements.
//
//  Params:
//      oParent     Element to get childs of
//      aArray      (DO NOT USE)
//  Returns:
//      All child elements of oParent
//
browser.dom.getAllChildElements = function(oParent, aArray){
    if(typeof(oParent.all) != "undefined"){
        return oParent.all;
    }else{
       
        if(typeof(aArray) == "undefined"){
            var aArray = new Array();
        }
        for(var iChild = 0; iChild < oParent.childNodes.length; iChild++){
            if(oParent.childNodes[iChild].nodeType != 3 && oParent.childNodes[iChild].nodeType != 8){
                aArray.push(oParent.childNodes[iChild]);
                browser.dom.getAllChildElements(oParent.childNodes[iChild], aArray);
            }
        }

        return aArray;
    }
}

//
//  Used to fetch an attribute from an dom element. True and false strings are 
//  converted to boolean. If not found the default string is returned. In the 
//  framework attributes have one char indicating the type before its name, in 
//  the dom / html code we like vdf here to indicate that the property belongs 
//  to the framework instead of this char.
//
//  Params:
//      oDomObj     Dom element to fetch attribute
//      sProperty   Name of the property to fetch
//      sDefault    Value returned if no element found
//  Returns:
//      Attribute (default if not set)
//
browser.dom.getVdfAttribute = function(oDomObj, sProperty, sDefault){
    var sResult;
    
    sProperty = "vdf" + sProperty.substr(1);
    sResult = oDomObj.getAttribute(sProperty);
    
    if(sResult == null){
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
}

//
//  Sets a attribute of the dom object. In the framework attributes have one 
//  char indicating the type before its name, in the dom / html code we like
//  vdf here to indicate that the property belongs to the framework instead of 
//  this char.
//
//  Params:
//      oDomObj     Dom element to fetch attribute
//      sProperty   Name of the property to fetch
//      sValue      The new value of the property
//
browser.dom.setVdfAttribute = function(oDomObj, sProperty, sValue){
    sProperty = "vdf" + sProperty.substr(1);
    oDomObj.setAttribute(sProperty, sValue);
}

//
//  Fetches the lenght of the selection in the input element.
//
//  Params:
//      oInputElement   Element wich value selection length is required
//  Returns:
//      Character length of the selection (0 if there is no selection)
//
browser.dom.getSelectionLength = function(oInputElement){
    var iResult = 0;
    
    if(oInputElement.selectionStart != null){
        iResult = oInputElement.selectionEnd - oInputElement.selectionStart;
    }else if(document.selection){
        var oRange = document.selection.createRange();
        if(oRange.text){
            var sText = oRange.text;
            
            if(oInputElement.value.indexOf(sText) != -1){
                iResult = sText.length;
            }
        }
    }
    
    return iResult;
}

//
//  Replaces the node with the new one.
//
//  Params:
//      oOrig   Node to be replaced
//      oNew    New node
//
browser.dom.swapNodes = function(oOrig, oNew){
    if (oOrig){
        if (oNew){
            if(typeof(oOrig.replaceNode) != "undefined"){
                oOrig.replaceNode(oNew);
            }else{
                oOrig.parentNode.replaceChild(oNew, oOrig);
            }
        }
    }
}

//
//  Get all elements with a specific class name inside an object.
//  Optionally you can define what type of element to get
//
//  Params:
//      oElm       object to look inside of (document for entire page)
//      sTagName   tagname of the object to get, "*" for all object types
//      sClassName classname of the objects to get
//
browser.dom.getElementsByClassName = function(oElm,sTagName,sClassName){
	var aElements=(sTagName=="*"&&document.all)?document.all:oElm.getElementsByTagName(sTagName);
	var aReturnElements=new Array();
	sClassName=sClassName.replace(/\-/g,"\\-");
	var oRegExp=new RegExp("(^|\\s)"+sClassName+"(\\s|$)");
	var oElement;

	iPos=aElements.length;
	while(iPos--)
	{
		oElement=aElements[iPos];
		if(oRegExp.test(oElement.className))
		{
			aReturnElements.push(oElement);
		}
	}
	return aReturnElements;
}


browser.dom.insertAfter = function(eElement, eNewElement){
    if(eElement.nextSibling != null){
        eElement.parentNode.insertBefore(eNewElement, eElement.nextSibling);
    }else{
        eElement.parentNode.appendChild(eNewElement);
    }
}


//  Browser independent xml tools
browser.xml = new Object();

//
//  Finds child elements with the given name. For a strange reason the 
//  nodenames get the 'm:' addition. The internet explorer needs this addition
//  to find the node by name while firefox won't find it with the addition.
//
//  Params:
//      oNode       Xml Element to search in
//      sNodeName   Name of the searched node
//  Returns:
//      Array with the found nodes
//
browser.xml.find = function(oNode, sNodeName){
    var aResult;
    
    //  FF also requires prefix since version 3 so the version check is removed, this makes firefox 2 and older perform finds always twice, so upgrade!
    aResult = oNode.getElementsByTagName("m:" + sNodeName);
    
    if(aResult == null || aResult.length == 0){
        aResult = oNode.getElementsByTagName(sNodeName);
    }
    
    return aResult;
}

//
//  Searches the first child with nodename (used to maintain possibility of 
//  optimization)
//
//  Params:
//      oNode       Xml Element to search in
//      sNodeName   Name of the searched node
//  Returns:
//      First child with name (null if not found)
//
browser.xml.findFirst = function(oNode, sNodeName){
    return browser.xml.find(oNode, sNodeName)[0];
}

//
//  Returns the content of the searched node.
//
//  Params:
//      oNode       Node to search
//      sNodeName   Name of node to gind
//  Returns:
//      Content of the node ("" if not found)
//
browser.xml.findNodeContent = function(oNode, sNodeName){
    var oXml, result = "";

    oXml = browser.xml.find(oNode, sNodeName)[0];
    
    if(oXml != null){
        for (var iCount=0; iCount<oXml.childNodes.length; iCount++){            
            result += oXml.childNodes[iCount].nodeValue;
        }
    }
    
    if(result == null){
        result = "";
    }

    return result;
}

//
//  Returns the name of the node without the 'm:' addition.
//
//  Params:
//      oNode   The XML node
//  Returns:
//      Name of the node withoud addition
//
browser.xml.getNodeName = function(oNode){
    return oNode.nodeName.replace(/.*:/, "");
}

//
//  Replaces special characters to prefent XML errors
//
//  Params:
//      sValue  Value to encode
//  Returns:
//      Encoded value
browser.xml.encode = function(sValue){
    return '<![CDATA[' + sValue + ']]>';
}

//
//  Creates the xml request object used for sending xml requests to the server.
//  On IE the activex object should be used, other browsers have the native
//  version of the object. On ie it first tries to create the version 2 of the
//  element, else it uses the older version.
//
//  Returns:
//      XMLHttpRequest object
//
browser.xml.getXMLRequestObject = function(){
    var oResult = null;
    
    if(window.XMLHttpRequest){
        oResult = new XMLHttpRequest();
    }else if(window.ActiveXObject){
        try {
            oResult = new ActiveXObject("Msxml2.XMLHTTP");
        } catch (e) {
            try {
                oResult = new ActiveXObject("Microsoft.XMLHTTP");
            } catch (E) {

            }
        }
    }
    
    return oResult;
}



//  Functionality for working with cookies
browser.cookie = new Object();

//
//	Places an cookie
//	
//	Params:
//		sVar	Name of cookie variable
//		sValue	Value of cookie variable
//	
browser.cookie.set = function(sVar, sValue){
	var date = new Date(), sCookie = "";
	
	date.setDate(date.getDate()+2);

	document.cookie = sVar + "=" + sValue + "; expires=" + date.toGMTString();	
}

//
//	Removes cookie bij expiring
//
//	Params:
//		sVar	Name of cookie variable
//		sValue	Value of cookie variable
//
browser.cookie.del = function(sVar){
	var date = new Date(), sCookie = "";
	
	date.setTime(date.getTime()-1);

	document.cookie = sVar + "=; expires=" + date.toGMTString();		
}

//
//	Fetches cookie value
//
//	Params:
//		sVar		Name of cookie variable
//		sDefault	Variable to return when not found
//	Returns:
//		Value of the cookie variable (sDefault if not found)
//
browser.cookie.get = function(sVar, sDefault){
	var sResult = null, aVars, aVar, iVar;
	
	if(document.cookie){
		aVars = document.cookie.split(';');
		
		for(iVar = 0; iVar < aVars.length && sResult == null; iVar++){
			aVar = aVars[iVar].split('=');
			
			if(aVar.length > 1){
				if(browser.data.trim(aVar[0]) == browser.data.trim(sVar)){
					sResult = aVar[1];	
				}
			}
		}
	}
	
	if(sResult != null){
		return sResult;
	}else{
		return sDefault;
	}
}


//  Methods for data manipulation
browser.data = new Object();

//
//	Removes spaces before and after the given string
//
//	Params:
//		s	String to trim
//	Returns:
//		Trimmed string
//
browser.data.trim = function(s){
	return (browser.data.ltrim(browser.data.rtrim(s)));
}

//
//	Removes spaces before the given string
//
//	Params:
//		s	String to trim
//	Returns:
//		Trimmed string
//
browser.data.ltrim = function(s){
    while (s.substring(0,1) == ' ') {
		s = s.substring(1,s.length);
	}
    return s;
}

//
//	Removes spaces after the given string
//
//	Params:
//		s	String to trim
//	Returns:
//		Trimmed string
//
browser.data.rtrim = function(s){
    while (s.substring(s.length-1,s.length) == ' ') {
		s = s.substring(0,s.length-1);
	}
    return s;
}

//
//	Merges two objects (which can be arrays) by their attributes.
//
//	Params:
//		oObject1	Main object whichs attributes overrule
//		oObject2	Object to merge with
//	Returns:
//		Object with all the attributes
//
browser.data.merge = function(oObject1, oObject2){
	var sProp, oResult = new Object();
	
	for(sProp in oObject2){
		oResult[sProp] = oObject2[sProp];
	}
	
	for(sProp in oObject1){
		oResult[sProp] = oObject1[sProp];
	}
	
	return oResult;
}

browser.data.clone = function(oObject){
    if(oObject == null || typeof(oObject) != "object") return oObject;

    if(oObject.constructor == Array) {
        var aResult = [];
        for(var i = 0; i < oObject.length; i++){
            aResult.push(browser.data.clone(oObject[i]));
        }
        
        return aResult;
    }

	var oResult = {};
    for(var i in oObject)oResult[i] = browser.data.clone(oObject[i]);
    return oResult;
}

//  Gui contains default methods for gui use
browser.gui = new Object();


//
//  Disables the textselection for the element.
//
//  Params:
//      eElement    Reference to DOM element
//
browser.gui.disableTextSelection = function(eElement){
    eElement.onselectstart = function() {
        return false;
    };
    eElement.unselectable = "on";
    eElement.style.MozUserSelect = "none";
    eElement.style.cursor = "default";
}

//
//  Hides all select boxes behind the object (only on IE)
//
//  Params:
//      oObject     The object (mostly DIV)
//      eContent    DOM Element in which the selects shouldn't hide
//
browser.gui.hideSelectBoxes = function(oObject, eContent)
{
    var iTop, iBottom, iLeft, iRight, oAllSelects, iTopSelect;
    var iBottomSelect, iLeftSelect, iRightSelect, sVisibilityState;
    var iVisibilityCount;
    
    if(typeof(eContent) == "undefined"){
        var eContent = null;
    }
    
    if(typeof(oObject) == "object")
    {
        // check to see if this is IE version 6 or lower. hide select boxes if so
        if(browser.isIE && browser.iVersion <= 6){
            
            
            iTop = browser.gui.getAbsoluteOffsetTop(oObject);
            iBottom = iTop + oObject.offsetHeight;
            iLeft = browser.gui.getAbsoluteOffsetLeft(oObject);
            iRight = iLeft + oObject.offsetWidth;
		
            oAllSelects = document.getElementsByTagName("select");
            for(i=0; i < oAllSelects.length; i++)
            {  
                iTopSelect= browser.gui.getAbsoluteOffsetTop(oAllSelects[i]);
                iBottomSelect= browser.gui.getAbsoluteOffsetTop(oAllSelects[i]) + oAllSelects[i].offsetHeight; 

                if(((iTopSelect>iTop && iTopSelect<iBottom) || (iBottomSelect>iTop && iBottomSelect<iBottom)) || (iTopSelect<iTop && iBottomSelect>iBottom))  
                {
                    iLeftSelect= browser.gui.getAbsoluteOffsetLeft(oAllSelects[i]);
                    iRightSelect= browser.gui.getAbsoluteOffsetLeft(oAllSelects[i]) + oAllSelects[i].offsetWidth;
                    if((iLeftSelect > iLeft && iLeftSelect<iRight || (iRightSelect > iLeft && iRightSelect<iRight)) || (iLeftSelect<iLeft && iRightSelect>iRight))
                    {
                        //  Special check if the select isn't inside the content element
                        if(eContent == null || !browser.dom.isParent(oAllSelects[i], eContent)){
                            sVisibilityState = oAllSelects[i].getAttribute("VisibilityState");
                            if(sVisibilityState == null)
                            {
                                if(oAllSelects[i].style.visibility)
                                {
                                    sVisibilityState = oAllSelects[i].style.visibility;
                                }
                                else
                                {
                                    sVisibilityState = "";
                                }
    							
                                if(sVisibilityState != "hidden")
                                {
                                    oAllSelects[i].setAttribute("VisibilityState", sVisibilityState);
                                    oAllSelects[i].setAttribute("VisibilityCount", "1");
                                    oAllSelects[i].style.visibility = "hidden";
                                }
                            }
                            else
                            {
                                iVisibilityCount = parseInt(oAllSelects[i].getAttribute("VisibilityCount"));
                                oAllSelects[i].setAttribute("VisibilityCount",iVisibilityCount+1);
                            }
                        }
                    }
                }
            }
        }
    } 
}
	

//
//  Restores all the hidden selectboxes of the function 'hideSelectboxes'
//
//  Params:
//      oObject     The object
//      eContent    DOM Element in which the selects aren't hidden
//
browser.gui.displaySelectBoxes = function(oObject, eContent)
{
    var iTop, iBottom, iLeft, iRight, oAllSelects, iTopSelect;
    var iBottomSelect, iLeftSelect, iRightSelect, sVisibilityState;
    var iVisibilityCount;
    
    if(typeof(eContent) == "undefined"){
        var eContent = null;
    }
    
    if(typeof(oObject) == "object")
    {
        // check to see if this is IE version 6 or lower. display select boxes if so
        if(browser.isIE && browser.iVersion <= 6){
        
            var iTop = browser.gui.getAbsoluteOffsetTop(oObject);
            var iBottom = iTop + oObject.offsetHeight;
            var iLeft = browser.gui.getAbsoluteOffsetLeft(oObject);
            var iRight = iLeft + oObject.offsetWidth;
		
            var oAllSelects = document.getElementsByTagName("select");
            for(i=0; i < oAllSelects.length; i++)
            {   
                var iTopSelect= browser.gui.getAbsoluteOffsetTop(oAllSelects[i]);
                var iBottomSelect= browser.gui.getAbsoluteOffsetTop(oAllSelects[i]) + oAllSelects[i].offsetHeight; 
            
                if(((iTopSelect>iTop && iTopSelect<iBottom) || (iBottomSelect>iTop && iBottomSelect<iBottom)) || (iTopSelect<iTop && iBottomSelect>iBottom))
                {            
                    var iLeftSelect= browser.gui.getAbsoluteOffsetLeft(oAllSelects[i]);
                    var iRightSelect= browser.gui.getAbsoluteOffsetLeft(oAllSelects[i]) + oAllSelects[i].offsetWidth;
                    if((iLeftSelect > iLeft && iLeftSelect<iRight || (iRightSelect > iLeft && iRightSelect<iRight)) || (iLeftSelect<iLeft && iRightSelect>iRight))
                    {   
                        //  Special check if the select isn't inside the content element
                        if(eContent == null || !browser.dom.isParent(oAllSelects[i], eContent)){
                            var sVisibilityState = oAllSelects[i].getAttribute("VisibilityState");
                            if(sVisibilityState !=null)
                            {
                                var iVisibilityCount = parseInt(oAllSelects[i].getAttribute("VisibilityCount"));
                                if(iVisibilityCount <=1)
                                {   
                                    oAllSelects[i].removeAttribute("VisibilityCount");
                                    oAllSelects[i].style.visibility = sVisibilityState;
                                    oAllSelects[i].removeAttribute("VisibilityState");
                                }
                                else
                                {
                                    oAllSelects[i].setAttribute("VisibilityCount", iVisibilityCount - 1);	
                                }
                            }
                        }
                    }
                } 
            }
        }
    }	 
}

//
//  Get the full display width (of the frame / window)
//
browser.gui.getViewportHeight = function() 
{
    if (window.innerHeight!=window.undefined) return window.innerHeight;
	if (document.compatMode=='CSS1Compat') return document.documentElement.clientHeight;
	if (document.body) return document.body.clientHeight; 
	return window.undefined; 
}

//
//  Get the full display height (of the frame / window)
//
browser.gui.getViewportWidth = function() {
	if (window.innerWidth!=window.undefined) return window.innerWidth; 
	if (document.compatMode=='CSS1Compat') return document.documentElement.clientWidth; 
	if (document.body) return document.body.clientWidth; 
	return window.undefined; 
}

//
//  This Function measures the offsetLeft position of the object that is 
//  referred to plus all its parent elements. The returnvalue is the total of
//  the object and the parent elements
//
//  Params:
//      oObject The object to get left offset from
//  Returns:
//      Total left offset of object
//
browser.gui.getAbsoluteOffsetLeft = function(oObject)
{
    var iReturnValue = 0;

    if (oObject.offsetParent){
        //  Working with relative / fixed elements causes some troubles with absolute elements inside
        while (oObject.offsetParent && oObject.offsetParent.style.position != "relative" && oObject.offsetParent.style.position != "fixed"){
            iReturnValue += oObject.offsetLeft;
            oObject = oObject.offsetParent;
        }
    }else if (oObject.x){
        iReturnValue += oObject.x;
    }

    return iReturnValue;
}


//
//  This Function measures the offsetTop position of the object that is 
//  referred to plus all its parent elements. The returnvalue is the total of
//  the object and the parent elements
//
//  Params:
//      oObject The object to get top offset from
//  Returns:
//      Total top offset of the object
//
browser.gui.getAbsoluteOffsetTop = function(oObject) 
{
    var iReturnValue = 0;

    if (oObject.offsetParent){
        //  Working with relative / fixed elements causes some troubles with absolute elements inside
        while (oObject.offsetParent && oObject.offsetParent.style.position != "relative" && oObject.offsetParent.style.position != "fixed"){
            iReturnValue += oObject.offsetTop;
            oObject = oObject.offsetParent;
        }
    }else if (oObject.y){
        iReturnValue += oObject.y;
    }

    return iReturnValue;
}


//  Math browser indepentdent math methods 
browser.math = new Object();

//
//  Converts string to integer, first it removens 0 chars in front.
//
//  Params:
//      sValue  String to convert
//  Result:
//      Integer value
//
browser.math.stringToInt = function(sValue){
    if(sValue != null){
        while(sValue.charAt(0) == '0'){
            sValue = sValue.substr(1);
        }
        
        return parseInt(sValue);
    }else{
        return 0;
    }
}

//
//  Fills out the given number with zero's until it has the required amount of
//  digits.
//
//  Params:
//      iNum    Number to convert
//      iDigits Number of digits
//  Returns:
//      String with the number outfilled with zero's.
//
browser.math.padZero = function(iNum, iDigits)
{
    var sResult = "" + iNum;
    
    while(sResult.length < iDigits){
        sResult = "0" + sResult;
    }
    
    return sResult;
}


//
//  Function used for array sorts to avoid case sensitivity else
//  bValue2, BValue1, CValue would be sorted as:
//  BValue1, CValue, bValue2
//
//  Paramers:
//      sValue1   first value
//      sValue2   second value
//  Returns:
//      Boolean indicating if first value should be above second value
//
browser.math.arraySort = function(sValue1, sValue2)
{
    sValue1 = sValue1.toUpperCase();
    sValue2 = sValue2.toUpperCase();
    if(sValue1 != "" && sValue2 != ""){
        try{
            if(sValue1 > sValue2) return 1;
            if (sValue2 > sValue1) return -1;
        }catch(e){
        
        }
    }
    return 0;
}

//
//	Contains method which is added to the string object
//
//	Returns:
//		True if the string contains the value
//	
String.prototype.contains = function(sValue){ 
    return (this.indexOf(sValue) >= 0 ? true : false); 
}