000100120721/* iTrace command source                                      */
000102120721/*                                                            */
000103120731/* Description: Itrace command definition. This command is    */
000104120731/*              processed by the TRCSESHDLR.pgm program which */
000105120731/*              initiates a trace session                     */
000106120731/*                                                            */
000107120721/* Author     : Isaac Ramirez Herrera                         */
000108120721/* Created on : July 21, 2012                                 */
000109120721/* Notes      : Based on the TTETRCC.CMD source code by IBM   */
000110120721
000111120721             CMD        PROMPT('iTrace - Trace Program Tool')
000112120721
000113120801             PARM       KWD(SET) TYPE(*CHAR) LEN(10) RSTD(*YES) VALUES(*ON *OFF) MIN(1) +
000114120801                          EXPR(*YES) PROMPT('Trace option setting')
000115120721
000116120801             PARM       KWD(PROGRAM) TYPE(PGMTOTRACE) PROMPT('Program to trace') PMTCTL(SETON)
000117120801
000118120801             PARM       KWD(PGMTYPE) TYPE(*CHAR) LEN(10) RSTD(*YES) DFT(*PGM) VALUES(*PGM +
000119120801                          *SRVPGM) CHOICE('*PGM, *SRVPGM') PMTCTL(SETON) PROMPT('Program Type')
000121120723
000122120801             PARM       KWD(TRACETYPE) TYPE(*CHAR) LEN(10) RSTD(*YES) DFT(*ALL) VALUES(*ALL +
000123120801                          *FLOWCHG) PMTCTL(SETON) PROMPT('Trace data to save')
000127120801
000128120801             PARM       KWD(OUTFILE) TYPE(OUTF) FILE(*OUT) PROMPT('File to receive output') +
000129120801                          PMTCTL(SETON)
000130120724
000131120801             PARM       KWD(OUTFILEOPT) TYPE(*CHAR) LEN(10) VALUES(*ADD *REPLACE) PROMPT('File +
000132120801                          output options') DFT(*ADD) RSTD(*YES) PMTCTL(SETON)
000133120724
000134120801             PARM       KWD(TRCDTAARA) TYPE(DTAARA) PROMPT('Contains the case id') +
000135120801                          PMTCTL(SETON)
000136120726
000137120801             PARM       KWD(BATCHTRACE) TYPE(*CHAR) LEN(10) DFT(*OFF) VALUES(*ON *OFF) +
000138120801                          RSTD(*YES) PROMPT('Trace for batch job') PMTCTL(SETON)
000139120723
000140120801             PARM       KWD(JOBTOTRACE) TYPE(JOB) PROMPT('Submited Job to trace') PMTCTL(BATCH)
000141120723
000142120731 PGMTOTRACE: QUAL       TYPE(*NAME) MIN(1) EXPR(*YES)
000143120731             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL) (*CURLIB *CURLIB)) +
000144120731                          PROMPT('Library')
000145120721
000146120724 OUTF:       QUAL       TYPE(*NAME) LEN(10) DFT(TRACEDATA) VARY(*NO) EXPR(*YES)
000147120726             QUAL       TYPE(*NAME) LEN(10) DFT(QTEMP) VARY(*NO) EXPR(*YES) SPCVAL((*CURLIB +
000148120726                          *CURLIB)) PROMPT('Library')
000149120726
000150120726 DTAARA:     QUAL       TYPE(*NAME) LEN(10) DFT(TRCDTAA) VARY(*NO) EXPR(*YES)
000151120726             QUAL       TYPE(*NAME) LEN(10) DFT(*CURLIB) VARY(*NO) EXPR(*YES) SPCVAL((*CURLIB +
000152120726                          *CURLIB)) PROMPT('Library')
000153120726
000154120731 JOB:        QUAL       TYPE(*NAME) LEN(10) MIN(1) EXPR(*YES)
000155120731             QUAL       TYPE(*NAME) LEN(10) MIN(1) EXPR(*YES) PROMPT('User')
000156120731             QUAL       TYPE(*CHAR) LEN(6) RANGE(000000 999999) MIN(1) FULL(*YES) EXPR(*YES) +
000157120731                          PROMPT('Number')
000158120725
000159120721 SETON:      PMTCTL     CTL(SET) COND((*EQ *ON))
000160120721
000161120724 BATCH:      PMTCTL     CTL(BATCHTRACE) COND((*EQ *ON))
