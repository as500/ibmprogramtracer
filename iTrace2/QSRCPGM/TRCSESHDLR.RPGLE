000100120722
000101120719     /**
000102120719      * \brief Trace all the executed lines in a RPGILE program
000103120719      *
000104120719      * <p>
000105120720      *  This program keep trace of all the statements executed of
000107120720      *  an specific program
000108120719      * </p>
000109120719      *
000110120719      * \author Isaac Ramirez Herrera
000111120719      * \date   July 19, 2012
000112120719      * \rev    1.0
000113120719      * \notes  Based on the code provided by Steve Kilner and
000114120719      *         the source included in IBM i V5R4 in the file
000115120719      *         QUSRTOOLS/QATTSYSC(TTERCP)
000116120719      *
000117120720      * Compilation comments:
000118120720      *   - Must use a named activation group dedicated
000119120802      *   - Must not include debug info for this program and any other
000120120802      *     software resource used by it (service program, module, etc)
000121120720      *
000122120729      * Use instructions
000123120729      *
000124120729      *   For interactive debug session follow these steps:
000125120729      *     ADDLIBLE TSX
000126120802      *     STRDBG UPDPROD(*YES)
000127120729      *     ITRACE SET(*ON) PROGRAM(LIB/PGM_TO_TRACE) ...
000128120729      *     CALL LIB/PGM_TO_TRACE
000129120729      *     ITRACE SET(*OFF)
000130120729      *     ENDDBG
000131120729      *
000132120729      *   For batch debug session follow these steps:
000133120802      *     Submit the job to debug normally
000134120802      *     Recover the number/user/name data of the job
000135120802      *     STRSRVJOB number/user/name
000136120802      *     STRDBG UPDPROD(*YES)
000137120802      *     ITRACE SET(*ON) PROGRAM(LIB/PGM_TO_TRACE) BATCHTRACE(*ON) JOBTOTRACE(number/user/name)
000138120802      *     Let the job do the intended task
000139120802      *     ITRACE SET(*OFF)
000140120802      *     ENDDBG
000141120802      *     ENDSRVJOB
000142120802      *
000150120722      * IMPORTANT: if this proram is recompiled and binded, it must NOT
000151120722      *            contain any debug information, otherwise the tracer
000152120722      *            will fail
000153120719      */
000154120719
000156120722     h option(*nodebugio:*noxref:*srcstmt)
000157120721     h bnddir('TRACEBNDD')
000158120723     h dftactgrp(*no)
000159120723     h actgrp('TRACEPGM')
000160120719
000161121028      /include qsrctxt,trchandler
000162121028      /include qsrctxt,trcenvvars
000163121028      /include qsrctxt,cexception
000164121028      /include qsrctxt,cstringutl
000165121028      /include qsrctxt,csqlutil
000166121028      /include qsrctxt,trcutil
000167121028      /include qsrctxt,trcrules
000168121028      /include qsrctxt,tracedata
000170121028      /include qsrctxt,debugrapis
000171120719
000172120725      //////////////////////////////////////////////////////
000173120725      // Constant definition
000174120725      //////////////////////////////////////////////////////
000175120725
000179120722     d STOP_HANDLER_PGM...
000180120723     d                 c                   const('TRCSTPHDLR')
000181140110
000182140110     d SEP_HANDLER_PGM...
000183140110     d                 c                   const('SRVENTHDLR')
000184121012
000185120724     d OPTION_ADD      c                   const('*ADD')
000186120724
000187120724     d OPTION_REPLACE  c                   const('*REPLACE')
000188120720
000189120725      //////////////////////////////////////////////////////
000190120725      // Global Variables
000191120725      //////////////////////////////////////////////////////
000192120725
000193120725     d psds           sds                  qualified
000194121012     d  pgm_library           81     90
000195120725     d  job_name             244    253
000196120725     d  job_user             254    263
000197120725     d  job_num              264    269s 0
000198120725
000199120719      //////////////////////////////////////////////////////
000200120719      // Prototype declaraion
000201120729      //////////////////////////////////////////////////////
000202120724
000203120723     d TRCSESHDLR_TraceSessionHandler...
000204120723     d                 pr                  extpgm('TRCSESHDLR')
000205120724     d  set                          10a   const
000206120724     d  program                      20a   const
000207120801     d  pgmType                      10a   const
000208120801     d  traceType                    10a   const
000209120724     d  outFile                      20a   const
000210120724     d  outFileOpt                   10a   const
000211120726     d  trcdtaara                    20a   const
000212120724     d  batchTrace                   10a   const
000213120724     d  jobtotrace                   26a   const
000215120719
000216120802     d cleanup         pr
000217120802
000221120726     d preparaDtaara...
000222120726     d                 pr
000223120726     d trcdtaara                     20a   const
000224120726
000226120724     d prepareOutPutFile...
000227120724     d                 pr
000228120724     d fileName                      20a   const
000229120724     d options                       10a   const
000230120724
000231120724     d saveDebuggedJob...
000232120724     d                 pr
000233120724     d isBatch                       10a   const
000234120724     d jobToTrace                    26a   const
000235120724
000236120724     d executeCommand...
000237120724     d                 pr              n
000238120724     d command                      500a   const varying
000239120724
000240120719      //////////////////////////////////////////////////////
000241120719      // Procedure definition
000242120719      //////////////////////////////////////////////////////
000243120719
000244120723     d TRCSESHDLR_TraceSessionHandler...
000245120720     d                 pi
000246120724     d  set                          10a   const
000247120719     d  program                      20a   const
000248120801     d  pgmType                      10a   const
000249120801     d  traceType                    10a   const
000250120724     d  outFile                      20a   const
000251120724     d  outFileOpt                   10a   const
000252120726     d  trcdtaara                    20a   const
000253120724     d  batchTrace                   10a   const
000255120724     d  jobtotrace                   26a   const
000258120726     d
000259120722     d stopHandlerPgm  ds                  qualified
000260120722     d  name                         10a
000261120722     d  library                      10a
000262140110     d
000263140110     d sepHandlerPgm   ds                  qualified
000264140110     d  name                         10a
000265140110     d  library                      10a
000266140110     d
000267140110     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)
000268120801
000269120719      /free
000270120721       monitor;
000271120721         select;
000272120724           when set = '*ON';
000273120722             stopHandlerPgm.name    = STOP_HANDLER_PGM;
000274121012             //The stopHandler MUST be in the same library as the
000275121012             //this program (TRCSESHDLR)
000276121012             stopHandlerPgm.library = psds.pgm_library;
000277120722
000278120802             //Load the rules
000279140110             TRCRULES_loadRules();
000280120802
000281120801             //Save the traceType on the environment
000282140110             TRCENVVARS_setTraceType(traceType);
000283120801
000284120726             //Prepare the data area
000285140110             preparaDtaara(trcdtaara);
000286120726
000287120724             //Create the output file
000288120724             prepareOutPutFile(outFile:outFileOpt);
000289120724
000290120724             //save the trace session id
000291120816             TRCENVVARS_setTraceID(TRACEDATA_getNextTraceId());
000292120724
000293120724             //Save the job being debugged
000294140110             saveDebuggedJob(batchTrace:jobToTrace);
000295120724
000296120724             //Start the debugging session
000297140110             //TRCHANDLER_startSourceDebug(program:pgmType:stopHandlerPgm);
000298140110             TRCHANDLER_startSEPMonitor(program:pgmType:stopHandlerPgm);
000299140110
000300140110             //Register SEPStopHandler
000301140110             //RegisterServiceEntyPointAPI(SEP_HANDLER_PGM:errorDS);
000303140110
000304120816             //Clear trace data
000305121001             TRACEDATA_clear();
000306120816             TRACEDATA_clearCache();
000307120816
000308120731             TRCUTIL_sendProgramMessage('Trace started successfully');
000309120731           when set = '*OFF';
000310120802             cleanup();
000311120731             TRCUTIL_sendProgramMessage('Trace ended successfully');
000312120721           other;
000313120721             CEXCEPTION_jobPrintf('Unsupported option');
000314120721         endsl;
000315120721       on-error;
000316120721         CEXCEPTION_catchException();
000317120721         CEXCEPTION_printStackTrace();
000318120802         cleanup();
000319120731         TRCUTIL_sendProgramMessage('Errors ocurred during the execution of +
000320120731           the program. Check Joblog');
000321120731       endmon;
000322120721
000323120719       *inlr = *on;
000324120719       return;
000325120719      /end-free
000326120719      //_______________________________________________________________________
000327120719
000328120816     /**
000329120816      * \brief cleanup: release all resources an initialize the environment
000330120816      *
000331120816      * <p>
000332120816      *  This procedure releases all previously allocated resources and
000333120816      *  initialize the environment values
000334120816      * </p>
000335120816      *
000336120816      */
000337120802     p cleanup         b
000338120802
000339120802      /free
000340120816       TRACEDATA_flushRecordCache();
000341120802       TRCHANDLER_tearDownTrace();
000342120802       TRCENVVARS_clear();
000343120802       TRCRULES_destroy();
000344120802      /end-free
000345120802     p                 e
000346120802      //_______________________________________________________________________
000347120802
000360120726     p preparaDtaara...
000361120726     p                 b
000362120726     d                 pi
000363120726     d trcdtaara                     20a   const
000364120726     d dtaaraLib       s             10a
000365120726     d dtaaraName      s             10a
000366120726
000367120726      /free
000368120726       monitor;
000369120726         dtaaraName = %subst(trcdtaara:1:10);
000370120726         dtaaraLib  = %subst(trcdtaara:11:10);
000371120726
000372120726         if dtaaraLib = 'QTEMP';
000373120726           CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000374120726           :'Must use a library different than QTEMP');
000375120726         endif;
000376120726
000377120726         //If the data area doesn't exist, create it
000378120726         if not (executeCommand(CSTRINGUTL_parse(
000379120726                 'CHKOBJ OBJ(&1/&2) OBJTYPE(*DTAARA)'
000380120726                 :%trim(dtaaraLib):%trim(dtaaraName))));
000381120726
000382120726           //Create the dataara
000383120726           if not executeCommand(CSTRINGUTL_parse('CRTDTAARA DTAARA(&1/&2) +
000384120729               TYPE(*CHAR) LEN(20)':%trim(dtaaraLib):%trim(dtaaraName)));
000385120726
000386120726             CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000387120726                :'Error creating the data area');
000388120726           endif;
000389120726         endif;
000390120726
000391120726        TRCENVVARS_setExchangeDtaara(%trim(dtaaraLib) + '/'
000392120726                                    + %trim(dtaaraName));
000393120726       on-error;
000394120726         CEXCEPTION_catchException();
000395120726         CEXCEPTION_printStackTrace();
000396120726         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000397120726           :'Error preparing exchange data area');
000398120726       endmon;
000399120726      /end-free
000400120726     p                 e
000401120726      //_______________________________________________________________________
000402120726
000403121008     /**
000404121008      * \brief prepareOutPutFile: prepare the trace output file
000405121008      *
000406121008      * <p>
000407121008      *  This procedure prepares the output file of the trace session.
000408121008      *  The preparation includes deleting all data if the parameter
000409121008      *  specified it
000410121008      * </p>
000411121008      *
000412121008      * \param qualified name of the file
000413121008      * \param indicate if the file must be cleared or not
000414121008      * \return
000415121008      */
000445120724     p prepareOutPutFile...
000446120724     p                 b
000447120724     d                 pi
000448120724     d file                          20a   const
000449120724     d options                       10a   const
000450120724     d
000451120724     d fileExist       s               n   inz(*on)
000452120724     d sqlstmt         s           5000a
000453120724
000454120724      /free
000455120724       monitor;
000456120725         TRCENVVARS_setOutFileName(%subst(file:1:10));
000457120725         TRCENVVARS_setOutFileLib(%subst(file:11:10));
000458120725
000471120724         if options = OPTION_REPLACE;
000472120816           TRACEDATA_deleteAll();
000489120816         endif;
000490120724       on-error;
000491120724         CEXCEPTION_catchException();
000492120724         CEXCEPTION_printStackTrace();
000493120725         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000494120724           :'Error while preparing output file');
000495120724       endmon;
000496120724      /end-free
000497120724     p                 e
000498120724      //_______________________________________________________________________
000499120724
000500121008     /**
000501121011      * \brief executeCommand: executes a CL command
000502121008      *
000507121011      * \param command to execute
000508121011      * \return indicator of the statucs of command execution
000509121008      */
000510120724     p executeCommand...
000511120724     p                 b
000512120724     d                 pi              n
000513120724     d command                      500a   const varying
000514120724     d
000515120724     d QCMDEXC         pr                  extpgm('QCMDEXC')
000516120724     d  command                     500a   const
000517120724     d  length                       15p 5 const
000518120724
000519120724
000520120724      /free
000521120724       monitor;
000522120724         QCMDEXC(%trim(command):%len(%trim(command)));
000523120724         return *on;
000524120724
000525120724       on-error;
000526120724         CEXCEPTION_catchException();
000527120724         CEXCEPTION_printStackTrace();
000528120724         return *off;
000529120724       endmon;
000530120724      /end-free
000531120724     p                 e
000532120724      //________________________________________________________________________
000533120724
000534121008     /**
000535121008      * \brief saveDebuggedJob: saves the job information in the environment
000536121008      *
000537121008      * <p>
000538121008      *  This procedure saves the debugged job information in the environment
000539121008      *  variables
000540121008      * </p>
000541121008      *
000542121008      * \param indicates if the debugged job is batch
000543121008      * \param job information
000544121008      */
000545120724     p saveDebuggedJob...
000546120725     p                 b
000547120724     d                 pi
000548120724     d isBatch                       10a   const
000549120724     d jobToTrace                    26a   const
000550120724
000551120724      /free
000552120729       if %trim(isBatch) = '*ON';
000553120725         //Save the indicated job as the job to be debugged.
000554120729         TRCENVVARS_setDebuggedJobName(%subst(jobToTrace:1:10));
000555120729         TRCENVVARS_setDebuggedJobUser(%subst(jobToTrace:11:10));
000556120729         TRCENVVARS_setDebuggedJobNumber(%subst(jobToTrace:21:6));
000557120725       else;
000558120725         //Save the job from the PSDS as the job that is going to be debugged
000559120725         TRCENVVARS_setDebuggedJobNumber(%char(psds.job_num));
000560120725         TRCENVVARS_setDebuggedJobName(psds.job_name);
000561120725         TRCENVVARS_setDebuggedJobUser(psds.job_user);
000562120725       endif;
000563120724      /end-free
000564120724     p                 e
000565120724      //________________________________________________________________________
000566120726
