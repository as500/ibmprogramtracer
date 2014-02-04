000100      
000102140113     h dftactgrp(*no)
000103140113     h actgrp('ITRACE2')
000104140113     h debug(*no)
000105140113     h option(*srcstmt:*nodebugio)
000106140113     h bnddir('CEXCEPBNDD':'QC2LE')
000107140113
000108140113      /include itrace2txt,debugrapis
000109140113      /include itrace2txt,traceapi
000110140113      /include itrace2txt,cexception
000111140113
000112140113     p TRACEAPI_StartSourceDebug...
000113140113     p                 b                   export
000114140113     d                 pi
000115140113     d stopHandler                         const
000116140113     d                                     likeds(QualifiedProgramName_Type)
000117140113     d errorDS         ds                  likeds(ApiError_Type)
000118140113     d                                     inz(*likeds)
000119140113     d programName     ds                  likeds(programName_type)
000120140113
000121140113      /free
000122140114       monitor;
000123140113         //Force an exception if the API call fails
000124140113         errorDS.Bytes = 0;
000125140113
000126140113         StarSourceDebugAPI(stopHandler:errorDS);
000132140113       on-error;
000133140113         CEXCEPTION_catchException();
000134140113         CEXCEPTION_printStackTrace();
000135140113         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000136140113            :'Error while starting debug');
000137140113       endmon;
000138140113     p                 e
000139140113      //_______________________________________________________________________
