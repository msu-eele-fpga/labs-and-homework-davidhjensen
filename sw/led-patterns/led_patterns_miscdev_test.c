#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>

// TODO: update these offsets if your address are different
#define HPS_LED_CONTROL_OFFSET 0x0
#define BASE_PERIOD_OFFSET 0x8
#define LED_REG_OFFSET 0x4

static volatile int keep_running = 1;

void int_handler(int irrelevant)
/**
 * int_handler() - Switch FPGA to hardware control mode and exit program when cntl-C is entered
 * @arg1: TODO
 *
 * TODO
 * 
 * Return: void.
 */
{
	printf("\nLOOP KILLED!\n");
	keep_running = 0;
}

int main () {
	FILE *file;
	size_t ret;	
	uint32_t val;

	file = fopen("/dev/led_patterns" , "rb+" );
	if (file == NULL) {
		printf("failed to open file\n");
		exit(1);
	}

	// Test reading the registers sequentially
	printf("\n************************************\n*");
	printf("* read initial register values\n");
	printf("************************************\n\n");

	ret = fread(&val, 4, 1, file);
	printf("HPS_LED_control = 0x%x\n", val);

	ret = fread(&val, 4, 1, file);
	printf("base period = 0x%x\n", val);

	ret = fread(&val, 4, 1, file);
	printf("LED_reg = 0x%x\n", val);

	// Reset file position to 0
	ret = fseek(file, 0, SEEK_SET);
	printf("fseek ret = %d\n", ret);
	printf("errno =%s\n", strerror(errno));


	printf("\n************************************\n*");
	printf("* write values\n");
	printf("************************************\n\n");
	// Turn on software-control mode
	val = 0x01;
    ret = fseek(file, HPS_LED_CONTROL_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	// We need to "flush" so the OS finishes writing to the file before our code continues.
	fflush(file);

	// Write cool pattern to LEDs as long until ctl-c
	signal(SIGINT, int_handler);
	int count = 0;
	char slow = 0x1;
	char fast = 0x80;
	while (keep_running) 
	{
		fast = (fast >> 1) | (fast << 7);
		if (count > 16)
		{
			count = 0;
			slow = (slow << 1) | (slow >> 7);
		}
		val = fast | slow;
		ret = fseek(file, LED_REG_OFFSET, SEEK_SET);
		ret = fwrite(&val, 4, 1, file);
		fflush(file);
		usleep(20*1000);
		count = count + 1;
	}


	// Turn on hardware-control mode
	printf("back to hardware-control mode....\n");
	val = 0x00;
    ret = fseek(file, HPS_LED_CONTROL_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	val = 0x12;
    ret = fseek(file, BASE_PERIOD_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	sleep(5);

	// Speed up the base period!
	val = 0x02;
    ret = fseek(file, BASE_PERIOD_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);


	printf("\n************************************\n*");
	printf("* read new register values\n");
	printf("************************************\n\n");
	
	// Reset file position to 0
	ret = fseek(file, 0, SEEK_SET);

	ret = fread(&val, 4, 1, file);
	printf("HPS_LED_control = 0x%x\n", val);

	ret = fread(&val, 4, 1, file);
	printf("base period = 0x%x\n", val);

	ret = fread(&val, 4, 1, file);
	printf("LED_reg = 0x%x\n", val);

	fclose(file);
	return 0;
}
