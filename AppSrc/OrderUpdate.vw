Use Windows.pkg
Use DFClient.pkg
Use dfTable.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use Order.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use cCJGrid.pkg
Use cCJGridColumn.pkg
Use cDbCJGrid.pkg
Use szcalendar.pkg



Deferred_View Activate_oOrderUpdate for ;
Object oOrderUpdate is a dbView
    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oProject_DD is a cProjectDataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
    Procedure OnConstrain
        Constrain Order.JobCloseDate EQ 0
    End_Procedure
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Set Main_DD to oOrder_DD
    Set Server to oOrder_DD
    Set Border_Style to Border_Thick
    Set Label to "Order Update"
    Set Size to 175 512
    Set Location to 53 34
Procedure Constrain
    Constrain Order.JobCloseDate eq ""
End_Procedure

    Object oDbCJGrid1 is a cDbCJGrid
        Set Size to 116 484
        Set Location to 21 19

        Object oOrder_JobNumber is a cDbCJGridColumn
            Entry_Item Order.JobNumber
            Set piWidth to 93
            Set psCaption to "Job Number"
        End_Object

        Object oLocation_Name is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 307
            Set psCaption to "Location"
        End_Object

        Object oOrder_JobOpenDate is a cDbCJGridColumn
            Entry_Item Order.JobOpenDate
            Set piWidth to 112
            Set psCaption to "Open Date"
            Set peTextAlignment to xtpAlignmentRight
        End_Object

        
        Object oOrder_BillingType is a cDbCJGridColumn
            Entry_Item Order.BillingType
            Set piWidth to 108
            Set psCaption to "Billing Type"
            Set pbComboButton to True
            Set peTextAlignment to xtpAlignmentCenter
        End_Object

        Object oOrder_EventOpenDate is a cDbCJGridColumn
            Entry_Item Order.EventOpenDate
            Set piWidth to 106
            Set psCaption to "Est.Billing Date"
            Set peTextAlignment to xtpAlignmentRight
        End_Object
    End_Object

Cd_End_Object
