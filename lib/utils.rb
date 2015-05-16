require 'digest/sha1'
module Utils
  def find_user(phone)
    for i in 0..(Rails.cache.read("max_id") - 1)
      if phone.to_s == Rails.cache.read("phone" + i.to_s).to_s
        return  Rails.cache.read("public_id" + i.to_s)
      end
    end
    return 0
  end

  def check_user(uuid)
    logger.info "Checking user " + uuid.to_s
    for i in 0..(Rails.cache.read("max_id") - 1)
      if (uuid.to_s.length > 0) and (uuid.to_s == Rails.cache.read("private_id" + i.to_s).to_s)
        logger.info "Matched " + uuid.to_s + " to " + Rails.cache.read("public_id" + i.to_s).to_s
        return  Rails.cache.read("public_id" + i.to_s)
      end
    end
    return 0
  end

  def make_uuid
    uuid = SecureRandom.uuid
    while User.where(private_id: uuid).count > 0
      uuid = SecureRandom.uuid
    end
    return uuid
  end

  def make_sha1(str)
    Digest::SHA1.hexdigest str
  end

end
