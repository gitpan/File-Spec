use Module::Build;

my $build = Module::Build->new
  (
   module_name => 'File::Spec',
   license => 'perl',
   dist_author => 'Ken Williams <KWILLIAMS@cpan.org>',
   installdirs => 'core',
   requires       => {
		      File::Basename => 0,
		      Cwd => '2.17_02',
		     },
   build_requires => {
		      Test::More => 0,
		      Test => 0,
		     },
   create_makefile_pl => 'traditional',
  );

$build->create_build_script;
