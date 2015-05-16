require 'aws-sdk'

class S3Storage

  def self.upload(filename, key)
    s3 = Aws::S3::Resource.new(
      :access_key_id => APP_CONFIG['s3_access_key_id'],
      :secret_access_key => APP_CONFIG['s3_secret_access_key'],
      :region => APP_CONFIG['s3_region'])
    s3.bucket(APP_CONFIG['s3_bucket']).object(APP_CONFIG['s3_prefix'] + "/" + key).upload_file(filename, options = {:acl => "public-read"})
  end

  def self.get_presigned_url(key)
    s3 = Aws::S3::Resource.new(
      :access_key_id => APP_CONFIG['s3_access_key_id'],
      :secret_access_key => APP_CONFIG['s3_secret_access_key'],
      :region => APP_CONFIG['s3_region'])
    obj = s3.bucket(APP_CONFIG['s3_bucket']).object(APP_CONFIG['s3_prefix'] + "/" + key)
    obj.presigned_url(:put, acl: 'public-read', expires_in: 3600)
  end

  def self.get_public_url(key)
    url = "https://s3-" + APP_CONFIG['s3_region'] + ".amazonaws.com/" + APP_CONFIG['s3_bucket'] + "/" + APP_CONFIG['s3_prefix'] + "/" + key
  end

end
