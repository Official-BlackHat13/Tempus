//
//  Class:
//      JPopCalendar
//
//  Contains code that displays an popcalendar to vdf ajax order entry. Can also
//  be used without vdf form. (show_JPopCalendar should be used instead of 
//  show_VdfJPopCalendar).
//
//  Since:
//      07-2006
//  Changed:
//      --
//  Version:
//      0.1
//  Creator:
//      Data Access Europe (Harm Wibier)
//



//
//  Displayes an JPopCalendar in an vdf form using the mask fetched from the 
//  VdfInfo object and the input element fetched from the form.
//
//  Params:
//      oControl    Control that displays the PopCalendar (used for positioning)
//      sName       Name of the vdf field to modify
//
function show_VdfJPopCalendar(oControl, sName){
    var oVdfForm, oField;
    sName = sName.toLowerCase();
    
    oVdfForm = findForm(oControl);
    if(oVdfForm == null) return false;
    
    oField = oVdfForm.getField(sName);
    
    if(oField == null) return false;
    
    show_JPopCalendar(oControl, oField.getElement(), oVdfForm.oVdfInfo.sDateMask);
}

//
//  Displayes an JPopCalendar for the given input element with the given mask. 
//  Checks if there is no PopCalendar displayed by the control to preven 
//  multiple popcalendars above each other.
//
//  Params:
//      oControl    Control that displays the PopCalendar (used for positioning)
//      oInput      Input element to get en store resulting date
//      sDateMask   Formatting mask for the date
//
function show_JPopCalendar(oControl, oInput, sDateMask){
    var oJPopCalendar;
    if(oControl.oJPopCalendar == null){
        oJPopCalendar = new JPopCalendar(oControl, oInput, sDateMask);
        oJPopCalendar.init();
    }
}

//
//  Constructor of the popup calendar. Fetches settings and creates needed data
//  structures and references.
//
//      oControl    Control that displays the PopCalendar (used for positioning)
//      oInput      Input element to get en store resulting date
//      sDateMask   Formatting mask for the date
//
function JPopCalendar(oControl, oInput, sDateMask){
    var dToday;
    
    dToday                  = new Date();
    
    //  Public properties
    this.oControl           = oControl;
    this.oInput             = oInput;
    if(typeof(sDateMask) == "undefined"){
        var sDateMask = "MM/DD/YYYY";
    }
    this.sDateMask          = browser.dom.getVdfAttribute(oControl, "sDateMask", sDateMask.toUpperCase());
    
    this.sCssMain           = browser.dom.getVdfAttribute(oControl, "sCssMain", "JPopCalendar");
    this.iPositionLeft      = browser.dom.getVdfAttribute(oControl, "iPositionLeft", -1);
    this.iPositionTop       = browser.dom.getVdfAttribute(oControl, "iPositionTop", -1);
    this.iMarginLeft        = browser.dom.getVdfAttribute(oControl, "iMarginLeft", 0);
    this.iMarginTop         = browser.dom.getVdfAttribute(oControl, "iMarginTop", 2);
    
    this.iStartAt           = browser.dom.getVdfAttribute(oControl, "iStartAt", 0); // (0 = sunday, 1 = monday)
    this.bShowWeekNumber    = browser.dom.getVdfAttribute(oControl, "bShowWeekNumber", true);
    this.bShowToday         = browser.dom.getVdfAttribute(oControl, "bShowToday", true);
    this.bShowMultipleYears = browser.dom.getVdfAttribute(oControl, "bShowMultipleYears", true);
    this.iSelectYearBegin   = browser.dom.getVdfAttribute(oControl, "iSelectYearBegin", 4);
    this.iSelectYearEnd     = browser.dom.getVdfAttribute(oControl, "iSelectYearEnd", 4);
    
    if(this.iStartAt == 0){
        this.aDayNames      = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
    }else{
        this.aDayNames      = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];
    }
    this.aMonthNames        = ["January","February","March","April","May","June","July","August","September","October","November","December"];
    this.aMonthNamesShort   = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"];
    
    //  Private properties
    this.iDateNow           = browser.dom.getVdfAttribute(oControl, "iDateNow", dToday.getDate());
    this.iMonthNow          = browser.dom.getVdfAttribute(oControl, "iMonthNow", dToday.getMonth());
    this.iYearNow           = browser.dom.getVdfAttribute(oControl, "iYearNow", dToday.getFullYear());
    
    this.iDateSelected      = browser.dom.getVdfAttribute(oControl, "iDateSelected", this.iDateNow);
    this.iMonthSelected     = browser.dom.getVdfAttribute(oControl, "iMonthSelected", this.iMonthNow);
    this.iYearSelected      = browser.dom.getVdfAttribute(oControl, "iYearSelected", this.iYearNow);
    
    this.iSelectYearTotal   = this.iSelectYearBegin + this.iSelectYearEnd + 1;
    this.iMonthDisplay      = this.iMonthSelected;
    this.iYearDisplay       = this.iYearSelected;
    
    //  References
    this.oMainDiv           = null;
    this.oTodaySpan         = null;
    this.oContentSpan       = null;
    this.oMonthSpan         = null;
    this.oMonthList         = null;
    this.oYearSpan          = null;
    this.oYearList          = null;    
    this.oBodyTable         = null;
    this.tYearScrollTimout  = null;
    this.tSubTimeout        = null;
    
    oControl.oJPopCalendar  = this;
    
}

//
//  Initializes the PopCalendar by constructing the dom elements, fetching the
//  current value, positioning the calendar and displaying the selected month.
//
JPopCalendar.prototype.init = function(){
    this.construct();
    this.parseCurrentValue();
    this.position();
    browser.gui.hideSelectBoxes(this.oMainDiv);
    this.displayCalendar(this.iYearSelected, this.iMonthSelected);
}

//
//  Creates the dom elements needed.
//
//  PRIVATE
JPopCalendar.prototype.construct = function(){
    var oMainDiv, oMainTable, oMainRow, oMainCell, oTitleTable, oTitleRow, oTodayLink;
    var oTitleCell, oCloseButton, oCaptionList, oCaptionItem, oContentSpan, oTodaySpan;
    var oMonthSpan, oMonthList, oMonthSpan, oYearList, oYearItem, oPrevSpan, oNextSpan;
    
    //  Maindiv
    oMainDiv = document.createElement("DIV");
    oMainDiv.className = this.sCssMain;
    oMainDiv.style.width = (this.bShowWeekNumber ? 250 : 220) + "px";
    oMainDiv.oPopCalendar = this;
    document.body.appendChild(oMainDiv);
    
    //  Maintable
    oMainTable = document.createElement("TABLE");
    oMainTable.className = "maintable";
    oMainTable.style.width = (this.bShowWeekNumber ? 250 : 220) + "px";
    oMainDiv.appendChild(oMainTable);
    
    //  Title
    oMainRow = oMainTable.insertRow(0);
    oMainRow.className = "title-background";
    oMainCell = oMainRow.insertCell(0);
    
    oTitleTable = document.createElement("TABLE");
    oTitleTable.style.width = (this.bShowWeekNumber ? 248 : 218) + "px";
    oMainCell.appendChild(oTitleTable);
    
    //  Caption
    oTitleRow = oTitleTable.insertRow(0);
    oTitleCell = oTitleRow.insertCell(0);
    oTitleCell.className = "title";
    oCaptionList = document.createElement("UL");
    oCaptionList.className = "menu-list";
    oTitleCell.appendChild(oCaptionList);
    
    //  Previous button
    oCaptionItem = document.createElement("LI");
    oCaptionList.appendChild(oCaptionItem);
    oPrevSpan = document.createElement("SPAN");
    oPrevSpan.className = "control-prev";
    oPrevSpan.innerHTML = "&nbsp;";
    browser.events.addGenericListener("click", oPrevSpan, this.onPreviousClick);
    oCaptionItem.appendChild(oPrevSpan);
    
    //  Next button
    oCaptionItem = document.createElement("LI");
    oCaptionList.appendChild(oCaptionItem);
    oNextSpan = document.createElement("SPAN");
    oNextSpan.className = "control-next";
    oNextSpan.innerHTML = "&nbsp;";
    browser.events.addGenericListener("click", oNextSpan, this.onNextClick);
    oCaptionItem.appendChild(oNextSpan);
    
    
    //  Month button
    oCaptionItem = document.createElement("LI");
    oCaptionList.appendChild(oCaptionItem);
    oMonthSpan = document.createElement("SPAN");
    oMonthSpan.className = "control-select";
    oMonthSpan.title = "Select month!";
    browser.events.addGenericListener("click", oMonthSpan, this.onMonthPullDown);
    oCaptionItem.appendChild(oMonthSpan);
    
    //  Month menu
    oMonthList = document.createElement("UL");
    oMonthList.className = "monthmenu";
    for(iMonth = 0; iMonth < 12; iMonth++){
        oMonthItem = document.createElement("LI");
        browser.dom.setCellText(oMonthItem, this.aMonthNames[iMonth]);
        oMonthItem.setAttribute("iMonth", iMonth);
        browser.events.addGenericListener("click", oMonthItem, this.onMonthClick);
        browser.events.addGenericListener("mouseover", oMonthItem, this.onSubMenuItemMouseOver);
        browser.events.addGenericListener("mouseout", oMonthItem, this.onSubMenuItemMouseOut);
        oMonthList.appendChild(oMonthItem);
    }
    browser.events.addGenericListener("mouseover", oMonthList, this.onSubMenuMouseOver);
    browser.events.addGenericListener("mouseout", oMonthList, this.onSubMenuMouseOut);
    oCaptionItem.appendChild(oMonthList);
    
    //  Year button
    oCaptionItem = document.createElement("LI");
    oCaptionList.appendChild(oCaptionItem);
    oYearSpan = document.createElement("SPAN");
    oYearSpan.className = "control-select";
    oYearSpan.title = "Select year!";
    browser.events.addGenericListener("click", oYearSpan, this.onYearPullDown);
    oCaptionItem.appendChild(oYearSpan);
    
    //  Year menu
    oYearList = document.createElement("UL");
    oYearList.className = "yearmenu";
    
    //  Scroll buttons
    if(this.bShowMultipleYears){
        oYearItem = document.createElement("LI");
        oYearItem.className = "submenu-scrollitem-up";
        oYearItem.innerHTML = "&nbsp;";
        browser.events.addGenericListener("mousedown", oYearItem, this.onYearUpStart);
        browser.events.addGenericListener("mouseup", oYearItem, this.onYearUpStop);
        browser.events.addGenericListener("mouseover", oYearItem, this.onYearUpOver);
        browser.events.addGenericListener("mouseout", oYearItem, this.onYearUpOut);
        oYearList.appendChild(oYearItem);
        
        oYearItem = document.createElement("LI");
        oYearItem.className = "submenu-scrollitem-down";
        oYearItem.innerHTML = "&nbsp;";
        browser.events.addGenericListener("mousedown", oYearItem, this.onYearDownStart);
        browser.events.addGenericListener("mouseup", oYearItem, this.onYearDownStop);
        browser.events.addGenericListener("mouseover", oYearItem, this.onYearDownOver);
        browser.events.addGenericListener("mouseout", oYearItem, this.onYearDownOut);
        oYearList.appendChild(oYearItem);
    }
    browser.events.addGenericListener("mouseover", oYearList, this.onSubMenuMouseOver);
    browser.events.addGenericListener("mouseout", oYearList, this.onSubMenuMouseOut);
    oCaptionItem.appendChild(oYearList);
    
    //  Close button
    oTitleCell = oTitleRow.insertCell(1);
    oTitleCell.style.textAlign = "right";
    oCloseButton = document.createElement("INPUT");
    oCloseButton.type = "button";
    oCloseButton.className = "closebutton";
    browser.events.addGenericListener("click", oCloseButton, this.onCloseClick);
    oTitleCell.appendChild(oCloseButton);
    
    //  Main body
    oMainRow = oMainTable.insertRow(1);
    oMainCell = oMainRow.insertCell(0);
    oMainCell.className = "body";
    oContentSpan = document.createElement("SPAN");
    oMainCell.appendChild(oContentSpan);
    
    //  Todayrow
    if(this.bShowToday){
        oMainRow = oMainTable.insertRow(2);
        oMainRow.className = "today";
        oMainCell = oMainRow.insertCell(0);
        oTodaySpan = document.createElement("SPAN");
        browser.dom.setCellText(oTodaySpan, "Today is ");
        
        oMainCell.appendChild(oTodaySpan);
        
        oTodayLink = document.createElement("A");
        oTodayLink.href = "javascript: browser.nothing();";
        browser.dom.setCellText(oTodayLink, this.constructDate(this.iYearNow, this.iMonthNow, this.iDateNow));
        browser.events.addGenericListener("click", oTodayLink, this.onTodayClick);
        oTodaySpan.appendChild(oTodayLink);
    }
    
    //  Save references
    this.oMainDiv = oMainDiv;
    this.oTodaySpan = oTodaySpan;
    this.oContentSpan = oContentSpan;
    this.oMonthSpan = oMonthSpan;
    this.oMonthList = oMonthList;
    this.oYearSpan = oYearSpan;
    this.oYearList = oYearList;
}

//
//  Positions the calendar relative to the control element.
//
//  PRIVATE
JPopCalendar.prototype.position = function(){
    var iLeft, iTop;

    iLeft = parseInt(this.iPositionLeft);
    iTop = parseInt(this.iPositionTop);
    
    if(iLeft == -1){
        iLeft = parseInt(browser.gui.getAbsoluteOffsetLeft(this.oControl)) + parseInt(this.iMarginLeft);
    }
    if(iTop == -1){
        iTop = parseInt(browser.gui.getAbsoluteOffsetTop(this.oControl)) + parseInt(this.oControl.offsetHeight) + parseInt(this.iMarginTop);
    }
    
    if(browser.isIE){
        iTop = parseInt(iTop) + 6;
    }

    this.oMainDiv.style.left = iLeft + "px";
    this.oMainDiv.style.top = iTop + "px";
}

//
//  Displays the given month.
//
//  Params:
//      iYear   Year of the month to display
//      iMonth  Month to display
//
JPopCalendar.prototype.displayCalendar = function(iYear, iMonth){
    var dStart, dEnd, oTable, oRow, oCell, iDay, iDayPointer, iDatePointer, sStyle, oLink;

    //  Update title buttons
    browser.dom.setCellText(this.oMonthSpan, this.aMonthNames[iMonth]);
    browser.dom.setCellText(this.oYearSpan, iYear);


    //  Generate dates
    this.iYearDisplay = iYear;
    this.iMonthDisplay = iMonth;
    dStart = new Date(iYear, iMonth, 1);
    dEnd = new Date(iYear, (iMonth + 1), 1);
    dEnd = new Date(dEnd - (24*60*60*1000));

    //  Remove orig table
    if(this.oBodyTable != null){
        this.oContentSpan.removeChild(this.oBodyTable);
    }
    
    //  Create table
    oTable = document.createElement("TABLE");
    oTable.className = "body";
    this.oContentSpan.appendChild(oTable);
    this.oBodyTable = oTable;
    
    //  Generate header
    oRow = oTable.insertRow(0);
    oRow.className = "body-title";
    if(this.bShowWeekNumber){
        oCell = oRow.insertCell(0);
        browser.dom.setCellText(oCell, "Wk");
        oCell = oRow.insertCell(1);
        oCell.className = "weeknumber-separator";
        oCell.rowSpan = 7;
    }
    for(iDay = 0; iDay < 7; iDay++){
        oCell = oRow.insertCell(oRow.cells.length);
        browser.dom.setCellText(oCell, this.aDayNames[iDay]);
    }
    
    //  Add empty cells
    oRow = oTable.insertRow(1);
    if(this.bShowWeekNumber){
        oCell = oRow.insertCell(0);
        browser.dom.setCellText(oCell, this.getWeekNr(dStart));
        oCell.className = "weeknumber";
    }
    iDayPointer = dStart.getDay() - this.iStartAt;
    if(iDayPointer < 0) iDayPointer = 7 + iDayPointer;
    for(iDay = 0; iDay < iDayPointer; iDay++){
        oCell = oRow.insertCell(oRow.cells.length);
        oCell.innerHTML = "&nbsp;";
    }
    
    //  Fill table
    iDaysInMonth = dEnd.getDate();
    for(iDatePointer = 1; iDatePointer <= iDaysInMonth; iDatePointer++){
        //  Determin style
        iDayPointer++;

        //  If needed go to next row
        if(iDayPointer > 7 && iDatePointer > 1){
            oRow = oTable.insertRow(oTable.rows.length);
            if(this.bShowWeekNumber){
                oCell = oRow.insertCell(0);
                browser.dom.setCellText(oCell, this.getWeekNr(new Date(iYear, iMonth, iDatePointer)));
                oCell.className = "weeknumber";
            }
            iDayPointer = 1;
        }
        
        //  Determine CSS style(s)
        sStyle = "normal-day";
        if(iDatePointer == this.iDateNow && iMonth == this.iMonthNow && iYear == this.iYearNow){
            sStyle = "current-day";
        }else if(iDayPointer == 7 || (this.iStartAt == 0 && iDayPointer == 1) || (this.iStartAt == 1 && iDayPointer == 6)){
            sStyle = "weekend-day";
        }
        
        if(iDatePointer == this.iDateSelected && iMonth == this.iMonthSelected && iYear == this.iYearSelected){
            sStyle += " selected-day";
        }
        
        //  Generate day
        oCell = oRow.insertCell(oRow.cells.length);
        oLink = document.createElement("A");
        oLink.className = sStyle;
        oLink.title = "Select " + this.constructDate(iYear, iMonth, iDatePointer) + " day:" + iDayPointer;
        oLink.setAttribute("iDate", iDatePointer);
        oLink.href = "javascript: browser.nothing();"
        browser.dom.setCellText(oLink, iDatePointer);
        browser.events.addGenericListener("click", oLink, this.onDayClick);
        oCell.appendChild(oLink);
    }
}

//
//  Displays the month pulldown by hiding the year and showing the 
//  (unsorted)list element of the month menu.
//
JPopCalendar.prototype.displayMonthPullDown = function(){
    if(this.oMonthList.style.display != "block"){
        this.oMonthList.style.display = "block";
        this.oYearList.style.display = "none";
    }else{
        this.oMonthList.style.display = "none";
    }
}

//
//  Clears, fills and displayes the year menu (hides the month menu)
//
JPopCalendar.prototype.displayYearPullDown = function(){
    var iYear;
    if(this.oYearList.style.display != "block"){
        //  Clear
        while(this.oYearList.childNodes.length > 2){
            this.oYearList.removeChild(this.oYearList.childNodes[1]);
        }
        
        //  Fill
        for(iYear = this.iYearDisplay - this.iSelectYearBegin; iYear <= (this.iYearDisplay + this.iSelectYearEnd); iYear++){
            this.displayNewYear(iYear, false);
        }
        
        //  Display
        this.oYearList.style.display = "block";
        this.oMonthList.style.display = "none";
    }else{
        this.oYearList.style.display = "none";
    }
}

//
//  Adds one year to the yearmenu list element.
//
//  Params:
//      iYear   The year to add
//      bStart  True if year should be added on top
//
//  PRIVATE
JPopCalendar.prototype.displayNewYear = function(iYear, bStart){
    var oYearItem;
    
    oYearItem = document.createElement("LI");
    browser.dom.setCellText(oYearItem, iYear);
    oYearItem.setAttribute("iYear", iYear);
    browser.events.addGenericListener("click", oYearItem, this.onYearClick);
    browser.events.addGenericListener("mouseover", oYearItem, this.onSubMenuItemMouseOver);
    browser.events.addGenericListener("mouseout", oYearItem, this.onSubMenuItemMouseOut);
    
    this.oYearList.insertBefore(oYearItem, this.oYearList.childNodes[(bStart ? 1 : this.oYearList.childNodes.length - 1)]);
}

//
//  Scrolls one year by inserting at one end and removing at the other.
//
//  Params:
//      bStart  If true year is added at the top (so it scrolls up)
//
JPopCalendar.prototype.yearScroll = function(bStart){
    var iYear, oYearList = this.oYearList;
    
    if(oYearList.childNodes.length > 2){
        oYearList.removeChild(oYearList.childNodes[(bStart ? oYearList.childNodes.length - 2 : 1)]);
        iYear = parseInt(oYearList.childNodes[(bStart ? 1 : oYearList.childNodes.length - 2)].getAttribute("iYear")) + (bStart ? -1 : 1);
        this.displayNewYear(iYear, bStart);
    }
}

//
//  Sets the value to the input element
//
//  PRIVATE
JPopCalendar.prototype.placeValue = function(){
    this.oInput.value = this.constructDate(this.iYearSelected, this.iMonthSelected, this.iDateSelected);
    
    //  Set focus and select text
    browser.dom.setFocus(this.oInput);
    this.oInput.select();
}

//
//  Hides & removes the calendar. Tries to clear al references.
//
JPopCalendar.prototype.closeCalendar = function(){
    //  Deatach dom element
    browser.gui.displaySelectBoxes(this.oMainDiv);
    this.oMainDiv.parentNode.removeChild(this.oMainDiv);
    
    //  Delete references to this
    this.oMainDiv.oPopCalendar = null;
    this.oControl.oJPopCalendar = null;
    
    //  Delete references to DOM
    this.oTodaySpan         = null;
    this.oContentSpan       = null;
    this.oMonthSpan         = null;
    this.oMonthList         = null;
    this.oYearSpan          = null;
    this.oYearList          = null;    
    this.oBodyTable         = null;
    this.oMainDiv           = null;
    this.oControl           = null;
    this.oInput             = null;
    
    //  Delete timouts
    if(this.tYearScrollTimout != null){
        clearTimeout(this.tYearScrollTimout);
        this.tYearScrollTimout = null;
    }
    if(this.tSubTimeout != null){
        clearTimeout(this.tSubTimeout);
        this.tSubTimeout = null;
    }
}

//
//  Fetches the current value of the input field and tries to parse it into the
//  separate date fields using the (given) date mask. If not in correct format 
//  it will set the sellected fields to the current date.
//
//  PRIVATE
JPopCalendar.prototype.parseCurrentValue = function(){
    var sValue, sDateMask, sSeparator, aMask, iTokensChanged, sSeparator, aData;
    var iPart, iMonth;
    
    sValue = this.oInput.value;
    sDateMask = this.sDateMask;
    sSeparator = " ";
    
    //  Find separator & split mask
    aMask = sDateMask.split(sSeparator);
    if (aMask.length < 3)
    {
        sSeparator = "/";
        aMask = sDateMask.split(sSeparator);
        if (aMask.length < 3)
        {
            sSeparator = ".";
            aMask = sDateMask.split(sSeparator);
            if (aMask.length < 3)
            {
                sSeparator = "-";
                aMask = sDateMask.split(sSeparator);
                if (aMask.length < 3)
                {
                    // invalid date	format
                    sSeparator = "";
                }
            }
        }
    }
    
    //  Split user date and identify values
    iTokensChanged = 0;
    if (sSeparator!= "" )
    {
        // use user's date
        aData = sValue.split(sSeparator);
        for (iPart = 0; iPart < 3; iPart++)
        {
            if ((aMask[iPart] == "D") || (aMask[iPart] == "DD"))
            {
                this.iDateSelected = parseInt(aData[iPart], 10);
                iTokensChanged ++;
            }
            else if	((aMask[iPart] == "M") || (aMask[iPart] == "MM"))
            {
                this.iMonthSelected = parseInt(aData[iPart], 10) - 1;
                iTokensChanged ++;
            }
            else if (aMask[iPart] == "YYYY")
            {
                this.iYearSelected = parseInt(aData[iPart], 10);
                iTokensChanged ++;
            }
            else if (aMask[iPart] == "MMM")
            {
                for (iMonth = 0; iMonth < 12; iMonth++)
                {
                    if (aMask[iPart] == this.aMonthNames[iMonth])
                    {
                        this.iMonthSelected = iMonth;
                        iTokensChanged++;
                    }
                }
            }
        }
    }
    
    //  If user value incorrect use current date
    if ((iTokensChanged!=3)||isNaN(this.iDateSelected)||isNaN(this.iMonthSelected)||isNaN(this.iYearSelected))
    {
        this.iDateSelected = this.iDateNow;
        this.iMonthSelected = this.iMonthNow;
        this.iYearSelected = this.iYearNow;
    }
}

//
//  Transforms the given date to the used format using the mask.
//
//  Params:
//      iYear   Year of the date
//      iMonth  Month of the date
//      iDate   Day of the date
//
//  PRIVATE
JPopCalendar.prototype.constructDate = function(iYear, iMonth, iDate){
    sResult = this.sDateMask;

    sResult = sResult.replace   ('DDD', '<n>');
    sResult = sResult.replace	("DD","<e>");
    sResult = sResult.replace	("D","<d>");
    sResult = sResult.replace	("<e>", browser.math.padZero(iDate, 2));
    sResult = sResult.replace	("<d>", iDate);
    sResult = sResult.replace	("MMM","<o>");
    sResult = sResult.replace	("MM","<n>");
    sResult = sResult.replace	("M","<m>");
    sResult = sResult.replace	("<m>", iMonth + 1);
    sResult = sResult.replace	("<n>", browser.math.padZero(iMonth + 1, 2));
    sResult = sResult.replace	("<o>", this.aMonthNamesShort[iMonth]);
    sResult = sResult.replace	("YYYY", iYear);
    return sResult.replace ("YY", browser.math.padZero(iYear % 100, 2));    
    
}

//
//  Returns the weeknumber of the given date object.
//  
//  Params:
//      dDate   Date object
//  Returns:
//      The week number
//
//  PRIVATE
JPopCalendar.prototype.getWeekNr = function(dDate){
    var iYear, iMonth, iDate, dNow, dFirstDay, dThen, iCompensation, iNumberOfWeek;
    
    iYear = dDate.getFullYear();
    iMonth = dDate.getMonth();
    iDate = dDate.getDate();
    dNow = Date.UTC(iYear,iMonth,iDate+1,0,0,0);
    
    dFirstday = new Date();
    dFirstday.setYear(iYear);
    dFirstday.setMonth(0);
    dFirstday.setDate(1);
    dThen = Date.UTC(iYear,0,1,0,0,0);
    iCompensation = dFirstday.getDay();
    
    if (iCompensation > 3){
        iCompensation -= 4;
    }else{
        iCompensation += 3;
    }
    iNumberOfWeek =  Math.round((((dNow-dThen)/86400000)+iCompensation)/7);
    return iNumberOfWeek;
}

//
//  Returns:
//      Date object with the currently selected date.
//
JPopCalendar.prototype.getSelectedDate = function(){
    return new Date(this.iYearSelected, this.iMonthSelected, this.iDateSelected);
}

//
//  Returns:
//      The weeknumber of the currently selected date.
//
JPopCalendar.prototype.getSelectedWeekNr = function(){
    return this.getWeekNr(this.getSelectedDate());
}

//
//  Returns:
//      The weekday number of the currently selected date where iStartAt 
//      determines if 0 is sunday or monday.
//
JPopCalendar.prototype.getSelectedWeekDay = function(){
    var iResult;

    iResult = this.getSelectedDate().getDay() - this.iStartAt;
    if(iResult < 0) iResult = 7 + iResult;
    if(iResult < 0) iResult = 7 + iResult;
    
    return iResult;
}

//
//  Fetches dayclick event, selects the date and hides the popCalendar.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onDayClick = function(e){
    var oLink, iDate, oPopCalendar, oDiv;
    
    oLink = browser.events.getTarget(e);
    oDiv = browser.dom.searchParent(oLink, "DIV");
    
    oPopCalendar = oDiv.oPopCalendar;
    
    
    if(oLink != null && oDiv != null && oPopCalendar != null){
        oPopCalendar.iYearSelected = oPopCalendar.iYearDisplay;
        oPopCalendar.iMonthSelected = oPopCalendar.iMonthDisplay;
        oPopCalendar.iDateSelected = oLink.getAttribute("iDate");
        oPopCalendar.placeValue();
        oPopCalendar.closeCalendar();
        
        browser.events.stop(e);
        return false;
    }
    
    return true;
}

//
//  Fetches monthclick event, selects and displays the clicked month.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onMonthClick = function(e){
   var oDiv, oPopCalendar, oMonth;
    
    oMonth = browser.events.getTarget(e);
    if(oMonth.getAttribute("iMonth") != null){
        oUL = browser.dom.searchParent(oMonth, "UL");
        oDiv = browser.dom.searchParent(oUL, "DIV");
        oPopCalendar = oDiv.oPopCalendar; 
        
        
        if(oDiv != null && oPopCalendar != null){
            oPopCalendar.displayCalendar(oPopCalendar.iYearDisplay, parseInt(oMonth.getAttribute("iMonth")));
            oUL.style.display = "none";
            browser.events.stop(e);
            return false;
        }
    }
}

//
//  Fetches yearclick event, selects and displays the clicked year.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onYearClick = function(e){
    var oDiv, oPopCalendar, oYear;
    
    oYear = browser.events.getTarget(e);
    if(oYear.getAttribute("iYear") != null){
        oUL = browser.dom.searchParent(oYear, "UL");
        oDiv = browser.dom.searchParent(oUL, "DIV");
        oPopCalendar = oDiv.oPopCalendar; 
        
        
        if(oDiv != null && oPopCalendar != null){
            oPopCalendar.displayCalendar(parseInt(oYear.getAttribute("iYear")), oPopCalendar.iMonthDisplay);
            oUL.style.display = "none";
            browser.events.stop(e);
            return false;
        }
    }
}

//
//  Fetches closeclick event, closes / hides the popup.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onCloseClick = function(e){
    var oDiv, oPopCalendar, iMonth, iYear;
    
    oDiv = browser.dom.searchParent(browser.events.getTarget(e), "DIV");
    oPopCalendar = oDiv.oPopCalendar;
    
    
    if(oDiv != null && oPopCalendar != null){
        oPopCalendar.closeCalendar();
    }
}

//
//  Fetches the nextclick event, displays the next month
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onNextClick = function(e){
    var oDiv, oPopCalendar, iMonth, iYear;
    
    oDiv = browser.dom.searchParent(browser.events.getTarget(e), "DIV");
    oPopCalendar = oDiv.oPopCalendar;
    
    
    if(oDiv != null && oPopCalendar != null){
        iMonth = oPopCalendar.iMonthDisplay;        
        iYear = oPopCalendar.iYearDisplay;
        iMonth++;
        if(iMonth > 11){
            iMonth = 0;
            iYear++;
        }
        oPopCalendar.displayCalendar(iYear, iMonth);
        
        browser.events.stop(e);
        return false;
    }
    
    return true; 
}

//
//  Fetches previousclick, displays the previous month.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onPreviousClick = function(e){
    var oDiv, oPopCalendar, iMonth, iYear;
    
    oDiv = browser.dom.searchParent(browser.events.getTarget(e), "DIV");
    oPopCalendar = oDiv.oPopCalendar;
    
    
    if(oDiv != null && oPopCalendar != null){
        iMonth = oPopCalendar.iMonthDisplay;        
        iYear = oPopCalendar.iYearDisplay;
        iMonth--;
        if(iMonth < 0){
            iMonth = 11;
            iYear--;
        }
        oPopCalendar.displayCalendar(iYear, iMonth);
        
        browser.events.stop(e);
        return false;
    }
    
    return true;
}

//
//  Fetches the click on the current date and selects it and hides / removes the
//  calendar.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onTodayClick = function(e){
    var oDiv, oPopCalendar, iMonth, iYear;
    
    oDiv = browser.dom.searchParent(browser.events.getTarget(e), "DIV");
    oPopCalendar = oDiv.oPopCalendar;
    
    
    if(oDiv != null && oPopCalendar != null){
        oPopCalendar.iMonthSelected = oPopCalendar.iMonthNow;        
        oPopCalendar.iYearSelected = oPopCalendar.iYearNow;
        oPopCalendar.iDateSelected = oPopCalendar.iDateNow;
        oPopCalendar.placeValue();
        oPopCalendar.closeCalendar();
        
        browser.events.stop(e);
        return false;
    }
    
    return true;
}

//
//  Fetches the click on the month button and displays the month selection list.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onMonthPullDown = function(e){
    var oDiv, oPopCalendar;
    
    oDiv = browser.dom.searchParent(browser.events.getTarget(e), "DIV");
    oPopCalendar = oDiv.oPopCalendar;
    
    
    if(oDiv != null && oPopCalendar != null){
        oPopCalendar.displayMonthPullDown();
        
        browser.events.stop(e);
        return false;
    }
    
    return true;
}

//
//  Fetches the click on the year button and displays the year selection list.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onYearPullDown = function(e){
    var oDiv, oPopCalendar;
    
    oDiv = browser.dom.searchParent(browser.events.getTarget(e), "DIV");
    oPopCalendar = oDiv.oPopCalendar;
    
    
    if(oDiv != null && oPopCalendar != null){
        oPopCalendar.displayYearPullDown();
        
        browser.events.stop(e);
        return false;
    }
    
    return true;
}

//
//  Fetches the onmouseover event of the submenu items and changes the style to
//  accentuate.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onSubMenuItemMouseOver = function(e){
    var oLI = browser.events.getTarget(e);
    
    if(oLI.tagName == "LI"){
        oLI.className = "submenuitem-hover";
    }
}

//
//  Fetches the onmouseout event of the submenu items and removes the style.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onSubMenuItemMouseOut = function(e){
    var oLI = browser.events.getTarget(e);
    
    if(oLI.tagName == "LI"){
        oLI.className = "";
    }
}

//
//  Fetches mouseover event, makes sure the timemout for removing the menu is 
//  stopped.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onSubMenuMouseOver = function(e){
    var oSubMenu, oDiv, oPopCalendar;

    oSubMenu = browser.events.getTarget(e);
    oDiv = browser.dom.searchParent(oSubMenu, "DIV");
    oPopCalendar = oDiv.oPopCalendar;
    
    if(oSubMenu != null && oPopCalendar != null){
        if(oPopCalendar.tSubTimeout != null){
            clearTimeout(oPopCalendar.tSubTimeout);
            oPopCalendar.tSubTimeout = null;
        }
    }
}

//
//  Fetches the mouseout event of the submenu. Sets an timeout to hide the menu.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onSubMenuMouseOut = function(e){
    var oSubMenu, oDiv, oPopCalendar;

    oSubMenu = browser.dom.searchParent(browser.events.getTarget(e), "UL");
    oDiv = browser.dom.searchParent(oSubMenu, "DIV");
    oPopCalendar = oDiv.oPopCalendar;
  
    if(oSubMenu != null && oPopCalendar != null){
    
        oPopCalendar.tSubTimeout = setTimeout(function(){
            if(oSubMenu.style.display != "none"){
                oSubMenu.style.display = "none";
            }
        },100)
    }
}

//
//  Fetches the mousedown event of the scroll down button. Scrolls down one step
//  and sets an timer to go another stop.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onYearDownStart = function(e){
    var oDiv, oLI, oPopCalendar, fScroll;
    
    oLI = browser.events.getTarget(e);
    oDiv = browser.dom.searchParent(oLI, "DIV");
    oPopCalendar = oDiv.oPopCalendar;
    
    if(oPopCalendar != null){
        oLI.className = "submenu-scrollitem-down-down";
        
        fScroll = function(){
            oPopCalendar.yearScroll(false);
            oPopCalendar.tYearScrollTimout = setTimeout(fScroll, 50);
        }
        fScroll();
    }
}

//
//  Fetches the mousedown event of the scroll up button. Scrolls up one step and
//  sets an timer for the next step.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onYearUpStart = function(e){
    var oDiv, oLI, oPopCalendar, fScroll;
    
    oLI = browser.events.getTarget(e);
    oDiv = browser.dom.searchParent(oLI, "DIV");
    oPopCalendar = oDiv.oPopCalendar;
    
    if(oPopCalendar != null){
        oLI.className = "submenu-scrollitem-up-down";
    
        fScroll = function(){
            oPopCalendar.yearScroll(true);
            oPopCalendar.tYearScrollTimout = setTimeout(fScroll, 50);
        }
        fScroll();
    }
}

//
//  Fetches the mouseup event of the scroll down button. Stops the scrollup by 
//  clearing the timeout.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onYearDownStop = function(e){
    var oDiv, oLI, oPopCalendar, fScroll;
    
    oLI = browser.events.getTarget(e);
    oDiv = browser.dom.searchParent(oLI, "DIV");
    oPopCalendar = oDiv.oPopCalendar;
    
    if(oPopCalendar != null){
        if(oPopCalendar.tYearScrollTimout != null){
            clearTimeout(oPopCalendar.tYearScrollTimout);
            oPopCalendar.tYearScrollTimout = null;
            
            if(oLI.className == "submenu-scrollitem-down-down"){
                oLI.className = "submenu-scrollitem-down-hover";
            }
        }
        
    }
}

//
//  Fetches the mouseup event of the scroll up button. Stops the scrolldown by 
//  clearing the timeout.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onYearUpStop = function(e){
    var oDiv, oLI, oPopCalendar, fScroll;
    
    oLI = browser.events.getTarget(e);
    oDiv = browser.dom.searchParent(oLI, "DIV");
    oPopCalendar = oDiv.oPopCalendar;
    
    if(oPopCalendar != null){
        if(oPopCalendar.tYearScrollTimout != null){
            clearTimeout(oPopCalendar.tYearScrollTimout);
            oPopCalendar.tYearScrollTimout = null;
            
            if(oLI.className == "submenu-scrollitem-up-down"){
                oLI.className = "submenu-scrollitem-up-hover";
            }
        }
    }
}

//
//  Fetches the mouseover event of the scrolldown button. Changes the style to 
//  accentuate.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onYearDownOver = function(e){
    var oLI = browser.events.getTarget(e);
    
    oLI.className = "submenu-scrollitem-down-hover";
}

//
//  Fetches the mouseover event of the scrollup button. Changes the style to
//  accentuate.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onYearUpOver = function(e){
    var oLI = browser.events.getTarget(e);
    
    oLI.className = "submenu-scrollitem-up-hover";
}

//
//  Fetches the mouseout event of the scrolldown button. Resets the style and 
//  clears the timeout.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onYearDownOut = function(e){
    var oDiv, oLI, oPopCalendar, fScroll;
    
    oLI = browser.events.getTarget(e);
    oDiv = browser.dom.searchParent(oLI, "DIV");
    oPopCalendar = oDiv.oPopCalendar;
    
    oLI.className = "submenu-scrollitem-down";
    
    if(oPopCalendar.tYearScrollTimout != null){
        clearTimeout(oPopCalendar.tYearScrollTimout);
        oPopCalendar.tYearScrollTimout = null;
    }
}

//
//  Fetches the mouseout event of the scrollup button. Resets the style and 
//  clears the timeout.
//
//  Params:
//      e   Event object on some browsers
//
//  PRIVATE
JPopCalendar.prototype.onYearUpOut = function(e){
    var oDiv, oLI, oPopCalendar, fScroll;
    
    oLI = browser.events.getTarget(e);
    oDiv = browser.dom.searchParent(oLI, "DIV");
    oPopCalendar = oDiv.oPopCalendar;
    
    oLI.className = "submenu-scrollitem-up";
    
    if(oPopCalendar.tYearScrollTimout != null){
        clearTimeout(oPopCalendar.tYearScrollTimout);
        oPopCalendar.tYearScrollTimout = null;
    }
}