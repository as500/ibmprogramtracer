000100120420     /**
000101120420      * \brief Linked List Implementation
000102120420      *
000103120420      * This is a typical Doubly-Linked List (Two-Way Linked List) Implementation
000104120420      * using dynamic memory allocation. The list is particular suitable for
000105120420      * character values but does also work with any other data (f. e. data
000106120420      * structures).
000107120420      *
000108120420      * <br><br>
000109120420      *
000110120420      * Values are stored as null-terminated chars.
000111120420      *
000112120420      * <br><br>
000113120420      *
000114120420      * Operations that index into the list will traverse the list from
000115120420      * the beginning or the end, whichever is closer to the specified index.
000116120420      *
000117120420      * <br><br>
000118120420      *
000119120420      * <b>Iteration:</b> With the procedure <em>getNext</em> the list is
000120120420      * traversable in the top-bottom direction. Each call to <em>getNext</em>
000121120420      * will return the next entry of the list till the end of the list.
000122120420      * If the walk through the list should be stopped early (before the end
000123120420      * of the list) the method <em>abortIteration</em> should be called.
000124120420      * If the list is structurally modified at any time
000125120420      * after an iteration has begun in any way, the result of the iteration
000126120420      * can not be safely determined. If an iteratioj is not going to continue
000127120420      * the procedure <em>abortIteration</em> should be called. After that
000128120420      * call it is safe to modify the list again.
000129120420      *
000130120420      * <br><br>
000131120420      *
000132120420      * Throughout this service program a zero-based index is used.
000133120420      *
000134120420      * <br><br>
000135120420      *
000136120420      * This list implementation is not thread-safe.
000137120420      *
000138120420      * \author Mihael Schmidt
000139120420      * \date   20.12.2007
000140120420      *
000141120420      * \rev 22.11.2009 Mihael Schmidt
000142120420      *      Added sorting support <br>
000143120420      *      Changed memory management to user created heap <br>
000144120420      *      Added removeRange procedure <br>
000145120420      *      Bug fix: list_addAll does not work if value has x'00'
000146120420      *
000147120420      * \rev 15.12.2009 Mihael Schmidx
000148120420      *      Added merge procedure
000149120420      *
000150120420      * \rev 19.02.2011 Mihael Schmidt
000151120420      *      Fixed list_sublist procedure <br>
000152120420      *      Added list_resetIteration <br>
000153120420      *      Deprecated list_abortIteration <br>
000154120420      *      Added list_iterate <br>
000155120420      *      Deprecated list_getNext <br>
000156120420      *      Userdata parameter on list_foreach is now optional <br>
000157120420      *      list_merge got new parameter to only optionally skip duplicate entries
000158120420      */
000159120420
000160120420      *------------------------------------------------------------------------
000161120420      *
000162120420      * Copyright (c) 2007-2009 Mihael Schmidt
000163120420      * All rights reserved.
000164120420      *
000165120420      * This file is part of the LLIST service program.
000166120420      *
000167120420      * LLIST is free software: you can redistribute it and/or modify it under
000168120420      * the terms of the GNU Lesser General Public License as published by
000169120420      * the Free Software Foundation, either version 3 of the License, or
000170120420      * any later version.
000171120420      *
000172120420      * LLIST is distributed in the hope that it will be useful,
000173120420      * but WITHOUT ANY WARRANTY; without even the implied warranty of
000174120420      * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
000175120420      * GNU Lesser General Public License for more details.
000176120420      *
000177120420      * You should have received a copy of the GNU Lesser General Public
000178120420      * License along with LLIST.  If not, see http://www.gnu.org/licenses/.
000179120420      *
000180120420      *------------------------------------------------------------------------
000181120420
000182120420
000183120420     H NOMAIN
000184120420     H COPYRIGHT('Copyright (c) 2007-2011 Mihael Schmidt. All rights reserved.')
000185120420
000186120420
000187120420      *-------------------------------------------------------------------------
000188120420      * Prototypen
000189120420      *-------------------------------------------------------------------------
000190121028      /include qsrctxt,llist_h
000191121028      /include qsrctxt,llist_in_h
000192121028      /include qsrctxt,ceeapi_h
000193120420
000194120420
000195120420      *-------------------------------------------------------------------------
000196120420      * Procedures
000197120420      *-------------------------------------------------------------------------
000198120420
000199120420     /**
000200120420      *  \brief Create list
000201120420      *
000202120420      * Creates a list. A header is generated for the list and the pointer to
000203120420      * the list returned.
000204120420      *
000205120420      * <br><br>
000206120420      *
000207120420      * A list must be disposed via the procedure <em>dispose</em> to free all
000208120420      * allocated memory.
000209120420      *
000210120420      * \author Mihael Schmidt
000211120420      * \date   18.12.2007
000212120420      *
000213120420      * \return Pointer to the list
000214120420      */
000215120420     P list_create     B                   export
000216120420     D                 PI              *
000217120420      *
000218120420     D listPtr         S               *
000219120420     D header          DS                  likeds(tmpl_header) based(listPtr)
000220120420     D heapId          S             10I 0
000221120420      /free
000222120420       cee_createHeap(heapId : *omit : *omit : *omit : *omit);
000223120420
000224120420       // allocate memory for list header
000225120420       cee_getStorage(heapId : %size(tmpl_header) : listPtr : *omit);
000226120420
000227120420       header.id = LIST_ID;
000228120420       header.heapId = heapId;
000229120420       header.size = 0;
000230120420       header.bytes = 0;
000231120420       header.firstEntry = *null;
000232120420       header.lastEntry = *null;
000233120420       header.iteration = -1;
000234120420       header.iterNextEntry = *null;
000235120420       header.iterPrevEntry = *null;
000236120420
000237120420       return listPtr;
000238120420      /end-free
000239120420     P                 E
000240120420
000241120420
000242120420     /**
000243120420      * \brief Dispose list
000244120420      *
000245120420      * The memory for whole list are is released
000246120420      * (deallocated). The list pointer is set to *null;
000247120420      *
000248120420      * <br><br>
000249120420      *
000250120420      * If the passed pointer is already *null the procedure simply returns.
000251120420      *
000252120420      * \author Mihael Schmidt
000253120420      * \date   18.12.2007
000254120420      *
000255120420      * \param Pointer to the list
000256120420      */
000257120420     P list_dispose    B                   export
000258120420     D                 PI
000259120420     D   listPtr                       *
000260120420     D header          DS                  likeds(tmpl_header) based(listPtr)
000261120420      /free
000262120420       if (listPtr = *null);
000263120420         // do nothing
000264120420       else;
000265120420
000266120420         if (isLinkedListImpl(listPtr));
000267120420           cee_discardHeap(header.heapId : *omit);
000268120420           listPtr = *null;
000269120420         endif;
000270120420
000271120420       endif;
000272120420      /end-free
000273120420     P                 E
000274120420
000275120420
000276120420     /**
000277120420      * \brief Add list entry
000278120420      *
000279120420      * Adds an entry at an exact position in the list. If the position is
000280120420      * outside the list the procedure returns <em>*off</em>. The current
000281120420      * entry of the list at that position will be pushed one position down
000282120420      * the list.
000283120420      *
000284120420      * <br><br>
000285120420      *
000286120420      * If no position is passed to the procedure then the entry will be
000287120420      * appended to the end of the list (like <em>addLast</em>).
000288120420      *
000289120420      * \author Mihael Schmidt
000290120420      * \date   18.12.2007
000291120420      *
000292120420      * \param Pointer to the list
000293120420      * \param Pointer to the new value
000294120420      * \param Length of the new value
000295120420      * \param List position for the new value (optional)
000296120420      *
000297120420      * \return *on = entry added the list <br>
000298120420      *         *off = error
000299120420      */
000300120420     P list_add        B                   export
000301120420     D                 PI              N
000302120420     D   listPtr                       *   const
000303120420     D   ptrValue                      *   const
000304120420     D   length                      10U 0 const
000305120420     D   pos                         10U 0 const options(*nopass)
000306120420      *
000307120420     D header          DS                  likeds(tmpl_header) based(listPtr)
000308120420     D nextEntryPtr    S               *
000309120420     D nextEntry       DS                  likeds(tmpl_entry)
000310120420     D                                     based(nextEntryPtr)
000311120420     D prevEntryPtr    S               *
000312120420     D prevEntry       DS                  likeds(tmpl_entry)
000313120420     D                                     based(prevEntryPtr)
000314120420     D newEntryPtr     S               *
000315120420     D newEntry        DS                  likeds(tmpl_entry)
000316120420     D                                     based(newEntryPtr)
000317120420     D tmpPtr          S               *
000318120420     D retVal          S               N   inz(*on)
000319120420      /free
000320120420       if (%parms() = 4);
000321120420
000322120420         if (isLinkedListImpl(listPtr));
000323120420           // check if the position is outside of the list
000324120420           if (pos < 0 or pos > header.size -1);
000325120420             sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
000326120420           endif;
000327120420
000328120420           nextEntryPtr = getListEntryDs(listPtr : pos);
000329120420           if (nextEntryPtr <> *null);
000330120420             if (nextEntry.prev <> *null);
000331120420               prevEntryPtr = nextEntry.prev;
000332120420             else;
000333120420               // must be the start of the list (which has no previous entry)
000334120420             endif;
000335120420
000336120420             //
000337120420             // create new entry
000338120420             //
000339120420
000340120420             // alloc memory for this entry
000341120420             cee_getStorage(header.heapId:%size(tmpl_entry):newEntryPtr:*omit);
000342120420             newEntry.length = length + 1;     // +1 for the null value
000343120420             cee_getStorage(header.heapId : length + 1 : newEntry.value :*omit);
000344120420             newEntry.next = *null;
000345120420             newEntry.prev = *null;
000346120420
000347120420             // copy value to the list entry
000348120420             memcpy(newEntry.value : ptrValue : length);
000349120420
000350120420             // set null to the last byte
000351120420             tmpPtr = newEntry.value + length;
000352120420             memcpy(tmpPtr : %addr(hexNull) : 1);
000353120420
000354120420             // set pointers so that the list is correctly linked again
000355120420             newEntry.prev = prevEntryPtr;
000356120420             newEntry.next = nextEntryPtr;
000357120420             nextEntry.prev = newEntryPtr;
000358120420             if (prevEntryPtr <> *null);
000359120420               prevEntry.next = newEntryPtr;
000360120420             endif;
000361120420
000362120420             // update header
000363120420             header.size += 1;
000364120420             if (newEntry.prev = *null);
000365120420               header.firstEntry = newEntryPtr;
000366120420             endif;
000367120420
000368120420           else;
000369120420             // could not get entry at given position
000370120420             retVal = *off;
000371120420           endif;
000372120420
000373120420         else;
000374120420           retVal = *off;
000375120420         endif;
000376120420
000377120420       else; // append to the end of the list
000378120420         retVal = list_addLast(listPtr : ptrValue : length);
000379120420       endif;
000380120420
000381120420       return retVal;
000382120420      /end-free
000383120420     P                 E
000384120420
000385120420
000386120420     /**
000387120420      * \brief Add list entry to the top of the list
000388120420      *
000389120420      * \author Mihael Schmidt
000390120420      * \date   18.12.2007
000391120420      *
000392120420      * \param Pointer to the list
000393120420      * \param Pointer to new value
000394120420      * \param Length of new value
000395120420      *
000396120420      * \return *on = successful <br>
000397120420      *         *off = error
000398120420      */
000399120420     P list_addFirst   B                   export
000400120420     D                 PI              N
000401120420     D   listPtr                       *
000402120420     D   valuePtr                      *   const
000403120420     D   length                      10U 0 const
000404120420      *
000405120420     D header          DS                  likeds(tmpl_header) based(listPtr)
000406120420     D newEntryPtr     S               *
000407120420     D newEntry        DS                  likeds(tmpl_entry)
000408120420     D                                     based(newEntryPtr)
000409120420     D nextEntryPtr    S               *
000410120420     D nextEntry       DS                  likeds(tmpl_entry)
000411120420     D                                     based(nextEntryPtr)
000412120420     D tmpPtr          S               *
000413120420     D retVal          S               N   inz(*on)
000414120420      /free
000415120420       if (isLinkedListImpl(listPtr));
000416120420
000417120420         //
000418120420         // create new entry
000419120420         //
000420120420
000421120420         // alloc memory for this entry
000422120420         cee_getStorage(header.heapId:%size(tmpl_entry):newEntryPtr:*omit);
000423120420         newEntry.length = length + 1;     // +1 for the null value
000424120420         cee_getStorage(header.heapId : length + 1 : newEntry.value :*omit);
000425120420         newEntry.next = *null;
000426120420         newEntry.prev = *null;
000427120420
000428120420         // copy value to the list entry
000429120420         memcpy(newEntry.value : valuePtr : length);
000430120420
000431120420         // add null
000432120420         tmpPtr = newEntry.value + length;
000433120420         memcpy(tmpPtr : %addr(hexNull) : 1);
000434120420
000435120420         if (header.size > 0);
000436120420           nextEntryPtr = getListEntryDs(listPtr : 0);
000437120420           nextEntry.prev = newEntryPtr;
000438120420           newEntry.next = nextEntryPtr;
000439120420         endif;
000440120420
000441120420         // update header
000442120420         header.size += 1;
000443120420         header.firstEntry = newEntryPtr;
000444120420         if (header.size = 1);
000445120420           header.lastEntry = newEntryPtr;
000446120420         endif;
000447120420
000448120420       endif;
000449120420
000450120420       return retVal;
000451120420      /end-free
000452120420     P                 E
000453120420
000454120420
000455120420     /**
000456120420      * \brief Add list entry to the end of the list
000457120420      *
000458120420      * \author Mihael Schmidt
000459120420      * \date   18.12.2007
000460120420      *
000461120420      * \param Pointer to the list
000462120420      * \param Pointer to new value
000463120420      * \param Length of new value
000464120420      *
000465120420      * \return *on = successful <br>
000466120420      *         *off = error
000467120420      */
000468120420     P list_addLast    B                   export
000469120420     D                 PI              N
000470120420     D   listPtr                       *   const
000471120420     D   valuePtr                      *   const
000472120420     D   length                      10U 0 const
000473120420      *
000474120420     D header          DS                  likeds(tmpl_header) based(listPtr)
000475120420     D newEntryPtr     S               *
000476120420     D newEntry        DS                  likeds(tmpl_entry)
000477120420     D                                     based(newEntryPtr)
000478120420     D prevEntryPtr    S               *
000479120420     D prevEntry       DS                  likeds(tmpl_entry)
000480120420     D                                     based(prevEntryPtr)
000481120420     D tmpPtr          S               *
000482120420     D retVal          S               N   inz(*on)
000483120420      /free
000484120420       if (isLinkedListImpl(listPtr));
000485120420
000486120420         //
000487120420         // create new entry
000488120420         //
000489120420
000490120420         // alloc memory for this entry
000491120420         cee_getStorage(header.heapId:%size(tmpl_entry):newEntryPtr:*omit);
000492120420         newEntry.length = length + 1;     // +1 for the null value
000493120420         cee_getStorage(header.heapId : length + 1 : newEntry.value :*omit);
000494120420         newEntry.next = *null;
000495120420         newEntry.prev = *null;
000496120420
000497120420         // copy value to the list entry
000498120420         memcpy(newEntry.value : valuePtr : length);
000499120420
000500120420         // add null
000501120420         tmpPtr = newEntry.value + length;
000502120420         memcpy(tmpPtr : %addr(hexNull) : 1);
000503120420
000504120420         if (header.size > 0);
000505120420           prevEntryPtr = getListEntryDs(listPtr : header.size -1);
000506120420           prevEntry.next = newEntryPtr;
000507120420           newEntry.prev = prevEntryPtr;
000508120420         endif;
000509120420
000510120420         // update header
000511120420         header.size += 1;
000512120420         header.lastEntry = newEntryPtr;
000513120420         if (header.size = 1);
000514120420           header.firstEntry = newEntryPtr;
000515120420         endif;
000516120420
000517120420       endif;
000518120420
000519120420       return retVal;
000520120420      /end-free
000521120420     P                 E
000522120420
000523120420
000524120420     /**
000525120420      * \brief Add all elements of a list
000526120420      *
000527120420      * Adds all elements of the passed list to the end of this list.
000528120420      * Elements will not be referenced but storage newly allocated.
000529120420      *
000530120420      * \author Mihael Schmidt
000531120420      * \date   18.12.2007
000532120420      *
000533120420      * \param Pointer to the destination list
000534120420      * \param Pointer to the source list
000535120420      *
000536120420      * \return *on = all elements added to list <br>
000537120420      *         *off = not all or none elements added
000538120420      */
000539120420     P list_addAll     B                   export
000540120420     D                 PI              N
000541120420     D   listPtr                       *   const
000542120420     D   srcListPtr                    *   const
000543120420      *
000544120420     D retVal          S               N   inz(*on)
000545120420     D header          DS                  likeds(tmpl_header) based(srcListPtr)
000546120420     D entryPtr        S               *
000547120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
000548120420      /free
000549120420       if (isLinkedListImpl(listPtr) and
000550120420           isLinkedLIstImpl(srcListPtr));
000551120420
000552120420         entryPtr = header.firstEntry;
000553120420         dow (entryPtr <> *null);
000554120420
000555120420           // entry.length -1 => dont include the null value
000556120420           if (not list_add(listPtr : entry.value : entry.length-1));
000557120420             retVal = *off;
000558120420             leave;
000559120420           endif;
000560120420
000561120420           entryPtr = entry.next;
000562120420         enddo;
000563120420       endif;
000564120420
000565120420       return retVal;
000566120420      /end-free
000567120420     P                 E
000568120420
000569120420
000570120420     /**
000571120420      * \brief Remove list entry
000572120420      *
000573120420      * Removes an entry from the list at the given position. If the
000574120420      * position is outside of the list the return value will be <em>*off</em>.
000575120420      *
000576120420      * <br><br>
000577120420      *
000578120420      * The index is 0 (zero) based.
000579120420      *
000580120420      * \author Mihael Schmidt
000581120420      * \date   18.12.2007
000582120420      *
000583120420      * \param Pointer to the list
000584120420      * \param index of the entry in the list (zero-based)
000585120420      *
000586120420      * \return *on = entry removed
000587120420      *         *off = error
000588120420      */
000589120420     P list_remove     B                   export
000590120420     D                 PI              N
000591120420     D   listPtr                       *   const
000592120420     D   index                       10U 0 const
000593120420      *
000594120420     D header          DS                  likeds(tmpl_header) based(listPtr)
000595120420     D ptr             S               *
000596120420     D entry           DS                  likeds(tmpl_entry) based(ptr)
000597120420     D nextEntryPtr    S               *
000598120420     D nextEntry       DS                  likeds(tmpl_entry)
000599120420     D                                     based(nextEntryPtr)
000600120420     D prevEntryPtr    S               *
000601120420     D prevEntry       DS                  likeds(tmpl_entry)
000602120420     D                                     based(prevEntryPtr)
000603120420     D retVal          S               N   inz(*on)
000604120420
000605120420      /free
000606120420       if (isLinkedListImpl(listPtr));
000607120420
000608120420         // check if the position is outside of the list
000609120420         if (index < 0 or index > header.size -1);
000610120420           return *off;
000611120420         endif;
000612120420
000613120420         ptr = getListEntryDs(listPtr : index);
000614120420         if (ptr = *null);
000615120420           return *off;
000616120420         endif;
000617120420
000618120420         nextEntryPtr = entry.next;
000619120420         prevEntryPtr = entry.prev;
000620120420
000621120420         if (prevEntryPtr <> *null);
000622120420           prevEntry.next = nextEntryPtr;
000623120420         endif;
000624120420
000625120420         if (nextEntryPtr <> *null);
000626120420           nextEntry.prev = prevEntryPtr;
000627120420         endif;
000628120420
000629120420         // free memory
000630120420         cee_freeStorage(entry.value : *omit);
000631120420         cee_freeStorage(ptr : *omit);
000632120420
000633120420         // update header
000634120420         header.size -= 1;
000635120420         if (nextEntryPtr = *null);
000636120420           header.lastEntry = prevEntryPtr;
000637120420         endif;
000638120420         if (prevEntryPtr = *null);
000639120420           header.firstEntry = nextEntryPtr;
000640120420         endif;
000641120420
000642120420       endif;
000643120420
000644120420       return retVal;
000645120420      /end-free
000646120420     P                 E
000647120420
000648120420
000649120420     /**
000650120420      * \brief Remove first list entry
000651120420      *
000652120420      * Removes the first entry from the list.
000653120420      *
000654120420      * \author Mihael Schmidt
000655120420      * \date   18.12.2007
000656120420      *
000657120420      * \param Pointer to the list
000658120420      *
000659120420      * \return *on = entry removed <br>
000660120420      *         *off = error
000661120420      */
000662120420     P list_removeFirst...
000663120420     P                 B                   export
000664120420     D                 PI              N
000665120420     D   listPtr                       *   const
000666120420
000667120420      /free
000668120420       return list_remove(listPtr : 0);
000669120420      /end-free
000670120420     P                 E
000671120420
000672120420
000673120420     /**
000674120420      * \brief Remove last list entry
000675120420      *
000676120420      * Removes the last entry from the list.
000677120420      *
000678120420      * \author Mihael Schmidt
000679120420      * \date   18.12.2007
000680120420      *
000681120420      * \param Pointer to the list
000682120420      *
000683120420      * \return *on = entry removed <br>
000684120420      *         *off = error (escape message)
000685120420      */
000686120420     P list_removeLast...
000687120420     P                 B                   export
000688120420     D                 PI              N
000689120420     D   listPtr                       *   const
000690120420      *
000691120420     D header          DS                  likeds(tmpl_header) based(listPtr)
000692120420     D retVal          S               N   inz(*off)
000693120420
000694120420      /free
000695120420       if (isLinkedListImpl(listPtr));
000696120420         retVal = list_remove(listPtr : header.size - 1);
000697120420       endif;
000698120420
000699120420       return retVal;
000700120420      /end-free
000701120420     P                 E
000702120420
000703120420
000704120420     /**
000705120420      * \brief Clear list
000706120420      *
000707120420      * Deletes all entries in the list.
000708120420      *
000709120420      * \author Mihael Schmidt
000710120420      * \date   18.12.2007
000711120420      *
000712120420      * \param Pointer to the list
000713120420      *
000714120420      * \return *on = successful <br>
000715120420      *         *off = error
000716120420      */
000717120420     P list_clear      B                   export
000718120420     D                 PI              N
000719120420     D   listPtr                       *   const
000720120420      *
000721120420     D header          DS                  likeds(tmpl_header) based(listPtr)
000722120420     D tmpPtr          S               *
000723120420     D ptr             S               *
000724120420     D entry           DS                  likeds(tmpl_entry) based(ptr)
000725120420     D retVal          S               N   inz(*off)
000726120420      /free
000727120420       if (isLinkedListImpl(listPtr));
000728120420
000729120420         ptr = header.lastEntry;
000730120420         dow (ptr <> *null);
000731120420           tmpPtr = entry.prev;
000732120420
000733120420           if (entry.value <> *null);
000734120420             cee_freeStorage(entry.value : *omit);
000735120420           endif;
000736120420
000737120420           cee_freeStorage(ptr : *omit);
000738120420           ptr = tmpPtr;
000739120420         enddo;
000740120420
000741120420         // update header
000742120420         header.size = 0;
000743120420         header.firstEntry = *null;
000744120420         header.lastEntry = *null;
000745120420         header.bytes = %size(tmpl_header);
000746120420         header.iteration = -1;
000747120420         header.iterNextEntry = *null;
000748120420         header.iterPrevEntry = *null;
000749120420
000750120420       endif;
000751120420
000752120420       return retVal;
000753120420      /end-free
000754120420     P                 E
000755120420
000756120420
000757120420     /**
000758120420      * \brief Get next entry
000759120420      *
000760120420      * Iterates through the list and gets the next entry. If the iterator is
000761120420      * at the end of the list this method will return <em>null</em>. The
000762120420      * iteration can be aborted early with the procedure <em>
000763120420      * list_resetIteration</em>.
000764120420      *
000765120420      * \author Mihael Schmidt
000766120420      * \date   18.12.2007
000767120420      *
000768120420      * \param Pointer to the list
000769120420      *
000770120420      * \return Pointer to entry or *null if no more entries in list
000771120420      *
000772120420      * \deprecated Use <em>list_iterate</em> instead.
000773120420      */
000774120420     P list_getNext    B                   export
000775120420     D                 PI              *
000776120420     D   listPtr                       *   const
000777120420      *
000778120420      /free
000779120420       return list_iterate(listPtr);
000780120420      /end-free
000781120420     P                 E
000782120420
000783120420
000784120420     /**
000785120420      * \brief Iterate list
000786120420      *
000787120420      * Iterates through the list and returns the next entry. If the iterator is
000788120420      * at the end of the list this method will return <em>null</em>. The
000789120420      * iteration can be aborted early with the procedure <em>list_resetIteration</em>.
000790120420      *
000791120420      * \author Mihael Schmidt
000792120420      * \date   19.2.2011
000793120420      *
000794120420      * \param Pointer to the list
000795120420      *
000796120420      * \return Pointer to entry or *nll if no more entries in list
000797120420      */
000798120420     P list_iterate    B                   export
000799120420     D                 PI              *
000800120420     D   listPtr                       *   const
000801120420      *
000802120420     D header          DS                  likeds(tmpl_header) based(listPtr)
000803120420     D entryPtr        S               *
000804120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
000805120420     D retVal          S               *
000806120420      /free
000807120420       if (isLinkedListImpl(listPtr));
000808120420
000809120420         if (header.iteration + 1 = header.size);
000810120420           list_resetIteration(listPtr);
000811120420           retVal = *null;
000812120420         else;
000813120420           header.iteration += 1;
000814120420
000815120420           if (header.iterNextEntry = *null);
000816120420             entryPtr = getListEntryDs(listPtr : header.iteration);
000817120420           else;
000818120420             entryPtr = header.iterNextEntry;
000819120420           endif;
000820120420
000821120420           header.iterNextEntry = entry.next;
000822120420           header.iterPrevEntry = entry.prev;
000823120420
000824120420           retVal = entry.value;
000825120420         endif;
000826120420
000827120420       endif;
000828120420
000829120420       return retVal;
000830120420      /end-free
000831120420     P                 E
000832120420
000833120420
000834120420     /**
000835120420      * \brief Get previous entry
000836120420      *
000837120420      * Iterates through the list and gets the previous entry. If the iterator is
000838120420      * before the start of the list this method will return <em>null</em>. The
000839120420      * iteration can be aborted early with the procedure <em>list_resetIteration</em>.
000840120420      *
000841120420      * \author Mihael Schmidt
000842120420      * \date   18.12.2007
000843120420      *
000844120420      * \param Pointer to the list
000845120420      *
000846120420      * \return Pointer to entry or *null if no more entries in list
000847120420      */
000848120420     P list_getPrev    B                   export
000849120420     D                 PI              *
000850120420     D   listPtr                       *   const
000851120420      *
000852120420     D header          DS                  likeds(tmpl_header) based(listPtr)
000853120420     D entryPtr        S               *
000854120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
000855120420     D retVal          S               *
000856120420      /free
000857120420       if (isLinkedListImpl(listPtr));
000858120420
000859120420         if (header.iteration = 0);
000860120420           list_resetIteration(listPtr);
000861120420           retVal = *null;
000862120420         else;
000863120420
000864120420           if (header.iteration = -1);
000865120420             header.iteration = header.size;
000866120420           endif;
000867120420
000868120420           header.iteration -= 1;
000869120420
000870120420           if (header.iterPrevEntry = *null);
000871120420             entryPtr = getListEntryDs(listPtr : header.iteration);
000872120420           else;
000873120420             entryPtr = header.iterPrevEntry;
000874120420           endif;
000875120420
000876120420           if (entryPtr = *null);
000877120420             retVal = *null;
000878120420           else;
000879120420             header.iterNextEntry = entry.next;
000880120420             header.iterPrevEntry = entry.prev;
000881120420
000882120420             retVal = entry.value;
000883120420           endif;
000884120420         endif;
000885120420
000886120420       endif;
000887120420
000888120420       return retVal;
000889120420      /end-free
000890120420     P                 E
000891120420
000892120420
000893120420     /**
000894120420      * \brief Abort iteration
000895120420      *
000896120420      * If the iteration through the list should be aborted early this
000897120420      * procedure should be called.
000898120420      *
000899120420      * \author Mihael Schmidt
000900120420      * \date   18.12.2007
000901120420      *
000902120420      * \param Pointer to the list
000903120420      *
000904120420      * \deprecated Use <em>list_resetIteration</em> instead.
000905120420      */
000906120420     P list_abortIteration...
000907120420     P                 B                   export
000908120420     D                 PI
000909120420     D   listPtr                       *   const
000910120420      *
000911120420     D header          DS                  likeds(tmpl_header) based(listPtr)
000912120420      /free
000913120420       list_resetIteration(listPtr);
000914120420      /end-free
000915120420     P                 E
000916120420
000917120420
000918120420     /**
000919120420      * \brief Reset iteration
000920120420      *
000921120420      * Resets the internal iteration state of the list so that the next
000922120420      * call to <em>list_iterate</em> will return the first element.
000923120420      *
000924120420      * \author Mihael Schmidt
000925120420      * \date   19.2.2011
000926120420      *
000927120420      * \param Pointer to the list
000928120420      */
000929120420     P list_resetIteration...
000930120420     P                 B                   export
000931120420     D                 PI
000932120420     D   listPtr                       *   const
000933120420      *
000934120420     D header          DS                  likeds(tmpl_header) based(listPtr)
000935120420      /free
000936120420       if (isLinkedListImpl(listPtr));
000937120420         header.iteration = -1;
000938120420         header.iterNextEntry = *null;
000939120420         header.iterPrevEntry = *null;
000940120420       endif;
000941120420      /end-free
000942120420     P                 E
000943120420
000944120420
000945120420     /**
000946120420      * \brief Replaces an entry in the list
000947120420      *
000948120420      * An element in the list will be replaced. If there is no element
000949120420      * at that position the return value will be <em>*off</em>.
000950120420      *
000951120420      * \author Mihael Schmidt
000952120420      * \date   19.12.2007
000953120420      *
000954120420      * \param Pointer to the list
000955120420      * \param Pointer to new value
000956120420      * \param Length of new value
000957120420      * \param index of new value
000958120420      *
000959120420      * \return *on = entry successfully replaced <br>
000960120420      *         *off = error
000961120420      */
000962120420     P list_replace    B                   export
000963120420     D                 PI              N
000964120420     D   listPtr                       *   const
000965120420     D   ptrValue                      *   const
000966120420     D   lengthValue                 10U 0 const
000967120420     D   index                       10U 0 const
000968120420      *
000969120420     D header          DS                  likeds(tmpl_header) based(listPtr)
000970120420     D entryPtr        S               *
000971120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
000972120420     D retVal          S               N   inz(*on)
000973120420      /free
000974120420       if (isLinkedListImpl(listPtr));
000975120420
000976120420         // check if the position is outside of the list
000977120420         if (index < 0 or index > header.size -1);
000978120420           return *off;
000979120420         endif;
000980120420
000981120420         entryPtr = getListEntryDs(listPtr : index);
000982120420         entry.length = lengthValue + 1;
000983120420         cee_reallocateStorage(entry.value : lengthValue + 1 : *omit); // +1 for the null byte
000984120420
000985120420         // copy value to the list entry
000986120420         memcpy(ptrValue : entry.value : lengthValue);
000987120420
000988120420         // set null to the last byte
000989120420         memcpy(entry.value + lengthValue : %addr(hexNull) : 1);
000990120420       endif;
000991120420
000992120420       return retVal;
000993120420      /end-free
000994120420     P                 E
000995120420
000996120420
000997120420     /**
000998120420      * \brief Contains entry
000999120420      *
001000120420      * Checks if this list contains the passed entry.
001001120420      *
001002120420      * \author Mihael Schmidt
001003120420      * \date   19.12.2007
001004120420      *
001005120420      * \param Pointer to the list
001006120420      * \param Pointer to value
001007120420      * \param Length of value
001008120420      *
001009120420      * \return *on = list contains value <br>
001010120420      *         *off = list does not contain value
001011120420      */
001012120420     P list_contains   B                   export
001013120420     D                 PI              N
001014120420     D   listPtr                       *   const
001015120420     D   valuePtr                      *   const
001016120420     D   valueLength                 10U 0 const
001017120420      *
001018120420     D header          DS                  likeds(tmpl_header) based(listPtr)
001019120420     D entryPtr        S               *
001020120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001021120420     D retVal          S               N   inz(*off)
001022120420      /free
001023120420       if (isLinkedListImpl(listPtr));
001024120420
001025120420         entryPtr = header.firstEntry;
001026120420         dow (entryPtr <> *null);
001027120420           if (valueLength = entry.length - 1 and
001028120420               memcmp(valuePtr : entry.value : valueLength) = 0); // dont include the null
001029120420             retVal = *on;
001030120420             leave;
001031120420           endif;
001032120420
001033120420           entryPtr = entry.next;
001034120420         enddo;
001035120420
001036120420       endif;
001037120420
001038120420       return retVal;
001039120420      /end-free
001040120420     P                 E
001041120420
001042120420
001043120420     /**
001044120420      * \brief Check if list is empty
001045120420      *
001046120420      * Checks if the list is empty.
001047120420      *
001048120420      * \author Mihael Schmidt
001049120420      * \date   19.12.2007
001050120420      *
001051120420      * \param Pointer to the list
001052120420      *
001053120420      * \return *on = list is empty <br>
001054120420      *         *off = list is not empty
001055120420      */
001056120420     P list_isEmpty    B                   export
001057120420     D                 PI              N
001058120420     D   listPtr                       *   const
001059120420      *
001060120420     D header          DS                  likeds(tmpl_header) based(listPtr)
001061120420     D retVal          S               N
001062120420      /free
001063120420       if (isLinkedListImpl(listPtr));
001064120420
001065120420         if (header.size = 0);
001066120420           retVal = *on;
001067120420         else;
001068120420           retVal = *off;
001069120420         endif;
001070120420
001071120420       endif;
001072120420
001073120420       return retVal;
001074120420      /end-free
001075120420     P                 E
001076120420
001077120420
001078120420     /**
001079120420      * \brief Get entry
001080120420      *
001081120420      * Returns a list entry specified by the passed index.
001082120420      *
001083120420      * \author Mihael Schmidt
001084120420      * \date   19.12.2007
001085120420      *
001086120420      * \param Pointer to the list
001087120420      * \param List position
001088120420      *
001089120420      * \return Pointer to a null terminated string or
001090120420      *         *null if an error occured or there is no
001091120420      *         entry at that position
001092120420      */
001093120420     P list_get        B                   export
001094120420     D                 PI              *
001095120420     D   listPtr                       *   const
001096120420     D   index                       10U 0 const
001097120420      *
001098120420     D header          DS                  likeds(tmpl_header) based(listPtr)
001099120420     D entryPtr        S               *
001100120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001101120420     D retVal          S               *
001102120420     D tmp             S           1000A   based(entry.value)
001103120420      /free
001104120420       if (isLinkedListImpl(listPtr));
001105120420         // check if list is empty or the position is outside of the list
001106120420         if (header.size = 0);
001107120420           return *null;
001108120420         elseif (index < 0 or index > header.size -1);
001109120420           return *null;
001110120420         endif;
001111120420
001112120420         entryPtr = getListEntryDs(listPtr : index);
001113120420         retVal = entry.value;
001114120420       endif;
001115120420
001116120420       return retVal;
001117120420      /end-free
001118120420     P                 E
001119120420
001120120420
001121120420     /**
001122120420      * \brief Get first entry
001123120420      *
001124120420      * Returns the first entry of the list.
001125120420      *
001126120420      * \author Mihael Schmidt
001127120420      * \date   19.12.2007
001128120420      *
001129120420      * \param Pointer to the list
001130120420      *
001131120420      * \return Pointer to a null terminated string or
001132120420      *         *null if the list is empty or an error occured
001133120420      */
001134120420     P list_getFirst   B                   export
001135120420     D                 PI              *
001136120420     D   listPtr                       *   const
001137120420      *
001138120420     D retVal          S               *   inz(*null)
001139120420      /free
001140120420       if (isLinkedListImpl(listPtr));
001141120420         retVal = list_get(listPtr : 0);
001142120420       endif;
001143120420
001144120420       return retVal;
001145120420      /end-free
001146120420     P                 E
001147120420
001148120420
001149120420     /**
001150120420      * \brief Get last entry
001151120420      *
001152120420      * Returns the last entry of the list.
001153120420      *
001154120420      * \author Mihael Schmidt
001155120420      * \date   19.12.2007
001156120420      *
001157120420      * \param Pointer to the list
001158120420      *
001159120420      * \return Pointer to a null terminated string or
001160120420      *         *null if the list is empty or an error occured
001161120420      */
001162120420     P list_getLast    B                   export
001163120420     D                 PI              *
001164120420     D   listPtr                       *   const
001165120420      *
001166120420     D header          DS                  likeds(tmpl_header) based(listPtr)
001167120420     D retVal          S               *   inz(*null)
001168120420      /free
001169120420       if (isLinkedListImpl(listPtr));
001170120420         retVal = list_get(listPtr : header.size -1);
001171120420       endif;
001172120420
001173120420       return retVal;
001174120420      /end-free
001175120420     P                 E
001176120420
001177120420
001178120420     /**
001179120420      * \brief Index of entry
001180120420      *
001181120420      * Returns the index of the passed entry or -1 if the entry could not
001182120420      * be found in the list.
001183120420      *
001184120420      * \author Mihael Schmidt
001185120420      * \date   19.12.2007
001186120420      *
001187120420      * \param Pointer to the list
001188120420      * \param Pointer to the value
001189120420      * \param Length of the value
001190120420      *
001191120420      * \return index of the entry or -1 if entry not in list
001192120420      */
001193120420     P list_indexOf    B                   export
001194120420     D                 PI            10I 0
001195120420     D   listPtr                       *   const
001196120420     D   valuePtr                      *   const
001197120420     D   valueLength                 10U 0 const
001198120420      *
001199120420     D header          DS                  likeds(tmpl_header) based(listPtr)
001200120420     D entryPtr        S               *
001201120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001202120420     D i               S             10I 0 inz(-1)
001203120420     D retVal          S             10I 0 inz(-1)
001204120420      /free
001205120420       if (isLinkedListImpl(listPtr));
001206120420
001207120420         entryPtr = header.firstEntry;
001208120420         dow (entryPtr <> *null);
001209120420           i += 1;
001210120420
001211120420           if (valueLength = entry.length - 1 and
001212120420               memcmp(valuePtr : entry.value : valueLength) = 0); // dont include the null
001213120420             retVal = i;
001214120420             leave;
001215120420           endif;
001216120420
001217120420           entryPtr = entry.next;
001218120420         enddo;
001219120420
001220120420       endif;
001221120420
001222120420       return retVal;
001223120420      /end-free
001224120420     P                 E
001225120420
001226120420
001227120420     /**
001228120420      * \brief Last index of entry
001229120420      *
001230120420      * Returns the last indes of the passed entry or -1 if the entry
001231120420      * could not be found in the list.
001232120420      *
001233120420      * \author Mihael Schmidt
001234120420      * \date   19.12.2007
001235120420      *
001236120420      * \param Pointer to the list
001237120420      * \param Pointer to the value
001238120420      * \param Length of the value
001239120420      *
001240120420      * \return index of the entry or -1 if entry not in list
001241120420      */
001242120420     P list_lastIndexOf...
001243120420     P                 B                   export
001244120420     D                 PI            10I 0
001245120420     D   listPtr                       *   const
001246120420     D   valuePtr                      *   const
001247120420     D   valueLength                 10U 0 const
001248120420      *
001249120420      *
001250120420     D header          DS                  likeds(tmpl_header) based(listPtr)
001251120420     D entryPtr        S               *
001252120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001253120420     D i               S             10I 0
001254120420     D retVal          S             10I 0 inz(-1)
001255120420      /free
001256120420       if (isLinkedListImpl(listPtr));
001257120420
001258120420         entryPtr = header.lastEntry;
001259120420         i = header.size;
001260120420         dow (entryPtr <> *null);
001261120420           i -= 1;
001262120420
001263120420           if (valueLength = entry.length - 1 and
001264120420               memcmp(valuePtr : entry.value : valueLength) = 0); // dont include the null
001265120420             retVal = i;
001266120420             leave;
001267120420           endif;
001268120420
001269120420           entryPtr = entry.prev;
001270120420         enddo;
001271120420
001272120420       endif;
001273120420
001274120420       return retVal;
001275120420      /end-free
001276120420     P                 E
001277120420
001278120420
001279120420     /**
001280120420      * \brief To character array
001281120420      *
001282120420      * Copies all entries of this list to the passed array. Entries will be
001283120420      * truncated if they are too big for the array. If the array is not big
001284120420      * enough, the last entries will be silently dropped.
001285120420      *
001286120420      * \author Mihael Schmidt
001287120420      * \date   19.12.2007
001288120420      *
001289120420      * \param Pointer to the list
001290120420      * \param Pointer to the array
001291120420      * \param Element count
001292120420      * \param Element length
001293120420      *
001294120420      */
001295120420     P list_toCharArray...
001296120420     P                 B                   export
001297120420     D                 PI
001298120420     D   listPtr                       *   const
001299120420     D   arrayPtr                      *   const
001300120420     D   count                       10U 0 const
001301120420     D   length                      10U 0 const
001302120420      *
001303120420     D header          DS                  likeds(tmpl_header) based(listPtr)
001304120420     D entryPtr        S               *
001305120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001306120420     D i               S             10I 0
001307120420     D arrayElemPtr    S               *
001308120420     D tmpLength       S             10I 0
001309120420      /free
001310120420       if (isLinkedListImpl(listPtr));
001311120420         if (header.size = 0);
001312120420           return;
001313120420         endif;
001314120420
001315120420         for i = 0 to header.size;
001316120420           if (count > i);
001317120420             entryPtr = getListEntryDs(listPtr : i);
001318120420             arrayElemPtr = arrayPtr + (i * length);
001319120420
001320120420             if (entry.length < length);
001321120420               tmpLength = entry.length;
001322120420             else;
001323120420               tmpLength = length;
001324120420             endif;
001325120420
001326120420             memcpy(arrayElemPtr : entry.value : tmpLength);
001327120420
001328120420           endif;
001329120420         endfor;
001330120420
001331120420       endif;
001332120420      /end-free
001333120420     P                 E
001334120420
001335120420
001336120420     /**
001337120420      * \brief Check for linked list implementation
001338120420      *
001339120420      * Checks if the pointer points to a linked list implementation.
001340120420      * The linked list implementation of this service program has
001341120420      * an id in the first 20 bytes of the list header.
001342120420      *
001343120420      * <br><br>
001344120420      *
001345120420      * If the pointer does not point to a list implementation an
001346120420      * escape message will be sent.
001347120420      *
001348120420      * \author Mihael Schmidt
001349120420      * \date   23.12.2007
001350120420      *
001351120420      * \param Pointer to the list
001352120420      *
001353120420      * \return *on = is linked list implementation <br>
001354120420      *         *off = is no linked list implementation (escape message)
001355120420      */
001356120420     P isLinkedListImpl...
001357120420     P                 B                   export
001358120420     D                 PI              N
001359120420     D   listPtr                       *   const
001360120420      *
001361120420     D header          DS                  likeds(tmpl_header) based(listPtr)
001362120420     D isList          S               N
001363120420      /free
001364120420       monitor;
001365120420         if (header.id = LIST_ID);
001366120420           isList = *on;
001367120420         else;
001368120420           isList = *off;
001369120420         endif;
001370120420
001371120420         on-error *all;
001372120420           isList = *off;
001373120420       endmon;
001374120420
001375120420       if (not isList);
001376120420         sendEscapeMessage(MSG_NO_LIST_IMPL);
001377120420       endif;
001378120420
001379120420       return isList;
001380120420      /end-free
001381120420     P                 E
001382120420
001383120420
001384120420     /**
001385120420      * \brief Send Escape Message
001386120420      *
001387120420      * Sends an escape message with the specified id.
001388120420      *
001389120420      * \author Mihael Schmidt
001390120420      * \date   23.12.2007
001391120420      *
001392120420      * \param Message id
001393120420      */
001394120420     P sendEscapeMessage...
001395120420     P                 B                   export
001396120420     D                 PI
001397120420     D   id                          10I 0 const
001398120420      *
001399120420     D sendProgramMessage...
001400120420     D                 PR                  extpgm('QMHSNDPM')
001401120420     D  szMsgID                       7A   const
001402120420     D  szMsgFile                    20A   const
001403120420     D  szMsgData                  6000A   const  options(*varsize)
001404120420     D  nMsgDataLen                  10I 0 const
001405120420     D  szMsgType                    10A   const
001406120420     D  szCallStkEntry...
001407120420     D                               10A   const
001408120420     D  nRelativeCallStkEntry...
001409120420     D                               10I 0 const
001410120420     D  szRtnMsgKey                   4A
001411120420     D  error                       265A   options(*varsize)
001412120420      *
001413120420     D msgdata         S            512A
001414120420     D msgkey          S              4A
001415120420     D apiError        S            265A
001416120420      /free
001417120420       if (id = MSG_NO_LIST_IMPL);
001418120420         msgdata = 'The pointer does not point to a list data structure.';
001419120420       elseif (id = MSG_POSITION_OUT_OF_BOUNDS);
001420120420         msgdata = 'The index points outside the list. No such element in ' +
001421120420                   'the list.';
001422120420       elseif (id = MSG_INVALID_VALUE_TYPE);
001423120420         msgdata = 'The requested type does not correspond to the list ' +
001424120420                   'entry type.';
001425120420       endif;
001426120420
001427120420       sendProgramMessage('CPF9898' :
001428120420                          'QCPFMSG   *LIBL     ' :
001429120420                          %trimr(msgdata) :
001430120420                          %len(%trimr(msgdata)) :
001431120420                          '*ESCAPE   ' :
001432120420                          '*PGMBDY' :
001433120420                          0 :
001434120420                          msgkey :
001435120420                          apiError);
001436120420      /end-free
001437120420     P                 E
001438120420
001439120420
001440120420     /**
001441120420      * \brief Get list entry data structure
001442120420      *
001443120420      * Returns the data structure of a list entry.
001444120420      *
001445120420      * \author Mihael Schmidt
001446120420      * \date   23.12.2007
001447120420      *
001448120420      * \param Pointer to the list
001449120420      * \param List position (zero-based)
001450120420      *
001451120420      * \return Pointer to list entry or *null
001452120420      */
001453120420     P getListEntryDs...
001454120420     P                 B                   export
001455120420     D                 PI              *
001456120420     D   listPtr                       *   const
001457120420     D   pos                         10I 0 const
001458120420      *
001459120420     D i               S             10I 0
001460120420     D header          DS                  likeds(tmpl_header) based(listPtr)
001461120420     D entryPtr        S               *
001462120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001463120420      /free
001464120420       monitor;
001465120420         if (pos < header.size / 2);
001466120420           // walk through the list from the start to the end
001467120420           entryPtr = header.firstEntry;
001468120420           for i = 0 to pos-1;
001469120420             if (entryPtr = *null);
001470120420               leave;
001471120420             endif;
001472120420
001473120420             entryPtr = entry.next;
001474120420           endfor;
001475120420
001476120420         else;
001477120420           // walk through the list from the end to the start
001478120420           entryPtr = header.lastEntry;
001479120420           for i = header.size -1 downto pos + 1;
001480120420             if (entryPtr = *null);
001481120420               leave;
001482120420             endif;
001483120420
001484120420             entryPtr = entry.prev;
001485120420           endfor;
001486120420
001487120420         endif;
001488120420
001489120420         on-error *all;
001490120420           entryPtr = *null;
001491120420       endmon;
001492120420
001493120420       return entryPtr;
001494120420      /end-free
001495120420     P                 E
001496120420
001497120420     /**
001498120420      * \brief Get list size
001499120420      *
001500120420      * Returns the number elements in the list.
001501120420      *
001502120420      * \author Mihael Schmidt
001503120420      * \date   16.01.2008
001504120420      *
001505120420      * \param Pointer to the list
001506120420      *
001507120420      * \return number of elements in the list or -1 if an error occurs
001508120420      */
001509120420     P list_size       B                   export
001510120420     D                 PI            10U 0
001511120420     D  listPtr                        *   const
001512120420      *
001513120420     D header          DS                  likeds(tmpl_header) based(listPtr)
001514120420      /free
001515120420       if (isLinkedListImpl(listPtr));
001516120420         return header.size;
001517120420       else;
001518120420         return -1;
001519120420       endif;
001520120420      /end-free
001521120420     P                 E
001522120420
001523120420
001524120420     /**
001525120420      * \brief Create sublist
001526120420      *
001527120420      * Creates a list with copies of a part of the passed list.
001528120420      *
001529120420      * \author Mihael Schmidt
001530120420      * \date   16.1.2008
001531120420      *
001532120420      * \param Pointer to the list
001533120420      * \param start of the index to copy
001534120420      * \param number of elements to copy
001535120420      *
001536120420      * \return new list
001537120420      */
001538120420     P list_sublist    B                   export
001539120420     D                 PI              *
001540120420     D   listPtr                       *   const
001541120420     D   startIndex                  10U 0 const
001542120420     D   length                      10U 0 const options(*nopass)
001543120420      *
001544120420     D header          DS                  likeds(tmpl_header) based(listPtr)
001545120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001546120420     D newListPtr      S               *
001547120420     D i               S             10I 0
001548120420     D endIndex        S             10I 0
001549120420      /free
001550120420       if (isLinkedListImpl(listPtr));
001551120420
001552120420         if (%parms() = 2);
001553120420           endIndex = header.size -1;
001554120420         else;
001555120420           endIndex = startIndex + length - 1;
001556120420         endif;
001557120420
001558120420         if (startIndex < 0);
001559120420           return *null;
001560120420         endif;
001561120420
001562120420         newListPtr = list_create();
001563120420
001564120420         entryPtr = getListEntryDs(listPtr : startIndex);
001565120420
001566120420         for i = startIndex to endIndex;
001567120420           if (header.size > i);
001568120420             list_add(newListPtr : entry.value : entry.length - 1);
001569120420             entryPtr = entry.next;
001570120420           else;
001571120420             leave;
001572120420           endif;
001573120420         endfor;
001574120420
001575120420         return newListPtr;
001576120420
001577120420       else;
001578120420         return *null;
001579120420       endif;
001580120420      /end-free
001581120420     P                 E
001582120420
001583120420
001584120420     /**
001585120420      * \brief Rotate list by n positions
001586120420      *
001587120420      * Rotatas items in the list by the given number.
001588120420      *
001589120420      * <br><br>
001590120420      *
001591120420      * The elements from the end will be pushed to the front.
001592120420      * A rotation of one will bring the last element to the first
001593120420      * position and the first element will become the second element
001594120420      * (pushed one position down the list).
001595120420      *
001596120420      * <br><br>
001597120420      *
001598120420      * Only a forward rotation is possible. No negative number of
001599120420      * rotations are valid.
001600120420      *
001601120420      * <br><br>
001602120420      *
001603120420      * The number of rotations may even be greater than the size of
001604120420      * the list. Example: List size 4, rotation number 5 = rotation
001605120420      * number 1.
001606120420      *
001607120420      * \author Mihael Schmidt
001608120420      * \date   23.01.2008
001609120420      *
001610120420     * \param Pointer to the list
001611120420      * \param Number positions to rotate list
001612120420      */
001613120420     P list_rotate     B                   export
001614120420     D                 PI
001615120420     D   listPtr                       *   const
001616120420     D   rotatePos                   10I 0 const
001617120420      *
001618120420     D header          DS                  likeds(tmpl_header) based(listPtr)
001619120420     D newStartPtr     S               *
001620120420     D newStartEntry   DS                  likeds(tmpl_entry) based(newStartPtr)
001621120420     D newEndPtr       S               *
001622120420     D newEndEntry     DS                  likeds(tmpl_entry) based(newEndPtr)
001623120420     D firstPtr        S               *
001624120420     D firstEntry      DS                  likeds(tmpl_entry) based(firstPtr)
001625120420     D lastPtr         S               *
001626120420     D lastEntry       DS                  likeds(tmpl_entry) based(lastPtr)
001627120420     D absRotPos       S             10I 0
001628120420      /free
001629120420       if (isLinkedListImpl(listPtr));
001630120420         if (header.size = 0);
001631120420           return;
001632120420         endif;
001633120420
001634120420         absRotPos = %rem(rotatePos : list_size(listPtr));
001635120420
001636120420         if (absRotPos > 0);
001637120420           firstPtr = header.firstEntry;
001638120420           lastPtr = header.lastEntry;
001639120420
001640120420           // connect the ends of the list
001641120420           firstEntry.prev = lastPtr;
001642120420           lastEntry.next = firstPtr;
001643120420
001644120420           // set new start entry
001645120420           newStartPtr = getListEntryDs(listPtr :
001646120420                                        list_size(listPtr) - absRotPos);
001647120420           // set new end entry
001648120420           newEndPtr = newStartEntry.prev;
001649120420
001650120420           // disconnect new end and new start entry
001651120420           newEndEntry.next = *null;
001652120420           newStartEntry.prev = *null;
001653120420
001654120420           // update header
001655120420           header.firstEntry = newStartPtr;
001656120420           header.lastEntry = newEndPtr;
001657120420         endif;
001658120420
001659120420       endif;
001660120420      /end-free
001661120420     P                 E
001662120420
001663120420
001664120420     /**
001665120420      * \brief Swap list items
001666120420      *
001667120420      *
001668120420      * \author Mihael Schmidt
001669120420      * \date   23.01.2008
001670120420      *
001671120420      * \param Pointer to the list
001672120420      * \param List item to swap
001673120420      * \param List item to swap
001674120420      */
001675120420     P list_swap       B                   export
001676120420     D                 PI              N
001677120420     D   listPtr                       *   const
001678120420     D   itemPos1                    10U 0 const
001679120420     D   itemPos2                    10U 0 const
001680120420      /free
001681120420       if (isLinkedListImpl(listPtr));
001682120420         return internal_swap(listPtr : itemPos1 : itemPos2);
001683120420       else;
001684120420         return *off;
001685120420       endif;
001686120420      /end-free
001687120420     P                 E
001688120420
001689120420
001690120420     P internal_swap   B                   export
001691120420     D                 PI              N
001692120420     D   listPtr                       *   const
001693120420     D   itemPos1                    10U 0 const options(*omit)
001694120420     D   itemPos2                    10U 0 const options(*omit)
001695120420     D   itemPtr1                      *   const options(*nopass)
001696120420     D   itemPtr2                      *   const options(*nopass)
001697120420      *
001698120420     D header          DS                  likeds(tmpl_header) based(listPtr)
001699120420      *
001700120420     D entryPtr1       S               *
001701120420     D entry1          DS                  likeds(tmpl_entry) based(entryPtr1)
001702120420     D entryPtr1P      S               *
001703120420     D entry1P         DS                  likeds(tmpl_entry) based(entryPtr1P)
001704120420     D entryPtr1N      S               *
001705120420     D entry1N         DS                  likeds(tmpl_entry) based(entryPtr1N)
001706120420      *
001707120420     D entryPtr2       S               *
001708120420     D entry2          DS                  likeds(tmpl_entry) based(entryPtr2)
001709120420     D entryPtr2P      S               *
001710120420     D entry2P         DS                  likeds(tmpl_entry) based(entryPtr2P)
001711120420     D entryPtr2N      S               *
001712120420     D entry2N         DS                  likeds(tmpl_entry) based(entryPtr2N)
001713120420      *
001714120420     D tmpPtr          S               *
001715120420      /free
001716120420       if (%parms() = 3);
001717120420
001718120420         // check both items point to the same entry
001719120420         if (itemPos1 = itemPos2);
001720120420           return *on;
001721120420         endif;
001722120420
001723120420         // check if item is out of bounds
001724120420         if (itemPos1 < 0 or
001725120420             itemPos2 < 0 or
001726120420             itemPos1 >= header.size or
001727120420             itemPos2 >= header.size);
001728120420           return *off;
001729120420         endif;
001730120420
001731120420         entryPtr1 = getListEntryDs(listPtr : itemPos1);
001732120420         entryPtr2 = getListEntryDs(listPtr : itemPos2);
001733120420
001734120420       elseif (%parms() = 5);
001735120420         entryPtr1 = itemPtr1;
001736120420         entryPtr2 = itemPtr2;
001737120420       else;
001738120420         return *off;
001739120420       endif;
001740120420
001741120420         // check if the entries are valid
001742120420         if (entryPtr1 <> *null and entryPtr2 <> *null);
001743120420           entryPtr1P = entry1.prev;
001744120420           entryPtr1N = entry1.next;
001745120420           entryPtr2P = entry2.prev;
001746120420           entryPtr2N = entry2.next;
001747120420
001748120420
001749120420           // check if the two nodes are neighbouring nodes
001750120420           if (entry1.next = entryPtr2);
001751120420             entry1.next = entry2.next;
001752120420             entry2.next = entryPtr1;
001753120420
001754120420             entry2.prev = entry1.prev;
001755120420             entry1.prev = entryPtr2;
001756120420
001757120420             if (entryPtr1P <> *null);
001758120420               entry1P.next = entryPtr2;
001759120420             endif;
001760120420
001761120420             if (entryPtr2N <> *null);
001762120420               entry2N.prev = entryPtr1;
001763120420             endif;
001764120420
001765120420           elseif (entry1.prev = entryPtr2); // neighbouring nodes (other way round)
001766120420             entry2.next = entry1.next;
001767120420             entry1.next = entryPtr2;
001768120420
001769120420             entry1.prev = entry2.prev;
001770120420             entry2.prev = entryPtr1;
001771120420
001772120420
001773120420             if (entryPtr1N <> *null);
001774120420               entry1N.prev = entryPtr2;
001775120420             endif;
001776120420
001777120420             if (entryPtr2P <> *null);
001778120420               entry2P.next = entryPtr1;
001779120420             endif;
001780120420
001781120420           else; // no neighbours
001782120420             tmpPtr = entry1.next;
001783120420             entry1.next = entry2.next;
001784120420             entry2.next = tmpPtr;
001785120420
001786120420             tmpPtr = entry1.prev;
001787120420             entry1.prev = entry2.prev;
001788120420             entry2.prev = tmpPtr;
001789120420
001790120420             if (entryPtr1P <> *null);
001791120420               entry1P.next = entryPtr2;
001792120420             endif;
001793120420
001794120420             if (entryPtr1N <> *null);
001795120420               entry1N.prev = entryPtr2;
001796120420             endif;
001797120420
001798120420             if (entryPtr2P <> *null);
001799120420               entry2P.next = entryPtr1;
001800120420             endif;
001801120420
001802120420             if (entryPtr2N <> *null);
001803120420               entry2N.prev = entryPtr1;
001804120420             endif;
001805120420
001806120420           endif;
001807120420
001808120420
001809120420           if (entry1.prev = *null);         // check if it is the first item
001810120420             header.firstEntry = entryPtr1;
001811120420           endif;
001812120420
001813120420           if (entry2.prev = *null);         // check if it is the first item
001814120420             header.firstEntry = entryPtr2;
001815120420           endif;
001816120420
001817120420           if (entry1.next = *null);         // check if it is the last item
001818120420             header.lastEntry = entryPtr1;
001819120420           endif;
001820120420
001821120420           if (entry2.next = *null);         // check if it is the last item
001822120420             header.lastEntry = entryPtr2;
001823120420           endif;
001824120420
001825120420           return *on;
001826120420         else;
001827120420           return *off;
001828120420         endif;
001829120420
001830120420      /end-free
001831120420     P                 E
001832120420
001833120420
001834120420     /**
001835120420      * \brief Execute procedure for every list item
001836120420      *
001837120420      * The passed procedure will be executed for every item
001838120420      * in the list.
001839120420      *
001840120420      * <br><br>
001841120420      *
001842120420      * The user can pass data through a pointer to the procedure.
001843120420      * The pointer will not be touched by this procedure itself, so it
001844120420      * can be *null.
001845120420      *
001846120420      * <br><br>
001847120420      *
001848120420      * The value of list entry can be changed through the passed procedure
001849120420      * but not the size of the entry/allocated memory.
001850120420      *
001851120420      * \author Mihael Schmidt
001852120420      * \date   23.01.2008
001853120420      *
001854120420      * \param Pointer to the list
001855120420      * \param Procedure pointer
001856120420      * \param Pointer to user data (optional)
001857120420      */
001858120420     P list_foreach...
001859120420     P                 B                   export
001860120420     D                 PI
001861120420     D   listPtr                       *   const
001862120420     D   procPtr                       *   const procptr
001863120420     D   userData                      *   const options(*nopass)
001864120420      *
001865120420     D foreachProc     PR                  extproc(procPtr)
001866120420     D   valuePtr                      *   const
001867120420     D   userData                      *   const options(*nopass)
001868120420      *
001869120420     D header          DS                  likeds(tmpl_header) based(listPtr)
001870120420     D ptr             S               *
001871120420     D entry           DS                  likeds(tmpl_entry) based(ptr)
001872120420     D userDataPassed  S               N
001873120420      /free
001874120420       userDataPassed = (%parms() = 3);
001875120420
001876120420       if (isLinkedListImpl(listPtr));
001877120420         ptr = header.firstEntry;
001878120420         dow (ptr <> *null);
001879120420
001880120420           if (userDataPassed);
001881120420             foreachProc(entry.value : userData);
001882120420           else;
001883120420             foreachProc(entry.value);
001884120420           endif;
001885120420
001886120420           ptr = entry.next;
001887120420         enddo;
001888120420       endif;
001889120420      /end-free
001890120420     P                 E
001891120420
001892120420
001893120420     /**
001894120420      * \brief Return character representation of list
001895120420      *
001896120420      * Returns a string with the list items separated either by
001897120420      * the passed or default separator. The items can be
001898120420      * enclosed by a passed character. The maximum character length
001899120420      * returned is 65535. Every character/item after that will be
001900120420      * dropped silently. Items will not be trimmed for this operation.
001901120420      *
001902120420      * <br><br>
001903120420      *
001904120420      * If the third parameter is passed, the third parameter will be
001905120420      * pre- and appended to the item. If the fourth parameter is also
001906120420      * passed the third parameter will be prepended to the item and the
001907120420      * fourth parameter will be appended to the item.
001908120420      *
001909120420      * \author Mihael Schmidt
001910120420      * \date   08.02.2008
001911120420      *
001912120420      * \param Pointer to the list
001913120420      * \param separator (default: ,)
001914120420      * \param enclosing character (default: nothing)
001915120420      * \param enclosing character at the end of item (default: nothing)
001916120420      *
001917120420      * \return character representation of all list items
001918120420      */
001919120420     P list_toString   B                   export
001920120420     D                 PI         65535A   varying
001921120420     D   listPtr                       *   const
001922120420     D   pSeparator                   1A   const varying options(*omit:*nopass)
001923120420     D   pEnclosing                 100A   const varying options(*nopass)
001924120420     D   pEnclosingEnd...
001925120420     D                              100A   const varying options(*nopass)
001926120420      *
001927120420     D noSeparator     S               n   inz(*off)
001928120420     D separator       S              1A   inz(',')
001929120420     D enclosingStart...
001930120420     D                 S            100A   varying
001931120420     D enclosingEnd...
001932120420     D                 S            100A   varying
001933120420     D valuePtr        S               *
001934120420     D retVal          S          65535A   varying
001935120420      /free
001936120420       if (isLinkedListImpl(listPtr));
001937120420
001938120420         // check if separator is passed
001939120420         if (%parms() >= 2 and %addr(pSeparator) <> *null);
001940120420           noSeparator = (%len(pSeparator) = 0);
001941120420           separator = pSeparator;
001942120420         endif;
001943120420
001944120420         // check if enclosing characters are passed
001945120420         if (%parms() >= 3);
001946120420           enclosingStart = pEnclosing;
001947120420           enclosingEnd = pEnclosing;
001948120420         endif;
001949120420
001950120420         // check if we should use different chars for start and end of item
001951120420         if (%parms() = 4);
001952120420           enclosingEnd = pEnclosingEnd;
001953120420         endif;
001954120420
001955120420         // process list items
001956120420         valuePtr = list_getNext(listPtr);
001957120420         dow (valuePtr <> *null);
001958120420           if (noSeparator);
001959120420             retVal += enclosingStart + %str(valuePtr) + enclosingEnd;
001960120420           else;
001961120420             retVal += enclosingStart + %str(valuePtr) + enclosingEnd +
001962120420                       separator;
001963120420           endif;
001964120420
001965120420           valuePtr = list_getNext(listPtr);
001966120420         enddo;
001967120420
001968120420         // remove the last separator
001969120420         if (not noSeparator and %len(retVal) > 0);
001970120420           %len(retVal) = %len(retVal) -1;
001971120420         endif;
001972120420       endif;
001973120420
001974120420       return retVal;
001975120420      /end-free
001976120420     P                 E
001977120420
001978120420
001979120420     /**
001980120420      * \brief Split character string
001981120420      *
001982120420      * The passed character string will be split into tokens by either
001983120420      * a passed or the default separator. All tokens will be added to
001984120420      * a new list which will be returned.
001985120420      *
001986120420      * <br><br>
001987120420      *
001988120420      * Empty (but not blank) values will be dropped silently.
001989120420      *
001990120420      * \author Mihael Schmidt
001991120420      * \date   08.02.2008
001992120420      *
001993120420      * \param Character string (null-terminated)
001994120420      * \param Separator (default: ;)
001995120420      *
001996120420      * \return Pointer to the filled list
001997120420      */
001998120420     P list_split      B                   export
001999120420     D                 PI              *   opdesc
002000120420     D   pString                  65535A   const options(*varsize)
002001120420     D   pSeparator                   1A   const options(*nopass)
002002120420      *
002003120420     D descType        S             10I 0
002004120420     D dataType        S             10I 0
002005120420     D descInfo1       S             10I 0
002006120420     D descInfo2       S             10I 0
002007120420     D length          S             10I 0
002008120420      *
002009120420     D list            S               *
002010120420     D token           S               *
002011120420     D separator       S              1A   inz(';')
002012120420     D string          S          65535A   inz(*blank)
002013120420      /free
002014120420       cee_getOpDescInfo(1 : descType : dataType : descInfo1 : descInfo2 :
002015120420                         length : *omit);
002016120420       string = %subst(pString : 1 : length);
002017120420
002018120420       if (%parms() = 2);
002019120420         separator = pSeparator;
002020120420       endif;
002021120420
002022120420       list = list_create();
002023120420
002024120420       token = getToken(string : separator);
002025120420       dow (token <> *null);
002026120420         list_add(list : token : getStringLength(token));
002027120420         token = getToken(*null : separator);
002028120420       enddo;
002029120420
002030120420       return list;
002031120420      /end-free
002032120420     P                 E
002033120420
002034120420
002035120420     /**
002036120420      * \brief Reverse list
002037120420      *
002038120420      * Reverse the order of the list by simply switching the previous and
002039120420      * next pointers of each element.
002040120420      *
002041120420      * \param Pointer to the list
002042120420      */
002043120420     P list_reverse    B                   export
002044120420     D                 PI
002045120420     D listPtr                         *   const
002046120420      *
002047120420     D header          DS                  likeds(tmpl_header) based(listPtr)
002048120420     D ptr             S               *
002049120420     D entry           DS                  likeds(tmpl_entry) based(ptr)
002050120420     D tmp             S               *
002051120420      /free
002052120420       ptr = header.lastEntry;
002053120420
002054120420       dow (ptr <> *null);
002055120420         tmp = entry.prev;
002056120420         entry.prev = entry.next;
002057120420         entry.next = tmp;
002058120420         ptr = tmp;
002059120420       enddo;
002060120420
002061120420       // update header
002062120420       tmp = header.firstEntry;
002063120420       header.firstEntry = header.lastEntry;
002064120420       header.lastEntry = tmp;
002065120420      /end-free
002066120420     P                 E
002067120420
002068120420
002069120420     /**
002070120420      * \brief Create a copy of a list
002071120420      *
002072120420      * Creates a list with copies of all elements of the list.
002073120420      *
002074120420      * \author Mihael Schmidt
002075120420      * \date   7.4.2008
002076120420      *
002077120420      * \param Pointer to the list
002078120420      *
002079120420      * \return Pointer to te new list
002080120420      */
002081120420     P list_copy       B                   export
002082120420     D                 PI              *
002083120420     D   listPtr                       *   const
002084120420      *
002085120420     D header          DS                  likeds(tmpl_header) based(listPtr)
002086120420     D entryPtr        S               *
002087120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
002088120420     D newListPtr      S               *   inz(*null)
002089120420      /free
002090120420       if (isLinkedListImpl(listPtr));
002091120420
002092120420         newListPtr = list_create();
002093120420
002094120420         entryPtr = header.firstEntry;
002095120420
002096120420         dow (entryPtr <> *null);
002097120420           list_add(newListPtr : entry.value : entry.length - 1);
002098120420           entryPtr = entry.next;
002099120420         enddo;
002100120420
002101120420         return newListPtr;
002102120420
002103120420       endif;
002104120420
002105120420       return newListPtr;
002106120420      /end-free
002107120420     P                 E
002108120420
002109120420
002110120420     /**
002111120420      * \brief Frequency of a value in the list
002112120420      *
002113120420      * Returns the number of times the passed value
002114120420      * can be found in the list.
002115120420      *
002116120420      * \author Mihael Schmidt
002117120420      * \date   05.04.2008
002118120420      *
002119120420      * \param Pointer to the list
002120120420      * \param Pointer to the value
002121120420      * \param Length of the value
002122120420      *
002123120420      * \return number of copies of passed value in the list
002124120420      */
002125120420     P list_frequency...
002126120420     P                 B                   export
002127120420     D                 PI            10U 0
002128120420     D   listPtr                       *   const
002129120420     D   valuePtr                      *   const
002130120420     D   valueLength                 10U 0 const
002131120420      *
002132120420     D header          DS                  likeds(tmpl_header) based(listPtr)
002133120420     D entryPtr        S               *
002134120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
002135120420     D count           S             10U 0 inz(0)
002136120420      /free
002137120420       if (isLinkedListImpl(listPtr));
002138120420
002139120420         entryPtr = header.firstEntry;
002140120420         dow (entryPtr <> *null);
002141120420
002142120420           if (valueLength = entry.length - 1 and
002143120420               memcmp(valuePtr : entry.value : valueLength) = 0); // dont include the null
002144120420             count += 1;
002145120420           endif;
002146120420
002147120420           entryPtr = entry.next;
002148120420         enddo;
002149120420
002150120420       endif;
002151120420
002152120420       return count;
002153120420      /end-free
002154120420     P                 E
002155120420
002156120420
002157120420     /**
002158120420      * \brief Add character list entry
002159120420      *
002160120420      * Adds a character entry to the list. If the position is outside the list
002161120420      * the procedure returns <em>*off</em>. The current entry of the list at
002162120420      * that position will be pushed one position down the list.
002163120420      *
002164120420      * <br><br>
002165120420      *
002166120420      * If no position is passed to the procedure then the entry will be
002167120420      * appended to the end of the list (like <em>addLast</em>).
002168120420      *
002169120420      * \author Mihael Schmidt
002170120420      * \date   21.09.2008
002171120420      *
002172120420      * \param Pointer to the list
002173120420      * \param Character value
002174120420      * \param List position for the new value (optional)
002175120420      *
002176120420      * \return *on = entry added the list <br>
002177120420      *         *off = error
002178120420      */
002179120420     P list_addString...
002180120420     P                 B                   export
002181120420     D                 PI              N   opdesc
002182120420     D   listPtr                       *   const
002183120420     D   value                    65535A   const options(*varsize)
002184120420     D   index                       10U 0 const options(*nopass)
002185120420      *
002186120420     D descType        S             10I 0
002187120420     D dataType        S             10I 0
002188120420     D descInfo1       S             10I 0
002189120420     D descInfo2       S             10I 0
002190120420     D length          S             10I 0
002191120420      *
002192120420     D string          S          65535A   inz(*blank)
002193120420      /free
002194120420       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
002195120420                         length : *omit);
002196120420       string = %subst(value : 1 : length);
002197120420
002198120420       if (%parms() = 2);
002199120420         return list_add(listPtr : %addr(string) : length);
002200120420       elseif (%parms() = 3);
002201120420         return list_add(listPtr : %addr(string) : length : index);
002202120420       else;
002203120420         return *off;
002204120420       endif;
002205120420      /end-free
002206120420     P                 E
002207120420
002208120420
002209120420     /**
002210120420      * \brief Add integer list entry
002211120420      *
002212120420      * Adds an integer entry to the list. If the position is outside the list
002213120420      * the procedure returns <em>*off</em>. The current entry of the list at
002214120420      * that position will be pushed one position down the list.
002215120420      *
002216120420      * <br><br>
002217120420      *
002218120420      * If no position is passed to the procedure then the entry will be
002219120420      * appended to the end of the list (like <em>addLast</em>).
002220120420      *
002221120420      * \author Mihael Schmidt
002222120420      * \date   21.09.2008
002223120420      *
002224120420      * \param Pointer to the list
002225120420      * \param Integer value
002226120420      * \param List position for the new value (optional)
002227120420      *
002228120420      * \return *on = entry added the list <br>
002229120420      *         *off = error
002230120420      */
002231120420     P list_addInteger...
002232120420     P                 B                   export
002233120420     D                 PI              N
002234120420     D   listPtr                       *   const
002235120420     D   value                       10I 0 const
002236120420     D   index                       10U 0 const options(*nopass)
002237120420      *
002238120420     D integer         S             10I 0
002239120420      /free
002240120420       integer = value;
002241120420
002242120420       if (%parms() = 2);
002243120420         return list_add(listPtr : %addr(integer) : 4);
002244120420       elseif (%parms() = 3);
002245120420         return list_add(listPtr : %addr(integer) : 4 : index);
002246120420       else;
002247120420         return *off;
002248120420       endif;
002249120420      /end-free
002250120420     P                 E
002251120420
002252120420
002253120420     /**
002254120420      * \brief Add long list entry
002255120420      *
002256120420      * Adds a long entry to the list. If the position is outside the list
002257120420      * the procedure returns <em>*off</em>. The current entry of the list at
002258120420      * that position will be pushed one position down the list.
002259120420      *
002260120420      * <br><br>
002261120420      *
002262120420      * If no position is passed to the procedure then the entry will be
002263120420      * appended to the end of the list (like <em>addLast</em>).
002264120420      *
002265120420      * \author Mihael Schmidt
002266120420      * \date   21.09.2008
002267120420      *
002268120420      * \param Pointer to the list
002269120420      * \param Long value
002270120420      * \param List position for the new value (optional)
002271120420      *
002272120420      * \return *on = entry added the list <br>
002273120420      *         *off = error
002274120420      */
002275120420     P list_addLong...
002276120420     P                 B                   export
002277120420     D                 PI              N
002278120420     D   listPtr                       *   const
002279120420     D   value                       20I 0 const
002280120420     D   index                       10U 0 const options(*nopass)
002281120420      *
002282120420     D local           S             20I 0
002283120420      /free
002284120420       local = value;
002285120420
002286120420       if (%parms() = 2);
002287120420         return list_add(listPtr : %addr(local) : 8);
002288120420       elseif (%parms() = 3);
002289120420         return list_add(listPtr : %addr(local) : 8 : index);
002290120420       else;
002291120420         return *off;
002292120420       endif;
002293120420      /end-free
002294120420     P                 E
002295120420
002296120420
002297120420     /**
002298120420      * \brief Add short list entry
002299120420      *
002300120420      * Adds a short entry to the list. If the position is outside the list
002301120420      * the procedure returns <em>*off</em>. The current entry of the list at
002302120420      * that position will be pushed one position down the list.
002303120420      *
002304120420      * <br><br>
002305120420      *
002306120420      * If no position is passed to the procedure then the entry will be
002307120420      * appended to the end of the list (like <em>addLast</em>).
002308120420      *
002309120420      * \author Mihael Schmidt
002310120420      * \date   21.09.2008
002311120420      *
002312120420      * \param Pointer to the list
002313120420      * \param Short value
002314120420      * \param List position for the new value (optional)
002315120420      *
002316120420      * \return *on = entry added the list <br>
002317120420      *         *off = error
002318120420      */
002319120420     P list_addShort...
002320120420     P                 B                   export
002321120420     D                 PI              N
002322120420     D   listPtr                       *   const
002323120420     D   value                        5I 0 const
002324120420     D   index                       10U 0 const options(*nopass)
002325120420      *
002326120420     D local           S              5I 0
002327120420      /free
002328120420       local = value;
002329120420
002330120420       if (%parms() = 2);
002331120420         return list_add(listPtr : %addr(local) : 2);
002332120420       elseif (%parms() = 3);
002333120420         return list_add(listPtr : %addr(local) : 2 : index);
002334120420       else;
002335120420         return *off;
002336120420       endif;
002337120420      /end-free
002338120420     P                 E
002339120420
002340120420
002341120420     /**
002342120420      * \brief Add float list entry
002343120420      *
002344120420      * Adds a float entry to the list. If the position is outside the list
002345120420      * the procedure returns <em>*off</em>. The current entry of the list at
002346120420      * that position will be pushed one position down the list.
002347120420      *
002348120420      * <br><br>
002349120420      *
002350120420      * If no position is passed to the procedure then the entry will be
002351120420      * appended to the end of the list (like <em>addLast</em>).
002352120420      *
002353120420      * \author Mihael Schmidt
002354120420      * \date   21.09.2008
002355120420      *
002356120420      * \param Pointer to the list
002357120420      * \param Float value
002358120420      * \param List position for the new value (optional)
002359120420      *
002360120420      * \return *on = entry added the list <br>
002361120420      *         *off = error
002362120420      */
002363120420     P list_addFloat...
002364120420     P                 B                   export
002365120420     D                 PI              N
002366120420     D   listPtr                       *   const
002367120420     D   value                        4F   const
002368120420     D   index                       10U 0 const options(*nopass)
002369120420      *
002370120420     D local           S              4F
002371120420      /free
002372120420       local = value;
002373120420
002374120420       if (%parms() = 2);
002375120420         return list_add(listPtr : %addr(local) : %size(local));
002376120420       elseif (%parms() = 3);
002377120420         return list_add(listPtr : %addr(local) : %size(local) : index);
002378120420       else;
002379120420         return *off;
002380120420       endif;
002381120420      /end-free
002382120420     P                 E
002383120420
002384120420
002385120420     /**
002386120420      * \brief Add double list entry
002387120420      *
002388120420      * Adds a double entry to the list. If the position is outside the list
002389120420      * the procedure returns <em>*off</em>. The current entry of the list at
002390120420      * that position will be pushed one position down the list.
002391120420      *
002392120420      * <br><br>
002393120420      *
002394120420      * If no position is passed to the procedure then the entry will be
002395120420      * appended to the end of the list (like <em>addLast</em>).
002396120420      *
002397120420      * \author Mihael Schmidt
002398120420      * \date   21.09.2008
002399120420      *
002400120420      * \param Pointer to the list
002401120420      * \param Double value
002402120420      * \param List position for the new value (optional)
002403120420      *
002404120420      * \return *on = entry added the list <br>
002405120420      *         *off = error
002406120420      */
002407120420     P list_addDouble...
002408120420     P                 B                   export
002409120420     D                 PI              N
002410120420     D   listPtr                       *   const
002411120420     D   value                        8F   const
002412120420     D   index                       10U 0 const options(*nopass)
002413120420      *
002414120420     D local           S              8F
002415120420      /free
002416120420       local = value;
002417120420
002418120420       if (%parms() = 2);
002419120420         return list_add(listPtr : %addr(local) : %size(local));
002420120420       elseif (%parms() = 3);
002421120420         return list_add(listPtr : %addr(local) : %size(local) : index);
002422120420       else;
002423120420         return *off;
002424120420       endif;
002425120420      /end-free
002426120420     P                 E
002427120420
002428120420
002429120420     /**
002430120420      * \brief Add boolean list entry
002431120420      *
002432120420      * Adds a boolean entry to the list. If the position is outside the list
002433120420      * the procedure returns <em>*off</em>. The current entry of the list at
002434120420      * that position will be pushed one position down the list.
002435120420      *
002436120420      * <br><br>
002437120420      *
002438120420      * If no position is passed to the procedure then the entry will be
002439120420      * appended to the end of the list (like <em>addLast</em>).
002440120420      *
002441120420      * \author Mihael Schmidt
002442120420      * \date   21.09.2008
002443120420      *
002444120420      * \param Pointer to the list
002445120420      * \param Boolean value
002446120420      * \param List position for the new value (optional)
002447120420      *
002448120420      * \return *on = entry added the list <br>
002449120420      *         *off = error
002450120420      */
002451120420     P list_addBoolean...
002452120420     P                 B                   export
002453120420     D                 PI              N
002454120420     D   listPtr                       *   const
002455120420     D   value                         N   const
002456120420     D   index                       10U 0 const options(*nopass)
002457120420      *
002458120420     D local           S               N
002459120420      /free
002460120420       local = value;
002461120420
002462120420       if (%parms() = 2);
002463120420         return list_add(listPtr : %addr(local) : %size(local));
002464120420       elseif (%parms() = 3);
002465120420         return list_add(listPtr : %addr(local) : %size(local) : index);
002466120420       else;
002467120420         return *off;
002468120420       endif;
002469120420      /end-free
002470120420     P                 E
002471120420
002472120420
002473120420     /**
002474120420      * \brief Add packed decimal list entry
002475120420      *
002476120420      * Adds a packed decimal entry to the list. If the position is outside the list
002477120420      * the procedure returns <em>*off</em>. The current entry of the list at
002478120420      * that position will be pushed one position down the list.
002479120420      *
002480120420      * <br><br>
002481120420      *
002482120420      * If no position is passed to the procedure then the entry will be
002483120420      * appended to the end of the list (like <em>addLast</em>).
002484120420      *
002485120420      * \author Mihael Schmidt
002486120420      * \date   21.09.2008
002487120420      *
002488120420      * \param Pointer to the list
002489120420      * \param Packed decimal value
002490120420      * \param List position for the new value (optional)
002491120420      *
002492120420      * \return *on = entry added the list <br>
002493120420      *         *off = error
002494120420      */
002495120420     P list_addDecimal...
002496120420     P                 B                   export
002497120420     D                 PI              N
002498120420     D   listPtr                       *   const
002499120420     D   value                       15P 5 const
002500120420     D   index                       10U 0 const options(*nopass)
002501120420      *
002502120420     D local           S             15P 5
002503120420      /free
002504120420       local = value;
002505120420
002506120420       if (%parms() = 2);
002507120420         return list_add(listPtr : %addr(local) : %size(local));
002508120420       elseif (%parms() = 3);
002509120420         return list_add(listPtr : %addr(local) : %size(local) : index);
002510120420       else;
002511120420         return *off;
002512120420       endif;
002513120420      /end-free
002514120420     P                 E
002515120420
002516120420
002517120420     /**
002518120420      * \brief Add date list entry
002519120420      *
002520120420      * Adds a date entry to the list. If the position is outside the list
002521120420      * the procedure returns <em>*off</em>. The current entry of the list at
002522120420      * that position will be pushed one position down the list.
002523120420      *
002524120420      * <br><br>
002525120420      *
002526120420      * If no position is passed to the procedure then the entry will be
002527120420      * appended to the end of the list (like <em>addLast</em>).
002528120420      *
002529120420      * \author Mihael Schmidt
002530120420      * \date   21.09.2008
002531120420      *
002532120420      * \param Pointer to the list
002533120420      * \param Date value
002534120420      * \param List position for the new value (optional)
002535120420      *
002536120420      * \return *on = entry added the list <br>
002537120420      *         *off = error
002538120420      */
002539120420     P list_addDate...
002540120420     P                 B                   export
002541120420     D                 PI              N
002542120420     D   listPtr                       *   const
002543120420     D   value                         D   const
002544120420     D   index                       10U 0 const options(*nopass)
002545120420      *
002546120420     D local           S               D
002547120420      /free
002548120420       local = value;
002549120420
002550120420       if (%parms() = 2);
002551120420         return list_add(listPtr : %addr(local) : %size(local));
002552120420       elseif (%parms() = 3);
002553120420         return list_add(listPtr : %addr(local) : %size(local) : index);
002554120420       else;
002555120420         return *off;
002556120420       endif;
002557120420      /end-free
002558120420     P                 E
002559120420
002560120420
002561120420     /**
002562120420      * \brief Get character entry
002563120420      *
002564120420      * Returns a character list entry specified by the passed index.
002565120420      *
002566120420      * \author Mihael Schmidt
002567120420      * \date   21.09.2008
002568120420      *
002569120420      * \param Pointer to the list
002570120420      * \param List position
002571120420      *
002572120420      * \return Character string of the specified position
002573120420      */
002574120420     P list_getString...
002575120420     P                 B                   export
002576120420     D                 PI         65535A
002577120420     D   listPtr                       *   const
002578120420     D   index                       10U 0 const
002579120420      *
002580120420     D header          DS                  likeds(tmpl_header) based(listPtr)
002581120420     D entryPtr        S               *
002582120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
002583120420     D temp            S          65535A   based(entry.value)
002584120420     D testVar         S          65535A
002585120420      /free
002586120420       if (isLinkedListImpl(listPtr));
002587120420         // check if list is empty or the position is outside of the list
002588120420         if (header.size = 0);
002589120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
002590120420           return *blank;
002591120420         elseif (index < 0 or index > header.size -1);
002592120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
002593120420           return *blank;
002594120420         endif;
002595120420
002596120420         entryPtr = getListEntryDs(listPtr : index);
002597120420
002598120420         monitor;
002599120420           // test if the temp variable is filled with the right data for the type
002600120420           // by moving the data from temp to another var (testVar in this case)
002601120420           testVar = %subst(temp : 1 : entry.length - 1); // subtract the appended null value
002602120420           return testVar;
002603120420           on-error *all;
002604120420             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002605120420             return *blank;
002606120420         endmon;
002607120420       endif;
002608120420      /end-free
002609120420     P                 E
002610120420
002611120420
002612120420     /**
002613120420      * \brief Get integer entry
002614120420      *
002615120420      * Returns an integer list entry specified by the passed index.
002616120420      *
002617120420      * \author Mihael Schmidt
002618120420      * \date   21.09.2008
002619120420      *
002620120420      * \param Pointer to the list
002621120420      * \param List position
002622120420      *
002623120420      * \return Integer value of the specified position
002624120420      */
002625120420     P list_getInteger...
002626120420     P                 B                   export
002627120420     D                 PI            10I 0
002628120420     D   listPtr                       *   const
002629120420     D   index                       10U 0 const
002630120420      *
002631120420     D header          DS                  likeds(tmpl_header) based(listPtr)
002632120420     D entryPtr        S               *
002633120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
002634120420     D temp            S             10I 0 based(entry.value)
002635120420     D testVar         S             10I 0
002636120420      /free
002637120420       if (isLinkedListImpl(listPtr));
002638120420         // check if list is empty or the position is outside of the list
002639120420         if (header.size = 0);
002640120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
002641120420           return *loval;
002642120420         elseif (index < 0 or index > header.size -1);
002643120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
002644120420           return *loval;
002645120420         endif;
002646120420
002647120420         entryPtr = getListEntryDs(listPtr : index);
002648120420
002649120420         if (entry.length -1 <> 4);  // integer = 4 byte
002650120420           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002651120420         endif;
002652120420
002653120420         monitor;
002654120420           // test if the temp variable is filled with the right data for the type
002655120420           // by moving the data from temp to another var (testVar in this case)
002656120420           testVar = temp;
002657120420           return testVar;
002658120420           on-error *all;
002659120420             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002660120420             return *loval;
002661120420         endmon;
002662120420       endif;
002663120420      /end-free
002664120420     P                 E
002665120420
002666120420
002667120420     /**
002668120420      * \brief Get short entry
002669120420      *
002670120420      * Returns a short list entry specified by the passed index.
002671120420      *
002672120420      * \author Mihael Schmidt
002673120420      * \date   21.09.2008
002674120420      *
002675120420      * \param Pointer to the list
002676120420      * \param List position
002677120420      *
002678120420      * \return Short value of the specified position
002679120420      */
002680120420     P list_getShort...
002681120420     P                 B                   export
002682120420     D                 PI             5I 0
002683120420     D   listPtr                       *   const
002684120420     D   index                       10U 0 const
002685120420      *
002686120420     D header          DS                  likeds(tmpl_header) based(listPtr)
002687120420     D entryPtr        S               *
002688120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
002689120420     D temp            S              5I 0 based(entry.value)
002690120420     D testVar         S              5I 0
002691120420      /free
002692120420       if (isLinkedListImpl(listPtr));
002693120420         // check if list is empty or the position is outside of the list
002694120420         if (header.size = 0);
002695120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
002696120420           return *loval;
002697120420         elseif (index < 0 or index > header.size -1);
002698120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
002699120420           return *loval;
002700120420         endif;
002701120420
002702120420         entryPtr = getListEntryDs(listPtr : index);
002703120420
002704120420         if (entry.length -1 <> 2);  // short = 2 byte
002705120420           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002706120420         endif;
002707120420
002708120420         monitor;
002709120420           // test if the temp variable is filled with the right data for the type
002710120420           // by moving the data from temp to another var (testVar in this case)
002711120420           testVar = temp;
002712120420           return testVar;
002713120420           on-error *all;
002714120420             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002715120420             return *loval;
002716120420         endmon;
002717120420       endif;
002718120420      /end-free
002719120420     P                 E
002720120420
002721120420
002722120420     /**
002723120420      * \brief Get long entry
002724120420      *
002725120420      * Returns a long list entry specified by the passed index.
002726120420      *
002727120420      * \author Mihael Schmidt
002728120420      * \date   21.09.2008
002729120420      *
002730120420      * \parem Pointer to the list
002731120420      * \param List position
002732120420      *
002733120420      * \return Long value of the specified position
002734120420      */
002735120420     P list_getLong...
002736120420     P                 B                   export
002737120420     D                 PI            20I 0
002738120420     D   listPtr                       *   const
002739120420     D   index                       10U 0 const
002740120420      *
002741120420     D header          DS                  likeds(tmpl_header) based(listPtr)
002742120420     D entryPtr        S               *
002743120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
002744120420     D temp            S             20I 0 based(entry.value)
002745120420     D testVar         S             20I 0
002746120420      /free
002747120420       if (isLinkedListImpl(listPtr));
002748120420         // check if list is empty or the position is outside of the list
002749120420         if (header.size = 0);
002750120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
002751120420           return *loval;
002752120420         elseif (index < 0 or index > header.size -1);
002753120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
002754120420           return *loval;
002755120420         endif;
002756120420
002757120420         entryPtr = getListEntryDs(listPtr : index);
002758120420
002759120420         if (entry.length -1 <> 8);  // long = 8 byte
002760120420           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002761120420         endif;
002762120420
002763120420         monitor;
002764120420           // test if the temp variable is filled with the right data for the type
002765120420           // by moving the data from temp to another var (testVar in this case)
002766120420           testVar = temp;
002767120420           return testVar;
002768120420           on-error *all;
002769120420             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002770120420             return *loval;
002771120420         endmon;
002772120420       endif;
002773120420      /end-free
002774120420     P                 E
002775120420
002776120420
002777120420     /**
002778120420      * \brief Get float entry
002779120420      *
002780120420      * Returns a float list entry specified by the passed index.
002781120420      *
002782120420      * \author Mihael Schmidt
002783120420      * \date   21.09.2008
002784120420      *
002785120420      * \param Pointer to the list
002786120420      * \param List position
002787120420      *
002788120420      * \return Float value of the specified position
002789120420      */
002790120420     P list_getFloat...
002791120420     P                 B                   export
002792120420     D                 PI             4F
002793120420     D   listPtr                       *   const
002794120420     D   index                       10U 0 const
002795120420      *
002796120420     D header          DS                  likeds(tmpl_header) based(listPtr)
002797120420     D entryPtr        S               *
002798120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
002799120420     D temp            S              4F   based(entry.value)
002800120420     D testVar         S              4F
002801120420      /free
002802120420       if (isLinkedListImpl(listPtr));
002803120420         // check if list is empty or the position is outside of the list
002804120420         if (header.size = 0);
002805120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
002806120420           return *loval;
002807120420         elseif (index < 0 or index > header.size -1);
002808120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
002809120420           return *loval;
002810120420         endif;
002811120420
002812120420         entryPtr = getListEntryDs(listPtr : index);
002813120420
002814120420         if (entry.length -1 <> %size(temp));
002815120420           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002816120420         endif;
002817120420
002818120420         monitor;
002819120420           // test if the temp variable is filled with the right data for the type
002820120420           // by moving the data from temp to another var (testVar in this case)
002821120420           testVar = temp;
002822120420           return testVar;
002823120420           on-error *all;
002824120420             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002825120420             return *loval;
002826120420         endmon;
002827120420       endif;
002828120420      /end-free
002829120420     P                 E
002830120420
002831120420
002832120420     /**
002833120420      * \brief Get double entry
002834120420      *
002835120420      * Returns a double list entry specified by the passed index.
002836120420      *
002837120420      * \author Mihael Schmidt
002838120420      * \date   21.09.2008
002839120420      *
002840120420      * \param Pointer to the list
002841120420      * \param List position
002842120420      *
002843120420      * \return Double value of the specified position
002844120420      */
002845120420     P list_getDouble...
002846120420     P                 B                   export
002847120420     D                 PI             8F
002848120420     D   listPtr                       *   const
002849120420     D   index                       10U 0 const
002850120420      *
002851120420     D header          DS                  likeds(tmpl_header) based(listPtr)
002852120420    D entryPtr        S               *
002853120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
002854120420     D temp            S              8F   based(entry.value)
002855120420     D testVar         S              8F
002856120420      /free
002857120420       if (isLinkedListImpl(listPtr));
002858120420         // check if list is empty or the position is outside of the list
002859120420         if (header.size = 0);
002860120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
002861120420           return *loval;
002862120420         elseif (index < 0 or index > header.size -1);
002863120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
002864120420           return *loval;
002865120420         endif;
002866120420
002867120420         entryPtr = getListEntryDs(listPtr : index);
002868120420
002869120420         if (entry.length -1 <> %size(temp));
002870120420           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002871120420         endif;
002872120420
002873120420         monitor;
002874120420           // test if the temp variable is filled with the right data for the type
002875120420           // by moving the data from temp to another var (testVar in this case)
002876120420           testVar = temp;
002877120420           return testVar;
002878120420           on-error *all;
002879120420             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002880120420             return *loval;
002881120420         endmon;
002882120420       endif;
002883120420      /end-free
002884120420     P                 E
002885120420
002886120420
002887120420     /**
002888120420      * \brief Get boolean entry
002889120420      *
002890120420      * Returns a boolean list entry specified by the passed index.
002891120420      *
002892120420      * \author Mihael Schmidt
002893120420      * \date   21.09.2008
002894120420      *
002895120420      * \param Pointer to the list
002896120420      * \param List position
002897120420      *
002898120420      * \return Boolean value of the specified position
002899120420      */
002900120420     P list_getBoolean...
002901120420     P                 B                   export
002902120420     D                 PI              N
002903120420     D   listPtr                       *   const
002904120420     D   index                       10U 0 const
002905120420      *
002906120420     D header          DS                  likeds(tmpl_header) based(listPtr)
002907120420     D entryPtr        S               *
002908120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
002909120420     D temp            S               N   based(entry.value)
002910120420     D testVar         S               N
002911120420      /free
002912120420       if (isLinkedListImpl(listPtr));
002913120420         // check if list is empty or the position is outside of the list
002914120420         if (header.size = 0);
002915120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
002916120420           return *loval;
002917120420         elseif (index < 0 or index > header.size -1);
002918120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
002919120420           return *loval;
002920120420         endif;
002921120420
002922120420         entryPtr = getListEntryDs(listPtr : index);
002923120420
002924120420         if (entry.length -1 <> 1);
002925120420           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002926120420         endif;
002927120420
002928120420         monitor;
002929120420           // test if the temp variable is filled with the right data for the type
002930120420           // by moving the data from temp to another var (testVar in this case)
002931120420           testVar = temp;
002932120420           return testVar;
002933120420           on-error *all;
002934120420             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002935120420             return *loval;
002936120420         endmon;
002937120420       endif;
002938120420      /end-free
002939120420     P                 E
002940120420
002941120420
002942120420     /**
002943120420      * \brief Get packed decimal entry
002944120420      *
002945120420      * Returns a packed decimal list entry specified by the passed index.
002946120420      *
002947120420      * \author Mihael Schmidt
002948120420      * \date   21.09.2008
002949120420      *
002950120420      * \param Pointer to the list
002951120420      * \param List position
002952120420      *
002953120420      * \return Packed decimal value of the specified position
002954120420      */
002955120420     P list_getDecimal...
002956120420     P                 B                   export
002957120420     D                 PI            15P 5
002958120420     D   listPtr                       *   const
002959120420     D   index                       10U 0 const
002960120420      *
002961120420     D header          DS                  likeds(tmpl_header) based(listPtr)
002962120420     D entryPtr        S               *
002963120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
002964120420     D temp            S             15P 5 based(entry.value)
002965120420     D testVar         S             15P 5
002966120420      /free
002967120420       if (isLinkedListImpl(listPtr));
002968120420         // check if list is empty or the position is outside of the list
002969120420         if (header.size = 0);
002970120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
002971120420           return *loval;
002972120420         elseif (index < 0 or index > header.size -1);
002973120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
002974120420           return *loval;
002975120420         endif;
002976120420
002977120420         entryPtr = getListEntryDs(listPtr : index);
002978120420
002979120420         if (entry.length -1 <> %size(temp));
002980120420           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002981120420         endif;
002982120420
002983120420         monitor;
002984120420           // test if the temp variable is filled with the right data for the type
002985120420           // by moving the data from temp to another var (testVar in this case)
002986120420           testVar = temp;
002987120420           return testVar;
002988120420           on-error *all;
002989120420             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002990120420             return *loval;
002991120420         endmon;
002992120420       endif;
002993120420      /end-free
002994120420     P                 E
002995120420
002996120420
002997120420     /**
002998120420      * \brief Get date entry
002999120420      *
003000120420      * Returns a date list entry specified by the passed index.
003001120420      *
003002120420      * \author Mihael Schmidt
003003120420      * \date   21.09.2008
003004120420      *
003005120420      * \param Pointer to the list
003006120420      * \param List position
003007120420      *
003008120420      * \return Date value of the specified position
003009120420      */
003010120420     P list_getDate...
003011120420     P                 B                   export
003012120420     D                 PI              D
003013120420     D   listPtr                       *   const
003014120420     D   index                       10U 0 const
003015120420      *
003016120420     D header          DS                  likeds(tmpl_header) based(listPtr)
003017120420     D entryPtr        S               *
003018120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
003019120420     D temp            S               D   based(entry.value)
003020120420     D testVar         S               D
003021120420      /free
003022120420       if (isLinkedListImpl(listPtr));
003023120420         // check if list is empty or the position is outside of the list
003024120420         if (header.size = 0);
003025120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
003026120420           return *loval;
003027120420         elseif (index < 0 or index > header.size -1);
003028120420           sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
003029120420           return *loval;
003030120420         endif;
003031120420
003032120420         entryPtr = getListEntryDs(listPtr : index);
003033120420
003034120420         if (entry.length -1 <> %size(temp));
003035120420           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
003036120420         endif;
003037120420
003038120420         monitor;
003039120420           // test if the temp variable is filled with the right data for the type
003040120420           // by moving the data from temp to another var (testVar in this case)
003041120420           testVar = temp;
003042120420           return testVar;
003043120420           on-error *all;
003044120420             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
003045120420             return *loval;
003046120420         endmon;
003047120420       endif;
003048120420      /end-free
003049120420     P                 E
003050120420
003051120420
003052120420     /**
003053120420      * \brief Remove range of elements
003054120420      *
003055120420      * Removes a number of elements from the list.
003056120420      *
003057120420      * \param Pointer to the list
003058120420      * \param Starting index
003059120420      * \param Number of elements to remove
003060120420      *
003061120420      * \throws CPF9898 Position out of bounds
003062120420      */
003063120420     P list_removeRange...
003064120420     P                 B                   export
003065120420     D                 PI
003066120420     D   listPtr                       *   const
003067120420     D   index                       10U 0 const
003068120420     D   pNumberElements...
003069120420     D                               10U 0 const
003070120420      *
003071120420     D header          DS                  likeds(tmpl_header) based(listPtr)
003072120420     D numberElements  S             10U 0
003073120420     D i               S             10U 0
003074120420      /free
003075120420       isLinkedListImpl(listPtr);
003076120420
003077120420       // check if the start is in the range of the list
003078120420       if (index > header.size - 1);
003079120420         sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
003080120420       endif;
003081120420
003082120420       if (index + pNumberElements > header.size -1);
003083120420         numberElements = header.size - index;
003084120420       else;
003085120420         numberElements = pNumberElements;
003086120420       endif;
003087120420
003088120420       for i = 1 to numberElements;
003089120420         list_remove(listPtr : index);
003090120420       endfor;
003091120420
003092120420      /end-free
003093120420     P                 E
003094120420
003095120420     /**
003096120420      * \brief Sort list
003097120420      *
003098120420      * Sorts the list with the passed procedure.
003099120420      *
003100120420      * <br>
003101120420      *
003102120420      * The passed procedure should have the list pointer as its
003103120420      * only parameter (const) and should sort the list in-place.
003104120420      *
003105120420      * \param Pointer to the list
003106120420      * \param Procedure pointer to the sort procedure
003107120420      */
003108120420     P list_sort       B                   export
003109120420     D                 PI
003110120420     D   listPtr                       *   const
003111120420     D   sortAlgorithm...
003112120420     D                                 *   const procptr
003113120420      *
003114120420     D sort            PR                  extproc(sortAlgorithm)
003115120420     D   listPtr                       *   const
003116120420      /free
003117120420       if (isLinkedListImpl(listPtr));
003118120420         sort(listPtr);
003119120420       endif;
003120120420      /end-free
003121120420     P                 E
003122120420
003123120420
003124120420     /**
003125120420      * \brief Merge lists
003126120420      *
003127120420      * Merges the elements of second list with the first list. Elements which
003128120420      * are already in the first list are not added by default (see third parameter).
003129120420      *
003130120420      * \author Mihael Schmidt
003131120420      * \date   15.12.2009
003132120420      *
003133120420      * \param Destination list
003134120420      * \param Source list
003135120420      * \param Skip duplicates (default: *off)
003136120420      */
003137120420     P list_merge      B                   export
003138120420     D                 PI
003139120420     D   destList                      *   const
003140120420     D   sourceList                    *   const
003141120420     D   pSkipDuplicates...
003142120420     D                                 N   const options(*nopass)
003143120420      *
003144120420     D skipDuplicates...
003145120420     D                 S               N   inz(*off)
003146120420     D header          DS                  likeds(tmpl_header) based(sourceList)
003147120420     D entryPtr        S               *
003148120420     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
003149120420      /free
003150120420       if (%parms() = 3);
003151120420         skipDuplicates = pSkipDuplicates;
003152120420       endif;
003153120420
003154120420       if (isLinkedListImpl(destList) and
003155120420           isLinkedListImpl(sourceList));
003156120420
003157120420         entryPtr = header.firstEntry;
003158120420         dow (entryPtr <> *null);
003159120420
003160120420           if (skipDuplicates);
003161120420             if (not list_contains(destList : entry.value : entry.length - 1));
003162120420               list_add(destList : entry.value : entry.length - 1); // dont include the null value
003163120420             endif;
003164120420           else;
003165120420             list_add(destList : entry.value : entry.length - 1); // dont include the null value
003166120420           endif;
003167120420
003168120420           entryPtr = entry.next;
003169120420         enddo;
003170120420
003171120420       endif;
003172120420      /end-free
003173120420     P                 E
