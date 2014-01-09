000100120823/* codCoverag command source                                  */
000101120823/*                                                            */
000102120823/* Description: This command determines which lines of an     */
000103120823/*              specific program where executed given a       */
000104120823/*              tracedata generated with iTrace               */
000105120823/*                                                            */
000106120823/* Author     : Isaac Ramirez Herrera                         */
000107120823/* Created on : August 22, 2012                               */
000108120823             CMD        PROMPT('Code coverage Tool')
000109120823             PARM       KWD(PROGRAM) TYPE(PGMTOTRACE) PROMPT('Program Name')
000110120823
000111120823             PARM       KWD(PGMTYPE) TYPE(*CHAR) LEN(10) RSTD(*YES) DFT(*PGM) VALUES(*PGM +
000112120823                          *SRVPGM) CHOICE('*PGM, *SRVPGM') PROMPT('Program Type')
000113120823
000114120823             PARM       KWD(TRACEDATA) TYPE(OUTF) FILE(*OUT) PROMPT('Trace data file')
000115120823
000116120823             PARM       KWD(OUTLIB) TYPE(*CHAR) LEN(10) PROMPT('Output library') DFT(*CURLIB) +
000117120823                          SPCVAL((*CURLIB *CURLIB))
000118121008
000119121008             PARM       KWD(PREFFIX) TYPE(*CHAR) LEN(4) RSTD(*NO) DFT(*DFT) SPCVAL((*DFT +
000120121008                          'DFT')) CHOICE('*DFT, Preffix') PROMPT('Outfile preffix')
000121121008
000122120823
000123121001 PGMTOTRACE: QUAL       TYPE(*NAME) MIN(1) EXPR(*YES) SPCVAL((*ALL *ALL))
000124120823             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL) (*CURLIB *CURLIB)) +
000125120823                          PROMPT('Library')
000126120823
000127120823 OUTF:       QUAL       TYPE(*NAME) LEN(10) DFT(TRACEDATA) VARY(*NO) EXPR(*YES)
000128120823             QUAL       TYPE(*NAME) LEN(10) DFT(QTEMP) VARY(*NO) EXPR(*YES) SPCVAL((*CURLIB +
000129120823                          *CURLIB)) PROMPT('Library')
