# To build image: sudo docker build -t arch_kicad-git:latest .
# To run the image: sudo docker run -t --name kicad_build -v ~/kicad_build/kicad_volume:/home/makeuser/ arch_kicad-git
# sudo docker build -q -t arch_kicad-git:latest . && sudo docker run -d -t --name kicad_build -v ~/kicad_docker/kicad_volume:/home/makeuser/ arch_kicad-git
FROM library/archlinux:latest
RUN pacman -Syyu base-devel git vim boost-libs curl desktop-file-utils glew glm opencascade python python-wxpython swig wxgtk3 ngspice boost cmake mesa zlib --noconfirm
RUN useradd -ms /bin/bash makeuser
USER makeuser
WORKDIR /home/makeuser/
CMD rm -rf kicad-git && git clone http://aur.archlinux.org/kicad-git && cd kicad-git && makepkg -c
# Uncomment this line and commend the previous one if you want to use four threads. Edit the '-j4' flag for '-jX' where X is the number of threads you want to use.
#CMD rm -rf kicad-git && git clone http://aur.archlinux.org/kicad-git && cd kicad-git && sed -i '44s/.*/make -j4\n /' PKGBUILD && makepkg -c
