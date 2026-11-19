/* usim --- MIT CADR simulator
 */

#include <err.h>
#include <limits.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include <sys/time.h>

#ifdef WITH_SDL3
#define SDL_MAIN_USE_CALLBACKS
#include <SDL3/SDL_main.h>
#include <SDL3/SDL.h>
#include <SDL3/SDL_revision.h>
#endif

#include "colortv.h"
#include "config.h"
#include "diagnostic-interface.h"
#include "disk-unit.h"
#include "disk-controller.h"
#include "dump.h"
#include "idle.h"
#include "iob.h"
#include "kbd.h"
#include "machine-control.h"
#include "main-memory.h"
#include "misc.h"
#include "tape-controller.h"
#include "tape-drive.h"
#include "tv.h"
#include "ucfg.h"
#include "ucode.h"
#include "udiss.h"
#include "usim.h"
#include "usym.h"
#include "utrace.h"

#ifdef WITH_SDL3
#include "sdl3-audio.h"
#include "sdl3-keyboard.h"
#include "sdl3-mouse.h"
#include "sdl3-video.h"
#elif WITH_SDL2
#include "sdl2.h"
#elif WITH_X11
#include "x11.h"
#endif

#define BOOL2STR(X) (X ? "true" : "false")

// usim.ini options
char usim_state_filename[PATH_MAX] = {0};
char usim_sys_directory[PATH_MAX] = {0};
char usim_fs_root_directory[PATH_MAX] = {0};

typedef enum
{
	usim_app_failure,
	usim_app_success,
	usim_app_continue
} usim_app_t;

static char *config_filename;
static bool dump_state_flag;

char window_title[1024] = {0};
bool apply_new_window_title = false;

bool dump_running_config_flag = false;
char dump_running_config_filename[PATH_MAX] = {0};

bool colortv_enabled = false;
bool verbose_dump_state_flag;
bool warm_boot_flag;
char *warm_boot_filename;
bool headless;

symtab_t sym_mcr;
symtab_t sym_prom;

static void
sighup_handler(__attribute__((unused)) int arg)
{
    NOTICE(TRACE_USIM, "usim: sighup_handler\n");
    ucfg_load_config_file(config_filename);
}

static void
sigint_handler(__attribute__((unused)) int arg)
{
    NOTICE(TRACE_USIM, "usim: sigint_handler\n");
    machine_control_shutdown();
}

static void
sigterm_handler(__attribute__((unused)) int arg)
{
    NOTICE(TRACE_USIM, "usim: sigterm_handler\n");
    machine_control_shutdown();
}

static void
siginfo_handler(__attribute__((unused)) int arg)
{
    NOTICE(TRACE_USIM, "usim: siginfo_handler\n");
    dump_state(false, 0);
    save_state(NULL);
    save_screenshot();
}

static void
run_at_1hz(void)
{
    usim_update_window_title();
}

static void
run_at_60hz(void)
{
    static int div_to_1 = 0;

    tv_assert_interrupt();
    if (colortv_enabled) colortv_assert_interrupt();

    the_60_cycle_clock++;

    div_to_1++;
    if (div_to_1 >= 60)
    {
        run_at_1hz();
        div_to_1 = 0;
    }
}

static void
sigalrm_handler(__attribute__((unused)) int arg)
{
    run_at_60hz();
}

static void
print_header(void)
{
	printf("CADR emulator v" VERSION " " USIM_BACKEND "-" USIM_BUILD_TYPE "\n");
}

static bool dump_running_config(void);
static bool dump_running_config_to_stdout(void);

static void
usage(void)
{
    printf("usage: usim [OPTION]...\n");
	printf("\n");

	printf("  -c FILE       configuration file (default: %s)\n", config_filename);
#ifdef WITH_SDL3
	printf("  -g X,Y[,DISP] set window position to X,Y overriding the config (decimal integers)\n");
#else
	printf("  -g X,Y        set window position to X,Y overriding the config (decimal integers)\n");
#endif

	printf("  -p [FILE]     print running configuration (for stdout use -)\n");

	printf("  -H            run headless, overriding usim:headless in the config\n");

#ifdef WITH_SDL3
    printf("  -a            enable Color TV\n");
#endif

	printf("  -w [FILE]     warm boot (from usim:state_filename or FILE)\n");

	printf("  -d            dump all PC history of state on halt\n");
	printf("  -D            like -d, but verbose\n");

#ifndef DISABLE_FULL_TRACE_AFTER_LC
	printf("  -f LC         enable *full* tracing after lc reaches LC (decimal integer)\n");
#endif
#ifndef DISABLE_DUMP_AT_LC
	printf("  -l LC         dump state whenever lc reaches LC (decimal integer)\n");
#endif
#ifndef DISABLE_TRACE_MEMORY
	printf("  -t VMEM       add a read/write trace for virtual memory location VMEM (decimal integer)\n");
#endif
#ifndef DISABLE_DUMP_AT_NPC
	printf("  -u npc        dump state whenever the microcode pc reaches npc (decimal integer)\n");
#endif

	printf("  -h            display this help message\n");
}

static usim_app_t
usim_init(int argc, char **argv)
{
    srand(time(NULL));
    // strdup so it can always be freed
	config_filename = strdup("usim.ini");
	warm_boot_flag = false;
    warm_boot_filename = NULL;
    bool gparams = false;
    int gx=0, gy=0, gdisplay=0;
    // like gparams, applied after the config file so -H wins over it
    bool headless_flag = false;
	int c;
    // leading : means getopt does not print error and 
    // returns ':' for missing option, which is handled explicitly
    while ((c = getopt(argc, argv, ":ac:dDf:g:hHl:p:t:u:w:")) != -1) 
    {
        switch (c) 
        {
            case 'a': colortv_enabled = true; break;
            case 'c': config_filename = strdup(optarg); break;
            case 'd': dump_state_flag = true; break;
            case 'D': verbose_dump_state_flag = true; break;

#ifndef DISABLE_FULL_TRACE_AFTER_LC
            case 'f': 
                      {
                          full_trace_lc = atoi(optarg);
                          printf("enabling full tracing after LC #x%x\n", 
                                  full_trace_lc);
                      }
                      break;
#else
            case 'f': errx(1, "-f is disabled at build time"); break;
#endif

            case 'g':
                      {
                          gparams = true;
                          int x, y, display;
                          int nc = sscanf(optarg, "%d,%d,%d", &x, &y, &display);
                          if (nc >= 2) {
                              gx = x;
                              gy = y;
                              if (nc == 3) gdisplay = display;
                          } else {
                              fprintf(stderr, "invalid value, specify as -g X,Y[,DISP]\n");
                              return usim_app_failure;
                          }
                      }
                      break;
            case 'h': print_header(); usage(); return usim_app_success;

            case 'H': headless_flag = true; break;

#ifndef DISABLE_DUMP_AT_LC
            case 'l': add_dump_lc(atoi(optarg)); break;
#else
            case 'l': errx(1, "-l is disabled at build time"); break;
#endif

            case 'p': 
                dump_running_config_flag = true;
                strcpy(dump_running_config_filename, optarg);
                break;

#ifndef DISABLE_TRACE_MEMORY
            case 't': add_trace_vmem(atoi(optarg)); break;
#else
            case 't': errx(1, "-t is disabled at build time"); break;
#endif

#ifndef DISABLE_DUMP_AT_NPC
            case 'u': add_dump_npc(atoi(optarg)); break;
#else
            case 'u': errx(1, "-u is disabled at build time"); break;
#endif

            case 'w': 
                  warm_boot_flag = true;
                  warm_boot_filename = strdup(optarg);
                  break;

            // -p and -w has optional arguments
            case ':':
                  {
                      switch (optopt)
                      {
                          case 'p':
                              dump_running_config_flag = true;
                              dump_running_config_filename[0] = '-';
                              break;

                          case 'w':
                              warm_boot_flag = true;
                              warm_boot_filename = NULL;
                              break;

                          default:
                              usage();
                              return usim_app_failure;
                      }
                  }
                  break;

            default:
                      usage();
                      return usim_app_failure;
        }
    }

	argc -= optind;
	argv += optind;
	if (argc > 0) 
    {
		usage();
		return usim_app_failure;
	}

    /*
     * The banner is chatter, not configuration.  When the running
     * configuration is dumped to stdout it is meant to be redirected
     * into a usim.ini, so the banner must not land in it.
     */
    if (!dump_running_config_to_stdout()) print_header();

    bool config_file_access_ok = true;

    if (access(config_filename, R_OK) != 0)
    {
        config_file_access_ok = false;

        if (!dump_running_config_flag)
        {
            errx(1, "cannot access or read config file: %s", config_filename);
        }
    }

    ucfg_init();

	if (config_file_access_ok)
    {
        if (!ucfg_load_config_file(config_filename)) return usim_app_failure;
    }

    if (gparams)
    {
        window_position_x = gx;
        window_position_y = gy;
        window_display = gdisplay;
    }

    if (headless_flag) headless = true;

    if (streq(ucfg.usim_state_filename, ""))
    {
        char temp[PATH_MAX];

        if (snprintf(temp, sizeof(temp), "usim-%s.state", ucfg.chaos_myname) <= 0)
        {
            errx(1, "error when preparing the state filename with chaos myname");
        }

        strcpy(usim_state_filename, strlwr(temp));
    }
    else
    {
        strcpy(usim_state_filename, ucfg.usim_state_filename);
    }

    if (warm_boot_flag)
    {
        if (warm_boot_filename == NULL)
        {
            warm_boot_filename = strdup(usim_state_filename);
        }

        warnx("warm_boot_filename: %s", warm_boot_filename);
    }

    /*
     * Parsing the disk configuration is pure string work and cannot
     * fail on a missing file, so it runs here, before the machine is
     * brought up, and completes the running configuration.
     */
#define DISK_UNIT_CONFIGURE(N) disk_unit_configure(N, ucfg.disk_disk##N)
    DISK_UNIT_CONFIGURE(0);
    DISK_UNIT_CONFIGURE(1);
    DISK_UNIT_CONFIGURE(2);
    DISK_UNIT_CONFIGURE(3);
    DISK_UNIT_CONFIGURE(4);
    DISK_UNIT_CONFIGURE(5);
    DISK_UNIT_CONFIGURE(6);
    DISK_UNIT_CONFIGURE(7);
#undef DISK_UNIT_CONFIGURE

    /*
     * -p is how a usim.ini is generated in the first place, so it has
     * to work in a directory that has nothing in it yet.  Everything
     * the dump needs is in place by now; everything below opens files
     * that a not-yet-configured machine does not have.
     */
    if (dump_running_config_flag)
    {
        return dump_running_config() ? usim_app_success : usim_app_failure;
    }

    // run usim
#if SIGINFO
	signal(SIGINFO, siginfo_handler);
#endif
	signal(SIGUSR1, siginfo_handler);
	signal(SIGHUP, sighup_handler);
    signal(SIGINT, sigint_handler);
    signal(SIGTERM, sigterm_handler);

    ucode_init();

    /*
     * tv_init only picks the monitor dimensions.  It touches no
     * backend, and the TV bus code and the screenshot need those
     * dimensions, so it runs headless as well; what headless skips is
     * the backend below.
     */
	tv_init();
    if (colortv_enabled) colortv_init();

    NOTICE(TRACE_USIM, "memory: %zukW (kilowords) installed (%zu pages)\n", 
            main_memory_npages / 4, main_memory_npages);

#define DISK_UNIT_LOAD_PACK(N) disk_unit_load_pack(N)
    DISK_UNIT_LOAD_PACK(0);
    DISK_UNIT_LOAD_PACK(1);
    DISK_UNIT_LOAD_PACK(2);
    DISK_UNIT_LOAD_PACK(3);
    DISK_UNIT_LOAD_PACK(4);
    DISK_UNIT_LOAD_PACK(5);
    DISK_UNIT_LOAD_PACK(6);
    DISK_UNIT_LOAD_PACK(7);
#undef DISK_UNIT_LOAD_PACK

    disk_controller_init();

#define TAPE_DRIVE_INIT(N) tape_drive_init(N, ucfg.tape_tape##N)
    TAPE_DRIVE_INIT(0);
    TAPE_DRIVE_INIT(1);
    TAPE_DRIVE_INIT(2);
    TAPE_DRIVE_INIT(3);
    TAPE_DRIVE_INIT(4);
    TAPE_DRIVE_INIT(5);
    TAPE_DRIVE_INIT(6);
    TAPE_DRIVE_INIT(7);
#undef TAPE_DRIVE_INIT

    tape_controller_init();

	iob_init();

    idle_init();

    return usim_app_continue;
}

static bool
dump_running_config_to_stdout(void)
{
    return dump_running_config_flag && (dump_running_config_filename[0] == '-');
}

static bool
dump_running_config(void)
{
    FILE* fp = NULL;
    if (dump_running_config_to_stdout()) fp = stdout;
    else 
    {
        fp = fopen(dump_running_config_filename, "w");
    }

    if (fp == NULL)
    {
        warnx("path %s is not writable", dump_running_config_filename);
        return false;
    }

    ucfg_dump_running_config(fp);
    
    if (fp != stdout)
    {
        fclose(fp);
    }

    return true;
}

static void
usim_post_init(void)
{
    if (warm_boot_flag) iob_prepare_for_warm_boot();

    signal(SIGALRM, sigalrm_handler);
    struct itimerval itimer;
    itimer.it_interval.tv_sec = 0;
    itimer.it_interval.tv_usec = 16666;
    itimer.it_value.tv_sec = 0;
    itimer.it_value.tv_usec = 16666;
    setitimer(ITIMER_REAL, &itimer, 0);
}

void
usim_update_window_title(void)
{
    snprintf(window_title, sizeof(window_title), "%s [%s]", 
            ucfg.chaos_myname == NULL ? "usim" : ucfg.chaos_myname,
            idle_is_idle() ? "idle" : "running");

    apply_new_window_title = true;
}

static void
usim_quit(void)
{
    disk_controller_quit();
    tape_controller_quit();
    iob_quit();
    idle_quit();

    if (machine_cycles > 0)
    {
        if (dump_state_flag || verbose_dump_state_flag)
        {
            dump_state(verbose_dump_state_flag, 0);
        }
        else
        {
            // number of PCs in history to dump at the end of normal exit
            // without -d or -D options
            const int dump_state_at_exit_length = 5;
            dump_state(false, dump_state_at_exit_length);
        }

        save_state(NULL);
        save_screenshot();
    }

    ucfg_quit();

    // release symbols, there are strdupped things in them
    sym_release(&sym_mcr);
    sym_release(&sym_prom);

    // these are strdupped
    free(config_filename);
    free(warm_boot_filename);
}

#ifdef WITH_SDL3

// SDL3 main callback functions below are explained here:
// https://wiki.libsdl.org/SDL3/README/main-functions

SDL_AppResult
SDL_AppInit
	(
	 __attribute__((unused)) void **appstate, 
	 int argc, 
	 char **argv
	)
{
	switch (usim_init(argc, argv))
	{
		case usim_app_failure: 
			return SDL_APP_FAILURE;
		case usim_app_success:
			return SDL_APP_SUCCESS;
		case usim_app_continue:
			break;
	}

	NOTICE(TRACE_USIM, 
			"usim: built with SDL v%d.%d.%d (%s)\n",
			SDL_MAJOR_VERSION,
			SDL_MINOR_VERSION,
			SDL_MICRO_VERSION,
			SDL_REVISION);

	const int sdl_version = SDL_GetVersion();

	NOTICE(TRACE_USIM, 
			"sdl3: SDL v%d.%d.%d (%s)\n",
			SDL_VERSIONNUM_MAJOR(sdl_version),
			SDL_VERSIONNUM_MINOR(sdl_version),
			SDL_VERSIONNUM_MICRO(sdl_version),
			SDL_GetRevision());

    // this causes an exception thrown from SDL3 audio subsystem
    // if under debugger and debugger may stop due to the exception
    // it seems the exception can be ignored, so either continue 
    // or do not enable stop on exceptions in the debugger
    /*
     * Headless still runs as an SDL app -- SDL drives the main loop
     * through these callbacks -- but it initializes no video, audio,
     * keyboard or mouse, and so opens no window.  Events are all it
     * needs.  The machine itself does not go through SDL at all.
     */
	if (!SDL_Init(headless ? SDL_INIT_EVENTS : (SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_EVENTS))) 
    {
		ERR(TRACE_USIM, "sdl init failed: %s\n", SDL_GetError());
		return SDL_APP_FAILURE;
	}

	if (headless)
	{
		NOTICE(TRACE_USIM, "sdl3: headless, no window\n");
	}
	else
	{
		// it might be important to initialize video first
		// things may depend on a valid window handle
		if (!sdl3_video_init()) 
		{
			ERR(TRACE_USIM, "usim: sdl3-video init failed, quitting\n");
			return SDL_APP_FAILURE;
		}

		usim_update_window_title();

		if (!sdl3_audio_init()) 
		{
			WARNING(TRACE_USIM, "usim: sdl3-audio init failed, continuing without audio\n");
		}

		if (!sdl3_keyboard_init())
		{
			ERR(TRACE_USIM, "usim: sdl3-keyboard init failed, quitting\n");
			return SDL_APP_FAILURE;
		}

		if (!sdl3_mouse_init()) 
		{
			ERR(TRACE_USIM, "usim: sdl3-mouse init failed, quitting\n");
			return SDL_APP_FAILURE;
		}
	}

    usim_post_init();

    if (!machine_control_start_nonblocking())
    {
        ERR(TRACE_USIM, "usim: cannot start machine nonblocking\n");
        return SDL_APP_FAILURE;
    }

	return SDL_APP_CONTINUE;
}

SDL_AppResult
SDL_AppIterate(__attribute__((unused)) void *appstate)
{
	// if machine is halted, quit sdl
	if (machine_state.halted) return SDL_APP_SUCCESS;

	if (headless)
	{
		/*
		 * There is no window to title or to draw.  Without the
		 * present below there is nothing to pace this callback
		 * either, so sleep rather than spin; the machine runs in
		 * its own thread and the 60Hz TV interrupt comes from the
		 * interval timer, so neither depends on this.
		 */
		SDL_Delay(16);
		return SDL_APP_CONTINUE;
	}

	// window title update is here because it has to be on the same thread
	if (apply_new_window_title)
	{
		sdl3_video_update_window_title(window_title);
        apply_new_window_title = false;
	}

	// update display
	if (!sdl3_video_present()) return SDL_APP_FAILURE;

	return SDL_APP_CONTINUE;
}

SDL_AppResult
SDL_AppEvent
	(
	 __attribute__((unused)) void *appstate, 
	 SDL_Event *event
	)
{
	switch (event->type) 
    {
		case SDL_EVENT_KEY_DOWN:
            if (event->key.windowID != main_window_id) break;
            idle_keyboard_activity();
			sdl3_keyboard_key_down(event);
			break;

		case SDL_EVENT_KEY_UP:
            if (event->key.windowID != main_window_id) break;
            idle_keyboard_activity();
			sdl3_keyboard_key_up(event);
			break;

		case SDL_EVENT_MOUSE_MOTION: 
            if (event->motion.windowID != main_window_id) break;
            idle_mouse_activity();
			sdl3_mouse_motion(event); 
			break;

		case SDL_EVENT_MOUSE_BUTTON_DOWN: 
            if (event->button.windowID != main_window_id) break;
            idle_mouse_activity();
			sdl3_mouse_button_down(event); 
			break;

		case SDL_EVENT_MOUSE_BUTTON_UP: 
            if (event->button.windowID != main_window_id) break;
            idle_mouse_activity();
			sdl3_mouse_button_up(event); 
			break;

        // when window is closed with close window icon/button/X
        // this event is sent if there are multiple windows
        case SDL_EVENT_WINDOW_CLOSE_REQUESTED:
        // this event is sent if there is only one window
		case SDL_EVENT_QUIT:
            // this happens for example the window is closed with the close button
            DEBUG(TRACE_USIM, "usim: SDL_EVENT_QUIT\n");
            machine_control_shutdown();
			break;
	}

	return SDL_APP_CONTINUE;
}

void
SDL_AppQuit
	(
	 __attribute__((unused)) void *appstate, 
	 __attribute__((unused)) SDL_AppResult result
	)
{
	if (!headless)
	{
		sdl3_mouse_quit();
		sdl3_keyboard_quit();
		sdl3_audio_quit();
		sdl3_video_quit();
	}

	SDL_Quit();

	usim_quit();
}

#else

int
main(int argc, char *argv[])
{
	usim_app_t init_ret = usim_init(argc, argv);
	switch (init_ret)
	{
		case usim_app_failure: 
		case usim_app_success:
			break;
        case usim_app_continue:
            {
                if (!headless)
                {
#if defined(WITH_X11)
                    x11_init();
#elif defined(WITH_SDL2)
                    sdl2_init();
#endif
                }
                usim_post_init();
                machine_control_start_blocking();
            }
			break;
	}
	usim_quit();
	if (init_ret == usim_app_failure) return EXIT_FAILURE;
	return EXIT_SUCCESS;
}

#endif

char*
disassemble_pc(uint32_t pc)
{
    if (machine_state.promdisabled) return uinst_desc(imem[pc], &sym_mcr);
    else return uinst_desc(prom[pc], &sym_prom);
}

char*
disassemble_pc2(uint32_t pc, bool pc_imem)
{
    if (pc_imem) return uinst_desc(imem[pc], &sym_mcr);
    else return uinst_desc(prom[pc], &sym_prom);
}


char*
disassemble_inst(uint64_t u)
{
    if (machine_state.promdisabled) return uinst_desc(u, &sym_mcr);
    else return uinst_desc(u, &sym_prom);
}

char*
disassemble_inst2(uint64_t u, bool pc_imem)
{
    if (pc_imem) return uinst_desc(u, &sym_mcr);
    else return uinst_desc(u, &sym_prom);
}
