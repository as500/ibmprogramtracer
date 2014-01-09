000100120726             CMD        PROMPT('Set Case Id for Trace')
000101120726
000102120726             PARM       KWD(CASEID) TYPE(*CHAR) LEN(20) MIN(1) PROMPT('Case id for the current +
000103120726                          trace')
000104120729             PARM       KWD(DATAARA) TYPE(DTAARA) PROMPT('Name of the dataara')
000108120729
000109120729 DTAARA:     QUAL       TYPE(*NAME) LEN(10) DFT(TRCDTAA) VARY(*NO) EXPR(*YES)
000110120729             QUAL       TYPE(*NAME) LEN(10) DFT(*CURLIB) VARY(*NO) EXPR(*YES) SPCVAL((*CURLIB +
000111120729                          *CURLIB)) PROMPT('Library')
