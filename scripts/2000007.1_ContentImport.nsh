OS="Linux"
if [[ "${OS}" = "WindowsNT" ]]
then
	UTILS_DIR="$TEMP/Utilities"
else
	UTILS_DIR="/tmp/Utilities"
fi

echo "Checking for existence of '$UTILS_DIR'."

ITERATION=1
while [ $ITERATION -lt 30 ]
do
	if [ ! -d $UTILS_DIR ]
	then
		break;
	fi

	if [ $ITERATION -eq 1 ]
	then
		echo "Waiting for another installer to complete. If another installation doesn't complete in next 30 minutes, this operation will resume..."
	fi

	sleep 60
	ITERATION=$(($ITERATION+1))
done

echo -E "Starting execution..."

mkdir -p "/opt/bmc/bladelogic/appserver/NSH/br/Content_Installer"
cp -f "//clm-aus-tb11e6/opt/bmc/bladelogic/storage/installer_bundle/linux/files/compliance_content/Content89-SP3-P1-LIN.bin" "/opt/bmc/bladelogic/appserver/NSH/br/Content_Installer/"
exit_code=`echo $?`
if [ "$exit_code" -ne '0' ]
then
	echo "Error occurred while copying //clm-aus-tb11e6/opt/bmc/bladelogic/storage/installer_bundle/linux/files/compliance_content/Content89-SP3-P1-LIN.bin EXIT_CODE is $exit_code... Exiting"
	exit "$exit_code"
fi
cp -f "//clm-aus-tb11e6/opt/bmc/bladelogic/storage/installer_bundle/linux/files/compliance_content/final_response_file.properties" "/opt/bmc/bladelogic/appserver/NSH/br/Content_Installer/"
exit_code=`echo $?`
if [ "$exit_code" -ne '0' ]
then
	echo "Error occurred while copying //clm-aus-tb11e6/opt/bmc/bladelogic/storage/installer_bundle/linux/files/compliance_content/final_response_file.properties EXIT_CODE is $exit_code... Exiting"
	exit "$exit_code"
fi
chmod +x "/opt/bmc/bladelogic/appserver/NSH/br/Content_Installer/Content89-SP3-P1-LIN.bin"
exit_code=`echo $?`
if [ "$exit_code" -ne '0' ]
then
	echo "Error occurred while executing chmod +x EXIT_CODE is $exit_code... Exiting"
	exit "$exit_code"
fi
nexec clm-aus-t3ved5.bmc.com rsu  root "/opt/bmc/bladelogic/appserver/NSH/br/Content_Installer/Content89-SP3-P1-LIN.bin" -i silent -DOPTIONS_FILE="/opt/bmc/bladelogic/appserver/NSH/br/Content_Installer/final_response_file.properties"
exit_code=`echo $?`
if [ "$exit_code" -ne '0' ]
then
	echo "Error occurred while executing "nexec" EXIT_CODE is $exit_code... Exiting"
	exit "$exit_code"
fi
rm -rf "/opt/bmc/bladelogic/appserver/NSH/br/Content_Installer"
