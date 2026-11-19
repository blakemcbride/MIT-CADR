/* Link-time stubs: usim.o carries main(), so it is left out of the
 * test link.  Nothing here is reached by the ALU test. */
#include <limits.h>
#include <stdbool.h>
#include "usym.h"

char usim_state_filename[PATH_MAX];
char usim_sys_directory[PATH_MAX];
char usim_fs_root_directory[PATH_MAX];
symtab_t sym_mcr;
symtab_t sym_prom;
bool colortv_enabled;
bool headless;
int chaos_addr;
char *chaos_name;
void *host_data;
void readhosts(char *whoami, char *hoststable);
void readhosts(char *whoami, char *hoststable) { (void) whoami; (void) hoststable; }

char *disassemble_pc2(unsigned int pc, bool pc_imem);
char *disassemble_pc2(unsigned int pc, bool pc_imem) { (void) pc; (void) pc_imem; return ""; }
char *disassemble_inst2(unsigned long long u, bool pc_imem);
char *disassemble_inst2(unsigned long long u, bool pc_imem) { (void) u; (void) pc_imem; return ""; }
