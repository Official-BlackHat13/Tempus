//
//  Class:
//      JTabMenu
//
//  Used for generating tabpages. Should be simplified!
//
//  Since:
//      11-07-06
//  Changed:
//      --
//  Version:
//      0.9
//  Creator:
//      Data Access Europe (Harm Wibier)
//

//  Attach scan method to load event
browser.events.addGenericListener("load", window, scanJTabMenu);

//  
//  Scans through the tables searching for JControlType tags and create 
//  JTabMenu object for each table with "tabmenu" controltype.
//
function scanJTabMenu(){
    var oTabMenu, oMainTable = document.getElementById("JTabMenu");

    if(oMainTable != null && typeof(oMainTable.oJTabMenu) == "undefined"){
        oTabMenu = new JTabMenu(oMainTable);
        oTabMenu.init();
    }
}

//
//  Constructor that intializes the attributes.
//
//  Params:
//      oMainTable  The table containing the components
//
function JTabMenu(oMainTable){
    //  Main references
    this.oMainTable             = oMainTable;
    this.oMainTable.oJTabMenu   = this;
    this.oContainer             = null;
    
    this.sSelectedName          = "";
    
    //  Data structures
    this.aTabPages              = new Object();
    this.oDisplayFirst          = null;
}

//
//  Initializes the tabmenu
//
JTabMenu.prototype.init = function(){
    //  Scan for the needed components
    this.scanTabs(this.oMainTable);
    
    //  Initialize the components
    this.initComponents();
    
    //  Display the first tab
    if(this.oDisplayFirst != null){
        this.displayTab(this.oDisplayFirst);
    }
}

//
//  Loops recursive through the table searching for JTabComponents and 
//  administrates the found objects.
//
//  Params:
//      oElement    The current element
//
//  PRIVATE
JTabMenu.prototype.scanTabs = function(oElement){
    var oHeader, iChild, sTabName, oContainer;
    
    oHeader = document.getElementById("JTabMenuHeader");
    
    for(iChild = 0; iChild < oHeader.childNodes.length; iChild++){
        if(oHeader.childNodes[iChild].nodeType != 3 && oHeader.childNodes[iChild].nodeType != 8){
            sTabName = oHeader.childNodes[iChild].getAttribute("JTabName");
            if(sTabName != null){
                this.aTabPages[sTabName] = new Object();
                this.aTabPages[sTabName].oButton = oHeader.childNodes[iChild];
            }
        }
    }
    
    oContainer = document.getElementById("JTabMenuContent");
    
    for(iChild = 0; iChild < oContainer.childNodes.length; iChild++){
        if(oContainer.childNodes[iChild].nodeType != 3 && oContainer.childNodes[iChild].nodeType != 8){
            sTabName = oContainer.childNodes[iChild].getAttribute("JTabName");
            if(sTabName != null){
                this.aTabPages[sTabName].oTab = oContainer.childNodes[iChild];
                oContainer.childNodes[iChild].style.visibility = "hidden";
            }
        }
    }
    this.oContainer = oContainer;
}

//
//  Loop through tabs to attach events and find the highest tab.
//
//  PRIVATE
JTabMenu.prototype.initComponents = function(){
    var iMaxHeight = 0, iMaxWidth = 0, sName, oTab;
    
    for(sName in this.aTabPages){
        
        oTab = this.aTabPages[sName];
        
        //  Attach listener and fetch origional class
        if(oTab.oButton != null){
            oTab.oButton.oJTabMenu = this;
            browser.events.addGenericListener("click", oTab.oButton, this.onButtonClick);
            oTab.sOrigClassName = oTab.oButton.className;
        }
        
        //  Get height of content and hide
        if(oTab.oTab != null){
            if(oTab.oTab.offsetHeight > iMaxHeight){
                iMaxHeight = oTab.oTab.offsetHeight;
            }
            if(oTab.oTab.offsetWidth > iMaxWidth){
                iMaxWidth = oTab.oTab.offsetWidth;
            }
            
            oTab.oTab.style.display = "none";
            oTab.oTab.style.visibility = "";
        }
        
        //  Remember first tab
        if(this.oDisplayFirst == null){
            this.oDisplayFirst = oTab;
        }
    }
    
    //  Set container height
    if(this.oContainer != null){
        this.oContainer.style.height = (iMaxHeight + 30) + "px";
        if(this.oContainer.offsetWidth < iMaxWidth){
            this.oContainer.style.width = (iMaxWidth + 20) + "px";
        }
    }
}

//
//  Hides all tabs except the given tab. Also updates the style of the button.
//
//  Params:
//      oDisplayTab     Tab object of tab to display
//
JTabMenu.prototype.displayTab = function(oDisplayTab){
    var sName, oTab;
    
    for(sName in this.aTabPages){
        oTab = this.aTabPages[sName];

        if(oTab != oDisplayTab){
            oTab.oTab.style.display = "none";
            oTab.oButton.className = oTab.sOrigClassName;
        }else{
            oTab.oTab.style.display = "";
            oTab.oButton.className = "Current";
            this.sSelectedName = sName;
        }
    }
}

//
//  Loops up into the dom to find the tabpage element (searching for the 
//  JTabName attribute) and calls the displayTab function to display this 
//  tabpage.
//
//  Params:
//      oElement    Element that needs to be displayed
//  Returns:
//      True if tab page found & displayed
//  
JTabMenu.prototype.displayTabWithElement = function(oElement){
    var oCurrent = oElement;
    
    while(oCurrent != null && typeof(oCurrent.getAttribute) == "function"){
        if(oCurrent.getAttribute("JTabName") != null && this.aTabPages[oCurrent.getAttribute("JTabName")] != null){
            this.displayTab(this.aTabPages[oCurrent.getAttribute("JTabName")]);
            return true;
        }
        
        oCurrent = oCurrent.parentNode;
    }
    
    return false;
}

//
//  Handles the onClick event from the tabpage buttons. It searches the button 
//  component and displays the tab if name matches any.
//
//  Params:
//      e   Event object (on some browsers)
//
//  PRIVATE
JTabMenu.prototype.onButtonClick = function(e){
    var oButton, oMenu, sTabName;
    
    oButton = browser.events.getTarget(e);
    
    while(oButton != null && oButton.getAttribute("JTabName") == null){
        oButton = oButton.parentNode;
    }
        
    if(oButton == null)
        return false;

    oMenu = document.getElementById("JTabMenu").oJTabMenu;
    sTabName = oButton.getAttribute("JTabName");
    if(oMenu.aTabPages[sTabName] != null){
        oMenu.displayTab(oMenu.aTabPages[sTabName]);
    }
}