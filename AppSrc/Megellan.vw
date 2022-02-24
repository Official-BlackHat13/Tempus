Use Windows.pkg
Use DFClient.pkg
Use dfTreeVw.pkg
Use cSplitterContainer.pkg
Use cGlblCheckBox.pkg

// TreeView items
Enumeration_List 
    Define tiOrganization
    Define tiContacts
    Define tiContact
    Define tiLocations
    Define tiLocation
    Define tiOrders
    Define tiOrder
    Define tiQuotes
    Define tiQuote
    Define tiEstimates
    Define tiEstimate
    Define tiInvoices
    Define tiInvoice

End_Enumeration_List

Struct tSearchResults
    Integer iId
    String  sCol1
    String  sCol2
    String  sCol3
    String  sCol4
End_Struct

Open Customer
Open Contact
Open Location
Open Order
Open Invhdr
Open Quotehdr
Open Eshead

Use InvoiceViewer.dg
Use TrckBr.pkg

Register_Object oCustomerEntry
Register_Object oContactEntry
Register_Object oLocationEntry
Register_Object oOrderEntry
Register_Object oQuoteEntry
Register_Object oSnowbook

Activate_View Activate_oMegellan for oMegellan
Object oMegellan is a dbView

    Property Handle phRefreshItem
    Property Date pdStartDate
    Property String psStatus
    Property Boolean pbActive
    Set Size to 298 618
    Set Location to 4 22
    Set piMinSize to 239 500
    Set Label to "Magellan - Database Navigator"
    Set View_Latch_State to False
    Set Border_Style to Border_Thick
    Set Maximize_Icon to True
    Set pbSizeToClientArea to False

    Object oSplitterContainer is a cSplitterContainer
        Set piSplitterLocation to 202

        Object oTreeViewContainer is a cSplitterContainerChild

            Object oResultTreeView is a cGlblTreeView

                Property Integer piCustomerIdno
                Property Integer piLocationIdno
                Property Integer piLocationContactIdno
                Property Integer piJobNumber
                Property Integer piQuoteId
                Property Integer piEsheadId
                //
                Property Integer peSearchType
                Property Integer piSearchId
                //
                Property Integer peGroup
                Property Integer piSelected
                //
                Property Handle  phRoot
                Property Handle  phContacts
                Property Handle  phLocations
                Property Handle  phLocation
                Property Handle  phItem
                // used by oContextMenu
                Property Boolean pbCreateOrganization
                Property Boolean pbDisplayItem
                Property Boolean pbCreateContact
                Property Boolean pbCreateLocation
                Property Boolean pbCreateEditAPForm
                Property Boolean pbCreateQuote
                Property Boolean pbCreateEstimate
                Property Boolean pbCreateOrder
                Property Boolean pbDocumentFolder
                Property Boolean pbSnowBook
                
                //Property String psStatus

                Set Size to 236 194
                Set Location to 5 4
                Set peAnchors to anAll

                Object oImageList is a cImageList
                    Set piMaxImages to 6 // 3
        
                    Procedure OnCreate // add the images
                        Integer iImage
                        //
                        Get AddTransparentImage "Open16.bmp"   clFuchsia to iImage
                        Get AddTransparentImage "Select16.bmp" clFuchsia to iImage
                        Get AddTransparentImage "New16.bmp"    clFuchsia to iImage
                        Get AddTransparentImage "Person.bmp"   clLtGray  to iImage  //value#3-default
//                        Get AddTransparentImage "Schedule.bmp" clWhite   to iImage  //value#0-top
//                        Get AddTransparentImage "Select16.bmp" clFuchsia to iImage  //value#1-pointer-whenItemClicked
//                        Get AddTransparentImage "New16.bmp"    clFuchsia to iImage  //value#2-MainTreeviewItems
//                       // Get AddTransparentImage "HighP.bmp"    clLtGray   to iImage  //clbLACK   to iImage  //
//                        Get AddTransparentImage "Dbewarn.bmp"  clLtGray  to iImage  //value#4-medicalAlert
//                       //  Get AddTransparentImage "next.bmp"     clFuchsia to iImage  //
//                         Get AddTransparentImage "CheckOnD.bmp"  clBlack  to iImage 
//                       //Get AddTransparentImage "Checkout16.bmp" clWhite to iImage  //for testing
                    End_Procedure
                End_Object
                // Now assign the ImageList to the TreeView
                Set ImageListObject to (oImageList(Self))
            
                Object oContextMenu is a cCJContextMenu

                    Property Integer peGroup

                    Object oCreateOrganization is a cCJDeoNavigateMenuItem
                        Set psCaption to "Create a Organization"
                        Set psDescription to "Create a Organization"
                        Set psToolTip to "Create a Organization"
//                        Set psImage to "actioncascade.ico"
                        
                        Procedure OnExecute Variant vCommandBarControl
                            Set pbCreateOrganization to True
                        End_Procedure
                    End_Object
                    
                    Object oDisplayItem is a cCJDeoNavigateMenuItem
                        Set psCaption to "Display Item"
                        Set psDescription to "Display Item"
                        Set psToolTip to "Displays the selected item in the appropriate view"
//                        Set psImage to "Checkin.ico"
        
                        Procedure OnExecute Variant vCommandBarControl
                            Set pbDisplayItem to True
                        End_Procedure
                    End_Object
        
                    Object oCreateContact is a cCJDeoNavigateMenuItem
                        Set psCaption to "Create a Contact"
                        Set psDescription to "Create a Contact"
                        Set psToolTip to "Create a Contact"
//                        Set psImage to "actioncascade.ico"
                        
                        Procedure OnExecute Variant vCommandBarControl
                            Set pbCreateContact to True
                        End_Procedure
                    End_Object
        
                    Object oCreateLocation is a cCJDeoNavigateMenuItem
                        Set psCaption to "Create a Location"
                        Set psDescription to "Create a Location"
                        Set psToolTip to "Create a Location"
//                        Set psImage to "actioncascade.ico"
                        
                        Procedure OnExecute Variant vCommandBarControl
                            Set pbCreateLocation to True
                        End_Procedure
                    End_Object

                    Object oCreateEditAPForm is a cCJDeoNavigateMenuItem
                        Set psCaption to "Create/Edit AP Form"
                        Set psDescription to "Create/Edit AP Form"
                        Set psToolTip to "Create/Edit AP Form"
//                        Set psImage to "actioncascade.ico"
                        
                        Procedure OnExecute Variant vCommandBarControl
                            Set pbCreateEditAPForm to True
                        End_Procedure
                    End_Object

                    Object oCreateQuote is a cCJDeoNavigateMenuItem
                        Set psCaption to "Create a Quote"
                        Set psDescription to "Create a Quote"
                        Set psToolTip to "Create a Quote"
//                        Set psImage to "actioncascade.ico"
                        
                        Procedure OnExecute Variant vCommandBarControl
                            Set pbCreateQuote to True
                        End_Procedure
                    End_Object

                    Object oCreateEstimate is a cCJDeoNavigateMenuItem
                        Set psCaption to "Create a Estimate"
                        Set psDescription to "Create a Estimate"
                        Set psToolTip to "Create a Estimate"
//                        Set psImage to "actioncascade.ico"
                        
                        Procedure OnExecute Variant vCommandBarControl
                            Set pbCreateEstimate to True
                        End_Procedure
                    End_Object
                    
                    Object oCreateOrder is a cCJDeoNavigateMenuItem
                        Set psCaption to "Create Order"
                        Set psDescription to "Create Order"
                        Set psToolTip to "Create Order"
//                        Set psImage to "actioncascade.ico"
                        
                        Procedure OnExecute Variant vCommandBarControl
                            Set pbCreateOrder to True
                        End_Procedure
                    End_Object
        
                    Object oDocumentFolder is a cCJDeoNavigateMenuItem
                        Set psCaption to "Open Document Folder"
                        Set psDescription to "Open Document Folder"
                        Set psToolTip to "Open Document Folder"
                        
                        Procedure OnExecute Variant vCommandBarControl
                            Set pbDocumentFolder to True
                        End_Procedure
                    End_Object
                    
                    Object oSnowBook is a cCJDeoNavigateMenuItem
                        Set psCaption to "Open Snow Book"
                        Set psDescription to "Open Snow Book"
                        Set psToolTip to "Open Snow Book"
                        
                        Procedure OnExecute Variant vCommandBarControl
                            Set pbSnowBook to True
                        End_Procedure
                    End_Object
        
                    Procedure OnPopupInit Variant vCommandBarControl Handle hoCommandBarControls
                        Boolean bState
                        Integer eGroup
                        //
                        Get peGroup to eGroup
                        Move (                         ;
                            eGroup = tiOrganization or ;
                            eGroup = tiContact      or ;
                            eGroup = tiLocation     or ;
                            eGroup = tiOrder        or ;
                            eGroup = tiQuote        or ;
                            eGroup = tiEstimate     or ;
                            eGroup = tiInvoice) to bState
                        //
                        Set pbEnabled of oDisplayItem           to bState
                        Set pbVisible of oDisplayItem           to bState
                        Set pbEnabled of oCreateContact         to (eGroup = tiContacts)
                        Set pbVisible of oCreateContact         to (eGroup = tiContacts)
                        Set pbEnabled of oCreateOrganization    to (eGroup = tiOrganization)
                        Set pbVisible of oCreateOrganization    to (eGroup = tiOrganization)
                        Set pbEnabled of oCreateLocation        to (eGroup = tiLocations)
                        Set pbVisible of oCreateLocation        to (eGroup = tiLocations)
                        Set pbEnabled of oCreateEditAPForm      to (eGroup = tiLocation)
                        Set pbVisible of oCreateEditAPForm      to (eGroup = tiLocation)
                        Set pbEnabled of oCreateQuote           to (eGroup = tiLocation)
                        Set pbVisible of oCreateQuote           to (eGroup = tiLocation)
                        Set pbEnabled of oCreateEstimate        to (eGroup = tiLocation)
                        Set pbVisible of oCreateEstimate        to (eGroup = tiLocation)
                        Set pbEnabled of oCreateOrder           to (eGroup = tiLocation)
                        Set pbVisible of oCreateOrder           to (eGroup = tiLocation)
                        Set pbEnabled of oDocumentFolder        to (eGroup = tiLocation)
                        Set pbVisible of oDocumentFolder        to (eGroup = tiLocation)
                        Set pbVisible of oSnowBook              to (eGroup = tiLocation)
//                        Set pbEnabled of oNoShow        to (peGroup(Self) = tiCheckIn)
//                        Set pbEnabled of oAddToWillCall to (peGroup(Self) = tiCheckIn)
//                        Set pbEnabled of oCancel        to (peGroup(Self) = tiCheckIn)
//                        Set pbEnabled of oSeat          to (peGroup(Self) = tiOnDeck)
//                        Set pbEnabled of oAssign        to (peGroup(Self) = tiNeedsAppt)
//                        Set pbEnabled of oSearch        to (peGroup(Self) = tiNeedsAppt)
//                        Set pbEnabled of oRemove        to (peGroup(Self) = tiNeedsAppt)
//                        Set pbEnabled of oWillCall      to (peGroup(Self) = tiNeedsAppt)
//                        Set pbEnabled of oHold          to ;
//                            (peGroup(Self) = tiSeated   or ;
//                             peGroup(Self) = tiNeedsAppt)
//                        Set pbEnabled of oCheckOut      to ;
//                            (peGroup(Self) = tiCheckIn or  ;
//                             peGroup(Self) = tiOnDeck  or  ;
//                             peGroup(Self) = tiSeated)  
//                        //
//                        Set pbVisible of oCheckIn       to (peGroup(Self) = tiCheckIn)
//                        Set pbVisible of oNoShow        to (peGroup(Self) = tiCheckIn)
//                        Set pbVisible of oAddToWillCall to (peGroup(Self) = tiCheckIn)
//                        Set pbVisible of oCancel        to (peGroup(Self) = tiCheckIn)
//                        Set pbVisible of oSeat          to (peGroup(Self) = tiOnDeck)
//                        Set pbVisible of oAssign        to (peGroup(Self) = tiNeedsAppt)
//                        Set pbVisible of oSearch        to (peGroup(Self) = tiNeedsAppt)
//                        Set pbVisible of oRemove        to (peGroup(Self) = tiNeedsAppt)
//                        Set pbVisible of oWillCall      to (peGroup(Self) = tiNeedsAppt)
//                        Set pbVisible of oHold          to ;
//                            (peGroup(Self) = tiSeated   or ;
//                             peGroup(Self) = tiNeedsAppt)
//                        Set pbVisible of oCheckOut      to ;
//                            (peGroup(Self) = tiCheckIn  or ;
//                             peGroup(Self) = tiOnDeck   or ;
//                             peGroup(Self) = tiSeated) 
                    End_Procedure
        
                End_Object

                Procedure OnCreateTree
                    Integer iData
                    Handle  hRoot hGroup
                    //
                    Get CreateDataValue tiOrganization 0 "Root"    to iData
                    Get AddTreeItem "Organization"     0 iData 0 1 to hRoot
                    Set phRoot                                     to hRoot
                    //
                    Get CreateDataValue tiContacts     0 ""        to iData
                    Get AddTreeItem "Contacts"     hRoot iData 3 1 to hGroup
                    Set phContacts                                 to hGroup
                    Set ItemChildCount hGroup                      to 1
                    //
                    Get CreateDataValue tiLocations    0 ""        to iData
                    Get AddTreeItem "Locations"    hRoot iData 2 1 to hGroup
                    Set phLocations                                to hGroup
                    Set ItemChildCount hGroup                      to 1
                    //
                    Send DoExpandItem hRoot
                End_Procedure

                Procedure OnItemExpanding Handle hGroup
                    Boolean bFound
                    Integer iData eGroup eType iCustId iId iValue iCount iLocId iContactId
                    String  sValue
                    Handle  hItem
                    //
                    Get ItemData hGroup             to iData
                    Get IsItemDataValue iData True  to eGroup
                    Get IsItemDataValue iData False to iLocId
                    Get piCustomerIdno              to iCustId
                    Get peSearchType                to eType
                    Get piSearchId                  to iId
                    //
                    If (hGroup <> phRoot(Self)) Begin
                        Send DoDeleteChildItems hGroup
                    End
                    //
                    If      (eGroup = tiContacts) Begin
                        Clear Contact
                        // this property is set when search by location name, address, city or zip
                        If (piLocationContactIdno(Self) <> 0) Begin
                            Get piLocationContactIdno                                   to iContactId
                            //
                            Constraint_Set 1
                            Constrain Contact.ContactIdno eq iContactId
                            If (pbActive(Self)) Constrain Contact.Status eq "A"
                            Constrained_Find FIRST Contact by 2
                            While ((Found) and Contact.ContactIdno = iContactId)
                                Move (Trim(Contact.FirstName)*Trim(Contact.LastName)*If(Contact.Status="I",("(Inactive)"),"")) to sValue
                                Get CreateDataValue tiContact Contact.ContactIdno ""    to iValue
                                Get AddTreeItem sValue hGroup iValue 3 1                to hItem
                                Constrained_Find Next
                            Loop
                            Constraint_Set 1 Delete
//                            //
//                            Move iContactId                                             to Contact.ContactIdno
//                            Find eq Contact.ContactIdno
//                            If (Found) Begin
//                                Move (Trim(Contact.FirstName) * Trim(Contact.LastName)) to sValue
//                                Get CreateDataValue tiContact Contact.ContactIdno ""    to iValue
//                                Get AddTreeItem sValue hGroup iValue 3 1                to hItem
//                            End
                        End
                        //
                        If      (eType = tiOrganization) Begin

                            Constraint_Set 1
                            Constrain Contact.CustomerIdno eq iId
                            If (pbActive(Self)) Constrain Contact.Status eq "A"
                            Constrained_Find FIRST Contact by 1
                            While ((Found) and Contact.CustomerIdno = iId)
                                Move (Trim(Contact.FirstName)*Trim(Contact.LastName)*If(Contact.Status="I",("(Inactive)"),"")) to sValue
                                Get CreateDataValue tiContact Contact.ContactIdno ""    to iValue
                                Get AddTreeItem sValue hGroup iValue 3 1                to hItem
                                Constrained_Find Next
                            Loop
                            Constraint_Set 1 Delete
//                            Move iId                                                    to Contact.CustomerIdno                            
//                            Find ge Contact.CustomerIdno
//                            While ((Found) and Contact.CustomerIdno = iId)
//                                Move (Trim(Contact.FirstName) * Trim(Contact.LastName)) to sValue
//                                Get CreateDataValue tiContact Contact.ContactIdno ""    to iValue
//                                Get AddTreeItem sValue hGroup iValue 3 1                to hItem
//                                Find gt Contact.CustomerIdno
//                            Loop
                        End
                        Else If (eType = tiContacts) Begin
                            Move iId                                                to iContactId
                            Move iContactId                                         to Contact.ContactIdno
                            Find eq Contact.ContactIdno
                            Move (Trim(Contact.FirstName)*Trim(Contact.LastName)*If(Contact.Status="I",("(Inactive)"),"")) to sValue
                            Get CreateDataValue tiContact Contact.ContactIdno ""    to iValue
                            Get AddTreeItem sValue hGroup iValue 3 1                to hItem
                        End
                        Get ItemChildCount hGroup to iCount
                        If (iCount = 0) Begin
                            Set ItemChildCount hGroup to 1
                        End
                    End // If      (eGroup = tiContacts) Begin
                    //
                    Else If (eGroup = tiLocations) Begin
                        Clear Location
                        If      (eType = tiOrganization) Begin
                            Constraint_Set 1
                            Constrain Location.CustomerIdno eq iId
                            If (pbActive(Self)) Constrain Location.Status eq "A"
                            Constrained_Find First Location by 2
                            While ((Found) and Location.CustomerIdno = iId)
                                Move (Trim(Location.Name)*If(Location.Status="I",("(Inactive)"),""))                              to sValue
                                Get CreateDataValue tiLocation Location.LocationIdno "" to iValue
                                Get AddTreeItem sValue hGroup iValue 2 1                to hItem
                                Set ItemChildCount hItem                                to 1
                                Constrained_Find Next
                            Loop
                            Constraint_Set 1 Delete
                            
//                            Move iId to Location.CustomerIdno
//                            Find ge Location.CustomerIdno
//                            Move ((Found) and Location.CustomerIdno = iId) to bFound
//                            While (bFound)
//                                Move (Trim(Location.Name))                              to sValue
//                                Get CreateDataValue tiLocation Location.LocationIdno "" to iValue
//                                Get AddTreeItem sValue hGroup iValue 2 1                to hItem
//                                Set ItemChildCount hItem                                to 1
//                                //
//                                Find gt Location.CustomerIdno
//                                Move ((Found) and Location.CustomerIdno = iId) to bFound
//                            Loop
                        End
                        Else If (eType = tiContacts) Begin
                            
                            
                            
                            Move iId to Location.ContactIdno
                            Find ge Location.ContactIdno
                            Move ((Found) and Location.ContactIdno = iId) to bFound
                            While (bFound)
                                Move (Trim(Location.Name)*If(Location.Status="I",("(Inactive)"),""))                              to sValue
                                Get CreateDataValue tiLocation Location.LocationIdno "" to iValue
                                Get AddTreeItem sValue hGroup iValue 2 1                to hItem
                                Set ItemChildCount hItem                                to 1
                                //
                                Find gt Location.ContactIdno
                                Move ((Found) and Location.ContactIdno = iId) to bFound
                            Loop
                        End
                        Else If (eType = tiLocations) Begin
                            Move iId to Location.LocationIdno
                            Find eq Location.LocationIdno
                            Move (Trim(Location.Name)*If(Location.Status="I",("(Inactive)"),""))                              to sValue
                            Get CreateDataValue tiLocation Location.LocationIdno "" to iValue
                            Get AddTreeItem sValue hGroup iValue 2 1                to hItem
                            Set ItemChildCount hItem                                to 1
                        End
                        Else If (eType = tiOrder or eType = tiQuote) Begin
                            Get piLocationIdno                                      to iLocId
                            Move iLocId                                             to Location.LocationIdno
                            Find eq Location.LocationIdno
                            Move (Trim(Location.Name)*If(Location.Status="I",("(Inactive)"),""))                              to sValue
                            Get CreateDataValue tiLocation Location.LocationIdno "" to iValue
                            Get AddTreeItem sValue hGroup iValue 2 1                to hItem
                            Set phLocation                                          to hItem
                            Set ItemChildCount hItem                                to 1
                        End
                        Get ItemChildCount hGroup to iCount
                        If (iCount = 0) Begin
                            Set ItemChildCount hGroup to 1
                        End
                    End // Else If (eGroup = tiLocations) Begin
                    //
                    Else If (eGroup = tiLocation) Begin
                        If (hGroup = phLocation(Self)) Begin
                            If      (eType = tiOrder) Begin
                                Get piLocationIdno                         to iLocId
                                Get CreateDataValue tiOrders iLocId ""     to iValue
                                Get AddTreeItem "Orders" hGroup iValue 2 1 to hItem
                                Set phItem                                 to hItem
                                Set ItemChildCount hItem                   to 1
                            End
                            Else If (eType = tiQuote) Begin
                                Get piLocationIdno                         to iLocId
                                Get CreateDataValue tiQuotes iLocId ""     to iValue
                                Get AddTreeItem "Quotes" hGroup iValue 2 1 to hItem
                                Set phItem                                 to hItem
                                Set ItemChildCount hItem                   to 1
                            End
                        End
                        Else Begin
                            // create Orders
                            Clear Order
                            Move iLocId to Order.LocationIdno
                            Find ge Order.LocationIdno
                            If ((Found) and Order.LocationIdno = iLocId) Begin
                                Get CreateDataValue tiOrders iLocId ""     to iValue
                                Get AddTreeItem "Orders" hGroup iValue 2 1 to hItem
                                Set ItemChildCount hItem                   to 1
                            End
                            // create Invoices
                            Clear Invhdr
                            Move iLocId to Invhdr.LocationIdno
                            Find ge Invhdr.LocationIdno
                            If ((Found) and Invhdr.LocationIdno = iLocId) Begin
                                Get CreateDataValue tiInvoices iLocId ""     to iValue
                                Get AddTreeItem "Invoices" hGroup iValue 2 1 to hItem
                                Set ItemChildCount hItem                     to 1
                            End
                            // create Quotes
                            Clear Quotehdr
                            Move iLocId to Quotehdr.LocationIdno
                            Find ge Quotehdr.LocationIdno
                            If ((Found) and Quotehdr.LocationIdno = iLocId) Begin
                                Get CreateDataValue tiQuotes iLocId ""     to iValue
                                Get AddTreeItem "Quotes" hGroup iValue 2 1 to hItem
                                Set ItemChildCount hItem                   to 1
                            End
                            // create Estimates
                            Clear Eshead
                            Move iLocId to Eshead.LocationIdno
                            Find ge Eshead.LocationIdno
                            If ((Found) and Eshead.LocationIdno = iLocId) Begin
                                Get CreateDataValue tiEstimates iLocId ""       to iValue
                                Get AddTreeItem "Estimates" hGroup iValue 2 1   to hItem
                                Set ItemChildCount hItem                        to 1
                            End
                        End
                    End // Else If (eGroup = tiLocation) Begin
                    //
                    Else If (eGroup = tiOrders) Begin
                        Clear Order
                        Constraint_Set 1
                        Constrain Order.LocationIdno eq iLocId
                        Constrain Order.JobOpenDate ge (pdStartDate(Self))
                        Constrained_Find Last Order by 2
                        
//                        Move iLocId to Order.LocationIdno
//                        Find GE Order by 13
                        While ((Found) and Order.LocationIdno = iLocId)
                            Move (String(Order.JobNumber) * "-" * String(Order.JobOpenDate)) to sValue
                            Move (sValue * "-" * Trim(Order.Title))                          to sValue
                            Get CreateDataValue tiOrder Order.JobNumber ""                   to iValue
                            Get AddTreeItem sValue hGroup iValue 2 1                         to hItem
//                            Find GT Order by 13
                            Constrained_Find Next
                        Loop
                        Constraint_Set 1 Delete
                        Get ItemChildCount hGroup to iCount
                        If (iCount = 0) Begin
                            Set ItemChildCount hGroup to 1
                        End
                    End // Else If (eGroup = tiOrders) Begin
                    //
                    Else If (eGroup = tiInvoices) Begin
                        Clear Invhdr
                        Constraint_Set 1
                        Constrain Invhdr.LocationIdno matches iLocId
                        If (pbActive(Self)) Constrain Invhdr.VoidFlag eq 0
                        Constrain Invhdr.InvoiceDate ge (pdStartDate(Self))
                        Constrained_Find Last Invhdr by 5
//                        Move iLocId to Invhdr.LocationIdno
//                        Find ge Invhdr.LocationIdno
                        While ((Found) and Invhdr.LocationIdno = iLocId)
                            Move (String(Invhdr.InvoiceIdno) * If(Invhdr.VoidFlag=1,"- VOIDED","")* "-" * String(Invhdr.InvoiceDate)) to sValue
                            Move (sValue * "-" * "$" + String(Invhdr.TotalAmount))               to sValue
                            Get CreateDataValue tiInvoice Invhdr.InvoiceIdno ""                  to iValue
                            Get AddTreeItem sValue hGroup iValue 2 1                             to hItem
//                            Find gt Invhdr.LocationIdno
                            Constrained_Find Next
                        Loop
                        Constraint_Set 1 Delete
                        Get ItemChildCount hGroup to iCount
                        If (iCount = 0) Begin
                            Set ItemChildCount hGroup to 1
                        End
                    End // Else If (eGroup = tiInvoices) Begin
                    //
                    Else If (eGroup = tiQuotes) Begin
                        Clear Quotehdr
                        Constraint_Set 1
                        Constrain Quotehdr.LocationIdno matches iLocId
                        Constrain Quotehdr.QuoteDate ge (pdStartDate(Self))
                        Constrained_Find Last Quotehdr by 2
//                        Move iLocId to Quotehdr.LocationIdno
//                        Find ge Quotehdr.LocationIdno
                        While ((Found) and Quotehdr.LocationIdno = iLocId)
                            Move (String(Quotehdr.QuotehdrID) * "-" * String(Quotehdr.QuoteDate)) to sValue
                            Move (sValue * "-" * Trim(Quotehdr.QuoteLostMemo))                    to sValue
                            Move (sValue * "-" * "$" + String(Quotehdr.Amount))                   to sValue
                            Get CreateDataValue tiQuote Quotehdr.QuotehdrID ""                    to iValue
                            Get AddTreeItem sValue hGroup iValue 2 1                              to hItem
//                            Find gt Quotehdr.LocationIdno
                            Constrained_Find Next
                        Loop
                        Constraint_Set 1 Delete
                        Get ItemChildCount hGroup to iCount
                        If (iCount = 0) Begin
                            Set ItemChildCount hGroup to 1
                        End
                    End // Else If (eGroup = tiQuotes) Begin
                    //
                    Else If (eGroup = tiEstimates) Begin
                        Clear Eshead
                        Constraint_Set 1
                        Constrain Eshead.LocationIdno matches iLocId
                        Constrain Eshead.CREATION_DATE ge (pdStartDate(Self))
                        Constrained_Find Last Eshead by 3
                        While ((Found) and Eshead.LocationIdno = iLocId)
                            Move (String(Eshead.ESTIMATE_ID) * "-" * String(Eshead.CREATION_DATE))  to sValue
                            Move (sValue * "-" * Trim(Replaces('"', Eshead.TITLE, '')))             to sValue
                            Move (sValue * "-" * "$" + String(Eshead.Q1_X_$))                       to sValue
                            Get CreateDataValue tiEstimate Eshead.ESTIMATE_ID ""                    to iValue
                            Get AddTreeItem sValue hGroup iValue 2 1                              to hItem
                            Constrained_Find Next
                        Loop
                        Constraint_Set 1 Delete
                        Get ItemChildCount hGroup to iCount
                        If (iCount = 0) Begin
                            Set ItemChildCount hGroup to 1
                        End
                    End // Else If (eGroup = tiEstimates) Begin
                End_Procedure // OnItemExpanding

                Procedure OnItemDblClick Handle hItem Boolean ByRef bCancel
                    Integer iData eGroup iValue
                    //
                    If (hItem = phRoot(Self)) Begin
                        Get piCustomerIdno to iValue
                        Send DoEditCustomerID of oCustomerEntry iValue
                    End
                    Else Begin
                        Get ItemData hItem              to iData
                        Get IsItemDataValue iData True  to eGroup
                        Get IsItemDataValue iData False to iValue
                    End
                    //
                    If      (eGroup = tiContact) Begin
                        Clear Contact
                        Move iValue to Contact.ContactIdno
                        Find eq Contact.ContactIdno
                        Send DoDisplayContact of oContactEntry Contact.Recnum       
                    End
                    Else If (eGroup = tiLocation) Begin
                        Clear Location
                        Move iValue to Location.LocationIdno
                        Find eq Location.LocationIdno
                        Send DoDisplayLocation of oLocationEntry Location.Recnum
                    End
                    Else If (eGroup = tiOrder) Begin
                        Clear Order
                        Move iValue to Order.JobNumber
                        Find eq Order.JobNumber
                        Send DoViewOrder of oOrderEntry Order.Recnum
                    End
                    Else If (eGroup = tiInvoice) Begin
                        Send DoViewInvoice of oInvoiceViewer iValue
                        Procedure_Return
                    End
                    Else If (eGroup = tiQuote) Begin
                        Send DoViewQuote of oQuoteEntry iValue
                    End
                    Else If (eGroup = tiEstimate) Begin
                        Send DoCallFromClient to oRPCClient iValue "oEstimate"
                    End
                    // Ben - Commented following out to  avoid minimizing of Search Engine after a double click
                    Set View_Mode of oMegellan to Viewmode_Iconize

                End_Procedure

                Procedure OnItemRClick Handle hSelectedItem
                    Integer iData eGroup iValue
                    String  sFolder sFilename
                    // make sure the item is selected
                    If (CurrentTreeItem(Self) <> hSelectedItem) Begin
                        Set CurrentTreeItem to hSelectedItem
                    End
                    //
                    If (hSelectedItem = phRoot(Self)) Begin
                        Get piCustomerIdno to iValue
                    End
                    Else Begin
                        Get ItemData hSelectedItem      to iData
                        Get IsItemDataValue iData True  to eGroup
                        Get IsItemDataValue iData False to iValue
                        Set peGroup of oContextMenu     to eGroup
                    End
                    //
                    If (eGroup = tiOrders    or ;
                        eGroup = tiInvoices  or ;
                        eGroup = tiQuotes    or ;
                        eGroup = tiEstimates ) Begin
                        //
                        Procedure_Return
                    End
                    //
                    Set pbCreateOrganization    to False
                    Set pbCreateEstimate        to False
                    Set pbDisplayItem           to False
                    Set pbCreateContact         to False
                    Set pbCreateLocation        to False
                    Set pbCreateEditAPForm      to False
                    Set pbCreateQuote           to False
                    Set pbCreateOrder           to False
                    Set pbDocumentFolder        to False
                    Set pbSnowBook              to False
                    //
                    Send Popup of oContextMenu
                    //
                    
                    If (pbSnowBook (Self)) Begin
                        Clear Location
                        Move iValue to Location.LocationIdno
                        Find eq Location.LocationIdno
                        Send DoDisplayLocation of oSnowBook Location.Recnum
                    End
                    If (pbCreateEstimate(Self)) Begin
                        Send Info_Box "This function is not available" "Function not available"
                    End
                    If (pbCreateEditAPForm(Self)) Begin
                        Boolean bSuccess
                        Clear LocationAPForm
                        Move iValue to LocationAPForm.LocationAPIdno
                        Find eq LocationAPForm.LocationAPIdno
                        Get PromptAPForm of oAPForm iValue to bSuccess
                    End
                    If (pbCreateQuote(Self)) Begin
                        Clear Location
                        Move iValue to Location.LocationIdno
                        Find eq Location.LocationIdno
                        Send DoCreateQuote of oQuoteEntry Location.CustomerIdno Location.LocationIdno
                    End
                    If (pbCreateOrder(Self)) Begin
                        Clear Order
                        Move iValue to Location.LocationIdno
                        Find eq Location.LocationIdno
                        Send DoCreateOrder of oOrderEntry Location.CustomerIdno Location.LocationIdno
                    End
                    If (pbDocumentFolder(Self)) Begin
                        Clear Location
                        Move iValue to Location.LocationIdno
                        Find eq Location.LocationIdno
                        If ((Found) and Location.DocumentFolder <> "") Begin
                            Move (Trim(Location.DocumentFolder))                                                           to sFolder
                            Get IsSelectFile "All Files|*.*" "Select a file to open" sFolder to sFileName
                            If (sFilename = "") Break
                            Send DoStartDocument "open" sFilename ""
                        End
                        Else Begin
                            Send Stop_Box "No document folder is defined for this location"
                        End
                    End
                    If (pbCreateOrganization(Self)) Begin
                        Set phRefreshItem  to hSelectedItem
                        //Get piCustomerIdno to iValue
                        Send DoCreateCustomer of oCustomerEntry
                    End
                    //
                    If (pbCreateContact(Self)) Begin
                        Set phRefreshItem  to hSelectedItem
                        Get piCustomerIdno to iValue
                        Send DoCreateContact of oContactEntry iValue
                    End
                    If (pbCreateLocation(Self)) Begin
                        Set phRefreshItem  to hSelectedItem
                        Get piCustomerIdno to iValue
                        Send DoCreateLocation of oLocationEntry iValue
                    End
                    //
                    If (not(pbDisplayItem(Self))) Begin
                        Procedure_Return
                    End
                    //
                    If (hSelectedItem = phRoot(Self)) Begin
                        Send DoEditCustomerID of oCustomerEntry iValue
                    End
                    //
                    If      (eGroup = tiContact) Begin
                        Clear Contact
                        Move iValue to Contact.ContactIdno
                        Find eq Contact.ContactIdno
                        Send DoDisplayContact of oContactEntry Contact.Recnum
                    End
                    Else If (eGroup = tiLocation) Begin
                        Clear Location
                        Move iValue to Location.LocationIdno
                        Find eq Location.LocationIdno
                        Send DoDisplayLocation of oLocationEntry Location.Recnum
                    End
                    Else If (eGroup = tiOrder) Begin
                        Clear Order
                        Move iValue to Order.JobNumber
                        Find eq Order.JobNumber
                        Send DoViewOrder of oOrderEntry Order.Recnum
                    End
                    Else If (eGroup = tiInvoice) Begin
                        Send DoViewInvoice of oInvoiceViewer iValue
                    End
                    Else If (eGroup = tiQuote) Begin
                        Send DoViewQuote of oQuoteEntry iValue
                    End
                    Else If (eGroup = tiEstimate) Begin
                        Send DoCallFromClient to oRPCClient iValue "oEstimate"
                    End
                End_Procedure

                Procedure DoDisplaySearchResult Integer eGroup Integer iId
                    tGlblTreeViewData[] tData
                    //
                    Integer iValue iData
                    String  sValue
                    Handle  hRoot hGroup
                    //
                    Send ClearAll
                    Set ptData                to tData
                    Set peSearchType          to eGroup
                    Set piSearchId            to iId
                    Set piLocationContactIdno to 0
                    //
                    If      (eGroup = tiOrganization) Begin
                        Clear Customer
                        Move iId           to Customer.CustomerIdno
                        Find eq Customer.CustomerIdno
                        Set piCustomerIdno to Customer.CustomerIdno
                        //
//                        Move (String(Customer.CustomerIdno) * Trim(Customer.Name)) to sValue
//                        Get AddTreeItem sValue 0 tiOrganization 0 1                to hRoot
//                        Set phRoot                                                 to hRoot
//                        //
//                        Get AddTreeItem "Contacts"  hRoot tiContacts    3 1 to hGroup
//                        Set phContacts                                      to hGroup
//                        Set ItemChildCount hGroup                           to 1
//                        //
//                        Get AddTreeItem "Locations" hRoot tiLocations   2 1 to hGroup
//                        Set phLocations                                     to hGroup
//                        Set ItemChildCount hGroup                           to 1
                    End
                    Else If (eGroup = tiContacts) Begin
                        Clear Contact Customer
                        Move iId to Contact.ContactIdno
                        Find eq Contact.ContactIdno
                        Relate Contact
                        Set piCustomerIdno to Customer.CustomerIdno
                        //
//                        Move (String(Customer.CustomerIdno) * Trim(Customer.Name)) to sValue
//                        Get AddTreeItem sValue 0 tiOrganization 0 1                to hRoot
//                        Set phRoot                                                 to hRoot
//                        //
//                        Get AddTreeItem "Contacts"  hRoot tiContacts    3 1 to hGroup
//                        Set phContacts                                      to hGroup
//                        Set ItemChildCount hGroup                           to 1
//                        //
//                        Get AddTreeItem "Locations" hRoot tiLocations   2 1 to hGroup
//                        Set phLocations                                     to hGroup
//                        Set ItemChildCount hGroup                           to 1
                    End
                    Else If (eGroup = tiLocations) Begin
                        Clear Location Customer
                        Move iId to Location.LocationIdno
                        Find eq Location.LocationIdno
                        Relate Location
                        Set piCustomerIdno        to Customer.CustomerIdno
                        Set piLocationContactIdno to Location.ContactIdno
                    End
                    Else If (eGroup = tiOrder) Begin
                        Clear Order Location Customer
                        Move iId to Order.JobNumber
                        Find eq Order.JobNumber
                        Relate Order
                        Set piCustomerIdno        to Customer.CustomerIdno
                        Set piLocationIdno        to Location.LocationIdno
                        Set piLocationContactIdno to Location.PropmgrIdno
                        Set piJobNumber           to Order.JobNumber
                    End
                    Else If (eGroup = tiQuote) Begin
                        Clear Quotehdr Location Customer
                        Move iId to Quotehdr.QuotehdrID
                        Find eq Quotehdr.QuotehdrID
                        Relate Quotehdr
                        Set piCustomerIdno        to Customer.CustomerIdno
                        Set piLocationIdno        to Location.LocationIdno
                        Set piLocationContactIdno to Location.PropmgrIdno
                        Set piQuoteId             to Quotehdr.QuotehdrID
                    End
                    Else If (eGroup = tiEstimate) Begin
                        Clear Eshead Location Customer
                        Move iId to Eshead.ESTIMATE_ID
                        Find eq Eshead.ESTIMATE_ID
                        Relate Eshead
                        Set piCustomerIdno        to Customer.CustomerIdno
                        Set piLocationIdno        to Location.LocationIdno
                        Set piLocationContactIdno to Location.PropmgrIdno
                        Set piEsheadId            to Eshead.ESTIMATE_ID
                    End
                    //
                    Move (String(Customer.CustomerIdno) * Trim(Customer.Name)) to sValue
                    Get CreateDataValue tiOrganization 0 "Root"                to iData
                    Get AddTreeItem sValue 0 iData 0 1                         to hRoot
                    Set phRoot                                                 to hRoot
                    //
                    Get CreateDataValue tiContacts 0 ""         to iData
                    Get AddTreeItem "Contacts"  hRoot iData 3 1 to hGroup
                    Set phContacts                              to hGroup
                    Set ItemChildCount hGroup                   to 1
                    //
                    Get CreateDataValue tiLocations 0 ""        to iData
                    Get AddTreeItem "Locations" hRoot iData 2 1 to hGroup
                    Set phLocations                             to hGroup
                    Set ItemChildCount hGroup                   to 1
                    //
                    Send DoExpandItem (phRoot     (Self))
                    Send DoExpandItem (phContacts (Self))
                    Send DoExpandItem (phLocations(Self))
                    //
                    If (eGroup = tiOrder or eGroup = tiQuote) Begin
                        Send DoExpandItem (phLocation(Self))
                        Send DoExpandItem (phItem    (Self))
                    End
                End_Procedure
            End_Object

            Object oHistoryTrackBar is a TrackBar
                Set Size to 19 131
                Set Location to 251 7
                Set Label to "Years"
                Set Label_Justification_Mode to JMode_Top
                Set Label_Col_Offset to 0
                Set peAnchors to anBottomLeftRight
                Set Minimum_Position to 1
                Set Maximum_Position to 100
                Set Page_Size to 10
                Set Tick_Frequency to 10
                Set Current_Position to 3
                Set pbCenterToolTip to True
            
                //OnSetPosition is always called when the slider changes.
            
                Procedure OnSetPosition
                    Integer iCurPos
                    Date dToday dStartDate
                    Sysdate dToday
                    Get Current_Position to iCurPos
                    Set Label to ("Showing Quotes, Order and Invoices of the past"* String(iCurPos)*"year(s)")
                    Set pdStartDate to (dToday - (iCurPos*365))
                    //
                    Send DoUpdateSearch of oGridContainer
                    //
                End_Procedure
            
            End_Object

            Object oStatusCheckBox is a CheckBox
                Set Size to 10 50
                Set Location to 255 147
                Set Label to 'Active Only'
                Set Checked_State to True
                Set peAnchors to anBottomRight

                Procedure OnChange
                    Forward Send OnChange
                    Send DoUpdateSearch of oGridContainer
                End_Procedure

            End_Object

        End_Object

        Object oGridContainer is a cSplitterContainerChild

            Property Integer peGroup

            Object oResultGrid is a Grid

                Property Boolean pbFilled

                Set Location to 5 4
                Set Size to 236 402
                Set peAnchors to anAll
//                Set Line_Width to 6 0
                Set Line_Width to 5 0
                Set peResizeColumn to rcAll
            
                Set Form_Width                0 to 38
                Set Header_Label              0 to "Org ID"
                Set Header_Justification_Mode 0 to JMode_Right
            
                Set Form_Width   1 to 202
                Set Header_Label 1 to "Organization Name"

                Set Form_Width   2 to 110
                Set Header_Label 2 to "City"

                Set Form_Width   3 to 50
                Set Header_Label 3 to "Zip"

                Set Form_Width   4 to 1
                Set Header_Label 4 to "Status"
                Set CurrentCellColor to clYellow
                Set CurrentCellTextColor to clBlack
                Set CurrentRowColor to clYellow
                Set CurrentRowTextColor to clBlack
                Set Highlight_Row_State to True

//                Set Form_Width   5 to 1
//                Set Header_Label 5 to ""

                Procedure AddReadOnlyItem String sValue Boolean bNumber
                    Integer iItem
                    //
                    Move (Item_Count(Self))                       to iItem
                    Send Add_Item msg_None                           sValue
                    If (bNumber) Begin
                        Set Form_Datatype item iItem              to MASK_NUMERIC_WINDOW
                    End
                    Set Entry_State item ((Item_Count(Self)) - 1) to False
                End_Procedure

                Procedure DoFillGrid tSearchResults[] tResults
                    Integer iItems iItem
                    //
                    Set pbFilled                 to False
                    Set Dynamic_Update_State     to False
                    Send Delete_Data
                    Set Select_Mode              to Multi_Select
                    //
                    Move (SizeOfArray(tResults)) to iItems
                    Decrement iItems
                    For iItem from 0 to iItems
                        Send AddReadOnlyItem tResults[iItem].iId   True
                        Send AddReadOnlyItem tResults[iItem].sCol1 False
                        Send AddReadOnlyItem tResults[iItem].sCol2 False
                        Send AddReadOnlyItem tResults[iItem].sCol3 False
                        Send AddReadOnlyItem tResults[iItem].sCol4 False
                    Loop
                    //
                    Set Select_Mode          to No_Select
                    Set Dynamic_Update_State to True
                    Set pbFilled             to True
//                    Set Current_Item         to 0
                    Send Beginning_of_Data
                End_Procedure
            
                Function IsWidth Number nCol Number nGrid Number ngGrid Returns Integer
                    Integer iWidth
                    Number  nWidth
                    //
                    Move ((nCol / nGrid) * ngGrid) to nWidth
                    Move (Round(nWidth))           to iWidth
                    Function_Return iWidth
                End_Function

                Procedure DoConfigureHeaders
                    Integer iSize igSize iWidth igWidth eGroup
                    //
                    Get Size           to iSize
                    Move (Low(iSize))  to iWidth
                    Get GuiSize        to igSize
                    Move (Low(igSize)) to igWidth
                    Get peGroup        to eGroup
                    //
                    If      (eGroup = tiOrganization) Begin
                        Set Form_Width   0 to (IsWidth(Self,38,409,iWidth))
                        Set Header_Label 0 to "Org ID"
                        Set Form_Width   1 to (IsWidth(Self,202,409,iWidth))
                        Set Header_Label 1 to "Organization Name"
                        Set Form_Width   2 to (IsWidth(Self,110,409,iWidth))
                        Set Header_Label 2 to "City"
                        Set Form_Width   3 to (IsWidth(Self,50,409,iWidth))
                        Set Header_Label 3 to "Zip"
                        Set Form_Width   4 to 0
                        Set Header_Label 4 to ""
//                        Set Form_Width   5 to 0
//                        Set Header_Label 5 to ""
                    End
                    Else If (eGroup = tiContacts    ) Begin
                        Set Form_Width   0 to (IsWidth(Self,38,409,iWidth))
                        Set Header_Label 0 to "Cont ID"
                        Set Form_Width   1 to (IsWidth(Self,105,409,iWidth))
                        Set Header_Label 1 to "Last Name"
                        Set Form_Width   2 to (IsWidth(Self,105,409,iWidth))
                        Set Header_Label 2 to "First Name"
                        Set Form_Width   3 to (IsWidth(Self,102,409,iWidth))
                        Set Header_Label 3 to "City"
                        Set Form_Width   4 to (IsWidth(Self,50,409,iWidth))
                        Set Header_Label 4 to "Zip"
//                        Set Form_Width   5 to 0
//                        Set Header_Label 5 to ""
                    End
                    Else If (eGroup = tiLocations   ) Begin
                        Set Form_Width   0 to (IsWidth(Self,38,409,iWidth))
                        Set Header_Label 0 to "Loc ID"
                        Set Form_Width   1 to (IsWidth(Self,120,409,iWidth))
                        Set Header_Label 1 to "Location Name"
                        Set Form_Width   2 to (IsWidth(Self,110,409,iWidth))
                        Set Header_Label 2 to "Address"
                        Set Form_Width   3 to (IsWidth(Self,82,409,iWidth))
                        Set Header_Label 3 to "City"
                        Set Form_Width   4 to (IsWidth(Self,50,409,iWidth))
                        Set Header_Label 4 to "Zip"
//                        Set Form_Width   5 to 0
//                        Set Header_Label 5 to ""
                    End
                    Else If (eGroup = tiOrder       ) Begin
                        Set Form_Width   0 to (IsWidth(Self,38,409,iWidth))
                        Set Header_Label 0 to "Job Number"
                        Set Form_Width   1 to (IsWidth(Self,120,409,iWidth))
                        Set Header_Label 1 to "Location Name"
                        Set Form_Width   2 to (IsWidth(Self,110,409,iWidth))
                        Set Header_Label 2 to "Address"
                        Set Form_Width   3 to (IsWidth(Self,82,409,iWidth))
                        Set Header_Label 3 to "City"
                        Set Form_Width   4 to (IsWidth(Self,50,409,iWidth))
                        Set Header_Label 4 to "Zip"
                    End
                    Else If (eGroup = tiQuote       ) Begin
                        Set Form_Width   0 to (IsWidth(Self,38,409,iWidth))
                        Set Header_Label 0 to "Quote ID"
                        Set Form_Width   1 to (IsWidth(Self,120,409,iWidth))
                        Set Header_Label 1 to "Location Name"
                        Set Form_Width   2 to (IsWidth(Self,110,409,iWidth))
                        Set Header_Label 2 to "Address"
                        Set Form_Width   3 to (IsWidth(Self,82,409,iWidth))
                        Set Header_Label 3 to "City"
                        Set Form_Width   4 to (IsWidth(Self,50,409,iWidth))
                        Set Header_Label 4 to "Zip"
                    End
                    Else If (eGroup = tiEstimate       ) Begin
                        Set Form_Width   0 to (IsWidth(Self,38,409,iWidth))
                        Set Header_Label 0 to "Estimate ID"
                        Set Form_Width   1 to (IsWidth(Self,120,409,iWidth))
                        Set Header_Label 1 to "Location Name"
                        Set Form_Width   2 to (IsWidth(Self,110,409,iWidth))
                        Set Header_Label 2 to "Address"
                        Set Form_Width   3 to (IsWidth(Self,82,409,iWidth))
                        Set Header_Label 3 to "City"
                        Set Form_Width   4 to (IsWidth(Self,50,409,iWidth))
                        Set Header_Label 4 to "Zip"
                    End
                    Else If (eGroup = tiInvoice     ) Begin
                        Set Form_Width   0 to (IsWidth(Self,38,409,iWidth))
                        Set Header_Label 0 to "Invoice"
                        Set Form_Width   1 to (IsWidth(Self,120,409,iWidth))
                        Set Header_Label 1 to "Location Name"
                        Set Form_Width   2 to (IsWidth(Self,110,409,iWidth))
                        Set Header_Label 2 to "Address"
                        Set Form_Width   3 to (IsWidth(Self,82,409,iWidth))
                        Set Header_Label 3 to "City"
                        Set Form_Width   4 to (IsWidth(Self,50,409,iWidth))
                        Set Header_Label 4 to "Zip"
                    End
                End_Procedure            

                Procedure Item_Change Integer iFromItem Integer iToItem Returns Integer
                    Integer iCols iCol iCurrentCol iBaseItem iRetval eGroup iId iItem
                    //
                    If (pbFilled(Self)) Begin
                        Move 5                    to iCols
//                        Get piCols                to iCols
                        Move (mod(iToItem,iCols)) to iCol
                        Move (iToItem   / iCols)  to iBaseItem
                        Move (iBaseItem * iCols)  to iBaseItem
                        If (iCol <> 0) Begin
                            Move iBaseItem        to iRetval
                        End
                        Else Begin
                            Move iToItem          to iRetval
                        End
                        //
                        Get peGroup               to eGroup
                        Get Value item iRetval    to iId
                        //
                        Send DoDisplaySearchResult of oResultTreeView eGroup iId
                    End // if (pbFilled(self)) begin
                    //
                    Else Begin
                        Forward Get msg_Item_Change iFromItem iToItem to iRetval
                    End
                    //
                    Procedure_Return iRetval
                End_Procedure
            End_Object

            Object oSearchContainer is a Container3d
                Set Size to 29 398
                Set Location to 244 3
                Set peAnchors to anBottomLeftRight
    
                Object oSearchInComboForm is a ComboForm
                    Set Size to 13 100
                    Set Location to 10 5
                    Set Label_Col_Offset to 0
                    Set Label_Justification_Mode to JMode_Top
                    Set Label to "Search in"
                    Set peAnchors to anBottomLeft
                    Set Combo_Sort_State to False
                    Set Value to "Organization Name"
                    Set Label_FontUnderLine to True
                    Set Label_Row_Offset to 1
    
                    Procedure Combo_Fill_List
                        Send Combo_Add_Item "Organization Name"
                        Send Combo_Add_Item "Contact Last Name"
                        Send Combo_Add_Item "Contact First Name"
                        Send Combo_Add_Item "Location Name"
                        Send Combo_Add_Item "Location Address"
                        Send Combo_Add_Item "Location City"
                        Send Combo_Add_Item "Location Zip"
                        Send Combo_Add_Item "Job Number"
                        Send Combo_Add_Item "Quote Number"
                        Send Combo_Add_Item "Estimate Number"
                        Send Combo_Add_Item "Invoice Number"
                    End_Procedure
                
                    Procedure OnChange
                        String sValue
                        //
                        Send Delete_Data of oResultGrid
                        //
                        Get Value to sValue
                        If      (sValue = "Organization Name" ) Begin
                            Set peGroup             of oResultGrid to tiOrganization
                            Send DoConfigureHeaders of oResultGrid
                        End
                        Else If (sValue = "Contact Last Name" ) Begin
                            Set peGroup             of oResultGrid to tiContacts
                            Send DoConfigureHeaders of oResultGrid
                        End
                        Else If (sValue = "Contact First Name") Begin
                            Set peGroup             of oResultGrid to tiContacts
                            Send DoConfigureHeaders of oResultGrid
                        End
                        Else If (sValue = "Location Name"     ) Begin
                            Set peGroup             of oResultGrid to tiLocations
                            Send DoConfigureHeaders of oResultGrid
                        End
                        Else If (sValue = "Location Address"  ) Begin
                            Set peGroup             of oResultGrid to tiLocations
                            Send DoConfigureHeaders of oResultGrid
                        End
                        Else If (sValue = "Location City"     ) Begin
                            Set peGroup             of oResultGrid to tiLocations
                            Send DoConfigureHeaders of oResultGrid
                        End
                        Else If (sValue = "Location Zip"      ) Begin
                            Set peGroup             of oResultGrid to tiLocations
                            Send DoConfigureHeaders of oResultGrid
                        End
                        Else If (sValue = "Job Number"        ) Begin
                            Set peGroup             of oResultGrid to tiOrder
                            Send DoConfigureHeaders of oResultGrid
                        End
                        Else If (sValue = "Quote Number"      ) Begin
                            Set peGroup             of oResultGrid to tiQuote
                            Send DoConfigureHeaders of oResultGrid
                        End
                        Else If (sValue = "Estimate Number"      ) Begin
                            Set peGroup             of oResultGrid to tiEstimate
                            Send DoConfigureHeaders of oResultGrid
                        End
                        Else If (sValue = "Invoice Number"    ) Begin
                            Set peGroup             of oResultGrid to tiInvoice
                            Send DoConfigureHeaders of oResultGrid
                        End
                    End_Procedure
                
                    //Notification that the list has dropped down
                    //Procedure OnDropDown
                    //End_Procedure
                
                    //Notification that the list was closed
                    //Procedure OnCloseUp
                    //End_Procedure
                
                End_Object
                
                Object oSearchForForm is a Form
                    Set Size to 13 156
                    Set Location to 10 115
                    Set peAnchors to anBottomLeftRight
                    Set Label_Col_Offset to 0
                    Set Label_Justification_Mode to JMode_Top
                    Set Label to "Search for"
                    Set Label_FontUnderLine to True
                    Set Label_Row_Offset to 1

                    Procedure Activating
                        Forward Send Activating
                        Set Visible_State to False
                        Set Visible_State to True
                    End_Procedure
                    
                    On_Key kEnter Send DoSearch
                    
                End_Object
    
                Object oSearchButton is a Button
                    Set Location to 9 280
                    Set Label to "Search"
                    Set peAnchors to anBottomRight
                    Set Skip_State to True
                
                    Procedure OnClick
                        Send DoSearch
                    End_Procedure
                End_Object
    
                Object oContainsCheckBox is a cGlblCheckBox
                    Set Size to 10 50
                    Set Location to 11 344
                    Set Label to "Contains"
                    Set peAnchors to anBottomRight
                    Set Checked_State to True
    
                    Procedure OnChange
                        Boolean bChecked
                        Get Checked_State to bChecked
                        Send DoUpdateSearch of oGridContainer
                    End_Procedure  // OnChange
                End_Object
                
            End_Object


            Procedure DoUpdateSearch
                Integer iCurrentItem iSuccess
                Get Current_Item of oResultGrid to iCurrentItem
                If (iCurrentItem<>0) Begin
                    Send DoSearch of oGridContainer
                    //Get msg_Activate_Item of oResultGrid iCurrentItem to iSuccess
                End
                //Get msg_Activate of oResultTreeView to iSuccess
                //Send DoMakeItemFirstVisible of oResultTreeView 0
                //Send Top_of_Panel of oResultTreeView                
            End_Procedure

            Procedure DoSearch
                tSearchResults[] tResults
                //
                Boolean bContains bStatus
                Integer eGroup iSize
                String  sValue sSearch
                //
                Send Delete_Data  of oResultGrid
                Get Value         of oSearchInComboForm to sSearch
                Get peGroup       of oResultGrid        to eGroup
                Get Checked_State of oContainsCheckBox  to bContains
                Get Value         of oSearchForForm     to sValue
                Move (Uppercase(sValue))                to sValue
                Move (Trim     (sValue))                to sValue
                //
                Get Checked_State of oStatusCheckBox to bStatus
                Set pbActive to (bStatus)
                //
                If      (eGroup = tiOrganization) Begin
                    If (bContains) Get DoSearchOrganizationNameContains sValue to tResults
                    Else           Get DoSearchOrganizationName         sValue to tResults
                End
                Else If (eGroup = tiContacts) Begin
                    If (sSearch = "Contact Last Name") Begin
                        If (bContains) Get DoSearchContactLastNameContains sValue to tResults
                        Else           Get DoSearchContactLastName         sValue to tResults
                    End
                    Else Begin
                        If (bContains) Get DoSearchContactFirstNameContains sValue to tResults
                        Else           Get DoSearchContactFirstName         sValue to tResults
                    End
                End
                Else If (eGroup = tiLocations) Begin
                    If      (sSearch = "Location Name") Begin
                        If (bContains) Get DoSearchLocationNameContains sValue to tResults
                        Else           Get DoSearchLocationName         sValue to tResults
                    End
                    Else If (sSearch = "Location Address") Begin
                        If (bContains) Get DoSearchLocationAddressContains sValue to tResults
                        Else           Get DoSearchLocationAddress         sValue to tResults
                    End
                    Else If (sSearch = "Location City") Begin
                        If (bContains) Get DoSearchLocationCityContains sValue to tResults
                        Else           Get DoSearchLocationCity         sValue to tResults
                    End
                    Else Begin
                        If (bContains) Get DoSearchLocationZipContains sValue to tResults
                        Else           Get DoSearchLocationZip         sValue to tResults
                    End
                End
                Else If (eGroup = tiOrder) Begin
                    Get DoSearchJobNumber sValue to tResults
                End
                Else If (eGroup = tiQuote) Begin
                    Get DoSearchQuoteId sValue to tResults
                End
                Else If (eGroup = tiEstimate) Begin
                    Get DoSearchEstimateId sValue to tResults
                End
                // Ben - Added 07/02/2012 - Enabeling Invoice search
                Else If (eGroup = tiInvoice) Begin
                    Get DoSearchInvoiceNumber sValue to tResults
                    Send DoViewInvoice of oInvoiceViewer sValue
                End
                //
                If (SizeOfArray(tResults)) Begin
                    Send DoFillGrid of oResultGrid tResults
                End
                //
                Send Activate of oSearchForForm
            End_Procedure

            Function DoSearchOrganizationName String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iLength iItem
                String  sName
                //
                Move (Length(sValue)) to iLength
                Clear Customer
                Move sValue to Customer.Name
                Find ge Customer.Name
                While (Found)
                    Move (Left(Customer.Name,iLength)) to sName
                    Move (Uppercase(sName))            to sName
                    //If (sName = sValue) Begin
                    If (sName = sValue and If(pbActive(Self),Customer.Status="A",Customer.Status<>"")) Begin
                        Move (SizeOfArray(tResults))        to iItem
                        Move Customer.CustomerIdno          to tResults[iItem].iId
                        Move (trim(Customer.Name))          to tResults[iItem].sCol1
                        Move (trim(Customer.City))          to tResults[iItem].sCol2
                        Move (Left(Trim(Customer.Zip),5))   to tResults[iItem].sCol3
                        Move (Customer.Status)              to tResults[iItem].sCol4
                    End
                    Else Break
                    //
                    Find gt Customer.Name
                Loop
                Function_Return tResults
            End_Function // DoSearchOrganizationName

            Function DoSearchOrganizationNameContains String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iItem
                String  sName
                //
                Clear Customer
                Find ge Customer.Name
                While (Found)
                    Move (Trim(Customer.Name)) to sName
                    Move (Uppercase(sName))    to sName
                    //If (sName contains sValue and Customer.Status = sActiveStatus) Begin
                    If (sName contains sValue and If(pbActive(Self),Customer.Status="A",Customer.Status<>"")) Begin
                        Move (SizeOfArray(tResults))        to iItem
                        Move Customer.CustomerIdno          to tResults[iItem].iId
                        Move (trim(Customer.Name))          to tResults[iItem].sCol1
                        Move (trim(Customer.City))          to tResults[iItem].sCol2
                        Move (Left(Trim(Customer.Zip),5))   to tResults[iItem].sCol3
                        Move (Customer.Status)              to tResults[iItem].sCol4
                    End
                    //
                    Find gt Customer.Name
                Loop
                Function_Return tResults
            End_Function // DoSearchOrganizationNameContains

            Function DoSearchContactLastName String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iLength iItem
                String  sName
                //
                Move (Length(sValue)) to iLength
                Clear Contact
                Move sValue to Contact.LastName
                Find ge Contact.LastName
                While (Found)
                    Move (Left(Contact.LastName,iLength)) to sName
                    Move (Uppercase(sName))               to sName
                    If (sName = sValue and If(pbActive(Self),Contact.Status="A",Contact.Status<>"")) Begin
                        Move (SizeOfArray(tResults))   to iItem
                        Move Contact.ContactIdno                        to tResults[iItem].iId
                        Move (trim(Contact.FirstName*Contact.LastName)) to tResults[iItem].sCol1
                        Move (Trim(Contact.City))                       to tResults[iItem].sCol2
                        Move (Left(Trim(Contact.Zip),5))                to tResults[iItem].sCol3
                        Move (Contact.Status)                           to tResults[iItem].sCol4
                    End
                    Else Break
                    //
                    Find gt Contact.LastName
                Loop
                Function_Return tResults
            End_Function // DoSearchContactLastName

            Function DoSearchContactLastNameContains String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iItem
                String  sName
                //
                Clear Contact
                Find ge Contact.LastName
                While (Found)
                    Move (trim(Contact.LastName))      to sName
                    Move (Uppercase(sName))            to sName
                    If (sName contains sValue and If(pbActive(Self),Contact.Status="A",Contact.Status<>"")) Begin
                        Move (SizeOfArray(tResults))   to iItem
                        Move Contact.ContactIdno                        to tResults[iItem].iId
                        Move (trim(Contact.FirstName*Contact.LastName)) to tResults[iItem].sCol1
                        Move (Trim(Contact.City))                       to tResults[iItem].sCol2
                        Move (Left(Trim(Contact.Zip),5))                to tResults[iItem].sCol3
                        Move (Contact.Status)                           to tResults[iItem].sCol4
                    End
                    //
                    Find gt Contact.LastName
                Loop
                Function_Return tResults
            End_Function // DoSearchContactLastNameContains

            Function DoSearchContactFirstName String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iLength iItem
                String  sName
                //
                Move (Length(sValue)) to iLength
                Clear Contact
                Find ge Contact.FirstName
                While (Found)
                    Move (Left(Contact.FirstName,iLength)) to sName
                    Move (Uppercase(sName))                to sName
                    If (sName = sValue and If(pbActive(Self),Contact.Status="A",Contact.Status<>"")) Begin
                        Move (SizeOfArray(tResults))   to iItem
                        Move Contact.ContactIdno                        to tResults[iItem].iId
                        Move (trim(Contact.FirstName*Contact.LastName)) to tResults[iItem].sCol1
                        Move (Trim(Contact.City))                       to tResults[iItem].sCol2
                        Move (Left(Trim(Contact.Zip),5))                to tResults[iItem].sCol3
                        Move (Contact.Status)                           to tResults[iItem].sCol4
                    End
                    //
                    Find gt Contact.LastName
                Loop
                Function_Return tResults
            End_Function // DoSearchContactFirstName

            Function DoSearchContactFirstNameContains String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iItem
                String  sName
                //
                Clear Contact
                Find ge Contact.FirstName
                While (Found)
                    Move (trim(Contact.FirstName))     to sName
                    Move (Uppercase(sName))            to sName
                    If (sName contains sValue and If(pbActive(Self),Contact.Status="A",Contact.Status<>"")) Begin
                        Move (SizeOfArray(tResults))   to iItem
                        Move Contact.ContactIdno                        to tResults[iItem].iId
                        Move (trim(Contact.FirstName*Contact.LastName)) to tResults[iItem].sCol1
                        Move (Trim(Contact.City))                       to tResults[iItem].sCol2
                        Move (Left(Trim(Contact.Zip),5))                to tResults[iItem].sCol3
                        Move (Contact.Status)                           to tResults[iItem].sCol4
                    End
                    //
                    Find gt Contact.LastName
                Loop
                Function_Return tResults
            End_Function // DoSearchContactFirstNameContains

            Function DoSearchLocationName String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iLength iItem
                String  sName
                //
                Move (Length(sValue)) to iLength
                Clear Location
                Move sValue to Location.Name
                Find ge Location.Name
                While (Found)
                    Move (Left(Location.Name,iLength)) to sName
                    Move (Uppercase(sName))            to sName
                    If (sName = sValue and If(pbActive(Self),Location.Status="A",Location.Status<>"")) Begin
                        Move (SizeOfArray(tResults))   to iItem
                        Move Location.LocationIdno     to tResults[iItem].iId
                        Move (trim(Location.Name))     to tResults[iItem].sCol1
                        Move (trim(Location.Address1)) to tResults[iItem].sCol2
                        Move (trim(Location.City))     to tResults[iItem].sCol3
                        Move (Trim(Location.Zip))      to tResults[iItem].sCol4
                    End
                    Else Break
                    //
                    Find gt Location.Name
                Loop
                Function_Return tResults
            End_Function // DoSearchLocationName

            Function DoSearchLocationNameContains String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iItem
                String  sName
                //
                Clear Location
                Find ge Location.Name
                While (Found)
                    Move (Trim(Location.Name)) to sName
                    Move (Uppercase(sName))    to sName
                    If (sName contains sValue and If(pbActive(Self),Location.Status="A",Location.Status<>"")) Begin
                        Move (SizeOfArray(tResults))   to iItem
                        Move Location.LocationIdno     to tResults[iItem].iId
                        Move (trim(Location.Name))     to tResults[iItem].sCol1
                        Move (trim(Location.Address1)) to tResults[iItem].sCol2
                        Move (trim(Location.City))     to tResults[iItem].sCol3
                        Move (Trim(Location.Zip))      to tResults[iItem].sCol4
                    End
                    //
                    Find gt Location.Name
                Loop
                Function_Return tResults
            End_Function // DoSearchLocationNameContains

            Function DoSearchLocationAddress String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iLength iItem
                String  sName
                //
                Move (Length(sValue)) to iLength
                Clear Location
                Move sValue to Location.Address1
                Find ge Location.Address1
                While (Found)
                    Move (Left(Location.Address1,iLength)) to sName
                    Move (Uppercase(sName))                to sName
                    If (sName = sValue and If(pbActive(Self),Location.Status="A",Location.Status<>"")) Begin
                        Move (SizeOfArray(tResults))   to iItem
                        Move Location.LocationIdno     to tResults[iItem].iId
                        Move (trim(Location.Name))     to tResults[iItem].sCol1
                        Move (trim(Location.Address1)) to tResults[iItem].sCol2
                        Move (trim(Location.City))     to tResults[iItem].sCol3
                        Move (Trim(Location.Zip))      to tResults[iItem].sCol4
                    End
                    Else Break
                    //
                    Find gt Location.Address1
                Loop
                Function_Return tResults
            End_Function // DoSearchLocationAddress

            Function DoSearchLocationAddressContains String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iItem
                String  sName
                //
                Clear Location
                Find ge Location.Address1
                While (Found)
                    Move (Trim(Location.Address1)) to sName
                    Move (Uppercase(sName))        to sName
                    If (sName contains sValue and If(pbActive(Self),Location.Status="A",Location.Status<>"")) Begin
                        Move (SizeOfArray(tResults))   to iItem
                        Move Location.LocationIdno     to tResults[iItem].iId
                        Move (trim(Location.Name))     to tResults[iItem].sCol1
                        Move (trim(Location.Address1)) to tResults[iItem].sCol2
                        Move (trim(Location.City))     to tResults[iItem].sCol3
                        Move (Trim(Location.Zip))      to tResults[iItem].sCol4
                    End
                    //
                    Find gt Location.Address1
                Loop
                Function_Return tResults
            End_Function // DoSearchLocationAddressContains

            Function DoSearchLocationCity String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iLength iItem
                String  sName
                //
                Move (Length(sValue)) to iLength
                Clear Location
                Find ge Location.Name
                While (Found)
                    Move (Left(Location.City,iLength)) to sName
                    Move (Uppercase(sName))            to sName
                    If (sName = sValue and If(pbActive(Self),Location.Status="A",Location.Status<>"")) Begin
                        Move (SizeOfArray(tResults))   to iItem
                        Move Location.LocationIdno     to tResults[iItem].iId
                        Move (trim(Location.Name))     to tResults[iItem].sCol1
                        Move (trim(Location.Address1)) to tResults[iItem].sCol2
                        Move (trim(Location.City))     to tResults[iItem].sCol3
                        Move (Trim(Location.Zip))      to tResults[iItem].sCol4
                    End
                    //
                    Find gt Location.Name
                Loop
                Function_Return tResults
            End_Function // DoSearchLocationCity

            Function DoSearchLocationCityContains String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iItem
                String  sName
                //
                Clear Location
                Find ge Location.Name
                While (Found)
                    Move (Trim(Location.City)) to sName
                    Move (Uppercase(sName))    to sName
                    If (sName contains sValue and If(pbActive(Self),Location.Status="A",Location.Status<>"")) Begin
                        Move (SizeOfArray(tResults))   to iItem
                        Move Location.LocationIdno     to tResults[iItem].iId
                        Move (trim(Location.Name))     to tResults[iItem].sCol1
                        Move (trim(Location.Address1)) to tResults[iItem].sCol2
                        Move (trim(Location.City))     to tResults[iItem].sCol3
                        Move (Trim(Location.Zip))      to tResults[iItem].sCol4
                    End
                    //
                    Find gt Location.Name
                Loop
                Function_Return tResults
            End_Function // DoSearchLocationCityContains

            Function DoSearchLocationZip String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iLength iItem
                String  sName
                //
                Move (Length(sValue)) to iLength
                Clear Location
                Find ge Location.Name
                While (Found)
                    Move (Left(Location.Zip,iLength)) to sName
                    Move (Uppercase(sName))            to sName
                    If (sName = sValue and If(pbActive(Self),Location.Status="A",Location.Status<>"")) Begin
                        Move (SizeOfArray(tResults))   to iItem
                        Move Location.LocationIdno     to tResults[iItem].iId
                        Move (trim(Location.Name))     to tResults[iItem].sCol1
                        Move (trim(Location.Address1)) to tResults[iItem].sCol2
                        Move (trim(Location.City))     to tResults[iItem].sCol3
                        Move (Trim(Location.Zip))      to tResults[iItem].sCol4
                    End
                    //
                    Find gt Location.Name
                Loop
                Function_Return tResults
            End_Function // DoSearchLocationZip

            Function DoSearchLocationZipContains String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iItem
                String  sName
                //
                Clear Location
                Find ge Location.Name
                While (Found)
                    Move (Trim(Location.Zip)) to sName
                    Move (Uppercase(sName))   to sName
                    If (sName contains sValue and If(pbActive(Self),Location.Status="A",Location.Status<>"")) Begin
                        Move (SizeOfArray(tResults))   to iItem
                        Move Location.LocationIdno     to tResults[iItem].iId
                        Move (trim(Location.Name))     to tResults[iItem].sCol1
                        Move (trim(Location.Address1)) to tResults[iItem].sCol2
                        Move (trim(Location.City))     to tResults[iItem].sCol3
                        Move (Trim(Location.Zip))      to tResults[iItem].sCol4
                    End
                    //
                    Find gt Location.Name
                Loop
                Function_Return tResults
            End_Function // DoSearchLocationZipContains

            Function DoSearchJobNumber String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iJobNumber iItem
                String  sName
                //
                Move (String(sValue)) to iJobNumber
                Clear Order Location
                Move iJobNumber to Order.JobNumber
                Find eq Order.JobNumber
                If (Found) Begin
                    Relate Order
                    Move (SizeOfArray(tResults))   to iItem
                    Move Order.JobNumber           to tResults[iItem].iId
                    Move (trim(Location.Name))     to tResults[iItem].sCol1
                    Move (trim(Location.Address1)) to tResults[iItem].sCol2
                    Move (trim(Location.City))     to tResults[iItem].sCol3
                    Move (Trim(Location.Zip))      to tResults[iItem].sCol4
                End
                Function_Return tResults
            End_Function // DoSearchJobNumber

            
            // Ben - Added 07/02/2012 - To enable Invoice number Search
            Function DoSearchInvoiceNumber String sValue Returns tSearchResults[]
                tSearchResults[] tResults

                Integer iInvNumber iItem
                String  sName

                Move (String(sValue)) to iInvNumber
                Clear Order Location Invhdr
                Move iInvNumber to Invhdr.InvoiceIdno
                Find eq Invhdr.InvoiceIdno
               
                If (Found) Begin
                    Relate Order
                    Move (SizeOfArray(tResults))   to iItem
                    Move Invhdr.InvoiceIdno           to tResults[iItem].iId
                    Move (trim(Invhdr.InvoiceDate))     to tResults[iItem].sCol1
                    Move (trim(Invhdr.TotalAmount)) to tResults[iItem].sCol2
                End
                Function_Return tResults
            End_Function // DoSearchInvoiceNumber

            Function DoSearchQuoteId String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iQuoteId iItem
                //
                Move (String(sValue)) to iQuoteId
                Clear Quotehdr Order Location
                Move iQuoteId to Quotehdr.QuotehdrID
                Find eq Quotehdr.QuotehdrID
                If (Found) Begin
                    Relate Quotehdr
                    Move (SizeOfArray(tResults))   to iItem
                    Move Quotehdr.QuotehdrID       to tResults[iItem].iId
                    Move (trim(Location.Name))     to tResults[iItem].sCol1
                    Move (trim(Location.Address1)) to tResults[iItem].sCol2
                    Move (trim(Location.City))     to tResults[iItem].sCol3
                    Move (Trim(Location.Zip))      to tResults[iItem].sCol4
                End
                Function_Return tResults
            End_Function // DoSearchQuoteId
            
            Function DoSearchEstimateId String sValue Returns tSearchResults[]
                tSearchResults[] tResults
                //
                Integer iEstimateId iItem
                //
                Move (String(sValue)) to iEstimateId
                Clear Eshead Order Location
                Move iEstimateId to Eshead.ESTIMATE_ID
                Find eq Eshead.ESTIMATE_ID
                If (Found) Begin
                    Relate Eshead
                    Move (SizeOfArray(tResults))   to iItem
                    Move Eshead.ESTIMATE_ID        to tResults[iItem].iId
                    Move (trim(Location.Name))     to tResults[iItem].sCol1
                    Move (trim(Location.Address1)) to tResults[iItem].sCol2
                    Move (trim(Location.City))     to tResults[iItem].sCol3
                    Move (Trim(Location.Zip))      to tResults[iItem].sCol4
                End
                Function_Return tResults
            End_Function // DoSearchQuoteId
        End_Object
    End_Object

    Procedure Activate Returns Integer
        Integer iRetval
        //
        Forward Get msg_Activate to iRetval
        //
        If (not(iRetval)) Begin
            Send Activate of oSearchForForm
            //
            If (phRefreshItem(Self)) Begin
                Send DoCollapseItem of oResultTreeView (phRefreshItem(Self))
                Send DoExpandItem   of oResultTreeView (phRefreshItem(Self))
                Set phRefreshItem to 0
            End
        End
        //
        Procedure_Return iRetval
    End_Procedure

End_Object
