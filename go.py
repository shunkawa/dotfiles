#!/usr/bin/env python3

from __future__ import print_function
import os
import argparse

description = """
Go deploy symlinks to dotfiles with GNU Stow.

Sample usage:
  ./go.py --stow --all
     Stow all folders in the src directory
  ./go.py -ua
     Unstow all folders in the src directory
  ./go.py -u git
     Stow the folder called "git" in the src directory
  ./go.py --unstow git
     Unstow the folder called "git" in the src directory
"""
src = os.path.join(os.path.expanduser("~"), ".config/dotfiles/src")


def stow(target):
    os.system("stow -v " + target + " -t $HOME -R;")


def stow_all():
    for subdir in os.listdir(src):
        stow(subdir)


def unstow(target):
    os.system("stow -D " + target + " -t $HOME -D;")


def unstow_all():
    for subdir in os.listdir(src):
        unstow(subdir)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument("-a", "--all", action="store_true")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("-s", "--stow", action="store_true")
    group.add_argument("-u", "--unstow", action="store_true")
    parser.add_argument("target", type=str,
                        help="Target directory to stow or unstow",
                        nargs="?")
    args = parser.parse_args()
    cwd = os.getcwd()
    os.chdir(src)
    if hasattr(args, "all"):
        if args.stow:
            stow_all()
        elif args.unstow:
            unstow_all()
    elif args.stow:
        stow(args.target)
    elif args.unstow:
        unstow(args.target)
    else:
        print(description)
    os.chdir(cwd)
