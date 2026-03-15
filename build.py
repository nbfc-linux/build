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
    def __init__(self, os, image, project, package_glob):
        self.os = os
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
        script = './packaging/%s/%s.sh' % (self.project, self.os)
        dest = '%s/root' % self.chroot_dir
        print("Copying %s to %s" % (script, dest))
        shutil.copy(script, dest)
        run('chroot', self.chroot_dir, './root/%s.sh' % self.os)

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

DEBIAN_IMAGE = "docker.io/library/debian:trixie"
FEDORA_IMAGE = "registry.fedoraproject.org/fedora:43"
OPENSUSE_IMAGE = "registry.opensuse.org/opensuse/tumbleweed:latest"
ARCHLINUX_IMAGE = "docker.io/library/archlinux:latest"

builds = [
    # NBFC-Linux
    ProjectBuild("debian",     DEBIAN_IMAGE,    "nbfc-linux", "*.deb"),
    ProjectBuild("fedora",     FEDORA_IMAGE,    "nbfc-linux", "*.rpm"),
    ProjectBuild("opensuse",   OPENSUSE_IMAGE,  "nbfc-linux", "*.rpm"),
    ProjectBuild("arch-linux", ARCHLINUX_IMAGE, "nbfc-linux", "*.pkg.tar.zst"),

    # NBFC-Gtk
    ProjectBuild("debian",     DEBIAN_IMAGE,    "nbfc-gtk",   "*.deb"),
    ProjectBuild("fedora",     FEDORA_IMAGE,    "nbfc-gtk",   "*.rpm"),
    ProjectBuild("opensuse",   OPENSUSE_IMAGE,  "nbfc-gtk",   "*.rpm"),
    ProjectBuild("arch-linux", ARCHLINUX_IMAGE, "nbfc-gtk",   "*.pkg.tar.zst"),

    # NBFC-Qt
    ProjectBuild("debian",     DEBIAN_IMAGE,    "nbfc-qt",    "*.deb"),
    ProjectBuild("fedora",     FEDORA_IMAGE,    "nbfc-qt",    "*.rpm"),
    ProjectBuild("opensuse",   OPENSUSE_IMAGE,  "nbfc-qt",    "*.rpm"),
    ProjectBuild("arch-linux", ARCHLINUX_IMAGE, "nbfc-qt",    "*.pkg.tar.zst")
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

    build.create_chroot()
    try:
        build.mount_chroot()
        build.package()
        build.move_package()
    finally:
        build.umount_chroot()
