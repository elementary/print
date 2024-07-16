project(
    'io.elementary.print',
    'vala', 'c',
    version: '0.1.3'
)

executable(
    meson.project_name(),
    'src/Application.vala',
    'src/CustomOperation.vala',
    dependencies: [
        dependency('gtk4'),
        dependency('cairo'),
        dependency('pango'),
        meson.get_compiler('vala').find_library('posix'),
        meson.get_compiler('c').find_library('m', required : false)
    ],
    install : true
)

install_data(
    'data/' + meson.project_name() + '.contract',
    install_dir: join_paths(get_option('datadir'), 'contractor')
)
