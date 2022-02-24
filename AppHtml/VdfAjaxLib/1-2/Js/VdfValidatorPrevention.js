//
//  Class:
//      VdfValidator
//
//  Contains event handler methods that prevent the user from inserting wrong 
//  characters.
//
//  Since:
//      10-12-2005
//  Changed:
//      31-03-2006 Harm Wibier
//          Complete restructure of the validation methods
//  Version:
//      0.9
//  Creator:
//      Data Access Europe (Ruud Tuitert)
//

//
//  Stops all characters
//
VdfValidator.prototype.preventDisplayOnly = function(e){
    if(!e) var e = event;
    
    if(!e.canceled){
        var oElement = browser.events.getTarget(e);
        var iKey = browser.events.getKeyCode(e);
        
        if(!KEY_CODE_NON_EDIT[iKey] && !e.altKey && !e.ctrlKey){
            browser.events.stop(e);
            return false;
        }
    }
    
    return true;
}

//
//  Stops all characters
//
VdfValidator.prototype.preventNoEnter = function(e){
    if(!e) var e = event;
    
    if(!e.canceled){
        var oElement = browser.events.getTarget(e);
        var iKey = browser.events.getKeyCode(e);
        
        if(!KEY_CODE_NON_EDIT[iKey] && !e.altKey && !e.ctrlKey){
            browser.events.stop(e);
            
            return false;
        }  
    }
        
    return true;
}

//
//  Only allows numeric characters
//
VdfValidator.prototype.preventNumeric = function(e){
    if(!e) var e = event;

    if(!e.canceled){
        var oElement = browser.events.getTarget(e);
        var oField = oElement.oVdfField;
        var iKey = browser.events.getKeyCode(e);
        var iChar = browser.events.getCharCode(e);
        
        if(!KEY_CODE_SPECIAL[iKey] && !e.altKey && !e.ctrlKey){
            var sSeparator = oField.getVdfAttribute("sDecimalSeparator");
            var sValidChars = "0123456789-" + sSeparator;
            var sKeyEntered = String.fromCharCode(iChar);
            
            if(sValidChars.indexOf(sKeyEntered) == -1){
                browser.events.stop(e);
                
                return false;
            }
        }
    }
    
    return true;
}

//
//  Only allow date characters
//
VdfValidator.prototype.preventDate = function(e){
    if(!e) var e = event;
    
    if(!e.canceled){
        var oElement = browser.events.getTarget(e);
        var iKey = browser.events.getKeyCode(e);
        var iChar = browser.events.getCharCode(e);
        var oField = oElement.oVdfField;
        
        if(!KEY_CODE_SPECIAL[iKey] && !e.altKey && !e.ctrlKey){
            
            var sValidChars = "0123456789" + oField.getVdfAttribute("sDateSeparator");
            var sKeyEntered = String.fromCharCode(iChar);

            if(sValidChars.indexOf(sKeyEntered) == -1){
                //  Internet explorer uses keyCode wich wont work with special chars so this special check is added
                if(!(browser.isIE && ((oField.getVdfAttribute("sDateSeparator") == "-" && iChar == 189) || (oField.getVdfAttribute("sDateSeparator") == "/" && iChar == 191)))){
                    browser.events.stop(e);
                
                    return false;
                }
            }
        }
    }
    
    return true;
}

//
//  Don't allow any character when field already contains maximum number of 
//  characters.
//
VdfValidator.prototype.preventMaxLength = function(e){
    if(!e) var e = event;
    
    if(!e.canceled){
        var oElement = browser.events.getTarget(e);
        var iKey = browser.events.getKeyCode(e);
        var iLength = parseInt(oElement.oVdfField.getVdfAttribute("iMaxLength"));
        
        if(!KEY_CODE_SPECIAL[iKey] && !e.altKey && !e.ctrlKey){
            if(oElement.value.length >= iLength && browser.dom.getSelectionLength(oElement) <= 0){
                browser.events.stop(e);
                
                return false;
            }
        }
    }
}