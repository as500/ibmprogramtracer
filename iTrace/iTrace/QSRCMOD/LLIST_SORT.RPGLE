000100120420     /**
000101120420      * \brief Linked List : Sorting Algorithms
000102120420      *
000103120420      *
000104120420      * \author Mihael Schmidt
000105120420      * \date   2009-02-17
000106120420      *
000107120420      */
000108120420
000109120420      *------------------------------------------------------------------------
000110120420      *
000111120420      * Copyright (c) 2007-2009 Mihael Schmidt
000112120420      * All rights reserved.
000113120420      *
000114120420      * This file is part of the LLIST service program.
000115120420      *
000116120420      * LLIST is free software: you can redistribute it and/or modify it under
000117120420      * the terms of the GNU Lesser General Public License as published by
000118120420      * the Free Software Foundation, either version 3 of the License, or
000119120420      * any later version.
000120120420      *
000121120420      * LLIST is distributed in the hope that it will be useful,
000122120420      * but WITHOUT ANY WARRANTY; without even the implied warranty of
000123120420      * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
000124120420      * GNU Lesser General Public License for more details.
000125120420      *
000126120420      * You should have received a copy of the GNU Lesser General Public
000127120420      * License along with LLIST.  If not, see http://www.gnu.org/licenses/.
000128120420      *
000129120420      *------------------------------------------------------------------------
000130120420
000131120420
000132120420     H NOMAIN
000133120420     H COPYRIGHT('Copyright (c) 2007-2009 Mihael Schmidt. All rights reserved.')
000134120420
000135120420
000136120420      *---------------------------------------------------------------
000137120420      * Prototypen
000138120420      *---------------------------------------------------------------
000139121028      /include qsrctxt,llist_h
000140121028      /include qsrctxt,llist_in_h
000141121028      /include qsrctxt,ceeapi_h
000142120420
000143120420
000144120420      *-------------------------------------------------------------------------
000145120420      * Procedures
000146120420      *-------------------------------------------------------------------------
000147120420
000148120420     /**
000149120420      *  \brief Insertion sort
000150120420      *
000151120420      * The list will be sorted inline.
000152120420      *
000153120420      * \author Mihael Schmidt
000154120420      * \date   2009-02-17
000155120420      *
000156120420      * \param Pointer to the list
000157120420      */
000158120420     P list_sort_insertionSort...
000159120420     P                 B                   export
000160120420     D                 PI
000161120420     D   listPtr                       *   const
000162120420      *
000163120420     D header          DS                  likeds(tmpl_header) based(listPtr)
000164120420     D keepRunning     S               N   inz(*on)
000165120420     D entryPtr1       S               *
000166120420     D entry1          DS                  likeds(tmpl_entry) based(entryPtr1)
000167120420     D entryPtr2       S               *
000168120420     D entry2          DS                  likeds(tmpl_entry) based(entryPtr2)
000169120420     D rc              S             10I 0
000170120420     D length          S             10U 0
000171120420     D shouldSwap      S               N   inz(*off)
000172120420     D top             S               N   inz(*off)
000173120420     D bottom          S               N   inz(*off)
000174120420      /free
000175120420       if (header.size <= 1);
000176120420         return;
000177120420       endif;
000178120420
000179120420       entryPtr1 = getListEntryDs(listPtr : 0);
000180120420       entryPtr2 = getListEntryDs(listPtr : 1);
000181120420
000182120420       dow (keepRunning);
000183120420         if (entry1.length < entry2.length);
000184120420           length = entry1.length;
000185120420         else;
000186120420           length = entry2.length;
000187120420         endif;
000188120420
000189120420         rc = memcmp(entry1.value : entry2.value : length);
000190120420         if (rc > 0);
000191120420           shouldSwap = *on;
000192120420
000193120420         elseif (rc = 0 and entry1.length > entry2.length); // check the length of the values
000194120420           shouldSwap = *on;
000195120420
000196120420         else;
000197120420           // correct order => go down again
000198120420           shouldSwap = *off;
000199120420         endif;
000200120420
000201120420
000202120420         if (shouldSwap);
000203120420           top = *off;
000204120420           bottom = *off;
000205120420
000206120420           internal_swap(listPtr : *omit : *omit : entryPtr1 : entryPtr2);
000207120420
000208120420           //
000209120420           // get next entries to check
000210120420           //
000211120420
000212120420           // check if we are already at the top
000213120420           if (entry2.prev <> *null); // note: entry2 is now above entry1
000214120420             // go one up
000215120420             entryPtr1 = entry2.prev;
000216120420           else;
000217120420             // we are at the top, now go down again
000218120420             top = *on;
000219120420
000220120420             // skip one entry because we just made the check
000221120420             if (entry1.next <> *null);
000222120420               entryPtr2 = entry1.next;
000223120420             else;
000224120420               bottom = *on;
000225120420             endif;
000226120420           endif;
000227120420
000228120420         else;
000229120420           // check next entries
000230120420           if (bottom); // need to go up
000231120420
000232120420             if (entry1.prev <> *null);
000233120420               entryPtr2 = entryPtr1;
000234120420               entryPtr1 = entry2.prev;
000235120420             else;
000236120420               top = *on;
000237120420
000238120420               // go down
000239120420               entryPtr1 = entryPtr2;
000240120420               entryPtr2 = entry1.next;
000241120420             endif;
000242120420
000243120420           else;        // need to go down
000244120420
000245120420             if (entry2.next <> *null);
000246120420               entryPtr1 = entryPtr2;
000247120420               entryPtr2 = entry1.next;
000248120420             else;
000249120420               bottom = *on;
000250120420
000251120420               if (entry1.prev <> *null);
000252120420                 // go up again
000253120420                 entryPtr2 = entryPtr1;
000254120420                 entryPtr1 = entry2.prev;
000255120420               else;
000256120420                 top = *on;
000257120420               endif;
000258120420
000259120420             endif;
000260120420
000261120420           endif;
000262120420         endif;
000263120420
000264120420
000265120420         // if both ends have been visited without change => end loop
000266120420         if (top and bottom);
000267120420           keepRunning = *off;
000268120420         endif;
000269120420
000270120420         // reset things
000271120420         shouldSwap = *off;
000272120420       enddo;
000273120420      /end-free
000274120420     P                 E
