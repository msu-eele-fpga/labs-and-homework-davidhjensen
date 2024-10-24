#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <sys/mman.h> // FOR mapp
#include <fcntl.h> // for file open flags
#include <unistd.h> // for getting the page size
#include <ctype.h>
#include <string.h>
#include <signal.h>

static volatile int keep_running = 1;

void verbose_print(uint32_t pattern, uint32_t time);
/**
 * verbose_print() - Print out the LED pattern in binary and the time it will be displayed.
 * @arg1: The LED pattern to print.
 * @arg2: The time in milliseconds that the pattern will be printed for.
 *
 * This simple function formats the printout for the verbose flag
 *
 * Return: void.
 */

void file_to_patterns_and_times(char *file_name, uint32_t *pattern_array, uint32_t *time_array, int *num_patterns);
/**
 * file_to_patterns_and_times() - This function read a file holding patterns and times and stores them in provided arrays.
 * @file_name: Pointer to the string that holds the file name.
 * @pattern_array: Pointer to the array of unit32_t values corrisponding to the patterns
 * @time_array: Pointer to the array of uint32_t values corrisponding to the time each pattern should be displayed
 * @num_patterns: Pointer to the number of patterns to display
 *
 * The function will open and read the file that is provided. The file has the following format:
 * 
 * <xx> <yyyy>
 * <xx> <yyyy>
 * 	   .
 *     .
 *     .
 * <xx> <yyyy>
 * 
 * where <xx> corresponods to the pattern and <yyyy> corresponds to the time each pattern is displayed
 *
 * Return: void.
 */

int write_to_devmem(int fd, uint32_t address, size_t page_size, uint32_t data);
/**
 * write_to_devmem() - Write a provided 32-bit piece of data to the FPGA.
 * @fd: TODO
 * @address: TODO
 * @page_size: TODO
 * @data: TODO
 *
 * TODO
 *
 * Return: void.
 */

void int_handler(int irrelevant);
/**
 * int_handler() - Switch FPGA to hardware control mode and exit program when cntl-C is entered
 * @arg1: TODO
 *
 * TODO
 * 
 * Return: void.
 */

void usage();
/**
 * usage() - Function to print usage of the led_patterns command
 *
 * Return: void.
 */

int main (int argc, char **argv)
{
  int help_flag = 0;
  int verbose_flag = 0;
  int pattern_flag = 0;
  int file_flag = 0;

  int num_patterns = 0;

  // store the file name if passed
  char patterns_file[20];

  // allocate memory for patterns and times
  uint32_t *patterns;
  patterns = malloc(1*sizeof(uint32_t));
  uint32_t *pattern_times;
  pattern_times = malloc(1*sizeof(uint32_t));
  
  int index;
  int c;

  // memory page size
  const size_t PAGE_SIZE = sysconf(_SC_PAGE_SIZE);
  // memory address for patterns
  const uint32_t PATTERN_ADDRESS = 0xff200004;
  // memory address for sw/hw control
  const uint32_t SW_CONTROL_ADDRESS = 0xff200000;
  // bit to write to turn sw control on
  const uint32_t SW_CONTROL_ON = 0x1;
  // bit to write to turn sw control off
  const uint32_t SW_CONTROL_OFF = 0x0;

  opterr = 0;

  while ((c = getopt (argc, argv, "hvp:f:")) != -1)
    switch (c)
      {
      case 'h':
        help_flag = 1;
		usage();
		return 1;
        break;

      case 'v':
        verbose_flag = 1;
        break;

	  case 'p':
	  	pattern_flag = 1;
		// error out if no or odd number of args are passed
		int num_args = (int) argc - (int) optind + 1;
		if (num_args % 2 == 1) 
		{
			fprintf(stderr, "Each pattern should be followed by a time value.\n");
			return 1;
		}
		else if (num_args == 0)
		{
			fprintf(stderr, "-p flag requires that patterns and corresponding durations are passed in pairs.\n");
			return 1;
		}
		num_patterns = num_args / 2;
		patterns = realloc(patterns, num_patterns*sizeof(uint32_t));
		pattern_times = realloc(pattern_times, num_patterns*sizeof(uint32_t));
		for(int i=optind; i<argc; i=i+2)
		{
			patterns[(i-optind)/2] = strtoul(argv[i-1], NULL, 0);
			pattern_times[(i-optind)/2] = strtoul(argv[i], NULL, 0);
		}
		break;

	  case 'f':
	  	file_flag = 1;
		// if no file is passed
		// TODO
		if (0) {
			fprintf(stderr, "-f flag requires that a file is passed.\n");
			return 1;
		}
		else
		{
			// save file name
			strcpy(patterns_file, optarg);
		}
		break;

      case '?':
        if (optopt == 'p' | optopt == 'f')
		{
			fprintf(stderr, "Options -p and -f require an argument.\n");
		}
		else if (isprint (optopt)) 
		{
			fprintf (stderr, "Unknown option `-%c'.\n", optopt);
		}
        else
          fprintf (stderr,
                   "Unknown option character `\\x%x'.\n",
                   optopt);
        return 1;

      default:
        abort ();
      }

if (argc == 1) {
	fprintf(stderr, "ERROR!\n");
	return 1;
}

if (pattern_flag & file_flag) 
{
	fprintf(stderr, "-p and -f flags are exclusive: make a choice!\n");
	return 1;
}

signal(SIGINT, int_handler);

//-------------------------------- set up writing to memory -----------------------------------------------------
// Open the /dev/mem file, which is an image of the main system memory
// We use synchronous write operations (O_SYNC) to ensure that the value
// is fully written to the underlying hardware before the write call returns.
int fd = open("/dev/mem", O_RDWR | O_SYNC);
if (fd == -1)
{
	fprintf(stderr, "failed to open /dev/mem.\n");
	return 1;
}

// set to software control mode
if (write_to_devmem(fd, SW_CONTROL_ADDRESS, PAGE_SIZE, SW_CONTROL_ON))
{
	return 1;
}

while (keep_running)
{
	if (pattern_flag == 1) 
	{
		for (int i=0; i<num_patterns; i++)
		{
			if (verbose_flag == 1) 
			{
				verbose_print(patterns[i], pattern_times[i]);
			}
			if (write_to_devmem(fd, PATTERN_ADDRESS, PAGE_SIZE, patterns[i]))
			{
				return 1;
			}
			usleep(pattern_times[i]*1000);
		}
	}
	else if (file_flag == 1) 
	{
		file_to_patterns_and_times(patterns_file, patterns, pattern_times, &num_patterns);
		for (int i=0; i<num_patterns; i++)
		{
			if (verbose_flag == 1) 
			{
				verbose_print(patterns[i], pattern_times[i]);
			}
			if (write_to_devmem(fd, PATTERN_ADDRESS, PAGE_SIZE, patterns[i]))
			{
				return 1;
			}
			usleep(pattern_times[i]*1000);
		}
	}
}

if (write_to_devmem(fd, SW_CONTROL_ADDRESS, PAGE_SIZE, SW_CONTROL_OFF))
{
	return 1;
}
printf("software control disabled");

return 0;
}

void verbose_print(uint32_t pattern, uint32_t time)
/**
 * verbose_print() - Print out the LED pattern in binary and the time it will be displayed.
 * @arg1: The LED pattern to print.
 * @arg2: The time in milliseconds that the pattern will be printed for.
 *
 * This simple function formats the printout for the verbose flag
 *
 * Return: void.
 */
{
	printf("LED pattern: ");
	for (int i=0; i< 8; i++)
	{
		if (pattern & 0x00000080) 
		{
			printf("1");
		}
		else 
		{
			printf("0");
		}
		pattern <<= 1;
	}
	printf("| Display time: %d ms\n", time);
	return;
}

void file_to_patterns_and_times(char *file_name, uint32_t *pattern_array, uint32_t *time_array, int *num_patterns)
/**
 * file_to_patterns_and_times() - This function read a file holding patterns and times and stores them in provided arrays.
 * @file_name: Pointer to the string that holds the file name.
 * @pattern_array: Pointer to the array of unit32_t values corrisponding to the patterns
 * @time_array: Pointer to the array of uint32_t values corrisponding to the time each pattern should be displayed
 * @num_patterns: Pointer to the number of patterns to display
 *
 * The function will open and read the file that is provided. The file has the following format:
 * 
 * <xx> <yyyy>
 * <xx> <yyyy>
 * 	   .
 *     .
 *     .
 * <xx> <yyyy>
 * 
 * where <xx> corresponods to the pattern and <yyyy> corresponds to the time each pattern is displayed
 *
 * Return: void.
 */
{
	// open file
	FILE *patterns_file_ptr;
	patterns_file_ptr = fopen(file_name, "r");

	// count the number of lines
	int num_lines = 0;
	char line_buf[100];

	while(fgets(line_buf, sizeof(line_buf), patterns_file_ptr))
	{
		num_lines++;
	}
	*num_patterns = num_lines;
	rewind(patterns_file_ptr);

	// reallocate pattern arrays
	pattern_array = realloc(pattern_array, num_lines*sizeof(uint32_t));
	time_array = realloc(time_array, num_lines*sizeof(uint32_t));

	// save patterns and times
	char *params;
	for(int i=0; i<num_lines; i++)
	{
		fgets(line_buf, sizeof(line_buf), patterns_file_ptr);
		params = strtok(line_buf, " ");
		pattern_array[i] = strtoul(params, NULL, 0);
		params = strtok(NULL, " ");
		time_array[i] = strtoul(params, NULL, 0);
	}

	return;
}

int write_to_devmem(int fd, uint32_t address, size_t page_size, uint32_t data)
/**
 * write_to_devmem() - Write a provided 32-bit piece of data to the FPGA.
 * @fd: TODO
 * @address: TODO
 * @page_size: TODO
 * @data: TODO
 *
 * TODO
 *
 * Return: void.
 */
{
	// mmap needs to map memory at page boudries (address we map needs to be page-algned). ~(PAGE_SIZE - 1) is the bit mask that handles this
	uint32_t page_aligned_addr = address & ~(page_size - 1);
	// Map a page of physical memory into virtual memory. See mmap man page for info
	uint32_t *page_virtual_addr = (uint32_t *)mmap(NULL, page_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, page_aligned_addr);
	if (page_virtual_addr == MAP_FAILED)
	{
		fprintf(stderr, "failed to map memory/\n");
		return 1;
	}
	// we need to offset the provided address
	uint32_t offset_in_page = address & (page_size - 1);

	// Compute the virtual address corresponding to ADDRESS. Because
	// page_virtual_addr and target_virtual_addr are both uint32_t pointers,
	// pointer addition multiplies the pointer address by the number of bytes
	// needed to store a uint32_t (4 bytes); e.g., 0x10 + 4 = 0x20, not 0x14.
	// Consequently, we need to divide offset_in_page by 4 bytes to make the
	// pointer addition return our desired address (0x14 in the example).
	// We use volatile because the value at target_virtual_addr could change
	// outside of our program; the address refers to memory-mapped I/O
	// that could be changed by hardware. volatile tells the compiler to
	// not optimize accesses to this memory address.
	volatile uint32_t *target_virtual_addr = page_virtual_addr + offset_in_page/sizeof(uint32_t *);

	*target_virtual_addr = data;
	return 0;
}

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
	printf("\nGoing to hardware control!\n");
	keep_running = 0;
}

void usage()
/**
 * usage() - Function to print usage of the led_patterns command
 *
 * Return: void.
 */
{
    fprintf(stderr, "usage: led-patterns [-h] [-v] [-p] [-f] [<args>]\n");
    fprintf(stderr, "display a PATTERN for a TIME duration and loop until Ctrl-C is pressed\n");
    fprintf(stderr, "PATTERN is default an eight bit hexadecimal value\n");
    fprintf(stderr, "TIME is default an interger value for millisecond duration\n");
    fprintf(stderr, "Example: led-patterns -v -p 0x50 500 0xff 1000\n\n");
    fprintf(stderr, "options:\n");
    fprintf(stderr, " -h    display this help text and exit\n");
    fprintf(stderr, " -v    verbosely print PATTERN and TIME\n");
    fprintf(stderr, " -p    PATTERN and TIME to be displayed\n");
    fprintf(stderr, " -f    text file for which PATTERN and TIME will be read from\n\n");
}

/*
if (help_flag) == 1
{
	printf("usage: myprogram [-h] [-f FOO]\n");
	printf("options:");
	printf("    -h show this help message and exit");
	printf("    -f FOO foo of the myprogram program");

-h show this help message and exit
-f FOO foo of the myprogram program")
}
  printf ("help_flag = %d, verbose_flag = %d\n",
          help_flag, verbose_flag);

  for (index = optind; index < argc; index++)
    printf ("Non-option argument %s\n", argv[index]);
  return 0;

}



//_______________________________________________________________________
int main(int argc, char **argv)
{
const size_t PAGE_SIZE = sysconf(_SC_PAGE_SIZE);

if (argc == 1)
{
	// No arguments were passed, so print usage text
	usage();
	return 1;
}

// If the VALUE argument was given, we'll perform a write operartion
bool is_write = (argc == 3) ? true : false;

const uint32_t ADDRESS = strtoul(argv[1], NULL, 0);

// Open the /dev/mem file, which is an image of the main system memory
// We use synchronous write operations (O_SYNC) to ensure that the value
// is fully written to the underlying hardware before the write call returns.
int fd = open("/dev/mem", O_RDWR | O_SYNC);
if (fd == -1)
{
	printf(stderr, "failed to open /dev/mem.\n");
	return 1;
}


// mmap needs to map memory at page boudries (address we map needs to be page-algned). ~(PAGE_SIZE - 1) is the bit mask that handles this
uint32_t page_aligned_addr = ADDRESS & ~(PAGE_SIZE - 1);
printf("memory addresses:\n");
printf("---------------------------------------------------------\n");
printf("page aligned address = 0x%x\n", page_aligned_addr);

// Map a page of physical memory into virtual memory. See mmap man page for info
uint32_t *page_virtual_addr = (uint32_t *)mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, page_aligned_addr);
if (page_virtual_addr == MAP_FAILED)
{
	printf(stderr, "failed to map memory/\n");
	return 1;
}
printf("page_virutal_addr = %p\n", page_virtual_addr);

// we need to offset the provided address
uint32_t offset_in_page = ADDRESS & (PAGE_SIZE - 1);
printf("offset in page = 0x%x\n", offset_in_page);

// Compute the virtual address corresponding to ADDRESS. Because
// page_virtual_addr and target_virtual_addr are both uint32_t pointers,
// pointer addition multiplies the pointer address by the number of bytes
// needed to store a uint32_t (4 bytes); e.g., 0x10 + 4 = 0x20, not 0x14.
// Consequently, we need to divide offset_in_page by 4 bytes to make the
// pointer addition return our desired address (0x14 in the example).
// We use volatile because the value at target_virtual_addr could change
// outside of our program; the address refers to memory-mapped I/O
// that could be changed by hardware. volatile tells the compiler to
// not optimize accesses to this memory address.
volatile uint32_t *target_virtual_addr = page_virtual_addr + offset_in_page/sizeof(uint32_t *);
printf("target_virtual_addr = %p\n", target_virtual_addr);
printf("----------------------------------------------------------\n");

if (is_write)
{
	const uint32_t VALUE = strtoul(argv[2], NULL, 0);
	*target_virtual_addr = VALUE;
}
else
{
	printf("\nvalue at 0x%x == 0x%x\n", ADDRESS, *target_virtual_addr);
}

return 0;

} 
*/