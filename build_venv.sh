#!/bin/sh
HERE=`pwd`
# Get optionnal arguments : build.sh ~source ~target -- ~[all | modules]
SRC_PATH=${1:-.}
REQUESTED_INSTALL_PATH=${2:-build}
MODULES="${@:3}"
MODULES=${MODULES:-all}

# List of available modules to install
PACKAGES=("rqd" "cuegui" "cuesubmit" "cueadmin")

cd $SRC_PATH
SRC_PATH="`pwd`"
cd $HERE
mkdir -p $REQUESTED_INSTALL_PATH
cd $REQUESTED_INSTALL_PATH
INSTALL_PATH="`pwd`"
cd $HERE

echo
echo src: $SRC_PATH
echo tgt: $INSTALL_PATH
echo modules: $MODULES
echo

# Create and enter virtualenv
echo "
python -m venv $INSTALL_PATH/venv
sh $INSTALL_PATH/venv/Scripts/activate
"

# List of available modules to install
PACKAGES=("rqd" "cuegui" "cuesubmit" "cueadmin")
if [ "$MODULES" == "all" ];  then
	MODULES=${PACKAGES[*]}
fi

install_package () {
  # echo $VERSION > "$SRC_PATH/$PKG/VERSION"
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
