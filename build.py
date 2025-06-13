#!/usr/bin/env python3

import os
import sys
import glob
import shutil
import subprocess
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--chroot-prefix-dir', default='/tmp')
parser.add_argument('--project', action='append',
    help='Only build project. Can be specified multiple times')
parser.add_argument('--os', action='append',
    help='Only build for OS. Can be specified multiple times')
parser.add_argument('--dry', action='store_true',
    help='Only print out what would be built')

OPTS = parser.parse_args()

PACKAGE_DEST_DIR = "/tmp/packages"
DEBIAN_CHROOT    = os.path.join(OPTS.chroot_prefix_dir, "debian.nbfc-linux")
FEDORA_CHROOT    = os.path.join(OPTS.chroot_prefix_dir, "fedora.nbfc-linux")
OPENSUSE_CHROOT  = os.path.join(OPTS.chroot_prefix_dir, "opensuse.nbfc-linux")

script_path = os.path.abspath(sys.argv[0])
script_dir = os.path.dirname(script_path)
os.chdir(script_dir)

if os.geteuid() != 0:
    raise Exception("Please run this script as root")

def run(*args):
    result = subprocess.run(
        args,
        stderr=sys.stderr,
        stdout=sys.stdout,
        check=False)

    if result.returncode != 0:
        raise Exception('Command `%s` failed' % args)

def make_chroot(operating_system, chroot):
    script = './chroots/%s.sh' % operating_system

    if not os.path.exists(chroot):
        print('Installing %s to chroot %s' % (operating_system, chroot))
        run(script, chroot)
    else:
        print('Skip installing %s' % (operating_system,))

def build(operating_system, package_glob, package_prefix, chroot, project):
    make_chroot(operating_system, chroot)

    print('Building %s for %s in %s' % (project, operating_system, chroot))

    package_dest_dir = os.path.join(PACKAGE_DEST_DIR, project)
    os.makedirs(package_dest_dir, exist_ok=True)

    if not os.path.isdir(chroot):
        raise Exception("Chroot directory not found: %s" % chroot)

    build_script_filename = '%s.sh' % operating_system

    root_user_dir       = os.path.join(chroot, 'root')
    build_script        = os.path.join('./packaging', project, build_script_filename)
    chroot_build_script = os.path.join(root_user_dir, build_script_filename)
    build_command       = os.path.join('/root', build_script_filename)

    print("\tCopying %s to %s" % (build_script, chroot_build_script))
    shutil.copy(build_script, chroot_build_script)

    print("\tRunning arch-chroot ...")
    run('arch-chroot', chroot, build_command)

    print("\tSearching for package ...")
    files = glob.glob(os.path.join(root_user_dir, project, package_glob))
    if not files:
        raise Exception('No package found')
    if len(files) > 1:
        raise Exception('Too much packages found: %s' % files)
    package = files[0]
    print("\tFound package: ", package)

    package_basename = os.path.basename(package)

    print("\tCopying package ...")
    dest_package = os.path.join(package_dest_dir, "%s%s" % (package_prefix, package_basename))
    shutil.copy(package, dest_package)

os.makedirs(PACKAGE_DEST_DIR, exist_ok=True)

class BuildRule:
    def __init__(self, operating_system, package_glob, package_prefix, chroot, project):
        self.operating_system = operating_system
        self.package_glob = package_glob
        self.package_prefix = package_prefix
        self.chroot = chroot
        self.project = project

builds = [
    BuildRule('debian',   '*.deb', '',          DEBIAN_CHROOT,   'nbfc-qt'),
    BuildRule('debian',   '*.deb', '',          DEBIAN_CHROOT,   'nbfc-gtk'),
    BuildRule('debian',   '*.deb', '',          DEBIAN_CHROOT,   'nbfc-linux'),

    BuildRule('fedora',   '*.rpm', 'fedora-',   FEDORA_CHROOT,   'nbfc-qt'),
    BuildRule('fedora',   '*.rpm', 'fedora-',   FEDORA_CHROOT,   'nbfc-gtk'),
    BuildRule('fedora',   '*.rpm', 'fedora-',   FEDORA_CHROOT,   'nbfc-linux'),

    BuildRule('opensuse', '*.rpm', 'opensuse-', OPENSUSE_CHROOT, 'nbfc-qt'),
    BuildRule('opensuse', '*.rpm', 'opensuse-', OPENSUSE_CHROOT, 'nbfc-gtk'),
    BuildRule('opensuse', '*.rpm', 'opensuse-', OPENSUSE_CHROOT, 'nbfc-linux'),
]

selected_builds = builds

if OPTS.project:
    selected_builds = filter(lambda rule: rule.project in OPTS.project, selected_builds)

if OPTS.os:
    selected_builds = filter(lambda rule: rule.operating_system in OPTS.os, selected_builds)

for rule in selected_builds:
    if OPTS.dry:
        print('Building:', rule.operating_system, rule.package_glob, rule.package_prefix, rule.chroot, rule.project)
        continue

    build(rule.operating_system, rule.package_glob, rule.package_prefix, rule.chroot, rule.project)
