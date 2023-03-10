#!/bin/bash

# Set default directory to the location of the script 
DEFAULT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Define array of file extension to be backup
file_extensions=(txt doc ppt sh)

# Get the current date in YYYY-MM-DD format
current_date=$(date +%Y-%m-%d)


# Create the backup directories for each file extension
backup_dir=${DEFAULT_DIR}/backUp_${current_date}
mkdir "$backup_dir"
for ext in "${file_extensions[@]}"
do
    mkdir "${backup_dir}/${ext}"
done

# Copy files to their respective backup directories
for ext in "${file_extensions[@]}"
do
    cp ${DEFAULT_DIR}/*."${ext}" "${backup_dir}/${ext}/"
done


# Zip each backup directory
for ext in "${file_extensions[@]}"
do
    zip -r "${backup_dir}/${ext}.zip" "${backup_dir}/${ext}"
done

# Combine all zip files into one
zip_file=${DEFAULT_DIR}/backup_${current_date}.zip
zip -j "${zip_file}" "${backup_dir}"/*.zip


# Set the remote server address
remote_address=" abc@127.0.0.1:/home/abc/test"


# Set the encrypted backup file name
encrypted_file=${DEFAULT_DIR}/backup_${current_date}.zip.enc


#5 Sending the file and notification
# Verify that the encrypted backup file was created
if [ -f "$zip_file" ]; then 
  echo "Successfully created zip file: $zip_file"


  # Encrypt the backup file with OpenSSL
  openssl enc -aes-256-cbc -md sha256 -in "$zip_file" -out "$encrypted_file" -pass pass:mysecretpassword

  # Send a telegram to notify that the backup is complete
  curl "https://api.telegram.org/bot6126256095:AAGTrYa8mnc31U3bDsmJV-Q9Ytcayl5Gw_M/sendMessage?chat_id=-844217782&text=BackUpComplete"
  # Send the encrypted backup file to the Telegram group
  curl -F document=@$encrypted_file "https://api.telegram.org/bot6126256095:AAGTrYa8mnc31U3bDsmJV-Q9Ytcayl5Gw_M/sendDocument?chat_id=-844217782"
  # Send the encrypted backup file to the remote server using scp
  scp "$encrypted_file" "$remote_address"
else
  echo "Failed to create zip file: $zip_file"
  curl "https://api.telegram.org/bot6126256095:AAGTrYa8mnc31U3bDsmJV-Q9Ytcayl5Gw_M/sendMessage?chat_id=-844217782&text=BackUp-Failed"
fi

# Remove the temporary backup directories and zip files
rm -rf "${backup_dir}"
rm "${zip_file}"
rm "${encrypted_file}"