with import <nixpkgs> {
  config = {
    allowUnfree = true;
  };
};

let
  systemLibs = [
    pkgs.glib
    pkgs.cudatoolkit
    pkgs.libGLU
    pkgs.libGL
    pkgs.xorg.libXi
    pkgs.xorg.libXmu
    pkgs.freeglut
    pkgs.xorg.libXext
    pkgs.xorg.libX11
    pkgs.xorg.libXv
    pkgs.xorg.libXrandr
    pkgs.zlib
    pkgs.ncurses5
    pkgs.stdenv.cc
    pkgs.binutils
  ];

in
mkShell {
  buildInputs = systemLibs;

  shellHook = ''
    # Make system libraries available to Python packages that use C extensions
    export CUDA_HOME=${pkgs.cudatoolkit}
    export CUDA_PATH=${pkgs.cudatoolkit}

    # Library path setup - using system NVIDIA drivers
    export LD_LIBRARY_PATH=${stdenv.cc.cc.lib}/lib:/run/opengl-driver/lib
    export LD_LIBRARY_PATH="${pkgs.cudatoolkit}/lib64:${pkgs.cudatoolkit}/lib:$LD_LIBRARY_PATH"
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath systemLibs}:$LD_LIBRARY_PATH"

    # Add CUDA bins to PATH
    export PATH=${pkgs.cudatoolkit}/bin:$PATH

    # CUDA specific flags
    export EXTRA_LDFLAGS="-L/lib -L${pkgs.cudatoolkit}/lib64 -L${pkgs.cudatoolkit}/lib"
    export EXTRA_CCFLAGS="-I/usr/include -I${pkgs.cudatoolkit}/include"
  '';
}
