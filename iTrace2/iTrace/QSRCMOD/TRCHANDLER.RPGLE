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
000188120817     d disposeProgramData...
000189120817     d                 pr
000190121011     d program_data                        likeds(programData_type)
000191120817
000192120817     d getAllStatementsForModules...
000193120817     d                 pr
000194120817     d programData                         likeds(programData_type)
000195120817
000196121009     d mapViewPosition...
000197121009     d                 pr            10i 0
000198121009     d fromView                      10i 0 const
000199121009     d fromView_Line                 10i 0 const
000200121009     d toView                        10i 0 const
000201121009
000202120720      /////////////////////////////////////////////////////////////////////////
000203120720      // Procedure definition
000204120720      /////////////////////////////////////////////////////////////////////////
000205120820
000206120820     /**
000207120820      * \brief TRCHANDLER_startSourceDebug: this procedure begins the trace
000208120820      *
000209120820      * <p>
000210120820      *  This procedure starts the trace session.
000211120820      * </p>
000212120820      *
000213120820      * \param qualified program name
000214120820      * \param type of the program (*SRVPGM or *PGM)
000215120820      * \param qualified name of the stop handler
000216120820      */
000217120720     p TRCHANDLER_startSourceDebug...
000218120720     p                 b                   export
000219120720     d                 pi
000220120820     d program                       20a   const
000221120801     d programType                   10a   const
000222120720     d stopHandler                   20a   const
000223120721     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
000224120720     d programName     ds                  likeds(programName_type)
000225120720
000226120720      /free
000227120720       monitor;
000228120720         //Force an exception if the API call fails
000229120721         errorDS.Bytes = 0;
000230120720
000231120720         //Initiate the debug
000232120720         StarSourceDebugAPI(stopHandler:errorDS);
000233120720
000234120720         //Add the program to debug
000235120820         programName.name    = %subst(program:1:10);
000236120820         programName.library = %subst(program:11:10);
000237121009         TRCHANDLER_prepareForDebug(programName:programType);
000238120720       on-error;
000239120720         CEXCEPTION_catchException();
000240120720         CEXCEPTION_printStackTrace();
000241120721         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000242120720            :'Error while starting debug');
000243120720       endmon;
000244120720      /end-free
000245120720     p                 e
000246120720      //_______________________________________________________________________
000247120720
000248120820     /**
000249120820      * \brief TRCHANDLER_tearDownTrace: disposes all resources used for trace
000250120820      *
000251120820      * <p>
000252120820      *  This procedure releases all resources used by the tracing session
000253120820      * </p>
000254120820      *
000255120820      */
000256120720     p TRCHANDLER_tearDownTrace...
000257120720     p                 b                   export
000258120720     d index           s             10i 0
000260120721     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
000265120817
000266120720      /free
000267120720       monitor;
000270121011         if (programInDebug_ListSize > 0);
000271120817           //For each program in the debug list, release its resources
000275121011           for index = 1 to programInDebug_ListSize;
000276121011             disposeProgramData(programInDebug_List(index));
000277120817           endfor;
000278121011
000279121011           clear programInDebug_List;
000280121011           clear programInDebug_ListSize;
000281120720         endif;
000282120720       on-error;
000283120720         CEXCEPTION_catchException();
000284120720         CEXCEPTION_printStackTrace();
000285120720       endmon;
000286120720
000287120720       monitor;
000288120720         //Force an exception if the API fails
000289120721         errorDS.Bytes = 0;
000290120720
000291120720         //Stop the source debugger
000292120720         EndSourceDebugAPI(errorDS);
000293120720       on-error;
000294120720         CEXCEPTION_catchException();
000295120720         CEXCEPTION_printStackTrace();
000296120720       endmon;
000297120720      /end-free
000298120720
000299120720     p                 e
000300120720      //_______________________________________________________________________
000301120720
000302120821     /**
000303120821      * \brief disposeProgramData: release the resources of the program debug
000304120821      *
000305120821      * <p>
000306120821      *  This procedure disposes all the resources used by a single program
000307120821      *  debug data
000308120821      * </p>
000309120821      *
000310121011      * \param program debug data
000311120821      */
000312120817     p disposeProgramData...
000313120817     p                 b
000314120817     d                 pi
000317121011     d program_data                        likeds(programData_type)
000318121011     d
000319120817     d index           s             10i 0
000320120817     d limit           s             10i 0
000321120817
000322120817      /free
000323120817       monitor;
000324121011         clear program_data.viewIndexListSize;
000325121011         clear program_data.viewIndexList;
000326121008
000327121011         for index = 1 to limit;
000328120817           TS_Free(program_data.statementBufferArray(index));
000329120820           clear program_data.debugData;
000330120817           clear program_data;
000331120817         endfor;
000332120817       on-error;
000333120817         CEXCEPTION_catchException();
000334120817         CEXCEPTION_printStackTrace();
000335120817         CEXCEPTION_jobPrintf('Error while disposing individual program data');
000336120817       endmon;
000337120817      /end-free
000338120817     p                 e
000339120817      //_______________________________________________________________________
000340120821
000341120821     /**
000342120821      * \brief  TRCHANDLER_step: executes a step instruction
000343120821      *
000344120821      * <p>
000345120821      *   This procedure executes a step instruction for the current trace
000346120821      *   session.
000347120821      * </p>
000348120821      *
000349120821      * \param id of the view in which to do a step
000350120821      * \param indicates if the step must do a step into or not
000351120821      * \param indicates how many steps must be executed in the code
000352120821      */
000353120720     p TRCHANDLER_step...
000354120720     p                 b                   export
000355120720     d                 pi
000356120720     d viewId                        10i 0 const
000357120731     d stepIntoFlag                    n   const
000358120720     d stepCount                     10i 0 const
000359120720     d stepType        s             10a
000360120721     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
000361120720
000362120720      /free
000363120720       monitor;
000364120731         if stepIntoFlag;
000365120731           stepType = '*INTO';
000366120731         else;
000367120720           stepType = '*OVER';
000368120731         endif;
000369120720
000370120721         errorDS.Bytes = 0;
000371120731
000372120720         StepAPI(viewId:stepCount:stepType:errorDS);
000373120720       on-error;
000374120720         CEXCEPTION_catchException();
000375120720         CEXCEPTION_printStackTrace();
000376120721         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000377120720           :'Error processing step');
000378120720       endmon;
000379120720      /end-free
000380120720     p                 e
000381120720      //_______________________________________________________________________
000382120720
000383120821     /**
000384121009      * \brief TRCHANDLER_prepareForDebug: adds a program to the debug queue
000385120821      *
000386120821      * <p>
000387120821      *  This procedure loads the debug data of an specific program and
000388120821      *  adds it to a list of programs in debug
000389120821      * </p>
000390120821      *
000391121009      * \param name of the program
000392121009      * \param type of the program
000393121011      * \return Added program. Type programData_type
000394120821      */
000395121009     p TRCHANDLER_prepareForDebug...
000396120720     p                 b                   export
000397121011     d                 pi                  likeds(programData_type)
000398120720     d programName                         likeds(programName_type)
000399120720     d programType                   10a   const
000400121008     d
000401121011     d program_data    ds                  likeds(programData_type) inz(*likeds)
000403121008     d firstStatementView...
000404121008     d                 ds                  likeds(viewIndex_type)
000406121008
000407120720      /free
000408120720       monitor;
000411121011         //Save the program data
000412121011         program_data.programType = programType;
000413121011         program_data.program     = programName;
000414121011
000415121008         //Retrieve and register all the debug views
000416121011         TRCHANDLER_retrieveDebugViews(programName:programType:program_data);
000442121011
000443121011         if program_data.viewIndexListSize > 0;
000444121011
000462121011           firstStatementView = program_data.viewIndexList(1);
000463121011
000469121011           //Save all the statement information related to the module
000470121011           getAllStatementsForModules(program_data);
000471121009
000472121011           //Do a single step into the first debug view
000473121011           TRCHANDLER_step(program_data.debugData.elements(firstStatementView
000474121011               .statement).viewNumber:*ON:1);
000475121011
000476121011           //Add at the end of the programs list
000477121011           programInDebug_ListSize += 1;
000478121011           programInDebug_List(programInDebug_ListSize) = program_data;
000479121011
000485121011           //Return the retrieved program data
000487121011           return program_data;
000488121011         else;
000489121011           CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000490121011            :'Program ' + programName.name + ' not available for debug');
000491121011         endif;
000492121011       on-error;
000493120720         CEXCEPTION_catchException();
000494120720         CEXCEPTION_printStackTrace();
000495120721         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000496120720            :'Error adding program to debug');
000497120720       endmon;
000498120720      /end-free
000499120721     p                 e
000500120720      //_______________________________________________________________________
000501120720
000502121008
000503121008     /**
000504121011      * \brief TRCHANDLER_retrieveDebugViews: retrives and register debug viwe
000505121008      *
000506121008      * <p>
000507121008      *  This procedure retrieves and register all the available debug views
000508121008      *  for an specific program
000509121008      * </p>
000510121008      *
000511121008      * \param name of the program (input/output)
000512121008      * \param type of the program
000513121011      * \param structure containing the program data (output)
000514121008      */
000515121011     p TRCHANDLER_retrieveDebugViews...
000516121011     p                 b                   export
000517121011     d                 pi
000518121009     d programName                         likeds(programName_type)
000519121008     d programType                   10a   const
000520121011     d programData                         likeds(programData_type)
000521121011     d
000522121008     d elementCount    s             10i 0
000523121008     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
000524121008     d viewLines       s             10i 0
000525121008     d viewId          s             10i 0
000526121008     d index           s             10i 0
000527121008     d libraryReturned...
000528121008     d                 s             10a
000529121008     d timestamp       s             13a
000531121009     d viewIndex       ds                  likeds(viewIndex_type)
000532121008     d currentModule   s             10a   inz(*blanks)
000533121011     d tempIndex       s             10i 0
000534121011
000535121008      /free
000536121008       reset errorDS;
000537121008       errorDS.Bytes = 0;
000538121011       programData.viewIndexListSize = 0;
000539121009
000540121008       //Retrieve all the module views info
000541121011       RetrieveModuleViewsAPI(programData.debugData
000542121011                             :%size(programData.debugData)
000543121011                             :'VEWL0100'
000544121011                             :programName
000545121011                             :programType
000546121011                             :ALL_VIEWS
000547121011                             :libraryReturned
000548121011                             :errorDS);
000549121008
000550121011       if (programData.debugData.numberOfElements = 0);
000551121008         //Raise the exception
000552121008         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000553121008            :'Program is not debuggable');
000554121008       else;
000555121008         //Useful when *LIBL or *CURLIB was specified
000556121008         programName.library = libraryReturned;
000557121008       endif;
000558121008
000559121008       //Register all the views in the program
000560121011       elementCount = programData.debugData.numberOfElements;
000561121009
000562121008       for index = 1 to elementCount;
000563121008         //Register the view
000564121008         errorDS.Bytes = 0;
000565121008         RegisterDebugViewAPI( viewId
000566121008                             : viewLines
000567121008                             : libraryReturned
000568121008                             : timestamp
000569121008                             : programName
000570121008                             : programType
000571121011                             : programData.debugData.elements(index).moduleName
000572121011                             : programData.debugData.elements(index).viewNumber
000573121008                             : errorDS);
000574121008         //Save the viewId
000575121011         programData.debugData.elements(index).viewNumber = viewId;
000576121008
000577121008         if currentModule = *blanks;
000578121008           clear viewIndex;
000579121011           currentModule    = programData.debugData.elements(index).moduleName;
000580121009           viewIndex.module = currentModule;
000581121008         else;
000582121011           if currentModule <> programData.debugData.elements(index).moduleName;
000583121011             //Add the new element
000584121011             tempIndex  = programData.viewIndexListSize;
000585121011             tempIndex += 1;
000586121011             programData.viewIndexList(tempIndex) = viewIndex;
000587121011             programData.viewIndexListSize        = tempIndex;
000588121011
000589121011             //Prepare the new view Index
000590121008             clear viewIndex;
000591121011             currentModule = programData.debugData.elements(index).moduleName;
000592121008             viewIndex.module = currentModule;
000593121008           endif;
000594121008         endif;
000595121009
000596121008         select;
000597121011           when programData.debugData.elements(index).viewType = STATEMENT_VIEW;
000598121008             viewIndex.statement   = index;
000599121008             viewIndex.statementId = viewId;
000600121011           when programData.debugData.elements(index).viewType = TEXT_VIEW;
000601121009             viewIndex.text   = index;
000602121009             viewIndex.textId = viewId;
000603121011           when programData.debugData.elements(index).viewType = LISTING_VIEW;
000604121009             viewIndex.listing   = index;
000605121009             viewIndex.listingId = viewId;
000606121008         endsl;
000607121008       endfor;
000608121009
000609121009       if (currentModule <> *blanks);
000610121011         //Add the new element
000611121011         tempIndex  = programData.viewIndexListSize;
000612121011         tempIndex += 1;
000613121011         programData.viewIndexList(tempIndex) = viewIndex;
000614121011         programData.viewIndexListSize        = tempIndex;
000615121009       endif;
000616121008      /end-free
000617121008     p                 e
000618121008      //_______________________________________________________________________
000619121008
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
000689120820     /**
000690121009      * \brief mapViewPosition: maps lines between lines
000691120820      *
000692120820      * <p>
000693120821      *  This procedure maps a line number between different views
000694120820      * </p>
000695120820      *
000696120821      * \param origin view
000697120821      * \param origin line
000698120821      * \param destination view
000699120821      * \return destination view corresponding line
000700120820      */
000701121009     p mapViewPosition...
000702121009     p                 b
000703120720     d                 pi            10i 0
000704121008     d fromView                      10i 0 const
000705121008     d fromView_Line                 10i 0 const
000706121008     d toView                        10i 0 const
000707120720     d
000708120720     d mapViewDta      ds                  likeds(mapViewData_type)
000709120720     d                                     based(mapViewPtr)
000710120720     d mapViewLen      s             10i 0
000711120720     d column          s             10i 0 inz(1)
000712120721     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
000713120720     d tempBuffer      s          65535a
000714120720
000715120720      /free
000716120720       monitor;
000717121009         mapViewLen    = %size(mapViewData_type);
000718120721         errorDS.Bytes = 0;
000719120720
000720120720         MapViewPositionAPI(tempBuffer
000721120720                           :mapViewLen
000722120720                           :fromView
000723120720                           :fromView_Line
000724120720                           :column
000725120720                           :toView
000726120720                           :errorDS);
000727120720
000728120720         mapViewPtr = %addr(tempBuffer);
000729120720         return mapViewDta.elements(1).lineNumber;
000730120720       on-error;
000731120720         CEXCEPTION_catchException();
000732120721         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG':
000733120720           'Error mapping position');
000734120720       endmon;
000735120720      /end-free
000736120720     p                 e
000737120720      //_______________________________________________________________________
000738120720
000739120820     /**
000740120820      * \brief TRCHANDLER_retrieveTextLineFromView: retrieve the line of code
000741120820      *
000742120820      * <p>
000743120820      *  This procedure retrieve the code line of the debug view identified
000744120820      *  by viewId
000745120820      * </p>
000746120820      *
000747120820      * \param id of the code view
000748120820      * \param number of the current line in the view
000749120820      * \return structure containing line data
000750120820      */
000751120720     p TRCHANDLER_retrieveTextLineFromView...
000752120720     p                 b                   export
000753120720     d                 pi                  likeds(codeLine_type)
000754120720     d viewId                        10i 0 const
000755120720     d lineNumber                    10i 0 const
000756121004     d viewType                      10a   const
000757121004     d
000758120720     d
000759120720     d lineCount       s             10i 0 inz(1)
000760120720     d
000761121004      //Data structure of the code view line
000762121004     d codeViewLine    ds                  qualified based(codeViewLinePtr)
000763120720     d  bytesReturned                10i 0
000764120720     d  bytesAvailabl                10i 0
000765120720     d  linesReturned                10i 0
000766120720     d  lineLength                   10i 0
000767120720     d  sequenceNumbr                12a
000768120720     d  lineText                    255a
000769121004
000770121004      //Data structure of the listing View Line
000771121004     d listingViewLine...
000772121004     d                 ds                  qualified based(listingViewLinePtr)
000773121004     d  bytesReturned                10i 0
000774121004     d  bytesAvailabl                10i 0
000775121004     d  linesReturned                10i 0
000776121004     d  lineLength                   10a
000777121004     d  lineText                    255a
000778120720     d
000779120720     d buffer          s          65535a
000780120721     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
000781120720     d codeLine        ds                  likeds(codeLine_type)
000782121004     d codeBeggining   s             10i 0
000783121217     d sequenceBegin   s             10i 0
000784121217     d sequenceEnding  s             10i 0
000785121217
000786120720      /free
000787120720       monitor;
000788120721         errorDS.Bytes = 0;
000789120720         RetrieveViewTextAPI( buffer
000790120720                            : %size(buffer)
000791120720                            : viewId
000792120720                            : lineNumber
000793120720                            : lineCount
000794120720                            : 255
000795120720                            : errorDs);
000796120720
000797121217         //Set the default value for the line
000798121217         clear codeLine;
000799121217         codeLine.text = 'Code Line unavailable';
000800121217
000801121004         select;
000802121004            when viewType = TEXT_VIEW;
000803121217              //Code lines from the text view have a well-defined
000804121217              //structure
000805121004              codeViewLinePtr = %addr(buffer);
000806121004              codeLine.sequence = %subst(codeViewLine.sequenceNumbr:1:6);
000807121004              codeLine.date     = %subst(codeViewLine.sequenceNumbr:7);
000808121004              codeLine.text     = codeViewLine.lineText;
000809121213              codeLine.origin   = CODE_FROM_SOURCE;
000810121213            when viewType = LISTING_VIEW;
000811121217              //The lines of code in the listing view dont have a separate
000812121217              //field for the sequence. This sequence is variable size so
000813121217              //it must look for the first space (corresponding column 6)
000814121217              //or first '*' and retrieve the sequence with the previous
000815121217              //characters of that column
000816121004              listingViewLinePtr = %addr(buffer);
000817121217
000818121217              //Find the boundaries of the sequence number
000819121217              sequenceBegin  = %check(' ':listingViewLine.lineText);
000820121217              sequenceEnding = %check('0123456789':listingViewLine.lineText
000821121217                                    :sequenceBegin);
000822121217
000823121217              codeLine.sequence = %subst(listingViewLine.lineText
000824121217                                       :sequenceBegin
000825121217                                       :sequenceEnding - sequenceBegin);
000826121217
000842121217              codeLine.date  = '400101'; //Default date
000843121217              codeLine.text  = %subst(listingViewLine.lineText
000844121217                                     :sequenceEnding + 1);
000845121217              codeLine.origin= CODE_FROM_LISTING;
000857121004            other;
000858121004              clear codeLine;
000859121004              codeLine.text = 'Code Line unavailable';
000860121004         endsl;
000861121004
000862120720         return codeLine;
000863120720       on-error;
000864120720         CEXCEPTION_catchException();
000865121009         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000866121009           :'Line unavailable');
000867121004       endmon;
000868120720      /end-free
000869120720     p                 e
000870120720      //_______________________________________________________________________
000871120723
000872121009     /**
000873121009      * \brief TRCHANDLER_getCodeLine retrieve code line from text or listing
000874121009      *
000875121009      * <p>
000876121009      *  This procedure retrieves the code line from the *TEXT or
000877121009      *  *LISTTNG view
000878121009      * </p>
000879121009      *
000880121009      * \param views indexes
000881121009      * \param id of the stopped line
000882121009      * \return code line information
000883121009      */
000884121009     p TRCHANDLER_getCodeLine...
000885121009     p                 b                   export
000886121009     d                 pi                  likeds(codeLine_type)
000887121009     d viewIndex                           likeds(viewIndex_type) const
000888121009     d stoppedLine                   10i 0 const
000889121009     d codeLine        ds                  likeds(codeLine_type)
000890121009     d mappedLine      s             10i 0
000891121009
000892121009      /free
000893121009       monitor;
000894121009         clear codeLine;
000895121009         codeLine.sequence = '000000';
000896121009         codeLine.date     = *blanks;
000897121009         codeLine.text     = 'Code unavailable';
000898121009
000899121009         //First, try to retrieve the code line from the code view
000900121009         if viewIndex.textId <> -1;
000901121009           monitor;
000902121009             mappedLine = mapViewPosition(
000903121009               viewIndex.statementId
000904121009              :stoppedLine
000905121009              :viewIndex.textId);
000906121009
000907121009             codeLine = TRCHANDLER_retrieveTextLineFromView(
000908121009                    viewIndex.textId:mappedLine:TEXT_VIEW);
000909121009
000910121009             return codeline;
000911121009           on-error;
000912121009             CEXCEPTION_catchException();
000913121009             CEXCEPTION_jobPrintf('Source view not available for module ' +
000914121009               viewIndex.module);
000915121009           endmon;
000916121009         endif;
000917121009
000918121009         //If the line couldnt be retrieved, try with the listing view
000919121009         if viewIndex.listingId <> -1;
000920121009           monitor;
000921121009             mappedLine = mapViewPosition(
000922121009                 viewIndex.statementId
000923121009                :stoppedLine
000924121009                :viewIndex.listingId);
000925121009
000926121009             codeLine = TRCHANDLER_retrieveTextLineFromView(
000927121009                 viewIndex.listingId:mappedLine:LISTING_VIEW);
000928121009           on-error;
000929121009             CEXCEPTION_catchException();
000930121009             CEXCEPTION_jobPrintf('Listing view not available for module ' +
000931121009               viewIndex.module);
000932121009           endmon;
000933121009         endif;
000934121009
000935121009         return codeLine;
000936121009
000937121009       on-error;
000938121009         CEXCEPTION_catchException();
000939121009         CEXCEPTION_printStackTrace();
000940121009         return codeLine;
000941121009       endmon;
000942121009      /end-free
000943121009     p                 e
000944121009      //_______________________________________________________________________
000945121009
000946120820     /**
000947120820      * \brief TRCHANDLER_getCurrentProcedureName: retrieves the current proced.
000948120820      *
000949120820      * <p>
000950120820      *  This procedure retrieves the name of the current procedure during the
000951120820      *  stop debug event
000952120820      * </p>
000953120820      *
000954121009      * \param statement buffer pointer
000955120820      * \param identification of the statement view
000956120820      * \param current stopped line
000957120822      * \param statement line (output)
000958120820      * \return name of the procedure
000959120820      */
000960120725     p TRCHANDLER_getCurrentProcedureName...
000961120725     p                 b                   export
000962120725     d                 pi          1024a
000963121009     d stmtBufferPtr                   *   const
000964120725     d currentLine                   10i 0 const
000965120822     d stmtLine                      10i 0
000966120725     d
000967120725     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
000968121009     d bufferPtr       s               *
000969120725     d statementBuff   ds                  likeds(statementBuffer_type)
000970120725     d                                     based(bufferPtr)
000971120820     d statementInfo   ds                  likeds(statementInfo_type)
000972120820     d                                     based(statementInfoPtr)
000973120725     d procedureInfo   ds                  likeds(procedureInfo_type)
000974120725     d                                     based(procedureInfoPtr)
000975120725     d procedureNameBuffer...
000976120725     d                 s          65535a   based(procedureNameBufferPtr)
000977120725
000978120725      /free
000979120725       monitor;
000980120820         clear errorDs;
000981121009         errorDS.Bytes    = 0;
000982121009         bufferPtr        = stmtBufferPtr;
000983120820         statementInfoPtr = %addr(statementBuff)
000984120820                          + statementBuff.viewLineOffset
000985120820                          + ((currentLine - 1) * %size(statementInfo_type));
000986120820
000987121009         stmtLine = statementInfo.number;
000988120822
000989120725         procedureInfoPtr = %addr(statementBuff)
000990120820                          + statementInfo.procedureInfoOffset;
000991120725
000992120725         procedureNameBufferPtr = %addr(statementBuff)
000993120725                                + procedureInfo.procedureNameOffset;
000994120725
000995120725         return %subst(procedureNameBuffer:1:procedureInfo.procedureNameLen);
000996120725       on-error;
000997120725         CEXCEPTION_catchException();
000998120725         CEXCEPTION_printStackTrace();
000999120725         return 'MISSING INFO';
001000120725       endmon;
001001120725      /end-free
001002120725     p                 e
001003120725      //_______________________________________________________________________
001004120725
001005120820     /**
001006120820      * \brief getAllStatementsForModules: loads all of the statement views
001007120820      *
001008120820      * <p>
001009120820      *  This procedures iterates through all the modules views and loads into
001010120820      *  an array, every statement of the statement view
001011120820      * </p>
001012120820      *
001013120820      * \param structure containing the program debug data
001014120820      */
001015120817     p getAllStatementsForModules...
001016120817     p                 b                   export
001017120817     d                 pi
001018120817     d programData                         likeds(programData_type)
001019120817     d
001020120817     d errorDs         ds                  likeds(ApiError_Type) inz(*likeds)
001021120820     d stmtBuffer      ds                  likeds(statementBuffer_type)
001022120820     d                                     based(stmtBufferPtr)
001023120820     d stmtBufferLen   s             10i 0
001024120820     d
001025120820     d tempBuffer      ds                  likeds(statementBuffer_type)
001026120820     d tempBufferLen   s             10i 0 inz(8)
001027120820     d
001028120817     d index           s             10i 0
001029120817     d limit           s             10i 0
001030120820     d viewId          s             10i 0
001031120817
001032120817      /free
001033120817       monitor;
001034120817         programData.statementBufferArray = *NULL;
001035120817         limit = programData.debugData.numberOfElements;
001036120817
001037120817         //Get the statement for each of the modules
001038120817         for index = 1 to limit;
001039120817           clear errorDs;
001040120817           errorDS.Bytes = 0;
001041120820
001042120820           if programData.debugData.elements(index).viewType = STATEMENT_VIEW;
001043120820             viewId = programData.debugData.elements(index).viewNumber;
001044120820
001045120820             clear tempBuffer;
001046120820
001047120820             //Query the API to retrieve the size that must be
001048120820             //allocated for the buffer
001049120820             RetrieveStatementViewAPI(tempBuffer
001050120820                :tempBufferLen:viewId:1:0:errorDS);
001051120820
001052120820             //Alloc the right size
001053120820             stmtBufferLen = tempBuffer.bytesAvailable;
001054120820             stmtBufferPtr = TS_Malloc(stmtBufferLen);
001055120820
001056120820             //Retrieve the data with the right buffer
001057120820             RetrieveStatementViewAPI(stmtBuffer:stmtBufferLen
001058120820                                     :viewId:1:0:errorDS);
001059120821
001060120820             programData.statementBufferArray(index) = stmtBufferPtr;
001061120820           else;
001062120820             programData.statementBufferArray(index) = *NULL;
001063120820           endif;
001064120817         endfor;
001065120817       on-error;
001066120817         CEXCEPTION_catchException();
001067120817         CEXCEPTION_printStackTrace();
001068120820
001069120820         if stmtBufferPtr <> *NULL;
001070120820           monitor;
001071120820             TS_Free(stmtBufferPtr);
001072120820           on-error;
001073120820
001074120820           endmon;
001075120820         endif;
001076120820
001077120817         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
001078120817           :'Could not retrieve the statment view');
001079120817       endmon;
001080120817      /end-free
001081120817     p                 e
001082120817      //_______________________________________________________________________
001083120817
001084120802     /**
001085120802      * \brief TRCHANDLER_setCaseId: Sets the current case id for the trace
001086120802      *
001087120802      * <p>
001088120802      *  This procedure sets the current case id in the exchange data area.
001089120802      *  The exchange data area is used to related a trace record with an
001090120802      *  test case. The application executing the test cases is responsible
001091120802      *  for calling this procedure with the appropiate test case
001092120802      * </p>
001093120802      *
001094120802      * \param case id to set in the data area
001095120802      * \param library of the exchange data area
001096120802      * \param name of the exchange data area
001097120802      */
001098120726     p TRCHANDLER_setCaseId...
001099120725     p                 b                   export
001100120725     d                 pi
001101120802     d caseId                        20a   const
001102120726     d dtaaraLib                     10a   const
001103120726     d dtaaraName                    10a   const
001104120726
001105120725      /free
001106120725       monitor;
001107120726         exchangeArea = dtaaraLib + '/' + dtaaraName;
001108120726         in *lock exchange;
001109120802         exchange.value = caseId;
001110120726         out exchange;
001111120726       on-error;
001112120725         CEXCEPTION_catchException();
001113120725         CEXCEPTION_printStackTrace();
001114120726
001115120726         unlock exchange;
001116120726
001117120725         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
001118120725           :'Could not set the correlationId');
001119120725       endmon;
001120120725      /end-free
001121120725     p                 e
001122120725      //_______________________________________________________________________
001123120731
001124120802     /**
001125120802      * \brief TRCHANDLER_submitDebugCommand: Submits a debug command
001126120802      *
001127120802      * <p>
001128120802      *  This procedure submits a debug command to the debug session.
001129120802      *  A debug command can be: 'STEP OUTF', 'STEP INTO', and others.
001130120802      * </p>
001131120802      *
001132120802      * \param command to submit
001133120802      * \param identification of the compiler used for the current debug view
001134120802      * \param identification of the debug view to submit the command
001135120802      */
001136120731     p TRCHANDLER_submitDebugCommand...
001137120731     p                 b                   export
001138120731     d                 pi
001139120731     d command                      255a   const
001140120731     d compilerId                    20a   const
001141120731     d viewId                        10i 0 const
001142120731     d
001143120731     d buffer          s          65535a
001144120731     d inputBuffer     s            255a
001145120820     d
001146120731     d errorDs         ds                  likeds(ApiError_Type)
001147120820     d
001148120731     d receiverData    ds                  qualified based(receiverPtr)
001149120731     d  bytesReturned                10i 0
001150120731     d  bytesAvailabl                10i 0
001151120731     d  entryCount                   10i 0
001152120731     d  resultArray                        dim(1) likeds(result_Type)
001153120731     d
001154120820     d result_Type     ds                  qualified template
001155120731     d  resultKind                   10i 0
001156120731     d  stepCount                    10i 0
001157121001     d  reserved                      4a
001158120731
001159120731      /free
001160120731       monitor;
001161120731         inputBuffer   = command;
001162121001         errorDs.Bytes = 0;
001163120731         SubmitDebugCommandAPI(buffer
001164120731                              :%len(buffer)
001165120731                              :viewId
001166120731                              :inputBuffer
001167120731                              :%len(%trim(command))
001168120731                              :compilerId
001169120731                              :errorDs);
001170121001
001171120731         receiverPtr = %addr(buffer);
001172121001
001173120731         if receiverData.bytesReturned > 0 and receiverData.entryCount > 0;
001174120731           CEXCEPTION_jobPrintf('Debug command sucessful');
001175120731         else;
001176120731           CEXCEPTION_jobPrintf('Debug command failed');
001177120731         endif;
001178120731       on-error;
001179120731         CEXCEPTION_catchException();
001180120731         CEXCEPTION_printStackTrace();
001181120731       endmon;
001182120731      /end-free
001183120731     p                 e
001184120802      //_______________________________________________________________________
001185121011
001186121011     /**
001187121011      * \brief TRCHANDLER_getProgramInList: gets a program from the list
001188121011      *
001189121011      * \param index of the list
001190121011      * \return program data structure
001191121011      */
001192121011     p TRCHANDLER_getProgramInList...
001193121011     p                 b                   export
001194121011     d                 pi                  likeds(programData_type)
001195121011     d index                         10i 0 const
001196121011
001197121011      /free
001198121011       if index > *zero and index <= programInDebug_ListSize;
001199121011         return programInDebug_List(index);
001200121011       else;
001201121011         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG':'Invalid index');
001202121011       endif;
001203121011      /end-free
001204121011     p                 e
001205121011      //_______________________________________________________________________
