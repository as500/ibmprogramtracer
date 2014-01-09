000100
000101120726
000102120726     h datedit(*ymd)
000103120726     h option(*nodebugio:*noxref:*srcstmt)
000104120726     h bnddir('TRACEBNDD')
000105120726     h dftactgrp(*no)
000106120726     h actgrp('TRACEPGM')
000107120726
000108121028      /include qsrctxt,trchandler
000109121028      /include qsrctxt,cexception
000110120726
000111120726     d TRCSETCASE_main...
000112120726     d                 pr                  extpgm('TRCSETCASE')
000113120726     d caseId                        20a   const options(*varsize)
000114120729     d dataara                       20a   const options(*varsize)
000115120726
000117120726     d TRCSETCASE_main...
000118120726     d                 pi
000119120726     d caseId                        20a   const options(*varsize)
000120120729     d dataara                       20a   const options(*varsize)
000122120729     d dataaraName     s             10a
000123120729     d dataaraLib      s             10a
000124120729
000125120726      /free
000126120729       monitor;
000127120729         dataaraName = %subst(dataara:1:10);
000128120729         dataaraLib  = %subst(dataara:11:10);
000129120729
000130120729         TRCHANDLER_setCaseId(caseId:dataaraLib:dataaraName);
000131120729       on-error;
000132120729         CEXCEPTION_catchException();
000133120729         CEXCEPTION_printStackTrace();
000134120729       endmon;
000135120729
000136120726       *inLR = *on;
000137120726       return;
000138120726      /end-free
000139120726
