require 'utils'

class LikeController < ApplicationController
skip_before_filter :verify_authenticity_token
include Utils

def like
  image_ids = request.headers['id']
  image_ids = image_ids == nil ? "" : image_ids
  image_ids.split(",").each do |id|
    image = Image.where(image_id: id).first
    if ( (image != nil) and (!image.likes.include?(@public_id.to_s)))
      image.add_like(@public_id.to_s)
      image.save
      Rails.logger.info( image.likes )
    end
  end
  msg = { :result => "OK" }
  respond_to do |format|
    format.json  { render :json => msg }
  end
end

def unlike
  image_ids = request.headers['id']
  image_ids = image_ids == nil ? "" : image_ids
  image_ids.split(",").each do |id|
    image = Image.where(image_id: id).first
    if image != nil
      #image.likes.delete(@public_id.to_s)
      image.remove_like(@public_id.to_s)
      image.save
    end
  end
  msg = { :result => "OK" }
  respond_to do |format|
    format.json  { render :json => msg }
  end
end

end
