000100
000101121002     h option(*nodebugio:*noxref:*srcstmt)
000102121002     h bnddir('TRACEBNDD')
000103121002     h dftactgrp(*NO)
000104121002     h actgrp('TRACEPGM')
000105121002
000106121002      ///////////////////////////////////////////////////////
000107121002      // Prototype declaration
000108121002      ///////////////////////////////////////////////////////
000109121002
000110121028      /include qsrctxt,tracetypes
000111121002
000114121002     d SRVENTHDLR_main...
000115121002     d                 pr                  extpgm('SRVENTHDLR')
000116121002     d  programName                        const likeds(programName_type)
000117121002     d  programType                  10a   const
000118121002     d  moduleName                   10a   const
000119121002     d  stopInfo                     10a   const
000120121002     d  job                                const likeds(jobName_Type)
000121121002
000122121002      ///////////////////////////////////////////////////////
000123121002      // Procedure implementation
000124121002      ///////////////////////////////////////////////////////
000125121002
000127121002     d SRVENTHDLR_main...
000128121002     d                 pi
000129121002     d  programName                        const likeds(programName_type)
000130121002     d  programType                  10a   const
000131121002     d  moduleName                   10a   const
000132121002     d  stopInfo                     10a   const
000133121002     d  job                                const likeds(jobName_Type)
000134121002
000135121002      /free
000136121002
000137121002
000138121002       *inLR = *ON;
000139121002       return;
000140121002      /end-free
