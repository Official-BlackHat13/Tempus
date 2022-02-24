/*
Name:
    vdf.gui.CustomMenu
Type:
    Prototype
Revisions:
    2008/12/03  Created the initial version. (HW, DAE)
*/

/*
Constructor of the CustomMenu which contains the interface required by the 
initializer (see: vdf.core.init).

@param  eElement        The DOM element defining the menu.
@param  oParentControl  Reference to the parent control if the control is nested.
*/
vdf.gui.CustomMenu = function CustomMenu(eElement, oParentControl){
    /*
    Reference to the main DOM element.
    */
    this.eElement = eElement;
    /*
    The name of the control.
    
    @html
    */
    this.sName = vdf.determineName(this, "custommenu");
    /*
    Reference to the parent control.
    */
    this.oParentControl = (typeof(oParentControl) === "object" ? oParentControl : null);
    
    /*
    If true the focus of the anchor DOM elements is hiden (which doesn't work in 
    all browsers).
    */
    this.bHideFocus = this.getVdfAttribute("bHideFocus", true, false);
    /*
    If true opacity of the menu's fades to their target if the menu is 
    displayed.
    */
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
    
    this.eElement.oVdfControl = this;
};
/*
The CustomMenu can be used to create customized menu systems. It builds a tree 
of the menu structure with references to the DOM and attaches event handlers 
that hide & display submenu's. It doesn't require the menu items to be in menu 
structure, so a submenu can be placed outside of the menu item that opens it. 
@code
    <div vdfControlType="vdf.gui.CustomMenu">
        <ul class="mainmenu">
            <li vdfElement="item"><a href="Default.asp"><div>Home</div></a></li>
            <li vdfElement="item"><a href="Login.asp"><div>Login</div></a></li>
            <li vdfElement="item" vdfSubMenu="dataentry"><a href="javascript: vdf.sys.nothing();"><div>Data Entry</div></a></li>
            <li vdfElement="item" vdfSubMenu="reports"><a href="javascript: vdf.sys.nothing();"><div>Reporting</div></a></li>
        </ul>
        <ul vdfElement="menu" vdfName="dataentry" class="submenu" style="display:none">
            <li vdfElement="item"><a href="Customer.asp">Customers</a></li>
            <li vdfElement="item"><a href="CustomerPopup.asp">Customers (List)</a></li>
            <li vdfElement="item"><a href="SalesPerson.asp">Sales People</a></li>
            <li vdfElement="item"><a href="Order.asp">Order</a></li>
            <li vdfElement="item"><a href="Vendor.asp">Vendors</a></li>
            <li vdfElement="item"><a href="Invt.asp">Inventory Items</a></li>
        </ul>
        <ul vdfElement="menu" vdfName="reports" class="submenu" style="display:none">
            <li vdfElement="item"><a href="CustomerReport.asp">Customer list</a></li>
            <li vdfElement="item"><a href="OrderReport.asp">Order list</a></li>
        </ul>
    </div>
@code
*/
vdf.definePrototype("vdf.gui.CustomMenu", {

/*
Initializes the menu system by scanning for items, attaching event listeners
and displaying the current menu if there is one. Usually called by the 
initialization system.
*/
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
                throw new vdf.errors.Error(0, "Menu not found: {{0}}", this, [oItem.sTarget]);
            }
        }
    }
    
    //  Select current item if needed
    if(oCurrentItem !== null){
        this.select(oCurrentItem);
    }
    
    //  Set opacity to zero if effects are used
    if(this.bFadeOpacity){
        for(iMenu = 0; iMenu < this.aMenus.length; iMenu++){
            if(this.aMenus[iMenu] !== this.oMainMenu){
                vdf.sys.gui.setOpacity(this.aMenus[iMenu].eElement, 0);
            }
        }
    }
},

/*
Recursive scan method that loops through the child elements of the menu 
searching for menu items and menus creating objects that represent them.

@param  eElement    The current element.
@param  oMenu       Object representing the menu where inside.

@private    
*/
scan : function(eElement, oMenu, oMenuItem){
    var iChild, sElement, sSubMenu, sMenuName;
    
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
    
    for(iChild = 0; iChild < eElement.childNodes.length; iChild++){
        if(eElement.childNodes[iChild].nodeType !== 3 && eElement.childNodes[iChild].nodeType !== 8){
            this.scan(eElement.childNodes[iChild], oMenu, oMenuItem);
        }
    }
},

/*
Selects the given menu item and displays it submenu.

@param  oItem   Object representing an menu item.
*/
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

/*
Deselects the given menu item and hides it submenu.

@param  oItem   Object representing an menu item.
*/
deSelect : function(oItem){
    if(oItem.bSelected){
        oItem.eElement.className = oItem.eElement.className.replace("selected", "");
        oItem.bSelected = false;
        
        if(oItem.oSubMenu !== null){
            this.hideMenu(oItem.oSubMenu);
        }
    }
},

/*
Displays the given menu.

@param  oMenu   Object representing the menu.
*/
displayMenu : function(oMenu){
    if(!oMenu.bDisplayed){
        oMenu.bDisplayed = true;
        oMenu.eElement.style.display = "";
        
        if(this.bFadeOpacity){
            vdf.sys.gui.fadeOpacity(oMenu.eElement, 100, 500, null, null);
        }
    }
},

/*
Hides the given menu.

@param  oMenu   Object representing the menu.
*/
hideMenu : function(oMenu){
    if(oMenu.bDisplayed){
        oMenu.bDisplayed = false;
        oMenu.eElement.style.display = "none";
        
        if(this.bFadeOpacity){
            vdf.sys.gui.stopFadeOpacity(oMenu.eElement);
            vdf.sys.gui.setOpacity(oMenu.eElement, 0);
        }
    }
},

/*
Handles the onclick event on an item. Calls the select method for the item.

@param  e   Event object

@private
*/
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

/*
Determines if the url of the current page matches the url that is linked to. It
ignores the get parameters of the current page if the give url hasn't got any.

@param  sUrl    Url to match.
@return True if the url leads to the current page.
*/
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


/*
Method used to determine vdf attributes (which are usually set on the element).
Some attributes bubble which means that if a parent control is known this 
parent control is asked for the attribute value. Almost all attributes have a 
default value.

@param  sName       Name of the attribute.
@param  sDefault    Value returned if attribute not available.
@param  bBubble     If true the parent is asked for the value.
@return Value of the attribute (sDefault if not set).
*/
getVdfAttribute : function(sName, sDefault, bBubble){
    var sResult = null;
    
    if(this.eElement !== null){
        sResult = vdf.getDOMAttribute(this.eElement, sName, null);
    }

    if(sResult === null){
        if((bBubble) && this.oParentControl !== null && typeof(this.oParentControl.getVdfAttribute) == "function"){
            sResult = this.oParentControl.getVdfAttribute(sName, sDefault, true);
        }else{
            sResult = sDefault;
        }
    }
    
    return sResult;
}

});