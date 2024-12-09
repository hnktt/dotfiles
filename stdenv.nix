{ ... }:
rec {
  isDarwin =
    system:
    builtins.elem system [
      "aarch64-darwin"
      "x86_64-darwin"
    ];

  isLinux =
    system:
    builtins.elem system [
      "aarch64-linux"
      "x86_64-linux"
      "i686-linux"
    ];
}
