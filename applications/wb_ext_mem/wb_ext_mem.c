#include <api.h>
#include <stdlib.h>
#include "wb_ext_mem_std.h"

Message msg;

int main()
{
	int i;

	Echo("START_FIB: Writing Fibonacci sequence to the external memory");

	msg.msg[0] = 0;
	msg.msg[1] = 1;
	for (i = 2; i < MSG_SIZE; i++) {
		msg.msg[i] = msg.msg[i - 1] + msg.msg[i - 2];

		if (msg.msg[i] < msg.msg[i - 1])
			// overflow max int reached
			break;
	}
	msg.length = i;

	SendIO(&msg, WB_PERIPHERAL, 0xA);

	Echo("END_FIB");
	exit();
}


