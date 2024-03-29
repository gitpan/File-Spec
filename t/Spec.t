#!/usr/bin/perl -w

use Test;

# Grab all of the plain routines from File::Spec
use File::Spec @File::Spec::EXPORT_OK ;

require File::Spec::Unix ;
require File::Spec::Win32 ;
require Cwd;

eval {
   require VMS::Filespec ;
} ;

my $skip_exception = "Install VMS::Filespec (from vms/ext)" ;

if ( $@ ) {
   # Not pretty, but it allows testing of things not implemented soley
   # on VMS.  It might be better to change File::Spec::VMS to do this,
   # making it more usable when running on (say) Unix but working with
   # VMS paths.
   eval qq-
      sub File::Spec::VMS::vmsify  { die "$skip_exception" }
      sub File::Spec::VMS::unixify { die "$skip_exception" }
      sub File::Spec::VMS::vmspath { die "$skip_exception" }
   - ;
   $INC{"VMS/Filespec.pm"} = 1 ;
}
require File::Spec::VMS ;

require File::Spec::OS2 ;
require File::Spec::Mac ;
require File::Spec::Epoc ;
require File::Spec::Cygwin ;

# $root is only needed by Mac OS tests; these particular
# tests are skipped on other OSs
my $root = '';
if ($^O eq 'MacOS') {
	$root = File::Spec::Mac->rootdir();
}

# Each element in this array is a single test. Storing them this way makes
# maintenance easy, and should be OK since perl should be pretty functional
# before these tests are run.

@tests = (
# [ Function          ,            Expected          ,         Platform ]

[ "Unix->case_tolerant()",         '0'  ],

[ "Unix->catfile('a','b','c')",         'a/b/c'  ],
[ "Unix->catfile('a','b','./c')",       'a/b/c'  ],
[ "Unix->catfile('./a','b','c')",       'a/b/c'  ],
[ "Unix->catfile('c')",                 'c' ],
[ "Unix->catfile('./c')",               'c' ],

[ "Unix->splitpath('file')",            ',,file'            ],
[ "Unix->splitpath('/d1/d2/d3/')",      ',/d1/d2/d3/,'      ],
[ "Unix->splitpath('d1/d2/d3/')",       ',d1/d2/d3/,'       ],
[ "Unix->splitpath('/d1/d2/d3/.')",     ',/d1/d2/d3/.,'     ],
[ "Unix->splitpath('/d1/d2/d3/..')",    ',/d1/d2/d3/..,'    ],
[ "Unix->splitpath('/d1/d2/d3/.file')", ',/d1/d2/d3/,.file' ],
[ "Unix->splitpath('d1/d2/d3/file')",   ',d1/d2/d3/,file'   ],
[ "Unix->splitpath('/../../d1/')",      ',/../../d1/,'      ],
[ "Unix->splitpath('/././d1/')",        ',/././d1/,'        ],

[ "Unix->catpath('','','file')",            'file'            ],
[ "Unix->catpath('','/d1/d2/d3/','')",      '/d1/d2/d3/'      ],
[ "Unix->catpath('','d1/d2/d3/','')",       'd1/d2/d3/'       ],
[ "Unix->catpath('','/d1/d2/d3/.','')",     '/d1/d2/d3/.'     ],
[ "Unix->catpath('','/d1/d2/d3/..','')",    '/d1/d2/d3/..'    ],
[ "Unix->catpath('','/d1/d2/d3/','.file')", '/d1/d2/d3/.file' ],
[ "Unix->catpath('','d1/d2/d3/','file')",   'd1/d2/d3/file'   ],
[ "Unix->catpath('','/../../d1/','')",      '/../../d1/'      ],
[ "Unix->catpath('','/././d1/','')",        '/././d1/'        ],
[ "Unix->catpath('d1','d2/d3/','')",        'd2/d3/'          ],
[ "Unix->catpath('d1','d2','d3/')",         'd2/d3/'          ],

[ "Unix->splitdir('')",           ''           ],
[ "Unix->splitdir('/d1/d2/d3/')", ',d1,d2,d3,' ],
[ "Unix->splitdir('d1/d2/d3/')",  'd1,d2,d3,'  ],
[ "Unix->splitdir('/d1/d2/d3')",  ',d1,d2,d3'  ],
[ "Unix->splitdir('d1/d2/d3')",   'd1,d2,d3'   ],

[ "Unix->catdir()",                     ''          ],
[ "Unix->catdir('/')",                  '/'         ],
[ "Unix->catdir('','d1','d2','d3','')", '/d1/d2/d3' ],
[ "Unix->catdir('d1','d2','d3','')",    'd1/d2/d3'  ],
[ "Unix->catdir('','d1','d2','d3')",    '/d1/d2/d3' ],
[ "Unix->catdir('d1','d2','d3')",       'd1/d2/d3'  ],

[ "Unix->canonpath('')",                                      ''          ],
[ "Unix->canonpath('///../../..//./././a//b/.././c/././')",   '/a/b/../c' ],
[ "Unix->canonpath('/.')",                                    '/'         ],
[ "Unix->canonpath('/./')",                                   '/'         ],
[ "Unix->canonpath('/a/./')",                                 '/a'        ],
[ "Unix->canonpath('/a/.')",                                  '/a'        ],

[  "Unix->abs2rel('/t1/t2/t3','/t1/t2/t3')",          ''                   ],
[  "Unix->abs2rel('/t1/t2/t4','/t1/t2/t3')",          '../t4'              ],
[  "Unix->abs2rel('/t1/t2','/t1/t2/t3')",             '..'                 ],
[  "Unix->abs2rel('/t1/t2/t3/t4','/t1/t2/t3')",       't4'                 ],
[  "Unix->abs2rel('/t4/t5/t6','/t1/t2/t3')",          '../../../t4/t5/t6'  ],
#[ "Unix->abs2rel('../t4','/t1/t2/t3')",              '../t4'              ],
[  "Unix->abs2rel('/','/t1/t2/t3')",                  '../../..'           ],
[  "Unix->abs2rel('///','/t1/t2/t3')",                '../../..'           ],
[  "Unix->abs2rel('/.','/t1/t2/t3')",                 '../../..'           ],
[  "Unix->abs2rel('/./','/t1/t2/t3')",                '../../..'           ],
#[ "Unix->abs2rel('../t4','/t1/t2/t3')",              '../t4'              ],

[ "Unix->rel2abs('t4','/t1/t2/t3')",             '/t1/t2/t3/t4'    ],
[ "Unix->rel2abs('t4/t5','/t1/t2/t3')",          '/t1/t2/t3/t4/t5' ],
[ "Unix->rel2abs('.','/t1/t2/t3')",              '/t1/t2/t3'       ],
[ "Unix->rel2abs('..','/t1/t2/t3')",             '/t1/t2/t3/..'    ],
[ "Unix->rel2abs('../t4','/t1/t2/t3')",          '/t1/t2/t3/../t4' ],
[ "Unix->rel2abs('/t1','/t1/t2/t3')",            '/t1'             ],

[ "Win32->case_tolerant()",         '1'  ],

[ "Win32->splitpath('file')",                            ',,file'                            ],
[ "Win32->splitpath('\\d1/d2\\d3/')",                    ',\\d1/d2\\d3/,'                    ],
[ "Win32->splitpath('d1/d2\\d3/')",                      ',d1/d2\\d3/,'                      ],
[ "Win32->splitpath('\\d1/d2\\d3/.')",                   ',\\d1/d2\\d3/.,'                   ],
[ "Win32->splitpath('\\d1/d2\\d3/..')",                  ',\\d1/d2\\d3/..,'                  ],
[ "Win32->splitpath('\\d1/d2\\d3/.file')",               ',\\d1/d2\\d3/,.file'               ],
[ "Win32->splitpath('\\d1/d2\\d3/file')",                ',\\d1/d2\\d3/,file'                ],
[ "Win32->splitpath('d1/d2\\d3/file')",                  ',d1/d2\\d3/,file'                  ],
[ "Win32->splitpath('C:\\d1/d2\\d3/')",                  'C:,\\d1/d2\\d3/,'                  ],
[ "Win32->splitpath('C:d1/d2\\d3/')",                    'C:,d1/d2\\d3/,'                    ],
[ "Win32->splitpath('C:\\d1/d2\\d3/file')",              'C:,\\d1/d2\\d3/,file'              ],
[ "Win32->splitpath('C:d1/d2\\d3/file')",                'C:,d1/d2\\d3/,file'                ],
[ "Win32->splitpath('C:\\../d2\\d3/file')",              'C:,\\../d2\\d3/,file'              ],
[ "Win32->splitpath('C:../d2\\d3/file')",                'C:,../d2\\d3/,file'                ],
[ "Win32->splitpath('\\../..\\d1/')",                    ',\\../..\\d1/,'                    ],
[ "Win32->splitpath('\\./.\\d1/')",                      ',\\./.\\d1/,'                      ],
[ "Win32->splitpath('\\\\node\\share\\d1/d2\\d3/')",     '\\\\node\\share,\\d1/d2\\d3/,'     ],
[ "Win32->splitpath('\\\\node\\share\\d1/d2\\d3/file')", '\\\\node\\share,\\d1/d2\\d3/,file' ],
[ "Win32->splitpath('\\\\node\\share\\d1/d2\\file')",    '\\\\node\\share,\\d1/d2\\,file'    ],
[ "Win32->splitpath('file',1)",                          ',file,'                            ],
[ "Win32->splitpath('\\d1/d2\\d3/',1)",                  ',\\d1/d2\\d3/,'                    ],
[ "Win32->splitpath('d1/d2\\d3/',1)",                    ',d1/d2\\d3/,'                      ],
[ "Win32->splitpath('\\\\node\\share\\d1/d2\\d3/',1)",   '\\\\node\\share,\\d1/d2\\d3/,'     ],

[ "Win32->catpath('','','file')",                            'file'                            ],
[ "Win32->catpath('','\\d1/d2\\d3/','')",                    '\\d1/d2\\d3/'                    ],
[ "Win32->catpath('','d1/d2\\d3/','')",                      'd1/d2\\d3/'                      ],
[ "Win32->catpath('','\\d1/d2\\d3/.','')",                   '\\d1/d2\\d3/.'                   ],
[ "Win32->catpath('','\\d1/d2\\d3/..','')",                  '\\d1/d2\\d3/..'                  ],
[ "Win32->catpath('','\\d1/d2\\d3/','.file')",               '\\d1/d2\\d3/.file'               ],
[ "Win32->catpath('','\\d1/d2\\d3/','file')",                '\\d1/d2\\d3/file'                ],
[ "Win32->catpath('','d1/d2\\d3/','file')",                  'd1/d2\\d3/file'                  ],
[ "Win32->catpath('C:','\\d1/d2\\d3/','')",                  'C:\\d1/d2\\d3/'                  ],
[ "Win32->catpath('C:','d1/d2\\d3/','')",                    'C:d1/d2\\d3/'                    ],
[ "Win32->catpath('C:','\\d1/d2\\d3/','file')",              'C:\\d1/d2\\d3/file'              ],
[ "Win32->catpath('C:','d1/d2\\d3/','file')",                'C:d1/d2\\d3/file'                ],
[ "Win32->catpath('C:','\\../d2\\d3/','file')",              'C:\\../d2\\d3/file'              ],
[ "Win32->catpath('C:','../d2\\d3/','file')",                'C:../d2\\d3/file'                ],
[ "Win32->catpath('','\\../..\\d1/','')",                    '\\../..\\d1/'                    ],
[ "Win32->catpath('','\\./.\\d1/','')",                      '\\./.\\d1/'                      ],
[ "Win32->catpath('\\\\node\\share','\\d1/d2\\d3/','')",     '\\\\node\\share\\d1/d2\\d3/'     ],
[ "Win32->catpath('\\\\node\\share','\\d1/d2\\d3/','file')", '\\\\node\\share\\d1/d2\\d3/file' ],
[ "Win32->catpath('\\\\node\\share','\\d1/d2\\','file')",    '\\\\node\\share\\d1/d2\\file'    ],

[ "Win32->splitdir('')",             ''           ],
[ "Win32->splitdir('\\d1/d2\\d3/')", ',d1,d2,d3,' ],
[ "Win32->splitdir('d1/d2\\d3/')",   'd1,d2,d3,'  ],
[ "Win32->splitdir('\\d1/d2\\d3')",  ',d1,d2,d3'  ],
[ "Win32->splitdir('d1/d2\\d3')",    'd1,d2,d3'   ],

[ "Win32->catdir()",                        ''                   ],
[ "Win32->catdir('')",                      '\\'                 ],
[ "Win32->catdir('/')",                     '\\'                 ],
[ "Win32->catdir('/', '../')",              '\\'                 ],
[ "Win32->catdir('/', '..\\')",             '\\'                 ],
[ "Win32->catdir('\\', '../')",             '\\'                 ],
[ "Win32->catdir('\\', '..\\')",            '\\'                 ],
[ "Win32->catdir('//d1','d2')",             '\\\\d1\\d2'         ],
[ "Win32->catdir('\\d1\\','d2')",           '\\d1\\d2'         ],
[ "Win32->catdir('\\d1','d2')",             '\\d1\\d2'         ],
[ "Win32->catdir('\\d1','\\d2')",           '\\d1\\d2'         ],
[ "Win32->catdir('\\d1','\\d2\\')",         '\\d1\\d2'         ],
[ "Win32->catdir('','/d1','d2')",           '\\\\d1\\d2'         ],
[ "Win32->catdir('','','/d1','d2')",        '\\\\\\d1\\d2'       ],
[ "Win32->catdir('','//d1','d2')",          '\\\\\\d1\\d2'       ],
[ "Win32->catdir('','','//d1','d2')",       '\\\\\\\\d1\\d2'     ],
[ "Win32->catdir('','d1','','d2','')",      '\\d1\\d2'           ],
[ "Win32->catdir('','d1','d2','d3','')",    '\\d1\\d2\\d3'       ],
[ "Win32->catdir('d1','d2','d3','')",       'd1\\d2\\d3'         ],
[ "Win32->catdir('','d1','d2','d3')",       '\\d1\\d2\\d3'       ],
[ "Win32->catdir('d1','d2','d3')",          'd1\\d2\\d3'         ],
[ "Win32->catdir('A:/d1','d2','d3')",       'A:\\d1\\d2\\d3'     ],
[ "Win32->catdir('A:/d1','d2','d3','')",    'A:\\d1\\d2\\d3'     ],
#[ "Win32->catdir('A:/d1','B:/d2','d3','')", 'A:\\d1\\d2\\d3'     ],
[ "Win32->catdir('A:/d1','B:/d2','d3','')", 'A:\\d1\\B:\\d2\\d3' ],
[ "Win32->catdir('A:/')",                   'A:\\'               ],
[ "Win32->catdir('\\', 'foo')",             '\\foo'              ],

[ "Win32->catfile('a','b','c')",        'a\\b\\c' ],
[ "Win32->catfile('a','b','.\\c')",      'a\\b\\c'  ],
[ "Win32->catfile('.\\a','b','c')",      'a\\b\\c'  ],
[ "Win32->catfile('c')",                'c' ],
[ "Win32->catfile('.\\c')",              'c' ],


[ "Win32->canonpath('')",               ''                    ],
[ "Win32->canonpath('a:')",             'A:'                  ],
[ "Win32->canonpath('A:f')",            'A:f'                 ],
[ "Win32->canonpath('A:/')",            'A:\\'                ],
[ "Win32->canonpath('//a\\b//c')",      '\\\\a\\b\\c'         ],
[ "Win32->canonpath('/a/..../c')",      '\\a\\....\\c'        ],
[ "Win32->canonpath('//a/b\\c')",       '\\\\a\\b\\c'         ],
[ "Win32->canonpath('////')",           '\\\\\\'              ],
[ "Win32->canonpath('//')",             '\\'                  ],
[ "Win32->canonpath('/.')",             '\\.'                 ],
[ "Win32->canonpath('//a/b/../../c')",  '\\\\a\\b\\c'         ],
[ "Win32->canonpath('//a/b/c/../d')",   '\\\\a\\b\\d'         ],
[ "Win32->canonpath('//a/b/c/../../d')",'\\\\a\\b\\d'         ],
[ "Win32->canonpath('//a/b/c/.../d')",  '\\\\a\\b\\d'         ],
[ "Win32->canonpath('/a/b/c/../../d')", '\\a\\d'              ],
[ "Win32->canonpath('/a/b/c/.../d')",   '\\a\\d'              ],
[ "Win32->canonpath('\\../temp\\')",    '\\temp'              ],
[ "Win32->canonpath('\\../')",          '\\'                  ],
[ "Win32->canonpath('\\..\\')",         '\\'                  ],
[ "Win32->canonpath('/../')",           '\\'                  ],
[ "Win32->canonpath('/..\\')",          '\\'                  ],
[ "Win32->can('_cwd')",                 '/CODE/'              ],

# FakeWin32 subclass (see below) just sets CWD to C:\one\two and getdcwd('D') to D:\alpha\beta

[ "FakeWin32->abs2rel('/t1/t2/t3','/t1/t2/t3')",     ''                       ],
[ "FakeWin32->abs2rel('/t1/t2/t4','/t1/t2/t3')",     '..\\t4'                 ],
[ "FakeWin32->abs2rel('/t1/t2','/t1/t2/t3')",        '..'                     ],
[ "FakeWin32->abs2rel('/t1/t2/t3/t4','/t1/t2/t3')",  't4'                     ],
[ "FakeWin32->abs2rel('/t4/t5/t6','/t1/t2/t3')",     '..\\..\\..\\t4\\t5\\t6' ],
[ "FakeWin32->abs2rel('../t4','/t1/t2/t3')",         '..\\..\\..\\one\\t4'    ],  # Uses _cwd()
[ "FakeWin32->abs2rel('/','/t1/t2/t3')",             '..\\..\\..'             ],
[ "FakeWin32->abs2rel('///','/t1/t2/t3')",           '..\\..\\..'             ],
[ "FakeWin32->abs2rel('/.','/t1/t2/t3')",            '..\\..\\..'             ],
[ "FakeWin32->abs2rel('/./','/t1/t2/t3')",           '..\\..\\..'             ],
[ "FakeWin32->abs2rel('\\\\a/t1/t2/t4','/t2/t3')",   '\\\\a\\t1\\t2\\t4'      ],
[ "FakeWin32->abs2rel('//a/t1/t2/t4','/t2/t3')",     '\\\\a\\t1\\t2\\t4'      ],
[ "FakeWin32->abs2rel('A:/t1/t2/t3','A:/t1/t2/t3')",     ''                   ],
[ "FakeWin32->abs2rel('A:/t1/t2/t3/t4','A:/t1/t2/t3')",  't4'                 ],
[ "FakeWin32->abs2rel('A:/t1/t2/t3','A:/t1/t2/t3/t4')",  '..'                 ],
[ "FakeWin32->abs2rel('A:/t1/t2/t3','B:/t1/t2/t3')",     'A:\\t1\\t2\\t3'     ],
[ "FakeWin32->abs2rel('A:/t1/t2/t3/t4','B:/t1/t2/t3')",  'A:\\t1\\t2\\t3\\t4' ],
[ "FakeWin32->abs2rel('E:/foo/bar/baz')",            'E:\\foo\\bar\\baz'      ],
[ "FakeWin32->abs2rel('C:/one/two/three')",          'three'                  ],

[ "FakeWin32->rel2abs('temp','C:/')",                       'C:\\temp'                        ],
[ "FakeWin32->rel2abs('temp','C:/a')",                      'C:\\a\\temp'                     ],
[ "FakeWin32->rel2abs('temp','C:/a/')",                     'C:\\a\\temp'                     ],
[ "FakeWin32->rel2abs('../','C:/')",                        'C:\\'                            ],
[ "FakeWin32->rel2abs('../','C:/a')",                       'C:\\'                            ],
[ "FakeWin32->rel2abs('temp','//prague_main/work/')",       '\\\\prague_main\\work\\temp'     ],
[ "FakeWin32->rel2abs('../temp','//prague_main/work/')",    '\\\\prague_main\\work\\temp'     ],
[ "FakeWin32->rel2abs('temp','//prague_main/work')",        '\\\\prague_main\\work\\temp'     ],
[ "FakeWin32->rel2abs('../','//prague_main/work')",         '\\\\prague_main\\work'           ],

[ "VMS->case_tolerant()",         '1'  ],

[ "VMS->catfile('a','b','c')",         '[.a.b]c'  ],
[ "VMS->catfile('a','b','[]c')",       '[.a.b]c'  ],
[ "VMS->catfile('[.a]','b','c')",       '[.a.b]c'  ],
[ "VMS->catfile('c')",                 'c' ],
[ "VMS->catfile('[]c')",               'c' ],

[ "VMS->splitpath('file')",                                       ',,file'                                   ],
[ "VMS->splitpath('[d1.d2.d3]')",                                 ',[d1.d2.d3],'                               ],
[ "VMS->splitpath('[.d1.d2.d3]')",                                ',[.d1.d2.d3],'                              ],
[ "VMS->splitpath('[d1.d2.d3]file')",                             ',[d1.d2.d3],file'                           ],
[ "VMS->splitpath('d1/d2/d3/file')",                              ',[.d1.d2.d3],file'                          ],
[ "VMS->splitpath('/d1/d2/d3/file')",                             'd1:,[d2.d3],file'                         ],
[ "VMS->splitpath('[.d1.d2.d3]file')",                            ',[.d1.d2.d3],file'                          ],
[ "VMS->splitpath('node::volume:[d1.d2.d3]')",                    'node::volume:,[d1.d2.d3],'                  ],
[ "VMS->splitpath('node::volume:[d1.d2.d3]file')",                'node::volume:,[d1.d2.d3],file'              ],
[ "VMS->splitpath('node\"access_spec\"::volume:[d1.d2.d3]')",     'node"access_spec"::volume:,[d1.d2.d3],'     ],
[ "VMS->splitpath('node\"access_spec\"::volume:[d1.d2.d3]file')", 'node"access_spec"::volume:,[d1.d2.d3],file' ],

[ "VMS->catpath('','','file')",                                       'file'                                     ],
[ "VMS->catpath('','[d1.d2.d3]','')",                                 '[d1.d2.d3]'                               ],
[ "VMS->catpath('','[.d1.d2.d3]','')",                                '[.d1.d2.d3]'                              ],
[ "VMS->catpath('','[d1.d2.d3]','file')",                             '[d1.d2.d3]file'                           ],
[ "VMS->catpath('','[.d1.d2.d3]','file')",                            '[.d1.d2.d3]file'                          ],
[ "VMS->catpath('','d1/d2/d3','file')",                               '[.d1.d2.d3]file'                            ],
[ "VMS->catpath('v','d1/d2/d3','file')",                              'v:[.d1.d2.d3]file'                            ],
[ "VMS->catpath('v','w:[d1.d2.d3]','file')",                          'v:[d1.d2.d3]file'                         ],
[ "VMS->catpath('node::volume:','[d1.d2.d3]','')",                    'node::volume:[d1.d2.d3]'                  ],
[ "VMS->catpath('node::volume:','[d1.d2.d3]','file')",                'node::volume:[d1.d2.d3]file'              ],
[ "VMS->catpath('node\"access_spec\"::volume:','[d1.d2.d3]','')",     'node"access_spec"::volume:[d1.d2.d3]'     ],
[ "VMS->catpath('node\"access_spec\"::volume:','[d1.d2.d3]','file')", 'node"access_spec"::volume:[d1.d2.d3]file' ],

[ "VMS->canonpath('')",                                    ''                        ],
[ "VMS->canonpath('volume:[d1]file')",                     'volume:[d1]file'         ],
[ "VMS->canonpath('volume:[d1.-.d2.][d3.d4.-]')",              'volume:[d2.d3]'          ],
[ "VMS->canonpath('volume:[000000.d1]d2.dir;1')",                 'volume:[d1]d2.dir;1'   ],
[ "VMS->canonpath('volume:[d1.d2.d3]file.txt')", 	'volume:[d1.d2.d3]file.txt' ],
[ "VMS->canonpath('[d1.d2.d3]file.txt')", 		'[d1.d2.d3]file.txt' ],
[ "VMS->canonpath('volume:[-.d1.d2.d3]file.txt')", 	'volume:[-.d1.d2.d3]file.txt' ],
[ "VMS->canonpath('[-.d1.d2.d3]file.txt')", 		'[-.d1.d2.d3]file.txt' ],
[ "VMS->canonpath('volume:[--.d1.d2.d3]file.txt')", 	'volume:[--.d1.d2.d3]file.txt' ],
[ "VMS->canonpath('[--.d1.d2.d3]file.txt')", 		'[--.d1.d2.d3]file.txt' ],
[ "VMS->canonpath('volume:[d1.-.d2.d3]file.txt')", 	'volume:[d2.d3]file.txt' ],
[ "VMS->canonpath('[d1.-.d2.d3]file.txt')", 		'[d2.d3]file.txt' ],
[ "VMS->canonpath('volume:[d1.--.d2.d3]file.txt')", 	'volume:[-.d2.d3]file.txt' ],
[ "VMS->canonpath('[d1.--.d2.d3]file.txt')", 		'[-.d2.d3]file.txt' ],
[ "VMS->canonpath('volume:[d1.d2.-.d3]file.txt')", 	'volume:[d1.d3]file.txt' ],
[ "VMS->canonpath('[d1.d2.-.d3]file.txt')", 		'[d1.d3]file.txt' ],
[ "VMS->canonpath('volume:[d1.d2.--.d3]file.txt')", 	'volume:[d3]file.txt' ],
[ "VMS->canonpath('[d1.d2.--.d3]file.txt')", 		'[d3]file.txt' ],
[ "VMS->canonpath('volume:[d1.d2.d3.-]file.txt')", 	'volume:[d1.d2]file.txt' ],
[ "VMS->canonpath('[d1.d2.d3.-]file.txt')", 		'[d1.d2]file.txt' ],
[ "VMS->canonpath('volume:[d1.d2.d3.--]file.txt')", 	'volume:[d1]file.txt' ],
[ "VMS->canonpath('[d1.d2.d3.--]file.txt')", 		'[d1]file.txt' ],
[ "VMS->canonpath('volume:[d1.000000.][000000.][d3.--]file.txt')", 	'volume:[d1]file.txt' ],
[ "VMS->canonpath('[d1.000000.][000000.][d3.--]file.txt')", 		'[d1]file.txt' ],
[ "VMS->canonpath('volume:[d1.000000.][000000.][d2.000000]file.txt')",	'volume:[d1.000000.d2.000000]file.txt' ],
[ "VMS->canonpath('[d1.000000.][000000.][d2.000000]file.txt')", 	'[d1.000000.d2.000000]file.txt' ],
[ "VMS->canonpath('volume:[d1.000000.][000000.][d3.--.000000]file.txt')",'volume:[d1.000000]file.txt' ],
[ "VMS->canonpath('[d1.000000.][000000.][d3.--.000000]file.txt')", 	'[d1.000000]file.txt' ],
[ "VMS->canonpath('volume:[d1.000000.][000000.][-.-.000000]file.txt')",	'volume:[000000]file.txt' ],
[ "VMS->canonpath('[d1.000000.][000000.][--.-.000000]file.txt')", 	'[-.000000]file.txt' ],

[ "VMS->splitdir('')",            ''          ],
[ "VMS->splitdir('[]')",          ''          ],
[ "VMS->splitdir('d1.d2.d3')",    'd1,d2,d3'  ],
[ "VMS->splitdir('[d1.d2.d3]')",  'd1,d2,d3'  ],
[ "VMS->splitdir('.d1.d2.d3')",   ',d1,d2,d3' ],
[ "VMS->splitdir('[.d1.d2.d3]')", ',d1,d2,d3' ],
[ "VMS->splitdir('.-.d2.d3')",    ',-,d2,d3'  ],
[ "VMS->splitdir('[.-.d2.d3]')",  ',-,d2,d3'  ],
[ "VMS->splitdir('[d1.d2]')",  		'd1,d2'  ],
[ "VMS->splitdir('[d1-.--d2]')",  	'd1-,--d2'  ],
[ "VMS->splitdir('[d1---.-.d2]')",  	'd1---,-,d2'  ],
[ "VMS->splitdir('[d1.---.d2]')",  	'd1,-,-,-,d2'  ],
[ "VMS->splitdir('[d1---d2]')",  	'd1---d2'  ],
[ "VMS->splitdir('[d1.][000000.d2]')",  'd1,d2'  ],

[ "VMS->catdir('')",                                                      ''                 ],
[ "VMS->catdir('d1','d2','d3')",                                          '[.d1.d2.d3]'         ],
[ "VMS->catdir('d1','d2/','d3')",                                         '[.d1.d2.d3]'         ],
[ "VMS->catdir('','d1','d2','d3')",                                       '[.d1.d2.d3]'        ],
[ "VMS->catdir('','-','d2','d3')",                                        '[-.d2.d3]'         ],
[ "VMS->catdir('','-','','d3')",                                          '[-.d3]'            ],
[ "VMS->catdir('dir.dir','d2.dir','d3.dir')",                             '[.dir.d2.d3]'        ],
[ "VMS->catdir('[.name]')",                                               '[.name]'            ],
[ "VMS->catdir('[.name]','[.name]')",                                     '[.name.name]'],

[  "VMS->abs2rel('node::volume:[t1.t2.t3]','node::volume:[t1.t2.t3]')", ''                 ],
[  "VMS->abs2rel('node::volume:[t1.t2.t3]','[t1.t2.t3]')", 'node::volume:[t1.t2.t3]'                 ],
[  "VMS->abs2rel('node::volume:[t1.t2.t4]','node::volume:[t1.t2.t3]')", '[-.t4]'           ],
[  "VMS->abs2rel('node::volume:[t1.t2.t4]','[t1.t2.t3]')", 'node::volume:[t1.t2.t4]'           ],
[  "VMS->abs2rel('[t1.t2.t3]','[t1.t2.t3]')",              ''                 ],
[  "VMS->abs2rel('[t1.t2.t3]file','[t1.t2.t3]')",          'file'             ],
[  "VMS->abs2rel('[t1.t2.t3]file','[t1.t2]')",             '[.t3]file'        ],
[  "VMS->abs2rel('v:[t1.t2.t3]file','v:[t1.t2]')",         '[.t3]file'        ],
[  "VMS->abs2rel('[t1.t2.t4]','[t1.t2.t3]')",              '[-.t4]'           ],
[  "VMS->abs2rel('[t1.t2]file','[t1.t2.t3]')",             '[-]file'          ],
[  "VMS->abs2rel('[t1.t2.t3.t4]','[t1.t2.t3]')",           '[.t4]'            ],
[  "VMS->abs2rel('[t4.t5.t6]','[t1.t2.t3]')",              '[---.t4.t5.t6]'   ],
[ "VMS->abs2rel('[000000]','[t1.t2.t3]')",                 '[---]'            ],
[ "VMS->abs2rel('a:[t1.t2.t4]','a:[t1.t2.t3]')",             '[-.t4]'           ],
[ "VMS->abs2rel('a:[t1.t2.t4]','[t1.t2.t3]')",             'a:[t1.t2.t4]'           ],
[ "VMS->abs2rel('[a.-.b.c.-]','[t1.t2.t3]')",              '[---.b]'          ],

[ "VMS->rel2abs('[.t4]','[t1.t2.t3]')",          '[t1.t2.t3.t4]'    ],
[ "VMS->rel2abs('[.t4.t5]','[t1.t2.t3]')",       '[t1.t2.t3.t4.t5]' ],
[ "VMS->rel2abs('[]','[t1.t2.t3]')",             '[t1.t2.t3]'       ],
[ "VMS->rel2abs('[-]','[t1.t2.t3]')",            '[t1.t2]'          ],
[ "VMS->rel2abs('[-.t4]','[t1.t2.t3]')",         '[t1.t2.t4]'       ],
[ "VMS->rel2abs('[t1]','[t1.t2.t3]')",           '[t1]'             ],

[ "OS2->case_tolerant()",         '1'  ],

[ "OS2->catdir('A:/d1','B:/d2','d3','')", 'A:/d1/B:/d2/d3' ],

[ "OS2->catfile('a','b','c')",            'a/b/c'          ],
[ "OS2->catfile('a','b','./c')",          'a/b/c'  ],
[ "OS2->catfile('./a','b','c')",          'a/b/c'  ],
[ "OS2->catfile('c')",                    'c' ],
[ "OS2->catfile('./c')",                  'c' ],

[ "OS2->catdir('/', '../')",              '/'                 ],
[ "OS2->catdir('/', '..\\')",             '/'                 ],
[ "OS2->catdir('\\', '../')",             '/'                 ],
[ "OS2->catdir('\\', '..\\')",            '/'                 ],

[ "Mac->case_tolerant()",         '1'  ],

[ "Mac->catpath('','','')",              ''                ],
[ "Mac->catpath('',':','')",             ':'               ],
[ "Mac->catpath('','::','')",            '::'              ],

[ "Mac->catpath('hd','','')",            'hd:'             ],
[ "Mac->catpath('hd:','','')",           'hd:'             ],
[ "Mac->catpath('hd:',':','')",          'hd:'             ],
[ "Mac->catpath('hd:','::','')",         'hd::'            ],

[ "Mac->catpath('hd','','file')",       'hd:file'          ],
[ "Mac->catpath('hd',':','file')",      'hd:file'          ],
[ "Mac->catpath('hd','::','file')",     'hd::file'         ],
[ "Mac->catpath('hd',':::','file')",    'hd:::file'        ],

[ "Mac->catpath('hd:','',':file')",      'hd:file'         ],
[ "Mac->catpath('hd:',':',':file')",     'hd:file'         ],
[ "Mac->catpath('hd:','::',':file')",    'hd::file'        ],
[ "Mac->catpath('hd:',':::',':file')",   'hd:::file'       ],

[ "Mac->catpath('hd:','d1','file')",     'hd:d1:file'      ],
[ "Mac->catpath('hd:',':d1:',':file')",  'hd:d1:file'      ],
[ "Mac->catpath('hd:','hd:d1','')",      'hd:d1:'          ],

[ "Mac->catpath('','d1','')",            ':d1:'            ],
[ "Mac->catpath('',':d1','')",           ':d1:'            ],
[ "Mac->catpath('',':d1:','')",          ':d1:'            ],

[ "Mac->catpath('','d1','file')",        ':d1:file'        ],
[ "Mac->catpath('',':d1:',':file')",     ':d1:file'        ],

[ "Mac->catpath('','','file')",          'file'            ],
[ "Mac->catpath('','',':file')",         'file'            ], # !
[ "Mac->catpath('',':',':file')",        ':file'           ], # !


[ "Mac->splitpath(':')",              ',:,'               ],
[ "Mac->splitpath('::')",             ',::,'              ],
[ "Mac->splitpath(':::')",            ',:::,'             ],

[ "Mac->splitpath('file')",           ',,file'            ],
[ "Mac->splitpath(':file')",          ',:,file'           ],

[ "Mac->splitpath('d1',1)",           ',:d1:,'            ], # dir, not volume
[ "Mac->splitpath(':d1',1)",          ',:d1:,'            ],
[ "Mac->splitpath(':d1:',1)",         ',:d1:,'            ],
[ "Mac->splitpath(':d1:')",           ',:d1:,'            ],
[ "Mac->splitpath(':d1:d2:d3:')",     ',:d1:d2:d3:,'      ],
[ "Mac->splitpath(':d1:d2:d3:',1)",   ',:d1:d2:d3:,'      ],
[ "Mac->splitpath(':d1:file')",       ',:d1:,file'        ],
[ "Mac->splitpath('::d1:file')",      ',::d1:,file'       ],

[ "Mac->splitpath('hd:', 1)",         'hd:,,'             ],
[ "Mac->splitpath('hd:')",            'hd:,,'             ],
[ "Mac->splitpath('hd:d1:d2:')",      'hd:,:d1:d2:,'      ],
[ "Mac->splitpath('hd:d1:d2',1)",     'hd:,:d1:d2:,'      ],
[ "Mac->splitpath('hd:d1:d2:file')",  'hd:,:d1:d2:,file'  ],
[ "Mac->splitpath('hd:d1:d2::file')", 'hd:,:d1:d2::,file' ],
[ "Mac->splitpath('hd::d1:d2:file')", 'hd:,::d1:d2:,file' ], # invalid path
[ "Mac->splitpath('hd:file')",        'hd:,,file'         ],

[ "Mac->splitdir()",                   ''            ],
[ "Mac->splitdir('')",                 ''            ],
[ "Mac->splitdir(':')",                ':'           ],
[ "Mac->splitdir('::')",               '::'          ],
[ "Mac->splitdir(':::')",              '::,::'       ],
[ "Mac->splitdir(':::d1:d2')",         '::,::,d1,d2' ],

[ "Mac->splitdir(':d1:d2:d3::')",      'd1,d2,d3,::'],
[ "Mac->splitdir(':d1:d2:d3:')",       'd1,d2,d3'   ],
[ "Mac->splitdir(':d1:d2:d3')",        'd1,d2,d3'   ],

# absolute paths in splitdir() work, but you'd better use splitpath()
[ "Mac->splitdir('hd:')",              'hd:'              ],
[ "Mac->splitdir('hd::')",             'hd:,::'           ], # invalid path, but it works
[ "Mac->splitdir('hd::d1:')",          'hd:,::,d1'        ], # invalid path, but it works
[ "Mac->splitdir('hd:d1:d2:::')",      'hd:,d1,d2,::,::'  ],
[ "Mac->splitdir('hd:d1:d2::')",       'hd:,d1,d2,::'     ],
[ "Mac->splitdir('hd:d1:d2:')",        'hd:,d1,d2'        ],
[ "Mac->splitdir('hd:d1:d2')",         'hd:,d1,d2'        ],
[ "Mac->splitdir('hd:d1::d2::')",      'hd:,d1,::,d2,::'  ],

[ "Mac->catdir()",                 ''             ],
[ "Mac->catdir('')",               $root, 'MacOS' ], # skipped on other OS
[ "Mac->catdir(':')",              ':'            ],

[ "Mac->catdir('', '')",           $root, 'MacOS' ], # skipped on other OS
[ "Mac->catdir('', ':')",          $root, 'MacOS' ], # skipped on other OS
[ "Mac->catdir(':', ':')",         ':'            ],
[ "Mac->catdir(':', '')",          ':'            ],

[ "Mac->catdir('', '::')",         $root, 'MacOS' ], # skipped on other OS
[ "Mac->catdir(':', '::')",        '::'           ],

[ "Mac->catdir('::', '')",         '::'           ],
[ "Mac->catdir('::', ':')",        '::'           ],

[ "Mac->catdir('::', '::')",       ':::'          ],

[ "Mac->catdir(':d1')",                    ':d1:'        ],
[ "Mac->catdir(':d1:')",                   ':d1:'        ],
[ "Mac->catdir(':d1','d2')",               ':d1:d2:'     ],
[ "Mac->catdir(':d1',':d2')",              ':d1:d2:'     ],
[ "Mac->catdir(':d1',':d2:')",             ':d1:d2:'     ],
[ "Mac->catdir(':d1',':d2::')",            ':d1:d2::'     ],
[ "Mac->catdir(':',':d1',':d2')",          ':d1:d2:'     ],
[ "Mac->catdir('::',':d1',':d2')",         '::d1:d2:'    ],
[ "Mac->catdir('::','::',':d1',':d2')",    ':::d1:d2:'   ],
[ "Mac->catdir(':',':',':d1',':d2')",      ':d1:d2:'     ],
[ "Mac->catdir('::',':',':d1',':d2')",     '::d1:d2:'    ],

[ "Mac->catdir('d1')",                    ':d1:'         ],
[ "Mac->catdir('d1','d2','d3')",          ':d1:d2:d3:'   ],
[ "Mac->catdir('d1','d2/','d3')",         ':d1:d2/:d3:'  ],
[ "Mac->catdir('d1','',':d2')",           ':d1:d2:'      ],
[ "Mac->catdir('d1',':',':d2')",          ':d1:d2:'      ],
[ "Mac->catdir('d1','::',':d2')",         ':d1::d2:'     ],
[ "Mac->catdir('d1',':::',':d2')",        ':d1:::d2:'    ],
[ "Mac->catdir('d1','::','::',':d2')",    ':d1:::d2:'    ],
[ "Mac->catdir('d1','d2')",               ':d1:d2:'      ],
[ "Mac->catdir('d1','d2', '')",           ':d1:d2:'      ],
[ "Mac->catdir('d1','d2', ':')",          ':d1:d2:'      ],
[ "Mac->catdir('d1','d2', '::')",         ':d1:d2::'     ],
[ "Mac->catdir('d1','d2','','')",         ':d1:d2:'      ],
[ "Mac->catdir('d1','d2',':','::')",      ':d1:d2::'     ],
[ "Mac->catdir('d1','d2','::','::')",     ':d1:d2:::'    ],
[ "Mac->catdir('d1',':d2')",              ':d1:d2:'      ],
[ "Mac->catdir('d1',':d2:')",             ':d1:d2:'      ],

[ "Mac->catdir('','d1','d2','d3')",        $root . 'd1:d2:d3:', 'MacOS' ], # skipped on other OS
[ "Mac->catdir('',':','d1','d2')",         $root . 'd1:d2:'   , 'MacOS' ], # skipped on other OS
[ "Mac->catdir('','::','d1','d2')",        $root . 'd1:d2:'   , 'MacOS' ], # skipped on other OS
[ "Mac->catdir('',':','','d1')",           $root . 'd1:'      , 'MacOS' ], # skipped on other OS
[ "Mac->catdir('', ':d1',':d2')",          $root . 'd1:d2:'   , 'MacOS' ], # skipped on other OS
[ "Mac->catdir('','',':d1',':d2')",        $root . 'd1:d2:'   , 'MacOS' ], # skipped on other OS

[ "Mac->catdir('hd:',':d1')",       'hd:d1:'      ],
[ "Mac->catdir('hd:d1:',':d2')",    'hd:d1:d2:'   ],
[ "Mac->catdir('hd:','d1')",        'hd:d1:'      ],
[ "Mac->catdir('hd:d1:',':d2')",    'hd:d1:d2:'   ],
[ "Mac->catdir('hd:d1:',':d2:')",   'hd:d1:d2:'   ],

[ "Mac->catfile()",                      ''                      ],
[ "Mac->catfile('')",                    ''                      ],
[ "Mac->catfile('', '')",                $root         , 'MacOS' ], # skipped on other OS
[ "Mac->catfile('', 'file')",            $root . 'file', 'MacOS' ], # skipped on other OS
[ "Mac->catfile(':')",                   ':'                     ],
[ "Mac->catfile(':', '')",               ':'                     ],

[ "Mac->catfile('d1','d2','file')",      ':d1:d2:file' ],
[ "Mac->catfile('d1','d2',':file')",     ':d1:d2:file' ],
[ "Mac->catfile('file')",                'file'        ],
[ "Mac->catfile(':', 'file')",           ':file'       ],

[ "Mac->canonpath('')",                   ''     ],
[ "Mac->canonpath(':')",                  ':'    ],
[ "Mac->canonpath('::')",                 '::'   ],
[ "Mac->canonpath('a::')",                'a::'  ],
[ "Mac->canonpath(':a::')",               ':a::' ],

[ "Mac->abs2rel('hd:d1:d2:','hd:d1:d2:')",            ':'            ],
[ "Mac->abs2rel('hd:d1:d2:','hd:d1:d2:file')",        ':'            ], # ignore base's file portion
[ "Mac->abs2rel('hd:d1:d2:file','hd:d1:d2:')",        ':file'        ],
[ "Mac->abs2rel('hd:d1:','hd:d1:d2:')",               '::'           ],
[ "Mac->abs2rel('hd:d3:','hd:d1:d2:')",               ':::d3:'       ],
[ "Mac->abs2rel('hd:d3:','hd:d1:d2::')",              '::d3:'        ],
[ "Mac->abs2rel('hd:d1:d4:d5:','hd:d1::d2:d3::')",    '::d1:d4:d5:'  ],
[ "Mac->abs2rel('hd:d1:d4:d5:','hd:d1::d2:d3:')",     ':::d1:d4:d5:' ], # first, resolve updirs in base
[ "Mac->abs2rel('hd:d1:d3:','hd:d1:d2:')",            '::d3:'        ],
[ "Mac->abs2rel('hd:d1::d3:','hd:d1:d2:')",           ':::d3:'       ],
[ "Mac->abs2rel('hd:d3:','hd:d1:d2:')",               ':::d3:'       ], # same as above
[ "Mac->abs2rel('hd:d1:d2:d3:','hd:d1:d2:')",         ':d3:'         ],
[ "Mac->abs2rel('hd:d1:d2:d3::','hd:d1:d2:')",        ':d3::'        ],
[ "Mac->abs2rel('hd1:d3:d4:d5:','hd2:d1:d2:')",       'hd1:d3:d4:d5:'], # volume mismatch
[ "Mac->abs2rel('hd:','hd:d1:d2:')",                  ':::'          ],

[ "Mac->rel2abs(':d3:','hd:d1:d2:')",          'hd:d1:d2:d3:'     ],
[ "Mac->rel2abs(':d3:d4:','hd:d1:d2:')",       'hd:d1:d2:d3:d4:'  ],
[ "Mac->rel2abs('','hd:d1:d2:')",              ''                 ],
[ "Mac->rel2abs('::','hd:d1:d2:')",            'hd:d1:d2::'       ],
[ "Mac->rel2abs('::','hd:d1:d2:file')",        'hd:d1:d2::'       ],# ignore base's file portion
[ "Mac->rel2abs(':file','hd:d1:d2:')",         'hd:d1:d2:file'    ],
[ "Mac->rel2abs('::file','hd:d1:d2:')",        'hd:d1:d2::file'   ],
[ "Mac->rel2abs('::d3:','hd:d1:d2:')",         'hd:d1:d2::d3:'    ],
[ "Mac->rel2abs('hd:','hd:d1:d2:')",           'hd:'              ], # path already absolute
[ "Mac->rel2abs('hd:d3:file','hd:d1:d2:')",    'hd:d3:file'       ],
[ "Mac->rel2abs('hd:d3:','hd:d1:file')",       'hd:d3:'           ],

[ "Epoc->case_tolerant()",         '1'  ],

[ "Epoc->canonpath('')",                                      ''          ],
[ "Epoc->canonpath('///../../..//./././a//b/.././c/././')",   '/a/b/../c' ],
[ "Epoc->canonpath('/./')",                                   '/'         ],
[ "Epoc->canonpath('/a/./')",                                 '/a'        ],

# XXX Todo, copied from Unix, but fail. Should they? 2003-07-07 Tels
#[ "Epoc->canonpath('/a/.')",                                  '/a'        ],
#[ "Epoc->canonpath('/.')",                                    '/'         ],

[ "Cygwin->case_tolerant()",         '0'  ],

) ;

if ($^O eq 'MSWin32') {
  push @tests, [ "FakeWin32->rel2abs('D:foo.txt')", 'D:\\alpha\\beta\\foo.txt' ];
}


plan tests => scalar @tests;

{
    package File::Spec::FakeWin32;
    use vars qw(@ISA);
    @ISA = qw(File::Spec::Win32);

    sub _cwd { 'C:\\one\\two' }

    # Some funky stuff to override Cwd::getdcwd() for testing purposes,
    # in the limited scope of the rel2abs() method.
    if ($Cwd::VERSION gt '2.17') {
	local $^W;
	*rel2abs = sub {
	    my $self = shift;
	    local $^W;
	    local *Cwd::getdcwd = sub {
	      return 'D:\alpha\beta' if $_[0] eq 'D:';
	      return 'C:\one\two'    if $_[0] eq 'C:';
	      return;
	    };
	    *Cwd::getdcwd = *Cwd::getdcwd; # Avoid a 'used only once' warning
	    return $self->SUPER::rel2abs(@_);
	};
	*rel2abs = *rel2abs; # Avoid a 'used only once' warning
    }
}


# Test out the class methods
for ( @tests ) {
   tryfunc( @$_ ) ;
}


#
# Tries a named function with the given args and compares the result against
# an expected result. Works with functions that return scalars or arrays.
#
sub tryfunc {
    my $function = shift ;
    my $expected = shift ;
    my $platform = shift ;

    if ($platform && $^O ne $platform) {
	skip("skip $function", 1);
	return;
    }

    $function =~ s#\\#\\\\#g ;
    $function =~ s/^([^\$].*->)/File::Spec::$1/;
    my $got = join ',', eval $function;

    if ( $@ ) {
      if ( $@ =~ /^\Q$skip_exception/ ) {
	skip "skip $function: $skip_exception", 1;
      }
      else {
	ok $@, '', $function;
      }
      return;
    }

    ok $got, $expected, $function;
}
