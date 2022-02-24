if(!DR){
    var DR = { };
}

DR.sVersion = "6.2.3.191";

DFERR_DATAFLEX_REPORTS = 4425;

C_TBCENTER = 0;
C_TBRIGHT = 1;
C_TBLEFT = 2;

DR.WebReportViewer = function WebReportViewer(oDef, oParent){
    DR.WebReportViewer.base.constructor.call(this, oDef, oParent);

    // Get the server version of the control
    this.prop(df.tString, "psVersion", "");

    this.prop(df.tInt, "piZoom", 100);
    this.prop(df.tInt, "piPage", 0);
    this.prop(df.tInt, "piPageCount", 0);

    this.prop(df.tBool, "pbShowToolbar", true);
    this.prop(df.tBool, "pbShowPrintButton", true);

    this.event("OnOpenReport", df.cCallModeDefault);
    this.event("OnPageChange", df.cCallModeDefault);
    this.event("OnClickActionLink", df.cCallModeWait);

    this.prop(df.tInt, "peToolbarAlignment", 0);

    this.prop(df.tInt, "peMode", 0);

    this.addSync('piPage');
    this.addSync('piPageCount');

    this._sReportHtml = null;

    this._eIframe = null;
    this._eViewHtml = null;
    this._eViewBody = null;
    this._eViewPort = null;
    this._eViewSizer = null;
    this._eToolbar = null;
    this._eToolbarTotalPages = null;
    this._eToolbarCurrentPageInput = null;
    this._eToolbarPrintButton = null;

    this._aPages = null;

    this._sControlClass = "DRViewer";
    
    this._sTheme = null;
};

df.defineClass("DR.WebReportViewer", "df.WebHtmlBox", {
/*
During object creation check if the server version of the control matches with the client version
*/
create : function(){
    DR.WebReportViewer.base.create.apply(this, arguments);

    if(this.psVersion != DR.sVersion) {
        throw new df.Error(DFERR_DATAFLEX_REPORTS, "Version number mismatch in the DataFlex Reports previewer.\nClient: {{0}}. \nServer: {{1}}. \n \nRefresh your cache to update the control.", this, [ DR.sVersion, this.psVersion ]);
    }
},

/*
This method augments the html generation and adds the iframe element and optionally a tool-bar.

@param  aHtml   String builder array containing html.

@private
*/
openHtml : function(aHtml){
    DR.WebReportViewer.base.openHtml.call(this, aHtml);

    if(this.pbShowToolbar){
        aHtml.push(this.createToolbar());
    }

    aHtml.push('<iframe class="DR_Frame">');
},

/*
This method augments the html generation and closes the iframe element.

@param  aHtml   String builder array containing html.

@private
*/
closeHtml : function(aHtml){
    aHtml.push('</iframe>');

    DR.WebReportViewer.base.closeHtml.call(this, aHtml);
},

afterRender : function(){
    var that = this;

    DR.WebReportViewer.base.afterRender.call(this);

    this._eIframe = df.dom.query(this._eElem, "iframe.DR_Frame");

    if(this._eIframe.contentWindow){
        this.initIframe();
    }else{
        this._eIframe.onload = function(){
            that.initIframe();
        };
    }
},

webviewerScriptPath : function(){
    var sCurrentPath, i, aScriptTags, aSourcePart;
    
    // locate the folder with previewer.js and assume all CSS files needed
    // for the previewer are in the CssThemes and CssThemes\ThemeName subfolders
    aScriptTags = document.getElementsByTagName("Script");

    for(i = 0; i < aScriptTags.length; i++){
        aSourcePart = aScriptTags[i].src.split("/");
        if(aSourcePart[aSourcePart.length-1].toLowerCase() == "previewer.js"){
            aSourcePart.pop();
            sCurrentPath = aSourcePart.join("/");
            sCurrentPath += "/";
        }
    }
    
    return sCurrentPath;
},

// While there will be other situations this event is called when the theme changes.
resizeHorizontal : function(){
    var eWebApp = this.getWebApp(), i;
    
    if (this._sTheme != eWebApp.psTheme){
        var sCurrentPath = this.webviewerScriptPath();
        this.isThemeCSSLoaded(sCurrentPath);
    }    
    
    //  Call children
    for(i = 0; i < this._aChildren.length; i++){
        if(this._aChildren[i] instanceof df.WebBaseUIObject && !(this._aChildren[i] instanceof df.WebView)){ //  Skip views, they are called by the WebApp
            if(this._aChildren[i].pbRender && this._aChildren[i].resizeHorizontal){                
                this._aChildren[i].resizeHorizontal();
            }
        }
    }
},

isThemeCSSLoaded : function(sCurrentPath){
    var eHead, eWebApp, aStyles, i;
    var bThemeLoaded = false, sV, sWebAppTheme, eTheme;
    var sLocalTheme, eCurrentTheme, eInsertAfter;

    // Determine the head element of the main document (often index.html)
    // Check if the previewer.css for the current web application style is loaded
    // if it is not loaded, then dynamically load this. Note that on a theme change
    // the styles of an earlier loaded theme are not unloaded or destroyed
    eHead = document.head || document.getElementsByTagName("head")[0];
    if (eHead) {
        eWebApp = this.getWebApp();
        sWebAppTheme = eWebApp.psTheme;
        sLocalTheme = this._sTheme;
        if(sLocalTheme){
            sLocalTheme = sLocalTheme.toLowerCase();
        }
        aStyles = df.dom.query(document, "link", true);
        for(i = 0; i < aStyles.length && bThemeLoaded === false; i++){
            if(aStyles[i].href.toLowerCase().indexOf("cssthemes/reportviewer.css") > 0){
                eInsertAfter = aStyles[i];
            }
            // Check if local stored theme is loaded
            if(sLocalTheme){
                if(aStyles[i].href.toLowerCase().indexOf("cssthemes/" + sLocalTheme + "/previewer.css") > 0){
                    eCurrentTheme = aStyles[i];
                }
            }
            // Check if current web framework theme is loaded
            if(aStyles[i].href.toLowerCase().indexOf("cssthemes/" + sWebAppTheme + "/previewer.css") > 0){
                bThemeLoaded = true;
            }
        }
        if (bThemeLoaded === false) {
            sV = "?v=" + df.psVersionId + "." + DR.sVersion;
            eTheme = df.dom.createCSSElem(sCurrentPath + "CssThemes/" + sWebAppTheme + "/previewer.css" + sV);
            if (eTheme) {
                if (eCurrentTheme) {
                    df.dom.swapNodes(eCurrentTheme,eTheme);
                }else{
                    if (!eInsertAfter){
                        eInsertAfter = eHead.lastChild;
                    }
                    df.dom.insertAfter(eTheme, eInsertAfter);
                }
            }
        }
        this._sTheme = sWebAppTheme;
    }
},

initIframe : function(){
    var aHtml = [], sCurrentPath;

    sCurrentPath = this.webviewerScriptPath();
    
    this.isThemeCSSLoaded(sCurrentPath);

    //  Write the viewer HTML
    aHtml.push('<!DOCTYPE HTML>');
    aHtml.push('<html moznomarginboxes>');
    aHtml.push('<head>');
    aHtml.push('<meta http-equiv="Content-Type" content="text/html;charset=utf-8">');
    aHtml.push('<title>Report Preview</title>');
    aHtml.push('<link href="',sCurrentPath,'CssThemes/PreviewerCommon.css" rel="stylesheet" type="text/css" />');
    aHtml.push('</head>');
    aHtml.push('<body class="DR_Body">');
    aHtml.push('<div class="DR_Print"></div>');
    aHtml.push('<div class="DR_Screen">');
    aHtml.push('<div class="DR_ViewPort">');
    aHtml.push('<div class="DR_Sizer">');
    aHtml.push('</div>');
    aHtml.push('</div>');
    aHtml.push('</div>');
    aHtml.push('</body>');
    aHtml.push('</html>');

    this._eIframe.contentWindow.document.write(aHtml.join(""));
    this._eIframe.contentWindow.document.close();

    this._eViewBody = this._eIframe.contentWindow.document.body;
    this._eViewWindow = this._eViewBody.parentNode;
    this._eViewPrint = df.dom.query(this._eViewBody, "div.DR_Print");
    this._eViewScreen = df.dom.query(this._eViewBody, "div.DR_Screen");
    this._eViewPort = df.dom.query(this._eViewBody, "div.DR_ViewPort");
    this._eViewSizer = df.dom.query(this._eViewBody, "div.DR_Sizer");

    if(this._sReportHtml) {
        this.refreshPreview();
    }

    if(this.pbShowToolbar){
        this.initToolbar();
        //remove the opacity so the tool-bar disappears
        this._eToolbar.style.opacity="";
        this.updateToolbar();
    }

    this.set_piZoom(this.piZoom);

    df.events.addDomListener("scroll", this._eIframe.contentWindow , this.onScroll, this);
    df.events.addDomListener("click", this._eViewSizer, this.clickActionLink, this);
},

createToolbar : function(){
    var aToolbarHtml = [];

    switch(this.peToolbarAlignment){
        case C_TBRIGHT:
            aToolbarHtml.push('<div class="DR_Toolbar" style="opacity:1; right: 0px; padding-right: 0px">');
            break;
        case C_TBLEFT:
            aToolbarHtml.push('<div class="DR_Toolbar" style="opacity:1; margin-left: 0px; left: 0px;">');
            break;
        default:
            aToolbarHtml.push('<div class="DR_Toolbar" style="opacity:1; left: 50%;">');
            break;
    }

    aToolbarHtml.push('<div class="DR_Inner clearfix">');

    aToolbarHtml.push('<div class="DR_Wrapper ', (this.pbShowPrintButton ? '' : 'DR_Hidden'), '">');
    aToolbarHtml.push('<div class="DR_PrintButton"></div>');
    aToolbarHtml.push('</div>');

    aToolbarHtml.push('<div class="DR_Separator ', (this.pbShowPrintButton ? '' : 'DR_Hidden'), '"></div>');
    aToolbarHtml.push('<div class="DR_Wrapper">');
    aToolbarHtml.push('<div class="DR_PreviousButton"></div>');
    aToolbarHtml.push('</div>');
    aToolbarHtml.push('<div class="DR_Wrapper">');
    aToolbarHtml.push('<div class="DR_NextButton"></div>');
    aToolbarHtml.push('</div>');
    aToolbarHtml.push('<div class="DR_Separator"></div>');
    aToolbarHtml.push('<div class="DR_PageIndicator">');
    aToolbarHtml.push('<input type="text" size="1px" class="DR_CurrentPage" value="0"/>');
    aToolbarHtml.push('<p class="DR_PageSeparator">/</p>');
    aToolbarHtml.push('<p class="DR_LastPage">',this.get_piPageCount(),'</p>');
    aToolbarHtml.push('</div>');
    aToolbarHtml.push('<div class="DR_Separator"></div>');
    aToolbarHtml.push('<div class="DR_Wrapper">');
    aToolbarHtml.push('<div class="DR_ZoomOutButton"></div>');
    aToolbarHtml.push('</div>');
    aToolbarHtml.push('<div class="DR_Wrapper">');
    aToolbarHtml.push('<div class="DR_ZoomInButton"></div>');
    aToolbarHtml.push('</div>');
    aToolbarHtml.push('</div>');
    aToolbarHtml.push('</div>');

    return aToolbarHtml.join("");
},

initToolbar : function(){
    var eButton = null;

    this._eToolbar = df.dom.query(this._eElem, "div.DR_Toolbar");
    this._eToolbarTotalPages = df.dom.query(this._eToolbar, "p.DR_LastPage");
    this._eToolbarCurrentPageInput = df.dom.query(this._eToolbar, "input.DR_CurrentPage");
    this._eToolbarPrintButton = df.dom.query(this._eToolbar, "div.DR_PrintButton");

    //print button
    if(this.pbShowPrintButton && this._eToolbarPrintButton){
        df.events.addDomListener("click", this._eToolbarPrintButton, this.printReport, this);
    }

    // Previous button
    eButton = df.dom.query(this._eToolbar, "div.DR_PreviousButton");
    if (eButton){
        df.events.addDomListener("click", eButton, this.previousPage, this);
    }

    // Next button
    eButton = df.dom.query(this._eToolbar, "div.DR_NextButton");
    if (eButton){
        df.events.addDomListener("click", eButton, this.nextPage, this);
    }

    // Zoom in button
    eButton = df.dom.query(this._eToolbar, "div.DR_ZoomOutButton");
    if (eButton){
        df.events.addDomListener("click", eButton, this.zoomOut, this);
    }

    // Zoom out button
    eButton = df.dom.query(this._eToolbar, "div.DR_ZoomInButton");
    if (eButton){
        df.events.addDomListener("click", eButton, this.zoomIn, this);
    }

    if (this._eToolbarCurrentPageInput){
        df.events.addDomListener("click", this._eToolbarCurrentPageInput, this.currentPageClick, this);
    
        df.events.addDomListener("focus", this._eToolbarCurrentPageInput, function(){
            df.events.addDomKeyListener(this._eToolbarCurrentPageInput, this.onKey, this);
        }, this);

        df.events.addDomListener("blur", this._eToolbarCurrentPageInput, function(){
            df.events.removeDomKeyListener(this._eToolbarCurrentPageInput, this.onKey, this);
            this._eToolbarCurrentPageInput.value = this.get_piPage();
            df.dom.removeClass(this._eToolbar, "active");
        }, this);
    }
},

updateToolbar : function(){
    if(this._eToolbar){
        this._eToolbarCurrentPageInput.value = this.get_piPage();
        this._eToolbarTotalPages.innerHTML = this.get_piPageCount();
    }
},

currentPageClick : function(){
    df.dom.addClass(this._eToolbar, "active");
    this._eToolbarCurrentPageInput.focus();
    this._eToolbarCurrentPageInput.select();
},

onKey : function(oEvent){
    if(oEvent.getKeyCode() === 13){
        this.updateCurrentPage(this._eToolbarCurrentPageInput.value);
    }
},

refreshPreview : function(){
    if(this._eViewSizer){
        this._eViewSizer.innerHTML = this._sReportHtml;
        this.recalcSize();

        this._aPages = df.dom.query(this._eViewSizer, "div.page", true);
    }
},

updateCurrentPage: function(iNewPage){
    if(iNewPage){
        if(iNewPage > this.get_piPageCount()){
            iNewPage = this.get_piPageCount();
        }else if(iNewPage < 1){
            iNewPage = 1;
        }
        this.set_piPage(iNewPage);
    }

    this.updateToolbar();
},

nextPage : function(){
    var iCurrentPage = this.get_piPage();

    if(iCurrentPage !== this.get_piPageCount()){
        iCurrentPage++;
        this.set_piPage(iCurrentPage);
        if(this._eToolbarCurrentPageInput){
            this._eToolbarCurrentPageInput.value = iCurrentPage;
        }
    }
},

previousPage : function(){
    var iCurrentPage = this.get_piPage();

    if(iCurrentPage !== 1){
        iCurrentPage--;
        this.set_piPage(iCurrentPage);
        if(this._eToolbarCurrentPageInput){
            this._eToolbarCurrentPageInput.value = iCurrentPage;
        }
    }
},

zoomIn : function(){
    this.piZoom += 10;
    this.set_piZoom(this.piZoom);
},

zoomOut : function(){
    if(this.piZoom !== 10){
        this.piZoom -= 10;
        this.set_piZoom(this.piZoom);
    }
},

deserializeVT : df.sys.vt.generateDeserializer([df.tString]),

showReport : function(){
    var i, j, aReportData, aPageData, reportHtml = "";

    if(this.peMode === 0){
		aReportData = this._tActionData.c;
        if(aReportData.length > 0){
		    for(i = 0; i < aReportData.length; i++){
			    aPageData = this.deserializeVT(aReportData[i]);
			    for(j = 0; j < aPageData.length; j++){
				    reportHtml += Base64.decode(aPageData[j]);
		        }
	        }
			this._sReportHtml = reportHtml;
            this.refreshPreview();
            this.piPage = this.get_piPage();
            this.fire('OnOpenReport');

            this.updateToolbar();
        }else{
            throw new df.Error(DFERR_DATAFLEX_REPORTS, "No HTML data received.");
        }
    }else{
		aReportData = this.deserializeVT(this._tActionData);
		if(aReportData.length > 0){
            for(i = 0; i < aReportData.length; i++){
                reportHtml += "<div class='page' style='position: relative;'>";
                reportHtml += "<img src='"+aReportData[i]+"' width='100%' height='100%'>";
                reportHtml += "</div>";
            }
            this._sReportHtml = reportHtml;
            this.refreshPreview();
			this.piPage = this.get_piPage();
			this.fire('OnOpenReport');
			
            this.updateToolbar();
        }else{
            throw new df.Error(DFERR_DATAFLEX_REPORTS, "No image data received.");
		}
    }
},

clickActionLink : function(oEvent){
    var eElem = oEvent.getTarget(), eDataType, sData = null;

    while(eElem && eElem !== this._eViewSizer){
        if(eElem.className === "DR_Click"){
            eDataType = eElem.getAttribute("data-drtype");
            sData = df.dom.getText(eElem);
            this.fire('OnClickActionLink', [ sData , eDataType ]);
            return false;
        }
        eElem = eElem.parentNode;
    }
},

printReport : function(){
    if(this._aPages && this._aPages.length > 0){
        var that = this;

        this._eViewScreen.style.display = "none";
        this._eViewPrint.innerHTML = this._sReportHtml;
        this._eViewPrint.style.display = "";

        if(this.peMode === 0){
            that.doPrint();
        }else {
            if (this._eViewSizer){
                var iPages = df.dom.query(this._eViewSizer,"img",true).length;
                setTimeout(function(){
                    that.doPrint();
                }, iPages >= 2 ? iPages * 50 : 100);
            }
        }
    }else{
        throw new df.Error(DFERR_DATAFLEX_REPORTS, "Nothing to print!", this);
    }
},

doPrint : function(){
    if(df.sys.isIE){
        this._eIframe.contentWindow.focus();
    }
    this._eIframe.contentWindow.print();

    this._eViewPrint.style.display = "none";
    this._eViewScreen.style.display = "";
},

set_piZoom : function(iVal){
    var sTransform, nScale, eElem = this._eViewSizer;
	
    if(this._eViewSizer && this._eViewPort){
        nScale = iVal / 100;
        sTransform = "scale(" + nScale + ", " + nScale + ")";

        if(typeof(this._eViewPort.style.transform) !== "undefined"){
            eElem.style.transform = sTransform;
        }else if(typeof(eElem.style.WebkitTransform) !== "undefined"){
            eElem.style.WebkitTransform = sTransform;
        }else if(typeof(eElem.style.msTransform) !== "undefined"){
            eElem.style.msTransform = sTransform;
        }else if(typeof(eElem.style.MozTransform) !== "undefined"){
            eElem.style.MozTransform = sTransform;
        }else if(typeof(eElem.style.OTransform) !== "undefined"){
            eElem.style.OTransform = sTransform;
        }
        this.piZoom = iVal;
        this.recalcSize();
	}
},

set_piPage : function(iPage){
    var iScroll = 0;

    if(this._aPages && this._aPages.length > 0 && this._eViewWindow){
        iPage--;
        if(iPage < 0){
            iPage = 0;
        }else {
            if(iPage >= this._aPages.length){
                iPage = this._aPages.length;
                iPage--;
            }
        }
        iScroll = Math.round(this._aPages[iPage].offsetTop * (this.piZoom / 100));
        this._eViewWindow.scrollTop = iScroll;
    }
},

get_piPage : function(){
    var iPage = 0, iScroll, iDivider = 1;

    if(this._aPages && this._aPages.length > 0 && this._eViewWindow){
        iScroll = this._eViewWindow.scrollTop;

        iDivider = (this._aPages[0].offsetHeight * (this.piZoom / 100));
        iPage = Math.floor(iScroll / iDivider) + 1;

        if(iPage > this._aPages.length){
            iPage = this._aPages.length;
        }
    }

    return iPage;
},

get_piPageCount : function(){
    if(this._aPages){
        return this._aPages.length;
    }
    return 0;
},

recalcSize : function(){
    var that = this;

    if(this.peMode === 0){
        setTimeout(function(){
            that.doRecalcSize();
        }, 20);
    }
    else {
        if (this._eViewSizer){
            var iPages = df.dom.query(this._eViewSizer,"img",true).length;
            setTimeout(function(){
                that.doRecalcSize();
            }, iPages >= 2 ? iPages * 50 : 100);
        }
    }
},

doRecalcSize : function(){
    var iTopOffset, iZoomHeight, iZoomWidth, iRealHeight, iRealWidth, iLeftOffset, iCenterOffset;

    if(this._eViewPort){
        iRealHeight = this._eViewSizer.clientHeight;
        iRealWidth = this._eViewSizer.clientWidth;

        if(iRealHeight > 0 && iRealWidth > 0){
            iZoomHeight = (iRealHeight * (this.piZoom / 100));
            iZoomWidth = (iRealWidth * (this.piZoom / 100));

            iTopOffset = (iZoomHeight - iRealHeight) / 2;
            iLeftOffset = (iZoomWidth - iRealWidth) / 2;

            this._eViewSizer.style.top = iTopOffset + "px";
            this._eViewSizer.style.left = iLeftOffset + "px";

            this._eViewPort.style.height = iZoomHeight + "px";
            this._eViewPort.style.width = iZoomWidth + "px";

            iCenterOffset = (this._eViewPort.parentNode.clientWidth - iZoomWidth) / 2;

            this._eViewPort.style.marginLeft = (iCenterOffset > 0 ? iCenterOffset + "px" : "");
        }
    }
},

onScroll : function(oEvent){
    if(this.get_piPage() !== this.piPage){
        this.piPage = this.get_piPage;
        this.fire('OnPageChange');
        this.updateToolbar();
    }
},

updateHtml : function(){
},

set_pbShowPrintButton : function(bVal){
    if(this._eToolbarPrintButton){
        df.dom.toggleClass(this._eToolbarPrintButton.parentNode, "DR_Hidden", bVal);
    }
},

set_pbShowToolbar: function(bVal){
    if(this._eControl){
        if(bVal){
            if(!this._eToolbar){
                this._eToolbar = df.dom.create(this.createToolbar());
                if(this._eControl.firstChild){
                    this._eControl.insertBefore(this._eToolbar, this._eControl.firstChild);
                }else{
                    this._eControl.appendChild(this._eToolbar);
                }
                this.initToolbar();
                this.updateToolbar();
                //remove the opacity so the tool-bar disappears
                this._eToolbar.style.opacity="";
            }else{
                df.dom.removeClass(this._eToolbar, "invisible");
            }
        }else if(this._eToolbar){
            df.dom.addClass(this._eToolbar, "invisible");
        }
    }
}
}
);

var Base64 = {
// private property
_keyStr : "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",

// public method for encoding
encode : function (input) {
    var output = "";
    var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
    var i = 0;

    input = Base64._utf8_encode(input);

    while (i < input.length) {

        chr1 = input.charCodeAt(i++);
        chr2 = input.charCodeAt(i++);
        chr3 = input.charCodeAt(i++);

        enc1 = chr1 >> 2;
        enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
        enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
        enc4 = chr3 & 63;

        if (isNaN(chr2)) {
            enc3 = enc4 = 64;
        } else if (isNaN(chr3)) {
            enc4 = 64;
        }

        output = output +
        this._keyStr.charAt(enc1) + this._keyStr.charAt(enc2) +
        this._keyStr.charAt(enc3) + this._keyStr.charAt(enc4);

    }

    return output;
},

// public method for decoding
decode : function (input) {
    var output = "";
    var chr1, chr2, chr3;
    var enc1, enc2, enc3, enc4;
    var i = 0;

    input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");

    while (i < input.length) {

        enc1 = this._keyStr.indexOf(input.charAt(i++));
        enc2 = this._keyStr.indexOf(input.charAt(i++));
        enc3 = this._keyStr.indexOf(input.charAt(i++));
        enc4 = this._keyStr.indexOf(input.charAt(i++));

        chr1 = (enc1 << 2) | (enc2 >> 4);
        chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
        chr3 = ((enc3 & 3) << 6) | enc4;

        output = output + String.fromCharCode(chr1);

        if (enc3 != 64) {
            output = output + String.fromCharCode(chr2);
        }
        if (enc4 != 64) {
            output = output + String.fromCharCode(chr3);
        }

    }

    output = Base64._utf8_decode(output);

    return output;
},

// private method for UTF-8 encoding
_utf8_encode : function (string) {
    string = string.replace(/\r\n/g,"\n");
    var utftext = "";

    for (var n = 0; n < string.length; n++) {
        var c = string.charCodeAt(n);
        if (c < 128) {
            utftext += String.fromCharCode(c);
        }
        else if((c > 127) && (c < 2048)) {
            utftext += String.fromCharCode((c >> 6) | 192);
            utftext += String.fromCharCode((c & 63) | 128);
        }
        else {
            utftext += String.fromCharCode((c >> 12) | 224);
            utftext += String.fromCharCode(((c >> 6) & 63) | 128);
            utftext += String.fromCharCode((c & 63) | 128);
        }
    }

    return utftext;
},

// private method for UTF-8 decoding
_utf8_decode : function (utftext) {
    var string = "";
    var i = 0;
    var c = c1 = c2 = 0;

    while ( i < utftext.length ) {
        c = utftext.charCodeAt(i);
        if (c < 128) {
            string += String.fromCharCode(c);
            i++;
        }
        else if((c > 191) && (c < 224)) {
            c2 = utftext.charCodeAt(i+1);
            string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
            i += 2;
        }
        else {
            c2 = utftext.charCodeAt(i+1);
            c3 = utftext.charCodeAt(i+2);
            string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
            i += 3;
        }
    }

    return string;
}
}