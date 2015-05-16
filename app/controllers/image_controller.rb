require 'utils'
require 'uploader'
require 'rmagick'
require 'aws-sdk'
require 'constants'
require 'push'

class ImageController < ApplicationController
skip_before_filter :verify_authenticity_token
before_filter :restrict_demo_account, :except => [:get]

include Utils

# Multi-part image upload
def upload
  server_prefix = APP_CONFIG['server_prefix']

  image = params[:image]
  name = params[:name]
  local_uri = params[:uri_local]
  img_id = SecureRandom.uuid

  # Processing original image
  name_original = img_id + "_original" + File.extname(name) 
  filepath_original = Rails.root.join('public', 'uploads', name_original)
  url_original = server_prefix + "/uploads/" + name_original

  File.open( filepath_original, 'wb') do |file|
    file.write(image.read)
  end

  image_original = Magick::Image.read( filepath_original ).first
  orig_width = image_original.columns
  orig_height = image_original.rows
  aspect_ratio = orig_height.to_f / orig_width

  # Processing medium thumbnail
  name_medium = img_id + "_medium" + File.extname(name)
  filepath_medium = Rails.root.join('public', 'uploads', name_medium) 
  url_medium = server_prefix + "/uploads/" + name_medium
  medium_height = Image::MEDIUM_WIDTH * aspect_ratio
  image_medium = image_original.resize_to_fit(Image::MEDIUM_WIDTH, medium_height)
  image_medium.write( filepath_medium ){self.quality=100}

  # Processing small thumbnail
  name_small = img_id + "_small" + File.extname(name)
  filepath_small = Rails.root.join('public', 'uploads', name_small)
  url_small = server_prefix + "/uploads/" + name_small
  small_height = Image::SMALL_WIDTH * aspect_ratio
  image_small = image_original.resize_to_fit(Image::SMALL_WIDTH, small_height)
  image_small.write( filepath_small ){self.quality=100}

  # Storing ActiveRecord
  image = Image.new
  image.image_id = img_id
  image.author_id = @public_id
  image.url_original = url_original
  image.path_original = filepath_original.to_s
  image.url_medium = url_medium
  image.path_medium = filepath_medium.to_s
  image.url_small = url_small
  image.path_small = filepath_small.to_s
  image.aspect_ratio = aspect_ratio
  image.timestamp = Time.current.utc.to_time.to_i
  image.status = Image::STATUS_DEFAULT
  image.storage = Image::STORAGE_LOCAL
  image.title = ""
  if ((local_uri != nil) and (local_uri.length > 0))
    image.local_uri = local_uri
  end
  image.save

  author = User.where(id: image.author_id).first
  if (author != nil)
    followers = Friend.where(public_id_dest: author.id.to_s, status: Friend::STATUS_FRIEND)
    followers.each do |follower|
      data = {:image_id => img_id, :author => author.profile, :image => image}
      PushSender.perform(follower.public_id_src, PushSender::EVENT_NEW_IMAGE, data)
    end
  end

  msg = { :result => "OK", :data => { :id => image.image_id, :url_original => url_original, :url_medium => url_medium, :url_small => url_small, :ratio => aspect_ratio} }
  render :json => msg
end

# Share new image
def put
  json_body = JSON.parse(request.body.read)
  img_id = json_body["id"]
  img_title = json_body["title"]
  timestamp = Time.current.utc.to_time.to_i

  images = Image.where(image_id: img_id)
  if images.count > 0
    images.first.status = Image::STATUS_SHARED
    images.first.title = img_title
    images.first.timestamp = timestamp
    images.first.save
  end
  images_public = Image.where(status: Image::STATUS_SHARED)
  user_images_public = {}
  images_public.each do |image_public|
    user_images_public[image_public.image_id] = image_public.as_jsonn
  end

  msg = { :result => "OK", :data => images.first.as_jsonn }
  respond_to do |format|
    format.json  { render :json => msg }
  end
end

# Get all user images
def get
  img_id = request.headers['imageid']
  user_id = request.headers[Constants::HEADER_ID]
  if img_id != nil
    images = Image.where(author_id: @public_id.to_s, image_id: img_id.to_s)
  elsif user_id != nil
    images = Image.where(author_id: user_id, status: Image::STATUS_SHARED).order("timestamp DESC")
  else
    images = Image.where(author_id: @public_id.to_s).order("timestamp DESC").order("timestamp DESC")
  end
  user_images = []
  images.each do |image|
    user_images << image.as_jsonn
  end

  msg = { :result => "OK", :data => user_images }
  respond_to do |format|
    format.json  { render :json => msg }
  end
end

# Unshare image
def delete
  img_id = request.headers['imageid'] 
  image = Image.where(image_id: img_id.to_s).first
  if image != nil
    image.status = Image::STATUS_DEFAULT
    image.save 
    msg = { :result => "OK" }
  else
    msg = { :result => "ERROR", :msg => "Image does not exist" }
  end
  respond_to do |format|
    format.json  { render :json => msg }
  end
end

#Generate presigned url for upload
def presigned_url
  #Prepare filename
  img_id = SecureRandom.uuid
  name = request.headers['name']
  if name == nil
    name = img_id + ".jpg" 
  end
  name_original = img_id + "_original" + File.extname(name)

  #Generate presigned url
  presigned_url = S3Storage.get_presigned_url(name_original)
  public_url = S3Storage.get_public_url(name_original)

  #Save DB entry
  image = Image.new
  image.image_id = img_id
  image.url_original = public_url
  image.author_id = @public_id
  image.timestamp = Time.current.utc.to_time.to_i
  image.status = Image::STATUS_DEFAULT
  image.storage = Image::STORAGE_AWS_PENDING_UPLOAD
  image.save
  data = {:url => presigned_url, :id => img_id}
  msg = { :result => Constants::RESULT_OK, :data => data }
  respond_to do |format|
    format.json  { render :json => msg }
  end
end

#Crop and save uploaded file
def create
  img_id = request.headers['imageid']
  image = Image.where(image_id: img_id).first
  json_body = JSON.parse(request.body.read)
  if image != nil
    if ((json_body['local_uri'] != nil) && (json_body['local_uri'].length > 0))
      image.local_uri = json_body['local_uri']
    end
    if (json_body['title'] != nil)
      image.title = json_body['title']
    end
    image.save
    begin
      if Resque.info[:pending] <= 5
        Resque.enqueue(Uploader, img_id)
      else
        Uploader.perform(img_id)
      end
    rescue
      Uploader.perform(img_id)
    end
    msg = { :result => Constants::RESULT_OK}
  else
    msg = { :result => Constants::RESULT_ERROR, :code => Constants::ERROR_NOT_FOUND, :message => Constants::MSG_NOT_FOUND }
  end
  respond_to do |format|
    format.json  { render :json => msg }
  end
end

end
