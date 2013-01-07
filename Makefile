CC = gcc
AM_CFLAGS = -Wall -D_FILE_OFFSET_BITS=64 -D_FORTIFY_SOURCE=2 -DBTRFS_FLAT_INCLUDES -fPIC
CFLAGS = -g -O1
objects = ctree.o disk-io.o radix-tree.o extent-tree.o print-tree.o \
	  root-tree.o dir-item.o file-item.o inode-item.o inode-map.o \
	  extent-cache.o extent_io.o volumes.o utils.o btrfslabel.o repair.o \
	  qgroup.o
cmds_objects = cmds-subvolume.o cmds-filesystem.o cmds-device.o cmds-scrub.o \
	       cmds-inspect.o cmds-balance.o cmds-send.o cmds-receive.o \
	       cmds-quota.o cmds-qgroup.o
libbtrfs_objects = send-stream.o send-utils.o rbtree.o btrfs-list.o crc32c.o
libbtrfs_headers = send-stream.h send-utils.h send.h rbtree.h btrfs-list.h \
	       crc32c.h list.h kerncompat.h radix-tree.h extent-cache.h \
	       extent_io.h ioctl.h ctree.h

CHECKFLAGS= -D__linux__ -Dlinux -D__STDC__ -Dunix -D__unix__ -Wbitwise \
	    -Wuninitialized -Wshadow -Wundef
DEPFLAGS = -Wp,-MMD,$(@D)/.$(@F).d,-MT,$@

INSTALL = install
prefix ?= /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib
incdir = $(prefix)/include/btrfs
lib_LIBS=-luuid -lm -L.
LIBS=$(lib_LIBS) -lbtrfs
RESTORE_LIBS=-lz

progs = btrfsctl mkfs.btrfs btrfs-debug-tree btrfs-show btrfs-vol btrfsck \
	btrfs btrfs-map-logical btrfs-image btrfs-zero-log btrfs-convert \
	btrfs-find-root btrfs-restore btrfstune

libs = libbtrfs.so.1.0
lib_links = libbtrfs.so.1 libbtrfs.so
headers = $(libbtrfs_headers)

# make C=1 to enable sparse
ifdef C
	check = sparse $(CHECKFLAGS)
else
	check = ls
endif

.c.o:
	$(check) $<
	$(CC) $(DEPFLAGS) $(AM_CFLAGS) $(CFLAGS) -c $<


all: version $(libs) $(progs) manpages

version:
	bash version.sh

$(libs): $(libbtrfs_objects) $(lib_links) send.h
	$(CC) $(CFLAGS) $(libbtrfs_objects) $(lib_LIBS) -shared -Wl,-soname,libbtrfs.so.1 -o libbtrfs.so.1.0

$(lib_links):
	ln -sf libbtrfs.so.1.0 libbtrfs.so.1
	ln -sf libbtrfs.so.1.0 libbtrfs.so

btrfs: $(objects) btrfs.o help.o common.o $(cmds_objects) $(libs)
	$(CC) $(CFLAGS) -o btrfs btrfs.o help.o common.o $(cmds_objects) \
		$(objects) $(LDFLAGS) $(LIBS) -lpthread

calc-size: $(objects) $(libs) calc-size.o
	$(CC) $(CFLAGS) -o calc-size calc-size.o $(objects) $(LDFLAGS) $(LIBS)

btrfs-find-root: $(objects) $(libs) find-root.o
	$(CC) $(CFLAGS) -o btrfs-find-root find-root.o $(objects) $(LDFLAGS) $(LIBS)

btrfs-restore: $(objects) $(libs) restore.o
	$(CC) $(CFLAGS) -o btrfs-restore restore.o $(objects) $(LDFLAGS) $(LIBS) $(RESTORE_LIBS)

btrfsctl: $(objects) $(libs) btrfsctl.o
	$(CC) $(CFLAGS) -o btrfsctl btrfsctl.o $(objects) $(LDFLAGS) $(LIBS)

btrfs-vol: $(objects) $(libs) btrfs-vol.o
	$(CC) $(CFLAGS) -o btrfs-vol btrfs-vol.o $(objects) $(LDFLAGS) $(LIBS)

btrfs-show: $(objects) $(libs) btrfs-show.o
	$(CC) $(CFLAGS) -o btrfs-show btrfs-show.o $(objects) $(LDFLAGS) $(LIBS)

btrfsck: $(objects) $(libs) btrfsck.o
	$(CC) $(CFLAGS) -o btrfsck btrfsck.o $(objects) $(LDFLAGS) $(LIBS)

mkfs.btrfs: $(objects) $(libs) mkfs.o
	$(CC) $(CFLAGS) -o mkfs.btrfs $(objects) mkfs.o $(LDFLAGS) $(LIBS)

btrfs-debug-tree: $(objects) $(libs) debug-tree.o
	$(CC) $(CFLAGS) -o btrfs-debug-tree $(objects) debug-tree.o $(LDFLAGS) $(LIBS)

btrfs-zero-log: $(objects) $(libs) btrfs-zero-log.o
	$(CC) $(CFLAGS) -o btrfs-zero-log $(objects) btrfs-zero-log.o $(LDFLAGS) $(LIBS)

btrfs-select-super: $(objects) $(libs) btrfs-select-super.o
	$(CC) $(CFLAGS) -o btrfs-select-super $(objects) btrfs-select-super.o $(LDFLAGS) $(LIBS)

btrfstune: $(objects) $(libs) btrfstune.o
	$(CC) $(CFLAGS) -o btrfstune $(objects) btrfstune.o $(LDFLAGS) $(LIBS)

btrfs-map-logical: $(objects) $(libs) btrfs-map-logical.o
	$(CC) $(CFLAGS) -o btrfs-map-logical $(objects) btrfs-map-logical.o $(LDFLAGS) $(LIBS)

btrfs-corrupt-block: $(objects) $(libs) btrfs-corrupt-block.o
	$(CC) $(CFLAGS) -o btrfs-corrupt-block $(objects) btrfs-corrupt-block.o $(LDFLAGS) $(LIBS)

btrfs-image: $(objects) $(libs) btrfs-image.o
	$(CC) $(CFLAGS) -o btrfs-image $(objects) btrfs-image.o -lpthread -lz $(LDFLAGS) $(LIBS)

dir-test: $(objects) $(libs) dir-test.o
	$(CC) $(CFLAGS) -o dir-test $(objects) dir-test.o $(LDFLAGS) $(LIBS)

quick-test: $(objects) $(libs) quick-test.o
	$(CC) $(CFLAGS) -o quick-test $(objects) quick-test.o $(LDFLAGS) $(LIBS)

btrfs-convert: $(objects) $(libs) convert.o
	$(CC) $(CFLAGS) -o btrfs-convert $(objects) convert.o -lext2fs -lcom_err $(LDFLAGS) $(LIBS)

ioctl-test: $(objects) $(libs) ioctl-test.o
	$(CC) $(CFLAGS) -o ioctl-test $(objects) ioctl-test.o $(LDFLAGS) $(LIBS)

send-test: $(objects) send-test.o
	$(CC) $(CFLAGS) -o send-test send-test.o $(LDFLAGS) $(LIBS) -lpthread

manpages:
	cd man; $(MAKE)

install-man:
	cd man; $(MAKE) install

clean :
	rm -f $(progs) $(libs) cscope.out *.o .*.d btrfs-convert btrfs-image \
	      btrfs-select-super btrfs-zero-log btrfstune dir-test ioctl-test \
	      quick-test send-test version.h
	cd man; $(MAKE) clean

install: $(libs) $(progs) install-man
	$(INSTALL) -m755 -d $(DESTDIR)$(bindir)
	$(INSTALL) $(progs) $(DESTDIR)$(bindir)
	$(INSTALL) -m755 -d $(DESTDIR)$(libdir)
	$(INSTALL) $(libs) $(DESTDIR)$(libdir)
	cp -a $(lib_links) $(DESTDIR)$(libdir)
	$(INSTALL) -m755 -d $(DESTDIR)$(incdir)
	$(INSTALL) $(headers) $(DESTDIR)$(incdir)

-include .*.d
