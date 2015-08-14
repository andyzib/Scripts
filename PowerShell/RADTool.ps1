	

    <#
    ----------------------------------------
     
    RADToolkit                        
      Created By : Ryan Abbott            
      Date: 04-30-2014                    
      Purpose: Toolkit for working with AD
                                           
    ----------------------------------------
    #>
     
    #Set Script Params here:
    $waitDuration = 2
    $end=0
 
    #Create outerloop
    :OuterLoop do
    {
     
    #Begin Main Loop
    Do {
     
    clear
     
    #Write Menu
    Write-Output "
     
       --------------Main Menu------------------
         
            1 = Query Specific User
            2 = Query All Users
            3 = Unlock Account
            4 = Script Settings
            99 = Quit
     
          Created by: Ryan Abbott
     
       -----------------------------------------"
     
       $m1Choice = read-host -prompt "Select an Option and press Enter"
       } until($m1Choice -eq "1" -or $m1Choice -eq "2" -or $m1Choice -eq "3" -or $m1Choice -eq "4" -or $m1Choice -eq "99")
     
       Switch($m1Choice){
     
        "1" {
          	clear
         	 $userName = read-host -prompt "Enter Username to Query"
         	 $c = Get-ADUser -Identity $userName -Properties * | select Name,DisplayName,SamAccountName,Mail,Enabled,LastLogonDate,LastBadPasswordAttempt,DistinguishedName,SID,@{n='MemberOf';e={$_.MemberOf -join '; '}}
         	 echo $c
         	 $prompt = read-host -prompt "Do you wish to save to file? (Y/N)"
        	 if ($prompt -eq 'y')
                   {
            		$c | export-csv "$fPath\ADUser-Export_$userName.csv"
          		Write-Output "File saved as: $fPath\ADUser-Export_$userName.csv"
          		Start-Sleep -s $waitDuration
                   }
             
            }
     
        "2" {
              clear
              Write-Output "Exporting AD Users to CSV"
              Get-ADUser -Filter * -Properties * | select Name,DisplayName,SamAccountName,Mail,Enabled,LastLogonDate,LastBadPasswordAttempt,DistinguishedName,SID,@{n='MemberOf';e={$_.MemberOf -join '; '}} | export-csv "$fPath\FullAD-Export.csv"
              Write-Output "File saved as: $fPath\FullAD-Export.csv"
              Start-Sleep -s $waitDuration
     
            }
     
     
     
        "3" {
                $userName = read-host -prompt "Enter Username to Unlock"
                Unlock-ADAccount -Identity $userName
                Write-Output "User Account $userName has been unlocked!"
                Start-Sleep -s $waitDuration
            }
     
       
        "4" {
	  $setExit=0
           Do{
            Do{
             clear
             Write-Output "-------------- Settings ------------------
                     
            1 = Set Domain
            2 = Set Output File Path
            3 = Main Menu
                            "          
            Write-host "  Selected Domain:"$domain -fore "Yellow" -back "black"
            Write-host "  File Path:"$fPath -fore "Yellow" -back "black"
            Write-host "------------------------------------------"
     
             $m2Choice = read-host -prompt "Select a setup option and press Enter"
             } until($m2Choice -eq "1" -or $m2Choice -eq "2" -or $m2Choice -eq "3")
           
             Switch($m2Choice){
     
              "1" {
                      $domain = read-host -prompt "Enter Domain (ie. contoso.local) "
                  }
     
              "2" {
                      $fPath = read-host -prompt "Enter File Path Do not include trailing '\' (ie. C:\output) "
                  }
                         
              "3" {
                    $setExit=1
                  }        
           
           
              }
           } while($setExit -ne 1)
        }
           
     
               
        "99" {
                Write-Output "Exiting"
             
                #clear out the vars
                Remove-Variable fPath
                Remove-Variable userName
                Remove-Variable domain
                Remove-Variable end
                Remove-Variable setexit
                Remove-Variable c
                $end = 1
                break OuterLoop
            }
       }
     
    #End OuterLoop
    } while ($end -ne 1)


