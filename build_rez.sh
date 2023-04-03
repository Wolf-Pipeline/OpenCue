#!/bin/sh
HERE=`pwd`
# Get arguments from build_command (see package.py)
SRC_PATH=${1}
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
mkdir -p $INSTALL_PATH
cd $INSTALL_PATH
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
echo rqst: $REQUESTED_INSTALL_PATH
echo libs: $LIB_PATH
echo modules: $MODULES
echo version: $VERSION
echo

install_package () {
  PKG=$1
  VERSION_FILE="$SRC_PATH/$PKG/VERSION"
  echo $VERSION > "$VERSION_FILE"
  rez-pip --install $SRC_PATH/$PKG --prefix $INSTALL_PATH --extra  --no-deps
  rm "$VERSION_FILE"
}

# Install packages dependencies
rez-pip --install "$SRC_PATH/requirements.txt" --release --prefix "$LIB_PATH" --extra --requirement
rez-pip --install "$SRC_PATH/requirements_gui.txt" --release --prefix "$LIB_PATH" --extra --requirement

# When installing RQD
if [[ " ${MODULES[*]} " =~ " rqd " ]];  then
  # Build rqd's grpc protocol files and convert them to python3
  python -m grpc_tools.protoc --proto_path=$SRC_PATH/proto --python_out=$SRC_PATH/rqd/rqd/compiled_proto --grpc_python_out=$SRC_PATH/rqd/rqd/compiled_proto $SRC_PATH/proto/*.proto
  2to3 -wn -f import $SRC_PATH/rqd/rqd/compiled_proto/*_pb2*.py
fi

# When installing any module
if [  ! "$MODULES" = "rqd" ];  then
  # Build pycue's grpc protocol files and convert them to python3
  python -m grpc_tools.protoc --proto_path=$SRC_PATH/proto --python_out=$SRC_PATH/pycue/opencue/compiled_proto --grpc_python_out=$SRC_PATH/pycue/opencue/compiled_proto $SRC_PATH/proto/*.proto
  2to3 -wn -f import $SRC_PATH/pycue/opencue/compiled_proto//*_pb2*.py
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
