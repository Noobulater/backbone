# nim -r -p:lib -d:useSysAssert -d:useGcAssert c src/main
PATH = "C:\Program Files\Intel\WiFi\bin\;C:\Program Files\Common Files\Intel\WirelessCommon\;C:\Nim\dist\mingw;C:\Nim\dist\mingw\bin;C:\Nim\bin;C:\Nim\dist\babel;C:\Program Files (x86)\Git\bin;C:\Program Files (x86)\Git\cmd"
nimble build
if [ $? -eq 0 ]
then
  echo "BUILD SUCCESSFUL"
  ./src/main
else
  echo "BUILD FAILED"
fi
