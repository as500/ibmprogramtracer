000100120731
000101120731     h nomain
000102120731     h option(*srcstmt)
000103120731
000104121028      /include qsrctxt,cException
000105121028      /include qsrctxt,cExcpTypes
000106121028      /include qsrctxt,cExcpError
000107121028      /include qsrctxt,trcutil
000108120731
000109120731     p TRCUTIL_sendProgramMessage...
000110120731     p                 b                   export
000111120731     d                 pi
000112120731     d message                      150a   const
000113120731     d
000114120731     d errorApi        ds                  likeds(errorDS_Type)
000115120731     d msgKey          s              4a
000116120731
000117120731      /free
000120120731       SendProgramMessage(*blanks:
000121120731                    *blanks:
000122120731                    message:
000123120731                    %len(%trimr(message)):
000124121011                    '*INFO':
000125121011                    '*':
000126121011                    7:
000127120731                    MsgKey:
000128120731                    errorApi);
000129120731
000130120731      /end-free
000131120731     p                 e
000132120731      //_______________________________________________________________________
000133120731
