000100120120     h nomain
000104120802     h bnddir('QC2LE':'TRACEBNDD')
000105120119
000109121028      /include qsrctxt,cexception
000110121028      /include qsrctxt,cregexp
000177120119
000178120626     p CREGEXP_create  b                   export
000179120119     d                 pi                  likeds(regex_T)
000180120120     d pattern                    32768a   value
000181120802     d convertPattern                  n   value options(*nopass)
000182120119     d
000183120119     d reasonCode      s             10i 0
000184120119     d regularExpression...
000185120119     d                 ds                  likeds(regex_T)
000186120119     d convertedPattern...
000187120119     d                 s                   like(pattern)
000188120802     d patternAddr     s               *
000189120119     d convertedPatternAddr...
000190120119     d                 s               *   inz(%addr(convertedPattern))
000191120802     d
000193120802     d doConvertion    s               n   inz(*OFF)
000194120802     d regexError      s            100a
000195120802
000196120119      /free
000197120119       monitor;
000198120802         if %parms > 1;
000199120802           doConvertion = convertPattern;
000200120802         endif;
000201120802
000202120802         patternAddr = %addr(pattern);
000203120802
000204120802         if doConvertion;
000205120802           //Convert from the current job ccsid to ccsid IBM-37
000206120802           //This step is required for the regcomp only if the
000207120802           //pattern is in a ccsid other than 37
000208120802           CREGEXP_convertCCSID(patternAddr
000209120802                               :convertedPatternAddr:0:37
000210120802                               :%len(%trim(pattern)));
000211120802         else;
000212120802           convertedPattern = pattern;
000213120802         endif;
000214120121
000215120119         //Prepare the regular expression and check for errors
000216120121         reasonCode = regcomp(regularExpression
000217120121                    : %subst(convertedPattern : 1
000218120121                            : %len(%trimr(convertedPattern)))
000219120121                    : REG_EXTENDED);
000220120119
000221120119         if (reasonCode <> 0);
000222120802           regerror(reasonCode : regularExpression : %addr(regexError)
000223120802                               : %size(regexError));
000224120119
000225120119           //The expression had an error
000226120119           CEXCEPTION_throwNewException('CPF9898' : 'QCPFMSG' : 'Error while ' +
000227120120               'compiling the regular expression. RC: ' + %char(reasonCode) +
000228120802               ':' + regexError);
000229120119         else;
000230120119           return regularExpression;
000231120119         endif;
000232120119
000233120119       on-error;
000234120119         CEXCEPTION_catchException();
000235120119         CEXCEPTION_printStackTrace();
000236120119         CEXCEPTION_throwNewException('CPF9898' : 'QCPFMSG' : 'Error while ' +
000237120119               'compiling the regular expression');
000238120119       endmon;
000239120119      /end-free
000240120119     p                 e
000241120119      //_______________________________________________________________________
000242120119
000243120626     p CREGEXP_isMatch...
000244120626     p                 b                   export
000245120119     d                 pi              n
000246120119     d
000247120119     d dataToCompare              32768a   varying const
000248120119     d regularExp                          likeds(regex_T) value
000249120119     d matchInfo       ds                  likeds(regMatch_T) Dim(2)
000250120119     d reasonCode      s             10i 0
000251120119     d tempBuffer      s            100a
000252120119
000253120119      /free
000254120119       monitor;
000255120121         reasonCode = regexec(regularExp : %trimr(dataToCompare)
000256120121                             : 1 : matchInfo : 0);
000257120119
000258120121         if (reasonCode = 0);
000259120119           return *on;
000260120119         else;
000261120119           if (reasonCode = REG_NOMATCH);
000262120119             return *off;
000263120119           else;
000264120119             //An error ocurred
000265120119             regerror(reasonCode : regularExp : %addr(tempBuffer)
000266120119                     : %size(tempBuffer));
000267120119
000268120119             CEXCEPTION_throwNewException('CPF9898' : 'QCPFMSG' :
000269120119                'Error while compiling the regular expression. RC: ' +
000270120120                %char(reasonCode) + ':' + tempBuffer);
000271120119           endif;
000272120119         endif;
000273120119       on-error;
000274120119         CEXCEPTION_catchException();
000275120119         CEXCEPTION_printStackTrace();
000276120119         CEXCEPTION_throwNewException('CPF9898' : 'QCPFMSG' : 'Error while ' +
000277120119               'comparing the regular expression');
000278120119       endmon;
000279120119      /end-free
000280120119
000281120119     p                 e
000282120119      //_______________________________________________________________________
000283120119
000284120626     p CREGEXP_destroy...
000285120626     p                 b                   export
000286120119     d                 pi
000287120119     d regularExp                          likeds(regex_T) value
000288120119
000289120119      /free
000290120119       monitor;
000291120119         regfree(regularExp);
000292120119
000293120119       on-error;
000294120119         CEXCEPTION_catchException();
000295120119         CEXCEPTION_printStackTrace();
000296120119       endmon;
000297120119      /end-free
000298120119     p                 e
000299120628      //_______________________________________________________________________
000300120628
000301120628     p CREGEXP_convertCCSID...
000302120628     p                 b                   export
000303120628     d                 pi
000304120628     d   inputBuffer                   *   const
000305120628     d   outputBuffer                  *   const
000306120628     d   fromCcsid                   10i 0 value
000307120628     d   toCcsid                     10i 0 value
000308120628     d   buffersLen                  10u 0 value
000309120628
000310120628     d iconv_t         ds                  based(prototype_only)
000311120628     d   return_value                10i 0
000312120628     d   cd                          10i 0 dim(12)
000313120628      *
000314120628     d from            ds                  qualified
000315120628     d  CCSID                        10i 0 inz(0)
000316120628     d  ConvAlt                      10i 0 inz(0)
000317120628     d  SubsAlt                      10i 0 inz(0)
000318120628     d  ShiftAlt                     10i 0 inz(1)
000319120628     d  InpLenOp                     10i 0 inz(0)
000320120628     d  ErrorOpt                     10i 0 inz(1)
000321120628     d  Reserved                      8a   inz(*ALLx'00')
000322120628      *
000323120628     d to              ds                  qualified
000324120628     d  CCSID                        10i 0 inz(0)
000325120628     d  ConvAlt                      10i 0 inz(0)
000326120628     d  SubsAlt                      10i 0 inz(0)
000327120628     d  ShiftAlt                     10i 0 inz(1)
000328120628     d  InpLenOp                     10i 0 inz(0)
000329120628     d  ErrorOpt                     10i 0 inz(1)
000330120628     d  Reserved                      8a   inz(*ALLx'00')
000331120628      *
000332120628     d QtqIconvOpen    pr                  extproc('QtqIconvOpen')
000333120628     d                                     like(iconv_t)
000334120628     d    tocode                           like(to) const
000335120628     d    fromcode                         like(from) const
000336120628      *
000337120628     d iconv           pr            10i 0 extproc('iconv')
000338120628     d   cd                                like(iconv_t) value
000339120628     d   inbuf                         *   const
000340120628     d   inbytesleft                 10u 0
000341120628     d   outbuf                        *   const
000342120628     d   outbytesleft                10u 0
000343120628      *
000344120628     d iconv_close     pr            10i 0 extproc('iconv_close')
000345120628     d   cd                                like(iconv_t) value
000346120628      *
000347120628     d hInconv         ds                  likeds(iconv_t)
000348120628     d pInBuf          s               *   inz
000349120628     d pOutBuf         s               *   inz
000350120628      *
000351120628     d DIGITS          c                   const(%len(to.ccsid))
000352120628     d DECPOS          c                   const(%decpos(to.ccsid))
000353120628
000354120628      /free
000355120628
000356120628         from.ccsid = fromCcsid;
000357120628         to.ccsid = toCcsid;
000358120628
000359120628         hInconv = QtqIconvOpen(to:from);
000360120628
000361120628         iconv(hInconv:inputBuffer:buffersLen:outputBuffer:buffersLen);
000362120628
000363120628         iconv_close(hInconv);
000364120628
000365120628      /end-free
000366120628
000367120628     p                 e
000368120628
