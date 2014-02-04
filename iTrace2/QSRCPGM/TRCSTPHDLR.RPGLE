000102120817     /**
000103120722      * \brief TRCSTPHDLR: Implements the stop handler of the debugger
000104120722      *
000105120722      * <p>
000106120722      *  This module contains the implementation of the stop handler
000107120722      *  for the program tracing session
000108120722      * </p>
000109120722      *
000110120722      * \author Isaac Ramirez Herrera
000111120722      * \date   July 19, 2012
000112120722      * \rev    1.0
000113120722      * \notes  Based on the code provided by Steve Kilner and
000114120722      *         the source included in IBM i V5R4 in the file
000115120722      *         QUSRTOOLS/QATTSYSC(TTERCP)
000116120722      *
000117120722      * IMPORTANT: if this proram is recompiled and binded, it must NOT
000118120722      *            contain any debug information, otherwise the tracer
000119120730      *            will fail. This rule also applies to *SRVPGM and *PGMS
000120120730      *            called by this program.
000121120722      **/
000122120719
000123120719     h datedit(*ymd)
000124120722     h option(*nodebugio:*noxref:*srcstmt)
000125120723     h bnddir('TRACEBNDD')
000126120723     h dftactgrp(*NO)
000127120723     h actgrp('TRACEPGM')
000128120720
000129121028      /include qsrctxt,trcenvvars
000130121028      /include qsrctxt,tracetypes
000131121028      /include qsrctxt,traceconst
000132121028      /include qsrctxt,trcrules
000133121028      /include qsrctxt,debugrapis
000134121028      /include qsrctxt,trchandler
000136121028      /include qsrctxt,cexception
000137121028      /include qsrctxt,csqlutil
000138121028      /include qsrctxt,cstringutl
000139121028      /include qsrctxt,tracedata
000140121028      /include qsrctxt,llist_h
000141120720
000142120801      //Trace types
000143120801     d TRACE_ALL       c                   const('*ALL')
000144120801     d TRACE_FLOWCHG   c                   const('*FLOWCHG')
000145120801
000146120720     d STEP_CONDITION  c                   const(3)
000148120816
000149120723     d receiverDta_Format...
000150120729     d                 ds                  qualified template
000151120723     d watchNumber                   10i 0
000152120723     d stopInfoOffset                10i 0
000153120723     d watchIntrrpOff                10i 0
000154120723
000169120723      ///////////////////////////////////////////////////////
000170120723      // Global Variables
000171120723      ///////////////////////////////////////////////////////
000172120723
000176120726     d g_dtaaraName    s             21a
000177120726     d exchangeDtaara...
000178120726     d                 ds                  dtaara(*VAR:g_dtaaraName) qualified
000179120726     d  value                        20a
000180120726
000187120720      ///////////////////////////////////////////////////////
000188120720      // Prototype declaration
000189120720      ///////////////////////////////////////////////////////
000190120720
000193120723     d writeTraceData  pr
000194120725     d programLib                    10a   value
000195120725     d programName                   10a   value
000196121001     d programType                   10a   value
000197120725     d moduleName                    10a   value
000198120725     d procedureName               1024a   value
000199120725     d codeLine                            likeds(codeLine_type) value
000200120821     d stmtNumber                    10i 0 value
000201120821
000202120802     d checkWriteTrace...
000203120802     d                 pr              n
000204120801     d programName                         const likeds(programName_type)
000205120801     d moduleName                    10a   const
000206120801     d programType                   10a   const
000207120801     d procedureName               1024a   const
000208120801
000214120723     d TRCSTPHDLR_HandleStop...
000215120723     d                 pr                  extpgm('TRCSTPHDLR')
000216120720     d  programName                        const likeds(programName_type)
000217120720     d  programType                  10a   const
000218120720     d  moduleName                   10a   const
000219120720     d  stopReason                   10a   const
000220120723     d  receiverDta                4096a
000221120720     d  entryCount                   10i 0 const
000222120720     d  messageDta                 4096    const
000223120719
000224120820      ///////////////////////////////////////////////////////
000225120720      // Procedure definition
000226120720      ///////////////////////////////////////////////////////
000227120720
000228120723     d TRCSTPHDLR_HandleStop...
000229120723     d                 pi
000230120720     d  programName                        const likeds(programName_type)
000231120720     d  programType                  10a   const
000232120720     d  moduleName                   10a   const
000233120720     d  stopReason                   10a   const
000234120723     d  receiverDta                4096a
000235120720     d  entryCount                   10i 0 const
000236120720     d  messageDta                 4096    const
000237120720     d
000238121011     d program_data    ds                  likeds(programData_type) inz(*likeds)
000240120720     d index           s             10i 0
000245120720     d
000246120720     d StopInfo        ds                  qualified based(StopInfoPtr)
000247120720     d  lineNumber                   10i 0
000248120720     d
000249120720     d tempProgramName...
000250120720     d                 ds                  likeds(programName_type)
000251120730     d tempProgramType...
000252120730     d                 s                   like(programType)
000258120725     d procedureName   s           1024a
000259120821     d stmtLine        s             10i 0
000265121011     d programIndex    s             10i 0
000266121011     d viewIndex       ds                  likeds(viewIndex_type)
000267140110     d stmtBreakLine   s             10i 0
000268140110     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
000269120720      /free
000270120723       monitor;
000271140110         dsply 'CALLED';
000272140110
000273121011         reset program_data;
000274121011
000275120802         //Get the current stopped line
000276120802         StopInfoPtr = %addr(receiverDta);
000277120730
000278120802         //The stop reason must be a 'step' action
000279140110         dsply stopReason;
000280140110
000281120802         if %subst(stopReason:STEP_CONDITION:1) <> '1';
000282140110           dsply stopReason;
000283120802           return;
000284120802         endif;
000285120721
000286120802         tempProgramName = programName;
000287120802         tempProgramType = programType;
000288120730
000300120802         //Look for the program data in the list
000301121011         programIndex = TRCHANDLER_findProgramDebugData(
000302120802            tempProgramName:tempProgramType);
000303120721
000304121011         if (programIndex = *ZERO);
000308121011           program_data = TRCHANDLER_prepareForDebug(tempProgramName
000310120802              :tempProgramType);
000316121011         else;
000317121011           program_data = TRCHANDLER_getProgramInList(programIndex);
000318121011         endif;
000319120721
000323121008         //Search the view id index for the current module
000324121011         for index = 1 to program_data.viewIndexListSize;
000325121011           viewIndex = program_data.viewIndexList(index);
000326121008           if (moduleName = viewIndex.module);
000328121008             leave;
000329121008           endif;
000348120802         endfor;
000349120721
000355121004         //Retrieve the name of the current procedure
000359121011         procedureName = TRCHANDLER_getCurrentProcedureName(
000360121011              program_data.statementBufferArray(viewIndex.statement)
000361121011              :StopInfo.lineNumber
000363121011              :stmtLine);
000364120821
000365121011         if checkWriteTrace(tempProgramName:moduleName
000366121011                           :programType:procedureName);
000367121011           monitor;
000448121011             writeTraceData(tempProgramName.library
000449121011               :tempProgramName.name
000450121011               :programType
000451121011               :moduleName
000452121011               :procedureName
000453121011               :TRCHANDLER_getCodeLine(viewIndex:StopInfo.lineNumber)
000454121011               :stmtLine);
000462121011           on-error;
000463121004             CEXCEPTION_catchException();
000464121004             CEXCEPTION_printStackTrace();
000465121004             CEXCEPTION_jobPrintf('Error while recovering line');
000466121004           endmon;
000467121011         endif;
000468120730
000469140110           errorDs.Bytes = 0;
000470140110          AddBreakpointAPI(
000471140110                          viewIndex.statementId
000472140110                          :24
000473140110                          :1
000474140110                          :stmtBreakLine
000475140110                          :errorDS );
000476140110
000477120802         //Check if the stopped program is registered in the step into the
000478120802         //exceptions. If the program must not be trace, execute a step out
000479120802         //debug action
000480140110       //  if TRCRULES_doStepInto(tempProgramName.library
000481140110       //                        :tempProgramName.name
000482140110       //                        :procedureName);
000483140110       //    TRCHANDLER_step(viewIndex.statementId:*ON:1);
000484140110       //  else;
000485140110       //    //Do a step out
000486140110       //    TRCHANDLER_submitDebugCommand('STEP OUTOF'
000487140110       //        :program_data.debugData.elements(viewIndex.statement).compilerId
000488140110       //        :viewIndex.statementId);
000489140110       //  endif;
000490120730
000491120802         return;
000492120720       on-error;
000493120720         CEXCEPTION_catchException();
000494120720         CEXCEPTION_printStackTrace();
000495120720         return;
000496120720       endmon;
000497120720      /end-free
000498120723      //_______________________________________________________________________
000499120723
000509120816     /**
000510120816      * \brief checkWriteTrace: check if the line must be written
000511120816      *
000512120816      * <p>
000513120816      *   Check if the line should be written down according to the
000514120816      *   trace type: *ALL     (write all lines)
000515120816      *               *FLOWCHG (write line only if a change on the library,
000516120816      *                        program, module or procedure is detected)
000517120816      * </p>
000518120816      *
000519120816      * \param name of the program
000520120816      * \param name of the module
000521120816      * \param name of the procedure
000522120816      *
000523120816      * \return *ON  = Write trace
000524120816      *         *OFF = Don't write trace
000525120816      */
000526120802     p checkWriteTrace...
000527120802     p                 b
000528120801     d                 pi              n
000529120801     d programName                         const likeds(programName_type)
000530120801     d moduleName                    10a   const
000531120801     d programType                   10a   const
000532120801     d procedureName               1024a   const
000533120801     d
000534120801     d oldProgramName  s             10a
000535120801     d oldProgramLib   s             10a
000536120801     d oldProgramType  s             10a
000537120801     d oldModule       s             10a
000538120801     d oldProcedure    s           1024a
000539120802     d saveFlowChange  s               n   inz(*OFF)
000540120802     d doWriteTrace    s               n   inz(*ON)
000541120802
000542120801      /free
000543120802       //Special case: this procedure is PEP for any service program
000544120802       //this shouldnt be considered as a flow change nor be written
000545120802       //in the tracedata table
000546120802       if procedureName = '_QRNI_NOMAIN';
000547120802         return *OFF;
000548120802       else;
000549120802         //Check the rules
000550121011         doWriteTrace = TRCRULES_writeTrace(programName.library
000551121011              :programName.name:procedureName);
000552120802
000553120802         //Check the trace type selected by the user
000554120802         //and save the change in the flow accordingly
000555120802         if TRCENVVARS_getTraceType() = TRACE_ALL;
000556120802           saveFlowChange = *ON;
000557120802         else;
000558120802           oldProgramLib  = TRCENVVARS_getDebuggedProgramLibrary();
000559120802           oldProgramName = TRCENVVARS_getDebuggedProgramName();
000560120802           oldProgramType = TRCENVVARS_getDebuggedProgramType();
000561120802           oldModule      = TRCENVVARS_getDebuggedModule();
000562120802           oldProcedure   = TRCENVVARS_getDebuggedProcedure();
000563120802
000564120802           //Check if the current debugged entity is different
000565120802           if %trim(oldProgramName) = %trim(programName.name) and
000566120802              %trim(oldProgramLib)  = %trim(programName.library) and
000567120802              %trim(oldProgramType) = %trim(programType) and
000568120802              %trim(oldModule)      = %trim(moduleName) and
000569120802              %trim(oldProcedure)   = %trim(procedureName);
000570120802             saveFlowChange = *OFF;
000571120802           else;
000572120802             saveFlowChange = *ON;
000573120802           endif;
000574120802         endif;
000575120802
000576120820          if saveFlowChange and doWriteTrace;
000577120802            TRCENVVARS_setDebuggedProgramLibrary(tempProgramName.library);
000578120802            TRCENVVARS_setDebuggedProgramName(tempProgramName.name);
000579120802            TRCENVVARS_setDebuggedProgramType(programType);
000580120802            TRCENVVARS_setDebuggedModule(moduleName);
000581120802            TRCENVVARS_setDebuggedProcedure(procedureName);
000582120802          endif;
000583120802
000584120802          return saveFlowChange and doWriteTrace;
000585120802       endif;
000586120801      /end-free
000587120801     p                 e
000588120801      //_______________________________________________________________________
000589120801
000590120817     /**
000591120817      * \brief writeTraceData: writes the trace data to the trace output
000592120817      *
000593120817      * <p>
000594120817      *  This procedure loads the necessary data and writes it to the
000595120817      *  output file
000596120817      * </p>
000597120817      *
000598120817      * \param name of the library of the traced program
000599120817      * \param name of the traced program
000600121001      * \param type of the traced program (srvpgm or pgm)
000601120817      * \param name of the traced module
000602120817      * \param name of the current procedure
000603120817      * \param current line of code
000604120817      */
000605120723     p writeTraceData  b
000606120723     d                 pi
000607120725     d programLib                    10a   value
000608120725     d programName                   10a   value
000609121001     d programType                   10a   value
000610120725     d moduleName                    10a   value
000611120725     d procedureName               1024a   value
000612120725     d codeLine                            likeds(codeLine_type) value
000613120821     d stmtNumber                    10i 0 value
000614120725     d
000615120816     d caseId          s             20a
000616120816
000617120723      /free
000618120816       monitor;
000619120816         //Get the case Id
000620120816         g_dtaaraName = TRCENVVARS_getExchangeDtaara();
000621120816         in *lock exchangeDtaara;
000622120816         caseId = exchangeDtaara.value;
000623120816
000625120816         //Prepare all the trace data
000626120816         TRACEDATA_clear();
000627121001         TRACEDATA_setCASEID(caseId);
000628120816         TRACEDATA_setCODEDTA(codeLine.text);
000629121001
000630121004         monitor;
000631121004           if (codeLine.date <> *blanks);
000632121004             TRACEDATA_setCODEDATE(%date(codeLine.date:*YMD0));
000633121004           else;
000634121004             TRACEDATA_setCODEDATE(%date('1940-01-01'));
000635121004           endif;
000636121004         on-error;
000637121004           TRACEDATA_setCODEDATE(%date('1940-01-01'));
000638121004         endmon;
000639121001
000640121001         TRACEDATA_setCODESEQ(codeLine.sequence);
000641120821         TRACEDATA_setSTMTNUMBER(stmtNumber);
000642120816         TRACEDATA_setJOBNAME(TRCENVVARS_getDebuggedJobName());
000643120816         TRACEDATA_setJOBNUM(TRCENVVARS_getDebuggedJobNumber());
000644120816         TRACEDATA_setJOBUSER(TRCENVVARS_getDebuggedJobUser());
000645120816         TRACEDATA_setMDLNAME(moduleName);
000646120816         TRACEDATA_setPGMLIB(programLib);
000647121001         TRACEDATA_setPGMTYPE(programType);
000648121001         TRACEDATA_setPGMNAME(programName);
000649120816         TRACEDATA_setPROCNAME(procedurename);
000650120816         TRACEDATA_setREGTIME(%timestamp());
000651120816         TRACEDATA_setTRACEID(TRCENVVARS_getTraceID());
000652120816
000653120816         //Save the information in the buffer
000654120816         TRACEDATA_writeWithCaching(*OFF);
000655120816
000656120726         unlock exchangeDtaara;
000657120726       on-error;
000658120726         CEXCEPTION_catchException();
000659120726         CEXCEPTION_printStackTrace();
000660120816
000661120816         unlock exchangeDtaara;
000662120816
000663120726         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000664120726           :'Error while writing the trace data');
000665120726       endmon;
000666120723      /end-free
000667120723     p                 e
000668120724      //_______________________________________________________________________
000669120724
