Use Windows.pkg
Use DFClient.pkg
Use dfTreeVw.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use Order.DD

Enumeration_List
    Define tiOpenOrder
    Define tiOpenOrderDetail
    Define tiLib
    Define tiExamples
    Define tiWines
    //Define tiContact
End_Enumeration_List


Deferred_View Activate_oOdersManagement for ;
Object oOdersManagement is a dbView
    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oLocation_DD
        
        Procedure OnConstrain
            //Constrain Order.JobNumber gt "2900"
        End_Procedure
        
    End_Object

    Set Main_DD to oOrder_DD
    Set Server to oOrder_DD

    Set Border_Style to Border_Thick
    Set Size to 318 681
    Set Location to 2 2

    Object oTreeView1 is a TreeView
        Set Size to 125 640
        Set Location to 23 10
    
        Procedure OnCreateTree
            Handle hItemRoot hItemChild hItemExamples
            String sOrderText
            Integer iQuoteRef
            
            Open Order
            Constraint_Set 1
            Constrain Order.JobOpenDate gt 0
            Constrain Order.JobCloseDate eq 0
            Constrain Order.PromiseDate eq 0
            Constrained_Find First Order by 1

            While (Found)
                Relate Order
                Move (String(Order.JobNumber) *"-"* Order.Title *"-"* Customer.Name *"-"* Location.Name) to sOrderText
                Move Order.QuoteReference to iQuoteRef
                
                Get AddTreeItem     sOrderText      0               tiOpenOrder             0 1 to hItemRoot
                If (iQuoteRef<>0) Begin
                    Clear Quotedtl
                    Move iQuoteRef to Quotedtl.QuotehdrID
                    Find GE Quotedtl by Index.2
                    If (Found) Begin
                        Get AddTreeItem  ("Detail: " + Quotedtl.Description)  hItemRoot       tiOpenOrderDetail       2 1 to hItemChild
                    End
                    Find GT Quotedtl.QuotehdrID
                End
                
                
                Constrained_Find Next
            Loop
            
            
 
 
            
        End_Procedure

        
    End_Object

Cd_End_Object
