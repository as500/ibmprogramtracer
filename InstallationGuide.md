In order to successfully install the **iTrace** tool in an _IBM i System_, please follow the next steps

## Step 1 ##
Download the [savf archive](http://ibmprogramtracer.googlecode.com/files/ITRACE.SAVF) available in the download page or do an SVN checkout from RDp/RDi/WSDC of the complete project source.

## Step 2 ##
Upload the savf to the IBM i. An example of this procedure can be:

  * Bring up the command prompt window: `>Start >run “cmd” [enter]`
  * Change the directory to the folder on your PC where you saved the downloaded iTrace file:
  * Enter: `CD c:/myfolderpath`
  * Enter: `FTP xxx.xxx.xxx.xxx` (your IBM i IP address) when FTP prompts you, enter your IBM i User ID & Password
  * Enter: `binary`
  * Enter: `quote site namefmt 1`
  * Enter: `cd /qsys.lib/qgpl.lib`
  * Enter: `put itrace.savf itrace.savf`
  * Enter: `quit`

If you did an SVN checkout, you will just need to push the source code to the IBM i with the help of RDi/WSDC.

## Step 3 ##
Unpack the uploaded file using `RSTLIB` (only applies if you downloaded the SAVF)

## Step 4 ##
Compile the installation CL program:

`CHGCURLIB DESTINATION_LIB`

`CRTBNDCL PGM(BUILDTRACR) SRCFILE(QSRCPGM) SRCMBR(BUILDTRACR) OPTION(*EVENTF) REPLACE(*YES) TGTRLS(V6R1M0) DBGVIEW(*SOURCE)`

## Step 5 ##
Run the installation program. This will compile all the objects:

`CALL BUILDTRACR DESTINATION_LIB`