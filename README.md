# ps-vscode-debug
Using VSCode to debug remote embedded PowerShell instances
which might be:

- powerJobs
- powerGate 
- VDS
- your own PowerShell hosting solution

## Prerequisites

1. a current version of VSCode installed and running
1. a current version of the PowerShell extension installed in VSCode
1. the sourcecode for your customization project (for VDS, powerGate, powerJobs, etc.) organized in a VSCode workspace, opened in VSCode
1. a VSCode launch configuration file for this workspace (i.e. a launch.json file), this file will be frequently overwritten, so make sure you do not have any precious contents in it 

### How it works

To debug powerShell code running in a separate application, the VSCode debugger (which runs in a different process) needs to connect to the executing PowerShell runspace. These steps must take place:

1. The embedded PowerShell in the hosting process must halt and wait for a connecting VSCode debugger
1. The VSCode debugger must be told to connect to the waiting hosted PowerShell runspace. To accomplish that, the debugger needs to know

  - the process id of the hosting process 
  - the runspace id of the executing PowerShell inside the hosting process
  
The connection information must be present in the launch.json file in the VSCode workspace. Unfortunately process id and runspace id change with every new invocation of the hosting process resp. the executing runspace.

To solve this problem the launch.json file gets replaced with a new generated one with every invocation of the hosting process/runspace. This is done from within the runspace in the hosting process.

The PowerShell host just needs to know the location of the launch.json in the filesystem (you have to edit this)

Then, with every new invocation of the PowerShell code, the host determines the process id and the runspace id of the executing runspace and generates a new lauch.json file in the VSCode workspace. Fortunately, VSCode does not lock the launch.json file and it can be replaced while VSCode is running.

### Installation

1. Place a copy of the debugger.ps1 file into a folder containing your other ps1 modules, so that if can be found and loaded during startup
1. At the top of Debugger.ps1 there is a variable called $LaunchJsonPath. This variable tells the system where to put the launch.json file. You have to edit the value so that it matches your workspace environment.
1. If the debugger.ps1 file is loaded automatically at startup (e.g. in powerJobs or VDS) you do not need additional steps to load the code, otherwise you should dotsource the debugger.ps1 file at the startup fo your PowerShell code.
1. Early on in the execution of your PowerShell code you have to insert a call of the function PrepareDebugger (see sourcecdoe in debugger.ps1) This routine will determine process id and runspace id and generate a matching launch.json. It will also show a Win10 notification that you can start the debugger in VSCode
1. As a last step in your PowerShell code you need to add a statement to stop and wait for a connecting debugger. For this purpose there is an alias defined as 'bp' at the top of debugger.ps1. You have to find a suitable place in your sourcecode where you want the debugger to attach and insert the bp statement there

### Usage 

Once everything is set up as described above you 

1. Start VSCode
1. Open up the VSCode workspace with the ps1 files you want to debug
1. Start your PowerShell host (Vault, powerJobs, etc.)

1. Execute your hosted functionality. Once the launch.json is up to date you will get the Win10 notification, which tells you that your code is now waiting for a connecting debugger 

1. Start the debugger in VSCode. The connection should be established and the PowerShell sourcecode should be shown in VSCode