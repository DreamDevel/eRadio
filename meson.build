project('com.github.dreamdevel.eradio', 'vala', 'c', version: '2.0.1')

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

asresources = gnome.compile_resources(
    'as-resources', join_paths('data', meson.project_name() + '.gresource.xml'),
    source_dir: 'data',
    c_name: 'as'
)

subdir('src')

executable(
    meson.project_name(),
    asresources,
    sources,
    config_header,
    dependencies: [
        dependency('gstreamer-1.0'),
        dependency('gtk+-3.0'),
        dependency('granite'),
        dependency('sqlite3'),
        dependency('gee-0.8'),
        dependency('libnotify'),
        dependency('json-glib-1.0'),
        dependency('libsoup-2.4'),
        dependency('libxml-2.0'),
        dependency('sqlheavy-0.1'),
        meson.get_compiler('c').find_library('m', required: 'false')
    ],
    install: true
)

subdir('data')
subdir('po')
subdir('schemas')

