class Api::V1::ImageTextsController < ApplicationController
  require 'mini_magick'
  require 'base64' 
  
  def wakeup
    render json: { message: 'Server is awake' }
  end

  def preview
    image_text = ImageText.new(answer1: params[:image_text][:answer1], answer2: params[:image_text][:answer2], answer3: params[:image_text][:answer3])
    image = generate_image(image_text)

    temp_image_path = Rails.root.join('tmp', 'temp_image.jpg')
    image.write(temp_image_path)

    encoded_image = Base64.encode64(File.open(temp_image_path).read)
    File.delete(temp_image_path)

    render json: { url: "data:image/jpg;base64,#{encoded_image}" } 
  end

  # def create
  #   image_text = ImageText.new(answer1: params[:image_text][:answer1], answer2: params[:image_text][:answer2], answer3: params[:image_text][:answer3])
  
  #   begin
  #     image = generate_image(image_text)
  #     temp_image_path = Rails.root.join('tmp', 'temp_image.jpg')
  #     image.write(temp_image_path)
  
  #     image_text.image.attach(io: File.open(temp_image_path), filename: 'temp_image.jpg')
  #     File.delete(temp_image_path)
  
  #     # Get the public URL of the uploaded image from S3
  #     s3_client = Aws::S3::Client.new(region: ENV['AWS_REGION'])
  #     s3_resource = Aws::S3::Resource.new(client: s3_client)
  #     object = s3_resource.bucket(ENV['AWS_BUCKET']).object(image_text.image.key)
  #     image_url = object.public_url
  
  #     # Save the ImageText object with the image_url
  #     image_text.image_url = image_url
  #     if image_text.save
  #       render json: { url: image_url, id: image_text.id }
  #     else
  #       render json: { errors: image_text.errors.full_messages }, status: :unprocessable_entity
  #     end
  #   rescue => e
  #     Rails.logger.error e.message
  #     Rails.logger.error e.backtrace.join("\n") 
  #     render json: { errors: [e.message] }, status: :internal_server_error
  #   end
  # end
  
  def create
    Rails.logger.debug ENV['AWS_BUCKET'] 
    image_text = ImageText.new(image_text_params)
  
    begin
      ActiveRecord::Base.transaction do
        # 画像生成
        image = generate_image(image_text)
  
        # S3リソースの初期化
        s3_client = Aws::S3::Client.new(region: ENV['AWS_REGION'])
        s3_resource = Aws::S3::Resource.new(client: s3_client)
  
        # S3のバケットを取得
        bucket = s3_resource.bucket(ENV['AWS_BUCKET_NAME'])
  
        # ファイル名を生成（ここではUUIDを使用）
        filename = SecureRandom.uuid + '.jpg'
        
        # S3に画像をアップロード
        obj = bucket.put_object(key: filename, body: image.to_blob, acl: 'public-read')
  
        # S3の公開URLを生成
        image_url = "https://#{ENV['AWS_BUCKET_NAME']}.s3.#{ENV['AWS_REGION']}.amazonaws.com/#{filename}"
  
        # URLを設定して保存
        image_text.image_url = image_url
        image_text.save!
      end
      render json: { status: 'success', message: 'Image created successfully.', url: image_url, id: image_text.id }
    rescue => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n") 
      render json: { status: 'error', message: e.message }, status: :internal_server_error
    end
  end

  def show
    image_text = 
    ImageText.find(params[:id])
    if image_text
      render json: { image_url: image_text.image_url, id: image_text.id  }
    else
      render json: { error: "Image not found" }, status: :not_found
    end
  end

  private

  def image_text_params
    params.require(:image_text).permit(:answer1, :answer2, :answer3)
  end

  def generate_image(image_text)
    # MiniMagickを使って画像を読み込む。
    image = MiniMagick::Image.open(Rails.root.join('public', 'images', 'template1.png'))

    # 画像にテキストを追加する。
    image.combine_options do |c|
      c.gravity 'North'
      c.pointsize '40'
      c.font Rails.root.join('public', 'fonts', 'Yomogi.ttf') 
      c.fill '#666666'
      # c.draw "text 0,180 '#{image_text.answer1}'"
      c.annotate '-268+207', image_text.answer1
      c.annotate '+271+207', image_text.answer2

      lines = image_text.answer3.split("\n")
      lines.each_with_index do |line, index|
        # Adjust the text position based on the line count
        text_position = case lines.size
        when 1
          # Adjust the position for 1 line text
          "0,#{418 + index * 40}"
        when 2
          # Adjust the position for 2 line text
          "0,#{396 + index * 40}"
        when 3
          # Adjust the position for 3 line text
          "0,#{380 + index * 40}"
        end
  
        image.combine_options do |c|
          c.gravity 'North'
          c.pointsize '40'
          c.font Rails.root.join('public', 'fonts', 'Yomogi.ttf')
          c.fill '#666666'
          c.draw "text #{text_position} '#{line}'"
        end
      end
    end
    
    image
  end
end
