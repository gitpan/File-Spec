use Module::Build;

my $build = Module::Build->new
  (
   module_name => 'File::Spec',
   license => 'perl',
   installdirs => 'core',
  );

$build->create_build_script;
