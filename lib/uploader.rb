require 'aws-sdk'
require 'open-uri'
require 's3'

class Uploader
  @queue = :upload

  def self.perform(img_id)
    Resque.after_fork = Proc.new do
      Rails.logger.auto_flushing = true
    end

    log = Logger.new 'log/resque.log'

    image = Image.where(image_id: img_id).first

    if image == nil
      log.debug("Image " + img_id + " not found")
      return
    end

    log.debug("Start S3 upload for " + image.image_id)

    image.storage = Image::STORAGE_AWS_PENDING_CROP
    image.save

    image_original = Magick::Image.from_blob(open(image.url_original).read).first
    orig_width = image_original.columns
    orig_height = image_original.rows
    aspect_ratio = orig_height.to_f / orig_width
  
    name_medium = image.image_id + "_medium" + File.extname(URI.parse(image.url_original).path)
    filepath_medium = Rails.root.join('public', 'uploads', name_medium)
    url_medium = S3Storage.get_public_url(name_medium)
    medium_height = Image::MEDIUM_WIDTH * aspect_ratio
    if medium_height < orig_height
      image_medium = image_original.resize_to_fit(Image::MEDIUM_WIDTH, medium_height)
      image_medium.write( filepath_medium ){self.quality=100}
      S3Storage.upload(filepath_medium, name_medium)
      image.url_medium = S3Storage.get_public_url(name_medium)
      log.debug("Uploaded medium image")
    else
      image_original.write( filepath_medium ){self.quality=100}
      image.url_medium = image.url_original
      log.debug("Skipped uploading medium image")
    end
  
    name_small = image.image_id + "_small" + File.extname(URI.parse(image.url_original).path)
    filepath_small = Rails.root.join('public', 'uploads', name_small)
    url_small = S3Storage.get_public_url(name_small)
    small_height = Image::SMALL_WIDTH * aspect_ratio
    if small_height < orig_height
      image_small = image_original.resize_to_fit(Image::SMALL_WIDTH, small_height)
      image_small.write( filepath_small ){self.quality=100}
      S3Storage.upload(filepath_small, name_small)
      image.url_small = S3Storage.get_public_url(name_small)
    else
      image_original.write( filepath_small ){self.quality=100}
      image.url_small = image.url_original
    end

    image.aspect_ratio = aspect_ratio
    image.timestamp = Time.current.utc.to_time.to_i
    image.status = Image::STATUS_SHARED
    image.storage = Image::STORAGE_AWS
 
    image.save

    author = User.where(id: image.author_id).first
    if (author != nil)
      followers = Friend.where(public_id_dest: author.id.to_s, status: Friend::STATUS_FRIEND)
      followers.each do |follower|
        data = {:image_id => img_id, :author => JSON.parse(author.profile), :image => image}
        PushSender.perform(follower.public_id_src, PushSender::EVENT_NEW_IMAGE, data)
      end
    end

    log.debug("S3 upload complete for " + image.image_id)
  end

  def self.remote(name)
    return "photobook/" + name
  end

end
