class Api::V1::ImageTextsController < ApplicationController
  require 'mini_magick'
  require 'base64' 
  
  skip_before_action :authenticate_token
  
  def wakeup
    render json: { message: 'Server is awake' }
  end

  def preview
    image_text = ImageText.new(nickname: params[:image_text][:nickname], hobby: params[:image_text][:hobby], message: params[:image_text][:message])
    image = generate_image(image_text)

    temp_image_path = Rails.root.join('tmp', 'temp_image.jpg')
    image.write(temp_image_path)

    encoded_image = Base64.encode64(File.open(temp_image_path).read)
    File.delete(temp_image_path)

    render json: { url: "data:image/jpg;base64,#{encoded_image}" } 
  end
  
  def create
    Rails.logger.debug ENV['AWS_BUCKET'] 
    image_text = ImageText.new(image_text_params)
  
    begin
      ActiveRecord::Base.transaction do
        # 画像生成
        image = generate_image(image_text)
  
        # S3に画像をアップロードし、URLを設定
        uploader = ImageUploader.new(image)
        image_text.image_url = uploader.upload
  
        # 保存
        image_text.save!
      end
      render json: { status: 'success', message: 'Image created successfully.', url: image_text.image_url, id: image_text.id }

    rescue => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n") 
      render json: { status: 'error', message: e.message }, status: :internal_server_error
    end
  end

  def show
    image_text = ImageText.find(params[:id])
    if image_text
      render json: { image_url: image_text.image_url, id: image_text.id  }
    else
      render json: { error: "Image not found" }, status: :not_found
    end
  end

  private

  def image_text_params
    params.require(:image_text).permit(:nickname, :hobby, :message)
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
      c.annotate '-268+207', image_text.nickname
      c.annotate '+271+207', image_text.hobby

      lines = image_text.message.split("\n")
      lines.each_with_index do |line, index|
        text_position = case lines.size
        when 1
          "0,#{418 + index * 40}"
        when 2
          "0,#{396 + index * 40}"
        when 3
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
