//
//  Class:
//      VdfValidator
//
//  Contians all code needed for the validation. The class is separated in 
//  four different files: this, Adjustment, Prevention, Validation. This 
//  file contains the code that is needed initialize the validation using an
//  form object. The other files could be used without the complete engine.
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


//  Tab key
var KEY_CODE_TAB = 9;
var KEY_CODE_NON_EDIT = {37:1, 38:1, 39:1, 40:1, 35:1, 36:1, 9:1};

//  Special keys
var KEY_CODE_SPECIAL = {37:1, 38:1, 39:1, 40:1, 35:1, 36:1, 46:1, 8:1, 9:1};
//  37, 38, 39, 40 cursor keys
//  35  end
//  36  home
//  46  delete
//  8   backspace
//  9   tab

//
//  Constructor
//  
//  Params:
//      oVdfForm     VdfForm object
//
function VdfValidator(oVdfForm){
    this.oVdfForm = oVdfForm;
}

//
//  Initializes field by attaching the nessacary events and setting the 
//  nessacary attributes.
//
//  Params:
//      oField  VdfField object
//
VdfValidator.prototype.initField = function(oField){
    var oVdfForm = this.oVdfForm;
    var sType = oVdfForm.getVdfFieldAttribute(oField, "sDataType");

    var iDataLength = oVdfForm.getVdfFieldAttribute(oField, "iDataLength");

    if(this.oVdfForm.getVdfFieldAttribute(oField, "bValidatePrevent")){
        this.preventField(oField, oVdfForm, sType);
    } 
    
    if(this.oVdfForm.getVdfFieldAttribute(oField, "bValidateAdjust")){
        this.adjustField(oField, oVdfForm, sType);
    }
    
    if(this.oVdfForm.getVdfFieldAttribute(oField, "bValidateClient") || this.oVdfForm.getVdfFieldAttribute(oField, "bValidateServer")){
        oField.addKeyListener(this.onValidateField);
    }
}

//
//  Attaches the (key)events for the prevention methods.
//
//  Params:
//      oField  Field to prevent
//      oVdfForm Form that owns the field
//      sType   Typ of the field
//
VdfValidator.prototype.preventField = function(oField, oVdfForm, sType){
    var iMaxLength = 0;
    
    //  Display only
    if(oVdfForm.getVdfFieldAttribute(oField, "bDisplayOnly")){
        oField.addGenericListener("keypress", this.preventDisplayOnly);
    }
    
    //  No enter
    if(oVdfForm.getVdfFieldAttribute(oField, "bNoEnter")){
        oField.addGenericListener("keypress", this.preventNoEnter);
    }
    
    //  Type prevention
    if(sType == "bcd"){
        oField.addGenericListener("keypress", this.preventNumeric);
    }else if(sType == "date"){
        oField.setVdfAttribute("sDateSeparator", this.getDateSeparator(oVdfForm.oVdfInfo.sDateMask));
        oField.addGenericListener("keypress", this.preventDate);
    }
    
    //  Maximum length
    //  Determine
    if(sType == "ascii" || sType == "text"){
        iMaxLength = oVdfForm.getVdfFieldAttribute(oField, "iDataLength");
    }else if(sType == "bcd"){
        iMaxLength = oVdfForm.getVdfFieldAttribute(oField, "iDataLength");
    
        if(parseInt(oVdfForm.getVdfFieldAttribute(oField, "iPrecision")) > 0){
            iMaxLength++;
        }
        iMaxLength++;
    }else if(sType == "date"){
        iMaxLength = oVdfForm.oVdfInfo.sDateMask.length;
    }

    //  Set
    if(iMaxLength > 0){
        if(oField.sType == "textarea"){
            oField.setVdfAttribute("iMaxLength", iMaxLength);
            oField.addGenericListener("keypress", this.preventMaxLength);
        }else{
            oField.setAttribute("maxLength", iMaxLength);
        }
    }
 }
 
//
//  Attaches the events that handle the value adjustment of the field.
//
//  Params:
//      oField  Field to adjust
//      oVdfForm Form to wich the field belongs
//      sType   Type of the field
//
VdfValidator.prototype.adjustField = function(oField, oVdfForm, sType){
    var sMask, sCheck, iPrecision;
    
    //  Autofind
    if(oVdfForm.getVdfFieldAttribute(oField, "bAutoFind")){
        oField.addKeyListener(this.adjustAutoFind);
    }
    
    //  Autofind GE
    if(oVdfForm.getVdfFieldAttribute(oField, "bAutoFind_GE")){
        oField.addKeyListener(this.adjustAutoFindGE);
    }
    
    //  Capslock
    if(oVdfForm.getVdfFieldAttribute(oField, "bCapsLock")){
        if(browser.isIE || oField.getType() != "text"){
            oField.addGenericListener("keypress", this.adjustCapslockIE);
        }else{
            oField.getElement().style.textTransform = "uppercase";
        }
		oField.addGenericListener("blur", this.adjustCapslock);
    }  
    
    //  Date
    if(sType == "date"){
        oField.setVdfAttribute("sDateMask", oVdfForm.oVdfInfo.sDateMask);
        oField.setVdfAttribute("sDateSeparator", this.getDateSeparator(oVdfForm.oVdfInfo.sDateMask));
        oField.addGenericListener("keyup", this.adjustDate);
    }
    
    //  Numeric
    if(sType == "bcd"){
        iPrecision = parseInt(oVdfForm.getVdfFieldAttribute(oField, "iPrecision"));
        oField.setVdfAttribute("iDataLength", oVdfForm.getVdfFieldAttribute(oField, "iDataLength"));
        oField.setVdfAttribute("iPrecision", iPrecision);
        oField.setVdfAttribute("sDecimalSeparator", oVdfForm.oVdfInfo.sDecimalSeparator);
        oField.addGenericListener("keyup", this.adjustNumeric);
    }
    
    //  Mask
    sMask = oVdfForm.getVdfFieldAttribute(oField, "sMask");
    if(sMask != null && sMask != ""){
        oField.setVdfAttribute("sMask", sMask);
        oField.addGenericListener("keyup", this.adjustMask);
    }
    
    //  Check
    sCheck = oVdfForm.getVdfFieldAttribute(oField, "sCheck")
    if(sCheck != null && sCheck != ""){
        oField.setVdfAttribute("sCheck", sCheck);
        oField.addGenericListener("keyup", this.adjustCheck);
    }
}

//
//  Calls the clienside validation (if enabled) and if no client-side errors the
//  server-side validation (if enabled) is called.
//
//  Params:
//      oField          Field to validate
//      bValidateServer If false no server validation is done (optional, 
//                      default true)
//  Returns:
//      False if validation failed
// 
VdfValidator.prototype.validateField = function(oField, bValidateServer){
    var bResult = true;
    
    if(typeof(bValidateServer) == "undefined"){
        var bValidateServer = true;
    }
    
    if(this.oVdfForm.getVdfFieldAttribute(oField, "bValidateClient")){
        bResult = (bResult && this.validateFieldClient(oField));
    }
    
    if(this.oVdfForm.getVdfFieldAttribute(oField, "bValidateServer") && bValidateServer){
        bResult = (bResult && this.validateFieldServer(oField));
    }
    
    return bResult;
}

//
//  Validates the field on the server using the ValidateField call. Works 
//  asynchronous so the user isn't bothered too much. The data of the whole table 
//  is send to make validation valuable.
//
//  Params:
//      oField  The field that should be validated.
//  Returns:
//      True (because of asynchronous sending no result is known)
//
VdfValidator.prototype.validateFieldServer = function(oField){
    var oXmlRequest;
    var sXml = new JStringBuilder();

    //  Clear all errors on the field
    VdfErrorsClearField(oField.sTable, oField.sField);
    
    sXml.append("<tRequest>\n");
    sXml.append("    <sSessionKey>" + browser.cookie.get("vdfSessionKey") + "</sSessionKey>\n");
    sXml.append("    <sWebObject>" + this.oVdfForm.sWebObject + "</sWebObject>\n");
    sXml.append("    <sFieldName>" + oField.getTableName() + "." + oField.getFieldName() + "</sFieldName>\n");
    sXml.append("    <tRow>\n");
    sXml.append("        <aCols>\n");
    sXml.append(this.oVdfForm.getCurrentStatusXml());
    sXml.append(this.oVdfForm.aTables[oField.getTableName()].getDataXml(false, false));
    sXml.append("        </aCols>\n");
    sXml.append("    </tRow>\n");
    sXml.append("</tRequest>");
    
    oRequest = new comm.XmlRequest(true, "ValidateField", sXml.toString(), this.validateFieldServerHandler, this, this.oVdfForm.sWebServiceUrl);
    oRequest.oVdfField = oField;
    oRequest.request();
    
    return true;
}

//
//  Handles the result of the server side validation. If error occurred it is 
//  displayed (only if user hasn't changed the value already).
//
//  Params:
//      oRequest    The comm.XmlRequest object
//
//  PRIVATE
VdfValidator.prototype.validateFieldServerHandler = function(oRequest){
    var oResult, aErrors, iError, sField, oField;
    
    //  Check for request error (like vault error)
    if(oRequest.iError == 0){
        oResult = oRequest.getResponseXml();
        
        //  Check for validation 
        if(browser.xml.findNodeContent(oResult, "iError") != "0"){
            sField = browser.xml.findNodeContent(oResult, "sFieldName").replace(".", "__");
            oField = oRequest.oVdfField;
            
            //  Check if value isn't changed
            if(oField != null){
                if(oField.getValue() == browser.xml.findNodeContent(oResult, "sFieldValue")){
                    
                    //  Display the errors
                    aErrors = browser.xml.find(oResult, "TAjaxError");
                    if(aErrors.length > 0){
                        for(iError = 0; iError < aErrors.length; iError++){
                            VdfErrorHandle(new VdfServerError(aErrors[iError], this.oVdfForm, this));
                        }
                    }
                }
            }
        }
    }else{
        VdfErrorHandle(new VdfError(130, oRequest.sErrorMessage + "(Error: " + oRequest.iError + ")", null, null, this));
    }
}

//
//  Performes client-side validation.
//
//  Params:
//      oField  Field to validate
//  Returns:
//      False if validation failed
//      
VdfValidator.prototype.validateFieldClient = function(oField){
    var sMask, sCheck, iMaxLength, sMinValue, sMaxValue;
    var oVdfForm = this.oVdfForm;
    var sType = oVdfForm.getVdfFieldAttribute(oField, "sDataType");
    var bResult = true, bRequired = true;
    
    //  Clear all errors on the field
    VdfErrorsClearField(oField.sTable, oField.sField);
    
    //  Custom validation in onValidate event of VdfField
    bResult = (oField.onValidate(sType));
    
    //  Display only
    if(oVdfForm.getVdfFieldAttribute(oField, "bDisplayOnly")){
        bResult = (this.validateDisplayOnly(oField) && bResult);
    } 

    //  Find required
    if(bRequired &&  oVdfForm.getVdfFieldAttribute(oField, "bFindReq")){
        bRequired = this.validateFindRequired(oField, sType);
        
        bResult = (bRequired && bResult);
    }

    //  Required
    if(bRequired && oVdfForm.getVdfFieldAttribute(oField, "bRequired")){
        bRequired = this.validateRequired(oField, sType);
        bResult = (bRequired && bResult);
    }
    
    //  Type validation
    if(sType == "bcd"){
        bResult = (this.validateNumeric(oField, oVdfForm.oVdfInfo.sDecimalSeparator) && bResult);
    }else if(sType == "date"){
        bResult = (this.validateDate(oField, oVdfForm.oVdfInfo.sDateMask, this.getDateSeparator(oVdfForm.oVdfInfo.sDateMask)) && bResult);
    }
    
    //  Mask
//    sMask = oVdfForm.getVdfFieldAttribute(oField, "sMask");
//    if(sMask != null && sMask != ""){
//        bResult = (this.validateMask(oField, sMask) && bResult);
//    }
    
    //  Check
    sCheck = oVdfForm.getVdfFieldAttribute(oField, "sCheck");
    if(sCheck != null && sCheck != ""){
        bResult = (this.validateCheck(oField, sCheck) && bResult);
    }
    
    //  Maximum length
    if(sType == "bcd"){
        bResult = (this.validateMaxLengthNum(oField, oVdfForm.getVdfFieldAttribute(oField, "iDataLength"), oVdfForm.getVdfFieldAttribute(oField, "iPrecision"), oVdfForm.oVdfInfo.sDecimalSeparator) && bResult);
    }else{
        if(sType == "date"){
            iMaxLength = oVdfForm.oVdfInfo.sDateMask.length;
        }else{
            iMaxLength = oVdfForm.getVdfFieldAttribute(oField, "iDataLength");
        }
        
        bResult = (this.validateMaxLength(oField, iMaxLength) && bResult);
    }
    
    //  Range
    if(sType == "bcd"){
        sMinValue = oVdfForm.getVdfFieldAttribute(oField, "sMinValue");
        if(sMinValue != null && sMinValue != ""){
            bResult = (this.validateMinValue(oField, sMinValue) && bResult);
        }

        sMaxValue = oVdfForm.getVdfFieldAttribute(oField, "sMaxValue");
        if(sMaxValue != null && sMaxValue != ""){
            bResult = (this.validateMaxValue(oField, sMaxValue) && bResult);
        }
    }
    
    return bResult;
}

//
//  Gets the date mask separator from the mask
//
//  Params:
//      sMask   Mask
//  Returns:
//      Separator used in the mask
//
//  PRIVATE
VdfValidator.prototype.getDateSeparator = function(sMask){
    var iChar, sChar;
    
    for(iChar = 0; iChar < sMask.length; iChar++){
        sChar = sMask.toUpperCase().charAt(iChar);
        if(sChar != 'M' && sChar != 'D' && sChar != 'Y'){
            return sChar;
        }
    }
    
    return null;
}

//
//  Fetches onkeypres event from the form fields and validates if needed (on 
//  tab). Event is cancelled on validation errors.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
VdfValidator.prototype.onValidateField = function(e){
    var oSource,oVdfField, oVdfForm;
    
    if(!browser.events.canceled(e) && browser.events.getKeyCode(e) == 9 && !e.shiftKey){
        oSource = browser.events.getTarget(e);
        if(oSource == null) return false;
    
        oVdfField = oSource.oVdfField;
        if(oVdfField == null) return false;
        
        oVdfForm = oVdfField.oVdfForm;
    
        if(oVdfForm.oVdfValidator != null && !oVdfForm.oVdfValidator.validateField(oVdfField)){
            browser.events.stop(e);
            return false;
        }
    }
    
    return true;
}
