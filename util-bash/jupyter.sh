#!/bin/sh

CURDIR=$(cd "$(dirname "$0")"; pwd);
MYNAME="${0##*/}"

jpyProfile=vidardb3
profileFile="${HOME}/.ipython/profile_${jpyProfile}/ipython_kernel_config.py"
jupyterPort="8888"

if [ "$TERM"="linux" ] ; then
    export LANG=en_US.UTF-8
fi

## install action
_install() {
    ### INSTALL pip3
    sudo apt install python3-pip

    export LC_ALL=C
    sudo /usr/bin/pip3 install jupyter
    sudo /usr/bin/pip3 install ipython-sql
    sudo /usr/bin/pip3 install pgspecial
    # https://matplotlib.org/users/installing.html
    sudo /usr/bin/pip3 install matplotlib
    sudo /usr/bin/pip3 install pandas
    sudo /usr/bin/pip3 install ipympl
    sudo /usr/bin/pip3 install networkx
    sudo /usr/bin/pip3 install scipy
    sudo /usr/bin/pip3 install pandas
    sudo /usr/bin/pip3 install xlrd

    ### create jupyter
    ipython profile create ${jpyProfile}
    #cat ~/.ipython/profile_${jpyProfile}/ipython_kernel_config.py

    PASS="vidardb2019"
    iPASS=`ipython -c "from IPython.lib import passwd; passwd(\"${PASS}\");" | awk '{print $2}'`
    echo ${iPASS}

    grep -q 'c.NotebookApp.ip' ${profileFile} || {
    cat >>${profileFile} <<EOF
c = get_config()
# Kernel config
c.IPKernelApp.pylab = 'inline'
# Notebook config
c.NotebookApp.ip='*'
c.NotebookApp.open_browser = False
c.NotebookApp.password = u$iPASS
c.NotebookApp.port = ${jupyterPort}
EOF
    }

}

## start action
_start() {
    jupyter notebook --config ${profileFile}
}

## usage
_usage() {
    cat << USAGE
Usage: bash ${MYNAME} start|install

Action:
    start               Start jupyter notebook service.
    install             Install jupyter and python modules for jupyter.
USAGE

    exit 1
}

## main
action=$1
case $action in
    ## opt
    "start" )
        _start
        ;;
    "install" )
        _install
        ;;
    *)
        _usage
        ;;
esac
