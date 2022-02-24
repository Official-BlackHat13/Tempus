Use Windows.pkg
Use DFClient.pkg
Use cTempusDbView.pkg
Use cTextEdit.pkg
Use cszDropDownButton.pkg
Use TransactionProcess.bp

Use Employer.DD
Use Employee.DD
Use Empltime.DD


Deferred_View Activate_oShopKeyPad for ;
Object oShopKeyPad is a dbView

    Set Border_Style to Border_Thick
    Set Size to 382 606
    Set Location to 2 2

    Object oKeyPadGroup is a Container3d
        Set Size to 311 263
        Set Location to 28 329
        Set Color to 16744448
        
        Object oNameForm is a Form
        Set Size to 57 147
        Set Location to 18 11
        Set Color to clWhite
        Set TextColor to clBlack
        Set FontSize to 16 4
        Set FontWeight to 800
        Set Form_Justification_Mode to Form_DisplayCenter
        //OnChange is called on every changed character
    
        //Procedure OnChange
        //    String sValue
        //
        //    Get Value to sValue
        //End_Procedure
    
        End_Object
        
      

 Object oButton1 is a cszDropDownButton
            Set Size to 35 40 
            Set Location to 84 10
            Set Label to '1'
            Set Color to clWhite
                       Set FontWeight to 800
            Set FontSize to 16 1
            Set pbDropDownButton to False
           
            // fires when the button is clicked
            Procedure OnClick
                Send DoIncrementDisplay 1
                
            End_Procedure
        
        End_Object

        Object oButton2 is a cszDropDownButton
                   Set Size to 35 40 
                   Set Location to 84 71
                   Set Label to '2'
                   Set Color to clWhite
                                  Set FontWeight to 800
                   Set FontSize to 16 1
                   Set pbDropDownButton to False
                   
                   // fires when the button is clicked
                   Procedure OnClick
                        Send DoIncrementDisplay 2
                   End_Procedure
               
        End_Object
        
        Object oButton3 is a cszDropDownButton
                   Set Size to 35 40 
                   Set Location to 84 131
                   Set Label to '3'
                   Set Color to clWhite
                                 Set FontWeight to 800
                   Set FontSize to 16 1
                   Set pbDropDownButton to False
                   
                   // fires when the button is clicked
                   Procedure OnClick
                        Send DoIncrementDisplay 3
                   End_Procedure
               
        End_Object
        Object oButton4 is a cszDropDownButton
            Set Size to 35 40 
            Set Location to 134 11
            Set Label to '4'
            Set Color to clWhite
               Set FontWeight to 800
            Set FontSize to 16 1
            Set pbDropDownButton to False
           
            // fires when the button is clicked
            Procedure OnClick
                 Send DoIncrementDisplay 4
            End_Procedure
        
        End_Object

        Object oButton5 is a cszDropDownButton
                   Set Size to 35 40 
                   Set Location to 134 71
                   Set Label to '5'
                   Set Color to clWhite
   
                   Set FontWeight to 800
                   Set FontSize to 16 1
                   Set pbDropDownButton to False
                   
                   // fires when the button is clicked
                   Procedure OnClick
                        Send DoIncrementDisplay 5
                   End_Procedure
               
        End_Object
        
        Object oButton6 is a cszDropDownButton
                   Set Size to 35 40 
                   Set Location to 134 131
                   Set Label to '6'
                   Set Color to clWhite
                              Set FontWeight to 800
                   Set FontSize to 16 1
                   Set pbDropDownButton to False
                  
                   // fires when the button is clicked
                   Procedure OnClick
                      Send DoIncrementDisplay 6  
                   End_Procedure
               
        End_Object
        Object oButton7 is a cszDropDownButton
            Set Size to 35 40 
            Set Location to 184 11
            Set Label to '7'
            Set Color to clWhite
                    Set FontWeight to 800
            Set FontSize to 16 1
            Set pbDropDownButton to False
            
        
            // fires when the button is clicked
            Procedure OnClick
                 Send DoIncrementDisplay 7
            End_Procedure
        
        End_Object

        Object oButton8 is a cszDropDownButton
                   Set Size to 35 40 
                   Set Location to 184 72
                   Set Label to '8'
                   Set Color to clWhite
                                Set FontWeight to 800
                   Set FontSize to 16 1
                   Set pbDropDownButton to False
                   
               
                   // fires when the button is clicked
                   Procedure OnClick
                       Send DoIncrementDisplay 8
                   End_Procedure
               
        End_Object
        
        Object oButton9 is a cszDropDownButton
                   Set Size to 35 40 
                   Set Location to 184 131
                   Set Label to '9'
                   Set Color to clWhite
                          Set FontWeight to 800
                   Set FontSize to 16 1
                   Set pbDropDownButton to False
                   
                   // fires when the button is clicked
                   Procedure OnClick
                        Send DoIncrementDisplay 9
                   End_Procedure
               
        End_Object
         Object oButton0 is a cszDropDownButton
                   Set Size to 35 40 
                   Set Location to 233 73
                   Set Label to '0'
                   Set Color to clWhite
                           Set FontWeight to 800
                   Set FontSize to 16 1
                   Set pbDropDownButton to False
                   
                   // fires when the button is clicked
                   Procedure OnClick
                        Send DoIncrementDisplay 0
                   End_Procedure
               
         End_Object
          Object oExitButton is a Button
        Set Size to 10 10
        Set Location to 294 245
        Set FlatState to True
        Set peAnchors to anBottomLeft
              Set Status_Help to "EXIT"
    
        Procedure OnClick
            Send Exit_Application
        End_Procedure
    End_Object

 Procedure DoIncrementDisplay Integer iNumber
            Integer hoDD iEmployeeIdno iEmpltimeId
            String  sNumber
            Date    dToday
            //
          //  If (not(HasRecord(oEmployee_DD))) Begin
          //      Get Value of oNameForm           to sNumber
          //      Move (sNumber + String(iNumber)) to sNumber
          //      Set Value of oNameForm       to sNumber
           // End
        End_Procedure
    
    End_Object

Cd_End_Object
