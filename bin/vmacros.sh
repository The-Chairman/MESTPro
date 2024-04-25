#!/bin/bash
romfs=`wc -l $2 | awk -F' ' '{print $$1}'`;
printf "DUMP_FILE=\`\"%s\`\"\n" $1; 
printf "ROM_FILE=\`\"%s\`\"\n" $2;
printf "ROM_SIZE=%d\n" $romfs