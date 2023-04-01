
name = 'opencue'

version = '0.22.1'

branch_path = "{root}/dev/cuesubmit/dev"

#variants = [['platform-linux']]

#build_command = f"bash {{root}}/build_rez.sh {branch_path} {{build_path}} {{install_path}} {{version}}" #+ extra args
build_command = f"bash {{root}}/build_rez.sh {branch_path} {{install_path}} {{version}}" #+ extra args

@early()
def requires():
    base_requires = [        
        '2to3',
        'future',
        'grpcio',
        'grpcio_tools',
        'mock',
        'packaging',
        'psutil',
        'pyfakefs',
        'pynput',
        'PyYAML',
        'six',
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
        'PySide2',
        'QtPy',
        ]
    if building:
        return []
    else:
        return base_requires + tools_requires + gui_requires

def commands():
    env.CUEBOT_HOSTNAME = "CUEBOT_SERVER"
    env.CUESUBMIT_CONFIG_FILE = "{root}/cuesubmit/cuesubmit_config.example.yaml"
    env.OPENCUE_CONFIG_FILE = "{root}/pycue/opencue/default.yaml"
    env.RQD_CONFIG_FILE = "{root}/rqd/rqd.conf"
    env.MAYA_JOB_CONFIG_FILE = "{root}/cuesubmit/cuesubmit_isolated_job_config.example.yaml"