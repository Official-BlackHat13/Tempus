//
//  Class:
//      comm.XmlRequest
//
//  The XmlRequest contains the functionality to do XmlRequests in a standard
//  way. It can be used for both asynchronous and synchronous proccesing. When 
//  synchronous the request functions waits for response, asynchronous returns and
//  calls return function (if set) with the XmlRequest itself as parameter.
//
//  If sFunction is given the object asumes that the called url is an 
//  webservice and wraps the request xml in an soap envelope. It will also scan
//  the result for soap faults. If no function and no xml is given the request 
//  will be a GET request instead of the usual POST request.
//  
//  Since:      
//      08-2005
//  Changed:
//      --
//  Version:    
//      0.9
//  Creator:    
//      Data Access Europe (Harm Wibier)
//

if(typeof(comm) != "Object"){
    var comm = new Object();
}

comm.REQUEST_STATE_UNITIALIZED  = 0;
comm.REQUEST_STATE_LOADING      = 1;
comm.REQUEST_STATE_LOADED       = 2;
comm.REQUEST_STATE_INTERACTIVE  = 3;
comm.REQUEST_STATE_COMPLETE     = 4;

//
//  Constructor of XmlRequest object, initializes the attributes using the 
//  given (not required) values or the defaults.
// 
//  Params:
//      bASynchronous   True if request should be send ASyncronous
//      sFunction       Function to be called (if null or not given request 
//                      won't be threated as a soap call)
//      sXML            XML to be send with the request
//      oReturnFunction Function to call when request is finished
//      oSource         Source object (becomes  context when calling 
//                      returnfunction)
//      sRequestURL     Request URL (optional, default: "WebService.wso")
//      sXmlNS          The namespace for the webservice (optional, default: 
//                      "http://tempuri.org/")
//      
comm.XmlRequest = function(bASynchronous, sFunction, sXML, oReturnFunction, oSource, sRequestURL, sXmlNS){
    this.bASynchronous      = bASynchronous;
    this.sFunction          = (sFunction) ? sFunction : null;
    this.sXML               = (sXML) ? sXML : null;
    this.oReturnFunction    = (oReturnFunction) ? oReturnFunction : null;
    this.oSource            = (oSource) ? oSource : null;
    this.sRequestURL        = (sRequestURL) ? sRequestURL : "WebService.wso";
    this.sXmlNS             = (sXmlNS) ? sXmlNS : "http://tempuri.org/";
    
    this.oLoader            = null;
    
    this.iError             = 0;
    this.sErrorMessage      = null;    
}

   
//
//  Creates the request object, does its settings and sends the request.
//
comm.XmlRequest.prototype.request = function(){
    var oXmlRequest = this;
    
    this.oLoader = browser.xml.getXMLRequestObject();
    
    //  If asynchronousattach onreadystatechange function (if synchronous it
    //  is called mannualy)
    if(this.bASynchronous){
        this.oLoader.onreadystatechange = function(){
            try{
                oXmlRequest.onReadyStateChange.call(oXmlRequest);
            }catch(oError){
                VdfErrorHandle(oError);
            }
        }
    }

    //  Open connection, set headers, send request
    this.oLoader.open((this.sXML) ? "POST" : "GET", this.completeRequestURL(), this.bASynchronous);
    if(this.sXML){
        this.oLoader.setRequestHeader("Content-Type", "text/xml");
    }
    this.oLoader.send(this.completeXML());
    
    //  If synchronous request call readyStateChange manually (IE won't do 
    //  it)
    if(!this.bASynchronous){
        this.onReadyStateChange();
    }
}

//
//  Called when the state of the request object changes. Checks if request
//  is complete and if so it handles it by checking for errors and if 
//  neccessary call the handling method.
//
comm.XmlRequest.prototype.onReadyStateChange = function(){
    if(this.oLoader.readyState == comm.REQUEST_STATE_COMPLETE){

        //  Check if load succesfull
        if(this.oLoader.status < 300 || this.oLoader.status == 500){
            this.iError = this.checkErrors();
        }else{
            this.iError = 503;
            this.sErrorMessage = "Received HTTP error: " + this.oLoader.status + " " + this.oLoader.statusText;
        }
        
        // Call returnfunction (if given) with source (if given) as context
        // and this request object as parameter
        if(this.oReturnFunction){
            this.oReturnFunction.call(((this.oSource) ? this.oSource : this), this);
        }
    }
}

//
//  Checks if any webservice errors are returned (if an webservice has 
//  been called). Sets the errormessage and returns the errornumber.
//
//  Returns:
//      Error number (0 if no errors found)
//
comm.XmlRequest.prototype.checkErrors = function(){
    var iResult = 0;
    
    //  Only do checks if funtion is called
    if(this.sFunction){
        
        //  Check if valid xml (if parsed)
        if(this.oLoader.responseXML != null){
            var iLoop, sMsg, oXmlNode, sPreName;
            
            //  Internet Explorer only finds with the full name while other browsers 
            //  (tested with firefox 1.0.x) only find without "m:"
            if(browser.isIE){
                sPreName = "soap:";
            }else{
                sPreName = "";
            }
            
            //  Check for soap errors 
            var aErrors = this.oLoader.responseXML.getElementsByTagName(sPreName + "Fault");
            
            if(aErrors.length == 0){
                
                //  Check if response body is found
                if(browser.xml.findFirst(this.oLoader.responseXML, this.sFunction + "Response") == null){
                    this.sErrorMessage = "Could not find response body!";
                    iResult = 501;
                }
            
            
            }else{
                this.sErrorMessage = "";
                //  Generate soap error message
                for(iLoop = 0; iLoop < aErrors.length; iLoop++){
                    if(this.sErrorMessage != ""){
                        this.sErrorMessage += "\n";
                    }
                    
                    this.sErrorMessage += browser.xml.findNodeContent(aErrors[iLoop], "faultstring");            
                }
                
                iResult = 500;
            }

            
        }else{
            this.sErrorMessage = "Could not parse response xml!";
            iResult = 502;
        }
    }
    
    return iResult;
}

//
//  Generates the url used for the request. (if it is relative it makes it 
//  absolute using the value of the addressbar)
//
//  Returns:
//      Complete url for the request
//
comm.XmlRequest.prototype.completeRequestURL = function(){
    var sPath;
    
    //  Dynamically find the path to post the data to
    if(this.sRequestURL.substr(0,7).toLowerCase() != "http://"){
        
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
        if (this.sRequestURL.substr(0, 1) != "/"){
            this.sRequestURL = sPath + "/" + this.sRequestURL ;
        }else{
            this.sRequestURL = sPath + this.sRequestURL;
        }
    }
    
    return this.sRequestURL;
}

//
//  Completes the Xml request with the soap envelope if an webservice 
//  function name has been given.
//
//  Returns:
//      The complete XML request message
//        
comm.XmlRequest.prototype.completeXML = function(){
    if(this.sFunction){
        var sResult = new JStringBuilder();
        
        sResult.append('<?xml version="1.0" encoding="utf-8"?>\n');
        sResult.append('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">\n');
        sResult.append("<soap:Body>\n");
        sResult.append("<" + this.sFunction + ' xmlns="' + this.sXmlNS + '">\n');
        sResult.append(this.sXML);
        sResult.append("</" + this.sFunction + ">\n");
        sResult.append("</soap:Body>\n");
        sResult.append("</soap:Envelope>\n");
        
        this.sXML = sResult.toString();
    }
    
    return this.sXML;
}

//
//  Returns the response xml document.
//
//  Returns:
//      Response xml document. Null if not available.
//
comm.XmlRequest.prototype.getResponseXml = function(){
    if(this.sFunction){
        return browser.xml.findFirst(this.oLoader.responseXML, this.sFunction + "Response");
    }else{
        return this.oLoader.responseXML;
    }
}