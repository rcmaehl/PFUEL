Func _GetLanguage($iFlag = 0)
	$sLang = "Unknown"
	Switch @OSLang
		Case "0436"
			$sLang = "Afrikaans - South Africa"
		Case "041C"
			$sLang = "Albanian - Albania"
		Case "1401"
			$sLang = "Arabic - Algeria"
		Case "3C01"
			$sLang = "Arabic - Bahrain"
		Case "0C01"
			$sLang = "Arabic - Egypt"
		Case "0801"
			$sLang = "Arabic - Iraq"
		Case "2C01"
			$sLang = "Arabic - Jordan"
		Case "3401"
			$sLang = "Arabic - Kuwait"
		Case "3001"
			$sLang = "Arabic - Lebanon"
		Case "1001"
			$sLang = "Arabic - Libya"
		Case "1801"
			$sLang = "Arabic - Morocco"
		Case "2001"
			$sLang = "Arabic - Oman"
		Case "4001"
			$sLang = "Arabic - Qatar"
		Case "0401"
			$sLang = "Arabic - Saudi Arabia"
		Case "2801"
			$sLang = "Arabic - Syria"
		Case "1C01"
			$sLang = "Arabic - Tunisia"
		Case "3801"
			$sLang = "Arabic - United Arab Emirates"
		Case "2401"
			$sLang = "Arabic - Yemen"
		Case "042B"
			$sLang = "Armenian - Armenia"
		Case "082C"
			$sLang = "Azeri (Cyrillic) - Azerbaijan"
		Case "042C"
			$sLang = "Azeri (Latin) - Azerbaijan"
		Case "042D"
			$sLang = "Basque - Basque"
		Case "0423"
			$sLang = "Belarusian - Belarus"
		Case "0402"
			$sLang = "Bulgarian - Bulgaria"
		Case "0403"
			$sLang = "Catalan - Catalan"
		Case "0804"
			$sLang = "Chinese - China"
		Case "0C04"
			$sLang = "Chinese - Hong Kong SAR"
		Case "1404"
			$sLang = "Chinese - Macau SAR"
		Case "1004"
			$sLang = "Chinese - Singapore"
		Case "0404"
			$sLang = "Chinese - Taiwan"
		Case "0004"
			$sLang = "Chinese (Simplified)"
		Case "7C04"
			$sLang = "Chinese (Traditional)"
		Case "041A"
			$sLang = "Croatian - Croatia"
		Case "0405"
			$sLang = "Czech - Czech Republic"
		Case "0406"
			$sLang = "Danish - Denmark"
		Case "0465"
			$sLang = "Dhivehi - Maldives"
		Case "0813"
			$sLang = "Dutch - Belgium"
		Case "0413"
			$sLang = "Dutch - The Netherlands"
		Case "0C09"
			$sLang = "English - Australia"
		Case "2809"
			$sLang = "English - Belize"
		Case "1009"
			$sLang = "English - Canada"
		Case "2409"
			$sLang = "English - Caribbean"
		Case "1809"
			$sLang = "English - Ireland"
		Case "2009"
			$sLang = "English - Jamaica"
		Case "1409"
			$sLang = "English - New Zealand"
		Case "3409"
			$sLang = "English - Philippines"
		Case "1C09"
			$sLang = "English - South Africa"
		Case "2C09"
			$sLang = "English - Trinidad and Tobago"
		Case "0809"
			$sLang = "English - United Kingdom"
		Case "0409"
			$sLang = "English - United States"
		Case "3009"
			$sLang = "English - Zimbabwe"
		Case "0425"
			$sLang = "Estonian - Estonia"
		Case "0438"
			$sLang = "Faroese - Faroe Islands"
		Case "0429"
			$sLang = "Farsi - Iran"
		Case "040B"
			$sLang = "Finnish - Finland"
		Case "080C"
			$sLang = "French - Belgium"
		Case "0C0C"
			$sLang = "French - Canada"
		Case "040C"
			$sLang = "French - France"
		Case "140C"
			$sLang = "French - Luxembourg"
		Case "180C"
			$sLang = "French - Monaco"
		Case "100C"
			$sLang = "French - Switzerland"
		Case "0456"
			$sLang = "Galician - Galician"
		Case "0437"
			$sLang = "Georgian - Georgia"
		Case "0C07"
			$sLang = "German - Austria"
		Case "0407"
			$sLang = "German - Germany"
		Case "1407"
			$sLang = "German - Liechtenstein"
		Case "1007"
			$sLang = "German - Luxembourg"
		Case "0807"
			$sLang = "German - Switzerland"
		Case "0408"
			$sLang = "Greek - Greece"
		Case "0447"
			$sLang = "Gujarati - India"
		Case "040D"
			$sLang = "Hebrew - Israel"
		Case "0439"
			$sLang = "Hindi - India"
		Case "040E"
			$sLang = "Hungarian - Hungary"
		Case "040F"
			$sLang = "Icelandic - Iceland"
		Case "0421"
			$sLang = "Indonesian - Indonesia"
		Case "0410"
			$sLang = "Italian - Italy"
		Case "0810"
			$sLang = "Italian - Switzerland"
		Case "0411"
			$sLang = "Japanese - Japan"
		Case "044B"
			$sLang = "Kannada - India"
		Case "043F"
			$sLang = "Kazakh - Kazakhstan"
		Case "0457"
			$sLang = "Konkani - India"
		Case "0412"
			$sLang = "Korean - Korea"
		Case "0440"
			$sLang = "Kyrgyz - Kazakhstan"
		Case "0426"
			$sLang = "Latvian - Latvia"
		Case "0427"
			$sLang = "Lithuanian - Lithuania"
		Case "042F"
			$sLang = "Macedonian (FYROM)"
		Case "083E"
			$sLang = "Malay - Brunei"
		Case "043E"
			$sLang = "Malay - Malaysia"
		Case "044E"
			$sLang = "Marathi - India"
		Case "0450"
			$sLang = "Mongolian - Mongolia"
		Case "0414"
			$sLang = "Norwegian (Bokmål) - Norway"
		Case "0814"
			$sLang = "Norwegian (Nynorsk) - Norway"
		Case "0415"
			$sLang = "Polish - Poland"
		Case "0416"
			$sLang = "Portuguese - Brazil"
		Case "0816"
			$sLang = "Portuguese - Portugal"
		Case "0446"
			$sLang = "Punjabi - India"
		Case "0418"
			$sLang = "Romanian - Romania"
		Case "0419"
			$sLang = "Russian - Russia"
		Case "044F"
			$sLang = "Sanskrit - India"
		Case "0C1A"
			$sLang = "Serbian (Cyrillic) - Serbia"
		Case "081A"
			$sLang = "Serbian (Latin) - Serbia"
		Case "041B"
			$sLang = "Slovak - Slovakia"
		Case "0424"
			$sLang = "Slovenian - Slovenia"
		Case "2C0A"
			$sLang = "Spanish - Argentina"
		Case "400A"
			$sLang = "Spanish - Bolivia"
		Case "340A"
			$sLang = "Spanish - Chile"
		Case "240A"
			$sLang = "Spanish - Colombia"
		Case "140A"
			$sLang = "Spanish - Costa Rica"
		Case "1C0A"
			$sLang = "Spanish - Dominican Republic"
		Case "300A"
			$sLang = "Spanish - Ecuador"
		Case "440A"
			$sLang = "Spanish - El Salvador"
		Case "100A"
			$sLang = "Spanish - Guatemala"
		Case "480A"
			$sLang = "Spanish - Honduras"
		Case "080A"
			$sLang = "Spanish - Mexico"
		Case "4C0A"
			$sLang = "Spanish - Nicaragua"
		Case "180A"
			$sLang = "Spanish - Panama"
		Case "3C0A"
			$sLang = "Spanish - Paraguay"
		Case "280A"
			$sLang = "Spanish - Peru"
		Case "500A"
			$sLang = "Spanish - Puerto Rico"
		Case "0C0A"
			$sLang = "Spanish - Spain"
		Case "380A"
			$sLang = "Spanish - Uruguay"
		Case "200A"
			$sLang = "Spanish - Venezuela"
		Case "0441"
			$sLang = "Swahili - Kenya"
		Case "081D"
			$sLang = "Swedish - Finland"
		Case "041D"
			$sLang = "Swedish - Sweden"
		Case "045A"
			$sLang = "Syriac - Syria"
		Case "0449"
			$sLang = "Tamil - India"
		Case "0444"
			$sLang = "Tatar - Russia"
		Case "044A"
			$sLang = "Telugu - India"
		Case "041E"
			$sLang = "Thai - Thailand"
		Case "041F"
			$sLang = "Turkish - Turkey"
		Case "0422"
			$sLang = "Ukrainian - Ukraine"
		Case "0420"
			$sLang = "Urdu - Pakistan"
		Case "0843"
			$sLang = "Uzbek (Cyrillic) - Uzbekistan"
		Case "0443"
			$sLang = "Uzbek (Latin) - Uzbekistan"
		Case "042A"
			$sLang = "Vietnamese - Vietnam"
		Case Else
			Switch StringRight(@OSLang, 2)
				Case "36"
					$sLang = "Afrikaans - Other"
				Case "1C"
					$sLang = "Albanian - Other"
				Case "01"
					$sLang = "Arabic - Other"
				Case "2B"
					$sLang = "Armenian - Other"
				Case "2C"
					$sLang = "Azeri - Other"
				Case "2D"
					$sLang = "Basque - Other"
				Case "23"
					$sLang = "Belarusian - Other"
				Case "02"
					$sLang = "Bulgarian - Other"
				Case "03"
					$sLang = "Catalan - Other"
				Case "04"
					$sLang = "Chinese - Other"
				Case "1A"
					$sLang = "Croatian - Other"
				Case "05"
					$sLang = "Czech - Other"
				Case "06"
					$sLang = "Danish - Other"
				Case "65"
					$sLang = "Dhivehi - Other"
				Case "13"
					$sLang = "Dutch - Other"
				Case "09"
					$sLang = "English - Other"
				Case "25"
					$sLang = "Estonian - Other"
				Case "38"
					$sLang = "Faroese - Other"
				Case "29"
					$sLang = "Farsi - Other"
				Case "0B"
					$sLang = "Finnish - Other"
				Case "0C"
					$sLang = "French - Other"
				Case "56"
					$sLang = "Galician - Other"
				Case "37"
					$sLang = "Georgian - Other"
				Case "07"
					$sLang = "German - Other"
				Case "08"
					$sLang = "Greek - Other"
				Case "47"
					$sLang = "Gujarati - Other"
				Case "0D"
					$sLang = "Hebrew - Other"
				Case "39"
					$sLang = "Hindi - Other"
				Case "0E"
					$sLang = "Hungarian - Other"
				Case "0F"
					$sLang = "Icelandic - Other"
				Case "21"
					$sLang = "Indonesian - Other"
				Case "10"
					$sLang = "Italian - Other"
				Case "11"
					$sLang = "Japanese - Other"
				Case "4B"
					$sLang = "Kannada - Other"
				Case "3F"
					$sLang = "Kazakh - Other"
				Case "57"
					$sLang = "Konkani - Other"
				Case "12"
					$sLang = "Korean - Other"
				Case "40"
					$sLang = "Kyrgyz - Other"
				Case "26"
					$sLang = "Latvian - Other"
				Case "27"
					$sLang = "Lithuanian - Other"
				Case "2F"
					$sLang = "Macedonian - Other"
				Case "3E"
					$sLang = "Malay - Other"
				Case "4E"
					$sLang = "Marathi - Other"
				Case "50"
					$sLang = "Mongolian - Other"
				Case "14"
					$sLang = "Norwegian - Other"
				Case "15"
					$sLang = "Polish - Other"
				Case "16"
					$sLang = "Portuguese - Other"
				Case "46"
					$sLang = "Punjabi - Other"
				Case "18"
					$sLang = "Romanian - Other"
				Case "19"
					$sLang = "Russian - Other"
				Case "4F"
					$sLang = "Sanskrit - Other"
				Case "1A"
					$sLang = "Serbian - Other"
				Case "1B"
					$sLang = "Slovak - Other"
				Case "24"
					$sLang = "Slovenian - Other"
				Case "0A"
					$sLang = "Spanish - Other"
				Case "41"
					$sLang = "Swahili - Other"
				Case "1D"
					$sLang = "Swedish - Other"
				Case "5A"
					$sLang = "Syriac - Other"
				Case "49"
					$sLang = "Tamil - Other"
				Case "44"
					$sLang = "Tatar - Other"
				Case "4A"
					$sLang = "Telugu - Other"
				Case "1E"
					$sLang = "Thai - Other"
				Case "1F"
					$sLang = "Turkish - Other"
				Case "22"
					$sLang = "Ukrainian - Other"
				Case "20"
					$sLang = "Urdu - Other"
				Case "43"
					$sLang = "Uzbek - Other"
				Case "2A"
					$sLang = "Vietnamese - Other"
			EndSwitch
	EndSwitch
	Return $sLang
EndFunc