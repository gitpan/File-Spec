#!/usr/bin/perl

print "1..3\n";

use File::Spec;

if (File::Spec->catfile('a','b','c') eq 'a/b/c') {
	print "ok 1\n";
} else {
	print "not ok 1\n";
}

use File::Spec::OS2;

if (File::Spec::OS2->catfile('a','b','c') eq 'a/b/c') {
	print "ok 2\n";
} else {
	print "not ok 2\n";
}

use File::Spec::Win32;

if (File::Spec::Win32->catfile('a','b','c') eq 'a\b\c') {
	print "ok 3\n";
} else {
	print "not ok 3\n";
}
