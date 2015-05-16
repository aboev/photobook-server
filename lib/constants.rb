class Constants
  RESULT_OK 		= 	"OK"
  RESULT_ERROR		= 	"ERROR"

  ERROR_JSON_PARSE 	= 	101
  MSG_JSON_PARSE 	= 	"JSON parse error"
  ERROR_BODY_FORMAT 	= 	102
  MSG_BODY_FORMAT 	= 	"Missing required argument in body"
  ERROR_NOT_FOUND	=	103
  MSG_NOT_FOUND		=	"Entry not found"

  ERROR_NUMBER_EXISTS	=	120
  MSG_NUMBER_EXISTS	=	"Number already exists"
  ERROR_WRONG_CODE	=	121
  MSG_WRONG_CODE	=	"SMS validation failed"

  HEADER_USERID		=	"userid"
  HEADER_IMAGEID	=	"imageid"
  HEADER_MODTIME	=	"from"
  HEADER_ID		=	"id"
  KEY_IMAGEID		=	"image_id"
  KEY_SERVER_VERSION	=	"version"
  KEY_MIN_CLIENT_VERSION=	"min_client"
  KEY_LATEST_APK_URL	=	"latest_apk"
  KEY_LATEST_APK_VER	=	"latest_ver"

  KEY_CONTACT_KEY	=	"contact_key"
  KEY_NUMBER		=	"number"
  KEY_CODE		=	"code"
  KEY_STATUS		=	"status"

  JSON_IMAGE_IMAGE_ID	=	"image_id"
  JSON_IMAGE_AUTHOR_ID	=	"author_id"
  JSON_IMAGE_URL_ORIGINAL=	"url_original"
  JSON_IMAGE_URL_MEDIUM	=	"url_medium"
  JSON_IMAGE_URL_SMALL	=	"url_small"
  JSON_IMAGE_ASPECT_RATIO=	"aspect_ratio"
  JSON_IMAGE_TIMESTAMP	=	"timestamp"
  JSON_IMAGE_STATUS	=	"status"
  JSON_IMAGE_TITLE	=	"title"
  JSON_IMAGE_STORAGE	=	"storage"
  JSON_IMAGE_PATH_ORIGINAL=	"path_original"
  JSON_IMAGE_PATH_MEDIUM=	"path_medium"
  JSON_IMAGE_PATH_SMALL=	"path_small"
  JSON_IMAGE_LIKES	=	"likes"
  JSON_IMAGE_LOCAL_URI	=	"local_uri"

  JSON_USER_PUBLIC_ID  	=       "id"
  JSON_USER_PRIVATE_ID  =       "private_id"
  JSON_USER_CONTACT_KEY =       "contact_key"
  JSON_USER_PROFILE	=      	"profile"
  JSON_USER_PUSHID	=       "pushid"
  JSON_USER_SMSCODE	=       "smscode"
  JSON_USER_STATUS	=      	"status"

  JSON_COMMENT_ID	=	"id"
  JSON_COMMENT_IMAGE_ID	=	"image_id"
  JSON_COMMENT_AUTHOR_ID=	"author_id"
  JSON_COMMENT_TIMESTAMP=	"timestamp"
  JSON_COMMENT_TEXT	=	"text"
  JSON_COMMENT_REPLY_TO	=	"reply_to"

  JSON_CONTACT_PUBLIC_ID=	"public_id"
  JSON_CONTACT_CONTACT_KEY=	"contact_key"

  JSON_FRIEND_PUBLIC_ID =	"public_id"
  JSON_FRIEND_PUBLIC_ID_SRC=	"public_id_src"
  JSON_FRIEND_PUBLIC_ID_DEST=	"public_id_dest"
  JSON_FRIEND_STATUS	=	"status"
  JSON_FRIEND_CONTACT_KEY=	"contact_key"
end
