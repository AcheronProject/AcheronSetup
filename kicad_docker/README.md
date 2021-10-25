# KiCAD Nightly Build Dockerfile

This Dockerfile is used to build a fresh KiCAD nightly tarball which can be used by pacman to install that KiCAD version.

It is based on the Arch Linux docker file. To build the image, copy the Dockerfile and create a volume folder ``KICAD_VOLUME`` (don't forget to adjust its permissions), and run:

``docker build --rm -t arch_kicad-git:latest .``

This will build an image called ```arch_kicad-git``` which can be run inside a Docker container:

``docker run --rm -d -t --name kicad_build -v ${KICAD_VOLUME}:/home/makeuser/ arch_kicad-git``

The final binary will be located in ``${KICAD_VOLUME}/kicad-git/``.

## How it works

First, the Dockerfile pulls the ``archlinux:latest`` image, to which it then installs dependencies for the build. Then, an user called "makeuser" is added; the compilation process is undertaken with that user.

The ``docker build`` command provided uses the ``-t`` option to tag the image built; the ``:latest`` suffix makes it overwrite a previously built image.

Finally, once the image is build, the container is run. The Dockerfile contains the ``CMD`` directive which makes the build command run as soon as the container is started. The container is run using certain options:

- ``--rm`` automatically removes the container once it exits, that is, the building process is done;
- ``-d`` makes the container run in detached mode, so you can close the window and do other things while the process goes on;
- ``-t`` assigns the container a pseudo-tty so you can access it later for whatever reason.

The commands run basically pull the code from the [kicad-git](https://aur.archlinux.org/packages/kicad-git/) package in the Arch User Repository and compiles the code.

To monitor the container one can use ``docker stats``. I recommend

``docker stats --all --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"``

Which lists all containers and their CPU percentage and memory usage.

## Notes

The building process is quite CPU and memory intensive, so if you don't want it to overtake your CPU and RAM you might want to limit the container's CPU and memory usage.
