000100120731
000101120731     h nomain
000102120731     h option(*srcstmt)
000103120802     h bnddir('TRCBNDD')
000104120731
000105121028      /include qsrctxt,trcrules
000106121028      /include qsrctxt,llist_h
000107121028      /include qsrctxt,cexception
000108121028      /include qsrctxt,cregexp
000109121028      /include qsrctxt,csqlutil
000110120731
000111120820      /////////////////////////////////////////////////////
000112120820      // Types
000113120820      /////////////////////////////////////////////////////
000114120820
000115120820     d rulesStructure_Type...
000116120820     d               e ds                  extname(TRACERULES) qualified
000117120820     d                                     template
000118120820
000119120820     d ruleScopeStructure_Type...
000120120820     d               e ds                  extname(RULESCOPE) qualified
000121120820     d                                     template
000122120820
000123120820     d ruleTypeStructure_Type...
000124120820     d               e ds                  extname(RULETYPE) qualified
000125120820     d                                     template
000126120820
000127120802      /////////////////////////////////////////////////////
000128120802      // Constants
000129120802      /////////////////////////////////////////////////////
000130120802
000131120802      //Rules types
000132120802     d STEP_OUT        c                   const('STEP_OUT')
000133120802     d DO_NOT_WRITE    c                   const('DO_NOT_WRITE')
000134120802
000135120802      //Rules range
000136120802     d LIBRARY_RANGE   c                   const('LIBRARY')
000137120802     d PROGRAM_RANGE   c                   const('PROGRAM')
000138120802     d PROCEDURE_RANGE...
000139120802     d                 c                   const('PROCEDURE')
000140120802
000141120802      /////////////////////////////////////////////////////
000142120802      // Global variables
000143120802      /////////////////////////////////////////////////////
000144120802
000145120802     d Rule_Type       ds                  qualified template inz
000146120802     d  ruleId                       10i 0
000147120802     d  type                         50a   varying
000148120802     d  scope                        50a   varying
000149120802     d  pattern                            likeds(regex_t)
000150120802
000151120802     d StepOut_Rules...
000152120802     d                 s               *   inz(*NULL)
000153120802
000154120802     d DoNotWwrite_Rules...
000155120802     d                 s               *   inz(*NULL)
000156120802
000157120802      /////////////////////////////////////////////////////
000158120802      // Prototype declaration
000159120802      /////////////////////////////////////////////////////
000160120802
000161120802     d prepareRulePattern...
000162120820     d                 pr           500a
000163120820     d pattern                             like(rulesStructure_Type.PATTERN)
000164120820     d                                     const
000165120802
000166120802     d checkRule       pr              n
000167120802     d library                       10a   const
000168120802     d program                       10a   const
000169120802     d procedure                    255a   const
000170120802     d ruleType                      50a   const
000171120802     d ruleList                        *
000172120802
000173120802     d loadRuleByType  pr
000174120802     d type                          50a   const
000175120802     d listToLoad                      *
000176120802
000177120802     d destroyRuleList...
000178120802     d                 pr
000179120802     d listPtr                         *
000180120802
000181120802      /////////////////////////////////////////////////////
000182120802      // Procedure definition
000183120802      /////////////////////////////////////////////////////
000184120802
000185120802     p TRCRULES_loadRules...
000186120802     p                 b                   export
000187120802
000188120802      /free
000189120802       monitor;
000190120802         if StepOut_Rules = *NULL;
000191120802           StepOut_Rules = list_create();
000192120802         endif;
000193120802
000194120802         if DoNotWwrite_Rules = *NULL;
000195120802           DoNotWwrite_Rules = list_create();
000196120802         endif;
000197120802
000198120802         loadRuleByType(STEP_OUT:StepOut_Rules);
000199120802         loadRuleByType(DO_NOT_WRITE:DoNotWwrite_Rules);
000239120802       on-error;
000240120802         CEXCEPTION_catchException();
000241120802         CEXCEPTION_printStackTrace();
000242120802         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000243120802           :'Error loading step out rules');
000244120802       endmon;
000245120802      /end-free
000246120802     p                 e
000247120802      //_______________________________________________________________________
000248120802
000250120802     p TRCRULES_destroy...
000251120802     p                 b                   export
000252120802
000253120802      /free
000254120802       monitor;
000255120802         destroyRuleList(StepOut_Rules);
000256120802         destroyRuleList(DoNotWwrite_Rules);
000257120802       on-error;
000258120802         CEXCEPTION_catchException();
000259120802         CEXCEPTION_printStackTrace();
000260120802       endmon;
000261120802      /end-free
000262120802     p                 e
000263120802      //_______________________________________________________________________
000279120802
000280120731     p TRCRULES_doStepInto...
000281120731     p                 b                   export
000282120731     d                 pi              n
000283120731     d library                       10a   const
000284120731     d program                       10a   const
000285120802     d procedure                    255a   const
000286120802     d
000287120802     d ruleApplied     s               n   inz(*off)
000288120802
000289120731      /free
000290120802       monitor;
000291120802         ruleApplied = checkRule(library
000292120802                                :program
000293120802                                :procedure
000294120802                                :STEP_OUT
000295120802                                :StepOut_Rules);
000296120802
000297120802         return not ruleApplied;
000298120802       on-error;
000299120802         CEXCEPTION_catchException();
000300120802         CEXCEPTION_printStackTrace();
000301120802         return *ON;
000302120802       endmon;
000311120731      /end-free
000313120731     p                 e
000314120731      //______________________________________________________________________
000315120731
000316120802     p TRCRULES_writeTrace...
000317120802     p                 b                   export
000318120802     d                 pi              n
000319120802     d library                       10a   const
000320120802     d program                       10a   const
000321120802     d procedure                    255a   const
000322120802     d ruleApplied     s               n   inz(*off)
000323120802
000324120802      /free
000325120802       monitor;
000326120802         ruleApplied = checkRule(library
000327120802                                :program
000328120802                                :procedure
000329120802                                :DO_NOT_WRITE
000330120802                                :DoNotWwrite_Rules);
000331120802
000332120802         return not ruleApplied;
000333120802       on-error;
000334120802         CEXCEPTION_catchException();
000335120802         CEXCEPTION_printStackTrace();
000336120802         return *ON;
000337120802       endmon;
000338120802      /end-free
000339120802     p                 e
000340120802      //______________________________________________________________________
000341120802
000342120802     p loadRuleByType  b
000343120802     d                 pi
000344120802     d type                          50a   const
000345120802     d listToLoad                      *
000346120802     d
000347120820     d ruleId          s                   like(rulesStructure_Type.RULEID)
000348120820     d ruleType        s                   like(ruleTypeStructure_Type.NAME)
000349120820     d ruleScope       s                   like(ruleScopeStructure_Type.NAME)
000350120820     d rulePattern     s                   like(rulesStructure_Type.PATTERN)
000351120820     d newRule         ds                  likeds(Rule_Type)
000352120802
000357120802      /free
000358120802       EXEC SQL
000359120820           DECLARE RULE_CURSOR CURSOR FOR
000360120820            SELECT RULES.RULEID, RTYPE.NAME, RSCOPE.NAME, RULES.PATTERN
000361120820              FROM TRACERULES RULES
000362120820        INNER JOIN RULETYPE RTYPE
000363120820                ON RULES.RULETYPE  = RTYPE.TYPEID
000364120820        INNER JOIN RULESCOPE RSCOPE
000365120820                ON RULES.RULESCOPE = RSCOPE.SCOPEID
000367120820             WHERE RTYPE.NAME = :TYPE
000368120820               AND RULES.ACTIVE = 'Y';
000369120802
000371120802       EXEC SQL
000372120802         OPEN RULE_CURSOR;
000373120802
000374120802       CSQLUTIL_checkSQLState(SQLSTT:'OPEN RULECURSOR');
000375120802
000376120802       monitor;
000377120802         EXEC SQL
000378120802           FETCH RULE_CURSOR INTO :RULEID, :RULETYPE, :RULESCOPE, :RULEPATTERN;
000379120802
000380120802         dow CSQLUTIL_checkSQLState(SQLSTT:'FETCH RULECURSOR');
000381120802           newRule.ruleId  = ruleid;
000382120802           newRule.type    = ruleType;
000383120802           newRule.scope   = ruleScope;
000384120802           newRule.pattern = CREGEXP_create(prepareRulePattern(rulePattern));
000385120802
000386120802           list_add(listToLoad:%addr(newRule):%size(Rule_Type));
000387120802           clear newRule;
000388120802
000389120802           EXEC SQL
000390120802             FETCH RULE_CURSOR INTO :RULEID,    :RULETYPE,
000391120802                                    :RULESCOPE, :RULEPATTERN;
000392120802         enddo;
000393120802       on-error;
000394120802         CEXCEPTION_catchException();
000395120802         CEXCEPTION_printStackTrace();
000396120802       endmon;
000397120802
000398120802       EXEC SQL
000399120802         CLOSE RULE_CURSOR;
000400120802      /end-free
000401120802     p                 e
000402120802      //______________________________________________________________________
000403120802
000404120802     p prepareRulePattern...
000405120802     p                 b
000406120820     d                 pi           500a
000407120820     d pattern                             like(rulesStructure_Type.PATTERN)
000408120820     d                                     const
000409120802
000410120802      //Characters ^ and $ in hexadecimal for CCSID 037
000411120802      //^ means begin of pattern and $ end of pattern
000412120802     d BEGIN_ANCHOR    c                   const(x'B0')
000413120802     d END_ANCHOR      c                   const(x'5B')
000414120802     d wrkPattern      s                   like(pattern)
000415120802     d wrkPatternPtr   s               *   inz(%addr(wrkPattern))
000416120802     d convertedPattern...
000417120802     d                 s                   like(pattern)
000418120802     d convertedPatternPtr...
000419120802     d                 s               *   inz(%addr(convertedPattern))
000420120802
000421120802      /free
000422120802       wrkPattern = pattern;
000423120802
000424120802       CREGEXP_convertCCSID(wrkPatternPtr:convertedPatternPtr:0:37
000425120802           :%len(%trim(wrkPattern)));
000426120802
000427120802       //Check the beginning and end of the pattern to determine if it
000428120802       //has anchor characters, otherwise put anchors
000429120802       if %subst(convertedPattern:1:1) <> BEGIN_ANCHOR;
000430120802         convertedPattern = BEGIN_ANCHOR + %trim(convertedPattern);
000431120802       endif;
000432120802
000433120802       if %subst(convertedPattern:%len(%trim(
000434120802             convertedPattern)):1) <> END_ANCHOR;
000435120802
000436120802         convertedPattern = %trim(convertedPattern) + END_ANCHOR;
000437120802       endif;
000438120802
000439120802       return convertedPattern;
000440120802      /end-free
000441120802     p                 e
000442120802      //______________________________________________________________________
000443120802
000444120802     p checkRule       b
000445120802     d                 pi              n
000446120802     d library                       10a   const
000447120802     d program                       10a   const
000448120802     d procedure                    255a   const
000449120802     d ruleType                      50a   const
000450120802     d ruleList                        *
000451120802     d
000452120802     d listLength      s             10i 0
000453120802     d index           s             10i 0
000454120802     d
000455120802     d currentRulePtr  s               *
000456120802     d currentRule     ds                  likeds(Rule_Type)
000457120802     d                                     based(currentRulePtr)
000458120802     d
000459120802     d fullProgramName...
000460120802     d                 s             21a   varying
000461120802     d fullProcedureName...
000462120820     d                 s          10000a   varying
000463120802     d ruleApplied     s               n   inz(*off)
000464120802
000465120802      /free
000466120820       if ruleList <> *null and list_size(ruleList) > 0;
000467120802         fullProgramName   = %trim(library) + '/'
000468120802                           + %trim(program);
000469120802         fullProcedureName = %trim(fullProgramName) + '/'
000470120802                           + %trim(procedure);
000471120802
000472120802         listLength = list_size(ruleList) - 1;
000473120802
000474120802         for index = 0 to listLength;
000475120802           currentRulePtr = list_get(ruleList:index);
000476120802
000477120802           if currentRule.type = ruleType;
000478120802             select;
000479120802               when currentRule.scope = LIBRARY_RANGE;
000480120802                 ruleApplied = CREGEXP_isMatch(%trim(library)
000481120802                    :currentRule.pattern);
000482120802
000483120802               when currentRule.scope = PROGRAM_RANGE;
000484120802                 ruleApplied = CREGEXP_isMatch(%trim(fullProgramName)
000485120802                    :currentRule.pattern);
000486120802
000487120802               when currentRule.scope = PROCEDURE_RANGE;
000488120802                 ruleApplied = CREGEXP_isMatch(%trim(fullProcedureName)
000489120802                    :currentRule.pattern);
000490120802             endsl;
000491120802
000492120802             if ruleApplied;
000493120802               return ruleApplied;
000494120802             endif;
000495120802           endif;
000496120802         endfor;
000497120802
000498120802         return *OFF;
000499120802       else;
000500120820         return *OFF;
000501120802       endif;
000502120802      /end-free
000503120802     p                 e
000504120802      //______________________________________________________________________
000505120802
000506120802     p destroyRuleList...
000507120802     p                 b
000508120802     d                 pi
000509120802     d listPtr                         *
000510120802     d
000511120802     d index           s             10i 0
000512120802     d currentRulePtr  s               *
000513120802     d currentRule     ds                  likeds(Rule_Type)
000514120802     d                                     based(currentRulePtr)
000515120802     d listLength      s             10i 0
000516120802
000517120802      /free
000518120820       if listPtr <> *NULL and list_size(listPtr) > 0;
000519120820         listLength = list_size(listPtr) - 1;
000520120802
000521120820         for index = 0 to listLength;
000522120820           currentRulePtr = list_get(listPtr:index);
000523120820           CREGEXP_destroy(currentRule.pattern);
000524120820           clear currentRule;
000525120820         endfor;
000528120820       endif;
000529120820
000530120820       list_dispose(listPtr);
000532120802      /end-free
000533120802     p                 e
000534120802      //_______________________________________________________________________
