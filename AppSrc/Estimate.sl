// Estimate.sl
// Estimate Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Customer.DD
Use Areas.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use Location.DD
Use SalesRep.DD
Use Contact.DD
Use Eshead.DD

Cd_Popup_Object oEstimate_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 610
    Set Label To "Estimate Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oCustomer_DD is a Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oAreas_DD is a Areas_DataDictionary
    End_Object // oAreas_DD

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object // oSalesTaxGroup_DD

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oAreas_DD
        Set DDO_Server To oSalesTaxGroup_DD
    End_Object // oLocation_DD

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object // oSalesRep_DD

    Object oContact_DD is a Contact_DataDictionary
        Set DDO_Server To oCustomer_DD
    End_Object // oContact_DD

    Object oEshead_DD is a Eshead_DataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server To oContact_DD
        Set DDO_Server To oSalesRep_DD
    End_Object // oEshead_DD

    Set Main_DD To oEshead_DD
    Set Server  To oEshead_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 600
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "oEstimate_oSelList"
        Set pbAutoServer to True

        Object oEshead_ESTIMATE_ID is a cDbCJGridColumn
            Entry_Item Eshead.ESTIMATE_ID
            Set piWidth to 84
            Set psCaption to "Estimate"
        End_Object // oEshead_ESTIMATE_ID

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 262
            Set psCaption to "Customer"
        End_Object // oCustomer_Name

        Object oLocation_Name is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 262
            Set psCaption to "Location"
        End_Object // oLocation_Name

        Object oSalesRep_LastName is a cDbCJGridColumn
            Entry_Item SalesRep.LastName
            Set piWidth to 262
            Set psCaption to "Sales Rep"
        End_Object // oSalesRep_LastName

        Object oEshead_TITLE is a cDbCJGridColumn
            Entry_Item Eshead.TITLE
            Set piWidth to 262
            Set psCaption to "Title"
        End_Object // oEshead_TITLE

        Object oEshead_Q1_X_$ is a cDbCJGridColumn
            Entry_Item Eshead.Q1_X_$
            Set piWidth to 115
            Set psCaption to "Total"
        End_Object // oEshead_Q1_X_$


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 447
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 501
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 555
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // oEstimate
