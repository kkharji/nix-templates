{ pkgs, lib, path, cpath, overrides, extra, ... }:
let
  lua = (pkgs.lua5_4.override {
    packageOverrides = _: p: (overrides p);
  }).withPackages extra;

  resolveLuaPaths = paths: (map (str: lua.outPath + "/" + str) paths);
  joinLuaPaths = lib.concatStringsSep ";";
  LuaCPathSearchPaths = resolveLuaPaths lua.lua.LuaCPathSearchPaths;
  LuaPathSearchPaths = resolveLuaPaths lua.lua.LuaPathSearchPaths;

in {
  inherit lua;
  cpath = joinLuaPaths (LuaCPathSearchPaths ++ cpath);
  path = joinLuaPaths (LuaPathSearchPaths ++ path);
}
