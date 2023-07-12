require 'aws-sdk-s3'

class ImageUploader
  def initialize(image)
    @image = image
  end

  def upload
    s3_client = Aws::S3::Client.new(region: ENV['AWS_REGION'])
    s3_resource = Aws::S3::Resource.new(client: s3_client)
    bucket = s3_resource.bucket(ENV['AWS_BUCKET'])
    filename = SecureRandom.uuid + '.jpg'
    obj = bucket.put_object(key: filename, body: @image.to_blob)
    image_url = "https://#{ENV['AWS_BUCKET']}.s3.#{ENV['AWS_REGION']}.amazonaws.com/#{filename}"
    image_url
  end
end
