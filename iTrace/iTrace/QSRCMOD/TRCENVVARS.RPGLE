000100120724
000101120724     h nomain
000102120724     h option(*srcstmt:*nodebugio)
000103120724
000104121028      /include qsrctxt,trcenvvars
000106120724
000108120724     d outPutFile_Type...
000109120801     d                 ds                  qualified template
000110120724     d  fileName                     10a
000111120724     d  libName                      10a
000112120724
000113120801     d job_Type        ds                  qualified template
000114120724     d  number                        6a
000115120724     d  user                         10a
000116120724     d  name                         10a
000117120724
000118120801     d debuggedPgm_Type...
000119120801     d                 ds                  qualified template
000120120801     d  programLib                   10a
000121120801     d  programName                  10a
000122120801     d  programType                  10a
000123120801     d  module                       10a
000124120801     d  procedure                  1024a
000125120801
000126120724     d environment     ds                  qualified
000127120724     d  traceId                      10i 0
000128120724     d  outputFile                         likeds(outPutFile_Type)
000129120724     d  debuggedJob                        likeds(job_Type)
000130120726     d  exchangeDtaara...
000131120726     d                               21a
000132120801     d  traceType                    10a
000133120801     d  debuggedPgm                        likeds(debuggedPgm_Type)
000136120724
000137120724      //////////////////////////////////////////////////////////////////////
000138120724      // Procedure definition
000139120724      //////////////////////////////////////////////////////////////////////
000140120724
000141120801     p TRCENVVARS_clear...
000142120801     p                 b                   export
000143120801
000144120801      /free
000145120801       clear environment;
000146120801      /end-free
000147120801     p                 e
000148120801      //_______________________________________________________________________
000149120801
000150120801
000151120724     p TRCENVVARS_setTraceID...
000152120724     p                 b                   export
000153120724     d                 pi
000154120724     d ptraceId                      10i 0 const
000155120724
000156120724      /free
000157120724       environment.traceID = pTraceId;
000158120724      /end-free
000159120724     p                 e
000160120724      //_______________________________________________________________________
000161120724
000162120724     p TRCENVVARS_getTraceID...
000163120724     p                 b                   export
000164120724     d                 pi            10i 0
000165120724
000166120724      /free
000167120724       return environment.traceID;
000168120724      /end-free
000169120724     p                 e
000170120724      //_______________________________________________________________________
000171120724
000172120724     p TRCENVVARS_setOutFileName...
000173120724     p                 b                   export
000174120724     d                 pi
000175120724     d fileName                      10a   const
000176120724
000177120724      /free
000178120724       environment.outPutFile.fileName = fileName;
000179120724      /end-free
000180120724     p                 e
000181120724      //_______________________________________________________________________
000182120724
000183120724     p TRCENVVARS_getOutFileName...
000184120724     p                 b                   export
000185120724     d                 pi            10a
000186120724
000187120724      /free
000188120724       return environment.outPutFile.fileName;
000189120724      /end-free
000190120724     p                 e
000191120724      //_______________________________________________________________________
000192120724
000193120724     p TRCENVVARS_getOutFileLib...
000194120724     p                 b                   export
000195120724     d                 pi            10a
000196120724
000197120724      /free
000198120724       return environment.outPutFile.libName;
000199120724      /end-free
000200120724     p                 e
000201120724      //_______________________________________________________________________
000202120724
000203120724     p TRCENVVARS_setOutFileLib...
000204120724     p                 b                   export
000205120724     d                 pi
000206120724     d libName                       10a   const
000207120724
000208120724      /free
000209120724       environment.outPutFile.libName = libName;
000210120724      /end-free
000211120724     p                 e
000212120724      //_______________________________________________________________________
000213120724
000214120724     p TRCENVVARS_setDebuggedJobNumber...
000215120724     p                 b                   export
000216120724     d                 pi
000217120724     d jobNumber                      6a   const
000218120724
000219120724      /free
000220120724       environment.debuggedJob.number = jobNumber;
000221120724      /end-free
000222120724     p                 e
000223120724      //_______________________________________________________________________
000224120724
000225120724     p TRCENVVARS_getDebuggedJobNumber...
000226120724     p                 b                   export
000227120724     d                 pi             6a
000228120724
000229120724      /free
000230120724       return environment.debuggedJob.number;
000231120724      /end-free
000232120724     p                 e
000233120724      //_______________________________________________________________________
000234120724
000235120724     p TRCENVVARS_setDebuggedJobName...
000236120724     p                 b                   export
000237120724     d                 pi
000238120724     d jobName                       10a   const
000239120724
000240120724      /free
000241120724       environment.debuggedJob.name = jobName;
000242120724      /end-free
000243120724     p                 e
000244120724      //_______________________________________________________________________
000245120724
000246120724     p TRCENVVARS_getDebuggedJobName...
000247120724     p                 b                   export
000248120724     d                 pi            10a
000249120724
000250120724      /free
000251120724       return environment.debuggedJob.name;
000252120724      /end-free
000253120724     p                 e
000254120724      //_______________________________________________________________________
000255120724
000256120724     p TRCENVVARS_setDebuggedJobUser...
000257120724     p                 b                   export
000258120724     d                 pi
000259120724     d jobUser                       10a   const
000260120724
000261120724      /free
000262120724       environment.debuggedJob.user = jobUser;
000263120724      /end-free
000264120724     p                 e
000265120724      //_______________________________________________________________________
000266120724
000267120724     p TRCENVVARS_getDebuggedJobUser...
000268120724     p                 b                   export
000269120724     d                 pi            10a
000270120724
000271120724      /free
000272120724       return environment.debuggedJob.user;
000273120724      /end-free
000274120724     p                 e
000275120724      //_______________________________________________________________________
000276120726
000277120726     p TRCENVVARS_setExchangeDtaara...
000278120726     p                 b                   export
000279120726     d                 pi
000280120726     d dtaara                        21a   const
000281120726
000282120726      /free
000283120726       environment.exchangeDtaara = dtaara;
000284120726      /end-free
000285120726     p                 e
000286120726      //_______________________________________________________________________
000287120726
000288120726     p TRCENVVARS_getExchangeDtaara...
000289120726     p                 b                   export
000290120726     d                 pi            21a
000291120726
000292120726      /free
000293120726       return environment.exchangeDtaara;
000294120726      /end-free
000295120726     p                 e
000296120726      //_______________________________________________________________________
000297120801
000298120801     p TRCENVVARS_getTraceType...
000299120801     p                 b                   export
000300120801     d                 pi            10a
000301120801
000302120801      /free
000303120801       return environment.traceType;
000304120801      /end-free
000305120801     p                 e
000306120801      //_______________________________________________________________________
000307120801
000308120801     p TRCENVVARS_setTraceType...
000309120801     p                 b                   export
000310120801     d                 pi
000311120801     d traceType                     10a   const
000312120801
000313120801      /free
000314120801       environment.traceType = traceType;
000315120801      /end-free
000316120801     p                 e
000317120801      //_______________________________________________________________________
000318120801
000319120801     p TRCENVVARS_setDebuggedProgramName...
000320120801     p                 b                   export
000321120801     d                 pi
000322120801     d programName                   10a   const
000323120801
000324120801      /free
000325120801       environment.debuggedPgm.programName = programName;
000326120801      /end-free
000327120801     p                 e
000328120801      //_______________________________________________________________________
000329120801
000330120801     p TRCENVVARS_getDebuggedProgramName...
000331120801     p                 b                   export
000332120801     d                 pi            10a
000333120801
000334120801      /free
000335120801       return environment.debuggedPgm.programName;
000336120801      /end-free
000337120801     p                 e
000338120801      //_______________________________________________________________________
000339120801
000340120801     p TRCENVVARS_setDebuggedProgramLibrary...
000341120801     p                 b                   export
000342120801     d                 pi
000343120801     d programLibrary                10a   const
000344120801
000345120801      /free
000346120801       environment.debuggedPgm.programLib = programLibrary;
000347120801      /end-free
000348120801     p                 e
000349120801      //_______________________________________________________________________
000350120801
000351120801     p TRCENVVARS_getDebuggedProgramLibrary...
000352120801     p                 b                   export
000353120801     d                 pi            10a
000354120801
000355120801      /free
000356120801       return environment.debuggedPgm.programLib;
000357120801      /end-free
000358120801     p                 e
000359120801      //_______________________________________________________________________
000360120801
000361120801     p TRCENVVARS_setDebuggedProgramType...
000362120801     p                 b                   export
000363120801     d                 pi
000364120801     d programType                   10a   const
000365120801
000366120801      /free
000367120801       environment.debuggedPgm.programType = programType;
000368120801      /end-free
000369120801     p                 e
000370120801      //_______________________________________________________________________
000371120801
000372120801     p TRCENVVARS_getDebuggedProgramType...
000373120801     p                 b                   export
000374120801     d                 pi            10a
000375120801
000376120801      /free
000377120801       return environment.debuggedPgm.programType;
000378120801      /end-free
000379120801     p                 e
000380120801      //_______________________________________________________________________
000381120801
000382120801     p TRCENVVARS_setDebuggedModule...
000383120801     p                 b                   export
000384120801     d                 pi
000385120801     d module                        10a   const
000386120801
000387120801      /free
000388120801       environment.debuggedPgm.module = module;
000389120801      /end-free
000390120801     p                 e
000391120801      //_______________________________________________________________________
000392120801
000393120801     p TRCENVVARS_getDebuggedModule...
000394120801     p                 b                   export
000395120801     d                 pi            10a
000396120801
000397120801      /free
000398120801       return environment.debuggedPgm.module;
000399120801      /end-free
000400120801     p                 e
000401120801      //_______________________________________________________________________
000402120801
000403120801     p TRCENVVARS_setDebuggedProcedure...
000404120801     p                 b                   export
000405120801     d                 pi
000406120801     d procedure                   1024a   const
000407120801
000408120801      /free
000409120801       environment.debuggedPgm.procedure = procedure;
000410120801      /end-free
000411120801     p                 e
000412120801      //_______________________________________________________________________
000413120801
000414120801     p TRCENVVARS_getDebuggedProcedure...
000415120801     p                 b                   export
000416120801     d                 pi          1024a
000417120801
000418120801      /free
000419120801       return environment.debuggedPgm.procedure;
000420120801      /end-free
000421120801     p                 e
000422120801      //_______________________________________________________________________
