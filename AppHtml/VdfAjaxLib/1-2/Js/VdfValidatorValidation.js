//
//  Class:
//      VdfValidator
//
//  Contains methods for field validation.
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
//  Checks if the value of the field is completely uppercase.
//
//  Params:
//      oVdfField    Field to check
//  Returns:
//      True if correct
//
VdfValidator.prototype.validateCapslock = function(oVdfField){
    var bResult = oVdfField.getValue() == oVdfField.getValue().toUpperCase();

    if(!bResult){
        VdfErrorHandle(new VdfFieldError(301, "Uppercase", oVdfField, this.oVdfForm));
    }else{
        VdfErrorsClearError(oVdfField.sTable, oVdfField.sField, 301);
    }
    
    return bResult;
}

//
//  Checks if the value is not changed since the last action
//
//  Params:
//      oVdfField    Field to check
//  Returns:
//      True if correct
//
VdfValidator.prototype.validateDisplayOnly = function(oVdfField){
    var bResult = !oVdfField.getChangedState();

    if(!bResult){
        VdfErrorHandle(new VdfFieldError(302, "Displayonly", oVdfField, this.oVdfForm));
    }else{
        VdfErrorsClearError(oVdfField.sTable, oVdfField.sField, 302);
    }
    
    return bResult;
}

//
//  Checks if the value is not changed since the last action
//
//  Params:
//      oVdfField   Field to check
//      sType       Data type of the field
//  Returns:
//      True if correct
//
VdfValidator.prototype.validateFindRequired = function(oVdfField, sType){
    var bResult = (!oVdfField.getChangedState() && oVdfField.getValue() != "" && (sType != "bcd" || parseInt(oVdfField.getValue()) != 0));

    if(!bResult){
        VdfErrorHandle(new VdfFieldError(303, "Find required", oVdfField, this.oVdfForm));
    }else{
        VdfErrorsClearError(oVdfField.sTable, oVdfField.sField, 303);
    }
    
    return bResult;
}

//
//  Checks if the value is not changed since the last action
//
//  Params:
//      oVdfField    Field to check
//  Returns:
//      True if correct
//
//  DEPRECATED
VdfValidator.prototype.validateFindRequiredNum = function(oVdfField){
    var bResult = (!oVdfField.getChangedState() && parseInt(oVdfField.getValue()) != 0 && oVdfField.getValue() != "");

    if(!bResult){
        VdfErrorHandle(new VdfFieldError(303, "Find required", oVdfField, this.oVdfForm));
    }else{
        VdfErrorsClearError(oVdfField.sTable, oVdfField.sField, 303);
    }
    
    return bResult;
}

//
//  Checks it the field is not empty
//
//  Params:
//      oVdfField    Field to check
//  Returns:
//      True if correct
//
VdfValidator.prototype.validateRequired = function(oVdfField, sType){
    var bResult = oVdfField.getValue() != "" && (sType != "bcd" || parseInt(oVdfField.getValue()) != 0);

    if(!bResult){
        VdfErrorHandle(new VdfFieldError(312, "Required", oVdfField, this.oVdfForm));
    }else{
        VdfErrorsClearError(oVdfField.sTable, oVdfField.sField, 312);
    }
    
    return bResult;
}

//
//  Checks if the field is not numeric empty ("" or 0)
//
//  Params:
//      oVdfField    Field to check
//  Returns:
//      True if correct
//
//  DEPRECATED
VdfValidator.prototype.validateRequiredNum = function(oVdfField){
    var bResult = (oVdfField.getValue() != "" && parseInt(oVdfField.getValue()) != 0);

    if(!bResult){
        VdfErrorHandle(new VdfFieldError(306, "Required", oVdfField, this.oVdfForm));
    }else{
        VdfErrorsClearError(oVdfField.sTable, oVdfField.sField, 306);
    }
    
    return bResult;
}

//
//  Checks if the value is an correct numeric value
//
//  Params:
//      oVdfField    Field to check
//      sSeparator  Separator used
//  Returns:
//      True if correct
//
VdfValidator.prototype.validateNumeric = function(oVdfField, sSeparator){
    var regex = new RegExp("^(-?)([0-9]+)(" + sSeparator +"([0-9]*))?$");
    var bResult = (oVdfField.getValue() == "" || regex.test(oVdfField.getValue()));
    
    if(!bResult){
        VdfErrorHandle(new VdfFieldError(304, "Not numeric", oVdfField, this.oVdfForm));
    }else{
        VdfErrorsClearError(oVdfField.sTable, oVdfField.sField, 304);
    }
    
    return bResult;
}

//
//  Checks if the value is an correct date. If this.bAdjust is true it will try
//  to correct the value.
//
//  Params:
//      oVdfField        Field to check
//      sDateMask       Mask for the date value
//      sDateSeparator  Separator used for dates
//  Returns:
//      True if correct
//
VdfValidator.prototype.validateDate = function(oVdfField, sDateMask, sDateSeparator){
    var sNewValue = "";
    
    var aValids = sDateMask.toUpperCase().split(sDateSeparator);
    var aValues = oVdfField.getValue().split(sDateSeparator);
    
    var bResult = aValids.length == aValues.length;
    var iCurrent = 0;
    var sPart, iPart;
    var regex = /^([0-9]+)$/;
    while(iCurrent < aValids.length){
        sPart = aValues[iCurrent];
        if(sPart == null){
            sPart = "";
        }
        
        bResult = bResult && regex.test(sPart);
        switch(aValids[iCurrent]){
            case "M":                
                //  If allowed adjust
                if(this.bAdjust){
                    sPart = browser.math.stringToInt(sPart);
                    if(sPart > 12){
                        sPart = 12;
                    }
                    sPart = "" + sPart;
                }
                
                bResult = (bResult && sPart.length > 0 && sPart.length <= 2 && browser.math.stringToInt(sPart) <= 12 && browser.math.stringToInt(sPart) > 0);
                break;
            case "MM":
                //  If allowed adjust
                if(this.bAdjust){
                    if(browser.math.stringToInt(sPart) > 12){
                        sPart = "12";
                    }
                    
                    if(sPart.length == 1){
                        sPart = "0" + sPart;
                    }
                }
            
                bResult = (bResult && sPart.length == 2 && browser.math.stringToInt(sPart) <= 12 && browser.math.stringToInt(sPart) > 0);
                break;
            case "D":
                //  If allowed adjust
                if(this.bAdjust){
                    sPart = browser.math.stringToInt(sPart);
                    if(sPart > 31){
                        sPart = 31;
                    }
                    
                    sPart = "" + sPart;
                }
            
                bResult = (bResult && sPart.length > 0 && sPart.length <= 2 && browser.math.stringToInt(sPart) <= 31 && browser.math.stringToInt(sPart) > 0);
                break;
            case "DD":
                //  If allowed adjust
                if(this.bAdjust){
                    if(browser.math.stringToInt(sPart) > 31){
                        sPart = "31";
                    }
                    
                    if(sPart.length == 1){
                        sPart = "0" + sPart;
                    }
                }
            
                bResult = (bResult && sPart.length == 2 && browser.math.stringToInt(sPart) <= 31 && browser.math.stringToInt(sPart) > 0);
                break;
            case "YY":
                //  If allowed adjust
                if(this.bAdjust){
                    if(sPart.length == 1){  //  if single char add "0" (6 => 06)
                        sPart = "0" + sPart;
                    }
                }
            
                bResult = (bResult && sPart.length == 2);
                break;
            case "YYYY":
                //  If allowed adjust
                if(this.bAdjust){   // Try to adjust 2 decimal to 4 decimal
                    if(sPart.length == 2 && (sPart.charAt(0) == '0' || sPart.charAt(0) == '1')){
                        sPart = "20" + sPart;
                    }
                    if(sPart.length == 2 && (sPart.charAt(0) == '8' || sPart.charAt(0) == '9')){
                        sPart = "19" + sPart;
                    }
                }
                
                bResult = (bResult && sPart.length == 4);
                break;
        }
           
        //  If allowed adjust
        if(this.bAdjust){
            if(iCurrent > 0){
                sNewValue += sDateSeparator;
            }
            sNewValue += sPart;
        }
        
        iCurrent++;
    }
    
    //  If allowed adjust
    if(this.bAdjust && aValids.length == aValues.length){
        oVdfField.setValue(sNewValue);
    }
    
    bResult = (oVdfField.getValue() == "" || bResult);
    
    if(!bResult){
        VdfErrorHandle(new VdfFieldError(305, "Not a date", oVdfField, this.oVdfForm));
    }else{
        VdfErrorsClearError(oVdfField.sTable, oVdfField.sField, 305);
    }
    
    return bResult;
}

//
//  Checks if the value matches the mask
//
//  Params:
//      oVdfField    Field to check
//      sMask       VDF mask to match with
//  Returns:
//      True if correct
//
//  DEPRECATED
VdfValidator.prototype.validateMask = function(oVdfField, sMask){
    var bResult, regex;
    var sSpecials = "\|()[{^$*+?.";
    var sRegex = "^";
    for(iChar = 0; iChar < sMask.length; iChar++){
        switch(sMask.charAt(iChar)){
            case '#':   //  If numeric char accept
                sRegex += "[0-9]";
                break;
            case '@':   //  If alphabetic accept
                sRegex += "[a-zA-Z]";
                break;
            case '!':   //  If punctuation accept
                sRegex += "[^a-zA-Z_0-9]";
                break;
            case '*':   //  Accept all
                sRegex += ".";
                break;
            default:
                if(sSpecials.indexOf(sMask.charAt(iChar)) != -1){
                    sRegex += "\\";
                }
                sRegex += sMask.charAt(iChar);
                break;
        }
    }
    sRegex += "$";
    
    regex = new RegExp(sRegex);
    bResult = (oVdfField.getValue() == "" || regex.test(oVdfField.getValue()));
    
    if(!bResult){
        VdfErrorHandle(new VdfFieldError(307, "Unmatched mask", oVdfField, this.oVdfForm));
    }else{
        VdfErrorsClearError(oVdfField.sTable, oVdfField.sField, 307);
    }
    
    return bResult;
}

//
//  Checks if the value matches one of the check values
//
//  Params:
//      oVdfField    Field to check
//      sCheck      VDF check values (| separated)
//  Returns:
//      True if correct
//
VdfValidator.prototype.validateCheck = function(oVdfField, sCheck){
    var aCheck = sCheck.split("|");
    var sValue = oVdfField.getValue();
    var bResult = false;
    
    for(iCurrent = 0; iCurrent < aCheck.length && (!bResult); iCurrent++){
        bResult = (aCheck[iCurrent] == sValue);
    }
    
    bResult = (oVdfField.getValue() == "" || bResult);
    
    if(!bResult){
        VdfErrorHandle(new VdfFieldError(308, "Unmatched check value", oVdfField, this.oVdfForm));
    }else{
        VdfErrorsClearError(oVdfField.sTable, oVdfField.sField, 308);
    }
    
    return bResult;   
}

//
//  Checks if the numeric value is not to long
//
//  Params:
//      oVdfField    Field to check
//      iDataLength Total field lenth
//      iPrecision  Number of decimals
//      sSeparator  Character separating decimals
//  Returns:
//      True if correct
//
VdfValidator.prototype.validateMaxLengthNum = function(oVdfField, iDataLength, iPrecision, sSeparator){
    var iBefore = iDataLength - iPrecision;
    var sValue = oVdfField.getValue();
    var aValues = sValue.split(sSeparator);
    var bResult;
    
    if(sValue.indexOf("-") != -1) iBefore++;
    
    bResult = (aValues[0].length <= iBefore && (aValues.length == 1 || aValues[1].length <= iPrecision));
    
    
    if(!bResult){
        VdfErrorHandle(new VdfFieldError(309, "Maximum length", oVdfField, this.oVdfForm));
    }else{
        VdfErrorsClearError(oVdfField.sTable, oVdfField.sField, 309);
    }
    
    return bResult; 
}

//
//  Checks the length of the value
//
//  Params:
//      oVdfField    Field to check
//      iDataLength Maximum lenght of the value
//  Returns:
//      True if correct
//
VdfValidator.prototype.validateMaxLength = function(oVdfField, iDataLength){
    bResult = oVdfField.getValue().length <= iDataLength;
    
    if(!bResult){
        VdfErrorHandle(new VdfFieldError(309, "Maximum length", oVdfField, this.oVdfForm));
    }else{
        VdfErrorsClearError(oVdfField.sTable, oVdfField.sField, 309);
    }
    
    return bResult; 
}

//
//  Checks if value is lower than the maximum value
//
//  Params:
//      oVdfField    Field to check
//      sMaxValue   Maximum value
//  Returns:
//      True if correct
//
VdfValidator.prototype.validateMaxValue = function(oVdfField, sMaxValue){
    bResult = (oVdfField.getValue() == "" || oVdfField.getValue() <= sMaxValue);
    
    if(!bResult){
        VdfErrorHandle(new VdfFieldError(310, "Maximum value", oVdfField, this.oVdfForm));
    }else{
        VdfErrorsClearError(oVdfField.sTable, oVdfField.sField, 310);
    }
    
    return bResult; 
}

//
//  Checks if the value is higher than the minimum value
//
//  Params:
//      oVdfField    Field to check
//      sMinValue   Minumum value
//  Returns:
//      True if correct
//
VdfValidator.prototype.validateMinValue = function(oVdfField, sMinValue){
    bResult = (oVdfField.getValue() == "" || oVdfField.getValue() >= sMinValue);
    
    if(!bResult){
        VdfErrorHandle(new VdfFieldError(311, "Minumum Value", oVdfField, this.oVdfForm));
    }else{
        VdfErrorsClearError(oVdfField.sTable, oVdfField.sField, 311);
    }
    
    return bResult; 
}