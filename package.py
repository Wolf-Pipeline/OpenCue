
name = 'opencue'

version = '0.22.2'

branch_path = "{root}"  # Source code directory

#variants = [['platform-linux']]

#build_command = f"bash {{root}}/build_rez.sh {branch_path} {{build_path}} {{install_path}} {{version}}" #+ extra args
build_command = f"bash {{root}}/build_rez.sh {branch_path} {{install_path}} {{version}}" #+ extra args

@early()
def requires():
    build_requires = [
        '2to3-1.0',
        'grpcio-1.47.0',
        'grpcio_tools-1.47.0',
    ]
    base_requires = [
        '2to3-1.0',
        'future-0.18.3',
        'grpcio-1.47.0',
        'grpcio_tools-1.47.0',
        'mock-2.0.0',
        'packaging-20.9',
        'psutil-5.6.7',
        'pyfakefs-3.6',
        'pynput-1.7.6',
        'PyYAML-5.1',
        'six-1.11.0',
        'python_xlib'
        ]
    tools_requires = [
        'pycue',
        'pyoutline',
        'cueadmin',
        'cuegui',
        'cuesubmit',
        'rqd'
        ]
    gui_requires = [
        'PySide2-5.15.2.1',
        'QtPy-2.3.0',
        ]
    if building:
        return build_requires
    else:
        return base_requires + tools_requires + gui_requires

def commands():
    env.CUEBOT_HOSTNAME = "CUEBOT_SERVER"
    env.CUESUBMIT_CONFIG_FILE = "{root}/cuesubmit/cuesubmit_config.example.yaml"
    env.OPENCUE_CONFIG_FILE = "{root}/pycue/opencue/default.yaml"
    env.RQD_CONFIG_FILE = "{root}/rqd/rqd.conf"
    env.MAYA_JOB_CONFIG_FILE = "{root}/cuesubmit/cuesubmit_isolated_job_config.example.yaml"