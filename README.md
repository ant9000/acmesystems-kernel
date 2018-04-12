## DESCRIPTION

Scripts to automate kernel builds for AcmeSystem's boards.

## USAGE

The script `prepare.sh` will download and unpack the toolchains, the kernel source and AcmeSystem's patch. You only need to run it once, but calling it multiple times does no harm.

To compile the kernel, execute `kernel.sh` with a board name; any other arguments will be passed as is to the kernel makefile system. Without arguments, you'll get a usage with the list of supported boards.

For instance, use

```./kernel.sh roadrunner```

to compile a kernel for the RoadRunner board using the default configuration. The output will be available in `deploy/roadrunner/` (you will need to copy everything here on the board filesystem).

If you need to customize your build, use

```./kernel.sh roadrunner menuconfig```

(or `xconfig`, etc...), and then build again as before.
