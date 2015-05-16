require 'constants'
class Image < ActiveRecord::Base
  STATUS_PENDING_SHARE = 2
  STATUS_SHARED = 1
  STATUS_DEFAULT = 0

  MEDIUM_WIDTH = 600
  SMALL_WIDTH = 400

  STORAGE_LOCAL = 0
  STORAGE_DROPBOX = 1
  STORAGE_AWS_PENDING_UPLOAD = 10
  STORAGE_AWS_PENDING_CROP = 11
  STORAGE_AWS = 12

  def add_like(public_id)
    update_attributes likes: likes + [ public_id ]
  end

  def remove_like(public_id)
    update_attributes likes: likes - [ public_id ]
  end

  def as_jsonn
    tmp = as_json
    res = {}
    res[Constants::JSON_IMAGE_IMAGE_ID] 	= tmp["image_id"]
    res[Constants::JSON_IMAGE_AUTHOR_ID] 	= tmp["author_id"]
    res[Constants::JSON_IMAGE_URL_ORIGINAL] 	= tmp["url_original"]
    res[Constants::JSON_IMAGE_URL_MEDIUM] 	= tmp["url_medium"]
    res[Constants::JSON_IMAGE_URL_SMALL] 	= tmp["url_small"]
    res[Constants::JSON_IMAGE_ASPECT_RATIO] 	= tmp["aspect_ratio"]
    res[Constants::JSON_IMAGE_TIMESTAMP]	= tmp["timestamp"]
    res[Constants::JSON_IMAGE_STATUS] 		= tmp["status"]
    res[Constants::JSON_IMAGE_TITLE] 		= tmp["title"]
    res[Constants::JSON_IMAGE_STORAGE] 		= tmp["storage"]
    res[Constants::JSON_IMAGE_PATH_ORIGINAL] 	= tmp["path_original"]
    res[Constants::JSON_IMAGE_PATH_MEDIUM] 	= tmp["path_medium"]
    res[Constants::JSON_IMAGE_PATH_SMALL] 	= tmp["path_small"]
    res[Constants::JSON_IMAGE_LIKES] 		= tmp["likes"]
    res[Constants::JSON_IMAGE_LOCAL_URI] 	= tmp["local_uri"]
    res
  end

end
