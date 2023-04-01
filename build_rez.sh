#!/bin/sh
HERE=`pwd`
# Get arguments from build_command (see package.py)
SRC_PATH=${1}
# BUILD_TMP_PATH=realpath ${2:-build}
REQUESTED_INSTALL_PATH=${2}
VERSION=${3}
MODULES="${@:4}"
MODULES=${MODULES:-all}

# List of available modules to install
PACKAGES=("rqd" "cuegui" "cuesubmit" "cueadmin")

cd $SRC_PATH
SRC_PATH="`pwd`"
cd $HERE

# Where to install opencue libraries
INSTALL_PATH="${REQUESTED_INSTALL_PATH%%"$VERSION"*}../"

mkdir -p $REQUESTED_INSTALL_PATH
cd $REQUESTED_INSTALL_PATH
INSTALL_PATH="`pwd`"
cd $HERE

# Path to external dependencies
LIB_PATH=$INSTALL_PATH/lib

if [ "$MODULES" = "all" ];  then
	MODULES=${PACKAGES[*]}
fi

echo
echo src: $SRC_PATH
echo tgt: $INSTALL_PATH
echo libs: $LIB_PATH
echo modules: $MODULES
echo version: $VERSION
echo

install_package () {
  # cp "$SRC_PATH/VERSION.in" "$SRC_PATH/$PKG/VERSION"
  PKG=$1
  cd $SRC_PATH/$PKG
  echo "python setup.py install $PKG"
  cd $SRC_PATH
  # rm "$SRC_PATH/$PKG/VERSION"
}


# Install packages dependencies
echo "
  pip install -r requirements.txt
  pip install -r requirements_gui.txt
  "

install_package "pycue"

# When installing RQD
if [[ " ${MODULES[*]} " =~ " rqd " ]];  then
  echo "
  # Build rqd's grpc protocol files and convert them to python3
  cd $SRC_PATH/proto
  python -m grpc_tools.protoc --proto_path=. --python_out=../rqd/rqd/compiled_proto --grpc_python_out=../rqd/rqd/compiled_proto ./*.proto
  cd $SRC_PATH/rqd/rqd/compiled_proto/
  2to3 -wn -f import ./*_pb2*.py
  "
fi

# When installing any module
if [  ! "$MODULES" = "rqd" ];  then
  echo "
  # Build pycue's grpc protocol files and convert them to python3
  cd $SRC_PATH/proto
  python -m grpc_tools.protoc --proto_path=. --python_out=../pycue/opencue/compiled_proto --grpc_python_out=../pycue/opencue/compiled_proto ./*.proto
  cd $SRC_PATH/pycue/opencue/compiled_proto/
  2to3 -wn -f import ./*_pb2*.py
  "
fi

cd $INSTALL_PATH
# Finally install each package
for pkg in "${PACKAGES[@]}"; do
  if [[ ! " ${MODULES[*]} " =~ " $pkg " ]];  then
  	continue
  fi
  # extra dependencies for cuesubmit
  if [ "$pkg" = "cuesubmit" ];  then
    install_package "pyoutline"
  fi
  install_package $pkg
done
