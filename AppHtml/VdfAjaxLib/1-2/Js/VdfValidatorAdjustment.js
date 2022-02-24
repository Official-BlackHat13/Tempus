//
//  Class:
//      VdfValidator
//
//  Contains event handler methods that adjust form values according to the
//  datadictionary settings.
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
//  Applies autofind when leaving field using tab.
//
VdfValidator.prototype.adjustAutoFind = function(e){
    if(!e) var e = event;
    
    if(!e.canceled){
        var oElement = browser.events.getTarget(e);
        var iKey = browser.events.getKeyCode(e);
        
        if(iKey == KEY_CODE_TAB){
            var oField = oElement.oVdfField;
            if(oField.getChangedState()){
                if (findForm(oElement)) findForm(oElement).doFindByField(dfEQ, oField, true);
            }
        }
    }
    
    return true;
}

//
//  Applies autofindGE when leaving field using tab.
//
VdfValidator.prototype.adjustAutoFindGE = function(e){
    if(!e) var e = event;
    
    if(!e.canceled){
        var oElement = browser.events.getTarget(e);
        var iKey = browser.events.getKeyCode(e);

        if(iKey == KEY_CODE_TAB){
            var oField = oElement.oVdfField;
            
            if(oField.getChangedState()){
                if (findForm(oElement)) findForm(oElement).doFindByField(dfGE, oField, true);
            }
        }    
    }
    
    return true;
}

//
//  Make sure the added character is uppercase (only works with IE because 
//  other browsers have an readyonly keyCode)
//
VdfValidator.prototype.adjustCapslockIE = function(e){
	if(!e) var e = event;
	
    if(!e.canceled){
		if(typeof(event) != "undefined"){
			event.keyCode = String.fromCharCode(event.keyCode).toUpperCase().charCodeAt(0);
		}
        
        return true;
    }
}

//
//  Adjusts the field value to uppercase when leaving the field. (specially for 
//  browsers that only support text-transform uppercase (wich does not changes 
//  the value))
//
VdfValidator.prototype.adjustCapslock = function(e){
    if(!e) var e = event;
    var oElement = browser.events.getTarget(e);
	
    if(!e.canceled){
        if(oElement.value != oElement.value.toUpperCase()){
            oElement.value = oElement.value.toUpperCase();
        }
        
        return true;
    }
}

//
//  Make sure the field value is in correct date form by rebuilding the 
//  available value using the date mask.
//
VdfValidator.prototype.adjustDate = function(e){
    if(!e) var e = event;
    
    if(!e.canceled){

        var oElement = browser.events.getTarget(e);
        var iKey = browser.events.getKeyCode(e);
        var oField = oElement.oVdfField;

        if(!KEY_CODE_SPECIAL[iKey] && !e.altKey && !e.ctrlKey){
        
            var iCurrentPart, sNewValue = "", bExtend;
            var sMask = oField.getVdfAttribute("sDateMask").toUpperCase();
            var sSeparator = oField.getVdfAttribute("sDateSeparator");
            
            var aMaskParts = sMask.split(sSeparator);
            var sOrigValue = oElement.value;
            var aValueParts = sOrigValue.split(sSeparator);
            
            //  Loop through the parts checking if they are not to long eventually
            //  removing '0' chars in front and check if separator char might be
            //  inserted after the part
            for(iCurrentPart = 0; iCurrentPart < aValueParts.length; iCurrentPart++){
                bExtend = false;
                sPart = aValueParts[iCurrentPart];
                switch(aMaskParts[iCurrentPart]){
                    case "M": // expected: 1, 2 ..11, 12
                        if(sPart != ""){
                            sPart = sPart.substr(0, 2);
                            sPart = parseInt(sPart);
                            bExtend = (sPart.length == 2 || sPart != 1);
                        }
                        break;
                    case "MM":
                        if(sPart != ""){
                            sPart = sPart.substr(0, 2);
                            
                            bExtend = (sPart.length == 2)
                            if(sPart.length == 1 && sPart > 3){
                                 bExtend = true;
                                 sPart = browser.math.padZero(sPart, 2);
                            }
                        }
                        break;
                    case "D":
                        if(sPart != ""){
                            sPart = sPart.substr(0, 2);
                            sPart = parseInt(sPart);
                            bExtend = (sPart.length == 2 || sPart > 3);
                        }
                        
                        
                        break;
                    case "DD":
                        if(sPart != ""){
                            sPart = sPart.substr(0, 2);
                            
                            bExtend = (sPart.length == 2)
                            if(sPart.length == 1 && sPart > 3){
                                bExtend = true;
                                sPart = browser.math.padZero(sPart, 2);
                            }
                        }
                        break;
                    case "YY":
                        if(sPart != ""){
                            sPart = sPart.substr(0, 2);
                            
                            bExtend = (sPart.length == 2);
                        }
                        break;
                    case "YYYY":
                        if(sPart != ""){
                            sPart = sPart.substr(0, 4);
                            
                            bExtend = (sPart.length == 4);
                        }
                        break;
                }
                
                //  Append value and separator if needed
                if(iCurrentPart > 0){
                    sNewValue += sSeparator;
                }
                sNewValue += sPart;
            }
            
            //  If last part append separator
            if(aValueParts.length < aMaskParts.length && bExtend){
                sNewValue += sSeparator;
            }
            
            //  Set new value (only if value changed because the cursor is moved 
            //  to the end when new value is set)
            if(oElement.value != sNewValue){
                oElement.value = sNewValue;
            }
        }
    }
    
    return true;
}

//
//  Rebuild the value according to the mask.
//
VdfValidator.prototype.adjustMask = function(e){
    if(!e) var e = event;
    
    if(!e.canceled){
        var oElement = browser.events.getTarget(e);
        var iKey = browser.events.getKeyCode(e);
        var oField = oElement.oVdfField;
        var sOrigValue = oElement.value;
        
        if(!KEY_CODE_SPECIAL[iKey] && !e.altKey && !e.ctrlKey && sOrigValue != ""){
            
            var sMask = oField.getVdfAttribute("sMask");
            var iOrigChar = 0, iMaskChar = 0, sNewValue = "";
            
            //  Loop through characters
            while(iMaskChar < sMask.length && iOrigChar < sOrigValue.length){
                switch(sMask.charAt(iMaskChar)){
                    case '#':   //  If numeric char accept
                        if(sOrigValue.charAt(iOrigChar).match(/[0-9]/)){
                            sNewValue += sOrigValue.charAt(iOrigChar);
                            iOrigChar++;
                            iMaskChar++;
                        }else{
                            iOrigChar++;
                        }
                        break;
                    case '@':   //  If alphabetic accept
                        if(sOrigValue.charAt(iOrigChar).match(/[a-zA-Z]/)){
                            sNewValue += sOrigValue.charAt(iOrigChar);
                            iOrigChar++;
                            iMaskChar++;
                        }else{
                            iOrigChar++;
                        }
                        break;
                    case '!':   //  If punctuation accept
                        if(sOrigValue.charAt(iOrigChar).match(/[^a-zA-Z_0-9]/)){
                            sNewValue += sOrigValue.charAt(iOrigChar);
                            iOrigChar++;
                            iMaskChar++;
                        }else{
                            iOrigChar++;
                        }

                        break;
                    case '*':   //  Accept all
                        sNewValue += sOrigValue.charAt(iOrigChar);
                        iOrigChar++;
                        iMaskChar++;
                        break;
                    default:    //  If no token character use mask char and if 
                                //  sOrigValue contains same accept
                        sNewValue += sMask.charAt(iMaskChar);
                        if(sOrigValue.charAt(iOrigChar) == sMask.charAt(iMaskChar)){
                            iOrigChar++;
                        }
                        iMaskChar++;
                        break;
                }
            }
            
            //  If special char (non-token) in mask at next position add it to new 
            //  value
            while(iMaskChar < sMask.length && sNewValue.length == iMaskChar){
                var sMaskChar = sMask.charAt(iMaskChar);
                if(sMaskChar != '#' && sMaskChar != '@' && sMaskChar != '!' && sMaskChar != '*'){
                    sNewValue += sMaskChar;
                }
                iMaskChar++;
            }
            
            if(sNewValue != oElement.value){
                oElement.value = sNewValue;
            }
        }
    }
    
    return true;
}

//
//  Make sure the value is a correct number and if nessacary insert separator. 
//  It rebuilds the value character by character and replaces the original
//  value if it is changed (to prevent cursor flickering).
//
VdfValidator.prototype.adjustNumeric = function(e){
    if(!e) var e = event;
    
    if(!e.canceled){
        var oElement = browser.events.getTarget(e);
        var iKey = browser.events.getKeyCode(e);
        var oField = oElement.oVdfField;
        
        if(!KEY_CODE_SPECIAL[iKey] && !e.altKey && !e.ctrlKey){
            var sOrigValue = oElement.value;
            var iAfter = parseInt(oField.getVdfAttribute("iPrecision"));
            var iBefore = oField.getVdfAttribute("iDataLength") - iAfter;
            var sSeparator = oField.getVdfAttribute("sDecimalSeparator");
            var sValidator = "0123456789-" + sSeparator;
            var bFound = false, iChar = 0, sNewValue = "", iTo = iBefore;

            //  Loop through characters and make sure there are not to much before 
            //  and after the separator
            while(iChar < iTo && iChar < sOrigValue.length){
                if(sValidator.indexOf(sOrigValue.charAt(iChar)) != -1){
                    if(iChar == 0 && sOrigValue.charAt(iChar) == '-'){
                        sNewValue += sOrigValue.charAt(iChar);
                        iTo++;
                    }else if(sOrigValue.charAt(iChar) != sSeparator){
                        sNewValue += sOrigValue.charAt(iChar);
                    }else{
                        if(!bFound){
                            sNewValue += sSeparator;
                            iTo = iChar + 1 + iAfter;
                            bFound = true;
                        }
                    }
                }
                
                iChar++;
                if(iChar >= iTo && !bFound && iAfter > 0){
                    sNewValue += sSeparator;
                    iTo = iChar + 1 + iAfter;
                    bFound = true;
                }
            }
            
            if(oElement.value != sNewValue){
                oElement.value = sNewValue;
            }
        }
    }
    
    return true;
}

//
//  Correct the value according to the check values.
//
VdfValidator.prototype.adjustCheck = function(e){
    if(!e) var e = event;
    
    if(!e.canceled){
        var oElement = browser.events.getTarget(e);
        var iKey = browser.events.getKeyCode(e);
        var oField = oElement.oVdfField;
        
        if(!KEY_CODE_SPECIAL[iKey] && !e.altKey && !e.ctrlKey){
            var aPossible = oField.getVdfAttribute("sCheck").split("|");
            var sOrigValue = oElement.value;
            var iChar = 0, sNewValue = "";
            
            while(aPossible.length > 0 && iChar < sOrigValue.length){
                for(iCurrent = aPossible.length - 1; iCurrent >= 0; iCurrent--){
                    if(aPossible[iCurrent].charAt(iChar) != sOrigValue.charAt(iChar)){
                        aPossible.splice(iCurrent, 1);
                    }
                }
                
                if(aPossible.length > 0){
                    sNewValue += sOrigValue.charAt(iChar);
                }
                
                iChar++;
            }
        
            if(oElement.value != sNewValue){
                oElement.value = sNewValue;
            }
        }
    }
    
    return true;
}
