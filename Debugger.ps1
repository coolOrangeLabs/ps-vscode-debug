##############################################################################################
#                            Debugging support for embedded powershell
#
#           1: Make this file accessible to the powershell handlers you want to debug
#           2: Edit $LaunchJsonPath to point to the launch.json you're using
#           3: Right at the beginning of your powershell handler execute the PrepareDebugger function
#               This will create the correct launch.json for VSCode
#           4: Insert a bp statemnt at the location where the debugger should attach to your code
#           5: start VSCode
#           6: Execute your powershell code
#           7: Once the PrepareDebugger is executed you will get a notification in the Windows notification area
#               that you can now attach your debugger
#           8: Switch to VSCode, show the debug window and click on the green 'Debug' arrow. The VSCode debugger should now attach.
#





#the path to the launch.json file that should be updated
$LaunchJsonPath = 'C:\ProgramData\Autodesk\Vault 2018\Extensions\DataStandard\Vault\addinVault\Menus\.vscode\launch.json'

#define the alias that can be used as a 'breakpoint' 
Set-Alias bp Wait-Debugger

#internal function used to generate a balloon notification
function ShowConnectDebuggerNotification
{
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon 
    $objNotifyIcon.Icon = [System.Drawing.SystemIcons]::Information 
    $objNotifyIcon.BalloonTipIcon = "Info" 
    $objNotifyIcon.BalloonTipText = "You can now start your debugger." 
    $objNotifyIcon.BalloonTipTitle = "Attach Debugger"
    $objNotifyIcon.Visible = $True 
    $objNotifyIcon.ShowBalloonTip(1000)
}

#internal function used to generate a launch.json file that vscode can use to attach
#its debugger to the currently executing runspace
function CreateLaunchJson
{
	param ( [int] $runspaceId, [string] $outputFilename)

$contents = 
@"
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "PowerShell",
            "request": "attach",
            "name": "PowerShell Attach to Host Process",
            "processId": "$pid",
            "runspaceId": $runspaceId
        }
    ]
}
"@
	Set-Content $outputFilename $contents 
}

#public function used to attach the debugger to the currently executing runspace.
#You must insert at least one bp statement for the debugger to attach
function PrepareDebugger
{
    $id = [PowerShell]::Create("CurrentRunspace").Runspace.Id
	CreateLaunchJson $id $LaunchJsonPath
	ShowConnectDebuggerNotification
}

