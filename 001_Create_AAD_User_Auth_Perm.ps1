
###############################################################################
###############################################################################
#                                   VARIABLES                
###############################################################################
###############################################################################

###################################################################
#                   VARIABLES TO DEFINE
###################################################################
$DebugMode = $false

IF($DebugMode)
{
    # Credential Testing
    $SQLDBName = "db_tjicdev"
    # $SQLServer
    $uid = "robot_add_log"
    # $password 
}
else
{
    # Credential Production
    $SQLDBName = "db_tjicbrain"
    # $SQLServer
    $uid = "robot_add_log"
    # $password
}

#------------------------------------------------------------
# THE PARAMETERS TO CREATE THE ACCOUNT
$GivenName            = $args[0]         # Le Prénom            exemple: marc
$Surname              = $args[1]         # Le Nom de Famille    exemple: BLANC
$PasswordNewUserAD    = $args[2]         # Le Mot De Passe:     exemple: MonMotDePasseS3curis32022
$Alias1               = $args[3]         # alias 1 email        exemple: m.blanc
$Alias2               = $args[4]         # alias 2 email        exemple: marcblanc
$DomainName           = $args[5]         # domaine              exemple: 1plus2.ch


#------------------------------------------------------------
# DATA TO FILL THE TABLE USER_IT OF THE DATABASE
$ValSortIT              = $args[6]       # chiffre entre 1 et 99 exemple: 54
$ValPhoneNumberIT       = $args[7]       # Format : 41DDDDDDD   exemple: 022 123 45 56 => 22123456 
$ValPhoneNumberM365IT   = $args[8]       # Format : 41DDDDDDD   exemple: 022 123 45 56 => 22123456 


#------------------------------------------------------------
# REFERENCE 
$RefLicense             = $args[9]


#------------------------------------------------------------
# ASSIGN 
# $ComputerNumber         = ""
# $UserNumber             = ""


#------------------------------------------------------------
# THE GROUPS
$Group1ToAdd          = $args[12]       # L'utilisateur vas être affilié à ce groupe default
$Group2ToAdd          = $args[13]
$Group3ToAdd          = $args[14]
$Group4ToAdd          = $args[15]



#------------------------------------------------------------
# DATA TO FILL THE TABLE EMPLOYE OF THE DATABASE
$ValAccessLevel         = 3


###################################################################
#                    FIXED VARIABLES
###################################################################

#------------------------------------------------------------
# THE PARAMETERS TO CREATE THE ACCOUNT
$TimeSleep              = 20

#------------------------------------------------------------
# THE PARAMETERS TO CREATE THE ACCOUNT
$DisplayName          ="$GivenName $Surname"  # correspond au champs Nom lorsque on crée un user
$MailNickName         = "Newuser"
$Countrylocation      ="CH"                   # La localisation - normes (ISO standard 3166)
$AccountEnabled       = $true
$UserPrincipalName    = "$GivenName.$Surname@$DomainName".ToLower()   # correspond au nom d'utilisateur principal
$ALias                = "$Alias1", "$Alias2"


#------------------------------------------------------------
# INFORMATION TO LOG IN THE DATABASE
$SQLServer= $args[16]
$uid = "robot_add_log"
$password = $args[17]


#------------------------------------------------------------
# INFOMARTION ABOUT THE TABLE EMPLOYE 
$TableEmploye = "tblEmployee"
$ColUsername = "[UserName]"
$ColEmployeName = "[EmployeeName]"
$ColAccessLevel = "[AccessLevel]"
$ColCeatedBy = "[CeatedBy]"
$ColCreatedOn = "[CreatedOn]"
$ColEmail = "[Email]"

# VALUES TO INSERT IN THE TABLE EMPLOYE
$ValUsername         = "$GivenName$Surname".ToLower()
$ValEmployeName      = $DisplayName
$ValCeatedBy         = $uid
$ValEmail            = $UserPrincipalName

#------------------------------------------------------------
# INFOMARTION ABOUT THE TABLE IT_USER
$TableUserIT           = "tbl_ITUser"

$ColEmailIT            ="[Email]"
$ColUsernameIT         ="[Username]"
$ColFonctionIT         ="[Fonction]"
$ColSortIT             ="[Sort]"
$ColCreatedOnIT        ="[CreatedOn]"
$ColCreatedByIT        ="[CreatedBy]"
$ColAccountTypeIT      ="[AccountType]"
$ColUserLevelIT        ="[UserLevel]"
$ColFirstNameIT        ="[FirstName]"
$ColLastNameIT         ="[LastName]"
$ColPhoneNumberIT      ="[PhoneNumber]"
$ColPhoneNumberM365IT  ="[PhoneNumberM365]"

# VALUES TO INSERT IN THE TABLE EMPLOYE
$ValEmailIT            = $UserPrincipalName
$ValUserNameIT         = $ValUsername
$ValCreatedByIT        = $uid
$ValFirstNameIT        = $GivenName
$ValLastNameIT         = $Surname
$ValAccountTypeIT       = "Utilisateurs"
$ValUserLevelIT         = "User"

#------------------------------------------------------------
# GET USERNAME
#Obtenir le nom d'utilisateur
$UsernameWindows = $env:UserName

#------------------------------------------------------------
# INFOMARTION ABOUT THE TABLE ScriptLog
$TableScriptLog             = "tbl_ScriptLog"

$ColSourceLog               = "[Source]"
$ColScriptNameLog           = "[ScriptName]"
$ColActionPerfShortLog      = "[ActionPerformedShort]"
$ColActionPerfLongLog       = "[ActionPerformedLong]" 
$ColStatutLog               = "[Statut]"
$ColCreatedByLog            = "[CreatedBy]"
$ColCreatedOnLog            = "[CreatedOn]"
$ColTimeStampLog            = "[ExecutionTimeStamp]"

$ValSourceLog               = "NewUserInAzure"
$ValScriptNameLog           = "ScriptNewUserAzure.ps1"
$ValActionPerfLongLog       = ""
$ValCreatedByLog            = $uid
$ValCreatedOnLog            = get-date -Format "yyyy-MM-dd HH:mm:ss"

$ListColsLog                = "$ColSourceLog, $ColScriptNameLog, $ColActionPerfShortLog, $ColActionPerfLongLog, $ColStatutLog, $ColCreatedByLog, $ColCreatedOnLog, $ColTimeStampLog"




###############################################################################
###############################################################################
#                                FUNCTIONS                
###############################################################################
###############################################################################

#### ---------------------------------------------------------
####                    FUNCTION N°1
#### ---------------------------------------------------------

function Add-SqlLog {

    # THE PARAMETERS THAT WE DEFINE AS MANDATORY
    param(
    [parameter(Mandatory=$true)]
    [string]$TableDatabase,
    [string]$Connection,
    [string]$ListColumns,
    [string]$ListValues
    )   

    # THE QUERY TO INSERT THE DATA IN THE DATABASE
    $QueryLog = "INSERT INTO $TableDatabase ($ListColumns) VALUES  ($ListValues)"

    # WE INSERT THE DATA
    Invoke-Sqlcmd -Query $QueryLog -ConnectionString $Connection 
}

#### ---------------------------------------------------------
####                    FUNCTION N°2
#### ---------------------------------------------------------

function Load-Module ($m) {

    # If module is imported say that and do nothing
    if (Get-Module | Where-Object {$_.Name -eq $m}) {
        write-host "Module $m is already imported."
    }
    else {

        # If module is not imported, but available on disk then import
        if (Get-Module -ListAvailable | Where-Object {$_.Name -eq $m}) {
            Import-Module $m -Verbose
        }
        else {

            # If module is not imported, not available on disk, but is in online gallery then install and import
            if (Find-Module -Name $m | Where-Object {$_.Name -eq $m}) {
                Install-Module -Name $m -Force -Verbose -Scope CurrentUser
                Import-Module $m -Verbose
            }
            else {

                # If the module is not imported, not available and not in the online gallery then abort
                write-host "Module $m not imported, not available and not in an online gallery, exiting."
                EXIT 1
            }
        }
    }
}

#### ---------------------------------------------------------
####                    FUNCTION N°3
#### ---------------------------------------------------------


function Check-User{
    # THE PARAMETERS THAT WE DEFINE AS MANDATORY
    param(
    [parameter(Mandatory=$true)]
    [string]$UserToIdentify)


    if(Get-AzureADUser -SearchString $UserToIdentify) {
        return $true
    }
    else{
        return $false
    }
}

#### ---------------------------------------------------------
####                    FUNCTION N°4
#### ---------------------------------------------------------

function Check-License{
    # THE PARAMETERS THAT WE DEFINE AS MANDATORY
    param(
    [parameter(Mandatory=$true)]
    [string]$UserRef,
    [string]$NewUser
    )

    $LicensesRefUser = Get-MgUserLicenseDetail -UserId $UserRef 
    $LicensesNewUser = Get-MgUserLicenseDetail -UserId $NewUser

    
    if($LicensesRefUser.Length -eq $LicensesNewUser.Length){
    }
    else{
        return $false, "STEP 2 : The user ($NewUser) has not the same number of licences as the reference. We stop here"
    }

    for ($i=0; $i -lt $LicensesRefUser.SkuPartNumber.length; $i++){
        $LicenseToCheck = $LicensesNewUser.SkuPartNumber[$i]
        if($LicensesRefUser.SkuPartNumber.Contains($LicenseToCheck)){
        }
        else{
            return $false, "STEP 2 : The license $LicenseToCheck is not in the list. We stop here"
        }
        return $true, "STEP 2 : The user ($NewUser) has all the licenses"
    }
}

#### ---------------------------------------------------------
####                    FUNCTION N°5
#### ---------------------------------------------------------

function Check-Alias
{
    param(
        [parameter(Mandatory=$true)]
        [array]$AliasToCheck,
        [string]$NewUser
        )

    $MailBoxInfoUser = Get-Mailbox -Identity $UserPrincipalName 
    $EmailListNewUser = $MailBoxInfoUser.EmailAddresses

    for ($j=0; $j -lt @($AliasToCheck).Length; $j++)
    {
        if($EmailListNewUser -match @($AliasToCheck)[$j]){
        }
        else {
            return $false
        }
    }
    return $true
}

#### ---------------------------------------------------------
####                    FUNCTION N°6
#### ---------------------------------------------------------
function Get-GroupToAdd
{
    param(
        [parameter(Mandatory=$true)]
        [array]$ArrayGroups
        )

    $GroupName = Get-Variable -Name $ArrayGroups[$k] -ValueOnly
    IF($GroupName.length -ne 0)
    {
        return $true, $GroupName
    }
    else 
    {
        return $false, $GroupName
    }
}

#### ---------------------------------------------------------
####                    FUNCTION N°7
#### ---------------------------------------------------------
function Start-Sleep($seconds) {
    $doneDT = (Get-Date).AddSeconds($seconds)
    while($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining 0 -Completed
}


#### ---------------------------------------------------------
####                    FUNCTION N°8
#### ---------------------------------------------------------

function Create-AliasArray
{
    param(
        [parameter(Mandatory=$true)]
        [array]$ArrayAlias,
        [string]$Domaine
        )

    $Target = @()

    foreach ($element in $ArrayAlias)
    {
        if($element -ne "")
        {
            $AliasDomaine = "$element@$Domaine"
            $Target += $AliasDomaine
        }
    }
    
    return $Target  
}

###############################################################################
###############################################################################
#                    PART 0 : STARTUP           
###############################################################################
###############################################################################

# -----------------------------------------------------------
# THE MODULES TO INSTALL
# -----------------------------------------------------------
# Install-Module AzureAD
# Install-Module Microsoft.Graph.Users
# Install-Module Microsoft.Graph.Users.Actions
# Install-Module ExchangeOnlineManagement
# Install-Module MicrosoftTeams

$ModuleAzureAD = "AzureAD"
$ModuleGraphUsers = "Microsoft.Graph.Users"
$ModuleGraphUsersActions = "Microsoft.Graph.Users.Actions"
$ModulesExchangeOnlineManagement = "ExchangeOnlineManagement"
$ModuleMicrosoftTeams = "MicrosoftTeams"

$ListModules = @($ModuleAzureAD, $ModuleGraphUsers, $ModuleGraphUsersActions, $ModulesExchangeOnlineManagement, $ModuleMicrosoftTeams)

for ($i=0; $i -lt $ListModules.length; $i++){
    Load-Module $ListModules[$i]   
}

# -----------------------------------------------------------
# CREATION OF THE STRING CONNECTION TO THE SQL DATABASE
# -----------------------------------------------------------

# WE DEFINE THE CONNECTION STRING
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$ConnectionString = "Server = $SQLServer; Database = $SQLDBName; User ID = $uid; Password = $password;"
$SqlConnection.ConnectionString = $ConnectionString


###############################################################################
###############################################################################
#                    PART 1 : Création des accès et permissions                
###############################################################################
###############################################################################


#==================================================================
#==================================================================
#                       STEP 1 - DONE
#==================================================================
#==================================================================
# Créer un utilisateur dans l'active directory prenom.nom@domain.ch - 
# ne pas inclure les accents, MDP XXXXXXXXXXXX. Attribuer un numéro 
# d'utilisateur et un numéro de PC.


# STEPS TO CONNECT
Connect-AzureAD

# We CHECK THAT THE USER DOES NOT EXIST
$StatutUser = Check-User -UserToIdentify $UserPrincipalName

IF(-not $StatutUser) {
   
    # THE USER DOES NOT EXIST
    #------------------------------------

    # THE LOG IN THE DATABASE 
    $ValActionPerfShortLog  = "STEP 1a : The user $UserPrincipalName does not exist"
    $ValActionPerfLongLog   = ""
    $ValStatutLog           = "Successful"
    $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

    $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

    Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog

    # WE CREATE THE USER
    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = $PasswordNewUserAD
    $PasswordProfile.ForceChangePasswordNextLogin = 0

    $params = @{
        AccountEnabled      = $AccountEnabled
        DisplayName         = $DisplayName
        PasswordProfile     = $PasswordProfile
        UserPrincipalName   = $UserPrincipalName 
        MailNickName        = $MailNickName
        UsageLocation       = $Countrylocation
        GivenName           = $GivenName
        Surname             = $Surname
    }

    try 
    {
        New-AzureADUser @params -ErrorAction Stop 
    }
    catch 
    {
        # THE LOG IN THE DATABASE 
        $ValActionPerfShortLog  = "STEP 1b : Fail to create the $UserPrincipalName. We stop here"
        $ValActionPerfLongLog   = $_.Exception.Message -replace '[^a-zA-Z0-9 .-]', ''
        $ValStatutLog           = "Failed"
        $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

        $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

        Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog

        EXIT
    }
      
}
ELSE
{   
    # THE USER EXISTS
    #------------------------------------
    
    # THE LOG IN THE DATABASE 
    $ValActionPerfShortLog  = "STEP 1a : The user $UserPrincipalName already exists. We stop Here"
    $ValActionPerfLongLog   = ""
    $ValStatutLog           = "Failed"
    $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

    $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

    Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog

    EXIT
}

# WE PUT A SLEEP
Start-Sleep $TimeSleep

# WE CHECK THAT THE USER EXISTS 
$StatutUserCreated = Check-User -UserToIdentify $UserPrincipalName

IF($StatutUserCreated){

    # WE HAVE CREATED THE USER WITH SUCCESS
    #------------------------------------

    # THE LOG IN THE DATABASE 
    $ValActionPerfShortLog  = "STEP 1b : The user $UserPrincipalName has been created"
    $ValActionPerfLongLog   = ""
    $ValStatutLog           = "Successful"
    $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

    $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

    Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog
}
else 
{

    # WE FAILED TO CREATE THE USER
    #------------------------------------

    # THE LOG IN THE DATABASE 
    $ValActionPerfShortLog  = "STEP 1b : Fail to create the $UserPrincipalName. We stop here"
    $ValActionPerfLongLog   = "The function has been well executed but the user does not appear in the listing"
    $ValStatutLog           = "Failed"
    $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

    $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

    Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog

    EXIT 
}


#==================================================================
#==================================================================
#               STEP 2 - LICENSES
#==================================================================
#==================================================================
# Assigner les licences: Microsoft 365 E3 (obligatoire), Audio Conférence 
# (obligatoire), Microsoft Téléphone (obligatoire), Credit de 
# Communication, PowerAutomate Free

# WE CONNECT TO GRAPH
Connect-Graph -Scopes User.ReadWrite.All, Organization.Read.All

try{

    # WE ATTRIBUATE THE LICENCES
    $mgUser = Get-MgUser -UserId $RefLicense -Select id, displayName, assignedLicenses -ErrorAction Stop
    Set-MgUserLicense -UserId $UserPrincipalName -AddLicenses $mgUser.AssignedLicenses -RemoveLicenses @() -ErrorAction Stop
}
catch
{

    # AN ERROR HAS HAPPENED ! WE ADD IT IN THE LOG TABLE
    #----------------------------
    # THE LOG IN THE DATABASE 
    $ValActionPerfShortLog  = "STEP 2a: Fail to add the licences to the user $UserPrincipalName"
    $ValActionPerfLongLog   = $_.Exception.Message -replace '[^a-zA-Z0-9 .-]', ''
    $ValStatutLog           = "Failed"
    $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

    $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

    Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog

    EXIT
}

# WE PUT A SLEEP
Start-Sleep $TimeSleep

# WE CHECK THAT THE LICENSES ARE WELL ADDED
$StatutLicenses, $MessageLicenses = Check-License -UserRef $RefLicense -NewUser $UserPrincipalName

# WE ADD A LOG TO THE LOG TABLE
IF($StatutLicenses){

    $ValActionPerfShortLog  = $MessageLicenses
    $ValActionPerfLongLog   = ""
    $ValStatutLog           = "Successful"
    $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

    $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

    Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog
}
else 
{
    $ValActionPerfShortLog  = $MessageLicenses
    $ValActionPerfLongLog   = ""
    $ValStatutLog           = "Failed"
    $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

    $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

    Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog

    EXIT
}


# #==================================================================
# #==================================================================
# # STEP 4 
# #==================================================================
# #==================================================================
# # Créer un alias pour les emails prenomnom@domain.ch p.nom@domain.ch - ne pas inclure les accents


$ArrayDef = Create-AliasArray -ArrayAlias $ALias -Domaine $DomainName

IF(@($ArrayDef.Length) -gt 0)
{
    # WE CONNECT TO EXCHANGE ONLINE
    Connect-ExchangeOnline

    # WE SET A BREAK TIME 
    $TimeSleepAlias = [int](4*$TimeSleep)
    Start-Sleep $TimeSleepAlias

    # WE TRY TO ADD THE ALIAS TO THE ACCOUNT
    try
    {
        # WE ADD THE ALIAS TO THE MAILBOX
        Set-Mailbox -Identity $UserPrincipalName -EmailAddresses @{add=$ALias} -ErrorAction Stop

        # ADD THE LOG FOR THE TENTATIVE
        $ValActionPerfShortLog  = "STEP 3a : Tentative to add alias to the user $UserPrincipalName"
        $ValActionPerfLongLog   =  ""
        $ValStatutLog           = "Successful"
        $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

        $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

        Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog
    }
    catch
    {
        # ADD THE LOG FOR THE FAIL
        $ValActionPerfShortLog  = "STEP 3a : Fail to add alias to the user $UserPrincipalName. We go on to the next step"
        $ValActionPerfLongLog   =  $_.Exception.Message -replace '[^a-zA-Z0-9 .-]', ''
        $ValStatutLog           = "Failed"
        $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

        $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

        Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog
    }

    # WE SET A BREAK TIME
    Start-Sleep $TimeSleep

    # WE CHECK THAT THE ALIAS ARE CREATED
    $StatutAlias = Check-Alias -AliasToCheck $ALias -NewUser $UserPrincipalName

    # ----------------------------------------------------------
    # WE ADD A LOG TO THE LOG TABLE
    IF($StatutAlias)
    {
        # ALL WENT WELL ! THE ALIAS ARE ADDED
        $ValActionPerfShortLog  = "STEP 3b : The user $UserPrincipalName has the right alias"
        $ValActionPerfLongLog   = ""
        $ValStatutLog           = "Successful"
        $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

        $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

        Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog
    }
    ELSE 
    {
        # IT FAILED
        $ValActionPerfShortLog  = "STEP 3b : Fail to add the alias to the user $UserPrincipalName"
        $ValActionPerfLongLog   = ""
        $ValStatutLog           = "Failed"
        $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

        $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

        Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog
    }
}
ELSE
{
    # ----------------------------------------------------------
    IF($StatutAlias)
    {
        $ValActionPerfShortLog  = "STEP 3 : No alias was set to add to the user $UserPrincipalName"
        $ValActionPerfLongLog   = ""
        $ValStatutLog           = "Successful"
        $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

        $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

        Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog
    }
}


#==================================================================
#==================================================================
# STEP 5 - DONE
#==================================================================
#==================================================================
# Ajouter au groupe (ajouter comme membre)

# NEW USER OBJECT AND OBJECT_ID
$UserContent = Get-AzureADUser -ObjectID $UserPrincipalName | Select ObjectId
$UserID = $UserContent.ObjectId

# ARRAY LIST OF THE GROUPS
[System.Collections.ArrayList]$ArrayGroupsAAD = @'
Group1ToAdd
Group2ToAdd
Group3ToAdd
Group4ToAdd
'@ -split '\r?\n'

# WE DO A LOOP OVER THE ELEMENTS OF THE ARRAY LIST
for ($k=0; $k -lt $ArrayGroupsAAD.Count; $k++) 
{
    # WE LOOK IF THE VARIABLE CONTENTS A STRING 
    $StatutGroup, $GroupName = Get-GroupToAdd -ArrayGroups $ArrayGroupsAAD

    IF($StatutGroup)
    {
        try
        {
            # WE GET THE ID OF THE GROUP
            $GroupObject = Get-AzureADGroup | Where-Object {$_.DisplayName  -Match $GroupName}
            $GroupID =  $GroupObject.ObjectId
            
            # WE ADD THE USER TO THE GROUP
            Add-AzureADGroupMember -ObjectId $GroupID -RefObjectId $UserID -ErrorAction Stop

            # ----------------------------------------------------------
            # WE ADD A LOG THAT WE HAVE ADDED THE USER TO A GROUP
            $ValActionPerfShortLog  = "STEP 4 : The user $UserPrincipalName has been added to the group : $GroupName"
            $ValActionPerfLongLog   =  ""
            $ValStatutLog           = "Successful"
            $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

            $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

            Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog
        }
        catch
        {
            # ----------------------------------------------------------
            # WE ADD A LOG THAT WE HAVE FAILED TO ADD THE NEW USER TO A GROUP
            $ValActionPerfShortLog  = "STEP 4: Fail to add the user $UserPrincipalName to the group : $GroupName"
            $ValActionPerfLongLog   =  $_.Exception.Message -replace '[^a-zA-Z0-9 .-]', ''
            $ValStatutLog           = "Failed"
            $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

            $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

            Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog
        }
    }
}


# #==================================================================
# #==================================================================
# # STEP 6 - DONE
# #==================================================================
# #==================================================================
# #Attribuer un numéro de téléphone (powershell) à l'utilisateur sur microsoft teams#

if($ValPhoneNumberM365IT -ne "")
{
    # IMPORT THE MODULE
    Import-Module MicrosoftTeams

    # WE CONNECT TO MICROSOFT TEAMS
    Connect-MicrosoftTeams

    # WE SET THE PHONE NUMBER
    try
    {
        Set-CsUser -identity $UserPrincipalName -EnterpriseVoiceEnabled $true -HostedVoicemail $true -OnPremlineURI "tel:+$ValPhoneNumberM365IT" -ErrorAction Stop
        Grant-CsOnlineVoiceRoutingPolicy -Identity $UserPrincipalName -PolicyName "Peoplefone" -ErrorAction Stop

        # ----------------------------------------------------------
        # WE ADD THE A LOG THAT WE HAVE ADDED A PHONE NUMBER
        $ValActionPerfShortLog  = "STEP 5 : Phone number assigned to the user $UserPrincipalName"
        $ValActionPerfLongLog   =  ""
        $ValStatutLog           = "Successful"
        $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

        $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

        Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog
    }
    catch
    {
        # ----------------------------------------------------------
        # WE ADD THE A LOG THAT WE HAVE ADDED A PHONE NUMBER
        $ValActionPerfShortLog  = "STEP 5 : Fail to add a phone number to the user $UserPrincipalName"
        $ValActionPerfLongLog   =  $_.Exception.Message -replace '[^a-zA-Z0-9 .-]', ''
        $ValStatutLog           = "Failed"
        $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

        $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

        Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog
    }

}
else 
{
    {
        # ----------------------------------------------------------
        # WE ADD THE A LOG THAT WE HAVE ADDED A PHONE NUMBER
        $ValActionPerfShortLog  = "STEP 5 : None phone number assigned to the user $UserPrincipalName"
        $ValActionPerfLongLog   =  ""
        $ValStatutLog           = "Successful"
        $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

        $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

        Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog
    }
}
# #==================================================================
# #==================================================================
# # STEP 7 
# #==================================================================
# #==================================================================
# Création du nom d'utilisateur dans tblEmployee prenomNOM

# THE TIMESTAMP
$ValCreatedOn          = get-date -Format "yyyy-MM-dd HH:mm:ss"

# WE DEFINE THE LISTS
$ListColsTableEmploye  = "$ColUsername, $ColEmployeName, $ColAccessLevel, $ColCeatedBy, $ColCreatedOn, $ColEmail"
$ListValuesEmploye     = "'$ValUsername', '$ValEmployeName', '$ValAccessLevel', '$ValCeatedBy', '$ValCreatedOn', '$ValEmail'"

try
{
    # WE ADD THE USER IN THE TABLE EMPLOYEE
    Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsTableEmploye -ListValues $ListValuesEmploye -TableDatabase $TableEmploye -ErrorAction Stop

    # ----------------------------------------------------------
    # WE ADD THE A LOG THAT WE HAVE ADDED IT 
    $ValActionPerfShortLog  = "STEP 6 : The new user $UserPrincipalName has been added in the table $TableEmploye"
    $ValActionPerfLongLog   =  ""
    $ValStatutLog           = "Successful"
    $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

    $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

    Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog
}
catch
{
    # ----------------------------------------------------------
    # WE ADD THE A LOG THAT WE HAVE FAILED TO ADD THE NEW USER 
    $ValActionPerfShortLog  = "STEP 6 : Fail to add the new user $UserPrincipalName in the table $TableEmploye"
    $ValActionPerfLongLog   =  $_.Exception.Message -replace '[^a-zA-Z0-9 .]', ''
    $ValStatutLog           = "Failed"
    $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

    $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

    Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog
}

# #==================================================================
# #==================================================================
# # STEP 8 
# #==================================================================
# #==================================================================

# # THE TIMESTAMP
$ValCreatedOnIT        = get-date -Format "yyyy-MM-dd HH:mm:ss"

# WE DEFINE THE LISTS
$ListColsTableUserIT   = "$ColEmailIT, $ColUsernameIT, $ColSortIT, $ColCreatedOnIT, $ColCreatedByIT, $ColAccountTypeIT, $ColUserLevelIT, $ColFirstNameIT, $ColLastNameIT, $ColPhoneNumberIT, $ColPhoneNumberM365IT"
$ListValuesTableUserIT = "'$ValEmailIT', '$ValUserNameIT', '$ValSortIT' ,'$ValCreatedOnIT', '$ValCreatedByIT', '$ValAccountTypeIT', '$ValUserLevelIT', '$ValFirstNameIT', '$ValLastNameIT', '$ValPhoneNumberIT', '$ValPhoneNumberM365IT'"

TRY
{
    # WE ADD THE USER IN THE TABLE USER IT
    Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsTableUserIT -ListValues $ListValuesTableUserIT -TableDatabase $TableUserIT -ErrorAction Stop

    # ----------------------------------------------------------
    # WE ADD THE A LOG THAT WE HAVE ADDED IT 
    $ValActionPerfShortLog  = "STEP 7 : The new user $UserPrincipalName has been added in the table $TableUserIT"
    $ValActionPerfLongLog   =  ""
    $ValStatutLog           = "Successful"
    $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

    $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

    Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog
}
catch
{
    # ----------------------------------------------------------
    # WE ADD THE A LOG THAT WE HAVE FAILED TO ADD THE NEW USER 
    $ValActionPerfShortLog  = "STEP 7 : Fail to add the new user $UserPrincipalName in the table $TableUserIT"
    $ValActionPerfLongLog   =  $_.Exception.Message -replace '[^a-zA-Z0-9 .]', ''
    $ValStatutLog           = "Failed"
    $ValTimeStampLog        = get-date -Format "yyyy-MM-dd HH:mm:ss"

    $ListValsLog            = "'$ValSourceLog', '$ValScriptNameLog', '$ValActionPerfShortLog' ,'$ValActionPerfLongLog', '$ValStatutLog', '$ValCreatedByLog', '$ValCreatedOnLog', '$ValTimeStampLog'"

    Add-SqlLog -Connection $SqlConnection.ConnectionString -ListColumns $ListColsLog -ListValues $ListValsLog -TableDatabase $TableScriptLog
}