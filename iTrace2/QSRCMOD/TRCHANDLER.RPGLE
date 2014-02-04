000100120820     /**
000101120722      * \brief TRCHANDLER: Implements some basic debugging actions
000102120722      *
000103120722      * <p>
000104120722      *  This module contains the implementation of some basic debugger
000105120722      *  operations needed to trace a program
000106120722      * </p>
000107120722      *
000108120722      * \author Isaac Ramirez Herrera
000109120722      * \date   July 19, 2012
000110120722      * \rev    1.0
000111120722      * \notes  Based on the code provided by Steve Kilner and
000112120722      *         the source included in IBM i V5R4 in the file
000113120722      *         QUSRTOOLS/QATTSYSC(TTERCP)
000114120722      *
000115120722      * IMPORTANT: if this proram is recompiled and binded, it must NOT
000116120722      *            contain any debug information, otherwise the tracer
000117120722      *            will fail
000118120722      **/
000119120722
000120120720     h nomain
000121121008     h bnddir('CEXCEPBNDD':'QC2LE')
000122120722     h option(*nodebugio:*noxref:*srcstmt)
000123120721     h bnddir('TRACEBNDD')
000124120721
000125121028      /include qsrctxt,llist_h
000126121028      /include qsrctxt,debugrapis
000127121028      /include qsrctxt,trchandler
000128121028      /include qsrctxt,tracetypes
000129121028      /include qsrctxt,traceconst
000130121028      /include qsrctxt,trcrules
000131121028      /include qsrctxt,cexception
000132120720
000151120720      /////////////////////////////////////////////////////////////////////////
000152120720      // Variable declaration
000153120720      /////////////////////////////////////////////////////////////////////////
000154120720
000155121009     d CODEBEGIN_COLUMN...
000156121009     d                 c                   const(6)
000157121011
000158121011     d MAX_PROGRAMS_IN_DEBUG...
000159121011     d                 c                   const(128)
000160121009
000161120802      //Contains the list of debug information for every program debugged
000162120802      //in the current trace session
000163120720     d programInDebug_List...
000164121011     d                 ds                  likeds(programData_type)
000165121011     d                                     dim(MAX_PROGRAMS_IN_DEBUG)
000166121011     d                                     inz(*likeds)
000167121011     d programInDebug_ListSize...
000168121011     d                 s             10i 0 inz(0)
000169120802
000170120802      //Variables used to interact with the data area containing the
000171120802      //case id. This case id is used to related a trace record
000172120802      //with a test case
000173120726     d exchangeArea    s             21a
000174120726     d exchange        ds                  dtaara(*var:exchangeArea) qualified
000175120726     d  value                        20a
000176120817
000177120817
000178120817      /////////////////////////////////////////////////////////////////////////
000179120817      // Prototype declaration
000180120817      /////////////////////////////////////////////////////////////////////////
000181120817
000182120817     d TS_Malloc       pr              *   extproc('_C_TS_malloc')
000183120817     d  size                         10u 0 value
000184120817
000185120817     d TS_Free         pr                  extproc('_C_TS_free')
000186120817     d  pointer                        *   value
000187120726
000188140110     d prepareForSEP...
000190140110     d                 pr                  likeds(programData_type)
000191140110     d programName                         likeds(programName_type)
000192140110     d programType                   10a   const
000193140110
000194120817     d disposeProgramData...
000195120817     d                 pr
000196121011     d program_data                        likeds(programData_type)
000197120817
000198120817     d getAllStatementsForModules...
000199120817     d                 pr
000200120817     d programData                         likeds(programData_type)
000201120817
000202121009     d mapViewPosition...
000203121009     d                 pr            10i 0
000204121009     d fromView                      10i 0 const
000205121009     d fromView_Line                 10i 0 const
000206121009     d toView                        10i 0 const
000207121009
000208120720      /////////////////////////////////////////////////////////////////////////
000209120720      // Procedure definition
000210120720      /////////////////////////////////////////////////////////////////////////
000211120820
000212120820     /**
000213120820      * \brief TRCHANDLER_startSourceDebug: this procedure begins the trace
000214120820      *
000215120820      * <p>
000216120820      *  This procedure starts the trace session.
000217120820      * </p>
000218120820      *
000219120820      * \param qualified program name
000220120820      * \param type of the program (*SRVPGM or *PGM)
000221120820      * \param qualified name of the stop handler
000222120820      */
000223120720     p TRCHANDLER_startSourceDebug...
000224120720     p                 b                   export
000225120720     d                 pi
000226120820     d program                       20a   const
000227120801     d programType                   10a   const
000228120720     d stopHandler                   20a   const
000229120721     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
000230120720     d programName     ds                  likeds(programName_type)
000231120720
000232120720      /free
000233120720       monitor;
000234120720         //Force an exception if the API call fails
000235120721         errorDS.Bytes = 0;
000236120720
000237120720         //Initiate the debug
000238120720         StarSourceDebugAPI(stopHandler:errorDS);
000239120720
000240120720         //Add the program to debug
000241120820         programName.name    = %subst(program:1:10);
000242120820         programName.library = %subst(program:11:10);
000243121009         TRCHANDLER_prepareForDebug(programName:programType);
000244120720       on-error;
000245120720         CEXCEPTION_catchException();
000246120720         CEXCEPTION_printStackTrace();
000247120721         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000248120720            :'Error while starting debug');
000249120720       endmon;
000250120720      /end-free
000251120720     p                 e
000252120720      //_______________________________________________________________________
000253120720
000254140110     /**
000255140110      * \brief: Start the service entry point monitor sesion.
000256140110      *
000257140110      * <p>
000258140110      *  This procedure set up the service entry point for an specific program
000259140110      *  The session that calls this procedure must be different from the
000260140110      *  session where the program is called.
000261140110      * </p>
000262140110      */
000263140110     p TRCHANDLER_startSEPMonitor...
000264140110     p                 b                   export
000265140110     d                 pi
000266140110     d program                       20a   const
000267140110     d programType                   10a   const
000268140110     d stopHandler                   20a   const
000269140110     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
000270140110     d programName     ds                  likeds(programName_type)
000271140110
000272140110      /free
000273140110       monitor;
000274140110         //Force an exception if the API call fails
000275140110         errorDS.Bytes = 0;
000276140110
000277140110         //Initiate the debug
000278140110         StarSourceDebugAPI(stopHandler:errorDS);
000279140110
000280140110         //Add the program to debug
000281140110         programName.name    = %subst(program:1:10);
000282140110         programName.library = %subst(program:11:10);
000283140110
000284140110         prepareForSEP(programName:programType);
000285140110
000286140110       on-error;
000287140110         CEXCEPTION_catchException();
000288140110         CEXCEPTION_printStackTrace();
000289140110         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000290140110            :'Error while starting debug');
000291140110       endmon;
000292140110      /end-free
000293140110     p                 e
000294140110      //_______________________________________________________________________
000295140110
000296120820     /**
000297120820      * \brief TRCHANDLER_tearDownTrace: disposes all resources used for trace
000298120820      *
000299120820      * <p>
000300120820      *  This procedure releases all resources used by the tracing session
000301120820      * </p>
000302120820      *
000303120820      */
000304120720     p TRCHANDLER_tearDownTrace...
000305120720     p                 b                   export
000306120720     d index           s             10i 0
000307120721     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
000308120817
000309120720      /free
000310120720       monitor;
000311121011         if (programInDebug_ListSize > 0);
000312120817           //For each program in the debug list, release its resources
000313121011           for index = 1 to programInDebug_ListSize;
000314121011             disposeProgramData(programInDebug_List(index));
000315120817           endfor;
000316121011
000317121011           clear programInDebug_List;
000318121011           clear programInDebug_ListSize;
000319120720         endif;
000320120720       on-error;
000321120720         CEXCEPTION_catchException();
000322120720         CEXCEPTION_printStackTrace();
000323120720       endmon;
000324120720
000325120720       monitor;
000326120720         //Force an exception if the API fails
000327120721         errorDS.Bytes = 0;
000328120720
000329120720         //Stop the source debugger
000330120720         EndSourceDebugAPI(errorDS);
000331120720       on-error;
000332120720         CEXCEPTION_catchException();
000333120720         CEXCEPTION_printStackTrace();
000334120720       endmon;
000335120720      /end-free
000337120720     p                 e
000338120720      //_______________________________________________________________________
000339120720
000340140110     /**
000341140110      * \brief  TRCHANDLER_step: executes a step instruction
000342140110      *
000343140110      * <p>
000344140110      *   This procedure executes a step instruction for the current trace
000345140110      *   session.
000346140110      * </p>
000347140110      *
000348140110      * \param id of the view in which to do a step
000349140110      * \param indicates if the step must do a step into or not
000350140110      * \param indicates how many steps must be executed in the code
000351140110      */
000352140110     p TRCHANDLER_step...
000353140110     p                 b                   export
000354140110     d                 pi
000355140110     d viewId                        10i 0 const
000356140110     d stepIntoFlag                    n   const
000357140110     d stepCount                     10i 0 const
000358140110     d stepType        s             10a
000359140110     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
000360140110
000361140110      /free
000362140110       monitor;
000363140110         if stepIntoFlag;
000364140110           stepType = '*INTO';
000365140110         else;
000366140110           stepType = '*OVER';
000367140110         endif;
000368140110
000369140110         errorDS.Bytes = 0;
000370140110
000371140110         StepAPI(viewId:stepCount:stepType:errorDS);
000372140110       on-error;
000373140110         CEXCEPTION_catchException();
000374140110         CEXCEPTION_printStackTrace();
000375140110         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000376140110           :'Error processing step');
000377140110       endmon;
000378140110      /end-free
000379140110     p                 e
000380140110      //_______________________________________________________________________
000381140110
000382140110     /**
000383140110      * \brief TRCHANDLER_prepareForDebug: adds a program to the debug queue
000384140110      *
000385140110      * <p>
000386140110      *  This procedure loads the debug data of an specific program and
000387140110      *  adds it to a list of programs in debug
000388140110      * </p>
000389140110      *
000390140110      * \param name of the program
000391140110      * \param type of the program
000392140110      * \return Added program. Type programData_type
000393140110      */
000394140110     p TRCHANDLER_prepareForDebug...
000395140110     p                 b                   export
000396140110     d                 pi                  likeds(programData_type)
000397140110     d programName                         likeds(programName_type)
000398140110     d programType                   10a   const
000399140110     d
000400140110     d program_data    ds                  likeds(programData_type) inz(*likeds)
000401140110     d firstStatementView...
000402140110     d                 ds                  likeds(viewIndex_type)
000403140110
000404140110      /free
000405140110       monitor;
000406140110         //Save the program data
000407140110         program_data.programType = programType;
000408140110         program_data.program     = programName;
000409140110
000410140110         //Retrieve and register all the debug views
000411140110         TRCHANDLER_retrieveDebugViews(programName:programType:program_data);
000412140110
000413140110         if program_data.viewIndexListSize > 0;
000414140110
000415140110           firstStatementView = program_data.viewIndexList(1);
000416140110
000417140110           //Save all the statement information related to the module
000418140110           getAllStatementsForModules(program_data);
000419140110
000420140110           //Do a single step into the first debug view
000421140110           TRCHANDLER_step(program_data.debugData.elements(firstStatementView
000422140110               .statement).viewNumber:*ON:1);
000423140110
000431140110           //Add at the end of the programs list
000432140110           programInDebug_ListSize += 1;
000433140110           programInDebug_List(programInDebug_ListSize) = program_data;
000434140110
000435140110           //Return the retrieved program data
000436140110           return program_data;
000437140110         else;
000438140110           CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000439140110            :'Program ' + programName.name + ' not available for debug');
000440140110         endif;
000441140110       on-error;
000442140110         CEXCEPTION_catchException();
000443140110         CEXCEPTION_printStackTrace();
000444140110         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000445140110            :'Error adding program to debug');
000446140110       endmon;
000447140110      /end-free
000448140110     p                 e
000449140110      //_______________________________________________________________________
000450140110
000451140110     p prepareForSEP...
000452140110     p                 b
000453140110     d                 pi                  likeds(programData_type)
000454140110     d programName                         likeds(programName_type)
000455140110     d programType                   10a   const
000456140110     d
000457140110     d program_data    ds                  likeds(programData_type) inz(*likeds)
000458140110     d firstStatementView...
000459140110     d                 ds                  likeds(viewIndex_type)
000460140110
000462140110     d
000463140110      /free
000464140110       monitor;
000465140110         //Save the program data
000466140110         program_data.programType = programType;
000467140110         program_data.program     = programName;
000468140110
000469140110         //Retrieve and register all the debug views
000470140110         TRCHANDLER_retrieveDebugViews(programName:programType:program_data);
000471140110
000472140110         if program_data.viewIndexListSize > 0;
000473140110
000474140110           firstStatementView = program_data.viewIndexList(1);
000475140110
000476140110           //Save all the statement information related to the module
000477140110           getAllStatementsForModules(program_data);
000478140110
000479140110           //Do a single step into the first debug view
000480140110       //    TRCHANDLER_submitDebugCommand('BREAK 24 '
000481140110       //        :program_data.debugData.elements(firstStatementView.statement).
000482140110       //         compilerId
000483140110       //        :program_data.debugData.elements(firstStatementView.statement)
000484140110       //         .viewNumber);
000485140110
000486140110          TRCHANDLER_step(program_data.debugData.elements(firstStatementView
000487140110               .statement).viewNumber:*ON:1);
000488140110
000489140110       //   errorDs.Bytes = 0;
000490140110       //   AddBreakpointAPI(program_data.debugData.elements
000491140110       //                    (firstStatementView.statement).viewNumber
000492140110       //                   :24
000493140110       //                   :1
000494140110       //                   :stmtBreakLine
000495140110       //                   :errorDS );
000496140110
000497140110
000503140110
000504140110
000505140110           //Add at the end of the programs list
000506140110           programInDebug_ListSize += 1;
000507140110           programInDebug_List(programInDebug_ListSize) = program_data;
000508140110
000509140110           //Return the retrieved program data
000510140110           return program_data;
000511140110         else;
000512140110           CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000513140110            :'Program ' + programName.name + ' not available for debug');
000514140110         endif;
000515140110       on-error;
000516140110         CEXCEPTION_catchException();
000517140110         CEXCEPTION_printStackTrace();
000518140110         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000519140110            :'Error adding program to debug');
000520140110       endmon;
000521140110      /end-free
000522140110     p                 e
000523140110      //_______________________________________________________________________
000524140110
000525140110     /**
000526140110      * \brief TRCHANDLER_retrieveDebugViews: retrives and register debug viwe
000527140110      *
000528140110      * <p>
000529140110      *  This procedure retrieves and register all the available debug views
000530140110      *  for an specific program
000531140110      * </p>
000532140110      *
000533140110      * \param name of the program (input/output)
000534140110      * \param type of the program
000535140110      * \param structure containing the program data (output)
000536140110      */
000537140110     p TRCHANDLER_retrieveDebugViews...
000538140110     p                 b                   export
000539140110     d                 pi
000540140110     d programName                         likeds(programName_type)
000541140110     d programType                   10a   const
000542140110     d programData                         likeds(programData_type)
000543140110     d
000544140110     d elementCount    s             10i 0
000545140110     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
000546140110     d viewLines       s             10i 0
000547140110     d viewId          s             10i 0
000548140110     d index           s             10i 0
000549140110     d libraryReturned...
000550140110     d                 s             10a
000551140110     d timestamp       s             13a
000552140110     d viewIndex       ds                  likeds(viewIndex_type)
000553140110     d currentModule   s             10a   inz(*blanks)
000554140110     d tempIndex       s             10i 0
000555140110
000556140110      /free
000557140110       reset errorDS;
000558140110       errorDS.Bytes = 0;
000559140110       programData.viewIndexListSize = 0;
000560140110
000561140110       //Retrieve all the module views info
000562140110       RetrieveModuleViewsAPI(programData.debugData
000563140110                             :%size(programData.debugData)
000564140110                             :'VEWL0100'
000565140110                             :programName
000566140110                             :programType
000567140110                             :ALL_VIEWS
000568140110                             :libraryReturned
000569140110                             :errorDS);
000570140110
000571140110       if (programData.debugData.numberOfElements = 0);
000572140110         //Raise the exception
000573140110         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000574140110            :'Program is not debuggable');
000575140110       else;
000576140110         //Useful when *LIBL or *CURLIB was specified
000577140110         programName.library = libraryReturned;
000578140110       endif;
000579140110
000580140110       //Register all the views in the program
000581140110       elementCount = programData.debugData.numberOfElements;
000582140110
000583140110       for index = 1 to elementCount;
000584140110         //Register the view
000585140110         errorDS.Bytes = 0;
000586140110         RegisterDebugViewAPI( viewId
000587140110                             : viewLines
000588140110                             : libraryReturned
000589140110                             : timestamp
000590140110                             : programName
000591140110                             : programType
000592140110                             : programData.debugData.elements(index).moduleName
000593140110                             : programData.debugData.elements(index).viewNumber
000594140110                             : errorDS);
000595140110         //Save the viewId
000596140110         programData.debugData.elements(index).viewNumber = viewId;
000597140110
000598140110         if currentModule = *blanks;
000599140110           clear viewIndex;
000600140110           currentModule    = programData.debugData.elements(index).moduleName;
000601140110           viewIndex.module = currentModule;
000602140110         else;
000603140110           if currentModule <> programData.debugData.elements(index).moduleName;
000604140110             //Add the new element
000605140110             tempIndex  = programData.viewIndexListSize;
000606140110             tempIndex += 1;
000607140110             programData.viewIndexList(tempIndex) = viewIndex;
000608140110             programData.viewIndexListSize        = tempIndex;
000609140110
000610140110             //Prepare the new view Index
000611140110             clear viewIndex;
000612140110             currentModule = programData.debugData.elements(index).moduleName;
000613140110             viewIndex.module = currentModule;
000614140110           endif;
000615140110         endif;
000616140110
000617140110         select;
000618140110           when programData.debugData.elements(index).viewType = STATEMENT_VIEW;
000619140110             viewIndex.statement   = index;
000620140110             viewIndex.statementId = viewId;
000621140110           when programData.debugData.elements(index).viewType = TEXT_VIEW;
000622140110             viewIndex.text   = index;
000623140110             viewIndex.textId = viewId;
000624140110           when programData.debugData.elements(index).viewType = LISTING_VIEW;
000625140110             viewIndex.listing   = index;
000626140110             viewIndex.listingId = viewId;
000627140110         endsl;
000628140110       endfor;
000629140110
000630140110       if (currentModule <> *blanks);
000631140110         //Add the new element
000632140110         tempIndex  = programData.viewIndexListSize;
000633140110         tempIndex += 1;
000634140110         programData.viewIndexList(tempIndex) = viewIndex;
000635140110         programData.viewIndexListSize        = tempIndex;
000636140110       endif;
000637140110      /end-free
000638140110     p                 e
000639140110      //_______________________________________________________________________
000640140110
000641120821     /**
000642120821      * \brief  TRCHANDLER_findProgramDebugData: search for debug data
000643120821      *
000644120821      * <p>
000645120821      *  This procedure iterates over the programInDebug_List in order to
000646120821      *  find the debug data previously loaded for an specific program
000647120821      * </p>
000648120821      *
000649120821      * \param  name of the program
000650120821      * \param  type of the program
000651121011      * \return index of the searched program in list. *Zero if not found
000652120821      */
000653120720     p TRCHANDLER_findProgramDebugData...
000654120720     p                 b                   export
000655121011     d                 pi            10i 0
000656120720     d programName                         likeds(programName_type) const
000657120720     d programType                   10a   const
000658121011     d
000659120720     d index           s             10i 0
000661120720     d program_data    ds                  likeds(programData_type)
000663120720
000664120720      /free
000665121011       if (programInDebug_ListSize = 0);
000668121011         return *ZERO;
000669120720       else;
000673120821         //List index is zero-based
000674121011         for index = 1 to programInDebug_ListSize;
000675121011           program_data = programInDebug_List(index);
000676120720           if program_data.program.name    = programName.name and
000677120720              program_data.program.library = programName.library and
000678120720              program_data.programType     = programType;
000679121011            return index;
000680120720           endif;
000681120720         endfor;
000682120720
000683121011         return *ZERO;
000684120720       endif;
000685120720      /end-free
000686120720     p                 e
000687120720      //_______________________________________________________________________
000688120720
000776120820     /**
000777120820      * \brief TRCHANDLER_retrieveTextLineFromView: retrieve the line of code
000778120820      *
000779120820      * <p>
000780120820      *  This procedure retrieve the code line of the debug view identified
000781120820      *  by viewId
000782120820      * </p>
000783120820      *
000784120820      * \param id of the code view
000785120820      * \param number of the current line in the view
000786120820      * \return structure containing line data
000787120820      */
000788120720     p TRCHANDLER_retrieveTextLineFromView...
000789120720     p                 b                   export
000790120720     d                 pi                  likeds(codeLine_type)
000791120720     d viewId                        10i 0 const
000792120720     d lineNumber                    10i 0 const
000793121004     d viewType                      10a   const
000794121004     d
000795140110     d
000796120720     d lineCount       s             10i 0 inz(1)
000797120720     d
000798121004      //Data structure of the code view line
000799121004     d codeViewLine    ds                  qualified based(codeViewLinePtr)
000800120720     d  bytesReturned                10i 0
000801120720     d  bytesAvailabl                10i 0
000802120720     d  linesReturned                10i 0
000803120720     d  lineLength                   10i 0
000804120720     d  sequenceNumbr                12a
000805120720     d  lineText                    255a
000806121004
000807121004      //Data structure of the listing View Line
000808121004     d listingViewLine...
000809121004     d                 ds                  qualified based(listingViewLinePtr)
000810121004     d  bytesReturned                10i 0
000811121004     d  bytesAvailabl                10i 0
000812121004     d  linesReturned                10i 0
000813121004     d  lineLength                   10a
000814121004     d  lineText                    255a
000815120720     d
000816120720     d buffer          s          65535a
000817120721     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
000818120720     d codeLine        ds                  likeds(codeLine_type)
000819121004     d codeBeggining   s             10i 0
000820121217     d sequenceBegin   s             10i 0
000821121217     d sequenceEnding  s             10i 0
000822121217
000823120720      /free
000824120720       monitor;
000825120721         errorDS.Bytes = 0;
000826120720         RetrieveViewTextAPI( buffer
000827120720                            : %size(buffer)
000828120720                            : viewId
000829120720                            : lineNumber
000830120720                            : lineCount
000831120720                            : 255
000832120720                            : errorDs);
000833120720
000834121217         //Set the default value for the line
000835121217         clear codeLine;
000836121217         codeLine.text = 'Code Line unavailable';
000837121217
000838121004         select;
000839121004            when viewType = TEXT_VIEW;
000840121217              //Code lines from the text view have a well-defined
000841121217              //structure
000842121004              codeViewLinePtr = %addr(buffer);
000843121004              codeLine.sequence = %subst(codeViewLine.sequenceNumbr:1:6);
000844121004              codeLine.date     = %subst(codeViewLine.sequenceNumbr:7);
000845121004              codeLine.text     = codeViewLine.lineText;
000846121213              codeLine.origin   = CODE_FROM_SOURCE;
000847121213            when viewType = LISTING_VIEW;
000848121217              //The lines of code in the listing view dont have a separate
000849121217              //field for the sequence. This sequence is variable size so
000850121217              //it must look for the first space (corresponding column 6)
000851121217              //or first '*' and retrieve the sequence with the previous
000852121217              //characters of that column
000853121004              listingViewLinePtr = %addr(buffer);
000854121217
000855121217              //Find the boundaries of the sequence number
000856121217              sequenceBegin  = %check(' ':listingViewLine.lineText);
000857121217              sequenceEnding = %check('0123456789':listingViewLine.lineText
000858121217                                    :sequenceBegin);
000859121217
000860121217              codeLine.sequence = %subst(listingViewLine.lineText
000861121217                                       :sequenceBegin
000862121217                                       :sequenceEnding - sequenceBegin);
000863121217
000864121217              codeLine.date  = '400101'; //Default date
000865121217              codeLine.text  = %subst(listingViewLine.lineText
000866121217                                     :sequenceEnding + 1);
000867121217              codeLine.origin= CODE_FROM_LISTING;
000868121004            other;
000869121004              clear codeLine;
000870121004              codeLine.text = 'Code Line unavailable';
000871121004         endsl;
000872121004
000873120720         return codeLine;
000874120720       on-error;
000875120720         CEXCEPTION_catchException();
000876121009         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000877121009           :'Line unavailable');
000878121004       endmon;
000879120720      /end-free
000880120720     p                 e
000881120720      //_______________________________________________________________________
000882120723
000883121009     /**
000884121009      * \brief TRCHANDLER_getCodeLine retrieve code line from text or listing
000885121009      *
000886121009      * <p>
000887121009      *  This procedure retrieves the code line from the *TEXT or
000888121009      *  *LISTTNG view
000889121009      * </p>
000890121009      *
000891121009      * \param views indexes
000892121009      * \param id of the stopped line
000893121009      * \return code line information
000894121009      */
000895121009     p TRCHANDLER_getCodeLine...
000896121009     p                 b                   export
000897121009     d                 pi                  likeds(codeLine_type)
000898121009     d viewIndex                           likeds(viewIndex_type) const
000899121009     d stoppedLine                   10i 0 const
000900121009     d codeLine        ds                  likeds(codeLine_type)
000901121009     d mappedLine      s             10i 0
000902121009
000903121009      /free
000904121009       monitor;
000905121009         clear codeLine;
000906121009         codeLine.sequence = '000000';
000907121009         codeLine.date     = *blanks;
000908121009         codeLine.text     = 'Code unavailable';
000909121009
000910121009         //First, try to retrieve the code line from the code view
000911121009         if viewIndex.textId <> -1;
000912121009           monitor;
000913121009             mappedLine = mapViewPosition(
000914121009               viewIndex.statementId
000915121009              :stoppedLine
000916121009              :viewIndex.textId);
000917121009
000918121009             codeLine = TRCHANDLER_retrieveTextLineFromView(
000919121009                    viewIndex.textId:mappedLine:TEXT_VIEW);
000920121009
000921121009             return codeline;
000922121009           on-error;
000923121009             CEXCEPTION_catchException();
000924121009             CEXCEPTION_jobPrintf('Source view not available for module ' +
000925121009               viewIndex.module);
000926121009           endmon;
000927121009         endif;
000928121009
000929121009         //If the line couldnt be retrieved, try with the listing view
000930121009         if viewIndex.listingId <> -1;
000931121009           monitor;
000932121009             mappedLine = mapViewPosition(
000933121009                 viewIndex.statementId
000934121009                :stoppedLine
000935121009                :viewIndex.listingId);
000936121009
000937121009             codeLine = TRCHANDLER_retrieveTextLineFromView(
000938121009                 viewIndex.listingId:mappedLine:LISTING_VIEW);
000939121009           on-error;
000940121009             CEXCEPTION_catchException();
000941121009             CEXCEPTION_jobPrintf('Listing view not available for module ' +
000942121009               viewIndex.module);
000943121009           endmon;
000944121009         endif;
000945121009
000946121009         return codeLine;
000947121009
000948121009       on-error;
000949121009         CEXCEPTION_catchException();
000950121009         CEXCEPTION_printStackTrace();
000951121009         return codeLine;
000952121009       endmon;
000953121009      /end-free
000954121009     p                 e
000955121009      //_______________________________________________________________________
000956121009
000957120820     /**
000958120820      * \brief TRCHANDLER_getCurrentProcedureName: retrieves the current proced.
000959120820      *
000960120820      * <p>
000961120820      *  This procedure retrieves the name of the current procedure during the
000962120820      *  stop debug event
000963120820      * </p>
000964120820      *
000965121009      * \param statement buffer pointer
000966120820      * \param identification of the statement view
000967120820      * \param current stopped line
000968120822      * \param statement line (output)
000969120820      * \return name of the procedure
000970120820      */
000971120725     p TRCHANDLER_getCurrentProcedureName...
000972120725     p                 b                   export
000973120725     d                 pi          1024a
000974121009     d stmtBufferPtr                   *   const
000975120725     d currentLine                   10i 0 const
000976120822     d stmtLine                      10i 0
000977120725     d
000978120725     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
000979121009     d bufferPtr       s               *
000980120725     d statementBuff   ds                  likeds(statementBuffer_type)
000981120725     d                                     based(bufferPtr)
000982120820     d statementInfo   ds                  likeds(statementInfo_type)
000983120820     d                                     based(statementInfoPtr)
000984120725     d procedureInfo   ds                  likeds(procedureInfo_type)
000985120725     d                                     based(procedureInfoPtr)
000986120725     d procedureNameBuffer...
000987120725     d                 s          65535a   based(procedureNameBufferPtr)
000988120725
000989120725      /free
000990120725       monitor;
000991120820         clear errorDs;
000992121009         errorDS.Bytes    = 0;
000993121009         bufferPtr        = stmtBufferPtr;
000994120820         statementInfoPtr = %addr(statementBuff)
000995120820                          + statementBuff.viewLineOffset
000996120820                          + ((currentLine - 1) * %size(statementInfo_type));
000997120820
000998121009         stmtLine = statementInfo.number;
000999120822
001000120725         procedureInfoPtr = %addr(statementBuff)
001001120820                          + statementInfo.procedureInfoOffset;
001002120725
001003120725         procedureNameBufferPtr = %addr(statementBuff)
001004120725                                + procedureInfo.procedureNameOffset;
001005120725
001006120725         return %subst(procedureNameBuffer:1:procedureInfo.procedureNameLen);
001007120725       on-error;
001008120725         CEXCEPTION_catchException();
001009120725         CEXCEPTION_printStackTrace();
001010120725         return 'MISSING INFO';
001011120725       endmon;
001012120725      /end-free
001013120725     p                 e
001014120725      //_______________________________________________________________________
001015120725
001182120802     /**
001183120802      * \brief TRCHANDLER_setCaseId: Sets the current case id for the trace
001184120802      *
001185120802      * <p>
001186120802      *  This procedure sets the current case id in the exchange data area.
001187120802      *  The exchange data area is used to related a trace record with an
001188120802      *  test case. The application executing the test cases is responsible
001189120802      *  for calling this procedure with the appropiate test case
001190120802      * </p>
001191120802      *
001192120802      * \param case id to set in the data area
001193120802      * \param library of the exchange data area
001194120802      * \param name of the exchange data area
001195120802      */
001196120726     p TRCHANDLER_setCaseId...
001197120725     p                 b                   export
001198120725     d                 pi
001199120802     d caseId                        20a   const
001200120726     d dtaaraLib                     10a   const
001201120726     d dtaaraName                    10a   const
001202120726
001203120725      /free
001204120725       monitor;
001205120726         exchangeArea = dtaaraLib + '/' + dtaaraName;
001206120726         in *lock exchange;
001207120802         exchange.value = caseId;
001208120726         out exchange;
001209120726       on-error;
001210120725         CEXCEPTION_catchException();
001211120725         CEXCEPTION_printStackTrace();
001212120726
001213120726         unlock exchange;
001214120726
001215120725         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
001216120725           :'Could not set the correlationId');
001217120725       endmon;
001218120725      /end-free
001219120725     p                 e
001220120725      //_______________________________________________________________________
001221120731
001222120802     /**
001223120802      * \brief TRCHANDLER_submitDebugCommand: Submits a debug command
001224120802      *
001225120802      * <p>
001226120802      *  This procedure submits a debug command to the debug session.
001227120802      *  A debug command can be: 'STEP OUTF', 'STEP INTO', and others.
001228120802      * </p>
001229120802      *
001230120802      * \param command to submit
001231120802      * \param identification of the compiler used for the current debug view
001232120802      * \param identification of the debug view to submit the command
001233120802      */
001234120731     p TRCHANDLER_submitDebugCommand...
001235120731     p                 b                   export
001236120731     d                 pi
001237120731     d command                      255a   const
001238120731     d compilerId                    20a   const
001239120731     d viewId                        10i 0 const
001240120731     d
001241120731     d buffer          s          65535a
001242120731     d inputBuffer     s            255a
001243120820     d
001244120731     d errorDs         ds                  likeds(ApiError_Type)
001245120820     d
001246120731     d receiverData    ds                  qualified based(receiverPtr)
001247120731     d  bytesReturned                10i 0
001248120731     d  bytesAvailabl                10i 0
001249120731     d  entryCount                   10i 0
001250120731     d  resultArray                        dim(1) likeds(result_Type)
001251120731     d
001252120820     d result_Type     ds                  qualified template
001253120731     d  resultKind                   10i 0
001254120731     d  stepCount                    10i 0
001255121001     d  reserved                      4a
001256120731
001257120731      /free
001258120731       monitor;
001259120731         inputBuffer   = command;
001260121001         errorDs.Bytes = 0;
001261120731         SubmitDebugCommandAPI(buffer
001262120731                              :%len(buffer)
001263120731                              :viewId
001264120731                              :inputBuffer
001265120731                              :%len(%trim(command))
001266120731                              :compilerId
001267120731                              :errorDs);
001268121001
001269120731         receiverPtr = %addr(buffer);
001270121001
001271120731         if receiverData.bytesReturned > 0 and receiverData.entryCount > 0;
001272120731           CEXCEPTION_jobPrintf('Debug command sucessful');
001273120731         else;
001274120731           CEXCEPTION_jobPrintf('Debug command failed');
001275120731         endif;
001276120731       on-error;
001277120731         CEXCEPTION_catchException();
001278120731         CEXCEPTION_printStackTrace();
001279120731       endmon;
001280120731      /end-free
001281120731     p                 e
001282120802      //_______________________________________________________________________
001283121011
001284121011     /**
001285121011      * \brief TRCHANDLER_getProgramInList: gets a program from the list
001286121011      *
001287121011      * \param index of the list
001288121011      * \return program data structure
001289121011      */
001290121011     p TRCHANDLER_getProgramInList...
001291121011     p                 b                   export
001292121011     d                 pi                  likeds(programData_type)
001293121011     d index                         10i 0 const
001294121011
001295121011      /free
001296121011       if index > *zero and index <= programInDebug_ListSize;
001297121011         return programInDebug_List(index);
001298121011       else;
001299121011         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG':'Invalid index');
001300121011       endif;
001301121011      /end-free
001302121011     p                 e
001303121011      //_______________________________________________________________________
001304140110
001305140110    /**
001306140110      * \brief disposeProgramData: release the resources of the program debug
001307140110      *
001308140110      * <p>
001309140110      *  This procedure disposes all the resources used by a single program
001310140110      *  debug data
001311140110      * </p>
001312140110      *
001313140110      * \param program debug data
001314140110      */
001315140110     p disposeProgramData...
001316140110     p                 b
001317140110     d                 pi
001318140110     d program_data                        likeds(programData_type)
001319140110     d
001320140110     d index           s             10i 0
001321140110     d limit           s             10i 0
001322140110
001323140110      /free
001324140110       monitor;
001325140110         clear program_data.viewIndexListSize;
001326140110         clear program_data.viewIndexList;
001327140110
001328140110         for index = 1 to limit;
001329140110           TS_Free(program_data.statementBufferArray(index));
001330140110           clear program_data.debugData;
001331140110           clear program_data;
001332140110         endfor;
001333140110       on-error;
001334140110         CEXCEPTION_catchException();
001335140110         CEXCEPTION_printStackTrace();
001336140110         CEXCEPTION_jobPrintf('Error while disposing individual program data');
001337140110       endmon;
001338140110      /end-free
001339140110     p                 e
001340140110      //_______________________________________________________________________
001341140110
001342140110     /**
001343140110      * \brief mapViewPosition: maps lines between lines
001344140110      *
001345140110      * <p>
001346140110      *  This procedure maps a line number between different views
001347140110      * </p>
001348140110      *
001349140110      * \param origin view
001350140110      * \param origin line
001351140110      * \param destination view
001352140110      * \return destination view corresponding line
001353140110      */
001354140110     p mapViewPosition...
001355140110     p                 b
001356140110     d                 pi            10i 0
001357140110     d fromView                      10i 0 const
001358140110     d fromView_Line                 10i 0 const
001359140110     d toView                        10i 0 const
001360140110     d
001361140110     d mapViewDta      ds                  likeds(mapViewData_type)
001362140110     d                                     based(mapViewPtr)
001363140110     d mapViewLen      s             10i 0
001364140110     d column          s             10i 0 inz(1)
001365140110     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
001366140110     d tempBuffer      s          65535a
001367140110
001368140110      /free
001369140110       monitor;
001370140110         mapViewLen    = %size(mapViewData_type);
001371140110         errorDS.Bytes = 0;
001372140110
001373140110         MapViewPositionAPI(tempBuffer
001374140110                           :mapViewLen
001375140110                           :fromView
001376140110                           :fromView_Line
001377140110                           :column
001378140110                           :toView
001379140110                           :errorDS);
001380140110
001381140110         mapViewPtr = %addr(tempBuffer);
001382140110         return mapViewDta.elements(1).lineNumber;
001383140110       on-error;
001384140110         CEXCEPTION_catchException();
001385140110         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG':
001386140110           'Error mapping position');
001388140110       endmon;
001389140110      /end-free
001390140110     p                 e
001391140110      //_______________________________________________________________________
001392140110
001393140110     /**
001394140110      * \brief getAllStatementsForModules: loads all of the statement views
001395140110      *
001396140110      * <p>
001397140110      *  This procedures iterates through all the modules views and loads into
001398140110      *  an array, every statement of the statement view
001399140110      * </p>
001400140110      *
001401140110      * \param structure containing the program debug data
001402140110      */
001403140110     p getAllStatementsForModules...
001404140110     p                 b                   export
001405140110     d                 pi
001406140110     d programData                         likeds(programData_type)
001407140110     d
001408140110     d errorDs         ds                  likeds(ApiError_Type) inz(*likeds)
001409140110     d stmtBuffer      ds                  likeds(statementBuffer_type)
001410140110     d                                     based(stmtBufferPtr)
001411140110     d stmtBufferLen   s             10i 0
001412140110     d
001413140110     d tempBuffer      ds                  likeds(statementBuffer_type)
001414140110     d tempBufferLen   s             10i 0 inz(8)
001415140110     d
001416140110     d index           s             10i 0
001417140110     d limit           s             10i 0
001418140110     d viewId          s             10i 0
001419140110
001420140110      /free
001421140110       monitor;
001422140110         programData.statementBufferArray = *NULL;
001423140110         limit = programData.debugData.numberOfElements;
001424140110
001425140110         //Get the statement for each of the modules
001426140110         for index = 1 to limit;
001427140110           clear errorDs;
001428140110           errorDS.Bytes = 0;
001429140110
001430140110           if programData.debugData.elements(index).viewType = STATEMENT_VIEW;
001431140110             viewId = programData.debugData.elements(index).viewNumber;
001432140110
001433140110             clear tempBuffer;
001434140110
001435140110             //Query the API to retrieve the size that must be
001436140110             //allocated for the buffer
001437140110             RetrieveStatementViewAPI(tempBuffer
001438140110                :tempBufferLen:viewId:1:0:errorDS);
001439140110
001440140110             //Alloc the right size
001441140110             stmtBufferLen = tempBuffer.bytesAvailable;
001442140110             stmtBufferPtr = TS_Malloc(stmtBufferLen);
001443140110
001444140110             //Retrieve the data with the right buffer
001445140110             RetrieveStatementViewAPI(stmtBuffer:stmtBufferLen
001446140110                                     :viewId:1:0:errorDS);
001447140110
001448140110             programData.statementBufferArray(index) = stmtBufferPtr;
001449140110           else;
001450140110             programData.statementBufferArray(index) = *NULL;
001451140110           endif;
001452140110         endfor;
001453140110       on-error;
001454140110         CEXCEPTION_catchException();
001455140110         CEXCEPTION_printStackTrace();
001456140110
001457140110         if stmtBufferPtr <> *NULL;
001458140110           monitor;
001459140110             TS_Free(stmtBufferPtr);
001460140110           on-error;
001461140110
001462140110           endmon;
001463140110         endif;
001464140110
001465140110         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
001466140110           :'Could not retrieve the statment view');
001467140110       endmon;
001468140110      /end-free
001469140110     p                 e
001470140110      //_______________________________________________________________________
