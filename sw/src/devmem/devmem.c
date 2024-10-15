#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <sys/mman.h> // FOR mapp
#include <fcntl.h> // for file open flags
#include <unistd.h> // for getting the page size

void usage()
{
	fprintf(stderr, "devmem ADDRESS [VALUE]\n");
	fprintf(stderr, "  devmem can be used to read/write to physical memory via the /dev/memdevice.\n");
	fprintf(stderr, "  devmem will only read/write 32-bit values.\n\n");
	fprintf(stderr, "  Arguments:\n");
	fprintf(stderr, "    ADDRESS The address to read/write to/from\n");
 	fprintf(stderr, "    VALUE   The optional value to write to ADDRESS; if not given, a read will be performed.\n");
}

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
	fprintf(stderr, "failed to open /dev/mem.\n");
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
	fprintf(stderr, "failed to map memory/\n");
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
