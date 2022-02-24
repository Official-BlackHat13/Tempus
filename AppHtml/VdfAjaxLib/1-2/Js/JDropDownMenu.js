//
//  Attaches the event listeners that display and hide the submenu's. Is only
//  needed for IE6 and older.
//
function JDropDownMenu_Init() 
{
    var navRoot, node;
    
    //  Only IE V6 and older need the script, newer other browsers work on the CSS :hover selector
    if (browser.isIE && browser.iVersion <= 6) {
        navRoot = document.getElementById("nav");
        if (navRoot != null) {
            for (i=0; i<navRoot.childNodes.length; i++) {
                node = navRoot.childNodes[i];
                if (node.nodeName=="LI") {
                    node.onmouseover=function() {
                    if (!(this.contains(window.event.fromElement))) { 
                        this.className = this.className + " over";
                        browser.gui.hideSelectBoxes(this.childNodes[1]);
                    }
                }
                node.onmouseout=function() {
                        if (!(this.contains(window.event.toElement))) { 
                            browser.gui.displaySelectBoxes(this.childNodes[1]);
                            this.className= this.className.replace(" over", "");
                        }
                    }
                }
            }
        }
    }
}


browser.events.addGenericListener("load", window, JDropDownMenu_Init);

