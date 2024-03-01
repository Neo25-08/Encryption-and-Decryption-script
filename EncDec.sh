#!/bin/bash
privatekey="/path/to/sender's private key" #modify
publickey="/path/to/receiver's public key" #modify
signfile="path/to/signature file" #modify
figlet Encryption
figlet Decryption
figlet "               Tool"                                                                
echo "--------------------WELCOME!!!!!--------------------"
echo "This is your place to encrypt or decrypt a file." 
echo "What do you want to do?" 
echo "1. Encrypt"
echo "2. Decrypt"
read -p "Enter your choice: " choice

case $choice in
	1) echo "Do you want to input an already existing file or create a new one with new text?" 
	echo "1. Input existing file"
	echo "2. Input a new message"
	read -p "Enter you choice: " fileChoice
		case $fileChoice in
			1) read -p "Enter the file path: " fileToEnc;;
			2) read -p "Enter your message: " msg
			echo $msg > secretmsg.txt
			fileToEnc=./secretmsg.txt;;
		esac
		echo "Which encryption method would you like to use?" 
		echo "1. Symmetric"
		echo "2. Asymmetric"
		read -p "Enter your choice: " encType
		case $encType in
			1) echo "Choose your alogrithm" 
			echo "1. aes-192-cbc"
			echo "2. aes-256-cbc"
			echo "3. des-cbc"
			echo "4. seed-ecb"
			echo "5. aria-192-cbc"
			read -p "Enter your choice: " algorithm
			case $algorithm in
				1) openssl enc -aes-192-cbc -pbkdf2 -in $fileToEnc -out encFile.txt;; 
				2) openssl enc -aes-256-cbc -pbkdf2 -in $fileToEnc -out encFile.txt;;
				3) openssl enc -descbc -pbkdf2 -in $fileToEnc -out encFile.txt;;
				4) openssl enc -seed-ebc -pbkdf2 -in $fileToEnc -out encFile.txt;;
				5) openssl enc -aria-192-cbc -pbkdf2 -in $fileToEnc -out encFile.txt;;
			esac
			rm $fileToEnc;;
			2) openssl pkeyutl -encrypt -in $fileToEnc -out enc.txt -inkey $publickey -pubin
			openssl dgst -sha256 -sign $privatekey -out signature.txt $signfile
			base64 signature.txt > encSign.txt
			rm -f signature.txt
			scp enc.txt encSign.txt #<username of receiver>@<ip of receiver>:/path/to/paste/file #modify
			rm -f enc.txt encSign.txt $fileToEnc;;
			*) echo "Invalid choice!" ;;
		esac;;
	2) read -p "Enter the file path of the file you want to decrypt: " fileToDec
	echo "Which decryption method would you like to use?" 
	echo "1. Symmetric"
	echo "2. Asymmetric"
	read -p "Enter your choice: " decType
	case $decType in
		1) echo "Choose your alogrithm"
			echo "1. aes-192-cbc"
			echo "2. aes-256-cbc"
			echo "3. des-cbc"
			echo "4. seed-ecb"
			echo "5. aria-192-cbc"
			read -p "Enter your choice: " algorithm
			case $algorithm in
				1) openssl enc -d -aes-192-cbc -pbkdf2 -in $fileToDec -out decFile.txt;; 
				2) openssl enc -d -aes-256-cbc -pbkdf2 -in $fileToDec -out decFile.txt;;
				3) openssl enc -d -des-cbc -pbkdf2 -in $fileToDec -out decFile.txt;;
				4) openssl enc -d -seed-cbc -pbkdf2 -in $fileToDec -out decFile.txt;;
				5) openssl enc -d -aria-192-cbc -pbkdf2 -in $fileToDec -out decFile.txt;;
			esac
			echo -n "Decrypted message: "
			cat decFile.txt
			rm -f decFile.txt;;
		2) 	base64 -d encSign.txt > signature.txt
			if [[ $(openssl dgst -sha256 -verify $publickey -signature signature.txt file.txt) == "Verified OK" ]]; then
				openssl pkeyutl -decrypt -in $fileToDec -out dec.txt -inkey $privatekey
				echo -n "Decrypted message: "
				cat dec.txt
				rm -f dec.txt signature.txt encSign.txt
			else
				echo "An error occured"
			fi;;
		*) echo "Invalid choice!" ;;
	esac;;
	*) echo "Invalid choice!" ;;
esac
