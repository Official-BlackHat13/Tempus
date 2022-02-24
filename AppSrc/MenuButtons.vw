Use Windows.pkg
Use DFClient.pkg

Deferred_View Activate_oMenuButtons for ;
Object oMenuButtons is a dbView

    Set Border_Style to Border_None
    Set Size to 321 126
    Set Location to 0 0
    Set Auto_Top_View_State to True
    Set peAnchors to anAll
    Set pbAutoActivate to True
    Set piMaxSize to 321 126
    Set piMinSize to 321 126

   

    Object oContainer3d1 is a Container3d
        Set Size to 303 110
        Set Location to 10 8
        
          Object oSearchEngineButton is a Button
            Set Size to 14 85
            Set Location to 9 11
            Set Label to "Search Engine"
        
            // fires when the button is clicked
            Procedure OnClick
               Handle hoClient
                Get Client_Id to hoClient
                Send Activate_oMegellan of hoClient
                            
            End_Procedure
        
        End_Object   
    
        Object oQuoteEntryButton is a Button
          Set Size to 14 85
          Set Location to 27 11
          Set Label to "Quote Entry"
      
          // fires when the button is clicked
          Procedure OnClick
             Handle hoClient
              Get Client_Id to hoClient
              Send Activate_oQuoteEntry of hoClient                
          End_Procedure
      
      End_Object   
    
          Object oTransactionEntryButton is a Button
            Set Size to 14 85
            Set Location to 45 10
            Set Label to "Transaction Edit"
        
            // fires when the button is clicked
            Procedure OnClick
               Handle hoClient
                Get Client_Id to hoClient
                Send Activate_oTransactions of hoClient
            End_Procedure
        End_Object   
    
        Object oEmployeeEntryButton is a Button
          Set Size to 14 85
          Set Location to 81 10
          Set Label to "Employees"
        
          // fires when the button is clicked
          Procedure OnClick
             Handle hoClient
              Get Client_Id to hoClient
              Send Activate_oEmployeeEntry of hoClient                  
          End_Procedure
        End_Object
            
        Object oOperations is a Button
            Set Size to 14 85
            Set Location to 63 10
            Set Label to "Operations"
            
            // fires when the button is clicked
            Procedure OnClick
                Handle hoClient
                Get Client_Id to hoClient
                Send Activate_oOrdersOpen of hoClient                  
            End_Procedure
            
        End_Object     
        
        Object oOrderEntry is a Button
            Set Size to 14 85
            Set Location to 99 10
            Set Label to "Order Entry"
            
            // fires when the button is clicked
            Procedure OnClick
                Handle hoClient
                Get Client_Id to hoClient
                Send Activate_oOrderEntry of hoClient                  
            End_Procedure
            
        End_Object 
        
        Object oJobCostEntryEdit is a Button
            Set Size to 14 85
            Set Location to 118 10
            Set Label to "Job Cost"
            
            // fires when the button is clicked
            Procedure OnClick
                Handle hoClient
                Get Client_Id to hoClient
                Send Activate_oJobCost of hoClient                  
            End_Procedure
            
        End_Object 

        Object oJobCostEntryEdit is a Button
            Set Size to 14 85
            Set Location to 135 10
            Set Label to "Estimating"
            
            // fires when the button is clicked
            Procedure OnClick
                Handle hoClient
                Get Client_Id to hoClient
                Runprogram background "TempusEstimating.exe"              
            End_Procedure
            
        End_Object 
    End_Object

Cd_End_Object
