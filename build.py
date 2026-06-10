#!/usr/bin/env python3

import os
import sys
import glob
import shutil
import subprocess
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--dir', default='/tmp')
parser.add_argument('--package-dir', default='/tmp/packages')
parser.add_argument('--ignore-errors', action='store_true')
parser.add_argument('--project', action='append',
    help='Only build project. Can be specified multiple times')
parser.add_argument('--os', action='append',
    help='Only build for OS. Can be specified multiple times')
parser.add_argument('--dry', action='store_true',
    help='Only print out what would be built')

OPTS = parser.parse_args()

SCRIPT_PATH = os.path.abspath(sys.argv[0])
SCRIPT_DIR = os.path.dirname(SCRIPT_PATH)
os.chdir(SCRIPT_DIR)

if os.geteuid() != 0:
    raise Exception("Please run this script as root")

def run(*args):
    result = subprocess.run(
        args,
        stderr=sys.stderr,
        stdout=sys.stdout,
        check=False)

    if result.returncode != 0:
        raise Exception('Command `%s` failed' % ' '.join(args))

class ProjectBuild:
    def __init__(self, os, build_script, image, project, package_glob):
        self.os = os
        self.build_script = build_script
        self.image = image
        self.project = project
        self.package_glob = package_glob
        self.directory = OPTS.dir
        self.chroot_dir = '%s/%s-%s-chroot' % (self.directory, self.os, self.project)
        self.podman_root = '%s/podman-root' % self.directory
        self.podman_runroot = '%s/podman-runroot' % self.directory

    def create_chroot(self):
        if os.path.exists(self.chroot_dir):
            print('Skip installing chroot %s ...' % self.chroot_dir)
            return

        print('Installing chroot %s ...' % self.chroot_dir)
        run('./create_chroot.sh', self.podman_root, self.podman_runroot, self.image, self.chroot_dir)

    def mount_chroot(self):
        shutil.copy('/etc/resolv.conf', '%s/etc/resolv.conf' % self.chroot_dir)

        run('mount', '-t', 'proc', 'proc', '%s/proc' % self.chroot_dir)

        run('mount', '--rbind', '/sys',    '%s/sys'  % self.chroot_dir)
        run('mount', '--make-rslave',      '%s/sys'  % self.chroot_dir)

        run('mount', '--rbind', '/dev',    '%s/dev'  % self.chroot_dir)
        run('mount', '--make-rslave',      '%s/dev'  % self.chroot_dir)

        run('mount', '--rbind', '/run',    '%s/run'  % self.chroot_dir)
        run('mount', '--make-rslave',      '%s/run'  % self.chroot_dir)

    def umount_chroot(self):
        try: run('umount', '-R', '%s/dev'  % self.chroot_dir)
        except: pass
        try: run('umount', '-R', '%s/sys'  % self.chroot_dir)
        except: pass
        try: run('umount', '-R', '%s/proc' % self.chroot_dir)
        except: pass
        try: run('umount', '-R', '%s/run'  % self.chroot_dir)
        except: pass

    def package(self):
        print('Building %s for %s ...' % (self.project, self.os))
        script = './packaging/%s/%s' % (self.project, self.build_script)
        dest = '%s/root' % self.chroot_dir
        print("Copying %s to %s" % (script, dest))
        shutil.copy(script, dest)
        run('chroot', self.chroot_dir, './root/%s' % self.build_script)

    def move_package(self):
        pattern = '%s/root/%s/%s' % (self.chroot_dir, self.project, self.package_glob)
        files = glob.glob(pattern)
        if not files:
            raise Exception('No package found')
        if len(files) > 1:
            raise Exception('Too much packages found: %s' % files)
        package = files[0]
        package_basename = os.path.basename(package)
        print("Found package: ", package)
        dest_package = '%s/%s-%s' % (OPTS.package_dir, self.os, package_basename)
        print("Copying %s to %s" % (package, dest_package))
        shutil.copy(package, dest_package)

os.makedirs(OPTS.package_dir, exist_ok=True)

DEBIAN_TRIXIE     = "docker.io/library/debian:trixie"
DEBIAN_BOOKWORM   = "docker.io/library/debian:bookworm"
DEBIAN_LATEST     = DEBIAN_TRIXIE

UBUNTU_NOBLE      = "ubuntu:noble"
UBUNTU_JAMMY      = "ubuntu:jammy"
UBUNTU_LATEST     = UBUNTU_NOBLE

LINUX_MINT_22     = "docker.io/linuxmintd/mint22-amd64"
LINUX_MINT_21     = "docker.io/linuxmintd/mint21-amd64"
LINUX_MINT_LATEST = LINUX_MINT_22

FEDORA_44         = "registry.fedoraproject.org/fedora:44"
FEDORA_43         = "registry.fedoraproject.org/fedora:43"
FEDORA_LATEST     = FEDORA_44

OPENSUSE_IMAGE    = "registry.opensuse.org/opensuse/tumbleweed:latest"
ARCHLINUX_IMAGE   = "docker.io/library/archlinux:latest"

builds = [
    # NBFC-Linux
    ProjectBuild("debian-trixie",   "debian.sh",     DEBIAN_TRIXIE,   "nbfc-linux", "*.deb"),
    ProjectBuild("debian-bookworm", "debian.sh",     DEBIAN_BOOKWORM, "nbfc-linux", "*.deb"),
    ProjectBuild("ubuntu-noble",    "debian.sh",     UBUNTU_NOBLE,    "nbfc-linux", "*.deb"),
    ProjectBuild("ubuntu-jammy",    "debian.sh",     UBUNTU_JAMMY,    "nbfc-linux", "*.deb"),
    ProjectBuild("linux-mint-22",   "debian.sh",     LINUX_MINT_22,   "nbfc-linux", "*.deb"),
    ProjectBuild("linux-mint-21",   "debian.sh",     LINUX_MINT_21,   "nbfc-linux", "*.deb"),
    ProjectBuild("fedora-44",       "fedora.sh",     FEDORA_44,       "nbfc-linux", "*.rpm"),
    ProjectBuild("fedora-43",       "fedora.sh",     FEDORA_43,       "nbfc-linux", "*.rpm"),
    ProjectBuild("opensuse",        "opensuse.sh",   OPENSUSE_IMAGE,  "nbfc-linux", "*.rpm"),
    ProjectBuild("arch-linux",      "arch-linux.sh", ARCHLINUX_IMAGE, "nbfc-linux", "*.pkg.tar.zst"),

    # NBFC-Gtk
    ProjectBuild("debian",          "debian.sh",     DEBIAN_LATEST,   "nbfc-gtk",   "*.deb"),
    ProjectBuild("fedora",          "fedora.sh",     FEDORA_LATEST,   "nbfc-gtk",   "*.rpm"),
    ProjectBuild("opensuse",        "opensuse.sh",   OPENSUSE_IMAGE,  "nbfc-gtk",   "*.rpm"),
    ProjectBuild("arch-linux",      "arch-linux.sh", ARCHLINUX_IMAGE, "nbfc-gtk",   "*.pkg.tar.zst"),

    # NBFC-Qt
    ProjectBuild("debian",          "debian.sh",     DEBIAN_LATEST,   "nbfc-qt",    "*.deb"),
    ProjectBuild("fedora",          "fedora.sh",     FEDORA_LATEST,   "nbfc-qt",    "*.rpm"),
    ProjectBuild("opensuse",        "opensuse.sh",   OPENSUSE_IMAGE,  "nbfc-qt",    "*.rpm"),
    ProjectBuild("arch-linux",      "arch-linux.sh", ARCHLINUX_IMAGE, "nbfc-qt",    "*.pkg.tar.zst")
]

selected_builds = builds

if OPTS.project:
    selected_builds = filter(lambda rule: rule.project in OPTS.project, selected_builds)

if OPTS.os:
    selected_builds = filter(lambda rule: rule.os in OPTS.os, selected_builds)

for build in selected_builds:
    if OPTS.dry:
        print('Building:', build.os, build.project)
        continue

    try:
        build.create_chroot()
    except Exception as e:
        if OPTS.ignore_errors:
            continue
        else:
            raise e

    try:
        build.mount_chroot()
        build.package()
        build.move_package()
    except Exception as e:
        if OPTS.ignore_errors:
            continue
        else:
            raise e
    finally:
        build.umount_chroot()
