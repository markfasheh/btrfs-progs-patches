SUBDIRS = man

AM_CFLAGS = -Wall -D_FILE_OFFSET_BITS=64 -D_FORTIFY_SOURCE=2 \
	    -DBTRFS_FLAT_INCLUDES

version.h : version.sh
	sh $(top_srcdir)/version.sh

noinst_LTLIBRARIES = libbtrfs_static.la
lib_LTLIBRARIES = libbtrfs.la
libbtrfs_la_SOURCES = send-stream.c send-utils.c rbtree.c btrfs-list.c crc32c.c
libbtrfs_la_LDFLAGS = -version-info 0:1:0
libbtrfs_la_LIBADD = -luuid
libbtrfs_static_la_SOURCES = $(libbtrfs_la_SOURCES)

noinst_LTLIBRARIES += libbtrfscore.la
libbtrfscore_la_SOURCES = ctree.c disk-io.c radix-tree.c extent-tree.c \
			  print-tree.c root-tree.c dir-item.c file-item.c \
			  inode-item.c inode-map.c extent-cache.c extent_io.c \
			  volumes.c utils.c btrfslabel.c repair.c qgroup.c

CMDS = cmds-subvolume.c cmds-filesystem.c cmds-device.c cmds-scrub.c \
       cmds-inspect.c cmds-balance.c cmds-send.c cmds-receive.c \
       cmds-quota.c cmds-qgroup.c

sbin_PROGRAMS = mkfs.btrfs btrfs-debug-tree btrfsck btrfs btrfs-image \
		btrfs-zero-log btrfs-find-root btrfs-restore btrfstune \
		btrfs-select-super btrfs-convert
bin_PROGRAMS = btrfsctl btrfs-show btrfs-vol btrfs-map-logical
noinst_PROGRAMS = send-test

LDADD = libbtrfscore.la libbtrfs_static.la -luuid -lm

libbtrfsdir = $(includedir)/btrfs
libbtrfs_HEADERS = send-stream.h send-utils.h send.h rbtree.h btrfs-list.h \
		  crc32c.h list.h kerncompat.h radix-tree.h extent-cache.h \
		  extent_io.h ioctl.h ctree.h

btrfs_SOURCES = btrfs.c help.c common.c $(CMDS)
btrfs_LDADD = -lpthread $(LDADD)
btrfs_debug_tree_SOURCES = debug-tree.c

btrfs_convert_SOURCES = convert.c
btrfs_convert_LDADD = -lext2fs -lcom_err $(LDADD)

btrfs_restore_SOURCES = restore.c
btrfs_restore_LDADD = -lz $(LDADD)

btrfs_find_root_SOURCES = find-root.c

btrfs_image_LDADD = -lpthread -lz $(LDADD)

send_test_LDADD = -lpthread $(LDADD)

