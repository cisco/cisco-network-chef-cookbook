/****************************************************************************/
/* demo-one.c - simple demo RPM source.                                     */
/* Copyright (c) 2015 Cisco and/or its affiliates.                          */
/*                                                                          */
/* Licensed under the Apache License, Version 2.0 (the "License");          */
/* you may not use this file except in compliance with the License.         */
/* You may obtain a copy of the License at                                  */
/*                                                                          */
/*     http://www.apache.org/licenses/LICENSE-2.0                           */
/*                                                                          */
/* Unless required by applicable law or agreed to in writing, software      */
/* distributed under the License is distributed on an "AS IS" BASIS,        */
/* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. */
/* See the License for the specific language governing permissions and      */
/* limitations under the License.                                           */
/****************************************************************************/

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <time.h>

int main (void) {
 time_t curr;
 char*  curr_str;
 FILE* fd;

 printf("\n\n"
   "      ####################\n"
   "      # demo-one started #\n"
   "      ####################\n\n");

 curr = time(NULL);
 curr_str = ctime(&curr);

 fd = fopen("/tmp/demo-one.log", "a");
 if (fd) {
   fprintf(fd, "demo-one started at: %s\n", curr_str);
   fclose(fd);
 }

 sleep(600);
 return (0);
}
